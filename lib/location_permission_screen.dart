import 'package:flutter/material.dart';
import 'package:location/location.dart'; // Import the location package
import 'package:myapp/search_pan_screen.dart'; // Import the SearchPANScreen

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  _LocationPermissionScreenState createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  Location location = Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission(); // Check permission status when the screen initializes
  }

  Future<void> _checkLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      // No need to request again here, it will be requested on button press
      setState(() {}); // Update UI if needed based on initial status
    } else if (_permissionGranted == PermissionStatus.granted) {
       // If already granted, navigate directly (optional, depends on UX flow)
       // Currently, the navigation is tied to the button click for explicit user action.
    }
  }

  Future<void> _requestLocationPermissionAndNavigate() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        // User did not enable location service, stay on current screen
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        // User denied permission, stay on current screen
        return;
      }
    }

    // If service is enabled and permission is granted, navigate to SearchPANScreen
    if (_serviceEnabled && _permissionGranted == PermissionStatus.granted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SearchPANScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Replace with your app logo widget
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.flutter_dash), // Placeholder for logo
            ),
            Text('arthik', style: TextStyle(fontWeight: FontWeight.bold)), // App name
          ],
        ),
        actions: [
          // Help Icon
          IconButton(
            icon: Icon(Icons.question_mark_outlined), // Help icon
            onPressed: () {
              // TODO: Implement help action
            },
          ),
          // Progress Indicator
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
                      value: 2/5, // Represents step 2 out of 5 for location
                      strokeWidth: 3,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  Text(
                    '2/5', // Step text
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20.0), // Spacing from app bar
            Text(
              'Location',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Next: KYC',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 40.0), // Spacing
            Text(
              'Provide Your Location',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              "Can you let us know your location so we can check if you're in our service area?",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30.0),

            // Image placeholder
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/location_permission_illustration.png', // Replace with your actual image path
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 40.0),

            // Give Location Access Button
            ElevatedButton(
              onPressed: _requestLocationPermissionAndNavigate, // Call the new method
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                backgroundColor: Colors.deepOrange, // Assuming orange color from screenshot
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(8.0),
                 ),
              ),
              child: Text(
                'GIVE LOCATION ACCESS',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}