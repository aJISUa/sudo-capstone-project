/// Centralised route paths for the trainer app. Anything that needs to
/// navigate imports this rather than another feature module
/// (STRUCTURE.md §4).
class AppRoutes {
  AppRoutes._();

  /// Trainer login screen (email/password + demo bypass).
  static const String signIn = '/auth/sign-in';

  // Main tabs (StatefulShellRoute branches).

  /// 고객 관리 — client list (home tab).
  static const String clients = '/clients';

  /// 스케줄 — daily PT timeline.
  static const String schedule = '/schedule';

  /// AI 루틴 — AI routine generation.
  static const String aiRoutine = '/ai-routine';

  /// MY — trainer profile.
  static const String my = '/my';
}
