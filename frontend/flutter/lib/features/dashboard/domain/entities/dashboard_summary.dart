/// One row of the "오늘의 건강 요약" progress list.
class HealthIndicator {
  const HealthIndicator({
    required this.label,
    required this.current,
    required this.max,
    required this.unit,
    this.overBudget = false,
  });

  final String label;
  final num current;
  final num max;
  final String unit;

  /// True when [current] should be treated as exceeding the target,
  /// even if the number is below `max` for a different reason. The
  /// React mock marks 나트륨 2100/2000 as `warning: true`.
  final bool overBudget;

  double get progress =>
      max == 0 ? 0 : (current / max).clamp(0.0, 1.0).toDouble();

  factory HealthIndicator.fromJson(Map<String, Object?> json) =>
      HealthIndicator(
        label: json['label']! as String,
        current: json['current']! as num,
        max: json['max']! as num,
        unit: json['unit']! as String,
        overBudget: (json['over_budget'] as bool?) ?? false,
      );
}

class ScheduleItem {
  const ScheduleItem({
    required this.time,
    required this.title,
    required this.emoji,
  });

  final String time;
  final String title;
  final String emoji;

  factory ScheduleItem.fromJson(Map<String, Object?> json) => ScheduleItem(
    time: json['time']! as String,
    title: json['title']! as String,
    emoji: (json['emoji'] as String?) ?? '',
  );
}

/// Snapshot displayed on the home dashboard. Mirrors the data the
/// React `Dashboard.tsx` mounts in `healthData` / `todaySchedule` /
/// `quickStats` / weekly score.
class DashboardSummary {
  const DashboardSummary({
    required this.indicators,
    required this.dietEntries,
    required this.exerciseMinutes,
    required this.todaySchedule,
    required this.weekScore,
    required this.weekScoreDelta,
    required this.sodiumWarning,
  });

  /// 4-row health summary (칼로리 / 나트륨 / 당류 / 혈당).
  final List<HealthIndicator> indicators;

  /// `quickStats` left tile — number of diet records logged today.
  final int dietEntries;

  /// `quickStats` right tile — total exercise minutes today.
  final int exerciseMinutes;

  /// Today's schedule list (병원 정기검진 / 헬스장 운동 …).
  final List<ScheduleItem> todaySchedule;

  /// "이번 주 건강 점수" card.
  final int weekScore;
  final int weekScoreDelta;

  /// One-line warning shown above the indicator list when something
  /// is over budget (e.g. sodium intake).
  final String? sodiumWarning;

  factory DashboardSummary.fromJson(Map<String, Object?> json) =>
      DashboardSummary(
        indicators: (json['indicators']! as List<Object?>)
            .cast<Map<String, Object?>>()
            .map(HealthIndicator.fromJson)
            .toList(),
        dietEntries: (json['diet_entries']! as num).toInt(),
        exerciseMinutes: (json['exercise_minutes']! as num).toInt(),
        todaySchedule: (json['today_schedule']! as List<Object?>)
            .cast<Map<String, Object?>>()
            .map(ScheduleItem.fromJson)
            .toList(),
        weekScore: (json['week_score']! as num).toInt(),
        weekScoreDelta: (json['week_score_delta']! as num).toInt(),
        sodiumWarning: json['sodium_warning'] as String?,
      );
}
