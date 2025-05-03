import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String _name = '';
  String _address = '';
  String _currentUserId = '';

  String get name => _name;
  String get address => _address;
  String get currentUserId => _currentUserId;

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        _name = doc.data()?['name'] ?? '';
        _address = doc.data()?['address'] ?? '';
        _currentUserId = doc.data()?['uid'] ?? '';
        notifyListeners();
      }
    }
  }
}
