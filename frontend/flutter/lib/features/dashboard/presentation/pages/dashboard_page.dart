import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/errors/app_error.dart';
import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:oncare/features/dashboard/presentation/widgets/dashboard_content.dart';
import 'package:oncare/gen/l10n/app_localizations.dart';
import 'package:oncare/shared/widgets/error_view.dart';
import 'package:oncare/shared/widgets/oncare_header.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final summary = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: <Widget>[
          OncareHeader(
            title: l.pageDashboardTitle,
            onNotificationTap: () {
              // TODO(stage-8.8): open NotificationPanel right-slide sheet.
            },
            onCalendarTap: () {
              // TODO(stage-8.7): open Calendar bottom sheet.
            },
          ),
          Expanded(
            child: summary.when(
              data: (s) => DashboardContent(summary: s),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace _) => ErrorView(
                error: error is AppError
                    ? error
                    : UnknownError(message: error.toString()),
                onRetry: () => ref.invalidate(dashboardSummaryProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
