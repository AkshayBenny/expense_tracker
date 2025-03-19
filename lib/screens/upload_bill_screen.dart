import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';
import 'bill_screen.dart';

class UploadReceiptScreen extends StatefulWidget {
  const UploadReceiptScreen({super.key});

  @override
  _UploadReceiptScreenState createState() => _UploadReceiptScreenState();
}

class _UploadReceiptScreenState extends State<UploadReceiptScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _uploadReceipt();
      });
      _uploadReceipt();
    }
  }

  Future<void> _uploadReceipt() async {
    if (_image == null) return;

    setState(() => _isUploading = true);
    context.loaderOverlay.show(); // Show overlay

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception("User not authenticated");

      final url = Uri.parse('$backendBaseUrl/process-bill');
      final request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('bill', _image!.path));

      final response = await request.send();
      final responseString = await response.stream.bytesToString();
      final responseData = jsonDecode(responseString);

      context.loaderOverlay.hide(); // Always hide before state changes
      setState(() => _isUploading = false);

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BillReceiptScreen(
              structuredData: responseData['structuredData'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Upload failed")),
        );
      }
    } catch (e) {
      context.loaderOverlay.hide();
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      useDefaultLoading: true, // Use default loading indicator
      overlayColor: Colors.black.withOpacity(0.8), // Customize overlay
      child: Scaffold(
        appBar: AppBar(title: const Text("Upload Receipt")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image != null
                  ? Image.file(_image!, height: 200)
                  : const Text("No image selected"),
              const SizedBox(height: 20),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _isUploading ? null : _takePicture,
                    child: const Text("Take Picture"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isUploading ? null : _uploadReceipt,
                    child: const Text("Upload Receipt"),
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
