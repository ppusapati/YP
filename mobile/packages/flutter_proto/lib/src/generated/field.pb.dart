// This is a generated file - do not edit.
//
// Generated from field.proto.

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

import 'field.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'field.pbenum.dart';

class GeoPoint extends $pb.GeneratedMessage {
  factory GeoPoint({
    $core.double? longitude,
    $core.double? latitude,
  }) {
    final result = create();
    if (longitude != null) result.longitude = longitude;
    if (latitude != null) result.latitude = latitude;
    return result;
  }

  GeoPoint._();

  factory GeoPoint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GeoPoint.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GeoPoint',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'longitude')
    ..aD(2, _omitFieldNames ? '' : 'latitude')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeoPoint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeoPoint copyWith(void Function(GeoPoint) updates) =>
      super.copyWith((message) => updates(message as GeoPoint)) as GeoPoint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GeoPoint create() => GeoPoint._();
  @$core.override
  GeoPoint createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GeoPoint getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GeoPoint>(create);
  static GeoPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get longitude => $_getN(0);
  @$pb.TagNumber(1)
  set longitude($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLongitude() => $_has(0);
  @$pb.TagNumber(1)
  void clearLongitude() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get latitude => $_getN(1);
  @$pb.TagNumber(2)
  set latitude($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLatitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLatitude() => $_clearField(2);
}

class GeoPolygon extends $pb.GeneratedMessage {
  factory GeoPolygon({
    $core.Iterable<GeoPoint>? points,
  }) {
    final result = create();
    if (points != null) result.points.addAll(points);
    return result;
  }

  GeoPolygon._();

  factory GeoPolygon.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GeoPolygon.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GeoPolygon',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..pPM<GeoPoint>(1, _omitFieldNames ? '' : 'points',
        subBuilder: GeoPoint.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeoPolygon clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeoPolygon copyWith(void Function(GeoPolygon) updates) =>
      super.copyWith((message) => updates(message as GeoPolygon)) as GeoPolygon;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GeoPolygon create() => GeoPolygon._();
  @$core.override
  GeoPolygon createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GeoPolygon getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GeoPolygon>(create);
  static GeoPolygon? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GeoPoint> get points => $_getList(0);
}

class Field extends $pb.GeneratedMessage {
  factory Field({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? name,
    $core.double? areaHectares,
    GeoPolygon? boundary,
    $core.String? currentCropId,
    $0.Timestamp? plantingDate,
    $0.Timestamp? expectedHarvestDate,
    GrowthStage? growthStage,
    SoilType? soilType,
    IrrigationType? irrigationType,
    FieldType? fieldType,
    FieldStatus? status,
    $core.double? elevationMeters,
    $core.double? slopeDegrees,
    AspectDirection? aspectDirection,
    $core.String? createdBy,
    $core.String? updatedBy,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (name != null) result.name = name;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (boundary != null) result.boundary = boundary;
    if (currentCropId != null) result.currentCropId = currentCropId;
    if (plantingDate != null) result.plantingDate = plantingDate;
    if (expectedHarvestDate != null)
      result.expectedHarvestDate = expectedHarvestDate;
    if (growthStage != null) result.growthStage = growthStage;
    if (soilType != null) result.soilType = soilType;
    if (irrigationType != null) result.irrigationType = irrigationType;
    if (fieldType != null) result.fieldType = fieldType;
    if (status != null) result.status = status;
    if (elevationMeters != null) result.elevationMeters = elevationMeters;
    if (slopeDegrees != null) result.slopeDegrees = slopeDegrees;
    if (aspectDirection != null) result.aspectDirection = aspectDirection;
    if (createdBy != null) result.createdBy = createdBy;
    if (updatedBy != null) result.updatedBy = updatedBy;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (version != null) result.version = version;
    return result;
  }

  Field._();

  factory Field.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Field.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Field',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'name')
    ..aD(5, _omitFieldNames ? '' : 'areaHectares')
    ..aOM<GeoPolygon>(6, _omitFieldNames ? '' : 'boundary',
        subBuilder: GeoPolygon.create)
    ..aOS(7, _omitFieldNames ? '' : 'currentCropId')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'plantingDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'expectedHarvestDate',
        subBuilder: $0.Timestamp.create)
    ..aE<GrowthStage>(10, _omitFieldNames ? '' : 'growthStage',
        enumValues: GrowthStage.values)
    ..aE<SoilType>(11, _omitFieldNames ? '' : 'soilType',
        enumValues: SoilType.values)
    ..aE<IrrigationType>(12, _omitFieldNames ? '' : 'irrigationType',
        enumValues: IrrigationType.values)
    ..aE<FieldType>(13, _omitFieldNames ? '' : 'fieldType',
        enumValues: FieldType.values)
    ..aE<FieldStatus>(14, _omitFieldNames ? '' : 'status',
        enumValues: FieldStatus.values)
    ..aD(15, _omitFieldNames ? '' : 'elevationMeters')
    ..aD(16, _omitFieldNames ? '' : 'slopeDegrees')
    ..aE<AspectDirection>(17, _omitFieldNames ? '' : 'aspectDirection',
        enumValues: AspectDirection.values)
    ..aOS(18, _omitFieldNames ? '' : 'createdBy')
    ..aOS(19, _omitFieldNames ? '' : 'updatedBy')
    ..aOM<$0.Timestamp>(20, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(21, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aInt64(22, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Field clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Field copyWith(void Function(Field) updates) =>
      super.copyWith((message) => updates(message as Field)) as Field;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Field create() => Field._();
  @$core.override
  Field createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Field getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Field>(create);
  static Field? _defaultInstance;

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
  $core.double get areaHectares => $_getN(4);
  @$pb.TagNumber(5)
  set areaHectares($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAreaHectares() => $_has(4);
  @$pb.TagNumber(5)
  void clearAreaHectares() => $_clearField(5);

  @$pb.TagNumber(6)
  GeoPolygon get boundary => $_getN(5);
  @$pb.TagNumber(6)
  set boundary(GeoPolygon value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasBoundary() => $_has(5);
  @$pb.TagNumber(6)
  void clearBoundary() => $_clearField(6);
  @$pb.TagNumber(6)
  GeoPolygon ensureBoundary() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get currentCropId => $_getSZ(6);
  @$pb.TagNumber(7)
  set currentCropId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCurrentCropId() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrentCropId() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get plantingDate => $_getN(7);
  @$pb.TagNumber(8)
  set plantingDate($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasPlantingDate() => $_has(7);
  @$pb.TagNumber(8)
  void clearPlantingDate() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensurePlantingDate() => $_ensure(7);

  @$pb.TagNumber(9)
  $0.Timestamp get expectedHarvestDate => $_getN(8);
  @$pb.TagNumber(9)
  set expectedHarvestDate($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasExpectedHarvestDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearExpectedHarvestDate() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureExpectedHarvestDate() => $_ensure(8);

  @$pb.TagNumber(10)
  GrowthStage get growthStage => $_getN(9);
  @$pb.TagNumber(10)
  set growthStage(GrowthStage value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasGrowthStage() => $_has(9);
  @$pb.TagNumber(10)
  void clearGrowthStage() => $_clearField(10);

  @$pb.TagNumber(11)
  SoilType get soilType => $_getN(10);
  @$pb.TagNumber(11)
  set soilType(SoilType value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasSoilType() => $_has(10);
  @$pb.TagNumber(11)
  void clearSoilType() => $_clearField(11);

  @$pb.TagNumber(12)
  IrrigationType get irrigationType => $_getN(11);
  @$pb.TagNumber(12)
  set irrigationType(IrrigationType value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasIrrigationType() => $_has(11);
  @$pb.TagNumber(12)
  void clearIrrigationType() => $_clearField(12);

  @$pb.TagNumber(13)
  FieldType get fieldType => $_getN(12);
  @$pb.TagNumber(13)
  set fieldType(FieldType value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasFieldType() => $_has(12);
  @$pb.TagNumber(13)
  void clearFieldType() => $_clearField(13);

  @$pb.TagNumber(14)
  FieldStatus get status => $_getN(13);
  @$pb.TagNumber(14)
  set status(FieldStatus value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasStatus() => $_has(13);
  @$pb.TagNumber(14)
  void clearStatus() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get elevationMeters => $_getN(14);
  @$pb.TagNumber(15)
  set elevationMeters($core.double value) => $_setDouble(14, value);
  @$pb.TagNumber(15)
  $core.bool hasElevationMeters() => $_has(14);
  @$pb.TagNumber(15)
  void clearElevationMeters() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.double get slopeDegrees => $_getN(15);
  @$pb.TagNumber(16)
  set slopeDegrees($core.double value) => $_setDouble(15, value);
  @$pb.TagNumber(16)
  $core.bool hasSlopeDegrees() => $_has(15);
  @$pb.TagNumber(16)
  void clearSlopeDegrees() => $_clearField(16);

  @$pb.TagNumber(17)
  AspectDirection get aspectDirection => $_getN(16);
  @$pb.TagNumber(17)
  set aspectDirection(AspectDirection value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasAspectDirection() => $_has(16);
  @$pb.TagNumber(17)
  void clearAspectDirection() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get createdBy => $_getSZ(17);
  @$pb.TagNumber(18)
  set createdBy($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasCreatedBy() => $_has(17);
  @$pb.TagNumber(18)
  void clearCreatedBy() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get updatedBy => $_getSZ(18);
  @$pb.TagNumber(19)
  set updatedBy($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasUpdatedBy() => $_has(18);
  @$pb.TagNumber(19)
  void clearUpdatedBy() => $_clearField(19);

  @$pb.TagNumber(20)
  $0.Timestamp get createdAt => $_getN(19);
  @$pb.TagNumber(20)
  set createdAt($0.Timestamp value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasCreatedAt() => $_has(19);
  @$pb.TagNumber(20)
  void clearCreatedAt() => $_clearField(20);
  @$pb.TagNumber(20)
  $0.Timestamp ensureCreatedAt() => $_ensure(19);

  @$pb.TagNumber(21)
  $0.Timestamp get updatedAt => $_getN(20);
  @$pb.TagNumber(21)
  set updatedAt($0.Timestamp value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasUpdatedAt() => $_has(20);
  @$pb.TagNumber(21)
  void clearUpdatedAt() => $_clearField(21);
  @$pb.TagNumber(21)
  $0.Timestamp ensureUpdatedAt() => $_ensure(20);

  @$pb.TagNumber(22)
  $fixnum.Int64 get version => $_getI64(21);
  @$pb.TagNumber(22)
  set version($fixnum.Int64 value) => $_setInt64(21, value);
  @$pb.TagNumber(22)
  $core.bool hasVersion() => $_has(21);
  @$pb.TagNumber(22)
  void clearVersion() => $_clearField(22);
}

class FieldBoundary extends $pb.GeneratedMessage {
  factory FieldBoundary({
    $core.String? id,
    $core.String? fieldId,
    GeoPolygon? polygon,
    $core.double? areaHectares,
    $core.double? perimeterMeters,
    $core.String? source,
    $0.Timestamp? recordedAt,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fieldId != null) result.fieldId = fieldId;
    if (polygon != null) result.polygon = polygon;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (perimeterMeters != null) result.perimeterMeters = perimeterMeters;
    if (source != null) result.source = source;
    if (recordedAt != null) result.recordedAt = recordedAt;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  FieldBoundary._();

  factory FieldBoundary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FieldBoundary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldBoundary',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOM<GeoPolygon>(3, _omitFieldNames ? '' : 'polygon',
        subBuilder: GeoPolygon.create)
    ..aD(4, _omitFieldNames ? '' : 'areaHectares')
    ..aD(5, _omitFieldNames ? '' : 'perimeterMeters')
    ..aOS(6, _omitFieldNames ? '' : 'source')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'recordedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldBoundary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldBoundary copyWith(void Function(FieldBoundary) updates) =>
      super.copyWith((message) => updates(message as FieldBoundary))
          as FieldBoundary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FieldBoundary create() => FieldBoundary._();
  @$core.override
  FieldBoundary createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FieldBoundary getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldBoundary>(create);
  static FieldBoundary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  GeoPolygon get polygon => $_getN(2);
  @$pb.TagNumber(3)
  set polygon(GeoPolygon value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasPolygon() => $_has(2);
  @$pb.TagNumber(3)
  void clearPolygon() => $_clearField(3);
  @$pb.TagNumber(3)
  GeoPolygon ensurePolygon() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.double get areaHectares => $_getN(3);
  @$pb.TagNumber(4)
  set areaHectares($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAreaHectares() => $_has(3);
  @$pb.TagNumber(4)
  void clearAreaHectares() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get perimeterMeters => $_getN(4);
  @$pb.TagNumber(5)
  set perimeterMeters($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPerimeterMeters() => $_has(4);
  @$pb.TagNumber(5)
  void clearPerimeterMeters() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get source => $_getSZ(5);
  @$pb.TagNumber(6)
  set source($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSource() => $_has(5);
  @$pb.TagNumber(6)
  void clearSource() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get recordedAt => $_getN(6);
  @$pb.TagNumber(7)
  set recordedAt($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasRecordedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearRecordedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureRecordedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get createdAt => $_getN(7);
  @$pb.TagNumber(8)
  set createdAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureCreatedAt() => $_ensure(7);
}

class FieldCropAssignment extends $pb.GeneratedMessage {
  factory FieldCropAssignment({
    $core.String? id,
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? cropVariety,
    $0.Timestamp? plantingDate,
    $0.Timestamp? expectedHarvestDate,
    $0.Timestamp? actualHarvestDate,
    GrowthStage? growthStage,
    $core.double? yieldPerHectare,
    $core.String? notes,
    $core.String? season,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (cropVariety != null) result.cropVariety = cropVariety;
    if (plantingDate != null) result.plantingDate = plantingDate;
    if (expectedHarvestDate != null)
      result.expectedHarvestDate = expectedHarvestDate;
    if (actualHarvestDate != null) result.actualHarvestDate = actualHarvestDate;
    if (growthStage != null) result.growthStage = growthStage;
    if (yieldPerHectare != null) result.yieldPerHectare = yieldPerHectare;
    if (notes != null) result.notes = notes;
    if (season != null) result.season = season;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  FieldCropAssignment._();

  factory FieldCropAssignment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FieldCropAssignment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldCropAssignment',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'cropId')
    ..aOS(4, _omitFieldNames ? '' : 'cropVariety')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'plantingDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'expectedHarvestDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'actualHarvestDate',
        subBuilder: $0.Timestamp.create)
    ..aE<GrowthStage>(8, _omitFieldNames ? '' : 'growthStage',
        enumValues: GrowthStage.values)
    ..aD(9, _omitFieldNames ? '' : 'yieldPerHectare')
    ..aOS(10, _omitFieldNames ? '' : 'notes')
    ..aOS(11, _omitFieldNames ? '' : 'season')
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldCropAssignment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldCropAssignment copyWith(void Function(FieldCropAssignment) updates) =>
      super.copyWith((message) => updates(message as FieldCropAssignment))
          as FieldCropAssignment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FieldCropAssignment create() => FieldCropAssignment._();
  @$core.override
  FieldCropAssignment createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FieldCropAssignment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldCropAssignment>(create);
  static FieldCropAssignment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get cropId => $_getSZ(2);
  @$pb.TagNumber(3)
  set cropId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCropId() => $_has(2);
  @$pb.TagNumber(3)
  void clearCropId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get cropVariety => $_getSZ(3);
  @$pb.TagNumber(4)
  set cropVariety($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCropVariety() => $_has(3);
  @$pb.TagNumber(4)
  void clearCropVariety() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get plantingDate => $_getN(4);
  @$pb.TagNumber(5)
  set plantingDate($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPlantingDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearPlantingDate() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensurePlantingDate() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.Timestamp get expectedHarvestDate => $_getN(5);
  @$pb.TagNumber(6)
  set expectedHarvestDate($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasExpectedHarvestDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpectedHarvestDate() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureExpectedHarvestDate() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Timestamp get actualHarvestDate => $_getN(6);
  @$pb.TagNumber(7)
  set actualHarvestDate($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasActualHarvestDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearActualHarvestDate() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureActualHarvestDate() => $_ensure(6);

  @$pb.TagNumber(8)
  GrowthStage get growthStage => $_getN(7);
  @$pb.TagNumber(8)
  set growthStage(GrowthStage value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasGrowthStage() => $_has(7);
  @$pb.TagNumber(8)
  void clearGrowthStage() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get yieldPerHectare => $_getN(8);
  @$pb.TagNumber(9)
  set yieldPerHectare($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasYieldPerHectare() => $_has(8);
  @$pb.TagNumber(9)
  void clearYieldPerHectare() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get notes => $_getSZ(9);
  @$pb.TagNumber(10)
  set notes($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNotes() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotes() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get season => $_getSZ(10);
  @$pb.TagNumber(11)
  set season($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSeason() => $_has(10);
  @$pb.TagNumber(11)
  void clearSeason() => $_clearField(11);

  @$pb.TagNumber(12)
  $0.Timestamp get createdAt => $_getN(11);
  @$pb.TagNumber(12)
  set createdAt($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasCreatedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearCreatedAt() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureCreatedAt() => $_ensure(11);

  @$pb.TagNumber(13)
  $0.Timestamp get updatedAt => $_getN(12);
  @$pb.TagNumber(13)
  set updatedAt($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasUpdatedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearUpdatedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureUpdatedAt() => $_ensure(12);
}

class FieldSegment extends $pb.GeneratedMessage {
  factory FieldSegment({
    $core.String? id,
    $core.String? fieldId,
    $core.String? name,
    GeoPolygon? boundary,
    $core.double? areaHectares,
    SoilType? soilType,
    $core.String? currentCropId,
    $core.String? notes,
    $core.int? segmentIndex,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fieldId != null) result.fieldId = fieldId;
    if (name != null) result.name = name;
    if (boundary != null) result.boundary = boundary;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (soilType != null) result.soilType = soilType;
    if (currentCropId != null) result.currentCropId = currentCropId;
    if (notes != null) result.notes = notes;
    if (segmentIndex != null) result.segmentIndex = segmentIndex;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  FieldSegment._();

  factory FieldSegment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FieldSegment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldSegment',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOM<GeoPolygon>(4, _omitFieldNames ? '' : 'boundary',
        subBuilder: GeoPolygon.create)
    ..aD(5, _omitFieldNames ? '' : 'areaHectares')
    ..aE<SoilType>(6, _omitFieldNames ? '' : 'soilType',
        enumValues: SoilType.values)
    ..aOS(7, _omitFieldNames ? '' : 'currentCropId')
    ..aOS(8, _omitFieldNames ? '' : 'notes')
    ..aI(9, _omitFieldNames ? '' : 'segmentIndex')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldSegment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldSegment copyWith(void Function(FieldSegment) updates) =>
      super.copyWith((message) => updates(message as FieldSegment))
          as FieldSegment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FieldSegment create() => FieldSegment._();
  @$core.override
  FieldSegment createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FieldSegment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldSegment>(create);
  static FieldSegment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  GeoPolygon get boundary => $_getN(3);
  @$pb.TagNumber(4)
  set boundary(GeoPolygon value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasBoundary() => $_has(3);
  @$pb.TagNumber(4)
  void clearBoundary() => $_clearField(4);
  @$pb.TagNumber(4)
  GeoPolygon ensureBoundary() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.double get areaHectares => $_getN(4);
  @$pb.TagNumber(5)
  set areaHectares($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAreaHectares() => $_has(4);
  @$pb.TagNumber(5)
  void clearAreaHectares() => $_clearField(5);

  @$pb.TagNumber(6)
  SoilType get soilType => $_getN(5);
  @$pb.TagNumber(6)
  set soilType(SoilType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSoilType() => $_has(5);
  @$pb.TagNumber(6)
  void clearSoilType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get currentCropId => $_getSZ(6);
  @$pb.TagNumber(7)
  set currentCropId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCurrentCropId() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrentCropId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get notes => $_getSZ(7);
  @$pb.TagNumber(8)
  set notes($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNotes() => $_has(7);
  @$pb.TagNumber(8)
  void clearNotes() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get segmentIndex => $_getIZ(8);
  @$pb.TagNumber(9)
  set segmentIndex($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSegmentIndex() => $_has(8);
  @$pb.TagNumber(9)
  void clearSegmentIndex() => $_clearField(9);

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

  @$pb.TagNumber(11)
  $0.Timestamp get updatedAt => $_getN(10);
  @$pb.TagNumber(11)
  set updatedAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasUpdatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearUpdatedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureUpdatedAt() => $_ensure(10);
}

class CreateFieldRequest extends $pb.GeneratedMessage {
  factory CreateFieldRequest({
    $core.String? farmId,
    $core.String? name,
    $core.double? areaHectares,
    GeoPolygon? boundary,
    FieldType? fieldType,
    SoilType? soilType,
    IrrigationType? irrigationType,
    $core.double? elevationMeters,
    $core.double? slopeDegrees,
    AspectDirection? aspectDirection,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (name != null) result.name = name;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (boundary != null) result.boundary = boundary;
    if (fieldType != null) result.fieldType = fieldType;
    if (soilType != null) result.soilType = soilType;
    if (irrigationType != null) result.irrigationType = irrigationType;
    if (elevationMeters != null) result.elevationMeters = elevationMeters;
    if (slopeDegrees != null) result.slopeDegrees = slopeDegrees;
    if (aspectDirection != null) result.aspectDirection = aspectDirection;
    return result;
  }

  CreateFieldRequest._();

  factory CreateFieldRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateFieldRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateFieldRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aD(3, _omitFieldNames ? '' : 'areaHectares')
    ..aOM<GeoPolygon>(4, _omitFieldNames ? '' : 'boundary',
        subBuilder: GeoPolygon.create)
    ..aE<FieldType>(5, _omitFieldNames ? '' : 'fieldType',
        enumValues: FieldType.values)
    ..aE<SoilType>(6, _omitFieldNames ? '' : 'soilType',
        enumValues: SoilType.values)
    ..aE<IrrigationType>(7, _omitFieldNames ? '' : 'irrigationType',
        enumValues: IrrigationType.values)
    ..aD(8, _omitFieldNames ? '' : 'elevationMeters')
    ..aD(9, _omitFieldNames ? '' : 'slopeDegrees')
    ..aE<AspectDirection>(10, _omitFieldNames ? '' : 'aspectDirection',
        enumValues: AspectDirection.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFieldRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFieldRequest copyWith(void Function(CreateFieldRequest) updates) =>
      super.copyWith((message) => updates(message as CreateFieldRequest))
          as CreateFieldRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateFieldRequest create() => CreateFieldRequest._();
  @$core.override
  CreateFieldRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateFieldRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateFieldRequest>(create);
  static CreateFieldRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get areaHectares => $_getN(2);
  @$pb.TagNumber(3)
  set areaHectares($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAreaHectares() => $_has(2);
  @$pb.TagNumber(3)
  void clearAreaHectares() => $_clearField(3);

  @$pb.TagNumber(4)
  GeoPolygon get boundary => $_getN(3);
  @$pb.TagNumber(4)
  set boundary(GeoPolygon value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasBoundary() => $_has(3);
  @$pb.TagNumber(4)
  void clearBoundary() => $_clearField(4);
  @$pb.TagNumber(4)
  GeoPolygon ensureBoundary() => $_ensure(3);

  @$pb.TagNumber(5)
  FieldType get fieldType => $_getN(4);
  @$pb.TagNumber(5)
  set fieldType(FieldType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasFieldType() => $_has(4);
  @$pb.TagNumber(5)
  void clearFieldType() => $_clearField(5);

  @$pb.TagNumber(6)
  SoilType get soilType => $_getN(5);
  @$pb.TagNumber(6)
  set soilType(SoilType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSoilType() => $_has(5);
  @$pb.TagNumber(6)
  void clearSoilType() => $_clearField(6);

  @$pb.TagNumber(7)
  IrrigationType get irrigationType => $_getN(6);
  @$pb.TagNumber(7)
  set irrigationType(IrrigationType value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasIrrigationType() => $_has(6);
  @$pb.TagNumber(7)
  void clearIrrigationType() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get elevationMeters => $_getN(7);
  @$pb.TagNumber(8)
  set elevationMeters($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasElevationMeters() => $_has(7);
  @$pb.TagNumber(8)
  void clearElevationMeters() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get slopeDegrees => $_getN(8);
  @$pb.TagNumber(9)
  set slopeDegrees($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSlopeDegrees() => $_has(8);
  @$pb.TagNumber(9)
  void clearSlopeDegrees() => $_clearField(9);

  @$pb.TagNumber(10)
  AspectDirection get aspectDirection => $_getN(9);
  @$pb.TagNumber(10)
  set aspectDirection(AspectDirection value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasAspectDirection() => $_has(9);
  @$pb.TagNumber(10)
  void clearAspectDirection() => $_clearField(10);
}

class CreateFieldResponse extends $pb.GeneratedMessage {
  factory CreateFieldResponse({
    Field? field_1,
  }) {
    final result = create();
    if (field_1 != null) result.field_1 = field_1;
    return result;
  }

  CreateFieldResponse._();

  factory CreateFieldResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateFieldResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateFieldResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOM<Field>(1, _omitFieldNames ? '' : 'field', subBuilder: Field.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFieldResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFieldResponse copyWith(void Function(CreateFieldResponse) updates) =>
      super.copyWith((message) => updates(message as CreateFieldResponse))
          as CreateFieldResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateFieldResponse create() => CreateFieldResponse._();
  @$core.override
  CreateFieldResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateFieldResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateFieldResponse>(create);
  static CreateFieldResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Field get field_1 => $_getN(0);
  @$pb.TagNumber(1)
  set field_1(Field value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasField_1() => $_has(0);
  @$pb.TagNumber(1)
  void clearField_1() => $_clearField(1);
  @$pb.TagNumber(1)
  Field ensureField_1() => $_ensure(0);
}

class GetFieldRequest extends $pb.GeneratedMessage {
  factory GetFieldRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetFieldRequest._();

  factory GetFieldRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFieldRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFieldRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldRequest copyWith(void Function(GetFieldRequest) updates) =>
      super.copyWith((message) => updates(message as GetFieldRequest))
          as GetFieldRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFieldRequest create() => GetFieldRequest._();
  @$core.override
  GetFieldRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFieldRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFieldRequest>(create);
  static GetFieldRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetFieldResponse extends $pb.GeneratedMessage {
  factory GetFieldResponse({
    Field? field_1,
  }) {
    final result = create();
    if (field_1 != null) result.field_1 = field_1;
    return result;
  }

  GetFieldResponse._();

  factory GetFieldResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFieldResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFieldResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOM<Field>(1, _omitFieldNames ? '' : 'field', subBuilder: Field.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldResponse copyWith(void Function(GetFieldResponse) updates) =>
      super.copyWith((message) => updates(message as GetFieldResponse))
          as GetFieldResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFieldResponse create() => GetFieldResponse._();
  @$core.override
  GetFieldResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFieldResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFieldResponse>(create);
  static GetFieldResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Field get field_1 => $_getN(0);
  @$pb.TagNumber(1)
  set field_1(Field value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasField_1() => $_has(0);
  @$pb.TagNumber(1)
  void clearField_1() => $_clearField(1);
  @$pb.TagNumber(1)
  Field ensureField_1() => $_ensure(0);
}

class ListFieldsRequest extends $pb.GeneratedMessage {
  factory ListFieldsRequest({
    $core.int? pageSize,
    $core.int? pageOffset,
    $core.String? farmId,
    FieldStatus? status,
    FieldType? fieldType,
    $core.String? search,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    if (farmId != null) result.farmId = farmId;
    if (status != null) result.status = status;
    if (fieldType != null) result.fieldType = fieldType;
    if (search != null) result.search = search;
    return result;
  }

  ListFieldsRequest._();

  factory ListFieldsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListFieldsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFieldsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aI(2, _omitFieldNames ? '' : 'pageOffset')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aE<FieldStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: FieldStatus.values)
    ..aE<FieldType>(5, _omitFieldNames ? '' : 'fieldType',
        enumValues: FieldType.values)
    ..aOS(6, _omitFieldNames ? '' : 'search')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldsRequest copyWith(void Function(ListFieldsRequest) updates) =>
      super.copyWith((message) => updates(message as ListFieldsRequest))
          as ListFieldsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFieldsRequest create() => ListFieldsRequest._();
  @$core.override
  ListFieldsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListFieldsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFieldsRequest>(create);
  static ListFieldsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageOffset => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageOffset($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageOffset() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageOffset() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmId() => $_clearField(3);

  @$pb.TagNumber(4)
  FieldStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(FieldStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  FieldType get fieldType => $_getN(4);
  @$pb.TagNumber(5)
  set fieldType(FieldType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasFieldType() => $_has(4);
  @$pb.TagNumber(5)
  void clearFieldType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get search => $_getSZ(5);
  @$pb.TagNumber(6)
  set search($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSearch() => $_has(5);
  @$pb.TagNumber(6)
  void clearSearch() => $_clearField(6);
}

class ListFieldsResponse extends $pb.GeneratedMessage {
  factory ListFieldsResponse({
    $core.Iterable<Field>? fields,
    $core.int? totalCount,
  }) {
    final result = create();
    if (fields != null) result.fields.addAll(fields);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListFieldsResponse._();

  factory ListFieldsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListFieldsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFieldsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..pPM<Field>(1, _omitFieldNames ? '' : 'fields', subBuilder: Field.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldsResponse copyWith(void Function(ListFieldsResponse) updates) =>
      super.copyWith((message) => updates(message as ListFieldsResponse))
          as ListFieldsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFieldsResponse create() => ListFieldsResponse._();
  @$core.override
  ListFieldsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListFieldsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFieldsResponse>(create);
  static ListFieldsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Field> get fields => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class UpdateFieldRequest extends $pb.GeneratedMessage {
  factory UpdateFieldRequest({
    $core.String? id,
    $core.String? name,
    $core.double? areaHectares,
    FieldType? fieldType,
    SoilType? soilType,
    IrrigationType? irrigationType,
    FieldStatus? status,
    $core.double? elevationMeters,
    $core.double? slopeDegrees,
    AspectDirection? aspectDirection,
    GrowthStage? growthStage,
    $1.FieldMask? updateMask,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (fieldType != null) result.fieldType = fieldType;
    if (soilType != null) result.soilType = soilType;
    if (irrigationType != null) result.irrigationType = irrigationType;
    if (status != null) result.status = status;
    if (elevationMeters != null) result.elevationMeters = elevationMeters;
    if (slopeDegrees != null) result.slopeDegrees = slopeDegrees;
    if (aspectDirection != null) result.aspectDirection = aspectDirection;
    if (growthStage != null) result.growthStage = growthStage;
    if (updateMask != null) result.updateMask = updateMask;
    return result;
  }

  UpdateFieldRequest._();

  factory UpdateFieldRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateFieldRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateFieldRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aD(3, _omitFieldNames ? '' : 'areaHectares')
    ..aE<FieldType>(4, _omitFieldNames ? '' : 'fieldType',
        enumValues: FieldType.values)
    ..aE<SoilType>(5, _omitFieldNames ? '' : 'soilType',
        enumValues: SoilType.values)
    ..aE<IrrigationType>(6, _omitFieldNames ? '' : 'irrigationType',
        enumValues: IrrigationType.values)
    ..aE<FieldStatus>(7, _omitFieldNames ? '' : 'status',
        enumValues: FieldStatus.values)
    ..aD(8, _omitFieldNames ? '' : 'elevationMeters')
    ..aD(9, _omitFieldNames ? '' : 'slopeDegrees')
    ..aE<AspectDirection>(10, _omitFieldNames ? '' : 'aspectDirection',
        enumValues: AspectDirection.values)
    ..aE<GrowthStage>(11, _omitFieldNames ? '' : 'growthStage',
        enumValues: GrowthStage.values)
    ..aOM<$1.FieldMask>(12, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $1.FieldMask.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFieldRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFieldRequest copyWith(void Function(UpdateFieldRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateFieldRequest))
          as UpdateFieldRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateFieldRequest create() => UpdateFieldRequest._();
  @$core.override
  UpdateFieldRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateFieldRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateFieldRequest>(create);
  static UpdateFieldRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get areaHectares => $_getN(2);
  @$pb.TagNumber(3)
  set areaHectares($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAreaHectares() => $_has(2);
  @$pb.TagNumber(3)
  void clearAreaHectares() => $_clearField(3);

  @$pb.TagNumber(4)
  FieldType get fieldType => $_getN(3);
  @$pb.TagNumber(4)
  set fieldType(FieldType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldType() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldType() => $_clearField(4);

  @$pb.TagNumber(5)
  SoilType get soilType => $_getN(4);
  @$pb.TagNumber(5)
  set soilType(SoilType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSoilType() => $_has(4);
  @$pb.TagNumber(5)
  void clearSoilType() => $_clearField(5);

  @$pb.TagNumber(6)
  IrrigationType get irrigationType => $_getN(5);
  @$pb.TagNumber(6)
  set irrigationType(IrrigationType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasIrrigationType() => $_has(5);
  @$pb.TagNumber(6)
  void clearIrrigationType() => $_clearField(6);

  @$pb.TagNumber(7)
  FieldStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status(FieldStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get elevationMeters => $_getN(7);
  @$pb.TagNumber(8)
  set elevationMeters($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasElevationMeters() => $_has(7);
  @$pb.TagNumber(8)
  void clearElevationMeters() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get slopeDegrees => $_getN(8);
  @$pb.TagNumber(9)
  set slopeDegrees($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSlopeDegrees() => $_has(8);
  @$pb.TagNumber(9)
  void clearSlopeDegrees() => $_clearField(9);

  @$pb.TagNumber(10)
  AspectDirection get aspectDirection => $_getN(9);
  @$pb.TagNumber(10)
  set aspectDirection(AspectDirection value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasAspectDirection() => $_has(9);
  @$pb.TagNumber(10)
  void clearAspectDirection() => $_clearField(10);

  @$pb.TagNumber(11)
  GrowthStage get growthStage => $_getN(10);
  @$pb.TagNumber(11)
  set growthStage(GrowthStage value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasGrowthStage() => $_has(10);
  @$pb.TagNumber(11)
  void clearGrowthStage() => $_clearField(11);

  @$pb.TagNumber(12)
  $1.FieldMask get updateMask => $_getN(11);
  @$pb.TagNumber(12)
  set updateMask($1.FieldMask value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasUpdateMask() => $_has(11);
  @$pb.TagNumber(12)
  void clearUpdateMask() => $_clearField(12);
  @$pb.TagNumber(12)
  $1.FieldMask ensureUpdateMask() => $_ensure(11);
}

class UpdateFieldResponse extends $pb.GeneratedMessage {
  factory UpdateFieldResponse({
    Field? field_1,
  }) {
    final result = create();
    if (field_1 != null) result.field_1 = field_1;
    return result;
  }

  UpdateFieldResponse._();

  factory UpdateFieldResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateFieldResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateFieldResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOM<Field>(1, _omitFieldNames ? '' : 'field', subBuilder: Field.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFieldResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFieldResponse copyWith(void Function(UpdateFieldResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateFieldResponse))
          as UpdateFieldResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateFieldResponse create() => UpdateFieldResponse._();
  @$core.override
  UpdateFieldResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateFieldResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateFieldResponse>(create);
  static UpdateFieldResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Field get field_1 => $_getN(0);
  @$pb.TagNumber(1)
  set field_1(Field value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasField_1() => $_has(0);
  @$pb.TagNumber(1)
  void clearField_1() => $_clearField(1);
  @$pb.TagNumber(1)
  Field ensureField_1() => $_ensure(0);
}

class DeleteFieldRequest extends $pb.GeneratedMessage {
  factory DeleteFieldRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteFieldRequest._();

  factory DeleteFieldRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteFieldRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteFieldRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFieldRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFieldRequest copyWith(void Function(DeleteFieldRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteFieldRequest))
          as DeleteFieldRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFieldRequest create() => DeleteFieldRequest._();
  @$core.override
  DeleteFieldRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteFieldRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteFieldRequest>(create);
  static DeleteFieldRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteFieldResponse extends $pb.GeneratedMessage {
  factory DeleteFieldResponse() => create();

  DeleteFieldResponse._();

  factory DeleteFieldResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteFieldResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteFieldResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFieldResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFieldResponse copyWith(void Function(DeleteFieldResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteFieldResponse))
          as DeleteFieldResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFieldResponse create() => DeleteFieldResponse._();
  @$core.override
  DeleteFieldResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteFieldResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteFieldResponse>(create);
  static DeleteFieldResponse? _defaultInstance;
}

class SetFieldBoundaryRequest extends $pb.GeneratedMessage {
  factory SetFieldBoundaryRequest({
    $core.String? fieldId,
    GeoPolygon? polygon,
    $core.String? source,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (polygon != null) result.polygon = polygon;
    if (source != null) result.source = source;
    return result;
  }

  SetFieldBoundaryRequest._();

  factory SetFieldBoundaryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFieldBoundaryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFieldBoundaryRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOM<GeoPolygon>(2, _omitFieldNames ? '' : 'polygon',
        subBuilder: GeoPolygon.create)
    ..aOS(3, _omitFieldNames ? '' : 'source')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFieldBoundaryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFieldBoundaryRequest copyWith(
          void Function(SetFieldBoundaryRequest) updates) =>
      super.copyWith((message) => updates(message as SetFieldBoundaryRequest))
          as SetFieldBoundaryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFieldBoundaryRequest create() => SetFieldBoundaryRequest._();
  @$core.override
  SetFieldBoundaryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetFieldBoundaryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFieldBoundaryRequest>(create);
  static SetFieldBoundaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  GeoPolygon get polygon => $_getN(1);
  @$pb.TagNumber(2)
  set polygon(GeoPolygon value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPolygon() => $_has(1);
  @$pb.TagNumber(2)
  void clearPolygon() => $_clearField(2);
  @$pb.TagNumber(2)
  GeoPolygon ensurePolygon() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get source => $_getSZ(2);
  @$pb.TagNumber(3)
  set source($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSource() => $_has(2);
  @$pb.TagNumber(3)
  void clearSource() => $_clearField(3);
}

class SetFieldBoundaryResponse extends $pb.GeneratedMessage {
  factory SetFieldBoundaryResponse({
    FieldBoundary? boundary,
  }) {
    final result = create();
    if (boundary != null) result.boundary = boundary;
    return result;
  }

  SetFieldBoundaryResponse._();

  factory SetFieldBoundaryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFieldBoundaryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFieldBoundaryResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOM<FieldBoundary>(1, _omitFieldNames ? '' : 'boundary',
        subBuilder: FieldBoundary.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFieldBoundaryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFieldBoundaryResponse copyWith(
          void Function(SetFieldBoundaryResponse) updates) =>
      super.copyWith((message) => updates(message as SetFieldBoundaryResponse))
          as SetFieldBoundaryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFieldBoundaryResponse create() => SetFieldBoundaryResponse._();
  @$core.override
  SetFieldBoundaryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetFieldBoundaryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFieldBoundaryResponse>(create);
  static SetFieldBoundaryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FieldBoundary get boundary => $_getN(0);
  @$pb.TagNumber(1)
  set boundary(FieldBoundary value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBoundary() => $_has(0);
  @$pb.TagNumber(1)
  void clearBoundary() => $_clearField(1);
  @$pb.TagNumber(1)
  FieldBoundary ensureBoundary() => $_ensure(0);
}

class AssignCropRequest extends $pb.GeneratedMessage {
  factory AssignCropRequest({
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? cropVariety,
    $0.Timestamp? plantingDate,
    $0.Timestamp? expectedHarvestDate,
    $core.String? season,
    $core.String? notes,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (cropVariety != null) result.cropVariety = cropVariety;
    if (plantingDate != null) result.plantingDate = plantingDate;
    if (expectedHarvestDate != null)
      result.expectedHarvestDate = expectedHarvestDate;
    if (season != null) result.season = season;
    if (notes != null) result.notes = notes;
    return result;
  }

  AssignCropRequest._();

  factory AssignCropRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AssignCropRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AssignCropRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'cropId')
    ..aOS(3, _omitFieldNames ? '' : 'cropVariety')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'plantingDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'expectedHarvestDate',
        subBuilder: $0.Timestamp.create)
    ..aOS(6, _omitFieldNames ? '' : 'season')
    ..aOS(7, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssignCropRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssignCropRequest copyWith(void Function(AssignCropRequest) updates) =>
      super.copyWith((message) => updates(message as AssignCropRequest))
          as AssignCropRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AssignCropRequest create() => AssignCropRequest._();
  @$core.override
  AssignCropRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AssignCropRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AssignCropRequest>(create);
  static AssignCropRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cropId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get cropVariety => $_getSZ(2);
  @$pb.TagNumber(3)
  set cropVariety($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCropVariety() => $_has(2);
  @$pb.TagNumber(3)
  void clearCropVariety() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get plantingDate => $_getN(3);
  @$pb.TagNumber(4)
  set plantingDate($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPlantingDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearPlantingDate() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensurePlantingDate() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Timestamp get expectedHarvestDate => $_getN(4);
  @$pb.TagNumber(5)
  set expectedHarvestDate($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasExpectedHarvestDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpectedHarvestDate() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureExpectedHarvestDate() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get season => $_getSZ(5);
  @$pb.TagNumber(6)
  set season($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSeason() => $_has(5);
  @$pb.TagNumber(6)
  void clearSeason() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get notes => $_getSZ(6);
  @$pb.TagNumber(7)
  set notes($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNotes() => $_has(6);
  @$pb.TagNumber(7)
  void clearNotes() => $_clearField(7);
}

class AssignCropResponse extends $pb.GeneratedMessage {
  factory AssignCropResponse({
    FieldCropAssignment? assignment,
  }) {
    final result = create();
    if (assignment != null) result.assignment = assignment;
    return result;
  }

  AssignCropResponse._();

  factory AssignCropResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AssignCropResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AssignCropResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOM<FieldCropAssignment>(1, _omitFieldNames ? '' : 'assignment',
        subBuilder: FieldCropAssignment.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssignCropResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssignCropResponse copyWith(void Function(AssignCropResponse) updates) =>
      super.copyWith((message) => updates(message as AssignCropResponse))
          as AssignCropResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AssignCropResponse create() => AssignCropResponse._();
  @$core.override
  AssignCropResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AssignCropResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AssignCropResponse>(create);
  static AssignCropResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FieldCropAssignment get assignment => $_getN(0);
  @$pb.TagNumber(1)
  set assignment(FieldCropAssignment value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAssignment() => $_has(0);
  @$pb.TagNumber(1)
  void clearAssignment() => $_clearField(1);
  @$pb.TagNumber(1)
  FieldCropAssignment ensureAssignment() => $_ensure(0);
}

class ListFieldsByFarmRequest extends $pb.GeneratedMessage {
  factory ListFieldsByFarmRequest({
    $core.String? farmId,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListFieldsByFarmRequest._();

  factory ListFieldsByFarmRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListFieldsByFarmRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFieldsByFarmRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aI(2, _omitFieldNames ? '' : 'pageSize')
    ..aI(3, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldsByFarmRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldsByFarmRequest copyWith(
          void Function(ListFieldsByFarmRequest) updates) =>
      super.copyWith((message) => updates(message as ListFieldsByFarmRequest))
          as ListFieldsByFarmRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFieldsByFarmRequest create() => ListFieldsByFarmRequest._();
  @$core.override
  ListFieldsByFarmRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListFieldsByFarmRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFieldsByFarmRequest>(create);
  static ListFieldsByFarmRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageOffset => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageOffset($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageOffset() => $_clearField(3);
}

class ListFieldsByFarmResponse extends $pb.GeneratedMessage {
  factory ListFieldsByFarmResponse({
    $core.Iterable<Field>? fields,
    $core.int? totalCount,
  }) {
    final result = create();
    if (fields != null) result.fields.addAll(fields);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListFieldsByFarmResponse._();

  factory ListFieldsByFarmResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListFieldsByFarmResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFieldsByFarmResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..pPM<Field>(1, _omitFieldNames ? '' : 'fields', subBuilder: Field.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldsByFarmResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldsByFarmResponse copyWith(
          void Function(ListFieldsByFarmResponse) updates) =>
      super.copyWith((message) => updates(message as ListFieldsByFarmResponse))
          as ListFieldsByFarmResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFieldsByFarmResponse create() => ListFieldsByFarmResponse._();
  @$core.override
  ListFieldsByFarmResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListFieldsByFarmResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFieldsByFarmResponse>(create);
  static ListFieldsByFarmResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Field> get fields => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class SegmentFieldRequest extends $pb.GeneratedMessage {
  factory SegmentFieldRequest({
    $core.String? fieldId,
    $core.Iterable<FieldSegmentInput>? segments,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (segments != null) result.segments.addAll(segments);
    return result;
  }

  SegmentFieldRequest._();

  factory SegmentFieldRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SegmentFieldRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SegmentFieldRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..pPM<FieldSegmentInput>(2, _omitFieldNames ? '' : 'segments',
        subBuilder: FieldSegmentInput.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SegmentFieldRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SegmentFieldRequest copyWith(void Function(SegmentFieldRequest) updates) =>
      super.copyWith((message) => updates(message as SegmentFieldRequest))
          as SegmentFieldRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SegmentFieldRequest create() => SegmentFieldRequest._();
  @$core.override
  SegmentFieldRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SegmentFieldRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SegmentFieldRequest>(create);
  static SegmentFieldRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<FieldSegmentInput> get segments => $_getList(1);
}

class FieldSegmentInput extends $pb.GeneratedMessage {
  factory FieldSegmentInput({
    $core.String? name,
    GeoPolygon? boundary,
    $core.double? areaHectares,
    SoilType? soilType,
    $core.String? notes,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (boundary != null) result.boundary = boundary;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (soilType != null) result.soilType = soilType;
    if (notes != null) result.notes = notes;
    return result;
  }

  FieldSegmentInput._();

  factory FieldSegmentInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FieldSegmentInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldSegmentInput',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOM<GeoPolygon>(2, _omitFieldNames ? '' : 'boundary',
        subBuilder: GeoPolygon.create)
    ..aD(3, _omitFieldNames ? '' : 'areaHectares')
    ..aE<SoilType>(4, _omitFieldNames ? '' : 'soilType',
        enumValues: SoilType.values)
    ..aOS(5, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldSegmentInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldSegmentInput copyWith(void Function(FieldSegmentInput) updates) =>
      super.copyWith((message) => updates(message as FieldSegmentInput))
          as FieldSegmentInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FieldSegmentInput create() => FieldSegmentInput._();
  @$core.override
  FieldSegmentInput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FieldSegmentInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldSegmentInput>(create);
  static FieldSegmentInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  GeoPolygon get boundary => $_getN(1);
  @$pb.TagNumber(2)
  set boundary(GeoPolygon value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBoundary() => $_has(1);
  @$pb.TagNumber(2)
  void clearBoundary() => $_clearField(2);
  @$pb.TagNumber(2)
  GeoPolygon ensureBoundary() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.double get areaHectares => $_getN(2);
  @$pb.TagNumber(3)
  set areaHectares($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAreaHectares() => $_has(2);
  @$pb.TagNumber(3)
  void clearAreaHectares() => $_clearField(3);

  @$pb.TagNumber(4)
  SoilType get soilType => $_getN(3);
  @$pb.TagNumber(4)
  set soilType(SoilType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSoilType() => $_has(3);
  @$pb.TagNumber(4)
  void clearSoilType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get notes => $_getSZ(4);
  @$pb.TagNumber(5)
  set notes($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNotes() => $_has(4);
  @$pb.TagNumber(5)
  void clearNotes() => $_clearField(5);
}

class SegmentFieldResponse extends $pb.GeneratedMessage {
  factory SegmentFieldResponse({
    $core.Iterable<FieldSegment>? segments,
  }) {
    final result = create();
    if (segments != null) result.segments.addAll(segments);
    return result;
  }

  SegmentFieldResponse._();

  factory SegmentFieldResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SegmentFieldResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SegmentFieldResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..pPM<FieldSegment>(1, _omitFieldNames ? '' : 'segments',
        subBuilder: FieldSegment.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SegmentFieldResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SegmentFieldResponse copyWith(void Function(SegmentFieldResponse) updates) =>
      super.copyWith((message) => updates(message as SegmentFieldResponse))
          as SegmentFieldResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SegmentFieldResponse create() => SegmentFieldResponse._();
  @$core.override
  SegmentFieldResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SegmentFieldResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SegmentFieldResponse>(create);
  static SegmentFieldResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FieldSegment> get segments => $_getList(0);
}

class GetFieldSegmentsRequest extends $pb.GeneratedMessage {
  factory GetFieldSegmentsRequest({
    $core.String? fieldId,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    return result;
  }

  GetFieldSegmentsRequest._();

  factory GetFieldSegmentsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFieldSegmentsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFieldSegmentsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldSegmentsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldSegmentsRequest copyWith(
          void Function(GetFieldSegmentsRequest) updates) =>
      super.copyWith((message) => updates(message as GetFieldSegmentsRequest))
          as GetFieldSegmentsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFieldSegmentsRequest create() => GetFieldSegmentsRequest._();
  @$core.override
  GetFieldSegmentsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFieldSegmentsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFieldSegmentsRequest>(create);
  static GetFieldSegmentsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);
}

class GetFieldSegmentsResponse extends $pb.GeneratedMessage {
  factory GetFieldSegmentsResponse({
    $core.Iterable<FieldSegment>? segments,
  }) {
    final result = create();
    if (segments != null) result.segments.addAll(segments);
    return result;
  }

  GetFieldSegmentsResponse._();

  factory GetFieldSegmentsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFieldSegmentsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFieldSegmentsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..pPM<FieldSegment>(1, _omitFieldNames ? '' : 'segments',
        subBuilder: FieldSegment.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldSegmentsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldSegmentsResponse copyWith(
          void Function(GetFieldSegmentsResponse) updates) =>
      super.copyWith((message) => updates(message as GetFieldSegmentsResponse))
          as GetFieldSegmentsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFieldSegmentsResponse create() => GetFieldSegmentsResponse._();
  @$core.override
  GetFieldSegmentsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFieldSegmentsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFieldSegmentsResponse>(create);
  static GetFieldSegmentsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FieldSegment> get segments => $_getList(0);
}

class GetCropHistoryRequest extends $pb.GeneratedMessage {
  factory GetCropHistoryRequest({
    $core.String? fieldId,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  GetCropHistoryRequest._();

  factory GetCropHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCropHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCropHistoryRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aI(2, _omitFieldNames ? '' : 'pageSize')
    ..aI(3, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropHistoryRequest copyWith(
          void Function(GetCropHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as GetCropHistoryRequest))
          as GetCropHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCropHistoryRequest create() => GetCropHistoryRequest._();
  @$core.override
  GetCropHistoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCropHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCropHistoryRequest>(create);
  static GetCropHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageOffset => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageOffset($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageOffset() => $_clearField(3);
}

class GetCropHistoryResponse extends $pb.GeneratedMessage {
  factory GetCropHistoryResponse({
    $core.Iterable<FieldCropAssignment>? assignments,
    $core.int? totalCount,
  }) {
    final result = create();
    if (assignments != null) result.assignments.addAll(assignments);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  GetCropHistoryResponse._();

  factory GetCropHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCropHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCropHistoryResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..pPM<FieldCropAssignment>(1, _omitFieldNames ? '' : 'assignments',
        subBuilder: FieldCropAssignment.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropHistoryResponse copyWith(
          void Function(GetCropHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as GetCropHistoryResponse))
          as GetCropHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCropHistoryResponse create() => GetCropHistoryResponse._();
  @$core.override
  GetCropHistoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCropHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCropHistoryResponse>(create);
  static GetCropHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FieldCropAssignment> get assignments => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class CropCycle extends $pb.GeneratedMessage {
  factory CropCycle({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? cropAssignmentId,
    $core.String? season,
    $core.int? cycleYear,
    $core.String? name,
    $0.Timestamp? plannedPlantingDate,
    $0.Timestamp? actualPlantingDate,
    $0.Timestamp? plannedHarvestDate,
    $0.Timestamp? actualHarvestDate,
    CropCycleStatus? status,
    $core.double? targetYieldPerHectare,
    $core.double? actualYieldPerHectare,
    $core.String? yieldUnit,
    $fixnum.Int64? totalInputCost,
    $fixnum.Int64? totalRevenue,
    $core.String? currency,
    $core.String? notes,
    $fixnum.Int64? version,
    $core.String? createdBy,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $core.String? managementUnitId,
    $core.String? cropVariety,
    $core.String? seedSource,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (cropAssignmentId != null) result.cropAssignmentId = cropAssignmentId;
    if (season != null) result.season = season;
    if (cycleYear != null) result.cycleYear = cycleYear;
    if (name != null) result.name = name;
    if (plannedPlantingDate != null)
      result.plannedPlantingDate = plannedPlantingDate;
    if (actualPlantingDate != null)
      result.actualPlantingDate = actualPlantingDate;
    if (plannedHarvestDate != null)
      result.plannedHarvestDate = plannedHarvestDate;
    if (actualHarvestDate != null) result.actualHarvestDate = actualHarvestDate;
    if (status != null) result.status = status;
    if (targetYieldPerHectare != null)
      result.targetYieldPerHectare = targetYieldPerHectare;
    if (actualYieldPerHectare != null)
      result.actualYieldPerHectare = actualYieldPerHectare;
    if (yieldUnit != null) result.yieldUnit = yieldUnit;
    if (totalInputCost != null) result.totalInputCost = totalInputCost;
    if (totalRevenue != null) result.totalRevenue = totalRevenue;
    if (currency != null) result.currency = currency;
    if (notes != null) result.notes = notes;
    if (version != null) result.version = version;
    if (createdBy != null) result.createdBy = createdBy;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (managementUnitId != null) result.managementUnitId = managementUnitId;
    if (cropVariety != null) result.cropVariety = cropVariety;
    if (seedSource != null) result.seedSource = seedSource;
    return result;
  }

  CropCycle._();

  factory CropCycle.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CropCycle.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CropCycle',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'cropId')
    ..aOS(5, _omitFieldNames ? '' : 'cropAssignmentId')
    ..aOS(6, _omitFieldNames ? '' : 'season')
    ..aI(7, _omitFieldNames ? '' : 'cycleYear')
    ..aOS(8, _omitFieldNames ? '' : 'name')
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'plannedPlantingDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'actualPlantingDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'plannedHarvestDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'actualHarvestDate',
        subBuilder: $0.Timestamp.create)
    ..aE<CropCycleStatus>(13, _omitFieldNames ? '' : 'status',
        enumValues: CropCycleStatus.values)
    ..aD(14, _omitFieldNames ? '' : 'targetYieldPerHectare')
    ..aD(15, _omitFieldNames ? '' : 'actualYieldPerHectare')
    ..aOS(16, _omitFieldNames ? '' : 'yieldUnit')
    ..aInt64(17, _omitFieldNames ? '' : 'totalInputCost')
    ..aInt64(18, _omitFieldNames ? '' : 'totalRevenue')
    ..aOS(19, _omitFieldNames ? '' : 'currency')
    ..aOS(20, _omitFieldNames ? '' : 'notes')
    ..aInt64(21, _omitFieldNames ? '' : 'version')
    ..aOS(22, _omitFieldNames ? '' : 'createdBy')
    ..aOM<$0.Timestamp>(23, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(24, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aOS(25, _omitFieldNames ? '' : 'managementUnitId')
    ..aOS(26, _omitFieldNames ? '' : 'cropVariety')
    ..aOS(27, _omitFieldNames ? '' : 'seedSource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CropCycle clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CropCycle copyWith(void Function(CropCycle) updates) =>
      super.copyWith((message) => updates(message as CropCycle)) as CropCycle;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CropCycle create() => CropCycle._();
  @$core.override
  CropCycle createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CropCycle getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CropCycle>(create);
  static CropCycle? _defaultInstance;

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
  $core.String get cropId => $_getSZ(3);
  @$pb.TagNumber(4)
  set cropId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCropId() => $_has(3);
  @$pb.TagNumber(4)
  void clearCropId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cropAssignmentId => $_getSZ(4);
  @$pb.TagNumber(5)
  set cropAssignmentId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCropAssignmentId() => $_has(4);
  @$pb.TagNumber(5)
  void clearCropAssignmentId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get season => $_getSZ(5);
  @$pb.TagNumber(6)
  set season($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSeason() => $_has(5);
  @$pb.TagNumber(6)
  void clearSeason() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get cycleYear => $_getIZ(6);
  @$pb.TagNumber(7)
  set cycleYear($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCycleYear() => $_has(6);
  @$pb.TagNumber(7)
  void clearCycleYear() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get name => $_getSZ(7);
  @$pb.TagNumber(8)
  set name($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasName() => $_has(7);
  @$pb.TagNumber(8)
  void clearName() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get plannedPlantingDate => $_getN(8);
  @$pb.TagNumber(9)
  set plannedPlantingDate($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasPlannedPlantingDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearPlannedPlantingDate() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensurePlannedPlantingDate() => $_ensure(8);

  @$pb.TagNumber(10)
  $0.Timestamp get actualPlantingDate => $_getN(9);
  @$pb.TagNumber(10)
  set actualPlantingDate($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasActualPlantingDate() => $_has(9);
  @$pb.TagNumber(10)
  void clearActualPlantingDate() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureActualPlantingDate() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Timestamp get plannedHarvestDate => $_getN(10);
  @$pb.TagNumber(11)
  set plannedHarvestDate($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasPlannedHarvestDate() => $_has(10);
  @$pb.TagNumber(11)
  void clearPlannedHarvestDate() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensurePlannedHarvestDate() => $_ensure(10);

  @$pb.TagNumber(12)
  $0.Timestamp get actualHarvestDate => $_getN(11);
  @$pb.TagNumber(12)
  set actualHarvestDate($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasActualHarvestDate() => $_has(11);
  @$pb.TagNumber(12)
  void clearActualHarvestDate() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureActualHarvestDate() => $_ensure(11);

  @$pb.TagNumber(13)
  CropCycleStatus get status => $_getN(12);
  @$pb.TagNumber(13)
  set status(CropCycleStatus value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasStatus() => $_has(12);
  @$pb.TagNumber(13)
  void clearStatus() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get targetYieldPerHectare => $_getN(13);
  @$pb.TagNumber(14)
  set targetYieldPerHectare($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasTargetYieldPerHectare() => $_has(13);
  @$pb.TagNumber(14)
  void clearTargetYieldPerHectare() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get actualYieldPerHectare => $_getN(14);
  @$pb.TagNumber(15)
  set actualYieldPerHectare($core.double value) => $_setDouble(14, value);
  @$pb.TagNumber(15)
  $core.bool hasActualYieldPerHectare() => $_has(14);
  @$pb.TagNumber(15)
  void clearActualYieldPerHectare() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get yieldUnit => $_getSZ(15);
  @$pb.TagNumber(16)
  set yieldUnit($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasYieldUnit() => $_has(15);
  @$pb.TagNumber(16)
  void clearYieldUnit() => $_clearField(16);

  @$pb.TagNumber(17)
  $fixnum.Int64 get totalInputCost => $_getI64(16);
  @$pb.TagNumber(17)
  set totalInputCost($fixnum.Int64 value) => $_setInt64(16, value);
  @$pb.TagNumber(17)
  $core.bool hasTotalInputCost() => $_has(16);
  @$pb.TagNumber(17)
  void clearTotalInputCost() => $_clearField(17);

  @$pb.TagNumber(18)
  $fixnum.Int64 get totalRevenue => $_getI64(17);
  @$pb.TagNumber(18)
  set totalRevenue($fixnum.Int64 value) => $_setInt64(17, value);
  @$pb.TagNumber(18)
  $core.bool hasTotalRevenue() => $_has(17);
  @$pb.TagNumber(18)
  void clearTotalRevenue() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get currency => $_getSZ(18);
  @$pb.TagNumber(19)
  set currency($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasCurrency() => $_has(18);
  @$pb.TagNumber(19)
  void clearCurrency() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get notes => $_getSZ(19);
  @$pb.TagNumber(20)
  set notes($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasNotes() => $_has(19);
  @$pb.TagNumber(20)
  void clearNotes() => $_clearField(20);

  @$pb.TagNumber(21)
  $fixnum.Int64 get version => $_getI64(20);
  @$pb.TagNumber(21)
  set version($fixnum.Int64 value) => $_setInt64(20, value);
  @$pb.TagNumber(21)
  $core.bool hasVersion() => $_has(20);
  @$pb.TagNumber(21)
  void clearVersion() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.String get createdBy => $_getSZ(21);
  @$pb.TagNumber(22)
  set createdBy($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasCreatedBy() => $_has(21);
  @$pb.TagNumber(22)
  void clearCreatedBy() => $_clearField(22);

  @$pb.TagNumber(23)
  $0.Timestamp get createdAt => $_getN(22);
  @$pb.TagNumber(23)
  set createdAt($0.Timestamp value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasCreatedAt() => $_has(22);
  @$pb.TagNumber(23)
  void clearCreatedAt() => $_clearField(23);
  @$pb.TagNumber(23)
  $0.Timestamp ensureCreatedAt() => $_ensure(22);

  @$pb.TagNumber(24)
  $0.Timestamp get updatedAt => $_getN(23);
  @$pb.TagNumber(24)
  set updatedAt($0.Timestamp value) => $_setField(24, value);
  @$pb.TagNumber(24)
  $core.bool hasUpdatedAt() => $_has(23);
  @$pb.TagNumber(24)
  void clearUpdatedAt() => $_clearField(24);
  @$pb.TagNumber(24)
  $0.Timestamp ensureUpdatedAt() => $_ensure(23);

  @$pb.TagNumber(25)
  $core.String get managementUnitId => $_getSZ(24);
  @$pb.TagNumber(25)
  set managementUnitId($core.String value) => $_setString(24, value);
  @$pb.TagNumber(25)
  $core.bool hasManagementUnitId() => $_has(24);
  @$pb.TagNumber(25)
  void clearManagementUnitId() => $_clearField(25);

  @$pb.TagNumber(26)
  $core.String get cropVariety => $_getSZ(25);
  @$pb.TagNumber(26)
  set cropVariety($core.String value) => $_setString(25, value);
  @$pb.TagNumber(26)
  $core.bool hasCropVariety() => $_has(25);
  @$pb.TagNumber(26)
  void clearCropVariety() => $_clearField(26);

  @$pb.TagNumber(27)
  $core.String get seedSource => $_getSZ(26);
  @$pb.TagNumber(27)
  set seedSource($core.String value) => $_setString(26, value);
  @$pb.TagNumber(27)
  $core.bool hasSeedSource() => $_has(26);
  @$pb.TagNumber(27)
  void clearSeedSource() => $_clearField(27);
}

class CreateCropCycleRequest extends $pb.GeneratedMessage {
  factory CreateCropCycleRequest({
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? season,
    $core.int? cycleYear,
    $core.String? name,
    $0.Timestamp? plannedPlantingDate,
    $0.Timestamp? plannedHarvestDate,
    $core.double? targetYieldPerHectare,
    $core.String? yieldUnit,
    $core.String? notes,
    $core.String? managementUnitId,
    $core.String? cropVariety,
    $core.String? seedSource,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (season != null) result.season = season;
    if (cycleYear != null) result.cycleYear = cycleYear;
    if (name != null) result.name = name;
    if (plannedPlantingDate != null)
      result.plannedPlantingDate = plannedPlantingDate;
    if (plannedHarvestDate != null)
      result.plannedHarvestDate = plannedHarvestDate;
    if (targetYieldPerHectare != null)
      result.targetYieldPerHectare = targetYieldPerHectare;
    if (yieldUnit != null) result.yieldUnit = yieldUnit;
    if (notes != null) result.notes = notes;
    if (managementUnitId != null) result.managementUnitId = managementUnitId;
    if (cropVariety != null) result.cropVariety = cropVariety;
    if (seedSource != null) result.seedSource = seedSource;
    return result;
  }

  CreateCropCycleRequest._();

  factory CreateCropCycleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateCropCycleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateCropCycleRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'cropId')
    ..aOS(3, _omitFieldNames ? '' : 'season')
    ..aI(4, _omitFieldNames ? '' : 'cycleYear')
    ..aOS(5, _omitFieldNames ? '' : 'name')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'plannedPlantingDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'plannedHarvestDate',
        subBuilder: $0.Timestamp.create)
    ..aD(8, _omitFieldNames ? '' : 'targetYieldPerHectare')
    ..aOS(9, _omitFieldNames ? '' : 'yieldUnit')
    ..aOS(10, _omitFieldNames ? '' : 'notes')
    ..aOS(11, _omitFieldNames ? '' : 'managementUnitId')
    ..aOS(12, _omitFieldNames ? '' : 'cropVariety')
    ..aOS(13, _omitFieldNames ? '' : 'seedSource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCropCycleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCropCycleRequest copyWith(
          void Function(CreateCropCycleRequest) updates) =>
      super.copyWith((message) => updates(message as CreateCropCycleRequest))
          as CreateCropCycleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateCropCycleRequest create() => CreateCropCycleRequest._();
  @$core.override
  CreateCropCycleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateCropCycleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateCropCycleRequest>(create);
  static CreateCropCycleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cropId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get season => $_getSZ(2);
  @$pb.TagNumber(3)
  set season($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSeason() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeason() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get cycleYear => $_getIZ(3);
  @$pb.TagNumber(4)
  set cycleYear($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCycleYear() => $_has(3);
  @$pb.TagNumber(4)
  void clearCycleYear() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get name => $_getSZ(4);
  @$pb.TagNumber(5)
  set name($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasName() => $_has(4);
  @$pb.TagNumber(5)
  void clearName() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get plannedPlantingDate => $_getN(5);
  @$pb.TagNumber(6)
  set plannedPlantingDate($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasPlannedPlantingDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearPlannedPlantingDate() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensurePlannedPlantingDate() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Timestamp get plannedHarvestDate => $_getN(6);
  @$pb.TagNumber(7)
  set plannedHarvestDate($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasPlannedHarvestDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearPlannedHarvestDate() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensurePlannedHarvestDate() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.double get targetYieldPerHectare => $_getN(7);
  @$pb.TagNumber(8)
  set targetYieldPerHectare($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTargetYieldPerHectare() => $_has(7);
  @$pb.TagNumber(8)
  void clearTargetYieldPerHectare() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get yieldUnit => $_getSZ(8);
  @$pb.TagNumber(9)
  set yieldUnit($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasYieldUnit() => $_has(8);
  @$pb.TagNumber(9)
  void clearYieldUnit() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get notes => $_getSZ(9);
  @$pb.TagNumber(10)
  set notes($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNotes() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotes() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get managementUnitId => $_getSZ(10);
  @$pb.TagNumber(11)
  set managementUnitId($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasManagementUnitId() => $_has(10);
  @$pb.TagNumber(11)
  void clearManagementUnitId() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get cropVariety => $_getSZ(11);
  @$pb.TagNumber(12)
  set cropVariety($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasCropVariety() => $_has(11);
  @$pb.TagNumber(12)
  void clearCropVariety() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get seedSource => $_getSZ(12);
  @$pb.TagNumber(13)
  set seedSource($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasSeedSource() => $_has(12);
  @$pb.TagNumber(13)
  void clearSeedSource() => $_clearField(13);
}

class CreateCropCycleResponse extends $pb.GeneratedMessage {
  factory CreateCropCycleResponse({
    CropCycle? cycle,
  }) {
    final result = create();
    if (cycle != null) result.cycle = cycle;
    return result;
  }

  CreateCropCycleResponse._();

  factory CreateCropCycleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateCropCycleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateCropCycleResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOM<CropCycle>(1, _omitFieldNames ? '' : 'cycle',
        subBuilder: CropCycle.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCropCycleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCropCycleResponse copyWith(
          void Function(CreateCropCycleResponse) updates) =>
      super.copyWith((message) => updates(message as CreateCropCycleResponse))
          as CreateCropCycleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateCropCycleResponse create() => CreateCropCycleResponse._();
  @$core.override
  CreateCropCycleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateCropCycleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateCropCycleResponse>(create);
  static CreateCropCycleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CropCycle get cycle => $_getN(0);
  @$pb.TagNumber(1)
  set cycle(CropCycle value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCycle() => $_has(0);
  @$pb.TagNumber(1)
  void clearCycle() => $_clearField(1);
  @$pb.TagNumber(1)
  CropCycle ensureCycle() => $_ensure(0);
}

class GetCropCycleRequest extends $pb.GeneratedMessage {
  factory GetCropCycleRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetCropCycleRequest._();

  factory GetCropCycleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCropCycleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCropCycleRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropCycleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropCycleRequest copyWith(void Function(GetCropCycleRequest) updates) =>
      super.copyWith((message) => updates(message as GetCropCycleRequest))
          as GetCropCycleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCropCycleRequest create() => GetCropCycleRequest._();
  @$core.override
  GetCropCycleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCropCycleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCropCycleRequest>(create);
  static GetCropCycleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetCropCycleResponse extends $pb.GeneratedMessage {
  factory GetCropCycleResponse({
    CropCycle? cycle,
  }) {
    final result = create();
    if (cycle != null) result.cycle = cycle;
    return result;
  }

  GetCropCycleResponse._();

  factory GetCropCycleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCropCycleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCropCycleResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOM<CropCycle>(1, _omitFieldNames ? '' : 'cycle',
        subBuilder: CropCycle.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropCycleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropCycleResponse copyWith(void Function(GetCropCycleResponse) updates) =>
      super.copyWith((message) => updates(message as GetCropCycleResponse))
          as GetCropCycleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCropCycleResponse create() => GetCropCycleResponse._();
  @$core.override
  GetCropCycleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCropCycleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCropCycleResponse>(create);
  static GetCropCycleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CropCycle get cycle => $_getN(0);
  @$pb.TagNumber(1)
  set cycle(CropCycle value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCycle() => $_has(0);
  @$pb.TagNumber(1)
  void clearCycle() => $_clearField(1);
  @$pb.TagNumber(1)
  CropCycle ensureCycle() => $_ensure(0);
}

class ListCropCyclesRequest extends $pb.GeneratedMessage {
  factory ListCropCyclesRequest({
    $core.String? fieldId,
    CropCycleStatus? status,
    $core.int? pageSize,
    $core.int? pageOffset,
    $core.String? managementUnitId,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (status != null) result.status = status;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    if (managementUnitId != null) result.managementUnitId = managementUnitId;
    return result;
  }

  ListCropCyclesRequest._();

  factory ListCropCyclesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListCropCyclesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListCropCyclesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aE<CropCycleStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: CropCycleStatus.values)
    ..aI(3, _omitFieldNames ? '' : 'pageSize')
    ..aI(4, _omitFieldNames ? '' : 'pageOffset')
    ..aOS(5, _omitFieldNames ? '' : 'managementUnitId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCropCyclesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCropCyclesRequest copyWith(
          void Function(ListCropCyclesRequest) updates) =>
      super.copyWith((message) => updates(message as ListCropCyclesRequest))
          as ListCropCyclesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListCropCyclesRequest create() => ListCropCyclesRequest._();
  @$core.override
  ListCropCyclesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListCropCyclesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListCropCyclesRequest>(create);
  static ListCropCyclesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  CropCycleStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(CropCycleStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

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

  @$pb.TagNumber(5)
  $core.String get managementUnitId => $_getSZ(4);
  @$pb.TagNumber(5)
  set managementUnitId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasManagementUnitId() => $_has(4);
  @$pb.TagNumber(5)
  void clearManagementUnitId() => $_clearField(5);
}

class ListCropCyclesResponse extends $pb.GeneratedMessage {
  factory ListCropCyclesResponse({
    $core.Iterable<CropCycle>? cycles,
    $core.int? totalCount,
  }) {
    final result = create();
    if (cycles != null) result.cycles.addAll(cycles);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListCropCyclesResponse._();

  factory ListCropCyclesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListCropCyclesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListCropCyclesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..pPM<CropCycle>(1, _omitFieldNames ? '' : 'cycles',
        subBuilder: CropCycle.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCropCyclesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCropCyclesResponse copyWith(
          void Function(ListCropCyclesResponse) updates) =>
      super.copyWith((message) => updates(message as ListCropCyclesResponse))
          as ListCropCyclesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListCropCyclesResponse create() => ListCropCyclesResponse._();
  @$core.override
  ListCropCyclesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListCropCyclesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListCropCyclesResponse>(create);
  static ListCropCyclesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CropCycle> get cycles => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class UpdateCropCycleRequest extends $pb.GeneratedMessage {
  factory UpdateCropCycleRequest({
    $core.String? id,
    CropCycleStatus? status,
    $0.Timestamp? actualPlantingDate,
    $0.Timestamp? actualHarvestDate,
    $core.double? actualYieldPerHectare,
    $fixnum.Int64? totalInputCost,
    $fixnum.Int64? totalRevenue,
    $core.String? notes,
    $1.FieldMask? updateMask,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (status != null) result.status = status;
    if (actualPlantingDate != null)
      result.actualPlantingDate = actualPlantingDate;
    if (actualHarvestDate != null) result.actualHarvestDate = actualHarvestDate;
    if (actualYieldPerHectare != null)
      result.actualYieldPerHectare = actualYieldPerHectare;
    if (totalInputCost != null) result.totalInputCost = totalInputCost;
    if (totalRevenue != null) result.totalRevenue = totalRevenue;
    if (notes != null) result.notes = notes;
    if (updateMask != null) result.updateMask = updateMask;
    return result;
  }

  UpdateCropCycleRequest._();

  factory UpdateCropCycleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateCropCycleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateCropCycleRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<CropCycleStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: CropCycleStatus.values)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'actualPlantingDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'actualHarvestDate',
        subBuilder: $0.Timestamp.create)
    ..aD(5, _omitFieldNames ? '' : 'actualYieldPerHectare')
    ..aInt64(6, _omitFieldNames ? '' : 'totalInputCost')
    ..aInt64(7, _omitFieldNames ? '' : 'totalRevenue')
    ..aOS(8, _omitFieldNames ? '' : 'notes')
    ..aOM<$1.FieldMask>(9, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $1.FieldMask.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCropCycleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCropCycleRequest copyWith(
          void Function(UpdateCropCycleRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateCropCycleRequest))
          as UpdateCropCycleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateCropCycleRequest create() => UpdateCropCycleRequest._();
  @$core.override
  UpdateCropCycleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateCropCycleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateCropCycleRequest>(create);
  static UpdateCropCycleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  CropCycleStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(CropCycleStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get actualPlantingDate => $_getN(2);
  @$pb.TagNumber(3)
  set actualPlantingDate($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasActualPlantingDate() => $_has(2);
  @$pb.TagNumber(3)
  void clearActualPlantingDate() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureActualPlantingDate() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Timestamp get actualHarvestDate => $_getN(3);
  @$pb.TagNumber(4)
  set actualHarvestDate($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasActualHarvestDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearActualHarvestDate() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureActualHarvestDate() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.double get actualYieldPerHectare => $_getN(4);
  @$pb.TagNumber(5)
  set actualYieldPerHectare($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasActualYieldPerHectare() => $_has(4);
  @$pb.TagNumber(5)
  void clearActualYieldPerHectare() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get totalInputCost => $_getI64(5);
  @$pb.TagNumber(6)
  set totalInputCost($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalInputCost() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalInputCost() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get totalRevenue => $_getI64(6);
  @$pb.TagNumber(7)
  set totalRevenue($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTotalRevenue() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalRevenue() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get notes => $_getSZ(7);
  @$pb.TagNumber(8)
  set notes($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNotes() => $_has(7);
  @$pb.TagNumber(8)
  void clearNotes() => $_clearField(8);

  @$pb.TagNumber(9)
  $1.FieldMask get updateMask => $_getN(8);
  @$pb.TagNumber(9)
  set updateMask($1.FieldMask value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasUpdateMask() => $_has(8);
  @$pb.TagNumber(9)
  void clearUpdateMask() => $_clearField(9);
  @$pb.TagNumber(9)
  $1.FieldMask ensureUpdateMask() => $_ensure(8);
}

class UpdateCropCycleResponse extends $pb.GeneratedMessage {
  factory UpdateCropCycleResponse({
    CropCycle? cycle,
  }) {
    final result = create();
    if (cycle != null) result.cycle = cycle;
    return result;
  }

  UpdateCropCycleResponse._();

  factory UpdateCropCycleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateCropCycleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateCropCycleResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOM<CropCycle>(1, _omitFieldNames ? '' : 'cycle',
        subBuilder: CropCycle.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCropCycleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCropCycleResponse copyWith(
          void Function(UpdateCropCycleResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateCropCycleResponse))
          as UpdateCropCycleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateCropCycleResponse create() => UpdateCropCycleResponse._();
  @$core.override
  UpdateCropCycleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateCropCycleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateCropCycleResponse>(create);
  static UpdateCropCycleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CropCycle get cycle => $_getN(0);
  @$pb.TagNumber(1)
  set cycle(CropCycle value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCycle() => $_has(0);
  @$pb.TagNumber(1)
  void clearCycle() => $_clearField(1);
  @$pb.TagNumber(1)
  CropCycle ensureCycle() => $_ensure(0);
}

class ActivityEvent extends $pb.GeneratedMessage {
  factory ActivityEvent({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? cropCycleId,
    $core.String? performedBy,
    $core.String? activityType,
    ActivityCategory? category,
    $0.Timestamp? startedAt,
    $0.Timestamp? completedAt,
    $core.int? durationMinutes,
    $core.String? description,
    $core.String? notes,
    $core.String? inputProductId,
    $core.double? inputQuantity,
    $core.String? inputUnit,
    $fixnum.Int64? inputCost,
    $core.String? currency,
    $core.double? areaHectares,
    $core.double? weatherTempCelsius,
    $core.double? weatherHumidityPct,
    $core.double? weatherWindSpeedKmh,
    $core.String? weatherConditions,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropCycleId != null) result.cropCycleId = cropCycleId;
    if (performedBy != null) result.performedBy = performedBy;
    if (activityType != null) result.activityType = activityType;
    if (category != null) result.category = category;
    if (startedAt != null) result.startedAt = startedAt;
    if (completedAt != null) result.completedAt = completedAt;
    if (durationMinutes != null) result.durationMinutes = durationMinutes;
    if (description != null) result.description = description;
    if (notes != null) result.notes = notes;
    if (inputProductId != null) result.inputProductId = inputProductId;
    if (inputQuantity != null) result.inputQuantity = inputQuantity;
    if (inputUnit != null) result.inputUnit = inputUnit;
    if (inputCost != null) result.inputCost = inputCost;
    if (currency != null) result.currency = currency;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (weatherTempCelsius != null)
      result.weatherTempCelsius = weatherTempCelsius;
    if (weatherHumidityPct != null)
      result.weatherHumidityPct = weatherHumidityPct;
    if (weatherWindSpeedKmh != null)
      result.weatherWindSpeedKmh = weatherWindSpeedKmh;
    if (weatherConditions != null) result.weatherConditions = weatherConditions;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  ActivityEvent._();

  factory ActivityEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActivityEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActivityEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'cropCycleId')
    ..aOS(5, _omitFieldNames ? '' : 'performedBy')
    ..aOS(6, _omitFieldNames ? '' : 'activityType')
    ..aE<ActivityCategory>(7, _omitFieldNames ? '' : 'category',
        enumValues: ActivityCategory.values)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'startedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'completedAt',
        subBuilder: $0.Timestamp.create)
    ..aI(10, _omitFieldNames ? '' : 'durationMinutes')
    ..aOS(11, _omitFieldNames ? '' : 'description')
    ..aOS(12, _omitFieldNames ? '' : 'notes')
    ..aOS(13, _omitFieldNames ? '' : 'inputProductId')
    ..aD(14, _omitFieldNames ? '' : 'inputQuantity')
    ..aOS(15, _omitFieldNames ? '' : 'inputUnit')
    ..aInt64(16, _omitFieldNames ? '' : 'inputCost')
    ..aOS(17, _omitFieldNames ? '' : 'currency')
    ..aD(18, _omitFieldNames ? '' : 'areaHectares')
    ..aD(19, _omitFieldNames ? '' : 'weatherTempCelsius')
    ..aD(20, _omitFieldNames ? '' : 'weatherHumidityPct')
    ..aD(21, _omitFieldNames ? '' : 'weatherWindSpeedKmh')
    ..aOS(22, _omitFieldNames ? '' : 'weatherConditions')
    ..aOM<$0.Timestamp>(23, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivityEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivityEvent copyWith(void Function(ActivityEvent) updates) =>
      super.copyWith((message) => updates(message as ActivityEvent))
          as ActivityEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActivityEvent create() => ActivityEvent._();
  @$core.override
  ActivityEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ActivityEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActivityEvent>(create);
  static ActivityEvent? _defaultInstance;

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
  $core.String get cropCycleId => $_getSZ(3);
  @$pb.TagNumber(4)
  set cropCycleId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCropCycleId() => $_has(3);
  @$pb.TagNumber(4)
  void clearCropCycleId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get performedBy => $_getSZ(4);
  @$pb.TagNumber(5)
  set performedBy($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPerformedBy() => $_has(4);
  @$pb.TagNumber(5)
  void clearPerformedBy() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get activityType => $_getSZ(5);
  @$pb.TagNumber(6)
  set activityType($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasActivityType() => $_has(5);
  @$pb.TagNumber(6)
  void clearActivityType() => $_clearField(6);

  @$pb.TagNumber(7)
  ActivityCategory get category => $_getN(6);
  @$pb.TagNumber(7)
  set category(ActivityCategory value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCategory() => $_has(6);
  @$pb.TagNumber(7)
  void clearCategory() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get startedAt => $_getN(7);
  @$pb.TagNumber(8)
  set startedAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStartedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearStartedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureStartedAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $0.Timestamp get completedAt => $_getN(8);
  @$pb.TagNumber(9)
  set completedAt($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasCompletedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCompletedAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureCompletedAt() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.int get durationMinutes => $_getIZ(9);
  @$pb.TagNumber(10)
  set durationMinutes($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDurationMinutes() => $_has(9);
  @$pb.TagNumber(10)
  void clearDurationMinutes() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get description => $_getSZ(10);
  @$pb.TagNumber(11)
  set description($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDescription() => $_has(10);
  @$pb.TagNumber(11)
  void clearDescription() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get notes => $_getSZ(11);
  @$pb.TagNumber(12)
  set notes($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasNotes() => $_has(11);
  @$pb.TagNumber(12)
  void clearNotes() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get inputProductId => $_getSZ(12);
  @$pb.TagNumber(13)
  set inputProductId($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasInputProductId() => $_has(12);
  @$pb.TagNumber(13)
  void clearInputProductId() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get inputQuantity => $_getN(13);
  @$pb.TagNumber(14)
  set inputQuantity($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasInputQuantity() => $_has(13);
  @$pb.TagNumber(14)
  void clearInputQuantity() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get inputUnit => $_getSZ(14);
  @$pb.TagNumber(15)
  set inputUnit($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasInputUnit() => $_has(14);
  @$pb.TagNumber(15)
  void clearInputUnit() => $_clearField(15);

  @$pb.TagNumber(16)
  $fixnum.Int64 get inputCost => $_getI64(15);
  @$pb.TagNumber(16)
  set inputCost($fixnum.Int64 value) => $_setInt64(15, value);
  @$pb.TagNumber(16)
  $core.bool hasInputCost() => $_has(15);
  @$pb.TagNumber(16)
  void clearInputCost() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get currency => $_getSZ(16);
  @$pb.TagNumber(17)
  set currency($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasCurrency() => $_has(16);
  @$pb.TagNumber(17)
  void clearCurrency() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.double get areaHectares => $_getN(17);
  @$pb.TagNumber(18)
  set areaHectares($core.double value) => $_setDouble(17, value);
  @$pb.TagNumber(18)
  $core.bool hasAreaHectares() => $_has(17);
  @$pb.TagNumber(18)
  void clearAreaHectares() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.double get weatherTempCelsius => $_getN(18);
  @$pb.TagNumber(19)
  set weatherTempCelsius($core.double value) => $_setDouble(18, value);
  @$pb.TagNumber(19)
  $core.bool hasWeatherTempCelsius() => $_has(18);
  @$pb.TagNumber(19)
  void clearWeatherTempCelsius() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.double get weatherHumidityPct => $_getN(19);
  @$pb.TagNumber(20)
  set weatherHumidityPct($core.double value) => $_setDouble(19, value);
  @$pb.TagNumber(20)
  $core.bool hasWeatherHumidityPct() => $_has(19);
  @$pb.TagNumber(20)
  void clearWeatherHumidityPct() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.double get weatherWindSpeedKmh => $_getN(20);
  @$pb.TagNumber(21)
  set weatherWindSpeedKmh($core.double value) => $_setDouble(20, value);
  @$pb.TagNumber(21)
  $core.bool hasWeatherWindSpeedKmh() => $_has(20);
  @$pb.TagNumber(21)
  void clearWeatherWindSpeedKmh() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.String get weatherConditions => $_getSZ(21);
  @$pb.TagNumber(22)
  set weatherConditions($core.String value) => $_setString(21, value);
  @$pb.TagNumber(22)
  $core.bool hasWeatherConditions() => $_has(21);
  @$pb.TagNumber(22)
  void clearWeatherConditions() => $_clearField(22);

  @$pb.TagNumber(23)
  $0.Timestamp get createdAt => $_getN(22);
  @$pb.TagNumber(23)
  set createdAt($0.Timestamp value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasCreatedAt() => $_has(22);
  @$pb.TagNumber(23)
  void clearCreatedAt() => $_clearField(23);
  @$pb.TagNumber(23)
  $0.Timestamp ensureCreatedAt() => $_ensure(22);
}

class LogActivityEventRequest extends $pb.GeneratedMessage {
  factory LogActivityEventRequest({
    $core.String? fieldId,
    $core.String? cropCycleId,
    $core.String? activityType,
    ActivityCategory? category,
    $0.Timestamp? startedAt,
    $0.Timestamp? completedAt,
    $core.int? durationMinutes,
    $core.String? description,
    $core.String? notes,
    $core.String? inputProductId,
    $core.double? inputQuantity,
    $core.String? inputUnit,
    $fixnum.Int64? inputCost,
    $core.String? currency,
    $core.double? areaHectares,
    $core.double? weatherTempCelsius,
    $core.double? weatherHumidityPct,
    $core.double? weatherWindSpeedKmh,
    $core.String? weatherConditions,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (cropCycleId != null) result.cropCycleId = cropCycleId;
    if (activityType != null) result.activityType = activityType;
    if (category != null) result.category = category;
    if (startedAt != null) result.startedAt = startedAt;
    if (completedAt != null) result.completedAt = completedAt;
    if (durationMinutes != null) result.durationMinutes = durationMinutes;
    if (description != null) result.description = description;
    if (notes != null) result.notes = notes;
    if (inputProductId != null) result.inputProductId = inputProductId;
    if (inputQuantity != null) result.inputQuantity = inputQuantity;
    if (inputUnit != null) result.inputUnit = inputUnit;
    if (inputCost != null) result.inputCost = inputCost;
    if (currency != null) result.currency = currency;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (weatherTempCelsius != null)
      result.weatherTempCelsius = weatherTempCelsius;
    if (weatherHumidityPct != null)
      result.weatherHumidityPct = weatherHumidityPct;
    if (weatherWindSpeedKmh != null)
      result.weatherWindSpeedKmh = weatherWindSpeedKmh;
    if (weatherConditions != null) result.weatherConditions = weatherConditions;
    return result;
  }

  LogActivityEventRequest._();

  factory LogActivityEventRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogActivityEventRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogActivityEventRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'cropCycleId')
    ..aOS(3, _omitFieldNames ? '' : 'activityType')
    ..aE<ActivityCategory>(4, _omitFieldNames ? '' : 'category',
        enumValues: ActivityCategory.values)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'startedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'completedAt',
        subBuilder: $0.Timestamp.create)
    ..aI(7, _omitFieldNames ? '' : 'durationMinutes')
    ..aOS(8, _omitFieldNames ? '' : 'description')
    ..aOS(9, _omitFieldNames ? '' : 'notes')
    ..aOS(10, _omitFieldNames ? '' : 'inputProductId')
    ..aD(11, _omitFieldNames ? '' : 'inputQuantity')
    ..aOS(12, _omitFieldNames ? '' : 'inputUnit')
    ..aInt64(13, _omitFieldNames ? '' : 'inputCost')
    ..aOS(14, _omitFieldNames ? '' : 'currency')
    ..aD(15, _omitFieldNames ? '' : 'areaHectares')
    ..aD(16, _omitFieldNames ? '' : 'weatherTempCelsius')
    ..aD(17, _omitFieldNames ? '' : 'weatherHumidityPct')
    ..aD(18, _omitFieldNames ? '' : 'weatherWindSpeedKmh')
    ..aOS(19, _omitFieldNames ? '' : 'weatherConditions')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogActivityEventRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogActivityEventRequest copyWith(
          void Function(LogActivityEventRequest) updates) =>
      super.copyWith((message) => updates(message as LogActivityEventRequest))
          as LogActivityEventRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogActivityEventRequest create() => LogActivityEventRequest._();
  @$core.override
  LogActivityEventRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogActivityEventRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogActivityEventRequest>(create);
  static LogActivityEventRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cropCycleId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropCycleId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropCycleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropCycleId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get activityType => $_getSZ(2);
  @$pb.TagNumber(3)
  set activityType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasActivityType() => $_has(2);
  @$pb.TagNumber(3)
  void clearActivityType() => $_clearField(3);

  @$pb.TagNumber(4)
  ActivityCategory get category => $_getN(3);
  @$pb.TagNumber(4)
  set category(ActivityCategory value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCategory() => $_has(3);
  @$pb.TagNumber(4)
  void clearCategory() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get startedAt => $_getN(4);
  @$pb.TagNumber(5)
  set startedAt($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStartedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearStartedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureStartedAt() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.Timestamp get completedAt => $_getN(5);
  @$pb.TagNumber(6)
  set completedAt($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCompletedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCompletedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureCompletedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.int get durationMinutes => $_getIZ(6);
  @$pb.TagNumber(7)
  set durationMinutes($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDurationMinutes() => $_has(6);
  @$pb.TagNumber(7)
  void clearDurationMinutes() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get description => $_getSZ(7);
  @$pb.TagNumber(8)
  set description($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDescription() => $_has(7);
  @$pb.TagNumber(8)
  void clearDescription() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get notes => $_getSZ(8);
  @$pb.TagNumber(9)
  set notes($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasNotes() => $_has(8);
  @$pb.TagNumber(9)
  void clearNotes() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get inputProductId => $_getSZ(9);
  @$pb.TagNumber(10)
  set inputProductId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasInputProductId() => $_has(9);
  @$pb.TagNumber(10)
  void clearInputProductId() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get inputQuantity => $_getN(10);
  @$pb.TagNumber(11)
  set inputQuantity($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasInputQuantity() => $_has(10);
  @$pb.TagNumber(11)
  void clearInputQuantity() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get inputUnit => $_getSZ(11);
  @$pb.TagNumber(12)
  set inputUnit($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasInputUnit() => $_has(11);
  @$pb.TagNumber(12)
  void clearInputUnit() => $_clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get inputCost => $_getI64(12);
  @$pb.TagNumber(13)
  set inputCost($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasInputCost() => $_has(12);
  @$pb.TagNumber(13)
  void clearInputCost() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get currency => $_getSZ(13);
  @$pb.TagNumber(14)
  set currency($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasCurrency() => $_has(13);
  @$pb.TagNumber(14)
  void clearCurrency() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get areaHectares => $_getN(14);
  @$pb.TagNumber(15)
  set areaHectares($core.double value) => $_setDouble(14, value);
  @$pb.TagNumber(15)
  $core.bool hasAreaHectares() => $_has(14);
  @$pb.TagNumber(15)
  void clearAreaHectares() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.double get weatherTempCelsius => $_getN(15);
  @$pb.TagNumber(16)
  set weatherTempCelsius($core.double value) => $_setDouble(15, value);
  @$pb.TagNumber(16)
  $core.bool hasWeatherTempCelsius() => $_has(15);
  @$pb.TagNumber(16)
  void clearWeatherTempCelsius() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.double get weatherHumidityPct => $_getN(16);
  @$pb.TagNumber(17)
  set weatherHumidityPct($core.double value) => $_setDouble(16, value);
  @$pb.TagNumber(17)
  $core.bool hasWeatherHumidityPct() => $_has(16);
  @$pb.TagNumber(17)
  void clearWeatherHumidityPct() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.double get weatherWindSpeedKmh => $_getN(17);
  @$pb.TagNumber(18)
  set weatherWindSpeedKmh($core.double value) => $_setDouble(17, value);
  @$pb.TagNumber(18)
  $core.bool hasWeatherWindSpeedKmh() => $_has(17);
  @$pb.TagNumber(18)
  void clearWeatherWindSpeedKmh() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get weatherConditions => $_getSZ(18);
  @$pb.TagNumber(19)
  set weatherConditions($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasWeatherConditions() => $_has(18);
  @$pb.TagNumber(19)
  void clearWeatherConditions() => $_clearField(19);
}

class LogActivityEventResponse extends $pb.GeneratedMessage {
  factory LogActivityEventResponse({
    ActivityEvent? event,
  }) {
    final result = create();
    if (event != null) result.event = event;
    return result;
  }

  LogActivityEventResponse._();

  factory LogActivityEventResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LogActivityEventResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LogActivityEventResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOM<ActivityEvent>(1, _omitFieldNames ? '' : 'event',
        subBuilder: ActivityEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogActivityEventResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LogActivityEventResponse copyWith(
          void Function(LogActivityEventResponse) updates) =>
      super.copyWith((message) => updates(message as LogActivityEventResponse))
          as LogActivityEventResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LogActivityEventResponse create() => LogActivityEventResponse._();
  @$core.override
  LogActivityEventResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LogActivityEventResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LogActivityEventResponse>(create);
  static LogActivityEventResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ActivityEvent get event => $_getN(0);
  @$pb.TagNumber(1)
  set event(ActivityEvent value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEvent() => $_has(0);
  @$pb.TagNumber(1)
  void clearEvent() => $_clearField(1);
  @$pb.TagNumber(1)
  ActivityEvent ensureEvent() => $_ensure(0);
}

class ListActivityEventsRequest extends $pb.GeneratedMessage {
  factory ListActivityEventsRequest({
    $core.String? fieldId,
    $core.String? cropCycleId,
    ActivityCategory? category,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (cropCycleId != null) result.cropCycleId = cropCycleId;
    if (category != null) result.category = category;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListActivityEventsRequest._();

  factory ListActivityEventsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListActivityEventsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListActivityEventsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'cropCycleId')
    ..aE<ActivityCategory>(3, _omitFieldNames ? '' : 'category',
        enumValues: ActivityCategory.values)
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aI(5, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActivityEventsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActivityEventsRequest copyWith(
          void Function(ListActivityEventsRequest) updates) =>
      super.copyWith((message) => updates(message as ListActivityEventsRequest))
          as ListActivityEventsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListActivityEventsRequest create() => ListActivityEventsRequest._();
  @$core.override
  ListActivityEventsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListActivityEventsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListActivityEventsRequest>(create);
  static ListActivityEventsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cropCycleId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropCycleId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropCycleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropCycleId() => $_clearField(2);

  @$pb.TagNumber(3)
  ActivityCategory get category => $_getN(2);
  @$pb.TagNumber(3)
  set category(ActivityCategory value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCategory() => $_has(2);
  @$pb.TagNumber(3)
  void clearCategory() => $_clearField(3);

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

class ListActivityEventsResponse extends $pb.GeneratedMessage {
  factory ListActivityEventsResponse({
    $core.Iterable<ActivityEvent>? events,
    $core.int? totalCount,
  }) {
    final result = create();
    if (events != null) result.events.addAll(events);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListActivityEventsResponse._();

  factory ListActivityEventsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListActivityEventsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListActivityEventsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..pPM<ActivityEvent>(1, _omitFieldNames ? '' : 'events',
        subBuilder: ActivityEvent.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActivityEventsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActivityEventsResponse copyWith(
          void Function(ListActivityEventsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListActivityEventsResponse))
          as ListActivityEventsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListActivityEventsResponse create() => ListActivityEventsResponse._();
  @$core.override
  ListActivityEventsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListActivityEventsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListActivityEventsResponse>(create);
  static ListActivityEventsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ActivityEvent> get events => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class ActivityEvidence extends $pb.GeneratedMessage {
  factory ActivityEvidence({
    $core.String? id,
    $core.String? tenantId,
    $core.String? activityEventId,
    EvidenceType? evidenceType,
    $core.String? fileUrl,
    $core.String? fileName,
    $fixnum.Int64? fileSizeBytes,
    $core.String? mimeType,
    $core.String? thumbnailUrl,
    $core.String? caption,
    $core.double? latitude,
    $core.double? longitude,
    $0.Timestamp? capturedAt,
    $core.String? capturedBy,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (activityEventId != null) result.activityEventId = activityEventId;
    if (evidenceType != null) result.evidenceType = evidenceType;
    if (fileUrl != null) result.fileUrl = fileUrl;
    if (fileName != null) result.fileName = fileName;
    if (fileSizeBytes != null) result.fileSizeBytes = fileSizeBytes;
    if (mimeType != null) result.mimeType = mimeType;
    if (thumbnailUrl != null) result.thumbnailUrl = thumbnailUrl;
    if (caption != null) result.caption = caption;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (capturedAt != null) result.capturedAt = capturedAt;
    if (capturedBy != null) result.capturedBy = capturedBy;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  ActivityEvidence._();

  factory ActivityEvidence.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActivityEvidence.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActivityEvidence',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'activityEventId')
    ..aE<EvidenceType>(4, _omitFieldNames ? '' : 'evidenceType',
        enumValues: EvidenceType.values)
    ..aOS(5, _omitFieldNames ? '' : 'fileUrl')
    ..aOS(6, _omitFieldNames ? '' : 'fileName')
    ..aInt64(7, _omitFieldNames ? '' : 'fileSizeBytes')
    ..aOS(8, _omitFieldNames ? '' : 'mimeType')
    ..aOS(9, _omitFieldNames ? '' : 'thumbnailUrl')
    ..aOS(10, _omitFieldNames ? '' : 'caption')
    ..aD(11, _omitFieldNames ? '' : 'latitude')
    ..aD(12, _omitFieldNames ? '' : 'longitude')
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'capturedAt',
        subBuilder: $0.Timestamp.create)
    ..aOS(14, _omitFieldNames ? '' : 'capturedBy')
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivityEvidence clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivityEvidence copyWith(void Function(ActivityEvidence) updates) =>
      super.copyWith((message) => updates(message as ActivityEvidence))
          as ActivityEvidence;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActivityEvidence create() => ActivityEvidence._();
  @$core.override
  ActivityEvidence createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ActivityEvidence getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActivityEvidence>(create);
  static ActivityEvidence? _defaultInstance;

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
  $core.String get activityEventId => $_getSZ(2);
  @$pb.TagNumber(3)
  set activityEventId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasActivityEventId() => $_has(2);
  @$pb.TagNumber(3)
  void clearActivityEventId() => $_clearField(3);

  @$pb.TagNumber(4)
  EvidenceType get evidenceType => $_getN(3);
  @$pb.TagNumber(4)
  set evidenceType(EvidenceType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasEvidenceType() => $_has(3);
  @$pb.TagNumber(4)
  void clearEvidenceType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get fileUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set fileUrl($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFileUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearFileUrl() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get fileName => $_getSZ(5);
  @$pb.TagNumber(6)
  set fileName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFileName() => $_has(5);
  @$pb.TagNumber(6)
  void clearFileName() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get fileSizeBytes => $_getI64(6);
  @$pb.TagNumber(7)
  set fileSizeBytes($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFileSizeBytes() => $_has(6);
  @$pb.TagNumber(7)
  void clearFileSizeBytes() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get mimeType => $_getSZ(7);
  @$pb.TagNumber(8)
  set mimeType($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMimeType() => $_has(7);
  @$pb.TagNumber(8)
  void clearMimeType() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get thumbnailUrl => $_getSZ(8);
  @$pb.TagNumber(9)
  set thumbnailUrl($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasThumbnailUrl() => $_has(8);
  @$pb.TagNumber(9)
  void clearThumbnailUrl() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get caption => $_getSZ(9);
  @$pb.TagNumber(10)
  set caption($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCaption() => $_has(9);
  @$pb.TagNumber(10)
  void clearCaption() => $_clearField(10);

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
  $0.Timestamp get capturedAt => $_getN(12);
  @$pb.TagNumber(13)
  set capturedAt($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasCapturedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearCapturedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureCapturedAt() => $_ensure(12);

  @$pb.TagNumber(14)
  $core.String get capturedBy => $_getSZ(13);
  @$pb.TagNumber(14)
  set capturedBy($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasCapturedBy() => $_has(13);
  @$pb.TagNumber(14)
  void clearCapturedBy() => $_clearField(14);

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
}

class AddActivityEvidenceRequest extends $pb.GeneratedMessage {
  factory AddActivityEvidenceRequest({
    $core.String? activityEventId,
    EvidenceType? evidenceType,
    $core.String? fileUrl,
    $core.String? fileName,
    $fixnum.Int64? fileSizeBytes,
    $core.String? mimeType,
    $core.String? thumbnailUrl,
    $core.String? caption,
    $core.double? latitude,
    $core.double? longitude,
    $0.Timestamp? capturedAt,
  }) {
    final result = create();
    if (activityEventId != null) result.activityEventId = activityEventId;
    if (evidenceType != null) result.evidenceType = evidenceType;
    if (fileUrl != null) result.fileUrl = fileUrl;
    if (fileName != null) result.fileName = fileName;
    if (fileSizeBytes != null) result.fileSizeBytes = fileSizeBytes;
    if (mimeType != null) result.mimeType = mimeType;
    if (thumbnailUrl != null) result.thumbnailUrl = thumbnailUrl;
    if (caption != null) result.caption = caption;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (capturedAt != null) result.capturedAt = capturedAt;
    return result;
  }

  AddActivityEvidenceRequest._();

  factory AddActivityEvidenceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddActivityEvidenceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddActivityEvidenceRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'activityEventId')
    ..aE<EvidenceType>(2, _omitFieldNames ? '' : 'evidenceType',
        enumValues: EvidenceType.values)
    ..aOS(3, _omitFieldNames ? '' : 'fileUrl')
    ..aOS(4, _omitFieldNames ? '' : 'fileName')
    ..aInt64(5, _omitFieldNames ? '' : 'fileSizeBytes')
    ..aOS(6, _omitFieldNames ? '' : 'mimeType')
    ..aOS(7, _omitFieldNames ? '' : 'thumbnailUrl')
    ..aOS(8, _omitFieldNames ? '' : 'caption')
    ..aD(9, _omitFieldNames ? '' : 'latitude')
    ..aD(10, _omitFieldNames ? '' : 'longitude')
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'capturedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddActivityEvidenceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddActivityEvidenceRequest copyWith(
          void Function(AddActivityEvidenceRequest) updates) =>
      super.copyWith(
              (message) => updates(message as AddActivityEvidenceRequest))
          as AddActivityEvidenceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddActivityEvidenceRequest create() => AddActivityEvidenceRequest._();
  @$core.override
  AddActivityEvidenceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddActivityEvidenceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddActivityEvidenceRequest>(create);
  static AddActivityEvidenceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get activityEventId => $_getSZ(0);
  @$pb.TagNumber(1)
  set activityEventId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasActivityEventId() => $_has(0);
  @$pb.TagNumber(1)
  void clearActivityEventId() => $_clearField(1);

  @$pb.TagNumber(2)
  EvidenceType get evidenceType => $_getN(1);
  @$pb.TagNumber(2)
  set evidenceType(EvidenceType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEvidenceType() => $_has(1);
  @$pb.TagNumber(2)
  void clearEvidenceType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fileUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set fileUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFileUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearFileUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fileName => $_getSZ(3);
  @$pb.TagNumber(4)
  set fileName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFileName() => $_has(3);
  @$pb.TagNumber(4)
  void clearFileName() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get fileSizeBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set fileSizeBytes($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFileSizeBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearFileSizeBytes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get mimeType => $_getSZ(5);
  @$pb.TagNumber(6)
  set mimeType($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMimeType() => $_has(5);
  @$pb.TagNumber(6)
  void clearMimeType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get thumbnailUrl => $_getSZ(6);
  @$pb.TagNumber(7)
  set thumbnailUrl($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasThumbnailUrl() => $_has(6);
  @$pb.TagNumber(7)
  void clearThumbnailUrl() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get caption => $_getSZ(7);
  @$pb.TagNumber(8)
  set caption($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCaption() => $_has(7);
  @$pb.TagNumber(8)
  void clearCaption() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get latitude => $_getN(8);
  @$pb.TagNumber(9)
  set latitude($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLatitude() => $_has(8);
  @$pb.TagNumber(9)
  void clearLatitude() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get longitude => $_getN(9);
  @$pb.TagNumber(10)
  set longitude($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasLongitude() => $_has(9);
  @$pb.TagNumber(10)
  void clearLongitude() => $_clearField(10);

  @$pb.TagNumber(11)
  $0.Timestamp get capturedAt => $_getN(10);
  @$pb.TagNumber(11)
  set capturedAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasCapturedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearCapturedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureCapturedAt() => $_ensure(10);
}

class AddActivityEvidenceResponse extends $pb.GeneratedMessage {
  factory AddActivityEvidenceResponse({
    ActivityEvidence? evidence,
  }) {
    final result = create();
    if (evidence != null) result.evidence = evidence;
    return result;
  }

  AddActivityEvidenceResponse._();

  factory AddActivityEvidenceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddActivityEvidenceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddActivityEvidenceResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOM<ActivityEvidence>(1, _omitFieldNames ? '' : 'evidence',
        subBuilder: ActivityEvidence.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddActivityEvidenceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddActivityEvidenceResponse copyWith(
          void Function(AddActivityEvidenceResponse) updates) =>
      super.copyWith(
              (message) => updates(message as AddActivityEvidenceResponse))
          as AddActivityEvidenceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddActivityEvidenceResponse create() =>
      AddActivityEvidenceResponse._();
  @$core.override
  AddActivityEvidenceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddActivityEvidenceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddActivityEvidenceResponse>(create);
  static AddActivityEvidenceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ActivityEvidence get evidence => $_getN(0);
  @$pb.TagNumber(1)
  set evidence(ActivityEvidence value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEvidence() => $_has(0);
  @$pb.TagNumber(1)
  void clearEvidence() => $_clearField(1);
  @$pb.TagNumber(1)
  ActivityEvidence ensureEvidence() => $_ensure(0);
}

class ListActivityEvidenceRequest extends $pb.GeneratedMessage {
  factory ListActivityEvidenceRequest({
    $core.String? activityEventId,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (activityEventId != null) result.activityEventId = activityEventId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListActivityEvidenceRequest._();

  factory ListActivityEvidenceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListActivityEvidenceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListActivityEvidenceRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'activityEventId')
    ..aI(2, _omitFieldNames ? '' : 'pageSize')
    ..aI(3, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActivityEvidenceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActivityEvidenceRequest copyWith(
          void Function(ListActivityEvidenceRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ListActivityEvidenceRequest))
          as ListActivityEvidenceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListActivityEvidenceRequest create() =>
      ListActivityEvidenceRequest._();
  @$core.override
  ListActivityEvidenceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListActivityEvidenceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListActivityEvidenceRequest>(create);
  static ListActivityEvidenceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get activityEventId => $_getSZ(0);
  @$pb.TagNumber(1)
  set activityEventId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasActivityEventId() => $_has(0);
  @$pb.TagNumber(1)
  void clearActivityEventId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageOffset => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageOffset($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageOffset() => $_clearField(3);
}

class ListActivityEvidenceResponse extends $pb.GeneratedMessage {
  factory ListActivityEvidenceResponse({
    $core.Iterable<ActivityEvidence>? evidence,
    $core.int? totalCount,
  }) {
    final result = create();
    if (evidence != null) result.evidence.addAll(evidence);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListActivityEvidenceResponse._();

  factory ListActivityEvidenceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListActivityEvidenceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListActivityEvidenceResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..pPM<ActivityEvidence>(1, _omitFieldNames ? '' : 'evidence',
        subBuilder: ActivityEvidence.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActivityEvidenceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListActivityEvidenceResponse copyWith(
          void Function(ListActivityEvidenceResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListActivityEvidenceResponse))
          as ListActivityEvidenceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListActivityEvidenceResponse create() =>
      ListActivityEvidenceResponse._();
  @$core.override
  ListActivityEvidenceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListActivityEvidenceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListActivityEvidenceResponse>(create);
  static ListActivityEvidenceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ActivityEvidence> get evidence => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class DeleteActivityEvidenceRequest extends $pb.GeneratedMessage {
  factory DeleteActivityEvidenceRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteActivityEvidenceRequest._();

  factory DeleteActivityEvidenceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteActivityEvidenceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteActivityEvidenceRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteActivityEvidenceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteActivityEvidenceRequest copyWith(
          void Function(DeleteActivityEvidenceRequest) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteActivityEvidenceRequest))
          as DeleteActivityEvidenceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteActivityEvidenceRequest create() =>
      DeleteActivityEvidenceRequest._();
  @$core.override
  DeleteActivityEvidenceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteActivityEvidenceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteActivityEvidenceRequest>(create);
  static DeleteActivityEvidenceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteActivityEvidenceResponse extends $pb.GeneratedMessage {
  factory DeleteActivityEvidenceResponse() => create();

  DeleteActivityEvidenceResponse._();

  factory DeleteActivityEvidenceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteActivityEvidenceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteActivityEvidenceResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteActivityEvidenceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteActivityEvidenceResponse copyWith(
          void Function(DeleteActivityEvidenceResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DeleteActivityEvidenceResponse))
          as DeleteActivityEvidenceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteActivityEvidenceResponse create() =>
      DeleteActivityEvidenceResponse._();
  @$core.override
  DeleteActivityEvidenceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteActivityEvidenceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteActivityEvidenceResponse>(create);
  static DeleteActivityEvidenceResponse? _defaultInstance;
}

class FieldServiceApi {
  final $pb.RpcClient _client;

  FieldServiceApi(this._client);

  /// Field CRUD
  $async.Future<CreateFieldResponse> createField(
          $pb.ClientContext? ctx, CreateFieldRequest request) =>
      _client.invoke<CreateFieldResponse>(
          ctx, 'FieldService', 'CreateField', request, CreateFieldResponse());
  $async.Future<GetFieldResponse> getField_(
          $pb.ClientContext? ctx, GetFieldRequest request) =>
      _client.invoke<GetFieldResponse>(
          ctx, 'FieldService', 'GetField', request, GetFieldResponse());
  $async.Future<ListFieldsResponse> listFields(
          $pb.ClientContext? ctx, ListFieldsRequest request) =>
      _client.invoke<ListFieldsResponse>(
          ctx, 'FieldService', 'ListFields', request, ListFieldsResponse());
  $async.Future<UpdateFieldResponse> updateField(
          $pb.ClientContext? ctx, UpdateFieldRequest request) =>
      _client.invoke<UpdateFieldResponse>(
          ctx, 'FieldService', 'UpdateField', request, UpdateFieldResponse());
  $async.Future<DeleteFieldResponse> deleteField(
          $pb.ClientContext? ctx, DeleteFieldRequest request) =>
      _client.invoke<DeleteFieldResponse>(
          ctx, 'FieldService', 'DeleteField', request, DeleteFieldResponse());
  $async.Future<SetFieldBoundaryResponse> setFieldBoundary(
          $pb.ClientContext? ctx, SetFieldBoundaryRequest request) =>
      _client.invoke<SetFieldBoundaryResponse>(ctx, 'FieldService',
          'SetFieldBoundary', request, SetFieldBoundaryResponse());
  $async.Future<AssignCropResponse> assignCrop(
          $pb.ClientContext? ctx, AssignCropRequest request) =>
      _client.invoke<AssignCropResponse>(
          ctx, 'FieldService', 'AssignCrop', request, AssignCropResponse());
  $async.Future<ListFieldsByFarmResponse> listFieldsByFarm(
          $pb.ClientContext? ctx, ListFieldsByFarmRequest request) =>
      _client.invoke<ListFieldsByFarmResponse>(ctx, 'FieldService',
          'ListFieldsByFarm', request, ListFieldsByFarmResponse());
  $async.Future<SegmentFieldResponse> segmentField(
          $pb.ClientContext? ctx, SegmentFieldRequest request) =>
      _client.invoke<SegmentFieldResponse>(
          ctx, 'FieldService', 'SegmentField', request, SegmentFieldResponse());
  $async.Future<GetFieldSegmentsResponse> getFieldSegments(
          $pb.ClientContext? ctx, GetFieldSegmentsRequest request) =>
      _client.invoke<GetFieldSegmentsResponse>(ctx, 'FieldService',
          'GetFieldSegments', request, GetFieldSegmentsResponse());
  $async.Future<GetCropHistoryResponse> getCropHistory(
          $pb.ClientContext? ctx, GetCropHistoryRequest request) =>
      _client.invoke<GetCropHistoryResponse>(ctx, 'FieldService',
          'GetCropHistory', request, GetCropHistoryResponse());

  /// Crop Cycles
  $async.Future<CreateCropCycleResponse> createCropCycle(
          $pb.ClientContext? ctx, CreateCropCycleRequest request) =>
      _client.invoke<CreateCropCycleResponse>(ctx, 'FieldService',
          'CreateCropCycle', request, CreateCropCycleResponse());
  $async.Future<GetCropCycleResponse> getCropCycle(
          $pb.ClientContext? ctx, GetCropCycleRequest request) =>
      _client.invoke<GetCropCycleResponse>(
          ctx, 'FieldService', 'GetCropCycle', request, GetCropCycleResponse());
  $async.Future<ListCropCyclesResponse> listCropCycles(
          $pb.ClientContext? ctx, ListCropCyclesRequest request) =>
      _client.invoke<ListCropCyclesResponse>(ctx, 'FieldService',
          'ListCropCycles', request, ListCropCyclesResponse());
  $async.Future<UpdateCropCycleResponse> updateCropCycle(
          $pb.ClientContext? ctx, UpdateCropCycleRequest request) =>
      _client.invoke<UpdateCropCycleResponse>(ctx, 'FieldService',
          'UpdateCropCycle', request, UpdateCropCycleResponse());

  /// Activity Events
  $async.Future<LogActivityEventResponse> logActivityEvent(
          $pb.ClientContext? ctx, LogActivityEventRequest request) =>
      _client.invoke<LogActivityEventResponse>(ctx, 'FieldService',
          'LogActivityEvent', request, LogActivityEventResponse());
  $async.Future<ListActivityEventsResponse> listActivityEvents(
          $pb.ClientContext? ctx, ListActivityEventsRequest request) =>
      _client.invoke<ListActivityEventsResponse>(ctx, 'FieldService',
          'ListActivityEvents', request, ListActivityEventsResponse());

  /// Activity Evidence
  $async.Future<AddActivityEvidenceResponse> addActivityEvidence(
          $pb.ClientContext? ctx, AddActivityEvidenceRequest request) =>
      _client.invoke<AddActivityEvidenceResponse>(ctx, 'FieldService',
          'AddActivityEvidence', request, AddActivityEvidenceResponse());
  $async.Future<ListActivityEvidenceResponse> listActivityEvidence(
          $pb.ClientContext? ctx, ListActivityEvidenceRequest request) =>
      _client.invoke<ListActivityEvidenceResponse>(ctx, 'FieldService',
          'ListActivityEvidence', request, ListActivityEvidenceResponse());
  $async.Future<DeleteActivityEvidenceResponse> deleteActivityEvidence(
          $pb.ClientContext? ctx, DeleteActivityEvidenceRequest request) =>
      _client.invoke<DeleteActivityEvidenceResponse>(ctx, 'FieldService',
          'DeleteActivityEvidence', request, DeleteActivityEvidenceResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
