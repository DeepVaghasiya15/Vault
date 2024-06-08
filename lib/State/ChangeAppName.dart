import 'package:flutter/services.dart';

class AppNameChannel {
  static const MethodChannel _channel = MethodChannel('app_name_channel');

  static Future<void> changeAppName(String newName) async {
    try {
      await _channel.invokeMethod('changeAppName', {'newName': newName});
    } on PlatformException catch (e) {
      print("Failed to change app name: '${e.message}'.");
    }
  }
}
