import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String loggedInEmail;

  const ChangePasswordScreen({super.key, required this.loggedInEmail});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  bool _otpSent = false;
  bool _otpVerified = false;
  String _sentOtp = "";
  bool _isOtpExpired = false;
  Timer? _otpTimer;

  String? _emailError;
  String? _otpError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.loggedInEmail; // ✅ Moved here from _sendOtp
  }

  bool _isValidEmail(String email) {
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$").hasMatch(email);
  }

  void _sendOtp() {
    final email = _emailController.text.trim();

    if (!_isValidEmail(email)) {
      setState(() => _emailError = "Please enter a valid email address");
      return;
    }

    setState(() {
      _sentOtp = "123456"; // Simulated OTP
      _otpSent = true;
      _isOtpExpired = false;
      _otpError = null;
      _emailError = null;
    });

    _otpTimer?.cancel();
    _otpTimer = Timer(const Duration(minutes: 2), () {
      setState(() => _isOtpExpired = true);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP sent to your email.")),
    );
  }

  void _verifyOtp() {
    if (_isOtpExpired) {
      setState(() => _otpError = "OTP expired. Please resend.");
      return;
    }

    if (_otpController.text.trim() != _sentOtp) {
      setState(() => _otpError = "Invalid OTP. Please try again.");
      return;
    }

    setState(() {
      _otpVerified = true;
      _otpError = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("OTP Verified")),
    );
  }

  void _changePassword() {
    final newPass = _newPasswordController.text.trim();

    if (newPass.isEmpty) {
      setState(() => _passwordError = "Please enter a new password");
      return;
    }

    setState(() => _passwordError = null);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password changed successfully.")),
    );
    Navigator.pop(context);
  }

  void _resendOtp() {
    setState(() => _isOtpExpired = false);
    _sendOtp();
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
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
          Positioned(top: -50, left: -40, child: _circle(140, Colors.white.withOpacity(0.05))),
          Positioned(bottom: -40, right: -30, child: _circle(180, Colors.white.withOpacity(0.08))),
          Positioned(bottom: 80, left: 50, child: _circle(100, Colors.white.withOpacity(0.05))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Change Password",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _buildInput("Email", _emailController, errorText: _emailError, enabled: !_otpSent),
                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: !_otpSent ? _sendOtp : null,
                    style: _buttonStyle(),
                    child: const Text("Send OTP"),
                  ),

                  if (_otpSent) ...[
                    const SizedBox(height: 16),
                    _buildInput("Enter OTP", _otpController, errorText: _otpError),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _verifyOtp,
                          style: _buttonStyle(),
                          child: const Text("Verify OTP"),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: _resendOtp,
                          child: const Text("Resend OTP", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],

                  if (_otpVerified) ...[
                    const SizedBox(height: 24),
                    _buildInput("New Password", _newPasswordController,
                        isPassword: true, errorText: _passwordError),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _changePassword,
                      style: _buttonStyle(),
                      icon: const Icon(Icons.lock),
                      label: const Text("Change Password"),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller,
      {bool enabled = true, bool isPassword = false, String? errorText}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        errorText: errorText,
        errorStyle: const TextStyle(color: Colors.redAccent),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
      cursorColor: Colors.white,
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
// This code defines a Change Password screen with OTP verification and password change functionality.
// It includes fields for email, OTP, and new password, with validation and error handling.