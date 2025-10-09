import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:myapp/splash_screen.dart'; // Import the actual splash screen widget
import 'package:myapp/onboarding_screen.dart'; // Import the first onboarding screen
import 'package:myapp/login_page.dart'; // Import the login page
import 'package:myapp/login_with_mpin_screen.dart'; // Import the LoginWithMpinScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arthik',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreenWrapper(), // Start with the wrapper
    );
  }
}

// Wrapper widget to handle the splash screen timer and navigation
class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    // Start a timer to navigate after 2 seconds
    Timer(const Duration(seconds: 2), () async { // Timer set to 2 seconds
      final prefs = await SharedPreferences.getInstance();
      final onboardingVisited = prefs.getBool('onboarding_visited') ?? false;
      final setMpinFlag = prefs.getBool('setMpin') ?? false; // Fetch setMpin flag
      final setBiometricFlag = prefs.getBool('setBiometric') ?? false; // Fetch setBiometric flag

      if (mounted) { // Check if the widget is still mounted before navigating
        if (setMpinFlag || setBiometricFlag) {
          // If either MPIN or Biometric is set, navigate to LoginWithMpinScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginWithMpinScreen()),
          );
        } else if (onboardingVisited) {
          // If onboarding has been visited but no MPIN/Biometric, navigate to Login Page
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          // If onboarding has not been visited and no MPIN/Biometric, navigate to the first Onboarding Screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Display the SplashScreen from splash_screen.dart
    return const SplashScreen(); // Use the imported SplashScreen widget
  }
}

// The original MyHomePage is kept but not used in the initial flow
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
