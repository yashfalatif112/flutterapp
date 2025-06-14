import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homease/views/home/widgets/book_later_section.dart';
import 'package:homease/views/home/widgets/home_header.dart';
import 'package:homease/views/home/widgets/most_popular.dart';
import 'package:homease/views/home/widgets/our_services.dart';
import 'package:homease/views/home/widgets/phone_consultation_section.dart';
import 'package:homease/views/home/widgets/recommended_section.dart';
import 'package:homease/views/home/widgets/whats_buzzing_section.dart';

class HomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const HomeScreen({super.key, required this.scaffoldKey});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _menuKey = GlobalKey();
  void _showPopupMenu() {
    final RenderBox button = _menuKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero, ancestor: overlay);
    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + button.size.height + 5,
      offset.dx + button.size.width,
      0,
    );

    showMenu(
      context: context,
      position: position,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      items: [
        _popupItem('Phone Consultation'),
        _popupItem('New on Platform'),
        _popupItem('Hot this Week'),
        _popupItem('Extended Hours Experts'),
        _popupItem('Favorites'),
        _popupItem("What's Buzzing Today"),
        _popupItem('Search for services'),
        _popupItem('Start a project'),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFF8F1EB),
        actions: [
          // GestureDetector(
          //   onTap: () {
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => NotificationScreen()));
          //   },
          //   child: Padding(
          //     padding: const EdgeInsets.only(right: 10.0),
          //     child: Container(
          //       width: 29,
          //       height: 29,
          //       decoration: BoxDecoration(
          //           border: Border.all(color: Colors.grey),
          //           borderRadius: BorderRadius.circular(6)),
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           SvgPicture.asset(
          //             'assets/icons/bell.svg',
          //             width: 20,
          //             height: 20,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          GestureDetector(
            onTap: () {
              final scaffold = Scaffold.of(context);
              if (scaffold.hasDrawer) {
                scaffold.openDrawer();
              } else {
                widget.scaffoldKey.currentState?.openDrawer();
              }
            },
            child: Padding(
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
                      'assets/icons/vert_bars.svg',
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            key: _menuKey,
            onTap: _showPopupMenu,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Container(
                width: 29,
                height: 29,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(6)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.more_vert)],
                ),
              ),
            ),
          ),
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
                SizedBox(height: 20),
                BookLaterSection(),
                SizedBox(height: 20),
                PhoneConsultationSection(),
                SizedBox(height: 20),
                WhatsBuzzingSection(),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: Container(
      //   width: 60,
      //   height: 60,
      //   decoration: BoxDecoration(
      //     shape: BoxShape.circle,
      //     color: Colors.green,
      //   ),
      //   child: Icon(
      //     Icons.star_border,
      //     color: Colors.white,
      //   ),
      // ),
    );
  }
}


PopupMenuItem _popupItem(String title) {
  return PopupMenuItem(
    value: title,
    child: Text(title),
  );
}
