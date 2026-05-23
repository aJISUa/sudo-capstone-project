import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:oncare/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:oncare/features/dashboard/presentation/controllers/dashboard_controller.dart';

void main() {
  test('dashboardSummaryProvider returns the mock summary', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final summary = await container.read(dashboardSummaryProvider.future);
    expect(summary, isA<DashboardSummary>());
    expect(summary.caloriesGoal, 2000);
    expect(summary.weeklyWeight.length, 7);
  });

  test('MockDashboardRepository delivers a stable snapshot', () async {
    const repo = MockDashboardRepository();
    final s = await repo.fetchSummary();
    expect(s.weeklyWeight.first, greaterThanOrEqualTo(s.weeklyWeight.last));
  });
}
