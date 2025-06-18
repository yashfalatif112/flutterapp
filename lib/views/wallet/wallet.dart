import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homease/provider/user_provider.dart';
import 'package:homease/services/paypal_service.dart';
import 'package:homease/services/stripe_service.dart';
import 'package:homease/views/book_service/provider/booking_provider.dart';
import 'package:homease/views/bottom_bar/bottom_bar.dart';
import 'package:homease/views/payment_status/payment_status.dart';
import 'package:homease/views/wallet/add_card.dart';
import 'package:homease/views/wallet/widgets/card_box.dart';
import 'package:homease/views/wallet/widgets/paypal_payment_handler.dart' as paypal;
import 'package:homease/widgets/dialog.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

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
  bool isProcessingPayment = false;
  final PayPalService _paypalService = PayPalService();

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

  void _showPaymentMethodDialog(Map<String, dynamic> card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Select Payment Method', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: SvgPicture.asset('assets/icons/stripe.svg',
                  width: 32, height: 32),
              title: const Text('Pay with Stripe'),
              onTap: () {
                Navigator.pop(context);
                _processStripePayment(card);
              },
            ),
            const Divider(),
            ListTile(
              leading: SvgPicture.asset('assets/icons/paypal.svg',
                  width: 32, height: 32),
              title: const Text('Pay with PayPal'),
              onTap: () {
                Navigator.pop(context);
                _processPayPalPayment(card);
              },
            ),
          ],
        ),
      ),
    );
  }

  // New method for PayPal payment
  Future<void> _processPayPalPayment(Map<String, dynamic> card) async {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    if (bookingProvider.price == null || bookingProvider.price! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid payment amount')),
      );
      return;
    }

    setState(() {
      isProcessingPayment = true;
    });

    try {
      const Uuid().v4();
      final String returnUrl = 'homease://payment/success';
      final String cancelUrl = 'homease://payment/cancel';

      final result = await _paypalService.createPayment(
        amount: bookingProvider.price!,
        currency: 'USD',
        returnUrl: returnUrl,
        cancelUrl: cancelUrl,
        description: 'Payment for ${bookingProvider.serviceName ?? "services"}',
      );

      setState(() {
        isProcessingPayment = false;
      });

      if (result['success'] == true && result['approvalUrl'] != null) {
        
        // Show PayPal WebView for payment
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => paypal.PayPalWebView(
                approvalUrl: result['approvalUrl'],
                returnUrl: returnUrl,
                cancelUrl: cancelUrl,
                onSuccess: (paymentId, payerId) async {
                  Navigator.pop(context); // Close the WebView
                  
                  // Execute the payment
                  try {
                    final executeResult = await _paypalService.executePayment(
                      paymentId: paymentId,
                      payerId: payerId,
                    );

                    if (executeResult['success'] == true) {
                      await _saveBookingToFirebase(card, 'Approved', 'PayPal');
                    } else {
                      _showPaymentFailedDialog(
                        executeResult['message'] ?? 'Failed to execute payment'
                      );
                    }
                  } catch (e) {
                    _showPaymentFailedDialog('Error executing payment: $e');
                  }
                },
                onCancel: () {
                  Navigator.pop(context);
                  _showPaymentFailedDialog('Payment was cancelled');
                },
                onError: () {
                  Navigator.pop(context);
                  _showPaymentFailedDialog('An error occurred during payment');
                },
              ),
            ),
          );
        }
      } else {
        _showPaymentFailedDialog(
            result['message'] ?? 'Failed to create PayPal payment');
      }
    } catch (e) {
      setState(() {
        isProcessingPayment = false;
      });
      _showPaymentFailedDialog('Error: ${e.toString()}');
    }
  }

  Future<void> _processStripePayment(Map<String, dynamic> card) async {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    if (bookingProvider.price == null || bookingProvider.price! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid payment amount')),
      );
      return;
    }

    setState(() {
      isProcessingPayment = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      ),
    );

    try {
      final stripeService = StripeService();

      final initResponse = await stripeService.initPaymentSheet(
        amount: (bookingProvider.price! * 100).round(),
        currency: 'usd',
        customerName: card['cardName'] ?? 'Customer',
      );

      if (!initResponse.success) {
        Navigator.pop(context);
        _showPaymentFailedDialog(
            initResponse.message ?? 'Payment initialization failed');
        return;
      }

      final result = await stripeService.presentPaymentSheet();

      Navigator.pop(context);

      if (result.success) {
        await _saveBookingToFirebase(card, 'Approved', 'Stripe');
      } else {
        _showPaymentFailedDialog(result.message ?? 'Payment processing failed');
      }
    } catch (e) {
      Navigator.pop(context);
      _showPaymentFailedDialog('Error: ${e.toString()}');
    } finally {
      setState(() {
        isProcessingPayment = false;
      });
    }
  }

  Future<void> _saveBookingToFirebase(
      Map<String, dynamic> card, String paymentStatus, String paymentType) async {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    final serviceName = bookingProvider.serviceName ?? 'N/A';
    final selectedDate = bookingProvider.selectedDate;
    final selectedTime = bookingProvider.selectedTime;
    final address = bookingProvider.address ?? 'N/A';
    final instructions = bookingProvider.instructions ?? 'N/A';
    final currentUserId = bookingProvider.currentUserId;
    final serviceProviderId = bookingProvider.serviceProviderId;
    final price = bookingProvider.price;

    final selectedTimeFormatted =
        selectedTime != null ? selectedTime.format(context) : 'N/A';

    final cardNumber = card['cardNumber'] ?? '';
    final last4Digits = cardNumber.length > 4
        ? cardNumber.substring(cardNumber.length - 4)
        : cardNumber;

    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'serviceName': serviceName,
        'selectedDate': selectedDate,
        'selectedTime': selectedTimeFormatted,
        'address': address,
        'instructions': instructions,
        'currentUserId': currentUserId,
        'serviceProviderId': serviceProviderId,
        'status': "pending",
        'price': price,
        'paymentStatus': paymentStatus,
        'paymentMethod': {
          'type': paymentType,
          'cardName': card['cardName'],
          'last4Digits': paymentType == 'PayPal' ? 'PayPal' : last4Digits,
        },
        'createdAt': Timestamp.now(),
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ThankYouDialog(
          titleText: 'Payment Approved',
          subtitleText: 'Your payment has been approved successfully',
          buttonText: 'Continue',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => BottomBarScreen()),
              (route) => false,
            );
            Provider.of<BookingProvider>(context).clearBookingData();
          },
        ),
      );
    } catch (e) {
      _showPaymentFailedDialog('Failed to save booking: $e');
    }
  }

  void _showPaymentFailedDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Payment Failed', textAlign: TextAlign.center),
          ],
        ),
        content: Text(
          errorMessage,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFCF7),
        elevation: 0,
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        //   onPressed: () => Navigator.pop(context),
        // ),
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
                    child: CircularProgressIndicator(color: Color(0xff48B1DB)),
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
                          ? () {
                              _showPaymentMethodDialog(card);
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
                    backgroundColor: Color(0xff48B1DB),
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