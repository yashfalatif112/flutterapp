import 'package:flutter/material.dart';
import 'package:homease/services/paypal_service.dart';
import 'package:homease/views/book_service/provider/booking_provider.dart';
import 'package:homease/views/bottom_bar/bottom_bar.dart';
import 'package:homease/widgets/dialog.dart';
import 'package:provider/provider.dart';

class PayPalPaymentHandler extends StatefulWidget {
  final String paymentId;
  final String payerId;
  final Function(bool success, Map<String, dynamic> data) onPaymentComplete;

  const PayPalPaymentHandler({
    super.key,
    required this.paymentId,
    required this.payerId,
    required this.onPaymentComplete,
  });

  @override
  State<PayPalPaymentHandler> createState() => _PayPalPaymentHandlerState();
}

class _PayPalPaymentHandlerState extends State<PayPalPaymentHandler> {
  bool isLoading = true;
  bool isSuccess = false;
  String message = "Processing payment...";
  final PayPalService _paypalService = PayPalService();

  @override
  void initState() {
    super.initState();
    _verifyPayment();
  }

  Future<void> _verifyPayment() async {
    try {
      final result = await _paypalService.executePayment(
        paymentId: widget.paymentId,
        payerId: widget.payerId,
      );

      setState(() {
        isLoading = false;
        isSuccess = result['success'] == true;
        message = result['success'] == true
            ? 'Payment successful!'
            : result['message'] ?? 'Payment verification failed';
      });

      widget.onPaymentComplete(isSuccess, result);

      if (isSuccess) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
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
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                message,
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isSuccess = false;
        message = 'Error: ${e.toString()}';
      });

      widget.onPaymentComplete(false, {'message': message});

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              message,
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Processing Payment',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const CircularProgressIndicator(color: Colors.blue)
            else
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 80,
              ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
