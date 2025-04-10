import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Color(0xFFA7D7A9),
        borderRadius: BorderRadius.circular(16),
        // image: const DecorationImage(
        //   image: AssetImage('assets/images/banner.png'),
        //   fit: BoxFit.cover,
        // ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Home Cleaning Services',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Professional cleaning for your home with eco-friendly solutions.',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
