import 'package:dio/dio.dart';

import 'package:oncare/features/vitals/domain/entities/vital.dart';
import 'package:oncare/features/vitals/domain/repositories/vitals_repository.dart';

/// Network-side [VitalsRepository]. Calls go through `Dio`; the
/// dev/local build short-circuits them in `LocalApiInterceptor`,
/// the prod build forwards to FastAPI.
class DioVitalsRepository implements VitalsRepository {
  DioVitalsRepository(this._dio);
  final Dio _dio;

  @override
  Future<VitalRecord> submit(VitalSubmission submission) async {
    final body = <String, Object?>{
      ...submission.toJson(),
      'recorded_at': DateTime.now().toIso8601String(),
    };
    final res = await _dio.post<Map<String, Object?>>(
      '/vitals/${submission.kind.path}',
      data: body,
    );
    return VitalRecord.fromJson(res.data!);
  }

  @override
  Future<VitalRecord?> latest(VitalKind kind) async {
    final res = await _dio.get<Map<String, Object?>>(
      '/vitals/${kind.path}/latest',
    );
    final data = res.data;
    if (data == null || data.isEmpty) return null;
    return VitalRecord.fromJson(data);
  }
}
