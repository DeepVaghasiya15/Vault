import 'package:flutter/material.dart';
import 'package:vault/Screens/HomePage.dart';

class PreHomeScreen extends StatelessWidget {
  const PreHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Homescreen.jpg', // replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Positioned invisible button
          Positioned(
            top: 90, // Adjust these values to position the button
            left: 20, // Adjust these values to position the button
            child: Opacity(
              opacity: 0.0, // Make the button invisible
              child: ElevatedButton(
                onPressed: () {
                  // Define the action for the button press
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
                  print('Button Pressed');
                },
                child: const Text('Press Me'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}