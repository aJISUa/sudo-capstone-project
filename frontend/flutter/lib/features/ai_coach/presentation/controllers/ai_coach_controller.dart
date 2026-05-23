import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/features/ai_coach/data/repositories/mock_ai_coach_repository.dart';
import 'package:oncare/features/ai_coach/domain/entities/ai_coach_state.dart';
import 'package:oncare/features/ai_coach/domain/repositories/ai_coach_repository.dart';

final aiCoachRepositoryProvider = Provider<AiCoachRepository>(
  (ref) => const MockAiCoachRepository(),
  name: 'aiCoachRepository',
);

final aiCoachStateProvider = FutureProvider<AiCoachState>((ref) {
  return ref.watch(aiCoachRepositoryProvider).fetchState();
}, name: 'aiCoachState');
