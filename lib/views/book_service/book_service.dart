import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homease/views/book_service/confirm_booking.dart';
import 'package:homease/views/book_service/provider/booking_provider.dart';
import 'package:homease/views/book_service/widgets/service_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookService extends StatefulWidget {
  final String providerId;
  final String providerName;
  final String? providerImage;
  final String? providerOccupation;
  final String? providerDescription;
  final String? providerAddress;
  final double? servicePrice;
  final bool isCustomOffer;

  const BookService({
    super.key,
    required this.providerId,
    required this.providerName,
    this.providerImage,
    this.providerOccupation,
    this.providerDescription,
    this.providerAddress,
    this.servicePrice,
    this.isCustomOffer = false,
  });

  @override
  State<BookService> createState() => _BookServiceState();
}

class _BookServiceState extends State<BookService> {
  String? selectedService;
  bool isDropdownOpen = false;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isCustomOffer && widget.servicePrice != null) {
      _priceController.text = widget.servicePrice.toString();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.isCustomOffer ? 'Custom Offer' : 'Task',
          style: const TextStyle(
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
              Text(
                '${widget.providerDescription ?? 'Service'} Booking',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              buildServiceCard(
                title: "SERVICE",
                service: widget.providerDescription ?? 'Service',
                index: 1,
                onTap: () {},
              ),
              const SizedBox(height: 12),
              const Text(
                'Select Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('M/d/yyyy').format(selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedTime.format(context),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.access_time, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    hintText: 'Street, City, Zip Code',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Your Offered Price',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _priceController,
                  enabled: !widget.isCustomOffer,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    hintText: widget.isCustomOffer ? 'Custom offer price' : 'Enter your price (e.g., 50.00)',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.attach_money, color: Color(0xff48B1DB)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Special Instruction (Optional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _instructionController,
                  decoration: const InputDecoration(
                    hintText: 'Write here...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  maxLines: 5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_addressController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter an address')),
                      );
                      return;
                    }

                    if (_priceController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter your offered price')),
                      );
                      return;
                    }

                    double? userOfferedPrice;
                    try {
                      userOfferedPrice = double.parse(_priceController.text.trim());
                      if (userOfferedPrice <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid price greater than 0')),
                        );
                        return;
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a valid price')),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        );
                      },
                    );

                    try {
                      final String currentUserId = await getCurrentUserId();

                      Navigator.pop(context);

                      final bookingProvider =
                          Provider.of<BookingProvider>(context, listen: false);
                      bookingProvider.setBookingData(
                        serviceName: widget.providerDescription ?? '',
                        selectedDate: selectedDate,
                        selectedTime: selectedTime,
                        address: _addressController.text.trim(),
                        instructions: _instructionController.text.trim(),
                        currentUserId: currentUserId,
                        serviceProviderId: widget.providerId,
                        price: userOfferedPrice,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConfirmBooking(),
                        ),
                      );
                    } catch (e) {
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff48B1DB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.isCustomOffer ? 'Confirm Booking' : 'Book Now',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 30,)
            ],
          ),
        ),
      ),
    );
  }

  Future<String> getCurrentUserId() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return '';
    }

    final authUid = currentUser.uid;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authUid)
          .get();

      if (userDoc.exists && userDoc.data()!.containsKey('uid')) {
        return userDoc.data()!['uid'] as String;
      } else {
        return authUid;
      }
    } catch (e) {
      print('Error fetching user data: $e');

      return authUid;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _instructionController.dispose();
    _priceController.dispose(); // Don't forget to dispose the new controller
    super.dispose();
  }
}