import 'package:flutter/material.dart';
import 'idno.dart';

void main() {
  runApp(const EasyQRApp());
}

class EasyQRApp extends StatelessWidget {
  const EasyQRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farewell 2026 QR',
      debugShowCheckedModeBanner: false,
      
      // Using a more modern Material 3 theme configuration
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        
        // Consistent button styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            minimumSize: const Size(200, 50),
          ),
        ),
        
        // Consistent input styling
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.withOpacity(0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // The app starts at the ID Input Page
      home: const IDInputPage(),
    );
  }
}