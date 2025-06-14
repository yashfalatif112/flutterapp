import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homease/views/bottom_bar/service_provider_status.dart';
import 'package:homease/views/home/service_home.dart';
import 'package:homease/views/profile/provider/profile_provider.dart';
import 'package:homease/views/services/services.dart';
import 'package:homease/views/bottom_bar/provider/bottom_bar_provider.dart';
import 'package:homease/views/home/home.dart';
import 'package:homease/views/messages/messages.dart';
import 'package:homease/views/profile/profile.dart';
import 'package:homease/views/wallet/wallet.dart';
import 'package:homease/widgets/custom_drawer.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class BottomBarScreen extends StatefulWidget {
  BottomBarScreen({super.key});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  List<Widget> _screens = [];

  final List<String> _icons = const [
    'assets/icons/bottom1.svg',
    'assets/icons/bottom2.svg',
    'assets/icons/bottom3.svg',
    'assets/icons/bottom4.svg',
    'assets/icons/bottom5.svg',
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDataAndUpdateStatus();
  }

  void fetchUserDataAndUpdateStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final isServiceProvider = data['serviceProvider'] ?? false;
        
        // Update the provider with the fetched status
        if (mounted) {
          Provider.of<ServiceProviderStatus>(context, listen: false)
              .setStatus(isServiceProvider);
        }
      }
    }
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      Provider.of<ProfileProvider>(context, listen: false).fetchUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BottomNavProvider>(context);
    final serviceProviderStatus = Provider.of<ServiceProviderStatus>(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    _screens = [
      serviceProviderStatus.isServiceProvider
          ? ServiceHomeScreen(scaffoldKey: _scaffoldKey)
          : HomeScreen(scaffoldKey: _scaffoldKey),
      BookingsScreen(),
      WalletScreen(),
      MessageScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      drawer: const CustomDrawer(),
      key: _scaffoldKey,
      body: _screens[provider.currentIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_icons.length, (index) {
            final isSelected = provider.currentIndex == index;
            return GestureDetector(
              onTap: () => provider.changeTab(index),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xff48B1DB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      _icons[index],
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}