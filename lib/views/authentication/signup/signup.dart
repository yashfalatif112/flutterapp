import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homease/views/authentication/login/login.dart';
import 'package:homease/views/authentication/signup/provider/category_provider.dart';
import 'package:homease/views/authentication/signup/widgets/occupation_sheet.dart';
import 'package:homease/views/bottom_bar/bottom_bar.dart';
import 'package:homease/widgets/custom_button.dart';
import 'package:homease/widgets/custom_textfield.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final occupationController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  String? selectedAddress;
  PlatformFile? pickedFile;
  String? errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Map<String, dynamic>> categories = [];
  String? selectedMainCategory;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void pickGovIdFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<String?> _uploadImage() async {
    if (pickedFile == null) return null;

    try {
      File file = File(pickedFile!.path!);
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${pickedFile!.name}';
      Reference ref = _storage.ref().child('user_images').child(fileName);

      await ref.putFile(file);
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to upload image: $e';
        _isLoading = false;
      });
      return null;
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (pickedFile == null) {
      setState(() {
        errorMessage = 'Please upload your government ID';
      });
      return;
    }

    setState(() {
      errorMessage = null;
      _isLoading = true;
    });

    try {
      String? imageUrl = await _uploadImage();
      if (imageUrl == null && errorMessage != null) return;

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'occupation': occupationController.text.trim(),
        'description': descriptionController.text.trim(),
        'address': addressController.text.trim(),
        'govIdImageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BottomBarScreen()));
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'An account already exists for that email.';
        } else {
          errorMessage = 'Error: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        errorMessage = 'An error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesProvider = Provider.of<CategoriesProvider>(context);
    final categories = categoriesProvider.categories;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/logo/mainlogo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Fill Your Information Below To Register Your Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                if (errorMessage != null)
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
                            errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Text(
                      'Name',
                      style: GoogleFonts.roboto(
                          fontSize: 16, color: Color(0xff7d7d7d)),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                CustomTextField(
                  hintText: '',
                  controller: nameController,
                  validator: (value) => _validateField(value, 'Name'),
                ),
                const SizedBox(height: 12),
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
                  hintText: '',
                  controller: emailController,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 12),
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
                  hintText: '',
                  controller: passwordController,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onToggleObscure: _togglePasswordVisibility,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Occupation',
                      style: GoogleFonts.roboto(
                          fontSize: 16, color: Color(0xff7d7d7d)),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                CustomTextField(
                  hintText: '',
                  controller: occupationController,
                  validator: (value) => _validateField(value, 'Occupation'),
                  onTap: () {
                    if (categoriesProvider.isLoading) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Loading categories...')));
                      return;
                    }

                    if (categoriesProvider.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Error loading categories. Please try again.')));
                      return;
                    }

                    showOccupationSheet(
                        items:
                            categories.map((e) => e['name'] as String).toList(),
                        onSelected: (value) {
                          occupationController.text = value;
                          selectedMainCategory = value;
                          descriptionController.clear();
                        },
                        context: context);
                  },
                  readOnly: true,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Description',
                      style: GoogleFonts.roboto(
                          fontSize: 16, color: Color(0xff7d7d7d)),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                CustomTextField(
                  hintText: '',
                  controller: descriptionController,
                  readOnly: true,
                  validator: (value) => _validateField(value, 'Description'),
                  onTap: () {
                    if (selectedMainCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Please select an occupation first')));
                      return;
                    }

                    final selected = categories.firstWhere(
                      (e) => e['name'] == selectedMainCategory,
                      orElse: () => {},
                    );
                    final subcategories =
                        List<String>.from(selected['subcategories'] ?? []);

                    showOccupationSheet(
                      items: subcategories,
                      onSelected: (value) {
                        descriptionController.text = value;
                      },
                      context: context,
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Address',
                      style: GoogleFonts.roboto(
                          fontSize: 16, color: Color(0xff7d7d7d)),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                CustomTextField(
                  hintText: '',
                  controller: addressController,
                  validator: (value) => _validateField(value, 'Address'),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE6E6E6)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.upload_file, color: Colors.black),
                          SizedBox(width: 8),
                          Text("GOV ID UPLOAD and picture"),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          pickGovIdFile();
                        },
                        child: DottedBorder(
                            color: Colors.grey,
                            strokeWidth: 1,
                            dashPattern: [6, 4],
                            borderType: BorderType.RRect,
                            radius: Radius.circular(12),
                            child: SizedBox(
                              height: 150,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    pickedFile?.name ??
                                        'Browse and select files you want to upload from your computer',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.black54, fontSize: 12),
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.green),
                                    child: Center(
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Signup',
                  onTap: _isLoading ? null : _signUp,
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text("Or Sign Up With"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SocialButton(
                        asset: 'assets/logo/google.svg', label: 'Google'),
                    _SocialButton(
                        asset: 'assets/logo/apple.svg', label: 'Apple ID'),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: GoogleFonts.roboto(color: Colors.black),
                      children: const [
                        TextSpan(
                          text: 'Sign in',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String asset;
  final String label;

  const _SocialButton({required this.asset, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2E6),
        border: Border.all(color: const Color(0xFFE6E6E6)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(asset, height: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
