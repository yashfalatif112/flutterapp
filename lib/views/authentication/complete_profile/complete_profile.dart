import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homease/views/authentication/signup/provider/category_provider.dart';
import 'package:homease/views/authentication/signup/widgets/occupation_sheet.dart';
import 'package:homease/views/bottom_bar/bottom_bar.dart';
import 'package:homease/widgets/custom_button.dart';
import 'package:homease/widgets/custom_textfield.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import 'package:homease/services/social_auth_service.dart';
import 'dart:io';

class CompleteProfileScreen extends StatefulWidget {
  final String uid;
  final String email;
  final String name;

  const CompleteProfileScreen({
    Key? key,
    required this.uid,
    required this.email,
    required this.name,
  }) : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final occupationController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();
  final _socialAuthService = SocialAuthService();

  bool _isLoading = false;
  String? errorMessage;
  PlatformFile? pickedFile;
  String? selectedMainCategory;

  @override
  void initState() {
    super.initState();
    Provider.of<CategoriesProvider>(context, listen: false).fetchCategories();
  }

  void pickGovIdFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (pickedFile == null) return null;

    try {
      File file = File(pickedFile!.path!);
      String fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedFile!.name}';
      Reference ref = FirebaseStorage.instance.ref().child('user_images').child(fileName);

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

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (pickedFile == null) {
      setState(() {
        errorMessage = 'Please upload your government ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      String? imageUrl = await _uploadImage();
      if (imageUrl == null && errorMessage != null) return;

      await _socialAuthService.saveUserData(
        uid: widget.uid,
        email: widget.email,
        name: widget.name,
        isServiceProvider: true,
        occupation: occupationController.text.trim(),
        description: descriptionController.text.trim(),
        address: addressController.text.trim(),
        govIdImageUrl: imageUrl,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomBarScreen()),
      );
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'Complete Your Profile',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please provide your service provider details to continue',
                  style: TextStyle(color: Colors.grey[600]),
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

                Text(
                  'Occupation',
                  style: GoogleFonts.roboto(fontSize: 16, color: Color(0xff7d7d7d)),
                ),
                SizedBox(height: 5),
                CustomTextField(
                  hintText: '',
                  controller: occupationController,
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Occupation is required';
                    }
                    return null;
                  },
                  onTap: () {
                    if (categoriesProvider.isLoading) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Loading categories...')),
                      );
                      return;
                    }

                    if (categoriesProvider.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error loading categories. Please try again.')),
                      );
                      return;
                    }

                    showOccupationSheet(
                      items: categoriesProvider.categories.map((e) => e['name'] as String).toList(),
                      onSelected: (value) {
                        setState(() {
                          occupationController.text = value;
                          selectedMainCategory = value;
                          descriptionController.clear();
                        });
                      },
                      context: context,
                    );
                  },
                ),

                const SizedBox(height: 16),
                Text(
                  'Description',
                  style: GoogleFonts.roboto(fontSize: 16, color: Color(0xff7d7d7d)),
                ),
                SizedBox(height: 5),
                CustomTextField(
                  hintText: '',
                  controller: descriptionController,
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                  onTap: () async {
                    if (selectedMainCategory == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select an occupation first')),
                      );
                      return;
                    }

                    final subcategoriesSnapshot = await FirebaseFirestore.instance
                        .collection('services')
                        .doc(selectedMainCategory)
                        .collection('subcategories')
                        .get();

                    final subcategoryNames = subcategoriesSnapshot.docs
                        .map((doc) => doc.data()['name'] as String)
                        .toList();

                    if (!mounted) return;

                    showOccupationSheet(
                      items: subcategoryNames,
                      onSelected: (value) {
                        setState(() {
                          descriptionController.text = value;
                        });
                      },
                      context: context,
                    );
                  },
                ),

                const SizedBox(height: 16),
                Text(
                  'Address',
                  style: GoogleFonts.roboto(fontSize: 16, color: Color(0xff7d7d7d)),
                ),
                SizedBox(height: 5),
                CustomTextField(
                  hintText: '',
                  controller: addressController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),
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
                        onTap: pickGovIdFile,
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
                                  style: TextStyle(color: Colors.black54, fontSize: 12),
                                ),
                                SizedBox(height: 5),
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Color(0xff48B1DB),
                                  ),
                                  child: Icon(Icons.add, color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                CustomButton(
                  text: 'Complete Profile',
                  onTap: _isLoading ? null : _completeProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    occupationController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    super.dispose();
  }
} 