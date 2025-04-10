import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> messages = [
      {
        "fromMe": false,
        "message": "Hey Olivia, can you please review the latest design when you can?"
      },
      {
        "fromMe": true,
        "message": "That sounds great! I'm in. What time works for you?"
      },
      {
        "fromMe": false,
        "message": "Hey Olivia, can you please review the latest design when you can?"
      },
      {
        "fromMe": true,
        "message": "That sounds great! I'm in. What time works for you?"
      },
      {
        "fromMe": false,
        "message": "Hey Olivia, can you please review the latest design when you can?"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCF9),
        elevation: 0,
        centerTitle: true,
        title: const Text("Inbox"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.more_vert),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final bool isMe = msg['fromMe'] as bool;

                return Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundImage: AssetImage("assets/images/book.png"),
                            ),
                            SizedBox(width: 8),
                            Text("Phoenix Baker",
                                style: TextStyle(fontSize: 12, color: Colors.black)),
                            Spacer(),
                            Text("Friday 2:20pm",
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
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
                    ),
                  ],
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
                    child: const TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Message",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
