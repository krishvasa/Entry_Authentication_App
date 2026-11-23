import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'qrcode.dart';

class IDInputPage extends StatefulWidget {
  const IDInputPage({super.key});

  @override
  State<IDInputPage> createState() => _IDInputPageState();
}

class _IDInputPageState extends State<IDInputPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isVerifying = false;
  
  // Validation for BITS ID format
  final RegExp _idPattern = RegExp(r'^202\d[AB]\dPS\d{4}H$');

  // The URL we are verifying in the screenshot
  final String _targetUrl = "bitspilani.almaconnect.com";

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageName = image.name;
      });
    }
  }

  String _getMimeType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    if (extension == 'png') return 'image/png';
    if (extension == 'jpg' || extension == 'jpeg') return 'image/jpeg';
    return 'image/png';
  }

  Future<void> _verifyAndSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_imageBytes == null) {
      _showError("Please upload the AlmaConnect verification screenshot.");
      return;
    }

    setState(() => _isVerifying = true);

    try {
      // Using your provided API Key
      const apiKey = "AIzaSyCKE83O8gygnykyjb9gwXWmZEiXIsDJx90"; 
      
      // Using gemini-1.5-flash-latest for stability
      final model = GenerativeModel(
        model: 'gemini-2.5-flash', 
        apiKey: apiKey,
      );

      final mimeType = _getMimeType(_imageName ?? "image.png");

      final content = [
        Content.multi([
          TextPart("CRITICAL TASK: Check if the text '$_targetUrl' is present in this image. "
                   "It might be in the browser address bar at the top or within the page content. "
                   "Only respond with the following JSON format: {\"verified\": true} if found, or {\"verified\": false} if not found. "
                   "Do not provide any other text."),
          DataPart(mimeType, _imageBytes!),
        ])
      ];

      // Request with timeout
      final response = await model.generateContent(content).timeout(const Duration(seconds: 15));
      final responseText = response.text ?? "";
      
      // Robust JSON extraction
      Map<String, dynamic> data;
      try {
        final start = responseText.indexOf('{');
        final end = responseText.lastIndexOf('}') + 1;
        if (start == -1 || end == 0) throw Exception("No JSON found in response");
        final cleanJson = responseText.substring(start, end);
        data = json.decode(cleanJson);
      } catch (e) {
        // Fallback: If JSON parsing fails, check for keywords in the raw text
        if (responseText.toLowerCase().contains('"verified": true') || 
            responseText.toLowerCase().contains('"verified":true')) {
          data = {"verified": true};
        } else {
          rethrow;
        }
      }

      if (data['verified'] == true) {
        if (!mounted) return;
        _navigateToQR();
      } else {
        _showError("Verification Failed: The URL '$_targetUrl' was not detected in the image. Please ensure the screenshot shows the full browser window.");
      }
    } catch (e) {
      debugPrint("Full Error: $e");
      String errorMsg = e.toString();
      
      if (errorMsg.contains("API_KEY_INVALID")) {
        errorMsg = "Invalid API Key. Please check your settings.";
      } else if (errorMsg.contains("TimeoutException")) {
        errorMsg = "Request timed out. Please try again.";
      } else {
        errorMsg = "An error occurred during verification. Please try again.";
      }
      
      _showError(errorMsg);
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  void _navigateToQR() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodePage(id: _controller.text.toUpperCase()),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg), 
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 6),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Farewell 2026")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Enter your BITS ID",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: "BITS ID Number",
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => (val != null && _idPattern.hasMatch(val.toUpperCase())) 
                  ? null : "Enter valid ID (e.g. 2024A7PS0106H)",
              ),
              const SizedBox(height: 30),
              const Text(
                "Upload AlmaConnect Screenshot",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: _isVerifying ? null : _pickImage,
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: _imageBytes == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 50, color: Colors.blue),
                            SizedBox(height: 10),
                            Text("Upload Screenshot"),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                        ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isVerifying ? null : _verifyAndSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("VERIFY & GENERATE QR", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _navigateToQR,
                  child: const Text("DEBUG: Skip Verification", style: TextStyle(color: Colors.grey)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}