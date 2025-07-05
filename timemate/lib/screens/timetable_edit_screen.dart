import 'package:flutter/material.dart';

class TimetableEditScreen extends StatelessWidget {
  const TimetableEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Timetable")),
      body: const Center(
        child: Text(
          "Timetable edit screen content goes here.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// This screen is a placeholder for editing the timetable.
// You can expand it later to include actual editing functionality, such as adding/removing classes,
