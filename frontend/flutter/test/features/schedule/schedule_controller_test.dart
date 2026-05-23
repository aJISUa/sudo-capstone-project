import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare/features/schedule/data/repositories/mock_schedule_repository.dart';
import 'package:oncare/features/schedule/domain/entities/schedule_event.dart';
import 'package:oncare/features/schedule/presentation/controllers/schedule_controller.dart';

void main() {
  test(
    'scheduleEventsProvider returns mock list for the requested date',
    () async {
      final container = ProviderContainer(
        overrides: <Override>[
          scheduleRepositoryProvider.overrideWithValue(
            const MockScheduleRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      const date = '2026-05-20';
      final events = await container.read(scheduleEventsProvider(date).future);
      expect(events.length, 2);
      expect(events.first.title, '병원 정기검진');
      expect(events.first.category, ScheduleCategory.hospital);
      expect(events.last.category, ScheduleCategory.exercise);
      // All events carry the requested date.
      for (final e in events) {
        expect(e.date, date);
      }
    },
  );
}
