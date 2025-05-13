import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homease/services/call_manager.dart';
import 'package:homease/views/messages/video_call.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class IncomingCallScreen extends StatefulWidget {
  final String channelName;
  final String callerName;

  const IncomingCallScreen({
    Key? key,
    required this.channelName,
    required this.callerName,
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
            builder: (_) => VideoCallScreen(
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

  void _rejectCall() async {
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
        _rejectCall();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Caller avatar
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade800,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                // Caller name
                Text(
                  widget.callerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                // Call status
                const Text(
                  'Incoming video call...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                // Call controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Reject button
                      GestureDetector(
                        onTap: _rejectCall,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                      // Accept button
                      GestureDetector(
                        onTap: _acceptCall,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: _isAnswering
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                )
                              : const Icon(
                                  Icons.videocam,
                                  color: Colors.white,
                                  size: 35,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}