import 'package:drift/drift.dart';

import '../database/app_database.dart';

part 'sensor_dao.g.dart';

/// Data access object for sensor reading records.
///
/// Provides insert, query, and aggregation methods for sensor data.
@DriftAccessor(tables: [SensorReadings])
class SensorDao extends DatabaseAccessor<AppDatabase> with _$SensorDaoMixin {
  SensorDao(super.db);

  /// Retrieves all sensor readings, ordered by timestamp descending.
  Future<List<SensorReading>> getAllReadings() {
    return (select(sensorReadings)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  /// Retrieves readings for a specific sensor.
  Future<List<SensorReading>> getReadingsBySensor(String sensorId) {
    return (select(sensorReadings)
          ..where((t) => t.sensorId.equals(sensorId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  /// Watches readings for a specific sensor.
  Stream<List<SensorReading>> watchReadingsBySensor(String sensorId) {
    return (select(sensorReadings)
          ..where((t) => t.sensorId.equals(sensorId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .watch();
  }

  /// Retrieves readings for a sensor within a time range.
  Future<List<SensorReading>> getReadingsInRange({
    required String sensorId,
    required DateTime from,
    required DateTime to,
  }) {
    return (select(sensorReadings)
          ..where((t) =>
              t.sensorId.equals(sensorId) &
              t.timestamp.isBiggerOrEqualValue(from) &
              t.timestamp.isSmallerOrEqualValue(to))
          ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]))
        .get();
  }

  /// Retrieves readings filtered by sensor type.
  Future<List<SensorReading>> getReadingsByType(String type) {
    return (select(sensorReadings)
          ..where((t) => t.type.equals(type))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
  }

  /// Retrieves the latest reading for a sensor.
  Future<SensorReading?> getLatestReading(String sensorId) {
    return (select(sensorReadings)
          ..where((t) => t.sensorId.equals(sensorId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Inserts a new sensor reading.
  Future<int> insertReading(SensorReadingsCompanion reading) {
    return into(sensorReadings).insert(reading);
  }

  /// Inserts multiple sensor readings in a batch.
  Future<void> insertReadings(List<SensorReadingsCompanion> readings) {
    return batch((batch) {
      batch.insertAll(sensorReadings, readings);
    });
  }

  /// Deletes readings older than [cutoff].
  Future<int> deleteOldReadings(DateTime cutoff) {
    return (delete(sensorReadings)
          ..where((t) => t.timestamp.isSmallerThanValue(cutoff)))
        .go();
  }

  /// Deletes all readings for a sensor.
  Future<int> deleteReadingsBySensor(String sensorId) {
    return (delete(sensorReadings)
          ..where((t) => t.sensorId.equals(sensorId)))
        .go();
  }

  /// Retrieves unsynced sensor readings.
  Future<List<SensorReading>> getUnsyncedReadings() {
    return (select(sensorReadings)
          ..where((t) => t.lastSyncedAt.isNull()))
        .get();
  }

  /// Marks a reading as synced.
  Future<void> markSynced(int localId) {
    return (update(sensorReadings)..where((t) => t.localId.equals(localId)))
        .write(
      SensorReadingsCompanion(lastSyncedAt: Value(DateTime.now())),
    );
  }
}
