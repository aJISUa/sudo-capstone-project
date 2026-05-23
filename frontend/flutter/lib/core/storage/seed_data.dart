import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:oncare/core/storage/app_database.dart';

/// Idempotent seeder. Runs at bootstrap; if the `seeded_v2` flag is
/// already set in `AppKeyValues`, returns immediately. Otherwise it
/// inserts the React prototype's mock data into the new resource
/// tables.
///
/// v2 (vs v1) re-seeds the weekly exercise sessions with multi-type
/// rows per day so the `WeeklyActivity` stacked-bar chart renders the
/// 유산소 / 근력 / 스트레칭 breakdown the prototype shows.
Future<void> seedIfEmpty(AppDatabase db) async {
  final flag = await db.readValue('seeded_v2');
  if (flag == 'true') return;

  // Wipe v1 exercise rows so the new shape lands cleanly — keep
  // anything the user added after upgrading.
  await (db.delete(
    db.exerciseSessions,
  )..where((t) => t.id.like('seed-ex-%'))).go();

  final today = _fmtDate(DateTime.now());
  final weekStart = _fmtDate(_mondayOfThisWeek(DateTime.now()));

  await db.transaction(() async {
    // ---- Diet entries (3 meals for today) ----
    await db.batch((Batch b) {
      b.insertAll(db.dietEntries, <DietEntriesCompanion>[
        DietEntriesCompanion.insert(
          id: 'seed-diet-breakfast',
          date: today,
          mealType: 'breakfast',
          timeLabel: '08:20',
          foodsJson: jsonEncode(<Map<String, Object?>>[
            <String, Object?>{'name': '오트밀', 'calories': 220},
            <String, Object?>{'name': '바나나 1개', 'calories': 90},
            <String, Object?>{'name': '아메리카노', 'calories': 5},
          ]),
          totalCalories: 315,
          sodiumMg: const Value(380),
          sugarG: const Value(18),
        ),
        DietEntriesCompanion.insert(
          id: 'seed-diet-lunch',
          date: today,
          mealType: 'lunch',
          timeLabel: '12:40',
          foodsJson: jsonEncode(<Map<String, Object?>>[
            <String, Object?>{'name': '닭가슴살 샐러드', 'calories': 380},
            <String, Object?>{'name': '현미밥 반공기', 'calories': 150},
          ]),
          totalCalories: 530,
          sodiumMg: const Value(1120),
          sugarG: const Value(14),
        ),
        DietEntriesCompanion.insert(
          id: 'seed-diet-dinner',
          date: today,
          mealType: 'dinner',
          timeLabel: '19:00',
          foodsJson: jsonEncode(<Map<String, Object?>>[
            <String, Object?>{'name': '연어 스테이크', 'calories': 420},
            <String, Object?>{'name': '구운 야채', 'calories': 155},
          ]),
          totalCalories: 575,
          sodiumMg: const Value(600),
          sugarG: const Value(13),
        ),
      ]);
    });

    // ---- Exercise sessions ----
    // Per-day breakdown matches the prototype's WeeklyActivity stack:
    // 월 40 (30+10), 화 60 (45+10+5), 수 50 (40+10),
    // 목 65 (50+10+5), 금 55 (45+5+5), 토 80 (30+30+20), 일 0.
    await db.batch((Batch b) {
      b.insertAll(db.exerciseSessions, <ExerciseSessionsCompanion>[
        // ---- Mon ----
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-mon-c',
          weekStart: weekStart,
          dayLabel: '월',
          type: 'cardio',
          minutes: 30,
          calories: 225,
        ),
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-mon-s',
          weekStart: weekStart,
          dayLabel: '월',
          type: 'stretching',
          minutes: 10,
          calories: 30,
        ),
        // ---- Tue ----
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-tue-c',
          weekStart: weekStart,
          dayLabel: '화',
          type: 'cardio',
          minutes: 45,
          calories: 337,
        ),
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-tue-w',
          weekStart: weekStart,
          dayLabel: '화',
          type: 'strength',
          minutes: 10,
          calories: 50,
        ),
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-tue-s',
          weekStart: weekStart,
          dayLabel: '화',
          type: 'stretching',
          minutes: 5,
          calories: 15,
        ),
        // ---- Wed ----
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-wed-c',
          weekStart: weekStart,
          dayLabel: '수',
          type: 'cardio',
          minutes: 40,
          calories: 300,
        ),
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-wed-s',
          weekStart: weekStart,
          dayLabel: '수',
          type: 'stretching',
          minutes: 10,
          calories: 30,
        ),
        // ---- Thu ----
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-thu-c',
          weekStart: weekStart,
          dayLabel: '목',
          type: 'cardio',
          minutes: 50,
          calories: 375,
        ),
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-thu-w',
          weekStart: weekStart,
          dayLabel: '목',
          type: 'strength',
          minutes: 10,
          calories: 50,
        ),
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-thu-s',
          weekStart: weekStart,
          dayLabel: '목',
          type: 'stretching',
          minutes: 5,
          calories: 15,
        ),
        // ---- Fri ----
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-fri-c',
          weekStart: weekStart,
          dayLabel: '금',
          type: 'cardio',
          minutes: 45,
          calories: 337,
        ),
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-fri-w',
          weekStart: weekStart,
          dayLabel: '금',
          type: 'strength',
          minutes: 5,
          calories: 25,
        ),
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-fri-s',
          weekStart: weekStart,
          dayLabel: '금',
          type: 'stretching',
          minutes: 5,
          calories: 15,
        ),
        // ---- Sat ----
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-sat-c',
          weekStart: weekStart,
          dayLabel: '토',
          type: 'cardio',
          minutes: 30,
          calories: 225,
        ),
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-sat-w',
          weekStart: weekStart,
          dayLabel: '토',
          type: 'strength',
          minutes: 30,
          calories: 150,
        ),
        ExerciseSessionsCompanion.insert(
          id: 'seed-ex-sat-s',
          weekStart: weekStart,
          dayLabel: '토',
          type: 'stretching',
          minutes: 20,
          calories: 60,
        ),
      ]);
    });

    // ---- Today's schedule (2 events) ----
    await db.batch((Batch b) {
      b.insertAll(db.scheduleEvents, <ScheduleEventsCompanion>[
        ScheduleEventsCompanion.insert(
          id: 'seed-evt-hospital',
          date: today,
          time: '10:00',
          title: '병원 정기검진',
          category: 'hospital',
          emoji: const Value('🏥'),
          colorHex: const Value('#FEE2E2'),
        ),
        ScheduleEventsCompanion.insert(
          id: 'seed-evt-gym',
          date: today,
          time: '18:00',
          title: '헬스장 운동',
          category: 'exercise',
          emoji: const Value('💪'),
          colorHex: const Value('#DCFCE7'),
        ),
      ]);
    });

    // ---- Vitals (latest blood sugar, matches React mock 95 mg/dL) ----
    await db
        .into(db.vitals)
        .insert(
          VitalsCompanion.insert(
            id: 'seed-vital-bs',
            kind: 'blood-sugar',
            valueJson: jsonEncode(<String, Object?>{'mg_per_dl': 95}),
            recordedAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        );

    // ---- Notifications ----
    final now = DateTime.now();
    await db.batch((Batch b) {
      b.insertAll(db.notificationItems, <NotificationItemsCompanion>[
        NotificationItemsCompanion.insert(
          id: 'seed-noti-1',
          createdAt: now.subtract(const Duration(minutes: 10)),
          title: '식단 입력 알림',
          body: '오늘 점심 입력이 비어있어요.',
          category: 'reminder',
        ),
        NotificationItemsCompanion.insert(
          id: 'seed-noti-2',
          createdAt: now.subtract(const Duration(hours: 1)),
          title: '운동 목표 달성',
          body: '주간 운동 240분 달성!',
          category: 'achievement',
        ),
        NotificationItemsCompanion.insert(
          id: 'seed-noti-3',
          createdAt: now.subtract(const Duration(hours: 3)),
          title: '체중 측정 권장',
          body: '오늘 체중을 기록해 보세요.',
          category: 'health_check',
          read: const Value(true),
        ),
        NotificationItemsCompanion.insert(
          id: 'seed-noti-4',
          createdAt: now.subtract(const Duration(days: 1)),
          title: '서비스 점검 안내',
          body: '내일 02:00~03:00 점검 예정입니다.',
          category: 'system',
          read: const Value(true),
        ),
      ]);
    });
  });

  await db.putValue('seeded_v2', 'true');
}

String _fmtDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime _mondayOfThisWeek(DateTime now) {
  final weekday = now.weekday; // 1 = Mon ... 7 = Sun
  return DateTime(now.year, now.month, now.day - (weekday - 1));
}
