import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFCF5),
        elevation: 0,
        title: const Text("Message",
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('chats')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final chats = snapshot.data!.docs;

                  if (chats.isEmpty) {
                    return const Center(child: Text('No conversations yet'));
                  }

                  return ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      if (chat['userName'] == null ||
                          chat['userName'].isEmpty) {
                        // Fetch missing user data from users collection
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(chat.id)
                            .get()
                            .then((userData) {
                          if (userData.exists) {
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('chats')
                                .doc(chat.id)
                                .update({
                              'userName': userData['name'] ??
                                  'User', // Use name from Firestore
                              'userImage': userData['profilePic'] ?? '',
                            });
                          }
                        });
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                        otherUserId: chat.id,
                                        otherUserName: chat['userName'] ?? '',
                                        otherUserImage: chat['userImage'],
                                      )));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: chat['userImage'] != null
                                      ? NetworkImage(chat['userImage'])
                                      : null,
                                  child: chat['userImage'] == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(chat['userName'] ?? 'User',
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black)),
                                      const SizedBox(height: 4),
                                      Text(chat['lastMessage'] ?? '',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        chat['timestamp'] != null
                                            ? _formatTime(
                                                chat['timestamp'].toDate())
                                            : '',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    if (chat['unreadCount'] != null &&
                                        chat['unreadCount'] > 0)
                                      CircleAvatar(
                                        backgroundColor: Colors.green,
                                        radius: 10,
                                        child: Text(
                                          chat['unreadCount'].toString(),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
