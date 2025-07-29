import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/setup_complete_screen.dart'; // Import the SetupCompleteScreen
// You might want to navigate to a home screen or dashboard after setting biometric
// import 'package:myapp/home_screen.dart';

class SetBiometricScreen extends StatefulWidget {
  const SetBiometricScreen({super.key});

  @override
  _SetBiometricScreenState createState() => _SetBiometricScreenState();
}

class _SetBiometricScreenState extends State<SetBiometricScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometrics = false;
      print("Error checking biometrics: $e");
    }
    if (mounted) {
      setState(() {
        _canCheckBiometrics = canCheckBiometrics;
      });
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to set up fingerprint unlock',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print("Error during authentication: $e");
    }
    if (mounted) {
      if (authenticated) {
        // Save the flag in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('setBiometric', true);
        print('setBiometric flag set to true in SharedPreferences.');

        // Navigate to the SetupCompleteScreen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SetupCompleteScreen()),
        );

         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Biometric authentication set up successfully!')),
         );
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Biometric authentication failed or cancelled.')),
         );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Assuming white background from screenshot
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(),
              // Circular area with fingerprint icon
              Center(
                child: Container(
                  width: 180, // Adjust size as needed
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade200, width: 2.0), // Outer circle
                  ),
                  padding: const EdgeInsets.all(20.0), // Inner spacing
                  child: Container(
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       color: Colors.blue.shade100, // Inner circle color
                     ),
                     child: Icon(
                       Icons.fingerprint,
                       size: 80,
                       color: Colors.blue.shade700, // Fingerprint icon color
                     ),
                   ),
                ),
              ),
              const SizedBox(height: 40),

              // Title and Subtitle
              const Text(
                'Use Touch ID to authorise payments', // Assuming Touch ID/Fingerprint based on icon
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              const Text(
                'Activate touch ID so you dont need to confirm your PIN every time you want to send money.', // Subtitle
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              const Spacer(),

              // Activate Now Button
              ElevatedButton(
                // Only enable if biometrics are available
                onPressed: _canCheckBiometrics ? _authenticate : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.deepPurple, // Assuming purple color from screenshot
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Activate Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
