import 'package:drift/drift.dart';

import '../database/app_database.dart';

part 'field_dao.g.dart';

/// Data access object for field records.
///
/// Provides CRUD operations and query methods for the local fields table.
@DriftAccessor(tables: [Fields])
class FieldDao extends DatabaseAccessor<AppDatabase> with _$FieldDaoMixin {
  FieldDao(super.db);

  /// Retrieves all fields from the local database.
  Future<List<Field>> getAllFields() => select(fields).get();

  /// Watches all fields, emitting a new list whenever data changes.
  Stream<List<Field>> watchAllFields() => select(fields).watch();

  /// Retrieves a field by its unique identifier.
  Future<Field?> getFieldById(String id) {
    return (select(fields)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Watches a single field by ID.
  Stream<Field?> watchFieldById(String id) {
    return (select(fields)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Retrieves all fields belonging to a farm.
  Future<List<Field>> getFieldsByFarm(String farmId) {
    return (select(fields)..where((t) => t.farmId.equals(farmId))).get();
  }

  /// Watches fields belonging to a farm.
  Stream<List<Field>> watchFieldsByFarm(String farmId) {
    return (select(fields)..where((t) => t.farmId.equals(farmId))).watch();
  }

  /// Retrieves fields filtered by crop type.
  Future<List<Field>> getFieldsByCropType(String cropType) {
    return (select(fields)..where((t) => t.cropType.equals(cropType))).get();
  }

  /// Inserts or replaces a field record.
  Future<void> upsertField(FieldsCompanion field) {
    return into(fields).insertOnConflictUpdate(field);
  }

  /// Inserts or replaces multiple field records.
  Future<void> upsertFields(List<FieldsCompanion> fieldList) {
    return batch((batch) {
      for (final field in fieldList) {
        batch.insert(fields, field, mode: InsertMode.insertOrReplace);
      }
    });
  }

  /// Deletes a field by its unique identifier.
  Future<int> deleteFieldById(String id) {
    return (delete(fields)..where((t) => t.id.equals(id))).go();
  }

  /// Deletes all fields for a given farm.
  Future<int> deleteFieldsByFarm(String farmId) {
    return (delete(fields)..where((t) => t.farmId.equals(farmId))).go();
  }

  /// Retrieves fields that have not been synced since [since].
  Future<List<Field>> getUnsyncedFields(DateTime since) {
    return (select(fields)
          ..where((t) =>
              t.lastSyncedAt.isNull() | t.lastSyncedAt.isSmallerThanValue(since)))
        .get();
  }

  /// Marks a field as synced at the current time.
  Future<void> markSynced(String id) {
    return (update(fields)..where((t) => t.id.equals(id))).write(
      FieldsCompanion(lastSyncedAt: Value(DateTime.now())),
    );
  }
}
