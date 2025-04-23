import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginProvider with ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  bool _agreedToTerms = false;
  bool get agreedToTerms => _agreedToTerms;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void toggleObscure() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleTerms(bool? value) {
    _agreedToTerms = value ?? false;
    notifyListeners();
  }

  Future<bool> login() async {
    // Input validation
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      _errorMessage = 'Email and password are required';
      notifyListeners();
      return false;
    }

    if (!_agreedToTerms) {
      _errorMessage = 'Please agree to the Terms & Conditions';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Sign in with email and password
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      if (e.code == 'user-not-found') {
        _errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        _errorMessage = 'Wrong password provided.';
      } else {
        _errorMessage = 'Error: ${e.message}';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  // Check if user is already logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}