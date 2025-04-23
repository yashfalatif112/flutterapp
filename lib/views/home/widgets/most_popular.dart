import 'package:flutter/material.dart';

class MostPopularSection extends StatelessWidget {
  const MostPopularSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Most Popular', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Spacer(),
            Icon(Icons.more_horiz)
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 185,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
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
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(image: AssetImage('assets/images/mostPopular.png'),fit: BoxFit.cover)
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('AC Repair Services', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Text('\$100', style: TextStyle(color: Colors.green)),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('★ 5.5', style: TextStyle(fontSize: 12)),
                        Icon(Icons.arrow_forward, size: 18, color: Colors.green),
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
  }
}
