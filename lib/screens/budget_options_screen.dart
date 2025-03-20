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
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart'; // Ensure this file defines your backendBaseUrl

// Data model for chart data
class ChartData {
  final String category;
  final double amount;
  ChartData({required this.category, required this.amount});
}

// Widget that renders a bar chart using Syncfusion Flutter Charts with UI-consistent colors.
class CategoryBarChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategoryBarChart({Key? key, required this.categoryTotals})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert the map to a list of ChartData objects.
    List<ChartData> data = categoryTotals.entries
        .map((e) => ChartData(category: e.key, amount: e.value))
        .toList();

    // Determine maximum value (to set y-axis maximum)
    double maxValue = data.isNotEmpty
        ? data.map((e) => e.amount).reduce((a, b) => a > b ? a : b)
        : 1;

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelRotation: 45,
        title: AxisTitle(
          text: 'Category',
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        labelStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.black87),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(
          text: 'Amount (£)',
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        maximum: maxValue + (maxValue * 0.1),
        interval: maxValue / 5,
        labelStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.black87),
        numberFormat: NumberFormat.currency(symbol: "£", decimalDigits: 0),
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CartesianSeries<ChartData, String>>[
        ColumnSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData datum, _) => datum.category,
          yValueMapper: (ChartData datum, _) => datum.amount,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.white),
          ),
          enableTooltip: true,
          color: const Color(0xFF8E5AF7), // Matches the rest of the UI
        ),
      ],
    );
  }
}

class BudgetOptionsScreen extends StatefulWidget {
  const BudgetOptionsScreen({Key? key}) : super(key: key);

  @override
  _BudgetOptionsScreenState createState() => _BudgetOptionsScreenState();
}

class _BudgetOptionsScreenState extends State<BudgetOptionsScreen> {
  bool isExpanded = false;
  bool _isLoading = false;
  double? _budget;
  String? _currency;
  String? _errorMessage; // for budget fetching errors

  // Analytics state variables
  bool _analyticsLoading = false;
  Map<String, double> _categoryTotals = {};
  List<dynamic> _recentBills = [];
  String? _analyticsError; // for analytics-specific errors

  File? _image;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // Logout function
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Camera capture
  Future<void> _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadReceipt();
    }
  }

  // Upload a scanned bill
  Future<void> _uploadReceipt() async {
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
      setState(() => _isUploading = false);
      return;
    }

    final url = Uri.parse('$backendBaseUrl/process-bill');
    var request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token';

    request.files.add(await http.MultipartFile.fromPath('bill', _image!.path));

    try {
      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final responseData = jsonDecode(responseString);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Receipt uploaded successfully.")),
        );
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

  // Fetch Budget from server
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
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });
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

  // Fetch Analytics from server
  Future<void> _fetchAnalytics() async {
    setState(() => _analyticsLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() {
        _analyticsError = 'User is not authenticated';
        _analyticsLoading = false;
      });
      return;
    }
    final url = Uri.parse('$backendBaseUrl/analytics');
    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['error'] == false) {
          final data = responseData['data'] as Map<String, dynamic>;
          final ct = data['categoryTotals'] as Map<String, dynamic>;
          Map<String, double> catTotals = {};
          ct.forEach((key, value) {
            catTotals[key] = (value as num).toDouble();
          });
          final rb = data['recentBills'] as List<dynamic>;
          setState(() {
            _categoryTotals = catTotals;
            _recentBills = rb;
            _analyticsError = null;
          });
        } else {
          setState(() {
            _analyticsError =
                responseData['message'] ?? 'Failed to fetch analytics.';
          });
        }
      } else {
        setState(() {
          _analyticsError = 'Failed to fetch analytics.';
        });
      }
    } catch (error) {
      setState(() {
        _analyticsError = 'Error fetching analytics: $error';
      });
    } finally {
      setState(() {
        _analyticsLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchBudget().then((_) {
      _fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Budget Options", style: GoogleFonts.poppins()),
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
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1) Budget Info (always shown)
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
                            const SizedBox(height: 24),
                            // 2) Analytics Section
                            if (_analyticsLoading)
                              const Center(child: CircularProgressIndicator())
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Use our CategoryBarChart widget
                                  CategoryBarChart(categoryTotals: _categoryTotals),
                                  const SizedBox(height: 24),
                                  _buildRecentReceipts(),
                                  if (_analyticsError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Text(
                                        _analyticsError!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
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
      floatingActionButton: _buildFloatingButtons(),
    );
  }

  // Helper for Floating Action Buttons
  Widget _buildFloatingButtons() {
    return Column(
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
    );
  }

  // Display recent receipts
  Widget _buildRecentReceipts() {
    if (_recentBills.isEmpty) {
      return Text(
        "No recent receipts found.",
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Recent Receipts",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // Optionally, navigate to a detailed receipts page.
              },
              child: Text(
                "View All",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF8E5AF7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recentBills.length,
          itemBuilder: (context, index) {
            final bill = _recentBills[index];
            final shopName = bill['shopName'] ?? 'Unknown';
            final totalAmount = bill['totalAmount'] ?? 0.0;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF8E5AF7).withOpacity(0.1),
                child: Text(
                  shopName.isNotEmpty ? shopName[0].toUpperCase() : "?",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8E5AF7),
                  ),
                ),
              ),
              title: Text(
                shopName,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Text(
                "£${totalAmount.toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                // Optionally, navigate to a detailed Bill page.
              },
            );
          },
        ),
      ],
    );
  }
}
