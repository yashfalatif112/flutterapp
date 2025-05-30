// import 'package:flutter/material.dart';
// import 'package:homease/widgets/custom_button.dart';
// import 'package:homease/widgets/custom_textfield.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:homease/views/authentication/login/login.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class ResetPasswordScreen extends StatefulWidget {
//   final String email;
//   final String otp;

//   const ResetPasswordScreen({
//     super.key,
//     required this.email,
//     required this.otp,
//   });

//   @override
//   State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
// }

// class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   Future<void> resetPassword() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       // First verify if OTP is still valid
//       DocumentSnapshot otpDoc = await FirebaseFirestore.instance
//           .collection('password_resets')
//           .doc(widget.email)
//           .get();

//       if (!otpDoc.exists) {
//         setState(() {
//           _errorMessage = 'Password reset session expired. Please request a new OTP.';
//           _isLoading = false;
//         });
//         return;
//       }

//       Map<String, dynamic> data = otpDoc.data() as Map<String, dynamic>;
//       String storedOTP = data['otp'];
//       Timestamp createdAt = data['created_at'];

//       // Verify OTP
//       if (storedOTP != widget.otp) {
//         setState(() {
//           _errorMessage = 'Invalid reset session. Please request a new OTP.';
//           _isLoading = false;
//         });
//         return;
//       }

//       // Check if OTP is expired (5 minutes)
//       DateTime otpTime = createdAt.toDate();
//       if (DateTime.now().difference(otpTime).inMinutes > 5) {
//         setState(() {
//           _errorMessage = 'OTP has expired. Please request a new one.';
//           _isLoading = false;
//         });
//         return;
//       }

//       // Simply send Firebase's built-in password reset email
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);

//       // Delete the OTP document since it's verified
//       await FirebaseFirestore.instance
//           .collection('password_resets')
//           .doc(widget.email)
//           .delete();

//       // Show success and redirect to login
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Password reset email sent! Please check your email and follow the link to reset your password.'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 4),
//           ),
//         );
        
//         // Add a small delay then navigate
//         await Future.delayed(const Duration(seconds: 2));
        
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//           (route) => false,
//         );
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = 'Failed to send password reset email. Please try again.';
//       });
//       print('Reset password error: $e');
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFAF9F1),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: BackButton(color: Colors.black),
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 40),
//                 Image.asset(
//                   'assets/logo/bubble_logo.png',
//                   height: 100,
//                 ),
//                 const SizedBox(height: 24),
//                 const Text(
//                   'Reset Password',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Create a new password for ${widget.email}',
//                   style: const TextStyle(
//                     color: Colors.black54,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 if (_errorMessage != null)
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     margin: const EdgeInsets.only(bottom: 16),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade100,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.error_outline, color: Colors.red),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             _errorMessage!,
//                             style: const TextStyle(color: Colors.red),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 const Text(
//                   'New Password',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Color(0xff7d7d7d),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 CustomTextField(
//                   controller: _passwordController,
//                   hintText: 'Enter new password',
//                   isPassword: true,
//                   obscureText: _obscurePassword,
//                   onToggleObscure: () {
//                     setState(() {
//                       _obscurePassword = !_obscurePassword;
//                     });
//                   },
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a password';
//                     }
//                     if (value.length < 6) {
//                       return 'Password must be at least 6 characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 24),
//                 const Text(
//                   'Confirm Password',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Color(0xff7d7d7d),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 CustomTextField(
//                   controller: _confirmPasswordController,
//                   hintText: 'Confirm new password',
//                   isPassword: true,
//                   obscureText: _obscureConfirmPassword,
//                   onToggleObscure: () {
//                     setState(() {
//                       _obscureConfirmPassword = !_obscureConfirmPassword;
//                     });
//                   },
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please confirm your password';
//                     }
//                     if (value != _passwordController.text) {
//                       return 'Passwords do not match';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 32),
//                 CustomButton(
//                   text: _isLoading ? 'Resetting Password...' : 'Reset Password',
//                   onTap: _isLoading ? null : resetPassword,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }
// }