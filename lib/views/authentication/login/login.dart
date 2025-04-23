import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homease/views/authentication/forget_pass/forget_password.dart';
import 'package:homease/views/authentication/login/provider/login_provider.dart';
import 'package:homease/views/authentication/signup/signup.dart';
import 'package:homease/views/bottom_bar/bottom_bar.dart';
import 'package:homease/widgets/custom_button.dart';
import 'package:homease/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  String? _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _toggleObscure() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleTerms(bool? value) {
    setState(() {
      _agreedToTerms = value ?? false;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // Basic email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_agreedToTerms) {
      setState(() {
        _errorMessage = 'Please agree to the Terms & Conditions';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      // Sign in with email and password
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      // Navigate to home on successful login
      if (!mounted) return;
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => BottomBarScreen())
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.code == 'user-not-found') {
          _errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Wrong password provided.';
        } else {
          _errorMessage = 'Error: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 30),
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
              
              // Show error message if any
              if (_errorMessage != null)
                Container(
                  padding: EdgeInsets.all(8),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Email field
              Row(
                children: [
                  Text(
                    'Email address',
                    style: GoogleFonts.roboto(
                        fontSize: 16, color: Color(0xff7d7d7d)),
                  ),
                ],
              ),
              SizedBox(height: 5),
              CustomTextField(
                controller: emailController,
                hintText: '',
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              
              // Password field
              Row(
                children: [
                  Text(
                    'Password',
                    style: GoogleFonts.roboto(
                        fontSize: 16, color: Color(0xff7d7d7d)),
                  ),
                ],
              ),
              SizedBox(height: 5),
              CustomTextField(
                controller: passwordController,
                hintText: '',
                isPassword: true,
                obscureText: _obscurePassword,
                onToggleObscure: _toggleObscure,
                validator: _validatePassword,
              ),
              const SizedBox(height: 8),
              
              // Forget password link
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
              
              // Terms and conditions checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: _toggleTerms,
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
              
              // Login button with loading indicator
              CustomButton(
                text: "Login",
                onTap: _isLoading ? null : _login,
                // child: _isLoading 
                //     ? SizedBox(
                //         height: 20,
                //         width: 20,
                //         child: CircularProgressIndicator(
                //           color: Colors.white,
                //           strokeWidth: 2,
                //         ),
                //       )
                //     : null,
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
                        children: [
                          SvgPicture.asset(
                            'assets/logo/google.svg',
                            height: 20,
                          ),
                          SizedBox(width: 5),
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
                        children: [
                          SvgPicture.asset(
                            'assets/logo/apple.svg',
                            height: 20,
                          ),
                          SizedBox(width: 5),
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
                    const Text("Don't have an Account? "),
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
      ),
    );
  }
}