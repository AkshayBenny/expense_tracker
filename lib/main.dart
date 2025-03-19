import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/budget_options_screen.dart';
import 'screens/upload_bill_screen.dart';
import 'screens/edit_receipt_screen.dart';
import 'screens/record_payment_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/password_reset_sent_screen.dart';
import 'screens/reset_password_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  Future<void> _initDeepLinkListener() async {
    // Listen for deep links while the app is running
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      print("Error receiving deep link: $err");
    });

    // Check if the app was launched with a deep link
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print("Failed to get initial deep link: $e");
    }
  }

  void _handleDeepLink(Uri uri) {
    // Expect deep links like: myapp://reset-password/<token>
    if (uri.host == 'reset-password' && uri.pathSegments.isNotEmpty) {
      final token = uri.pathSegments[0];
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(token: token),
        ),
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/budget': (context) => const BudgetScreen(),
        '/budget-options': (context) => const BudgetOptionsScreen(),
        '/upload-receipt': (context) => const UploadReceiptScreen(),
        '/edit-receipt': (context) => const EditReceiptScreen(items: []),
        '/record-payment': (context) => const RecordPaymentScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/password-reset-sent': (context) => const PasswordResetSentScreen(),
        // No route is needed for ResetPasswordScreen because it is opened via deep link.
      },
      // Optional: you can set a default home if no deep link is received
      home: const SplashScreen(),
    );
  }
}
