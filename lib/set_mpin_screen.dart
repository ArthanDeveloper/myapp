import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/set_biometric_screen.dart'; // Import the SetBiometricScreen
// You might want to navigate to a home screen or dashboard after setting MPIN
// import 'package:myapp/home_screen.dart';

class SetMpinScreen extends StatefulWidget {
  const SetMpinScreen({super.key});

  @override
  _SetMpinScreenState createState() => _SetMpinScreenState();
}

class _SetMpinScreenState extends State<SetMpinScreen> {
  final TextEditingController _mpinController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _mpinController.dispose();
    super.dispose();
  }

  Future<void> _setMpinAndSaveFlag() async {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: Implement actual MPIN setting logic (e.g., send to backend)
      print('MPIN Set: ${_mpinController.text}');

      // Save the flag in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('setMpin', true);
      print('setMpin flag set to true in SharedPreferences.');

      // Navigate to the SetBiometricScreen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SetBiometricScreen()),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MPIN set successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Spacer(),
                // Lock Icon
                const Icon(Icons.lock_open, size: 60, color: Colors.blueAccent), // Changed icon for setting MPIN
                const SizedBox(height: 20),

                // Title and Subtitle
                const Text(
                  'Set Your MPIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please set a 4-digit MPIN for secure access.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // MPIN Input Field
                Pinput(
                  controller: _mpinController,
                  length: 4,
                  obscureText: true, // Hide the entered PIN
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: Colors.blue),
                  ),
                  validator: (s) {
                    if (s == null || s.isEmpty) {
                      return 'MPIN cannot be empty';
                    } else if (s.length != 4) {
                      return 'MPIN must be 4 digits';
                    }
                    return null;
                  }, 
                ),
                const SizedBox(height: 40),

                const Spacer(),

                // Set MPIN Button
                ElevatedButton(
                  onPressed: _setMpinAndSaveFlag,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Colors.deepOrange, // Consistent button style
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text(
                    'Set MPIN',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
