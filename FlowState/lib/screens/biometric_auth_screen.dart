import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../utils/biometric_helper.dart';
import 'pin_auth_screen.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String _status = 'Initializing...';
  bool _isAuthenticating = false;
  
  late AnimationController _animationController;
  
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animationController.repeat(reverse: true);
    _authenticate();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return; // Prevent multiple calls to authenticate
    setState(() {
      _isAuthenticating = true;
    });

    // First check if biometrics are available
    bool hasBiometrics = await BiometricHelper.hasBiometrics();
    if (!hasBiometrics) {
      setState(() {
        _isLoading = false;
        _status = 'Biometric authentication not available. Please use PIN instead.';
        _isAuthenticating = false;
      });
      return;
    }

    try {
      bool authenticated = await BiometricHelper.authenticate();
      if (authenticated) {
        Vibration.vibrate(duration: 100);
        await _audioPlayer.play(AssetSource('sounds/success.mp3'));
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Vibration.vibrate(duration: 500, pattern: [0, 100, 200, 100]);
        await _audioPlayer.play(AssetSource('sounds/failure.mp3'));
        setState(() {
          _isLoading = false;
          _status = 'Authentication failed. Please try again or use PIN.';
        });
      }
    } catch (e) {
      Vibration.vibrate(duration: 500, pattern: [0, 100, 200, 100]);
      await _audioPlayer.play(AssetSource('sounds/failure.mp3'));
      setState(() {
        _isLoading = false;
        _status = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isAuthenticating = false; // Reset flag after authentication attempt
      });
    }
  }

  void _usePinInstead() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PinAuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fingerprint,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 20),
            if (_isLoading) ...[
              CircularProgressIndicator(),
              SizedBox(height: 20),
            ],
            Text(_status, textAlign: TextAlign.center),
            SizedBox(height: 20),
            if (!_isLoading)
              ElevatedButton.icon(
                icon: Icon(Icons.lock),
                label: Text('Use PIN Instead'),
                onPressed: _usePinInstead,
              ),
          ],
        ),
      ),
    );
  }
}
