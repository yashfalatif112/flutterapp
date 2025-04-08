import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscurePassword = true;
  bool agreedToTerms = false;

  void toggleObscure() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleTerms(bool? value) {
    agreedToTerms = value ?? false;
    notifyListeners();
  }

  void login() {
    if (agreedToTerms) {
      // Handle login logic here
      debugPrint("Email: ${emailController.text}");
      debugPrint("Password: ${passwordController.text}");
    } else {
      debugPrint("Please accept terms & conditions");
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
