import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homease/models/portfolio_model.dart';

class PortfolioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updatePortfolio(PortfolioModel portfolio) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('portfolio')
        .doc('data')
        .set(portfolio.toMap());
  }

  Future<PortfolioModel?> getPortfolio([String? providerId]) async {
    final userId = providerId ?? _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('portfolio')
        .doc('data')
        .get();

    if (!doc.exists) return null;
    return PortfolioModel.fromMap(doc.data()!);
  }
} 