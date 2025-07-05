import 'package:flutter/material.dart';

class PeriodDetailsPopup extends StatefulWidget {
  final String day;
  final String periodLabel;
  final String initialSubject;
  final String initialStaff;
  final String initialTiming;
  final int initialLectures;
  final String initialTopic;
  final bool initialPlayHour;
  final bool isEditable;

  const PeriodDetailsPopup({
    super.key,
    required this.day,
    required this.periodLabel,
    required this.initialSubject,
    required this.initialStaff,
    required this.initialTiming,
    required this.initialLectures,
    required this.initialTopic,
    required this.initialPlayHour,
    required this.isEditable,
  });

  @override
  State<PeriodDetailsPopup> createState() => _PeriodDetailsPopupState();
}

class _PeriodDetailsPopupState extends State<PeriodDetailsPopup> {
  late TextEditingController _subjectController;
  late TextEditingController _topicController;
  late TextEditingController _lecturesController;
  late String _selectedStaff;
  late bool _playHour;

  final List<String> staffList = [
    'Prof. Kumar',
    'Prof. Anjali',
    'Prof. Sharma',
    'Prof. David',
  ];

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.initialSubject);
    _topicController = TextEditingController(text: widget.initialTopic);
    _lecturesController = TextEditingController(
      text: widget.initialLectures.toString(),
    );
    _selectedStaff = widget.initialStaff;
    _playHour = widget.initialPlayHour;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    _lecturesController.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop({
      'subject': _subjectController.text,
      'staff': _selectedStaff,
      'lectures': int.tryParse(_lecturesController.text) ?? 0,
      'topic': _topicController.text,
      'playHour': _playHour,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Period Details - ${widget.day} ${widget.periodLabel}"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.isEditable
                ? TextFormField(
                  controller: _subjectController,
                  decoration: const InputDecoration(labelText: "Subject"),
                )
                : Text("Subject: ${widget.initialSubject}"),
            const SizedBox(height: 8),
            widget.isEditable
                ? DropdownButtonFormField<String>(
                  value: _selectedStaff,
                  decoration: const InputDecoration(labelText: "Staff"),
                  items:
                      staffList
                          .map(
                            (staff) => DropdownMenuItem(
                              value: staff,
                              child: Text(staff),
                            ),
                          )
                          .toList(),
                  onChanged: (val) {
                    setState(() => _selectedStaff = val!);
                  },
                )
                : Text("Staff: ${widget.initialStaff}"),
            const SizedBox(height: 8),
            Text("Timing: ${widget.initialTiming}"),
            const SizedBox(height: 8),
            widget.isEditable
                ? TextFormField(
                  controller: _lecturesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "No. of Lectures",
                  ),
                )
                : Text("Lectures: ${widget.initialLectures}"),
            const SizedBox(height: 8),
            widget.isEditable
                ? TextFormField(
                  controller: _topicController,
                  decoration: const InputDecoration(labelText: "Topic"),
                )
                : Text("Topic: ${widget.initialTopic}"),
            const SizedBox(height: 8),
            widget.isEditable
                ? CheckboxListTile(
                  title: const Text("Play Hour"),
                  value: _playHour,
                  onChanged: (val) => setState(() => _playHour = val!),
                )
                : Text("Play Hour: ${widget.initialPlayHour ? 'Yes' : 'No'}"),
          ],
        ),
      ),
      actions: [
        if (widget.isEditable)
          TextButton(onPressed: _save, child: const Text("Save")),
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}

// This widget displays a popup dialog for editing period details.
// It includes fields for subject, staff, timing, number of lectures, topic, and play hour.
// The dialog can be in editable mode or view-only mode based on the `isEditable` parameter.
// When in editable mode, it allows users to modify the details and save them.
