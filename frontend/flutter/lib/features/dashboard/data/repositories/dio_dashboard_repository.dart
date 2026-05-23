import 'package:dio/dio.dart';

import 'package:oncare/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:oncare/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Network-side [DashboardRepository]. dev/local builds get served by
/// `LocalApiInterceptor` (drift aggregation); prod hits FastAPI's
/// `GET /dashboard/summary`.
class DioDashboardRepository implements DashboardRepository {
  DioDashboardRepository(this._dio);
  final Dio _dio;

  @override
  Future<DashboardSummary> fetchSummary() async {
    final res = await _dio.get<Map<String, Object?>>('/dashboard/summary');
    return DashboardSummary.fromJson(res.data!);
  }
}
