import 'package:flutter/material.dart';

class AddClassPage extends StatefulWidget {
  const AddClassPage({super.key});

  @override
  State<AddClassPage> createState() => _AddClassPageState();
}

class _ClassRowControllers {
  final subjectController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();

  void dispose() {
    subjectController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
  }
}

class _AddClassPageState extends State<AddClassPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedDay = 'Monday';
  final List<_ClassRowControllers> _controllers = [
    _ClassRowControllers(),
  ];

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

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
              ..._controllers.asMap().entries.map((entry) {
                final index = entry.key;
                final c = entry.value;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: c.subjectController,
                          decoration: InputDecoration(labelText: 'Subject ${index + 1}'),
                          validator: (value) => value!.isEmpty ? 'Enter subject' : null,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: c.startTimeController,
                                decoration: const InputDecoration(labelText: 'Start Time'),
                                validator: (value) => value!.isEmpty ? 'Enter start time' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: c.endTimeController,
                                decoration: const InputDecoration(labelText: 'End Time'),
                                validator: (value) => value!.isEmpty ? 'Enter end time' : null,
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _controllers.removeAt(index).dispose();
                              });
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
                    _controllers.add(_ClassRowControllers());
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final result = _controllers.map((c) => {
                          'day': _selectedDay,
                          'subject': c.subjectController.text,
                          'startTime': c.startTimeController.text,
                          'endTime': c.endTimeController.text,
                        }).toList();
                    Navigator.of(context).pop(result); // ✅ Correctly return data
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
