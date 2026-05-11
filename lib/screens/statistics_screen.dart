import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_traker/provider/time_entry_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';
import 'package:time_traker/models/project.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Statistics')),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, child) {
          if (provider.entries.isEmpty) {
            return const Center(child: Text('No data to visualize yet.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project Distribution',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sections: _getProjectSections(provider),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Daily Activity (Last 7 Days)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      barGroups: _getDailyGroups(provider),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final date = DateTime.now().subtract(
                                Duration(days: 6 - value.toInt()),
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('${date.day}/${date.month}'),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _getProjectSections(TimeEntryProvider provider) {
    final Map<String, double> data = {};
    for (var entry in provider.entries) {
      data[entry.projectId] = (data[entry.projectId] ?? 0) + entry.totalTime;
    }

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.teal,
    ];
    int index = 0;

    return data.entries.map((e) {
      final project = provider.projects.firstWhere(
        (p) => p.id == e.key,
        orElse: () => Project(id: '', name: 'Unknown'),
      );
      final color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        color: color,
        value: e.value,
        title: '${project.name}\n${e.value.toStringAsFixed(1)}h',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _getDailyGroups(TimeEntryProvider provider) {
    final Map<int, double> dailyData = {};
    final now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: i));
      final dayEntries = provider.entries.where(
        (e) =>
            e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day,
      );

      double total = 0;
      for (var entry in dayEntries) {
        total += entry.totalTime;
      }
      dailyData[6 - i] = total;
    }

    return dailyData.entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value,
            color: Colors.deepPurple,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }
}
