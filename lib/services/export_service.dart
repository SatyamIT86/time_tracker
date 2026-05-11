import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:time_traker/models/time_entry.dart';
import 'package:time_traker/models/project.dart';
import 'package:time_traker/models/task.dart';

class ExportService {
  static Future<void> exportToCsv(List<TimeEntry> entries, List<Project> projects, List<Task> tasks) async {
    List<List<dynamic>> rows = [];

    // Header
    rows.add(["ID", "Project", "Task", "Total Time (h)", "Date", "Notes"]);

    for (var entry in entries) {
      final project = projects.firstWhere((p) => p.id == entry.projectId, orElse: () => Project(id: '', name: 'Unknown')).name;
      final task = tasks.firstWhere((t) => t.id == entry.taskId, orElse: () => Task(id: '', name: 'Unknown')).name;
      
      rows.add([
        entry.id,
        project,
        task,
        entry.totalTime.toStringAsFixed(2),
        entry.date.toString(),
        entry.notes,
      ]);
    }

    String csvData = const ListToCsvConverter().convert(rows);
    
    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/time_entries_${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);
    await file.writeAsString(csvData);

    await Share.shareXFiles([XFile(path)], text: 'Exported Time Entries');
  }
}
