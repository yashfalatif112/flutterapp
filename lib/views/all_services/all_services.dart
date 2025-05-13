import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homease/views/book_service/book_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homease/views/messages/chat_screen.dart';

class AllServicesScreen extends StatefulWidget {
  final String categoryName;
  final String subcategoryName;

  const AllServicesScreen(
      {super.key, required this.categoryName, required this.subcategoryName});

  @override
  State<AllServicesScreen> createState() => _AllServicesScreenState();
}

class _AllServicesScreenState extends State<AllServicesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _serviceProviders = [];
  String? _error;
  double? _servicePrice;

  @override
  void initState() {
    super.initState();
    _fetchServiceProviders();
  }

  Future<void> _fetchServiceProviders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserId = currentUser?.uid;

      final subcategoryDoc = await _firestore
          .collection('services')
          .doc(widget.categoryName)
          .collection('subcategories')
          .doc(widget.subcategoryName)
          .get();

      if (!subcategoryDoc.exists) {
        setState(() {
          _isLoading = false;
          _serviceProviders = [];
        });
        return;
      }

      if (subcategoryDoc.data()!.containsKey('price')) {
        _servicePrice = (subcategoryDoc.data()!['price'] as num).toDouble();
      }

      if (!subcategoryDoc.data()!.containsKey('users')) {
        setState(() {
          _isLoading = false;
          _serviceProviders = [];
        });
        return;
      }

      final userIds = List<String>.from(subcategoryDoc.data()!['users'] ?? []);

      if (userIds.isEmpty) {
        setState(() {
          _isLoading = false;
          _serviceProviders = [];
        });
        return;
      }

      final List<Map<String, dynamic>> providers = [];

      for (var userId in userIds) {
        if (userId == currentUserId) continue;

        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists && userDoc.data() != null) {
          providers.add({
            ...userDoc.data()!,
            'id': userDoc.id,
          });
        }
      }

      setState(() {
        _isLoading = false;
        _serviceProviders = providers;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = "Error loading service providers: $e";
      });
      print("Error fetching service providers: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf8ed),
      appBar: AppBar(
        backgroundColor: const Color(0xfffdf8ed),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.subcategoryName,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.grid_view, color: Colors.black),
          SizedBox(width: 17),
          Icon(Icons.settings, color: Colors.black),
          SizedBox(width: 9),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                    color: Colors.black,
                  ))
                : _error != null
                    ? Center(child: Text(_error!))
                    : _serviceProviders.isEmpty
                        ? Center(
                            child: Text(
                                "No service providers available for ${widget.subcategoryName}"))
                        : ListView.builder(
                            itemCount: _serviceProviders.length,
                            itemBuilder: (context, index) {
                              final provider = _serviceProviders[index];
                              return ServiceTile(
                                name: provider['name'] ?? 'Unknown',
                                imageUrl: provider['profilePic'],
                                occupation: provider['occupation'] ?? 'Unknown',
                                description:
                                    provider['description'] ?? 'No description',
                                address: provider['address'] ?? 'Unknown',
                                userId: provider['id'],
                                servicePrice: _servicePrice,
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final String occupation;
  final String description;
  final String address;
  final String userId;
  final double? servicePrice;

  const ServiceTile({
    super.key,
    required this.name,
    this.imageUrl,
    required this.occupation,
    required this.description,
    required this.address,
    required this.userId,
    this.servicePrice,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookService(
              providerId: userId,
              providerName: name,
              providerImage: imageUrl,
              providerOccupation: occupation,
              providerDescription: description,
              providerAddress: address,
              servicePrice: servicePrice,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                  ? NetworkImage(imageUrl!)
                  : null,
              backgroundColor: Colors.grey[300],
              child: imageUrl == null || imageUrl!.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          address,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // if (servicePrice != null)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 4.0),
                  //     child: Text(
                  //       "Price: \$${servicePrice!.toStringAsFixed(2)}",
                  //       style: const TextStyle(
                  //         fontSize: 14,
                  //         fontWeight: FontWeight.w500,
                  //         color: Colors.green,
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey,
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () async {
                final currentUser = FirebaseAuth.instance.currentUser!;
                final userData = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .get();

                final ids = [currentUser.uid, userId];
                ids.sort();
                final chatId = ids.join('_');

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .collection('chats')
                    .doc(userId)
                    .set({
                  'chatId': chatId,
                  'userName': name,
                  'userImage': imageUrl ?? '',
                  'lastMessage': '',
                  'timestamp': FieldValue.serverTimestamp(),
                  'unreadCount': 0,
                }, SetOptions(merge: true));

                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(userId)
                    .collection('chats')
                    .doc(currentUser.uid)
                    .set({
                  'chatId': chatId,
                  'userName': userData.data()?['name'] ?? 'User',
                  'userImage': userData.data()?['profilePic'] ?? '',
                  'lastMessage': '',
                  'timestamp': FieldValue.serverTimestamp(),
                  'unreadCount': 0,
                }, SetOptions(merge: true));

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      otherUserId: userId,
                      otherUserName: name,
                      otherUserImage: imageUrl,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.chat_sharp, color: Colors.black),
            ),
            const SizedBox(
              width: 5,
            )
          ],
        ),
      ),
    );
  }
}
