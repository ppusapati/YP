// This is a generated file - do not edit.
//
// Generated from farm.proto.

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

import 'farm.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'farm.pbenum.dart';

/// FarmLocation represents the geographic coordinates of a farm.
class FarmLocation extends $pb.GeneratedMessage {
  factory FarmLocation({
    $core.double? latitude,
    $core.double? longitude,
    $core.double? elevationMeters,
  }) {
    final result = create();
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (elevationMeters != null) result.elevationMeters = elevationMeters;
    return result;
  }

  FarmLocation._();

  factory FarmLocation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FarmLocation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FarmLocation',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'latitude')
    ..aD(2, _omitFieldNames ? '' : 'longitude')
    ..aD(3, _omitFieldNames ? '' : 'elevationMeters')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FarmLocation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FarmLocation copyWith(void Function(FarmLocation) updates) =>
      super.copyWith((message) => updates(message as FarmLocation))
          as FarmLocation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FarmLocation create() => FarmLocation._();
  @$core.override
  FarmLocation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FarmLocation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FarmLocation>(create);
  static FarmLocation? _defaultInstance;

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
  $core.double get elevationMeters => $_getN(2);
  @$pb.TagNumber(3)
  set elevationMeters($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasElevationMeters() => $_has(2);
  @$pb.TagNumber(3)
  void clearElevationMeters() => $_clearField(3);
}

/// FarmBoundary represents the geographic boundary of a farm as a GeoJSON polygon.
class FarmBoundary extends $pb.GeneratedMessage {
  factory FarmBoundary({
    $core.String? id,
    $core.String? farmId,
    $core.String? geojson,
    $core.double? areaHectares,
    $core.double? perimeterMeters,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (farmId != null) result.farmId = farmId;
    if (geojson != null) result.geojson = geojson;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (perimeterMeters != null) result.perimeterMeters = perimeterMeters;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  FarmBoundary._();

  factory FarmBoundary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FarmBoundary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FarmBoundary',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aOS(3, _omitFieldNames ? '' : 'geojson')
    ..aD(4, _omitFieldNames ? '' : 'areaHectares')
    ..aD(5, _omitFieldNames ? '' : 'perimeterMeters')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FarmBoundary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FarmBoundary copyWith(void Function(FarmBoundary) updates) =>
      super.copyWith((message) => updates(message as FarmBoundary))
          as FarmBoundary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FarmBoundary create() => FarmBoundary._();
  @$core.override
  FarmBoundary createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FarmBoundary getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FarmBoundary>(create);
  static FarmBoundary? _defaultInstance;

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

  /// GeoJSON polygon representation of the farm boundary.
  @$pb.TagNumber(3)
  $core.String get geojson => $_getSZ(2);
  @$pb.TagNumber(3)
  set geojson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGeojson() => $_has(2);
  @$pb.TagNumber(3)
  void clearGeojson() => $_clearField(3);

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
  $0.Timestamp get createdAt => $_getN(5);
  @$pb.TagNumber(6)
  set createdAt($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureCreatedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Timestamp get updatedAt => $_getN(6);
  @$pb.TagNumber(7)
  set updatedAt($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasUpdatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearUpdatedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureUpdatedAt() => $_ensure(6);
}

/// FarmOwner represents the owner of a farm.
class FarmOwner extends $pb.GeneratedMessage {
  factory FarmOwner({
    $core.String? id,
    $core.String? farmId,
    $core.String? userId,
    $core.String? ownerName,
    $core.String? email,
    $core.String? phone,
    $core.bool? isPrimary,
    $core.double? ownershipPercentage,
    $0.Timestamp? acquiredAt,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (farmId != null) result.farmId = farmId;
    if (userId != null) result.userId = userId;
    if (ownerName != null) result.ownerName = ownerName;
    if (email != null) result.email = email;
    if (phone != null) result.phone = phone;
    if (isPrimary != null) result.isPrimary = isPrimary;
    if (ownershipPercentage != null)
      result.ownershipPercentage = ownershipPercentage;
    if (acquiredAt != null) result.acquiredAt = acquiredAt;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  FarmOwner._();

  factory FarmOwner.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FarmOwner.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FarmOwner',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aOS(3, _omitFieldNames ? '' : 'userId')
    ..aOS(4, _omitFieldNames ? '' : 'ownerName')
    ..aOS(5, _omitFieldNames ? '' : 'email')
    ..aOS(6, _omitFieldNames ? '' : 'phone')
    ..aOB(7, _omitFieldNames ? '' : 'isPrimary')
    ..aD(8, _omitFieldNames ? '' : 'ownershipPercentage')
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'acquiredAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FarmOwner clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FarmOwner copyWith(void Function(FarmOwner) updates) =>
      super.copyWith((message) => updates(message as FarmOwner)) as FarmOwner;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FarmOwner create() => FarmOwner._();
  @$core.override
  FarmOwner createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FarmOwner getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FarmOwner>(create);
  static FarmOwner? _defaultInstance;

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

  @$pb.TagNumber(3)
  $core.String get userId => $_getSZ(2);
  @$pb.TagNumber(3)
  set userId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get ownerName => $_getSZ(3);
  @$pb.TagNumber(4)
  set ownerName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOwnerName() => $_has(3);
  @$pb.TagNumber(4)
  void clearOwnerName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get email => $_getSZ(4);
  @$pb.TagNumber(5)
  set email($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEmail() => $_has(4);
  @$pb.TagNumber(5)
  void clearEmail() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get phone => $_getSZ(5);
  @$pb.TagNumber(6)
  set phone($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPhone() => $_has(5);
  @$pb.TagNumber(6)
  void clearPhone() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isPrimary => $_getBF(6);
  @$pb.TagNumber(7)
  set isPrimary($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsPrimary() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsPrimary() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get ownershipPercentage => $_getN(7);
  @$pb.TagNumber(8)
  set ownershipPercentage($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasOwnershipPercentage() => $_has(7);
  @$pb.TagNumber(8)
  void clearOwnershipPercentage() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get acquiredAt => $_getN(8);
  @$pb.TagNumber(9)
  set acquiredAt($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasAcquiredAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearAcquiredAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureAcquiredAt() => $_ensure(8);

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

/// Farm represents a registered farm.
class Farm extends $pb.GeneratedMessage {
  factory Farm({
    $core.String? id,
    $core.String? tenantId,
    $core.String? name,
    $core.String? description,
    $core.double? totalAreaHectares,
    FarmLocation? location,
    FarmType? farmType,
    FarmStatus? status,
    SoilType? soilType,
    ClimateZone? climateZone,
    $core.double? elevationMeters,
    $core.String? address,
    $core.String? region,
    $core.String? country,
    FarmBoundary? boundary,
    $core.Iterable<FarmOwner>? owners,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
    $fixnum.Int64? version,
    $core.String? createdBy,
    $core.String? updatedBy,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (totalAreaHectares != null) result.totalAreaHectares = totalAreaHectares;
    if (location != null) result.location = location;
    if (farmType != null) result.farmType = farmType;
    if (status != null) result.status = status;
    if (soilType != null) result.soilType = soilType;
    if (climateZone != null) result.climateZone = climateZone;
    if (elevationMeters != null) result.elevationMeters = elevationMeters;
    if (address != null) result.address = address;
    if (region != null) result.region = region;
    if (country != null) result.country = country;
    if (boundary != null) result.boundary = boundary;
    if (owners != null) result.owners.addAll(owners);
    if (metadata != null) result.metadata.addEntries(metadata);
    if (version != null) result.version = version;
    if (createdBy != null) result.createdBy = createdBy;
    if (updatedBy != null) result.updatedBy = updatedBy;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  Farm._();

  factory Farm.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Farm.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Farm',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aD(5, _omitFieldNames ? '' : 'totalAreaHectares')
    ..aOM<FarmLocation>(6, _omitFieldNames ? '' : 'location',
        subBuilder: FarmLocation.create)
    ..aE<FarmType>(7, _omitFieldNames ? '' : 'farmType',
        enumValues: FarmType.values)
    ..aE<FarmStatus>(8, _omitFieldNames ? '' : 'status',
        enumValues: FarmStatus.values)
    ..aE<SoilType>(9, _omitFieldNames ? '' : 'soilType',
        enumValues: SoilType.values)
    ..aE<ClimateZone>(10, _omitFieldNames ? '' : 'climateZone',
        enumValues: ClimateZone.values)
    ..aD(11, _omitFieldNames ? '' : 'elevationMeters')
    ..aOS(12, _omitFieldNames ? '' : 'address')
    ..aOS(13, _omitFieldNames ? '' : 'region')
    ..aOS(14, _omitFieldNames ? '' : 'country')
    ..aOM<FarmBoundary>(15, _omitFieldNames ? '' : 'boundary',
        subBuilder: FarmBoundary.create)
    ..pPM<FarmOwner>(16, _omitFieldNames ? '' : 'owners',
        subBuilder: FarmOwner.create)
    ..m<$core.String, $core.String>(17, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'Farm.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.farm.v1'))
    ..aInt64(18, _omitFieldNames ? '' : 'version')
    ..aOS(19, _omitFieldNames ? '' : 'createdBy')
    ..aOS(20, _omitFieldNames ? '' : 'updatedBy')
    ..aOM<$0.Timestamp>(21, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(22, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Farm clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Farm copyWith(void Function(Farm) updates) =>
      super.copyWith((message) => updates(message as Farm)) as Farm;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Farm create() => Farm._();
  @$core.override
  Farm createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Farm getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Farm>(create);
  static Farm? _defaultInstance;

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
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get totalAreaHectares => $_getN(4);
  @$pb.TagNumber(5)
  set totalAreaHectares($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalAreaHectares() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalAreaHectares() => $_clearField(5);

  @$pb.TagNumber(6)
  FarmLocation get location => $_getN(5);
  @$pb.TagNumber(6)
  set location(FarmLocation value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasLocation() => $_has(5);
  @$pb.TagNumber(6)
  void clearLocation() => $_clearField(6);
  @$pb.TagNumber(6)
  FarmLocation ensureLocation() => $_ensure(5);

  @$pb.TagNumber(7)
  FarmType get farmType => $_getN(6);
  @$pb.TagNumber(7)
  set farmType(FarmType value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasFarmType() => $_has(6);
  @$pb.TagNumber(7)
  void clearFarmType() => $_clearField(7);

  @$pb.TagNumber(8)
  FarmStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(FarmStatus value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(9)
  SoilType get soilType => $_getN(8);
  @$pb.TagNumber(9)
  set soilType(SoilType value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasSoilType() => $_has(8);
  @$pb.TagNumber(9)
  void clearSoilType() => $_clearField(9);

  @$pb.TagNumber(10)
  ClimateZone get climateZone => $_getN(9);
  @$pb.TagNumber(10)
  set climateZone(ClimateZone value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasClimateZone() => $_has(9);
  @$pb.TagNumber(10)
  void clearClimateZone() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get elevationMeters => $_getN(10);
  @$pb.TagNumber(11)
  set elevationMeters($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasElevationMeters() => $_has(10);
  @$pb.TagNumber(11)
  void clearElevationMeters() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get address => $_getSZ(11);
  @$pb.TagNumber(12)
  set address($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasAddress() => $_has(11);
  @$pb.TagNumber(12)
  void clearAddress() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get region => $_getSZ(12);
  @$pb.TagNumber(13)
  set region($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasRegion() => $_has(12);
  @$pb.TagNumber(13)
  void clearRegion() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get country => $_getSZ(13);
  @$pb.TagNumber(14)
  set country($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasCountry() => $_has(13);
  @$pb.TagNumber(14)
  void clearCountry() => $_clearField(14);

  @$pb.TagNumber(15)
  FarmBoundary get boundary => $_getN(14);
  @$pb.TagNumber(15)
  set boundary(FarmBoundary value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasBoundary() => $_has(14);
  @$pb.TagNumber(15)
  void clearBoundary() => $_clearField(15);
  @$pb.TagNumber(15)
  FarmBoundary ensureBoundary() => $_ensure(14);

  @$pb.TagNumber(16)
  $pb.PbList<FarmOwner> get owners => $_getList(15);

  @$pb.TagNumber(17)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(16);

  @$pb.TagNumber(18)
  $fixnum.Int64 get version => $_getI64(17);
  @$pb.TagNumber(18)
  set version($fixnum.Int64 value) => $_setInt64(17, value);
  @$pb.TagNumber(18)
  $core.bool hasVersion() => $_has(17);
  @$pb.TagNumber(18)
  void clearVersion() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get createdBy => $_getSZ(18);
  @$pb.TagNumber(19)
  set createdBy($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasCreatedBy() => $_has(18);
  @$pb.TagNumber(19)
  void clearCreatedBy() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get updatedBy => $_getSZ(19);
  @$pb.TagNumber(20)
  set updatedBy($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasUpdatedBy() => $_has(19);
  @$pb.TagNumber(20)
  void clearUpdatedBy() => $_clearField(20);

  @$pb.TagNumber(21)
  $0.Timestamp get createdAt => $_getN(20);
  @$pb.TagNumber(21)
  set createdAt($0.Timestamp value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasCreatedAt() => $_has(20);
  @$pb.TagNumber(21)
  void clearCreatedAt() => $_clearField(21);
  @$pb.TagNumber(21)
  $0.Timestamp ensureCreatedAt() => $_ensure(20);

  @$pb.TagNumber(22)
  $0.Timestamp get updatedAt => $_getN(21);
  @$pb.TagNumber(22)
  set updatedAt($0.Timestamp value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasUpdatedAt() => $_has(21);
  @$pb.TagNumber(22)
  void clearUpdatedAt() => $_clearField(22);
  @$pb.TagNumber(22)
  $0.Timestamp ensureUpdatedAt() => $_ensure(21);
}

class CreateFarmRequest extends $pb.GeneratedMessage {
  factory CreateFarmRequest({
    $core.String? name,
    $core.String? description,
    $core.double? totalAreaHectares,
    FarmLocation? location,
    FarmType? farmType,
    SoilType? soilType,
    ClimateZone? climateZone,
    $core.double? elevationMeters,
    $core.String? address,
    $core.String? region,
    $core.String? country,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
    FarmOwner? owner,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (totalAreaHectares != null) result.totalAreaHectares = totalAreaHectares;
    if (location != null) result.location = location;
    if (farmType != null) result.farmType = farmType;
    if (soilType != null) result.soilType = soilType;
    if (climateZone != null) result.climateZone = climateZone;
    if (elevationMeters != null) result.elevationMeters = elevationMeters;
    if (address != null) result.address = address;
    if (region != null) result.region = region;
    if (country != null) result.country = country;
    if (metadata != null) result.metadata.addEntries(metadata);
    if (owner != null) result.owner = owner;
    return result;
  }

  CreateFarmRequest._();

  factory CreateFarmRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateFarmRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateFarmRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aD(3, _omitFieldNames ? '' : 'totalAreaHectares')
    ..aOM<FarmLocation>(4, _omitFieldNames ? '' : 'location',
        subBuilder: FarmLocation.create)
    ..aE<FarmType>(5, _omitFieldNames ? '' : 'farmType',
        enumValues: FarmType.values)
    ..aE<SoilType>(6, _omitFieldNames ? '' : 'soilType',
        enumValues: SoilType.values)
    ..aE<ClimateZone>(7, _omitFieldNames ? '' : 'climateZone',
        enumValues: ClimateZone.values)
    ..aD(8, _omitFieldNames ? '' : 'elevationMeters')
    ..aOS(9, _omitFieldNames ? '' : 'address')
    ..aOS(10, _omitFieldNames ? '' : 'region')
    ..aOS(11, _omitFieldNames ? '' : 'country')
    ..m<$core.String, $core.String>(12, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'CreateFarmRequest.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.farm.v1'))
    ..aOM<FarmOwner>(13, _omitFieldNames ? '' : 'owner',
        subBuilder: FarmOwner.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFarmRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFarmRequest copyWith(void Function(CreateFarmRequest) updates) =>
      super.copyWith((message) => updates(message as CreateFarmRequest))
          as CreateFarmRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateFarmRequest create() => CreateFarmRequest._();
  @$core.override
  CreateFarmRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateFarmRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateFarmRequest>(create);
  static CreateFarmRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get totalAreaHectares => $_getN(2);
  @$pb.TagNumber(3)
  set totalAreaHectares($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalAreaHectares() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalAreaHectares() => $_clearField(3);

  @$pb.TagNumber(4)
  FarmLocation get location => $_getN(3);
  @$pb.TagNumber(4)
  set location(FarmLocation value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLocation() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocation() => $_clearField(4);
  @$pb.TagNumber(4)
  FarmLocation ensureLocation() => $_ensure(3);

  @$pb.TagNumber(5)
  FarmType get farmType => $_getN(4);
  @$pb.TagNumber(5)
  set farmType(FarmType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasFarmType() => $_has(4);
  @$pb.TagNumber(5)
  void clearFarmType() => $_clearField(5);

  @$pb.TagNumber(6)
  SoilType get soilType => $_getN(5);
  @$pb.TagNumber(6)
  set soilType(SoilType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSoilType() => $_has(5);
  @$pb.TagNumber(6)
  void clearSoilType() => $_clearField(6);

  @$pb.TagNumber(7)
  ClimateZone get climateZone => $_getN(6);
  @$pb.TagNumber(7)
  set climateZone(ClimateZone value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasClimateZone() => $_has(6);
  @$pb.TagNumber(7)
  void clearClimateZone() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get elevationMeters => $_getN(7);
  @$pb.TagNumber(8)
  set elevationMeters($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasElevationMeters() => $_has(7);
  @$pb.TagNumber(8)
  void clearElevationMeters() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get address => $_getSZ(8);
  @$pb.TagNumber(9)
  set address($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasAddress() => $_has(8);
  @$pb.TagNumber(9)
  void clearAddress() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get region => $_getSZ(9);
  @$pb.TagNumber(10)
  set region($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRegion() => $_has(9);
  @$pb.TagNumber(10)
  void clearRegion() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get country => $_getSZ(10);
  @$pb.TagNumber(11)
  set country($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCountry() => $_has(10);
  @$pb.TagNumber(11)
  void clearCountry() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(11);

  @$pb.TagNumber(13)
  FarmOwner get owner => $_getN(12);
  @$pb.TagNumber(13)
  set owner(FarmOwner value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasOwner() => $_has(12);
  @$pb.TagNumber(13)
  void clearOwner() => $_clearField(13);
  @$pb.TagNumber(13)
  FarmOwner ensureOwner() => $_ensure(12);
}

class CreateFarmResponse extends $pb.GeneratedMessage {
  factory CreateFarmResponse({
    Farm? farm,
  }) {
    final result = create();
    if (farm != null) result.farm = farm;
    return result;
  }

  CreateFarmResponse._();

  factory CreateFarmResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateFarmResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateFarmResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOM<Farm>(1, _omitFieldNames ? '' : 'farm', subBuilder: Farm.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFarmResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateFarmResponse copyWith(void Function(CreateFarmResponse) updates) =>
      super.copyWith((message) => updates(message as CreateFarmResponse))
          as CreateFarmResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateFarmResponse create() => CreateFarmResponse._();
  @$core.override
  CreateFarmResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateFarmResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateFarmResponse>(create);
  static CreateFarmResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Farm get farm => $_getN(0);
  @$pb.TagNumber(1)
  set farm(Farm value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFarm() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarm() => $_clearField(1);
  @$pb.TagNumber(1)
  Farm ensureFarm() => $_ensure(0);
}

class GetFarmRequest extends $pb.GeneratedMessage {
  factory GetFarmRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetFarmRequest._();

  factory GetFarmRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFarmRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFarmRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFarmRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFarmRequest copyWith(void Function(GetFarmRequest) updates) =>
      super.copyWith((message) => updates(message as GetFarmRequest))
          as GetFarmRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFarmRequest create() => GetFarmRequest._();
  @$core.override
  GetFarmRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFarmRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFarmRequest>(create);
  static GetFarmRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetFarmResponse extends $pb.GeneratedMessage {
  factory GetFarmResponse({
    Farm? farm,
  }) {
    final result = create();
    if (farm != null) result.farm = farm;
    return result;
  }

  GetFarmResponse._();

  factory GetFarmResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFarmResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFarmResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOM<Farm>(1, _omitFieldNames ? '' : 'farm', subBuilder: Farm.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFarmResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFarmResponse copyWith(void Function(GetFarmResponse) updates) =>
      super.copyWith((message) => updates(message as GetFarmResponse))
          as GetFarmResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFarmResponse create() => GetFarmResponse._();
  @$core.override
  GetFarmResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFarmResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFarmResponse>(create);
  static GetFarmResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Farm get farm => $_getN(0);
  @$pb.TagNumber(1)
  set farm(Farm value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFarm() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarm() => $_clearField(1);
  @$pb.TagNumber(1)
  Farm ensureFarm() => $_ensure(0);
}

class ListFarmsRequest extends $pb.GeneratedMessage {
  factory ListFarmsRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    FarmType? farmType,
    FarmStatus? status,
    $core.String? region,
    $core.String? country,
    ClimateZone? climateZone,
    $core.String? search,
    $core.String? orderBy,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (farmType != null) result.farmType = farmType;
    if (status != null) result.status = status;
    if (region != null) result.region = region;
    if (country != null) result.country = country;
    if (climateZone != null) result.climateZone = climateZone;
    if (search != null) result.search = search;
    if (orderBy != null) result.orderBy = orderBy;
    return result;
  }

  ListFarmsRequest._();

  factory ListFarmsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListFarmsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFarmsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aE<FarmType>(3, _omitFieldNames ? '' : 'farmType',
        enumValues: FarmType.values)
    ..aE<FarmStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: FarmStatus.values)
    ..aOS(5, _omitFieldNames ? '' : 'region')
    ..aOS(6, _omitFieldNames ? '' : 'country')
    ..aE<ClimateZone>(7, _omitFieldNames ? '' : 'climateZone',
        enumValues: ClimateZone.values)
    ..aOS(8, _omitFieldNames ? '' : 'search')
    ..aOS(9, _omitFieldNames ? '' : 'orderBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFarmsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFarmsRequest copyWith(void Function(ListFarmsRequest) updates) =>
      super.copyWith((message) => updates(message as ListFarmsRequest))
          as ListFarmsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFarmsRequest create() => ListFarmsRequest._();
  @$core.override
  ListFarmsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListFarmsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFarmsRequest>(create);
  static ListFarmsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set pageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  FarmType get farmType => $_getN(2);
  @$pb.TagNumber(3)
  set farmType(FarmType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmType() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmType() => $_clearField(3);

  @$pb.TagNumber(4)
  FarmStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(FarmStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get region => $_getSZ(4);
  @$pb.TagNumber(5)
  set region($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRegion() => $_has(4);
  @$pb.TagNumber(5)
  void clearRegion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get country => $_getSZ(5);
  @$pb.TagNumber(6)
  set country($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCountry() => $_has(5);
  @$pb.TagNumber(6)
  void clearCountry() => $_clearField(6);

  @$pb.TagNumber(7)
  ClimateZone get climateZone => $_getN(6);
  @$pb.TagNumber(7)
  set climateZone(ClimateZone value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasClimateZone() => $_has(6);
  @$pb.TagNumber(7)
  void clearClimateZone() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get search => $_getSZ(7);
  @$pb.TagNumber(8)
  set search($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSearch() => $_has(7);
  @$pb.TagNumber(8)
  void clearSearch() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get orderBy => $_getSZ(8);
  @$pb.TagNumber(9)
  set orderBy($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOrderBy() => $_has(8);
  @$pb.TagNumber(9)
  void clearOrderBy() => $_clearField(9);
}

class ListFarmsResponse extends $pb.GeneratedMessage {
  factory ListFarmsResponse({
    $core.Iterable<Farm>? farms,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (farms != null) result.farms.addAll(farms);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListFarmsResponse._();

  factory ListFarmsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListFarmsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFarmsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..pPM<Farm>(1, _omitFieldNames ? '' : 'farms', subBuilder: Farm.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFarmsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFarmsResponse copyWith(void Function(ListFarmsResponse) updates) =>
      super.copyWith((message) => updates(message as ListFarmsResponse))
          as ListFarmsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFarmsResponse create() => ListFarmsResponse._();
  @$core.override
  ListFarmsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListFarmsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFarmsResponse>(create);
  static ListFarmsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Farm> get farms => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class UpdateFarmRequest extends $pb.GeneratedMessage {
  factory UpdateFarmRequest({
    $core.String? id,
    $core.String? name,
    $core.String? description,
    $core.double? totalAreaHectares,
    FarmLocation? location,
    FarmType? farmType,
    FarmStatus? status,
    SoilType? soilType,
    ClimateZone? climateZone,
    $core.double? elevationMeters,
    $core.String? address,
    $core.String? region,
    $core.String? country,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
    $1.FieldMask? updateMask,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (totalAreaHectares != null) result.totalAreaHectares = totalAreaHectares;
    if (location != null) result.location = location;
    if (farmType != null) result.farmType = farmType;
    if (status != null) result.status = status;
    if (soilType != null) result.soilType = soilType;
    if (climateZone != null) result.climateZone = climateZone;
    if (elevationMeters != null) result.elevationMeters = elevationMeters;
    if (address != null) result.address = address;
    if (region != null) result.region = region;
    if (country != null) result.country = country;
    if (metadata != null) result.metadata.addEntries(metadata);
    if (updateMask != null) result.updateMask = updateMask;
    return result;
  }

  UpdateFarmRequest._();

  factory UpdateFarmRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateFarmRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateFarmRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aD(4, _omitFieldNames ? '' : 'totalAreaHectares')
    ..aOM<FarmLocation>(5, _omitFieldNames ? '' : 'location',
        subBuilder: FarmLocation.create)
    ..aE<FarmType>(6, _omitFieldNames ? '' : 'farmType',
        enumValues: FarmType.values)
    ..aE<FarmStatus>(7, _omitFieldNames ? '' : 'status',
        enumValues: FarmStatus.values)
    ..aE<SoilType>(8, _omitFieldNames ? '' : 'soilType',
        enumValues: SoilType.values)
    ..aE<ClimateZone>(9, _omitFieldNames ? '' : 'climateZone',
        enumValues: ClimateZone.values)
    ..aD(10, _omitFieldNames ? '' : 'elevationMeters')
    ..aOS(11, _omitFieldNames ? '' : 'address')
    ..aOS(12, _omitFieldNames ? '' : 'region')
    ..aOS(13, _omitFieldNames ? '' : 'country')
    ..m<$core.String, $core.String>(14, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'UpdateFarmRequest.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.farm.v1'))
    ..aOM<$1.FieldMask>(15, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $1.FieldMask.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFarmRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFarmRequest copyWith(void Function(UpdateFarmRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateFarmRequest))
          as UpdateFarmRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateFarmRequest create() => UpdateFarmRequest._();
  @$core.override
  UpdateFarmRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateFarmRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateFarmRequest>(create);
  static UpdateFarmRequest? _defaultInstance;

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
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get totalAreaHectares => $_getN(3);
  @$pb.TagNumber(4)
  set totalAreaHectares($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalAreaHectares() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalAreaHectares() => $_clearField(4);

  @$pb.TagNumber(5)
  FarmLocation get location => $_getN(4);
  @$pb.TagNumber(5)
  set location(FarmLocation value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLocation() => $_has(4);
  @$pb.TagNumber(5)
  void clearLocation() => $_clearField(5);
  @$pb.TagNumber(5)
  FarmLocation ensureLocation() => $_ensure(4);

  @$pb.TagNumber(6)
  FarmType get farmType => $_getN(5);
  @$pb.TagNumber(6)
  set farmType(FarmType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasFarmType() => $_has(5);
  @$pb.TagNumber(6)
  void clearFarmType() => $_clearField(6);

  @$pb.TagNumber(7)
  FarmStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status(FarmStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  SoilType get soilType => $_getN(7);
  @$pb.TagNumber(8)
  set soilType(SoilType value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasSoilType() => $_has(7);
  @$pb.TagNumber(8)
  void clearSoilType() => $_clearField(8);

  @$pb.TagNumber(9)
  ClimateZone get climateZone => $_getN(8);
  @$pb.TagNumber(9)
  set climateZone(ClimateZone value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasClimateZone() => $_has(8);
  @$pb.TagNumber(9)
  void clearClimateZone() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get elevationMeters => $_getN(9);
  @$pb.TagNumber(10)
  set elevationMeters($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasElevationMeters() => $_has(9);
  @$pb.TagNumber(10)
  void clearElevationMeters() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get address => $_getSZ(10);
  @$pb.TagNumber(11)
  set address($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAddress() => $_has(10);
  @$pb.TagNumber(11)
  void clearAddress() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get region => $_getSZ(11);
  @$pb.TagNumber(12)
  set region($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasRegion() => $_has(11);
  @$pb.TagNumber(12)
  void clearRegion() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get country => $_getSZ(12);
  @$pb.TagNumber(13)
  set country($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCountry() => $_has(12);
  @$pb.TagNumber(13)
  void clearCountry() => $_clearField(13);

  @$pb.TagNumber(14)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(13);

  @$pb.TagNumber(15)
  $1.FieldMask get updateMask => $_getN(14);
  @$pb.TagNumber(15)
  set updateMask($1.FieldMask value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasUpdateMask() => $_has(14);
  @$pb.TagNumber(15)
  void clearUpdateMask() => $_clearField(15);
  @$pb.TagNumber(15)
  $1.FieldMask ensureUpdateMask() => $_ensure(14);
}

class UpdateFarmResponse extends $pb.GeneratedMessage {
  factory UpdateFarmResponse({
    Farm? farm,
  }) {
    final result = create();
    if (farm != null) result.farm = farm;
    return result;
  }

  UpdateFarmResponse._();

  factory UpdateFarmResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateFarmResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateFarmResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOM<Farm>(1, _omitFieldNames ? '' : 'farm', subBuilder: Farm.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFarmResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateFarmResponse copyWith(void Function(UpdateFarmResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateFarmResponse))
          as UpdateFarmResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateFarmResponse create() => UpdateFarmResponse._();
  @$core.override
  UpdateFarmResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateFarmResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateFarmResponse>(create);
  static UpdateFarmResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Farm get farm => $_getN(0);
  @$pb.TagNumber(1)
  set farm(Farm value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFarm() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarm() => $_clearField(1);
  @$pb.TagNumber(1)
  Farm ensureFarm() => $_ensure(0);
}

class DeleteFarmRequest extends $pb.GeneratedMessage {
  factory DeleteFarmRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteFarmRequest._();

  factory DeleteFarmRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteFarmRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteFarmRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFarmRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFarmRequest copyWith(void Function(DeleteFarmRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteFarmRequest))
          as DeleteFarmRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFarmRequest create() => DeleteFarmRequest._();
  @$core.override
  DeleteFarmRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteFarmRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteFarmRequest>(create);
  static DeleteFarmRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteFarmResponse extends $pb.GeneratedMessage {
  factory DeleteFarmResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  DeleteFarmResponse._();

  factory DeleteFarmResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteFarmResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteFarmResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFarmResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFarmResponse copyWith(void Function(DeleteFarmResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteFarmResponse))
          as DeleteFarmResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFarmResponse create() => DeleteFarmResponse._();
  @$core.override
  DeleteFarmResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteFarmResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteFarmResponse>(create);
  static DeleteFarmResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

class SetFarmBoundaryRequest extends $pb.GeneratedMessage {
  factory SetFarmBoundaryRequest({
    $core.String? farmId,
    $core.String? geojson,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (geojson != null) result.geojson = geojson;
    return result;
  }

  SetFarmBoundaryRequest._();

  factory SetFarmBoundaryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFarmBoundaryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFarmBoundaryRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'geojson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFarmBoundaryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFarmBoundaryRequest copyWith(
          void Function(SetFarmBoundaryRequest) updates) =>
      super.copyWith((message) => updates(message as SetFarmBoundaryRequest))
          as SetFarmBoundaryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFarmBoundaryRequest create() => SetFarmBoundaryRequest._();
  @$core.override
  SetFarmBoundaryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetFarmBoundaryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFarmBoundaryRequest>(create);
  static SetFarmBoundaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get geojson => $_getSZ(1);
  @$pb.TagNumber(2)
  set geojson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGeojson() => $_has(1);
  @$pb.TagNumber(2)
  void clearGeojson() => $_clearField(2);
}

class SetFarmBoundaryResponse extends $pb.GeneratedMessage {
  factory SetFarmBoundaryResponse({
    FarmBoundary? boundary,
  }) {
    final result = create();
    if (boundary != null) result.boundary = boundary;
    return result;
  }

  SetFarmBoundaryResponse._();

  factory SetFarmBoundaryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetFarmBoundaryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetFarmBoundaryResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOM<FarmBoundary>(1, _omitFieldNames ? '' : 'boundary',
        subBuilder: FarmBoundary.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFarmBoundaryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFarmBoundaryResponse copyWith(
          void Function(SetFarmBoundaryResponse) updates) =>
      super.copyWith((message) => updates(message as SetFarmBoundaryResponse))
          as SetFarmBoundaryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetFarmBoundaryResponse create() => SetFarmBoundaryResponse._();
  @$core.override
  SetFarmBoundaryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetFarmBoundaryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFarmBoundaryResponse>(create);
  static SetFarmBoundaryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FarmBoundary get boundary => $_getN(0);
  @$pb.TagNumber(1)
  set boundary(FarmBoundary value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBoundary() => $_has(0);
  @$pb.TagNumber(1)
  void clearBoundary() => $_clearField(1);
  @$pb.TagNumber(1)
  FarmBoundary ensureBoundary() => $_ensure(0);
}

class GetFarmBoundaryRequest extends $pb.GeneratedMessage {
  factory GetFarmBoundaryRequest({
    $core.String? farmId,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    return result;
  }

  GetFarmBoundaryRequest._();

  factory GetFarmBoundaryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFarmBoundaryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFarmBoundaryRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFarmBoundaryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFarmBoundaryRequest copyWith(
          void Function(GetFarmBoundaryRequest) updates) =>
      super.copyWith((message) => updates(message as GetFarmBoundaryRequest))
          as GetFarmBoundaryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFarmBoundaryRequest create() => GetFarmBoundaryRequest._();
  @$core.override
  GetFarmBoundaryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFarmBoundaryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFarmBoundaryRequest>(create);
  static GetFarmBoundaryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);
}

class GetFarmBoundaryResponse extends $pb.GeneratedMessage {
  factory GetFarmBoundaryResponse({
    FarmBoundary? boundary,
  }) {
    final result = create();
    if (boundary != null) result.boundary = boundary;
    return result;
  }

  GetFarmBoundaryResponse._();

  factory GetFarmBoundaryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFarmBoundaryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFarmBoundaryResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOM<FarmBoundary>(1, _omitFieldNames ? '' : 'boundary',
        subBuilder: FarmBoundary.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFarmBoundaryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFarmBoundaryResponse copyWith(
          void Function(GetFarmBoundaryResponse) updates) =>
      super.copyWith((message) => updates(message as GetFarmBoundaryResponse))
          as GetFarmBoundaryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFarmBoundaryResponse create() => GetFarmBoundaryResponse._();
  @$core.override
  GetFarmBoundaryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFarmBoundaryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFarmBoundaryResponse>(create);
  static GetFarmBoundaryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FarmBoundary get boundary => $_getN(0);
  @$pb.TagNumber(1)
  set boundary(FarmBoundary value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBoundary() => $_has(0);
  @$pb.TagNumber(1)
  void clearBoundary() => $_clearField(1);
  @$pb.TagNumber(1)
  FarmBoundary ensureBoundary() => $_ensure(0);
}

class TransferOwnershipRequest extends $pb.GeneratedMessage {
  factory TransferOwnershipRequest({
    $core.String? farmId,
    $core.String? fromUserId,
    $core.String? toUserId,
    $core.String? toOwnerName,
    $core.String? toEmail,
    $core.String? toPhone,
    $core.double? ownershipPercentage,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fromUserId != null) result.fromUserId = fromUserId;
    if (toUserId != null) result.toUserId = toUserId;
    if (toOwnerName != null) result.toOwnerName = toOwnerName;
    if (toEmail != null) result.toEmail = toEmail;
    if (toPhone != null) result.toPhone = toPhone;
    if (ownershipPercentage != null)
      result.ownershipPercentage = ownershipPercentage;
    return result;
  }

  TransferOwnershipRequest._();

  factory TransferOwnershipRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransferOwnershipRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferOwnershipRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fromUserId')
    ..aOS(3, _omitFieldNames ? '' : 'toUserId')
    ..aOS(4, _omitFieldNames ? '' : 'toOwnerName')
    ..aOS(5, _omitFieldNames ? '' : 'toEmail')
    ..aOS(6, _omitFieldNames ? '' : 'toPhone')
    ..aD(7, _omitFieldNames ? '' : 'ownershipPercentage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOwnershipRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOwnershipRequest copyWith(
          void Function(TransferOwnershipRequest) updates) =>
      super.copyWith((message) => updates(message as TransferOwnershipRequest))
          as TransferOwnershipRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferOwnershipRequest create() => TransferOwnershipRequest._();
  @$core.override
  TransferOwnershipRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransferOwnershipRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferOwnershipRequest>(create);
  static TransferOwnershipRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fromUserId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fromUserId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFromUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromUserId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get toUserId => $_getSZ(2);
  @$pb.TagNumber(3)
  set toUserId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToUserId() => $_has(2);
  @$pb.TagNumber(3)
  void clearToUserId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get toOwnerName => $_getSZ(3);
  @$pb.TagNumber(4)
  set toOwnerName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasToOwnerName() => $_has(3);
  @$pb.TagNumber(4)
  void clearToOwnerName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get toEmail => $_getSZ(4);
  @$pb.TagNumber(5)
  set toEmail($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasToEmail() => $_has(4);
  @$pb.TagNumber(5)
  void clearToEmail() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get toPhone => $_getSZ(5);
  @$pb.TagNumber(6)
  set toPhone($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasToPhone() => $_has(5);
  @$pb.TagNumber(6)
  void clearToPhone() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get ownershipPercentage => $_getN(6);
  @$pb.TagNumber(7)
  set ownershipPercentage($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOwnershipPercentage() => $_has(6);
  @$pb.TagNumber(7)
  void clearOwnershipPercentage() => $_clearField(7);
}

class TransferOwnershipResponse extends $pb.GeneratedMessage {
  factory TransferOwnershipResponse({
    Farm? farm,
  }) {
    final result = create();
    if (farm != null) result.farm = farm;
    return result;
  }

  TransferOwnershipResponse._();

  factory TransferOwnershipResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransferOwnershipResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferOwnershipResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.farm.v1'),
      createEmptyInstance: create)
    ..aOM<Farm>(1, _omitFieldNames ? '' : 'farm', subBuilder: Farm.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOwnershipResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOwnershipResponse copyWith(
          void Function(TransferOwnershipResponse) updates) =>
      super.copyWith((message) => updates(message as TransferOwnershipResponse))
          as TransferOwnershipResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferOwnershipResponse create() => TransferOwnershipResponse._();
  @$core.override
  TransferOwnershipResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransferOwnershipResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferOwnershipResponse>(create);
  static TransferOwnershipResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Farm get farm => $_getN(0);
  @$pb.TagNumber(1)
  set farm(Farm value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFarm() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarm() => $_clearField(1);
  @$pb.TagNumber(1)
  Farm ensureFarm() => $_ensure(0);
}

/// FarmService provides farm management operations.
class FarmServiceApi {
  final $pb.RpcClient _client;

  FarmServiceApi(this._client);

  /// CreateFarm registers a new farm.
  $async.Future<CreateFarmResponse> createFarm(
          $pb.ClientContext? ctx, CreateFarmRequest request) =>
      _client.invoke<CreateFarmResponse>(
          ctx, 'FarmService', 'CreateFarm', request, CreateFarmResponse());

  /// GetFarm retrieves a farm by ID.
  $async.Future<GetFarmResponse> getFarm(
          $pb.ClientContext? ctx, GetFarmRequest request) =>
      _client.invoke<GetFarmResponse>(
          ctx, 'FarmService', 'GetFarm', request, GetFarmResponse());

  /// ListFarms lists farms with filtering and pagination.
  $async.Future<ListFarmsResponse> listFarms(
          $pb.ClientContext? ctx, ListFarmsRequest request) =>
      _client.invoke<ListFarmsResponse>(
          ctx, 'FarmService', 'ListFarms', request, ListFarmsResponse());

  /// UpdateFarm updates an existing farm.
  $async.Future<UpdateFarmResponse> updateFarm(
          $pb.ClientContext? ctx, UpdateFarmRequest request) =>
      _client.invoke<UpdateFarmResponse>(
          ctx, 'FarmService', 'UpdateFarm', request, UpdateFarmResponse());

  /// DeleteFarm soft-deletes a farm.
  $async.Future<DeleteFarmResponse> deleteFarm(
          $pb.ClientContext? ctx, DeleteFarmRequest request) =>
      _client.invoke<DeleteFarmResponse>(
          ctx, 'FarmService', 'DeleteFarm', request, DeleteFarmResponse());

  /// SetFarmBoundary sets or updates the geographic boundary of a farm.
  $async.Future<SetFarmBoundaryResponse> setFarmBoundary(
          $pb.ClientContext? ctx, SetFarmBoundaryRequest request) =>
      _client.invoke<SetFarmBoundaryResponse>(ctx, 'FarmService',
          'SetFarmBoundary', request, SetFarmBoundaryResponse());

  /// GetFarmBoundary retrieves the geographic boundary of a farm.
  $async.Future<GetFarmBoundaryResponse> getFarmBoundary(
          $pb.ClientContext? ctx, GetFarmBoundaryRequest request) =>
      _client.invoke<GetFarmBoundaryResponse>(ctx, 'FarmService',
          'GetFarmBoundary', request, GetFarmBoundaryResponse());

  /// TransferOwnership transfers ownership of a farm between users.
  $async.Future<TransferOwnershipResponse> transferOwnership(
          $pb.ClientContext? ctx, TransferOwnershipRequest request) =>
      _client.invoke<TransferOwnershipResponse>(ctx, 'FarmService',
          'TransferOwnership', request, TransferOwnershipResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
