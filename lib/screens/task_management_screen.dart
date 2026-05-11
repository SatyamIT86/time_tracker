import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_traker/provider/time_entry_provider.dart';
import 'package:time_traker/widgets/add_task_dialog.dart';

import '../models/task.dart';

class TaskManagementScreen extends StatelessWidget {
  const TaskManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Tasks')),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          if (provider.tasks.isEmpty) {
            return const Center(child: Text('No tasks added yet.'));
          }
          return ListView.builder(
            itemCount: provider.tasks.length,
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              return ListTile(
                title: Text(task.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.deleteTask(task.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final String? name = await showDialog<String>(
            context: context,
            builder: (context) => AddTaskDialog(),
          );

          if (name != null && name.isNotEmpty) {
            final newTask = Task(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: name,
            );
            // ignore: use_build_context_synchronously
            Provider.of<TimeEntryProvider>(
              context,
              listen: false,
            ).addTask(newTask);
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }
}
