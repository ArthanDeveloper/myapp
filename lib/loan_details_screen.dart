import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:myapp/account_details_screen.dart';
import 'package:myapp/models/loan_details_object.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/transaction_history.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io'; // For File operations
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

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
  bool _isLoading = false;
  String authToken = 'YOUR_AUTH_TOKEN'; // Token
  late ApiService _apiService;
  late Razorpay _razorpay;
  PaymentSuccessResponse? _lastSuccessfulPayment; // To store details for retrying postPaymentToServer
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
    debugPrint("PAYMENT SUCCESS: Payment ID: ${response.paymentId}, Order ID: ${response.orderId}, Signature: ${response.signature}");
    // IMPORTANT: Call your server to verify payment and record it
    _lastSuccessfulPayment = response;
    postPaymentToServer(response);

    // You might want to wait for postPaymentToServer to complete before showing
    // the final "Payment Successful" message to the user, or update UI based on its outcome.
    // For now, this is a simple approach:
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment processing with server...")), // Or similar
    );
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
      debugPrint('API Response:  $response');
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AccountDetailsScreen(loanDetailsObject: loanDetailsObject ?? widget.loan),
                            ),
                          );
                          // For example, navigate to another screen or expand details

                        },
                        child: Text(
                          'View More >',
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
                    loanDetailsObject.encoreAccountSummary?.normalInterestRate ?? 'N/A',
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
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction History',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      // Makes the "View More" text tappable
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TransactionHistory(accountId: loanDetailsObject.encoreAccountSummary?.accountId),
                          ),
                        );
                        // For example, navigate to another screen or expand details

                      },
                      child: Text(
                        'View More >',
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
                  'Statement of Loan',
                  Icons.receipt_long_outlined,
                ),
                _buildDownloadTile(
                  'NOC Certificate',
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
        _downloadReport(title);
      },
    );
  }

  Future<void> _onPayNow() async {
    // Ensure loanDetailsObject and dueDetails are not null and amount is valid
    // if (loanDetailsObject.dueDetails?.totoalDemadDue == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Unable to fetch payment amount.")),
    //   );
    // }

    String? amountString = '1';
    double? amountDouble = double.tryParse(amountString!);

    final prefs = await SharedPreferences.getInstance();
    final String? customerMobile = prefs.getString(
      'customerMobile',
    ); //what was the string

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
          'EMI Payment for Loan ID : ${loanDetailsObject.encoreAccountSummary?.accountId ?? 'N/A'}',
      'prefill': {
        'contact': customerMobile, // Replace with actual user contact
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

  Future<void> _downloadReport(String title) async {
    // Optional: Add a loading state for better UX
    // For example, using a Map to track loading state for each report type
    Map<String, bool> _isDownloadingReport = {};
    setState(() { _isDownloadingReport[title] = true; });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading "$title"...')),
    );

    try {
      final String? accountId = widget.loan.accountId;
      if (accountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Account ID is missing.')),
        );
        if (_isDownloadingReport.containsKey(title)) { // Reset loading state if used
          setState(() { _isDownloadingReport[title] = false; });
        }
        return;
      }
      final String reportName = "StatementOfAccount";

      // Assuming _apiService.generateReport returns Future<List<int>>
      // If it returns a Dio Response object, you'd access response.data
      final dynamic apiResponse = await _apiService.generateReport(accountId, reportName, 'pdf');

      List<int> fileBytes;

      // Check the type of apiResponse and extract bytes
      if (apiResponse is List<int>) {
        fileBytes = apiResponse;
      } else if (apiResponse is Response && apiResponse.data is List<int>) { // Example if ApiService returns Dio Response
        fileBytes = apiResponse.data;
      } else {
        // Handle unexpected response type
        debugPrint('Unexpected API response type: ${apiResponse.runtimeType}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download "$title": Invalid data format.')),
        );
        // if (_isDownloadingReport.containsKey(title)) { // Reset loading state
        //   setState(() { _isDownloadingReport[title] = false; });
        // }
        return;
      }

      if (fileBytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download "$title": Empty file received.')),
        );
        // if (_isDownloadingReport.containsKey(title)) { // Reset loading state
        //   setState(() { _isDownloadingReport[title] = false; });
        // }
        return;
      }

      // 1. Get the appropriate directory to save the file.
      // getApplicationDocumentsDirectory(): For files private to the app.
      // getExternalStorageDirectory(): For files accessible by other apps (requires more permissions usually).
      // For simplicity and fewer permission hassles, getApplicationDocumentsDirectory is often preferred.
      final directory = await getApplicationDocumentsDirectory();

      // 2. Create a filename. Make it unique if necessary.
      //    Replacing spaces in title for a cleaner filename.
      final String sanitizedReportName = reportName.replaceAll(RegExp(r'\s+'), '_').toLowerCase();
      final String fileName = '${sanitizedReportName}_$accountId.pdf'; // Assuming PDF, adjust if not
      final String filePath = '${directory.path}/$fileName';

      // 3. Write the file to local storage.
      final file = File(filePath);
      await file.writeAsBytes(fileBytes, flush: true); // `flush: true` ensures data is written immediately

      debugPrint('Report "$title" downloaded to: $filePath');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report "$title" downloaded successfully!'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () {
              OpenFilex.open(filePath);
            },
          ),
        ),
      );

      // 4. Optionally, open the downloaded file directly without SnackBar action
      // final result = await OpenFilex.open(filePath);
      // debugPrint('OpenFilex result: ${result.type} - ${result.message}');
      // if (result.type != ResultType.done) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Could not open file: ${result.message}')),
      //   );
      // }

    } catch (e) {
      print('Error downloading report "$title": $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading report "$title": ${e.toString()}')),
      );
    } finally {
      // if (_isDownloadingReport.containsKey(title)) { // Reset loading state
      //   setState(() { _isDownloadingReport[title] = false; });
      // }
      // Your existing setState if it's tied to a general loading indicator
      setState(() {
        // Hide general registering/loading indicator (if needed)
      });
    }
  }

  Future<void> postPaymentToServer(PaymentSuccessResponse response) async {
    final paymentData = {
      "account_id": loanDetailsObject.encoreAccountSummary?.accountId ?? 'N/A',
      "razorpay_payment_id": response.paymentId,
    };

    try {
      final serverResponse = await _apiService.updatePaymentEntry(paymentData);
      debugPrint('Server response after payment: $serverResponse');
      if (serverResponse['apiCode'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Payment recorded successfully on server.")),
        );
        _lastSuccessfulPayment = null;
      } else {
        throw Exception('Server error: ${serverResponse['apiDesc']}');
      }
    } catch (error) {
      debugPrint('Error sending payment data to server: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to record payment on server: ${error.toString()}")),
      );
      _lastSuccessfulPayment = response;
      // Show bottom sheet to allow retry for posting to server
      _showRetryPostPaymentBottomSheet();
    }
  }

  // Method to show the bottom sheet for retrying postPaymentToServer
  void _showRetryPostPaymentBottomSheet() {
    if (_lastSuccessfulPayment == null) return; // Should not happen if called correctly

    showModalBottomSheet<void>(
        context: context,
        isDismissible: true, // User can dismiss by tapping outside
        builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Payment Confirmation Failed',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your payment through Razorpay was successful, but we couldn\'t confirm it with our server immediately. Please retry.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Retry Confirmation'),
              onPressed: () {
                Navigator.pop(context); // Dismiss the bottom sheet
                if (_lastSuccessfulPayment != null) {
                  postPaymentToServer(_lastSuccessfulPayment!); // Retry posting
                }
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context); // Dismiss the bottom sheet
                // User chose not to retry. You might want to guide them to contact support
                // or check their transaction history later.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("You can check your transaction history or contact support.")),
                );
              },
            ),
          ],
        ),
      );
    },
    );
  }
}
