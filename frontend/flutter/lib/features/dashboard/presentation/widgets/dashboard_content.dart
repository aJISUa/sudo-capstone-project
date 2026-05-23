import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:oncare/design_system/charts/app_line_chart.dart';
import 'package:oncare/design_system/molecules/chart_card.dart';
import 'package:oncare/design_system/molecules/metric_card.dart';
import 'package:oncare/design_system/molecules/section_header.dart';
import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/dashboard/domain/entities/dashboard_summary.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({required this.summary, super.key});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final caloriesPct = (summary.caloriesToday / summary.caloriesGoal * 100)
        .round();
    final weightSpots = <FlSpot>[
      for (int i = 0; i < summary.weeklyWeight.length; i++)
        FlSpot(i.toDouble(), summary.weeklyWeight[i]),
    ];
    final firstWeight = summary.weeklyWeight.first;
    final lastWeight = summary.weeklyWeight.last;
    final weightDelta = lastWeight - firstWeight;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        const SectionHeader('오늘의 요약'),
        Row(
          children: <Widget>[
            Expanded(
              child: MetricCard(
                title: '칼로리',
                value: summary.caloriesToday.toString(),
                unit: 'kcal',
                delta: '$caloriesPct% of ${summary.caloriesGoal}',
                icon: Icons.restaurant,
                accentColor: AppColors.domainDiet,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: MetricCard(
                title: '운동',
                value: summary.exerciseMinutesToday.toString(),
                unit: '분',
                icon: Icons.fitness_center,
                accentColor: AppColors.domainExercise,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        MetricCard(
          title: '체중',
          value: summary.weightKg.toStringAsFixed(1),
          unit: 'kg',
          delta:
              '${weightDelta >= 0 ? '+' : ''}${weightDelta.toStringAsFixed(1)} '
              'vs 지난주',
          deltaTone: weightDelta <= 0
              ? MetricDeltaTone.positive
              : MetricDeltaTone.negative,
          icon: Icons.favorite_outline,
          accentColor: AppColors.domainHealth,
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader('체중 추이 (7일)'),
        ChartCard(
          title: '주간 체중',
          height: 160,
          child: AppLineChart(
            color: AppColors.domainHealth,
            spots: weightSpots,
          ),
        ),
      ],
    );
  }
}
