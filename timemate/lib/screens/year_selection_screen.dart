import 'package:flutter/material.dart';

class YearSelectionScreen extends StatelessWidget {
  const YearSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final years = ["1st Year", "2nd Year", "3rd Year", "4th Year"];
    return Scaffold(
      appBar: AppBar(title: const Text("Select Year")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: years.length,
              itemBuilder:
                  (context, index) => ListTile(
                    title: Text(years[index]),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pushNamed(context, '/timetable');
                    },
                  ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  icon: const Icon(Icons.person),
                  label: const Text("Profile"),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text("Settings"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// This screen allows users to select their academic year and navigate to the timetable view.
// It includes a list of years and buttons for profile and settings navigation.
