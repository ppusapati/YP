// This is a generated file - do not edit.
//
// Generated from irrigation.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'irrigation.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'irrigation.pbenum.dart';

class IrrigationSchedule extends $pb.GeneratedMessage {
  factory IrrigationSchedule({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? farmId,
    $core.String? zoneId,
    ScheduleType? scheduleType,
    $0.Timestamp? startTime,
    $0.Timestamp? endTime,
    $core.int? durationMinutes,
    $core.double? waterQuantityLiters,
    $core.double? flowRateLitersPerHour,
    Frequency? frequency,
    $core.double? soilMoistureThresholdPct,
    $core.bool? weatherAdjusted,
    $core.String? cropGrowthStage,
    $core.String? controllerId,
    IrrigationStatus? status,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $fixnum.Int64? version,
    $core.String? createdBy,
    $core.String? name,
    $core.String? description,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (zoneId != null) result.zoneId = zoneId;
    if (scheduleType != null) result.scheduleType = scheduleType;
    if (startTime != null) result.startTime = startTime;
    if (endTime != null) result.endTime = endTime;
    if (durationMinutes != null) result.durationMinutes = durationMinutes;
    if (waterQuantityLiters != null)
      result.waterQuantityLiters = waterQuantityLiters;
    if (flowRateLitersPerHour != null)
      result.flowRateLitersPerHour = flowRateLitersPerHour;
    if (frequency != null) result.frequency = frequency;
    if (soilMoistureThresholdPct != null)
      result.soilMoistureThresholdPct = soilMoistureThresholdPct;
    if (weatherAdjusted != null) result.weatherAdjusted = weatherAdjusted;
    if (cropGrowthStage != null) result.cropGrowthStage = cropGrowthStage;
    if (controllerId != null) result.controllerId = controllerId;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (version != null) result.version = version;
    if (createdBy != null) result.createdBy = createdBy;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    return result;
  }

  IrrigationSchedule._();

  factory IrrigationSchedule.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IrrigationSchedule.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IrrigationSchedule',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..aOS(5, _omitFieldNames ? '' : 'zoneId')
    ..aE<ScheduleType>(6, _omitFieldNames ? '' : 'scheduleType',
        enumValues: ScheduleType.values)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'startTime',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'endTime',
        subBuilder: $0.Timestamp.create)
    ..aI(9, _omitFieldNames ? '' : 'durationMinutes')
    ..aD(10, _omitFieldNames ? '' : 'waterQuantityLiters')
    ..aD(11, _omitFieldNames ? '' : 'flowRateLitersPerHour')
    ..aE<Frequency>(12, _omitFieldNames ? '' : 'frequency',
        enumValues: Frequency.values)
    ..aD(13, _omitFieldNames ? '' : 'soilMoistureThresholdPct')
    ..aOB(14, _omitFieldNames ? '' : 'weatherAdjusted')
    ..aOS(15, _omitFieldNames ? '' : 'cropGrowthStage')
    ..aOS(16, _omitFieldNames ? '' : 'controllerId')
    ..aE<IrrigationStatus>(17, _omitFieldNames ? '' : 'status',
        enumValues: IrrigationStatus.values)
    ..aOM<$0.Timestamp>(18, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(19, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aInt64(20, _omitFieldNames ? '' : 'version')
    ..aOS(21, _omitFieldNames ? '' : 'createdBy')
    ..aOS(22, _omitFieldNames ? '' : 'name')
    ..aOS(23, _omitFieldNames ? '' : 'description')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IrrigationSchedule clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IrrigationSchedule copyWith(void Function(IrrigationSchedule) updates) =>
      super.copyWith((message) => updates(message as IrrigationSchedule))
          as IrrigationSchedule;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IrrigationSchedule create() => IrrigationSchedule._();
  @$core.override
  IrrigationSchedule createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IrrigationSchedule getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IrrigationSchedule>(create);
  static IrrigationSchedule? _defaultInstance;

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
  $core.String get zoneId => $_getSZ(4);
  @$pb.TagNumber(5)
  set zoneId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasZoneId() => $_has(4);
  @$pb.TagNumber(5)
  void clearZoneId() => $_clearField(5);

  @$pb.TagNumber(6)
  ScheduleType get scheduleType => $_getN(5);
  @$pb.TagNumber(6)
  set scheduleType(ScheduleType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasScheduleType() => $_has(5);
  @$pb.TagNumber(6)
  void clearScheduleType() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get startTime => $_getN(6);
  @$pb.TagNumber(7)
  set startTime($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStartTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearStartTime() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureStartTime() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get endTime => $_getN(7);
  @$pb.TagNumber(8)
  set endTime($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasEndTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearEndTime() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureEndTime() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.int get durationMinutes => $_getIZ(8);
  @$pb.TagNumber(9)
  set durationMinutes($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDurationMinutes() => $_has(8);
  @$pb.TagNumber(9)
  void clearDurationMinutes() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get waterQuantityLiters => $_getN(9);
  @$pb.TagNumber(10)
  set waterQuantityLiters($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasWaterQuantityLiters() => $_has(9);
  @$pb.TagNumber(10)
  void clearWaterQuantityLiters() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get flowRateLitersPerHour => $_getN(10);
  @$pb.TagNumber(11)
  set flowRateLitersPerHour($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasFlowRateLitersPerHour() => $_has(10);
  @$pb.TagNumber(11)
  void clearFlowRateLitersPerHour() => $_clearField(11);

  @$pb.TagNumber(12)
  Frequency get frequency => $_getN(11);
  @$pb.TagNumber(12)
  set frequency(Frequency value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasFrequency() => $_has(11);
  @$pb.TagNumber(12)
  void clearFrequency() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get soilMoistureThresholdPct => $_getN(12);
  @$pb.TagNumber(13)
  set soilMoistureThresholdPct($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasSoilMoistureThresholdPct() => $_has(12);
  @$pb.TagNumber(13)
  void clearSoilMoistureThresholdPct() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get weatherAdjusted => $_getBF(13);
  @$pb.TagNumber(14)
  set weatherAdjusted($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasWeatherAdjusted() => $_has(13);
  @$pb.TagNumber(14)
  void clearWeatherAdjusted() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get cropGrowthStage => $_getSZ(14);
  @$pb.TagNumber(15)
  set cropGrowthStage($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasCropGrowthStage() => $_has(14);
  @$pb.TagNumber(15)
  void clearCropGrowthStage() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get controllerId => $_getSZ(15);
  @$pb.TagNumber(16)
  set controllerId($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasControllerId() => $_has(15);
  @$pb.TagNumber(16)
  void clearControllerId() => $_clearField(16);

  @$pb.TagNumber(17)
  IrrigationStatus get status => $_getN(16);
  @$pb.TagNumber(17)
  set status(IrrigationStatus value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasStatus() => $_has(16);
  @$pb.TagNumber(17)
  void clearStatus() => $_clearField(17);

  @$pb.TagNumber(18)
  $0.Timestamp get createdAt => $_getN(17);
  @$pb.TagNumber(18)
  set createdAt($0.Timestamp value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasCreatedAt() => $_has(17);
  @$pb.TagNumber(18)
  void clearCreatedAt() => $_clearField(18);
  @$pb.TagNumber(18)
  $0.Timestamp ensureCreatedAt() => $_ensure(17);

  @$pb.TagNumber(19)
  $0.Timestamp get updatedAt => $_getN(18);
  @$pb.TagNumber(19)
  set updatedAt($0.Timestamp value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasUpdatedAt() => $_has(18);
  @$pb.TagNumber(19)
  void clearUpdatedAt() => $_clearField(19);
  @$pb.TagNumber(19)
  $0.Timestamp ensureUpdatedAt() => $_ensure(18);

  @$pb.TagNumber(20)
  $fixnum.Int64 get version => $_getI64(19);
  @$pb.TagNumber(20)
  set version($fixnum.Int64 value) => $_setInt64(19, value);
  @$pb.TagNumber(20)
  $core.bool hasVersion() => $_has(19);
  @$pb.TagNumber(20)
  void clearVersion() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.String get createdBy => $_getSZ(20);
  @$pb.TagNumber(21)
  set createdBy($core.String value) => $_setString(20, value);
  @$pb.TagNumber(21)
  $core.bool hasCreatedBy() => $_has(20);
  @$pb.TagNumber(21)
  void clearCreatedBy() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.String get name => $_getSZ(21);
  @$pb.TagNumber(22)
  set name($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasName() => $_has(21);
  @$pb.TagNumber(22)
  void clearName() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.String get description => $_getSZ(22);
  @$pb.TagNumber(23)
  set description($core.String value) => $_setString(22, value);
  @$pb.TagNumber(23)
  $core.bool hasDescription() => $_has(22);
  @$pb.TagNumber(23)
  void clearDescription() => $_clearField(23);
}

class IrrigationZone extends $pb.GeneratedMessage {
  factory IrrigationZone({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? farmId,
    $core.String? name,
    $core.String? description,
    $core.double? areaHectares,
    $core.String? soilType,
    $core.String? cropType,
    $core.String? cropGrowthStage,
    $core.double? latitude,
    $core.double? longitude,
    $core.bool? isActive,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (soilType != null) result.soilType = soilType;
    if (cropType != null) result.cropType = cropType;
    if (cropGrowthStage != null) result.cropGrowthStage = cropGrowthStage;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (isActive != null) result.isActive = isActive;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  IrrigationZone._();

  factory IrrigationZone.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IrrigationZone.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IrrigationZone',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aD(7, _omitFieldNames ? '' : 'areaHectares')
    ..aOS(8, _omitFieldNames ? '' : 'soilType')
    ..aOS(9, _omitFieldNames ? '' : 'cropType')
    ..aOS(10, _omitFieldNames ? '' : 'cropGrowthStage')
    ..aD(11, _omitFieldNames ? '' : 'latitude')
    ..aD(12, _omitFieldNames ? '' : 'longitude')
    ..aOB(13, _omitFieldNames ? '' : 'isActive')
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IrrigationZone clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IrrigationZone copyWith(void Function(IrrigationZone) updates) =>
      super.copyWith((message) => updates(message as IrrigationZone))
          as IrrigationZone;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IrrigationZone create() => IrrigationZone._();
  @$core.override
  IrrigationZone createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IrrigationZone getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IrrigationZone>(create);
  static IrrigationZone? _defaultInstance;

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
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get areaHectares => $_getN(6);
  @$pb.TagNumber(7)
  set areaHectares($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAreaHectares() => $_has(6);
  @$pb.TagNumber(7)
  void clearAreaHectares() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get soilType => $_getSZ(7);
  @$pb.TagNumber(8)
  set soilType($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSoilType() => $_has(7);
  @$pb.TagNumber(8)
  void clearSoilType() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get cropType => $_getSZ(8);
  @$pb.TagNumber(9)
  set cropType($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCropType() => $_has(8);
  @$pb.TagNumber(9)
  void clearCropType() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get cropGrowthStage => $_getSZ(9);
  @$pb.TagNumber(10)
  set cropGrowthStage($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCropGrowthStage() => $_has(9);
  @$pb.TagNumber(10)
  void clearCropGrowthStage() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get latitude => $_getN(10);
  @$pb.TagNumber(11)
  set latitude($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasLatitude() => $_has(10);
  @$pb.TagNumber(11)
  void clearLatitude() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get longitude => $_getN(11);
  @$pb.TagNumber(12)
  set longitude($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasLongitude() => $_has(11);
  @$pb.TagNumber(12)
  void clearLongitude() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get isActive => $_getBF(12);
  @$pb.TagNumber(13)
  set isActive($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasIsActive() => $_has(12);
  @$pb.TagNumber(13)
  void clearIsActive() => $_clearField(13);

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

class WaterController extends $pb.GeneratedMessage {
  factory WaterController({
    $core.String? id,
    $core.String? tenantId,
    $core.String? zoneId,
    $core.String? fieldId,
    $core.String? farmId,
    $core.String? name,
    $core.String? model,
    $core.String? firmwareVersion,
    ControllerType? controllerType,
    Protocol? protocol,
    ControllerStatus? status,
    $core.String? endpoint,
    $core.double? maxFlowRateLitersPerHour,
    $0.Timestamp? lastHeartbeat,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (zoneId != null) result.zoneId = zoneId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (name != null) result.name = name;
    if (model != null) result.model = model;
    if (firmwareVersion != null) result.firmwareVersion = firmwareVersion;
    if (controllerType != null) result.controllerType = controllerType;
    if (protocol != null) result.protocol = protocol;
    if (status != null) result.status = status;
    if (endpoint != null) result.endpoint = endpoint;
    if (maxFlowRateLitersPerHour != null)
      result.maxFlowRateLitersPerHour = maxFlowRateLitersPerHour;
    if (lastHeartbeat != null) result.lastHeartbeat = lastHeartbeat;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  WaterController._();

  factory WaterController.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WaterController.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WaterController',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'zoneId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'farmId')
    ..aOS(6, _omitFieldNames ? '' : 'name')
    ..aOS(7, _omitFieldNames ? '' : 'model')
    ..aOS(8, _omitFieldNames ? '' : 'firmwareVersion')
    ..aE<ControllerType>(9, _omitFieldNames ? '' : 'controllerType',
        enumValues: ControllerType.values)
    ..aE<Protocol>(10, _omitFieldNames ? '' : 'protocol',
        enumValues: Protocol.values)
    ..aE<ControllerStatus>(11, _omitFieldNames ? '' : 'status',
        enumValues: ControllerStatus.values)
    ..aOS(12, _omitFieldNames ? '' : 'endpoint')
    ..aD(13, _omitFieldNames ? '' : 'maxFlowRateLitersPerHour')
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'lastHeartbeat',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(16, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WaterController clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WaterController copyWith(void Function(WaterController) updates) =>
      super.copyWith((message) => updates(message as WaterController))
          as WaterController;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WaterController create() => WaterController._();
  @$core.override
  WaterController createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WaterController getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WaterController>(create);
  static WaterController? _defaultInstance;

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
  $core.String get zoneId => $_getSZ(2);
  @$pb.TagNumber(3)
  set zoneId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasZoneId() => $_has(2);
  @$pb.TagNumber(3)
  void clearZoneId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fieldId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fieldId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get farmId => $_getSZ(4);
  @$pb.TagNumber(5)
  set farmId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFarmId() => $_has(4);
  @$pb.TagNumber(5)
  void clearFarmId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get name => $_getSZ(5);
  @$pb.TagNumber(6)
  set name($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasName() => $_has(5);
  @$pb.TagNumber(6)
  void clearName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get model => $_getSZ(6);
  @$pb.TagNumber(7)
  set model($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasModel() => $_has(6);
  @$pb.TagNumber(7)
  void clearModel() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get firmwareVersion => $_getSZ(7);
  @$pb.TagNumber(8)
  set firmwareVersion($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFirmwareVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearFirmwareVersion() => $_clearField(8);

  @$pb.TagNumber(9)
  ControllerType get controllerType => $_getN(8);
  @$pb.TagNumber(9)
  set controllerType(ControllerType value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasControllerType() => $_has(8);
  @$pb.TagNumber(9)
  void clearControllerType() => $_clearField(9);

  @$pb.TagNumber(10)
  Protocol get protocol => $_getN(9);
  @$pb.TagNumber(10)
  set protocol(Protocol value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasProtocol() => $_has(9);
  @$pb.TagNumber(10)
  void clearProtocol() => $_clearField(10);

  @$pb.TagNumber(11)
  ControllerStatus get status => $_getN(10);
  @$pb.TagNumber(11)
  set status(ControllerStatus value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasStatus() => $_has(10);
  @$pb.TagNumber(11)
  void clearStatus() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get endpoint => $_getSZ(11);
  @$pb.TagNumber(12)
  set endpoint($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasEndpoint() => $_has(11);
  @$pb.TagNumber(12)
  void clearEndpoint() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get maxFlowRateLitersPerHour => $_getN(12);
  @$pb.TagNumber(13)
  set maxFlowRateLitersPerHour($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasMaxFlowRateLitersPerHour() => $_has(12);
  @$pb.TagNumber(13)
  void clearMaxFlowRateLitersPerHour() => $_clearField(13);

  @$pb.TagNumber(14)
  $0.Timestamp get lastHeartbeat => $_getN(13);
  @$pb.TagNumber(14)
  set lastHeartbeat($0.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasLastHeartbeat() => $_has(13);
  @$pb.TagNumber(14)
  void clearLastHeartbeat() => $_clearField(14);
  @$pb.TagNumber(14)
  $0.Timestamp ensureLastHeartbeat() => $_ensure(13);

  @$pb.TagNumber(15)
  $0.Timestamp get createdAt => $_getN(14);
  @$pb.TagNumber(15)
  set createdAt($0.Timestamp value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(14);
  @$pb.TagNumber(15)
  void clearCreatedAt() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Timestamp ensureCreatedAt() => $_ensure(14);

  @$pb.TagNumber(16)
  $0.Timestamp get updatedAt => $_getN(15);
  @$pb.TagNumber(16)
  set updatedAt($0.Timestamp value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasUpdatedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearUpdatedAt() => $_clearField(16);
  @$pb.TagNumber(16)
  $0.Timestamp ensureUpdatedAt() => $_ensure(15);
}

class IrrigationEvent extends $pb.GeneratedMessage {
  factory IrrigationEvent({
    $core.String? id,
    $core.String? tenantId,
    $core.String? scheduleId,
    $core.String? zoneId,
    $core.String? controllerId,
    IrrigationStatus? status,
    $0.Timestamp? startedAt,
    $0.Timestamp? endedAt,
    $core.int? actualDurationMinutes,
    $core.double? actualWaterLiters,
    $core.double? soilMoistureBeforePct,
    $core.double? soilMoistureAfterPct,
    $core.String? failureReason,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (scheduleId != null) result.scheduleId = scheduleId;
    if (zoneId != null) result.zoneId = zoneId;
    if (controllerId != null) result.controllerId = controllerId;
    if (status != null) result.status = status;
    if (startedAt != null) result.startedAt = startedAt;
    if (endedAt != null) result.endedAt = endedAt;
    if (actualDurationMinutes != null)
      result.actualDurationMinutes = actualDurationMinutes;
    if (actualWaterLiters != null) result.actualWaterLiters = actualWaterLiters;
    if (soilMoistureBeforePct != null)
      result.soilMoistureBeforePct = soilMoistureBeforePct;
    if (soilMoistureAfterPct != null)
      result.soilMoistureAfterPct = soilMoistureAfterPct;
    if (failureReason != null) result.failureReason = failureReason;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  IrrigationEvent._();

  factory IrrigationEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IrrigationEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IrrigationEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'scheduleId')
    ..aOS(4, _omitFieldNames ? '' : 'zoneId')
    ..aOS(5, _omitFieldNames ? '' : 'controllerId')
    ..aE<IrrigationStatus>(6, _omitFieldNames ? '' : 'status',
        enumValues: IrrigationStatus.values)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'startedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'endedAt',
        subBuilder: $0.Timestamp.create)
    ..aI(9, _omitFieldNames ? '' : 'actualDurationMinutes')
    ..aD(10, _omitFieldNames ? '' : 'actualWaterLiters')
    ..aD(11, _omitFieldNames ? '' : 'soilMoistureBeforePct')
    ..aD(12, _omitFieldNames ? '' : 'soilMoistureAfterPct')
    ..aOS(13, _omitFieldNames ? '' : 'failureReason')
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IrrigationEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IrrigationEvent copyWith(void Function(IrrigationEvent) updates) =>
      super.copyWith((message) => updates(message as IrrigationEvent))
          as IrrigationEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IrrigationEvent create() => IrrigationEvent._();
  @$core.override
  IrrigationEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IrrigationEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IrrigationEvent>(create);
  static IrrigationEvent? _defaultInstance;

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
  $core.String get scheduleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set scheduleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScheduleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearScheduleId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get zoneId => $_getSZ(3);
  @$pb.TagNumber(4)
  set zoneId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasZoneId() => $_has(3);
  @$pb.TagNumber(4)
  void clearZoneId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get controllerId => $_getSZ(4);
  @$pb.TagNumber(5)
  set controllerId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasControllerId() => $_has(4);
  @$pb.TagNumber(5)
  void clearControllerId() => $_clearField(5);

  @$pb.TagNumber(6)
  IrrigationStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(IrrigationStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get startedAt => $_getN(6);
  @$pb.TagNumber(7)
  set startedAt($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStartedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearStartedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureStartedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get endedAt => $_getN(7);
  @$pb.TagNumber(8)
  set endedAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasEndedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearEndedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureEndedAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.int get actualDurationMinutes => $_getIZ(8);
  @$pb.TagNumber(9)
  set actualDurationMinutes($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasActualDurationMinutes() => $_has(8);
  @$pb.TagNumber(9)
  void clearActualDurationMinutes() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get actualWaterLiters => $_getN(9);
  @$pb.TagNumber(10)
  set actualWaterLiters($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasActualWaterLiters() => $_has(9);
  @$pb.TagNumber(10)
  void clearActualWaterLiters() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get soilMoistureBeforePct => $_getN(10);
  @$pb.TagNumber(11)
  set soilMoistureBeforePct($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSoilMoistureBeforePct() => $_has(10);
  @$pb.TagNumber(11)
  void clearSoilMoistureBeforePct() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get soilMoistureAfterPct => $_getN(11);
  @$pb.TagNumber(12)
  set soilMoistureAfterPct($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasSoilMoistureAfterPct() => $_has(11);
  @$pb.TagNumber(12)
  void clearSoilMoistureAfterPct() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get failureReason => $_getSZ(12);
  @$pb.TagNumber(13)
  set failureReason($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasFailureReason() => $_has(12);
  @$pb.TagNumber(13)
  void clearFailureReason() => $_clearField(13);

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
}

class DecisionInputs extends $pb.GeneratedMessage {
  factory DecisionInputs({
    $core.double? soilMoisture,
    $core.double? temperature,
    $core.double? humidity,
    $core.double? rainfallForecastMm,
    $core.double? windSpeed,
    $core.String? cropType,
    $core.String? growthStage,
    $core.double? evapotranspirationMm,
  }) {
    final result = create();
    if (soilMoisture != null) result.soilMoisture = soilMoisture;
    if (temperature != null) result.temperature = temperature;
    if (humidity != null) result.humidity = humidity;
    if (rainfallForecastMm != null)
      result.rainfallForecastMm = rainfallForecastMm;
    if (windSpeed != null) result.windSpeed = windSpeed;
    if (cropType != null) result.cropType = cropType;
    if (growthStage != null) result.growthStage = growthStage;
    if (evapotranspirationMm != null)
      result.evapotranspirationMm = evapotranspirationMm;
    return result;
  }

  DecisionInputs._();

  factory DecisionInputs.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DecisionInputs.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DecisionInputs',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'soilMoisture')
    ..aD(2, _omitFieldNames ? '' : 'temperature')
    ..aD(3, _omitFieldNames ? '' : 'humidity')
    ..aD(4, _omitFieldNames ? '' : 'rainfallForecastMm')
    ..aD(5, _omitFieldNames ? '' : 'windSpeed')
    ..aOS(6, _omitFieldNames ? '' : 'cropType')
    ..aOS(7, _omitFieldNames ? '' : 'growthStage')
    ..aD(8, _omitFieldNames ? '' : 'evapotranspirationMm')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecisionInputs clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecisionInputs copyWith(void Function(DecisionInputs) updates) =>
      super.copyWith((message) => updates(message as DecisionInputs))
          as DecisionInputs;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecisionInputs create() => DecisionInputs._();
  @$core.override
  DecisionInputs createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DecisionInputs getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecisionInputs>(create);
  static DecisionInputs? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get soilMoisture => $_getN(0);
  @$pb.TagNumber(1)
  set soilMoisture($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSoilMoisture() => $_has(0);
  @$pb.TagNumber(1)
  void clearSoilMoisture() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get temperature => $_getN(1);
  @$pb.TagNumber(2)
  set temperature($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTemperature() => $_has(1);
  @$pb.TagNumber(2)
  void clearTemperature() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get humidity => $_getN(2);
  @$pb.TagNumber(3)
  set humidity($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHumidity() => $_has(2);
  @$pb.TagNumber(3)
  void clearHumidity() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get rainfallForecastMm => $_getN(3);
  @$pb.TagNumber(4)
  set rainfallForecastMm($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRainfallForecastMm() => $_has(3);
  @$pb.TagNumber(4)
  void clearRainfallForecastMm() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get windSpeed => $_getN(4);
  @$pb.TagNumber(5)
  set windSpeed($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWindSpeed() => $_has(4);
  @$pb.TagNumber(5)
  void clearWindSpeed() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get cropType => $_getSZ(5);
  @$pb.TagNumber(6)
  set cropType($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCropType() => $_has(5);
  @$pb.TagNumber(6)
  void clearCropType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get growthStage => $_getSZ(6);
  @$pb.TagNumber(7)
  set growthStage($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasGrowthStage() => $_has(6);
  @$pb.TagNumber(7)
  void clearGrowthStage() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get evapotranspirationMm => $_getN(7);
  @$pb.TagNumber(8)
  set evapotranspirationMm($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEvapotranspirationMm() => $_has(7);
  @$pb.TagNumber(8)
  void clearEvapotranspirationMm() => $_clearField(8);
}

class DecisionOutput extends $pb.GeneratedMessage {
  factory DecisionOutput({
    $core.bool? shouldIrrigate,
    $core.double? waterQuantityLiters,
    $core.int? durationMinutes,
    $0.Timestamp? optimalTime,
    $core.String? reasoning,
    $core.double? confidenceScore,
  }) {
    final result = create();
    if (shouldIrrigate != null) result.shouldIrrigate = shouldIrrigate;
    if (waterQuantityLiters != null)
      result.waterQuantityLiters = waterQuantityLiters;
    if (durationMinutes != null) result.durationMinutes = durationMinutes;
    if (optimalTime != null) result.optimalTime = optimalTime;
    if (reasoning != null) result.reasoning = reasoning;
    if (confidenceScore != null) result.confidenceScore = confidenceScore;
    return result;
  }

  DecisionOutput._();

  factory DecisionOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DecisionOutput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DecisionOutput',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'shouldIrrigate')
    ..aD(2, _omitFieldNames ? '' : 'waterQuantityLiters')
    ..aI(3, _omitFieldNames ? '' : 'durationMinutes')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'optimalTime',
        subBuilder: $0.Timestamp.create)
    ..aOS(5, _omitFieldNames ? '' : 'reasoning')
    ..aD(6, _omitFieldNames ? '' : 'confidenceScore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecisionOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecisionOutput copyWith(void Function(DecisionOutput) updates) =>
      super.copyWith((message) => updates(message as DecisionOutput))
          as DecisionOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecisionOutput create() => DecisionOutput._();
  @$core.override
  DecisionOutput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DecisionOutput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecisionOutput>(create);
  static DecisionOutput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get shouldIrrigate => $_getBF(0);
  @$pb.TagNumber(1)
  set shouldIrrigate($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShouldIrrigate() => $_has(0);
  @$pb.TagNumber(1)
  void clearShouldIrrigate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get waterQuantityLiters => $_getN(1);
  @$pb.TagNumber(2)
  set waterQuantityLiters($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWaterQuantityLiters() => $_has(1);
  @$pb.TagNumber(2)
  void clearWaterQuantityLiters() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get durationMinutes => $_getIZ(2);
  @$pb.TagNumber(3)
  set durationMinutes($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDurationMinutes() => $_has(2);
  @$pb.TagNumber(3)
  void clearDurationMinutes() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get optimalTime => $_getN(3);
  @$pb.TagNumber(4)
  set optimalTime($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasOptimalTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearOptimalTime() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureOptimalTime() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get reasoning => $_getSZ(4);
  @$pb.TagNumber(5)
  set reasoning($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReasoning() => $_has(4);
  @$pb.TagNumber(5)
  void clearReasoning() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get confidenceScore => $_getN(5);
  @$pb.TagNumber(6)
  set confidenceScore($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasConfidenceScore() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfidenceScore() => $_clearField(6);
}

class IrrigationDecision extends $pb.GeneratedMessage {
  factory IrrigationDecision({
    $core.String? id,
    $core.String? tenantId,
    $core.String? zoneId,
    $core.String? fieldId,
    $core.String? scheduleId,
    DecisionInputs? inputs,
    DecisionOutput? output,
    $0.Timestamp? decidedAt,
    $core.bool? applied,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (zoneId != null) result.zoneId = zoneId;
    if (fieldId != null) result.fieldId = fieldId;
    if (scheduleId != null) result.scheduleId = scheduleId;
    if (inputs != null) result.inputs = inputs;
    if (output != null) result.output = output;
    if (decidedAt != null) result.decidedAt = decidedAt;
    if (applied != null) result.applied = applied;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  IrrigationDecision._();

  factory IrrigationDecision.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IrrigationDecision.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IrrigationDecision',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'zoneId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'scheduleId')
    ..aOM<DecisionInputs>(6, _omitFieldNames ? '' : 'inputs',
        subBuilder: DecisionInputs.create)
    ..aOM<DecisionOutput>(7, _omitFieldNames ? '' : 'output',
        subBuilder: DecisionOutput.create)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'decidedAt',
        subBuilder: $0.Timestamp.create)
    ..aOB(9, _omitFieldNames ? '' : 'applied')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IrrigationDecision clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IrrigationDecision copyWith(void Function(IrrigationDecision) updates) =>
      super.copyWith((message) => updates(message as IrrigationDecision))
          as IrrigationDecision;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IrrigationDecision create() => IrrigationDecision._();
  @$core.override
  IrrigationDecision createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IrrigationDecision getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IrrigationDecision>(create);
  static IrrigationDecision? _defaultInstance;

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
  $core.String get zoneId => $_getSZ(2);
  @$pb.TagNumber(3)
  set zoneId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasZoneId() => $_has(2);
  @$pb.TagNumber(3)
  void clearZoneId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fieldId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fieldId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get scheduleId => $_getSZ(4);
  @$pb.TagNumber(5)
  set scheduleId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasScheduleId() => $_has(4);
  @$pb.TagNumber(5)
  void clearScheduleId() => $_clearField(5);

  @$pb.TagNumber(6)
  DecisionInputs get inputs => $_getN(5);
  @$pb.TagNumber(6)
  set inputs(DecisionInputs value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasInputs() => $_has(5);
  @$pb.TagNumber(6)
  void clearInputs() => $_clearField(6);
  @$pb.TagNumber(6)
  DecisionInputs ensureInputs() => $_ensure(5);

  @$pb.TagNumber(7)
  DecisionOutput get output => $_getN(6);
  @$pb.TagNumber(7)
  set output(DecisionOutput value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasOutput() => $_has(6);
  @$pb.TagNumber(7)
  void clearOutput() => $_clearField(7);
  @$pb.TagNumber(7)
  DecisionOutput ensureOutput() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get decidedAt => $_getN(7);
  @$pb.TagNumber(8)
  set decidedAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasDecidedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearDecidedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureDecidedAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.bool get applied => $_getBF(8);
  @$pb.TagNumber(9)
  set applied($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasApplied() => $_has(8);
  @$pb.TagNumber(9)
  void clearApplied() => $_clearField(9);

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

class WaterUsageLog extends $pb.GeneratedMessage {
  factory WaterUsageLog({
    $core.String? id,
    $core.String? tenantId,
    $core.String? zoneId,
    $core.String? controllerId,
    $core.double? waterLiters,
    $0.Timestamp? recordedAt,
    $0.Timestamp? periodStart,
    $0.Timestamp? periodEnd,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (zoneId != null) result.zoneId = zoneId;
    if (controllerId != null) result.controllerId = controllerId;
    if (waterLiters != null) result.waterLiters = waterLiters;
    if (recordedAt != null) result.recordedAt = recordedAt;
    if (periodStart != null) result.periodStart = periodStart;
    if (periodEnd != null) result.periodEnd = periodEnd;
    return result;
  }

  WaterUsageLog._();

  factory WaterUsageLog.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WaterUsageLog.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WaterUsageLog',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'zoneId')
    ..aOS(4, _omitFieldNames ? '' : 'controllerId')
    ..aD(5, _omitFieldNames ? '' : 'waterLiters')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'recordedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'periodStart',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'periodEnd',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WaterUsageLog clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WaterUsageLog copyWith(void Function(WaterUsageLog) updates) =>
      super.copyWith((message) => updates(message as WaterUsageLog))
          as WaterUsageLog;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WaterUsageLog create() => WaterUsageLog._();
  @$core.override
  WaterUsageLog createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WaterUsageLog getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WaterUsageLog>(create);
  static WaterUsageLog? _defaultInstance;

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
  $core.String get zoneId => $_getSZ(2);
  @$pb.TagNumber(3)
  set zoneId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasZoneId() => $_has(2);
  @$pb.TagNumber(3)
  void clearZoneId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get controllerId => $_getSZ(3);
  @$pb.TagNumber(4)
  set controllerId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasControllerId() => $_has(3);
  @$pb.TagNumber(4)
  void clearControllerId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get waterLiters => $_getN(4);
  @$pb.TagNumber(5)
  set waterLiters($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWaterLiters() => $_has(4);
  @$pb.TagNumber(5)
  void clearWaterLiters() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get recordedAt => $_getN(5);
  @$pb.TagNumber(6)
  set recordedAt($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasRecordedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearRecordedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureRecordedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Timestamp get periodStart => $_getN(6);
  @$pb.TagNumber(7)
  set periodStart($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasPeriodStart() => $_has(6);
  @$pb.TagNumber(7)
  void clearPeriodStart() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensurePeriodStart() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get periodEnd => $_getN(7);
  @$pb.TagNumber(8)
  set periodEnd($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasPeriodEnd() => $_has(7);
  @$pb.TagNumber(8)
  void clearPeriodEnd() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensurePeriodEnd() => $_ensure(7);
}

class CreateScheduleRequest extends $pb.GeneratedMessage {
  factory CreateScheduleRequest({
    IrrigationSchedule? schedule,
  }) {
    final result = create();
    if (schedule != null) result.schedule = schedule;
    return result;
  }

  CreateScheduleRequest._();

  factory CreateScheduleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateScheduleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateScheduleRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOM<IrrigationSchedule>(1, _omitFieldNames ? '' : 'schedule',
        subBuilder: IrrigationSchedule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateScheduleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateScheduleRequest copyWith(
          void Function(CreateScheduleRequest) updates) =>
      super.copyWith((message) => updates(message as CreateScheduleRequest))
          as CreateScheduleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateScheduleRequest create() => CreateScheduleRequest._();
  @$core.override
  CreateScheduleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateScheduleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateScheduleRequest>(create);
  static CreateScheduleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  IrrigationSchedule get schedule => $_getN(0);
  @$pb.TagNumber(1)
  set schedule(IrrigationSchedule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSchedule() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchedule() => $_clearField(1);
  @$pb.TagNumber(1)
  IrrigationSchedule ensureSchedule() => $_ensure(0);
}

class CreateScheduleResponse extends $pb.GeneratedMessage {
  factory CreateScheduleResponse({
    IrrigationSchedule? schedule,
  }) {
    final result = create();
    if (schedule != null) result.schedule = schedule;
    return result;
  }

  CreateScheduleResponse._();

  factory CreateScheduleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateScheduleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateScheduleResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOM<IrrigationSchedule>(1, _omitFieldNames ? '' : 'schedule',
        subBuilder: IrrigationSchedule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateScheduleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateScheduleResponse copyWith(
          void Function(CreateScheduleResponse) updates) =>
      super.copyWith((message) => updates(message as CreateScheduleResponse))
          as CreateScheduleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateScheduleResponse create() => CreateScheduleResponse._();
  @$core.override
  CreateScheduleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateScheduleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateScheduleResponse>(create);
  static CreateScheduleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  IrrigationSchedule get schedule => $_getN(0);
  @$pb.TagNumber(1)
  set schedule(IrrigationSchedule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSchedule() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchedule() => $_clearField(1);
  @$pb.TagNumber(1)
  IrrigationSchedule ensureSchedule() => $_ensure(0);
}

class GetScheduleRequest extends $pb.GeneratedMessage {
  factory GetScheduleRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetScheduleRequest._();

  factory GetScheduleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetScheduleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetScheduleRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetScheduleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetScheduleRequest copyWith(void Function(GetScheduleRequest) updates) =>
      super.copyWith((message) => updates(message as GetScheduleRequest))
          as GetScheduleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetScheduleRequest create() => GetScheduleRequest._();
  @$core.override
  GetScheduleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetScheduleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetScheduleRequest>(create);
  static GetScheduleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetScheduleResponse extends $pb.GeneratedMessage {
  factory GetScheduleResponse({
    IrrigationSchedule? schedule,
  }) {
    final result = create();
    if (schedule != null) result.schedule = schedule;
    return result;
  }

  GetScheduleResponse._();

  factory GetScheduleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetScheduleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetScheduleResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOM<IrrigationSchedule>(1, _omitFieldNames ? '' : 'schedule',
        subBuilder: IrrigationSchedule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetScheduleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetScheduleResponse copyWith(void Function(GetScheduleResponse) updates) =>
      super.copyWith((message) => updates(message as GetScheduleResponse))
          as GetScheduleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetScheduleResponse create() => GetScheduleResponse._();
  @$core.override
  GetScheduleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetScheduleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetScheduleResponse>(create);
  static GetScheduleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  IrrigationSchedule get schedule => $_getN(0);
  @$pb.TagNumber(1)
  set schedule(IrrigationSchedule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSchedule() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchedule() => $_clearField(1);
  @$pb.TagNumber(1)
  IrrigationSchedule ensureSchedule() => $_ensure(0);
}

class ListSchedulesRequest extends $pb.GeneratedMessage {
  factory ListSchedulesRequest({
    $core.String? fieldId,
    $core.String? farmId,
    $core.String? zoneId,
    IrrigationStatus? status,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (zoneId != null) result.zoneId = zoneId;
    if (status != null) result.status = status;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListSchedulesRequest._();

  factory ListSchedulesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSchedulesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSchedulesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aOS(3, _omitFieldNames ? '' : 'zoneId')
    ..aE<IrrigationStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: IrrigationStatus.values)
    ..aI(5, _omitFieldNames ? '' : 'pageSize')
    ..aI(6, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSchedulesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSchedulesRequest copyWith(void Function(ListSchedulesRequest) updates) =>
      super.copyWith((message) => updates(message as ListSchedulesRequest))
          as ListSchedulesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSchedulesRequest create() => ListSchedulesRequest._();
  @$core.override
  ListSchedulesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSchedulesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSchedulesRequest>(create);
  static ListSchedulesRequest? _defaultInstance;

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
  $core.String get zoneId => $_getSZ(2);
  @$pb.TagNumber(3)
  set zoneId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasZoneId() => $_has(2);
  @$pb.TagNumber(3)
  void clearZoneId() => $_clearField(3);

  @$pb.TagNumber(4)
  IrrigationStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(IrrigationStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

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

class ListSchedulesResponse extends $pb.GeneratedMessage {
  factory ListSchedulesResponse({
    $core.Iterable<IrrigationSchedule>? schedules,
    $core.int? totalCount,
  }) {
    final result = create();
    if (schedules != null) result.schedules.addAll(schedules);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListSchedulesResponse._();

  factory ListSchedulesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSchedulesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSchedulesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..pPM<IrrigationSchedule>(1, _omitFieldNames ? '' : 'schedules',
        subBuilder: IrrigationSchedule.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSchedulesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSchedulesResponse copyWith(
          void Function(ListSchedulesResponse) updates) =>
      super.copyWith((message) => updates(message as ListSchedulesResponse))
          as ListSchedulesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSchedulesResponse create() => ListSchedulesResponse._();
  @$core.override
  ListSchedulesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSchedulesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSchedulesResponse>(create);
  static ListSchedulesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<IrrigationSchedule> get schedules => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class UpdateScheduleRequest extends $pb.GeneratedMessage {
  factory UpdateScheduleRequest({
    IrrigationSchedule? schedule,
  }) {
    final result = create();
    if (schedule != null) result.schedule = schedule;
    return result;
  }

  UpdateScheduleRequest._();

  factory UpdateScheduleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateScheduleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateScheduleRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOM<IrrigationSchedule>(1, _omitFieldNames ? '' : 'schedule',
        subBuilder: IrrigationSchedule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateScheduleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateScheduleRequest copyWith(
          void Function(UpdateScheduleRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateScheduleRequest))
          as UpdateScheduleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateScheduleRequest create() => UpdateScheduleRequest._();
  @$core.override
  UpdateScheduleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateScheduleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateScheduleRequest>(create);
  static UpdateScheduleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  IrrigationSchedule get schedule => $_getN(0);
  @$pb.TagNumber(1)
  set schedule(IrrigationSchedule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSchedule() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchedule() => $_clearField(1);
  @$pb.TagNumber(1)
  IrrigationSchedule ensureSchedule() => $_ensure(0);
}

class UpdateScheduleResponse extends $pb.GeneratedMessage {
  factory UpdateScheduleResponse({
    IrrigationSchedule? schedule,
  }) {
    final result = create();
    if (schedule != null) result.schedule = schedule;
    return result;
  }

  UpdateScheduleResponse._();

  factory UpdateScheduleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateScheduleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateScheduleResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOM<IrrigationSchedule>(1, _omitFieldNames ? '' : 'schedule',
        subBuilder: IrrigationSchedule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateScheduleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateScheduleResponse copyWith(
          void Function(UpdateScheduleResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateScheduleResponse))
          as UpdateScheduleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateScheduleResponse create() => UpdateScheduleResponse._();
  @$core.override
  UpdateScheduleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateScheduleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateScheduleResponse>(create);
  static UpdateScheduleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  IrrigationSchedule get schedule => $_getN(0);
  @$pb.TagNumber(1)
  set schedule(IrrigationSchedule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSchedule() => $_has(0);
  @$pb.TagNumber(1)
  void clearSchedule() => $_clearField(1);
  @$pb.TagNumber(1)
  IrrigationSchedule ensureSchedule() => $_ensure(0);
}

class DeleteScheduleRequest extends $pb.GeneratedMessage {
  factory DeleteScheduleRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteScheduleRequest._();

  factory DeleteScheduleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteScheduleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteScheduleRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteScheduleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteScheduleRequest copyWith(
          void Function(DeleteScheduleRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteScheduleRequest))
          as DeleteScheduleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteScheduleRequest create() => DeleteScheduleRequest._();
  @$core.override
  DeleteScheduleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteScheduleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteScheduleRequest>(create);
  static DeleteScheduleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteScheduleResponse extends $pb.GeneratedMessage {
  factory DeleteScheduleResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  DeleteScheduleResponse._();

  factory DeleteScheduleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteScheduleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteScheduleResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteScheduleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteScheduleResponse copyWith(
          void Function(DeleteScheduleResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteScheduleResponse))
          as DeleteScheduleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteScheduleResponse create() => DeleteScheduleResponse._();
  @$core.override
  DeleteScheduleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteScheduleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteScheduleResponse>(create);
  static DeleteScheduleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

class GenerateIrrigationDecisionRequest extends $pb.GeneratedMessage {
  factory GenerateIrrigationDecisionRequest({
    $core.String? zoneId,
    $core.String? fieldId,
    DecisionInputs? inputs,
  }) {
    final result = create();
    if (zoneId != null) result.zoneId = zoneId;
    if (fieldId != null) result.fieldId = fieldId;
    if (inputs != null) result.inputs = inputs;
    return result;
  }

  GenerateIrrigationDecisionRequest._();

  factory GenerateIrrigationDecisionRequest.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateIrrigationDecisionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateIrrigationDecisionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'zoneId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOM<DecisionInputs>(3, _omitFieldNames ? '' : 'inputs',
        subBuilder: DecisionInputs.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateIrrigationDecisionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateIrrigationDecisionRequest copyWith(
          void Function(GenerateIrrigationDecisionRequest) updates) =>
      super.copyWith((message) =>
              updates(message as GenerateIrrigationDecisionRequest))
          as GenerateIrrigationDecisionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateIrrigationDecisionRequest create() =>
      GenerateIrrigationDecisionRequest._();
  @$core.override
  GenerateIrrigationDecisionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateIrrigationDecisionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateIrrigationDecisionRequest>(
          create);
  static GenerateIrrigationDecisionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get zoneId => $_getSZ(0);
  @$pb.TagNumber(1)
  set zoneId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasZoneId() => $_has(0);
  @$pb.TagNumber(1)
  void clearZoneId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  DecisionInputs get inputs => $_getN(2);
  @$pb.TagNumber(3)
  set inputs(DecisionInputs value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasInputs() => $_has(2);
  @$pb.TagNumber(3)
  void clearInputs() => $_clearField(3);
  @$pb.TagNumber(3)
  DecisionInputs ensureInputs() => $_ensure(2);
}

class GenerateIrrigationDecisionResponse extends $pb.GeneratedMessage {
  factory GenerateIrrigationDecisionResponse({
    IrrigationDecision? decision,
  }) {
    final result = create();
    if (decision != null) result.decision = decision;
    return result;
  }

  GenerateIrrigationDecisionResponse._();

  factory GenerateIrrigationDecisionResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateIrrigationDecisionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateIrrigationDecisionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOM<IrrigationDecision>(1, _omitFieldNames ? '' : 'decision',
        subBuilder: IrrigationDecision.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateIrrigationDecisionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateIrrigationDecisionResponse copyWith(
          void Function(GenerateIrrigationDecisionResponse) updates) =>
      super.copyWith((message) =>
              updates(message as GenerateIrrigationDecisionResponse))
          as GenerateIrrigationDecisionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateIrrigationDecisionResponse create() =>
      GenerateIrrigationDecisionResponse._();
  @$core.override
  GenerateIrrigationDecisionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateIrrigationDecisionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateIrrigationDecisionResponse>(
          create);
  static GenerateIrrigationDecisionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  IrrigationDecision get decision => $_getN(0);
  @$pb.TagNumber(1)
  set decision(IrrigationDecision value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDecision() => $_has(0);
  @$pb.TagNumber(1)
  void clearDecision() => $_clearField(1);
  @$pb.TagNumber(1)
  IrrigationDecision ensureDecision() => $_ensure(0);
}

class CreateZoneRequest extends $pb.GeneratedMessage {
  factory CreateZoneRequest({
    IrrigationZone? zone,
  }) {
    final result = create();
    if (zone != null) result.zone = zone;
    return result;
  }

  CreateZoneRequest._();

  factory CreateZoneRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateZoneRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateZoneRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOM<IrrigationZone>(1, _omitFieldNames ? '' : 'zone',
        subBuilder: IrrigationZone.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateZoneRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateZoneRequest copyWith(void Function(CreateZoneRequest) updates) =>
      super.copyWith((message) => updates(message as CreateZoneRequest))
          as CreateZoneRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateZoneRequest create() => CreateZoneRequest._();
  @$core.override
  CreateZoneRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateZoneRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateZoneRequest>(create);
  static CreateZoneRequest? _defaultInstance;

  @$pb.TagNumber(1)
  IrrigationZone get zone => $_getN(0);
  @$pb.TagNumber(1)
  set zone(IrrigationZone value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasZone() => $_has(0);
  @$pb.TagNumber(1)
  void clearZone() => $_clearField(1);
  @$pb.TagNumber(1)
  IrrigationZone ensureZone() => $_ensure(0);
}

class CreateZoneResponse extends $pb.GeneratedMessage {
  factory CreateZoneResponse({
    IrrigationZone? zone,
  }) {
    final result = create();
    if (zone != null) result.zone = zone;
    return result;
  }

  CreateZoneResponse._();

  factory CreateZoneResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateZoneResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateZoneResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOM<IrrigationZone>(1, _omitFieldNames ? '' : 'zone',
        subBuilder: IrrigationZone.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateZoneResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateZoneResponse copyWith(void Function(CreateZoneResponse) updates) =>
      super.copyWith((message) => updates(message as CreateZoneResponse))
          as CreateZoneResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateZoneResponse create() => CreateZoneResponse._();
  @$core.override
  CreateZoneResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateZoneResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateZoneResponse>(create);
  static CreateZoneResponse? _defaultInstance;

  @$pb.TagNumber(1)
  IrrigationZone get zone => $_getN(0);
  @$pb.TagNumber(1)
  set zone(IrrigationZone value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasZone() => $_has(0);
  @$pb.TagNumber(1)
  void clearZone() => $_clearField(1);
  @$pb.TagNumber(1)
  IrrigationZone ensureZone() => $_ensure(0);
}

class ListZonesRequest extends $pb.GeneratedMessage {
  factory ListZonesRequest({
    $core.String? fieldId,
    $core.String? farmId,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListZonesRequest._();

  factory ListZonesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListZonesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListZonesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aI(3, _omitFieldNames ? '' : 'pageSize')
    ..aI(4, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListZonesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListZonesRequest copyWith(void Function(ListZonesRequest) updates) =>
      super.copyWith((message) => updates(message as ListZonesRequest))
          as ListZonesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListZonesRequest create() => ListZonesRequest._();
  @$core.override
  ListZonesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListZonesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListZonesRequest>(create);
  static ListZonesRequest? _defaultInstance;

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
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pageOffset => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageOffset($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageOffset() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageOffset() => $_clearField(4);
}

class ListZonesResponse extends $pb.GeneratedMessage {
  factory ListZonesResponse({
    $core.Iterable<IrrigationZone>? zones,
    $core.int? totalCount,
  }) {
    final result = create();
    if (zones != null) result.zones.addAll(zones);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListZonesResponse._();

  factory ListZonesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListZonesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListZonesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..pPM<IrrigationZone>(1, _omitFieldNames ? '' : 'zones',
        subBuilder: IrrigationZone.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListZonesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListZonesResponse copyWith(void Function(ListZonesResponse) updates) =>
      super.copyWith((message) => updates(message as ListZonesResponse))
          as ListZonesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListZonesResponse create() => ListZonesResponse._();
  @$core.override
  ListZonesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListZonesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListZonesResponse>(create);
  static ListZonesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<IrrigationZone> get zones => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class RegisterControllerRequest extends $pb.GeneratedMessage {
  factory RegisterControllerRequest({
    WaterController? controller,
  }) {
    final result = create();
    if (controller != null) result.controller = controller;
    return result;
  }

  RegisterControllerRequest._();

  factory RegisterControllerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterControllerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterControllerRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOM<WaterController>(1, _omitFieldNames ? '' : 'controller',
        subBuilder: WaterController.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterControllerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterControllerRequest copyWith(
          void Function(RegisterControllerRequest) updates) =>
      super.copyWith((message) => updates(message as RegisterControllerRequest))
          as RegisterControllerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterControllerRequest create() => RegisterControllerRequest._();
  @$core.override
  RegisterControllerRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterControllerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterControllerRequest>(create);
  static RegisterControllerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  WaterController get controller => $_getN(0);
  @$pb.TagNumber(1)
  set controller(WaterController value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasController() => $_has(0);
  @$pb.TagNumber(1)
  void clearController() => $_clearField(1);
  @$pb.TagNumber(1)
  WaterController ensureController() => $_ensure(0);
}

class RegisterControllerResponse extends $pb.GeneratedMessage {
  factory RegisterControllerResponse({
    WaterController? controller,
  }) {
    final result = create();
    if (controller != null) result.controller = controller;
    return result;
  }

  RegisterControllerResponse._();

  factory RegisterControllerResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterControllerResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterControllerResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOM<WaterController>(1, _omitFieldNames ? '' : 'controller',
        subBuilder: WaterController.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterControllerResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterControllerResponse copyWith(
          void Function(RegisterControllerResponse) updates) =>
      super.copyWith(
              (message) => updates(message as RegisterControllerResponse))
          as RegisterControllerResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterControllerResponse create() => RegisterControllerResponse._();
  @$core.override
  RegisterControllerResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterControllerResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterControllerResponse>(create);
  static RegisterControllerResponse? _defaultInstance;

  @$pb.TagNumber(1)
  WaterController get controller => $_getN(0);
  @$pb.TagNumber(1)
  set controller(WaterController value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasController() => $_has(0);
  @$pb.TagNumber(1)
  void clearController() => $_clearField(1);
  @$pb.TagNumber(1)
  WaterController ensureController() => $_ensure(0);
}

class ListControllersRequest extends $pb.GeneratedMessage {
  factory ListControllersRequest({
    $core.String? zoneId,
    $core.String? fieldId,
    ControllerStatus? status,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (zoneId != null) result.zoneId = zoneId;
    if (fieldId != null) result.fieldId = fieldId;
    if (status != null) result.status = status;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListControllersRequest._();

  factory ListControllersRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListControllersRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListControllersRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'zoneId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aE<ControllerStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: ControllerStatus.values)
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aI(5, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListControllersRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListControllersRequest copyWith(
          void Function(ListControllersRequest) updates) =>
      super.copyWith((message) => updates(message as ListControllersRequest))
          as ListControllersRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListControllersRequest create() => ListControllersRequest._();
  @$core.override
  ListControllersRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListControllersRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListControllersRequest>(create);
  static ListControllersRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get zoneId => $_getSZ(0);
  @$pb.TagNumber(1)
  set zoneId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasZoneId() => $_has(0);
  @$pb.TagNumber(1)
  void clearZoneId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  ControllerStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(ControllerStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

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
}

class ListControllersResponse extends $pb.GeneratedMessage {
  factory ListControllersResponse({
    $core.Iterable<WaterController>? controllers,
    $core.int? totalCount,
  }) {
    final result = create();
    if (controllers != null) result.controllers.addAll(controllers);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListControllersResponse._();

  factory ListControllersResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListControllersResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListControllersResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..pPM<WaterController>(1, _omitFieldNames ? '' : 'controllers',
        subBuilder: WaterController.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListControllersResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListControllersResponse copyWith(
          void Function(ListControllersResponse) updates) =>
      super.copyWith((message) => updates(message as ListControllersResponse))
          as ListControllersResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListControllersResponse create() => ListControllersResponse._();
  @$core.override
  ListControllersResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListControllersResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListControllersResponse>(create);
  static ListControllersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<WaterController> get controllers => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class TriggerIrrigationRequest extends $pb.GeneratedMessage {
  factory TriggerIrrigationRequest({
    $core.String? scheduleId,
    $core.String? controllerId,
    $core.String? zoneId,
    $core.int? durationMinutes,
    $core.double? waterQuantityLiters,
  }) {
    final result = create();
    if (scheduleId != null) result.scheduleId = scheduleId;
    if (controllerId != null) result.controllerId = controllerId;
    if (zoneId != null) result.zoneId = zoneId;
    if (durationMinutes != null) result.durationMinutes = durationMinutes;
    if (waterQuantityLiters != null)
      result.waterQuantityLiters = waterQuantityLiters;
    return result;
  }

  TriggerIrrigationRequest._();

  factory TriggerIrrigationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TriggerIrrigationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TriggerIrrigationRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'scheduleId')
    ..aOS(2, _omitFieldNames ? '' : 'controllerId')
    ..aOS(3, _omitFieldNames ? '' : 'zoneId')
    ..aI(4, _omitFieldNames ? '' : 'durationMinutes')
    ..aD(5, _omitFieldNames ? '' : 'waterQuantityLiters')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TriggerIrrigationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TriggerIrrigationRequest copyWith(
          void Function(TriggerIrrigationRequest) updates) =>
      super.copyWith((message) => updates(message as TriggerIrrigationRequest))
          as TriggerIrrigationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TriggerIrrigationRequest create() => TriggerIrrigationRequest._();
  @$core.override
  TriggerIrrigationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TriggerIrrigationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TriggerIrrigationRequest>(create);
  static TriggerIrrigationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get scheduleId => $_getSZ(0);
  @$pb.TagNumber(1)
  set scheduleId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasScheduleId() => $_has(0);
  @$pb.TagNumber(1)
  void clearScheduleId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get controllerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set controllerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasControllerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearControllerId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get zoneId => $_getSZ(2);
  @$pb.TagNumber(3)
  set zoneId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasZoneId() => $_has(2);
  @$pb.TagNumber(3)
  void clearZoneId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get durationMinutes => $_getIZ(3);
  @$pb.TagNumber(4)
  set durationMinutes($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDurationMinutes() => $_has(3);
  @$pb.TagNumber(4)
  void clearDurationMinutes() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get waterQuantityLiters => $_getN(4);
  @$pb.TagNumber(5)
  set waterQuantityLiters($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWaterQuantityLiters() => $_has(4);
  @$pb.TagNumber(5)
  void clearWaterQuantityLiters() => $_clearField(5);
}

class TriggerIrrigationResponse extends $pb.GeneratedMessage {
  factory TriggerIrrigationResponse({
    IrrigationEvent? event,
  }) {
    final result = create();
    if (event != null) result.event = event;
    return result;
  }

  TriggerIrrigationResponse._();

  factory TriggerIrrigationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TriggerIrrigationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TriggerIrrigationResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOM<IrrigationEvent>(1, _omitFieldNames ? '' : 'event',
        subBuilder: IrrigationEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TriggerIrrigationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TriggerIrrigationResponse copyWith(
          void Function(TriggerIrrigationResponse) updates) =>
      super.copyWith((message) => updates(message as TriggerIrrigationResponse))
          as TriggerIrrigationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TriggerIrrigationResponse create() => TriggerIrrigationResponse._();
  @$core.override
  TriggerIrrigationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TriggerIrrigationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TriggerIrrigationResponse>(create);
  static TriggerIrrigationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  IrrigationEvent get event => $_getN(0);
  @$pb.TagNumber(1)
  set event(IrrigationEvent value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEvent() => $_has(0);
  @$pb.TagNumber(1)
  void clearEvent() => $_clearField(1);
  @$pb.TagNumber(1)
  IrrigationEvent ensureEvent() => $_ensure(0);
}

class StopIrrigationRequest extends $pb.GeneratedMessage {
  factory StopIrrigationRequest({
    $core.String? eventId,
    $core.String? controllerId,
  }) {
    final result = create();
    if (eventId != null) result.eventId = eventId;
    if (controllerId != null) result.controllerId = controllerId;
    return result;
  }

  StopIrrigationRequest._();

  factory StopIrrigationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StopIrrigationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StopIrrigationRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'eventId')
    ..aOS(2, _omitFieldNames ? '' : 'controllerId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopIrrigationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopIrrigationRequest copyWith(
          void Function(StopIrrigationRequest) updates) =>
      super.copyWith((message) => updates(message as StopIrrigationRequest))
          as StopIrrigationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopIrrigationRequest create() => StopIrrigationRequest._();
  @$core.override
  StopIrrigationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StopIrrigationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StopIrrigationRequest>(create);
  static StopIrrigationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get eventId => $_getSZ(0);
  @$pb.TagNumber(1)
  set eventId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEventId() => $_has(0);
  @$pb.TagNumber(1)
  void clearEventId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get controllerId => $_getSZ(1);
  @$pb.TagNumber(2)
  set controllerId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasControllerId() => $_has(1);
  @$pb.TagNumber(2)
  void clearControllerId() => $_clearField(2);
}

class StopIrrigationResponse extends $pb.GeneratedMessage {
  factory StopIrrigationResponse({
    IrrigationEvent? event,
  }) {
    final result = create();
    if (event != null) result.event = event;
    return result;
  }

  StopIrrigationResponse._();

  factory StopIrrigationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StopIrrigationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StopIrrigationResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOM<IrrigationEvent>(1, _omitFieldNames ? '' : 'event',
        subBuilder: IrrigationEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopIrrigationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopIrrigationResponse copyWith(
          void Function(StopIrrigationResponse) updates) =>
      super.copyWith((message) => updates(message as StopIrrigationResponse))
          as StopIrrigationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopIrrigationResponse create() => StopIrrigationResponse._();
  @$core.override
  StopIrrigationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StopIrrigationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StopIrrigationResponse>(create);
  static StopIrrigationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  IrrigationEvent get event => $_getN(0);
  @$pb.TagNumber(1)
  set event(IrrigationEvent value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEvent() => $_has(0);
  @$pb.TagNumber(1)
  void clearEvent() => $_clearField(1);
  @$pb.TagNumber(1)
  IrrigationEvent ensureEvent() => $_ensure(0);
}

class GetWaterUsageRequest extends $pb.GeneratedMessage {
  factory GetWaterUsageRequest({
    $core.String? zoneId,
    $core.String? fieldId,
    $0.Timestamp? from,
    $0.Timestamp? to,
  }) {
    final result = create();
    if (zoneId != null) result.zoneId = zoneId;
    if (fieldId != null) result.fieldId = fieldId;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    return result;
  }

  GetWaterUsageRequest._();

  factory GetWaterUsageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetWaterUsageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetWaterUsageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'zoneId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'from',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'to',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWaterUsageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWaterUsageRequest copyWith(void Function(GetWaterUsageRequest) updates) =>
      super.copyWith((message) => updates(message as GetWaterUsageRequest))
          as GetWaterUsageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWaterUsageRequest create() => GetWaterUsageRequest._();
  @$core.override
  GetWaterUsageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetWaterUsageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWaterUsageRequest>(create);
  static GetWaterUsageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get zoneId => $_getSZ(0);
  @$pb.TagNumber(1)
  set zoneId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasZoneId() => $_has(0);
  @$pb.TagNumber(1)
  void clearZoneId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get from => $_getN(2);
  @$pb.TagNumber(3)
  set from($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasFrom() => $_has(2);
  @$pb.TagNumber(3)
  void clearFrom() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureFrom() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Timestamp get to => $_getN(3);
  @$pb.TagNumber(4)
  set to($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTo() => $_has(3);
  @$pb.TagNumber(4)
  void clearTo() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureTo() => $_ensure(3);
}

class GetWaterUsageResponse extends $pb.GeneratedMessage {
  factory GetWaterUsageResponse({
    $core.Iterable<WaterUsageLog>? logs,
    $core.double? totalLiters,
  }) {
    final result = create();
    if (logs != null) result.logs.addAll(logs);
    if (totalLiters != null) result.totalLiters = totalLiters;
    return result;
  }

  GetWaterUsageResponse._();

  factory GetWaterUsageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetWaterUsageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetWaterUsageResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..pPM<WaterUsageLog>(1, _omitFieldNames ? '' : 'logs',
        subBuilder: WaterUsageLog.create)
    ..aD(2, _omitFieldNames ? '' : 'totalLiters')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWaterUsageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWaterUsageResponse copyWith(
          void Function(GetWaterUsageResponse) updates) =>
      super.copyWith((message) => updates(message as GetWaterUsageResponse))
          as GetWaterUsageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWaterUsageResponse create() => GetWaterUsageResponse._();
  @$core.override
  GetWaterUsageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetWaterUsageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWaterUsageResponse>(create);
  static GetWaterUsageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<WaterUsageLog> get logs => $_getList(0);

  @$pb.TagNumber(2)
  $core.double get totalLiters => $_getN(1);
  @$pb.TagNumber(2)
  set totalLiters($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalLiters() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalLiters() => $_clearField(2);
}

class GetIrrigationHistoryRequest extends $pb.GeneratedMessage {
  factory GetIrrigationHistoryRequest({
    $core.String? zoneId,
    $core.String? fieldId,
    $core.String? scheduleId,
    $0.Timestamp? from,
    $0.Timestamp? to,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (zoneId != null) result.zoneId = zoneId;
    if (fieldId != null) result.fieldId = fieldId;
    if (scheduleId != null) result.scheduleId = scheduleId;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  GetIrrigationHistoryRequest._();

  factory GetIrrigationHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetIrrigationHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetIrrigationHistoryRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'zoneId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'scheduleId')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'from',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'to',
        subBuilder: $0.Timestamp.create)
    ..aI(6, _omitFieldNames ? '' : 'pageSize')
    ..aI(7, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIrrigationHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIrrigationHistoryRequest copyWith(
          void Function(GetIrrigationHistoryRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetIrrigationHistoryRequest))
          as GetIrrigationHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetIrrigationHistoryRequest create() =>
      GetIrrigationHistoryRequest._();
  @$core.override
  GetIrrigationHistoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetIrrigationHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetIrrigationHistoryRequest>(create);
  static GetIrrigationHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get zoneId => $_getSZ(0);
  @$pb.TagNumber(1)
  set zoneId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasZoneId() => $_has(0);
  @$pb.TagNumber(1)
  void clearZoneId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get scheduleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set scheduleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScheduleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearScheduleId() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get from => $_getN(3);
  @$pb.TagNumber(4)
  set from($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFrom() => $_has(3);
  @$pb.TagNumber(4)
  void clearFrom() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureFrom() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Timestamp get to => $_getN(4);
  @$pb.TagNumber(5)
  set to($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasTo() => $_has(4);
  @$pb.TagNumber(5)
  void clearTo() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureTo() => $_ensure(4);

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
}

class GetIrrigationHistoryResponse extends $pb.GeneratedMessage {
  factory GetIrrigationHistoryResponse({
    $core.Iterable<IrrigationEvent>? events,
    $core.int? totalCount,
  }) {
    final result = create();
    if (events != null) result.events.addAll(events);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  GetIrrigationHistoryResponse._();

  factory GetIrrigationHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetIrrigationHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetIrrigationHistoryResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.irrigation.v1'),
      createEmptyInstance: create)
    ..pPM<IrrigationEvent>(1, _omitFieldNames ? '' : 'events',
        subBuilder: IrrigationEvent.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIrrigationHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIrrigationHistoryResponse copyWith(
          void Function(GetIrrigationHistoryResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetIrrigationHistoryResponse))
          as GetIrrigationHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetIrrigationHistoryResponse create() =>
      GetIrrigationHistoryResponse._();
  @$core.override
  GetIrrigationHistoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetIrrigationHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetIrrigationHistoryResponse>(create);
  static GetIrrigationHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<IrrigationEvent> get events => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class IrrigationServiceApi {
  final $pb.RpcClient _client;

  IrrigationServiceApi(this._client);

  /// Schedule management
  $async.Future<CreateScheduleResponse> createSchedule(
          $pb.ClientContext? ctx, CreateScheduleRequest request) =>
      _client.invoke<CreateScheduleResponse>(ctx, 'IrrigationService',
          'CreateSchedule', request, CreateScheduleResponse());
  $async.Future<GetScheduleResponse> getSchedule(
          $pb.ClientContext? ctx, GetScheduleRequest request) =>
      _client.invoke<GetScheduleResponse>(ctx, 'IrrigationService',
          'GetSchedule', request, GetScheduleResponse());
  $async.Future<ListSchedulesResponse> listSchedules(
          $pb.ClientContext? ctx, ListSchedulesRequest request) =>
      _client.invoke<ListSchedulesResponse>(ctx, 'IrrigationService',
          'ListSchedules', request, ListSchedulesResponse());
  $async.Future<UpdateScheduleResponse> updateSchedule(
          $pb.ClientContext? ctx, UpdateScheduleRequest request) =>
      _client.invoke<UpdateScheduleResponse>(ctx, 'IrrigationService',
          'UpdateSchedule', request, UpdateScheduleResponse());
  $async.Future<DeleteScheduleResponse> deleteSchedule(
          $pb.ClientContext? ctx, DeleteScheduleRequest request) =>
      _client.invoke<DeleteScheduleResponse>(ctx, 'IrrigationService',
          'DeleteSchedule', request, DeleteScheduleResponse());

  /// AI-driven irrigation decisions
  $async.Future<GenerateIrrigationDecisionResponse> generateIrrigationDecision(
          $pb.ClientContext? ctx, GenerateIrrigationDecisionRequest request) =>
      _client.invoke<GenerateIrrigationDecisionResponse>(
          ctx,
          'IrrigationService',
          'GenerateIrrigationDecision',
          request,
          GenerateIrrigationDecisionResponse());

  /// Zone management
  $async.Future<CreateZoneResponse> createZone(
          $pb.ClientContext? ctx, CreateZoneRequest request) =>
      _client.invoke<CreateZoneResponse>(ctx, 'IrrigationService', 'CreateZone',
          request, CreateZoneResponse());
  $async.Future<ListZonesResponse> listZones(
          $pb.ClientContext? ctx, ListZonesRequest request) =>
      _client.invoke<ListZonesResponse>(
          ctx, 'IrrigationService', 'ListZones', request, ListZonesResponse());

  /// Controller management
  $async.Future<RegisterControllerResponse> registerController(
          $pb.ClientContext? ctx, RegisterControllerRequest request) =>
      _client.invoke<RegisterControllerResponse>(ctx, 'IrrigationService',
          'RegisterController', request, RegisterControllerResponse());
  $async.Future<ListControllersResponse> listControllers(
          $pb.ClientContext? ctx, ListControllersRequest request) =>
      _client.invoke<ListControllersResponse>(ctx, 'IrrigationService',
          'ListControllers', request, ListControllersResponse());

  /// Irrigation control
  $async.Future<TriggerIrrigationResponse> triggerIrrigation(
          $pb.ClientContext? ctx, TriggerIrrigationRequest request) =>
      _client.invoke<TriggerIrrigationResponse>(ctx, 'IrrigationService',
          'TriggerIrrigation', request, TriggerIrrigationResponse());
  $async.Future<StopIrrigationResponse> stopIrrigation(
          $pb.ClientContext? ctx, StopIrrigationRequest request) =>
      _client.invoke<StopIrrigationResponse>(ctx, 'IrrigationService',
          'StopIrrigation', request, StopIrrigationResponse());

  /// Reporting
  $async.Future<GetWaterUsageResponse> getWaterUsage(
          $pb.ClientContext? ctx, GetWaterUsageRequest request) =>
      _client.invoke<GetWaterUsageResponse>(ctx, 'IrrigationService',
          'GetWaterUsage', request, GetWaterUsageResponse());
  $async.Future<GetIrrigationHistoryResponse> getIrrigationHistory(
          $pb.ClientContext? ctx, GetIrrigationHistoryRequest request) =>
      _client.invoke<GetIrrigationHistoryResponse>(ctx, 'IrrigationService',
          'GetIrrigationHistory', request, GetIrrigationHistoryResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
