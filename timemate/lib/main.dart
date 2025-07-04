import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'add_class_page.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

class ClassTimetableApp extends StatelessWidget {
  const ClassTimetableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'College Timetable',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const HomePage(),
    );
  }
}

class ClassItem {
  final String day;
  final String subject;
  final String startTime;
  final String endTime;

  ClassItem({
    required this.day,
    required this.subject,
    required this.startTime,
    required this.endTime,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<ClassItem> _classItems = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('timetable') ?? [];
    setState(() {
      _classItems.clear();
      _classItems.addAll(data.map((e) {
        final decoded = jsonDecode(e);
        return ClassItem(
          day: decoded['day'],
          subject: decoded['subject'],
          startTime: decoded['startTime'],
          endTime: decoded['endTime'],
        );
      }));
    });
  }

  Future<void> _saveClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _classItems.map((e) {
      return jsonEncode({
        'day': e.day,
        'subject': e.subject,
        'startTime': e.startTime,
        'endTime': e.endTime,
      });
    }).toList();
    await prefs.setStringList('timetable', data);
  }

  Map<String, List<ClassItem>> _groupClassesByDay() {
    final Map<String, List<ClassItem>> grouped = {};
    for (var item in _classItems) {
      grouped.putIfAbsent(item.day, () => []).add(item);
    }
    return grouped;
  }

  Color _subjectColor(String subject) {
    final colors = [
      Colors.pink.shade100,
      Colors.green.shade100,
      Colors.orange.shade100,
      Colors.blue.shade100,
      Colors.purple.shade100,
      Colors.teal.shade100,
    ];
    return colors[subject.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My College Timetable'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _classItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/timemate.png', width: 120, height: 120),
                  const SizedBox(height: 16),
                  const Text('No classes added yet. Tap + to add!'),
                ],
              ),
            )
          : AnimationLimiter(
              child: ListView(
                children: _groupClassesByDay().entries.map((entry) {
                  final day = entry.key;
                  final classes = entry.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.indigo, Colors.blueAccent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ...classes.asMap().entries.map((e) => AnimationConfiguration.staggeredList(
                            position: e.key,
                            duration: const Duration(milliseconds: 500),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Card(
                                  color: _subjectColor(e.value.subject),
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  child: ListTile(
                                    leading: const Icon(Icons.class_),
                                    title: Text(
                                      e.value.subject,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text('${e.value.startTime} - ${e.value.endTime}'),
                                  ),
                                ),
                              ),
                            ),
                          ))
                    ],
                  );
                }).toList(),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddClassPage()),
          );
          if (result != null && result is List) {
            setState(() {
              for (final classMap in result) {
                _classItems.add(ClassItem(
                  day: classMap['day'],
                  subject: classMap['subject'],
                  startTime: classMap['startTime'],
                  endTime: classMap['endTime'],
                ));
              }
            });
            await _saveClasses();
          }
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }
}
// This code is the main entry point for a Flutter application that displays a college timetable.
// It includes a splash screen, a home page with a list of classes grouped by day,