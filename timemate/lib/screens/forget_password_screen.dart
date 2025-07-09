import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _animation;

  String? _generatedOtp;
  Timer? _otpTimer;
  bool _otpSent = false;
  bool _otpVerified = false;
  String? _errorMessage;
  int _otpCountdown = 60;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack);
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _otpTimer?.cancel();
    super.dispose();
  }

  void _sendOtp() {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = "Please enter a valid email.");
      return;
    }

    setState(() {
      _errorMessage = null;
      _generatedOtp = (100000 + Random().nextInt(900000)).toString();
      _otpSent = true;
      _otpVerified = false;
      _otpCountdown = 60;
    });

    _otpTimer?.cancel();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_otpCountdown > 0) {
          _otpCountdown--;
        } else {
          _generatedOtp = null;
          _otpSent = false;
          timer.cancel();
        }
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("OTP sent to $email: $_generatedOtp")),
    );
  }

  void _verifyOtpAndChangePassword() {
    final enteredOtp = _otpController.text.trim();
    final newPassword = _newPasswordController.text;

    if (_generatedOtp == null) {
      setState(() => _errorMessage = "OTP expired. Please resend.");
    } else if (enteredOtp != _generatedOtp) {
      setState(() => _errorMessage = "Invalid OTP.");
    } else if (newPassword.length < 6) {
      setState(() => _errorMessage = "Password must be at least 6 characters.");
    } else {
      setState(() {
        _errorMessage = null;
        _otpVerified = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully.")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),

          SafeArea(
            child: Column(
              children: [
                // Back Button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: ScaleTransition(
                      scale: _animation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              'assets/animations/resetpass.json',
                              width: MediaQuery.of(context).size.width * 0.5,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "Reset Password",
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Enter your email, verify with OTP, and set a new password.",
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            TextField(
                              controller: _emailController,
                              enabled: !_otpSent,
                              style: const TextStyle(color: Colors.white),
                              decoration: _buildInputDecoration("Email"),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            if (_otpSent) ...[
                              TextField(
                                controller: _otpController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration("Enter OTP"),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _newPasswordController,
                                style: const TextStyle(color: Colors.white),
                                decoration: _buildInputDecoration("New Password"),
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                            ],

                            if (_errorMessage != null) ...[
                              Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                              const SizedBox(height: 16),
                            ],

                            if (_otpSent && _otpCountdown > 0)
                              Text("OTP expires in $_otpCountdown seconds", style: const TextStyle(color: Colors.white70)),

                            const SizedBox(height: 24),

                            ElevatedButton.icon(
                              onPressed: _otpSent ? _verifyOtpAndChangePassword : _sendOtp,
                              icon: Icon(_otpSent ? Icons.check : Icons.send, color: Colors.black),
                              label: Text(
                                _otpSent ? "Verify & Change Password" : "Send OTP",
                                style: const TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                            ),

                            if (_otpSent && _otpCountdown <= 0)
                              TextButton(
                                onPressed: _sendOtp,
                                child: const Text("Resend OTP", style: TextStyle(color: Colors.cyanAccent)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
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
      ],
    );
  }

  Widget _decorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
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
    );
  }
}
// This code defines a Forget Password screen with OTP verification and password reset functionality.