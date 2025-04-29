import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homease/views/home/service_widgets/header.dart';
import 'package:homease/views/home/service_widgets/my_services.dart';

class ServiceHomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const ServiceHomeScreen({super.key, required this.scaffoldKey});

  @override
  State<ServiceHomeScreen> createState() => _ServiceHomeScreenState();
}

class _ServiceHomeScreenState extends State<ServiceHomeScreen> {
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Services'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF8F1EB),
        actions: [
          _iconButton('assets/icons/bell.svg', () {
            // Notification logic
          }),
          _iconButton('assets/icons/vert_bars.svg', () {
            widget.scaffoldKey.currentState?.openDrawer();
          }),
          GestureDetector(
            key: _menuKey,
            onTap: _showPopupMenu,
            child: _iconContainer(child: const Icon(Icons.more_vert)),
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
              children: [
                // Header Section
                Header(),
                const SizedBox(height: 20),

                // My Services
                MyServices(),
                const SizedBox(height: 20),

                // New Requests
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('New requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('View all', style: TextStyle(color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 10),
                _requestCard('Ac Installation', 'October 31, 2017', '12:23 pm - 2:00 pm', 'New offer'),
                const SizedBox(height: 10),

                const SizedBox(height: 20),

                // Active Requests
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Active requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('View all', style: TextStyle(color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 10),
                _requestCard('Ac Installation', 'October 31, 2017', '12:23 pm - 2:00 pm', 'Active'),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconButton(String assetPath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: _iconContainer(
          child: SvgPicture.asset(assetPath, width: 20, height: 20),
        ),
      ),
    );
  }

  Widget _iconContainer({required Widget child}) {
    return Container(
      width: 29,
      height: 29,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(child: child),
    );
  }


  Widget _requestCard(String title, String date, String time, String status) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text('$date\n$time', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status, style: const TextStyle(color: Colors.green)),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Divider(indent: 20,endIndent: 20,),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.person,color: Colors.white,),
            ),
            title: Text('Ronald Richards'),
            subtitle: Text('England',style: TextStyle(color: Colors.grey,fontSize: 12),),
          ),
          SizedBox(height: 10,),
          Row(
            children: [
              SizedBox(width: 15,),
              Container(
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.black
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Center(child: Text('Decline',style: TextStyle(color: Colors.green),),),
                ),
              ),
              Spacer(),
              Container(
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.green
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Center(child: Text('Accept',style: TextStyle(color: Colors.black),),),
                ),
              ),
              SizedBox(width: 15,),
            ],
          )
        ],
      ),
    );
  }



PopupMenuItem _popupItem(String title) {
  return PopupMenuItem(
    value: title,
    child: Text(title),
  );
}
}