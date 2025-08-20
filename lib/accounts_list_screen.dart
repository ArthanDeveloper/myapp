import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/set_mpin_screen.dart'; // Import the SetMpinScreen
import 'package:dio/dio.dart';
import 'package:myapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data model for an account, similar to CustomerProfile for design consistency
class Account {
  final String branch_code;
  final String branch_name;
  final String account_name;
  final String account_id;
  final String customer_id;
  final String product_code;
  final String opened_on_value_date;

  Account({
    required this.branch_code,
    required this.branch_name,
    required this.account_name,
    required this.account_id,
    required this.customer_id,
    required this.product_code,
    required this.opened_on_value_date,
  });
}

class AccountsListScreen extends StatefulWidget {
  final String customerId;
  const AccountsListScreen({Key? key, required this.customerId})
    : super(key: key);

  @override
  _AccountsListScreenState createState() => _AccountsListScreenState();
}

class _AccountsListScreenState extends State<AccountsListScreen> {
  List<Account> _accounts = [];
  bool _isLoading = false;
  late ApiService _apiService;
  final Set<String> _selectedAccountIds = {};
  @override
  void initState() {
    super.initState();
    print('Received customer ID: ${widget.customerId}');
    final dio = Dio();
    _apiService = ApiService(dio);
    _fetchAccounts();
  }

  //To send data, create a list of a map that is in JSON format.
  String getAccountListJson() {
    List<Map<String, dynamic>> jsonArray = [];
    for (String id in _selectedAccountIds) {
      // Find the account with a matching ID
      Account acc = _accounts.firstWhere((element) => element.account_id == id);
      //If you dont want to add every value, you can add just the acc id.
      jsonArray.add({
        "account_id": acc.account_id,
        "customer_id": widget.customerId,
      });
    }
    return jsonEncode({'accountsList': jsonArray});
  }

  Future<void> _saveArthikAccounts(String jsonData) async {
    setState(() {
      _isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    try {
      final registerResponse = await _apiService.saveArthikAccounts(
        jsonData,
      ); //TODO pass data
      if (registerResponse['apiCode'] == 200) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const SetMpinScreen()));
        print("Successfully sent Save Arthik accoutns for new page");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'An internal erorr has occured with this service please contact admin',
            ),
          ),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Issue during API Request:  ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAccounts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _apiService.fetchAccountsByCustomerId(
        widget.customerId,
      );
      if (response != null &&
          response is Map<String, dynamic> &&
          response.containsKey('accountsList')) {
        List<dynamic> accountsData = response['accountsList'];
        setState(() {
          _accounts =
              accountsData
                  .map(
                    (item) => Account(
                      account_name:
                          item['account_name'] ?? 'Account Type not available',
                      account_id:
                          item['account_id'] ?? 'Account Number not available',
                      customer_id:
                          item['customer_id']?.toString() ?? 'ID not available',
                      branch_code: '',
                      branch_name: '',
                      product_code: '',
                      opened_on_value_date: '',
                    ),
                  )
                  .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load account data. Please try again.'),
          ),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API fetch failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onAccountSelected(bool? isSelected, String accountId) {
    setState(() {
      if (isSelected == true) {
        _selectedAccountIds.add(accountId);
      } else {
        _selectedAccountIds.remove(accountId);
      }
    });
  }

  void _onContinue() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = getAccountListJson();
    print('JSON data to send: $jsonData'); // This prints the JSON
    if (_selectedAccountIds.isNotEmpty) {
      _saveArthikAccounts(jsonData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one account.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Accounts'), // Changed title
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _accounts.length,
                itemBuilder: (context, index) {
                  final account = _accounts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: CheckboxListTile(
                      // Changed from ListTile with Radio to CheckboxListTile
                      controlAffinity:
                          ListTileControlAffinity
                              .leading, // Checkbox on the left
                      value: _selectedAccountIds.contains(account.account_id),
                      onChanged: (bool? isSelected) {
                        _onAccountSelected(isSelected, account.account_id);
                      },
                      title: Text(
                        account.account_name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(account.account_id),
                      secondary: const Icon(
                        Icons.account_balance,
                      ), // Optional: Add an icon on the right
                      // If you want a full circle avatar on the left, use leading: CircleAvatar and set controlAffinity to trailing.
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedAccountIds.isNotEmpty ? _onContinue : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
