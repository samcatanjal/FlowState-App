import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _pinKey = 'pin';

  static Future<void> savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinKey, pin);
  }

  static Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pinKey);
  }
}
