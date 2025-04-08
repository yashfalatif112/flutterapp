import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homease/views/authentication/forget_pass/forget_password.dart';
import 'package:homease/views/authentication/login/provider/login_provider.dart';
import 'package:homease/views/authentication/signup/signup.dart';
import 'package:homease/widgets/custom_button.dart';
import 'package:homease/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LoginProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Image.asset('assets/logo/bubble_logo.png', height: 100),
            const SizedBox(height: 16),
            const Text("Login Here!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              "Welcome Back! Enter Your Credentials\nTo Explore Further",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Text(
                  'Email address',
                  style: GoogleFonts.roboto(
                      fontSize: 16, color: Color(0xff7d7d7d)),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            CustomTextField(
              controller: provider.emailController,
              hintText: '',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Password',
                  style: GoogleFonts.roboto(
                      fontSize: 16, color: Color(0xff7d7d7d)),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            CustomTextField(
              controller: provider.passwordController,
              hintText: '',
              isPassword: true,
              obscureText: provider.obscurePassword,
              onToggleObscure: provider.toggleObscure,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgetPasswordScreen()));
                },
                child: const Text("Forget password?",
                    style: TextStyle(color: Colors.black87)),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: provider.agreedToTerms,
                  onChanged: provider.toggleTerms,
                ),
                const Text("I agree to "),
                GestureDetector(
                  onTap: () {},
                  child: const Text("Terms & Conditions",
                      style: TextStyle(decoration: TextDecoration.underline)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: "Login",
              onTap: provider.login,
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("Or Login With"),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 100,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F2E6),
                      border: Border.all(color: const Color(0xFFE6E6E6)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 5,
                      children: [
                        SvgPicture.asset(
                          'assets/logo/google.svg',
                          height: 20,
                        ),
                        Text(
                          'Google',
                          style: GoogleFonts.montserrat(fontSize: 12),
                        )
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 100,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F2E6),
                      border: Border.all(color: const Color(0xFFE6E6E6)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 5,
                      children: [
                        SvgPicture.asset(
                          'assets/logo/apple.svg',
                          height: 20,
                        ),
                        Text(
                          'Apple',
                          style: GoogleFonts.montserrat(fontSize: 12),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignupScreen()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don’t have an Account? "),
                  const Text("Create Account",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
