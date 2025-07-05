import 'package:flutter/material.dart';

class FinalConfirmationScreen extends StatefulWidget {
  final String year;
  final Map<String, List<String>> timetable;

  const FinalConfirmationScreen({
    super.key,
    required this.year,
    required this.timetable,
  });

  @override
  State<FinalConfirmationScreen> createState() =>
      _FinalConfirmationScreenState();
}

class _FinalConfirmationScreenState extends State<FinalConfirmationScreen> {
  bool isConfirmed = false;

  void _finalize() {
    // TODO: Finalize timetable logic (e.g., save to database)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Timetable finalized successfully!")),
    );
    Navigator.popUntil(context, ModalRoute.withName('/dashboard'));
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.timetable.keys.toList();
    final periods = widget.timetable[days.first]!.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Final Confirmation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Please review your timetable carefully below. Once confirmed, it will be finalized and changes won't be allowed.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    const DataColumn(label: Text("Day")),
                    for (int p = 1; p <= periods; p++)
                      DataColumn(label: Text("P$p")),
                  ],
                  rows:
                      days.map((day) {
                        return DataRow(
                          cells: [
                            DataCell(Text(day)),
                            ...List.generate(periods, (p) {
                              final cellValue = widget.timetable[day]![p];
                              return DataCell(Text(cellValue));
                            }),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: isConfirmed,
                  onChanged:
                      (val) => setState(() => isConfirmed = val ?? false),
                ),
                const Expanded(
                  child: Text(
                    "I confirm that the above timetable is correct.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isConfirmed ? _finalize : null,
                    icon: const Icon(Icons.check),
                    label: const Text("Finalize"),
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

// This screen allows users to confirm their timetable before finalizing it.
// It displays the timetable in a DataTable format, allows users to confirm their agreement, and provides buttons to go back or finalize the timetable.
// The confirmation is required to ensure that users have reviewed their timetable before it is finalized.
