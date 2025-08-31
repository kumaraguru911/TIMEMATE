import 'package:flutter/material.dart';
import 'verify_subjects_screen.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _year = TextEditingController();
  final _dept = TextEditingController();
  final _section = TextEditingController();

  final _subject = TextEditingController();
  final _credits = TextEditingController();
  final _special = TextEditingController();

  final List<Map<String, dynamic>> subjects = [];

  void _addSubject() {
    if (_subject.text.trim().isEmpty || _credits.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter subject and credits')),
      );
      return;
    }
    setState(() {
      subjects.add({
        "subject": _subject.text.trim(),
        "credits": int.tryParse(_credits.text.trim()) ?? 1,
        "special": _special.text.trim().isEmpty ? "None" : _special.text.trim(),
      });
      _subject.clear();
      _credits.clear();
      _special.clear();
    });
  }

  void _goVerify() {
    if (_year.text.trim().isEmpty || _dept.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter Year and Department')),
      );
      return;
    }
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one subject')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerifySubjectsScreen(
          year: _year.text.trim(),
          department: _dept.text.trim(),
          section: _section.text.trim(),
          subjectsList: subjects,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.cyanAccent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Gradient background applied to full body
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // ✅ Back button visible
        title: const Text("Create Class",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2B5876), Color(0xFF4E4376)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight, // ✅ No empty white gap
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),

                          // Class Info Card
                          Card(
                            color: Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildInputField(
                                      controller: _year, label: "Year"),
                                  const SizedBox(height: 12),
                                  _buildInputField(
                                      controller: _dept, label: "Department"),
                                  const SizedBox(height: 12),
                                  _buildInputField(
                                      controller: _section,
                                      label: "Section (Optional)"),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Add Subjects Card
                          Card(
                            color: Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Add Subjects",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInputField(
                                      controller: _subject,
                                      label: "Subject Name"),
                                  const SizedBox(height: 12),
                                  _buildInputField(
                                      controller: _credits,
                                      label: "Credits",
                                      type: TextInputType.number),
                                  const SizedBox(height: 12),
                                  _buildInputField(
                                      controller: _special,
                                      label: "Special Class / Lab"),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _addSubject,
                                      icon: const Icon(Icons.add),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.cyanAccent,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                      ),
                                      label: const Text("Add Subject"),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Display Added Subjects
                          if (subjects.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Subjects Added",
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                ...subjects.map(
                                  (s) => Card(
                                    color: Colors.white12,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: ListTile(
                                      title: Text("${s['subject']}",
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      subtitle: Text(
                                          "Credits: ${s['credits']} | Special: ${s['special']}",
                                          style: const TextStyle(
                                              color: Colors.white70)),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.redAccent),
                                        onPressed: () {
                                          setState(() {
                                            subjects.remove(s);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          const Spacer(), // ✅ Push button to bottom

                          // Verify Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _goVerify,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyanAccent,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Verify Subjects",
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
