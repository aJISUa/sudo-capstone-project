/// One meal in a client's day (아침/점심/저녁), as shown on the 식단
/// sub-tab. Decoded from the drift `ClientDietEntries` row.
class ClientDietEntry {
  /// Creates a meal entry.
  const ClientDietEntry({
    required this.meal,
    required this.items,
    required this.calories,
    required this.sodiumMg,
  });

  /// Meal label (아침 | 점심 | 저녁).
  final String meal;

  /// Foods eaten, comma-joined (e.g. "오트밀, 바나나").
  final String items;

  /// Calories for this meal (kcal).
  final int calories;

  /// Sodium for this meal (mg).
  final int sodiumMg;
}
