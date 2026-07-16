/// Centralised route paths for the trainer app. Anything that needs to
/// navigate imports this rather than another feature module
/// (STRUCTURE.md §4).
///
/// Only the scaffold placeholder exists today; auth + the four trainer
/// tabs (고객 / 스케줄 / AI루틴 / MY) are added in their own issues.
class AppRoutes {
  AppRoutes._();

  /// Temporary landing route for the scaffold. Replaced by the real
  /// auth gate + tab shell in later issues.
  static const String home = '/';
}
