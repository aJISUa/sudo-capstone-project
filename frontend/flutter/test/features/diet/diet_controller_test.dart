import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/features/diet/domain/entities/diet_day.dart';
import 'package:oncare/features/diet/presentation/controllers/diet_controller.dart';

void main() {
  test('dietTodayProvider returns a day with three meals', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final day = await container.read(dietTodayProvider.future);
    expect(day, isA<DietDay>());
    expect(day.entries.length, 3);
    expect(
      day.entries.map((DietEntry e) => e.mealType),
      containsAll(<MealType>[
        MealType.breakfast,
        MealType.lunch,
        MealType.dinner,
      ]),
    );
    expect(
      day.macros.carbsPct + day.macros.proteinPct + day.macros.fatPct,
      100,
    );
  });
}
