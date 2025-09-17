import 'dart:ui';
import 'package:flutter/material.dart';
import 'change_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _smartSilenceEnabled = false;

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
          Positioned(top: -40, left: -30, child: _circle(150, Colors.white.withOpacity(0.05))),
          Positioned(bottom: -50, right: -20, child: _circle(180, Colors.white.withOpacity(0.07))),
          Positioned(bottom: 100, left: 40, child: _circle(100, Colors.white.withOpacity(0.05))),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ListView(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Center(
                    child: Text(
                      "Settings",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Preferences"),
                  SwitchListTile(
                    title: const Text("Enable Notifications", style: TextStyle(color: Colors.white)),
                    value: _notificationsEnabled,
                    onChanged: (val) {
                      setState(() => _notificationsEnabled = val);
                    },
                    activeColor: Colors.cyanAccent,
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle("Security"),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final email = prefs.getString('email') ?? '';

                      if (email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Email not found. Please log in again.")),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordScreen(loggedInEmail: email),
                        ),
                      );
                    },
                    icon: const Icon(Icons.lock),
                    label: const Text("Change Password"),
                    style: _buttonStyle(),
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle("Smart Features"),
                  SwitchListTile(
                    title: const Text("Smart Silence Mode", style: TextStyle(color: Colors.white)),
                    subtitle: const Text(
                      "Automatically silence phone during class hours",
                      style: TextStyle(color: Colors.white70),
                    ),
                    value: _smartSilenceEnabled,
                    onChanged: (val) {
                      setState(() => _smartSilenceEnabled = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Smart Silence Mode ${val ? 'enabled' : 'disabled'}")),
                      );
                    },
                    activeColor: Colors.cyanAccent,
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle("About App"),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.white),
                    title: const Text("App Version", style: TextStyle(color: Colors.white)),
                    subtitle: const Text("v1.0.0+1", style: TextStyle(color: Colors.white70)),
                  ),
                  ListTile(
  leading: const Icon(Icons.feedback, color: Colors.cyanAccent),
  title: const Text('Send Feedback', style: TextStyle(color: Colors.white)),
  onTap: () => _showFeedbackDialog(context),
),

                  ListTile(
                    leading: const Icon(Icons.group, color: Colors.white),
                    title: const Text("About Us", style: TextStyle(color: Colors.white)),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("About Us"),
                          content: const Text("TimeMate is developed by Kumaraguru to help organize class schedules."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle("App Maintenance"),
                  ElevatedButton.icon(
                    onPressed: _confirmClearDataFlow,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text("Clear All Data"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _showFeedbackDialog(BuildContext context) {
  TextEditingController feedbackController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Send Feedback"),
        content: TextField(
          controller: feedbackController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: "Share your thoughts about the app...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: const Text("Send"),
            onPressed: () {
              String feedback = feedbackController.text.trim();
              if (feedback.isNotEmpty) {
                // TODO: Send feedback to Firebase later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Thank you for your feedback!")),
                );
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  void _confirmClearDataFlow() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Reset"),
        content: const Text("Are you sure you want to clear all app data?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
        ],
      ),
    );

    if (confirmed == true) {
      _promptForPassword();
    }
  }

  void _promptForPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('password') ?? '';

    final TextEditingController passwordController = TextEditingController();

    final verified = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Enter Password"),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "Password",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (passwordController.text.trim() == savedPassword) {
                Navigator.pop(context, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Incorrect password")),
                );
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );

    if (verified == true) {
      await prefs.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All user data and settings have been reset.")),
      );
    }
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white70),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
