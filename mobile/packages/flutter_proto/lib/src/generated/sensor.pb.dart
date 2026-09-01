// This is a generated file - do not edit.
//
// Generated from sensor.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pb.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'sensor.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'sensor.pbenum.dart';

class GeoLocation extends $pb.GeneratedMessage {
  factory GeoLocation({
    $core.double? latitude,
    $core.double? longitude,
    $core.double? elevationM,
  }) {
    final result = create();
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (elevationM != null) result.elevationM = elevationM;
    return result;
  }

  GeoLocation._();

  factory GeoLocation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GeoLocation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GeoLocation',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'latitude')
    ..aD(2, _omitFieldNames ? '' : 'longitude')
    ..aD(3, _omitFieldNames ? '' : 'elevationM')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeoLocation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeoLocation copyWith(void Function(GeoLocation) updates) =>
      super.copyWith((message) => updates(message as GeoLocation))
          as GeoLocation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GeoLocation create() => GeoLocation._();
  @$core.override
  GeoLocation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GeoLocation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GeoLocation>(create);
  static GeoLocation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get latitude => $_getN(0);
  @$pb.TagNumber(1)
  set latitude($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLatitude() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitude() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get longitude => $_getN(1);
  @$pb.TagNumber(2)
  set longitude($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLongitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitude() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get elevationM => $_getN(2);
  @$pb.TagNumber(3)
  set elevationM($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasElevationM() => $_has(2);
  @$pb.TagNumber(3)
  void clearElevationM() => $_clearField(3);
}

class Sensor extends $pb.GeneratedMessage {
  factory Sensor({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? farmId,
    SensorType? sensorType,
    $core.String? deviceId,
    $core.String? manufacturer,
    $core.String? model,
    $core.String? firmwareVersion,
    GeoLocation? location,
    $0.Timestamp? installationDate,
    $0.Timestamp? lastReadingAt,
    $core.double? batteryLevelPct,
    $core.double? signalStrengthDbm,
    SensorStatus? status,
    SensorProtocol? protocol,
    $core.int? readingIntervalSeconds,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (sensorType != null) result.sensorType = sensorType;
    if (deviceId != null) result.deviceId = deviceId;
    if (manufacturer != null) result.manufacturer = manufacturer;
    if (model != null) result.model = model;
    if (firmwareVersion != null) result.firmwareVersion = firmwareVersion;
    if (location != null) result.location = location;
    if (installationDate != null) result.installationDate = installationDate;
    if (lastReadingAt != null) result.lastReadingAt = lastReadingAt;
    if (batteryLevelPct != null) result.batteryLevelPct = batteryLevelPct;
    if (signalStrengthDbm != null) result.signalStrengthDbm = signalStrengthDbm;
    if (status != null) result.status = status;
    if (protocol != null) result.protocol = protocol;
    if (readingIntervalSeconds != null)
      result.readingIntervalSeconds = readingIntervalSeconds;
    if (metadata != null) result.metadata.addEntries(metadata);
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (version != null) result.version = version;
    return result;
  }

  Sensor._();

  factory Sensor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Sensor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Sensor',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..aE<SensorType>(5, _omitFieldNames ? '' : 'sensorType',
        enumValues: SensorType.values)
    ..aOS(6, _omitFieldNames ? '' : 'deviceId')
    ..aOS(7, _omitFieldNames ? '' : 'manufacturer')
    ..aOS(8, _omitFieldNames ? '' : 'model')
    ..aOS(9, _omitFieldNames ? '' : 'firmwareVersion')
    ..aOM<GeoLocation>(10, _omitFieldNames ? '' : 'location',
        subBuilder: GeoLocation.create)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'installationDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'lastReadingAt',
        subBuilder: $0.Timestamp.create)
    ..aD(13, _omitFieldNames ? '' : 'batteryLevelPct')
    ..aD(14, _omitFieldNames ? '' : 'signalStrengthDbm')
    ..aE<SensorStatus>(15, _omitFieldNames ? '' : 'status',
        enumValues: SensorStatus.values)
    ..aE<SensorProtocol>(16, _omitFieldNames ? '' : 'protocol',
        enumValues: SensorProtocol.values)
    ..aI(17, _omitFieldNames ? '' : 'readingIntervalSeconds')
    ..m<$core.String, $core.String>(18, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'Sensor.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.sensor.v1'))
    ..aOM<$0.Timestamp>(19, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(20, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aInt64(21, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Sensor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Sensor copyWith(void Function(Sensor) updates) =>
      super.copyWith((message) => updates(message as Sensor)) as Sensor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Sensor create() => Sensor._();
  @$core.override
  Sensor createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Sensor getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Sensor>(create);
  static Sensor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fieldId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get farmId => $_getSZ(3);
  @$pb.TagNumber(4)
  set farmId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFarmId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFarmId() => $_clearField(4);

  @$pb.TagNumber(5)
  SensorType get sensorType => $_getN(4);
  @$pb.TagNumber(5)
  set sensorType(SensorType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSensorType() => $_has(4);
  @$pb.TagNumber(5)
  void clearSensorType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get deviceId => $_getSZ(5);
  @$pb.TagNumber(6)
  set deviceId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDeviceId() => $_has(5);
  @$pb.TagNumber(6)
  void clearDeviceId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get manufacturer => $_getSZ(6);
  @$pb.TagNumber(7)
  set manufacturer($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasManufacturer() => $_has(6);
  @$pb.TagNumber(7)
  void clearManufacturer() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get model => $_getSZ(7);
  @$pb.TagNumber(8)
  set model($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasModel() => $_has(7);
  @$pb.TagNumber(8)
  void clearModel() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get firmwareVersion => $_getSZ(8);
  @$pb.TagNumber(9)
  set firmwareVersion($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFirmwareVersion() => $_has(8);
  @$pb.TagNumber(9)
  void clearFirmwareVersion() => $_clearField(9);

  @$pb.TagNumber(10)
  GeoLocation get location => $_getN(9);
  @$pb.TagNumber(10)
  set location(GeoLocation value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasLocation() => $_has(9);
  @$pb.TagNumber(10)
  void clearLocation() => $_clearField(10);
  @$pb.TagNumber(10)
  GeoLocation ensureLocation() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Timestamp get installationDate => $_getN(10);
  @$pb.TagNumber(11)
  set installationDate($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasInstallationDate() => $_has(10);
  @$pb.TagNumber(11)
  void clearInstallationDate() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureInstallationDate() => $_ensure(10);

  @$pb.TagNumber(12)
  $0.Timestamp get lastReadingAt => $_getN(11);
  @$pb.TagNumber(12)
  set lastReadingAt($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasLastReadingAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearLastReadingAt() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureLastReadingAt() => $_ensure(11);

  @$pb.TagNumber(13)
  $core.double get batteryLevelPct => $_getN(12);
  @$pb.TagNumber(13)
  set batteryLevelPct($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasBatteryLevelPct() => $_has(12);
  @$pb.TagNumber(13)
  void clearBatteryLevelPct() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get signalStrengthDbm => $_getN(13);
  @$pb.TagNumber(14)
  set signalStrengthDbm($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasSignalStrengthDbm() => $_has(13);
  @$pb.TagNumber(14)
  void clearSignalStrengthDbm() => $_clearField(14);

  @$pb.TagNumber(15)
  SensorStatus get status => $_getN(14);
  @$pb.TagNumber(15)
  set status(SensorStatus value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasStatus() => $_has(14);
  @$pb.TagNumber(15)
  void clearStatus() => $_clearField(15);

  @$pb.TagNumber(16)
  SensorProtocol get protocol => $_getN(15);
  @$pb.TagNumber(16)
  set protocol(SensorProtocol value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasProtocol() => $_has(15);
  @$pb.TagNumber(16)
  void clearProtocol() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.int get readingIntervalSeconds => $_getIZ(16);
  @$pb.TagNumber(17)
  set readingIntervalSeconds($core.int value) => $_setSignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasReadingIntervalSeconds() => $_has(16);
  @$pb.TagNumber(17)
  void clearReadingIntervalSeconds() => $_clearField(17);

  @$pb.TagNumber(18)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(17);

  @$pb.TagNumber(19)
  $0.Timestamp get createdAt => $_getN(18);
  @$pb.TagNumber(19)
  set createdAt($0.Timestamp value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasCreatedAt() => $_has(18);
  @$pb.TagNumber(19)
  void clearCreatedAt() => $_clearField(19);
  @$pb.TagNumber(19)
  $0.Timestamp ensureCreatedAt() => $_ensure(18);

  @$pb.TagNumber(20)
  $0.Timestamp get updatedAt => $_getN(19);
  @$pb.TagNumber(20)
  set updatedAt($0.Timestamp value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasUpdatedAt() => $_has(19);
  @$pb.TagNumber(20)
  void clearUpdatedAt() => $_clearField(20);
  @$pb.TagNumber(20)
  $0.Timestamp ensureUpdatedAt() => $_ensure(19);

  @$pb.TagNumber(21)
  $fixnum.Int64 get version => $_getI64(20);
  @$pb.TagNumber(21)
  set version($fixnum.Int64 value) => $_setInt64(20, value);
  @$pb.TagNumber(21)
  $core.bool hasVersion() => $_has(20);
  @$pb.TagNumber(21)
  void clearVersion() => $_clearField(21);
}

class SensorReading extends $pb.GeneratedMessage {
  factory SensorReading({
    $core.String? id,
    $core.String? sensorId,
    $core.String? tenantId,
    $core.double? value,
    $core.String? unit,
    $0.Timestamp? timestamp,
    ReadingQuality? quality,
    $core.double? batteryLevelPct,
    $core.double? signalStrengthDbm,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (sensorId != null) result.sensorId = sensorId;
    if (tenantId != null) result.tenantId = tenantId;
    if (value != null) result.value = value;
    if (unit != null) result.unit = unit;
    if (timestamp != null) result.timestamp = timestamp;
    if (quality != null) result.quality = quality;
    if (batteryLevelPct != null) result.batteryLevelPct = batteryLevelPct;
    if (signalStrengthDbm != null) result.signalStrengthDbm = signalStrengthDbm;
    if (metadata != null) result.metadata.addEntries(metadata);
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  SensorReading._();

  factory SensorReading.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SensorReading.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SensorReading',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'sensorId')
    ..aOS(3, _omitFieldNames ? '' : 'tenantId')
    ..aD(4, _omitFieldNames ? '' : 'value')
    ..aOS(5, _omitFieldNames ? '' : 'unit')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aE<ReadingQuality>(7, _omitFieldNames ? '' : 'quality',
        enumValues: ReadingQuality.values)
    ..aD(8, _omitFieldNames ? '' : 'batteryLevelPct')
    ..aD(9, _omitFieldNames ? '' : 'signalStrengthDbm')
    ..m<$core.String, $core.String>(10, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'SensorReading.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.sensor.v1'))
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SensorReading clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SensorReading copyWith(void Function(SensorReading) updates) =>
      super.copyWith((message) => updates(message as SensorReading))
          as SensorReading;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SensorReading create() => SensorReading._();
  @$core.override
  SensorReading createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SensorReading getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SensorReading>(create);
  static SensorReading? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sensorId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sensorId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSensorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSensorId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tenantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set tenantId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTenantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTenantId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get value => $_getN(3);
  @$pb.TagNumber(4)
  set value($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearValue() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get unit => $_getSZ(4);
  @$pb.TagNumber(5)
  set unit($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUnit() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnit() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get timestamp => $_getN(5);
  @$pb.TagNumber(6)
  set timestamp($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasTimestamp() => $_has(5);
  @$pb.TagNumber(6)
  void clearTimestamp() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureTimestamp() => $_ensure(5);

  @$pb.TagNumber(7)
  ReadingQuality get quality => $_getN(6);
  @$pb.TagNumber(7)
  set quality(ReadingQuality value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasQuality() => $_has(6);
  @$pb.TagNumber(7)
  void clearQuality() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get batteryLevelPct => $_getN(7);
  @$pb.TagNumber(8)
  set batteryLevelPct($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBatteryLevelPct() => $_has(7);
  @$pb.TagNumber(8)
  void clearBatteryLevelPct() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get signalStrengthDbm => $_getN(8);
  @$pb.TagNumber(9)
  set signalStrengthDbm($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSignalStrengthDbm() => $_has(8);
  @$pb.TagNumber(9)
  void clearSignalStrengthDbm() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(9);

  @$pb.TagNumber(11)
  $0.Timestamp get createdAt => $_getN(10);
  @$pb.TagNumber(11)
  set createdAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasCreatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreatedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureCreatedAt() => $_ensure(10);
}

class SensorAlert extends $pb.GeneratedMessage {
  factory SensorAlert({
    $core.String? id,
    $core.String? sensorId,
    $core.String? tenantId,
    $core.String? fieldId,
    SensorType? sensorType,
    $core.double? threshold,
    $core.double? actualValue,
    AlertCondition? condition,
    AlertSeverity? severity,
    $core.String? message,
    $core.bool? acknowledged,
    $core.String? acknowledgedBy,
    $0.Timestamp? acknowledgedAt,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (sensorId != null) result.sensorId = sensorId;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (sensorType != null) result.sensorType = sensorType;
    if (threshold != null) result.threshold = threshold;
    if (actualValue != null) result.actualValue = actualValue;
    if (condition != null) result.condition = condition;
    if (severity != null) result.severity = severity;
    if (message != null) result.message = message;
    if (acknowledged != null) result.acknowledged = acknowledged;
    if (acknowledgedBy != null) result.acknowledgedBy = acknowledgedBy;
    if (acknowledgedAt != null) result.acknowledgedAt = acknowledgedAt;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  SensorAlert._();

  factory SensorAlert.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SensorAlert.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SensorAlert',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'sensorId')
    ..aOS(3, _omitFieldNames ? '' : 'tenantId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aE<SensorType>(5, _omitFieldNames ? '' : 'sensorType',
        enumValues: SensorType.values)
    ..aD(6, _omitFieldNames ? '' : 'threshold')
    ..aD(7, _omitFieldNames ? '' : 'actualValue')
    ..aE<AlertCondition>(8, _omitFieldNames ? '' : 'condition',
        enumValues: AlertCondition.values)
    ..aE<AlertSeverity>(9, _omitFieldNames ? '' : 'severity',
        enumValues: AlertSeverity.values)
    ..aOS(10, _omitFieldNames ? '' : 'message')
    ..aOB(11, _omitFieldNames ? '' : 'acknowledged')
    ..aOS(12, _omitFieldNames ? '' : 'acknowledgedBy')
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'acknowledgedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SensorAlert clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SensorAlert copyWith(void Function(SensorAlert) updates) =>
      super.copyWith((message) => updates(message as SensorAlert))
          as SensorAlert;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SensorAlert create() => SensorAlert._();
  @$core.override
  SensorAlert createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SensorAlert getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SensorAlert>(create);
  static SensorAlert? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sensorId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sensorId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSensorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSensorId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tenantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set tenantId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTenantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTenantId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fieldId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fieldId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldId() => $_clearField(4);

  @$pb.TagNumber(5)
  SensorType get sensorType => $_getN(4);
  @$pb.TagNumber(5)
  set sensorType(SensorType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSensorType() => $_has(4);
  @$pb.TagNumber(5)
  void clearSensorType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get threshold => $_getN(5);
  @$pb.TagNumber(6)
  set threshold($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasThreshold() => $_has(5);
  @$pb.TagNumber(6)
  void clearThreshold() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get actualValue => $_getN(6);
  @$pb.TagNumber(7)
  set actualValue($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasActualValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearActualValue() => $_clearField(7);

  @$pb.TagNumber(8)
  AlertCondition get condition => $_getN(7);
  @$pb.TagNumber(8)
  set condition(AlertCondition value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCondition() => $_has(7);
  @$pb.TagNumber(8)
  void clearCondition() => $_clearField(8);

  @$pb.TagNumber(9)
  AlertSeverity get severity => $_getN(8);
  @$pb.TagNumber(9)
  set severity(AlertSeverity value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasSeverity() => $_has(8);
  @$pb.TagNumber(9)
  void clearSeverity() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get message => $_getSZ(9);
  @$pb.TagNumber(10)
  set message($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMessage() => $_has(9);
  @$pb.TagNumber(10)
  void clearMessage() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get acknowledged => $_getBF(10);
  @$pb.TagNumber(11)
  set acknowledged($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAcknowledged() => $_has(10);
  @$pb.TagNumber(11)
  void clearAcknowledged() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get acknowledgedBy => $_getSZ(11);
  @$pb.TagNumber(12)
  set acknowledgedBy($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasAcknowledgedBy() => $_has(11);
  @$pb.TagNumber(12)
  void clearAcknowledgedBy() => $_clearField(12);

  @$pb.TagNumber(13)
  $0.Timestamp get acknowledgedAt => $_getN(12);
  @$pb.TagNumber(13)
  set acknowledgedAt($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasAcknowledgedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearAcknowledgedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureAcknowledgedAt() => $_ensure(12);

  @$pb.TagNumber(14)
  $0.Timestamp get createdAt => $_getN(13);
  @$pb.TagNumber(14)
  set createdAt($0.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasCreatedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearCreatedAt() => $_clearField(14);
  @$pb.TagNumber(14)
  $0.Timestamp ensureCreatedAt() => $_ensure(13);

  @$pb.TagNumber(15)
  $0.Timestamp get updatedAt => $_getN(14);
  @$pb.TagNumber(15)
  set updatedAt($0.Timestamp value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasUpdatedAt() => $_has(14);
  @$pb.TagNumber(15)
  void clearUpdatedAt() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Timestamp ensureUpdatedAt() => $_ensure(14);
}

class SensorNetwork extends $pb.GeneratedMessage {
  factory SensorNetwork({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? name,
    $core.String? description,
    SensorProtocol? protocol,
    $core.String? gatewayId,
    $core.Iterable<$core.String>? sensorIds,
    $core.int? totalSensors,
    $core.int? activeSensors,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (protocol != null) result.protocol = protocol;
    if (gatewayId != null) result.gatewayId = gatewayId;
    if (sensorIds != null) result.sensorIds.addAll(sensorIds);
    if (totalSensors != null) result.totalSensors = totalSensors;
    if (activeSensors != null) result.activeSensors = activeSensors;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  SensorNetwork._();

  factory SensorNetwork.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SensorNetwork.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SensorNetwork',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aE<SensorProtocol>(6, _omitFieldNames ? '' : 'protocol',
        enumValues: SensorProtocol.values)
    ..aOS(7, _omitFieldNames ? '' : 'gatewayId')
    ..pPS(8, _omitFieldNames ? '' : 'sensorIds')
    ..aI(9, _omitFieldNames ? '' : 'totalSensors')
    ..aI(10, _omitFieldNames ? '' : 'activeSensors')
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SensorNetwork clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SensorNetwork copyWith(void Function(SensorNetwork) updates) =>
      super.copyWith((message) => updates(message as SensorNetwork))
          as SensorNetwork;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SensorNetwork create() => SensorNetwork._();
  @$core.override
  SensorNetwork createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SensorNetwork getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SensorNetwork>(create);
  static SensorNetwork? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get name => $_getSZ(3);
  @$pb.TagNumber(4)
  set name($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasName() => $_has(3);
  @$pb.TagNumber(4)
  void clearName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);

  @$pb.TagNumber(6)
  SensorProtocol get protocol => $_getN(5);
  @$pb.TagNumber(6)
  set protocol(SensorProtocol value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasProtocol() => $_has(5);
  @$pb.TagNumber(6)
  void clearProtocol() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get gatewayId => $_getSZ(6);
  @$pb.TagNumber(7)
  set gatewayId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasGatewayId() => $_has(6);
  @$pb.TagNumber(7)
  void clearGatewayId() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get sensorIds => $_getList(7);

  @$pb.TagNumber(9)
  $core.int get totalSensors => $_getIZ(8);
  @$pb.TagNumber(9)
  set totalSensors($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTotalSensors() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotalSensors() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get activeSensors => $_getIZ(9);
  @$pb.TagNumber(10)
  set activeSensors($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasActiveSensors() => $_has(9);
  @$pb.TagNumber(10)
  void clearActiveSensors() => $_clearField(10);

  @$pb.TagNumber(11)
  $0.Timestamp get createdAt => $_getN(10);
  @$pb.TagNumber(11)
  set createdAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasCreatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearCreatedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureCreatedAt() => $_ensure(10);

  @$pb.TagNumber(12)
  $0.Timestamp get updatedAt => $_getN(11);
  @$pb.TagNumber(12)
  set updatedAt($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasUpdatedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearUpdatedAt() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureUpdatedAt() => $_ensure(11);
}

class SensorCalibration extends $pb.GeneratedMessage {
  factory SensorCalibration({
    $core.String? id,
    $core.String? sensorId,
    $core.String? tenantId,
    $core.double? offset,
    $core.double? scaleFactor,
    $0.Timestamp? calibrationDate,
    $0.Timestamp? nextCalibrationDate,
    $core.String? calibratedBy,
    $core.String? notes,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (sensorId != null) result.sensorId = sensorId;
    if (tenantId != null) result.tenantId = tenantId;
    if (offset != null) result.offset = offset;
    if (scaleFactor != null) result.scaleFactor = scaleFactor;
    if (calibrationDate != null) result.calibrationDate = calibrationDate;
    if (nextCalibrationDate != null)
      result.nextCalibrationDate = nextCalibrationDate;
    if (calibratedBy != null) result.calibratedBy = calibratedBy;
    if (notes != null) result.notes = notes;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  SensorCalibration._();

  factory SensorCalibration.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SensorCalibration.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SensorCalibration',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'sensorId')
    ..aOS(3, _omitFieldNames ? '' : 'tenantId')
    ..aD(4, _omitFieldNames ? '' : 'offset')
    ..aD(5, _omitFieldNames ? '' : 'scaleFactor')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'calibrationDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'nextCalibrationDate',
        subBuilder: $0.Timestamp.create)
    ..aOS(8, _omitFieldNames ? '' : 'calibratedBy')
    ..aOS(9, _omitFieldNames ? '' : 'notes')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SensorCalibration clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SensorCalibration copyWith(void Function(SensorCalibration) updates) =>
      super.copyWith((message) => updates(message as SensorCalibration))
          as SensorCalibration;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SensorCalibration create() => SensorCalibration._();
  @$core.override
  SensorCalibration createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SensorCalibration getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SensorCalibration>(create);
  static SensorCalibration? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sensorId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sensorId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSensorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSensorId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tenantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set tenantId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTenantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTenantId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get offset => $_getN(3);
  @$pb.TagNumber(4)
  set offset($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOffset() => $_has(3);
  @$pb.TagNumber(4)
  void clearOffset() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get scaleFactor => $_getN(4);
  @$pb.TagNumber(5)
  set scaleFactor($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasScaleFactor() => $_has(4);
  @$pb.TagNumber(5)
  void clearScaleFactor() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get calibrationDate => $_getN(5);
  @$pb.TagNumber(6)
  set calibrationDate($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCalibrationDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearCalibrationDate() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureCalibrationDate() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Timestamp get nextCalibrationDate => $_getN(6);
  @$pb.TagNumber(7)
  set nextCalibrationDate($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasNextCalibrationDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearNextCalibrationDate() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureNextCalibrationDate() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.String get calibratedBy => $_getSZ(7);
  @$pb.TagNumber(8)
  set calibratedBy($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCalibratedBy() => $_has(7);
  @$pb.TagNumber(8)
  void clearCalibratedBy() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get notes => $_getSZ(8);
  @$pb.TagNumber(9)
  set notes($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasNotes() => $_has(8);
  @$pb.TagNumber(9)
  void clearNotes() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Timestamp get createdAt => $_getN(9);
  @$pb.TagNumber(10)
  set createdAt($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureCreatedAt() => $_ensure(9);
}

class RegisterSensorRequest extends $pb.GeneratedMessage {
  factory RegisterSensorRequest({
    $core.String? fieldId,
    $core.String? farmId,
    SensorType? sensorType,
    $core.String? deviceId,
    $core.String? manufacturer,
    $core.String? model,
    $core.String? firmwareVersion,
    GeoLocation? location,
    $0.Timestamp? installationDate,
    SensorProtocol? protocol,
    $core.int? readingIntervalSeconds,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (sensorType != null) result.sensorType = sensorType;
    if (deviceId != null) result.deviceId = deviceId;
    if (manufacturer != null) result.manufacturer = manufacturer;
    if (model != null) result.model = model;
    if (firmwareVersion != null) result.firmwareVersion = firmwareVersion;
    if (location != null) result.location = location;
    if (installationDate != null) result.installationDate = installationDate;
    if (protocol != null) result.protocol = protocol;
    if (readingIntervalSeconds != null)
      result.readingIntervalSeconds = readingIntervalSeconds;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  RegisterSensorRequest._();

  factory RegisterSensorRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterSensorRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterSensorRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aE<SensorType>(3, _omitFieldNames ? '' : 'sensorType',
        enumValues: SensorType.values)
    ..aOS(4, _omitFieldNames ? '' : 'deviceId')
    ..aOS(5, _omitFieldNames ? '' : 'manufacturer')
    ..aOS(6, _omitFieldNames ? '' : 'model')
    ..aOS(7, _omitFieldNames ? '' : 'firmwareVersion')
    ..aOM<GeoLocation>(8, _omitFieldNames ? '' : 'location',
        subBuilder: GeoLocation.create)
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'installationDate',
        subBuilder: $0.Timestamp.create)
    ..aE<SensorProtocol>(10, _omitFieldNames ? '' : 'protocol',
        enumValues: SensorProtocol.values)
    ..aI(11, _omitFieldNames ? '' : 'readingIntervalSeconds')
    ..m<$core.String, $core.String>(12, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'RegisterSensorRequest.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.sensor.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterSensorRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterSensorRequest copyWith(
          void Function(RegisterSensorRequest) updates) =>
      super.copyWith((message) => updates(message as RegisterSensorRequest))
          as RegisterSensorRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterSensorRequest create() => RegisterSensorRequest._();
  @$core.override
  RegisterSensorRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterSensorRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterSensorRequest>(create);
  static RegisterSensorRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFarmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFarmId() => $_clearField(2);

  @$pb.TagNumber(3)
  SensorType get sensorType => $_getN(2);
  @$pb.TagNumber(3)
  set sensorType(SensorType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSensorType() => $_has(2);
  @$pb.TagNumber(3)
  void clearSensorType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get deviceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set deviceId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDeviceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearDeviceId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get manufacturer => $_getSZ(4);
  @$pb.TagNumber(5)
  set manufacturer($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasManufacturer() => $_has(4);
  @$pb.TagNumber(5)
  void clearManufacturer() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get model => $_getSZ(5);
  @$pb.TagNumber(6)
  set model($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasModel() => $_has(5);
  @$pb.TagNumber(6)
  void clearModel() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get firmwareVersion => $_getSZ(6);
  @$pb.TagNumber(7)
  set firmwareVersion($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFirmwareVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearFirmwareVersion() => $_clearField(7);

  @$pb.TagNumber(8)
  GeoLocation get location => $_getN(7);
  @$pb.TagNumber(8)
  set location(GeoLocation value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasLocation() => $_has(7);
  @$pb.TagNumber(8)
  void clearLocation() => $_clearField(8);
  @$pb.TagNumber(8)
  GeoLocation ensureLocation() => $_ensure(7);

  @$pb.TagNumber(9)
  $0.Timestamp get installationDate => $_getN(8);
  @$pb.TagNumber(9)
  set installationDate($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasInstallationDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearInstallationDate() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureInstallationDate() => $_ensure(8);

  @$pb.TagNumber(10)
  SensorProtocol get protocol => $_getN(9);
  @$pb.TagNumber(10)
  set protocol(SensorProtocol value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasProtocol() => $_has(9);
  @$pb.TagNumber(10)
  void clearProtocol() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get readingIntervalSeconds => $_getIZ(10);
  @$pb.TagNumber(11)
  set readingIntervalSeconds($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasReadingIntervalSeconds() => $_has(10);
  @$pb.TagNumber(11)
  void clearReadingIntervalSeconds() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(11);
}

class RegisterSensorResponse extends $pb.GeneratedMessage {
  factory RegisterSensorResponse({
    Sensor? sensor,
  }) {
    final result = create();
    if (sensor != null) result.sensor = sensor;
    return result;
  }

  RegisterSensorResponse._();

  factory RegisterSensorResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterSensorResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterSensorResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOM<Sensor>(1, _omitFieldNames ? '' : 'sensor', subBuilder: Sensor.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterSensorResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterSensorResponse copyWith(
          void Function(RegisterSensorResponse) updates) =>
      super.copyWith((message) => updates(message as RegisterSensorResponse))
          as RegisterSensorResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterSensorResponse create() => RegisterSensorResponse._();
  @$core.override
  RegisterSensorResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterSensorResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterSensorResponse>(create);
  static RegisterSensorResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Sensor get sensor => $_getN(0);
  @$pb.TagNumber(1)
  set sensor(Sensor value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSensor() => $_has(0);
  @$pb.TagNumber(1)
  void clearSensor() => $_clearField(1);
  @$pb.TagNumber(1)
  Sensor ensureSensor() => $_ensure(0);
}

class GetSensorRequest extends $pb.GeneratedMessage {
  factory GetSensorRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetSensorRequest._();

  factory GetSensorRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSensorRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSensorRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSensorRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSensorRequest copyWith(void Function(GetSensorRequest) updates) =>
      super.copyWith((message) => updates(message as GetSensorRequest))
          as GetSensorRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSensorRequest create() => GetSensorRequest._();
  @$core.override
  GetSensorRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSensorRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSensorRequest>(create);
  static GetSensorRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetSensorResponse extends $pb.GeneratedMessage {
  factory GetSensorResponse({
    Sensor? sensor,
  }) {
    final result = create();
    if (sensor != null) result.sensor = sensor;
    return result;
  }

  GetSensorResponse._();

  factory GetSensorResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSensorResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSensorResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOM<Sensor>(1, _omitFieldNames ? '' : 'sensor', subBuilder: Sensor.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSensorResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSensorResponse copyWith(void Function(GetSensorResponse) updates) =>
      super.copyWith((message) => updates(message as GetSensorResponse))
          as GetSensorResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSensorResponse create() => GetSensorResponse._();
  @$core.override
  GetSensorResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSensorResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSensorResponse>(create);
  static GetSensorResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Sensor get sensor => $_getN(0);
  @$pb.TagNumber(1)
  set sensor(Sensor value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSensor() => $_has(0);
  @$pb.TagNumber(1)
  void clearSensor() => $_clearField(1);
  @$pb.TagNumber(1)
  Sensor ensureSensor() => $_ensure(0);
}

class ListSensorsRequest extends $pb.GeneratedMessage {
  factory ListSensorsRequest({
    $core.String? fieldId,
    $core.String? farmId,
    SensorType? sensorType,
    SensorStatus? status,
    SensorProtocol? protocol,
    $core.int? pageSize,
    $core.int? pageOffset,
    $core.Iterable<$core.String>? sort,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (sensorType != null) result.sensorType = sensorType;
    if (status != null) result.status = status;
    if (protocol != null) result.protocol = protocol;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    if (sort != null) result.sort.addAll(sort);
    return result;
  }

  ListSensorsRequest._();

  factory ListSensorsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSensorsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSensorsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aE<SensorType>(3, _omitFieldNames ? '' : 'sensorType',
        enumValues: SensorType.values)
    ..aE<SensorStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: SensorStatus.values)
    ..aE<SensorProtocol>(5, _omitFieldNames ? '' : 'protocol',
        enumValues: SensorProtocol.values)
    ..aI(6, _omitFieldNames ? '' : 'pageSize')
    ..aI(7, _omitFieldNames ? '' : 'pageOffset')
    ..pPS(8, _omitFieldNames ? '' : 'sort')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSensorsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSensorsRequest copyWith(void Function(ListSensorsRequest) updates) =>
      super.copyWith((message) => updates(message as ListSensorsRequest))
          as ListSensorsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSensorsRequest create() => ListSensorsRequest._();
  @$core.override
  ListSensorsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSensorsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSensorsRequest>(create);
  static ListSensorsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFarmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFarmId() => $_clearField(2);

  @$pb.TagNumber(3)
  SensorType get sensorType => $_getN(2);
  @$pb.TagNumber(3)
  set sensorType(SensorType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSensorType() => $_has(2);
  @$pb.TagNumber(3)
  void clearSensorType() => $_clearField(3);

  @$pb.TagNumber(4)
  SensorStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(SensorStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  SensorProtocol get protocol => $_getN(4);
  @$pb.TagNumber(5)
  set protocol(SensorProtocol value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasProtocol() => $_has(4);
  @$pb.TagNumber(5)
  void clearProtocol() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get pageSize => $_getIZ(5);
  @$pb.TagNumber(6)
  set pageSize($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageSize() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get pageOffset => $_getIZ(6);
  @$pb.TagNumber(7)
  set pageOffset($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPageOffset() => $_has(6);
  @$pb.TagNumber(7)
  void clearPageOffset() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get sort => $_getList(7);
}

class ListSensorsResponse extends $pb.GeneratedMessage {
  factory ListSensorsResponse({
    $core.Iterable<Sensor>? sensors,
    $core.int? totalCount,
  }) {
    final result = create();
    if (sensors != null) result.sensors.addAll(sensors);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListSensorsResponse._();

  factory ListSensorsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSensorsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSensorsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..pPM<Sensor>(1, _omitFieldNames ? '' : 'sensors',
        subBuilder: Sensor.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSensorsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSensorsResponse copyWith(void Function(ListSensorsResponse) updates) =>
      super.copyWith((message) => updates(message as ListSensorsResponse))
          as ListSensorsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSensorsResponse create() => ListSensorsResponse._();
  @$core.override
  ListSensorsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSensorsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSensorsResponse>(create);
  static ListSensorsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Sensor> get sensors => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class UpdateSensorRequest extends $pb.GeneratedMessage {
  factory UpdateSensorRequest({
    $core.String? id,
    $1.FieldMask? updateMask,
    $core.String? firmwareVersion,
    GeoLocation? location,
    SensorStatus? status,
    SensorProtocol? protocol,
    $core.int? readingIntervalSeconds,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (updateMask != null) result.updateMask = updateMask;
    if (firmwareVersion != null) result.firmwareVersion = firmwareVersion;
    if (location != null) result.location = location;
    if (status != null) result.status = status;
    if (protocol != null) result.protocol = protocol;
    if (readingIntervalSeconds != null)
      result.readingIntervalSeconds = readingIntervalSeconds;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  UpdateSensorRequest._();

  factory UpdateSensorRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateSensorRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateSensorRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOM<$1.FieldMask>(2, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $1.FieldMask.create)
    ..aOS(3, _omitFieldNames ? '' : 'firmwareVersion')
    ..aOM<GeoLocation>(4, _omitFieldNames ? '' : 'location',
        subBuilder: GeoLocation.create)
    ..aE<SensorStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: SensorStatus.values)
    ..aE<SensorProtocol>(6, _omitFieldNames ? '' : 'protocol',
        enumValues: SensorProtocol.values)
    ..aI(7, _omitFieldNames ? '' : 'readingIntervalSeconds')
    ..m<$core.String, $core.String>(8, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'UpdateSensorRequest.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.sensor.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSensorRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSensorRequest copyWith(void Function(UpdateSensorRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateSensorRequest))
          as UpdateSensorRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateSensorRequest create() => UpdateSensorRequest._();
  @$core.override
  UpdateSensorRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateSensorRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateSensorRequest>(create);
  static UpdateSensorRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $1.FieldMask get updateMask => $_getN(1);
  @$pb.TagNumber(2)
  set updateMask($1.FieldMask value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUpdateMask() => $_has(1);
  @$pb.TagNumber(2)
  void clearUpdateMask() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.FieldMask ensureUpdateMask() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get firmwareVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set firmwareVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFirmwareVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearFirmwareVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  GeoLocation get location => $_getN(3);
  @$pb.TagNumber(4)
  set location(GeoLocation value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLocation() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocation() => $_clearField(4);
  @$pb.TagNumber(4)
  GeoLocation ensureLocation() => $_ensure(3);

  @$pb.TagNumber(5)
  SensorStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(SensorStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  SensorProtocol get protocol => $_getN(5);
  @$pb.TagNumber(6)
  set protocol(SensorProtocol value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasProtocol() => $_has(5);
  @$pb.TagNumber(6)
  void clearProtocol() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get readingIntervalSeconds => $_getIZ(6);
  @$pb.TagNumber(7)
  set readingIntervalSeconds($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasReadingIntervalSeconds() => $_has(6);
  @$pb.TagNumber(7)
  void clearReadingIntervalSeconds() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(7);
}

class UpdateSensorResponse extends $pb.GeneratedMessage {
  factory UpdateSensorResponse({
    Sensor? sensor,
  }) {
    final result = create();
    if (sensor != null) result.sensor = sensor;
    return result;
  }

  UpdateSensorResponse._();

  factory UpdateSensorResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateSensorResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateSensorResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOM<Sensor>(1, _omitFieldNames ? '' : 'sensor', subBuilder: Sensor.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSensorResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateSensorResponse copyWith(void Function(UpdateSensorResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateSensorResponse))
          as UpdateSensorResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateSensorResponse create() => UpdateSensorResponse._();
  @$core.override
  UpdateSensorResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateSensorResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateSensorResponse>(create);
  static UpdateSensorResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Sensor get sensor => $_getN(0);
  @$pb.TagNumber(1)
  set sensor(Sensor value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSensor() => $_has(0);
  @$pb.TagNumber(1)
  void clearSensor() => $_clearField(1);
  @$pb.TagNumber(1)
  Sensor ensureSensor() => $_ensure(0);
}

class DecommissionSensorRequest extends $pb.GeneratedMessage {
  factory DecommissionSensorRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (reason != null) result.reason = reason;
    return result;
  }

  DecommissionSensorRequest._();

  factory DecommissionSensorRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DecommissionSensorRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DecommissionSensorRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecommissionSensorRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecommissionSensorRequest copyWith(
          void Function(DecommissionSensorRequest) updates) =>
      super.copyWith((message) => updates(message as DecommissionSensorRequest))
          as DecommissionSensorRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecommissionSensorRequest create() => DecommissionSensorRequest._();
  @$core.override
  DecommissionSensorRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DecommissionSensorRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecommissionSensorRequest>(create);
  static DecommissionSensorRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class DecommissionSensorResponse extends $pb.GeneratedMessage {
  factory DecommissionSensorResponse({
    Sensor? sensor,
  }) {
    final result = create();
    if (sensor != null) result.sensor = sensor;
    return result;
  }

  DecommissionSensorResponse._();

  factory DecommissionSensorResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DecommissionSensorResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DecommissionSensorResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOM<Sensor>(1, _omitFieldNames ? '' : 'sensor', subBuilder: Sensor.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecommissionSensorResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecommissionSensorResponse copyWith(
          void Function(DecommissionSensorResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DecommissionSensorResponse))
          as DecommissionSensorResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecommissionSensorResponse create() => DecommissionSensorResponse._();
  @$core.override
  DecommissionSensorResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DecommissionSensorResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecommissionSensorResponse>(create);
  static DecommissionSensorResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Sensor get sensor => $_getN(0);
  @$pb.TagNumber(1)
  set sensor(Sensor value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSensor() => $_has(0);
  @$pb.TagNumber(1)
  void clearSensor() => $_clearField(1);
  @$pb.TagNumber(1)
  Sensor ensureSensor() => $_ensure(0);
}

class IngestReadingRequest extends $pb.GeneratedMessage {
  factory IngestReadingRequest({
    $core.String? sensorId,
    $core.double? value,
    $core.String? unit,
    $0.Timestamp? timestamp,
    ReadingQuality? quality,
    $core.double? batteryLevelPct,
    $core.double? signalStrengthDbm,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (sensorId != null) result.sensorId = sensorId;
    if (value != null) result.value = value;
    if (unit != null) result.unit = unit;
    if (timestamp != null) result.timestamp = timestamp;
    if (quality != null) result.quality = quality;
    if (batteryLevelPct != null) result.batteryLevelPct = batteryLevelPct;
    if (signalStrengthDbm != null) result.signalStrengthDbm = signalStrengthDbm;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  IngestReadingRequest._();

  factory IngestReadingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IngestReadingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IngestReadingRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sensorId')
    ..aD(2, _omitFieldNames ? '' : 'value')
    ..aOS(3, _omitFieldNames ? '' : 'unit')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aE<ReadingQuality>(5, _omitFieldNames ? '' : 'quality',
        enumValues: ReadingQuality.values)
    ..aD(6, _omitFieldNames ? '' : 'batteryLevelPct')
    ..aD(7, _omitFieldNames ? '' : 'signalStrengthDbm')
    ..m<$core.String, $core.String>(8, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'IngestReadingRequest.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.sensor.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IngestReadingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IngestReadingRequest copyWith(void Function(IngestReadingRequest) updates) =>
      super.copyWith((message) => updates(message as IngestReadingRequest))
          as IngestReadingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IngestReadingRequest create() => IngestReadingRequest._();
  @$core.override
  IngestReadingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IngestReadingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IngestReadingRequest>(create);
  static IngestReadingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sensorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sensorId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSensorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSensorId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get unit => $_getSZ(2);
  @$pb.TagNumber(3)
  set unit($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnit() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnit() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get timestamp => $_getN(3);
  @$pb.TagNumber(4)
  set timestamp($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureTimestamp() => $_ensure(3);

  @$pb.TagNumber(5)
  ReadingQuality get quality => $_getN(4);
  @$pb.TagNumber(5)
  set quality(ReadingQuality value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasQuality() => $_has(4);
  @$pb.TagNumber(5)
  void clearQuality() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get batteryLevelPct => $_getN(5);
  @$pb.TagNumber(6)
  set batteryLevelPct($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBatteryLevelPct() => $_has(5);
  @$pb.TagNumber(6)
  void clearBatteryLevelPct() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get signalStrengthDbm => $_getN(6);
  @$pb.TagNumber(7)
  set signalStrengthDbm($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSignalStrengthDbm() => $_has(6);
  @$pb.TagNumber(7)
  void clearSignalStrengthDbm() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(7);
}

class IngestReadingResponse extends $pb.GeneratedMessage {
  factory IngestReadingResponse({
    SensorReading? reading,
    $core.bool? alertTriggered,
    SensorAlert? alert,
  }) {
    final result = create();
    if (reading != null) result.reading = reading;
    if (alertTriggered != null) result.alertTriggered = alertTriggered;
    if (alert != null) result.alert = alert;
    return result;
  }

  IngestReadingResponse._();

  factory IngestReadingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IngestReadingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IngestReadingResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOM<SensorReading>(1, _omitFieldNames ? '' : 'reading',
        subBuilder: SensorReading.create)
    ..aOB(2, _omitFieldNames ? '' : 'alertTriggered')
    ..aOM<SensorAlert>(3, _omitFieldNames ? '' : 'alert',
        subBuilder: SensorAlert.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IngestReadingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IngestReadingResponse copyWith(
          void Function(IngestReadingResponse) updates) =>
      super.copyWith((message) => updates(message as IngestReadingResponse))
          as IngestReadingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IngestReadingResponse create() => IngestReadingResponse._();
  @$core.override
  IngestReadingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IngestReadingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IngestReadingResponse>(create);
  static IngestReadingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SensorReading get reading => $_getN(0);
  @$pb.TagNumber(1)
  set reading(SensorReading value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReading() => $_has(0);
  @$pb.TagNumber(1)
  void clearReading() => $_clearField(1);
  @$pb.TagNumber(1)
  SensorReading ensureReading() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.bool get alertTriggered => $_getBF(1);
  @$pb.TagNumber(2)
  set alertTriggered($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAlertTriggered() => $_has(1);
  @$pb.TagNumber(2)
  void clearAlertTriggered() => $_clearField(2);

  @$pb.TagNumber(3)
  SensorAlert get alert => $_getN(2);
  @$pb.TagNumber(3)
  set alert(SensorAlert value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasAlert() => $_has(2);
  @$pb.TagNumber(3)
  void clearAlert() => $_clearField(3);
  @$pb.TagNumber(3)
  SensorAlert ensureAlert() => $_ensure(2);
}

class BatchIngestReadingsRequest extends $pb.GeneratedMessage {
  factory BatchIngestReadingsRequest({
    $core.Iterable<IngestReadingRequest>? readings,
  }) {
    final result = create();
    if (readings != null) result.readings.addAll(readings);
    return result;
  }

  BatchIngestReadingsRequest._();

  factory BatchIngestReadingsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BatchIngestReadingsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BatchIngestReadingsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..pPM<IngestReadingRequest>(1, _omitFieldNames ? '' : 'readings',
        subBuilder: IngestReadingRequest.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchIngestReadingsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchIngestReadingsRequest copyWith(
          void Function(BatchIngestReadingsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as BatchIngestReadingsRequest))
          as BatchIngestReadingsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BatchIngestReadingsRequest create() => BatchIngestReadingsRequest._();
  @$core.override
  BatchIngestReadingsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BatchIngestReadingsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BatchIngestReadingsRequest>(create);
  static BatchIngestReadingsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<IngestReadingRequest> get readings => $_getList(0);
}

class BatchIngestReadingsResponse extends $pb.GeneratedMessage {
  factory BatchIngestReadingsResponse({
    $core.int? ingestedCount,
    $core.int? failedCount,
    $core.Iterable<$core.String>? errors,
    $core.Iterable<SensorAlert>? alerts,
  }) {
    final result = create();
    if (ingestedCount != null) result.ingestedCount = ingestedCount;
    if (failedCount != null) result.failedCount = failedCount;
    if (errors != null) result.errors.addAll(errors);
    if (alerts != null) result.alerts.addAll(alerts);
    return result;
  }

  BatchIngestReadingsResponse._();

  factory BatchIngestReadingsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BatchIngestReadingsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BatchIngestReadingsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'ingestedCount')
    ..aI(2, _omitFieldNames ? '' : 'failedCount')
    ..pPS(3, _omitFieldNames ? '' : 'errors')
    ..pPM<SensorAlert>(4, _omitFieldNames ? '' : 'alerts',
        subBuilder: SensorAlert.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchIngestReadingsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchIngestReadingsResponse copyWith(
          void Function(BatchIngestReadingsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as BatchIngestReadingsResponse))
          as BatchIngestReadingsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BatchIngestReadingsResponse create() =>
      BatchIngestReadingsResponse._();
  @$core.override
  BatchIngestReadingsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BatchIngestReadingsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BatchIngestReadingsResponse>(create);
  static BatchIngestReadingsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get ingestedCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set ingestedCount($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIngestedCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearIngestedCount() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get failedCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set failedCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFailedCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearFailedCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.String> get errors => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<SensorAlert> get alerts => $_getList(3);
}

class GetLatestReadingRequest extends $pb.GeneratedMessage {
  factory GetLatestReadingRequest({
    $core.String? sensorId,
  }) {
    final result = create();
    if (sensorId != null) result.sensorId = sensorId;
    return result;
  }

  GetLatestReadingRequest._();

  factory GetLatestReadingRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLatestReadingRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLatestReadingRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sensorId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLatestReadingRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLatestReadingRequest copyWith(
          void Function(GetLatestReadingRequest) updates) =>
      super.copyWith((message) => updates(message as GetLatestReadingRequest))
          as GetLatestReadingRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLatestReadingRequest create() => GetLatestReadingRequest._();
  @$core.override
  GetLatestReadingRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLatestReadingRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLatestReadingRequest>(create);
  static GetLatestReadingRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sensorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sensorId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSensorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSensorId() => $_clearField(1);
}

class GetLatestReadingResponse extends $pb.GeneratedMessage {
  factory GetLatestReadingResponse({
    SensorReading? reading,
  }) {
    final result = create();
    if (reading != null) result.reading = reading;
    return result;
  }

  GetLatestReadingResponse._();

  factory GetLatestReadingResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLatestReadingResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLatestReadingResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOM<SensorReading>(1, _omitFieldNames ? '' : 'reading',
        subBuilder: SensorReading.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLatestReadingResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLatestReadingResponse copyWith(
          void Function(GetLatestReadingResponse) updates) =>
      super.copyWith((message) => updates(message as GetLatestReadingResponse))
          as GetLatestReadingResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLatestReadingResponse create() => GetLatestReadingResponse._();
  @$core.override
  GetLatestReadingResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLatestReadingResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLatestReadingResponse>(create);
  static GetLatestReadingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SensorReading get reading => $_getN(0);
  @$pb.TagNumber(1)
  set reading(SensorReading value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReading() => $_has(0);
  @$pb.TagNumber(1)
  void clearReading() => $_clearField(1);
  @$pb.TagNumber(1)
  SensorReading ensureReading() => $_ensure(0);
}

class GetReadingHistoryRequest extends $pb.GeneratedMessage {
  factory GetReadingHistoryRequest({
    $core.String? sensorId,
    $0.Timestamp? startTime,
    $0.Timestamp? endTime,
    $core.int? pageSize,
    $core.int? pageOffset,
    ReadingQuality? minQuality,
  }) {
    final result = create();
    if (sensorId != null) result.sensorId = sensorId;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    if (minQuality != null) result.minQuality = minQuality;
    return result;
  }

  GetReadingHistoryRequest._();

  factory GetReadingHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReadingHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReadingHistoryRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sensorId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'startTime',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'endTime',
        subBuilder: $0.Timestamp.create)
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aI(5, _omitFieldNames ? '' : 'pageOffset')
    ..aE<ReadingQuality>(6, _omitFieldNames ? '' : 'minQuality',
        enumValues: ReadingQuality.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReadingHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReadingHistoryRequest copyWith(
          void Function(GetReadingHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as GetReadingHistoryRequest))
          as GetReadingHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReadingHistoryRequest create() => GetReadingHistoryRequest._();
  @$core.override
  GetReadingHistoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReadingHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReadingHistoryRequest>(create);
  static GetReadingHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sensorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sensorId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSensorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSensorId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get startTime => $_getN(1);
  @$pb.TagNumber(2)
  set startTime($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStartTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartTime() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureStartTime() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.Timestamp get endTime => $_getN(2);
  @$pb.TagNumber(3)
  set endTime($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEndTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndTime() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureEndTime() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.int get pageSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageSize($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pageOffset => $_getIZ(4);
  @$pb.TagNumber(5)
  set pageOffset($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageOffset() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageOffset() => $_clearField(5);

  @$pb.TagNumber(6)
  ReadingQuality get minQuality => $_getN(5);
  @$pb.TagNumber(6)
  set minQuality(ReadingQuality value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasMinQuality() => $_has(5);
  @$pb.TagNumber(6)
  void clearMinQuality() => $_clearField(6);
}

class GetReadingHistoryResponse extends $pb.GeneratedMessage {
  factory GetReadingHistoryResponse({
    $core.Iterable<SensorReading>? readings,
    $core.int? totalCount,
  }) {
    final result = create();
    if (readings != null) result.readings.addAll(readings);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  GetReadingHistoryResponse._();

  factory GetReadingHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReadingHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReadingHistoryResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..pPM<SensorReading>(1, _omitFieldNames ? '' : 'readings',
        subBuilder: SensorReading.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReadingHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReadingHistoryResponse copyWith(
          void Function(GetReadingHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as GetReadingHistoryResponse))
          as GetReadingHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReadingHistoryResponse create() => GetReadingHistoryResponse._();
  @$core.override
  GetReadingHistoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReadingHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReadingHistoryResponse>(create);
  static GetReadingHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SensorReading> get readings => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class CreateAlertRequest extends $pb.GeneratedMessage {
  factory CreateAlertRequest({
    $core.String? sensorId,
    SensorType? sensorType,
    $core.double? threshold,
    AlertCondition? condition,
    AlertSeverity? severity,
    $core.String? message,
  }) {
    final result = create();
    if (sensorId != null) result.sensorId = sensorId;
    if (sensorType != null) result.sensorType = sensorType;
    if (threshold != null) result.threshold = threshold;
    if (condition != null) result.condition = condition;
    if (severity != null) result.severity = severity;
    if (message != null) result.message = message;
    return result;
  }

  CreateAlertRequest._();

  factory CreateAlertRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateAlertRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateAlertRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sensorId')
    ..aE<SensorType>(2, _omitFieldNames ? '' : 'sensorType',
        enumValues: SensorType.values)
    ..aD(3, _omitFieldNames ? '' : 'threshold')
    ..aE<AlertCondition>(4, _omitFieldNames ? '' : 'condition',
        enumValues: AlertCondition.values)
    ..aE<AlertSeverity>(5, _omitFieldNames ? '' : 'severity',
        enumValues: AlertSeverity.values)
    ..aOS(6, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAlertRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAlertRequest copyWith(void Function(CreateAlertRequest) updates) =>
      super.copyWith((message) => updates(message as CreateAlertRequest))
          as CreateAlertRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateAlertRequest create() => CreateAlertRequest._();
  @$core.override
  CreateAlertRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateAlertRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateAlertRequest>(create);
  static CreateAlertRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sensorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sensorId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSensorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSensorId() => $_clearField(1);

  @$pb.TagNumber(2)
  SensorType get sensorType => $_getN(1);
  @$pb.TagNumber(2)
  set sensorType(SensorType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSensorType() => $_has(1);
  @$pb.TagNumber(2)
  void clearSensorType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get threshold => $_getN(2);
  @$pb.TagNumber(3)
  set threshold($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasThreshold() => $_has(2);
  @$pb.TagNumber(3)
  void clearThreshold() => $_clearField(3);

  @$pb.TagNumber(4)
  AlertCondition get condition => $_getN(3);
  @$pb.TagNumber(4)
  set condition(AlertCondition value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCondition() => $_has(3);
  @$pb.TagNumber(4)
  void clearCondition() => $_clearField(4);

  @$pb.TagNumber(5)
  AlertSeverity get severity => $_getN(4);
  @$pb.TagNumber(5)
  set severity(AlertSeverity value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSeverity() => $_has(4);
  @$pb.TagNumber(5)
  void clearSeverity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get message => $_getSZ(5);
  @$pb.TagNumber(6)
  set message($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMessage() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessage() => $_clearField(6);
}

class CreateAlertResponse extends $pb.GeneratedMessage {
  factory CreateAlertResponse({
    SensorAlert? alert,
  }) {
    final result = create();
    if (alert != null) result.alert = alert;
    return result;
  }

  CreateAlertResponse._();

  factory CreateAlertResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateAlertResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateAlertResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOM<SensorAlert>(1, _omitFieldNames ? '' : 'alert',
        subBuilder: SensorAlert.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAlertResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAlertResponse copyWith(void Function(CreateAlertResponse) updates) =>
      super.copyWith((message) => updates(message as CreateAlertResponse))
          as CreateAlertResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateAlertResponse create() => CreateAlertResponse._();
  @$core.override
  CreateAlertResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateAlertResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateAlertResponse>(create);
  static CreateAlertResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SensorAlert get alert => $_getN(0);
  @$pb.TagNumber(1)
  set alert(SensorAlert value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAlert() => $_has(0);
  @$pb.TagNumber(1)
  void clearAlert() => $_clearField(1);
  @$pb.TagNumber(1)
  SensorAlert ensureAlert() => $_ensure(0);
}

class ListAlertsRequest extends $pb.GeneratedMessage {
  factory ListAlertsRequest({
    $core.String? sensorId,
    $core.String? fieldId,
    AlertSeverity? severity,
    $core.bool? unacknowledgedOnly,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (sensorId != null) result.sensorId = sensorId;
    if (fieldId != null) result.fieldId = fieldId;
    if (severity != null) result.severity = severity;
    if (unacknowledgedOnly != null)
      result.unacknowledgedOnly = unacknowledgedOnly;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListAlertsRequest._();

  factory ListAlertsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAlertsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAlertsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sensorId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aE<AlertSeverity>(3, _omitFieldNames ? '' : 'severity',
        enumValues: AlertSeverity.values)
    ..aOB(4, _omitFieldNames ? '' : 'unacknowledgedOnly')
    ..aI(5, _omitFieldNames ? '' : 'pageSize')
    ..aI(6, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAlertsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAlertsRequest copyWith(void Function(ListAlertsRequest) updates) =>
      super.copyWith((message) => updates(message as ListAlertsRequest))
          as ListAlertsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAlertsRequest create() => ListAlertsRequest._();
  @$core.override
  ListAlertsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAlertsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAlertsRequest>(create);
  static ListAlertsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sensorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sensorId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSensorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSensorId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  AlertSeverity get severity => $_getN(2);
  @$pb.TagNumber(3)
  set severity(AlertSeverity value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSeverity() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeverity() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get unacknowledgedOnly => $_getBF(3);
  @$pb.TagNumber(4)
  set unacknowledgedOnly($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUnacknowledgedOnly() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnacknowledgedOnly() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pageSize => $_getIZ(4);
  @$pb.TagNumber(5)
  set pageSize($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageSize() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get pageOffset => $_getIZ(5);
  @$pb.TagNumber(6)
  set pageOffset($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageOffset() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageOffset() => $_clearField(6);
}

class ListAlertsResponse extends $pb.GeneratedMessage {
  factory ListAlertsResponse({
    $core.Iterable<SensorAlert>? alerts,
    $core.int? totalCount,
  }) {
    final result = create();
    if (alerts != null) result.alerts.addAll(alerts);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListAlertsResponse._();

  factory ListAlertsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAlertsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAlertsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..pPM<SensorAlert>(1, _omitFieldNames ? '' : 'alerts',
        subBuilder: SensorAlert.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAlertsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAlertsResponse copyWith(void Function(ListAlertsResponse) updates) =>
      super.copyWith((message) => updates(message as ListAlertsResponse))
          as ListAlertsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAlertsResponse create() => ListAlertsResponse._();
  @$core.override
  ListAlertsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAlertsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAlertsResponse>(create);
  static ListAlertsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SensorAlert> get alerts => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class AcknowledgeAlertRequest extends $pb.GeneratedMessage {
  factory AcknowledgeAlertRequest({
    $core.String? id,
    $core.String? acknowledgedBy,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (acknowledgedBy != null) result.acknowledgedBy = acknowledgedBy;
    return result;
  }

  AcknowledgeAlertRequest._();

  factory AcknowledgeAlertRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AcknowledgeAlertRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AcknowledgeAlertRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'acknowledgedBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcknowledgeAlertRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcknowledgeAlertRequest copyWith(
          void Function(AcknowledgeAlertRequest) updates) =>
      super.copyWith((message) => updates(message as AcknowledgeAlertRequest))
          as AcknowledgeAlertRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AcknowledgeAlertRequest create() => AcknowledgeAlertRequest._();
  @$core.override
  AcknowledgeAlertRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AcknowledgeAlertRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AcknowledgeAlertRequest>(create);
  static AcknowledgeAlertRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get acknowledgedBy => $_getSZ(1);
  @$pb.TagNumber(2)
  set acknowledgedBy($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAcknowledgedBy() => $_has(1);
  @$pb.TagNumber(2)
  void clearAcknowledgedBy() => $_clearField(2);
}

class AcknowledgeAlertResponse extends $pb.GeneratedMessage {
  factory AcknowledgeAlertResponse({
    SensorAlert? alert,
  }) {
    final result = create();
    if (alert != null) result.alert = alert;
    return result;
  }

  AcknowledgeAlertResponse._();

  factory AcknowledgeAlertResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AcknowledgeAlertResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AcknowledgeAlertResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOM<SensorAlert>(1, _omitFieldNames ? '' : 'alert',
        subBuilder: SensorAlert.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcknowledgeAlertResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AcknowledgeAlertResponse copyWith(
          void Function(AcknowledgeAlertResponse) updates) =>
      super.copyWith((message) => updates(message as AcknowledgeAlertResponse))
          as AcknowledgeAlertResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AcknowledgeAlertResponse create() => AcknowledgeAlertResponse._();
  @$core.override
  AcknowledgeAlertResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AcknowledgeAlertResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AcknowledgeAlertResponse>(create);
  static AcknowledgeAlertResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SensorAlert get alert => $_getN(0);
  @$pb.TagNumber(1)
  set alert(SensorAlert value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAlert() => $_has(0);
  @$pb.TagNumber(1)
  void clearAlert() => $_clearField(1);
  @$pb.TagNumber(1)
  SensorAlert ensureAlert() => $_ensure(0);
}

class GetSensorNetworkRequest extends $pb.GeneratedMessage {
  factory GetSensorNetworkRequest({
    $core.String? id,
    $core.String? farmId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (farmId != null) result.farmId = farmId;
    return result;
  }

  GetSensorNetworkRequest._();

  factory GetSensorNetworkRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSensorNetworkRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSensorNetworkRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSensorNetworkRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSensorNetworkRequest copyWith(
          void Function(GetSensorNetworkRequest) updates) =>
      super.copyWith((message) => updates(message as GetSensorNetworkRequest))
          as GetSensorNetworkRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSensorNetworkRequest create() => GetSensorNetworkRequest._();
  @$core.override
  GetSensorNetworkRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSensorNetworkRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSensorNetworkRequest>(create);
  static GetSensorNetworkRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFarmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFarmId() => $_clearField(2);
}

class GetSensorNetworkResponse extends $pb.GeneratedMessage {
  factory GetSensorNetworkResponse({
    SensorNetwork? network,
  }) {
    final result = create();
    if (network != null) result.network = network;
    return result;
  }

  GetSensorNetworkResponse._();

  factory GetSensorNetworkResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSensorNetworkResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSensorNetworkResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOM<SensorNetwork>(1, _omitFieldNames ? '' : 'network',
        subBuilder: SensorNetwork.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSensorNetworkResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSensorNetworkResponse copyWith(
          void Function(GetSensorNetworkResponse) updates) =>
      super.copyWith((message) => updates(message as GetSensorNetworkResponse))
          as GetSensorNetworkResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSensorNetworkResponse create() => GetSensorNetworkResponse._();
  @$core.override
  GetSensorNetworkResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSensorNetworkResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSensorNetworkResponse>(create);
  static GetSensorNetworkResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SensorNetwork get network => $_getN(0);
  @$pb.TagNumber(1)
  set network(SensorNetwork value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNetwork() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetwork() => $_clearField(1);
  @$pb.TagNumber(1)
  SensorNetwork ensureNetwork() => $_ensure(0);
}

class CalibrateSensorRequest extends $pb.GeneratedMessage {
  factory CalibrateSensorRequest({
    $core.String? sensorId,
    $core.double? offset,
    $core.double? scaleFactor,
    $core.String? notes,
    $0.Timestamp? nextCalibrationDate,
  }) {
    final result = create();
    if (sensorId != null) result.sensorId = sensorId;
    if (offset != null) result.offset = offset;
    if (scaleFactor != null) result.scaleFactor = scaleFactor;
    if (notes != null) result.notes = notes;
    if (nextCalibrationDate != null)
      result.nextCalibrationDate = nextCalibrationDate;
    return result;
  }

  CalibrateSensorRequest._();

  factory CalibrateSensorRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalibrateSensorRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalibrateSensorRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sensorId')
    ..aD(2, _omitFieldNames ? '' : 'offset')
    ..aD(3, _omitFieldNames ? '' : 'scaleFactor')
    ..aOS(4, _omitFieldNames ? '' : 'notes')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'nextCalibrationDate',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalibrateSensorRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalibrateSensorRequest copyWith(
          void Function(CalibrateSensorRequest) updates) =>
      super.copyWith((message) => updates(message as CalibrateSensorRequest))
          as CalibrateSensorRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalibrateSensorRequest create() => CalibrateSensorRequest._();
  @$core.override
  CalibrateSensorRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalibrateSensorRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalibrateSensorRequest>(create);
  static CalibrateSensorRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sensorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sensorId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSensorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSensorId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get offset => $_getN(1);
  @$pb.TagNumber(2)
  set offset($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearOffset() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get scaleFactor => $_getN(2);
  @$pb.TagNumber(3)
  set scaleFactor($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScaleFactor() => $_has(2);
  @$pb.TagNumber(3)
  void clearScaleFactor() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get notes => $_getSZ(3);
  @$pb.TagNumber(4)
  set notes($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNotes() => $_has(3);
  @$pb.TagNumber(4)
  void clearNotes() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get nextCalibrationDate => $_getN(4);
  @$pb.TagNumber(5)
  set nextCalibrationDate($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasNextCalibrationDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearNextCalibrationDate() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureNextCalibrationDate() => $_ensure(4);
}

class CalibrateSensorResponse extends $pb.GeneratedMessage {
  factory CalibrateSensorResponse({
    SensorCalibration? calibration,
  }) {
    final result = create();
    if (calibration != null) result.calibration = calibration;
    return result;
  }

  CalibrateSensorResponse._();

  factory CalibrateSensorResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CalibrateSensorResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CalibrateSensorResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sensor.v1'),
      createEmptyInstance: create)
    ..aOM<SensorCalibration>(1, _omitFieldNames ? '' : 'calibration',
        subBuilder: SensorCalibration.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalibrateSensorResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CalibrateSensorResponse copyWith(
          void Function(CalibrateSensorResponse) updates) =>
      super.copyWith((message) => updates(message as CalibrateSensorResponse))
          as CalibrateSensorResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CalibrateSensorResponse create() => CalibrateSensorResponse._();
  @$core.override
  CalibrateSensorResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CalibrateSensorResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CalibrateSensorResponse>(create);
  static CalibrateSensorResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SensorCalibration get calibration => $_getN(0);
  @$pb.TagNumber(1)
  set calibration(SensorCalibration value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCalibration() => $_has(0);
  @$pb.TagNumber(1)
  void clearCalibration() => $_clearField(1);
  @$pb.TagNumber(1)
  SensorCalibration ensureCalibration() => $_ensure(0);
}

class SensorServiceApi {
  final $pb.RpcClient _client;

  SensorServiceApi(this._client);

  /// Sensor lifecycle management
  $async.Future<RegisterSensorResponse> registerSensor(
          $pb.ClientContext? ctx, RegisterSensorRequest request) =>
      _client.invoke<RegisterSensorResponse>(ctx, 'SensorService',
          'RegisterSensor', request, RegisterSensorResponse());
  $async.Future<GetSensorResponse> getSensor(
          $pb.ClientContext? ctx, GetSensorRequest request) =>
      _client.invoke<GetSensorResponse>(
          ctx, 'SensorService', 'GetSensor', request, GetSensorResponse());
  $async.Future<ListSensorsResponse> listSensors(
          $pb.ClientContext? ctx, ListSensorsRequest request) =>
      _client.invoke<ListSensorsResponse>(
          ctx, 'SensorService', 'ListSensors', request, ListSensorsResponse());
  $async.Future<UpdateSensorResponse> updateSensor(
          $pb.ClientContext? ctx, UpdateSensorRequest request) =>
      _client.invoke<UpdateSensorResponse>(ctx, 'SensorService', 'UpdateSensor',
          request, UpdateSensorResponse());
  $async.Future<DecommissionSensorResponse> decommissionSensor(
          $pb.ClientContext? ctx, DecommissionSensorRequest request) =>
      _client.invoke<DecommissionSensorResponse>(ctx, 'SensorService',
          'DecommissionSensor', request, DecommissionSensorResponse());

  /// Data ingestion
  $async.Future<IngestReadingResponse> ingestReading(
          $pb.ClientContext? ctx, IngestReadingRequest request) =>
      _client.invoke<IngestReadingResponse>(ctx, 'SensorService',
          'IngestReading', request, IngestReadingResponse());
  $async.Future<BatchIngestReadingsResponse> batchIngestReadings(
          $pb.ClientContext? ctx, BatchIngestReadingsRequest request) =>
      _client.invoke<BatchIngestReadingsResponse>(ctx, 'SensorService',
          'BatchIngestReadings', request, BatchIngestReadingsResponse());
  $async.Future<GetLatestReadingResponse> getLatestReading(
          $pb.ClientContext? ctx, GetLatestReadingRequest request) =>
      _client.invoke<GetLatestReadingResponse>(ctx, 'SensorService',
          'GetLatestReading', request, GetLatestReadingResponse());
  $async.Future<GetReadingHistoryResponse> getReadingHistory(
          $pb.ClientContext? ctx, GetReadingHistoryRequest request) =>
      _client.invoke<GetReadingHistoryResponse>(ctx, 'SensorService',
          'GetReadingHistory', request, GetReadingHistoryResponse());

  /// Alerting
  $async.Future<CreateAlertResponse> createAlert(
          $pb.ClientContext? ctx, CreateAlertRequest request) =>
      _client.invoke<CreateAlertResponse>(
          ctx, 'SensorService', 'CreateAlert', request, CreateAlertResponse());
  $async.Future<ListAlertsResponse> listAlerts(
          $pb.ClientContext? ctx, ListAlertsRequest request) =>
      _client.invoke<ListAlertsResponse>(
          ctx, 'SensorService', 'ListAlerts', request, ListAlertsResponse());
  $async.Future<AcknowledgeAlertResponse> acknowledgeAlert(
          $pb.ClientContext? ctx, AcknowledgeAlertRequest request) =>
      _client.invoke<AcknowledgeAlertResponse>(ctx, 'SensorService',
          'AcknowledgeAlert', request, AcknowledgeAlertResponse());

  /// Network and calibration
  $async.Future<GetSensorNetworkResponse> getSensorNetwork(
          $pb.ClientContext? ctx, GetSensorNetworkRequest request) =>
      _client.invoke<GetSensorNetworkResponse>(ctx, 'SensorService',
          'GetSensorNetwork', request, GetSensorNetworkResponse());
  $async.Future<CalibrateSensorResponse> calibrateSensor(
          $pb.ClientContext? ctx, CalibrateSensorRequest request) =>
      _client.invoke<CalibrateSensorResponse>(ctx, 'SensorService',
          'CalibrateSensor', request, CalibrateSensorResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
