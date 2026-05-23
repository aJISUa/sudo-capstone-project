import 'package:dio/dio.dart';

import 'package:oncare/features/my_health/domain/entities/health_history.dart';
import 'package:oncare/features/my_health/domain/repositories/my_health_repository.dart';

class DioMyHealthRepository implements MyHealthRepository {
  DioMyHealthRepository(this._dio);
  final Dio _dio;

  @override
  Future<MyHealthState> fetchState() async {
    final res = await _dio.get<Map<String, Object?>>('/users/me/health');
    return MyHealthState.fromJson(res.data!);
  }
}
