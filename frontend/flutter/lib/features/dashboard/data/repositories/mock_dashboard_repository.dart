import 'package:oncare/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:oncare/features/dashboard/domain/repositories/dashboard_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  const MockDashboardRepository();

  @override
  Future<DashboardSummary> fetchSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const DashboardSummary(
      caloriesToday: 1420,
      caloriesGoal: 2000,
      exerciseMinutesToday: 38,
      weightKg: 68.2,
      weeklyWeight: <double>[70.4, 70.1, 69.8, 69.4, 69.0, 68.6, 68.2],
    );
  }
}
