import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // App Logo
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/app_splash.png', // Replace with your actual logo path
                  width: 300,
                  height: 200,
                ),
              ),
            ),
            // Company Name and App Version
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      text: 'Arthan Finance Private Limited',
                      // Replace with your company name
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      text: 'Version 1.0(082025)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
