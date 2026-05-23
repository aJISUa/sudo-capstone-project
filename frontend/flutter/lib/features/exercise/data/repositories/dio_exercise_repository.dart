import 'package:dio/dio.dart';

import 'package:oncare/features/exercise/domain/entities/exercise_week.dart';
import 'package:oncare/features/exercise/domain/repositories/exercise_repository.dart';

/// Network-side [ExerciseRepository]. dev/local builds get served by
/// `LocalApiInterceptor` (drift-backed); prod hits FastAPI.
class DioExerciseRepository implements ExerciseRepository {
  DioExerciseRepository(this._dio);
  final Dio _dio;

  @override
  Future<ExerciseWeek> fetchThisWeek() async {
    final res = await _dio.get<Map<String, Object?>>('/exercise/weeks/current');
    return ExerciseWeek.fromJson(res.data!);
  }
}
