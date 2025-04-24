import 'package:flutter/material.dart';
import 'package:homease/views/authentication/signup/provider/category_provider.dart';
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
        Row(
          children: const [
            Text('On-Demand Categories',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Spacer(),
            Icon(Icons.more_horiz)
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final service = categories[index]['name'] ?? '';
              return Column(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(getServiceIcon(service), color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(service, style: const TextStyle(fontSize: 12)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
