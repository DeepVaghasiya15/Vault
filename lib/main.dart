import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault/Screens/CameraScreen.dart';
import 'package:vault/Screens/SettingScreen.dart';
import 'package:vault/Themes/light_theme.dart';
import 'State/AppState.dart';
import 'Screens/HomePage.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vault',
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
      theme: lightMode,
      routes: {
        '/HomePage':(context) => HomePage(),
        '/SettingScreen':(context) => SettingScreen(),
        '/CameraScreen':(context) => CameraScreen(),
      },
    );
  }
}