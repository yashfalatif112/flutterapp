import 'package:flutter/material.dart';
import 'package:homease/views/services/services.dart';
import 'package:homease/views/services/provider/service_provider.dart';
import 'package:homease/views/home/widgets/shimmer_loading.dart';
import 'package:provider/provider.dart';

class RecommendedSection extends StatelessWidget {
  const RecommendedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServicesProvider>(context);
    
    if (provider.isLoading) {
      return const SectionShimmerLoading(
        title: 'Instant Help',
      );
    }

    // Skip the first 5 categories (shown in MostPopular) and take the next 5
    final categories = provider.categories.skip(5).take(5).toList();

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instant Help',
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
