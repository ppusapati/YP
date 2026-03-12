/// The current state of the sync engine.
enum SyncState {
  /// No sync is in progress and the local data is up to date.
  idle,

  /// A sync operation is currently in progress.
  syncing,

  /// The last sync completed successfully.
  synced,

  /// The last sync encountered an error.
  error,

  /// The device is offline; sync is suspended.
  offline,
}

/// Represents the overall sync status of the application.
class SyncStatus {
  const SyncStatus({
    required this.state,
    this.lastSyncedAt,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.errorMessage,
  });

  /// The default initial state.
  static const initial = SyncStatus(state: SyncState.idle);

  /// The current sync state.
  final SyncState state;

  /// When the last successful sync completed.
  final DateTime? lastSyncedAt;

  /// Number of mutations pending upload.
  final int pendingCount;

  /// Number of mutations that have failed to sync.
  final int failedCount;

  /// Error message from the last failed sync, if any.
  final String? errorMessage;

  /// Whether there are pending mutations waiting to sync.
  bool get hasPendingChanges => pendingCount > 0;

  /// Creates a copy with the given overrides.
  SyncStatus copyWith({
    SyncState? state,
    DateTime? lastSyncedAt,
    int? pendingCount,
    int? failedCount,
    String? errorMessage,
  }) {
    return SyncStatus(
      state: state ?? this.state,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      pendingCount: pendingCount ?? this.pendingCount,
      failedCount: failedCount ?? this.failedCount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() =>
      'SyncStatus(state: $state, pending: $pendingCount, '
      'failed: $failedCount, lastSynced: $lastSyncedAt)';
}

/// Represents a single entity's sync status.
class EntitySyncStatus {
  const EntitySyncStatus({
    required this.entityType,
    required this.entityId,
    required this.operation,
    this.syncedAt,
    this.error,
    this.retryCount = 0,
  });

  /// The type of entity (e.g., `farm`, `field`, `task`).
  final String entityType;

  /// The entity's primary key.
  final String entityId;

  /// The operation: `create`, `update`, or `delete`.
  final String operation;

  /// When this entity was last successfully synced.
  final DateTime? syncedAt;

  /// The last sync error, if any.
  final String? error;

  /// Number of failed sync attempts.
  final int retryCount;

  /// Whether this entity has been successfully synced.
  bool get isSynced => syncedAt != null && error == null;

  @override
  String toString() =>
      'EntitySyncStatus($entityType/$entityId: $operation, '
      'synced: $isSynced, retries: $retryCount)';
}
