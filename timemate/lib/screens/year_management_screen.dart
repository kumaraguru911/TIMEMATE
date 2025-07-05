import 'package:flutter/material.dart';
import 'input_subjects_screen.dart';
import 'timetable_generation_screen.dart';
import 'timetable_view_screen.dart';
import 'manual_extra_classes_screen.dart';

class YearManagementScreen extends StatelessWidget {
  final String year;

  const YearManagementScreen({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$year Management")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InputSubjectsScreen(year: year),
                  ),
                );
              },
              icon: const Icon(Icons.book),
              label: const Text("Input Subjects"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TimetableGenerationScreen(year: year),
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Generate Timetable"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // ✅ Provide dummy timetable here to avoid error
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => TimetableViewScreen(
                          year: year,
                          timetable: {
                            "Monday": [
                              "Math",
                              "English",
                              "Physics",
                              "Free",
                              "Chemistry",
                            ],
                            "Tuesday": [
                              "Biology",
                              "Math",
                              "Free",
                              "English",
                              "Physics",
                            ],
                            "Wednesday": [
                              "Free",
                              "Chemistry",
                              "Math",
                              "Biology",
                              "English",
                            ],
                            "Thursday": [
                              "Physics",
                              "Free",
                              "Chemistry",
                              "Math",
                              "English",
                            ],
                            "Friday": [
                              "Math",
                              "Physics",
                              "English",
                              "Biology",
                              "Free",
                            ],
                          },
                        ),
                  ),
                );
              },
              icon: const Icon(Icons.visibility),
              label: const Text("View Timetable"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ManualExtraClassesScreen(year: year),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Extra Classes"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back to Dashboard"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// This screen allows users to manage their academic year by inputting subjects, generating a timetable, viewing the timetable with dummy data, and adding extra classes.
