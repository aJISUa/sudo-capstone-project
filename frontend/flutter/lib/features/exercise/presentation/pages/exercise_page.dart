import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/exercise/presentation/widgets/add_session_sheet.dart';
import 'package:oncare/features/exercise/presentation/widgets/exercise_tab_switcher.dart';
import 'package:oncare/features/exercise/presentation/widgets/gym_tab.dart';
import 'package:oncare/features/exercise/presentation/widgets/workout_record_tab.dart';
import 'package:oncare/features/notification/presentation/widgets/notification_panel.dart';
import 'package:oncare/gen/l10n/app_localizations.dart';
import 'package:oncare/shared/widgets/modals/right_slide_panel.dart';
import 'package:oncare/shared/widgets/modals/schedule_calendar_sheet.dart';
import 'package:oncare/shared/widgets/oncare_header.dart';

class ExercisePage extends ConsumerStatefulWidget {
  const ExercisePage({super.key});

  @override
  ConsumerState<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends ConsumerState<ExercisePage> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: <Widget>[
          OncareHeader(
            title: l.pageExerciseTitle,
            onNotificationTap: () => showRightSlidePanel<void>(
              context,
              content: const NotificationPanelBody(),
            ),
            onCalendarTap: () => showScheduleCalendarSheet(context),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 672),
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.md,
                            AppSpacing.lg,
                            AppSpacing.sm,
                          ),
                          child: ExerciseTabSwitcher(
                            activeIndex: _activeIndex,
                            onChange: (i) => setState(() => _activeIndex = i),
                          ),
                        ),
                        Expanded(
                          child: IndexedStack(
                            index: _activeIndex,
                            children: const <Widget>[
                              WorkoutRecordTab(),
                              GymTab(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (_activeIndex == 0)
                      Positioned(
                        right: AppSpacing.lg,
                        bottom: AppSpacing.lg,
                        child: _AddSessionFab(
                          onPressed: () => showAddSessionSheet(context),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddSessionFab extends StatelessWidget {
  const _AddSessionFab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      elevation: 4,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 56,
          height: 56,
          child: Icon(Icons.add, size: 28, color: Colors.white),
        ),
      ),
    );
  }
}
