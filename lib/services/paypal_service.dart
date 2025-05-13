import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class PayPalService {
  final String _clientId = 'ASfDFMynV2eSzV4tlOSI8ml6W4KFWqYAGqEw9XPbbyckQPWqLyZNfb-jLS3p3mpEus-ECnlFc00qkn_s';
  final String _secret = 'ENOif3zapEH9ZOIhWozuCCftGgz2ymebRukdl7JO1rbhZvwcYuKqKTjBnH1bhcSyfnW8bHml_JLOYRl7';
  final String _baseUrl = 'https://api-m.sandbox.paypal.com';

  Future<String?> _getAccessToken() async {
    try {
      final authString = base64.encode(utf8.encode('$_clientId:$_secret'));
      
      final response = await http.post(
        Uri.parse('$_baseUrl/v1/oauth2/token'),
        headers: {
          'Authorization': 'Basic $authString',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=client_credentials',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['access_token'];
      } else {
        debugPrint('Failed to get access token: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Error getting access token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> createPayment({
    required double amount,
    required String currency,
    required String returnUrl,
    required String cancelUrl,
    String description = 'Payment for services',
  }) async {
    try {
      final accessToken = await _getAccessToken();
      
      if (accessToken == null) {
        return {
          'success': false,
          'message': 'Failed to authenticate with PayPal',
        };
      }

      final payload = {
        'intent': 'sale',
        'payer': {
          'payment_method': 'paypal',
        },
        'transactions': [
          {
            'amount': {
              'total': amount.toStringAsFixed(2),
              'currency': currency,
            },
            'description': description,
          }
        ],
        'redirect_urls': {
          'return_url': returnUrl,
          'cancel_url': cancelUrl,
        }
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/payments/payment'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        String approvalUrl = '';
        
        for (var link in data['links']) {
          if (link['rel'] == 'approval_url') {
            approvalUrl = link['href'];
            break;
          }
        }

        return {
          'success': true,
          'paymentId': data['id'],
          'approvalUrl': approvalUrl,
        };
      } else {
        debugPrint('Failed to create payment: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to create payment: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Error creating payment: $e');
      return {
        'success': false,
        'message': 'Error creating payment: $e',
      };
    }
  }

  Future<Map<String, dynamic>> executePayment({
    required String paymentId,
    required String payerId,
  }) async {
    try {
      final accessToken = await _getAccessToken();
      
      if (accessToken == null) {
        return {
          'success': false,
          'message': 'Failed to authenticate with PayPal',
        };
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/v1/payments/payment/$paymentId/execute'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'payer_id': payerId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final state = data['state'];
        
        return {
          'success': state.toLowerCase() == 'approved',
          'paymentId': paymentId,
          'paymentState': state,
          'data': data,
        };
      } else {
        debugPrint('Failed to execute payment: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to execute payment: ${response.statusCode}',
        };
      }
    } catch (e) {
      debugPrint('Error executing payment: $e');
      return {
        'success': false,
        'message': 'Error executing payment: $e',
      };
    }
  }
}

class PayPalWebView extends StatefulWidget {
  final String approvalUrl;
  final String returnUrl;
  final String cancelUrl;
  final Function(String, String) onSuccess;
  final VoidCallback onCancel;
  final VoidCallback onError;

  const PayPalWebView({
    super.key,
    required this.approvalUrl,
    required this.returnUrl,
    required this.cancelUrl,
    required this.onSuccess,
    required this.onCancel,
    required this.onError,
  });

  @override
  State<PayPalWebView> createState() => _PayPalWebViewState();
}

class _PayPalWebViewState extends State<PayPalWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            
            if (url.startsWith(widget.returnUrl)) {
              final uri = Uri.parse(url);
              final payerId = uri.queryParameters['PayerID'];
              final paymentId = uri.queryParameters['paymentId'];
              
              if (payerId != null && paymentId != null) {
                widget.onSuccess(paymentId, payerId);
              } else {
                widget.onError();
              }
              return NavigationDecision.prevent;
            }
            
            if (url.startsWith(widget.cancelUrl)) {
              widget.onCancel();
              return NavigationDecision.prevent;
            }
            
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('PayPal Checkout', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: widget.onCancel,
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            ),
        ],
      ),
    );
  }
}