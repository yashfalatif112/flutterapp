// import 'package:flutter/material.dart';
// import 'package:homease/views/authentication/verify_otp/widgets/otp_input_widget.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:homease/views/authentication/reset_password/reset_password.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:math';

// class VerificationScreen extends StatefulWidget {
//   final String email;
  
//   const VerificationScreen({
//     super.key,
//     required this.email,
//   });

//   @override
//   State<VerificationScreen> createState() => _VerificationScreenState();
// }

// class _VerificationScreenState extends State<VerificationScreen> {
//   final otpController = TextEditingController();
//   bool isLoading = false;
//   bool isResending = false;
//   String? errorMessage;

//   // Generate a 6-digit OTP
//   String generateOTP() {
//     Random random = Random();
//     return (100000 + random.nextInt(900000)).toString();
//   }

//   Future<void> resendOTP() async {
//     setState(() {
//       isResending = true;
//       errorMessage = null;
//     });

//     try {
//       // Generate new OTP
//       String otp = generateOTP();
      
//       // Store OTP in Firestore with timestamp
//       await FirebaseFirestore.instance.collection('password_resets').doc(widget.email).set({
//         'otp': otp,
//         'created_at': FieldValue.serverTimestamp(),
//         'attempts': 0,
//       });

//       // Send password reset email again
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('New verification code sent successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           errorMessage = 'Failed to resend code. Please try again.';
//         });
//       }
//     }

//     if (mounted) {
//       setState(() {
//         isResending = false;
//       });
//     }
//   }

//   Future<void> verifyOTP(String enteredOTP) async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       // Get the stored OTP document
//       DocumentSnapshot otpDoc = await FirebaseFirestore.instance
//           .collection('password_resets')
//           .doc(widget.email)
//           .get();

//       if (!otpDoc.exists) {
//         setState(() {
//           errorMessage = 'No OTP request found. Please try again.';
//           isLoading = false;
//         });
//         return;
//       }

//       Map<String, dynamic> data = otpDoc.data() as Map<String, dynamic>;
//       String storedOTP = data['otp'];
//       Timestamp createdAt = data['created_at'];
//       int attempts = data['attempts'] ?? 0;

//       // Check if OTP is expired (5 minutes)
//       DateTime otpTime = createdAt.toDate();
//       if (DateTime.now().difference(otpTime).inMinutes > 5) {
//         setState(() {
//           errorMessage = 'OTP has expired. Please request a new one.';
//           isLoading = false;
//         });
//         return;
//       }

//       // Check if too many attempts (max 3)
//       if (attempts >= 3) {
//         setState(() {
//           errorMessage = 'Too many attempts. Please request a new OTP.';
//           isLoading = false;
//         });
//         return;
//       }

//       // Update attempts
//       await FirebaseFirestore.instance
//           .collection('password_resets')
//           .doc(widget.email)
//           .update({'attempts': attempts + 1});

//       // Verify OTP
//       if (enteredOTP == storedOTP) {
//         // Navigate to password reset screen
//         if (mounted) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ResetPasswordScreen(
//                 email: widget.email,
//                 otp: storedOTP,
//               ),
//             ),
//           );
//         }
//       } else {
//         setState(() {
//           errorMessage = 'Invalid OTP. Please try again.';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'An error occurred. Please try again.';
//       });
//     }

//     if (mounted) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: BackButton(color: Colors.black),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           children: [
//             const SizedBox(height: 16),
//             const Text(
//               'Verification Code',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Please Enter The Code We Just Have Sent To\n${widget.email}',
//               textAlign: TextAlign.center,
//               style: const TextStyle(color: Colors.black54),
//             ),
//             const SizedBox(height: 32),
//             OtpInputRow(
//               controller: otpController,
//               onCompleted: (otp) {
//                 verifyOTP(otp);
//               },
//             ),
//             if (errorMessage != null) ...[
//               const SizedBox(height: 16),
//               Text(
//                 errorMessage!,
//                 style: const TextStyle(color: Colors.red),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//             const SizedBox(height: 24),
//             const Text("Didn't Receive OTP?",
//                 style: TextStyle(color: Colors.black54)),
//             TextButton(
//               onPressed: isResending ? null : resendOTP,
//               child: Text(isResending ? "Sending..." : "Resend Code"),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               height: 48,
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                 ),
//                 onPressed: isLoading
//                     ? null
//                     : () {
//                         if (otpController.text.length == 6) {
//                           verifyOTP(otpController.text);
//                         }
//                       },
//                 child: Text(
//                   isLoading ? 'Verifying...' : 'Verify',
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     otpController.dispose();
//     super.dispose();
//   }
// }
