import 'package:oncare/features/ai_coach/domain/entities/ai_coach_state.dart';

abstract class AiCoachRepository {
  Future<AiCoachState> fetchState();
}
