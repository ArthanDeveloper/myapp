import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:myapp/homepage.dart';
import 'package:myapp/models/loan_details_object.dart';
import 'package:myapp/services/api_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
// Assuming Loan model is in homepage.dart

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

class LoanDetailsScreen extends StatefulWidget {
  final dynamic loan;

  const LoanDetailsScreen({super.key, required this.loan});

  @override
  _LoanDetailsScreenState createState() => _LoanDetailsScreenState();
}

class _LoanDetailsScreenState extends State<LoanDetailsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<Transaction> _transactions = [];
  late var encoreAccountSummary = '';
  bool _isLoading = false;
  String authToken = 'YOUR_AUTH_TOKEN'; // Token
  late ApiService _apiService;
  late Razorpay _razorpay;
  LoanDetailsObject loanDetailsObject = LoanDetailsObject();

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    dio.options.headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    };
    _apiService = ApiService(dio);
    loadLoanDetails();
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

    _razorpay = Razorpay(); // Initialize Razorpay
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _razorpay.clear(); // Clear Razorpay
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handle payment success
    debugPrint("PAYMENT SUCCESS: ${response.paymentId}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful: ${response.paymentId}")),
    );
    // TODO:
    // 1. Verify the payment signature on your server.
    // 2. Update your backend with the payment status.
    // 3. Navigate to a success screen or update UI.
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment failure
    debugPrint("PAYMENT ERROR: ${response.code} - ${response.message}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
    // TODO:
    // 1. Log the error for debugging.
    // 2. Inform the user about the failure.
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet selection
    debugPrint("EXTERNAL WALLET: ${response.walletName}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External Wallet Selected: ${response.walletName}"),
      ),
    );
  }

  Future<void> loadLoanDetails() async {
    final String? accountId = widget.loan.accountId; //what was the string
    debugPrint('API Response ID: $accountId');
    setState(() {
      _isLoading = true; //Implements that function to load API
    });

    try {
      final response = await _apiService.getCustomerLoanInfo(accountId!);
      if (response != null) {
        setState(() {
          loanDetailsObject = response;
          final List<AccountStatements> transactionData =
              loanDetailsObject.accountStatements ?? [];
          _transactions = transactionData
              .map(
                (item) => Transaction(
                  valueDateStr: item.valueDateStr ?? 'Date not available',
                  transactionName:
                      item.transactionName ?? 'Transaction Name not available',
                  accountEntryType:
                      item.accountEntryType ?? 'Type not available',
                  amount: item.amount ?? 'Amount not available',
                ),
              )
              .toList();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data load issue! contact Support if issue persists'),
          ),
        );
        return;
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('API Call failed test again' + e.toString())),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(widget.loan.title),
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
                      InkWell(
                        // Makes the "View More" text tappable
                        onTap: () {
                          // TODO: Implement action for "View More"
                          // For example, navigate to another screen or expand details
                          print('View More tapped!');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('View More tapped!')),
                          );
                        },
                        child: Text(
                          'View More',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).primaryColor, // Or your preferred color
                            fontWeight: FontWeight.bold,
                            // fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize, // Optional: adjust size
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _buildDetailRow(
                    'Loan Amount:',
                    loanDetailsObject.encoreAccountSummary?.amount ?? 'N/A',
                  ),
                  _buildDetailRow(
                    'Status:',
                    loanDetailsObject.encoreAccountSummary?.operationalStatus ??
                        'N/A',
                  ),
                  _buildDetailRow(
                    'Disbursement Date:',
                    loanDetailsObject
                            .encoreAccountSummary
                            ?.accountOpenDateStr ??
                        'N/A',
                  ),
                  _buildDetailRow(
                    'Balance Tenure:',
                    '${loanDetailsObject.encoreAccountSummary?.tenureMagnitude ?? 'N/A'} ${loanDetailsObject.encoreAccountSummary?.tenureUnit ?? ''}',
                  ),
                  // Dummy data
                  _buildDetailRow(
                    'Interest Rate:',
                    '${loanDetailsObject.encoreAccountSummary?.normalInterestRate ?? 'N/A'}%',
                  ),
                  // Dummy data
                ],
              ),
            ),
          ),

          // Payment Section
          _buildSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.currency_rupee_rounded,
                                color: Colors.grey.shade700,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Next EMI Due',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: _onPayNow,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 0.0,
                                    horizontal: 12.0,
                                  ),
                                  backgroundColor: Colors.deepOrange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(width: 7),
                                    Text(
                                      'Pay Now',
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            4.0,
                                          ),
                                        ),
                                        child: Text(
                                          loanDetailsObject
                                                  .encoreAccountSummary
                                                  ?.accountId ??
                                              'NA',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 8),
                                  Text(
                                    'Due on ${loanDetailsObject.encoreAccountSummary?.accountOpenDateStr ?? 'NA'}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                loanDetailsObject.dueDetails?.totoalDemadDue ??
                                    '0.00',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
                  child: Text(
                    'Transaction History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ..._transactions.map(
                  (tx) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: tx.accountEntryType == 'Debit'
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      child: Icon(
                        tx.accountEntryType == 'Debit'
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: tx.accountEntryType == 'Debit'
                            ? Colors.green.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                    title: Text(tx.transactionName),
                    subtitle: Text(tx.valueDateStr),
                    trailing: Text(
                      '${tx.accountEntryType == 'Credit' ? '' : '- '}${tx.amount}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: tx.accountEntryType == 'Credit'
                            ? Colors.green.shade800
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Downloads Section
          _buildSection(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                  child: Text(
                    'Downloads',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildDownloadTile(
                  'Repayment Schedule',
                  Icons.calendar_today_outlined,
                ),
                _buildDownloadTile(
                  'Loan Statement',
                  Icons.receipt_long_outlined,
                ),
                _buildDownloadTile(
                  'Interest Certificate',
                  Icons.description_outlined,
                ),
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

  void _onPayNow() {
    // Ensure loanDetailsObject and dueDetails are not null and amount is valid
    // if (loanDetailsObject.dueDetails?.totoalDemadDue == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Unable to fetch payment amount.")),
    //   );
    // }

    String? amountString = '1200';
    double? amountDouble = double.tryParse(amountString!);

    if (amountDouble == null || amountDouble <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid payment amount.")));
      return;
    }

    // Razorpay expects amount in the smallest currency unit (e.g., paise for INR)
    // So, multiply by 100
    var amountInPaise = (amountDouble * 100).round();

    var options = {
      'key': 'rzp_live_06qz6CizJP1S0D',
      // Replace with your Key ID
      'amount': amountInPaise,
      // Amount in paise
      'name': 'ARTHAN FINANCE',
      // Title for the payment modal
      'description':
          'EMI Payment for Loan ID: ${loanDetailsObject.encoreAccountSummary?.accountId ?? 'N/A'}',
      'prefill': {
        'contact': 'USER_CONTACT_NUMBER', // Replace with actual user contact
        'email': 'USER_EMAIL_ADDRESS', // Replace with actual user email
      },
      // 'order_id': 'YOUR_ORDER_ID', // Optional: If you're creating orders on your server
      'notes': {
        'loan_account_id':
            loanDetailsObject.encoreAccountSummary?.accountId ?? 'N/A',
        // Add any other relevant notes
      },
      // 'theme': { // Optional: Customize the payment modal theme
      //   'color': '#F37254'
      // }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error opening Razorpay: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error initiating payment: ${e.toString()}")),
      );
    }
  }
}
