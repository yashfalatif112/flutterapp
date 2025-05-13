import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homease/provider/user_provider.dart';
import 'package:homease/services/call_notification_handler.dart';
import 'package:homease/services/stripe_service.dart';
import 'package:homease/views/authentication/login/provider/login_provider.dart';
import 'package:homease/views/authentication/signup/provider/category_provider.dart';
import 'package:homease/views/book_service/provider/booking_provider.dart';
import 'package:homease/views/bottom_bar/provider/bottom_bar_provider.dart';
import 'package:homease/views/bottom_bar/service_provider_status.dart';
import 'package:homease/views/profile/provider/profile_provider.dart';
import 'package:homease/views/services/provider/service_provider.dart';
import 'package:homease/views/splash/splash.dart';
import 'package:provider/provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data['type'] == 'video_call') {
    await CallNotificationHandler().handleBackgroundMessage(message);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  StripeService.init();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await CallNotificationHandler().initializeAppLevel();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => BottomNavProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(
            create: (_) => ServicesProvider()..fetchServices()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProviderStatus()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final CallNotificationHandler callHandler = CallNotificationHandler();

  @override
  void initState() {
    super.initState();
    callHandler.setNavigatorKey(_navigatorKey);

    callHandler.initializeAppLevel();

    callHandler.ensureChannelsCreated();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
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
