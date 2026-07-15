import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:oncare_trainer/app/router/routes.dart';
import 'package:oncare_trainer/features/auth/presentation/pages/trainer_sign_in_page.dart';
import 'package:oncare_trainer/features/placeholder/presentation/pages/scaffold_home_page.dart';

/// GoRouter for the trainer app. Starts on the login screen; the
/// dashboard route is a placeholder stand-in until the four-tab shell
/// (and its auth-gate redirect) land in a later issue.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.signIn,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const TrainerSignInPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const ScaffoldHomePage(),
      ),
    ],
  );
});
