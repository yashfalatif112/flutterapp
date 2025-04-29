import 'package:flutter/material.dart';
import 'package:homease/provider/user_provider.dart';
import 'package:provider/provider.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<UserProvider>(context, listen: false).fetchUserData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Row(
      children: [
        const CircleAvatar(
          backgroundImage: AssetImage('assets/images/profile.png'),
          radius: 25,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi, ${userProvider.name}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('Welcome to go homease',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Current location',
                style: TextStyle(fontSize: 10, color: Colors.grey)),
            Row(
              children: [
                Text(userProvider.address,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
