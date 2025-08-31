import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'generate_timetable_screen.dart';

class VerifySubjectsScreen extends StatefulWidget {
  final String year;
  final String department;
  final String section;
  final List<Map<String, dynamic>> subjectsList;

  const VerifySubjectsScreen({
    super.key,
    required this.year,
    required this.department,
    required this.section,
    required this.subjectsList,
  });

  @override
  State<VerifySubjectsScreen> createState() => _VerifySubjectsScreenState();
}

class _VerifySubjectsScreenState extends State<VerifySubjectsScreen> {
  List<Map<String, dynamic>> subjects = [];
  List<Map<String, dynamic>> staffList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    subjects = widget.subjectsList.map((e) => Map<String, dynamic>.from(e)).toList();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('staff_database');
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      staffList = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      staffList = [];
    }

    // Auto-assign staff if unique match
    for (var s in subjects) {
      final matching = staffList.where((st) {
        final List subs = (st['subjects'] as List?) ?? [];
        return subs.map((x) => x.toString().toLowerCase())
                   .contains(s['subject'].toString().toLowerCase());
      }).toList();

      s['staffName'] = (matching.length == 1) ? matching.first['name'] as String : null;
    }

    setState(() => loading = false);
  }

  void _editSubject(int index) {
    final subject = subjects[index];
    final subjectController = TextEditingController(text: subject['subject']);
    final creditsController = TextEditingController(text: subject['credits'].toString());
    final specialController = TextEditingController(text: subject['special']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Subject"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject Name')),
            TextField(controller: creditsController, decoration: const InputDecoration(labelText: 'Credits'), keyboardType: TextInputType.number),
            TextField(controller: specialController, decoration: const InputDecoration(labelText: 'Special Class / Lab')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              setState(() {
                subjects[index] = {
                  'subject': subjectController.text.trim(),
                  'credits': int.tryParse(creditsController.text.trim()) ?? 1,
                  'special': specialController.text.trim().isEmpty ? 'None' : specialController.text.trim(),
                  'staffName': subject['staffName'],
                };
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  bool _validateAllAssigned() {
    for (final s in subjects) {
      if ((s['staffName'] == null) || (s['staffName'].toString().trim().isEmpty)) {
        return false;
      }
    }
    return true;
  }

  void _generate() {
    if (!_validateAllAssigned()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please assign a staff for every subject')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GenerateTimetableScreen(
          year: widget.year,
          department: widget.department,
          section: widget.section,
          subjectsList: subjects,
          staffList: staffList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2B5876), Color(0xFF4E4376)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // HEADER
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Verify Subjects",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // CLASS INFO
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Year: ${widget.year}, Dept: ${widget.department}, Section: ${widget.section.isEmpty ? 'N/A' : widget.section}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),

                // SUBJECT LIST
                Expanded(
                  child: ListView.builder(
                    itemCount: subjects.length,
                    itemBuilder: (_, i) {
                      final sub = subjects[i];
                      return Card(
                        color: Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${sub['subject']} (Credits: ${sub['credits']})",
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.yellowAccent),
                                    onPressed: () => _editSubject(i),
                                  ),
                                ],
                              ),
                              Text("Special: ${sub['special']}", style: const TextStyle(color: Colors.white70)),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: sub['staffName'],
                                dropdownColor: const Color(0xFF2B5876),
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Assign Staff',
                                  labelStyle: TextStyle(color: Colors.white70),
                                ),
                                items: staffList
                                    .where((st) {
                                      final List subs = (st['subjects'] as List?) ?? [];
                                      return subs.map((x) => x.toString().toLowerCase())
                                                 .contains(sub['subject'].toString().toLowerCase());
                                    })
                                    .map<DropdownMenuItem<String>>((st) => DropdownMenuItem<String>(
                                          value: st['name'] as String,
                                          child: Text(st['name'], style: const TextStyle(color: Colors.white)),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  setState(() {
                                    sub['staffName'] = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _generate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("Generate Timetable", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
