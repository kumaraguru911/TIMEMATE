import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InputSubjectsScreen extends StatefulWidget {
  final String year;

  const InputSubjectsScreen({super.key, required this.year});

  @override
  State<InputSubjectsScreen> createState() => _InputSubjectsScreenState();
}

class _InputSubjectsScreenState extends State<InputSubjectsScreen> {
  List<Map<String, dynamic>> subjects = [];
  bool _isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
  super.initState();
  _fetchSubjects();
  Future<void> _fetchSubjects() async {
    setState(() => _isLoading = true);
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await _firestore.collection('users').doc(user.uid).collection('subjects').get();
      subjects = snapshot.docs.map((doc) => doc.data()).toList();
    }
    if (subjects.isEmpty) {
      subjects.add({'name': '', 'type': 'Lecture', 'lecturesPerWeek': ''});
    }
    setState(() => _isLoading = false);
  }
  }

  void _addSubject() {
    setState(() {
      subjects.add({'name': '', 'type': 'Lecture', 'lecturesPerWeek': ''});
    });
  }

  void _removeSubject(int index) {
    setState(() {
      subjects.removeAt(index);
    });
  }

  void _submit() {
    final user = _auth.currentUser;
    if (user != null) {
      final batch = _firestore.batch();
      final subjectsRef = _firestore.collection('users').doc(user.uid).collection('subjects');
      // Delete old subjects
      subjectsRef.get().then((snapshot) {
        for (var doc in snapshot.docs) {
          batch.delete(doc.reference);
        }
        // Add new subjects
        for (var subj in subjects) {
          if ((subj['name'] ?? '').toString().trim().isNotEmpty) {
            final docRef = subjectsRef.doc();
            batch.set(docRef, subj);
          }
        }
        batch.commit().then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subjects saved to Firestore!')),
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.year} - Input Subjects")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Enter subjects for the selected year. Specify subject name, type, and lectures per week.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Flexible(
                                  flex: 4,
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: "Subject Name",
                                    ),
                                    initialValue: subjects[index]['name'],
                                    onChanged: (val) => subjects[index]['name'] = val,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  flex: 3,
                                  child: DropdownButtonFormField<String>(
                                    value: subjects[index]['type'],
                                    decoration: const InputDecoration(
                                      labelText: "Type",
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'Lecture',
                                        child: Text('Lecture'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Practical',
                                        child: Text('Practical'),
                                      ),
                                    ],
                                    onChanged: (val) => setState(() => subjects[index]['type'] = val),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  flex: 2,
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: "Lectures/Wk",
                                    ),
                                    keyboardType: TextInputType.number,
                                    initialValue: subjects[index]['lecturesPerWeek'],
                                    onChanged: (val) => subjects[index]['lecturesPerWeek'] = val,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeSubject(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _addSubject,
                        icon: const Icon(Icons.add),
                        label: const Text("Add Subject"),
                      ),
                      const Spacer(),
                      ElevatedButton(onPressed: _submit, child: const Text("Submit")),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade700,
                        ),
                        child: const Text("Back"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

// This screen allows users to input subjects for a specific academic year.
// It includes fields for subject name, type (Lecture/Practical), and number of lectures per week.
// Users can add multiple subjects, remove them, and submit the data for further processing.
