import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'create_class_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<String> usernameFuture;
  late Timer _timer;
  late String greetingAnimation;
  late String greetingText;

  List<Map<String, dynamic>> classInvitations = [
    {
      "year": "3rd Year",
      "dept": "AI&DS",
      "section": "B",
      "subject": "Machine Learning",
      "role": "HS",
    },
  ];

  List<Map<String, dynamic>> assignedClasses = [];

  List<String> recentActivities = [
    "Created timetable for 2nd Year A",
    "Updated timetable for 3rd Year B",
    "Joined as HS for ML – 3rd Year B",
  ];

  @override
  void initState() {
    super.initState();
    usernameFuture = _loadUsername();
    _updateGreeting();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _updateGreeting());
    });
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<String> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'User';
  }

  bool _hasNextClass() {
    final now = DateTime.now();
    final currentTime = DateFormat('HH:mm').format(now);
    return int.parse(currentTime.split(":")[1]) % 2 == 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Lottie.asset('assets/animations/profile.json', fit: BoxFit.cover, repeat: false),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/settings'),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Lottie.asset('assets/animations/settingsicon.json', fit: BoxFit.cover, repeat: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: usernameFuture,
                    builder: (context, snapshot) {
                      String welcomeText = "Welcome!";
                      if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                        welcomeText = "$greetingText, ${snapshot.data}!";
                      }
                        return Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(welcomeText, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const SizedBox(height: 8),
                                  Container(height: 2, width: 60, color: Colors.cyanAccent),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: Lottie.asset(greetingAnimation, fit: BoxFit.contain, repeat: true),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Your Next Class", style: TextStyle(fontSize: 24, color: Colors.white70)),
                    ),
                    const SizedBox(height: 12),
                    _hasNextClass()
                        ? Card(
                            color: Colors.white.withOpacity(0.1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: ListTile(
                              leading: const Icon(Icons.class_, color: Colors.cyanAccent, size: 36),
                              title: const Text("2nd Year CSE", style: TextStyle(color: Colors.white, fontSize: 20)),
                              subtitle: const Text("Next: Data Structures at 10:00 AM", style: TextStyle(color: Colors.white70)),
                            ),
                          )
                        : Column(
                            children: [
                              SizedBox(
                                height: 100,
                                child: Lottie.asset('assets/animations/no_class.json', fit: BoxFit.contain),
                              ),
                              const SizedBox(height: 8),
                              const Text("No upcoming classes! 🎉", style: TextStyle(color: Colors.white, fontSize: 18)),
                            ],
                          ),

                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Recent Activities", style: TextStyle(fontSize: 24, color: Colors.white70)),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentActivities.length,
                      itemBuilder: (context, index) => ListTile(
                        leading: const Icon(Icons.check_circle, color: Colors.cyanAccent),
                        title: Text(recentActivities[index], style: const TextStyle(color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Create Class", style: TextStyle(fontSize: 24, color: Colors.white70)),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/create_class_screen');
                          },
                          child: const Text("+ Create Class"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Assigned Classes", style: TextStyle(fontSize: 24, color: Colors.white70)),
                    ),

                    const SizedBox(height: 12),

                    if (classInvitations.isNotEmpty)
                      ...classInvitations.map(_buildInvitationCard).toList(),

                    if (assignedClasses.isNotEmpty)
                      ...assignedClasses.map(_buildAssignedCard).toList(),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInvitationCard(Map<String, dynamic> invitation) {
    return Card(
      color: Colors.white.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text("${invitation["subject"]} - ${invitation["year"]} ${invitation["dept"]} ${invitation["section"]}", style: const TextStyle(color: Colors.white)),
        subtitle: Text("Role: ${invitation["role"]}", style: const TextStyle(color: Colors.white70)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.greenAccent),
              onPressed: () => _showConfirmationDialog(invitation, true),
            ),
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.redAccent),
              onPressed: () => _showConfirmationDialog(invitation, false),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(Map<String, dynamic> invitation, bool isAccepting) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isAccepting ? 'Accept Role' : 'Reject Role'),
          content: Text("Are you sure you want to ${isAccepting ? 'accept' : 'reject'} this role?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (isAccepting) {
                    assignedClasses.add(invitation);
                  }
                  classInvitations.remove(invitation);
                });
                Navigator.of(context).pop();
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAssignedCard(Map<String, dynamic> classInfo) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text("${classInfo["year"]} ${classInfo["dept"]} ${classInfo["section"]}", style: const TextStyle(color: Colors.white, fontSize: 18)),
        subtitle: Text("Role: ${classInfo["role"]} | Subject: ${classInfo["subject"]}", style: const TextStyle(color: Colors.white70)),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/view_timetable', arguments: classInfo);
          },
          child: const Text("View Timetable"),
        ),
      ),
    );
  }
}
// This is the end of the code for the DashboardScreen.
// It includes the main structure, greeting logic, class invitations, and recent activities.