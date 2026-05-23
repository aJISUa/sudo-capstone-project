import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:oncare/design_system/atoms/app_card.dart';
import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/radius.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/dashboard/domain/entities/dashboard_summary.dart';

/// The Home tab body — five stacked cards matching the React original
/// `Dashboard.tsx`:
///   1. greeting line
///   2. gradient quick-input card (체중 · 혈압 · 혈당)
///   3. 오늘의 건강 요약 (sodium warning + 4 progress bars + quick stats)
///   4. 오늘의 일정 (schedule list + "전체보기")
///   5. 이번 주 건강 점수 (green gradient)
class DashboardContent extends StatelessWidget {
  const DashboardContent({
    required this.summary,
    this.onQuickInputWeight,
    this.onQuickInputBloodPressure,
    this.onQuickInputBloodSugar,
    this.onOpenSchedule,
    super.key,
  });

  final DashboardSummary summary;
  final VoidCallback? onQuickInputWeight;
  final VoidCallback? onQuickInputBloodPressure;
  final VoidCallback? onQuickInputBloodSugar;
  final VoidCallback? onOpenSchedule;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      const _Greeting(),
      _QuickInputCard(
        onWeight: onQuickInputWeight,
        onBloodPressure: onQuickInputBloodPressure,
        onBloodSugar: onQuickInputBloodSugar,
      ),
      _HealthSummaryCard(summary: summary),
      _ScheduleCard(items: summary.todaySchedule, onOpenAll: onOpenSchedule),
      _WeekScoreCard(score: summary.weekScore, delta: summary.weekScoreDelta),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 672),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xxxl,
          ),
          children: <Widget>[
            for (int i = 0; i < cards.length; i++) ...<Widget>[
              cards[i]
                  .animate()
                  .fadeIn(
                    duration: const Duration(milliseconds: 280),
                    delay: Duration(milliseconds: 50 * i),
                  )
                  .slideY(begin: 0.06, end: 0, curve: Curves.easeOutCubic),
              if (i < cards.length - 1) const SizedBox(height: AppSpacing.xl),
            ],
          ],
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();
  @override
  Widget build(BuildContext context) {
    return Text(
      '오늘도 건강한 하루 되세요 ☀️',
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedForeground),
    );
  }
}

class _QuickInputCard extends StatelessWidget {
  const _QuickInputCard({
    this.onWeight,
    this.onBloodPressure,
    this.onBloodSugar,
  });

  final VoidCallback? onWeight;
  final VoidCallback? onBloodPressure;
  final VoidCallback? onBloodSugar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.all(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '오늘의 건강 기록',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _QuickButton(emoji: '⚖️', label: '체중', onTap: onWeight),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _QuickButton(
                  emoji: '❤️',
                  label: '혈압',
                  onTap: onBloodPressure,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _QuickButton(
                  emoji: '💉',
                  label: '혈당',
                  onTap: onBloodSugar,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({required this.emoji, required this.label, this.onTap});

  final String emoji;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: const BorderRadius.all(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            children: <Widget>[
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthSummaryCard extends StatelessWidget {
  const _HealthSummaryCard({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '오늘의 건강 요약',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (summary.sodiumWarning != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.10),
                borderRadius: const BorderRadius.all(AppRadius.lg),
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.20),
                ),
              ),
              child: Text(
                '${summary.sodiumWarning!} 🥗',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          for (final i in summary.indicators) ...<Widget>[
            _IndicatorRow(indicator: i),
            const SizedBox(height: AppSpacing.md),
          ],
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _QuickStat(
                  icon: Icons.restaurant_outlined,
                  label: '식단 기록',
                  value: summary.dietEntries.toString(),
                  unit: '회',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _QuickStat(
                  icon: Icons.fitness_center_outlined,
                  label: '운동 시간',
                  value: summary.exerciseMinutes.toString(),
                  unit: '분',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({required this.indicator});
  final HealthIndicator indicator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = indicator.overBudget ? AppColors.warning : AppColors.primary;
    final valueColor = indicator.overBudget
        ? AppColors.warning
        : AppColors.foreground;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(indicator.label, style: theme.textTheme.bodyMedium),
            Text(
              '${indicator.current} / ${indicator.max} ${indicator.unit}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          child: LinearProgressIndicator(
            value: indicator.progress,
            minHeight: 8,
            backgroundColor: AppColors.muted,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.all(AppRadius.lg),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: value,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.items, this.onOpenAll});

  final List<ScheduleItem> items;
  final VoidCallback? onOpenAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '오늘의 일정',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onOpenAll,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text('전체보기', style: TextStyle(fontSize: 13)),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final item in items) ...<Widget>[
            Material(
              color: AppColors.accent,
              borderRadius: const BorderRadius.all(AppRadius.lg),
              child: InkWell(
                onTap: onOpenAll,
                borderRadius: const BorderRadius.all(AppRadius.lg),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.all(AppRadius.lg),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item.emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.time,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: AppColors.mutedForeground,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (item != items.last) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _WeekScoreCard extends StatelessWidget {
  const _WeekScoreCard({required this.score, required this.delta});

  final int score;
  final int delta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            AppColors.scoreGradientStart,
            AppColors.scoreGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.all(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.trending_up, color: Colors.white, size: 24),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '이번 주 건강 점수',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    '$score점',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '지난 주보다 $delta점 상승했어요! 🎉',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
