import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homease/views/profile/tabbar_screens/task_screen/task.dart';

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.more_vert),
          )
        ],
      ),
      body: SingleChildScrollView( // Wrap the body in a SingleChildScrollView
        child: Column(
          children: [
            SizedBox(
              height: 220,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                    child: Image.asset(
                      "assets/images/eiffel.png",
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 3,
                    child: CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.person),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const Text(
                    "Ralph Edwards",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset('assets/icons/chat_icon.svg'),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const Text("Business name", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const Text(
                    "24 reviews",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TabBar(
              dividerColor: Colors.transparent,
              controller: _tabController,
              indicatorColor: Colors.green,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "About"),
                Tab(text: "Tasks"),
                Tab(text: "Reviews"),
              ],
            ),
            SizedBox( 
              height: MediaQuery.of(context).size.height,
              child: TabBarView(
                controller: _tabController,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber),
                            SizedBox(width: 5),
                            Text("4.99", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(width: 5),
                            Text("of 20 reviews", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text("United States", style: TextStyle(color: Colors.black)),
                        Text("Business address", style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 10),
                        Text("172 project posted", style: TextStyle(color: Colors.black)),
                        Text("70% hire rate, 1 open project", style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 10),
                        Text("57k\$ total spent", style: TextStyle(color: Colors.black)),
                        Text("Business address", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  TaskDetailScreen(),
                  const Center(child: Text("Reviews will be shown here.")),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
