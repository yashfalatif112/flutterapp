import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class TokenService {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  TokenService._internal();

  // Replace with your Firebase Function URL after deployment
  static const String tokenServerUrl = 'https://us-central1-go-home-ease.cloudfunctions.net/generateAgoraToken';

  // Cache token to avoid unnecessary requests
  final Map<String, _CachedToken> _tokenCache = {};

  // Get token for channel
  Future<String> getToken(String channelName) async {
    try {
      // Get current user
      final User? user = FirebaseAuth.instance.currentUser;
      
      // Ensure user is logged in
      if (user == null) {
        throw Exception('User must be logged in to generate a token');
      }

      // Generate numeric uid from user id - ensure it's positive and within int range
      final int uid = user.uid.hashCode.abs() % 100000;

      // Check if we have a valid cached token
      final cachedToken = _tokenCache[channelName];
      if (cachedToken != null && !cachedToken.isExpired) {
        debugPrint('Using cached token for channel: $channelName');
        return cachedToken.token;
      }

      debugPrint('Requesting new token for channel: $channelName, uid: $uid');
      
      // Request token from server with increased timeout
      final response = await http.post(
        Uri.parse(tokenServerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'channelName': channelName,
          'uid': uid,
          'role': 'publisher'
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Token request timed out'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (!data.containsKey('token') || data['token'] == null) {
          throw Exception('Invalid token response from server');
        }
        
        final token = data['token'] as String;
        debugPrint('Successfully received token for channel: $channelName');
        
        // Cache the token with expiration
        final newCachedToken = _CachedToken(
          token: token, 
          expiresAt: DateTime.now().add(const Duration(minutes: 50))  // Expire before the actual token expiration
        );
        _tokenCache[channelName] = newCachedToken;
        
        return token;
      } else {
        // More detailed error logging
        debugPrint('Token generation failed. Status code: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        throw Exception('Failed to generate token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Detailed token generation error: $e');
      rethrow;
    }
  }

  // Clear token cache
  void clearTokenCache() {
    _tokenCache.clear();
  }
  
  // Get token with retry logic
  Future<String> getTokenWithRetry(String channelName, {int maxRetries = 3}) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await getToken(channelName);
      } catch (e) {
        attempts++;
        debugPrint('Token fetch attempt $attempts failed: $e');
        
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(Duration(seconds: 2 * attempts));
      }
    }
    
    throw Exception('Failed to get token after $maxRetries attempts');
  }
}

// Internal class to manage token caching with expiration
class _CachedToken {
  final String token;
  final DateTime expiresAt;

  _CachedToken({required this.token, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}