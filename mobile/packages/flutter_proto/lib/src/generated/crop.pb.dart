// This is a generated file - do not edit.
//
// Generated from crop.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/field_mask.pb.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'crop.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'crop.pbenum.dart';

/// GrowthStage represents a single growth stage of a crop's lifecycle.
class GrowthStage extends $pb.GeneratedMessage {
  factory GrowthStage({
    $core.String? id,
    $core.String? cropId,
    $core.String? name,
    $core.int? stageOrder,
    $core.int? durationDays,
    $core.double? waterRequirementMm,
    $core.String? nutrientRequirements,
    $core.String? description,
    $core.double? optimalTempMin,
    $core.double? optimalTempMax,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (cropId != null) result.cropId = cropId;
    if (name != null) result.name = name;
    if (stageOrder != null) result.stageOrder = stageOrder;
    if (durationDays != null) result.durationDays = durationDays;
    if (waterRequirementMm != null)
      result.waterRequirementMm = waterRequirementMm;
    if (nutrientRequirements != null)
      result.nutrientRequirements = nutrientRequirements;
    if (description != null) result.description = description;
    if (optimalTempMin != null) result.optimalTempMin = optimalTempMin;
    if (optimalTempMax != null) result.optimalTempMax = optimalTempMax;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  GrowthStage._();

  factory GrowthStage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GrowthStage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GrowthStage',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'cropId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aI(4, _omitFieldNames ? '' : 'stageOrder')
    ..aI(5, _omitFieldNames ? '' : 'durationDays')
    ..aD(6, _omitFieldNames ? '' : 'waterRequirementMm')
    ..aOS(7, _omitFieldNames ? '' : 'nutrientRequirements')
    ..aOS(8, _omitFieldNames ? '' : 'description')
    ..aD(9, _omitFieldNames ? '' : 'optimalTempMin')
    ..aD(10, _omitFieldNames ? '' : 'optimalTempMax')
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GrowthStage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GrowthStage copyWith(void Function(GrowthStage) updates) =>
      super.copyWith((message) => updates(message as GrowthStage))
          as GrowthStage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GrowthStage create() => GrowthStage._();
  @$core.override
  GrowthStage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GrowthStage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GrowthStage>(create);
  static GrowthStage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cropId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get stageOrder => $_getIZ(3);
  @$pb.TagNumber(4)
  set stageOrder($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStageOrder() => $_has(3);
  @$pb.TagNumber(4)
  void clearStageOrder() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get durationDays => $_getIZ(4);
  @$pb.TagNumber(5)
  set durationDays($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDurationDays() => $_has(4);
  @$pb.TagNumber(5)
  void clearDurationDays() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get waterRequirementMm => $_getN(5);
  @$pb.TagNumber(6)
  set waterRequirementMm($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasWaterRequirementMm() => $_has(5);
  @$pb.TagNumber(6)
  void clearWaterRequirementMm() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get nutrientRequirements => $_getSZ(6);
  @$pb.TagNumber(7)
  set nutrientRequirements($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNutrientRequirements() => $_has(6);
  @$pb.TagNumber(7)
  void clearNutrientRequirements() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get description => $_getSZ(7);
  @$pb.TagNumber(8)
  set description($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDescription() => $_has(7);
  @$pb.TagNumber(8)
  void clearDescription() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get optimalTempMin => $_getN(8);
  @$pb.TagNumber(9)
  set optimalTempMin($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOptimalTempMin() => $_has(8);
  @$pb.TagNumber(9)
  void clearOptimalTempMin() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get optimalTempMax => $_getN(9);
  @$pb.TagNumber(10)
  set optimalTempMax($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasOptimalTempMax() => $_has(9);
  @$pb.TagNumber(10)
  void clearOptimalTempMax() => $_clearField(10);

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

/// CropVariety represents a specific variety of a crop.
class CropVariety extends $pb.GeneratedMessage {
  factory CropVariety({
    $core.String? id,
    $core.String? cropId,
    $core.String? name,
    $core.String? description,
    $core.int? maturityDays,
    $core.double? yieldPotentialKgPerHectare,
    $core.bool? isHybrid,
    $core.String? diseaseResistance,
    $core.String? suitableRegions,
    $core.String? seedRateKgPerHectare,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (cropId != null) result.cropId = cropId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (maturityDays != null) result.maturityDays = maturityDays;
    if (yieldPotentialKgPerHectare != null)
      result.yieldPotentialKgPerHectare = yieldPotentialKgPerHectare;
    if (isHybrid != null) result.isHybrid = isHybrid;
    if (diseaseResistance != null) result.diseaseResistance = diseaseResistance;
    if (suitableRegions != null) result.suitableRegions = suitableRegions;
    if (seedRateKgPerHectare != null)
      result.seedRateKgPerHectare = seedRateKgPerHectare;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  CropVariety._();

  factory CropVariety.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CropVariety.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CropVariety',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'cropId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aI(5, _omitFieldNames ? '' : 'maturityDays')
    ..aD(6, _omitFieldNames ? '' : 'yieldPotentialKgPerHectare')
    ..aOB(7, _omitFieldNames ? '' : 'isHybrid')
    ..aOS(8, _omitFieldNames ? '' : 'diseaseResistance')
    ..aOS(9, _omitFieldNames ? '' : 'suitableRegions')
    ..aOS(10, _omitFieldNames ? '' : 'seedRateKgPerHectare')
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CropVariety clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CropVariety copyWith(void Function(CropVariety) updates) =>
      super.copyWith((message) => updates(message as CropVariety))
          as CropVariety;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CropVariety create() => CropVariety._();
  @$core.override
  CropVariety createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CropVariety getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CropVariety>(create);
  static CropVariety? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cropId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropId() => $_clearField(2);

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
  $core.int get maturityDays => $_getIZ(4);
  @$pb.TagNumber(5)
  set maturityDays($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMaturityDays() => $_has(4);
  @$pb.TagNumber(5)
  void clearMaturityDays() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get yieldPotentialKgPerHectare => $_getN(5);
  @$pb.TagNumber(6)
  set yieldPotentialKgPerHectare($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasYieldPotentialKgPerHectare() => $_has(5);
  @$pb.TagNumber(6)
  void clearYieldPotentialKgPerHectare() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isHybrid => $_getBF(6);
  @$pb.TagNumber(7)
  set isHybrid($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsHybrid() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsHybrid() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get diseaseResistance => $_getSZ(7);
  @$pb.TagNumber(8)
  set diseaseResistance($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDiseaseResistance() => $_has(7);
  @$pb.TagNumber(8)
  void clearDiseaseResistance() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get suitableRegions => $_getSZ(8);
  @$pb.TagNumber(9)
  set suitableRegions($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSuitableRegions() => $_has(8);
  @$pb.TagNumber(9)
  void clearSuitableRegions() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get seedRateKgPerHectare => $_getSZ(9);
  @$pb.TagNumber(10)
  set seedRateKgPerHectare($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSeedRateKgPerHectare() => $_has(9);
  @$pb.TagNumber(10)
  void clearSeedRateKgPerHectare() => $_clearField(10);

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

/// CropRequirements captures the optimal growing conditions for a crop.
class CropRequirements extends $pb.GeneratedMessage {
  factory CropRequirements({
    $core.String? id,
    $core.String? cropId,
    $core.double? optimalTempMin,
    $core.double? optimalTempMax,
    $core.double? optimalHumidityMin,
    $core.double? optimalHumidityMax,
    $core.double? optimalSoilPhMin,
    $core.double? optimalSoilPhMax,
    $core.double? waterRequirementMmPerDay,
    $core.double? sunlightHours,
    $core.bool? frostTolerant,
    $core.bool? droughtTolerant,
    $core.String? soilTypePreference,
    $core.String? nutrientRequirements,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (cropId != null) result.cropId = cropId;
    if (optimalTempMin != null) result.optimalTempMin = optimalTempMin;
    if (optimalTempMax != null) result.optimalTempMax = optimalTempMax;
    if (optimalHumidityMin != null)
      result.optimalHumidityMin = optimalHumidityMin;
    if (optimalHumidityMax != null)
      result.optimalHumidityMax = optimalHumidityMax;
    if (optimalSoilPhMin != null) result.optimalSoilPhMin = optimalSoilPhMin;
    if (optimalSoilPhMax != null) result.optimalSoilPhMax = optimalSoilPhMax;
    if (waterRequirementMmPerDay != null)
      result.waterRequirementMmPerDay = waterRequirementMmPerDay;
    if (sunlightHours != null) result.sunlightHours = sunlightHours;
    if (frostTolerant != null) result.frostTolerant = frostTolerant;
    if (droughtTolerant != null) result.droughtTolerant = droughtTolerant;
    if (soilTypePreference != null)
      result.soilTypePreference = soilTypePreference;
    if (nutrientRequirements != null)
      result.nutrientRequirements = nutrientRequirements;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  CropRequirements._();

  factory CropRequirements.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CropRequirements.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CropRequirements',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'cropId')
    ..aD(3, _omitFieldNames ? '' : 'optimalTempMin')
    ..aD(4, _omitFieldNames ? '' : 'optimalTempMax')
    ..aD(5, _omitFieldNames ? '' : 'optimalHumidityMin')
    ..aD(6, _omitFieldNames ? '' : 'optimalHumidityMax')
    ..aD(7, _omitFieldNames ? '' : 'optimalSoilPhMin')
    ..aD(8, _omitFieldNames ? '' : 'optimalSoilPhMax')
    ..aD(9, _omitFieldNames ? '' : 'waterRequirementMmPerDay')
    ..aD(10, _omitFieldNames ? '' : 'sunlightHours')
    ..aOB(11, _omitFieldNames ? '' : 'frostTolerant')
    ..aOB(12, _omitFieldNames ? '' : 'droughtTolerant')
    ..aOS(13, _omitFieldNames ? '' : 'soilTypePreference')
    ..aOS(14, _omitFieldNames ? '' : 'nutrientRequirements')
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(16, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CropRequirements clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CropRequirements copyWith(void Function(CropRequirements) updates) =>
      super.copyWith((message) => updates(message as CropRequirements))
          as CropRequirements;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CropRequirements create() => CropRequirements._();
  @$core.override
  CropRequirements createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CropRequirements getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CropRequirements>(create);
  static CropRequirements? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cropId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get optimalTempMin => $_getN(2);
  @$pb.TagNumber(3)
  set optimalTempMin($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOptimalTempMin() => $_has(2);
  @$pb.TagNumber(3)
  void clearOptimalTempMin() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get optimalTempMax => $_getN(3);
  @$pb.TagNumber(4)
  set optimalTempMax($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOptimalTempMax() => $_has(3);
  @$pb.TagNumber(4)
  void clearOptimalTempMax() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get optimalHumidityMin => $_getN(4);
  @$pb.TagNumber(5)
  set optimalHumidityMin($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOptimalHumidityMin() => $_has(4);
  @$pb.TagNumber(5)
  void clearOptimalHumidityMin() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get optimalHumidityMax => $_getN(5);
  @$pb.TagNumber(6)
  set optimalHumidityMax($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOptimalHumidityMax() => $_has(5);
  @$pb.TagNumber(6)
  void clearOptimalHumidityMax() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get optimalSoilPhMin => $_getN(6);
  @$pb.TagNumber(7)
  set optimalSoilPhMin($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOptimalSoilPhMin() => $_has(6);
  @$pb.TagNumber(7)
  void clearOptimalSoilPhMin() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get optimalSoilPhMax => $_getN(7);
  @$pb.TagNumber(8)
  set optimalSoilPhMax($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasOptimalSoilPhMax() => $_has(7);
  @$pb.TagNumber(8)
  void clearOptimalSoilPhMax() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get waterRequirementMmPerDay => $_getN(8);
  @$pb.TagNumber(9)
  set waterRequirementMmPerDay($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasWaterRequirementMmPerDay() => $_has(8);
  @$pb.TagNumber(9)
  void clearWaterRequirementMmPerDay() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get sunlightHours => $_getN(9);
  @$pb.TagNumber(10)
  set sunlightHours($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSunlightHours() => $_has(9);
  @$pb.TagNumber(10)
  void clearSunlightHours() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get frostTolerant => $_getBF(10);
  @$pb.TagNumber(11)
  set frostTolerant($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasFrostTolerant() => $_has(10);
  @$pb.TagNumber(11)
  void clearFrostTolerant() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get droughtTolerant => $_getBF(11);
  @$pb.TagNumber(12)
  set droughtTolerant($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasDroughtTolerant() => $_has(11);
  @$pb.TagNumber(12)
  void clearDroughtTolerant() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get soilTypePreference => $_getSZ(12);
  @$pb.TagNumber(13)
  set soilTypePreference($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasSoilTypePreference() => $_has(12);
  @$pb.TagNumber(13)
  void clearSoilTypePreference() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get nutrientRequirements => $_getSZ(13);
  @$pb.TagNumber(14)
  set nutrientRequirements($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasNutrientRequirements() => $_has(13);
  @$pb.TagNumber(14)
  void clearNutrientRequirements() => $_clearField(14);

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

/// CropRecommendation represents an AI-generated recommendation for a crop.
class CropRecommendation extends $pb.GeneratedMessage {
  factory CropRecommendation({
    $core.String? id,
    $core.String? cropId,
    $core.String? tenantId,
    $core.String? recommendationType,
    $core.String? title,
    $core.String? description,
    $core.String? severity,
    $core.double? confidenceScore,
    $core.String? parameters,
    $core.String? applicableGrowthStage,
    $0.Timestamp? validFrom,
    $0.Timestamp? validUntil,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (cropId != null) result.cropId = cropId;
    if (tenantId != null) result.tenantId = tenantId;
    if (recommendationType != null)
      result.recommendationType = recommendationType;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (severity != null) result.severity = severity;
    if (confidenceScore != null) result.confidenceScore = confidenceScore;
    if (parameters != null) result.parameters = parameters;
    if (applicableGrowthStage != null)
      result.applicableGrowthStage = applicableGrowthStage;
    if (validFrom != null) result.validFrom = validFrom;
    if (validUntil != null) result.validUntil = validUntil;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  CropRecommendation._();

  factory CropRecommendation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CropRecommendation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CropRecommendation',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'cropId')
    ..aOS(3, _omitFieldNames ? '' : 'tenantId')
    ..aOS(4, _omitFieldNames ? '' : 'recommendationType')
    ..aOS(5, _omitFieldNames ? '' : 'title')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'severity')
    ..aD(8, _omitFieldNames ? '' : 'confidenceScore')
    ..aOS(9, _omitFieldNames ? '' : 'parameters')
    ..aOS(10, _omitFieldNames ? '' : 'applicableGrowthStage')
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'validFrom',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'validUntil',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CropRecommendation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CropRecommendation copyWith(void Function(CropRecommendation) updates) =>
      super.copyWith((message) => updates(message as CropRecommendation))
          as CropRecommendation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CropRecommendation create() => CropRecommendation._();
  @$core.override
  CropRecommendation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CropRecommendation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CropRecommendation>(create);
  static CropRecommendation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cropId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropId() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tenantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set tenantId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTenantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTenantId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get recommendationType => $_getSZ(3);
  @$pb.TagNumber(4)
  set recommendationType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRecommendationType() => $_has(3);
  @$pb.TagNumber(4)
  void clearRecommendationType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get title => $_getSZ(4);
  @$pb.TagNumber(5)
  set title($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTitle() => $_has(4);
  @$pb.TagNumber(5)
  void clearTitle() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get severity => $_getSZ(6);
  @$pb.TagNumber(7)
  set severity($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSeverity() => $_has(6);
  @$pb.TagNumber(7)
  void clearSeverity() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get confidenceScore => $_getN(7);
  @$pb.TagNumber(8)
  set confidenceScore($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasConfidenceScore() => $_has(7);
  @$pb.TagNumber(8)
  void clearConfidenceScore() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get parameters => $_getSZ(8);
  @$pb.TagNumber(9)
  set parameters($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasParameters() => $_has(8);
  @$pb.TagNumber(9)
  void clearParameters() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get applicableGrowthStage => $_getSZ(9);
  @$pb.TagNumber(10)
  set applicableGrowthStage($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasApplicableGrowthStage() => $_has(9);
  @$pb.TagNumber(10)
  void clearApplicableGrowthStage() => $_clearField(10);

  @$pb.TagNumber(11)
  $0.Timestamp get validFrom => $_getN(10);
  @$pb.TagNumber(11)
  set validFrom($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasValidFrom() => $_has(10);
  @$pb.TagNumber(11)
  void clearValidFrom() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureValidFrom() => $_ensure(10);

  @$pb.TagNumber(12)
  $0.Timestamp get validUntil => $_getN(11);
  @$pb.TagNumber(12)
  set validUntil($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasValidUntil() => $_has(11);
  @$pb.TagNumber(12)
  void clearValidUntil() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureValidUntil() => $_ensure(11);

  @$pb.TagNumber(13)
  $0.Timestamp get createdAt => $_getN(12);
  @$pb.TagNumber(13)
  set createdAt($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasCreatedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearCreatedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureCreatedAt() => $_ensure(12);
}

/// Crop is the main entity representing a crop in the catalog.
class Crop extends $pb.GeneratedMessage {
  factory Crop({
    $core.String? id,
    $core.String? tenantId,
    $core.String? name,
    $core.String? scientificName,
    $core.String? family,
    CropCategory? category,
    $core.String? description,
    $core.String? imageUrl,
    $core.Iterable<$core.String>? diseaseSusceptibilities,
    $core.Iterable<$core.String>? companionPlants,
    $core.String? rotationGroup,
    $core.int? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $core.Iterable<CropVariety>? varieties,
    $core.Iterable<GrowthStage>? growthStages,
    CropRequirements? requirements,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (name != null) result.name = name;
    if (scientificName != null) result.scientificName = scientificName;
    if (family != null) result.family = family;
    if (category != null) result.category = category;
    if (description != null) result.description = description;
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (diseaseSusceptibilities != null)
      result.diseaseSusceptibilities.addAll(diseaseSusceptibilities);
    if (companionPlants != null) result.companionPlants.addAll(companionPlants);
    if (rotationGroup != null) result.rotationGroup = rotationGroup;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (varieties != null) result.varieties.addAll(varieties);
    if (growthStages != null) result.growthStages.addAll(growthStages);
    if (requirements != null) result.requirements = requirements;
    return result;
  }

  Crop._();

  factory Crop.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Crop.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Crop',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'scientificName')
    ..aOS(5, _omitFieldNames ? '' : 'family')
    ..aE<CropCategory>(6, _omitFieldNames ? '' : 'category',
        enumValues: CropCategory.values)
    ..aOS(7, _omitFieldNames ? '' : 'description')
    ..aOS(8, _omitFieldNames ? '' : 'imageUrl')
    ..pPS(9, _omitFieldNames ? '' : 'diseaseSusceptibilities')
    ..pPS(10, _omitFieldNames ? '' : 'companionPlants')
    ..aOS(11, _omitFieldNames ? '' : 'rotationGroup')
    ..aI(12, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..pPM<CropVariety>(15, _omitFieldNames ? '' : 'varieties',
        subBuilder: CropVariety.create)
    ..pPM<GrowthStage>(16, _omitFieldNames ? '' : 'growthStages',
        subBuilder: GrowthStage.create)
    ..aOM<CropRequirements>(17, _omitFieldNames ? '' : 'requirements',
        subBuilder: CropRequirements.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Crop clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Crop copyWith(void Function(Crop) updates) =>
      super.copyWith((message) => updates(message as Crop)) as Crop;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Crop create() => Crop._();
  @$core.override
  Crop createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Crop getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Crop>(create);
  static Crop? _defaultInstance;

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
  $core.String get scientificName => $_getSZ(3);
  @$pb.TagNumber(4)
  set scientificName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasScientificName() => $_has(3);
  @$pb.TagNumber(4)
  void clearScientificName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get family => $_getSZ(4);
  @$pb.TagNumber(5)
  set family($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFamily() => $_has(4);
  @$pb.TagNumber(5)
  void clearFamily() => $_clearField(5);

  @$pb.TagNumber(6)
  CropCategory get category => $_getN(5);
  @$pb.TagNumber(6)
  set category(CropCategory value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCategory() => $_has(5);
  @$pb.TagNumber(6)
  void clearCategory() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get description => $_getSZ(6);
  @$pb.TagNumber(7)
  set description($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDescription() => $_has(6);
  @$pb.TagNumber(7)
  void clearDescription() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get imageUrl => $_getSZ(7);
  @$pb.TagNumber(8)
  set imageUrl($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasImageUrl() => $_has(7);
  @$pb.TagNumber(8)
  void clearImageUrl() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get diseaseSusceptibilities => $_getList(8);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get companionPlants => $_getList(9);

  @$pb.TagNumber(11)
  $core.String get rotationGroup => $_getSZ(10);
  @$pb.TagNumber(11)
  set rotationGroup($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasRotationGroup() => $_has(10);
  @$pb.TagNumber(11)
  void clearRotationGroup() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get version => $_getIZ(11);
  @$pb.TagNumber(12)
  set version($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasVersion() => $_has(11);
  @$pb.TagNumber(12)
  void clearVersion() => $_clearField(12);

  @$pb.TagNumber(13)
  $0.Timestamp get createdAt => $_getN(12);
  @$pb.TagNumber(13)
  set createdAt($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasCreatedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearCreatedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureCreatedAt() => $_ensure(12);

  @$pb.TagNumber(14)
  $0.Timestamp get updatedAt => $_getN(13);
  @$pb.TagNumber(14)
  set updatedAt($0.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasUpdatedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearUpdatedAt() => $_clearField(14);
  @$pb.TagNumber(14)
  $0.Timestamp ensureUpdatedAt() => $_ensure(13);

  /// Nested relations (optionally populated)
  @$pb.TagNumber(15)
  $pb.PbList<CropVariety> get varieties => $_getList(14);

  @$pb.TagNumber(16)
  $pb.PbList<GrowthStage> get growthStages => $_getList(15);

  @$pb.TagNumber(17)
  CropRequirements get requirements => $_getN(16);
  @$pb.TagNumber(17)
  set requirements(CropRequirements value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasRequirements() => $_has(16);
  @$pb.TagNumber(17)
  void clearRequirements() => $_clearField(17);
  @$pb.TagNumber(17)
  CropRequirements ensureRequirements() => $_ensure(16);
}

class CreateCropRequest extends $pb.GeneratedMessage {
  factory CreateCropRequest({
    $core.String? tenantId,
    $core.String? name,
    $core.String? scientificName,
    $core.String? family,
    CropCategory? category,
    $core.String? description,
    $core.String? imageUrl,
    $core.Iterable<$core.String>? diseaseSusceptibilities,
    $core.Iterable<$core.String>? companionPlants,
    $core.String? rotationGroup,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    if (name != null) result.name = name;
    if (scientificName != null) result.scientificName = scientificName;
    if (family != null) result.family = family;
    if (category != null) result.category = category;
    if (description != null) result.description = description;
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (diseaseSusceptibilities != null)
      result.diseaseSusceptibilities.addAll(diseaseSusceptibilities);
    if (companionPlants != null) result.companionPlants.addAll(companionPlants);
    if (rotationGroup != null) result.rotationGroup = rotationGroup;
    return result;
  }

  CreateCropRequest._();

  factory CreateCropRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateCropRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateCropRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'scientificName')
    ..aOS(4, _omitFieldNames ? '' : 'family')
    ..aE<CropCategory>(5, _omitFieldNames ? '' : 'category',
        enumValues: CropCategory.values)
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'imageUrl')
    ..pPS(8, _omitFieldNames ? '' : 'diseaseSusceptibilities')
    ..pPS(9, _omitFieldNames ? '' : 'companionPlants')
    ..aOS(10, _omitFieldNames ? '' : 'rotationGroup')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCropRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCropRequest copyWith(void Function(CreateCropRequest) updates) =>
      super.copyWith((message) => updates(message as CreateCropRequest))
          as CreateCropRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateCropRequest create() => CreateCropRequest._();
  @$core.override
  CreateCropRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateCropRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateCropRequest>(create);
  static CreateCropRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get scientificName => $_getSZ(2);
  @$pb.TagNumber(3)
  set scientificName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScientificName() => $_has(2);
  @$pb.TagNumber(3)
  void clearScientificName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get family => $_getSZ(3);
  @$pb.TagNumber(4)
  set family($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFamily() => $_has(3);
  @$pb.TagNumber(4)
  void clearFamily() => $_clearField(4);

  @$pb.TagNumber(5)
  CropCategory get category => $_getN(4);
  @$pb.TagNumber(5)
  set category(CropCategory value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCategory() => $_has(4);
  @$pb.TagNumber(5)
  void clearCategory() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get imageUrl => $_getSZ(6);
  @$pb.TagNumber(7)
  set imageUrl($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasImageUrl() => $_has(6);
  @$pb.TagNumber(7)
  void clearImageUrl() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get diseaseSusceptibilities => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get companionPlants => $_getList(8);

  @$pb.TagNumber(10)
  $core.String get rotationGroup => $_getSZ(9);
  @$pb.TagNumber(10)
  set rotationGroup($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRotationGroup() => $_has(9);
  @$pb.TagNumber(10)
  void clearRotationGroup() => $_clearField(10);
}

class CreateCropResponse extends $pb.GeneratedMessage {
  factory CreateCropResponse({
    Crop? crop,
  }) {
    final result = create();
    if (crop != null) result.crop = crop;
    return result;
  }

  CreateCropResponse._();

  factory CreateCropResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateCropResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateCropResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOM<Crop>(1, _omitFieldNames ? '' : 'crop', subBuilder: Crop.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCropResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCropResponse copyWith(void Function(CreateCropResponse) updates) =>
      super.copyWith((message) => updates(message as CreateCropResponse))
          as CreateCropResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateCropResponse create() => CreateCropResponse._();
  @$core.override
  CreateCropResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateCropResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateCropResponse>(create);
  static CreateCropResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Crop get crop => $_getN(0);
  @$pb.TagNumber(1)
  set crop(Crop value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCrop() => $_has(0);
  @$pb.TagNumber(1)
  void clearCrop() => $_clearField(1);
  @$pb.TagNumber(1)
  Crop ensureCrop() => $_ensure(0);
}

class GetCropRequest extends $pb.GeneratedMessage {
  factory GetCropRequest({
    $core.String? id,
    $core.String? tenantId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    return result;
  }

  GetCropRequest._();

  factory GetCropRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCropRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCropRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropRequest copyWith(void Function(GetCropRequest) updates) =>
      super.copyWith((message) => updates(message as GetCropRequest))
          as GetCropRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCropRequest create() => GetCropRequest._();
  @$core.override
  GetCropRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCropRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCropRequest>(create);
  static GetCropRequest? _defaultInstance;

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
}

class GetCropResponse extends $pb.GeneratedMessage {
  factory GetCropResponse({
    Crop? crop,
  }) {
    final result = create();
    if (crop != null) result.crop = crop;
    return result;
  }

  GetCropResponse._();

  factory GetCropResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCropResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCropResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOM<Crop>(1, _omitFieldNames ? '' : 'crop', subBuilder: Crop.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropResponse copyWith(void Function(GetCropResponse) updates) =>
      super.copyWith((message) => updates(message as GetCropResponse))
          as GetCropResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCropResponse create() => GetCropResponse._();
  @$core.override
  GetCropResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCropResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCropResponse>(create);
  static GetCropResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Crop get crop => $_getN(0);
  @$pb.TagNumber(1)
  set crop(Crop value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCrop() => $_has(0);
  @$pb.TagNumber(1)
  void clearCrop() => $_clearField(1);
  @$pb.TagNumber(1)
  Crop ensureCrop() => $_ensure(0);
}

class ListCropsRequest extends $pb.GeneratedMessage {
  factory ListCropsRequest({
    $core.String? tenantId,
    CropCategory? category,
    $core.String? searchTerm,
    $core.int? pageSize,
    $core.int? pageOffset,
    $core.Iterable<$core.String>? sort,
    $1.FieldMask? fieldMask,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    if (category != null) result.category = category;
    if (searchTerm != null) result.searchTerm = searchTerm;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    if (sort != null) result.sort.addAll(sort);
    if (fieldMask != null) result.fieldMask = fieldMask;
    return result;
  }

  ListCropsRequest._();

  factory ListCropsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListCropsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListCropsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aE<CropCategory>(2, _omitFieldNames ? '' : 'category',
        enumValues: CropCategory.values)
    ..aOS(3, _omitFieldNames ? '' : 'searchTerm')
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aI(5, _omitFieldNames ? '' : 'pageOffset')
    ..pPS(6, _omitFieldNames ? '' : 'sort')
    ..aOM<$1.FieldMask>(7, _omitFieldNames ? '' : 'fieldMask',
        subBuilder: $1.FieldMask.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCropsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCropsRequest copyWith(void Function(ListCropsRequest) updates) =>
      super.copyWith((message) => updates(message as ListCropsRequest))
          as ListCropsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListCropsRequest create() => ListCropsRequest._();
  @$core.override
  ListCropsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListCropsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListCropsRequest>(create);
  static ListCropsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => $_clearField(1);

  @$pb.TagNumber(2)
  CropCategory get category => $_getN(1);
  @$pb.TagNumber(2)
  set category(CropCategory value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCategory() => $_has(1);
  @$pb.TagNumber(2)
  void clearCategory() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get searchTerm => $_getSZ(2);
  @$pb.TagNumber(3)
  set searchTerm($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSearchTerm() => $_has(2);
  @$pb.TagNumber(3)
  void clearSearchTerm() => $_clearField(3);

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
  $pb.PbList<$core.String> get sort => $_getList(5);

  @$pb.TagNumber(7)
  $1.FieldMask get fieldMask => $_getN(6);
  @$pb.TagNumber(7)
  set fieldMask($1.FieldMask value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasFieldMask() => $_has(6);
  @$pb.TagNumber(7)
  void clearFieldMask() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.FieldMask ensureFieldMask() => $_ensure(6);
}

class ListCropsResponse extends $pb.GeneratedMessage {
  factory ListCropsResponse({
    $core.Iterable<Crop>? crops,
    $core.int? totalCount,
  }) {
    final result = create();
    if (crops != null) result.crops.addAll(crops);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListCropsResponse._();

  factory ListCropsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListCropsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListCropsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..pPM<Crop>(1, _omitFieldNames ? '' : 'crops', subBuilder: Crop.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCropsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCropsResponse copyWith(void Function(ListCropsResponse) updates) =>
      super.copyWith((message) => updates(message as ListCropsResponse))
          as ListCropsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListCropsResponse create() => ListCropsResponse._();
  @$core.override
  ListCropsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListCropsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListCropsResponse>(create);
  static ListCropsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Crop> get crops => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class UpdateCropRequest extends $pb.GeneratedMessage {
  factory UpdateCropRequest({
    $core.String? id,
    $core.String? tenantId,
    $core.String? name,
    $core.String? scientificName,
    $core.String? family,
    CropCategory? category,
    $core.String? description,
    $core.String? imageUrl,
    $core.Iterable<$core.String>? diseaseSusceptibilities,
    $core.Iterable<$core.String>? companionPlants,
    $core.String? rotationGroup,
    $core.int? version,
    $1.FieldMask? updateMask,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (name != null) result.name = name;
    if (scientificName != null) result.scientificName = scientificName;
    if (family != null) result.family = family;
    if (category != null) result.category = category;
    if (description != null) result.description = description;
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (diseaseSusceptibilities != null)
      result.diseaseSusceptibilities.addAll(diseaseSusceptibilities);
    if (companionPlants != null) result.companionPlants.addAll(companionPlants);
    if (rotationGroup != null) result.rotationGroup = rotationGroup;
    if (version != null) result.version = version;
    if (updateMask != null) result.updateMask = updateMask;
    return result;
  }

  UpdateCropRequest._();

  factory UpdateCropRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateCropRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateCropRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'scientificName')
    ..aOS(5, _omitFieldNames ? '' : 'family')
    ..aE<CropCategory>(6, _omitFieldNames ? '' : 'category',
        enumValues: CropCategory.values)
    ..aOS(7, _omitFieldNames ? '' : 'description')
    ..aOS(8, _omitFieldNames ? '' : 'imageUrl')
    ..pPS(9, _omitFieldNames ? '' : 'diseaseSusceptibilities')
    ..pPS(10, _omitFieldNames ? '' : 'companionPlants')
    ..aOS(11, _omitFieldNames ? '' : 'rotationGroup')
    ..aI(12, _omitFieldNames ? '' : 'version')
    ..aOM<$1.FieldMask>(13, _omitFieldNames ? '' : 'updateMask',
        subBuilder: $1.FieldMask.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCropRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCropRequest copyWith(void Function(UpdateCropRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateCropRequest))
          as UpdateCropRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateCropRequest create() => UpdateCropRequest._();
  @$core.override
  UpdateCropRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateCropRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateCropRequest>(create);
  static UpdateCropRequest? _defaultInstance;

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
  $core.String get scientificName => $_getSZ(3);
  @$pb.TagNumber(4)
  set scientificName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasScientificName() => $_has(3);
  @$pb.TagNumber(4)
  void clearScientificName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get family => $_getSZ(4);
  @$pb.TagNumber(5)
  set family($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFamily() => $_has(4);
  @$pb.TagNumber(5)
  void clearFamily() => $_clearField(5);

  @$pb.TagNumber(6)
  CropCategory get category => $_getN(5);
  @$pb.TagNumber(6)
  set category(CropCategory value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCategory() => $_has(5);
  @$pb.TagNumber(6)
  void clearCategory() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get description => $_getSZ(6);
  @$pb.TagNumber(7)
  set description($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDescription() => $_has(6);
  @$pb.TagNumber(7)
  void clearDescription() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get imageUrl => $_getSZ(7);
  @$pb.TagNumber(8)
  set imageUrl($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasImageUrl() => $_has(7);
  @$pb.TagNumber(8)
  void clearImageUrl() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get diseaseSusceptibilities => $_getList(8);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get companionPlants => $_getList(9);

  @$pb.TagNumber(11)
  $core.String get rotationGroup => $_getSZ(10);
  @$pb.TagNumber(11)
  set rotationGroup($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasRotationGroup() => $_has(10);
  @$pb.TagNumber(11)
  void clearRotationGroup() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get version => $_getIZ(11);
  @$pb.TagNumber(12)
  set version($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasVersion() => $_has(11);
  @$pb.TagNumber(12)
  void clearVersion() => $_clearField(12);

  @$pb.TagNumber(13)
  $1.FieldMask get updateMask => $_getN(12);
  @$pb.TagNumber(13)
  set updateMask($1.FieldMask value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasUpdateMask() => $_has(12);
  @$pb.TagNumber(13)
  void clearUpdateMask() => $_clearField(13);
  @$pb.TagNumber(13)
  $1.FieldMask ensureUpdateMask() => $_ensure(12);
}

class UpdateCropResponse extends $pb.GeneratedMessage {
  factory UpdateCropResponse({
    Crop? crop,
  }) {
    final result = create();
    if (crop != null) result.crop = crop;
    return result;
  }

  UpdateCropResponse._();

  factory UpdateCropResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateCropResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateCropResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOM<Crop>(1, _omitFieldNames ? '' : 'crop', subBuilder: Crop.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCropResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateCropResponse copyWith(void Function(UpdateCropResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateCropResponse))
          as UpdateCropResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateCropResponse create() => UpdateCropResponse._();
  @$core.override
  UpdateCropResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateCropResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateCropResponse>(create);
  static UpdateCropResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Crop get crop => $_getN(0);
  @$pb.TagNumber(1)
  set crop(Crop value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCrop() => $_has(0);
  @$pb.TagNumber(1)
  void clearCrop() => $_clearField(1);
  @$pb.TagNumber(1)
  Crop ensureCrop() => $_ensure(0);
}

class DeleteCropRequest extends $pb.GeneratedMessage {
  factory DeleteCropRequest({
    $core.String? id,
    $core.String? tenantId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    return result;
  }

  DeleteCropRequest._();

  factory DeleteCropRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteCropRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteCropRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteCropRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteCropRequest copyWith(void Function(DeleteCropRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteCropRequest))
          as DeleteCropRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteCropRequest create() => DeleteCropRequest._();
  @$core.override
  DeleteCropRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteCropRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteCropRequest>(create);
  static DeleteCropRequest? _defaultInstance;

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
}

class DeleteCropResponse extends $pb.GeneratedMessage {
  factory DeleteCropResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  DeleteCropResponse._();

  factory DeleteCropResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteCropResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteCropResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteCropResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteCropResponse copyWith(void Function(DeleteCropResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteCropResponse))
          as DeleteCropResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteCropResponse create() => DeleteCropResponse._();
  @$core.override
  DeleteCropResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteCropResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteCropResponse>(create);
  static DeleteCropResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

class AddVarietyRequest extends $pb.GeneratedMessage {
  factory AddVarietyRequest({
    $core.String? cropId,
    $core.String? tenantId,
    $core.String? name,
    $core.String? description,
    $core.int? maturityDays,
    $core.double? yieldPotentialKgPerHectare,
    $core.bool? isHybrid,
    $core.String? diseaseResistance,
    $core.String? suitableRegions,
    $core.String? seedRateKgPerHectare,
  }) {
    final result = create();
    if (cropId != null) result.cropId = cropId;
    if (tenantId != null) result.tenantId = tenantId;
    if (name != null) result.name = name;
    if (description != null) result.description = description;
    if (maturityDays != null) result.maturityDays = maturityDays;
    if (yieldPotentialKgPerHectare != null)
      result.yieldPotentialKgPerHectare = yieldPotentialKgPerHectare;
    if (isHybrid != null) result.isHybrid = isHybrid;
    if (diseaseResistance != null) result.diseaseResistance = diseaseResistance;
    if (suitableRegions != null) result.suitableRegions = suitableRegions;
    if (seedRateKgPerHectare != null)
      result.seedRateKgPerHectare = seedRateKgPerHectare;
    return result;
  }

  AddVarietyRequest._();

  factory AddVarietyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddVarietyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddVarietyRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cropId')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aI(5, _omitFieldNames ? '' : 'maturityDays')
    ..aD(6, _omitFieldNames ? '' : 'yieldPotentialKgPerHectare')
    ..aOB(7, _omitFieldNames ? '' : 'isHybrid')
    ..aOS(8, _omitFieldNames ? '' : 'diseaseResistance')
    ..aOS(9, _omitFieldNames ? '' : 'suitableRegions')
    ..aOS(10, _omitFieldNames ? '' : 'seedRateKgPerHectare')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddVarietyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddVarietyRequest copyWith(void Function(AddVarietyRequest) updates) =>
      super.copyWith((message) => updates(message as AddVarietyRequest))
          as AddVarietyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddVarietyRequest create() => AddVarietyRequest._();
  @$core.override
  AddVarietyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddVarietyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddVarietyRequest>(create);
  static AddVarietyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cropId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cropId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCropId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCropId() => $_clearField(1);

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
  $core.int get maturityDays => $_getIZ(4);
  @$pb.TagNumber(5)
  set maturityDays($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMaturityDays() => $_has(4);
  @$pb.TagNumber(5)
  void clearMaturityDays() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get yieldPotentialKgPerHectare => $_getN(5);
  @$pb.TagNumber(6)
  set yieldPotentialKgPerHectare($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasYieldPotentialKgPerHectare() => $_has(5);
  @$pb.TagNumber(6)
  void clearYieldPotentialKgPerHectare() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get isHybrid => $_getBF(6);
  @$pb.TagNumber(7)
  set isHybrid($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsHybrid() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsHybrid() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get diseaseResistance => $_getSZ(7);
  @$pb.TagNumber(8)
  set diseaseResistance($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDiseaseResistance() => $_has(7);
  @$pb.TagNumber(8)
  void clearDiseaseResistance() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get suitableRegions => $_getSZ(8);
  @$pb.TagNumber(9)
  set suitableRegions($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSuitableRegions() => $_has(8);
  @$pb.TagNumber(9)
  void clearSuitableRegions() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get seedRateKgPerHectare => $_getSZ(9);
  @$pb.TagNumber(10)
  set seedRateKgPerHectare($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSeedRateKgPerHectare() => $_has(9);
  @$pb.TagNumber(10)
  void clearSeedRateKgPerHectare() => $_clearField(10);
}

class AddVarietyResponse extends $pb.GeneratedMessage {
  factory AddVarietyResponse({
    CropVariety? variety,
  }) {
    final result = create();
    if (variety != null) result.variety = variety;
    return result;
  }

  AddVarietyResponse._();

  factory AddVarietyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddVarietyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddVarietyResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOM<CropVariety>(1, _omitFieldNames ? '' : 'variety',
        subBuilder: CropVariety.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddVarietyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddVarietyResponse copyWith(void Function(AddVarietyResponse) updates) =>
      super.copyWith((message) => updates(message as AddVarietyResponse))
          as AddVarietyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddVarietyResponse create() => AddVarietyResponse._();
  @$core.override
  AddVarietyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddVarietyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddVarietyResponse>(create);
  static AddVarietyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CropVariety get variety => $_getN(0);
  @$pb.TagNumber(1)
  set variety(CropVariety value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasVariety() => $_has(0);
  @$pb.TagNumber(1)
  void clearVariety() => $_clearField(1);
  @$pb.TagNumber(1)
  CropVariety ensureVariety() => $_ensure(0);
}

class ListVarietiesRequest extends $pb.GeneratedMessage {
  factory ListVarietiesRequest({
    $core.String? cropId,
    $core.String? tenantId,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (cropId != null) result.cropId = cropId;
    if (tenantId != null) result.tenantId = tenantId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListVarietiesRequest._();

  factory ListVarietiesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListVarietiesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListVarietiesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cropId')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aI(3, _omitFieldNames ? '' : 'pageSize')
    ..aI(4, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListVarietiesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListVarietiesRequest copyWith(void Function(ListVarietiesRequest) updates) =>
      super.copyWith((message) => updates(message as ListVarietiesRequest))
          as ListVarietiesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListVarietiesRequest create() => ListVarietiesRequest._();
  @$core.override
  ListVarietiesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListVarietiesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListVarietiesRequest>(create);
  static ListVarietiesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cropId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cropId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCropId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCropId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

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

class ListVarietiesResponse extends $pb.GeneratedMessage {
  factory ListVarietiesResponse({
    $core.Iterable<CropVariety>? varieties,
    $core.int? totalCount,
  }) {
    final result = create();
    if (varieties != null) result.varieties.addAll(varieties);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListVarietiesResponse._();

  factory ListVarietiesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListVarietiesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListVarietiesResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..pPM<CropVariety>(1, _omitFieldNames ? '' : 'varieties',
        subBuilder: CropVariety.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListVarietiesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListVarietiesResponse copyWith(
          void Function(ListVarietiesResponse) updates) =>
      super.copyWith((message) => updates(message as ListVarietiesResponse))
          as ListVarietiesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListVarietiesResponse create() => ListVarietiesResponse._();
  @$core.override
  ListVarietiesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListVarietiesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListVarietiesResponse>(create);
  static ListVarietiesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CropVariety> get varieties => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class GetGrowthStagesRequest extends $pb.GeneratedMessage {
  factory GetGrowthStagesRequest({
    $core.String? cropId,
    $core.String? tenantId,
  }) {
    final result = create();
    if (cropId != null) result.cropId = cropId;
    if (tenantId != null) result.tenantId = tenantId;
    return result;
  }

  GetGrowthStagesRequest._();

  factory GetGrowthStagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGrowthStagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGrowthStagesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cropId')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGrowthStagesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGrowthStagesRequest copyWith(
          void Function(GetGrowthStagesRequest) updates) =>
      super.copyWith((message) => updates(message as GetGrowthStagesRequest))
          as GetGrowthStagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGrowthStagesRequest create() => GetGrowthStagesRequest._();
  @$core.override
  GetGrowthStagesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGrowthStagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGrowthStagesRequest>(create);
  static GetGrowthStagesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cropId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cropId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCropId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCropId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);
}

class GetGrowthStagesResponse extends $pb.GeneratedMessage {
  factory GetGrowthStagesResponse({
    $core.Iterable<GrowthStage>? growthStages,
  }) {
    final result = create();
    if (growthStages != null) result.growthStages.addAll(growthStages);
    return result;
  }

  GetGrowthStagesResponse._();

  factory GetGrowthStagesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetGrowthStagesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetGrowthStagesResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..pPM<GrowthStage>(1, _omitFieldNames ? '' : 'growthStages',
        subBuilder: GrowthStage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGrowthStagesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetGrowthStagesResponse copyWith(
          void Function(GetGrowthStagesResponse) updates) =>
      super.copyWith((message) => updates(message as GetGrowthStagesResponse))
          as GetGrowthStagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetGrowthStagesResponse create() => GetGrowthStagesResponse._();
  @$core.override
  GetGrowthStagesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetGrowthStagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetGrowthStagesResponse>(create);
  static GetGrowthStagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GrowthStage> get growthStages => $_getList(0);
}

class GetCropRequirementsRequest extends $pb.GeneratedMessage {
  factory GetCropRequirementsRequest({
    $core.String? cropId,
    $core.String? tenantId,
  }) {
    final result = create();
    if (cropId != null) result.cropId = cropId;
    if (tenantId != null) result.tenantId = tenantId;
    return result;
  }

  GetCropRequirementsRequest._();

  factory GetCropRequirementsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCropRequirementsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCropRequirementsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cropId')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropRequirementsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropRequirementsRequest copyWith(
          void Function(GetCropRequirementsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetCropRequirementsRequest))
          as GetCropRequirementsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCropRequirementsRequest create() => GetCropRequirementsRequest._();
  @$core.override
  GetCropRequirementsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCropRequirementsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCropRequirementsRequest>(create);
  static GetCropRequirementsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cropId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cropId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCropId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCropId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);
}

class GetCropRequirementsResponse extends $pb.GeneratedMessage {
  factory GetCropRequirementsResponse({
    CropRequirements? requirements,
  }) {
    final result = create();
    if (requirements != null) result.requirements = requirements;
    return result;
  }

  GetCropRequirementsResponse._();

  factory GetCropRequirementsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCropRequirementsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCropRequirementsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOM<CropRequirements>(1, _omitFieldNames ? '' : 'requirements',
        subBuilder: CropRequirements.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropRequirementsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropRequirementsResponse copyWith(
          void Function(GetCropRequirementsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetCropRequirementsResponse))
          as GetCropRequirementsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCropRequirementsResponse create() =>
      GetCropRequirementsResponse._();
  @$core.override
  GetCropRequirementsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCropRequirementsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCropRequirementsResponse>(create);
  static GetCropRequirementsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CropRequirements get requirements => $_getN(0);
  @$pb.TagNumber(1)
  set requirements(CropRequirements value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRequirements() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequirements() => $_clearField(1);
  @$pb.TagNumber(1)
  CropRequirements ensureRequirements() => $_ensure(0);
}

class GenerateRecommendationRequest extends $pb.GeneratedMessage {
  factory GenerateRecommendationRequest({
    $core.String? cropId,
    $core.String? tenantId,
    $core.String? recommendationType,
    $core.String? currentGrowthStage,
    $core.double? currentTemperature,
    $core.double? currentHumidity,
    $core.double? currentSoilPh,
    $core.double? currentSoilMoisture,
  }) {
    final result = create();
    if (cropId != null) result.cropId = cropId;
    if (tenantId != null) result.tenantId = tenantId;
    if (recommendationType != null)
      result.recommendationType = recommendationType;
    if (currentGrowthStage != null)
      result.currentGrowthStage = currentGrowthStage;
    if (currentTemperature != null)
      result.currentTemperature = currentTemperature;
    if (currentHumidity != null) result.currentHumidity = currentHumidity;
    if (currentSoilPh != null) result.currentSoilPh = currentSoilPh;
    if (currentSoilMoisture != null)
      result.currentSoilMoisture = currentSoilMoisture;
    return result;
  }

  GenerateRecommendationRequest._();

  factory GenerateRecommendationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateRecommendationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateRecommendationRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cropId')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'recommendationType')
    ..aOS(4, _omitFieldNames ? '' : 'currentGrowthStage')
    ..aD(5, _omitFieldNames ? '' : 'currentTemperature')
    ..aD(6, _omitFieldNames ? '' : 'currentHumidity')
    ..aD(7, _omitFieldNames ? '' : 'currentSoilPh')
    ..aD(8, _omitFieldNames ? '' : 'currentSoilMoisture')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateRecommendationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateRecommendationRequest copyWith(
          void Function(GenerateRecommendationRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GenerateRecommendationRequest))
          as GenerateRecommendationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateRecommendationRequest create() =>
      GenerateRecommendationRequest._();
  @$core.override
  GenerateRecommendationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateRecommendationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateRecommendationRequest>(create);
  static GenerateRecommendationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cropId => $_getSZ(0);
  @$pb.TagNumber(1)
  set cropId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCropId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCropId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get recommendationType => $_getSZ(2);
  @$pb.TagNumber(3)
  set recommendationType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRecommendationType() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecommendationType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get currentGrowthStage => $_getSZ(3);
  @$pb.TagNumber(4)
  set currentGrowthStage($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCurrentGrowthStage() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrentGrowthStage() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get currentTemperature => $_getN(4);
  @$pb.TagNumber(5)
  set currentTemperature($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCurrentTemperature() => $_has(4);
  @$pb.TagNumber(5)
  void clearCurrentTemperature() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get currentHumidity => $_getN(5);
  @$pb.TagNumber(6)
  set currentHumidity($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCurrentHumidity() => $_has(5);
  @$pb.TagNumber(6)
  void clearCurrentHumidity() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get currentSoilPh => $_getN(6);
  @$pb.TagNumber(7)
  set currentSoilPh($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCurrentSoilPh() => $_has(6);
  @$pb.TagNumber(7)
  void clearCurrentSoilPh() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get currentSoilMoisture => $_getN(7);
  @$pb.TagNumber(8)
  set currentSoilMoisture($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCurrentSoilMoisture() => $_has(7);
  @$pb.TagNumber(8)
  void clearCurrentSoilMoisture() => $_clearField(8);
}

class GenerateRecommendationResponse extends $pb.GeneratedMessage {
  factory GenerateRecommendationResponse({
    CropRecommendation? recommendation,
  }) {
    final result = create();
    if (recommendation != null) result.recommendation = recommendation;
    return result;
  }

  GenerateRecommendationResponse._();

  factory GenerateRecommendationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateRecommendationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateRecommendationResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.crop.v1'),
      createEmptyInstance: create)
    ..aOM<CropRecommendation>(1, _omitFieldNames ? '' : 'recommendation',
        subBuilder: CropRecommendation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateRecommendationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateRecommendationResponse copyWith(
          void Function(GenerateRecommendationResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GenerateRecommendationResponse))
          as GenerateRecommendationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateRecommendationResponse create() =>
      GenerateRecommendationResponse._();
  @$core.override
  GenerateRecommendationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateRecommendationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateRecommendationResponse>(create);
  static GenerateRecommendationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CropRecommendation get recommendation => $_getN(0);
  @$pb.TagNumber(1)
  set recommendation(CropRecommendation value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRecommendation() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecommendation() => $_clearField(1);
  @$pb.TagNumber(1)
  CropRecommendation ensureRecommendation() => $_ensure(0);
}

class CropServiceApi {
  final $pb.RpcClient _client;

  CropServiceApi(this._client);

  /// Crop CRUD
  $async.Future<CreateCropResponse> createCrop(
          $pb.ClientContext? ctx, CreateCropRequest request) =>
      _client.invoke<CreateCropResponse>(
          ctx, 'CropService', 'CreateCrop', request, CreateCropResponse());
  $async.Future<GetCropResponse> getCrop(
          $pb.ClientContext? ctx, GetCropRequest request) =>
      _client.invoke<GetCropResponse>(
          ctx, 'CropService', 'GetCrop', request, GetCropResponse());
  $async.Future<ListCropsResponse> listCrops(
          $pb.ClientContext? ctx, ListCropsRequest request) =>
      _client.invoke<ListCropsResponse>(
          ctx, 'CropService', 'ListCrops', request, ListCropsResponse());
  $async.Future<UpdateCropResponse> updateCrop(
          $pb.ClientContext? ctx, UpdateCropRequest request) =>
      _client.invoke<UpdateCropResponse>(
          ctx, 'CropService', 'UpdateCrop', request, UpdateCropResponse());
  $async.Future<DeleteCropResponse> deleteCrop(
          $pb.ClientContext? ctx, DeleteCropRequest request) =>
      _client.invoke<DeleteCropResponse>(
          ctx, 'CropService', 'DeleteCrop', request, DeleteCropResponse());

  /// Varieties
  $async.Future<AddVarietyResponse> addVariety(
          $pb.ClientContext? ctx, AddVarietyRequest request) =>
      _client.invoke<AddVarietyResponse>(
          ctx, 'CropService', 'AddVariety', request, AddVarietyResponse());
  $async.Future<ListVarietiesResponse> listVarieties(
          $pb.ClientContext? ctx, ListVarietiesRequest request) =>
      _client.invoke<ListVarietiesResponse>(ctx, 'CropService', 'ListVarieties',
          request, ListVarietiesResponse());

  /// Growth Stages
  $async.Future<GetGrowthStagesResponse> getGrowthStages(
          $pb.ClientContext? ctx, GetGrowthStagesRequest request) =>
      _client.invoke<GetGrowthStagesResponse>(ctx, 'CropService',
          'GetGrowthStages', request, GetGrowthStagesResponse());

  /// Requirements
  $async.Future<GetCropRequirementsResponse> getCropRequirements(
          $pb.ClientContext? ctx, GetCropRequirementsRequest request) =>
      _client.invoke<GetCropRequirementsResponse>(ctx, 'CropService',
          'GetCropRequirements', request, GetCropRequirementsResponse());

  /// Intelligence
  $async.Future<GenerateRecommendationResponse> generateRecommendation(
          $pb.ClientContext? ctx, GenerateRecommendationRequest request) =>
      _client.invoke<GenerateRecommendationResponse>(ctx, 'CropService',
          'GenerateRecommendation', request, GenerateRecommendationResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
