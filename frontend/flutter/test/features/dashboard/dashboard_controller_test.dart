import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:oncare/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:oncare/features/dashboard/presentation/controllers/dashboard_controller.dart';

void main() {
  test('dashboardSummaryProvider returns mock indicators + schedule', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final summary = await container.read(dashboardSummaryProvider.future);
    expect(summary, isA<DashboardSummary>());
    expect(summary.indicators.length, 4);
    expect(summary.todaySchedule.length, 2);
    expect(summary.weekScore, 85);
  });

  test('MockDashboardRepository marks sodium as over-budget', () async {
    const repo = MockDashboardRepository();
    final s = await repo.fetchSummary();
    final sodium = s.indicators.firstWhere(
      (HealthIndicator h) => h.label == '나트륨',
    );
    expect(sodium.overBudget, isTrue);
    expect(sodium.progress, 1.0); // clamped
  });
}
