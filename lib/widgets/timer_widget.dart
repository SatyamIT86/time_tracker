import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_traker/provider/time_entry_provider.dart';
import 'package:time_traker/models/project.dart';
import 'package:time_traker/models/task.dart';

class TimerWidget extends StatelessWidget {
  const TimerWidget({super.key});

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimeEntryProvider>(
      builder: (context, provider, child) {
        if (!provider.isTimerRunning &&
            !provider.isTimerPaused &&
            provider.activeProjectId == null) {
          return const SizedBox.shrink();
        }

        final project = provider.projects.firstWhere(
          (p) => p.id == provider.activeProjectId,
          orElse: () => Project(id: '', name: 'Unknown Project'),
        );
        final task = provider.tasks.firstWhere(
          (t) => t.id == provider.activeTaskId,
          orElse: () => Task(id: '', name: 'Unknown Task'),
        );

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.deepPurple.shade50,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.timer, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            task.name,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDuration(provider.currentTimerDuration),
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => provider.cancelTimer(),
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (provider.isTimerPaused)
                      ElevatedButton.icon(
                        onPressed: () => provider.resumeTimer(),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Resume'),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => provider.pauseTimer(),
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                      ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final notes = await _showNotesDialog(context);
                        if (notes != null) {
                          provider.stopTimer(notes);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop & Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _showNotesDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Notes'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'What did you work on?'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// Add Project and Task models import if not available
