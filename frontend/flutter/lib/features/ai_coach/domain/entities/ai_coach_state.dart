enum AiSuggestionTag { diet, exercise, sleep, hydration }

class AiSuggestion {
  const AiSuggestion({
    required this.title,
    required this.body,
    required this.tag,
  });

  final String title;
  final String body;
  final AiSuggestionTag tag;
}

class AiCoachState {
  const AiCoachState({required this.greeting, required this.suggestions});
  final String greeting;
  final List<AiSuggestion> suggestions;
}
