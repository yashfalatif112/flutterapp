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
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final bool isCustomer;
  const EditProfileScreen({Key? key, required this.isCustomer})
      : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _imageFile;
  bool _isLoading = false;
  String? _currentImageUrl;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _oldOccupationController =
      TextEditingController();
  final TextEditingController _oldDescriptionController =
      TextEditingController();
  String? selectedMainCategory;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (!widget.isCustomer) {
      Provider.of<CategoriesProvider>(context, listen: false).fetchCategories();
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final userData = await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .get();

      if (userData.exists) {
        setState(() {
          _nameController.text = userData.data()?['name'] ?? '';
          _phoneController.text = userData.data()?['phone'] ?? '';
          _addressController.text = userData.data()?['address'] ?? '';
          _currentImageUrl = userData.data()?['profileImage'];
          if (!widget.isCustomer) {
            _occupationController.text = userData.data()?['occupation'] ?? '';
            _descriptionController.text = userData.data()?['description'] ?? '';
            _oldOccupationController.text =
                userData.data()?['occupation'] ?? '';
            _oldDescriptionController.text =
                userData.data()?['description'] ?? '';
            selectedMainCategory = userData.data()?['occupation'];
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return _currentImageUrl;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${_auth.currentUser?.uid}.jpg');

      await ref.putFile(_imageFile!);
      return await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }

  Future<void> _updateServiceProviderCategory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Remove from old category if changed
    if (_oldOccupationController.text.isNotEmpty &&
        _oldDescriptionController.text.isNotEmpty &&
        (_oldOccupationController.text != _occupationController.text ||
            _oldDescriptionController.text != _descriptionController.text)) {
      try {
        final oldServiceRef = FirebaseFirestore.instance
            .collection('services')
            .doc(_oldOccupationController.text)
            .collection('subcategories')
            .doc(_oldDescriptionController.text);

        final oldDoc = await oldServiceRef.get();
        if (oldDoc.exists) {
          List<String> providers =
              List<String>.from(oldDoc.data()?['providers'] ?? []);
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
          .doc(_occupationController.text)
          .collection('subcategories')
          .doc(_descriptionController.text);

      final doc = await newServiceRef.get();
      if (doc.exists) {
        List<String> providers =
            List<String>.from(doc.data()?['providers'] ?? []);
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
    setState(() => _isLoading = true);

    try {
      String? imageUrl = await _uploadImage();

      // Create an updates map with only non-empty values
      final Map<String, dynamic> updates = {};

      // Only add fields that have non-empty values
      if (_nameController.text.trim().isNotEmpty) {
        updates['name'] = _nameController.text.trim();
      }

      if (_phoneController.text.trim().isNotEmpty) {
        updates['phone'] = _phoneController.text.trim();
      }

      if (_addressController.text.trim().isNotEmpty) {
        updates['address'] = _addressController.text.trim();
      }

      if (imageUrl != null) {
        updates['profileImage'] = imageUrl;
      }

      if (!widget.isCustomer) {
        if (_occupationController.text.trim().isNotEmpty) {
          updates['occupation'] = _occupationController.text.trim();
        }
        if (_descriptionController.text.trim().isNotEmpty) {
          updates['description'] = _descriptionController.text.trim();
        }
        await _updateServiceProviderCategory();
      }

      // Only update if there are changes
      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(_auth.currentUser?.uid).set(
              updates,
              SetOptions(
                  merge:
                      true), // This will merge with existing data and create new fields if they don't exist
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No changes to update')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<ProfileProvider>(context).userData;
    final categoriesProvider = Provider.of<CategoriesProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: const Color(0xFFFDFCF9),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (userData?['profileImage'] != null
                                  ? NetworkImage(userData!['profileImage'])
                                  : null) as ImageProvider?,
                          child: (_imageFile == null &&
                                  userData?['profileImage'] == null)
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Color(0xff48B1DB),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xff48B1DB)),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xff48B1DB)),
                      ),
                      prefixIcon: const Icon(Icons.phone_outlined),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xff48B1DB)),
                      ),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                  ),
                  if (!widget.isCustomer) ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Occupation',
                      controller: _occupationController,
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
                              _occupationController.text = value;
                              selectedMainCategory = value;
                              _descriptionController.clear();
                            });
                          },
                          context: context,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Description',
                      controller: _descriptionController,
                      readOnly: true,
                      onTap: () async {
                        if (selectedMainCategory == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Please select an occupation first')),
                          );
                          return;
                        }

                        final subcategoriesSnapshot = await FirebaseFirestore
                            .instance
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
                              _descriptionController.text = value;
                            });
                          },
                          context: context,
                        );
                      },
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
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _occupationController.dispose();
    _descriptionController.dispose();
    _oldOccupationController.dispose();
    _oldDescriptionController.dispose();
    super.dispose();
  }
}
