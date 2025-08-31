import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaffDatabaseScreen extends StatefulWidget {
  const StaffDatabaseScreen({super.key});

  @override
  State<StaffDatabaseScreen> createState() => _StaffDatabaseScreenState();
}

class _StaffDatabaseScreenState extends State<StaffDatabaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _dept = TextEditingController();
  final _subjects = TextEditingController();

  List<Map<String, dynamic>> staffList = [];

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('staff_database');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      setState(() {
        staffList = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> _saveStaff() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('staff_database', jsonEncode(staffList));
  }

  void _addStaff() {
    if (!_formKey.currentState!.validate()) return;
    final subjects = _subjects.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    setState(() {
      staffList.add({
        "name": _name.text.trim(),
        "dept": _dept.text.trim(),
        "subjects": subjects,
      });
      _name.clear();
      _dept.clear();
      _subjects.clear();
    });
    _saveStaff();
  }

  void _deleteStaff(int i) {
    setState(() {
      staffList.removeAt(i);
    });
    _saveStaff();
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button + title
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Staff Database",
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Add Staff",
                      style: TextStyle(fontSize: 22, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),

                    // Form card
                    Card(
                      color: Colors.white.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(_name, "Staff Name"),
                              const SizedBox(height: 12),
                              _buildTextField(_dept, "Department"),
                              const SizedBox(height: 12),
                              _buildTextField(
                                  _subjects, "Subjects (comma separated)"),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _addStaff,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyanAccent,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text("Save Staff"),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Saved Staffs",
                      style: TextStyle(fontSize: 22, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),

                    // Staff list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: staffList.length,
                      itemBuilder: (_, i) {
                        final s = staffList[i];
                        return Card(
                          color: Colors.white.withOpacity(0.08),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            leading: const Icon(Icons.person,
                                color: Colors.cyanAccent, size: 32),
                            title: Text(
                              s['name'],
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                            subtitle: Text(
                              "Dept: ${s['dept']} | Subjects: ${(s['subjects'] as List).join(', ')}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.redAccent),
                              onPressed: () => _deleteStaff(i),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent),
        ),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }
}
