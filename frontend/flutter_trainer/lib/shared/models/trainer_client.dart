/// Daily sodium target (mg). Over this, the list card metric, the diet
/// summary tile, and the AI comment all flip to the warning case.
const int sodiumTargetMg = 2000;

/// Daily sugar target (g). Over this, the diet summary 당류 tile warns.
const int sugarTargetG = 50;

/// A trainer's client, as shown on the 고객 관리 list and detail screens.
/// Decoded from the drift `TrainerClients` row (the `weekCompletionJson`
/// column becomes a `List<int>` here).
class TrainerClient {
  /// Creates a client.
  const TrainerClient({
    required this.id,
    required this.name,
    required this.avatar,
    required this.goal,
    required this.lastMessage,
    required this.lastTime,
    required this.active,
    required this.calories,
    required this.sodiumMg,
    required this.sugarG,
    required this.lastRoutine,
    required this.weekCompletion,
  });

  /// Row id (e.g. `seed-client-1`).
  final String id;

  /// Display name (e.g. 김민수).
  final String name;

  /// Single-char avatar label (e.g. 김).
  final String avatar;

  /// Goal label (e.g. 혈압 관리 · 체중 감량).
  final String goal;

  /// Preview of the most recent chat message.
  final String lastMessage;

  /// Relative time label for [lastMessage] (e.g. 방금).
  final String lastTime;

  /// Whether the client is currently active.
  final bool active;

  /// Today's total calories (kcal).
  final int calories;

  /// Today's sodium (mg).
  final int sodiumMg;

  /// Today's sugar (g).
  final int sugarG;

  /// Label for the last routine sent (e.g. 오늘 / 어제 / 5일 전).
  final String lastRoutine;

  /// This week's daily completion rates (7 entries, 월→일).
  final List<int> weekCompletion;

  /// Sodium exceeds the [sodiumTargetMg] daily target — surfaced as a
  /// warning on the list card and counted by the AI summary.
  bool get sodiumOverBudget => sodiumMg > sodiumTargetMg;
}
