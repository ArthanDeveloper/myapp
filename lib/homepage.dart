import 'package:flutter/material.dart';
import 'package:myapp/helper/helper.dart';
import 'package:myapp/support_tickets_screen.dart';
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
  final String accountId;
  final String tenureMagnitude;
  final String tenureUnit;
  final String normalInterestRate;

  Loan({
    required this.title,
    required this.status,
    required this.icon,
    required this.amount,
    required this.lastUpdated,
    required this.accountId,
    this.tenureMagnitude = 'N/A',
    this.tenureUnit = 'N/A',
    this.normalInterestRate = 'N/A',
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
  int _selectedIndex = 0; // For BottomNavigationBar

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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
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
          _loans = loanData
              .map(
                (item) => Loan(
                  title: item['accountName'] ?? 'Account Name not available',
                  status: item['operationalStatus'] ?? 'Status not available',
                  icon: Icons.monetization_on_outlined,
                  amount: item['amount'] ?? 'Amount not available',
                  lastUpdated:
                      item['accountOpenDateStr'] ?? 'Date not available',
                  accountId: item['accountId'] ?? 'NA',
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

  Widget _buildStatusPill(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'Active':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        break;
      case 'Pending Approval':
        backgroundColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        break;
      case 'Closed':
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
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

  List<Widget> get _getWidgetOptions {
    // Using a getter
    return <Widget>[
      FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Welcome Message
              Text(
                'Welcome, ${toTitleCase(_customerName)}!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

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
                              builder: (context) =>
                                  LoanDetailsScreen(loan: loan),
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
                                    Icons.business_center_rounded,
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
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                              vertical: 4.0,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                            child: Text(
                                              loan.accountId,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          _buildStatusPill(loan.status),
                                        ],
                                      ),

                                      SizedBox(height: 8),
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
      // Placeholder for Loans page
      const Center(child: Text('Loans Page', style: TextStyle(fontSize: 24))),
      // Placeholder for Services page
      const Center(
        child: Text('Services Page', style: TextStyle(fontSize: 24)),
      ),
      // Placeholder for Profile page
      const Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SupportTicketsScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
        // If you want to re-trigger animations when switching to the "Home" tab (index 0)
        // and it's not already the current tab, you can do:
        if (index == 0) {
          _animationController.reset();
          _animationController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... inside the build method of _HomepageState
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: () {
            // TODO: Implement chat functionality
          },
        ),
        // Replace Text widget with Image widget for the title
        title: SizedBox(
          // Use SizedBox to constrain the image size if needed
          height: kToolbarHeight - 01,
          // Example: Adjust height as needed, kToolbarHeight is AppBar's typical height
          child: Image.asset(
            'assets/app_splash.png',
            // Replace with the correct path to your image
            fit: BoxFit
                .contain, // Adjust BoxFit as needed (e.g., BoxFit.fitHeight)
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // TODO: Implement profile/user action
            },
          ),
        ],
        // Optional: You might want to adjust AppBar properties like backgroundColor or elevation
        // backgroundColor: Colors.white, // If your logo looks better on a white AppBar
        elevation: 8,
      ),

      // ... rest of your build method
      backgroundColor: Colors.white,
      body: Center(
        // Or IndexedStack for better performance if pages are complex
        child: _getWidgetOptions.elementAt(
          _selectedIndex,
        ), // Use the getter here
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Loans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services_outlined),
            activeIcon: Icon(Icons.miscellaneous_services),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey.shade600,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }
}
