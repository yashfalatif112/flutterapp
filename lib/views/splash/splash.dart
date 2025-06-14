import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homease/views/authentication/login/login.dart';
import 'package:homease/views/bottom_bar/bottom_bar.dart';
import 'package:homease/views/authentication/signup/provider/category_provider.dart';
import 'package:homease/views/bottom_bar/service_provider_status.dart';
import 'package:homease/views/services/provider/service_provider.dart';
import 'package:homease/views/authentication/complete_profile/complete_profile.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<bool> _isProfileComplete(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    
    final data = doc.data()!;
    final isServiceProvider = data['serviceProvider'] ?? false;
    
    // For regular users, check basic profile completion
    if (!isServiceProvider) {
      return data['name'] != null && data['email'] != null;
    }
    
    // For service providers, check additional required fields
    return data['name'] != null && 
           data['email'] != null &&
           data['occupation'] != null &&
           data['description'] != null &&
           data['address'] != null;
  }

  Future<void> _requestPermissions() async {
    // Request all necessary permissions
    await Future.wait([
      Permission.camera.request(),
      Permission.microphone.request(),
      Permission.notification.request(),
      Permission.location.request(),
      Permission.photos.request(),
    ]);
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      // Request permissions first
      await _requestPermissions();
      
      // Then fetch data
      Provider.of<CategoriesProvider>(context, listen: false).fetchCategories();
      Provider.of<ServicesProvider>(context, listen: false).fetchMostPopular();
    });

    Future.delayed(const Duration(seconds: 3), () async {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final isProfileComplete = await _isProfileComplete(user.uid);
        await Provider.of<ServiceProviderStatus>(context, listen: false).refreshStatus();
        
        if (!mounted) return;
        
        if (isProfileComplete) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => BottomBarScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => CompleteProfileScreen(
                uid: user.uid,
                email: user.email ?? '',
                name: user.displayName ?? '',
              ),
            ),
          );
        }
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo/transparent_logo.png',
              width: 150,
              height: 150,
            ),
          ],
        ),
      ),
    );
  }
}
