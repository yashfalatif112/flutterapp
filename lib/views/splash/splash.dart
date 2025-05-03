import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homease/views/authentication/login/login.dart';
import 'package:homease/views/bottom_bar/bottom_bar.dart';
import 'package:homease/views/authentication/signup/provider/category_provider.dart';
import 'package:homease/views/bottom_bar/service_provider_status.dart';
import 'package:homease/views/services/provider/service_provider.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<CategoriesProvider>(context, listen: false).fetchCategories();
      Provider.of<ServicesProvider>(context, listen: false).fetchMostPopular();
    });

    Future.delayed(const Duration(seconds: 3), () async {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await Provider.of<ServiceProviderStatus>(context, listen: false).refreshStatus();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomBarScreen()),
        );
      } else {
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
      backgroundColor: const Color(0xff0f4910),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo/mainlogo.png',
              width: 150,
              height: 150,
            ),
          ],
        ),
      ),
    );
  }
}
