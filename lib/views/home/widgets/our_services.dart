import 'package:flutter/material.dart';

class OurServices extends StatelessWidget {
  const OurServices({super.key});

  final List<Map<String, dynamic>> services = const [
    {'icon': Icons.electrical_services, 'label': 'Electrician'},
    {'icon': Icons.cleaning_services, 'label': 'Cleaner'},
    {'icon': Icons.grass, 'label': 'Gardener'},
    {'icon': Icons.handyman, 'label': 'Carpenter'},
    {'icon': Icons.pets, 'label': 'Pet Grooming'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Our services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Spacer(),
            Icon(Icons.more_horiz)
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final service = services[index];
              return Column(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(service['icon'], color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(service['label'], style: const TextStyle(fontSize: 12)),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
