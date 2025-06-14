import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homease/views/authentication/login/login.dart';
import 'package:homease/views/bottom_bar/service_provider_status.dart';
import 'package:provider/provider.dart';
import 'package:homease/views/bookings/pending_bookings_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data();
        });
      }
    }
  }

  void toggleServiceProvider(bool value) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      // Update in Firebase
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'serviceProvider': value,
      });

      // Update in provider
      Provider.of<ServiceProviderStatus>(context, listen: false)
          .setStatus(value);
    }
  }

  Future<void> handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "No",
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigate to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceProviderStatus = Provider.of<ServiceProviderStatus>(context);

    return Drawer(
      backgroundColor: Colors.white,
      child: Container(
        color: const Color(0xFFF5F5E9),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                spacing: 10,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/logo/background_logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  Text(
                    "Go Home Ease",
                    style: const TextStyle(
                         fontSize: 20),
                  )
                ],
              ),
            ),
            _buildSectionTitle("SETTINGS"),
            _buildDrawerItem(Icons.account_circle, "My Account"),
            _buildDrawerItem(
                Icons.account_balance_wallet, "Wallet and Payment"),
            _buildDrawerItem(Icons.card_giftcard, "Credits and Gift Cards"),
            _buildDrawerItem(Icons.receipt_long, "My Orders"),
            _buildDrawerItem(Icons.bookmark, "My Favorites"),
            if (!serviceProviderStatus.isServiceProvider)
              _buildDrawerItem(
                Icons.location_on_outlined,
                'Track Your Booking',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PendingBookingsScreen(),
                    ),
                  );
                },
              ),
            _buildSectionTitle("GIFT-ON-DEMAND"),
            _buildDrawerItem(Icons.card_giftcard, "Buy a Gift Card"),
            _buildSectionTitle("NETWORK"),
            _buildDrawerItem(Icons.flight_takeoff, "Signup Now"),
            _buildDrawerItem(Icons.home, "Become a Partner"),
            _buildDrawerItem(Icons.share, "Sponsorship Opportunities"),
            _buildSectionTitle("SUPPORT ON DEMAND"),
            _buildDrawerItem(Icons.contact_mail, "Contact Us"),
            _buildDrawerItem(Icons.info_outline, "How It Works"),
            _buildSectionTitle("THE ESSENTIALS"),
            _buildDrawerItem(Icons.group, "About Us"),
            _buildDrawerItem(Icons.article, "Terms & Conditions"),
            _buildDrawerItem(Icons.privacy_tip, "Privacy Policy"),
            _buildDrawerItem(
              Icons.logout,
              "Logout",
              () => handleLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, [VoidCallback? onTap]) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}
