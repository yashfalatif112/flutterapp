import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homease/models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitReview(ReviewModel review) async {
    await _firestore.collection('reviews').doc(review.id).set(review.toMap());
    
    // Update the booking to mark it as reviewed
    await _firestore
        .collection('bookings')
        .doc(review.bookingId)
        .update({'isReviewed': true});
  }

  Stream<List<ReviewModel>> getServiceProviderReviews(String serviceProviderId) {
    return _firestore
        .collection('reviews')
        .where('serviceProviderId', isEqualTo: serviceProviderId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromMap(doc.data()))
            .toList());
  }

  Future<bool> hasReviewedBooking(String bookingId) async {
    final doc = await _firestore
        .collection('bookings')
        .doc(bookingId)
        .get();
    
    return doc.data()?['isReviewed'] ?? false;
  }
} 