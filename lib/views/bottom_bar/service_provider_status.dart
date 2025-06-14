import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homease/services/location_service.dart';

class ServiceProviderStatus with ChangeNotifier {
  bool _isServiceProvider = false;
  bool get isServiceProvider => _isServiceProvider;
  StreamSubscription<User?>? _authSubscription;
  final LocationService _locationService = LocationService();
  
  ServiceProviderStatus() {
    // Initialize with auth listener
    _setupAuthListener();
  }
  
  void _setupAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // Reset when user logs out
        setStatus(false);
      } else {
        // Refresh when user logs in
        refreshStatus();
      }
    });
  }
  
  void setStatus(bool value) {
    _isServiceProvider = value;
    if (value) {
      // Start location tracking when service provider becomes active
      _locationService.startLocationTracking();
    } else {
      // Stop location tracking when service provider becomes inactive
      _locationService.stopLocationTracking();
    }
    notifyListeners();
  }
  
  Future<void> refreshStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (doc.exists) {
          final status = doc.data()?['serviceProvider'] ?? false;
          setStatus(status);
        }
      } catch (e) {
        print("Error fetching service provider status: $e");
      }
    }
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}