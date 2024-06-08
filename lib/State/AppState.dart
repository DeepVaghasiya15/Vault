import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String _appName = 'Vault';

  String get appName => _appName;

  void changeAppName(String newName) {
    _appName = newName;
    notifyListeners();
  }
}
