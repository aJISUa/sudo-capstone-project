import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/errors/app_error.dart';
import 'package:oncare/design_system/atoms/app_badge.dart';
import 'package:oncare/design_system/atoms/app_card.dart';
import 'package:oncare/design_system/charts/app_bar_chart.dart';
import 'package:oncare/design_system/molecules/chart_card.dart';
import 'package:oncare/design_system/molecules/metric_card.dart';
import 'package:oncare/design_system/molecules/section_header.dart';
import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/exercise/domain/entities/exercise_week.dart';
import 'package:oncare/features/exercise/presentation/controllers/exercise_controller.dart';
import 'package:oncare/gen/l10n/app_localizations.dart';
import 'package:oncare/shared/widgets/error_view.dart';

String _typeLabel(ExerciseType t) => switch (t) {
  ExerciseType.cardio => '유산소',
  ExerciseType.strength => '근력',
  ExerciseType.yoga => '요가',
  ExerciseType.walking => '걷기',
};

class ExercisePage extends ConsumerWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(exerciseWeekProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.pageExerciseTitle)),
      body: async.when(
        data: (w) => _Body(week: w),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => ErrorView(
          error: e is AppError ? e : UnknownError(message: e.toString()),
          onRetry: () => ref.invalidate(exerciseWeekProvider),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.week});
  final ExerciseWeek week;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: MetricCard(
                title: '이번 주 총 시간',
                value: week.totalMinutes.toString(),
                unit: '분',
                icon: Icons.timer_outlined,
                accentColor: AppColors.domainExercise,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: MetricCard(
                title: '하루 평균',
                value: week.averageMinutes.toStringAsFixed(0),
                unit: '분',
                icon: Icons.show_chart,
                accentColor: AppColors.domainExercise,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ChartCard(
          title: '주간 운동 시간',
          child: AppBarChart(
            color: AppColors.domainExercise,
            values: week.dailyMinutes,
            labels: week.dayLabels,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader('세션 기록'),
        for (final s in week.sessions) ...<Widget>[
          AppCard(
            child: Row(
              children: <Widget>[
                AppBadge(label: _typeLabel(s.type)),
                const SizedBox(width: AppSpacing.sm),
                Text(s.dayLabel, style: theme.textTheme.bodySmall),
                const Spacer(),
                Text(
                  '${s.minutes}분 · ${s.calories} kcal',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}
