import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pinput.dart';
import 'package:myapp/homepage.dart'; // Import the Homepage
import 'package:myapp/set_mpin_screen.dart'; // Import for "Set MPIN" navigation

class LoginWithMpinScreen extends StatefulWidget {
  const LoginWithMpinScreen({super.key});

  @override
  State<LoginWithMpinScreen> createState() => _LoginWithMpinScreenState();
}

class _LoginWithMpinScreenState extends State<LoginWithMpinScreen> with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _mpinController = TextEditingController();

  String _customerName = 'User';
  String _customerMobile = '';
  bool _setMpinFlag = false;
  bool _setBiometricFlag = false;
  bool _canCheckBiometrics = false;
  bool _isAuthenticatingBiometric = false;

  // For animation (simple unlocking safely animation)
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFlags();
    _checkBiometricsAvailability();

    // Setup animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Adjust duration as needed
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
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
      _customerMobile = prefs.getString('customerMobile') ?? ''; // Assuming you save this somewhere
      _setMpinFlag = prefs.getBool('setMpin') ?? false;
      _setBiometricFlag = prefs.getBool('setBiometric') ?? false;
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
    if (mounted) {
      setState(() {
        _canCheckBiometrics = canCheckBiometricsResult;
      });
    }
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
    if (_isAuthenticatingBiometric) return; // Prevent multiple auth attempts
    setState(() {
      _isAuthenticatingBiometric = true;
    });
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to login',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print("Error during biometric authentication: $e");
      if (mounted && !isAutoAttempt) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication failed or cancelled.')),
        );
      }
    }
    if (mounted) {
      setState(() {
        _isAuthenticatingBiometric = false;
      });
      if (authenticated) {
        // On successful biometric login, navigate to Homepage
        _navigateToHomepage();
      }
    }
  }

  void _verifyMpin() {
    // TODO: Implement actual MPIN verification logic (e.g., send to backend)
    // For now, any 4 digits will be considered successful
    if (_mpinController.text.length == 4) {
      _navigateToHomepage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 4-digit MPIN.')),
      );
    }
  }

  void _navigateToHomepage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Homepage()),
      (Route<dynamic> route) => false,
    );
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
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Spacer(),
                  // Animation or welcome icon
                  const Icon(Icons.lock_open, size: 80, color: Colors.blueAccent), // Placeholder for unlocking animation
                  const SizedBox(height: 20),

                  Text(
                    'Welcome, $_customerName!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 16),

                  // Conditional UI for MPIN or Biometric prompt
                  if (_setBiometricFlag && _canCheckBiometrics) ...[
                    // Biometric ready, waiting for auto-popup or manual click
                    const Text(
                      'Authenticate to proceed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: _isAuthenticatingBiometric ? null : () => _authenticateBiometric(),
                      icon: _isAuthenticatingBiometric
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.fingerprint),
                      label: const Text('Login with Fingerprint', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        backgroundColor: Colors.deepPurple, // Example color
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Option to use MPIN if biometric is available but user wants to use MPIN
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _setBiometricFlag = false; // Temporarily disable biometric flow to show MPIN
                        });
                      },
                      child: const Text('Use MPIN instead', style: TextStyle(color: Colors.blue)),
                    ),
                  ] else if (_setMpinFlag) ...[
                    // MPIN is set, prompt for MPIN
                    const Text(
                      'Please enter your MPIN',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),
                    Pinput(
                      controller: _mpinController,
                      length: 4,
                      obscureText: true,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: defaultPinTheme.copyDecorationWith(
                        border: Border.all(color: Colors.blue),
                      ),
                      onCompleted: (pin) => _verifyMpin(),
                      validator: (s) {
                        if (s == null || s.length != 4) {
                          return 'Enter 4-digit MPIN';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement Forgot MPIN logic
                      },
                      child: const Text('Forgot MPIN?', style: TextStyle(color: Colors.blue)),
                    ),
                  ] else ...[
                    // Neither MPIN nor Biometric is set, navigate to set MPIN or show an error
                    const Text(
                      'No login method set. Please set up your MPIN.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to set MPIN screen
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const SetMpinScreen()),
                        );
                      },
                      child: const Text('Set MPIN'),
                    ),
                  ],
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
