import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homease/models/certification_model.dart';

class CertificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addCertification(CertificationModel certification) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('certifications')
        .doc(certification.id)
        .set(certification.toMap());
  }

  Future<void> updateCertification(CertificationModel certification) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('certifications')
        .doc(certification.id)
        .update(certification.toMap());
  }

  Future<void> deleteCertification(String certificationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('certifications')
        .doc(certificationId)
        .delete();
  }

  Stream<List<CertificationModel>> getCertifications([String? providerId]) {
    final userId = providerId ?? _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('certifications')
        .orderBy('issueDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CertificationModel.fromMap(doc.data()))
            .toList());
  }
} 