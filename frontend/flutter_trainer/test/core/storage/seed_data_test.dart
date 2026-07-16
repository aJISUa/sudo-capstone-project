import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oncare_trainer/core/storage/app_database.dart';
import 'package:oncare_trainer/core/storage/seed_data.dart';

String _todayString() {
  final now = DateTime.now();
  return '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('seedIfEmpty', () {
    test('first run seeds 3 clients with their related data', () async {
      await seedIfEmpty(db);

      final clients = await db.select(db.trainerClients).get();
      expect(clients.length, 3);
      expect(
        clients.map((c) => c.name).toSet(),
        <String>{'김민수', '이지수', '박성호'},
      );

      // Each client has 3 meals, 3 AI routines, 3 history entries, chat.
      final diet = await db.select(db.clientDietEntries).get();
      final routines = await db.select(db.clientAiRoutines).get();
      final history = await db.select(db.clientRoutineHistory).get();
      final chat = await db.select(db.clientChatMessages).get();
      expect(diet.length, 9);
      expect(routines.length, 9);
      expect(history.length, 9);
      expect(chat, isNotEmpty);

      // weekCompletion is stored as a 7-length JSON array.
      final minsu = clients.firstWhere((c) => c.name == '김민수');
      expect(
        (jsonDecode(minsu.weekCompletionJson) as List<Object?>).length,
        7,
      );

      expect(await db.readValue('trainer_seeded_v1'), _todayString());
    });

    test('schedule seeds onto today (never empty on a later day)', () async {
      await seedIfEmpty(db);

      final schedule = await db.select(db.trainerScheduleEntries).get();
      expect(schedule, isNotEmpty);
      expect(
        schedule.every((s) => s.date == _todayString()),
        isTrue,
        reason: 'all schedule rows must slide onto today',
      );
      // Program JSON is well-formed for a PT session.
      final pt = schedule.firstWhere((s) => s.clientName == '김민수');
      expect(jsonDecode(pt.programJson), isA<List<Object?>>());
    });

    test('same-day re-run is a no-op (no duplicates)', () async {
      await seedIfEmpty(db);
      final before = await db.select(db.trainerClients).get();

      await seedIfEmpty(db);
      final after = await db.select(db.trainerClients).get();

      expect(after.length, before.length);
    });

    test('stale flag (different date) re-seeds schedule onto today',
        () async {
      await seedIfEmpty(db);
      await db.putValue('trainer_seeded_v1', '2020-01-01');

      await seedIfEmpty(db);

      final schedule = await db.select(db.trainerScheduleEntries).get();
      expect(schedule.every((s) => s.date == _todayString()), isTrue);
      expect(await db.readValue('trainer_seeded_v1'), _todayString());
    });

    test('user-added (non-seed) chat messages survive a re-seed', () async {
      await seedIfEmpty(db);

      // A trainer reply added at runtime — no seed- prefix.
      await db
          .into(db.clientChatMessages)
          .insert(
            ClientChatMessagesCompanion.insert(
              id: 'chat-runtime-1',
              clientId: 'seed-client-1',
              sender: 'trainer',
              body: '다음 세션 때 봐요!',
              timeLabel: '21:00',
              createdAt: DateTime.now(),
            ),
          );

      // Force a re-seed.
      await db.putValue('trainer_seeded_v1', '2020-01-01');
      await seedIfEmpty(db);

      final chat = await db.select(db.clientChatMessages).get();
      expect(
        chat.any((m) => m.id == 'chat-runtime-1'),
        isTrue,
        reason: 'rows without a seed- prefix must never be wiped',
      );
    });
  });
}
