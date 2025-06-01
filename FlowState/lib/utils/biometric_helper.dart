import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      bool canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } on PlatformException catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to access your tasks',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      print('Authentication failed: ${e.message}');
      if (e.code == 'NotAvailable' || e.code == 'PasscodeNotSet' || e.code == 'NoBiometricEnrolled') {
        throw Exception('Biometric authentication not set up. Please configure it in your device settings.');
      } else if (e.code == 'LockedOut') {
        throw Exception('Too many failed attempts. Biometric authentication is temporarily disabled.');
      } else {
        throw Exception('Authentication failed: ${e.message}');
      }
    }
  }
}
