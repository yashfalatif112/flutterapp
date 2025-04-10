import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homease/views/home/widgets/home_header.dart';
import 'package:homease/views/home/widgets/most_popular.dart';
import 'package:homease/views/home/widgets/our_services.dart';
import 'package:homease/views/home/widgets/recommended_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFF8F1EB),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/bell.svg',
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/vert_bars.svg',
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      backgroundColor: const Color(0xFFF8F1EB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                HomeHeader(),
                SizedBox(height: 20),
                OurServices(),
                SizedBox(height: 20),
                MostPopularSection(),
                SizedBox(height: 20),
                RecommendedSection(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        color: Colors.green,
        ),
        child: Icon(Icons.star_border,color: Colors.white,),
      ),
    );
  }
}
