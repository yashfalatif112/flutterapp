import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homease/views/bottom_bar/provider/bottom_bar_provider.dart';
import 'package:homease/views/home/home.dart';
import 'package:provider/provider.dart';

class BottomBarScreen extends StatelessWidget {
  const BottomBarScreen({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    Placeholder(),
    Placeholder(),
    Placeholder(),
    Placeholder(),
  ];

  final List<String> _icons = const [
    'assets/icons/bottom1.svg',
    'assets/icons/bottom2.svg',
    'assets/icons/bottom3.svg',
    'assets/icons/bottom4.svg',
    'assets/icons/bottom5.svg',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BottomNavProvider>(context);

    return Scaffold(
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
                  color: isSelected ? Colors.green : Colors.transparent,
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
