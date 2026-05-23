/// Snapshot of a user's day surfaced on the dashboard.
class DashboardSummary {
  const DashboardSummary({
    required this.caloriesToday,
    required this.caloriesGoal,
    required this.exerciseMinutesToday,
    required this.weightKg,
    required this.weeklyWeight,
  });

  final int caloriesToday;
  final int caloriesGoal;
  final int exerciseMinutesToday;
  final double weightKg;

  /// Most-recent first (7 days).
  final List<double> weeklyWeight;
}
