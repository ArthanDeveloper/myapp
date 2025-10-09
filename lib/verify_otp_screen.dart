import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import 'package:myapp/search_pan_screen.dart';
import 'package:dio/dio.dart';
import 'package:myapp/services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:sms_autofill/sms_autofill.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String mobileNumber;

  const VerifyOtpScreen({
    super.key,
    required this.mobileNumber,
  });

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  // Constants
  static const int _otpLength = 4;
  static const int _resendTimeoutSeconds = 30;

  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _start = _resendTimeoutSeconds;
  late ApiService _apiService;
  bool _isVerifying = false;
  String _appSignature = '';

  // For SMS listening
  StreamSubscription? _smsSubscription;

  @override
  void initState() {
    super.initState();
    startTimer();
    final dio = Dio();
    _apiService = ApiService(dio);
    _initSmsListener();
  }

  // METHOD 1: Using SMS Code Stream (More Reliable)
  Future<void> _initSmsListener() async {
    try {
      // Get app signature
      _appSignature = await SmsAutoFill().getAppSignature ?? '';
      debugPrint('=========================================');
      debugPrint('App Signature: $_appSignature');
      debugPrint('Add this signature to your SMS for better detection');
      debugPrint('=========================================');

      // Method 1: Listen using stream
      _smsSubscription = SmsAutoFill().code.listen((code) {
        debugPrint('SMS Code Received via Stream: $code');
        if (code != null && code.isNotEmpty) {
          _extractAndFillOtp(code);
        }
      });

      // Start listening
      await SmsAutoFill().listenForCode();
      debugPrint('SMS Listener Started Successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ SMS auto-read is active'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green[700],
          ),
        );
      }
    } catch (e) {
      debugPrint('Error initializing SMS listener: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SMS auto-read permission denied. Please enter OTP manually.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Extract OTP from SMS text
  void _extractAndFillOtp(String smsCode) {
    debugPrint('Extracting OTP from: $smsCode');

    // Method 1: Look for pattern "is XXXX" (your SMS format)
    RegExp otpPattern = RegExp(r'is\s+(\d{4})');
    Match? match = otpPattern.firstMatch(smsCode);

    String? otp;
    if (match != null && match.groupCount >= 1) {
      otp = match.group(1);
      debugPrint('OTP found using pattern match: $otp');
    } else {
      // Method 2: Fallback - find any 4 consecutive digits
      RegExp digitsPattern = RegExp(r'\d{4}');
      Match? digitsMatch = digitsPattern.firstMatch(smsCode);
      if (digitsMatch != null) {
        otp = digitsMatch.group(0);
        debugPrint('OTP found using digits match: $otp');
      } else {
        // Method 3: Last resort - get all digits and take first 4
        String allDigits = smsCode.replaceAll(RegExp(r'[^0-9]'), '');
        if (allDigits.length >= _otpLength) {
          otp = allDigits.substring(0, _otpLength);
          debugPrint('OTP extracted from all digits: $otp');
        }
      }
    }

    if (otp != null && otp.length == _otpLength) {
      setState(() {
        _otpController.text = otp!;
      });
      debugPrint('✓ OTP Auto-filled: $otp');

      // Optional: Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP detected: $otp'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.blue[700],
          ),
        );
      }

      // Auto-verify after a short delay (gives user time to see the filled OTP)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _otpController.text.length == _otpLength) {
          _verifyOtp();
        }
      });
    } else {
      debugPrint('❌ Failed to extract OTP from SMS');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _smsSubscription?.cancel(); // Cancel stream subscription
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _start = _resendTimeoutSeconds;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != _otpLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete OTP.')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final response = await _apiService.verifyOtp({
        'mobileNumber': widget.mobileNumber,
        'otp': _otpController.text,
      });

      if (response != null && response['apiCode'] == 200) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => SearchPANScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect OTP. Please try again.')),
        );
        // Clear OTP field on error
        _otpController.clear();
      }
    } catch (e) {
      debugPrint('OTP Verification Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to verify OTP. Please check your connection.')),
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

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.blue, width: 2),
    );

    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Colors.green),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(),
              const Icon(Icons.lock_outline, size: 60, color: Colors.green),
              const SizedBox(height: 20),

              // Title and Subtitle
              const Text(
                'Enter OTP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sent to +91 ${widget.mobileNumber}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              // Auto-fill indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.autorenew, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Auto-read enabled',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // OTP Input Field using Pinput
              Pinput(
                controller: _otpController,
                length: _otpLength,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                keyboardType: TextInputType.number,
                // androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
                // listenForMultipleSmsOnAndroid: true,
                hapticFeedbackType: HapticFeedbackType.lightImpact,
                onCompleted: (pin) {
                  debugPrint('OTP Completed: $pin');
                  _verifyOtp();
                },
                onChanged: (value) {
                  debugPrint('OTP Changed: $value');
                },
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '  \u{23F1} 00:${_start.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              const Text(
                "Didn't receive the OTP?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _start > 0 || _isVerifying
                        ? null
                        : () {
                      _resendOtp();
                      startTimer();
                    },
                    icon: _isVerifying
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    )
                        : const Icon(Icons.refresh),
                    label: const Text('Resend OTP'),
                  ),
                ],
              ),

              const Spacer(),

              // Continue Button
              ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: _isVerifying ? Colors.grey[300] : Colors.blue,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: _isVerifying
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    color: Colors.white,
                  ),
                )
                    : const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Improved resend method - no navigation
  Future<void> _resendOtp() async {
    if (widget.mobileNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number.'),
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _otpController.clear(); // Clear previous OTP
    });

    try {
      final response = await _apiService.getOtp({
        'mobileNumber': widget.mobileNumber,
      });

      if (response != null && response['apiCode'] == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ OTP sent successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Restart SMS listener for new OTP
          await SmsAutoFill().listenForCode();
          debugPrint('SMS Listener restarted for new OTP');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send OTP. Please try again.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Resend OTP Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send OTP. Please check your connection.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }
}