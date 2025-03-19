// lib/screens/splash_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart'; // Ensure this file defines backendBaseUrl

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // This method checks authentication and budget status.
  Future<void> _checkAuthAndBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // If no token, send user to login.
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // If token exists, fetch budget details.
    final url = Uri.parse('$backendBaseUrl/budget');
    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Assuming responseData has a field "budget" (a number).
        final double? budget = (responseData['budget'] as num?)?.toDouble();

        // If budget is zero (or null), navigate to Budget Screen.
        if (budget == null || budget == 0) {
          Navigator.pushReplacementNamed(context, '/budget');
        } else {
          // Otherwise, navigate to the home screen (Budget Options).
          Navigator.pushReplacementNamed(context, '/budget-options');
        }
      } else {
        // If the response is not 200, default to login.
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // On error, log it and navigate to login.
      print('Error checking auth/budget: $e');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuthAndBudget();
  }

  @override
  Widget build(BuildContext context) {
    // A simple loading indicator.
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
