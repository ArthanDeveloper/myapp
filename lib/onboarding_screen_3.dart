import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class OnboardingScreen3 extends StatefulWidget {
  const OnboardingScreen3({super.key});

  @override
  _OnboardingScreen3State createState() => _OnboardingScreen3State();
}

class _OnboardingScreen3State extends State<OnboardingScreen3> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // Animation duration
      vsync: this,
    );

    // Define opacity animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Start the animation
    _controller.forward();

    // Set the onboarding visited flag in local storage when this screen is initialized
    _setOnboardingVisitedFlag();
  }

  Future<void> _setOnboardingVisitedFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_visited', true);
    print('Onboarding visited flag set to true'); // For debugging
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose animation controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60.0), // Spacing from the top
              Text(
                'Why Choose Us?', // Title from screenshot
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange, // Assuming orange color from screenshot
                ),
              ),
              SizedBox(height: 20.0),
              Text(
                'Because we provide flexible options and best-in-class customer service.', // Description from screenshot
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
                    'assets/onboarding_image_3.png', // Replace with your actual image path and add to pubspec.yaml
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