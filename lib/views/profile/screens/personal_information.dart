import 'package:flutter/material.dart';

class PersonalInformationScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const PersonalInformationScreen({Key? key, required this.userData}) : super(key: key);

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xff48B1DB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Color(0xff48B1DB),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.green.withOpacity(0.2),
                    width: 3,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: userData['profileImage'] != null && 
                                 userData['profileImage'].toString().isNotEmpty
                      ? NetworkImage(userData['profileImage'])
                      : null,
                  child: userData['profileImage'] == null || 
                         userData['profileImage'].toString().isEmpty
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[400],
                        )
                      : null,
                ),
              ),
              // Positioned(
              //   bottom: 0,
              //   right: 0,
              //   child: Container(
              //     padding: const EdgeInsets.all(6),
              //     decoration: BoxDecoration(
              //       color: Colors.green,
              //       shape: BoxShape.circle,
              //       border: Border.all(color: Colors.white, width: 2),
              //     ),
              //     child: const Icon(
              //       Icons.verified,
              //       color: Colors.white,
              //       size: 16,
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            userData['name'] ?? 'User Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            userData['email'] ?? 'user@example.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return 'Not available';
    
    try {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(
        timestamp.millisecondsSinceEpoch
      );
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Not available';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profile Information',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // leading: IconButton(
        //   icon: Container(
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.circular(12),
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.grey.withOpacity(0.1),
        //           spreadRadius: 1,
        //           blurRadius: 3,
        //           offset: const Offset(0, 1),
        //         ),
        //       ],
        //     ),
        //     child: Center(
        //       child: const Icon(
        //         Icons.arrow_back_ios,
        //         color: Colors.black87,
        //         size: 18,
        //       ),
        //     ),
        //   ),
        //   onPressed: () => Navigator.pop(context),
        // ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildInfoCard(
                'Phone Number',
                userData['phone'] ?? 'Not provided',
                Icons.phone,
              ),
              
              _buildInfoCard(
                'Email Address',
                userData['email'] ?? 'Not provided',
                Icons.email,
              ),
              
              _buildInfoCard(
                'Address',
                userData['address'] ?? 'Not provided',
                Icons.location_on,
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Account Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildInfoCard(
                'Member Since',
                _formatDate(userData['createdAt']),
                Icons.calendar_today,
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}