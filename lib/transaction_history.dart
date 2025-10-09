import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:myapp/models/loan_details_object.dart';
import 'package:myapp/services/api_service.dart';

// Simple data model for a transaction
class Transaction {
  final String valueDateStr;
  final String transactionName;
  final String accountEntryType;
  final String amount;
  final bool isCredit;

  Transaction({
    required this.valueDateStr,
    required this.transactionName,
    required this.accountEntryType,
    required this.amount,
    this.isCredit = false,
  });
}

class TransactionHistory extends StatefulWidget {
  final dynamic accountId;

  const TransactionHistory({Key? key, this.accountId}) : super(key: key);
  @override
  _TransactionHistoryState createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  List<Transaction> transactions = [];
  bool isLoading = true;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService(Dio());
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await _apiService.getAllAccStatement(widget.accountId);
      final List<AccountStatements> data = response.accountStatements ?? [];
      setState(() {
        transactions = data.map((item) {
          return Transaction(
            valueDateStr: item.valueDateStr ?? 'Date not available',
            transactionName:
            item.transactionName ?? 'Transaction Name not available',
            accountEntryType:
            item.accountEntryType ?? 'Type not available',
            amount: item.amount ?? 'Amount not available',
          );
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching transactions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: transaction.accountEntryType == 'Debit'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      transaction.accountEntryType == 'Debit'
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: transaction.accountEntryType == 'Debit'
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                    ),
                  ),

                  title: Text(transaction.transactionName),
                  subtitle: Text(transaction.valueDateStr),
                  trailing: Text(
                    '${transaction.accountEntryType == 'Credit' ? '' : '- '}${transaction.amount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: transaction.accountEntryType == 'Credit'
                          ? Colors.green.shade800
                          : Colors.black,
                    ),
                  ),
                );
              },
            ),
    );
  }
}