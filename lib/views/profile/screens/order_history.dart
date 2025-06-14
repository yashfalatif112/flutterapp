import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homease/models/review_model.dart';
import 'package:homease/services/review_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final ReviewService _reviewService = ReviewService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getBookings(String status) {
    return _firestore
        .collection('bookings')
        .where('currentUserId', isEqualTo: _userId)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _showReviewDialog(String bookingId, String serviceProviderId, String serviceName) async {
    final TextEditingController reviewController = TextEditingController();
    double rating = 0;

    // Get current user data
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .get();
    final userData = userDoc.data() as Map<String, dynamic>?;
    final customerName = userData?['name'] ?? 'Unknown User';
    final customerImage = userData?['profileImage'] ?? '';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Leave a Review'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reviewController,
                decoration: const InputDecoration(
                  hintText: 'Write your review here...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (rating == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a rating')),
                  );
                  return;
                }

                if (reviewController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please write a review')),
                  );
                  return;
                }

                try {
                  final review = ReviewModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    bookingId: bookingId,
                    serviceProviderId: serviceProviderId,
                    customerId: _userId,
                    customerName: customerName,
                    customerImage: customerImage,
                    rating: rating,
                    review: reviewController.text.trim(),
                    timestamp: DateTime.now(),
                  );

                  await _reviewService.submitReview(review);
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Review submitted successfully')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error submitting review: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff48B1DB),
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final status = data['status'] ?? '';
    final serviceName = data['serviceName'] ?? 'Unknown Service';
    final serviceProviderId = data['serviceProviderId'] ?? '';
    final date = data['selectedDate'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            data['selectedDate'].millisecondsSinceEpoch)
        : null;
    final time = data['selectedTime'] ?? '';
    final isReviewed = data['isReviewed'] ?? false;

    Color statusColor;
    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'accepted':
        statusColor = const Color(0xff48B1DB);
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  serviceName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(serviceProviderId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final providerData = snapshot.data!.data() as Map<String, dynamic>?;
                final providerName = providerData?['name'] ?? 'Unknown Provider';
                return Text(
                  'Provider: $providerName',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                );
              }
              return const Text(
                'Loading provider info...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          if (date != null)
            Text(
              'Date: ${date.day}/${date.month}/${date.year} at $time',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          // if (time.isNotEmpty) ...[
          //   const SizedBox(height: 5),
          //   Text(
          //     'Time: $time',
          //     style: TextStyle(
          //       color: Colors.grey[600],
          //       fontSize: 14,
          //     ),
          //   ),
          // ],
          if (status == 'accepted' && !isReviewed) ...[
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () => _showReviewDialog(doc.id, serviceProviderId, serviceName),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xff48B1DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: const Color(0xff48B1DB),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Leave a Review',
                      style: TextStyle(
                        color: const Color(0xff48B1DB),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrdersList(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getBookings(status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 50, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text(
                  'No ${status.toLowerCase()} orders found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCF9),
        elevation: 0,
        title: const Text(
          'Order History',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xff48B1DB),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color(0xff48B1DB),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'PENDING'),
            Tab(text: 'ACCEPTED'),
            Tab(text: 'REJECTED'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList('pending'),
          _buildOrdersList('accepted'),
          _buildOrdersList('rejected'),
        ],
      ),
    );
  }
} 