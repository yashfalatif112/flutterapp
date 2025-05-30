import 'package:flutter/material.dart';
import 'package:homease/views/profile/provider/profile_provider.dart';
import 'package:homease/widgets/custom_button.dart';
import 'package:homease/widgets/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homease/views/authentication/signup/widgets/occupation_sheet.dart';
import 'package:homease/views/authentication/signup/provider/category_provider.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  final bool isCustomer;
  const EditProfileScreen({super.key, required this.isCustomer});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final occupationController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();

  bool _isLoading = false;
  String? errorMessage;
  PlatformFile? pickedFile;
  String? selectedMainCategory;
  String? oldOccupation;
  String? oldDescription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (!widget.isCustomer) {
      Provider.of<CategoriesProvider>(context, listen: false).fetchCategories();
    }
  }

  void _loadUserData() {
    final userData = Provider.of<ProfileProvider>(context, listen: false).userData;
    if (userData != null) {
      nameController.text = userData['name'] ?? '';
      emailController.text = userData['email'] ?? '';
      if (!widget.isCustomer) {
        occupationController.text = userData['occupation'] ?? '';
        descriptionController.text = userData['description'] ?? '';
        addressController.text = userData['address'] ?? '';
        oldOccupation = userData['occupation'];
        oldDescription = userData['description'];
        selectedMainCategory = userData['occupation'];
      }
    }
  }

  void pickProfileImage() async {
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
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${pickedFile!.name}';
      Reference ref = FirebaseStorage.instance.ref().child('profile_images').child(fileName);

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

  Future<void> _updateServiceProviderCategory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Remove from old category if changed
    if (oldOccupation != null && oldDescription != null &&
        (oldOccupation != occupationController.text || oldDescription != descriptionController.text)) {
      try {
        final oldServiceRef = FirebaseFirestore.instance
            .collection('services')
            .doc(oldOccupation)
            .collection('subcategories')
            .doc(oldDescription);

        final oldDoc = await oldServiceRef.get();
        if (oldDoc.exists) {
          List<String> providers = List<String>.from(oldDoc.data()?['providers'] ?? []);
          providers.remove(uid);
          await oldServiceRef.update({'providers': providers});
        }
      } catch (e) {
        print('Error removing from old category: $e');
      }
    }

    // Add to new category
    try {
      final newServiceRef = FirebaseFirestore.instance
          .collection('services')
          .doc(occupationController.text)
          .collection('subcategories')
          .doc(descriptionController.text);

      final doc = await newServiceRef.get();
      if (doc.exists) {
        List<String> providers = List<String>.from(doc.data()?['providers'] ?? []);
        if (!providers.contains(uid)) {
          providers.add(uid);
          await newServiceRef.update({'providers': providers});
        }
      }
    } catch (e) {
      print('Error adding to new category: $e');
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
      errorMessage = null;
    });

    try {
      String? imageUrl;
      if (pickedFile != null) {
        imageUrl = await _uploadImage();
        if (imageUrl == null && errorMessage != null) return;
      }

      final updates = {
        'name': nameController.text.trim(),
        if (imageUrl != null) 'profileImage': imageUrl,
      };

      if (!widget.isCustomer) {
        updates.addAll({
          'occupation': occupationController.text.trim(),
          'description': descriptionController.text.trim(),
          'address': addressController.text.trim(),
        });
        await _updateServiceProviderCategory();
      }

      await Provider.of<ProfileProvider>(context, listen: false)
          .updateProfile(updates);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update profile: $e';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<ProfileProvider>(context).userData;
    final categoriesProvider = Provider.of<CategoriesProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1EB),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: pickedFile != null
                        ? FileImage(File(pickedFile!.path!))
                        : (userData?['profileImage'] != null
                            ? NetworkImage(userData!['profileImage'])
                            : null) as ImageProvider?,
                    child: (pickedFile == null && userData?['profileImage'] == null)
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: pickProfileImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              hintText: 'Name',
              controller: nameController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Email',
              controller: emailController,
              enabled: false,
            ),
            if (!widget.isCustomer) ...[
              const SizedBox(height: 16),
              CustomTextField(
                hintText: 'Occupation',
                controller: occupationController,
                readOnly: true,
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
                    items: categoriesProvider.categories
                        .map((e) => e['name'] as String)
                        .toList(),
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
              CustomTextField(
                hintText: 'Description',
                controller: descriptionController,
                readOnly: true,
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
              CustomTextField(
                hintText: 'Address',
                controller: addressController,
              ),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 24),
            CustomButton(
              text: _isLoading ? 'Updating...' : 'Update Profile',
              onTap: _isLoading ? null : _updateProfile,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    occupationController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    super.dispose();
  }
} 