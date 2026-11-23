import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodePage extends StatefulWidget {
  final String id;
  const QRCodePage({super.key, required this.id});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  // Persistence for the current session
  static final Set<String> _usedIds = {};
  bool get _isExpired => _usedIds.contains(widget.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Entry Pass")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "ID: ${widget.id}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 40),
              
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: _isExpired ? 0.15 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 15,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: QrImageView(
                        data: widget.id,
                        version: QrVersions.auto,
                        size: 260.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                  if (_isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "VOID / USED",
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 50),
              
              if (!_isExpired)
                Column(
                  children: [
                    const Icon(Icons.qr_code_scanner, color: Colors.grey, size: 40),
                    const SizedBox(height: 10),
                    const Text("Show this code to the event coordinator"),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text("SIMULATE ENTRY"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(220, 55),
                      ),
                      onPressed: () {
                        setState(() => _usedIds.add(widget.id));
                      },
                    ),
                  ],
                )
              else
                const Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 40),
                    SizedBox(height: 10),
                    Text(
                      "This pass is no longer valid.",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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