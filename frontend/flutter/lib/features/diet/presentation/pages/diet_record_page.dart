import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/errors/app_error.dart';
import 'package:oncare/design_system/charts/app_donut_chart.dart';
import 'package:oncare/design_system/molecules/chart_card.dart';
import 'package:oncare/design_system/molecules/metric_card.dart';
import 'package:oncare/design_system/molecules/section_header.dart';
import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/diet/domain/entities/diet_day.dart';
import 'package:oncare/features/diet/presentation/controllers/diet_controller.dart';
import 'package:oncare/features/diet/presentation/widgets/meal_card.dart';
import 'package:oncare/gen/l10n/app_localizations.dart';
import 'package:oncare/shared/widgets/error_view.dart';

class DietRecordPage extends ConsumerWidget {
  const DietRecordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(dietTodayProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.pageDietTitle)),
      body: async.when(
        data: (day) => _Body(day: day),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ErrorView(
          error: e is AppError ? e : UnknownError(message: e.toString()),
          onRetry: () => ref.invalidate(dietTodayProvider),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.day});
  final DietDay day;

  @override
  Widget build(BuildContext context) {
    final macros = <AppDonutSegment>[
      AppDonutSegment(
        label: '탄수화물',
        value: day.macros.carbsPct.toDouble(),
        color: AppColors.domainDiet,
      ),
      AppDonutSegment(
        label: '단백질',
        value: day.macros.proteinPct.toDouble(),
        color: AppColors.domainExercise,
      ),
      AppDonutSegment(
        label: '지방',
        value: day.macros.fatPct.toDouble(),
        color: AppColors.domainHealth,
      ),
    ];
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        MetricCard(
          title: '오늘 총 칼로리',
          value: day.totalCalories.toString(),
          unit: 'kcal',
          icon: Icons.restaurant,
          accentColor: AppColors.domainDiet,
        ),
        const SizedBox(height: AppSpacing.md),
        ChartCard(
          title: '영양소 분포',
          height: 180,
          child: AppDonutChart(segments: macros),
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader('오늘의 식단'),
        for (final entry in day.entries) ...<Widget>[
          MealCard(entry: entry),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
