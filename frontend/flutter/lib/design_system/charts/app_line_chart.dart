import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Minimal `LineChart` wrapper. Pass [spots] (FlSpot x/y), optional
/// brand colour. Feature charts that need axis labels or multi-series
/// can either compose around this or copy and extend.
class AppLineChart extends StatelessWidget {
  const AppLineChart({required this.spots, this.color, super.key});

  final List<FlSpot> spots;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: c,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: c.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }
}
