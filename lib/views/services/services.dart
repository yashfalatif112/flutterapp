import 'package:flutter/material.dart';
import 'package:homease/views/all_services/all_services.dart';
import 'package:homease/views/services/provider/service_provider.dart';
import 'package:provider/provider.dart';

class BookingsScreen extends StatelessWidget {
  final String? selectedCategory;
  const BookingsScreen({super.key, this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServicesProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedCategory ?? 'All Services'),
        centerTitle: true,
        automaticallyImplyLeading: selectedCategory != null,
        backgroundColor: Color(0xFFF8F1EB),
        leading: selectedCategory != null
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              )
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(6)
                  ),
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
              ),
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
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : serviceProvider.error != null
                        ? Center(child: Text("Error: ${serviceProvider.error}"))
                        : SingleChildScrollView(
                            child: Column(
                              children: serviceProvider.categories
                                  .where((category) =>
                                      selectedCategory == null ||
                                      category['name'] == selectedCategory)
                                  .map((category) {
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

class ServiceCategory extends StatelessWidget {
  final String title;
  final List<String> services;

  const ServiceCategory({
    Key? key,
    required this.title,
    required this.services,
  }) : super(key: key);

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