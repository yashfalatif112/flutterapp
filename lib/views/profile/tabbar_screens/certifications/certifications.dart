import 'package:flutter/material.dart';

class Certifications extends StatelessWidget {
  const Certifications({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Certifications and Qualifications',style: TextStyle(color: Colors.black),),
        ],
      ),
    );
  }
}