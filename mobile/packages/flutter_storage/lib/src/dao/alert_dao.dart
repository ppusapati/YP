import 'package:drift/drift.dart';

import '../database/app_database.dart';

part 'alert_dao.g.dart';

/// Data access object for alert records.
///
/// Provides CRUD operations, read/unread filtering, and query methods.
@DriftAccessor(tables: [Alerts])
class AlertDao extends DatabaseAccessor<AppDatabase> with _$AlertDaoMixin {
  AlertDao(super.db);

  /// Retrieves all alerts ordered by timestamp descending.
  Future<List<Alert>> getAllAlerts() {
    return (select(alerts)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  /// Watches all alerts.
  Stream<List<Alert>> watchAllAlerts() {
    return (select(alerts)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .watch();
  }

  /// Retrieves an alert by ID.
  Future<Alert?> getAlertById(String id) {
    return (select(alerts)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Retrieves alerts for a specific farm.
  Future<List<Alert>> getAlertsByFarm(String farmId) {
    return (select(alerts)
          ..where((t) => t.farmId.equals(farmId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  /// Watches alerts for a specific farm.
  Stream<List<Alert>> watchAlertsByFarm(String farmId) {
    return (select(alerts)
          ..where((t) => t.farmId.equals(farmId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .watch();
  }

  /// Retrieves unread alerts.
  Future<List<Alert>> getUnreadAlerts() {
    return (select(alerts)
          ..where((t) => t.read.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  /// Watches unread alerts.
  Stream<List<Alert>> watchUnreadAlerts() {
    return (select(alerts)
          ..where((t) => t.read.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .watch();
  }

  /// Returns the count of unread alerts.
  Future<int> getUnreadCount() async {
    final unread = await getUnreadAlerts();
    return unread.length;
  }

  /// Watches the count of unread alerts.
  Stream<int> watchUnreadCount() {
    return watchUnreadAlerts().map((alerts) => alerts.length);
  }

  /// Retrieves alerts filtered by type.
  Future<List<Alert>> getAlertsByType(String type) {
    return (select(alerts)
          ..where((t) => t.type.equals(type))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  /// Retrieves alerts filtered by severity.
  Future<List<Alert>> getAlertsBySeverity(String severity) {
    return (select(alerts)
          ..where((t) => t.severity.equals(severity))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  /// Inserts or replaces an alert record.
  Future<void> upsertAlert(AlertsCompanion alert) {
    return into(alerts).insertOnConflictUpdate(alert);
  }

  /// Inserts or replaces multiple alert records.
  Future<void> upsertAlerts(List<AlertsCompanion> alertList) {
    return batch((batch) {
      for (final alert in alertList) {
        batch.insert(alerts, alert, mode: InsertMode.insertOrReplace);
      }
    });
  }

  /// Marks an alert as read.
  Future<void> markAsRead(String id) {
    return (update(alerts)..where((t) => t.id.equals(id))).write(
      const AlertsCompanion(read: Value(true)),
    );
  }

  /// Marks all alerts as read.
  Future<void> markAllAsRead() {
    return update(alerts).write(const AlertsCompanion(read: Value(true)));
  }

  /// Deletes an alert by ID.
  Future<int> deleteAlertById(String id) {
    return (delete(alerts)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes alerts older than [cutoff].
  Future<int> deleteOldAlerts(DateTime cutoff) {
    return (delete(alerts)
          ..where((t) => t.timestamp.isSmallerThanValue(cutoff)))
        .go();
  }
}
