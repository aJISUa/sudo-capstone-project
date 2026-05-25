import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/errors/app_error.dart';
import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/features/ai_coach/presentation/widgets/ai_coach_panel.dart';
import 'package:oncare/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:oncare/features/dashboard/presentation/widgets/dashboard_content.dart';
import 'package:oncare/features/notification/presentation/widgets/notification_panel.dart';
import 'package:oncare/gen/l10n/app_localizations.dart';
import 'package:oncare/shared/widgets/error_view.dart';
import 'package:oncare/shared/widgets/modals/quick_input_dialog.dart';
import 'package:oncare/shared/widgets/modals/right_slide_panel.dart';
import 'package:oncare/shared/widgets/modals/schedule_calendar_sheet.dart';
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
            onNotificationTap: () => showRightSlidePanel<void>(
              context,
              content: const NotificationPanelBody(),
            ),
            onCalendarTap: () => showScheduleCalendarSheet(context),
          ),
          Expanded(
            child: summary.when(
              data: (s) => DashboardContent(
                summary: s,
                onQuickInputWeight: () =>
                    showQuickInputDialog(context, kind: QuickInputKind.weight),
                onQuickInputBloodPressure: () => showQuickInputDialog(
                  context,
                  kind: QuickInputKind.bloodPressure,
                ),
                onQuickInputBloodSugar: () => showQuickInputDialog(
                  context,
                  kind: QuickInputKind.bloodSugar,
                ),
                onOpenSchedule: () => showScheduleCalendarSheet(context),
              ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        tooltip: 'AI 코치',
        onPressed: () => showRightSlidePanel<void>(
          context,
          content: const AiCoachPanelBody(),
        ),
        child: const Icon(Icons.smart_toy_outlined),
      ),
    );
  }
}
