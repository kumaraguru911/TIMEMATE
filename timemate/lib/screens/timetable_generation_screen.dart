import 'package:flutter/material.dart';
import 'timetable_view_screen.dart';

class TimetableGenerationScreen extends StatefulWidget {
  final String year;

  const TimetableGenerationScreen({super.key, required this.year});

  @override
  State<TimetableGenerationScreen> createState() =>
      _TimetableGenerationScreenState();
}

class _TimetableGenerationScreenState extends State<TimetableGenerationScreen> {
  bool _isGenerating = false;

  /// ✅ This method simulates timetable generation and returns dummy data
  Future<Map<String, List<String>>> _generateTimetable() async {
    await Future.delayed(
      const Duration(seconds: 2),
    ); // simulate processing delay

    // ✅ Dummy timetable data; replace with real generation logic in future
    return {
      "Monday": ["Math", "English", "Physics", "Free", "Chemistry"],
      "Tuesday": ["Biology", "Math", "Free", "English", "Physics"],
      "Wednesday": ["Free", "Chemistry", "Math", "Biology", "English"],
      "Thursday": ["Physics", "Free", "Chemistry", "Math", "English"],
      "Friday": ["Math", "Physics", "English", "Biology", "Free"],
    };
  }

  /// ✅ Call this when user taps "Generate Timetable" button
  void _startGeneration() async {
    setState(() => _isGenerating = true);

    final generatedTimetable = await _generateTimetable();

    setState(() => _isGenerating = false);

    // ✅ Navigate to TimetableViewScreen and pass the generated timetable
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => TimetableViewScreen(
              year: widget.year,
              timetable:
                  generatedTimetable, // ✅ passing the generated timetable here
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Generate Timetable - ${widget.year}")),
      body: Center(
        child:
            _isGenerating
                ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("Generating timetable..."),
                  ],
                )
                : ElevatedButton.icon(
                  onPressed: _startGeneration,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Generate Timetable"),
                ),
      ),
    );
  }
}

// This screen allows users to generate a timetable for a specific academic year.
// It simulates the generation process and navigates to TimetableViewScreen with the generated timetable.
// The `_generateTimetable` method currently returns dummy data; replace it with real logic in the future.
// The `_startGeneration` method handles the button tap, shows a loading indicator, and navigates to the timetable view once done.
// The `year` parameter is passed to the screen to indicate which academic year the timetable is being generated for.
// The screen includes a button to start the generation process, which shows a loading indicator while the timetable is being generated.
// The generated timetable is a map where keys are days of the week and values are lists of subjects for each period.
// The button is disabled while the timetable is being generated to prevent multiple taps.
