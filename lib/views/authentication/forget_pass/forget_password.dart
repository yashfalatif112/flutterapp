import 'package:flutter/material.dart';
import 'package:homease/views/authentication/verify_otp/verify_otp.dart';
import 'package:homease/widgets/custom_button.dart';
import 'package:homease/widgets/custom_textfield.dart';

class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({super.key});

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/logo/bubble_logo.png',
                height: 100,
              ),
              const SizedBox(height: 24),
              const Text(
                'Forget Password?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please Enter Your Email Address',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                hintText: 'Enter email',
                controller: emailController,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Send Verification link',
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>VerificationScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
