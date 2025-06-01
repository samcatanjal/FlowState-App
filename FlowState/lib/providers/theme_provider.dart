import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = const Color(0xFFFF9800); // Default orange
  int _vibrationDuration = 10;
  late SharedPreferences _prefs;

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  Color get backgroundColor => _isDarkMode ? Colors.grey[900]! : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : Colors.black;
  int get vibrationDuration => _vibrationDuration;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    _primaryColor = Color(_prefs.getInt('primaryColor') ?? 0xFFFF9800);
    _vibrationDuration = _prefs.getInt('vibrationDuration') ?? 10;
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    await _prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    await _prefs.setInt('primaryColor', color.toARGB32());
    notifyListeners();
  }

  Future<void> resetToDefault() async {
    _primaryColor = const Color(0xFFFF9800);
    await _prefs.setInt('primaryColor', 0xFFFF9800);
    notifyListeners();
  }

  void setVibrationDuration(int duration) {
    _vibrationDuration = duration.clamp(0, 100);
    _prefs.setInt('vibrationDuration', _vibrationDuration).then((_) => notifyListeners());
  }

  ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      primaryColorLight: primaryColor.withAlpha(128),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          return states.contains(WidgetState.selected) 
            ? primaryColor 
            : Colors.grey;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          return states.contains(WidgetState.selected) 
            ? primaryColor 
            : Colors.grey;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          return states.contains(WidgetState.selected) 
            ? primaryColor 
            : Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          return states.contains(WidgetState.selected) 
            ? primaryColor.withAlpha(128) 
            : Colors.grey;
        }),
      ),
    );
  }

  ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
  
    return baseTheme.copyWith(
      colorScheme: ColorScheme.dark(
        primary: Colors.white,
        onPrimary: Colors.black,
        secondary: Colors.blueAccent,
        onSecondary: Colors.white,
        surface: Colors.black,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        color: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(color: Colors.white),
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Colors.black,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.grey[900],
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.blueAccent;
          }
          return Colors.grey;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.blueAccent;
          }
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.blueAccent.withAlpha(128);
          }
          return Colors.grey;
        }),
      ),
    );
  }
}
