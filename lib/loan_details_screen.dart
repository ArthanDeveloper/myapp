import 'package:flutter/material.dart';
import 'package:myapp/homepage.dart'; // Assuming Loan model is in homepage.dart

// Simple data model for a transaction
class Transaction {
  final String date;
  final String description;
  final String amount;
  final bool isCredit;

  Transaction({
    required this.date,
    required this.description,
    required this.amount,
    this.isCredit = false,
  });
}

class LoanDetailsScreen extends StatelessWidget {
  final Loan loan;

  const LoanDetailsScreen({super.key, required this.loan});

  // Dummy data for transaction history
  static final List<Transaction> _transactions = [
    Transaction(date: 'Apr 1, 2024', description: 'EMI Payment', amount: '\$550.00'),
    Transaction(date: 'Mar 1, 2024', description: 'EMI Payment', amount: '\$550.00'),
    Transaction(date: 'Feb 1, 2024', description: 'EMI Payment', amount: '\$550.00'),
    Transaction(date: 'Jan 1, 2024', description: 'Loan Disbursal', amount: '\$35,000.07', isCredit: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(loan.title),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          // Loan Details Section
          _buildSection(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loan Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildDetailRow('Loan Amount:', loan.amount),
                  _buildDetailRow('Status:', loan.status),
                  _buildDetailRow('Last Updated:', loan.lastUpdated),
                  _buildDetailRow('Interest Rate:', '8.5% p.a.'), // Dummy data
                  _buildDetailRow('Tenure:', '60 months'), // Dummy data
                ],
              ),
            ),
          ),

          // Downloads Section
          _buildSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Text('Downloads', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
                _buildDownloadTile('Repayment Schedule', Icons.calendar_today_outlined),
                _buildDownloadTile('Loan Statement', Icons.receipt_long_outlined),
                _buildDownloadTile('Interest Certificate', Icons.description_outlined),
              ],
            ),
          ),
          
          // Transaction History Section
          _buildSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Text('Transaction History', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
                ..._transactions.map((tx) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: tx.isCredit ? Colors.green.shade100 : Colors.red.shade100,
                    child: Icon(
                      tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: tx.isCredit ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                  title: Text(tx.description),
                  subtitle: Text(tx.date),
                  trailing: Text(
                    '${tx.isCredit ? '' : '- '}${tx.amount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: tx.isCredit ? Colors.green.shade800 : Colors.black,
                    ),
                  ),
                )).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to create a consistent section card
  Widget _buildSection({required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  // Helper widget for detail rows
  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Helper widget for download list tiles
  Widget _buildDownloadTile(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title),
      trailing: const Icon(Icons.download_outlined, color: Colors.grey),
      onTap: () {
        // TODO: Implement download logic
        print('Downloading $title');
      },
    );
  }
}
