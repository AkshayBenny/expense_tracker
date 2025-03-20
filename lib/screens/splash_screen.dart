import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndBudget();
  }

  Future<void> _checkAuthAndBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      // No token => must log in
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // If token exists, check monthlyBudget
    final double? userBudget = prefs.getDouble('monthlyBudget');
    if (userBudget != null && userBudget > 0) {
      // We have a budget
      Navigator.pushReplacementNamed(context, '/budget-options');
    } else {
      // userBudget is 0 or not set => go to budget screen
      Navigator.pushReplacementNamed(context, '/budget');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
