import 'package:flutter/material.dart';
import 'dart:async';
import 'package:myapp/onboarding_screen_3.dart'; // Import the next screen

class OnboardingScreen2 extends StatefulWidget {
  const OnboardingScreen2({super.key});

  @override
  _OnboardingScreen2State createState() => _OnboardingScreen2State();
}

class _OnboardingScreen2State extends State<OnboardingScreen2> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 1), // Animation duration
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn, // Fade-in curve
    );

    _controller.forward(); // Start the fade-in animation

    // Set a timer to navigate to the next screen after 3 seconds
    _timer = Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingScreen3()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel(); // Cancel the timer to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60.0), // Spacing from the top
              Text(
                'What Sets Us Apart?', // Title from screenshot
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange, // Assuming orange color from screenshot
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                "Quick loans, no fees, less paperwork and friendly support for you.", // Description from screenshot
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 40.0),
              // Image placeholder based on screenshot
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/onboarding_image_2.png', // Replace with your actual image path and add to pubspec.yaml
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 40.0),
              // Buttons from screenshot
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement navigation for new users
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'I AM NEW TO ARTHIK',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              SizedBox(height: 15.0),
              OutlinedButton(
                onPressed: () {
                  // TODO: Implement navigation for existing users
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15.0),
                  side: BorderSide(color: Colors.blue),
                  foregroundColor: Colors.blue,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'I ALREADY HAVE AN ACCOUNT',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              SizedBox(height: 40.0), // Spacing from the bottom
            ],
          ),
        ),
      ),
    );
  }
}