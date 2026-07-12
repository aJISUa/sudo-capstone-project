import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/features/schedule/domain/entities/schedule_event.dart';
import 'package:oncare/features/schedule/presentation/schedule_category_color.dart';

void main() {
  test('each category maps to a distinct color', () {
    final colors = ScheduleCategory.values.map(scheduleCategoryColor).toList();
    expect(
      colors.toSet().length,
      ScheduleCategory.values.length,
      reason: 'categories must be visually distinguishable on the calendar',
    );
  });

  test('same category always maps to the same color', () {
    for (final ScheduleCategory c in ScheduleCategory.values) {
      expect(scheduleCategoryColor(c), scheduleCategoryColor(c));
    }
  });

  test('every category has a Korean label', () {
    for (final ScheduleCategory c in ScheduleCategory.values) {
      expect(scheduleCategoryLabel(c), isNotEmpty);
    }
  });
}
