import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import 'package:myapp/search_pan_screen.dart';
import 'package:dio/dio.dart';
import 'package:myapp/services/api_service.dart'; //Import ApiService
import 'package:flutter/foundation.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String mobileNumber;

  const VerifyOtpScreen({
    Key? key,
    required this.mobileNumber,
  }) : super(key: key);

  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  late Timer _timer;
  int _start = 30;
  late ApiService _apiService; //Declare ApiService
  bool _isVerifying = false;
  String? _emulatorRetrievedOtp;

  @override
  void initState() {
    super.initState();
    startTimer();
    final dio = Dio();
    _apiService = ApiService(dio);
    if (kDebugMode) { // Only in debug mode, try to simulate OTP retrieval
      // Simulate OTP Retrieval (for debug/emulator purposes only)
      _simulateOtpRetrieval();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void startTimer() {
    setState(() {
      _start = 30;
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

  // Method to simulate OTP retrieval (for debug/emulator purposes only)
  Future<void> _simulateOtpRetrieval() async {
    // Replace this with your actual method to get OTP (e.g., read from a file, use a debug API endpoint)
    // In this example, let's just set a static OTP for testing
    await Future.delayed(const Duration(seconds: 1)); //Simulate network delay
    if(mounted){
    setState(() {
      _emulatorRetrievedOtp = '1234';
    });
    }
    print('Simulated OTP: $_emulatorRetrievedOtp');
  }

  void _fillOtp() {
    if (_emulatorRetrievedOtp != null) {
      _otpController.text = _emulatorRetrievedOtp!;
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete OTP.')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final response = await _apiService.getOtp({
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
      }
    } catch (e) {
      print(e);
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
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                'Sent to +91 ${widget.mobileNumber}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // OTP Input Field
              Pinput(
                controller: _otpController,
                length: 4,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyDecorationWith(
                  border: Border.all(color: Colors.blue),
                ),
                onCompleted: (pin) => _verifyOtp(),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('  \u{23F1} 00:$_start', style: const TextStyle(color: Colors.grey)),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Wrong Number?', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              const Text("Didn't receive the OTP?", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: _start > 0 || _isVerifying ? null : () {
                      // TODO: Implement resend OTP logic
                      startTimer();
                    },
                    icon: _isVerifying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                          )
                        : const Icon(Icons.refresh),
                    label: const Text('Resend'),
                  ),
                ],
              ),
               if (_emulatorRetrievedOtp != null)
                  ElevatedButton(
                    onPressed: _fillOtp,
                    child: const Text('Fill OTP (Debug Only)'),
                  ),
              const Spacer(),

              // Continue Button
              ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
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