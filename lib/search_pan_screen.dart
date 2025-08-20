import 'package:flutter/material.dart';
import 'package:myapp/accounts_list_screen.dart';
import 'package:myapp/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Data model for CustomerProfile
class CustomerProfile {
  final String full_name;
  final String account_id;
  final String customer_id;
  final String pan;
  final String phone1;

  CustomerProfile({
    required this.full_name,
    required this.account_id,
    required this.customer_id,
    required this.pan,
    required this.phone1,
  });
}

class SearchPANScreen extends StatefulWidget {
  const SearchPANScreen({super.key});

  @override
  _SearchPANScreenState createState() => _SearchPANScreenState();
}

class _SearchPANScreenState extends State<SearchPANScreen> {
  final TextEditingController _panAccountController = TextEditingController();
  String? _searchType = ''; // Internal variable to store search type
  List<CustomerProfile> _customerList = []; // List to hold customer data
  bool _isLoading = false;
  late ApiService _apiService;
  String? _selectedCustomerId;

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

  void _onProfileSelected(String? profileId) {
    setState(() {
      _selectedCustomerId = profileId;
    });
  }

  Future<void> _onContinue() async {
    // Validate that the input is not empty and a type has been determined
    if (_panAccountController.text.isNotEmpty && _searchType != null) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        final response = await _apiService.fetchCustId(
          _searchType!,
          _panAccountController.text,
        );
        debugPrint('API Response: $response'); // Print the entire response

        // Access the customersList from the response
        if (response != null &&
            response is Map<String, dynamic> &&
            response.containsKey('customersList')) {
          // Access the list of customer details
          List<dynamic> customersData = response['customersList'];
          // Clear existing list
          setState(() {
            _customerList = [];
          });

          // Map dynamic list to CustomerProfile objects
          for (var item in customersData) {
            setState(() {
              _customerList.add(
                CustomerProfile(
                  full_name: item['full_name'] ?? 'Name not available',
                  phone1: item['phone1'] ?? 'Mobile not available',
                  customer_id:
                      item['customer_id']?.toString() ?? 'ID not available',
                  pan: item['pan'] ?? 'PAN not available',
                  account_id: item['account_id'] ?? 'Account ID not available',
                ),
              );
            });
          }
        } else {
          // Display an error if the API response isn't a map with customersList
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load customer data. Please try again.'),
            ),
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

  Future<void> _registerUser(CustomerProfile profile) async {
    setState(() {
      // Show registering indicator (if needed)
    });
    final prefs = await SharedPreferences.getInstance();
    try {
      final String deviceId =
          "12455855"; //await _getDeviceId();  Removed getDeviceId to simplify. //todo implement this again
      final String customerName = profile.full_name;
      final String panNo = profile.pan;
      final String mobNo = profile.phone1;

      final registerResponse = await _apiService.registerUser({
        "mobNo": mobNo,
        "customerConsent": "true",
        "customerLanguage": "EN",
        "deviceId": deviceId,
        "loggedIn": "true",
        "active": "true",
        "customerId": _selectedCustomerId,
        "customerName": customerName,
        "panNo": panNo,
      });
      debugPrint('registerUser API Response: $registerResponse');
      if (registerResponse['apiCode'] == 200) {
        //store customerName
        await prefs.setString('customerName', profile.full_name);
        await prefs.setString('customerMobile', profile.phone1);
        await prefs.setString("customerId", profile.customer_id);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) =>
                    AccountsListScreen(customerId: _selectedCustomerId!),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'There was an error during User Registration, Please try again.',
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API registerUser failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        // Hide registering indicator (if needed)
      });
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
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
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
                      inputFormatters: [LengthLimitingTextInputFormatter(12)],
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
                        SizedBox(width: 5),
                        Text('Search', style: TextStyle(fontSize: 18.0)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (_customerList.isNotEmpty)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(1.0),
                    itemCount: _customerList.length,
                    itemBuilder: (context, index) {
                      final profile = _customerList[index];
                      return InkWell(
                        onTap: () => _onProfileSelected(profile.customer_id),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          color:
                              _selectedCustomerId == profile.customer_id
                                  ? Colors.blue[50]
                                  : null,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 1.0,
                            ),
                            leading: const CircleAvatar(
                              backgroundColor: Colors.black,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              profile.full_name,
                              style: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(profile.phone1),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (_customerList.isNotEmpty && _selectedCustomerId != null)
                ElevatedButton(
                  onPressed: () {
                    if (_selectedCustomerId != null) {
                      final selectedProfile = _customerList.firstWhere(
                        (profile) => profile.customer_id == _selectedCustomerId,
                      );
                      _registerUser(selectedProfile);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text('NEXT', style: TextStyle(fontSize: 18.0)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
