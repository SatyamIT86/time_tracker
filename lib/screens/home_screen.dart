import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_traker/models/project.dart';
import 'package:time_traker/models/task.dart';
import 'package:time_traker/provider/time_entry_provider.dart';
import 'package:time_traker/screens/add_time_entry_screen.dart';
import 'package:time_traker/screens/project_management_screen.dart';
import 'package:time_traker/screens/task_management_screen.dart';
import 'package:time_traker/screens/statistics_screen.dart';
import 'package:time_traker/widgets/timer_widget.dart';
import 'package:time_traker/services/export_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export CSV',
            onPressed: () => ExportService.exportToCsv(
              provider.entries,
              provider.projects,
              provider.tasks,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Time Tracker',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Time Entries'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Statistics'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatisticsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Manage Projects'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Manage Tasks'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskManagementScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SizeTransition(sizeFactor: animation, child: child);
            },
            child: const TimerWidget(),
          ),
          const Divider(height: 1),
          Expanded(
            child: Consumer<TimeEntryProvider>(
              builder: (context, provider, child) {
                final entries = provider.filteredAndSortedEntries;
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No time entries found',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final project = provider.projects.firstWhere(
                      (p) => p.id == entry.projectId,
                      orElse: () => Project(id: '', name: 'Unknown'),
                    );
                    final task = provider.tasks.firstWhere(
                      (t) => t.id == entry.taskId,
                      orElse: () => Task(id: '', name: 'Unknown'),
                    );

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.access_time,
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: Text(
                          project.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              task.name,
                              style: TextStyle(
                                color: Colors.deepPurple.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            if (entry.notes.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                entry.notes,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${entry.totalTime.toStringAsFixed(2)}h',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.deepPurple,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  provider.deleteTimeEntry(entry.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        child: const Icon(Icons.add),
        tooltip: 'Add Time',
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.green),
              title: const Text('Start Timer'),
              onTap: () {
                Navigator.pop(context);
                _showStartTimerDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Manual Entry'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTimeEntryScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStartTimerDialog(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context, listen: false);
    String? selectedProject;
    String? selectedTask;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Start Timer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Project'),
                items: provider.projects
                    .map(
                      (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedProject = val),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Task'),
                items: provider.tasks
                    .map(
                      (t) => DropdownMenuItem(value: t.id, child: Text(t.name)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => selectedTask = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedProject != null && selectedTask != null) {
                  provider.startTimer(selectedProject!, selectedTask!);
                  Navigator.pop(context);
                }
              },
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SortBy.values
              .map(
                (sort) => RadioListTile<SortBy>(
                  title: Text(sort.name.toUpperCase()),
                  value: sort,
                  groupValue: provider.sortBy,
                  onChanged: (val) {
                    provider.setSortBy(val!);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context, listen: false);
    String? projectId = provider.filterProjectId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: projectId,
                decoration: const InputDecoration(labelText: 'Project'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Projects'),
                  ),
                  ...provider.projects.map(
                    (p) => DropdownMenuItem(value: p.id, child: Text(p.name)),
                  ),
                ],
                onChanged: (val) => setState(() => projectId = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                provider.clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Clear'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.setFilters(projectId: projectId);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }
}
