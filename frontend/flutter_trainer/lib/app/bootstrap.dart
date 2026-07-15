import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oncare_trainer/app/app.dart';
import 'package:oncare_trainer/core/storage/prefs_provider.dart';

/// Single entry point used by `main.dart`. Initializes the binding,
/// resolves the async services the widget tree needs synchronously
/// (SharedPreferences, for session restore), and starts the app inside
/// a [ProviderScope].
///
/// Kept intentionally thin for now — config, logging, and the
/// drift-backed local backend are added in their own issues (mirroring
/// the user app's `bootstrap()` shape).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const OncareTrainerApp(),
    ),
  );
}
