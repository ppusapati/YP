import 'package:drift/drift.dart';

import '../database/app_database.dart';

part 'observation_dao.g.dart';

/// Data access object for field observation records.
///
/// Provides CRUD operations and query methods for observations.
@DriftAccessor(tables: [Observations])
class ObservationDao extends DatabaseAccessor<AppDatabase>
    with _$ObservationDaoMixin {
  ObservationDao(super.db);

  /// Retrieves all observations ordered by timestamp descending.
  Future<List<Observation>> getAllObservations() {
    return (select(observations)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  /// Watches all observations.
  Stream<List<Observation>> watchAllObservations() {
    return (select(observations)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .watch();
  }

  /// Retrieves an observation by ID.
  Future<Observation?> getObservationById(String id) {
    return (select(observations)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Retrieves observations for a specific field.
  Future<List<Observation>> getObservationsByField(String fieldId) {
    return (select(observations)
          ..where((t) => t.fieldId.equals(fieldId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  /// Watches observations for a specific field.
  Stream<List<Observation>> watchObservationsByField(String fieldId) {
    return (select(observations)
          ..where((t) => t.fieldId.equals(fieldId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .watch();
  }

  /// Retrieves observations filtered by category.
  Future<List<Observation>> getObservationsByCategory(String category) {
    return (select(observations)
          ..where((t) => t.category.equals(category))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  /// Retrieves observations within a time range.
  Future<List<Observation>> getObservationsInRange({
    required DateTime from,
    required DateTime to,
    String? fieldId,
  }) {
    final query = select(observations)
      ..where((t) =>
          t.timestamp.isBiggerOrEqualValue(from) &
          t.timestamp.isSmallerOrEqualValue(to))
      ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]);

    if (fieldId != null) {
      query.where((t) => t.fieldId.equals(fieldId));
    }

    return query.get();
  }

  /// Inserts or replaces an observation record.
  Future<void> upsertObservation(ObservationsCompanion observation) {
    return into(observations).insertOnConflictUpdate(observation);
  }

  /// Inserts or replaces multiple observations.
  Future<void> upsertObservations(List<ObservationsCompanion> observationList) {
    return batch((batch) {
      for (final obs in observationList) {
        batch.insert(observations, obs, mode: InsertMode.insertOrReplace);
      }
    });
  }

  /// Deletes an observation by ID.
  Future<int> deleteObservationById(String id) {
    return (delete(observations)..where((t) => t.id.equals(id))).go();
  }

  /// Retrieves unsynced observations.
  Future<List<Observation>> getUnsyncedObservations(DateTime since) {
    return (select(observations)
          ..where((t) =>
              t.lastSyncedAt.isNull() |
              t.lastSyncedAt.isSmallerThanValue(since)))
        .get();
  }

  /// Marks an observation as synced.
  Future<void> markSynced(String id) {
    return (update(observations)..where((t) => t.id.equals(id))).write(
      ObservationsCompanion(lastSyncedAt: Value(DateTime.now())),
    );
  }
}
