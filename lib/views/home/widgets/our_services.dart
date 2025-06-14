import 'package:flutter/material.dart';
import 'package:homease/views/authentication/signup/provider/category_provider.dart';
import 'package:homease/views/services/services.dart';
import 'package:provider/provider.dart';

class OurServices extends StatelessWidget {
  const OurServices({super.key});

  IconData getServiceIcon(String serviceName) {
    switch (serviceName.toLowerCase()) {
      case 'auto':
        return Icons.directions_car;
      case 'beauty':
        return Icons.brush;
      case 'care':
        return Icons.health_and_safety;
      case 'events':
        return Icons.event;
      case 'finance':
        return Icons.account_balance_wallet;
      case 'fitness':
        return Icons.fitness_center;
      case 'home':
        return Icons.home;
      case 'other':
        return Icons.miscellaneous_services;
      case 'real estate':
        return Icons.house;
      case 'repairs':
        return Icons.build;
      case 'wellness':
        return Icons.spa;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CategoriesProvider>(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(child: Text('Error: ${provider.error}'));
    }

    final categories = provider.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Our Services',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingsScreen(
                        selectedCategory: category['name'],
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        getServiceIcon(category['name']),
                        color: Color(0xff48B1DB),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category['name'],
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
