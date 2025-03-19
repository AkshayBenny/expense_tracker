import 'dart:convert';
import 'dart:io';
import 'package:expense_tracker/screens/bill_screen.dart';
import 'package:expense_tracker/screens/edit_receipt_screen.dart';
import 'package:expense_tracker/screens/record_payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart'; // Ensure this file defines your backendBaseUrl

class BudgetOptionsScreen extends StatefulWidget {
  const BudgetOptionsScreen({Key? key}) : super(key: key);

  @override
  _BudgetOptionsScreenState createState() => _BudgetOptionsScreenState();
}

class _BudgetOptionsScreenState extends State<BudgetOptionsScreen> {
  bool isExpanded = false; // Tracks whether the FAB is expanded
  bool _isLoading = false;
  double? _budget;
  String? _currency;
  String? _errorMessage;

  File? _image;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // Logout function: clears the token and navigates to login.
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Opens the camera to take a picture
  Future<void> _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadReceipt(); // Call after image is set
    }
  }

  // Uploads the captured image as a bill to the backend
  Future<void> _uploadReceipt() async {
    print("Checking if uploading the captured image is working");
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image selected.")),
      );
      return;
    }
    setState(() {
      _isUploading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated.")),
      );
      setState(() {
        _isUploading = false;
      });
      return;
    }

    final url = Uri.parse('$backendBaseUrl/process-bill');
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token';

    // Attach the image file with key 'bill'
    request.files.add(await http.MultipartFile.fromPath('bill', _image!.path));

    try {
      print("Uploading receipt...");
      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final responseData = jsonDecode(responseString);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Receipt uploaded successfully.")),
        );

        // Navigate to BillReceiptScreen if the response has bill data under key 'data'
        if (responseData['data'] != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => BillReceiptScreen(
                structuredData: responseData['data'],
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseData['message'] ?? "Failed to upload receipt.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading receipt: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Fetches the budget details from the backend
  Future<void> _fetchBudget() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _errorMessage = 'User is not authenticated';
        _isLoading = false;
      });
      return;
    }

    final url = Uri.parse('$backendBaseUrl/budget');
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _budget = (responseData['budget'] as num?)?.toDouble();
          _currency = responseData['currency'] as String?;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch budget details';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching budget details: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBudget();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Budget Options",
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFF8E5AF7),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),
                          if (_budget != null && _currency != null)
                            Text(
                              "$_currency $_budget Left",
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Meter full! Awesome, you haven’t spent anything this month.",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
          ),
          // Loading overlay while uploading receipt
          if (_isUploading)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isExpanded) ...[
            FloatingActionButton.extended(
              elevation: 6,
              onPressed: _takePicture,
              label: Text(
                "Scan a Bill",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF8E5AF7),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            FloatingActionButton.extended(
              elevation: 6,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecordPaymentScreen(),
                  ),
                );
              },
              label: Text(
                "Manually Record a Payment",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF8E5AF7),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
          ],
          FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(200),
            ),
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            backgroundColor: const Color(0xFF8E5AF7),
            child: Icon(
              isExpanded ? Icons.close : Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
