import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SectionShimmerLoading extends StatelessWidget {
  final String title;
  final bool isHorizontalList;
  final int itemCount;

  const SectionShimmerLoading({
    super.key,
    required this.title,
    this.isHorizontalList = true,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: isHorizontalList ? 170 : 90,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: isHorizontalList
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
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
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 100,
                              height: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 60,
                              height: 12,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: itemCount,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              width: 30,
                              height: 30,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 60,
                            height: 12,
                            color: Colors.white,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
} 