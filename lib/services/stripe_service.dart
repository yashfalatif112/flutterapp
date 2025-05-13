// lib/views/wallet/services/stripe_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  StripeResponse({
    required this.success,
    this.message,
    this.data,
  });
}

class StripeService {
  static void init() {
    Stripe.publishableKey =
        'pk_live_51RBwfcBc9GZiVt1MckyJCoOXFNcVsoSPzMMGvpIqQ8LT7vAYgvTDsPpGYrnG7Fx8tA0Ejua8filc5Azed1mQdBcP00Y6hpx0sW';
  }

  Future<StripeResponse> createPaymentIntent({
    required int amount,
    required String currency,
    String? customerName,
  }) async {
    try {
      const String secretKey =
          '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';

      final url = Uri.parse('https://api.stripe.com/v1/payment_intents');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency,
          'payment_method_types[]': 'card',
        },
      );

      if (response.statusCode == 200) {
        return StripeResponse(
          success: true,
          data: json.decode(response.body),
        );
      } else {
        final errorData = json.decode(response.body);
        return StripeResponse(
          success: false,
          message: errorData['error']?['message'] ?? 'Payment setup failed',
        );
      }
    } catch (e) {
      return StripeResponse(
        success: false,
        message: 'Error creating payment: $e',
      );
    }
  }

  Future<StripeResponse> initPaymentSheet({
    required int amount,
    required String currency,
    String? customerName,
  }) async {
    try {
      final paymentIntentResult = await createPaymentIntent(
        amount: amount,
        currency: currency,
        customerName: customerName,
      );

      if (!paymentIntentResult.success) {
        return paymentIntentResult;
      }

      final clientSecret = paymentIntentResult.data!['client_secret'] as String;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'HomeEase',
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF4CAF50),
            ),
            shapes: PaymentSheetShape(
              borderRadius: 12,
              borderWidth: 1,
            ),
          ),
          billingDetails: const BillingDetails(
            name: "HomeEase Customer",
          ),
        ),
      );

      return StripeResponse(success: true);
    } catch (e) {
      return StripeResponse(
        success: false,
        message: 'Error initializing payment: $e',
      );
    }
  }

  Future<StripeResponse> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      return StripeResponse(
        success: true,
        message: 'Payment completed successfully',
      );
    } on StripeException catch (e) {
      switch (e.error.code) {
        case FailureCode.Canceled:
          return StripeResponse(
            success: false,
            message: 'Payment canceled',
          );
        case FailureCode.Failed:
          return StripeResponse(
            success: false,
            message: 'Payment failed: ${e.error.localizedMessage}',
          );
        default:
          return StripeResponse(
            success: false,
            message: e.error.localizedMessage ?? 'Payment error occurred',
          );
      }
    } catch (e) {
      return StripeResponse(
        success: false,
        message: 'Error processing payment: $e',
      );
    }
  }

  Future<StripeResponse> confirmCardPayment(
    String paymentIntentClientSecret,
    CardDetails cardDetails,
  ) async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: const BillingDetails(
              name: "HomeEase Customer",
            ),
          ),
        ),
      );

      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentClientSecret,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: paymentMethod.id,
          ),
        ),
      );

      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        return StripeResponse(
          success: true,
          message: 'Payment successful',
          data: {'paymentIntentId': paymentIntent.id},
        );
      } else {
        return StripeResponse(
          success: false,
          message: 'Payment failed: ${paymentIntent.status}',
        );
      }
    } on StripeException catch (e) {
      return StripeResponse(
        success: false,
        message: e.error.localizedMessage ?? 'Payment error occurred',
      );
    } catch (e) {
      return StripeResponse(
        success: false,
        message: 'Error confirming payment: $e',
      );
    }
  }
}
