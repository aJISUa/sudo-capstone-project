import 'dart:typed_data';

import 'package:dio/dio.dart';

import 'package:oncare/features/diet/domain/entities/diet_analysis.dart';
import 'package:oncare/features/diet/domain/entities/diet_day.dart';
import 'package:oncare/features/diet/domain/repositories/diet_repository.dart';

/// Real-network implementation of [DietRepository]. Issues HTTP
/// requests via [Dio]; the dev/local build serves them out of
/// `LocalApiInterceptor` (drift-backed). FastAPI takes over once
/// `USE_MOCK_API=false`.
class DioDietRepository implements DietRepository {
  DioDietRepository(this._dio);
  final Dio _dio;

  @override
  Future<DietDay> fetchToday() async {
    final res = await _dio.get<Map<String, Object?>>('/diet/days/today');
    return DietDay.fromJson(res.data!);
  }

  @override
  Future<DietAnalysisResult> analyze({
    required Uint8List imageBytes,
    required String filename,
    required String mealType,
  }) async {
    final form = FormData.fromMap(<String, Object?>{
      'image': MultipartFile.fromBytes(
        imageBytes,
        filename: filename,
        contentType: DioMediaType('image', 'jpeg'),
      ),
      'meal_type': mealType,
    });
    final res = await _dio.post<Map<String, Object?>>(
      '/diet/analyze',
      data: form,
    );
    return DietAnalysisResult.fromResponse(res.data!);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _dio.delete<Map<String, Object?>>('/diet/entries/$id');
  }

  @override
  Future<DietEntry> updateEntry({
    required String id,
    String? mealType,
    String? timeLabel,
  }) async {
    final res = await _dio.put<Map<String, Object?>>(
      '/diet/entries/$id',
      data: <String, Object?>{
        'meal_type': ?mealType,
        'time_label': ?timeLabel,
      },
    );
    return DietEntry.fromJson(res.data!);
  }
}
