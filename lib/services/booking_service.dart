import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<QuerySnapshot> getNewestPendingRequest() async {
    return await _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'pending')
        .where('serviceProviderId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
  }

  Future<QuerySnapshot> getAllPendingRequests() async {
    return await _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'pending')
        .where('serviceProviderId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<QuerySnapshot> getNewestActiveRequest() async {
    return await _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'accepted')
        .where('serviceProviderId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
  }

  Future<QuerySnapshot> getAllActiveRequests() async {
    return await _firestore
        .collection('bookings')
        .where('status', isEqualTo: 'accepted')
        .where('serviceProviderId', isEqualTo: _currentUserId)
        .orderBy('createdAt', descending: true)
        .get();
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    return await _firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status});
  }

  Future<DocumentSnapshot> getUserDetails(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }
}
