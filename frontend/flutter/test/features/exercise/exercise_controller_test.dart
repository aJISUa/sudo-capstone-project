import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/features/exercise/presentation/controllers/exercise_controller.dart';

void main() {
  test('exerciseWeekProvider provides 7 days, sane average', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final week = await container.read(exerciseWeekProvider.future);
    expect(week.dailyMinutes.length, 7);
    expect(week.dayLabels.length, 7);
    expect(week.totalMinutes, 240);
    expect(week.averageMinutes, closeTo(34.28, 0.01));
    expect(week.sessions, isNotEmpty);
  });
}
