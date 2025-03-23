import 'package:expense_tracker/utils/camel_case_function.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditReceiptScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;

  const EditReceiptScreen({super.key, required this.items});

  @override
  _EditReceiptScreenState createState() => _EditReceiptScreenState();
}

class _EditReceiptScreenState extends State<EditReceiptScreen> {
  late List<Map<String, dynamic>> editableItems;

  @override
  void initState() {
    super.initState();
    editableItems = List.from(widget.items);
  }

  void updateTotal() {
    setState(() {});
  }

  void addItem() {
    setState(() {
      editableItems.add({"name": "", "quantity": 1, "price": 0.0});
    });
  }

  void removeItem(int index) {
    setState(() {
      editableItems.removeAt(index);
    });
  }

  double calculateTotal() {
    double total = editableItems.fold(0, (sum, item) {
      final price = item['price'] is num ? item['price'] as num : 0;
      final quantity = item['quantity'] is num ? item['quantity'] as num : 1;
      return sum + (price * quantity);
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Allows the whole screen to scroll
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 64),
              Text(
                "Edit Receipt",
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),

              // Headers for Items, Price, Quantity
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text("Items",
                          style: GoogleFonts.poppins(fontSize: 16)),
                    ),
                    Expanded(
                      child: Text("Price",
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(fontSize: 16)),
                    ),
                    Expanded(
                      child: Text("Qty",
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(fontSize: 16)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),

              // List of items
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: editableItems.length,
                itemBuilder: (context, index) {
                  final item = editableItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        // Item name
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            style: GoogleFonts.poppins(fontSize: 16),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              hintText: "Item Name",
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            initialValue: item['name'].toString().toCamelCase(),
                            onChanged: (value) {
                              item['name'] = value;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Price
                        Expanded(
                          child: TextFormField(
                            textAlign: TextAlign.right,
                            style: GoogleFonts.poppins(fontSize: 16),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
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
                              item['price'] = double.tryParse(value) ?? 0.0;
                              updateTotal();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Quantity
                        Expanded(
                          child: TextFormField(
                            textAlign: TextAlign.right,
                            style: GoogleFonts.poppins(fontSize: 16),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              hintText: "Qty",
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
                              item['quantity'] = int.tryParse(value) ?? 1;
                              updateTotal();
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Did we miss an item?",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: addItem,
                    child: Text(
                      "Add Item",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8E5AF7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),

              // Total
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
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
                      "£${calculateTotal().toStringAsFixed(2)}",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),

              // Save Button
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
                  onPressed: () {
                    Navigator.pop(context, editableItems);
                  },
                  child: Text(
                    "Save Changes",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Cancel Button
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
                  onPressed: () {
                    Navigator.pop(context, editableItems);
                  },
                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8E5AF7),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
