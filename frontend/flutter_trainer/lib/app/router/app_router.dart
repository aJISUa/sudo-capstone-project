import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:oncare_trainer/app/router/routes.dart';
import 'package:oncare_trainer/features/placeholder/presentation/pages/scaffold_home_page.dart';

/// GoRouter for the trainer app. Currently only the scaffold placeholder
/// is registered; the auth gate and the four-tab shell replace this in
/// later issues.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const ScaffoldHomePage(),
      ),
    ],
  );
});
