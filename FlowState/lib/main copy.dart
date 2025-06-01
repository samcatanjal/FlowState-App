import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outstanding To Do List',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(bodyLarge: TextStyle(color: Colors.black)),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange, width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
      home: PinAuthScreen(),
    );
  }
}

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
      duration: Duration(milliseconds: 500),
    );
    _pinFieldAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pinFieldAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _pinFieldAnimationController.forward();
  }

  // Check if this is the first time the user is logging in
  Future<void> _checkFirstTimeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final storedPin = prefs.getString('pin');
    if (storedPin == null) {
      setState(() {
        _isNewUser = true; // User is new and needs to set up a PIN
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Section with animated effect
              AnimatedContainer(
                duration: Duration(seconds: 1),
                curve: Curves.easeOut,
                margin: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.lock, size: 100, color: Colors.orange),
              ),
              // Welcome text
              FadeTransition(
                opacity: _pinFieldAnimation,
                child: Text(
                  _isNewUser
                      ? 'Welcome! Create your PIN'
                      : 'Enter your PIN to continue',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Instructions text
              FadeTransition(
                opacity: _pinFieldAnimation,
                child: Text(
                  _isNewUser
                      ? 'Please create a PIN for your privacy'
                      : 'Enter your PIN to access tasks',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              SizedBox(height: 40),
              // PIN Input Fields
              AnimatedBuilder(
                animation: _pinFieldAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _pinFieldAnimation.value,
                    child: TextFormField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '****',
                        contentPadding: EdgeInsets.symmetric(vertical: 18),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_isNewUser) ...[
                SizedBox(height: 12),
                // Confirm PIN field for new users
                AnimatedBuilder(
                  animation: _pinFieldAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _pinFieldAnimation.value,
                      child: TextFormField(
                        controller: _confirmPinController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '****',
                          contentPadding: EdgeInsets.symmetric(vertical: 18),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
              SizedBox(height: 24),
              // Submit Button with Animation
              AnimatedScale(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                scale: _isLoading ? 0.95 : 1.0,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePinSubmission,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.orange,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child:
                      _isLoading
                          ? CircularProgressIndicator()
                          : Text(
                            _isNewUser ? 'Create PIN' : 'Submit',
                            style: TextStyle(fontSize: 18),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handle PIN submission for both new and existing users
  Future<void> _handlePinSubmission() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();

    if (_isNewUser) {
      // For new users, validate if both PINs match
      if (_pinController.text != _confirmPinController.text) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PINs do not match!')));
      } else {
        await prefs.setString('pin', _pinController.text);
        setState(() {
          _isLoading = false;
        });
        _showSuccessDialog();
      }
    } else {
      // For existing users, validate the entered PIN
      final storedPin = prefs.getString('pin');
      if (storedPin == _pinController.text) {
        _navigateToTaskList();
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Incorrect PIN')));
      }
    }
  }

  // Show success message when PIN is created successfully
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: AnimatedScale(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            scale: 1.0,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 50),
                  SizedBox(height: 12),
                  Text(
                    'PIN Created Successfully',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Your PIN has been created successfully. Please use this PIN for future logins.',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToTaskList();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Navigate to the task list screen after successful login or PIN creation
  void _navigateToTaskList() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => TaskListScreen()),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Tasks'),
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: AlwaysStoppedAnimation(1.0),
              child: Text(
                'To-Do List',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  TaskCategoryWidget(categoryName: 'Personal', taskCount: 5),
                  TaskCategoryWidget(categoryName: 'Work', taskCount: 3),
                  TaskCategoryWidget(categoryName: 'Shopping', taskCount: 7),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                  onPressed: () {
                    // Implement task creation
                  },
                  backgroundColor: Colors.orange,
                  child: Icon(Icons.add, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCategoryWidget extends StatelessWidget {
  final String categoryName;
  final int taskCount;

  const TaskCategoryWidget({
    super.key,
    required this.categoryName,
    required this.taskCount,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Implement category navigation
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.category, size: 32, color: Colors.orange),
            SizedBox(width: 16),
            Text(
              categoryName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            Spacer(),
            Text('$taskCount Tasks', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
