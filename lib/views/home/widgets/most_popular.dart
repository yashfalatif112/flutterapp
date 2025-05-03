import 'package:flutter/material.dart';
import 'package:homease/views/services/provider/service_provider.dart';
import 'package:provider/provider.dart';

class MostPopularSection extends StatelessWidget {
  const MostPopularSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ServicesProvider>(
      builder: (context, servicesProvider, _) {
        final items = servicesProvider.randomSubcategories;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Popular Near You',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                // const Spacer(),
                // const Icon(Icons.more_horiz),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 185,
              child: servicesProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
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
                                  image: item['image'] != null &&
                                          item['image'].isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(item['image']),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: AssetImage(
                                              'assets/images/mostPopular.png'),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['name'] ?? 'No Name',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '\$${item['price'].toString()}',
                                style: const TextStyle(color: Colors.green),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '★ ${item['rating'].toString()}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const Icon(Icons.arrow_forward,
                                      size: 18, color: Colors.green),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
