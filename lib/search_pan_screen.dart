import 'package:flutter/material.dart';
import 'package:myapp/select_customer_screen.dart';
import 'package:myapp/services/api_service.dart'; // Import ApiService
import 'package:dio/dio.dart'; // Import Dio
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:flutter/services.dart';

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
  String? _searchType = ''; // Internal variable to store search type
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
        _searchType = null; // Reset if length does not match criteria
      }
    });
    print('Current Search Type: $_searchType'); // For debugging
  }

  Future<void> _onContinue() async {
    // Validate that the input is not empty and a type has been determined
    if (_panAccountController.text.isNotEmpty && _searchType != null) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        final response = await _apiService.fetchCustId(
            _searchType!, _panAccountController.text);
        debugPrint('API Response: $response'); // Print the entire response

        // Access the customersList from the response
        if (response != null &&
            response is Map<String, dynamic> &&
            response.containsKey('customersList')) {
          // Access the list of customer details
          List<dynamic> customersData = response['customersList'];
          // Clear existing list
            _customerList = [];
          setState(() {});
          // Map dynamic list to CustomerProfile objects
          for (var item in customersData) {
            // Map item data using correct keys
         setState(() {
        _customerList.add(
          CustomerProfile(
            name: item['full_name'] ?? 'Name not available',
            maskedMobile: item['phone1'] ?? 'Mobile not available',
            id: item['customer_id']?.toString() ?? 'ID not available',
          ),
        );
         });
          }
        } else {
          // Display an error if the API response isn't a map with customersList
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to load customer data. Please try again.')),
          );
        }
      } catch (e) {
        // Catch the errors, print it to console, and show the error dialog.
        debugPrint('API fetch failed: ${e.toString()}'); // Also print the error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API fetch failed: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Search Your Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                'Enter your PAN or Loan Account number to find your details.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40.0),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _panAccountController,
                      decoration: const InputDecoration(
                        hintText: 'Enter PAN No or Loan Account No.',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      keyboardType: TextInputType.text, // Could be alphanumeric
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(12),
                        UpperCaseTextFormatter(),
                      ],
                      onChanged: (value) {
                        _updateSearchType();
                      },
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  ElevatedButton(
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.search),
                        SizedBox(width: 5),
                        Text(
                          'Search',
                          style: TextStyle(fontSize: 18.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              if (_isLoading)
                const Padding(padding: EdgeInsets.only(top: 20),child: Center(
                  child: CircularProgressIndicator(),
                )),
              // Display Customer List
              if (_customerList.isNotEmpty)
                Expanded(
                 child:  Column(
                 children: [
                   Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(10.0),
                        itemCount: _customerList.length,
                        itemBuilder: (context, index) {
                          final profile = _customerList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5.0),
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
                              title: Text(profile.name, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16)),
                              subtitle: Text(profile.maskedMobile),
                            ),
                          );
                        },
                      ),
                   ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SelectCustomerScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
                 ])) else const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
