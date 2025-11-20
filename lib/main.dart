import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

// Import the HomePage from home.dart
import 'home.dart';
import 'shared.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Income Tax Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
  
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _buttonScaleAnimation;
  late Animation<Offset> _fieldSlideAnimation;

  bool _isHovered = false;

  late String selectedYear;
  final List<String> yearOptions = [
    '2024-25',
    '2025-26',
    '2026-27',
    '2027-28',
  ];


  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username.isEmpty) {
      _showErrorDialog('Please enter the username.');
      return;
    }

    try {
      final databaseRef = FirebaseDatabase.instance.ref();
      final userRef = databaseRef.child('$selectedYear/$username').child(username); // Correct child path
      final dataSnapshot = await userRef.get();

      if (dataSnapshot.exists) {
        Map<String, dynamic> userMap = Map<String, dynamic>.from(dataSnapshot.value as Map);
        String? storedPassword = userMap['password'];
        String storedZone = userMap['zone'];
        if (storedPassword == password) {
          sharedData.userPlace = '$selectedYear/$username';
          sharedData.ccurrentYear = selectedYear;
          sharedData.zone = storedZone;
          if(mounted){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }
        } else {
          _showErrorDialog('Wrong username or password.');
        }
      } else {
        _showErrorDialog('User not found.');
      }
    } catch (e) {
      _showErrorDialog('An error occured : $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showForgetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Forget Password'),
          content: const Text(
              'Reply to itaxcalculator8@gmail.com for resetting the password.\n\n1) Include your username in the email.\n2) Password reset may take 24-48 hours.\n3) False requests will be denied.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    int currentYear = now.year;
    int startYear = now.month >= 3 ? currentYear : currentYear - 1;
    selectedYear = '$startYear-${(startYear + 1).toString().substring(2)}';

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _buttonScaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fieldSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    // Define a max width for the inputs and buttons
    double maxWidth = 500; // Maximum width for the form content
    double padding = 16.0; // Standard padding
    double fontSize = screenWidth > 1200 ? 30 : 25;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Tax Calculator', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blueAccent.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth), // Limiting width
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        'Welcome to Income Tax Calculator',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800, // Blue text color
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Username TextField with scale and slide animation
                  SlideTransition(
                    position: _fieldSlideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: DropdownButton<String>(
                        value: selectedYear,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedYear = newValue!;
                          });
                        },
                        items: yearOptions.map<DropdownMenuItem<String>>((String year) {
                          return DropdownMenuItem<String>(
                            value: year,
                            child: Text(
                              year,
                              style: TextStyle(
                                fontSize: fontSize - 5,
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SlideTransition(
                    position: _fieldSlideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildInputField(
                        label: 'Username',
                        controller: _usernameController,
                        obscureText: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Password TextField with scale and slide animation
                  SlideTransition(
                    position: _fieldSlideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildInputField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        toggleVisibility: _togglePasswordVisibility,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Login Button with scale and hover animation
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _isHovered = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        _isHovered = false;
                      });
                    },
                    child: ScaleTransition(
                      scale: _buttonScaleAnimation,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isHovered ? Colors.blue.shade700 : Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                          shadowColor: Colors.black.withValues(alpha: 0.3),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.login,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: TextButton(
                      onPressed: _showForgetPasswordDialog,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build input fields
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.blue),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        suffixIcon: toggleVisibility != null
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.blue.shade600,
          ),
          onPressed: toggleVisibility,
        )
            : null,
      ),
    );
  }
}
