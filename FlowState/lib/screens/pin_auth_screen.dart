import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_layout.dart';

class PinAuthScreen extends StatefulWidget {
  const PinAuthScreen({super.key});

  @override
  _PinAuthScreenState createState() => _PinAuthScreenState();
}

class _PinAuthScreenState extends State<PinAuthScreen>
    with TickerProviderStateMixin {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isLoading = false;
  bool _isNewUser = false;

  late AnimationController _pinFieldAnimationController;
  late Animation<double> _pinFieldAnimation;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeLogin();

    _pinFieldAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pinFieldAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pinFieldAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _pinFieldAnimationController.forward();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    _pinFieldAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkFirstTimeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('user_pin') ?? '';
    if (storedPin.isEmpty) {
      setState(() => _isNewUser = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.only(bottom: 40),
                  child: const Icon(
                    Icons.lock,
                    size: 100,
                    color: Colors.orange,
                  ),
                ),
                FadeTransition(
                  opacity: _pinFieldAnimation,
                  child: Text(
                    _isNewUser
                        ? 'Welcome! Create your PIN'
                        : 'Enter your PIN to continue',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _pinFieldAnimation,
                  child: Text(
                    _isNewUser
                        ? 'Please create a PIN for your privacy'
                        : 'Enter your PIN to access tasks',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                _buildPinInput(),
                if (_isNewUser) ...[
                  const SizedBox(height: 12),
                  _buildConfirmPinInput(),
                ],
                const SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinInput() {
    return AnimatedBuilder(
      animation: _pinFieldAnimation,
      builder:
          (context, child) => Opacity(
            opacity: _pinFieldAnimation.value,
            child: TextFormField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: '****',
                contentPadding: EdgeInsets.symmetric(vertical: 18),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildConfirmPinInput() {
    return AnimatedBuilder(
      animation: _pinFieldAnimation,
      builder:
          (context, child) => Opacity(
            opacity: _pinFieldAnimation.value,
            child: TextFormField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Confirm PIN',
                contentPadding: EdgeInsets.symmetric(vertical: 18),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedScale(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      scale: _isLoading ? 0.95 : 1.0,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePinSubmission,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  _isNewUser ? 'Create PIN' : 'Submit',
                  style: const TextStyle(fontSize: 18),
                ),
      ),
    );
  }

  Future<void> _handlePinSubmission() async {
    setState(() => _isLoading = true);

    if (_isNewUser) {
      if (_pinController.text != _confirmPinController.text) {
        _showError('PINs do not match!');
        return;
      }
      if (_pinController.text.length != 4) {
        _showError('PIN must be 4 digits');
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_pin', _pinController.text);

      // Show success message before navigating
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PIN created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Add a delay before navigating
        await Future.delayed(const Duration(seconds: 2));
      }

      _navigateToMainLayout();
    } else {
      final prefs = await SharedPreferences.getInstance();
      final storedPin = prefs.getString('user_pin') ?? '';
      if (storedPin == _pinController.text) {
        _navigateToMainLayout();
      } else {
        _showError('Incorrect PIN!');
      }
    }
  }

  void _showError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _navigateToMainLayout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainLayout()),
    );
  }
}
