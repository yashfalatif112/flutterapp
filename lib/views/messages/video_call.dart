import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homease/services/call_manager.dart';
import 'package:homease/utils/call_handler.dart';

class VideoCallScreen extends StatefulWidget {
  final String channelName;
  final bool isIncoming;

  const VideoCallScreen({
    required this.channelName,
    this.isIncoming = false,
    super.key,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
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
      if (!snapshot.exists) {
        if (mounted && context.mounted) {
          _showCallEndedMessage("Call ended");
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && context.mounted) {
              Navigator.of(context).pop();
            }
          });
        }
        return;
      }

      final callData = snapshot.data();
      if (callData == null) return;

      final status = callData['status'] as String?;
      debugPrint('Call status changed: $status');

      if (status == 'rejected') {
        if (mounted && context.mounted) {
          _showCallEndedMessage("Call declined");
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && context.mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      } else if (status == 'cancelled') {
        if (mounted && context.mounted && widget.isIncoming) {
          _showCallEndedMessage("Call cancelled");
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted && context.mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      }
    }, onError: (error) {
      debugPrint("Error listening to call status: $error");
    });
  }

  void _showCallEndedMessage(String message) {
    setState(() {
      _isConnecting = false;
      _hasError = true;
      _errorMessage = message;
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _callManager.toggleCamera();
    } else if (state == AppLifecycleState.resumed) {
      if (_callManager.isCameraOff) {
        _callManager.toggleCamera();
      }
    }
  }

  Future<void> _initializeAndJoinCall() async {
    try {
      if (!_callManager.isInitialized) {
        await _callManager.initialize();
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
            debugPrint(
                'Local user joined successfully: ${connection.channelId}');
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
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            debugPrint('Token will expire: ${connection.channelId}');
          },
        ),
      );

      await _callManager.joinCall(widget.channelName,
          asCallee: widget.isIncoming);
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
            Center(
              child: _remoteUid != null
                  ? AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: _callManager.engine,
                        canvas: VideoCanvas(uid: _remoteUid),
                        connection:
                            RtcConnection(channelId: widget.channelName),
                      ),
                    )
                  : Center(
                      child: Text(
                        _hasError
                            ? _errorMessage
                            : (_isConnecting
                                ? 'Connecting to call...'
                                : 'Waiting for remote user to join...'),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
            ),
            Positioned(
              right: 20,
              top: 50,
              width: 120,
              height: 180,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _localUserJoined
                      ? AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _callManager.engine,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  VideoCallControlButton(
                    onPressed: () => setState(() {
                      _callManager.toggleMute();
                    }),
                    icon: _callManager.isMuted ? Icons.mic_off : Icons.mic,
                    backgroundColor: _callManager.isMuted
                        ? Colors.white
                        : Colors.grey.shade800,
                    iconColor:
                        _callManager.isMuted ? Colors.black : Colors.white,
                  ),
                  VideoCallControlButton(
                    onPressed: _endCall,
                    icon: Icons.call_end,
                    backgroundColor: Colors.red,
                    iconColor: Colors.white,
                    size: 70,
                  ),
                  VideoCallControlButton(
                    onPressed: () => setState(() {
                      _callManager.toggleCamera();
                    }),
                    icon: _callManager.isCameraOff
                        ? Icons.videocam_off
                        : Icons.videocam,
                    backgroundColor: _callManager.isCameraOff
                        ? Colors.white
                        : Colors.grey.shade800,
                    iconColor:
                        _callManager.isCameraOff ? Colors.black : Colors.white,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 130,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  VideoCallControlButton(
                    onPressed: () => setState(() {
                      _callManager.switchCamera();
                    }),
                    icon: Icons.switch_camera,
                    backgroundColor: Colors.grey.shade800,
                    iconColor: Colors.white,
                    size: 50,
                  ),
                  VideoCallControlButton(
                    onPressed: () => setState(() {
                      _callManager.toggleSpeaker();
                    }),
                    icon: _callManager.isSpeakerOn
                        ? Icons.volume_up
                        : Icons.volume_off,
                    backgroundColor: _callManager.isSpeakerOn
                        ? Colors.white
                        : Colors.grey.shade800,
                    iconColor:
                        _callManager.isSpeakerOn ? Colors.black : Colors.white,
                    size: 50,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  _remoteUid != null
                      ? 'In call'
                      : (_isConnecting ? 'Connecting...' : 'Waiting...'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoCallControlButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const VideoCallControlButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.5,
        ),
      ),
    );
  }
}
