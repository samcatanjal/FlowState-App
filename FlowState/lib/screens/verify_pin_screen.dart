import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyPinScreen extends StatefulWidget {
  const VerifyPinScreen({super.key});

  @override
  _VerifyPinScreenState createState() => _VerifyPinScreenState();
}

class _VerifyPinScreenState extends State<VerifyPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _errorText;

  Future<void> _verifyPin() async {
    if (_pinController.text.isEmpty) {
      setState(() {
        _errorText = 'Please enter your PIN';
      });
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('user_pin') ?? '';

    if (_pinController.text == storedPin) {
      Navigator.pushReplacementNamed(context, '/create_new_pin');
    } else {
      setState(() {
        _errorText = 'Incorrect PIN. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify PIN')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Enter Current PIN',
                errorText: _errorText,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _verifyPin, child: const Text('Verify')),
          ],
        ),
      ),
    );
  }
}
