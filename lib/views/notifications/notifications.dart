import 'package:flutter/material.dart';
import 'package:homease/views/reviews/reviews.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6ED),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6ED),
        elevation: 0,
        centerTitle: true,
        title:
            const Text('Notifications', style: TextStyle(color: Colors.black)),
        leading:
            const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Electrician',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Icon(Icons.tune),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section Titles
            _buildSectionTitle('Recent'),
            _buildNotificationTile(
                image: 'assets/images/user1.jpg',
                title: 'Work completed',
                subtitle: 'You got money rating from your client',
                date: '2/27/2025',
                buttonText: 'Rating employee',
                buttonColor: Colors.green,
                context: context),
            _buildNotificationTile(
                image: 'assets/images/user2.jpg',
                title: 'Work completed',
                subtitle: 'You got money rating from your client',
                date: '2/27/2025',
                buttonText: 'Rating employee',
                buttonColor: Colors.green,
                context: context),

            _buildSectionTitle('Yesterday'),
            _buildNotificationTile(
                image: null,
                title: 'Bank details updated.',
                subtitle: 'You got money rating from your client',
                date: '2/27/2025',
                buttonText: 'Rating client',
                buttonColor: Colors.green,
                context: context),
            _buildNotificationTile(
                image: null,
                title: 'Bank details updated.',
                subtitle: 'You got money rating from your client',
                date: '2/23/2025',
                buttonText: null,
                context: context),

            _buildSectionTitle('Weekday'),
            _buildNotificationTile(
                image: 'assets/images/user3.jpg',
                title: 'Project assigned',
                subtitle: 'New project assigned to you',
                date: '2/15/2025',
                buttonText: 'View Project',
                buttonColor: Colors.blue,
                context: context),

            _buildSectionTitle('This Month'),
            _buildNotificationTile(
                image: 'assets/images/user4.jpg',
                title: 'Payment received',
                subtitle: 'You received payment for your work',
                date: '1/10/2025',
                buttonText: 'View Details',
                buttonColor: Colors.orange,
                context: context),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNotificationTile(
      {String? image,
      required String title,
      required String subtitle,
      required String date,
      String? buttonText,
      Color? buttonColor,
      context}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: image != null ? AssetImage(image) : null,
            backgroundColor: Colors.grey.shade300,
            radius: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                if (buttonText != null)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RatingScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: buttonColor ?? Colors.grey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(buttonText,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ),
                  )
                else
                  const SizedBox(height: 0),
              ],
            ),
          ),
          Text(date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
