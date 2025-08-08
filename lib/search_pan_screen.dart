import 'package:flutter/material.dart';
import 'package:myapp/services/api_service.dart'; // Import ApiService
import 'package:dio/dio.dart'; // Import Dio

//Data model for CustomerProfile
class CustomerProfile {
  final String name;
  final String maskedMobile;
  final String id;

  CustomerProfile({required this.name, required this.maskedMobile, required this.id});
}

class SearchPANScreen extends StatefulWidget {
  @override
  _SearchPANScreenState createState() => _SearchPANScreenState();
}

class _SearchPANScreenState extends State<SearchPANScreen> {
  final TextEditingController _panAccountController = TextEditingController();
  String _searchType = ''; // Internal variable to store search type
  List<CustomerProfile> _customerList = []; // List to hold customer data
  bool _isLoading = false;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _panAccountController.addListener(_updateSearchType);
    final dio = Dio();
    _apiService = ApiService(dio);
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
        _searchType = 'PAN';
      } else if (text.length > 10) {
        _searchType = 'AcNo';
      } else {
        _searchType = ''; // Reset if length does not match criteria
      }
    });
    print('Current Search Type: $_searchType'); // For debugging
  }

  Future<void> _onContinue() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      if (_panAccountController.text.isNotEmpty && _searchType.isNotEmpty) {
        final response = await _apiService.fetchCustId(_searchType, _panAccountController.text);

        if (response != null && response is List) {
          // Clear existing list
          _customerList = [];

          // Map dynamic list to CustomerProfile objects
          for (var item in response) {
            // Ensure item is a Map and has the expected keys before accessing it
              _customerList.add(
                CustomerProfile(
                  name: item['name'] ?? 'Name not available',
                  maskedMobile: item['maskedMobile'] ?? 'Mobile not available',
                  id: item['id']?.toString() ?? 'ID not available',
                ),
              );
          }

          setState(() {}); // Trigger UI update with the new data
        } else {
          // Display an error if the API response isn't a list or is null
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to load customer data. Please try again.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid PAN or Loan Account Number.')),
        );
      }
    } catch (e) {
      // Catch the errors, print it to console, and show the error dialog.
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API fetch failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Search Your Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Enter your PAN or Loan Account number to find your details.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 40.0),
                  TextField(
                    controller: _panAccountController,
                    decoration: InputDecoration(
                      hintText: 'Enter PAN No or Loan Account No.',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      prefixIcon: Icon(Icons.credit_card),
                    ),
                    keyboardType: TextInputType.text, // Could be alphanumeric
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Detected Type: $_searchType',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.blueGrey,
                    ),
                  ),
                  SizedBox(height: 40.0),
                  ElevatedButton(
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      backgroundColor: Colors.deepOrange,
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
                  SizedBox(height: 20.0),
                ],
              ),
            ),
            if (_isLoading) // Show loading indicator while data is being fetched
              const Center(
                child: CircularProgressIndicator(),
              ),
            // Display Customer List
            if (_customerList.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _customerList.length,
                  itemBuilder: (context, index) {
                    final profile = _customerList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.black,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(profile.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(profile.maskedMobile),
                        // Removed Radio Button and onTap as requested
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
