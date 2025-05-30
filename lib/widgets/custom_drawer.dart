import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:homease/views/authentication/login/login.dart';
import 'package:homease/views/bottom_bar/service_provider_status.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isCustomer = true;

  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        if (mounted) {
          setState(() {
            _isCustomer = !(data['serviceProvider'] ?? false);
          });
        }
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
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
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
    // Use the provider directly for the switch
    final serviceProviderStatus = Provider.of<ServiceProviderStatus>(context);
    
    return Drawer(
      backgroundColor: Colors.white,
      child: Container(
        color: const Color(0xFFF5F5E9),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 50),
            Row(
              children: [
                const SizedBox(width: 15),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: AssetImage('assets/logo/mainlogo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Go Home Ease",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
            _buildSectionTitle("SETTINGS"),
            // if (!_isCustomer)
            //   ListTile(
            //     leading: const Icon(Icons.radio_button_checked_sharp),
            //     title: const Text('Service Provider'),
            //     trailing: Switch(
            //       activeColor: Colors.white,
            //       activeTrackColor: Colors.green,
            //       value: serviceProviderStatus.isServiceProvider,
            //       onChanged: (value) {
            //         toggleServiceProvider(value);
            //       },
            //     ),
            //   ),
            // Rest of your drawer items
            _buildDrawerItem(Icons.account_circle, "My Account"),
            _buildDrawerItem(Icons.account_balance_wallet, "Wallet and Payment"),
            _buildDrawerItem(Icons.card_giftcard, "Credits and Gift Cards"),
            _buildDrawerItem(Icons.receipt_long, "My Orders"),
            _buildDrawerItem(Icons.bookmark, "My Favorites"),
            _buildSectionTitle("GIFT-ON-DEMAND"),
            _buildDrawerItem(Icons.card_giftcard, "Buy a Gift Card"),
            _buildSectionTitle("NETWORK"),
            _buildDrawerItem(Icons.flight_takeoff, "Boss Up Now"),
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