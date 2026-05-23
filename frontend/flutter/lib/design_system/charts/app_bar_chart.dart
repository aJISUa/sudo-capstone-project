import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// Simple categorical bar chart. [values] is the y-axis data;
/// [labels] (optional) is rendered along the x-axis at matching
/// indices.
class AppBarChart extends StatelessWidget {
  const AppBarChart({required this.values, this.labels, this.color, super.key});

  final List<double> values;
  final List<String>? labels;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    final theme = Theme.of(context);
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: labels != null,
              getTitlesWidget: (double value, TitleMeta meta) {
                final i = value.toInt();
                final ls = labels;
                if (ls == null || i < 0 || i >= ls.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(ls[i], style: theme.textTheme.bodySmall),
                );
              },
            ),
          ),
        ),
        barGroups: <BarChartGroupData>[
          for (int i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: <BarChartRodData>[
                BarChartRodData(
                  toY: values[i],
                  color: c,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
