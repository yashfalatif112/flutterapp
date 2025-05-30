import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                  _isSearching = _searchQuery.isNotEmpty;
                });
              },
              decoration: InputDecoration(
                hintText: "Search in your chats...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _isSearching = false;
                          });
                        },
                      )
                    : null,
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
              child: _isSearching ? _buildSearchResults(user) : _buildChatList(user),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('chats')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter chats based on userName
        final filteredChats = snapshot.data!.docs.where((doc) {
          final chatData = doc.data() as Map<String, dynamic>;
          final userName = chatData['userName']?.toString().toLowerCase() ?? '';
          return userName.contains(_searchQuery);
        }).toList();

        if (filteredChats.isEmpty) {
          return const Center(
            child: Text(
              'No chats found',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredChats.length,
          itemBuilder: (context, index) {
            final chat = filteredChats[index];
            final chatData = chat.data() as Map<String, dynamic>;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      otherUserId: chat.id,
                      otherUserName: chatData['userName'] ?? '',
                      otherUserImage: chatData['userImage'] ?? '',
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: chatData['userImage'] != null &&
                                chatData['userImage'].isNotEmpty
                            ? NetworkImage(chatData['userImage'])
                            : null,
                        child: chatData['userImage'] == null ||
                                chatData['userImage'].isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          chatData['userName'] ?? 'User',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            chatData['timestamp'] != null
                                ? _formatTime(chatData['timestamp'].toDate())
                                : '',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 4),
                          if (chatData['unreadCount'] != null &&
                              chatData['unreadCount'] > 0)
                            CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 10,
                              child: Text(
                                chatData['unreadCount'].toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
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
    );
  }

  Widget _buildChatList(User user) {
    return StreamBuilder(
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
          return const Center(
            child: Text(
              'No conversations yet\nSearch for users to start chatting',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            if (chat['userName'] == null || chat['userName'].isEmpty) {
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
                    'userName': userData['name'] ?? 'User',
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
                        backgroundImage: chat['userImage'] != null &&
                                chat['userImage'].isNotEmpty
                            ? NetworkImage(chat['userImage'])
                            : null,
                        child: chat['userImage'] == null ||
                                chat['userImage'].isEmpty
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(chat['userName'] ?? 'User',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              chat['timestamp'] != null
                                  ? _formatTime(chat['timestamp'].toDate())
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
                                    color: Colors.white, fontSize: 12),
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