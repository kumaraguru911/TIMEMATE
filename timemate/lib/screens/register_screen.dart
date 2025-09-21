import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // ---------------- Handle Firebase Registration ----------------
  Future<void> _handleRegister() async {
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
      try {
        setState(() => _isLoading = true);

        // Create user in Firebase Auth
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Optionally update display name in Firebase
        await _auth.currentUser?.updateDisplayName(_nameController.text.trim());

        // Save user profile to Firestore
        final user = userCredential.user;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': _nameController.text.trim(),
            'username': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'department': _selectedDepartment,
            'profilePic': '', // Default empty, can be updated later
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registered successfully!")),
        );

        if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
      } on FirebaseAuthException catch (e) {
        String errorMessage = "Registration failed. Please try again.";
        if (e.code == 'email-already-in-use') {
          errorMessage = "This email is already registered.";
        } else if (e.code == 'invalid-email') {
          errorMessage = "Invalid email address.";
        } else if (e.code == 'weak-password') {
          errorMessage = "Password is too weak.";
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
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
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Create your account to start planning!",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      _buildTextField(_nameController, "Name", _nameError),
                      const SizedBox(height: 16),
                      _buildTextField(_usernameController, "Username", _usernameError),
                      const SizedBox(height: 16),
                      _buildTextField(_emailController, "Email", _emailError),
                      const SizedBox(height: 16),
                      _buildTextField(_passwordController, "Password", _passwordError, obscureText: true),
                      const SizedBox(height: 16),
                      _buildTextField(_confirmPasswordController, "Confirm Password", _confirmPasswordError, obscureText: true),
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
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text("Register", style: TextStyle(color: Colors.black, fontSize: 18)),
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
        ],
      ),
    );
  }

  Widget _decorativeCircle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  Widget _buildTextField(TextEditingController controller, String label, String? errorText,
          {bool obscureText = false}) =>
      TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: _buildInputDecoration(label, errorText),
        cursorColor: Colors.white,
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
