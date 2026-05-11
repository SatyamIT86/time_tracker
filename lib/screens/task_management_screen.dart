import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_traker/provider/time_entry_provider.dart';

import '../models/task.dart';

class TaskManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Tasks')),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          // Lists for managing tasks would be implemented here
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new task
        },
        child: Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }
}
