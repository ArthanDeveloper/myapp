import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:myapp/services/api_service.dart';
import 'package:myapp/models/otp_request_model.dart';
import 'package:myapp/location_permission_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _mobileNumberController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  bool _agreedToTerms = false;
  bool _otpSent = false;
  int _resendOtpTimer = 30;
  Timer? _timer;
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    _apiService = ApiService(dio);
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    _timer?.cancel();
    super.dispose();
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
    final String deviceId = await _getDeviceId();
    final String appVersion = await _getAppVersion();
    final OtpRequestModel request = OtpRequestModel(
      mobileNumber: _mobileNumberController.text,
      deviceId: deviceId,
      appVersion: appVersion,
    );

    try {
      await _apiService.getOtp(request);
      setState(() {
        _otpSent = true;
      });
      _startResendTimer();
    } catch (e) {
      // Handle error
      print(e);
    }
  }

  void _startResendTimer() {
    _resendOtpTimer = 30;
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendOtpTimer < 1) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() {
          _resendOtpTimer--;
        });
      }
    });
  }

  void _onOtpDigitChanged(String value, int index) {
    if (value.length == 1 && index < _otpControllers.length - 1) {
      FocusScope.of(context).nextFocus();
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (_otpSent) {
              setState(() {
                _otpSent = false;
                _timer?.cancel();
                for (var controller in _otpControllers) {
                  controller.clear();
                }
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Image.asset('assets/app_logo.png', height: 30),
            ),
            Text('arthik', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.question_mark_outlined),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      value: _otpSent ? 2 / 5 : 1 / 5,
                      strokeWidth: 3,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  Text(
                    _otpSent ? '2/5' : '1/5',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 20.0),
            Text(
              _otpSent
                  ? 'Verify OTP Next: Location'
                  : 'Mobile No. Next: Location',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40.0),
            Text(
              _otpSent ? 'Enter OTP' : 'Enter Your Mobile Number',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              _otpSent
                  ? 'Please enter the OTP sent to your mobile number.'
                  : 'Your phone number helps us stay in touch for account updates and offers.',
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
            ),
            SizedBox(height: 30.0),
            if (!_otpSent)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _mobileNumberController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Phone no.',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.0),
                  ElevatedButton(
                    onPressed: _getOtp,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 20.0,
                      ),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text('GET OTP'),
                  ),
                ],
              ),
            if (_otpSent)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      4,
                      (index) => SizedBox(
                        width: 50,
                        child: TextField(
                          controller: _otpControllers[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            counterText: "",
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2.0,
                              ),
                            ),
                          ),
                          onChanged:
                              (value) => _onOtpDigitChanged(value, index),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Align(
                    alignment: Alignment.center,
                    child:
                        _resendOtpTimer > 0
                            ? Text('RESEND OTP in $_resendOtpTimer seconds')
                            : TextButton(
                              onPressed: () {
                                _startResendTimer();
                              },
                              child: Text('RESEND OTP'),
                            ),
                  ),
                ],
              ),
            SizedBox(height: 15.0),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {},
                child: Text('I HAVE A REFERRAL ID'),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              padding: EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.green),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      'Enter the phone no. that is linked with your Aadhaar card & bank account.',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.0),
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _agreedToTerms = newValue ?? false;
                    });
                  },
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'I agree to the ',
                      style: TextStyle(fontSize: 14.0, color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Terms of Services',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        TextSpan(text: ' & agree with the '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        TextSpan(
                          text: ' of Arthan Finance',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(child: SizedBox()),
            ElevatedButton(
              onPressed:
                  _agreedToTerms
                      ? () {
                        if (_otpSent) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LocationPermissionScreen(),
                            ),
                          );
                        } else {
                          _getOtp();
                        }
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                _otpSent ? 'VERIFY OTP' : 'CONTINUE',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
