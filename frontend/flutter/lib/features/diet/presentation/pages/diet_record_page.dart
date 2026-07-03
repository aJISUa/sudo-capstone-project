import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:oncare/core/errors/app_error.dart';
import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/diet/presentation/controllers/diet_controller.dart';
import 'package:oncare/features/diet/presentation/pages/diet_analyze_page.dart';
import 'package:oncare/features/diet/presentation/widgets/diet_summary_card.dart';
import 'package:oncare/features/diet/presentation/widgets/diet_week_strip.dart';
import 'package:oncare/features/diet/presentation/widgets/meal_card.dart';
import 'package:oncare/features/notification/presentation/widgets/notification_panel.dart';
import 'package:oncare/gen/l10n/app_localizations.dart';
import 'package:oncare/shared/widgets/ai_coach_card.dart';
import 'package:oncare/shared/widgets/error_view.dart';
import 'package:oncare/shared/widgets/modals/right_slide_panel.dart';
import 'package:oncare/shared/widgets/modals/schedule_calendar_sheet.dart';
import 'package:oncare/shared/widgets/oncare_header.dart';

class DietRecordPage extends ConsumerStatefulWidget {
  const DietRecordPage({super.key});

  @override
  ConsumerState<DietRecordPage> createState() => _DietRecordPageState();
}

class _DietRecordPageState extends ConsumerState<DietRecordPage> {
  late DateTime _selectedDay = DateTime.now();

  static String _currentMealType() {
    final h = DateTime.now().hour;
    if (h < 11) return 'breakfast';
    if (h < 15) return 'lunch';
    if (h < 21) return 'dinner';
    return 'snack';
  }

  Future<ImageSource?> _pickSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('사진 촬영'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('갤러리에서 선택'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDietAddFlow() async {
    final source = await _pickSource();
    if (source == null) return;
    final XFile? file = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;

    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DietAnalyzePage(imageBytes: bytes, mealType: _currentMealType()),
        fullscreenDialog: true,
      ),
    );
    if (!mounted) return;
    if (added == true) {
      ref.invalidate(dietTodayProvider); // 새 식단이 오늘 목록·요약에 반영
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('식단이 추가되었어요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(dietTodayProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: <Widget>[
          OncareHeader(
            title: l.pageDietTitle,
            onNotificationTap: () => showRightSlidePanel<void>(
              context,
              content: const NotificationPanelBody(),
            ),
            onCalendarTap: () => showScheduleCalendarSheet(context),
          ),
          Expanded(
            child: async.when(
              data: (day) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 672),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.xxxl,
                    ),
                    children: <Widget>[
                      DietWeekStrip(
                        selectedDay: _selectedDay,
                        onSelect: (d) => setState(() => _selectedDay = d),
                        onShiftWeek: (delta) => setState(() {
                          _selectedDay = _selectedDay.add(
                            Duration(days: 7 * delta),
                          );
                        }),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      DietSummaryCard(day: day),
                      const SizedBox(height: AppSpacing.lg),
                      AiCoachCard(message: day.aiCoachMessage),
                      const SizedBox(height: AppSpacing.lg),
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          '오늘의 식단',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      for (final entry in day.entries) ...<Widget>[
                        MealCard(entry: entry),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object e, _) => ErrorView(
                error: e is AppError ? e : UnknownError(message: e.toString()),
                onRetry: () => ref.invalidate(dietTodayProvider),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        tooltip: '식단 추가',
        onPressed: _openDietAddFlow,
        child: const Icon(Icons.add),
      ),
    );
  }
}
