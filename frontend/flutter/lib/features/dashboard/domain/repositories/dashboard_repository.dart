import 'package:oncare/features/dashboard/domain/entities/dashboard_summary.dart';

abstract class DashboardRepository {
  Future<DashboardSummary> fetchSummary();
}
