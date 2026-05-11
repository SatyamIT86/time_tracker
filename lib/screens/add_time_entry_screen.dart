import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_traker/models/time_entry.dart';
import 'package:time_traker/provider/time_entry_provider.dart';

class AddTimeEntryScreen extends StatefulWidget {
  const AddTimeEntryScreen({super.key});

  @override
  State<AddTimeEntryScreen> createState() => _AddTimeEntryScreenState();
}

class _AddTimeEntryScreenState extends State<AddTimeEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  String? projectId;
  String? taskId;
  double totalTime = 0.0;
  DateTime date = DateTime.now();
  String notes = '';

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Time Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: projectId,
                onChanged: (String? newValue) {
                  setState(() {
                    projectId = newValue;
                  });
                },
                decoration: const InputDecoration(labelText: 'Project'),
                validator: (value) =>
                    value == null ? 'Please select a project' : null,
                items: provider.projects
                    .map<DropdownMenuItem<String>>((project) {
                  return DropdownMenuItem<String>(
                    value: project.id,
                    child: Text(project.name),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: taskId,
                onChanged: (String? newValue) {
                  setState(() {
                    taskId = newValue;
                  });
                },
                decoration: const InputDecoration(labelText: 'Task'),
                validator: (value) =>
                    value == null ? 'Please select a task' : null,
                items: provider.tasks.map<DropdownMenuItem<String>>((task) {
                  return DropdownMenuItem<String>(
                    value: task.id,
                    child: Text(task.name),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Total Time (hours)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total time';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => totalTime = double.parse(value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Notes'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter some notes';
                  }
                  return null;
                },
                onSaved: (value) => notes = value!,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Provider.of<TimeEntryProvider>(
                      context,
                      listen: false,
                    ).addTimeEntry(
                      TimeEntry(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        projectId: projectId!,
                        taskId: taskId!,
                        totalTime: totalTime,
                        date: date,
                        notes: notes,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
