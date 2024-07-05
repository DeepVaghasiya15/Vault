import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault/Screens/AuthScreen.dart';
import 'package:vault/Screens/CameraScreen.dart';
import 'package:vault/Screens/DataScreen.dart';
import 'package:vault/Screens/SettingScreen.dart';
import 'package:vault/Themes/light_theme.dart';
import 'Screens/UserDataScreen.dart';
import 'State/AppState.dart';
import 'Screens/HomePage.dart';
import 'UserAuthentication/LogIn.dart';
import 'UserAuthentication/SignUp.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Vault',
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        navigatorObservers: [routeObserver],
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/AuthScreen': (context) => AuthScreen(),
          '/HomePage': (context) => HomePage(),
          '/SettingScreen': (context) => SettingScreen(),
          '/CameraScreen': (context) => CameraScreen(),
          '/UserDataScreen': (context) => UserDataScreen(),
          '/DataScreen': (context) => DataScreen()
        },
      ),
    ),
  );
}

