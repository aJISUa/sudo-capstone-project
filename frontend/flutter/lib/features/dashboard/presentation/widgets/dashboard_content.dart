import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:oncare/design_system/charts/app_line_chart.dart';
import 'package:oncare/design_system/molecules/chart_card.dart';
import 'package:oncare/design_system/molecules/metric_card.dart';
import 'package:oncare/design_system/molecules/section_header.dart';
import 'package:oncare/design_system/responsive/responsive_builder.dart';
import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:oncare/gen/l10n/app_localizations.dart';

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

    final l = AppLocalizations.of(context);

    final caloriesCard = MetricCard(
      title: l.dashboardMetricCalories,
      value: summary.caloriesToday.toString(),
      unit: l.unitKcal,
      delta: l.dashboardCaloriesProgress(caloriesPct, summary.caloriesGoal),
      icon: Icons.restaurant,
      accentColor: AppColors.domainDiet,
    );
    final exerciseCard = MetricCard(
      title: l.dashboardMetricExercise,
      value: summary.exerciseMinutesToday.toString(),
      unit: l.unitMinutes,
      icon: Icons.fitness_center,
      accentColor: AppColors.domainExercise,
    );
    final weightCard = MetricCard(
      title: l.dashboardMetricWeight,
      value: summary.weightKg.toStringAsFixed(1),
      unit: l.unitKg,
      delta: l.dashboardWeightDelta(
        weightDelta >= 0 ? '+' : '',
        weightDelta.toStringAsFixed(1),
      ),
      deltaTone: weightDelta <= 0
          ? MetricDeltaTone.positive
          : MetricDeltaTone.negative,
      icon: Icons.favorite_outline,
      accentColor: AppColors.domainHealth,
    );
    final chartCard = ChartCard(
      title: l.dashboardChartWeightWeek,
      height: 160,
      child: AppLineChart(color: AppColors.domainHealth, spots: weightSpots),
    );

    final mobileTiles = <Widget>[
      Row(
        children: <Widget>[
          Expanded(child: caloriesCard),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: exerciseCard),
        ],
      ),
      weightCard,
      chartCard,
    ];

    return ResponsiveBuilder(
      mobile: (_) => _MobileLayout(tiles: mobileTiles),
      tablet: (_) => _WideLayout(
        leftColumn: <Widget>[caloriesCard, exerciseCard, weightCard],
        rightColumn: <Widget>[chartCard],
      ),
      desktop: (_) => _WideLayout(
        leftColumn: <Widget>[caloriesCard, exerciseCard, weightCard],
        rightColumn: <Widget>[chartCard],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.tiles});
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        SectionHeader(l.dashboardSectionToday),
        for (int i = 0; i < tiles.length; i++) ...<Widget>[
          tiles[i]
              .animate()
              .fadeIn(
                duration: const Duration(milliseconds: 320),
                delay: Duration(milliseconds: 60 * i),
              )
              .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
          if (i < tiles.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.leftColumn, required this.rightColumn});

  final List<Widget> leftColumn;
  final List<Widget> rightColumn;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget column(List<Widget> items) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            items[i],
            if (i < items.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SectionHeader(l.dashboardSectionToday),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: column(leftColumn)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: column(rightColumn)),
            ],
          ),
        ],
      ),
    );
  }
}
