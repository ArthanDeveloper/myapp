import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:myapp/splash_screen.dart'; // Import the actual splash screen widget
import 'package:myapp/onboarding_screen.dart'; // Import the first onboarding screen
import 'package:myapp/login_page.dart'; // Import the login page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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

      if (onboardingVisited) {
        // If onboarding has been visited, navigate to Login Page
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
      } else {
        // If onboarding has not been visited, navigate to the first Onboarding Screen
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
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
