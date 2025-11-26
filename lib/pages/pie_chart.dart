import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MyPieChart extends StatefulWidget {
  const MyPieChart({super.key});

  @override
  State<MyPieChart> createState() => _MyPieChartWithTooltipState();
}

class _MyPieChartWithTooltipState extends State<MyPieChart> {
  int? touchedIndex;

  final sectionsData = <Map<String, Object>>[
    {'label': 'Blue', 'value': 40.0, 'color': Colors.blue},
    {'label': 'Green', 'value': 30.0, 'color': Colors.green},
    {'label': 'Red', 'value': 30.0, 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 300,
            height: 300,
            child: PieChart(
              PieChartData(
                sectionsSpace: 6,
                centerSpaceRadius: 50,
                // touchCallback : on met à jour touchedIndex
                pieTouchData: PieTouchData(
                  enabled: true,
                  touchCallback: (FlTouchEvent event, PieTouchResponse? resp) {
                    // si on quitte (pointer up/out) on retire le touchedIndex
                    if (event is FlPointerExitEvent || event is FlTapUpEvent && resp == null) {
                      setState(() => touchedIndex = null);
                      return;
                    }

                    final idx = resp?.touchedSection?.touchedSectionIndex;
                    if (idx == null) {
                      setState(() => touchedIndex = null);
                    } else {
                      setState(() => touchedIndex = idx);
                    }
                  },
                ),
                sections: List.generate(sectionsData.length, (i) {
                  final data = sectionsData[i];
                  final isTouched = i == touchedIndex;
                  final value = data['value'] as double;
                  final label = data['label'] as String;
                  final color = data['color'] as Color;

                  return PieChartSectionData(
                    value: value,
                    color: color,
                    // agrandit la part quand elle est touchée
                    radius: isTouched ? 110 : 90,
                    title: '${value.toInt()}%',
                    titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    // badgeWidget : on affiche un petit badge (tooltip-like) sur la part touchée
                    badgeWidget: isTouched ? _buildBadge(label, value, color) : null,
                    badgePositionPercentageOffset: 1.2, // décale le badge hors du cercle
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, double value, Color color) {
    return Material(
      // Material pour obtenir elevation et background propre
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Text('$label — ${value.toInt()}%', style: TextStyle(color: color, fontSize: 12)),
      ),
    );
  }
}
