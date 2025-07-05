import 'package:flutter/material.dart';

class ManualExtraClassesScreen extends StatelessWidget {
  final String year;

  const ManualExtraClassesScreen({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Extra Classes - $year")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Enter extra class details below:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Select Day"),
              items:
                  ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
                      .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                      .toList(),
              onChanged: (val) {},
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Select Period"),
              items:
                  List.generate(8, (i) => "P${i + 1}")
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
              onChanged: (val) {},
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: "Subject Name"),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Select Staff"),
              items:
                  ["Prof. A", "Prof. B", "Prof. C"]
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
              onChanged: (val) {},
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Override Timing (optional)",
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: "Notes"),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Save extra class logic
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Save"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// This screen allows users to manually add extra classes with detailed options for day, period, subject, staff, timings, and notes.
// It provides a form to input the necessary details and save them, with a back button to return to the previous screen.
// The screen is designed to be user-friendly and intuitive, making it easy to manage extra classes for a specific academic year.
// The `year` parameter is passed to the screen to indicate which academic year the extra classes are being added for.
// The screen includes dropdowns for selecting day and period, text fields for subject name, staff selection, override timing, and notes.
// The save button is currently a placeholder for the actual saving logic, which can be implemented later
