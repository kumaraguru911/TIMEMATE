import 'package:flutter/material.dart';
import 'period_details_popup.dart';
import 'manual_extra_classes_screen.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TimetableViewScreen extends StatefulWidget {
  final String year;
  final Map<String, List<String>> timetable;

  const TimetableViewScreen({
    super.key,
    required this.year,
    required this.timetable,
  });

  @override
  State<TimetableViewScreen> createState() => _TimetableViewScreenState();
}

class _TimetableViewScreenState extends State<TimetableViewScreen> {
  bool isEditMode = false;
  late Map<String, List<String>> timetable;

  @override
  void initState() {
    super.initState();
    timetable = Map.from(widget.timetable);
  }

  void _toggleEdit() {
    setState(() => isEditMode = !isEditMode);
  }

  Future<void> _exportPDF() async {
    final pdf = pw.Document();
    final days = timetable.keys.toList();
    final periods = timetable[days.first]!.length;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text('${widget.year} Timetable',
                style: pw.TextStyle(
                    fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['Day'] + List.generate(periods, (p) => 'P${p + 1}'),
              data: days
                  .map((day) => [
                        day,
                        ...timetable[day]!,
                      ])
                  .toList(),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> _exportExcel() async {
    final excel = Excel.createExcel();
    final sheet = excel['Timetable'];
    final days = timetable.keys.toList();
    final periods = timetable[days.first]!.length;

    // Write header
    sheet.appendRow(['Day'] + List.generate(periods, (p) => 'P${p + 1}'));

    // Write data
    for (var day in days) {
      sheet.appendRow([day, ...timetable[day]!]);
    }

    final dir = await getExternalStorageDirectory();
    final String path = '${dir!.path}/${widget.year}_Timetable.xlsx';
    final bytes = excel.encode();
    final file = File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Excel saved at: $path')),
    );
  }

  void _addExtraClass() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManualExtraClassesScreen(year: widget.year),
      ),
    );
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Timetable saved!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final days = timetable.keys.toList();
    final periods = timetable[days.first]!.length;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.year} Timetable"),
        actions: [
          IconButton(
            icon: Icon(isEditMode ? Icons.done : Icons.edit),
            onPressed: _toggleEdit,
            tooltip: isEditMode ? "Done Editing" : "Edit",
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportPDF,
            tooltip: "Export PDF",
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            onPressed: _exportExcel,
            tooltip: "Export Excel",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              const DataColumn(label: Text("Day")),
              for (int p = 1; p <= periods; p++) DataColumn(label: Text("P$p")),
            ],
            rows: days
                .map((day) => DataRow(cells: [
                      DataCell(Text(day)),
                      ...List.generate(periods, (p) {
                        final periodLabel = "P${p + 1}";
                        final cellValue = timetable[day]![p];
                        return DataCell(
                          isEditMode
                              ? DropdownButton<String>(
                                  value: cellValue,
                                  items: [
                                    "Math",
                                    "English",
                                    "Physics",
                                    "Chemistry",
                                    "Biology",
                                    "Free"
                                  ]
                                      .map((s) =>
                                          DropdownMenuItem(value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() {
                                      timetable[day]![p] =
                                          val ?? timetable[day]![p];
                                    });
                                  },
                                )
                              : GestureDetector(
                                  onTap: () async {
                                    final result = await showDialog(
                                      context: context,
                                      builder: (_) => PeriodDetailsPopup(
                                        day: day,
                                        periodLabel: periodLabel,
                                        initialSubject: cellValue,
                                        initialStaff: "",
                                        initialTiming: "",
                                        initialLectures: 1,
                                        initialTopic: "",
                                        initialPlayHour: false,
                                        isEditable: isEditMode,
                                      ),
                                    );
                                    if (result != null) {
                                      debugPrint("Period updated: $result");
                                    }
                                  },
                                  child: Text(cellValue),
                                ),
                        );
                      }),
                    ]))
                .toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExtraClass,
        label: const Text("Add Extra Class"),
        icon: const Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text("Save"),
        ),
      ),
    );
  }
}
