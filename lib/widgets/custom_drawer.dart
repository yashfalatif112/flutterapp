import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Container(
        color: const Color(0xFFF5F5E9),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(height: 50,),
            Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundImage: AssetImage('assets/logo/logo.png'),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Go Home Ease",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )
              ],
            ),
            _buildSectionTitle("SETTINGS"),
            _buildDrawerItem(Icons.account_circle, "My Account"),
            _buildDrawerItem(
                Icons.account_balance_wallet, "Wallet and Payment"),
            _buildDrawerItem(
                Icons.card_giftcard, "Credits and Gift Cards"),
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
