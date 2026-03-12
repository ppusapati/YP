import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import '../database/app_database.dart';

/// Represents an operation in the offline sync queue.
class SyncQueueEntry {
  const SyncQueueEntry({
    this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
    this.lastError,
  });

  /// The local auto-incremented ID.
  final int? id;

  /// The entity type (e.g., `farm`, `field`, `task`).
  final String entityType;

  /// The entity's primary key.
  final String entityId;

  /// The mutation operation: `create`, `update`, or `delete`.
  final String operation;

  /// The JSON-serialised payload.
  final Map<String, dynamic> payload;

  /// When the entry was queued.
  final DateTime createdAt;

  /// Number of sync attempts so far.
  final int retryCount;

  /// Last error message, if any.
  final String? lastError;

  /// Maximum number of retry attempts before the entry is considered failed.
  static const int maxRetries = 5;

  /// Whether this entry has exceeded the retry limit.
  bool get isExhausted => retryCount >= maxRetries;

  /// Creates a [SyncQueueEntry] from a Drift [OfflineQueueData] row.
  factory SyncQueueEntry.fromRow(OfflineQueueData row) {
    return SyncQueueEntry(
      id: row.id,
      entityType: row.entityType,
      entityId: row.entityId,
      operation: row.operation,
      payload: json.decode(row.payloadJson) as Map<String, dynamic>,
      createdAt: row.createdAt,
      retryCount: row.retryCount,
      lastError: row.lastError,
    );
  }

  /// Converts to a Drift companion for database insertion.
  OfflineQueueCompanion toCompanion() {
    return OfflineQueueCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payloadJson: Value(json.encode(payload)),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: Value(lastError),
    );
  }

  @override
  String toString() =>
      'SyncQueueEntry($operation $entityType/$entityId, '
      'retries: $retryCount)';
}

/// Manages the offline sync queue stored in the local database.
///
/// Operations are queued when the device is offline and processed
/// in FIFO order when connectivity is restored.
class SyncQueue {
  SyncQueue({required this.db});

  final AppDatabase db;
  static final _log = Logger('SyncQueue');

  /// Enqueues a new mutation for later sync.
  Future<void> enqueue({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final entry = SyncQueueEntry(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      createdAt: DateTime.now(),
    );

    await db.into(db.offlineQueue).insert(entry.toCompanion());
    _log.fine('Enqueued: $operation $entityType/$entityId');
  }

  /// Returns all pending (non-exhausted) entries in FIFO order.
  Future<List<SyncQueueEntry>> getPendingEntries() async {
    final rows = await (db.select(db.offlineQueue)
          ..where((t) => t.retryCount.isSmallerThanValue(SyncQueueEntry.maxRetries))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();

    return rows.map(SyncQueueEntry.fromRow).toList();
  }

  /// Returns all entries (including exhausted) in FIFO order.
  Future<List<SyncQueueEntry>> getAllEntries() async {
    final rows = await (db.select(db.offlineQueue)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();

    return rows.map(SyncQueueEntry.fromRow).toList();
  }

  /// Returns entries that have exceeded the retry limit.
  Future<List<SyncQueueEntry>> getFailedEntries() async {
    final rows = await (db.select(db.offlineQueue)
          ..where(
              (t) => t.retryCount.isBiggerOrEqualValue(SyncQueueEntry.maxRetries))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();

    return rows.map(SyncQueueEntry.fromRow).toList();
  }

  /// Returns the count of pending entries.
  Future<int> getPendingCount() async {
    final entries = await getPendingEntries();
    return entries.length;
  }

  /// Removes a successfully synced entry from the queue.
  Future<void> remove(int entryId) async {
    await (db.delete(db.offlineQueue)
          ..where((t) => t.id.equals(entryId)))
        .go();
    _log.fine('Removed synced entry: $entryId');
  }

  /// Increments the retry count and records the error for a failed entry.
  Future<void> markFailed(int entryId, String error) async {
    await (db.update(db.offlineQueue)
          ..where((t) => t.id.equals(entryId)))
        .write(
      OfflineQueueCompanion(
        retryCount: db.offlineQueue.retryCount + const Variable(1),
        lastError: Value(error),
      ),
    );
    _log.warning('Entry $entryId failed: $error');
  }

  /// Clears all entries from the queue.
  Future<void> clearAll() async {
    await db.delete(db.offlineQueue).go();
    _log.info('Sync queue cleared');
  }

  /// Clears only exhausted (permanently failed) entries.
  Future<void> clearFailed() async {
    await (db.delete(db.offlineQueue)
          ..where(
              (t) => t.retryCount.isBiggerOrEqualValue(SyncQueueEntry.maxRetries)))
        .go();
    _log.info('Failed entries cleared from sync queue');
  }

  /// Resets the retry count for failed entries so they can be retried.
  Future<void> retryFailed() async {
    await (db.update(db.offlineQueue)
          ..where(
              (t) => t.retryCount.isBiggerOrEqualValue(SyncQueueEntry.maxRetries)))
        .write(
      const OfflineQueueCompanion(
        retryCount: Value(0),
        lastError: Value(null),
      ),
    );
    _log.info('Failed entries reset for retry');
  }
}
