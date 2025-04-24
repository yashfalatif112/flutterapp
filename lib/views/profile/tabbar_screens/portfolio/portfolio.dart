import 'package:flutter/material.dart';
import 'package:homease/views/profile/widgets/calender.dart';

class Portfolio extends StatelessWidget {
  const Portfolio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.star, color: Colors.amber),
                SizedBox(width: 5),
                Text("4.99",
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 5),
                Text("of 20 reviews", style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 10),
            const Text("United States", style: TextStyle(color: Colors.black)),
            const Text("Business address",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            const Text("172 project posted",
                style: TextStyle(color: Colors.black)),
            const Text("70% hire rate, 1 open project",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            const Text("57k\$ total spent",
                style: TextStyle(color: Colors.black)),
            const Text("Business address",
                style: TextStyle(color: Colors.grey)),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("'Next Availability'",
                        style: TextStyle(color: Colors.grey)),
                    Text('2 AM', style: TextStyle(color: Colors.grey))
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CalenderScreen()));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.green),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Text(
                        'Next Availability',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
