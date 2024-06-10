import 'package:shared_preferences/shared_preferences.dart';

class ImagePreference {
  static const _key = 'backgroundImagePath';

  static Future<void> saveImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, path);
  }

  static Future<String?> loadImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> removeImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
