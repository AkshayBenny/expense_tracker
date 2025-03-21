// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _checkAuthAndBudget() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // If no token, redirect to login.
    if (token == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // If the token is expired, attempt to refresh it.
    if (JwtDecoder.isExpired(token)) {
      final refreshToken = prefs.getString('refreshToken');
      if (refreshToken != null) {
        final refreshResponse = await AuthService.refreshToken(refreshToken);
        if (refreshResponse['token'] != null) {
          token = refreshResponse['token'] as String;
          await prefs.setString('token', token);
        } else {
          // Refresh failed, clear tokens and redirect to login.
          await prefs.remove('token');
          await prefs.remove('refreshToken');
          Navigator.pushReplacementNamed(context, '/login');
          return;
        }
      } else {
        await prefs.remove('token');
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
    }

    // Token is valid now—check if monthlyBudget is set.
    final double? userBudget = prefs.getDouble('monthlyBudget');
    if (userBudget == null) {
      Navigator.pushReplacementNamed(context, '/budget');
    } else {
      Navigator.pushReplacementNamed(context, '/budget-options');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuthAndBudget();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
