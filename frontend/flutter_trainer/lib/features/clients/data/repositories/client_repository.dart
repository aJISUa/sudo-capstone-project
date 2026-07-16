import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare_trainer/core/storage/app_database.dart';
import 'package:oncare_trainer/features/clients/domain/entities/trainer_client.dart';

/// Reads client + schedule data from the local drift DB for the
/// 고객 관리 tab. Returns reactive streams so the UI updates if the
/// underlying rows change (e.g. a routine sent from another tab).
class ClientRepository {
  /// Creates the repository over [_db].
  const ClientRepository(this._db);

  final AppDatabase _db;

  /// All clients, ordered as seeded (sortOrder).
  Stream<List<TrainerClient>> watchClients() {
    final query = _db.select(_db.trainerClients)
      ..orderBy(<OrderingTerm Function($TrainerClientsTable)>[
        (t) => OrderingTerm(expression: t.sortOrder),
      ]);
    return query.watch().map(
      (rows) => rows.map(_toEntity).toList(),
    );
  }

  /// Count of today's booked sessions — every schedule slot dated today
  /// that isn't a gap (`공백`). Drives the "오늘 N명 예약" header badge.
  /// Uses a SQL `COUNT(*)` aggregate rather than loading every row.
  Stream<int> watchTodayReservationCount() {
    final today = _todayString();
    final table = _db.trainerScheduleEntries;
    final count = countAll();
    final query = _db.selectOnly(table)
      ..addColumns(<Expression<Object>>[count])
      ..where(table.date.equals(today) & table.status.equals('공백').not());
    return query.map((row) => row.read(count) ?? 0).watchSingle();
  }

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  TrainerClient _toEntity(TrainerClientRow row) {
    final week = (jsonDecode(row.weekCompletionJson) as List<Object?>)
        .map((e) => e as int)
        .toList();
    return TrainerClient(
      id: row.id,
      name: row.name,
      avatar: row.avatar,
      goal: row.goal,
      lastMessage: row.lastMessage,
      lastTime: row.lastTime,
      active: row.active,
      calories: row.caloriesToday,
      sodiumMg: row.sodiumMg,
      sugarG: row.sugarG,
      lastRoutine: row.lastRoutine,
      weekCompletion: week,
    );
  }
}

/// Provides the [ClientRepository] wired to the app database.
final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository(ref.watch(appDatabaseProvider));
});

/// Streams the client list for the 고객 관리 tab.
final clientsProvider = StreamProvider<List<TrainerClient>>((ref) {
  return ref.watch(clientRepositoryProvider).watchClients();
});

/// Streams today's booked-session count for the header badge.
final todayReservationCountProvider = StreamProvider<int>((ref) {
  return ref.watch(clientRepositoryProvider).watchTodayReservationCount();
});
