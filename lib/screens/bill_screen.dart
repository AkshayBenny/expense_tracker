import 'package:expense_tracker/screens/edit_receipt_screen.dart';
import 'package:expense_tracker/utils/camel_case_function.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BillReceiptScreen extends StatefulWidget {
  final Map<String, dynamic> structuredData;

  const BillReceiptScreen({super.key, required this.structuredData});

  @override
  State<BillReceiptScreen> createState() => _BillReceiptScreenState();
}

class _BillReceiptScreenState extends State<BillReceiptScreen> {
  late List<Map<String, dynamic>> items;
  late double totalAmount;
  late double otherDiscounts;
  late double finalAmount;

  @override
  void initState() {
    super.initState();
    _loadData(widget.structuredData);
  }

  void _loadData(Map<String, dynamic> data) {
    items = List<Map<String, dynamic>>.from(data['items'] ?? []);
    totalAmount =
        (data['totalAmount'] is num) ? data['totalAmount'].toDouble() : 0.0;
    otherDiscounts = data['otherDiscounts'] ?? 0.0;
    finalAmount = totalAmount + otherDiscounts;
  }

  void _recalculateTotals() {
    totalAmount = items.fold(0.0, (sum, item) {
      final price = (item['price'] as num?) ?? 0.0;
      final quantity = (item['quantity'] as num?) ?? 1;
      return sum + (price * quantity);
    });
    finalAmount = totalAmount + otherDiscounts;
  }

  Future<void> _editReceipt() async {
    final updatedItems = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReceiptScreen(items: List.from(items)),
      ),
    );

    if (updatedItems != null && updatedItems is List<Map<String, dynamic>>) {
      setState(() {
        items = updatedItems;
        _recalculateTotals();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

              // Headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child:
                        Text("Items", style: GoogleFonts.poppins(fontSize: 16)),
                  ),
                  Expanded(
                    child: Text("Price",
                        textAlign: TextAlign.right,
                        style: GoogleFonts.poppins(fontSize: 16)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),

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
                                child: Text("${item['name']}".toCamelCase(),
                                    style: GoogleFonts.poppins(fontSize: 16)),
                              ),
                              Expanded(
                                child: Text(
                                  "£${(item['price'] as num).toStringAsFixed(2)} x ${item['quantity'] ?? 1}",
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

                    // Totals
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total",
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        Text("£${totalAmount.toStringAsFixed(2)}",
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Other Discounts",
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                        Text("-£${otherDiscounts.abs().toStringAsFixed(2)}",
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Grand Total",
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("£${finalAmount.toStringAsFixed(2)}",
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
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
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/budget-options');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E5AF7),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text("Done",
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),

              // Edit Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Found an error?",
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                  TextButton(
                    onPressed: _editReceipt,
                    child: Text("Edit Receipt",
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF8E5AF7))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
