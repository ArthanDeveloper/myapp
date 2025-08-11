import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/verify_otp_screen.dart';
import 'package:mobile_number/mobile_number.dart';

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

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    _apiService = ApiService(dio);
    _mobileNumberController.addListener(_onMobileNumberChanged);
    _autoDetectMobileNumber();
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    super.dispose();
  }

  Future<void> _autoDetectMobileNumber() async {
    if (Platform.isAndroid) {
      if (!await MobileNumber.hasPhonePermission) {
        await MobileNumber.requestPhonePermission;
      }
      try {
        final String? mobileNumber = await MobileNumber.mobileNumber;
        if (mobileNumber != null && mobileNumber.isNotEmpty) {
          final String last10Digits = mobileNumber.length > 10
              ? mobileNumber.substring(mobileNumber.length - 10)
              : mobileNumber;
          if (mounted) {
            setState(() {
              _mobileNumberController.text = last10Digits;
            });
          }
        }
      } on PlatformException catch (e) {
        debugPrint("Failed to get mobile number because of '${e.message}'");
      }
    }
  }

  void _onMobileNumberChanged() {
    if (_mobileNumberController.text.length == 10 &&
        _agreedToTerms1 &&
        !_isLoading) {
      _getOtp();
    }
  }

  void _getOtp() async {
    if (_isLoading) return;

    if (_mobileNumberController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getOtp({
        'mobileNumber': _mobileNumberController.text,
      });

      if (response != null && response['apiCode'] == 200) {
        // Successful API call: Navigate to VerifyOtpScreen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  VerifyOtpScreen(mobileNumber: _mobileNumberController.text),
            ),
          );
        }
      } else {
        // API returned an error, display a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get OTP. Please try again.')),
        );
      }
    } catch (e) {
      // Handle DioError or other exceptions
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to get OTP. Please check your connection and try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(height: 40),
            Icon(Icons.phone_android, size: 60, color: Colors.blue[700]),
            const SizedBox(height: 20),
            const Text(
              'Enter Mobile Number',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Linked to your bank account',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  const Text(
                    '+91',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _mobileNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
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
            const SizedBox(height: 20),
            _buildTermsCheckbox(
              value: _agreedToTerms1,
              onChanged: (value) => setState(() => _agreedToTerms1 = value!),
              text: [
                const TextSpan(text: 'By signing up, I agree to the '),
                TextSpan(
                  text: 'Terms and Conditions',
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      /* TODO */
                    },
                ),
                const TextSpan(text: ', '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      /* TODO */
                    },
                ),
                const TextSpan(
                  text:
                      ', and to receive regular communication from OneScore on WhatsApp, Email & SMS',
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _agreedToTerms1 ? _getOtp : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: _agreedToTerms1
                    ? Colors.deepOrange
                    : Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
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
                        color: _agreedToTerms1 ? Colors.white : Colors.black54,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
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
        Checkbox(value: value, onChanged: onChanged),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                children: text,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
