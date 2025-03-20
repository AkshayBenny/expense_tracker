import 'package:flutter/material.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      },
      home: const SplashScreen(),
    );
  }
}
