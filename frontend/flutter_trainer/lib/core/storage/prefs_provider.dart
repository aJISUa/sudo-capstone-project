import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the app-wide [SharedPreferences] instance.
///
/// The real value is resolved asynchronously in `bootstrap()` and
/// injected via an override, so the rest of the app can read prefs
/// synchronously. Reading this provider without that override throws —
/// that only happens in a misconfigured test.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in bootstrap() '
    '(or in tests via SharedPreferences.setMockInitialValues).',
  );
});
