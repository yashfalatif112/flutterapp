import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homease/views/notifications/notifications.dart';
import 'package:homease/views/service_details/service_details.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Services'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFFF8F1EB),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(6)
            ),
            child: Icon(Icons.person,color: Colors.white,size: 18,),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationScreen()));
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
                      'assets/icons/bell.svg',
                      width: 20,
                      height: 20,
                    ),
                  ],
                ),
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
                    'assets/icons/settings.svg',
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // const _AppBarSection(),
              // const SizedBox(height: 20),
              const _SearchBarSection(),
              const SizedBox(height: 20),
              const Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ServiceCategory(
                        title: 'Electrician Services',
                        services: [
                          'Electrical Wiring & Rewiring',
                          'Ceiling Fan Installation/Repair',
                          'Circuit Breaker Repairs',
                          'Lighting Installation (LED, Chandeliers)',
                          'Power Outlet Repair/Installation',
                        ],
                      ),
                      SizedBox(height: 16),
                      ServiceCategory(
                        title: 'Plumbing Services',
                        services: [
                          'Pipe Repairs and Replacements',
                          'Water Heater Installation/Repair',
                          'Sink and Faucet Installation/Repair',
                          'Bathroom Fitting Installation',
                          'Sewer Line Repairs',
                        ],
                      ),
                      SizedBox(height: 16),
                      ServiceCategory(
                        title: 'Carpentry Services',
                        services: [
                          'Custom Furniture Design',
                          'Door and Window Repairs',
                          'Cabinet Repairs and Installation',
                          'General Woodworking Repairs',
                          'Sewer Line Repairs',
                        ],
                      ),
                      SizedBox(height: 16),
                      ServiceCategory(
                        title: 'Cleaning Services',
                        services: [
                          'House Deep Cleaning',
                          'Office Cleaning',
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBarSection extends StatelessWidget {
  const _SearchBarSection();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(6)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/filter.svg',
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ServiceCategory extends StatelessWidget {
  final String title;
  final List<String> services;

  const ServiceCategory({
    super.key,
    required this.title,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...services.map(
            (service) => Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AllServicesScreen(
                      
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(service),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
