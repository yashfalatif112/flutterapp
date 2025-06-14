import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PayPalWebView extends StatefulWidget {
  final String approvalUrl;
  final String returnUrl;
  final String cancelUrl;
  final Function(String paymentId, String payerId) onSuccess;
  final VoidCallback onCancel;
  final VoidCallback onError;

  const PayPalWebView({
    Key? key,
    required this.approvalUrl,
    required this.returnUrl,
    required this.cancelUrl,
    required this.onSuccess,
    required this.onCancel,
    required this.onError,
  }) : super(key: key);

  @override
  State<PayPalWebView> createState() => _PayPalWebViewState();
}

class _PayPalWebViewState extends State<PayPalWebView> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(widget.returnUrl)) {
              final uri = Uri.parse(request.url);
              final paymentId = uri.queryParameters['paymentId'];
              final payerId = uri.queryParameters['PayerID'];
              if (paymentId != null && payerId != null) {
                widget.onSuccess(paymentId, payerId);
              } else {
                widget.onError();
              }
              return NavigationDecision.prevent;
            }
            if (request.url.startsWith(widget.cancelUrl)) {
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
    return WillPopScope(
      onWillPop: () async {
        widget.onCancel();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: widget.onCancel,
          ),
          title: const Text('PayPal Checkout', 
            style: TextStyle(color: Colors.black),
          ),
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
      ),
    );
  }
}
