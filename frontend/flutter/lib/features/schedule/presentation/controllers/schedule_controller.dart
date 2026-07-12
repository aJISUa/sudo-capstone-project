import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare/core/network/dio_client.dart';
import 'package:oncare/features/schedule/data/repositories/dio_schedule_repository.dart';
import 'package:oncare/features/schedule/domain/entities/schedule_event.dart';
import 'package:oncare/features/schedule/domain/repositories/schedule_repository.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) => DioScheduleRepository(ref.watch(dioProvider)),
  name: 'scheduleRepository',
);

/// Events for a given `YYYY-MM-DD` (defaults are read directly by the
/// caller). Auto-disposes so navigating away frees the cache.
final scheduleEventsProvider = FutureProvider.autoDispose
    .family<List<ScheduleEvent>, String>(
      (ref, date) => ref.watch(scheduleRepositoryProvider).fetchByDate(date),
      name: 'scheduleEvents',
    );

/// Events for a given `YYYY-MM` month (calendar grid). Auto-disposes.
final scheduleMonthProvider = FutureProvider.autoDispose
    .family<List<ScheduleEvent>, String>(
      (ref, month) => ref.watch(scheduleRepositoryProvider).fetchByMonth(month),
      name: 'scheduleMonth',
    );
