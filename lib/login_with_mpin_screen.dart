import 'package:flutter/material.dart';
import 'package:myapp/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pinput.dart';

class LoginWithMpinScreen extends StatefulWidget {
  const LoginWithMpinScreen({Key? key}) : super(key: key);

  @override
  _LoginWithMpinScreenState createState() => _LoginWithMpinScreenState();
}

class _LoginWithMpinScreenState extends State<LoginWithMpinScreen> with SingleTickerProviderStateMixin {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController _mpinController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  String _customerName = 'User';
  bool _setBiometricFlag = false;
  bool _canCheckBiometrics = false;
  bool _isAuthenticatingBiometric = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkBiometricsAvailability();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
    _animationController.forward(); // Trigger the animation
  }

  @override
  void dispose() {
    _mpinController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customerName = prefs.getString('customerName') ?? 'User';
      _setBiometricFlag = prefs.getBool('setBiometric') ?? false;
    });
    _checkLoginMethodAndProceed();
  }

  Future<void> _checkBiometricsAvailability() async {
    bool canCheckBiometricsResult;
    try {
      canCheckBiometricsResult = await auth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometricsResult = false;
      print("Error checking biometrics availability: $e");
    }
    setState(() {
      _canCheckBiometrics = canCheckBiometricsResult;
    });
  }

  Future<void> _checkLoginMethodAndProceed() async {
    if (_setBiometricFlag && _canCheckBiometrics) {
      // If biometric is enabled, authenticate
      _authenticateBiometric();
    }
  }
  Future<void> _authenticateBiometric() async {
  setState(() {
       _isAuthenticatingBiometric = true; // Stop API loading function
      });
    bool authenticated = false;
    try {
     authenticated = await auth.authenticate(
        localizedReason: 'Scan to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } catch (e) {
      print("Error during biometric authentication: $e");
    }
    //Check to navigate and set to new page after biometric is loaded.
    Navigator.pushReplacement(
      context,
       MaterialPageRoute(builder: (context) => const Homepage()),
   );
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
      backgroundColor: Color(0xFFE8EAF6),  // Set background color
        appBar: AppBar(
          leading: IconButton(
          icon: Icon(Icons.menu), // Add a menu-like icon
          onPressed: () {
           Navigator.pop(context);//backpressed
           },
           ),
          title: Row(   // Add a row to change the location and implement code
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
             Icon(Icons.headset_mic), //This for the call side on a help part
               Icon(Icons.more_vert), //This is a settings or what not on the action code        ],
       ),  
       elevation: 0,
      backgroundColor: Colors.transparent,
        ),
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Spacer(),
                const Icon(
                         Icons.shield, // Replace with new icon widget as needed
                         size: 80.0,
                         color: Colors.red,
                         //Added this to a icon, so it is what code is
                       ),
                       // Text Add for what the names should be with it
                       Text(
                      'Welcome $_customerName',//Added to be part of the user prompt
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87), // Assuming size and bold style
                       ),

                Text(
                  'Please enter your MPIN',//Text in the Text Field
                  textAlign: TextAlign.center,
                ),//Text field that will show
                const SizedBox(height: 16), // Spacing between widgets
                        Pinput(
                        controller: _mpinController,
                        length: 4,
                      obscureText: true, // hide input digits, to increase auths
                      defaultPinTheme: defaultPinTheme,
                       focusedPinTheme: defaultPinTheme.copyDecorationWith(
                       border: Border.all(color: Colors.blue),
                       ),
                    // onCompleted: (pin) => _verifyOtp(), // Call verify when it all completed
                        ),
                         Align(
                    alignment: Alignment.center, // Use the correct align
                    child: TextButton(
                    onPressed: () {},
                     child: const Text('Forgot MPIN?', style: TextStyle(color: Colors.blue)),//Text at login page design
                      ),
                    ),
                  
                   const Text('OR' ,textAlign: TextAlign.center,),

               Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0), child:         ElevatedButton.icon(
                icon: Icon(Icons.fingerprint),
                label: const Text('Login with your Fingerprint', style: TextStyle(fontSize: 18)),
                onPressed: _canCheckBiometrics ? _authenticateBiometric : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[100],
                  foregroundColor: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),    ),
          ),
         
         SizedBox( height:5),//Bottom naviagte and text
             Align(
               alignment: Alignment.bottomCenter,
            child:RichText(text: TextSpan(
            text: 'Version 2.42(18220)',
               style: TextStyle(fontSize: 12, color: Colors.black54),
                  )),
                 ),
                 SizedBox( height:5),
         Row( //Bottom icon Row
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
             children: [
               IconButton(
                  icon: const Icon(Icons.lock_outline,color: Colors.black54),
                   onPressed: () {},
                ),
              IconButton(
                icon: const Icon(Icons.manage_accounts,color: Colors.black54),
                onPressed: () {},
                 ),
              IconButton(
                icon: const Icon(Icons.qr_code,color: Colors.black54),
               onPressed: () {},
              ),
              IconButton(
               icon: const Icon(Icons.credit_card,color: Colors.black54),
                   onPressed: () {},
              ),
             ],
           ),
            
                 const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
