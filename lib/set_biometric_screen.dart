import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/setup_complete_screen.dart'; // Import the SetupCompleteScreen
import 'package:dio/dio.dart';
import 'package:myapp/services/api_service.dart'; // Import the ApiService

class SetBiometricScreen extends StatefulWidget {
  const SetBiometricScreen({super.key});

  @override
  _SetBiometricScreenState createState() => _SetBiometricScreenState();
}

class _SetBiometricScreenState extends State<SetBiometricScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
   bool _isLoading = false; // Track loading state
    late ApiService _apiService;
    String authToken = 'YOUR_AUTH_TOKEN'; // Token

  @override
  void initState() {
    super.initState();
    final dio = Dio();
          dio.options.headers = {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          };
        _apiService = ApiService(dio);
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
    setState(() {
        _isLoading = true;
      });
    try {
        final prefs = await SharedPreferences.getInstance();
         final String? customerId = prefs.getString('customerId'); // getting the right id with this one now
          bool authenticated = false;

        if (customerId == null) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('There was a problem with ID, Please Check that this info has been set up')),
           );
         return;
        }
       authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to set up fingerprint unlock',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );

             final Map<String, dynamic>  updateBiometric  = await _apiService.updateBiometric({
                 "biometricStatus": authenticated.toString(), //make sure to check if it equals true.
                 "customerId": customerId,
                });
                       await prefs.setBool('setBiometric', authenticated );
                      Navigator.of(context).pushReplacement(
                         MaterialPageRoute(builder: (context) => const SetupCompleteScreen()),
                         );

              ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('Biometric authentication set up successfully!')),
               );
   } catch (e) {
       print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Problem with the API call of your authenticate, ${e.toString()}')),
    );
   }
     finally {
        setState(() {
        _isLoading = false;
      });
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
                            if (_isLoading)
                  CircularProgressIndicator()
                  else          ElevatedButton(

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
