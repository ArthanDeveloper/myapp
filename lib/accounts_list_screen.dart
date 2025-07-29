import 'package:flutter/material.dart';

// Data model for an account, similar to CustomerProfile for design consistency
class Account {
  final String name;
  final String accountNumber;
  final String id;

  Account({required this.name, required this.accountNumber, required this.id});
}

class AccountsListScreen extends StatefulWidget {
  const AccountsListScreen({super.key});

  @override
  _AccountsListScreenState createState() => _AccountsListScreenState();
}

class _AccountsListScreenState extends State<AccountsListScreen> {
  // Dummy data for demonstration of multiple accounts
  final List<Account> _accounts = [
    Account(name: 'Savings Account', accountNumber: 'XXXXXX1234', id: 'acc1'),
    Account(name: 'Current Account', accountNumber: 'XXXXXX5678', id: 'acc2'),
    Account(name: 'Fixed Deposit', accountNumber: 'XXXXXX9012', id: 'acc3'),
    Account(name: 'Loan Account', accountNumber: 'XXXXXX3456', id: 'acc4'),
  ];

  // Using a Set to store selected account IDs for efficient add/remove and uniqueness
  final Set<String> _selectedAccountIds = {};

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
      // TODO: Implement navigation to the next screen, passing selected account IDs
      print('Selected account IDs: $_selectedAccountIds');
      // Example navigation:
      // Navigator.of(context).push(MaterialPageRoute(builder: (context) => NextScreen(selectedAccounts: _selectedAccountIds.toList())));
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
