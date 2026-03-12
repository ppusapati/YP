import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../dao/alert_dao.dart';
import '../dao/farm_dao.dart';
import '../dao/field_dao.dart';
import '../dao/observation_dao.dart';
import '../dao/sensor_dao.dart';
import '../dao/task_dao.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Table definitions
// ---------------------------------------------------------------------------

/// Local cache of farm records.
class Farms extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get ownerId => text()();
  TextColumn get boundariesJson => text().withDefault(const Constant('[]'))();
  RealColumn get totalArea => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local cache of field records.
class Fields extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().references(Farms, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get polygonJson => text().withDefault(const Constant('[]'))();
  RealColumn get area => real().withDefault(const Constant(0.0))();
  TextColumn get cropType => text().withDefault(const Constant(''))();
  TextColumn get soilType => text().withDefault(const Constant(''))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local cache of sensor readings.
class SensorReadings extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get sensorId => text()();
  TextColumn get type => text()();
  RealColumn get value => real()();
  TextColumn get unit => text()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}

/// Local cache of farm tasks.
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().references(Farms, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get taskType => text()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get assignee => text().withDefault(const Constant(''))();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local cache of field observations.
class Observations extends Table {
  TextColumn get id => text()();
  TextColumn get fieldId => text().references(Fields, #id)();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get photosJson => text().withDefault(const Constant('[]'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get category => text().withDefault(const Constant(''))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local cache of alerts.
class Alerts extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get message => text()();
  TextColumn get severity => text()();
  TextColumn get farmId => text().withDefault(const Constant(''))();
  TextColumn get fieldId => text().withDefault(const Constant(''))();
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get read => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Queue of mutations made while offline, pending sync.
class OfflineQueue extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The entity type (e.g., `farm`, `field`, `task`).
  TextColumn get entityType => text()();

  /// The entity's primary key.
  TextColumn get entityId => text()();

  /// The operation type: `create`, `update`, or `delete`.
  TextColumn get operation => text()();

  /// JSON-serialised payload of the mutation.
  TextColumn get payloadJson => text()();

  /// When the mutation was queued.
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// Number of sync attempts so far.
  IntColumn get retryCount =>
      integer().withDefault(const Constant(0))();

  /// Last sync error message, if any.
  TextColumn get lastError => text().nullable()();
}

/// Locally cached satellite/map tiles for offline use.
class CachedTiles extends Table {
  TextColumn get tileKey => text()();
  BlobColumn get tileData => blob()();
  DateTimeColumn get cachedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get expiresAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {tileKey};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

/// The Drift database for the YieldPoint mobile application.
///
/// Defines all local tables and provides access to DAOs for each entity.
///
/// Usage:
/// ```dart
/// final db = AppDatabase();
/// final farms = await db.farmDao.getAllFarms();
/// ```
@DriftDatabase(
  tables: [
    Farms,
    Fields,
    SensorReadings,
    Tasks,
    Observations,
    Alerts,
    OfflineQueue,
    CachedTiles,
  ],
  daos: [
    FarmDao,
    FieldDao,
    SensorDao,
    TaskDao,
    ObservationDao,
    AlertDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Creates the database, optionally with a custom [QueryExecutor].
  AppDatabase({QueryExecutor? executor})
      : super(executor ?? _openConnection());

  /// Creates an in-memory database for testing.
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations go here.
      },
    );
  }

  /// Deletes all data from all tables.
  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'yieldpoint.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
