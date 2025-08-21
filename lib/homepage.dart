import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/loan_details_screen.dart'; // Import the LoanDetailsScreen
import 'package:myapp/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

// Updated data model for a loan to match the new design
class Loan {
  final String title;
  final String status;
  final IconData icon;
  final String amount;
  final String lastUpdated;

  Loan({
    required this.title,
    required this.status,
    required this.icon,
    required this.amount,
    required this.lastUpdated,
  });
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  String _customerName = 'User';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<Loan> _loans = [];
  bool _isLoading = false;
  String authToken = 'YOUR_AUTH_TOKEN'; // Token
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    dio.options.headers = {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    };
    _apiService = ApiService(dio);
    loadDashBoard();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadDashBoard() async {
    setState(() {
      _isLoading = true; //Implements that function to load API
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? customerId = prefs.getString(
        'customerId',
      ); //what was the string
      if (customerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This is internal error please try to login again contact arthik Support and provide what has happened in screen',
            ),
          ),
        );
        return;
      }
      final response = await _apiService.getDashBoard(customerId);

      if (response != null && response is Map<String, dynamic>) {
        setState(() {
          _customerName = response['name'] as String? ?? 'Loading...';
          final List<dynamic> loanData = response['data'];
          _loans =
              loanData
                  .map(
                    (item) => Loan(
                      title:
                          item['accountName'] ?? 'Account Name not available',
                      status:
                          item['operationalStatus'] ?? 'Status not available',
                      icon: Icons.monetization_on_outlined,
                      amount: item['amount'] ?? 'Amount not available',
                      lastUpdated:
                          item['accountOpenDateStr'] ?? 'Date not available',
                    ),
                  )
                  .toList();
        });
        debugPrint(
          'API Response: $response',
        ); // Print the entire response to check all
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: () {},
        ),
        title: Text(
          'Lendeasy',
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Welcome Message
              Text(
                'Welcome, $_customerName!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),

              // Loan List - Redesigned Cards
              ..._loans
                  .map(
                    (loan) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => LoanDetailsScreen(loan: loan),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    loan.icon,
                                    color: Colors.grey.shade700,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    loan.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildStatusPill(loan.status),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Updated on ${loan.lastUpdated}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    loan.amount,
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
                  )
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the status pill
  Widget _buildStatusPill(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'Final Approval':
      case 'Approved':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'Initial Approval':
        backgroundColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        break;
      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
