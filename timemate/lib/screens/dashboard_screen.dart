import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'create_class_screen.dart';
import 'staff_database_screen.dart';
import 'timetable_view_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Main State Variables
  double _timetableCompletion = 0.0;
  List<Map<String, dynamic>> _announcements = [];
  String _profileName = '';
  String _profileDepartment = '';
  String _profileRole = '';
  String? _profilePicUrl;
  List<DateTime> _eventDates = [];
  String _quote = '';
  int _classCount = 0;
  int _subjectCount = 0;
  int _eventCount = 0;
  int _attendance = 0;
  Map<String, dynamic>? _nextClass;

  // Calendar State
  int _calendarMonth = DateTime.now().month;
  int _calendarYear = DateTime.now().year;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String greetingAnimation = 'assets/animations/sun.json';
  String greetingText = 'Good Morning';
  String username = '';
  bool _isLoading = true;
  bool hasTimetable = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _updateGreeting();
    _fetchUserData();
    _fetchStats();
    _fetchQuote();
    _fetchEventDates();
    _fetchProfileSummary();
    _fetchAnnouncements();
    _fetchTimetableCompletion();
    _fetchNextClass();
  }

  // --- Data Fetching Methods ---
  Future<void> _fetchNextClass() async {
    final user = _auth.currentUser;
    if (user != null) {
      final now = DateTime.now();
      final today = DateFormat('EEEE').format(now).toLowerCase();
      final doc = await _firestore.collection('users').doc(user.uid).collection('timetables').doc('main').get();

      if (doc.exists && doc.data() != null && doc.data()!['timetableData'] != null) {
        final data = doc.data()!['timetableData'];
        try {
          final List<dynamic> timetable = data is String ? List<Map<String, dynamic>>.from((jsonDecode(data) as List)) : data;
          
          for (var dayData in timetable) {
            if (dayData['day'].toString().toLowerCase() == today) {
              for (var period in dayData['periods']) {
                // Assuming periods are sorted by time, we find the next non-empty one
                if (period['subject'] != null && period['subject'].toString().isNotEmpty) {
                  _nextClass = period;
                  break; 
                }
              }
            }
          }
        } catch (e) {
          _nextClass = null;
        }
      } else {
        _nextClass = null;
      }
      setState(() {});
    }
  }

  Future<void> _fetchTimetableCompletion() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).collection('timetables').doc('main').get();
      if (doc.exists && doc.data() != null && doc.data()!['timetableData'] != null) {
        final data = doc.data()!['timetableData'];
        try {
          final List<dynamic> timetable = data is String ? List<Map<String, dynamic>>.from((jsonDecode(data) as List)) : data;
          int filled = 0;
          int total = 0;
          for (var day in timetable) {
            for (var period in day['periods']) {
              total++;
              if (period['subject'] != null && period['subject'].toString().isNotEmpty) filled++;
            }
          }
          _timetableCompletion = total > 0 ? filled / total : 0.0;
        } catch (e) {
          _timetableCompletion = 0.0;
        }
      } else {
        _timetableCompletion = 0.0;
      }
      setState(() {});
    }
  }

  Future<void> _fetchAnnouncements() async {
    final snap = await _firestore.collection('announcements').orderBy('timestamp', descending: true).limit(3).get();
    _announcements = snap.docs.map((doc) => doc.data()).toList();
    setState(() {});
  }

  Future<void> _fetchProfileSummary() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _profileName = data['name'] ?? '';
        _profileDepartment = data['department'] ?? '';
        _profileRole = data['role'] ?? '';
        _profilePicUrl = data['profilePic'];
        setState(() {});
      }
    }
  }

  Future<void> _fetchEventDates() async {
    final user = _auth.currentUser;
    if (user != null) {
      final eventsSnap = await _firestore.collection('users').doc(user.uid).collection('events').get();
      _eventDates = eventsSnap.docs
          .map((doc) => DateTime.tryParse(doc.data()['date'] ?? '') ?? DateTime.now())
          .toList();
      setState(() {});
    }
  }

  Future<void> _fetchQuote() async {
    final quoteSnap = await _firestore.collection('quotes').limit(1).get();
    if (quoteSnap.docs.isNotEmpty) {
      _quote = quoteSnap.docs.first.data()['text'] ?? '';
    } else {
      _quote = "Success is the sum of small efforts, repeated day in and day out.";
    }
    setState(() {});
  }

  Future<void> _fetchStats() async {
    final user = _auth.currentUser;
    if (user != null) {
      final classSnap = await _firestore.collection('users').doc(user.uid).collection('classes').get();
      _classCount = classSnap.size;
      final subjectSnap = await _firestore.collection('users').doc(user.uid).collection('subjects').get();
      _subjectCount = subjectSnap.size;
      final eventSnap = await _firestore.collection('users').doc(user.uid).collection('events').get();
      _eventCount = eventSnap.size;
      final attendanceSnap = await _firestore.collection('users').doc(user.uid).collection('attendance').get();
      _attendance = attendanceSnap.size;
      setState(() {});
    }
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      greetingAnimation = 'assets/animations/sun.json';
      greetingText = "Good Morning";
    } else if (hour >= 12 && hour < 18) {
      greetingAnimation = 'assets/animations/afternoon.json';
      greetingText = "Good Afternoon";
    } else {
      greetingAnimation = 'assets/animations/night.json';
      greetingText = "Good Evening";
    }
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        username = doc.data()!['name'] ?? 'User';
      }
      final timetableDoc = await _firestore.collection('users').doc(user.uid).collection('timetables').doc('main').get();
      hasTimetable = timetableDoc.exists && timetableDoc.data()?['timetableData'] != null;
    }
    setState(() => _isLoading = false);
  }

  void _changeCalendarMonth(int delta) {
    setState(() {
      _calendarMonth += delta;
      if (_calendarMonth > 12) {
        _calendarMonth = 1;
        _calendarYear++;
      } else if (_calendarMonth < 1) {
        _calendarMonth = 12;
        _calendarYear--;
      }
    });
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: const Color(0xFF232946),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.cyanAccent.shade700),
                  ),
                ),
              ),
              ListTile(
                leading: SizedBox(
                  width: 36,
                  height: 36,
                  child: Lottie.asset('assets/animations/profile.json', fit: BoxFit.contain, repeat: false),
                ),
                title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              ListTile(
                leading: SizedBox(
                  width: 36,
                  height: 36,
                  child: Lottie.asset('assets/animations/settingsicon.json', fit: BoxFit.contain, repeat: false),
                ),
                title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('© 2025 TimeMate', style: TextStyle(color: Colors.white38, fontSize: 14), textAlign: TextAlign.center),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2B5876), Color(0xFF4E4376)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Row with Menu Button, Greeting & Lottie
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.menu, color: Colors.cyanAccent, size: 32),
                                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                                tooltip: 'Open menu',
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "$greetingText, $username!",
                                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Container(height: 2, width: 60, color: Colors.cyanAccent),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  height: 70,
                                  width: 70,
                                  child: Lottie.asset(greetingAnimation, fit: BoxFit.contain, repeat: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Quick Actions Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton("View Timetable", Icons.calendar_today, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableViewScreen()))),
                              _buildActionButton("Staff Database", Icons.group, () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StaffDatabaseScreen()))),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Profile Summary Card
                          _buildSectionHeader("Profile Summary"),
                          Card(
                            color: const Color(0xFFFFFFFF).withOpacity(0.10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: ListTile(
                              leading: _profilePicUrl != null && _profilePicUrl!.isNotEmpty
                                  ? CircleAvatar(backgroundImage: NetworkImage(_profilePicUrl!))
                                  : const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(_profileName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                "$_profileDepartment${_profileRole.isNotEmpty ? ' • $_profileRole' : ''}",
                                style: TextStyle(color: const Color(0xFFFFFFFF).withOpacity(0.70)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Timetable Status & Completion
                          _buildSectionHeader("Timetable"),
                          if (hasTimetable)
                            Card(
                              color: const Color(0xFFFFFFFF).withOpacity(0.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: ListTile(
                                leading: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 36),
                                title: const Text("Timetable Created!", style: TextStyle(color: Colors.white, fontSize: 20)),
                                subtitle: Text("Completion: ${(_timetableCompletion * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.white70)),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TimetableViewScreen())),
                              ),
                            )
                          else
                            Card(
                              color: const Color(0xFFFFFFFF).withOpacity(0.1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              child: ListTile(
                                leading: const Icon(Icons.add, color: Colors.cyanAccent, size: 36),
                                title: const Text("Create Your Timetable", style: TextStyle(color: Colors.white, fontSize: 20)),
                                subtitle: const Text("It looks like you haven't created a timetable yet.", style: TextStyle(color: Colors.white70)),
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateClassScreen())),
                              ),
                            ),
                          const SizedBox(height: 20),
                          
                          // Upcoming Class Card
                          if (_nextClass != null) ...[
                            _buildSectionHeader("Next Class"),
                            Card(
                              color: const Color(0xFFFFFFFF).withOpacity(0.10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_nextClass!['subject'] ?? 'Unknown Subject', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text("Class: ${_nextClass!['class'] ?? 'N/A'}", style: TextStyle(color: const Color(0xFFFFFFFF).withOpacity(0.70))),
                                    Text("Time: ${_nextClass!['time'] ?? 'N/A'}", style: TextStyle(color: const Color(0xFFFFFFFF).withOpacity(0.70))),
                                    if (_nextClass!['location'] != null)
                                      Text("Room: ${_nextClass!['location']}", style: TextStyle(color: const Color(0xFFFFFFFF).withOpacity(0.70))),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Announcements
                          _buildSectionHeader("Announcements"),
                          if (_announcements.isEmpty)
                            const Text("No announcements.", style: TextStyle(color: Colors.white70))
                          else
                            Column(
                              children: _announcements.map((a) {
                                final ts = a['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(a['timestamp']) : DateTime.now();
                                return Card(
                                  color: const Color(0xFFFFFFFF).withOpacity(0.10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  child: ListTile(
                                    leading: const Icon(Icons.announcement, color: Colors.cyanAccent),
                                    title: Text(a['title'] ?? 'Announcement', style: const TextStyle(color: Colors.white)),
                                    subtitle: Text(
                                      '${a['message'] ?? ''}\n${ts.day}/${ts.month}/${ts.year}',
                                      style: TextStyle(color: const Color(0xFFFFFFFF).withOpacity(0.70)),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 20),

                          // Calendar Widget
                          _buildSectionHeader("Calendar"),
                          _buildNavigableCalendar(_eventDates),
                          const SizedBox(height: 20),
                          
                          // Quick Stats Cards (Horizontal scroll to prevent overflow)
                          _buildSectionHeader("Quick Stats"),
                          Container(
  height: 110, // Prevents vertical overflow
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _buildStatCard("Classes", _classCount, Icons.class_),
        const SizedBox(width: 10),
        _buildStatCard("Subjects", _subjectCount, Icons.book),
        const SizedBox(width: 10),
        _buildStatCard("Events", _eventCount, Icons.event),
        const SizedBox(width: 10),
        _buildStatCard("Attendance", _attendance, Icons.check_circle),
        // Removed the last SizedBox(width: 10)
      ],
    ),
  ),
),
const SizedBox(height: 35),

                          // Motivational Quote/Tip
                          _buildSectionHeader("Motivational Quote"),
                          Card(
                            color: const Color(0xFFFFFFFF).withOpacity(0.10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                _quote,
                                style: TextStyle(color: const Color(0xFFFFFFFF).withOpacity(0.70), fontSize: 16, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets and Functions (moved outside build) ---

  Widget _buildNavigableCalendar(List<DateTime> eventDates) {
    final now = DateTime.now();
    final firstDay = DateTime(_calendarYear, _calendarMonth, 1);
    final lastDay = DateTime(_calendarYear, _calendarMonth + 1, 0);
    final daysInMonth = lastDay.day;
    final int firstWeekday = firstDay.weekday % 7;
    final int totalCells = ((firstWeekday + daysInMonth) / 7).ceil() * 7;
    
    return Card(
      color: const Color(0xFFFFFFFF).withOpacity(0.10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.cyanAccent),
                  onPressed: () => _changeCalendarMonth(-1),
                  tooltip: 'Previous month',
                ),
                Text(
                  "${_monthName(_calendarMonth)} $_calendarYear",
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.cyanAccent),
                  onPressed: () => _changeCalendarMonth(1),
                  tooltip: 'Next month',
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("S", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                Text("M", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                Text("T", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                Text("W", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                Text("T", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                Text("F", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                Text("S", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1,
              ),
              itemCount: totalCells,
              itemBuilder: (context, index) {
                final int dayNum = index - firstWeekday + 1;
                if (index < firstWeekday || dayNum > daysInMonth) {
                  return const SizedBox.shrink();
                }
                final date = DateTime(_calendarYear, _calendarMonth, dayNum);
                final isToday = date.day == now.day && date.month == now.month && date.year == now.year;
                final hasEvent = eventDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
                return Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: hasEvent ? Colors.cyanAccent : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isToday ? Colors.yellowAccent : Colors.white30,
                      width: isToday ? 2.0 : 1.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        color: hasEvent ? Colors.black : Colors.white,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon) {
  return Card(
    color: const Color(0xFFFFFFFF).withOpacity(0.15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      // The `constraints` are okay, but we'll remove the fixed height to fix the overflow.
      constraints: const BoxConstraints(minWidth: 90, maxWidth: 120),
      // Removed: height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(8),
      child: Column(
        // Use `MainAxisSize.min` to ensure the column only takes up the space it needs.
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 32),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            // Prevents text from overflowing horizontally.
            overflow: TextOverflow.ellipsis,
          ),
          // Adding a `Flexible` widget ensures the label text will wrap if needed, preventing overflow.
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

String _monthName(int month) {
  const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  return months[month - 1];
}