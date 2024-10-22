import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CurrentUsageChart extends StatelessWidget {
  final double currentLoad;
  final double currentSolarGeneration;

  const CurrentUsageChart({
    Key? key,
    required this.currentLoad,
    required this.currentSolarGeneration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = currentLoad + currentSolarGeneration;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Limit the height of the chart
          Container(
            height: 200, // Set a specific height for the chart
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: currentLoad,
                    color: Colors.red,
                    title: '${(currentLoad / total * 100).toStringAsFixed(1)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: currentSolarGeneration,
                    color: Colors.green,
                    title:
                        '${(currentSolarGeneration / total * 100).toStringAsFixed(1)}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 8), // Add a little space after the chart
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
