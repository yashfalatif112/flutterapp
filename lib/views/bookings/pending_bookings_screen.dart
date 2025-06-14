import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homease/views/bookings/track_booking_screen.dart';
import 'package:intl/intl.dart';

class PendingBookingsScreen extends StatelessWidget {
  const PendingBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xfffdf8ed),
      appBar: AppBar(
        backgroundColor: const Color(0xfffdf8ed),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pending Bookings',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('currentUserId', isEqualTo: currentUser?.uid)
            .where('status', isEqualTo: 'pending')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No pending bookings found'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final booking = snapshot.data!.docs[index];
              final data = booking.data() as Map<String, dynamic>;
              
              final selectedDate = (data['selectedDate'] as Timestamp).toDate();
              final today = DateTime.now();
              final isBookingToday = selectedDate.year == today.year &&
                  selectedDate.month == today.month &&
                  selectedDate.day == today.day;

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    data['serviceName'] ?? 'Unknown Service',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}'),
                      Text('Time: ${data['selectedTime']}'),
                      Text('Address: ${data['address']}'),
                      Text('Price: \$${data['price']?.toStringAsFixed(2) ?? '0.00'}'),
                    ],
                  ),
                  trailing: isBookingToday
                      ? ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TrackBookingScreen(
                                  bookingId: booking.id,
                                  serviceProviderId: data['serviceProviderId'],
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff48B1DB),
                          ),
                          child: const Text('Track',style: TextStyle(
                            color:Colors.white,
                          ),),
                        )
                      : Text(
                          isBookingToday ? 'Today' : 'Not available for tracking',
                          style: TextStyle(
                            color: isBookingToday ? Colors.green : Colors.grey,
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 