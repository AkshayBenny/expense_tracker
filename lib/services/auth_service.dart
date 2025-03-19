import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('$backendBaseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"message": "Login failed. ${response.body}"};
      }
    } catch (e) {
      print('Login Error: $e');
      return {"message": "An error occurred. Please try again."};
    }
  }

  static Future<Map<String, dynamic>> signUp(
      String name, String email, String password) async {
    final url = Uri.parse('$backendBaseUrl/auth/sign-up');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      print('Sign Up Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {"message": "Sign up failed. ${response.body}"};
      }
    } catch (e) {
      print('Sign Up Error: $e');
      return {"message": "An error occurred. Please try again."};
    }
  }
}
