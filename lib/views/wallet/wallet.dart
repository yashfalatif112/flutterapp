import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homease/provider/user_provider.dart';
import 'package:homease/views/book_service/provider/booking_provider.dart';
import 'package:homease/views/bottom_bar/bottom_bar.dart';
import 'package:homease/views/payment_status/payment_status.dart';
import 'package:homease/widgets/dialog.dart';
import 'package:provider/provider.dart';

class WalletScreen extends StatefulWidget {
  final bool? fromConfirmBooking;
  const WalletScreen({super.key, this.fromConfirmBooking = false});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String? currentUserId;
  bool isLoading = true;
  List<Map<String, dynamic>> cards = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchUserData();
      currentUserId = userProvider.currentUserId;
      if (currentUserId != null && currentUserId!.isNotEmpty) {
        _fetchUserCards();
      }
    });
  }

  Future<void> _fetchUserCards() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userDoc.exists && userDoc.data()!.containsKey('cards')) {
        final cardsData = userDoc.data()!['cards'] as List<dynamic>;
        setState(() {
          cards = List<Map<String, dynamic>>.from(cardsData);
          isLoading = false;
        });
      } else {
        setState(() {
          cards = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch cards: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Payment Integration',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentStatus()),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset('assets/icons/bell.svg'),
              ),
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
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: Colors.green),
                  ),
                )
              else if (cards.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No payment methods added yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cards.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    final cardNumber = card['cardNumber'] ?? '';
                    final last4Digits = cardNumber.length > 4
                        ? cardNumber.substring(cardNumber.length - 4)
                        : cardNumber;

                    return CardBox(
                      text: 'Connected **** $last4Digits',
                      onTap: widget.fromConfirmBooking == true
                          ? () async {
                              final bookingProvider =
                                  Provider.of<BookingProvider>(context,
                                      listen: false);

                              final serviceName =
                                  bookingProvider.serviceName ?? 'N/A';
                              final selectedDate = bookingProvider.selectedDate;
                              final selectedTime = bookingProvider.selectedTime;
                              final address = bookingProvider.address ?? 'N/A';
                              final instructions =
                                  bookingProvider.instructions ?? 'N/A';
                              final currentUserId =
                                  bookingProvider.currentUserId;
                              final serviceProviderId =
                                  bookingProvider.serviceProviderId;

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.black)),
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
                                  'status': "pending",
                                  'paymentStatus': 'Approved',
                                  'paymentMethod': {
                                    'cardName': card['cardName'],
                                    'last4Digits': last4Digits,
                                  },
                                  'createdAt': Timestamp.now(),
                                });

                                await Future.delayed(
                                    const Duration(seconds: 1));

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
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                BottomBarScreen()),
                                        (route) => false,
                                      );
                                    },
                                  ),
                                );
                              } catch (e) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Failed to save booking: $e')),
                                );
                              }
                            }
                          : null,
                    );
                  },
                ),
              const SizedBox(height: 30),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => AddNewCardScreen(
                                currentUserId: currentUserId,
                                onCardAdded: _fetchUserCards,
                              )),
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

class AddNewCardScreen extends StatefulWidget {
  final String? currentUserId;
  final VoidCallback onCardAdded;

  const AddNewCardScreen({
    super.key,
    required this.currentUserId,
    required this.onCardAdded,
  });

  @override
  State<AddNewCardScreen> createState() => _AddNewCardScreenState();
}

class _AddNewCardScreenState extends State<AddNewCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _saveCardToFirebase() async {
    if (_formKey.currentState?.validate() != true ||
        widget.currentUserId == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the user document reference
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId);

      // Create a new card object
      final newCard = {
        'cardName': _cardNameController.text.trim(),
        'cardNumber': _cardNumberController.text.replaceAll(' ', '').trim(),
        'expiryDate': _expiryDateController.text.trim(),
        'cvv': _cvvController.text.trim(),
        'addedAt': Timestamp.now(),
      };

      // Get the current user document
      final userDoc = await userRef.get();

      if (userDoc.exists) {
        // If user already has cards, append the new one
        if (userDoc.data()!.containsKey('cards')) {
          await userRef.update({
            'cards': FieldValue.arrayUnion([newCard])
          });
        } else {
          // If user doesn't have cards yet, create the array
          await userRef.update({
            'cards': [newCard]
          });
        }
      } else {
        // If user document doesn't exist yet (shouldn't happen normally)
        await userRef.set({
          'cards': [newCard]
        });
      }

      setState(() {
        _isLoading = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ThankYouDialog(
          titleText: 'Card Added',
          subtitleText: 'Your card has been added successfully',
          buttonText: 'Continue',
          onPressed: () {
            widget.onCardAdded();
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Go back to wallet screen
          },
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add card: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFFDFCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
          child: Form(
            key: _formKey,
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
                    children: [
                      const Icon(Icons.credit_card,
                          color: Colors.white, size: 28),
                      const SizedBox(height: 16),
                      Text(
                        _cardNumberController.text.isEmpty
                            ? '1234 5678 8765 0876'
                            : _cardNumberController.text,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            letterSpacing: 2),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'VALID THRU    ${_expiryDateController.text.isEmpty ? '12/28' : _expiryDateController.text}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _cardNameController.text.isEmpty
                            ? 'CARD HOLDER'
                            : _cardNameController.text.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _cardNameController,
                  decoration: InputDecoration(
                    labelText: 'Card Name',
                    hintText: 'Card Holder Name',
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter card holder name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cardNumberController,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    hintText: '1234 5678 9012 3456',
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
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter card number';
                    }
                    // Remove spaces and check if it's a valid card format (simplified)
                    final cleanNumber = value.replaceAll(' ', '');
                    if (cleanNumber.length < 13 || cleanNumber.length > 19) {
                      return 'Please enter a valid card number';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _expiryDateController,
                        decoration: InputDecoration(
                          labelText: 'Expiry Date',
                          hintText: 'MM/YY',
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          // Simple MM/YY validation
                          if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                            return 'Use MM/YY format';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _cvvController,
                        decoration: InputDecoration(
                          labelText: 'CVV',
                          hintText: '123',
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
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Required';
                          }
                          if (value.length < 3 || value.length > 4) {
                            return 'Invalid CVV';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveCardToFirebase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Add',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
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
