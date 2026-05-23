import 'package:flutter/material.dart';

import 'package:oncare/design_system/atoms/app_badge.dart';
import 'package:oncare/design_system/atoms/app_card.dart';
import 'package:oncare/design_system/tokens/colors.dart';
import 'package:oncare/design_system/tokens/spacing.dart';
import 'package:oncare/features/diet/domain/entities/diet_day.dart';

String _mealLabel(MealType m) => switch (m) {
  MealType.breakfast => '아침',
  MealType.lunch => '점심',
  MealType.dinner => '저녁',
  MealType.snack => '간식',
};

class MealCard extends StatelessWidget {
  const MealCard({required this.entry, super.key});
  final DietEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AppBadge(label: _mealLabel(entry.mealType)),
              const SizedBox(width: AppSpacing.sm),
              Text(entry.timeLabel, style: theme.textTheme.bodySmall),
              const Spacer(),
              Text(
                '${entry.totalCalories} kcal',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.domainDiet,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final f in entry.foods)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(f.name, style: theme.textTheme.bodyMedium),
                  ),
                  Text('${f.calories} kcal', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
