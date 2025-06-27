import 'package:flutter/material.dart';

class AddClassPage extends StatefulWidget {
  const AddClassPage({super.key});

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  final _formKey = GlobalKey<FormState>();

  String _selectedDay = 'Monday';
  final List<Map<String, String>> _classRows = [
    {'subject': '', 'startTime': '', 'endTime': ''},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Day\'s Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedDay,
                items: const [
                  DropdownMenuItem(value: 'Monday', child: Text('Monday')),
                  DropdownMenuItem(value: 'Tuesday', child: Text('Tuesday')),
                  DropdownMenuItem(value: 'Wednesday', child: Text('Wednesday')),
                  DropdownMenuItem(value: 'Thursday', child: Text('Thursday')),
                  DropdownMenuItem(value: 'Friday', child: Text('Friday')),
                  DropdownMenuItem(value: 'Saturday', child: Text('Saturday')),
                ],
                onChanged: (value) => setState(() => _selectedDay = value!),
                decoration: const InputDecoration(labelText: 'Day'),
              ),
              const SizedBox(height: 16),
              ..._classRows.asMap().entries.map((entry) {
                final index = entry.key;
                final classData = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Subject ${index + 1}'),
                          validator: (value) => value!.isEmpty ? 'Enter subject' : null,
                          onSaved: (value) => classData['subject'] = value!,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: 'Start Time'),
                                validator: (value) => value!.isEmpty ? 'Enter start time' : null,
                                onSaved: (value) => classData['startTime'] = value!,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: 'End Time'),
                                validator: (value) => value!.isEmpty ? 'Enter end time' : null,
                                onSaved: (value) => classData['endTime'] = value!,
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() => _classRows.removeAt(index));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Another Class'),
                onPressed: () {
                  setState(() {
                    _classRows.add({'subject': '', 'startTime': '', 'endTime': ''});
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final result = _classRows.map((row) => {
                          'day': _selectedDay,
                          'subject': row['subject'],
                          'startTime': row['startTime'],
                          'endTime': row['endTime'],
                        }).toList();
                    Navigator.pop(context, result);
                  }
                },
                child: const Text('Save Schedule'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
