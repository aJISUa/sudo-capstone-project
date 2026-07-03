import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/radius.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/exercise/domain/entities/exercise_week.dart';
import 'package:oncare/features/exercise/presentation/controllers/exercise_controller.dart';

const List<String> _weekdayLabels = <String>['월', '화', '수', '목', '금', '토', '일'];

/// Bottom-sheet form mirroring the prototype's "운동 기록 추가" modal:
/// type chips (유산소 / 근력 / 스트레칭 / 기타), minutes, free-text
/// items, save button. On save, appends the new session to the local
/// [addedSessionsProvider] overlay so it appears at the top of the
/// list immediately.
Future<void> showAddSessionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext ctx) => const Padding(
      padding: EdgeInsets.only(top: AppSpacing.sm),
      child: _AddSessionForm(),
    ),
  );
}

class _AddSessionForm extends ConsumerStatefulWidget {
  const _AddSessionForm();

  @override
  ConsumerState<_AddSessionForm> createState() => _AddSessionFormState();
}

class _AddSessionFormState extends ConsumerState<_AddSessionForm> {
  ExerciseType _type = ExerciseType.cardio;
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _itemsController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _minutesController.dispose();
    _itemsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    if (minutes <= 0) {
      messenger.showSnackBar(const SnackBar(content: Text('운동 시간을 입력해주세요')));
      return;
    }
    setState(() => _saving = true);
    final dayLabel = _weekdayLabels[DateTime.now().weekday - 1];
    try {
      // 서버(mock 모드는 drift)에 저장 → 주간 데이터 무효화로 통계·차트·목록 모두 반영.
      await ref.read(exerciseRepositoryProvider).addSession(
        type: _type,
        minutes: minutes,
        calories: _estimateCalories(_type, minutes),
        dayLabel: dayLabel,
      );
      ref.invalidate(exerciseWeekProvider);
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('운동 기록이 추가되었어요')));
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('저장에 실패했어요. 잠시 후 다시 시도해 주세요')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  '운동 기록 추가',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                tooltip: '닫기',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('운동 유형', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 4.2,
            children: <Widget>[
              _TypeChip(
                label: '유산소',
                selected: _type == ExerciseType.cardio,
                onTap: () => setState(() => _type = ExerciseType.cardio),
              ),
              _TypeChip(
                label: '근력',
                selected: _type == ExerciseType.strength,
                onTap: () => setState(() => _type = ExerciseType.strength),
              ),
              _TypeChip(
                label: '스트레칭',
                selected: _type == ExerciseType.stretching,
                onTap: () => setState(() => _type = ExerciseType.stretching),
              ),
              _TypeChip(
                label: '기타',
                selected: _type == ExerciseType.other,
                onTap: () => setState(() => _type = ExerciseType.other),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('운동 시간', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _minutesController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              hintText: '분',
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('운동 내용', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _itemsController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '예: 러닝머신 30분, 스쿼트 3세트',
              filled: true,
              fillColor: AppColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(AppRadius.lg),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(AppRadius.lg),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('저장하기'),
            ),
          ),
        ],
      ),
    );
  }
}

int _estimateCalories(ExerciseType type, int minutes) {
  // Rough kcal/min so the new session's "soomo 칼로리" column isn't
  // a flat zero. Tuned to roughly match the mock data ratios.
  final perMin = switch (type) {
    ExerciseType.cardio || ExerciseType.walking => 7.5,
    ExerciseType.strength => 5.0,
    ExerciseType.yoga || ExerciseType.stretching => 3.0,
    ExerciseType.other => 4.0,
  };
  return (perMin * minutes).round();
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = selected
        ? AppColors.primary
        : AppColors.primary.withValues(alpha: 0.10);
    final fg = selected ? Colors.white : AppColors.foreground;
    return Material(
      color: bg,
      borderRadius: const BorderRadius.all(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(AppRadius.lg),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
