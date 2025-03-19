import 'package:expense_tracker/screens/edit_receipt_screen.dart';
import 'package:expense_tracker/utils/camel_case_function.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BillReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> structuredData;

  const BillReceiptScreen({super.key, required this.structuredData});

  @override
  Widget build(BuildContext context) {
    List<dynamic> items = structuredData['items'] ?? [];
    double totalAmount = (structuredData['totalAmount'] is num)
        ? structuredData['totalAmount'].toDouble()
        : 0.0;

    double otherDiscounts = structuredData['otherDiscounts'] ?? 0.0;
    double finalAmount = totalAmount + otherDiscounts;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Scanned Receipt",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Headers for Items, Quantity, and Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Items",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  /* Expanded(
                    child: Text(
                      "Qty",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                      ),
                    ),
                  ), */
                  Expanded(
                    child: Text(
                      "Price",
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              // List of Items with Quantity and Price
              Expanded(
                child: ListView(
                  children: [
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  "${item['name']}".toCamelCase(),
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ),
                              /* Expanded(
                                child: Text(
                                  "x ${item['quantity']}",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ), */
                              Expanded(
                                child: Text(
                                  "£${item['price'].toStringAsFixed(2)}",
                                  textAlign: TextAlign.right,
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    // Total before discounts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "£${totalAmount.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Discounts
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Other Discounts",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "-£${otherDiscounts.abs().toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Grand Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Grand Total",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "£${finalAmount.toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Done Button
              SizedBox(
                height: 56,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF8E5AF7), // Purple button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/budget-options');
                  },
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

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Found an error?",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditReceiptScreen(
                            items: List<Map<String, dynamic>>.from(items),
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Edit Receipt",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8E5AF7),
                      ),
                    ),
                  ),
                ],
              ),
              // Edit Receipt Link
            ],
          ),
        ),
      ),
    );
  }
}
