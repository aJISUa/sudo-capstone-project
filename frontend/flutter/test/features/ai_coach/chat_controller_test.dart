import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/features/ai_coach/domain/entities/ai_coach_state.dart';
import 'package:oncare/features/ai_coach/domain/entities/chat_message.dart';
import 'package:oncare/features/ai_coach/domain/repositories/ai_coach_repository.dart';
import 'package:oncare/features/ai_coach/presentation/controllers/ai_coach_controller.dart';
import 'package:oncare/features/ai_coach/presentation/controllers/chat_controller.dart';

class _FakeCoachRepo implements AiCoachRepository {
  @override
  Future<AiCoachState> fetchState() async =>
      const AiCoachState(greeting: '', suggestions: <AiSuggestion>[]);

  @override
  Future<ChatMessage> sendMessage({
    required String message,
    required List<ChatMessage> history,
  }) async => const ChatMessage(
    role: ChatRole.coach,
    content: '저염 식단이 도움이 됩니다.',
    sources: <String>['나트륨 줄이기'],
  );
}

void main() {
  test('starts with a single welcome message from the coach', () {
    final container = ProviderContainer(
      overrides: <Override>[
        aiCoachRepositoryProvider.overrideWithValue(_FakeCoachRepo()),
      ],
    );
    addTearDown(container.dispose);

    final state = container.read(chatControllerProvider);
    expect(state.messages.length, 1);
    expect(state.messages.single.role, ChatRole.coach);
    expect(state.sending, isFalse);
  });

  test('send() appends the user message and the coach reply', () async {
    final container = ProviderContainer(
      overrides: <Override>[
        aiCoachRepositoryProvider.overrideWithValue(_FakeCoachRepo()),
      ],
    );
    addTearDown(container.dispose);

    await container.read(chatControllerProvider.notifier).send('나트륨 줄이는 법');

    final state = container.read(chatControllerProvider);
    expect(state.sending, isFalse);
    expect(
      state.messages.any((ChatMessage m) => m.isUser && m.content == '나트륨 줄이는 법'),
      isTrue,
    );
    expect(state.messages.last.role, ChatRole.coach);
    expect(state.messages.last.content, contains('저염'));
    expect(state.messages.last.sources, contains('나트륨 줄이기'));
    // 진행 중 표시(pending)는 응답 후 남아있지 않아야 한다.
    expect(state.messages.any((ChatMessage m) => m.pending), isFalse);
  });
}
