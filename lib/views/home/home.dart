import 'package:flutter/material.dart';
import 'package:homease/views/home/widgets/home_header.dart';
import 'package:homease/views/home/widgets/most_popular.dart';
import 'package:homease/views/home/widgets/our_services.dart';
import 'package:homease/views/home/widgets/recommended_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                HomeHeader(),
                SizedBox(height: 20),
                OurServices(),
                SizedBox(height: 20),
                MostPopularSection(),
                SizedBox(height: 20),
                RecommendedSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
