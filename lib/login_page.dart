import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io' show Platform; // Import Platform
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/search_pan_screen.dart'; // Import SearchPANScreen
import 'package:smart_auth/smart_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _mobileNumberController = TextEditingController();
  bool _agreedToTerms1 = true;
  bool _isLoading = false;
  late ApiService _apiService;
  late SmartAuth _smartAuth;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    _apiService = ApiService(dio);
    _smartAuth = SmartAuth();
    _mobileNumberController.addListener(_onMobileNumberChanged);
    _autoDetectMobileNumber();
  }

  @override
  void dispose() {
    _mobileNumberController.removeListener(_onMobileNumberChanged);
    _mobileNumberController.dispose();
    super.dispose();
  }

  Future<void> _autoDetectMobileNumber() async {
    // Platform-specific check: Only run on Android
    if (Platform.isAndroid) {
      try {
        final String? mobileNumber = await _smartAuth.getPhoneNumber();
        if (mobileNumber != null && mobileNumber.isNotEmpty) {
          final String last10Digits = mobileNumber.length > 10
              ? mobileNumber.substring(mobileNumber.length - 10)
              : mobileNumber;
          // Check if the widget is still mounted before calling setState
          if (mounted) {
            setState(() {
              _mobileNumberController.text = last10Digits;
            });
          }
        }
      } catch (e) {
        print('Failed to get phone number hint: $e');
      }
    }
  }

  void _onMobileNumberChanged() {
    if (_mobileNumberController.text.length == 10 && _agreedToTerms1 && !_isLoading) {
      _getOtp();
    }
  }

  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.android) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "unknown";
    }
  }

  Future<String> _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  void _getOtp() async {
    if (_isLoading) return;

    if (_mobileNumberController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid 10-digit mobile number.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate a 3-second delay
    await Future.delayed(const Duration(seconds: 3));

    // Navigate to SearchPANScreen after the delay
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SearchPANScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 40),
            Icon(Icons.phone_android, size: 60, color: Colors.blue[700]),
            SizedBox(height: 20),
            Text(
              'Enter Mobile Number',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Linked to your bank account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  Text(
                    '+91',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _mobileNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Mobile Number',
                        border: InputBorder.none,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            _buildTermsCheckbox(
              value: _agreedToTerms1,
              onChanged: (value) => setState(() => _agreedToTerms1 = value!),
              text: [
                TextSpan(text: 'By signing up, I agree to the '),
                TextSpan(
                  text: 'Terms and Conditions',
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()..onTap = () {/* TODO */},
                ),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()..onTap = () {/* TODO */},
                ),
                TextSpan(
                  text:
                      ', and to receive regular communication from OneScore on WhatsApp, Email & SMS',
                ),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: (_agreedToTerms1 && !_isLoading) ? _getOtp : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: (_agreedToTerms1 && !_isLoading)
                    ? Colors.deepOrange
                    : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                  : Text(
                      'Get OTP',
                      style: TextStyle(
                        fontSize: 16,
                        color: (_agreedToTerms1 && !_isLoading)
                            ? Colors.white
                            : Colors.black54,
                      ),
                    ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required List<TextSpan> text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: Colors.black87),
                children: text,
              ),
            ),
          ),
        ),
      ],
    );
  }
}