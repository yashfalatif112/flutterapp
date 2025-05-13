// lib/utils/call_error_handler.dart

import 'package:flutter/material.dart';

class CallErrorHandler {
  // Handle call errors
  static void handleCallError(BuildContext context, dynamic error) {
    // Error message to show
    String errorMessage = 'Failed to join call';
    
    // Parse Agora error
    if (error.toString().contains('AgoraRtcException(-102)')) {
      errorMessage = 'Token authentication failed. Please check your connection and try again.';
    } else if (error.toString().contains('AgoraRtcException(-17)')) {
      errorMessage = 'Join channel failed. Please check your internet connection.';
    } else if (error.toString().contains('Failed to generate token')) {
      errorMessage = 'Token server error. Please try again later.';
    }
    
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Pop the screen after showing error
    Future.delayed(const Duration(seconds: 1), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }
}