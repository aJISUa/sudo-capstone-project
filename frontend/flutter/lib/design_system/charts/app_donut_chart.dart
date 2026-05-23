import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:oncare/design_system/tokens/spacing.dart';

class AppDonutSegment {
  const AppDonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;
}

/// Donut chart + simple legend. Used by dietary macro breakdowns,
/// weekly category splits, etc.
class AppDonutChart extends StatelessWidget {
  const AppDonutChart({required this.segments, super.key});

  final List<AppDonutSegment> segments;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 32,
              sections: <PieChartSectionData>[
                for (final s in segments)
                  PieChartSectionData(
                    value: s.value,
                    color: s.color,
                    radius: 28,
                    showTitle: false,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(child: _Legend(segments: segments)),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.segments});
  final List<AppDonutSegment> segments;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final s in segments)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: <Widget>[
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: s.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${s.label} (${s.value.toStringAsFixed(0)})',
                  style: t.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
