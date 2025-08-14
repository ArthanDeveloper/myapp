import 'package:flutter/material.dart';
import 'package:myapp/set_mpin_screen.dart'; // Import the SetMpinScreen
import 'package:dio/dio.dart';
import 'package:myapp/services/api_service.dart';

// Data model for an account, similar to CustomerProfile for design consistency
class Account {
  final String name;
  final String accountNumber;
  final String id;

  Account({required this.name, required this.accountNumber, required this.id});
}

class AccountsListScreen extends StatefulWidget {
  final String customerId;
  const AccountsListScreen({Key? key, required this.customerId}) : super(key: key);

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
  Future<void> _fetchAccounts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await _apiService.fetchAccountsByCustomerId(widget.customerId);
        if (response != null && response is Map<String, dynamic> && response.containsKey('accountsList')) {
      List<dynamic> accountsData = response['accountsList'];

      setState(() {
        _accounts = accountsData.map((item) => Account(
          name: item['account_name'] ?? 'Account Type not available',
          accountNumber: item['account_number'] ?? 'Account Number not available',
          id: item['account_id']?.toString() ?? 'ID not available',
        )).toList();
      });
      print('The accounts length = ${_accounts.length}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load account data. Please try again.')),
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

  void _onContinue() {
    if (_selectedAccountIds.isNotEmpty) {
      print('Selected account IDs: $_selectedAccountIds');
      // Navigate to the SetMpinScreen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const SetMpinScreen()),
      );
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
       if (_isLoading)  const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ) else Expanded(
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
                    controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
                    value: _selectedAccountIds.contains(account.id),
                    onChanged: (bool? isSelected) {
                      _onAccountSelected(isSelected, account.id);
                    },
                    title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(account.accountNumber),
                    secondary: const Icon(Icons.account_balance), // Optional: Add an icon on the right
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
