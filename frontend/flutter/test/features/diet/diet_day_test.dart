import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/features/diet/domain/entities/diet_day.dart';

void main() {
  test('DietDay constructs with entries, totals and coach message', () {
    const day = DietDay(
      entries: <DietEntry>[
        DietEntry(
          mealType: MealType.breakfast,
          timeLabel: '08:00',
          totalCalories: 300,
          foods: <FoodItem>[FoodItem(name: 'oat', calories: 300)],
          sodiumMg: 100,
          sugarG: 5,
        ),
      ],
      totalCalories: 300,
      totalSodiumMg: 100,
      totalSugarG: 5,
      macros: DietMacros(carbsPct: 60, proteinPct: 20, fatPct: 20),
      aiCoachMessage: 'hello',
    );
    expect(day.entries.first.mealType, MealType.breakfast);
    expect(day.totalCalories, 300);
    expect(day.totalSodiumMg, 100);
    expect(day.aiCoachMessage, 'hello');
  });
}
