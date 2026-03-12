import 'package:drift/drift.dart';

import '../database/app_database.dart';

part 'farm_dao.g.dart';

/// Data access object for farm records.
///
/// Provides CRUD operations and query methods for the local farms table.
@DriftAccessor(tables: [Farms])
class FarmDao extends DatabaseAccessor<AppDatabase> with _$FarmDaoMixin {
  FarmDao(super.db);

  /// Retrieves all farms from the local database.
  Future<List<Farm>> getAllFarms() => select(farms).get();

  /// Watches all farms, emitting a new list whenever data changes.
  Stream<List<Farm>> watchAllFarms() => select(farms).watch();

  /// Retrieves a farm by its unique identifier, or `null` if not found.
  Future<Farm?> getFarmById(String id) {
    return (select(farms)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Watches a single farm by ID.
  Stream<Farm?> watchFarmById(String id) {
    return (select(farms)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Retrieves all farms belonging to [ownerId].
  Future<List<Farm>> getFarmsByOwner(String ownerId) {
    return (select(farms)..where((t) => t.ownerId.equals(ownerId))).get();
  }

  /// Watches farms belonging to [ownerId].
  Stream<List<Farm>> watchFarmsByOwner(String ownerId) {
    return (select(farms)..where((t) => t.ownerId.equals(ownerId))).watch();
  }

  /// Inserts or replaces a farm record.
  Future<void> upsertFarm(FarmsCompanion farm) {
    return into(farms).insertOnConflictUpdate(farm);
  }

  /// Inserts or replaces multiple farm records in a single transaction.
  Future<void> upsertFarms(List<FarmsCompanion> farmList) {
    return batch((batch) {
      for (final farm in farmList) {
        batch.insert(farms, farm, mode: InsertMode.insertOrReplace);
      }
    });
  }

  /// Deletes a farm by its unique identifier.
  Future<int> deleteFarmById(String id) {
    return (delete(farms)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all farms from the local database.
  Future<int> deleteAllFarms() => delete(farms).go();

  /// Retrieves farms that have not been synced since [since].
  Future<List<Farm>> getUnsyncedFarms(DateTime since) {
    return (select(farms)
          ..where((t) =>
              t.lastSyncedAt.isNull() | t.lastSyncedAt.isSmallerThanValue(since)))
        .get();
  }

  /// Marks a farm as synced at the current time.
  Future<void> markSynced(String id) {
    return (update(farms)..where((t) => t.id.equals(id))).write(
      FarmsCompanion(lastSyncedAt: Value(DateTime.now())),
    );
  }
}
