import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:myapp/services/api_service.dart';

import 'models/loan_details_object.dart';

class AccountDetailsScreen extends StatefulWidget {
  final LoanDetailsObject loanDetailsObject;

  const AccountDetailsScreen({Key? key, required this.loanDetailsObject});

  @override
  _AccountDetailsScreenState createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late ApiService _apiService;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    _apiService = ApiService(dio);
    // loadLoanDetails();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.loanDetailsObject.encoreAccountSummary?.accountName ?? 'N/A',
        ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Loan Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Account Name:',
                    widget
                            .loanDetailsObject
                            .encoreAccountSummary
                            ?.accountName ??
                        'N/A',
                  ),
                  _buildDetailRow(
                    'Account Number:',
                    widget.loanDetailsObject.encoreAccountSummary?.accountId ??
                        'N/A',
                  ),
                  _buildDetailRow(
                    'Customer ID:',
                    widget
                            .loanDetailsObject
                            .encoreAccountSummary
                            ?.customerId1 ??
                        'N/A',
                  ),
                  _buildDetailRow(
                    'Disbursement Date:',
                    widget
                            .loanDetailsObject
                            .encoreAccountSummary
                            ?.accountOpenDateStr ??
                        'N/A',
                  ),
                  _buildDetailRow(
                    'Disbursed Amount:',
                    widget.loanDetailsObject.encoreAccountSummary?.amount ??
                        'N/A',
                  ),
                  _buildDetailRow(
                    'Tenure:',
                    '${widget.loanDetailsObject.encoreAccountSummary?.tenureMagnitude ?? 'N/A'} ${widget.loanDetailsObject.encoreAccountSummary?.tenureUnit ?? ''}',
                  ),
                  _buildDetailRow(
                    'Principal Outstanding:',
                    widget.loanDetailsObject.encoreAccountSummary?.amount ??
                        'N/A',
                  ),
                  _buildDetailRow(
                    'Balance Tenure:',
                    '${widget.loanDetailsObject.encoreAccountSummary?.tenureMagnitude ?? 'N/A'} ${widget.loanDetailsObject.encoreAccountSummary?.tenureUnit ?? ''}',
                  ),
                  _buildDetailRow(
                    'Interest Rate:',
                    widget
                            .loanDetailsObject
                            .encoreAccountSummary
                            ?.normalInterestRate ??
                        'N/A',
                  ),
                  _buildDetailRow(
                    'Operational Status:',
                    widget
                            .loanDetailsObject
                            .encoreAccountSummary
                            ?.operationalStatus ??
                        'N/A',
                  ),
                  _buildDetailRow(
                    'Loan Branch:',
                    widget.loanDetailsObject.encoreAccountSummary?.branchName ??
                        'N/A',
                  ),
                  _buildDetailRow(
                    'Loan Type:',
                    widget.loanDetailsObject.encoreAccountSummary?.udfText1 ??
                        'N/A',
                  ),
                  _buildDetailRow(
                    'Mortgage Type:',
                    widget.loanDetailsObject.encoreAccountSummary?.udfText6 ??
                        'N/A',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 1.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
