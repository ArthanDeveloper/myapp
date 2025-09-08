import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:myapp/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pinput.dart';
import 'package:myapp/homepage.dart'; // Import the Homepage

class LoginWithMpinScreen extends StatefulWidget {
  const LoginWithMpinScreen({super.key});

  @override
  State<LoginWithMpinScreen> createState() => _LoginWithMpinScreenState();
}

class _LoginWithMpinScreenState extends State<LoginWithMpinScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _mpinController = TextEditingController();

  String _customerName = 'User';
  String _customerId = '';
  bool _setBiometricFlag = false;
  bool _canCheckBiometrics = false;
  bool _setMpinFlag =
  false; //ADD here with new state for mpin to make it work, must have this
  bool _isAuthenticatingBiometric = false;

  // For animation (simple unlocking safely animation)
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late ApiService _apiService;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFlags();
    _checkBiometricsAvailability();
    final dio = Dio();
    _apiService = ApiService(dio);

    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Adjust duration as needed
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _mpinController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDataAndFlags() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customerName = prefs.getString('customerName') ?? 'User';
      _customerId = prefs.getString('customerId') ?? '';
      _setBiometricFlag = prefs.getBool('setBiometric') ?? false;
      _setMpinFlag = prefs.getBool('setMpin') ?? false; //get bool from set
    });
    _checkLoginMethodAndProceed();
  }

  Future<void> _checkBiometricsAvailability() async {
    bool canCheckBiometricsResult;
    try {
      canCheckBiometricsResult = await auth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometricsResult = false;
      print("Error checking biometrics availability: $e");
    }
    setState(() {
      _canCheckBiometrics = canCheckBiometricsResult;
    });
  }

  Future<void> _checkLoginMethodAndProceed() async {
    if (_setBiometricFlag && _canCheckBiometrics) {
      // Try biometric login automatically
      await _authenticateBiometric(isAutoAttempt: true);
    }
    // If biometric is not set or fails, then prompt for MPIN if set
    if (!_setBiometricFlag || (!_canCheckBiometrics && _setMpinFlag)) {
      // This means we'll show the MPIN input by default if biometric isn't set or available
      // No explicit action needed here, the UI will render accordingly.
    }
  }

  Future<void> _authenticateBiometric({bool isAutoAttempt = false}) async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Scan to authenticate',
        options: const AuthenticationOptions(stickyAuth: true),
      );
    } catch (e) {
      print("Error during biometric authentication: $e");
    }

    if (authenticated) {
      // On successful biometric login, navigate to Homepage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
    }
  }

  Future<void> _verifyMpin() async {
    if (_mpinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete MPIN.')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final response = await _apiService.auth({
        'customerId': _customerId,
        'mpin': _mpinController.text,
      });

      if (response != null && response['apiCode'] == 200) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect MPIN. Please try again.')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to verify MPIN. Please check your connection.')),
      );
    } finally {
      setState(() {
        _isVerifying = false;
      });
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
      backgroundColor: Color(0xFFE8EAF6), // Set background color
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Spacer(),
                Image.asset(
                  'assets/app_splash.png', // Replace with your actual logo path
                  width: 150,
                  height: 150,
                ),
                Icon(Icons.shield, size: 80, color: Colors.blue),
                //Added this to a icon, so it is what code is
                const SizedBox(height: 20),
                // Text Add for what the names should be with it
                Text(
                  'Welcome, $_customerName',
                  //Added to be part of the user prompt
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ), // Assuming size and bold style
                ),
                Text(
                  'Please enter your MPIN', //Text in the Text Field
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16), // Spacing between widgets
                Pinput(
                  controller: _mpinController,
                  length: 4,
                  obscureText: true,
                  // hide input digits, to increase auths
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyDecorationWith(
                    border: Border.all(color: Colors.blue),
                  ),
                  onCompleted: (pin) => _verifyMpin() // Call verify when it all completed
                ),
                Align(
                  alignment: Alignment.center, // Use the correct align
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot MPIN?',
                      style: TextStyle(color: Colors.blue),
                    ), //Text at login page design
                  ),
                ),

                const Text('OR', textAlign: TextAlign.center),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 15.0,
                  ),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.fingerprint),
                    label: const Text(
                      'Login with your Fingerprint',
                      style: TextStyle(fontSize: 18),
                    ),
                    onPressed: _canCheckBiometrics
                        ? _authenticateBiometric
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 10.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 5), //Bottom naviagte and text
                Align(
                  alignment: Alignment.bottomCenter,
                  child: RichText(
                    text: TextSpan(
                      text: 'Version 1.0(082025)',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                // Row(
                //   //Bottom icon Row
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: [
                //     IconButton(
                //       icon: const Icon(
                //         Icons.lock_outline,
                //         color: Colors.black54,
                //       ),
                //       onPressed: () {},
                //     ),
                //     IconButton(
                //       icon: const Icon(
                //         Icons.manage_accounts,
                //         color: Colors.black54,
                //       ),
                //       onPressed: () {},
                //     ),
                //     IconButton(
                //       icon: const Icon(Icons.qr_code, color: Colors.black54),
                //       onPressed: () {},
                //     ),
                //     IconButton(
                //       icon: const Icon(
                //         Icons.credit_card,
                //         color: Colors.black54,
                //       ),
                //       onPressed: () {},
                //     ),
                //   ],
                // ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
