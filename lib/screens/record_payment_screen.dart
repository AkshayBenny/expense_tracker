import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart'; // Ensure this file defines your backendBaseUrl
import 'package:expense_tracker/screens/budget_options_screen.dart';

class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({super.key});

  @override
  _RecordPaymentScreenState createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  List<Map<String, dynamic>> items = [
    {"name": "", "quantity": 1, "price": 0.0}
  ];

  void addItem() {
    setState(() {
      items.add({"name": "", "quantity": 1, "price": 0.0});
    });
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  double calculateTotal() {
    double total =
        items.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
    return total;
  }

  // New function to submit expenses to the API.
  Future<void> _submitExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated")),
      );
      return;
    }

    // Map items to expense items (only include price and quantity)
    final expenses = items
        .map((item) => {
              "price": item["price"],
              "quantity": item["quantity"],
            })
        .toList();

    final body = jsonEncode({"expenses": expenses});
    final url = Uri.parse("$backendBaseUrl/expense/add");

    try {
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: body);

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData["error"] == false) {
        // Success: show message and navigate to BudgetOptionsScreen (the home page)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(responseData["message"])));
        Navigator.pushReplacementNamed(context, '/budget-options');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseData["message"] ??
                  "Failed to add expenses. Please try again.")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 64),
            Text(
              "Record a Payment",
              style: GoogleFonts.poppins(
                  fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child:
                        Text("Items", style: GoogleFonts.poppins(fontSize: 16)),
                  ),
                  Expanded(
                    child: Text(
                      "Price",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Quantity",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Column(
              children: items.asMap().entries.map((entry) {
                int index = entry.key;
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          style: GoogleFonts.poppins(fontSize: 16),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            hintText: "Item Name (optional)",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          initialValue: item['name'],
                          onChanged: (value) {
                            setState(() {
                              items[index]['name'] = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(fontSize: 16),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            hintText: "Price",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          initialValue: item['price'].toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              items[index]['price'] =
                                  double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(fontSize: 16),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            hintText: "Quantity",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          initialValue: item['quantity'].toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              items[index]['quantity'] =
                                  int.tryParse(value) ?? 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: TextButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: addItem,
                child: Text(
                  "Add Another Item",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF8E5AF7),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Grand Total",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "£${calculateTotal().toStringAsFixed(2)}",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: const Color(0xFF8E5AF7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _submitExpenses,
                child: Text(
                  "Done",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
