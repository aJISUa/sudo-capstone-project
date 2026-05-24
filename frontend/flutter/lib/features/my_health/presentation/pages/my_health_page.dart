import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/errors/app_error.dart';
import 'package:oncare/design_system/atoms/app_avatar.dart';
import 'package:oncare/design_system/atoms/app_card.dart';
import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/radius.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/my_health/domain/entities/health_history.dart';
import 'package:oncare/features/my_health/presentation/controllers/my_health_controller.dart';
import 'package:oncare/features/notification/presentation/widgets/notification_panel.dart';
import 'package:oncare/gen/l10n/app_localizations.dart';
import 'package:oncare/shared/widgets/error_view.dart';
import 'package:oncare/shared/widgets/modals/right_slide_panel.dart';
import 'package:oncare/shared/widgets/modals/schedule_calendar_sheet.dart';
import 'package:oncare/shared/widgets/oncare_header.dart';

class MyHealthPage extends ConsumerWidget {
  const MyHealthPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(myHealthStateProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: <Widget>[
          OncareHeader(
            title: l.pageMyHealthTitle,
            onNotificationTap: () => showRightSlidePanel<void>(
              context,
              content: const NotificationPanelBody(),
            ),
            onCalendarTap: () => showScheduleCalendarSheet(context),
          ),
          Expanded(
            child: async.when(
              data: (s) => _Body(state: s),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object e, _) => ErrorView(
                error: e is AppError ? e : UnknownError(message: e.toString()),
                onRetry: () => ref.invalidate(myHealthStateProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});
  final MyHealthState state;

  @override
  Widget build(BuildContext context) {
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
            _ProfileCard(profile: state.profile),
            const SizedBox(height: AppSpacing.lg),
            _RiskCard(risk: state.risk),
            const SizedBox(height: AppSpacing.lg),
            const _SectionTitle('건강 지표 추이'),
            const SizedBox(height: AppSpacing.sm),
            for (final IndicatorTrend t in state.indicators) ...<Widget>[
              _IndicatorTile(trend: t),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.md),
            _PointsCard(points: state.activityPoints, rank: state.activityRank),
            const SizedBox(height: AppSpacing.lg),
            const _SectionTitle('설정'),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              outlined: true,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < state.settings.length; i++) ...<Widget>[
                    _SettingsRow(item: state.settings[i]),
                    if (i < state.settings.length - 1)
                      const Divider(
                        height: 1,
                        color: AppColors.border,
                        indent: AppSpacing.lg,
                        endIndent: AppSpacing.lg,
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
  );
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      outlined: true,
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[AppColors.primary, AppColors.secondary],
              ),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.background,
              child: AppAvatar(label: profile.name, size: 52),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.risk});
  final RiskAlert risk;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFFB923C), Color(0xFFEF4444)],
        ),
        borderRadius: BorderRadius.all(AppRadius.card),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(Icons.warning_amber_rounded, color: Colors.white),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  risk.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  risk.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
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

class _IndicatorTile extends StatelessWidget {
  const _IndicatorTile({required this.trend});
  final IndicatorTrend trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = trend.improving ? AppColors.success : AppColors.warning;
    return AppCard(
      outlined: true,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 80,
            height: 40,
            child: CustomPaint(
              painter: _SparklinePainter(values: trend.last7Days, color: color),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  trend.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: trend.latestValue,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: ' ${trend.unit}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: <Widget>[
                    Icon(
                      trend.improving ? Icons.trending_down : Icons.trending_up,
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      trend.deltaText,
                      style: theme.textTheme.bodySmall?.copyWith(color: color),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final fill = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final stepX = size.width / (values.length - 1);
    Offset point(int i) {
      final v = values[i].clamp(0, 1).toDouble();
      return Offset(stepX * i, size.height - v * size.height);
    }

    final path = Path()..moveTo(0, size.height);
    for (var i = 0; i < values.length; i++) {
      path.lineTo(point(i).dx, point(i).dy);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, fill);

    final line = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < values.length; i++) {
      line.lineTo(point(i).dx, point(i).dy);
    }
    canvas.drawPath(line, stroke);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.values != values || old.color != color;
}

class _PointsCard extends StatelessWidget {
  const _PointsCard({required this.points, required this.rank});
  final int points;
  final int rank;

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
      child: Row(
        children: <Widget>[
          const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '활동 포인트',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                Text(
                  '${points}P',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.20),
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(AppRadius.lg),
              ),
            ),
            child: Text('$rank위 랭킹'),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item});
  final SettingsItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: <Widget>[
            Text(item.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                item.label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.mutedForeground,
            ),
          ],
        ),
      ),
    );
  }
}
