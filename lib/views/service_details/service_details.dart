import 'package:flutter/material.dart';


class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf8ed),
      appBar: AppBar(
        backgroundColor: const Color(0xfffdf8ed),
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/women/1.jpg',
            ),
          ),
        ),
        title: const Text(
          'All services',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.grid_view, color: Colors.black),
          SizedBox(width: 17),
          Icon(Icons.settings, color: Colors.black),
          SizedBox(width: 9),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Electrician',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.filter_list, color: Colors.white),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (context, index) {
                return const ServiceTile();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  const ServiceTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        radius: 25,
        backgroundImage: NetworkImage(
          'https://randomuser.me/api/portraits/women/1.jpg',
        ),
      ),
      title: const Text('Brooklyn Simmons', style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: const [
          Icon(Icons.access_time, size: 16, color: Colors.grey),
          SizedBox(width: 4),
          Text('1hr-2hr', style: TextStyle(fontSize: 12)),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.orange, size: 16),
              SizedBox(width: 4),
              Text('4.99'),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, color: Colors.green, size: 16),
              Text('Location', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
