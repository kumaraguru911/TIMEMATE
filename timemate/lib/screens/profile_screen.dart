import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedDepartment = "No Department";
  ImageProvider _profileImage = const AssetImage('assets/profile.png');
  String? _profilePicUrl;

  // Store original values
  late String _originalName;
  late String _originalEmail;
  late String _originalPhone;
  late String _originalDepartment;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isLoading = true;

  List<String> _departments = [
    "No Department",
    "AI & DS",
    "CSE",
    "ECE",
    "MECH",
    "IT",
    "CIVIL",
    "EEE",
  ];

  Map<String, String> _roleAssignments = {
    "1st Year": "CT",
    "2nd Year": "HS",
    "3rd Year": "Not Assigned",
    "4th Year": "Not Assigned",
  };

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack);
    _animationController.forward();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    setState(() => _isLoading = true);
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
  // Ensure the selected department matches one of the dropdown values, else default
  final dept = data['department'] ?? 'No Department';
  _selectedDepartment = _departments.contains(dept) ? dept : 'No Department';
        _profilePicUrl = data['profilePic'] ?? '';
        if (_profilePicUrl != null && _profilePicUrl!.isNotEmpty) {
          _profileImage = NetworkImage(_profilePicUrl!);
        }
        // Store original values
        _originalName = _nameController.text;
        _originalEmail = _emailController.text;
        _originalPhone = _phoneController.text;
        _originalDepartment = _selectedDepartment;
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  // ...existing code...

  void _toggleEditing() {
    setState(() => _isEditing = !_isEditing);
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _nameController.text = _originalName;
      _emailController.text = _originalEmail;
      _phoneController.text = _originalPhone;
      _selectedDepartment = _originalDepartment;
    });
  }

  void _saveProfile() {
    setState(() {
      _isEditing = false;
      _originalName = _nameController.text;
      _originalEmail = _emailController.text;
      _originalPhone = _phoneController.text;
      _originalDepartment = _selectedDepartment;
    });
    final user = _auth.currentUser;
    if (user != null) {
      _firestore.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'department': _selectedDepartment,
        'profilePic': _profilePicUrl ?? '',
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully!")),
    );
  }

  Future<void> _pickProfileImage() async {
    if (!_isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tap Edit to change your profile image.")),
      );
      return;
    }
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final user = _auth.currentUser;
        if (user != null) {
          final ref = _storage.ref().child('users/${user.uid}/profile.jpg');
          await ref.putFile(File(picked.path));
          final url = await ref.getDownloadURL();
          setState(() {
            _profileImage = NetworkImage(url);
            _profilePicUrl = url;
          });
          // Update Firestore with new profilePic URL
          await _firestore.collection('users').doc(user.uid).update({'profilePic': url});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile image updated!")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking image: $e")),
      );
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2B5876), Color(0xFF4E4376)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Decorative blurred circles
          Positioned(top: -50, left: -50, child: _decorativeCircle(150, Colors.white.withOpacity(0.05))),
          Positioned(bottom: -50, right: -30, child: _decorativeCircle(200, Colors.white.withOpacity(0.08))),
          Positioned(bottom: 100, left: 40, child: _decorativeCircle(100, Colors.white.withOpacity(0.05))),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (!_isLoading)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SingleChildScrollView(
                  child: ScaleTransition(
                    scale: _animation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        GestureDetector(
                          onTap: _pickProfileImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: _profileImage,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "${_getGreeting()}, ${_nameController.text}!",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildTextField("Full Name", _nameController),
                        const SizedBox(height: 16),
                        _buildTextField("Email Address", _emailController),
                        const SizedBox(height: 16),
                        _buildTextField("Phone Number", _phoneController),
                        const SizedBox(height: 16),
                        _buildDropdownField("Department"),
                        const SizedBox(height: 24),
                        // Role Info Section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Your Roles:",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              ..._roleAssignments.entries.map((entry) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  "• ${entry.key} - ${entry.value}",
                                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                                ),
                              )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isEditing ? _saveProfile : _toggleEditing,
                              icon: Icon(_isEditing ? Icons.save : Icons.edit),
                              label: Text(_isEditing ? "Save" : "Edit"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                            ),
                            if (_isEditing)
                              ElevatedButton.icon(
                                onPressed: _cancelEditing,
                                icon: const Icon(Icons.cancel),
                                label: const Text("Cancel"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                            if (!_isEditing)
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await _auth.signOut();
                                  if (mounted) {
                                    Navigator.pushReplacementNamed(context, '/login');
                                  }
                                },
                                icon: const Icon(Icons.logout),
                                label: const Text("Logout"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                          ],
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

  Widget _buildTextField(String label, TextEditingController controller) => TextField(
        controller: controller,
        enabled: _isEditing,
        style: const TextStyle(color: Colors.white),
        decoration: _buildInputDecoration(label),
        cursorColor: Colors.white,
      );

  Widget _buildDropdownField(String label) => IgnorePointer(
        ignoring: !_isEditing,
        child: DropdownButtonFormField<String>(
          value: _selectedDepartment,
          items: _departments.map((dept) {
            return DropdownMenuItem<String>(
              value: dept,
              child: Text(dept, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: _isEditing
              ? (value) => setState(() => _selectedDepartment = value!)
              : null,
          decoration: _buildInputDecoration(label),
          dropdownColor: const Color(0xFF1A1A2E),
          style: const TextStyle(color: Colors.white),
        ),
      );

  InputDecoration _buildInputDecoration(String label) => InputDecoration(
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