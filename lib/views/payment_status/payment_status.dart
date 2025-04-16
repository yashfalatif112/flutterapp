import 'package:flutter/material.dart';

class PaymentStatus extends StatelessWidget {
  const PaymentStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> bookings = [
      {
        'serviceName': 'Sparkling Home Cleaning',
        'dateTime': 'March 15, 2024, 10:00 AM',
        'status': 'Pending',
      },
      {
        'serviceName': 'Spa Salon',
        'dateTime': 'March 15, 2024, 10:00 AM',
        'status': 'Paid',
      },
      {
        'serviceName': 'Sparkling Home Cleaning',
        'dateTime': 'March 15, 2024, 10:00 AM',
        'status': 'Pending',
      },
      {
        'serviceName': 'Spa Salon',
        'dateTime': 'March 15, 2024, 10:00 AM',
        'status': 'Paid',
      },
      {
        'serviceName': 'Sparkling Home Cleaning',
        'dateTime': 'March 15, 2024, 10:00 AM',
        'status': 'Pending',
      },
      {
        'serviceName': 'Spa Salon',
        'dateTime': 'March 15, 2024, 10:00 AM',
        'status': 'Paid',
      },
      {
        'serviceName': 'Sparkling Home Cleaning',
        'dateTime': 'March 15, 2024, 10:00 AM',
        'status': 'Pending',
      },
      {
        'serviceName': 'Spa Salon',
        'dateTime': 'March 15, 2024, 10:00 AM',
        'status': 'Paid',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Payment Status',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          final bool isPending = booking['status'] == 'Pending';
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage('https://placehold.co/400x400/png?text=Profile'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                booking['serviceName'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert,size: 20,),
                                onPressed: () {},
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                booking['dateTime'],
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 11,
                                ),
                              ),
                              Spacer(),
                              Text(
                                booking['status'],
                                style: TextStyle(
                                  color: isPending ? Colors.green : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 15,)
                            ],
                          ),
                          const SizedBox(height: 8),
                          
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                height: 30,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isPending ? Colors.green : Colors.white,
                                    foregroundColor: isPending ? Colors.white : Colors.green,
                                    side: isPending ? null : BorderSide(color: Colors.green),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: Text(
                                    isPending ? 'Pay now' : 'Send Notification',
                                  ),
                                ),
                              ),
                              
                              if (isPending)
                                SizedBox(
                                  height: 30,
                                  child: OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      side: const BorderSide(color: Colors.green),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    child: const Text('Send Reminder',style: TextStyle(
                                      color: Colors.white
                                    ),),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (index < bookings.length - 1)
                const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
            ],
          );
        },
      ),
    );
  }
}