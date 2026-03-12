import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import '../models/ndvi_data_model.dart';
import '../models/satellite_tile_model.dart';

/// Local data source for satellite data caching using Drift (SQLite).
abstract class SatelliteLocalDataSource {
  Future<List<SatelliteTileModel>> getCachedTiles(String fieldId);
  Future<void> cacheTiles(List<SatelliteTileModel> tiles);
  Future<List<NdviDataModel>> getCachedNdviHistory(String fieldId);
  Future<void> cacheNdviHistory(String fieldId, List<NdviDataModel> data);
  Future<void> cacheCropHealth(String fieldId, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getCachedCropHealth(String fieldId);
  Future<void> clearAll();
}

// --------------------------------------------------------------------------
// Drift table definitions
// --------------------------------------------------------------------------

class CachedSatelliteTiles extends Table {
  TextColumn get id => text()();
  TextColumn get fieldId => text()();
  TextColumn get dataJson => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class CachedNdviHistory extends Table {
  TextColumn get fieldId => text()();
  TextColumn get dataJson => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {fieldId};
}

class CachedCropHealth extends Table {
  TextColumn get fieldId => text()();
  TextColumn get dataJson => text()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {fieldId};
}

// --------------------------------------------------------------------------
// Drift database definition
// --------------------------------------------------------------------------

@DriftDatabase(tables: [CachedSatelliteTiles, CachedNdviHistory, CachedCropHealth])
class SatelliteDatabase extends GeneratedDatabase {
  SatelliteDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
      );

  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, dynamic>>();

  @override
  Iterable<DatabaseSchemaEntity> get allSchemaEntities {
    return [cachedSatelliteTiles, cachedNdviHistory, cachedCropHealth];
  }

  late final $CachedSatelliteTilesTable cachedSatelliteTiles =
      $CachedSatelliteTilesTable(this);
  late final $CachedNdviHistoryTable cachedNdviHistory =
      $CachedNdviHistoryTable(this);
  late final $CachedCropHealthTable cachedCropHealth =
      $CachedCropHealthTable(this);
}

// --------------------------------------------------------------------------
// Generated table classes
// --------------------------------------------------------------------------

class $CachedSatelliteTilesTable extends CachedSatelliteTiles
    with TableInfo<$CachedSatelliteTilesTable, CachedSatelliteTileEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;

  $CachedSatelliteTilesTable(this.attachedDatabase, [this._alias]);

  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => 'cached_satellite_tiles';

  @override
  Set<GeneratedColumn> get $primaryKey => {id};

  late final GeneratedColumn<String> id =
      GeneratedColumn<String>('id', aliasedName, false,
          type: DriftSqlType.string);
  late final GeneratedColumn<String> fieldId =
      GeneratedColumn<String>('field_id', aliasedName, false,
          type: DriftSqlType.string);
  late final GeneratedColumn<String> dataJson =
      GeneratedColumn<String>('data_json', aliasedName, false,
          type: DriftSqlType.string);
  late final GeneratedColumn<DateTime> cachedAt =
      GeneratedColumn<DateTime>('cached_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          defaultValue: currentDateAndTime);

  @override
  List<GeneratedColumn> get $columns => [id, fieldId, dataJson, cachedAt];

  @override
  $CachedSatelliteTilesTable createAlias(String alias) =>
      $CachedSatelliteTilesTable(attachedDatabase, alias);

  @override
  CachedSatelliteTileEntry map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final prefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedSatelliteTileEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${prefix}id'])!,
      fieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${prefix}field_id'])!,
      dataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${prefix}data_json'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${prefix}cached_at'])!,
    );
  }
}

class CachedSatelliteTileEntry extends DataClass {
  final String id;
  final String fieldId;
  final String dataJson;
  final DateTime cachedAt;

  const CachedSatelliteTileEntry({
    required this.id,
    required this.fieldId,
    required this.dataJson,
    required this.cachedAt,
  });
}

class CachedSatelliteTilesCompanion
    extends UpdateCompanion<CachedSatelliteTileEntry> {
  final Value<String> id;
  final Value<String> fieldId;
  final Value<String> dataJson;
  final Value<DateTime> cachedAt;

  const CachedSatelliteTilesCompanion({
    this.id = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });

  CachedSatelliteTilesCompanion.insert({
    required String id,
    required String fieldId,
    required String dataJson,
    this.cachedAt = const Value.absent(),
  })  : id = Value(id),
        fieldId = Value(fieldId),
        dataJson = Value(dataJson);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) map['id'] = Variable<String>(id.value);
    if (fieldId.present) map['field_id'] = Variable<String>(fieldId.value);
    if (dataJson.present) map['data_json'] = Variable<String>(dataJson.value);
    if (cachedAt.present) map['cached_at'] = Variable<DateTime>(cachedAt.value);
    return map;
  }
}

class $CachedNdviHistoryTable extends CachedNdviHistory
    with TableInfo<$CachedNdviHistoryTable, CachedNdviHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;

  $CachedNdviHistoryTable(this.attachedDatabase, [this._alias]);

  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => 'cached_ndvi_history';

  @override
  Set<GeneratedColumn> get $primaryKey => {fieldId};

  late final GeneratedColumn<String> fieldId =
      GeneratedColumn<String>('field_id', aliasedName, false,
          type: DriftSqlType.string);
  late final GeneratedColumn<String> dataJson =
      GeneratedColumn<String>('data_json', aliasedName, false,
          type: DriftSqlType.string);
  late final GeneratedColumn<DateTime> cachedAt =
      GeneratedColumn<DateTime>('cached_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          defaultValue: currentDateAndTime);

  @override
  List<GeneratedColumn> get $columns => [fieldId, dataJson, cachedAt];

  @override
  $CachedNdviHistoryTable createAlias(String alias) =>
      $CachedNdviHistoryTable(attachedDatabase, alias);

  @override
  CachedNdviHistoryEntry map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final prefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedNdviHistoryEntry(
      fieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${prefix}field_id'])!,
      dataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${prefix}data_json'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${prefix}cached_at'])!,
    );
  }
}

class CachedNdviHistoryEntry extends DataClass {
  final String fieldId;
  final String dataJson;
  final DateTime cachedAt;

  const CachedNdviHistoryEntry({
    required this.fieldId,
    required this.dataJson,
    required this.cachedAt,
  });
}

class CachedNdviHistoryCompanion
    extends UpdateCompanion<CachedNdviHistoryEntry> {
  final Value<String> fieldId;
  final Value<String> dataJson;
  final Value<DateTime> cachedAt;

  const CachedNdviHistoryCompanion({
    this.fieldId = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });

  CachedNdviHistoryCompanion.insert({
    required String fieldId,
    required String dataJson,
    this.cachedAt = const Value.absent(),
  })  : fieldId = Value(fieldId),
        dataJson = Value(dataJson);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fieldId.present) map['field_id'] = Variable<String>(fieldId.value);
    if (dataJson.present) map['data_json'] = Variable<String>(dataJson.value);
    if (cachedAt.present) map['cached_at'] = Variable<DateTime>(cachedAt.value);
    return map;
  }
}

class $CachedCropHealthTable extends CachedCropHealth
    with TableInfo<$CachedCropHealthTable, CachedCropHealthEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;

  $CachedCropHealthTable(this.attachedDatabase, [this._alias]);

  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => 'cached_crop_health';

  @override
  Set<GeneratedColumn> get $primaryKey => {fieldId};

  late final GeneratedColumn<String> fieldId =
      GeneratedColumn<String>('field_id', aliasedName, false,
          type: DriftSqlType.string);
  late final GeneratedColumn<String> dataJson =
      GeneratedColumn<String>('data_json', aliasedName, false,
          type: DriftSqlType.string);
  late final GeneratedColumn<DateTime> cachedAt =
      GeneratedColumn<DateTime>('cached_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          defaultValue: currentDateAndTime);

  @override
  List<GeneratedColumn> get $columns => [fieldId, dataJson, cachedAt];

  @override
  $CachedCropHealthTable createAlias(String alias) =>
      $CachedCropHealthTable(attachedDatabase, alias);

  @override
  CachedCropHealthEntry map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final prefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCropHealthEntry(
      fieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${prefix}field_id'])!,
      dataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${prefix}data_json'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${prefix}cached_at'])!,
    );
  }
}

class CachedCropHealthEntry extends DataClass {
  final String fieldId;
  final String dataJson;
  final DateTime cachedAt;

  const CachedCropHealthEntry({
    required this.fieldId,
    required this.dataJson,
    required this.cachedAt,
  });
}

class CachedCropHealthCompanion extends UpdateCompanion<CachedCropHealthEntry> {
  final Value<String> fieldId;
  final Value<String> dataJson;
  final Value<DateTime> cachedAt;

  const CachedCropHealthCompanion({
    this.fieldId = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });

  CachedCropHealthCompanion.insert({
    required String fieldId,
    required String dataJson,
    this.cachedAt = const Value.absent(),
  })  : fieldId = Value(fieldId),
        dataJson = Value(dataJson);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fieldId.present) map['field_id'] = Variable<String>(fieldId.value);
    if (dataJson.present) map['data_json'] = Variable<String>(dataJson.value);
    if (cachedAt.present) map['cached_at'] = Variable<DateTime>(cachedAt.value);
    return map;
  }
}

// --------------------------------------------------------------------------
// Implementation
// --------------------------------------------------------------------------

class SatelliteLocalDataSourceImpl implements SatelliteLocalDataSource {
  final SatelliteDatabase _db;
  final _log = Logger('SatelliteLocalDataSource');

  SatelliteLocalDataSourceImpl({required SatelliteDatabase database})
      : _db = database;

  @override
  Future<List<SatelliteTileModel>> getCachedTiles(String fieldId) async {
    _log.fine('Loading cached satellite tiles for field $fieldId');
    final query = _db.select(_db.cachedSatelliteTiles)
      ..where((t) => t.fieldId.equals(fieldId));
    final rows = await query.get();
    return rows.map((row) {
      final json = jsonDecode(row.dataJson) as Map<String, dynamic>;
      return SatelliteTileModel.fromJson(json);
    }).toList();
  }

  @override
  Future<void> cacheTiles(List<SatelliteTileModel> tiles) async {
    _log.fine('Caching ${tiles.length} satellite tiles');
    await _db.batch((batch) {
      for (final tile in tiles) {
        batch.insert(
          _db.cachedSatelliteTiles,
          CachedSatelliteTilesCompanion.insert(
            id: tile.id,
            fieldId: tile.fieldId,
            dataJson: jsonEncode(tile.toJson()),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  @override
  Future<List<NdviDataModel>> getCachedNdviHistory(String fieldId) async {
    final query = _db.select(_db.cachedNdviHistory)
      ..where((t) => t.fieldId.equals(fieldId));
    final row = await query.getSingleOrNull();
    if (row == null) return [];
    final list = jsonDecode(row.dataJson) as List<dynamic>;
    return list
        .map((item) => NdviDataModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> cacheNdviHistory(
      String fieldId, List<NdviDataModel> data) async {
    await _db.into(_db.cachedNdviHistory).insertOnConflictUpdate(
          CachedNdviHistoryCompanion.insert(
            fieldId: fieldId,
            dataJson: jsonEncode(data.map((d) => d.toJson()).toList()),
          ),
        );
  }

  @override
  Future<void> cacheCropHealth(
      String fieldId, Map<String, dynamic> data) async {
    await _db.into(_db.cachedCropHealth).insertOnConflictUpdate(
          CachedCropHealthCompanion.insert(
            fieldId: fieldId,
            dataJson: jsonEncode(data),
          ),
        );
  }

  @override
  Future<Map<String, dynamic>?> getCachedCropHealth(String fieldId) async {
    final query = _db.select(_db.cachedCropHealth)
      ..where((t) => t.fieldId.equals(fieldId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return jsonDecode(row.dataJson) as Map<String, dynamic>;
  }

  @override
  Future<void> clearAll() async {
    await _db.delete(_db.cachedSatelliteTiles).go();
    await _db.delete(_db.cachedNdviHistory).go();
    await _db.delete(_db.cachedCropHealth).go();
  }
}
