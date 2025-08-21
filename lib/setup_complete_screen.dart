import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:myapp/login_with_mpin_screen.dart'; //Import LoginWithMPinScreen
//import 'package:myapp/login_page.dart'; //Removed original to remove this

class SetupCompleteScreen extends StatefulWidget {
  const SetupCompleteScreen({super.key});

  @override
  _SetupCompleteScreenState createState() => _SetupCompleteScreenState();
}

class _SetupCompleteScreenState extends State<SetupCompleteScreen> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3), // Animation duration
    );
    _confettiController.play(); // Play the animation on load
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Assuming white background
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti Animation Layer
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive, // Explode outwards
                shouldLoop: false, // Don't loop the animation
                colors: const [ // Customize the colors
                  Colors.green, 
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
                createParticlePath: (size) { // Customize the particle shape (optional)
                  final path = Path();
                  path.addOval(Rect.fromCircle(center: Offset.zero, radius: 15.0));
                  return path;
                },
              ),
            ),
            // Main Content Layer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Spacer(),
                  // Congratulations Message
                  const Text(
                    'Congratulations!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Setup Completion Info
                  const Text(
                    'Your account setup is complete. You can now log in to the application.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 40),

                  const Spacer(),

                  // Login Now Button
                  ElevatedButton(
                    onPressed: () { //Naviagte to login with MPIN Screen
                      // Navigate to the login with mpin page and remove all previous routes
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginWithMpinScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.deepOrange, // Consistent button style
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: const Text(
                      'Login Now',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
