import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailService {
  // TODO: Replace these with your actual Gmail credentials
  // To set up:
  // 1. Use a Gmail account
  // 2. Enable 2-Step Verification in Google Account settings
  // 3. Generate an App Password:
  //    - Go to Google Account settings
  //    - Navigate to Security
  //    - Under "2-Step Verification", click on "App passwords"
  //    - Select "Mail" and "Other (Custom name)"
  //    - Enter "HomeEase" as the app name
  //    - Click "Generate"
  //    - Copy the 16-character password
  static const String _emailAddress = 'hassanshoaib1122@gmail.com';  // Replace with your Gmail
  static const String _appPassword = 'kpoj zsfr ybvs cufz';  // Replace with your app password

  static Future<void> sendOTPEmail({
    required String recipientEmail,
    required String otp,
  }) async {
    // Create the email message
    final message = Message()
      ..from = Address(_emailAddress, 'HomeEase')
      ..recipients.add(recipientEmail)
      ..subject = 'Password Reset OTP'
      ..html = '''
        <h2>Password Reset OTP</h2>
        <p>Hello,</p>
        <p>You have requested to reset your password. Please use the following OTP to proceed:</p>
        <h1 style="font-size: 32px; letter-spacing: 2px; color: #4CAF50;">$otp</h1>
        <p>This OTP will expire in 5 minutes.</p>
        <p>If you did not request this password reset, please ignore this email.</p>
        <br>
        <p>Best regards,</p>
        <p>HomeEase Team</p>
      ''';

    try {
      // Create an SMTP server using Gmail
      final smtpServer = gmail(_emailAddress, _appPassword);
      
      // Send the email
      final sendReport = await send(message, smtpServer);
      
      print('Email sent: ${sendReport.toString()}');
    } catch (e) {
      print('Error sending email: $e');
      throw Exception('Failed to send OTP email');
    }
  }
} 