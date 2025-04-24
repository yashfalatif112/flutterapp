import 'package:flutter/material.dart';
import 'package:homease/views/authentication/login/login.dart';
import 'package:homease/views/authentication/signup/provider/category_provider.dart';
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

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff0f4910),
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
