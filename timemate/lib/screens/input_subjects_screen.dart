import 'package:flutter/material.dart';

class InputSubjectsScreen extends StatefulWidget {
  final String year;

  const InputSubjectsScreen({super.key, required this.year});

  @override
  State<InputSubjectsScreen> createState() => _InputSubjectsScreenState();
}

class _InputSubjectsScreenState extends State<InputSubjectsScreen> {
  List<Map<String, dynamic>> subjects = [];

  @override
  void initState() {
    super.initState();
    // start with one row
    subjects.add({'name': '', 'type': 'Lecture', 'lecturesPerWeek': ''});
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
    // For now, just print the data
    for (var subj in subjects) {
      debugPrint(subj.toString());
    }
    // TODO: Save to database or pass to ML scheduling
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.year} - Input Subjects")),
      body: Padding(
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
                              onChanged:
                                  (val) => setState(
                                    () => subjects[index]['type'] = val,
                                  ),
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
                              onChanged:
                                  (val) =>
                                      subjects[index]['lecturesPerWeek'] = val,
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
