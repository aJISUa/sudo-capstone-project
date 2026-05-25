import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/radius.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/my_health/domain/entities/health_history.dart';

/// Opens the 건강 지표 추이 modal for the given indicator.
/// Layout (top → bottom): 최근 측정값 card · 변화 추이 chart · 최근 기록 list
/// · 닫기 button. Matches the React prototype's modal closely.
Future<void> showIndicatorTrendModal(
  BuildContext context,
  IndicatorTrend trend,
) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext _) => Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(AppRadius.card),
      ),
      child: _IndicatorTrendDialog(trend: trend),
    ),
  );
}

String _titleFor(IndicatorKind kind) => switch (kind) {
  IndicatorKind.weight => '체중 변화',
  IndicatorKind.bloodPressure => '혈압 변화',
  IndicatorKind.bloodSugar => '혈당 변화',
};

class _IndicatorTrendDialog extends StatelessWidget {
  const _IndicatorTrendDialog({required this.trend});
  final IndicatorTrend trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480, maxHeight: 760),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    _titleFor(trend.kind),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _RoundCloseButton(onTap: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _LatestMeasurementCard(trend: trend),
            const SizedBox(height: AppSpacing.lg),
            _TrendChartCard(values: trend.chartValues),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '최근 기록',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (int i = 0; i < trend.recentRecords.length; i++) ...<Widget>[
              _RecordRow(record: trend.recentRecords[i]),
              if (i < trend.recentRecords.length - 1)
                const SizedBox(height: AppSpacing.xs),
            ],
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(AppRadius.lg),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundCloseButton extends StatelessWidget {
  const _RoundCloseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.muted,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 32,
          height: 32,
          child: Icon(Icons.close, size: 18, color: AppColors.mutedForeground),
        ),
      ),
    );
  }
}

class _LatestMeasurementCard extends StatelessWidget {
  const _LatestMeasurementCard({required this.trend});
  final IndicatorTrend trend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deltaColor = trend.improving ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.all(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '최근 측정값',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: trend.latestValue,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.foreground,
                  ),
                ),
                TextSpan(
                  text: ' ${trend.unit}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: <Widget>[
              Icon(
                trend.improving ? Icons.trending_down : Icons.trending_up,
                color: deltaColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                trend.deltaText,
                style: theme.textTheme.bodySmall?.copyWith(color: deltaColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendChartCard extends StatelessWidget {
  const _TrendChartCard({required this.values});
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: const BorderRadius.all(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              '변화 추이',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(height: 200, child: _TrendLineChart(values: values)),
        ],
      ),
    );
  }
}

class _TrendLineChart extends StatelessWidget {
  const _TrendLineChart({required this.values});
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) return const SizedBox.shrink();
    final maxV = values.reduce((double a, double b) => a > b ? a : b);
    final step = _interval(maxV);
    final chartMax = ((maxV / step).ceil() * step).toDouble();

    final xLabels = <int, String>{};
    for (int i = 0; i < values.length; i++) {
      final daysAgo = values.length - 1 - i;
      if (daysAgo == 0) {
        xLabels[i] = '오늘';
      } else if (daysAgo <= 4 || daysAgo % 2 == 0) {
        // ignore: unnecessary_brace_in_string_interps
        xLabels[i] = '${daysAgo}일전';
      }
    }

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: chartMax,
        minX: 0,
        maxX: (values.length - 1).toDouble(),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: chartMax / 4,
          getDrawingHorizontalLine: (_) => const FlLine(
            color: AppColors.border,
            dashArray: <int>[4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: chartMax / 4,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value == meta.max) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final i = value.toInt();
                final label = xLabels[i];
                if (label == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: <LineChartBarData>[
          LineChartBarData(
            spots: <FlSpot>[
              for (int i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            color: AppColors.primary,
            dotData: FlDotData(
              getDotPainter: (FlSpot s, double p, LineChartBarData b, int i) =>
                  FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.primary,
                  ),
            ),
            belowBarData: BarAreaData(),
          ),
        ],
      ),
    );
  }

  double _interval(double max) {
    if (max <= 25) return 5;
    if (max <= 50) return 10;
    if (max <= 100) return 25;
    if (max <= 160) return 40;
    return 50;
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({required this.record});
  final IndicatorRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.all(AppRadius.md),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(record.label, style: theme.textTheme.bodyMedium),
          ),
          Text(
            record.value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
