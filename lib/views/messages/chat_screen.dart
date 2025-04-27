import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserImage;

  const ChatScreen({
    Key? key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserImage,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;
  
  late String chatId;

 @override
void initState() {
  super.initState();
  // chatId will be combination of two user ids
  final ids = [user.uid, widget.otherUserId];
  ids.sort();
  chatId = ids.join('_');
  
  // Mark messages as read when chat is opened
  markMessagesAsRead();
  syncUserInfo();
}

void markMessagesAsRead() async {
  // Update the unread count to 0 in the current user's chat record
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('chats')
      .doc(widget.otherUserId)
      .update({
    'unreadCount': 0,
  });
  
  // Mark all unread messages as read
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
  // Get current user's profile information from Firestore
  final currentUserDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
      
  final currentUserName = currentUserDoc.data()?['name'] ?? '';
  final currentUserImage = currentUserDoc.data()?['profilePic'] ?? '';

  // Update current user's chat entry for the other user if needed
  FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('chats')
      .doc(widget.otherUserId)
      .set({
    'userName': widget.otherUserName,
    'userImage': widget.otherUserImage ?? '',
  }, SetOptions(merge: true));

  // Update other user's chat entry for the current user
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

  // Get current user's profile information from Firestore
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
    'message': _controller.text.trim(),
    'timestamp': FieldValue.serverTimestamp(),
    'read': false,
  });

  // Update recent chats for current user
  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('chats')
      .doc(widget.otherUserId)
      .set({
    'chatId': chatId,
    'lastMessage': _controller.text.trim(),
    'timestamp': FieldValue.serverTimestamp(),
    'unreadCount': 0,
    'userName': widget.otherUserName,
    'userImage': widget.otherUserImage ?? '',
  });

  // Update recent chats for other user with complete sender information
  await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.otherUserId)
      .collection('chats')
      .doc(user.uid)
      .set({
    'chatId': chatId,
    'lastMessage': _controller.text.trim(),
    'timestamp': FieldValue.serverTimestamp(),
    'unreadCount': FieldValue.increment(1),
    'userName': currentUserName,  // Use name from Firestore
    'userImage': currentUserImage,
  });

  _controller.clear();
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
                    final msg = messages[index];
                    final isMe = msg['senderId'] == user.uid;

                    return Align(
  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
  child: Column(
    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [
      Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? Colors.black : const Color(0xFFD4F5C4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          msg['message'],
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 2.0, bottom: 8.0),
        child: Text(
          msg['timestamp'] != null 
              ? _formatTime(msg['timestamp'].toDate()) 
              : '',
          style: TextStyle(
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
            padding: const EdgeInsets.all(12),
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
                      color: Colors.green,
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.send, color: Colors.white),
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
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}"; // today
  } else {
    return "${time.day}/${time.month}"; // earlier dates
  }
}
}
