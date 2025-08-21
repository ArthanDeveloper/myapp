import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/set_biometric_screen.dart'; // Import the SetBiometricScreen
import 'package:dio/dio.dart';
import 'package:myapp/services/api_service.dart'; // Import the ApiService

class SetMpinScreen extends StatefulWidget {
  const SetMpinScreen({super.key});

  @override
  _SetMpinScreenState createState() => _SetMpinScreenState();
}

class _SetMpinScreenState extends State<SetMpinScreen> {
  final TextEditingController _mpinController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late ApiService _apiService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    _apiService = ApiService(dio);
  }

  @override
  void dispose() {
    _mpinController.dispose();
    super.dispose();
  }

  Future<void> _setMpinAndSaveFlag() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      try {
        final prefs = await SharedPreferences.getInstance();
        final String? customerId = prefs.getString('customerId');
        if (customerId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'There was a problem with ID, Please Check that this info has been set up',
              ),
            ),
          );
          return; // Stop execution if name is missing
        }
        final String mpin = _mpinController.text;

        final resetResponse = await _apiService.resetMpin({
          'mpin': mpin,
          'customerId': customerId,
        });
        if (resetResponse['apiCode'] == 200) {
          await prefs.setBool(
            'setMpin',
            true,
          ); // Implement actual MPIN setting logic (e.g., send to backend)
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SetBiometricScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sucessfully setup MPIN')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'API responded wih bad request: ${resetResponse['apiDesc']}',
              ),
            ),
          );
        }
      } catch (e) {
        // TODO: Handle error during API call or data retrieval
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error connecting with API, verify what you have selected on List and API details',
            ),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
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
                const Icon(
                  Icons.lock_open,
                  size: 60,
                  color: Colors.blueAccent,
                ), // Changed icon for setting MPIN
                const SizedBox(height: 20),

                // Title and Subtitle
                const Text(
                  'Set Your MPIN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
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
                  pinAnimationType: PinAnimationType.fade,

                  onCompleted: (pin) {
                    // Call the _setMpinAndSaveFlag function on OTP completion
                    _setMpinAndSaveFlag();
                  },
                ),
                const SizedBox(height: 40),

                const Spacer(),

                // Set MPIN Button
                ElevatedButton(
                  onPressed: _setMpinAndSaveFlag,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor:
                        Colors.deepOrange, // Consistent button style
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
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
