import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const IMDCostToolApp());
}

class IMDCostToolApp extends StatelessWidget {
  const IMDCostToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IMD Cost Tool',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const CostCalculatorScreen(),
    );
  }
}

class CostCalculatorScreen extends StatefulWidget {
  const CostCalculatorScreen({super.key});

  @override
  State<CostCalculatorScreen> createState() => _CostCalculatorScreenState();
}

class _CostCalculatorScreenState extends State<CostCalculatorScreen> {
  // State variables for user selections
  String? _selectedParameter;
  DateTimeRange? _selectedDateRange;
  
  // State variables for results
  int _totalCost = 0;
  int _numberOfRecords = 0;

  // Arbitrary costs assigned to different meteorological parameters
  final Map<String, int> _parameterCosts = {
    'Rainfall (RAIN)': 100,
    'Temperature (TEMP)': 150,
    'Relative Humidity (RH)': 100,
    'Wind Speed (WIND SPEED)': 150,
    'Soil Moisture (SOILM)': 200,
    'Solar Radiation (RAD)': 200,
  };

  // Date formatter for display
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  // Function to prompt the user to select a date range
  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2018, 1, 1), // Based on the CSV data start date
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _resetCalculation();
      });
    }
  }

  // Resets the calculation when inputs change
  void _resetCalculation() {
    setState(() {
      _totalCost = 0;
      _numberOfRecords = 0;
    });
  }

  // Core logic to calculate the cost
  void _calculateCost() {
    if (_selectedParameter == null || _selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both a parameter and a date range.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      // Calculate number of days (inclusive of start and end date)
      _numberOfRecords = _selectedDateRange!.duration.inDays + 1;
      
      // Calculate total cost
      int costPerRecord = _parameterCosts[_selectedParameter]!;
      _totalCost = _numberOfRecords * costPerRecord;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMD Cost Tool', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- INPUT SECTION ---
            const Text(
              'Data Retrieval Configuration',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Parameter Dropdown
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Parameter',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.science),
              ),
              value: _selectedParameter,
              items: _parameterCosts.keys.map((String param) {
                return DropdownMenuItem<String>(
                  value: param,
                  child: Text('$param (₹${_parameterCosts[param]}/day)'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedParameter = newValue;
                  _resetCalculation();
                });
              },
            ),
            
            const SizedBox(height: 20),

            // Date Range Selector
            InkWell(
              onTap: _pickDateRange,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Select Date Range',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.date_range),
                ),
                child: Text(
                  _selectedDateRange == null
                      ? 'Tap to select dates'
                      : '${_dateFormat.format(_selectedDateRange!.start)} - ${_dateFormat.format(_selectedDateRange!.end)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedDateRange == null ? Colors.grey[600] : Colors.black87,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Calculate Button
            ElevatedButton(
              onPressed: _calculateCost,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Calculate Cost',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 40),

            // --- OUTPUT SECTION ---
            if (_numberOfRecords > 0) ...[
              const Divider(),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.receipt_long, size: 48, color: Colors.teal),
                      const SizedBox(height: 16),
                      const Text(
                        'Estimated Cost',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),
                      
                      // Result Details
                      _buildResultRow('Parameter:', _selectedParameter!.split(' (')[0]),
                      const SizedBox(height: 12),
                      _buildResultRow('Days / Records:', '$_numberOfRecords'),
                      const SizedBox(height: 12),
                      _buildResultRow('Rate:', '₹${_parameterCosts[_selectedParameter]}/day'),
                      
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(thickness: 1.5),
                      ),
                      
                      // Total Cost Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹$_totalCost',
                            style: const TextStyle(
                              fontSize: 28, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.teal
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Helper widget to build consistent result rows
  Widget _buildResultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}