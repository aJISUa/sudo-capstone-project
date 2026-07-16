import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare_trainer/app/app.dart';

/// Single entry point used by `main.dart`. Initializes the binding and
/// starts the app inside a [ProviderScope].
///
/// Kept intentionally thin for the scaffold — config, logging, and the
/// drift-backed local backend are added in their own issues (mirroring
/// the user app's `bootstrap()` shape).
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: OncareTrainerApp(),
    ),
  );
}
