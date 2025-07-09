import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ For saving email

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late AnimationController _controller;
  late Animation<double> _animation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _selectedDepartment;

  String? _nameError;
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _departmentError;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty ? "Please enter your name" : null;
      _usernameError = _usernameController.text.trim().isEmpty ? "Please enter a username" : null;
      _emailError = _emailController.text.trim().isEmpty || !_emailController.text.contains("@")
          ? "Please enter a valid email"
          : null;
      _passwordError = _passwordController.text.length < 6 ? "Minimum 6 characters" : null;
      _confirmPasswordError = _confirmPasswordController.text != _passwordController.text
          ? "Passwords do not match"
          : null;
      _departmentError = _selectedDepartment == null ? "Please select a department" : null;
    });

    if (_nameError == null &&
        _usernameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _departmentError == null) {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim(); // ✅

      await saveUsername(username);
      await saveEmail(email); // ✅

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registered successfully!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2B5876), Color(0xFF4E4376)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(top: -50, left: -50, child: _decorativeCircle(150, Colors.white.withOpacity(0.05))),
          Positioned(bottom: -50, right: -30, child: _decorativeCircle(200, Colors.white.withOpacity(0.08))),
          Positioned(bottom: 100, left: 40, child: _decorativeCircle(100, Colors.white.withOpacity(0.05))),
          Center(
            child: SingleChildScrollView(
              child: ScaleTransition(
                scale: _animation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(
                          height: 180,
                          child: Lottie.asset(
                            'assets/animations/login.json',
                            fit: BoxFit.contain,
                            repeat: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Create your account to start planning!",
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration("Name", _nameError),
                          cursorColor: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration("Username", _usernameError),
                          cursorColor: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration("Email", _emailError),
                          cursorColor: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration("Password", _passwordError),
                          cursorColor: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _buildInputDecoration("Confirm Password", _confirmPasswordError),
                          cursorColor: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          dropdownColor: const Color(0xFF1A1A2E),
                          value: _selectedDepartment,
                          decoration: _buildInputDecoration("Department", _departmentError),
                          iconEnabledColor: Colors.white70,
                          style: const TextStyle(color: Colors.white),
                          items: const [
                            DropdownMenuItem(value: "AI & DS", child: Text("AI & DS")),
                            DropdownMenuItem(value: "CSE", child: Text("CSE")),
                            DropdownMenuItem(value: "ECE", child: Text("ECE")),
                            DropdownMenuItem(value: "EEE", child: Text("EEE")),
                            DropdownMenuItem(value: "IT", child: Text("IT")),
                            DropdownMenuItem(value: "MECH", child: Text("MECH")),
                            DropdownMenuItem(value: "CIVIL", child: Text("CIVIL")),
                          ],
                          onChanged: (value) => setState(() => _selectedDepartment = value),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: const Text("Register", style: TextStyle(color: Colors.black, fontSize: 18)),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(color: Colors.cyanAccent, decoration: TextDecoration.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorativeCircle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  InputDecoration _buildInputDecoration(String label, String? errorText) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        errorText: errorText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      );
}

// ✅ Helper to save username
Future<void> saveUsername(String username) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', username);
}

// ✅ Helper to save email
Future<void> saveEmail(String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('email', email);
}
// This code defines a Register screen with user registration functionality.
// It includes fields for name, username, email, password, confirm password, and department selection.
// The screen uses a form with validation, and upon successful registration, it saves the username and email using SharedPreferences.
// The UI features a gradient background, decorative circles, and an animated Lottie asset for visual appeal.
// The registration button triggers validation and saves the data, while a link allows users to navigate back to the login screen if they already have an account.
// The screen is designed to be user-friendly and visually appealing, with a focus on simplicity and ease of use.
// The use of Lottie animations enhances the user experience, making the registration process more engaging.