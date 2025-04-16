import 'package:flutter/material.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Pluming service", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Date", style: TextStyle(color: Colors.grey)),
                Text("February 9, 2015", style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 20),

            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text("Service (01)", style: TextStyle(fontWeight: FontWeight.bold)),
              children:  [
                const ListTile(
                  title: Text("Service type"),
                  subtitle: Text("Drain repair"),
                ),
                const SizedBox(height: 10),
                const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
                  ),
                  child: const Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua...",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),

            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text("Service (02)", style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                const ListTile(
                  title: Text("Service type"),
                  subtitle: Text("Bath repair"),
                ),
                const SizedBox(height: 10),
                const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
                  ),
                  child: const Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua...",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),

            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: const Text("Service (03)", style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                const ListTile(
                  title: Text("Service type"),
                  subtitle: Text("Pipe repair"),
                ),
                const SizedBox(height: 10),
                const Text("Description", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4)],
                  ),
                  child: const Text(
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua...",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Text("Project document", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(4, (index) {
                return Container(
                  width: (MediaQuery.of(context).size.width - 52) / 2,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: AssetImage("assets/images/project_sample.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}
