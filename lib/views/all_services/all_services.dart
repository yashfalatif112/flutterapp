import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homease/views/book_service/book_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:homease/views/messages/chat_screen.dart';
import 'package:homease/views/profile/tabbar_screens/portfolio/portfolio.dart';
import 'package:homease/views/profile/tabbar_screens/reviews_and_ratings.dart';
import 'package:homease/views/profile/tabbar_screens/certifications/certifications.dart';

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
          final serviceStatus = userDoc.data()?['serviceStatus'];
          if (serviceStatus == null || serviceStatus == true) {
            providers.add({
              ...userDoc.data()!,
              'id': userDoc.id,
            });
          }
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

class ServiceProviderProfileScreen extends StatefulWidget {
  final String providerId;
  final String providerName;
  final String? providerImage;
  final String providerOccupation;
  final String providerDescription;
  final String providerAddress;

  const ServiceProviderProfileScreen({
    super.key,
    required this.providerId,
    required this.providerName,
    this.providerImage,
    required this.providerOccupation,
    required this.providerDescription,
    required this.providerAddress,
  });

  @override
  State<ServiceProviderProfileScreen> createState() =>
      _ServiceProviderProfileScreenState();
}

class _ServiceProviderProfileScreenState
    extends State<ServiceProviderProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Service Provider Profile',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xff48B1DB).withOpacity(0.2),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[100],
                          backgroundImage: widget.providerImage != null &&
                                  widget.providerImage!.isNotEmpty
                              ? NetworkImage(widget.providerImage!)
                              : null,
                          child: widget.providerImage == null ||
                                  widget.providerImage!.isEmpty
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey[400],
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.providerName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xff48B1DB),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    child: Text(
                      widget.providerOccupation,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.providerDescription,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Color(0xff48B1DB)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.providerAddress,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                dividerColor: Colors.transparent,
                controller: _tabController,
                indicatorColor: const Color(0xff48B1DB),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: "Portfolio"),
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Reviews &\nRating",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Tab(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Certifications &\nQualifications",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: TabBarView(
                controller: _tabController,
                children: [
                  Portfolio(providerId: widget.providerId),
                  ReviewsAndRatings(providerId: widget.providerId),
                  Certifications(providerId: widget.providerId),
                ],
              ),
            ),
          ],
        ),
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
                          color: Color(0xff48B1DB), size: 16),
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
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceProviderProfileScreen(
                      providerId: userId,
                      providerName: name,
                      providerImage: imageUrl,
                      providerOccupation: occupation,
                      providerDescription: description,
                      providerAddress: address,
                    ),
                  ),
                );
              },
              child: const Icon(Icons.person_outline, color: Colors.black),
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
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
  }
}
