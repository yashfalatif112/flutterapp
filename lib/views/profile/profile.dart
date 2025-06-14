import 'package:flutter/material.dart';
import 'package:homease/views/bottom_bar/service_provider_status.dart';
import 'package:homease/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:homease/views/profile/tabbar_screens/portfolio/portfolio.dart';
import 'package:homease/views/profile/tabbar_screens/reviews_and_ratings.dart';
import 'package:homease/views/profile/tabbar_screens/certifications/certifications.dart';
import 'package:homease/views/profile/provider/profile_provider.dart';
import 'package:homease/views/profile/widgets/edit_profile.dart';
import 'package:homease/views/profile/screens/personal_information.dart';
import 'package:homease/views/profile/screens/order_history.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      Provider.of<ProfileProvider>(context, listen: false).fetchUserData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildServiceProviderProfile(Map<String, dynamic> userData) {
    final profilePic = userData['profileImage'] ?? '';
    final name = userData['name'] ?? 'No Name';
    final occupation = userData['occupation'] ?? 'No Occupation';
    final description = userData['description'] ?? 'No Description';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        profilePic.isNotEmpty ? NetworkImage(profilePic) : null,
                    child: profilePic.isEmpty ? Icon(Icons.person) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfileScreen(isCustomer: false),
                            ));
                      },
                      child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: Color(0xff48B1DB)),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                name,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Color(0xff48B1DB),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: Text(
                    occupation,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Color(0xff48B1DB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Service Type',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          description,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;

                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .get();

                          final currentStatus =
                              userDoc.data()?['serviceStatus'] ?? true;

                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .update({
                            'serviceStatus': !currentStatus,
                          });

                          // Start or stop location tracking based on new status
                          if (!currentStatus) {
                            await _locationService.startLocationTracking();
                          } else {
                            await _locationService.stopLocationTracking();
                          }

                          // Refresh the profile data
                          Provider.of<ProfileProvider>(context, listen: false)
                              .fetchUserData();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Error updating service status: $e')),
                          );
                        }
                      },
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final data =
                              snapshot.data?.data() as Map<String, dynamic>?;
                          final isActive = data?['serviceStatus'] ?? true;
                          return Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 2),
                              child: Text(
                                isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: isActive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 60.0),
              child: TabBar(
                dividerColor: Colors.transparent,
                controller: _tabController,
                indicatorColor: Color(0xff48B1DB),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: "Portfolio"),
                  Tab(
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("Reviews &\nRating",
                              textAlign: TextAlign.center))),
                  Tab(
                      child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("Certifications &\nQualifications",
                              textAlign: TextAlign.center))),
                ],
              ),
            ),
            SizedBox(height: 15),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              child: TabBarView(
                controller: _tabController,
                children: [
                  Portfolio(),
                  ReviewsAndRatings(),
                  Certifications(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerProfile(Map<String, dynamic> userData) {
    final profilePic = userData['profileImage'] ?? '';
    final name = userData['name'] ?? 'No Name';
    final email = userData['email'] ?? 'No Email';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: profilePic.isNotEmpty
                            ? NetworkImage(profilePic)
                            : null,
                        child: profilePic.isEmpty
                            ? Icon(Icons.person, size: 40)
                            : null,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Text(
                              email,
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xff48B1DB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(isCustomer: true),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xff48B1DB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.person_outline, color: Color(0xff48B1DB)),
                    ),
                    title: Text('Personal Information'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PersonalInformationScreen(userData: userData),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xff48B1DB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.history, color: Color(0xff48B1DB)),
                    ),
                    title: Text('Order History'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderHistoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCF9),
        elevation: 0,
        centerTitle: true,
        title: const Text("Profile"),
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<ProfileProvider, ServiceProviderStatus>(
        builder: (context, profileProvider, serviceProviderStatus, child) {
          if (profileProvider.userData == null) {
            return Center(child: CircularProgressIndicator());
          }

          return serviceProviderStatus.isServiceProvider
              ? _buildServiceProviderProfile(profileProvider.userData!)
              : _buildCustomerProfile(profileProvider.userData!);
        },
      ),
    );
  }
}
