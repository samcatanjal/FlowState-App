import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/theme_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/pin_auth_screen.dart';
import 'screens/biometric_auth_screen.dart';
import 'screens/main_layout.dart';
import 'screens/create_new_pin_screen.dart';
import 'screens/verify_pin_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProfileProvider()..loadProfile(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'FlowState',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: themeProvider.primaryColor,
          secondary: themeProvider.primaryColor.withAlpha(128),
        ),
        scaffoldBackgroundColor: themeProvider.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: themeProvider.primaryColor,
          titleTextStyle: TextStyle(
            color: themeProvider.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: themeProvider.textColor),
          bodyMedium: TextStyle(color: themeProvider.textColor),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: themeProvider.primaryColor,
          secondary: themeProvider.primaryColor.withAlpha(128),
        ),
        scaffoldBackgroundColor: themeProvider.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: themeProvider.primaryColor,
          titleTextStyle: TextStyle(
            color: themeProvider.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: themeProvider.textColor),
          bodyMedium: TextStyle(color: themeProvider.textColor),
        ),
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AuthWrapper(),
      routes: {
        '/pin': (context) => const PinAuthScreen(),
        '/biometric': (context) => const BiometricAuthScreen(),
        '/main': (context) => const MainLayout(),
        '/verify_pin': (context) => const VerifyPinScreen(),
        '/create_new_pin': (context) => const CreateNewPinScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final prefs = snapshot.data!;
        final useBiometric = prefs.getBool('use_biometric') ?? false;
        final hasPin = prefs.getString('user_pin') != null;

        // Always require unlock on launch
        if (useBiometric && hasPin) {
          return const BiometricAuthScreen();
        } else {
          return const PinAuthScreen();
        }
      },
    );
  }
}
