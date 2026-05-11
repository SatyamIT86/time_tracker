import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_traker/provider/time_entry_provider.dart';
import 'package:time_traker/widgets/add_project_dialog.dart';

import '../models/project.dart';

class ProjectManagementScreen extends StatelessWidget {
  const ProjectManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Projects')),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          if (provider.projects.isEmpty) {
            return const Center(child: Text('No projects added yet.'));
          }
          return ListView.builder(
            itemCount: provider.projects.length,
            itemBuilder: (context, index) {
              final project = provider.projects[index];
              return ListTile(
                title: Text(project.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.deleteProject(project.id),
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
            builder: (context) => AddProjectDialog(),
          );

          if (name != null && name.isNotEmpty) {
            final newProject = Project(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              name: name,
            );
            // ignore: use_build_context_synchronously
            Provider.of<TimeEntryProvider>(context, listen: false)
                .addProject(newProject);
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Project',
      ),
    );
  }
}
