import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MyBarChart extends StatefulWidget {
  const MyBarChart({super.key});

  @override
  State<MyBarChart> createState() => _MyBarChartWithTooltipState();
}

class _MyBarChartWithTooltipState extends State<MyBarChart> {
  int? touchedIndex;

  final List<Map<String, Object>> barData = [
    {'label': 'A', 'value': 8.0, 'color': Colors.blue},
    {'label': 'B', 'value': 12.0, 'color': Colors.green},
    {'label': 'C', 'value': 15.0, 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 20,
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final idx = value.toInt();
                    if (idx >= 0 && idx < barData.length) {
                      return Text(barData[idx]['label'] as String);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),

            borderData: FlBorderData(show: true),

            // ✅ Touch / surbrillance / tooltip
            barTouchData: BarTouchData(
              enabled: true,
              touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                if (!event.isInterestedForInteractions || response == null || response.spot == null) {
                  setState(() => touchedIndex = null);
                  return;
                }
                setState(() => touchedIndex = response.spot!.touchedBarGroupIndex);
              },
            ),

            barGroups: List.generate(barData.length, (i) {
              final data = barData[i];
              final isTouched = i == touchedIndex;
              final double y = data['value'] as double;
              final Color color = data['color'] as Color;
              final double width = 18; // barre plus large au survol

              return BarChartGroupData(
                x: i,
                barRods: [BarChartRodData(toY: y, color: color, width: width, borderRadius: BorderRadius.circular(6))],
                showingTooltipIndicators: isTouched ? [0] : [],
              );
            }),
          ),
        ),
      ),
    );
  }
}
