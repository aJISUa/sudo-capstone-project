/// Raised when a login attempt is rejected (e.g. empty credentials, or
/// invalid credentials once the real backend validates them).
class AuthException implements Exception {
  /// Creates an auth failure with a user-facing [message].
  const AuthException(this.message);

  /// Human-readable, Korean, ready to surface in a snackbar.
  final String message;

  @override
  String toString() => 'AuthException: $message';
}

/// Authenticates a trainer and returns a session access token.
///
/// Defined fresh for the trainer app — the user app's auth repository
/// is not reused. The real implementation (POST /auth/login) replaces
/// [MockTrainerAuthRepository] when the backend lands, keeping this
/// contract.
abstract class TrainerAuthRepository {
  /// Exchanges email/password for an access token. Throws
  /// [AuthException] on failure.
  Future<String> login({required String email, required String password});
}
