import 'package:flutter/material.dart';
import 'package:myapp/accounts_list_screen.dart'; // Import the AccountsListScreen

// Simple data model for a customer profile
class CustomerProfile {
  final String name;
  final String maskedMobile;
  final String id;

  CustomerProfile({required this.name, required this.maskedMobile, required this.id});
}

class SelectCustomerScreen extends StatefulWidget {
  final String profileId;
  const SelectCustomerScreen({
    super.key,  required this.profileId,
  });

  @override
  _SelectCustomerScreenState createState() => _SelectCustomerScreenState();
}

class _SelectCustomerScreenState extends State<SelectCustomerScreen> {

  @override
  void initState() {
    super.initState();
    // Print the profile id to the console when the screen loads
    print('Selected profile ID: ${widget.profileId}');
  }

  // Dummy data for demonstration
  final List<CustomerProfile> _profiles = [
    CustomerProfile(name: 'Kathleen Romero', maskedMobile: '+91 XXXXXX0221', id: '1'),
    CustomerProfile(name: 'John Doe', maskedMobile: '+91 XXXXXX1234', id: '2'),
    CustomerProfile(name: 'Jane Smith', maskedMobile: '+91 XXXXXX5678', id: '3'),
  ];

  String? _selectedProfileId;

  void _onProfileSelected(String? profileId) {
    setState(() {
      _selectedProfileId = profileId;
    });
  }

  void _onContinue() {
    if (_selectedProfileId != null) {
      // Navigate to the AccountsListScreen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AccountsListScreen()),
      );
    
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a profile to continue.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select your profile'),
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
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                final profile = _profiles[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 16.0,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      profile.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(profile.maskedMobile),
                    trailing: Radio<String>(
                      value: profile.id,
                      groupValue: _selectedProfileId,
                      onChanged: _onProfileSelected,
                    ),
                    onTap: () => _onProfileSelected(profile.id),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedProfileId != null ? _onContinue : null,
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
