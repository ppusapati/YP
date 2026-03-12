import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import '../models/diagnosis_model.dart';

/// Local data source for caching diagnosis results using Drift (SQLite).
abstract class DiagnosisLocalDataSource {
  Future<List<DiagnosisModel>> getDiagnosisHistory({String? fieldId});
  Future<DiagnosisModel?> getDiagnosisById(String diagnosisId);
  Future<void> cacheDiagnosis(DiagnosisModel diagnosis);
  Future<void> cacheDiagnoses(List<DiagnosisModel> diagnoses);
  Future<void> clearAll();
}

// --------------------------------------------------------------------------
// Drift table definition
// --------------------------------------------------------------------------

class CachedDiagnoses extends Table {
  TextColumn get id => text()();
  TextColumn get fieldId => text()();
  TextColumn get dataJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

// --------------------------------------------------------------------------
// Drift database
// --------------------------------------------------------------------------

@DriftDatabase(tables: [CachedDiagnoses])
class DiagnosisDatabase extends GeneratedDatabase {
  DiagnosisDatabase(QueryExecutor e) : super(e);

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
    return [cachedDiagnoses];
  }

  late final $CachedDiagnosesTable cachedDiagnoses =
      $CachedDiagnosesTable(this);
}

// --------------------------------------------------------------------------
// Generated table class
// --------------------------------------------------------------------------

class $CachedDiagnosesTable extends CachedDiagnoses
    with TableInfo<$CachedDiagnosesTable, CachedDiagnosisEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;

  $CachedDiagnosesTable(this.attachedDatabase, [this._alias]);

  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => 'cached_diagnoses';

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
  late final GeneratedColumn<DateTime> createdAt =
      GeneratedColumn<DateTime>('created_at', aliasedName, false,
          type: DriftSqlType.dateTime);
  late final GeneratedColumn<DateTime> cachedAt =
      GeneratedColumn<DateTime>('cached_at', aliasedName, false,
          type: DriftSqlType.dateTime,
          defaultValue: currentDateAndTime);

  @override
  List<GeneratedColumn> get $columns =>
      [id, fieldId, dataJson, createdAt, cachedAt];

  @override
  $CachedDiagnosesTable createAlias(String alias) =>
      $CachedDiagnosesTable(attachedDatabase, alias);

  @override
  CachedDiagnosisEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final prefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedDiagnosisEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${prefix}id'])!,
      fieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${prefix}field_id'])!,
      dataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${prefix}data_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${prefix}created_at'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${prefix}cached_at'])!,
    );
  }
}

class CachedDiagnosisEntry extends DataClass {
  final String id;
  final String fieldId;
  final String dataJson;
  final DateTime createdAt;
  final DateTime cachedAt;

  const CachedDiagnosisEntry({
    required this.id,
    required this.fieldId,
    required this.dataJson,
    required this.createdAt,
    required this.cachedAt,
  });
}

class CachedDiagnosesCompanion extends UpdateCompanion<CachedDiagnosisEntry> {
  final Value<String> id;
  final Value<String> fieldId;
  final Value<String> dataJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> cachedAt;

  const CachedDiagnosesCompanion({
    this.id = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });

  CachedDiagnosesCompanion.insert({
    required String id,
    required String fieldId,
    required String dataJson,
    required DateTime createdAt,
    this.cachedAt = const Value.absent(),
  })  : id = Value(id),
        fieldId = Value(fieldId),
        dataJson = Value(dataJson),
        createdAt = Value(createdAt);

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) map['id'] = Variable<String>(id.value);
    if (fieldId.present) map['field_id'] = Variable<String>(fieldId.value);
    if (dataJson.present) map['data_json'] = Variable<String>(dataJson.value);
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (cachedAt.present) map['cached_at'] = Variable<DateTime>(cachedAt.value);
    return map;
  }
}

// --------------------------------------------------------------------------
// Implementation
// --------------------------------------------------------------------------

class DiagnosisLocalDataSourceImpl implements DiagnosisLocalDataSource {
  final DiagnosisDatabase _db;
  final _log = Logger('DiagnosisLocalDataSource');

  DiagnosisLocalDataSourceImpl({required DiagnosisDatabase database})
      : _db = database;

  @override
  Future<List<DiagnosisModel>> getDiagnosisHistory({String? fieldId}) async {
    _log.fine('Loading cached diagnosis history');
    var query = _db.select(_db.cachedDiagnoses);
    if (fieldId != null) {
      query = query..where((t) => t.fieldId.equals(fieldId));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final rows = await query.get();
    return rows.map((row) {
      final json = jsonDecode(row.dataJson) as Map<String, dynamic>;
      return DiagnosisModel.fromJson(json);
    }).toList();
  }

  @override
  Future<DiagnosisModel?> getDiagnosisById(String diagnosisId) async {
    final query = _db.select(_db.cachedDiagnoses)
      ..where((t) => t.id.equals(diagnosisId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final json = jsonDecode(row.dataJson) as Map<String, dynamic>;
    return DiagnosisModel.fromJson(json);
  }

  @override
  Future<void> cacheDiagnosis(DiagnosisModel diagnosis) async {
    await _db.into(_db.cachedDiagnoses).insertOnConflictUpdate(
          CachedDiagnosesCompanion.insert(
            id: diagnosis.id,
            fieldId: diagnosis.fieldId,
            dataJson: jsonEncode(diagnosis.toJson()),
            createdAt: diagnosis.createdAt,
          ),
        );
  }

  @override
  Future<void> cacheDiagnoses(List<DiagnosisModel> diagnoses) async {
    await _db.batch((batch) {
      for (final diagnosis in diagnoses) {
        batch.insert(
          _db.cachedDiagnoses,
          CachedDiagnosesCompanion.insert(
            id: diagnosis.id,
            fieldId: diagnosis.fieldId,
            dataJson: jsonEncode(diagnosis.toJson()),
            createdAt: diagnosis.createdAt,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  @override
  Future<void> clearAll() async {
    await _db.delete(_db.cachedDiagnoses).go();
  }
}
