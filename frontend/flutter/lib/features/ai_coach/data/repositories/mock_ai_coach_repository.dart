import 'package:oncare/features/ai_coach/domain/entities/ai_coach_state.dart';
import 'package:oncare/features/ai_coach/domain/repositories/ai_coach_repository.dart';

class MockAiCoachRepository implements AiCoachRepository {
  const MockAiCoachRepository();

  @override
  Future<AiCoachState> fetchState() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const AiCoachState(
      greeting: '안녕하세요, 오늘 컨디션은 어떠세요?',
      suggestions: <AiSuggestion>[
        AiSuggestion(
          tag: AiSuggestionTag.diet,
          title: '점심에 단백질을 +10g 추가해 보세요',
          body: '오전 운동량을 보면 점심에 단백질을 조금 더 채우는 것이 좋아요.',
        ),
        AiSuggestion(
          tag: AiSuggestionTag.exercise,
          title: '저녁 산책 15분',
          body: '저녁 시간대 가벼운 유산소는 수면의 질도 함께 끌어올립니다.',
        ),
        AiSuggestion(
          tag: AiSuggestionTag.hydration,
          title: '수분 보충',
          body: '오늘 평소보다 활동량이 많았어요. 물 한 컵 더 마셔봐요.',
        ),
        AiSuggestion(
          tag: AiSuggestionTag.sleep,
          title: '취침 1시간 전 화면 줄이기',
          body: '깊은 수면 비율이 낮은 패턴이 보입니다. 자극을 줄여보세요.',
        ),
      ],
    );
  }
}
