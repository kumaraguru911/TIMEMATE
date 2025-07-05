import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedTheme = 'Light';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile & Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/avatar_placeholder.png'),
                ),
                const SizedBox(height: 12),
                const Text(
                  "John Doe",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text("johndoe@example.com"),
                const Text("Department of Computer Science"),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to Edit Profile
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profile"),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          // Preferences Section
          SwitchListTile(
            title: const Text("Enable Notifications"),
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
            },
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text("Select Theme"),
            trailing: DropdownButton<String>(
              value: _selectedTheme,
              items: const [
                DropdownMenuItem(value: 'Light', child: Text('Light')),
                DropdownMenuItem(value: 'Dark', child: Text('Dark')),
              ],
              onChanged: (val) {
                setState(() => _selectedTheme = val ?? _selectedTheme);
              },
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to Change Password screen
            },
            icon: const Icon(Icons.lock),
            label: const Text("Change Password"),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement logout logic
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}

// This screen allows users to view and edit their profile and settings.
// It includes options to enable/disable notifications, select a theme, change password, and logout.
// The profile section displays the user's avatar, name, email, and department.
