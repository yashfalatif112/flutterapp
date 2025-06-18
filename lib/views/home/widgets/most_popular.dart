import 'package:flutter/material.dart';
import 'package:homease/views/services/services.dart';
import 'package:homease/views/services/provider/service_provider.dart';
import 'package:homease/views/home/widgets/shimmer_loading.dart';
import 'package:provider/provider.dart';

class MostPopularSection extends StatelessWidget {
  const MostPopularSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesProvider>(
      builder: (context, servicesProvider, _) {
        if (servicesProvider.isLoading) {
          return const SectionShimmerLoading(
            title: 'Popular Near You',
          );
        }

        final categories = servicesProvider.categories.take(5).toList();

        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Popular Near You',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                              image: const DecorationImage(
                                image: AssetImage(
                                    'assets/images/mostPopular.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  category['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xff48B1DB),
                                size: 18,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}