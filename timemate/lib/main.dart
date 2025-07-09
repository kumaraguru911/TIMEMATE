import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'screens/login_screen.dart';
import 'screens/add_class_page.dart';
import 'screens/splash_screen.dart';
import 'screens/register_screen.dart';
import 'screens/year_selection_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/timetable_edit_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/forget_password_screen.dart';
import 'screens/create_class_screen.dart';

// DO NOT import manual_extra_classes_screen.dart here for static routing
// Because it needs a runtime year argument

void main() {
  runApp(const TimemateApp());
}

class TimemateApp extends StatelessWidget {
  const TimemateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Timemate',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/year-selection': (_) => const YearSelectionScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/dashboard': (_) => DashboardScreen(),
        '/edit-timetable': (_) => const TimetableEditScreen(),
        '/forgot-password': (context) => const ForgetPasswordScreen(),
        '/create_class_screen': (context) => const CreateClassScreen(),
        // Removed '/manual-extra-classes' route because ManualExtraClassesScreen needs runtime argument 'year'
        // Also removed '/timetable' for same reason (requires year).
      },
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
      _classItems.addAll(
        data.map((e) {
          final decoded = jsonDecode(e);
          return ClassItem(
            day: decoded['day'],
            subject: decoded['subject'],
            startTime: decoded['startTime'],
            endTime: decoded['endTime'],
          );
        }),
      );
    });
  }

  Future<void> _saveClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final data =
        _classItems.map((e) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body:
          _classItems.isEmpty
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
                  children:
                      _groupClassesByDay().entries.map((entry) {
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                day,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            ...classes.asMap().entries.map(
                              (e) => AnimationConfiguration.staggeredList(
                                position: e.key,
                                duration: const Duration(milliseconds: 500),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Card(
                                      color: _subjectColor(e.value.subject),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 4,
                                      ),
                                      child: ListTile(
                                        leading: const Icon(Icons.class_),
                                        title: Text(
                                          e.value.subject,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${e.value.startTime} - ${e.value.endTime}',
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
                _classItems.add(
                  ClassItem(
                    day: classMap['day'],
                    subject: classMap['subject'],
                    startTime: classMap['startTime'],
                    endTime: classMap['endTime'],
                  ),
                );
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

// This is the main entry point of the Timemate app.
// It initializes the app with a MaterialApp widget, sets the theme, and defines routes for different screens.
// The app includes a splash screen, login screen, registration screen, year selection screen, and
