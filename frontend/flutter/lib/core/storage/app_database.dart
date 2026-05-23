import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_database.g.dart';

/// Generic key-value table. Used for tiny app-level state (locale,
/// onboarding flags) and as a stash for JSON snapshots that don't yet
/// warrant their own table (MyHealthState, AiCoachState, …).
class AppKeyValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}

@DataClassName('DietEntryRow')
class DietEntries extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get mealType => text()(); // breakfast|lunch|dinner|snack
  TextColumn get timeLabel => text()(); // "08:20"
  TextColumn get foodsJson => text()(); // [{ "name": "...", "calories": ... }]
  IntColumn get totalCalories => integer()();
  IntColumn get sodiumMg => integer().withDefault(const Constant(0))();
  IntColumn get sugarG => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('ExerciseSessionRow')
class ExerciseSessions extends Table {
  TextColumn get id => text()();
  TextColumn get weekStart => text()(); // Monday YYYY-MM-DD
  TextColumn get dayLabel => text()(); // 월/화/수/...
  TextColumn get type => text()(); // cardio|strength|yoga|walking
  IntColumn get minutes => integer()();
  IntColumn get calories => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('VitalRow')
class Vitals extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()(); // weight|blood-pressure|blood-sugar
  TextColumn get valueJson =>
      text()(); // {"kg":68.2} / {"systolic":..} / {"mg_per_dl":..}
  DateTimeColumn get recordedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('ScheduleEventRow')
class ScheduleEvents extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get time => text()(); // "10:00"
  TextColumn get title => text()();
  TextColumn get category =>
      text()(); // hospital|exercise|meal|medication|other
  TextColumn get emoji => text().withDefault(const Constant(''))();
  TextColumn get colorHex => text().withDefault(const Constant('#E0F2F7'))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DataClassName('NotificationRow')
class NotificationItems extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get category =>
      text()(); // reminder|health_check|achievement|system
  BoolColumn get read => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@DriftDatabase(
  tables: <Type>[
    AppKeyValues,
    DietEntries,
    ExerciseSessions,
    Vitals,
    ScheduleEvents,
    NotificationItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(
        driftDatabase(
          name: 'oncare',
          // On web, drift needs the sqlite3 WASM module and a worker
          // script. The release CI downloads both into `web/` so the
          // bundled `index.html` can fetch them at the same origin.
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  /// Use in tests:
  ///   `AppDatabase.forTesting(NativeDatabase.memory())`
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(dietEntries);
        await m.createTable(exerciseSessions);
        await m.createTable(vitals);
        await m.createTable(scheduleEvents);
        await m.createTable(notificationItems);
      }
    },
  );

  // ---- AppKeyValues ----
  Future<void> putValue(String key, String value) {
    return into(appKeyValues).insertOnConflictUpdate(
      AppKeyValuesCompanion.insert(key: key, value: value),
    );
  }

  Future<String?> readValue(String key) async {
    final row = await (select(
      appKeyValues,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> deleteValue(String key) {
    return (delete(appKeyValues)..where((t) => t.key.equals(key))).go();
  }
}

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}, name: 'appDatabase');
