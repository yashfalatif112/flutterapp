import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool isServiceProvider = false;

  @override
  void initState() {
    super.initState();
    fetchServiceProviderStatus();
  }

  void fetchServiceProviderStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          isServiceProvider = doc.data()?['serviceProvider'] ?? false;
        });
      }
    }
  }

  void toggleServiceProvider(bool value) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'serviceProvider': value,
      });
      setState(() {
        isServiceProvider = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            
            ListTile(
              leading: const Icon(Icons.radio_button_checked_sharp),
              title: const Text('Service Provider'),
              trailing: Switch(
                activeColor: Colors.white,
                activeTrackColor: Colors.green,
                value: isServiceProvider,
                onChanged: (value) {
                  toggleServiceProvider(value);
                },
              ),
            ),

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
            _buildDrawerItem(Icons.logout, "Logout"),
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

  Widget _buildDrawerItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {},
    );
  }
}
