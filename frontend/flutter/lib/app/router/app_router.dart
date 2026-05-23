import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:oncare/app/router/main_shell.dart';
import 'package:oncare/app/router/routes.dart';
import 'package:oncare/core/config/app_config.dart';
import 'package:oncare/design_system/catalog/ui_catalog_page.dart';
import 'package:oncare/features/ai_coach/presentation/pages/ai_coach_page.dart';
import 'package:oncare/features/auth/presentation/pages/sign_in_page.dart';
import 'package:oncare/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:oncare/features/diet/presentation/pages/diet_record_page.dart';
import 'package:oncare/features/exercise/presentation/pages/exercise_page.dart';
import 'package:oncare/features/my_health/presentation/pages/my_health_page.dart';
import 'package:oncare/features/notification/presentation/pages/notification_page.dart';
import 'package:oncare/features/place/presentation/pages/place_page.dart';

/// Single source of truth for the app's routing tree. The `config`
/// is read once at build time — dev-only routes (UI catalog) are
/// excluded from prod builds.
GoRouter buildAppRouter({required AppConfig config}) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: !config.isProd,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.diet,
                builder: (context, state) => const DietRecordPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.exercise,
                builder: (context, state) => const ExercisePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.myHealth,
                builder: (context, state) => const MyHealthPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.aiCoach,
        builder: (context, state) => const AICoachPage(),
      ),
      GoRoute(
        path: AppRoutes.notification,
        builder: (context, state) => const NotificationPage(),
      ),
      GoRoute(
        path: AppRoutes.place,
        builder: (context, state) => const PlacePage(),
      ),
      GoRoute(
        path: AppRoutes.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      if (!config.isProd)
        GoRoute(
          path: AppRoutes.uiCatalog,
          builder: (context, state) => const UiCatalogPage(),
        ),
    ],
  );
}

/// Riverpod-managed router. Rebuilds if AppConfig is ever swapped.
final appRouterProvider = Provider<GoRouter>((ref) {
  final config = ref.watch(appConfigProvider);
  return buildAppRouter(config: config);
});
