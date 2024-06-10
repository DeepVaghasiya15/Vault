import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vault/Screens/HomePage.dart';
import '../State/StoringWallpaper.dart';

class PreHomeScreen extends StatefulWidget {
  const PreHomeScreen({Key? key, required String backgroundImagePath}) : super(key: key);

  @override
  _PreHomeScreenState createState() => _PreHomeScreenState();
}

class _PreHomeScreenState extends State<PreHomeScreen> {
  String? backgroundImagePath;

  @override
  void initState() {
    super.initState();
    _loadImagePath();
  }

  Future<void> _loadImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('selected_image_path');
    setState(() {
      backgroundImagePath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen image
          Positioned.fill(
            child: backgroundImagePath != null
                ? Image.file(
              File(backgroundImagePath!),
              fit: BoxFit.cover,
            )
                : Image.asset(
              'assets/images/Homescreen.jpg', // default image path
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
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
