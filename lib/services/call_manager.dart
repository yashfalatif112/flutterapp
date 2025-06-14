import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:homease/services/token_service.dart';
import 'dart:math' as Math;

class CallManager {
  static final CallManager _instance = CallManager._internal();
  factory CallManager() => _instance;
  CallManager._internal();

  // Keep your existing app ID
  static const String appId = '5d2a2254ac774f13bf57006c2df53a5b';

  // Create an instance of TokenService
  final TokenService _tokenService = TokenService();

  late RtcEngine _engine;
  bool _isInitialized = false;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _inCall = false;
  StreamSubscription<DocumentSnapshot>? _callStatusSubscription;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isMuted => _isMuted;
  bool get isCameraOff => _isCameraOff;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get inCall => _inCall;
  RtcEngine get engine => _engine;

  Future<void> initialize({bool isAudioOnly = false}) async {
    if (_isInitialized) return;

    try {
      // Request permissions first
      await handleCallPermissions();

      _engine = createAgoraRtcEngine();
      await _engine.initialize(const RtcEngineContext(appId: appId));

      if (!isAudioOnly) {
        // Configure video settings only for video calls
        await _engine.enableVideo();
        await _engine.setVideoEncoderConfiguration(
          const VideoEncoderConfiguration(
            dimensions: VideoDimensions(width: 640, height: 480),
            frameRate: 30,
            bitrate: 0, // Auto bitrate
          ),
        );
      } else {
        // Disable video for audio-only calls
        await _engine.disableVideo();
      }

      // Set default audio mode
      await _engine.setAudioProfile(
        profile: AudioProfileType.audioProfileDefault,
        scenario: AudioScenarioType.audioScenarioChatroom,
      );

      _isInitialized = true;
      debugPrint('Agora RTC Engine initialized successfully');
    } catch (e) {
      debugPrint('Initialization error: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> joinCall(String channelName, {bool asCallee = false, bool isAudioOnly = false}) async {
    if (!_isInitialized) {
      debugPrint('Initializing engine before joining call');
      await initialize(isAudioOnly: isAudioOnly);
    }

    try {
      // Get current user for consistent UID
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User must be logged in to join a call');
      }

      // Create a numeric UID from the Firebase UID - ensure it's positive and within int range
      final int uid = currentUser.uid.hashCode.abs() % 100000;
      debugPrint('Joining call with UID: $uid, Channel: $channelName');

      // Fetch token from token service with retry logic
      final String token = await _tokenService.getToken(channelName);
      if (token.isEmpty) {
        throw Exception('Failed to get a valid token');
      }
      debugPrint('Successfully retrieved token for channel: $channelName');

      if (!isAudioOnly) {
        // Start local video preview only for video calls
        await _engine.startPreview();
        debugPrint('Local preview started');

        // Enable video module
        await _engine.enableVideo();
      }

      // Set channel profile as communication
      await _engine
          .setChannelProfile(ChannelProfileType.channelProfileCommunication);

      // Set client role
      await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

      debugPrint(
          'Joining channel with token: ${token.substring(0, Math.min(20, token.length))}... (truncated)');

      // Join the channel WITH THE TOKEN
      try {
        await _engine.joinChannel(
          token: token,
          channelId: channelName,
          uid: uid,
          options: ChannelMediaOptions(
            channelProfile: ChannelProfileType.channelProfileCommunication,
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
            autoSubscribeAudio: true,
            autoSubscribeVideo: !isAudioOnly,
            publishCameraTrack: !isAudioOnly,
            publishMicrophoneTrack: true,
          ),
        );
        debugPrint('Successfully joined channel: $channelName');
        _inCall = true;

        if (asCallee) {
          await FirebaseFirestore.instance
              .collection('calls')
              .doc(channelName)
              .update({'status': 'connected'});
        }
      } on AgoraRtcException catch (e) {
        debugPrint('Error joining channel: ${e.code} - ${e.message}');
        // Handle specific error codes if necessary
      } catch (e) {
        debugPrint('Unexpected error joining channel: $e');
        // Handle other exceptions
      }
    } catch (e) {
      debugPrint('Detailed error joining call: $e');
      // Additional error handling logic
      if (e is AgoraRtcException) {
        switch (e.code) {
          case -102: // Invalid channel name or token
            debugPrint(
                'Invalid channel name or token - Check token generation and UID consistency');
            break;
          case -110: // Network error
            debugPrint('Network connection error');
            break;
          default:
            debugPrint('Unexpected Agora error: ${e.code}');
        }
      }
      rethrow; // Rethrow to handle in UI
    }
  }

  // The rest of your methods remain the same
  Future<void> endCall(String channelName) async {
    if (!_isInitialized) return;

    try {
      // Stop preview and leave channel
      await _engine.stopPreview();
      await _engine.leaveChannel();

      _inCall = false;

      // Update call status in Firestore
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(channelName)
          .update({'status': 'ended'});

      debugPrint('Successfully ended call: $channelName');
    } catch (e) {
      debugPrint('Error ending call: $e');
    }
  }

  Future<void> initiateCall(String channelName, String callerId,
      String receiverId, String callerName) async {
    try {
      debugPrint('Initiating call: $channelName');

      // Create a call document in Firestore
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(channelName)
          .set({
        'callerId': callerId,
        'receiverId': receiverId,
        'callerName': callerName,
        'channelName': channelName,
        'status': 'ringing',
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint('Call document created in Firestore');

      // Monitor call status for changes
      _callStatusSubscription = FirebaseFirestore.instance
          .collection('calls')
          .doc(channelName)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final status = snapshot.data()?['status'];
          debugPrint('Call status updated: $status');
          if (status == 'rejected') {
            endCall(channelName);
          }
        }
      });
    } catch (e) {
      debugPrint('Error initiating call: $e');
      rethrow;
    }
  }

  Future<void> toggleMute() async {
    if (!_isInitialized) return;
    _isMuted = !_isMuted;
    await _engine.muteLocalAudioStream(_isMuted);
  }

  Future<void> toggleCamera() async {
    if (!_isInitialized) return;
    _isCameraOff = !_isCameraOff;
    await _engine.muteLocalVideoStream(_isCameraOff);
  }

  Future<void> switchCamera() async {
    if (!_isInitialized) return;
    await _engine.switchCamera();
  }

  Future<void> toggleSpeaker() async {
    if (!_isInitialized) return;
    _isSpeakerOn = !_isSpeakerOn;
    await _engine.setEnableSpeakerphone(_isSpeakerOn);
  }

  void dispose() {
    if (_isInitialized) {
      _engine.leaveChannel();
      _engine.release();
      _isInitialized = false;
    }

    _callStatusSubscription?.cancel();
  }

  static Future<void> handleCallPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }
}
