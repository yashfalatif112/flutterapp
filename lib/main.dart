import 'package:flutter/material.dart';
import 'package:homease/views/authentication/login/provider/login_provider.dart';
import 'package:homease/views/bottom_bar/provider/bottom_bar_provider.dart';
import 'package:homease/views/splash/splash.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
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