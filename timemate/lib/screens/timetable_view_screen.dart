
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';


class TimetableViewScreen extends StatefulWidget {
  const TimetableViewScreen({super.key});

  @override
  State<TimetableViewScreen> createState() => _TimetableViewScreenState();
}

class _TimetableViewScreenState extends State<TimetableViewScreen> {
  bool _isLoading = true;
  List<List<Map<String, String>>> timetable = [];
  int periodsPerDay = 9;
  List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  String? pdfUrl;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    setState(() => _isLoading = true);
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).collection('timetables').doc('main').get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['timetableData'] != null) {
          final List decoded = jsonDecode(data['timetableData']);
          timetable = decoded
              .map<List<Map<String, String>>>((d) => (d as List)
                  .map<Map<String, String>>((c) => Map<String, String>.from(c))
                  .toList())
              .toList();
        }
        if (data['pdfUrl'] != null) {
          pdfUrl = data['pdfUrl'];
        }
      }
    }
    setState(() => _isLoading = false);
  }

  Future<void> _downloadPDF() async {
    if (pdfUrl != null) {
      await Printing.layoutPdf(onLayout: (format) async {
        final bytes = await _storage.refFromURL(pdfUrl!).getData();
        return bytes!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Timetable"),
        actions: [
          if (pdfUrl != null)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: _downloadPDF,
              tooltip: "Download PDF",
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : timetable.isEmpty
              ? const Center(child: Text("No timetable found."))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(color: Colors.white54),
                      defaultColumnWidth: const FixedColumnWidth(110),
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(color: Colors.cyanAccent),
                          children: [
                            const TableCell(
                                child: Center(
                                    child: Text("Day/Period",
                                        style: TextStyle(fontWeight: FontWeight.bold)))),
                            ...List.generate(periodsPerDay, (i) {
                              return TableCell(
                                child: Center(
                                  child: Text("P${i + 1}",
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              );
                            }),
                          ],
                        ),
                        ...List.generate(timetable.length, (dayIndex) {
                          return TableRow(
                            decoration: BoxDecoration(
                                color: dayIndex.isEven ? Colors.black26 : Colors.black12),
                            children: [
                              TableCell(
                                child: Center(
                                  child: Text(days[dayIndex],
                                      style: const TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              ...List.generate(periodsPerDay, (periodIndex) {
                                final subject = timetable[dayIndex][periodIndex]['subject'] ?? "";
                                final staff = timetable[dayIndex][periodIndex]['staff'] ?? "";
                                return TableCell(
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(subject, style: const TextStyle(color: Colors.white)),
                                        if (staff.isNotEmpty)
                                          Text(staff, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                      ],
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
    );
  }
}
