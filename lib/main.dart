import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault/Screens/AuthScreen.dart';
import 'package:vault/Screens/CameraScreen.dart';
import 'package:vault/Screens/SettingScreen.dart';
import 'package:vault/Themes/light_theme.dart';
import 'Screens/UserDataScreen.dart';
import 'State/AppState.dart';
import 'Screens/HomePage.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Vault',
        debugShowCheckedModeBanner: false,
        theme: lightMode,
        navigatorObservers: [routeObserver],
        initialRoute: '/AuthScreen',
        routes: {
          '/AuthScreen': (context) => AuthScreen(),
          '/HomePage': (context) => HomePage(),
          '/SettingScreen': (context) => SettingScreen(),
          '/CameraScreen': (context) => CameraScreen(),
          '/UserDataScreen': (context) => UserDataScreen(),
        },
      ),
    ),
  );
}

