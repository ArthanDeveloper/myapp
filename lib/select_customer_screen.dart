import 'package:flutter/material.dart';

// Simple data model for a customer profile
class CustomerProfile {
  final String name;
  final String maskedMobile;
  final String id;

  CustomerProfile({required this.name, required this.maskedMobile, required this.id});
}

class SelectCustomerScreen extends StatefulWidget {
  const SelectCustomerScreen({super.key});

  @override
  _SelectCustomerScreenState createState() => _SelectCustomerScreenState();
}

class _SelectCustomerScreenState extends State<SelectCustomerScreen> {
  // Dummy data for demonstration
  final List<CustomerProfile> _profiles = [
    CustomerProfile(name: 'John Doe', maskedMobile: '+91 XXXXXX1234', id: '1'),
    CustomerProfile(name: 'Jane Smith', maskedMobile: '+91 XXXXXX5678', id: '2'),
  ];

  String? _selectedProfileId;

  void _onProfileSelected(String? profileId) {
    setState(() {
      _selectedProfileId = profileId;
    });
  }

  void _onContinue() {
    if (_selectedProfileId != null) {
      // TODO: Implement navigation to the next screen
      print('Selected profile ID: $_selectedProfileId');
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(profile.name, style: const TextStyle(fontWeight: FontWeight.bold)),
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
