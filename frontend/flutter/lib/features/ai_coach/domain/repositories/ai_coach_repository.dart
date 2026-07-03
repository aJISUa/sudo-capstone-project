import 'package:oncare/features/ai_coach/domain/entities/ai_coach_state.dart';
import 'package:oncare/features/ai_coach/domain/entities/chat_message.dart';

abstract class AiCoachRepository {
  Future<AiCoachState> fetchState();

  /// Send a user message (+ prior turns) and get the coach's reply.
  Future<ChatMessage> sendMessage({
    required String message,
    required List<ChatMessage> history,
  });
}
