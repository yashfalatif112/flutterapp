import 'package:flutter/material.dart';
import 'package:homease/models/review_model.dart';
import 'package:homease/services/review_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewsAndRatings extends StatelessWidget {
  final String? providerId;

  const ReviewsAndRatings({
    super.key,
    this.providerId,
  });

  @override
  Widget build(BuildContext context) {
    final userId = providerId ?? FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return Center(child: Text('User not authenticated'));
    }

    final reviewService = ReviewService();

    return StreamBuilder<List<ReviewModel>>(
      stream: reviewService.getServiceProviderReviews(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading reviews: ${snapshot.error}'));
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return Center(
            child: Text('No reviews yet'),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Card(
              color: Colors.white,
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: review.customerImage.isNotEmpty
                              ? NetworkImage(review.customerImage)
                              : null,
                          child: review.customerImage.isEmpty
                              ? Icon(Icons.person)
                              : null,
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              review.customerName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < review.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  );
                                }),
                                SizedBox(width: 8),
                                Text(
                                  review.rating.toString(),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Spacer(),
                        Text(
                          _formatDate(review.timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      review.review,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
} 