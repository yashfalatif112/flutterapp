import 'package:flutter/material.dart';
import 'package:homease/views/services/services.dart';
import 'package:homease/views/services/provider/service_provider.dart';
import 'package:homease/views/home/widgets/shimmer_loading.dart';
import 'package:provider/provider.dart';

class WhatsBuzzingSection extends StatelessWidget {
  const WhatsBuzzingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServicesProvider>(context);
    final allCategories = provider.categories;
    
    if (provider.isLoading) {
      return const SectionShimmerLoading(
        title: "What's Buzzing Today",
      );
    }

    if (allCategories.isEmpty) {
      return const SizedBox.shrink(); // Return empty widget if no categories
    }
    
    // If we have less than 5 items, just use all of them
    // Otherwise, take items 20-24 (or cycle back to start if needed)
    final categories = List.generate(
      allCategories.length < 5 ? allCategories.length : 5,
      (index) {
        final actualIndex = (index + 20) % allCategories.length;
        return allCategories[actualIndex];
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "What's Buzzing Today",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
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
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/recommended.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['name'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${category['subcategories']?.length ?? 0} services",
                        style: const TextStyle(color: Color(0xff48B1DB)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 