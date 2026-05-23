import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/features/dashboard/data/repositories/mock_dashboard_repository.dart';
import 'package:oncare/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:oncare/features/dashboard/domain/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>(
  (ref) => const MockDashboardRepository(),
  name: 'dashboardRepository',
);

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchSummary();
}, name: 'dashboardSummary');
