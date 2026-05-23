import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:oncare/app/router/routes.dart';
import 'package:oncare/core/config/app_config.dart';
import 'package:oncare/core/errors/app_error.dart';
import 'package:oncare/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:oncare/features/dashboard/presentation/widgets/dashboard_content.dart';
import 'package:oncare/gen/l10n/app_localizations.dart';
import 'package:oncare/shared/widgets/error_view.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final config = ref.watch(appConfigProvider);
    final summary = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.pageDashboardTitle),
        actions: <Widget>[
          IconButton(
            tooltip: l.pageNotificationTitle,
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push(AppRoutes.notification),
          ),
          if (!config.isProd)
            IconButton(
              tooltip: 'UI Catalog',
              icon: const Icon(Icons.palette_outlined),
              onPressed: () => context.push(AppRoutes.uiCatalog),
            ),
        ],
      ),
      body: summary.when(
        data: (s) => DashboardContent(summary: s),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace _) => ErrorView(
          error: error is AppError
              ? error
              : UnknownError(message: error.toString()),
          onRetry: () => ref.invalidate(dashboardSummaryProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.smart_toy_outlined),
        label: Text(l.actionOpenAiCoach),
        onPressed: () => context.push(AppRoutes.aiCoach),
      ),
    );
  }
}
