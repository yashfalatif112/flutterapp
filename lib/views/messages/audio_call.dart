import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homease/services/call_manager.dart';
import 'package:homease/utils/call_handler.dart';

class AudioCallScreen extends StatefulWidget {
  final String channelName;
  final bool isIncoming;
  final String callerName;

  const AudioCallScreen({
    Key? key,
    required this.channelName,
    required this.callerName,
    this.isIncoming = false,
  }) : super(key: key);

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen>
    with WidgetsBindingObserver {
  final CallManager _callManager = CallManager();
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _isConnecting = true;
  bool _hasError = false;
  String _errorMessage = '';
  StreamSubscription<DocumentSnapshot>? _callStatusSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    Future.microtask(() {
      _initializeAndJoinCall();
      _listenForCallStatusChanges();
    });
  }

  void _listenForCallStatusChanges() {
    _callStatusSubscription = FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.channelName)
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;

      final status = snapshot.data()?['status'] as String?;
      if (status == 'ended' || status == 'cancelled') {
        _endCall();
      }
    });
  }

  Future<void> _initializeAndJoinCall() async {
    try {
      if (!_callManager.isInitialized) {
        await _callManager.initialize(isAudioOnly: true);
      }

      _callManager.engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            if (mounted) {
              setState(() {
                _localUserJoined = true;
                _isConnecting = false;
              });
            }
            debugPrint('Local user joined successfully: ${connection.channelId}');
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            if (mounted) {
              setState(() {
                _remoteUid = remoteUid;
                _isConnecting = false;
              });
            }
            debugPrint('Remote user joined: $remoteUid');
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            if (mounted) {
              setState(() {
                _remoteUid = null;
              });
            }
            debugPrint('Remote user offline: $remoteUid, reason: $reason');

            if (reason == UserOfflineReasonType.userOfflineQuit) {
              _endCall();
            }
          },
          onConnectionStateChanged: (RtcConnection connection,
              ConnectionStateType state, ConnectionChangedReasonType reason) {
            debugPrint('Connection state changed: $state, reason: $reason');

            if (state == ConnectionStateType.connectionStateConnected) {
              if (mounted) {
                setState(() {
                  _isConnecting = false;
                });
              }
            } else if (state == ConnectionStateType.connectionStateFailed ||
                state == ConnectionStateType.connectionStateDisconnected) {
              if (mounted &&
                  reason !=
                      ConnectionChangedReasonType
                          .connectionChangedLeaveChannel) {
                setState(() {
                  _hasError = true;
                  _errorMessage = 'Connection failed: ${reason.toString()}';
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(_errorMessage)));
                }

                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    _endCall();
                  }
                });
              }
            }
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint("Agora error: $err, msg: $msg");

            if (mounted) {
              setState(() {
                _hasError = true;
                _errorMessage = 'Call error: ${err.toString()}';
              });

              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(_errorMessage)));
              }

              if (err == ErrorCodeType.errTokenExpired ||
                  err == ErrorCodeType.errInvalidToken) {
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted && context.mounted) {
                    Navigator.of(context).pop();
                  }
                });
              }
            }
          },
        ),
      );

      await _callManager.joinCall(widget.channelName,
          asCallee: widget.isIncoming, isAudioOnly: true);
    } catch (e) {
      debugPrint("Error in _initializeAndJoinCall: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to join call: ${e.toString()}';
          _isConnecting = false;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(_errorMessage)));
        }

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && context.mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    }
  }

  void _endCall() async {
    if (!widget.isIncoming) {
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.channelName)
          .update({'status': 'cancelled'}).catchError(
              (e) => debugPrint("Error updating call status: $e"));
    } else {
      await FirebaseFirestore.instance
          .collection('calls')
          .doc(widget.channelName)
          .update({'status': 'ended'}).catchError(
              (e) => debugPrint("Error updating call status: $e"));
    }

    _callManager.endCall(widget.channelName);
    if (mounted && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _callStatusSubscription?.cancel();
    _callManager.engine.unregisterEventHandler(
        RtcEngineEventHandler(onJoinChannelSuccess: (_, __) {}));
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _endCall();
        return true;
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
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.callerName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isConnecting
                        ? 'Connecting...'
                        : _remoteUid != null
                            ? 'Connected'
                            : 'Calling...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                  // Call controls
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mute button
                        IconButton(
                          icon: Icon(
                            _callManager.isMuted
                                ? Icons.mic_off
                                : Icons.mic,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => _callManager.toggleMute(),
                        ),
                        // End call button
                        FloatingActionButton(
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.call_end),
                          onPressed: _endCall,
                        ),
                        // Speaker button
                        IconButton(
                          icon: Icon(
                            _callManager.isSpeakerOn
                                ? Icons.volume_up
                                : Icons.volume_off,
                            color: Colors.white,
                            size: 30,
                          ),
                          onPressed: () => _callManager.toggleSpeaker(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 