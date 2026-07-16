import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oncare_trainer/core/storage/prefs_provider.dart';

/// Persists the trainer session's access token across app restarts.
///
/// Backed by [SharedPreferences] for now — the token is a mock demo
/// token until the real backend lands. The store is intentionally a
/// thin abstraction so the backing implementation can be swapped for
/// secure storage (Keychain / Keystore) when real credentials are
/// introduced, without touching the session layer.
class SessionTokenStore {
  /// Creates a store over the given [SharedPreferences] instance.
  const SessionTokenStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _tokenKey = 'trainer_access_token';

  /// Returns the persisted access token, or `null` if the trainer is
  /// signed out.
  String? readToken() {
    final token = _prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) return null;
    return token;
  }

  /// Persists [token] so the session survives an app restart.
  Future<void> saveToken(String token) => _prefs.setString(_tokenKey, token);

  /// Clears the persisted token (sign-out).
  Future<void> clear() => _prefs.remove(_tokenKey);
}

/// Provides the [SessionTokenStore], wired to the app-wide prefs.
final sessionTokenStoreProvider = Provider<SessionTokenStore>((ref) {
  return SessionTokenStore(ref.watch(sharedPreferencesProvider));
});
