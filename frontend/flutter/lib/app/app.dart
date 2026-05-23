import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/app/router/app_router.dart';
import 'package:oncare/design_system/theme/app_theme.dart';
import 'package:oncare/shared/services/theme_mode_provider.dart';

class OncareApp extends ConsumerWidget {
  const OncareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final mode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Oncare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      routerConfig: router,
    );
  }
}
