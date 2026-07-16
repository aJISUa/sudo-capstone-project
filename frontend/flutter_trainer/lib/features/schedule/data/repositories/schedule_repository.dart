import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare_trainer/core/storage/app_database.dart';
import 'package:oncare_trainer/features/schedule/domain/entities/schedule_session.dart';

/// Reads the trainer's daily timeline from the local drift DB.
class ScheduleRepository {
  /// Creates the repository over [_db].
  const ScheduleRepository(this._db);

  final AppDatabase _db;

  /// Today's slots in timeline order (including 공백 gaps).
  Stream<List<ScheduleSession>> watchToday() {
    final query = _db.select(_db.trainerScheduleEntries)
      ..where((t) => t.date.equals(_todayString()))
      ..orderBy(<OrderingTerm Function($TrainerScheduleEntriesTable)>[
        (t) => OrderingTerm(expression: t.sortOrder),
      ]);
    return query.watch().map(
      (rows) => rows.map(_toEntity).toList(),
    );
  }

  ScheduleSession _toEntity(TrainerScheduleRow row) {
    final program = (jsonDecode(row.programJson) as List<Object?>)
        .map((e) => e! as Map<String, Object?>)
        .map(
          (m) => ProgramItem(
            name: m['name']! as String,
            sets: m['sets']! as int,
            reps: m['reps']! as String,
            weight: m['weight']! as String,
          ),
        )
        .toList();
    return ScheduleSession(
      id: row.id,
      time: row.time,
      clientName: row.clientName,
      type: row.type,
      durationMinutes: row.durationMinutes,
      status: row.status,
      note: row.note,
      program: program,
    );
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }
}

/// Provides the [ScheduleRepository].
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository(ref.watch(appDatabaseProvider));
});

/// Streams today's timeline for the 스케줄 tab.
final todayScheduleProvider = StreamProvider<List<ScheduleSession>>((ref) {
  return ref.watch(scheduleRepositoryProvider).watchToday();
});
