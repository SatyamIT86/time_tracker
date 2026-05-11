import 'dart:async';
import 'package:flutter/material.dart';
import 'package:time_traker/models/time_entry.dart';
import 'package:time_traker/models/project.dart';
import 'package:time_traker/models/task.dart';
import 'package:uuid/uuid.dart';

enum SortBy { date, duration, project }

class TimeEntryProvider with ChangeNotifier {
  List<TimeEntry> _entries = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];

  // Filter and Sort states
  SortBy _sortBy = SortBy.date;
  String? _filterProjectId;
  String? _filterTaskId;
  DateTimeRange? _filterDateRange;

  // Timer states
  Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  Duration _currentTimerDuration = Duration.zero;
  String? _activeProjectId;
  String? _activeTaskId;
  bool _isTimerPaused = false;

  List<TimeEntry> get entries => _entries;
  List<Project> get projects => _projects;
  List<Task> get tasks => _tasks;

  SortBy get sortBy => _sortBy;
  String? get filterProjectId => _filterProjectId;
  String? get filterTaskId => _filterTaskId;
  DateTimeRange? get filterDateRange => _filterDateRange;

  Duration get currentTimerDuration => _currentTimerDuration;
  String? get activeProjectId => _activeProjectId;
  String? get activeTaskId => _activeTaskId;
  bool get isTimerRunning => _stopwatch.isRunning;
  bool get isTimerPaused => _isTimerPaused;

  List<TimeEntry> get filteredAndSortedEntries {
    List<TimeEntry> list = List.from(_entries);

    // Filtering
    if (_filterProjectId != null) {
      list = list.where((e) => e.projectId == _filterProjectId).toList();
    }
    if (_filterTaskId != null) {
      list = list.where((e) => e.taskId == _filterTaskId).toList();
    }
    if (_filterDateRange != null) {
      list = list.where((e) => e.date.isAfter(_filterDateRange!.start) && e.date.isBefore(_filterDateRange!.end)).toList();
    }

    // Sorting
    switch (_sortBy) {
      case SortBy.date:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortBy.duration:
        list.sort((a, b) => b.totalTime.compareTo(a.totalTime));
        break;
      case SortBy.project:
        list.sort((a, b) {
          final pA = _projects.firstWhere((p) => p.id == a.projectId, orElse: () => Project(id: '', name: 'Unknown')).name;
          final pB = _projects.firstWhere((p) => p.id == b.projectId, orElse: () => Project(id: '', name: 'Unknown')).name;
          return pA.compareTo(pB);
        });
        break;
    }
    return list;
  }

  void setSortBy(SortBy sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void setFilters({String? projectId, String? taskId, DateTimeRange? dateRange}) {
    _filterProjectId = projectId;
    _filterTaskId = taskId;
    _filterDateRange = dateRange;
    notifyListeners();
  }

  void clearFilters() {
    _filterProjectId = null;
    _filterTaskId = null;
    _filterDateRange = null;
    notifyListeners();
  }

  // Timer Methods
  void startTimer(String projectId, String taskId) {
    _activeProjectId = projectId;
    _activeTaskId = taskId;
    _stopwatch.start();
    _isTimerPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentTimerDuration = _stopwatch.elapsed;
      notifyListeners();
    });
    notifyListeners();
  }

  void pauseTimer() {
    _stopwatch.stop();
    _isTimerPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  void resumeTimer() {
    _stopwatch.start();
    _isTimerPaused = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentTimerDuration = _stopwatch.elapsed;
      notifyListeners();
    });
    notifyListeners();
  }

  void stopTimer(String notes) {
    if (_activeProjectId == null || _activeTaskId == null) return;

    final duration = _stopwatch.elapsed;
    final totalHours = duration.inSeconds / 3600.0;

    addTimeEntry(TimeEntry(
      id: const Uuid().v4(),
      projectId: _activeProjectId!,
      taskId: _activeTaskId!,
      totalTime: totalHours,
      date: DateTime.now(),
      notes: notes,
    ));

    _stopwatch.stop();
    _stopwatch.reset();
    _timer?.cancel();
    _currentTimerDuration = Duration.zero;
    _activeProjectId = null;
    _activeTaskId = null;
    _isTimerPaused = false;
    notifyListeners();
  }

  void cancelTimer() {
    _stopwatch.stop();
    _stopwatch.reset();
    _timer?.cancel();
    _currentTimerDuration = Duration.zero;
    _activeProjectId = null;
    _activeTaskId = null;
    _isTimerPaused = false;
    notifyListeners();
  }

  void addTimeEntry(TimeEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void deleteTimeEntry(String id) {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void deleteProject(String id) {
    _projects.removeWhere((project) => project.id == id);
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();
  }
}
