import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homease/services/call_manager.dart';
import 'package:homease/services/call_notification_handler.dart';
import 'package:homease/services/voice_message_service.dart';
import 'package:homease/views/messages/video_call.dart';
import 'package:homease/views/messages/audio_call.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;

  const ChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  final _voiceService = VoiceMessageService();

  late String chatId;
  StreamSubscription<DocumentSnapshot>? _callSub;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();

    final ids = [user.uid, widget.otherUserId];
    ids.sort();
    chatId = ids.join('_');

    markMessagesAsRead();
    syncUserInfo();
    initCallNotifications();
  }

  void initCallNotifications() {
    CallNotificationHandler().updateFcmToken();
  }

  @override
  void dispose() {
    _callSub?.cancel();
    _voiceService.dispose();
    super.dispose();
  }

  void _startCall({bool isAudioCall = false}) async {
    await CallManager.handleCallPermissions();

    final timestamp =
        DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    final channelName =
        'ch_${user.uid.substring(0, 5)}_${widget.otherUserId.substring(0, 5)}_$timestamp';

    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final currentUserName = currentUserDoc.data()?['name'] ?? 'Unknown User';

    final callManager = CallManager();
    if (!callManager.isInitialized) {
      await callManager.initialize(isAudioOnly: isAudioCall);
    }

    await callManager.initiateCall(
      channelName,
      user.uid,
      widget.otherUserId,
      currentUserName,
    );

    await CallNotificationHandler().sendCallNotification(
      widget.otherUserId,
      channelName,
      currentUserName,
      isAudioCall: isAudioCall,
    );

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => isAudioCall
              ? AudioCallScreen(
                  channelName: channelName,
                  callerName: widget.otherUserName,
                  isIncoming: false,
                )
              : VideoCallScreen(
                  channelName: channelName,
                ),
        ),
      );
    }
  }

  void markMessagesAsRead() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .doc(widget.otherUserId)
        .update({
      'unreadCount': 0,
    }).catchError((_) {});

    final unreadMessages = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isEqualTo: widget.otherUserId)
        .where('read', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  void syncUserInfo() async {
    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final currentUserName = currentUserDoc.data()?['name'] ?? '';
    final currentUserImage = currentUserDoc.data()?['profilePic'] ?? '';

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .doc(widget.otherUserId)
        .set({
      'userName': widget.otherUserName,
      'userImage': widget.otherUserImage ?? '',
    }, SetOptions(merge: true));

    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherUserId)
        .collection('chats')
        .doc(user.uid)
        .set({
      'userName': currentUserName,
      'userImage': currentUserImage,
    }, SetOptions(merge: true));
  }

  void sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final messageText = _controller.text.trim();
    _controller.clear(); // Clear immediately

    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final currentUserName = currentUserDoc.data()?['name'] ?? '';
    final currentUserImage = currentUserDoc.data()?['profilePic'] ?? '';

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'receiverId': widget.otherUserId,
      'message': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .doc(widget.otherUserId)
        .set({
      'chatId': chatId,
      'lastMessage': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'unreadCount': 0,
      'userName': widget.otherUserName,
      'userImage': widget.otherUserImage ?? '',
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.otherUserId)
        .collection('chats')
        .doc(user.uid)
        .set({
      'chatId': chatId,
      'lastMessage': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'unreadCount': FieldValue.increment(1),
      'userName': currentUserName,
      'userImage': currentUserImage,
    });
  }

  Future<void> _startVoiceRecording() async {
    try {
      await _voiceService.startRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start recording: $e')),
      );
    }
  }

  Future<void> _stopVoiceRecording() async {
    try {
      final filePath = await _voiceService.stopRecording();
      setState(() {
        _isRecording = false;
      });

      if (filePath != null) {
        final downloadUrl = await _voiceService.uploadVoiceMessage(filePath, chatId);
        
        final currentUserDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final currentUserName = currentUserDoc.data()?['name'] ?? '';
        final currentUserImage = currentUserDoc.data()?['profilePic'] ?? '';

        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add({
          'senderId': user.uid,
          'receiverId': widget.otherUserId,
          'message': downloadUrl,
          'type': 'voice',
          'timestamp': FieldValue.serverTimestamp(),
          'read': false,
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('chats')
            .doc(widget.otherUserId)
            .set({
          'chatId': chatId,
          'lastMessage': '🎤 Voice message',
          'timestamp': FieldValue.serverTimestamp(),
          'unreadCount': 0,
          'userName': widget.otherUserName,
          'userImage': widget.otherUserImage ?? '',
        });

        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.otherUserId)
            .collection('chats')
            .doc(user.uid)
            .set({
          'chatId': chatId,
          'lastMessage': '🎤 Voice message',
          'timestamp': FieldValue.serverTimestamp(),
          'unreadCount': FieldValue.increment(1),
          'userName': currentUserName,
          'userImage': currentUserImage,
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send voice message: $e')),
      );
    }
  }

  Widget _buildMessageContent(Map<String, dynamic> msg) {
    final isMe = msg['senderId'] == user.uid;
    final isVoiceMessage = msg['type'] == 'voice';

    if (isVoiceMessage) {
      return GestureDetector(
        onTap: () => _voiceService.playVoiceMessage(msg['message']),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isMe ? const Color(0xff48B1DB) : const Color(0xFFD4F5C4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow,
                color: isMe ? Colors.white : Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                'Voice message',
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xff48B1DB) : const Color(0xFFD4F5C4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        msg['message'],
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCF9),
        elevation: 0,
        centerTitle: true,
        title: Text(widget.otherUserName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 8),
            icon: const Icon(Icons.call, color: Colors.black),
            onPressed: () => _startCall(isAudioCall: true),
          ),
          IconButton(
            padding: const EdgeInsets.only(right: 15),
            icon: const Icon(Icons.videocam, color: Colors.black),
            onPressed: () => _startCall(isAudioCall: false),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index].data();
                    final isMe = msg['senderId'] == user.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          _buildMessageContent(msg),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0, bottom: 8.0),
                            child: Text(
                              msg['timestamp'] != null
                                  ? _formatTime(msg['timestamp'].toDate())
                                  : '',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 25),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Message",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: sendMessage,
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xff48B1DB),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onLongPressStart: (_) => _startVoiceRecording(),
                  onLongPressEnd: (_) => _stopVoiceRecording(),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red : const Color(0xff48B1DB),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    } else {
      return "${time.day}/${time.month}";
    }
  }
}
