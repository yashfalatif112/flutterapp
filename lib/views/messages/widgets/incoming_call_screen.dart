import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homease/services/call_manager.dart';
import 'package:homease/views/messages/video_call.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:homease/views/messages/audio_call.dart';

class IncomingCallScreen extends StatefulWidget {
  final String channelName;
  final String callerName;
  final bool isAudioCall;

  const IncomingCallScreen({
    Key? key,
    required this.channelName,
    required this.callerName,
    this.isAudioCall = false,
  }) : super(key: key);

  @override
  State<IncomingCallScreen> createState() => _IncomingCallScreenState();
}

class _IncomingCallScreenState extends State<IncomingCallScreen> {
  final CallManager _callManager = CallManager();
  bool _isAnswering = false;
  StreamSubscription<DocumentSnapshot>? _callStatusSubscription;
  bool _isCallValid = true;
  
  @override
  void initState() {
    super.initState();
    
    // Cancel the notification when this screen is shown
    FlutterLocalNotificationsPlugin().cancel(0);
    
    // Initialize call manager if not already
    if (!_callManager.isInitialized) {
      _callManager.initialize();
    }
    
    // Listen for call status changes
    _listenForCallStatus();
  }
  
  void _listenForCallStatus() {
    _callStatusSubscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.channelName)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        // Call document was deleted
        if (mounted) {
          setState(() {
            _isCallValid = false;
          });
          _showCallEndedMessage("Call ended");
        }
        return;
      }

      final callData = snapshot.data();
      if (callData == null) return;

      final status = callData['status'] as String?;
      debugPrint('Incoming call status changed: $status');

      // Handle various call statuses
      if (status == 'cancelled') {
        if (mounted) {
          setState(() {
            _isCallValid = false;
          });
          _showCallEndedMessage("Call cancelled");
        }
      }
    }, onError: (error) {
      debugPrint("Error listening to call status: $error");
    });
  }
  
  void _showCallEndedMessage(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
      );
      
      // Close screen after showing error
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && context.mounted) {
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _acceptCall() async {
    if (_isAnswering || !_isCallValid) return;
    
    setState(() {
      _isAnswering = true;
    });
    
    try {
      // Request permissions before joining call
      await CallManager.handleCallPermissions();
      
      // Update call status in Firestore
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.channelName)
          .update({'status': 'connected'});
      
      // Navigate to video call screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => widget.isAudioCall
                ? AudioCallScreen(
                    channelName: widget.channelName,
                    callerName: widget.callerName,
                    isIncoming: true,
                  )
                : VideoCallScreen(
                    channelName: widget.channelName,
                    isIncoming: true,
                  ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error accepting call: $e');
      setState(() {
        _isAnswering = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept call: $e')),
        );
      }
    }
  }

  void _declineCall() async {
    try {
      // Update call status in Firestore
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.channelName)
          .update({'status': 'rejected'});
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error rejecting call: $e');
      
      // Just pop anyway
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
  
  @override
  void dispose() {
    _callStatusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If call is no longer valid, show a dismissible message
    if (!_isCallValid) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Call ended",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        _declineCall();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Colors.black,
                  ],
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Caller info
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      widget.isAudioCall ? Icons.person : Icons.videocam,
                      size: 60,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.callerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Incoming ${widget.isAudioCall ? 'Audio' : 'Video'} Call',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Call controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        icon: Icons.call_end,
                        backgroundColor: Colors.red,
                        onPressed: _declineCall,
                      ),
                      const SizedBox(width: 20),
                      _buildControlButton(
                        icon: widget.isAudioCall ? Icons.call : Icons.videocam,
                        backgroundColor: Colors.green,
                        onPressed: _acceptCall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}