import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:oncare_trainer/core/storage/app_database.dart';
import 'package:oncare_trainer/features/clients/domain/entities/client_chat_message.dart';

/// Reads and appends messages in a client's chat thread (drift-backed).
class ChatRepository {
  /// Creates the repository over [_db].
  const ChatRepository(this._db);

  final AppDatabase _db;

  /// Streams a client's messages in chronological order.
  Stream<List<ClientChatMessage>> watchThread(String clientId) {
    final query = _db.select(_db.clientChatMessages)
      ..where((t) => t.clientId.equals(clientId))
      ..orderBy(<OrderingTerm Function($ClientChatMessagesTable)>[
        (t) => OrderingTerm(expression: t.createdAt),
      ]);
    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  /// Appends a trainer message. The `chat-` id (no `seed-` prefix) means
  /// it survives re-seeding, and `now()` sorts it after the seed thread.
  Future<void> sendTrainerMessage({
    required String clientId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final now = DateTime.now();
    await _db
        .into(_db.clientChatMessages)
        .insert(
          ClientChatMessagesCompanion.insert(
            id: 'chat-$clientId-${now.microsecondsSinceEpoch}',
            clientId: clientId,
            sender: 'trainer',
            body: trimmed,
            timeLabel: _timeLabel(now),
            createdAt: now,
          ),
        );
  }

  ClientChatMessage _toEntity(ClientChatMessageRow row) {
    return ClientChatMessage(
      id: row.id,
      sender: row.sender == 'trainer' ? ChatSender.trainer : ChatSender.client,
      body: row.body,
      timeLabel: row.timeLabel,
      createdAt: row.createdAt,
    );
  }

  static String _timeLabel(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';
}

/// Provides the [ChatRepository].
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(appDatabaseProvider));
});

/// Streams a client's chat thread by client id.
final chatThreadProvider =
    StreamProvider.family<List<ClientChatMessage>, String>((ref, clientId) {
      return ref.watch(chatRepositoryProvider).watchThread(clientId);
    });
