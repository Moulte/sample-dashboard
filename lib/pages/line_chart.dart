import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MyLineChart extends StatelessWidget {
  const MyLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(show: true),
            borderData: FlBorderData(show: true),
            minX: 0,
            maxX: 4,
            minY: 0,
            maxY: 4,
            lineBarsData: [
              LineChartBarData(
                spots: const [
                  FlSpot(0, 1),
                  FlSpot(1, 1.5),
                  FlSpot(2, 3),
                  FlSpot(3, 2.5),
                  FlSpot(4, 4),
                ],
                isCurved: true,
                barWidth: 3,
                color: Colors.blue,
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
