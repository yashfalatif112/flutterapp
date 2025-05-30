import 'package:flutter/material.dart';
import 'package:homease/views/profile/provider/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:homease/views/profile/tabbar_screens/certifications/certifications.dart';
import 'package:homease/views/profile/tabbar_screens/portfolio/portfolio.dart';
import 'package:homease/views/profile/tabbar_screens/task_screen/task.dart';
import 'package:homease/views/bottom_bar/service_provider_status.dart';
import 'package:homease/views/profile/widgets/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profilePic.isNotEmpty
                      ? NetworkImage(profilePic)
                      : null,
                  child: profilePic.isEmpty ? Icon(Icons.person) : null,
                ),
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(isCustomer: false),
                      ),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.green,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: Text(
                    occupation,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                name,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.green,
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
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
                        child: Text('Active'),
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
                indicatorColor: Colors.green,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: "Portfolio"),
                  Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text("Reviews &\nRating", textAlign: TextAlign.center))),
                  Tab(child: FittedBox(fit: BoxFit.scaleDown, child: Text("Certifications &\nQualifications", textAlign: TextAlign.center))),
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: profilePic.isNotEmpty
                      ? NetworkImage(profilePic)
                      : null,
                  child: profilePic.isEmpty ? Icon(Icons.person) : null,
                ),
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(isCustomer: true),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                name,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                email,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person_outline),
                    title: Text('Personal Information'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.history),
                    title: Text('Order History'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.favorite_border),
                    title: Text('Saved Services'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
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
        // actions: [
        //   Container(
        //     margin: const EdgeInsets.only(right: 10),
        //     width: 40,
        //     height: 40,
        //     decoration: BoxDecoration(
        //       border: Border.all(color: Colors.grey.shade400),
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //     child: const Icon(Icons.more_vert),
        //   ),
        // ],
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
