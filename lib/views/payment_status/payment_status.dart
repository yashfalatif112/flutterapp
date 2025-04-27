import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentStatus extends StatefulWidget {
  const PaymentStatus({Key? key}) : super(key: key);

  @override
  State<PaymentStatus> createState() => _PaymentStatusState();
}

class _PaymentStatusState extends State<PaymentStatus> {
  late Future<String> _currentUserIdFuture;

  @override
  void initState() {
    super.initState();
    _currentUserIdFuture = getCurrentUserId();
  }

  Future<String> getCurrentUserId() async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    if (userUid == null) {
      return '';
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userUid).get();

    if (userDoc.exists) {
      return userDoc.data()?['uid'] ?? '';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Payment Status',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<String>(
        future: _currentUserIdFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentUserId = snapshot.data!;

          if (currentUserId.isEmpty) {
            return const Center(child: Text('User not found.'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('bookings')
                .where('currentUserId', isEqualTo: currentUserId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No bookings found.'));
              }

              final bookings = snapshot.data!.docs;

              return ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking =
                      bookings[index].data() as Map<String, dynamic>;
                  final bool isPending = booking['paymentStatus'] == 'Pending';
                  final Timestamp? timestamp = booking['selectedDate'];
                  final String? selectedTime = booking['selectedTime'];

                  String formattedDate = '';
                  if (timestamp != null) {
                    final DateTime dateTime = timestamp.toDate();
                    formattedDate =
                        '${dateTime.day}/${dateTime.month}/${dateTime.year}';
                  }
                  final String time = selectedTime ?? '';

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(
                                      'https://placehold.co/400x400/png?text=Profile'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        booking['serviceName'] ??
                                            'Unknown Service',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.more_vert,
                                            size: 20),
                                        onPressed: () {},
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        time,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        booking['paymentStatus'] ?? '',
                                        style: TextStyle(
                                          color: isPending
                                              ? Colors.green
                                              : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        height: 30,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isPending
                                                ? Colors.green
                                                : Colors.white,
                                            foregroundColor: isPending
                                                ? Colors.white
                                                : Colors.green,
                                            side: isPending
                                                ? null
                                                : const BorderSide(
                                                    color: Colors.green),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                          ),
                                          child: Text(
                                            isPending
                                                ? 'Pay now'
                                                : 'Send Notification',
                                          ),
                                        ),
                                      ),
                                      if (isPending)
                                        SizedBox(
                                          height: 30,
                                          child: OutlinedButton(
                                            onPressed: () {},
                                            style: OutlinedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              side: const BorderSide(
                                                  color: Colors.green),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                            ),
                                            child: const Text(
                                              'Send Reminder',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (index < bookings.length - 1)
                        const Divider(
                            height: 1, thickness: 1, indent: 16, endIndent: 16),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
