/// Centralised route paths for the trainer app. Anything that needs to
/// navigate imports this rather than another feature module
/// (STRUCTURE.md §4).
class AppRoutes {
  AppRoutes._();

  /// Trainer login screen (email/password + demo bypass).
  static const String signIn = '/auth/sign-in';

  /// Trainer home — the 고객(clients) tab. Currently a placeholder
  /// stand-in; the four-tab shell replaces it in a later issue.
  static const String dashboard = '/dashboard';
}
