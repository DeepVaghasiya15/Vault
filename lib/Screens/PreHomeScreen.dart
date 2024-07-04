import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vault/Screens/HomePage.dart';

class PreHomeScreen extends StatefulWidget {
  const PreHomeScreen({Key? key, required String backgroundImagePath}) : super(key: key);

  @override
  _PreHomeScreenState createState() => _PreHomeScreenState();
}

class _PreHomeScreenState extends State<PreHomeScreen> {
  String? backgroundImagePath;
  List<bool> buttonStates = [false, false, false];

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

  void _onButtonPressed(int index) {
    setState(() {
      buttonStates[index] = true;
      if (buttonStates.every((state) => state)) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final buttonWidth = size.width * 0.1;
    final buttonHeight = size.height * 0.04;
    var opacity = 0.2;

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
          // Positioned invisible buttons
          Positioned(
            top: size.height * 0.1,
            left: size.width * 0.05,
            child: Opacity(
              opacity: opacity,
              child: SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () => _onButtonPressed(0),
                  child: const Text(''),
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.1,
            right: size.width * 0.05,
            child: Opacity(
              opacity: opacity,
              child: SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () => _onButtonPressed(1),
                  child: const Text(''),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.41,
            right: size.width * 0.26,
            child: Opacity(
              opacity: opacity,
              child: SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: () => _onButtonPressed(2),
                  child: const Text(''),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
