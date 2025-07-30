import 'package:flutter/material.dart';
import 'package:myapp/select_customer_screen.dart'; // Import the new screen

class SearchPANScreen extends StatefulWidget {
  @override
  _SearchPANScreenState createState() => _SearchPANScreenState();
}

class _SearchPANScreenState extends State<SearchPANScreen> {
  final TextEditingController _panAccountController = TextEditingController();
  String _searchType = ''; // Internal variable to store search type

  @override
  void initState() {
    super.initState();
    _panAccountController.addListener(_updateSearchType); // Listen for text changes
  }

  @override
  void dispose() {
    _panAccountController.removeListener(_updateSearchType);
    _panAccountController.dispose();
    super.dispose();
  }

  void _updateSearchType() {
    final text = _panAccountController.text;
    setState(() {
      if (text.length == 10) {
        _searchType = 'pan_no';
      } else if (text.length > 10) {
        _searchType = 'account_no';
      } else {
        _searchType = ''; // Reset if length does not match criteria
      }
    });
    print('Current Search Type: $_searchType'); // For debugging
  }

  void _onContinue() {
    // Validate that the input is not empty and a type has been determined
    if (_panAccountController.text.isNotEmpty && _searchType.isNotEmpty) {
      print('Searching with type: $_searchType and value: ${_panAccountController.text}');
      // Navigate to the SelectCustomerScreen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SelectCustomerScreen()),
      );
    } else {
      // Show an error if the input is invalid
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid PAN or Loan Account Number.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Use SafeArea to avoid system overlays like status bar
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Minimal Header (just a back button, no blue background)
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back), // Back button
                  onPressed: () {
                    Navigator.pop(context); // Navigate back
                  },
                ),
              ),
              SizedBox(height: 20.0),

              // Main Title and Description
              Text(
                'Search Your Account', // New main title
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                'Enter your PAN or Loan Account number to find your details.', // New description
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 40.0),

              // Input Field
              TextField(
                controller: _panAccountController,
                decoration: InputDecoration(
                  hintText: 'Enter PAN No or Loan Account No.', // Renamed hint text
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: Icon(Icons.credit_card), // Example icon for input
                ),
                keyboardType: TextInputType.text, // Could be alphanumeric
              ),
              SizedBox(height: 20.0),

              // Display current search_type (for debugging/demonstration)
              Text(
                'Detected Type: $_searchType',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.blueGrey,
                ),
              ),
              SizedBox(height: 40.0),

              // Continue Button
              ElevatedButton(
                onPressed: _onContinue, // Updated onPressed callback
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  backgroundColor: Colors.deepOrange, // Consistent button style
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'CONTINUE',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
