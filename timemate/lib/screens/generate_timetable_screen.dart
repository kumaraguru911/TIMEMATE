import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class GenerateTimetableScreen extends StatefulWidget {
  final String year;
  final String department;
  final String section;
  final List<Map<String, dynamic>> subjectsList; // includes staffName
  final List<Map<String, dynamic>> staffList;    // from Staff DB
  final int periodsPerDay;
  final List<String> essentialSubjects;

  const GenerateTimetableScreen({
    super.key,
    required this.year,
    required this.department,
    required this.section,
    required this.subjectsList,
    required this.staffList,
    this.periodsPerDay = 9,
    this.essentialSubjects = const ["Placement", "Aptitude"],
  });

  @override
  State<GenerateTimetableScreen> createState() =>
      _GenerateTimetableScreenState();
}

class _GenerateTimetableScreenState extends State<GenerateTimetableScreen> {
  late List<List<Map<String, String>>> timetable = List.generate(
    6,
    (_) => List.generate(9, (_) => {"subject": "", "staff": ""}),
  );
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  bool includeSaturday = true;
  bool _isLoading = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _loadOrGenerate();
  }

  Future<void> _loadOrGenerate() async {
    setState(() => _isLoading = true);
    final loaded = await _loadTimetable();
    if (!loaded) {
      _generateFromInputs();
      await _saveTimetable();
    }
    setState(() => _isLoading = false);
  }

  Future<bool> _loadTimetable() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    final doc = await _firestore.collection('users').doc(user.uid).collection('timetables').doc('main').get();
    if (!doc.exists) return false;
    final data = doc.data();
    if (data == null || data['timetableData'] == null) return false;
    final List decoded = jsonDecode(data['timetableData']);
    timetable = decoded
        .map<List<Map<String, String>>>((d) => (d as List)
            .map<Map<String, String>>((c) => Map<String, String>.from(c))
            .toList())
        .toList();
    return true;
  }

  Future<void> _saveTimetable() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final docRef = _firestore.collection('users').doc(user.uid).collection('timetables').doc('main');
    await docRef.set({
      'generatedOn': DateTime.now().toIso8601String(),
      'timetableData': jsonEncode(timetable),
    });
  }

  // ---------------- allocation ----------------
  void _generateFromInputs() {
    final tasks = <_ClassTask>[];
    for (final s in widget.subjectsList) {
      final name = s['subject'].toString();
      final credits = (s['credits'] is int)
          ? s['credits'] as int
          : int.tryParse(s['credits'].toString()) ?? 1;
      final special = s['special']?.toString() ?? 'None';
      final staff = s['staffName']?.toString() ?? 'TBA';

      int weight = credits;
      if (widget.essentialSubjects
          .map((e) => e.toLowerCase())
          .contains(name.toLowerCase())) {
        weight += 10;
      }
      if (special.toLowerCase() != 'none') weight += 5;

      for (int i = 0; i < credits; i++) {
        tasks.add(_ClassTask(
            subject: name, staff: staff, special: special, weight: weight));
      }
    }

    tasks.sort((a, b) => b.weight.compareTo(a.weight));

    final int totalDays = days.length;
    final int periods = widget.periodsPerDay;

    final Map<String, Map<int, int>> subjectPerDayCount = {};

    bool place(int day, int period, _ClassTask t) {
      if (timetable[day][period]['subject']!.isNotEmpty) return false;

      final perDayMax = 1;
      subjectPerDayCount.putIfAbsent(t.subject, () => {});
      final used = subjectPerDayCount[t.subject]!.putIfAbsent(day, () => 0);
      if (used >= perDayMax) return false;

      timetable[day][period] = {"subject": t.subject, "staff": t.staff};
      subjectPerDayCount[t.subject]![day] = used + 1;
      return true;
    }

    int startDay = 0;
    int startPeriod = 0;

    for (final task in tasks) {
      bool placed = false;
      List<int> periodOrder = List.generate(periods, (i) => i);
      if (widget.essentialSubjects
          .map((e) => e.toLowerCase())
          .contains(task.subject.toLowerCase())) {
        periodOrder = [1, 2, 3, 4, 5, 6, 0, 7, 8];
      }

      for (int shift = 0; shift < totalDays && !placed; shift++) {
        final day = (startDay + shift) % totalDays;
        final isLab = task.special.toLowerCase().contains('lab');
        if (isLab) {
          for (final p in periodOrder) {
            if (p + 1 < periods) {
              if (timetable[day][p]['subject']!.isEmpty &&
                  timetable[day][p + 1]['subject']!.isEmpty) {
                if (place(day, p, task)) {
                  timetable[day][p + 1] = {
                    "subject": task.subject,
                    "staff": task.staff
                  };
                  placed = true;
                  break;
                }
              }
            }
          }
        } else {
          for (final p in periodOrder) {
            if (place(day, p, task)) {
              placed = true;
              break;
            }
          }
        }
      }

      if (!placed) {
        outer:
        for (int d = 0; d < totalDays; d++) {
          for (int p = 0; p < periods; p++) {
            if (timetable[d][p]['subject']!.isEmpty) {
              timetable[d][p] = {"subject": task.subject, "staff": task.staff};
              placed = true;
              break outer;
            }
          }
        }
      }

      startPeriod = (startPeriod + 1) % periods;
      if (startPeriod == 0) startDay = (startDay + 1) % totalDays;
    }
  }
  // ---------------- End allocation ----------------

  void _showCellInfo(int day, int period) {
    final subject = timetable[day][period]['subject'] ?? "";
    final staff = timetable[day][period]['staff'] ?? "";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(subject.isEmpty ? "Free Period" : subject),
        content: Text(staff.isEmpty ? "—" : "Staff: $staff"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  void _editCell(int day, int period) {
    final subjectController =
        TextEditingController(text: timetable[day][period]['subject'] ?? '');
    final staffController =
        TextEditingController(text: timetable[day][period]['staff'] ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Class"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Subject')),
            TextField(
                controller: staffController,
                decoration: const InputDecoration(labelText: 'Staff')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              setState(() {
                timetable[day][period] = {
                  "subject": subjectController.text.trim(),
                  "staff": staffController.text.trim()
                };
              });
              await _saveTimetable();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: () async {
              setState(() {
                timetable[day][period] = {"subject": "", "staff": ""};
              });
              await _saveTimetable();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }

  Color _getCellColor(String subject) {
    if (subject.isEmpty) return Colors.white10;
    if (subject.toLowerCase() == "placement") {
      return Colors.redAccent.withOpacity(0.7);
    }
    if (subject.toLowerCase() == "aptitude") {
      return Colors.orangeAccent.withOpacity(0.7);
    }
    if (subject.toLowerCase().contains("lab")) {
      return Colors.greenAccent.withOpacity(0.7);
    }
    return Colors.blueGrey.withOpacity(0.4);
  }

  void _exportExcel() {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];
    sheet.appendRow(
        ["Day/Period", ...List.generate(widget.periodsPerDay, (i) => "P${i + 1}")]);
    final displayDays = includeSaturday ? days : days.sublist(0, 5);
    for (int d = 0; d < displayDays.length; d++) {
      sheet.appendRow([
        displayDays[d],
        ...List.generate(widget.periodsPerDay,
            (p) => "${timetable[d][p]['subject']} (${timetable[d][p]['staff']})")
      ]);
    }
    final fileBytes = excel.encode()!;
    Printing.sharePdf(
        bytes: Uint8List.fromList(fileBytes), filename: "timetable.xlsx");
  }

  Future<void> _exportPDF() async {
    final pdf = pw.Document();
    final headers =
        ["Day/Period", ...List.generate(widget.periodsPerDay, (i) => "P${i + 1}")];
    final displayDays = includeSaturday ? days : days.sublist(0, 5);

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                  "Timetable - ${widget.year} ${widget.department} ${widget.section.isEmpty ? '' : 'Sec ${widget.section}'}",
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: headers,
                data: [
                  for (int d = 0; d < displayDays.length; d++)
                    [
                      displayDays[d],
                      ...List.generate(widget.periodsPerDay,
                          (p) => "${timetable[d][p]['subject']} (${timetable[d][p]['staff']})"),
                    ]
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.center,
              ),
            ],
          );
        },
      ),
    );
    final bytes = await pdf.save();
    await Printing.sharePdf(bytes: bytes, filename: "timetable.pdf");
    // Upload to Firebase Storage
    final user = _auth.currentUser;
    if (user != null) {
      final ref = _storage.ref().child('users/${user.uid}/timetables/main.pdf');
      await ref.putData(Uint8List.fromList(bytes));
      final url = await ref.getDownloadURL();
      await _firestore.collection('users').doc(user.uid).collection('timetables').doc('main').update({
        'pdfUrl': url,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayDays = includeSaturday ? days : days.sublist(0, 5);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("Generated Timetable",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Row(
            children: [
              const Text("Sat", style: TextStyle(color: Colors.white70)),
              Switch(
                value: includeSaturday,
                onChanged: (val) => setState(() => includeSaturday = val),
                activeColor: Colors.cyanAccent,
              ),
            ],
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF2B5876), Color(0xFF4E4376)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Image.asset("assets/college_logo.png", height: 80),
                      const SizedBox(height: 10),
                      Text(
                        "Year: ${widget.year}, Dept: ${widget.department}, Sec: ${widget.section.isEmpty ? 'N/A' : widget.section}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          color: Colors.white.withOpacity(0.1),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Table(
                              border: TableBorder.all(color: Colors.white54),
                              defaultColumnWidth: const FixedColumnWidth(110),
                              children: [
                                TableRow(
                                  decoration:
                                      const BoxDecoration(color: Colors.cyanAccent),
                                  children: [
                                    const TableCell(
                                        child: Center(
                                            child: Text("Day/Period",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold)))),
                                    ...List.generate(widget.periodsPerDay, (i) {
                                      return TableCell(
                                        child: Center(
                                          child: Text("P${i + 1}",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                ...List.generate(displayDays.length, (dayIndex) {
                                  return TableRow(
                                    decoration: BoxDecoration(
                                        color: dayIndex.isEven
                                            ? Colors.black26
                                            : Colors.black12),
                                    children: [
                                      TableCell(
                                        child: Center(
                                          child: Text(displayDays[dayIndex],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      ...List.generate(widget.periodsPerDay,
                                          (periodIndex) {
                                        final subject = timetable[dayIndex][periodIndex]
                                                ['subject'] ??
                                            "";
                                        final staff = timetable[dayIndex][periodIndex]
                                                ['staff'] ??
                                            "";
                                        return TableCell(
                                          child: GestureDetector(
                                            onTap: () =>
                                                _showCellInfo(dayIndex, periodIndex),
                                            onLongPress: () =>
                                                _editCell(dayIndex, periodIndex),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              alignment: Alignment.center,
                                              color: _getCellColor(subject),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(subject,
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                  if (staff.isNotEmpty)
                                                    Text(staff,
                                                        style: const TextStyle(
                                                            color: Colors.white70,
                                                            fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.picture_as_pdf),
                            onPressed: _exportPDF,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyanAccent,
                                foregroundColor: Colors.black),
                            label: const Text("Export PDF"),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.table_chart),
                            onPressed: _exportExcel,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyanAccent,
                                foregroundColor: Colors.black),
                            label: const Text("Export Excel"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _ClassTask {
  final String subject;
  final String staff;
  final String special;
  final int weight;
  _ClassTask(
      {required this.subject,
      required this.staff,
      required this.special,
      required this.weight});
}
// ---------------- End allocation ----------------