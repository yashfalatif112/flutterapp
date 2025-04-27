import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homease/views/book_service/provider/booking_provider.dart';
import 'package:homease/views/payment_status/payment_status.dart';
import 'package:homease/widgets/dialog.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCF7),
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        title: const Text('Payment Integration',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.more_vert, color: Colors.black),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardBox(
                text: 'Connected',
                onTap: () async {
                  final bookingProvider =
                      Provider.of<BookingProvider>(context, listen: false);

                  final serviceName = bookingProvider.serviceName ?? 'N/A';
                  final selectedDate = bookingProvider.selectedDate;
                  final selectedTime = bookingProvider.selectedTime;
                  final address = bookingProvider.address ?? 'N/A';
                  final instructions = bookingProvider.instructions ?? 'N/A';
                  final currentUserId = bookingProvider.currentUserId;
                  final serviceProviderId = bookingProvider.serviceProviderId;

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) =>
                        const Center(child: CircularProgressIndicator(color: Colors.black,)),
                  );

                  final selectedTimeFormatted = selectedTime != null
                      ? selectedTime.format(context)
                      : 'N/A';

                  try {
                    await FirebaseFirestore.instance
                        .collection('bookings')
                        .add({
                      'serviceName': serviceName,
                      'selectedDate': selectedDate,
                      'selectedTime': selectedTimeFormatted,
                      'address': address,
                      'instructions': instructions,
                      'currentUserId': currentUserId,
                      'serviceProviderId': serviceProviderId,
                      'paymentStatus': 'Approved',
                      'createdAt': Timestamp.now(),
                    });

                    await Future.delayed(const Duration(seconds: 1));

                    Navigator.pop(context);

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => ThankYouDialog(
                        titleText: 'Payment Approved',
                        subtitleText:
                            'Your payment has been approved successfully',
                        buttonText: 'Continue',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PaymentStatus()),
                          );
                        },
                      ),
                    );
                  } catch (e) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save booking: $e')),
                    );
                  }
                },
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddNewCardScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Add New Card',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardBox extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const CardBox({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class AddNewCardScreen extends StatelessWidget {
  const AddNewCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFDFCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCF7),
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        title:
            const Text('Add New Card', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.more_vert, color: Colors.black),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.credit_card, color: Colors.white, size: 28),
                    SizedBox(height: 16),
                    Text('1234 5678 8765 0876',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 2)),
                    SizedBox(height: 4),
                    Text('VALID THRU    12/28',
                        style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 4),
                    Text('ALEX',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const InputField(label: 'Card Name', hint: 'Ivory Black'),
              const SizedBox(height: 12),
              const InputField(label: 'Card Number', hint: '****  8765  3456'),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(
                      child: InputField(label: 'Expiry Date', hint: '05/29')),
                  SizedBox(width: 12),
                  Expanded(child: InputField(label: 'CVV', hint: '***')),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => ThankYouDialog(
                        titleText: 'Card Added',
                        subtitleText: 'Your card has been added successfully',
                        buttonText: 'Continue',
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PaymentStatus()));
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Add',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final String label;
  final String hint;

  const InputField({super.key, required this.label, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
