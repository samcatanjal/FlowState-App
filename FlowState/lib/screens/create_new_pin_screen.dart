import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateNewPinScreen extends StatefulWidget {
  const CreateNewPinScreen({super.key});

  @override
  _CreateNewPinScreenState createState() => _CreateNewPinScreenState();
}

class _CreateNewPinScreenState extends State<CreateNewPinScreen> {
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  String? _errorText;

  Future<void> _saveNewPin() async {
    if (_newPinController.text.length != 4) {
      setState(() {
        _errorText = 'PIN must be 4 digits';
      });
      return;
    }

    if (_newPinController.text != _confirmPinController.text) {
      setState(() {
        _errorText = 'PINs do not match';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', _newPinController.text);

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New PIN')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Create a new 4-digit PIN',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: _newPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: const InputDecoration(
                labelText: 'New PIN',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              onChanged: (value) {
                if (value.length == 4) {
                  FocusScope.of(context).nextFocus();
                }
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _confirmPinController,
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: InputDecoration(
                labelText: 'Confirm PIN',
                border: const OutlineInputBorder(),
                counterText: '',
                errorText: _errorText,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveNewPin,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
              child: const Text('Save', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
