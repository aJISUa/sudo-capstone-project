import 'package:dio/dio.dart';

import 'package:oncare/features/ai_coach/domain/entities/ai_coach_state.dart';
import 'package:oncare/features/ai_coach/domain/repositories/ai_coach_repository.dart';

class DioAiCoachRepository implements AiCoachRepository {
  DioAiCoachRepository(this._dio);
  final Dio _dio;

  @override
  Future<AiCoachState> fetchState() async {
    final res = await _dio.get<Map<String, Object?>>('/ai-coach/feedback');
    return AiCoachState.fromJson(res.data!);
  }
}
