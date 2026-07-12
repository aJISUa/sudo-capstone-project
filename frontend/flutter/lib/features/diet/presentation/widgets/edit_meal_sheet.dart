import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/radius.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/diet/domain/entities/diet_day.dart';
import 'package:oncare/features/diet/presentation/controllers/diet_controller.dart';

const Map<MealType, String> _mealLabels = <MealType, String>{
  MealType.breakfast: '아침',
  MealType.lunch: '점심',
  MealType.dinner: '저녁',
  MealType.snack: '간식',
};

/// Bottom sheet to edit a diet entry's meal type + time. Foods and
/// nutrition come from photo analysis and are not edited here.
Future<void> showEditMealSheet(BuildContext context, DietEntry entry) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext ctx) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: _EditMealForm(entry: entry),
    ),
  );
}

class _EditMealForm extends ConsumerStatefulWidget {
  const _EditMealForm({required this.entry});
  final DietEntry entry;

  @override
  ConsumerState<_EditMealForm> createState() => _EditMealFormState();
}

class _EditMealFormState extends ConsumerState<_EditMealForm> {
  late MealType _mealType = widget.entry.mealType;
  late final TextEditingController _time = TextEditingController(
    text: widget.entry.timeLabel,
  );
  bool _saving = false;

  @override
  void dispose() {
    _time.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final id = widget.entry.id;
    if (id == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(dietRepositoryProvider)
          .updateEntry(
            id: id,
            mealType: _mealType.name,
            timeLabel: _time.text.trim(),
          );
      ref.invalidate(dietTodayProvider);
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('식단 기록이 수정되었어요')),
      );
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('수정에 실패했어요. 잠시 후 다시 시도해 주세요')),
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
                  '식단 기록 수정',
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
          Text('끼니', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: <Widget>[
              for (final MealType m in MealType.values)
                ChoiceChip(
                  label: Text(_mealLabels[m]!),
                  selected: _mealType == m,
                  onSelected: (_) => setState(() => _mealType = m),
                  selectedColor: AppColors.accent,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('시간', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _time,
            keyboardType: TextInputType.datetime,
            decoration: const InputDecoration(
              hintText: '예: 12:40',
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
                  : const Text('수정하기'),
            ),
          ),
        ],
      ),
    );
  }
}
