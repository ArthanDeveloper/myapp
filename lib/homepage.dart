import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Simple data model for a loan
class Loan {
  final String title;
  final String status;
  final IconData icon;

  Loan({required this.title, required this.status, required this.icon});
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with SingleTickerProviderStateMixin {
  String _customerName = 'User';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Dummy data for the list of loans
  final List<Loan> _loans = [
    Loan(title: 'Personal Loan', status: 'Active', icon: Icons.person_outline),
    Loan(title: 'Home Loan', status: 'Pending Approval', icon: Icons.home_outlined),
    Loan(title: 'Car Loan', status: 'Closed', icon: Icons.directions_car_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomerName();

    // Setup animation for an "unlocking" feel
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _customerName = prefs.getString('customerName') ?? 'User';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // TODO: Handle notifications
            },
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
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
              const SizedBox(height: 10),
              Text(
                'Here is a summary of your loans.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              // Loan List
              ..._loans.map((loan) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade50,
                    child: Icon(loan.icon, color: Colors.deepPurple),
                  ),
                  title: Text(loan.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(loan.status, style: TextStyle(color: _getStatusColor(loan.status))),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Implement navigation to loan details page
                    print('Tapped on ${loan.title}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped on ${loan.title}')),
                    );
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Pending Approval':
        return Colors.orange;
      case 'Closed':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}
