import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homease/views/authentication/login/login.dart';
import 'package:homease/views/bottom_bar/bottom_bar.dart';
import 'package:homease/widgets/custom_button.dart';
import 'package:homease/widgets/custom_textfield.dart';
import 'package:dotted_border/dotted_border.dart';

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

  String? selectedAddress;
  PlatformFile? pickedFile;

  void pickGovIdFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              Image.asset('assets/logo/bubble_logo.png', height: 80),
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
              Row(
                children: [
                  Text(
                    'Name',
                    style: GoogleFonts.roboto(
                        fontSize: 16, color: Color(0xff7d7d7d)),
                  ),
                ],
              ),
              SizedBox(
                height: 5,
              ),
              CustomTextField(hintText: '', controller: nameController),
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
              SizedBox(
                height: 5,
              ),
              CustomTextField(hintText: '', controller: emailController),
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
              SizedBox(
                height: 5,
              ),
              CustomTextField(
                hintText: '',
                controller: passwordController,
                isPassword: true,
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
              SizedBox(
                height: 5,
              ),
              CustomTextField(hintText: '', controller: occupationController),
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
              SizedBox(
                height: 5,
              ),
              CustomTextField(hintText: '', controller: descriptionController),
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
              SizedBox(
                height: 5,
              ),
              CustomTextField(hintText: '', controller: descriptionController),
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
                                SizedBox(
                                  height: 5,
                                ),
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
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomBarScreen()));
                },
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
