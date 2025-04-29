import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homease/provider/user_provider.dart';
import 'package:homease/views/authentication/login/provider/login_provider.dart';
import 'package:homease/views/authentication/signup/provider/category_provider.dart';
import 'package:homease/views/book_service/provider/booking_provider.dart';
import 'package:homease/views/bottom_bar/provider/bottom_bar_provider.dart';
import 'package:homease/views/profile/provider/profile_provider.dart';
import 'package:homease/views/services/provider/service_provider.dart';
import 'package:homease/views/splash/splash.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()..fetchServices()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Go Homease',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(),
        scaffoldBackgroundColor: Color(0xFFFAF9F1),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFAF9F1),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}