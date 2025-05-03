import 'package:flutter/material.dart';
import 'package:homease/views/book_service/provider/booking_provider.dart';
import 'package:homease/views/wallet/wallet.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ConfirmBooking extends StatelessWidget {
  const ConfirmBooking({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final serviceName = bookingProvider.serviceName ?? 'N/A';
    final selectedDate = bookingProvider.selectedDate;
    final selectedTime = bookingProvider.selectedTime;
    final address = bookingProvider.address ?? 'N/A';
    final instructions = bookingProvider.instructions ?? 'N/A';
    final currentUserId = bookingProvider.currentUserId;
    final serviceProviderId = bookingProvider.serviceProviderId;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Confirm Booking',
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Summary',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow('Service', serviceName),
              const Divider(),
              _buildInfoRow(
                  'Date',
                  selectedDate != null
                      ? DateFormat('MMMM d, yyyy').format(selectedDate)
                      : 'N/A'),
              const Divider(),
              _buildInfoRow('Time',
                  selectedTime != null ? selectedTime.format(context) : 'N/A'),
              const Divider(),
              _buildInfoRow('Address', address),
              const Divider(),
              _buildInfoRow('Special Instructions', instructions),
              const Divider(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WalletScreen(fromConfirmBooking: true,),
                        ),
                      );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Confirm Booking',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
