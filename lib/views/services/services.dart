import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homease/views/notifications/notifications.dart';
import 'package:homease/views/all_services/all_services.dart';
import 'package:homease/views/services/provider/service_provider.dart';
import 'package:provider/provider.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServicesProvider>(context);
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
            const SizedBox(height: 20),
            Expanded(
              child: serviceProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white,))
                  : serviceProvider.error != null
                      ? Center(child: Text("Error: ${serviceProvider.error}"))
                      : SingleChildScrollView(
                          child: Column(
                            children: serviceProvider.categories.map((category) {
                              return Column(
                                children: [
                                  ServiceCategory(
                                    title: category['name'],
                                    services: List<String>.from(category['subcategories']),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }).toList(),
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
                          categoryName: title,
                          subcategoryName: service,
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