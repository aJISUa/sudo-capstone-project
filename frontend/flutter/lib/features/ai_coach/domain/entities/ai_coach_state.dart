enum AiSuggestionTag { diet, exercise, sleep, hydration }

AiSuggestionTag _tagFromString(String s) => AiSuggestionTag.values.firstWhere(
  (t) => t.name == s,
  orElse: () => AiSuggestionTag.diet,
);

class AiSuggestion {
  const AiSuggestion({
    required this.title,
    required this.body,
    required this.tag,
  });

  final String title;
  final String body;
  final AiSuggestionTag tag;

  factory AiSuggestion.fromJson(Map<String, Object?> json) => AiSuggestion(
    title: json['title']! as String,
    body: json['body']! as String,
    tag: _tagFromString(json['tag']! as String),
  );
}

class AiCoachState {
  const AiCoachState({required this.greeting, required this.suggestions});
  final String greeting;
  final List<AiSuggestion> suggestions;

  factory AiCoachState.fromJson(Map<String, Object?> json) => AiCoachState(
    greeting: json['greeting']! as String,
    suggestions: (json['suggestions']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map(AiSuggestion.fromJson)
        .toList(),
  );
}
