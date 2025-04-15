import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/biometric_data.dart';

class StressChart extends StatelessWidget {
  final List<BiometricData> data;

  const StressChart({super.key, required this.data});

  Color _stressColor(String level) {
    switch (level) {
      case 'high':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, _) {
                  int index = value.toInt();
                  if (index < data.length) {
                    return Text(data[index].timestamp
                        .toIso8601String()
                        .substring(11, 19));
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
          barGroups: data
              .asMap()
              .entries
              .map(
                (e) => BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: e.value.heartRate.toDouble(),
                      color: _stressColor(e.value.stressLevel),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
