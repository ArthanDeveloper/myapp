import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';
import 'package:myapp/search_pan_screen.dart'; // Import for navigation
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/models/otp_request_model.dart';

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
  final TextEditingController _otpController = TextEditingController();
  late Timer _timer;
  int _start = 30;
  late ApiService _apiService;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    startTimer();
    final dio = Dio();
    _apiService = ApiService(dio);
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
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<String> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    // This is a simplified version. In a real app, you would handle iOS as well.
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  }

  Future<String> _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
    });

    try {
      final String deviceId = await _getDeviceId();
      final String appVersion = await _getAppVersion();
      final OtpRequestModel request = OtpRequestModel(
        mobileNumber: widget.mobileNumber,
        deviceId: deviceId,
        appVersion: appVersion,
      );

      await _apiService.getOtp(request);
      
      startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new OTP has been sent.')),
      );
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to resend OTP. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _verifyOtp() {
    if (_otpController.text.length == 4) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SearchPANScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the complete OTP.')),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Spacer(),
              const Icon(Icons.lock_outline, size: 60, color: Colors.green),
              const SizedBox(height: 20),
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
                    onPressed: _start > 0 || _isResending ? null : _resendOtp,
                    icon: _isResending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.0),
                          )
                        : const Icon(Icons.refresh),
                    label: const Text('Resend'),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _verifyOtp,
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
