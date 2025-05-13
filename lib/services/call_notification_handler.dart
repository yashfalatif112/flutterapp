import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:homease/views/messages/widgets/incoming_call_screen.dart';

// This handles background messages when the app is closed or in the background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize important services for background handling
  // Note: You'll need to register this function in your main.dart
  
  if (message.data['type'] == 'video_call') {
    final CallNotificationHandler handler = CallNotificationHandler();
    await handler.handleBackgroundMessage(message);
  }
}

class CallNotificationHandler {
  static final CallNotificationHandler _instance =
      CallNotificationHandler._internal();
  factory CallNotificationHandler() => _instance;
  CallNotificationHandler._internal();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isInitialized = false;
  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> initializeAppLevel() async {
    if (_isInitialized) return;

    try {
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@drawable/ic_notification');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialize local notifications and set up callback for notification taps
      await _flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
            android: androidSettings, iOS: iosSettings),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationTap(response.payload);
        },
      );

      // Create a high priority channel for call notifications
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'call_channel',
        'Video Calls',
        description: 'Notifications for incoming video calls',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('ringtone'),
        enableVibration: true,
        enableLights: true,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Request critical permissions 
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        criticalAlert: true,  // Important for calls
        announcement: true,   // Allow notifications to be announced
      );

      // Set foreground notification presentation options
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Listen for messages when app is in foreground
      FirebaseMessaging.onMessage.listen(_handleIncomingMessage);

      // Listen for when a notification is tapped which opens the app
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.data['type'] == 'video_call') {
          _handleNotificationTap(message.data['channelName']);
        }
      });

      try {
        await updateFcmToken();
      } catch (e) {
        debugPrint('Failed to update FCM token: $e');
        Future.delayed(const Duration(minutes: 5), () => updateFcmToken());
      }

      _setupGlobalCallListener();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize CallNotificationHandler: $e');
      Future.delayed(const Duration(minutes: 1), () => initializeAppLevel());
    }
  }

  void setNavigatorKey(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  void _handleIncomingMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.data}');
    if (message.data['type'] == 'video_call') {
      final String channelName = message.data['channelName'] ?? '';
      final String callerName = message.data['callerName'] ?? 'Unknown';

      _showIncomingCallNotification(channelName, callerName);

      if (_navigatorKey?.currentState != null) {
        _navigatorKey!.currentState!.push(
          MaterialPageRoute(
            builder: (_) => IncomingCallScreen(
              channelName: channelName,
              callerName: callerName,
            ),
          ),
        );
      }
    }
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Background message received: ${message.data}');
    if (message.data['type'] == 'video_call') {
      final String channelName = message.data['channelName'] ?? '';
      final String callerName = message.data['callerName'] ?? 'Unknown';

      await _showIncomingCallNotification(channelName, callerName);
    }
  }

  Future<void> _showIncomingCallNotification(
      String channelName, String callerName) async {
    // Create Android-specific notification details with full screen intent
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
      'call_channel',
      'Video Calls',
      channelDescription: 'Notifications for incoming video calls',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('ringtone'),
      ongoing: true,
      visibility: NotificationVisibility.public,
      ticker: 'Incoming video call',
      category: AndroidNotificationCategory.call,
      actions: [
        AndroidNotificationAction('accept', 'Accept', 
            showsUserInterface: true, cancelNotification: true),
        AndroidNotificationAction('decline', 'Decline',
            showsUserInterface: true, cancelNotification: true),
      ]
    );

    // Create iOS-specific notification details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'ringtone.aiff',
      interruptionLevel: InterruptionLevel.timeSensitive,
      categoryIdentifier: 'INCOMING_CALL',
    );

    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,  // Use a unique ID for each call
      'Incoming Call',
      '$callerName is calling you',
      details,
      payload: channelName,
    );
  }

  void _handleNotificationTap(String? payload) {
    if (payload != null && _navigatorKey?.currentState != null) {
      FirebaseFirestore.instance
          .collection('calls')
          .doc(payload)
          .get()
          .then((snapshot) {
        if (snapshot.exists && snapshot.data()?['status'] == 'ringing') {
          final callerName = snapshot.data()?['callerName'] ?? 'Unknown';

          _navigatorKey!.currentState!.push(
            MaterialPageRoute(
              builder: (_) => IncomingCallScreen(
                channelName: payload,
                callerName: callerName,
              ),
            ),
          );
        }
      });
    }
  }

  void _setupGlobalCallListener() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    FirebaseFirestore.instance
        .collection('calls')
        .where('receiverId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'ringing')
        .snapshots()
        .listen((snapshot) {
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final channelName = data['channelName'];
        final callerName = data['callerName'] ?? 'Unknown';

        final timestamp = data['timestamp'] as Timestamp?;
        if (timestamp != null) {
          final callTime = timestamp.toDate();
          final now = DateTime.now();
          if (now.difference(callTime).inSeconds < 30) {
            _showIncomingCallNotification(channelName, callerName);

            if (_navigatorKey?.currentState != null) {
              _navigatorKey!.currentState!.push(
                MaterialPageRoute(
                  builder: (_) => IncomingCallScreen(
                    channelName: channelName,
                    callerName: callerName,
                  ),
                ),
              );
            }
          }
        }
      }
    });
  }

  Future<void> initialize(BuildContext context) async {
    if (_isInitialized) return;

    await initializeAppLevel();
  }

  Future<void> sendCallNotification(
      String receiverId, String channelName, String callerName) async {
    final receiverDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .get();

    final fcmToken = receiverDoc.data()?['fcmToken'];

    if (fcmToken != null) {
      final message = {
        'to': fcmToken,
        'priority': 'high',
        'data': {
          'type': 'video_call',
          'channelName': channelName,
          'callerName': callerName,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK', // Important for opening the app
        },
        'notification': {
          'title': 'Incoming Call',
          'body': '$callerName is calling you',
          'sound': 'ringtone.mp3',
          'android_channel_id': 'call_channel',
          'tag': 'call', // Use tag for call notifications
        },
        'android': {
          'priority': 'high',
          'notification': {
            'channel_id': 'call_channel',
            'sound': 'ringtone',
            'priority': 'max',
            'visibility': 'public',
            'tag': 'call',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
          'direct_boot_ok': true, // Work in direct boot mode
        },
        'apns': {
          'headers': {
            'apns-priority': '10', // High priority
            'apns-push-type': 'alert',
          },
          'payload': {
            'aps': {
              'sound': 'ringtone.aiff',
              'category': 'INCOMING_CALL',
              'content-available': 1,
              'interruption-level': 'time-sensitive',
              'mutable-content': 1,
            },
          },
        },
      };

      await FirebaseFirestore.instance.collection('notifications').add({
        'receiverId': receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> updateFcmToken() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'fcmToken': token});
            
        debugPrint('FCM Token updated: ${token.substring(0, 10)}...');
      }
      
      // Listen for token refreshes
      _firebaseMessaging.onTokenRefresh.listen((String token) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'fcmToken': token});
            
        debugPrint('FCM Token refreshed: ${token.substring(0, 10)}...');
      });
    } catch (e) {
      debugPrint('Failed to get FCM token: $e');
      Future.delayed(const Duration(minutes: 5), () => updateFcmToken());
    }
  }

  // Make sure notification channels are created when the app starts
  Future<void> ensureChannelsCreated() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'call_channel',
      'Video Calls',
      description: 'Notifications for incoming video calls',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('ringtone'),
      enableVibration: true,
      enableLights: true,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}