import 'dart:async';

import 'package:logging/logging.dart';

import '../database/app_database.dart';
import '../models/sync_status.dart';
import 'sync_queue.dart';

/// Callback type for executing a sync operation against the remote API.
///
/// Receives a [SyncQueueEntry] and should return `true` if the operation
/// succeeded, or throw an exception on failure.
typedef SyncExecutor = Future<bool> Function(SyncQueueEntry entry);

/// Manages offline-first data synchronisation.
///
/// Queues mutations when offline, automatically syncs when connectivity
/// is restored, and handles conflict resolution with a last-writer-wins
/// strategy (configurable per entity type).
///
/// Usage:
/// ```dart
/// final syncManager = SyncManager(
///   db: appDatabase,
///   executor: (entry) async {
///     // Call the appropriate service based on entry.entityType
///     return true;
///   },
/// );
///
/// // Listen for status changes
/// syncManager.statusStream.listen((status) {
///   print('Sync: ${status.state}, pending: ${status.pendingCount}');
/// });
///
/// // Queue an offline mutation
/// await syncManager.queueMutation(
///   entityType: 'task',
///   entityId: 'task-123',
///   operation: 'update',
///   payload: {'status': 'COMPLETED'},
/// );
///
/// // Trigger sync when connectivity returns
/// await syncManager.sync();
/// ```
class SyncManager {
  SyncManager({
    required AppDatabase db,
    required this.executor,
    this.batchSize = 10,
    this.syncInterval = const Duration(minutes: 5),
  })  : _syncQueue = SyncQueue(db: db),
        _db = db;

  final AppDatabase _db;
  final SyncQueue _syncQueue;

  /// The function that executes individual sync operations against the server.
  final SyncExecutor executor;

  /// Maximum number of entries to process in a single sync batch.
  final int batchSize;

  /// How often to automatically attempt sync (when periodic sync is enabled).
  final Duration syncInterval;

  static final _log = Logger('SyncManager');

  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  SyncStatus _currentStatus = SyncStatus.initial;
  Timer? _periodicTimer;
  bool _isSyncing = false;

  /// Stream of sync status updates.
  Stream<SyncStatus> get statusStream => _statusController.stream;

  /// The current sync status.
  SyncStatus get currentStatus => _currentStatus;

  /// Queues a mutation for later sync.
  ///
  /// Call this whenever a write operation occurs while offline (or always,
  /// for an offline-first architecture).
  Future<void> queueMutation({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    await _syncQueue.enqueue(
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
    );

    final pendingCount = await _syncQueue.getPendingCount();
    _updateStatus(_currentStatus.copyWith(pendingCount: pendingCount));
    _log.fine('Queued: $operation $entityType/$entityId '
        '(pending: $pendingCount)');
  }

  /// Runs a single sync pass, processing pending entries in batches.
  ///
  /// Returns the number of successfully synced entries.
  Future<int> sync() async {
    if (_isSyncing) {
      _log.fine('Sync already in progress — skipping');
      return 0;
    }

    _isSyncing = true;
    _updateStatus(_currentStatus.copyWith(state: SyncState.syncing));

    var successCount = 0;
    var failedCount = 0;

    try {
      final entries = await _syncQueue.getPendingEntries();

      if (entries.isEmpty) {
        _updateStatus(_currentStatus.copyWith(
          state: SyncState.synced,
          lastSyncedAt: DateTime.now(),
          pendingCount: 0,
        ));
        return 0;
      }

      _log.info('Starting sync: ${entries.length} pending entries');

      // Process in batches.
      for (var i = 0; i < entries.length; i += batchSize) {
        final batch = entries.skip(i).take(batchSize);

        for (final entry in batch) {
          try {
            // Check for conflicts: if a newer version of the same entity
            // exists in the queue, skip older mutations.
            if (await _hasNewerVersion(entry, entries)) {
              _log.fine('Skipping superseded entry: ${entry.id}');
              if (entry.id != null) {
                await _syncQueue.remove(entry.id!);
              }
              continue;
            }

            final success = await executor(entry);

            if (success && entry.id != null) {
              await _syncQueue.remove(entry.id!);
              successCount++;
            }
          } on Exception catch (e) {
            failedCount++;
            if (entry.id != null) {
              await _syncQueue.markFailed(entry.id!, e.toString());
            }
            _log.warning('Failed to sync entry ${entry.id}: $e');
          }
        }
      }

      final remainingPending = await _syncQueue.getPendingCount();
      final failedEntries = await _syncQueue.getFailedEntries();

      _updateStatus(SyncStatus(
        state: failedCount > 0 ? SyncState.error : SyncState.synced,
        lastSyncedAt: DateTime.now(),
        pendingCount: remainingPending,
        failedCount: failedEntries.length,
        errorMessage:
            failedCount > 0 ? '$failedCount entries failed to sync' : null,
      ));

      _log.info('Sync complete: $successCount synced, '
          '$failedCount failed, $remainingPending remaining');
    } on Exception catch (e) {
      _log.severe('Sync error: $e');
      _updateStatus(_currentStatus.copyWith(
        state: SyncState.error,
        errorMessage: e.toString(),
      ));
    } finally {
      _isSyncing = false;
    }

    return successCount;
  }

  /// Starts periodic background sync at [syncInterval].
  void startPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(syncInterval, (_) => sync());
    _log.info('Periodic sync started (interval: ${syncInterval.inMinutes}m)');
  }

  /// Stops periodic background sync.
  void stopPeriodicSync() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _log.info('Periodic sync stopped');
  }

  /// Called when network connectivity is restored.
  ///
  /// Triggers an immediate sync pass.
  Future<void> onConnectivityRestored() async {
    _log.info('Connectivity restored — triggering sync');
    await sync();
  }

  /// Called when the device goes offline.
  void onConnectivityLost() {
    _updateStatus(_currentStatus.copyWith(state: SyncState.offline));
    _log.info('Device offline — sync suspended');
  }

  /// Retries all permanently failed entries.
  Future<void> retryFailedEntries() async {
    await _syncQueue.retryFailed();
    final pendingCount = await _syncQueue.getPendingCount();
    _updateStatus(_currentStatus.copyWith(
      pendingCount: pendingCount,
      failedCount: 0,
    ));
    await sync();
  }

  /// Clears all entries from the sync queue.
  Future<void> clearQueue() async {
    await _syncQueue.clearAll();
    _updateStatus(_currentStatus.copyWith(
      pendingCount: 0,
      failedCount: 0,
    ));
  }

  /// Returns the number of pending sync entries.
  Future<int> getPendingCount() => _syncQueue.getPendingCount();

  /// Releases resources. Call when the sync manager is no longer needed.
  void dispose() {
    _periodicTimer?.cancel();
    _statusController.close();
  }

  // ---------------------------------------------------------------------------
  // Conflict resolution
  // ---------------------------------------------------------------------------

  /// Checks whether a newer version of the same entity exists later
  /// in the queue, making this entry superseded.
  ///
  /// Uses a last-writer-wins strategy: if a more recent mutation
  /// exists for the same entity, the older one can be skipped.
  Future<bool> _hasNewerVersion(
    SyncQueueEntry entry,
    List<SyncQueueEntry> allEntries,
  ) async {
    // Only applies to update operations — creates and deletes are
    // always processed.
    if (entry.operation != 'update') return false;

    final newerExists = allEntries.any((other) =>
        other.id != entry.id &&
        other.entityType == entry.entityType &&
        other.entityId == entry.entityId &&
        other.createdAt.isAfter(entry.createdAt));

    return newerExists;
  }

  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }
}
