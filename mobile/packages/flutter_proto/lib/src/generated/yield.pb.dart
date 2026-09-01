// This is a generated file - do not edit.
//
// Generated from yield.proto.

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

import 'yield.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'yield.pbenum.dart';

/// YieldFactors represents the individual contributing factors to yield prediction.
class YieldFactors extends $pb.GeneratedMessage {
  factory YieldFactors({
    $core.double? soilQualityScore,
    $core.double? weatherScore,
    $core.double? irrigationScore,
    $core.double? pestPressureScore,
    $core.double? nutrientScore,
    $core.double? managementScore,
  }) {
    final result = create();
    if (soilQualityScore != null) result.soilQualityScore = soilQualityScore;
    if (weatherScore != null) result.weatherScore = weatherScore;
    if (irrigationScore != null) result.irrigationScore = irrigationScore;
    if (pestPressureScore != null) result.pestPressureScore = pestPressureScore;
    if (nutrientScore != null) result.nutrientScore = nutrientScore;
    if (managementScore != null) result.managementScore = managementScore;
    return result;
  }

  YieldFactors._();

  factory YieldFactors.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory YieldFactors.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'YieldFactors',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'soilQualityScore')
    ..aD(2, _omitFieldNames ? '' : 'weatherScore')
    ..aD(3, _omitFieldNames ? '' : 'irrigationScore')
    ..aD(4, _omitFieldNames ? '' : 'pestPressureScore')
    ..aD(5, _omitFieldNames ? '' : 'nutrientScore')
    ..aD(6, _omitFieldNames ? '' : 'managementScore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  YieldFactors clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  YieldFactors copyWith(void Function(YieldFactors) updates) =>
      super.copyWith((message) => updates(message as YieldFactors))
          as YieldFactors;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static YieldFactors create() => YieldFactors._();
  @$core.override
  YieldFactors createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static YieldFactors getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<YieldFactors>(create);
  static YieldFactors? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get soilQualityScore => $_getN(0);
  @$pb.TagNumber(1)
  set soilQualityScore($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSoilQualityScore() => $_has(0);
  @$pb.TagNumber(1)
  void clearSoilQualityScore() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get weatherScore => $_getN(1);
  @$pb.TagNumber(2)
  set weatherScore($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWeatherScore() => $_has(1);
  @$pb.TagNumber(2)
  void clearWeatherScore() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get irrigationScore => $_getN(2);
  @$pb.TagNumber(3)
  set irrigationScore($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIrrigationScore() => $_has(2);
  @$pb.TagNumber(3)
  void clearIrrigationScore() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get pestPressureScore => $_getN(3);
  @$pb.TagNumber(4)
  set pestPressureScore($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPestPressureScore() => $_has(3);
  @$pb.TagNumber(4)
  void clearPestPressureScore() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get nutrientScore => $_getN(4);
  @$pb.TagNumber(5)
  set nutrientScore($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNutrientScore() => $_has(4);
  @$pb.TagNumber(5)
  void clearNutrientScore() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get managementScore => $_getN(5);
  @$pb.TagNumber(6)
  set managementScore($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasManagementScore() => $_has(5);
  @$pb.TagNumber(6)
  void clearManagementScore() => $_clearField(6);
}

/// YieldPrediction represents a yield forecast for a specific field and crop.
class YieldPrediction extends $pb.GeneratedMessage {
  factory YieldPrediction({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? season,
    $core.int? year,
    $core.double? predictedYieldKgPerHectare,
    $core.double? predictionConfidencePct,
    $core.String? predictionModelVersion,
    YieldFactors? yieldFactors,
    PredictionStatus? status,
    $core.String? createdBy,
    $core.String? updatedBy,
    $fixnum.Int64? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (predictedYieldKgPerHectare != null)
      result.predictedYieldKgPerHectare = predictedYieldKgPerHectare;
    if (predictionConfidencePct != null)
      result.predictionConfidencePct = predictionConfidencePct;
    if (predictionModelVersion != null)
      result.predictionModelVersion = predictionModelVersion;
    if (yieldFactors != null) result.yieldFactors = yieldFactors;
    if (status != null) result.status = status;
    if (createdBy != null) result.createdBy = createdBy;
    if (updatedBy != null) result.updatedBy = updatedBy;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  YieldPrediction._();

  factory YieldPrediction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory YieldPrediction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'YieldPrediction',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'cropId')
    ..aOS(6, _omitFieldNames ? '' : 'season')
    ..aI(7, _omitFieldNames ? '' : 'year')
    ..aD(8, _omitFieldNames ? '' : 'predictedYieldKgPerHectare')
    ..aD(9, _omitFieldNames ? '' : 'predictionConfidencePct')
    ..aOS(10, _omitFieldNames ? '' : 'predictionModelVersion')
    ..aOM<YieldFactors>(11, _omitFieldNames ? '' : 'yieldFactors',
        subBuilder: YieldFactors.create)
    ..aE<PredictionStatus>(12, _omitFieldNames ? '' : 'status',
        enumValues: PredictionStatus.values)
    ..aOS(13, _omitFieldNames ? '' : 'createdBy')
    ..aOS(14, _omitFieldNames ? '' : 'updatedBy')
    ..aInt64(15, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(16, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  YieldPrediction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  YieldPrediction copyWith(void Function(YieldPrediction) updates) =>
      super.copyWith((message) => updates(message as YieldPrediction))
          as YieldPrediction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static YieldPrediction create() => YieldPrediction._();
  @$core.override
  YieldPrediction createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static YieldPrediction getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<YieldPrediction>(create);
  static YieldPrediction? _defaultInstance;

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
  $core.String get fieldId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fieldId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cropId => $_getSZ(4);
  @$pb.TagNumber(5)
  set cropId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCropId() => $_has(4);
  @$pb.TagNumber(5)
  void clearCropId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get season => $_getSZ(5);
  @$pb.TagNumber(6)
  set season($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSeason() => $_has(5);
  @$pb.TagNumber(6)
  void clearSeason() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get year => $_getIZ(6);
  @$pb.TagNumber(7)
  set year($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasYear() => $_has(6);
  @$pb.TagNumber(7)
  void clearYear() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get predictedYieldKgPerHectare => $_getN(7);
  @$pb.TagNumber(8)
  set predictedYieldKgPerHectare($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPredictedYieldKgPerHectare() => $_has(7);
  @$pb.TagNumber(8)
  void clearPredictedYieldKgPerHectare() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get predictionConfidencePct => $_getN(8);
  @$pb.TagNumber(9)
  set predictionConfidencePct($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPredictionConfidencePct() => $_has(8);
  @$pb.TagNumber(9)
  void clearPredictionConfidencePct() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get predictionModelVersion => $_getSZ(9);
  @$pb.TagNumber(10)
  set predictionModelVersion($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPredictionModelVersion() => $_has(9);
  @$pb.TagNumber(10)
  void clearPredictionModelVersion() => $_clearField(10);

  @$pb.TagNumber(11)
  YieldFactors get yieldFactors => $_getN(10);
  @$pb.TagNumber(11)
  set yieldFactors(YieldFactors value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasYieldFactors() => $_has(10);
  @$pb.TagNumber(11)
  void clearYieldFactors() => $_clearField(11);
  @$pb.TagNumber(11)
  YieldFactors ensureYieldFactors() => $_ensure(10);

  @$pb.TagNumber(12)
  PredictionStatus get status => $_getN(11);
  @$pb.TagNumber(12)
  set status(PredictionStatus value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearStatus() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get createdBy => $_getSZ(12);
  @$pb.TagNumber(13)
  set createdBy($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCreatedBy() => $_has(12);
  @$pb.TagNumber(13)
  void clearCreatedBy() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get updatedBy => $_getSZ(13);
  @$pb.TagNumber(14)
  set updatedBy($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasUpdatedBy() => $_has(13);
  @$pb.TagNumber(14)
  void clearUpdatedBy() => $_clearField(14);

  @$pb.TagNumber(15)
  $fixnum.Int64 get version => $_getI64(14);
  @$pb.TagNumber(15)
  set version($fixnum.Int64 value) => $_setInt64(14, value);
  @$pb.TagNumber(15)
  $core.bool hasVersion() => $_has(14);
  @$pb.TagNumber(15)
  void clearVersion() => $_clearField(15);

  @$pb.TagNumber(16)
  $0.Timestamp get createdAt => $_getN(15);
  @$pb.TagNumber(16)
  set createdAt($0.Timestamp value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasCreatedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearCreatedAt() => $_clearField(16);
  @$pb.TagNumber(16)
  $0.Timestamp ensureCreatedAt() => $_ensure(15);

  @$pb.TagNumber(17)
  $0.Timestamp get updatedAt => $_getN(16);
  @$pb.TagNumber(17)
  set updatedAt($0.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasUpdatedAt() => $_has(16);
  @$pb.TagNumber(17)
  void clearUpdatedAt() => $_clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensureUpdatedAt() => $_ensure(16);
}

/// YieldRecord represents an actual recorded yield after harvest.
class YieldRecord extends $pb.GeneratedMessage {
  factory YieldRecord({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? season,
    $core.int? year,
    $core.double? actualYieldKgPerHectare,
    $core.double? totalAreaHarvestedHectares,
    $core.double? totalYieldKg,
    HarvestQualityGrade? harvestQualityGrade,
    $core.double? moistureContentPct,
    $0.Timestamp? harvestDate,
    $core.double? revenuePerHectare,
    $core.double? costPerHectare,
    $core.double? profitPerHectare,
    $core.String? predictionId,
    $core.String? createdBy,
    $core.String? updatedBy,
    $fixnum.Int64? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (actualYieldKgPerHectare != null)
      result.actualYieldKgPerHectare = actualYieldKgPerHectare;
    if (totalAreaHarvestedHectares != null)
      result.totalAreaHarvestedHectares = totalAreaHarvestedHectares;
    if (totalYieldKg != null) result.totalYieldKg = totalYieldKg;
    if (harvestQualityGrade != null)
      result.harvestQualityGrade = harvestQualityGrade;
    if (moistureContentPct != null)
      result.moistureContentPct = moistureContentPct;
    if (harvestDate != null) result.harvestDate = harvestDate;
    if (revenuePerHectare != null) result.revenuePerHectare = revenuePerHectare;
    if (costPerHectare != null) result.costPerHectare = costPerHectare;
    if (profitPerHectare != null) result.profitPerHectare = profitPerHectare;
    if (predictionId != null) result.predictionId = predictionId;
    if (createdBy != null) result.createdBy = createdBy;
    if (updatedBy != null) result.updatedBy = updatedBy;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  YieldRecord._();

  factory YieldRecord.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory YieldRecord.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'YieldRecord',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'cropId')
    ..aOS(6, _omitFieldNames ? '' : 'season')
    ..aI(7, _omitFieldNames ? '' : 'year')
    ..aD(8, _omitFieldNames ? '' : 'actualYieldKgPerHectare')
    ..aD(9, _omitFieldNames ? '' : 'totalAreaHarvestedHectares')
    ..aD(10, _omitFieldNames ? '' : 'totalYieldKg')
    ..aE<HarvestQualityGrade>(11, _omitFieldNames ? '' : 'harvestQualityGrade',
        enumValues: HarvestQualityGrade.values)
    ..aD(12, _omitFieldNames ? '' : 'moistureContentPct')
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'harvestDate',
        subBuilder: $0.Timestamp.create)
    ..aD(14, _omitFieldNames ? '' : 'revenuePerHectare')
    ..aD(15, _omitFieldNames ? '' : 'costPerHectare')
    ..aD(16, _omitFieldNames ? '' : 'profitPerHectare')
    ..aOS(17, _omitFieldNames ? '' : 'predictionId')
    ..aOS(18, _omitFieldNames ? '' : 'createdBy')
    ..aOS(19, _omitFieldNames ? '' : 'updatedBy')
    ..aInt64(20, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(21, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(22, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  YieldRecord clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  YieldRecord copyWith(void Function(YieldRecord) updates) =>
      super.copyWith((message) => updates(message as YieldRecord))
          as YieldRecord;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static YieldRecord create() => YieldRecord._();
  @$core.override
  YieldRecord createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static YieldRecord getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<YieldRecord>(create);
  static YieldRecord? _defaultInstance;

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
  $core.String get fieldId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fieldId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cropId => $_getSZ(4);
  @$pb.TagNumber(5)
  set cropId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCropId() => $_has(4);
  @$pb.TagNumber(5)
  void clearCropId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get season => $_getSZ(5);
  @$pb.TagNumber(6)
  set season($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSeason() => $_has(5);
  @$pb.TagNumber(6)
  void clearSeason() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get year => $_getIZ(6);
  @$pb.TagNumber(7)
  set year($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasYear() => $_has(6);
  @$pb.TagNumber(7)
  void clearYear() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get actualYieldKgPerHectare => $_getN(7);
  @$pb.TagNumber(8)
  set actualYieldKgPerHectare($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasActualYieldKgPerHectare() => $_has(7);
  @$pb.TagNumber(8)
  void clearActualYieldKgPerHectare() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get totalAreaHarvestedHectares => $_getN(8);
  @$pb.TagNumber(9)
  set totalAreaHarvestedHectares($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTotalAreaHarvestedHectares() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotalAreaHarvestedHectares() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get totalYieldKg => $_getN(9);
  @$pb.TagNumber(10)
  set totalYieldKg($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTotalYieldKg() => $_has(9);
  @$pb.TagNumber(10)
  void clearTotalYieldKg() => $_clearField(10);

  @$pb.TagNumber(11)
  HarvestQualityGrade get harvestQualityGrade => $_getN(10);
  @$pb.TagNumber(11)
  set harvestQualityGrade(HarvestQualityGrade value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasHarvestQualityGrade() => $_has(10);
  @$pb.TagNumber(11)
  void clearHarvestQualityGrade() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get moistureContentPct => $_getN(11);
  @$pb.TagNumber(12)
  set moistureContentPct($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasMoistureContentPct() => $_has(11);
  @$pb.TagNumber(12)
  void clearMoistureContentPct() => $_clearField(12);

  @$pb.TagNumber(13)
  $0.Timestamp get harvestDate => $_getN(12);
  @$pb.TagNumber(13)
  set harvestDate($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasHarvestDate() => $_has(12);
  @$pb.TagNumber(13)
  void clearHarvestDate() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureHarvestDate() => $_ensure(12);

  @$pb.TagNumber(14)
  $core.double get revenuePerHectare => $_getN(13);
  @$pb.TagNumber(14)
  set revenuePerHectare($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasRevenuePerHectare() => $_has(13);
  @$pb.TagNumber(14)
  void clearRevenuePerHectare() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get costPerHectare => $_getN(14);
  @$pb.TagNumber(15)
  set costPerHectare($core.double value) => $_setDouble(14, value);
  @$pb.TagNumber(15)
  $core.bool hasCostPerHectare() => $_has(14);
  @$pb.TagNumber(15)
  void clearCostPerHectare() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.double get profitPerHectare => $_getN(15);
  @$pb.TagNumber(16)
  set profitPerHectare($core.double value) => $_setDouble(15, value);
  @$pb.TagNumber(16)
  $core.bool hasProfitPerHectare() => $_has(15);
  @$pb.TagNumber(16)
  void clearProfitPerHectare() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get predictionId => $_getSZ(16);
  @$pb.TagNumber(17)
  set predictionId($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasPredictionId() => $_has(16);
  @$pb.TagNumber(17)
  void clearPredictionId() => $_clearField(17);

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
  $fixnum.Int64 get version => $_getI64(19);
  @$pb.TagNumber(20)
  set version($fixnum.Int64 value) => $_setInt64(19, value);
  @$pb.TagNumber(20)
  $core.bool hasVersion() => $_has(19);
  @$pb.TagNumber(20)
  void clearVersion() => $_clearField(20);

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

/// HarvestPlan represents a planned harvest operation.
class HarvestPlan extends $pb.GeneratedMessage {
  factory HarvestPlan({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? season,
    $core.int? year,
    $0.Timestamp? plannedStartDate,
    $0.Timestamp? plannedEndDate,
    $core.double? estimatedYieldKg,
    $core.double? totalAreaHectares,
    HarvestPlanStatus? status,
    $core.String? notes,
    $core.String? createdBy,
    $core.String? updatedBy,
    $fixnum.Int64? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (plannedStartDate != null) result.plannedStartDate = plannedStartDate;
    if (plannedEndDate != null) result.plannedEndDate = plannedEndDate;
    if (estimatedYieldKg != null) result.estimatedYieldKg = estimatedYieldKg;
    if (totalAreaHectares != null) result.totalAreaHectares = totalAreaHectares;
    if (status != null) result.status = status;
    if (notes != null) result.notes = notes;
    if (createdBy != null) result.createdBy = createdBy;
    if (updatedBy != null) result.updatedBy = updatedBy;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  HarvestPlan._();

  factory HarvestPlan.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HarvestPlan.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HarvestPlan',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'cropId')
    ..aOS(6, _omitFieldNames ? '' : 'season')
    ..aI(7, _omitFieldNames ? '' : 'year')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'plannedStartDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'plannedEndDate',
        subBuilder: $0.Timestamp.create)
    ..aD(10, _omitFieldNames ? '' : 'estimatedYieldKg')
    ..aD(11, _omitFieldNames ? '' : 'totalAreaHectares')
    ..aE<HarvestPlanStatus>(12, _omitFieldNames ? '' : 'status',
        enumValues: HarvestPlanStatus.values)
    ..aOS(13, _omitFieldNames ? '' : 'notes')
    ..aOS(14, _omitFieldNames ? '' : 'createdBy')
    ..aOS(15, _omitFieldNames ? '' : 'updatedBy')
    ..aInt64(16, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(18, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HarvestPlan clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HarvestPlan copyWith(void Function(HarvestPlan) updates) =>
      super.copyWith((message) => updates(message as HarvestPlan))
          as HarvestPlan;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HarvestPlan create() => HarvestPlan._();
  @$core.override
  HarvestPlan createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HarvestPlan getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HarvestPlan>(create);
  static HarvestPlan? _defaultInstance;

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
  $core.String get fieldId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fieldId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cropId => $_getSZ(4);
  @$pb.TagNumber(5)
  set cropId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCropId() => $_has(4);
  @$pb.TagNumber(5)
  void clearCropId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get season => $_getSZ(5);
  @$pb.TagNumber(6)
  set season($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSeason() => $_has(5);
  @$pb.TagNumber(6)
  void clearSeason() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get year => $_getIZ(6);
  @$pb.TagNumber(7)
  set year($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasYear() => $_has(6);
  @$pb.TagNumber(7)
  void clearYear() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get plannedStartDate => $_getN(7);
  @$pb.TagNumber(8)
  set plannedStartDate($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasPlannedStartDate() => $_has(7);
  @$pb.TagNumber(8)
  void clearPlannedStartDate() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensurePlannedStartDate() => $_ensure(7);

  @$pb.TagNumber(9)
  $0.Timestamp get plannedEndDate => $_getN(8);
  @$pb.TagNumber(9)
  set plannedEndDate($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasPlannedEndDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearPlannedEndDate() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensurePlannedEndDate() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.double get estimatedYieldKg => $_getN(9);
  @$pb.TagNumber(10)
  set estimatedYieldKg($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasEstimatedYieldKg() => $_has(9);
  @$pb.TagNumber(10)
  void clearEstimatedYieldKg() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get totalAreaHectares => $_getN(10);
  @$pb.TagNumber(11)
  set totalAreaHectares($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasTotalAreaHectares() => $_has(10);
  @$pb.TagNumber(11)
  void clearTotalAreaHectares() => $_clearField(11);

  @$pb.TagNumber(12)
  HarvestPlanStatus get status => $_getN(11);
  @$pb.TagNumber(12)
  set status(HarvestPlanStatus value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearStatus() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get notes => $_getSZ(12);
  @$pb.TagNumber(13)
  set notes($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasNotes() => $_has(12);
  @$pb.TagNumber(13)
  void clearNotes() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get createdBy => $_getSZ(13);
  @$pb.TagNumber(14)
  set createdBy($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasCreatedBy() => $_has(13);
  @$pb.TagNumber(14)
  void clearCreatedBy() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get updatedBy => $_getSZ(14);
  @$pb.TagNumber(15)
  set updatedBy($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasUpdatedBy() => $_has(14);
  @$pb.TagNumber(15)
  void clearUpdatedBy() => $_clearField(15);

  @$pb.TagNumber(16)
  $fixnum.Int64 get version => $_getI64(15);
  @$pb.TagNumber(16)
  set version($fixnum.Int64 value) => $_setInt64(15, value);
  @$pb.TagNumber(16)
  $core.bool hasVersion() => $_has(15);
  @$pb.TagNumber(16)
  void clearVersion() => $_clearField(16);

  @$pb.TagNumber(17)
  $0.Timestamp get createdAt => $_getN(16);
  @$pb.TagNumber(17)
  set createdAt($0.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasCreatedAt() => $_has(16);
  @$pb.TagNumber(17)
  void clearCreatedAt() => $_clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensureCreatedAt() => $_ensure(16);

  @$pb.TagNumber(18)
  $0.Timestamp get updatedAt => $_getN(17);
  @$pb.TagNumber(18)
  set updatedAt($0.Timestamp value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasUpdatedAt() => $_has(17);
  @$pb.TagNumber(18)
  void clearUpdatedAt() => $_clearField(18);
  @$pb.TagNumber(18)
  $0.Timestamp ensureUpdatedAt() => $_ensure(17);
}

/// CropPerformance represents analytics for a specific crop's performance.
class CropPerformance extends $pb.GeneratedMessage {
  factory CropPerformance({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? season,
    $core.int? year,
    $core.double? actualYieldKgPerHectare,
    $core.double? predictedYieldKgPerHectare,
    $core.double? yieldVariancePct,
    $core.double? comparisonToRegionalAvgPct,
    $core.double? comparisonToHistoricalAvgPct,
    $core.double? revenuePerHectare,
    $core.double? costPerHectare,
    $core.double? profitPerHectare,
    YieldFactors? yieldFactors,
    $fixnum.Int64? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (actualYieldKgPerHectare != null)
      result.actualYieldKgPerHectare = actualYieldKgPerHectare;
    if (predictedYieldKgPerHectare != null)
      result.predictedYieldKgPerHectare = predictedYieldKgPerHectare;
    if (yieldVariancePct != null) result.yieldVariancePct = yieldVariancePct;
    if (comparisonToRegionalAvgPct != null)
      result.comparisonToRegionalAvgPct = comparisonToRegionalAvgPct;
    if (comparisonToHistoricalAvgPct != null)
      result.comparisonToHistoricalAvgPct = comparisonToHistoricalAvgPct;
    if (revenuePerHectare != null) result.revenuePerHectare = revenuePerHectare;
    if (costPerHectare != null) result.costPerHectare = costPerHectare;
    if (profitPerHectare != null) result.profitPerHectare = profitPerHectare;
    if (yieldFactors != null) result.yieldFactors = yieldFactors;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  CropPerformance._();

  factory CropPerformance.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CropPerformance.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CropPerformance',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'cropId')
    ..aOS(6, _omitFieldNames ? '' : 'season')
    ..aI(7, _omitFieldNames ? '' : 'year')
    ..aD(8, _omitFieldNames ? '' : 'actualYieldKgPerHectare')
    ..aD(9, _omitFieldNames ? '' : 'predictedYieldKgPerHectare')
    ..aD(10, _omitFieldNames ? '' : 'yieldVariancePct')
    ..aD(11, _omitFieldNames ? '' : 'comparisonToRegionalAvgPct')
    ..aD(12, _omitFieldNames ? '' : 'comparisonToHistoricalAvgPct')
    ..aD(13, _omitFieldNames ? '' : 'revenuePerHectare')
    ..aD(14, _omitFieldNames ? '' : 'costPerHectare')
    ..aD(15, _omitFieldNames ? '' : 'profitPerHectare')
    ..aOM<YieldFactors>(16, _omitFieldNames ? '' : 'yieldFactors',
        subBuilder: YieldFactors.create)
    ..aInt64(17, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(18, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(19, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CropPerformance clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CropPerformance copyWith(void Function(CropPerformance) updates) =>
      super.copyWith((message) => updates(message as CropPerformance))
          as CropPerformance;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CropPerformance create() => CropPerformance._();
  @$core.override
  CropPerformance createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CropPerformance getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CropPerformance>(create);
  static CropPerformance? _defaultInstance;

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
  $core.String get fieldId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fieldId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cropId => $_getSZ(4);
  @$pb.TagNumber(5)
  set cropId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCropId() => $_has(4);
  @$pb.TagNumber(5)
  void clearCropId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get season => $_getSZ(5);
  @$pb.TagNumber(6)
  set season($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSeason() => $_has(5);
  @$pb.TagNumber(6)
  void clearSeason() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get year => $_getIZ(6);
  @$pb.TagNumber(7)
  set year($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasYear() => $_has(6);
  @$pb.TagNumber(7)
  void clearYear() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get actualYieldKgPerHectare => $_getN(7);
  @$pb.TagNumber(8)
  set actualYieldKgPerHectare($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasActualYieldKgPerHectare() => $_has(7);
  @$pb.TagNumber(8)
  void clearActualYieldKgPerHectare() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get predictedYieldKgPerHectare => $_getN(8);
  @$pb.TagNumber(9)
  set predictedYieldKgPerHectare($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPredictedYieldKgPerHectare() => $_has(8);
  @$pb.TagNumber(9)
  void clearPredictedYieldKgPerHectare() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get yieldVariancePct => $_getN(9);
  @$pb.TagNumber(10)
  set yieldVariancePct($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasYieldVariancePct() => $_has(9);
  @$pb.TagNumber(10)
  void clearYieldVariancePct() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get comparisonToRegionalAvgPct => $_getN(10);
  @$pb.TagNumber(11)
  set comparisonToRegionalAvgPct($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasComparisonToRegionalAvgPct() => $_has(10);
  @$pb.TagNumber(11)
  void clearComparisonToRegionalAvgPct() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get comparisonToHistoricalAvgPct => $_getN(11);
  @$pb.TagNumber(12)
  set comparisonToHistoricalAvgPct($core.double value) =>
      $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasComparisonToHistoricalAvgPct() => $_has(11);
  @$pb.TagNumber(12)
  void clearComparisonToHistoricalAvgPct() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get revenuePerHectare => $_getN(12);
  @$pb.TagNumber(13)
  set revenuePerHectare($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasRevenuePerHectare() => $_has(12);
  @$pb.TagNumber(13)
  void clearRevenuePerHectare() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get costPerHectare => $_getN(13);
  @$pb.TagNumber(14)
  set costPerHectare($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasCostPerHectare() => $_has(13);
  @$pb.TagNumber(14)
  void clearCostPerHectare() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get profitPerHectare => $_getN(14);
  @$pb.TagNumber(15)
  set profitPerHectare($core.double value) => $_setDouble(14, value);
  @$pb.TagNumber(15)
  $core.bool hasProfitPerHectare() => $_has(14);
  @$pb.TagNumber(15)
  void clearProfitPerHectare() => $_clearField(15);

  @$pb.TagNumber(16)
  YieldFactors get yieldFactors => $_getN(15);
  @$pb.TagNumber(16)
  set yieldFactors(YieldFactors value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasYieldFactors() => $_has(15);
  @$pb.TagNumber(16)
  void clearYieldFactors() => $_clearField(16);
  @$pb.TagNumber(16)
  YieldFactors ensureYieldFactors() => $_ensure(15);

  @$pb.TagNumber(17)
  $fixnum.Int64 get version => $_getI64(16);
  @$pb.TagNumber(17)
  set version($fixnum.Int64 value) => $_setInt64(16, value);
  @$pb.TagNumber(17)
  $core.bool hasVersion() => $_has(16);
  @$pb.TagNumber(17)
  void clearVersion() => $_clearField(17);

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
}

class PredictYieldRequest extends $pb.GeneratedMessage {
  factory PredictYieldRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? season,
    $core.int? year,
    YieldFactors? yieldFactors,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (yieldFactors != null) result.yieldFactors = yieldFactors;
    return result;
  }

  PredictYieldRequest._();

  factory PredictYieldRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PredictYieldRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PredictYieldRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'cropId')
    ..aOS(4, _omitFieldNames ? '' : 'season')
    ..aI(5, _omitFieldNames ? '' : 'year')
    ..aOM<YieldFactors>(6, _omitFieldNames ? '' : 'yieldFactors',
        subBuilder: YieldFactors.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PredictYieldRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PredictYieldRequest copyWith(void Function(PredictYieldRequest) updates) =>
      super.copyWith((message) => updates(message as PredictYieldRequest))
          as PredictYieldRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PredictYieldRequest create() => PredictYieldRequest._();
  @$core.override
  PredictYieldRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PredictYieldRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PredictYieldRequest>(create);
  static PredictYieldRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

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
  $core.String get season => $_getSZ(3);
  @$pb.TagNumber(4)
  set season($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSeason() => $_has(3);
  @$pb.TagNumber(4)
  void clearSeason() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get year => $_getIZ(4);
  @$pb.TagNumber(5)
  set year($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasYear() => $_has(4);
  @$pb.TagNumber(5)
  void clearYear() => $_clearField(5);

  @$pb.TagNumber(6)
  YieldFactors get yieldFactors => $_getN(5);
  @$pb.TagNumber(6)
  set yieldFactors(YieldFactors value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasYieldFactors() => $_has(5);
  @$pb.TagNumber(6)
  void clearYieldFactors() => $_clearField(6);
  @$pb.TagNumber(6)
  YieldFactors ensureYieldFactors() => $_ensure(5);
}

class PredictYieldResponse extends $pb.GeneratedMessage {
  factory PredictYieldResponse({
    YieldPrediction? prediction,
  }) {
    final result = create();
    if (prediction != null) result.prediction = prediction;
    return result;
  }

  PredictYieldResponse._();

  factory PredictYieldResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PredictYieldResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PredictYieldResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOM<YieldPrediction>(1, _omitFieldNames ? '' : 'prediction',
        subBuilder: YieldPrediction.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PredictYieldResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PredictYieldResponse copyWith(void Function(PredictYieldResponse) updates) =>
      super.copyWith((message) => updates(message as PredictYieldResponse))
          as PredictYieldResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PredictYieldResponse create() => PredictYieldResponse._();
  @$core.override
  PredictYieldResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PredictYieldResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PredictYieldResponse>(create);
  static PredictYieldResponse? _defaultInstance;

  @$pb.TagNumber(1)
  YieldPrediction get prediction => $_getN(0);
  @$pb.TagNumber(1)
  set prediction(YieldPrediction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPrediction() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrediction() => $_clearField(1);
  @$pb.TagNumber(1)
  YieldPrediction ensurePrediction() => $_ensure(0);
}

class GetPredictionRequest extends $pb.GeneratedMessage {
  factory GetPredictionRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetPredictionRequest._();

  factory GetPredictionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPredictionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPredictionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPredictionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPredictionRequest copyWith(void Function(GetPredictionRequest) updates) =>
      super.copyWith((message) => updates(message as GetPredictionRequest))
          as GetPredictionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPredictionRequest create() => GetPredictionRequest._();
  @$core.override
  GetPredictionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPredictionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPredictionRequest>(create);
  static GetPredictionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetPredictionResponse extends $pb.GeneratedMessage {
  factory GetPredictionResponse({
    YieldPrediction? prediction,
  }) {
    final result = create();
    if (prediction != null) result.prediction = prediction;
    return result;
  }

  GetPredictionResponse._();

  factory GetPredictionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPredictionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPredictionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOM<YieldPrediction>(1, _omitFieldNames ? '' : 'prediction',
        subBuilder: YieldPrediction.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPredictionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPredictionResponse copyWith(
          void Function(GetPredictionResponse) updates) =>
      super.copyWith((message) => updates(message as GetPredictionResponse))
          as GetPredictionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPredictionResponse create() => GetPredictionResponse._();
  @$core.override
  GetPredictionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPredictionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPredictionResponse>(create);
  static GetPredictionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  YieldPrediction get prediction => $_getN(0);
  @$pb.TagNumber(1)
  set prediction(YieldPrediction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPrediction() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrediction() => $_clearField(1);
  @$pb.TagNumber(1)
  YieldPrediction ensurePrediction() => $_ensure(0);
}

class ListPredictionsRequest extends $pb.GeneratedMessage {
  factory ListPredictionsRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? season,
    $core.int? year,
    PredictionStatus? status,
    $core.String? orderBy,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (status != null) result.status = status;
    if (orderBy != null) result.orderBy = orderBy;
    return result;
  }

  ListPredictionsRequest._();

  factory ListPredictionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPredictionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPredictionsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'cropId')
    ..aOS(6, _omitFieldNames ? '' : 'season')
    ..aI(7, _omitFieldNames ? '' : 'year')
    ..aE<PredictionStatus>(8, _omitFieldNames ? '' : 'status',
        enumValues: PredictionStatus.values)
    ..aOS(9, _omitFieldNames ? '' : 'orderBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPredictionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPredictionsRequest copyWith(
          void Function(ListPredictionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListPredictionsRequest))
          as ListPredictionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPredictionsRequest create() => ListPredictionsRequest._();
  @$core.override
  ListPredictionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPredictionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPredictionsRequest>(create);
  static ListPredictionsRequest? _defaultInstance;

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
  $core.String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fieldId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fieldId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cropId => $_getSZ(4);
  @$pb.TagNumber(5)
  set cropId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCropId() => $_has(4);
  @$pb.TagNumber(5)
  void clearCropId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get season => $_getSZ(5);
  @$pb.TagNumber(6)
  set season($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSeason() => $_has(5);
  @$pb.TagNumber(6)
  void clearSeason() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get year => $_getIZ(6);
  @$pb.TagNumber(7)
  set year($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasYear() => $_has(6);
  @$pb.TagNumber(7)
  void clearYear() => $_clearField(7);

  @$pb.TagNumber(8)
  PredictionStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(PredictionStatus value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get orderBy => $_getSZ(8);
  @$pb.TagNumber(9)
  set orderBy($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOrderBy() => $_has(8);
  @$pb.TagNumber(9)
  void clearOrderBy() => $_clearField(9);
}

class ListPredictionsResponse extends $pb.GeneratedMessage {
  factory ListPredictionsResponse({
    $core.Iterable<YieldPrediction>? predictions,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (predictions != null) result.predictions.addAll(predictions);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListPredictionsResponse._();

  factory ListPredictionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPredictionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPredictionsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..pPM<YieldPrediction>(1, _omitFieldNames ? '' : 'predictions',
        subBuilder: YieldPrediction.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPredictionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPredictionsResponse copyWith(
          void Function(ListPredictionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListPredictionsResponse))
          as ListPredictionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPredictionsResponse create() => ListPredictionsResponse._();
  @$core.override
  ListPredictionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPredictionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPredictionsResponse>(create);
  static ListPredictionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<YieldPrediction> get predictions => $_getList(0);

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

class RecordYieldRequest extends $pb.GeneratedMessage {
  factory RecordYieldRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? season,
    $core.int? year,
    $core.double? actualYieldKgPerHectare,
    $core.double? totalAreaHarvestedHectares,
    $core.double? totalYieldKg,
    HarvestQualityGrade? harvestQualityGrade,
    $core.double? moistureContentPct,
    $0.Timestamp? harvestDate,
    $core.double? revenuePerHectare,
    $core.double? costPerHectare,
    $core.String? predictionId,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (actualYieldKgPerHectare != null)
      result.actualYieldKgPerHectare = actualYieldKgPerHectare;
    if (totalAreaHarvestedHectares != null)
      result.totalAreaHarvestedHectares = totalAreaHarvestedHectares;
    if (totalYieldKg != null) result.totalYieldKg = totalYieldKg;
    if (harvestQualityGrade != null)
      result.harvestQualityGrade = harvestQualityGrade;
    if (moistureContentPct != null)
      result.moistureContentPct = moistureContentPct;
    if (harvestDate != null) result.harvestDate = harvestDate;
    if (revenuePerHectare != null) result.revenuePerHectare = revenuePerHectare;
    if (costPerHectare != null) result.costPerHectare = costPerHectare;
    if (predictionId != null) result.predictionId = predictionId;
    return result;
  }

  RecordYieldRequest._();

  factory RecordYieldRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecordYieldRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecordYieldRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'cropId')
    ..aOS(4, _omitFieldNames ? '' : 'season')
    ..aI(5, _omitFieldNames ? '' : 'year')
    ..aD(6, _omitFieldNames ? '' : 'actualYieldKgPerHectare')
    ..aD(7, _omitFieldNames ? '' : 'totalAreaHarvestedHectares')
    ..aD(8, _omitFieldNames ? '' : 'totalYieldKg')
    ..aE<HarvestQualityGrade>(9, _omitFieldNames ? '' : 'harvestQualityGrade',
        enumValues: HarvestQualityGrade.values)
    ..aD(10, _omitFieldNames ? '' : 'moistureContentPct')
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'harvestDate',
        subBuilder: $0.Timestamp.create)
    ..aD(12, _omitFieldNames ? '' : 'revenuePerHectare')
    ..aD(13, _omitFieldNames ? '' : 'costPerHectare')
    ..aOS(14, _omitFieldNames ? '' : 'predictionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordYieldRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordYieldRequest copyWith(void Function(RecordYieldRequest) updates) =>
      super.copyWith((message) => updates(message as RecordYieldRequest))
          as RecordYieldRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecordYieldRequest create() => RecordYieldRequest._();
  @$core.override
  RecordYieldRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecordYieldRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecordYieldRequest>(create);
  static RecordYieldRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

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
  $core.String get season => $_getSZ(3);
  @$pb.TagNumber(4)
  set season($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSeason() => $_has(3);
  @$pb.TagNumber(4)
  void clearSeason() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get year => $_getIZ(4);
  @$pb.TagNumber(5)
  set year($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasYear() => $_has(4);
  @$pb.TagNumber(5)
  void clearYear() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get actualYieldKgPerHectare => $_getN(5);
  @$pb.TagNumber(6)
  set actualYieldKgPerHectare($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasActualYieldKgPerHectare() => $_has(5);
  @$pb.TagNumber(6)
  void clearActualYieldKgPerHectare() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get totalAreaHarvestedHectares => $_getN(6);
  @$pb.TagNumber(7)
  set totalAreaHarvestedHectares($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTotalAreaHarvestedHectares() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalAreaHarvestedHectares() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get totalYieldKg => $_getN(7);
  @$pb.TagNumber(8)
  set totalYieldKg($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTotalYieldKg() => $_has(7);
  @$pb.TagNumber(8)
  void clearTotalYieldKg() => $_clearField(8);

  @$pb.TagNumber(9)
  HarvestQualityGrade get harvestQualityGrade => $_getN(8);
  @$pb.TagNumber(9)
  set harvestQualityGrade(HarvestQualityGrade value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasHarvestQualityGrade() => $_has(8);
  @$pb.TagNumber(9)
  void clearHarvestQualityGrade() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get moistureContentPct => $_getN(9);
  @$pb.TagNumber(10)
  set moistureContentPct($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMoistureContentPct() => $_has(9);
  @$pb.TagNumber(10)
  void clearMoistureContentPct() => $_clearField(10);

  @$pb.TagNumber(11)
  $0.Timestamp get harvestDate => $_getN(10);
  @$pb.TagNumber(11)
  set harvestDate($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasHarvestDate() => $_has(10);
  @$pb.TagNumber(11)
  void clearHarvestDate() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureHarvestDate() => $_ensure(10);

  @$pb.TagNumber(12)
  $core.double get revenuePerHectare => $_getN(11);
  @$pb.TagNumber(12)
  set revenuePerHectare($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasRevenuePerHectare() => $_has(11);
  @$pb.TagNumber(12)
  void clearRevenuePerHectare() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get costPerHectare => $_getN(12);
  @$pb.TagNumber(13)
  set costPerHectare($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCostPerHectare() => $_has(12);
  @$pb.TagNumber(13)
  void clearCostPerHectare() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get predictionId => $_getSZ(13);
  @$pb.TagNumber(14)
  set predictionId($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasPredictionId() => $_has(13);
  @$pb.TagNumber(14)
  void clearPredictionId() => $_clearField(14);
}

class RecordYieldResponse extends $pb.GeneratedMessage {
  factory RecordYieldResponse({
    YieldRecord? record,
  }) {
    final result = create();
    if (record != null) result.record = record;
    return result;
  }

  RecordYieldResponse._();

  factory RecordYieldResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecordYieldResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecordYieldResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOM<YieldRecord>(1, _omitFieldNames ? '' : 'record',
        subBuilder: YieldRecord.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordYieldResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordYieldResponse copyWith(void Function(RecordYieldResponse) updates) =>
      super.copyWith((message) => updates(message as RecordYieldResponse))
          as RecordYieldResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecordYieldResponse create() => RecordYieldResponse._();
  @$core.override
  RecordYieldResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecordYieldResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecordYieldResponse>(create);
  static RecordYieldResponse? _defaultInstance;

  @$pb.TagNumber(1)
  YieldRecord get record => $_getN(0);
  @$pb.TagNumber(1)
  set record(YieldRecord value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRecord() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecord() => $_clearField(1);
  @$pb.TagNumber(1)
  YieldRecord ensureRecord() => $_ensure(0);
}

class GetYieldHistoryRequest extends $pb.GeneratedMessage {
  factory GetYieldHistoryRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.int? fromYear,
    $core.int? toYear,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (fromYear != null) result.fromYear = fromYear;
    if (toYear != null) result.toYear = toYear;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  GetYieldHistoryRequest._();

  factory GetYieldHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetYieldHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetYieldHistoryRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'cropId')
    ..aI(4, _omitFieldNames ? '' : 'fromYear')
    ..aI(5, _omitFieldNames ? '' : 'toYear')
    ..aI(6, _omitFieldNames ? '' : 'pageSize')
    ..aOS(7, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetYieldHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetYieldHistoryRequest copyWith(
          void Function(GetYieldHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as GetYieldHistoryRequest))
          as GetYieldHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetYieldHistoryRequest create() => GetYieldHistoryRequest._();
  @$core.override
  GetYieldHistoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetYieldHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetYieldHistoryRequest>(create);
  static GetYieldHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

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
  $core.int get fromYear => $_getIZ(3);
  @$pb.TagNumber(4)
  set fromYear($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFromYear() => $_has(3);
  @$pb.TagNumber(4)
  void clearFromYear() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get toYear => $_getIZ(4);
  @$pb.TagNumber(5)
  set toYear($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasToYear() => $_has(4);
  @$pb.TagNumber(5)
  void clearToYear() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get pageSize => $_getIZ(5);
  @$pb.TagNumber(6)
  set pageSize($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageSize() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get pageToken => $_getSZ(6);
  @$pb.TagNumber(7)
  set pageToken($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPageToken() => $_has(6);
  @$pb.TagNumber(7)
  void clearPageToken() => $_clearField(7);
}

class GetYieldHistoryResponse extends $pb.GeneratedMessage {
  factory GetYieldHistoryResponse({
    $core.Iterable<YieldRecord>? records,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (records != null) result.records.addAll(records);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  GetYieldHistoryResponse._();

  factory GetYieldHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetYieldHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetYieldHistoryResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..pPM<YieldRecord>(1, _omitFieldNames ? '' : 'records',
        subBuilder: YieldRecord.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetYieldHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetYieldHistoryResponse copyWith(
          void Function(GetYieldHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as GetYieldHistoryResponse))
          as GetYieldHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetYieldHistoryResponse create() => GetYieldHistoryResponse._();
  @$core.override
  GetYieldHistoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetYieldHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetYieldHistoryResponse>(create);
  static GetYieldHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<YieldRecord> get records => $_getList(0);

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

class CreateHarvestPlanRequest extends $pb.GeneratedMessage {
  factory CreateHarvestPlanRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? season,
    $core.int? year,
    $0.Timestamp? plannedStartDate,
    $0.Timestamp? plannedEndDate,
    $core.double? estimatedYieldKg,
    $core.double? totalAreaHectares,
    $core.String? notes,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (plannedStartDate != null) result.plannedStartDate = plannedStartDate;
    if (plannedEndDate != null) result.plannedEndDate = plannedEndDate;
    if (estimatedYieldKg != null) result.estimatedYieldKg = estimatedYieldKg;
    if (totalAreaHectares != null) result.totalAreaHectares = totalAreaHectares;
    if (notes != null) result.notes = notes;
    return result;
  }

  CreateHarvestPlanRequest._();

  factory CreateHarvestPlanRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateHarvestPlanRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateHarvestPlanRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'cropId')
    ..aOS(4, _omitFieldNames ? '' : 'season')
    ..aI(5, _omitFieldNames ? '' : 'year')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'plannedStartDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'plannedEndDate',
        subBuilder: $0.Timestamp.create)
    ..aD(8, _omitFieldNames ? '' : 'estimatedYieldKg')
    ..aD(9, _omitFieldNames ? '' : 'totalAreaHectares')
    ..aOS(10, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateHarvestPlanRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateHarvestPlanRequest copyWith(
          void Function(CreateHarvestPlanRequest) updates) =>
      super.copyWith((message) => updates(message as CreateHarvestPlanRequest))
          as CreateHarvestPlanRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateHarvestPlanRequest create() => CreateHarvestPlanRequest._();
  @$core.override
  CreateHarvestPlanRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateHarvestPlanRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateHarvestPlanRequest>(create);
  static CreateHarvestPlanRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

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
  $core.String get season => $_getSZ(3);
  @$pb.TagNumber(4)
  set season($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSeason() => $_has(3);
  @$pb.TagNumber(4)
  void clearSeason() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get year => $_getIZ(4);
  @$pb.TagNumber(5)
  set year($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasYear() => $_has(4);
  @$pb.TagNumber(5)
  void clearYear() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get plannedStartDate => $_getN(5);
  @$pb.TagNumber(6)
  set plannedStartDate($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasPlannedStartDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearPlannedStartDate() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensurePlannedStartDate() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Timestamp get plannedEndDate => $_getN(6);
  @$pb.TagNumber(7)
  set plannedEndDate($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasPlannedEndDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearPlannedEndDate() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensurePlannedEndDate() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.double get estimatedYieldKg => $_getN(7);
  @$pb.TagNumber(8)
  set estimatedYieldKg($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEstimatedYieldKg() => $_has(7);
  @$pb.TagNumber(8)
  void clearEstimatedYieldKg() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get totalAreaHectares => $_getN(8);
  @$pb.TagNumber(9)
  set totalAreaHectares($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTotalAreaHectares() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotalAreaHectares() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get notes => $_getSZ(9);
  @$pb.TagNumber(10)
  set notes($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNotes() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotes() => $_clearField(10);
}

class CreateHarvestPlanResponse extends $pb.GeneratedMessage {
  factory CreateHarvestPlanResponse({
    HarvestPlan? plan,
  }) {
    final result = create();
    if (plan != null) result.plan = plan;
    return result;
  }

  CreateHarvestPlanResponse._();

  factory CreateHarvestPlanResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateHarvestPlanResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateHarvestPlanResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOM<HarvestPlan>(1, _omitFieldNames ? '' : 'plan',
        subBuilder: HarvestPlan.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateHarvestPlanResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateHarvestPlanResponse copyWith(
          void Function(CreateHarvestPlanResponse) updates) =>
      super.copyWith((message) => updates(message as CreateHarvestPlanResponse))
          as CreateHarvestPlanResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateHarvestPlanResponse create() => CreateHarvestPlanResponse._();
  @$core.override
  CreateHarvestPlanResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateHarvestPlanResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateHarvestPlanResponse>(create);
  static CreateHarvestPlanResponse? _defaultInstance;

  @$pb.TagNumber(1)
  HarvestPlan get plan => $_getN(0);
  @$pb.TagNumber(1)
  set plan(HarvestPlan value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPlan() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlan() => $_clearField(1);
  @$pb.TagNumber(1)
  HarvestPlan ensurePlan() => $_ensure(0);
}

class GetHarvestPlanRequest extends $pb.GeneratedMessage {
  factory GetHarvestPlanRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetHarvestPlanRequest._();

  factory GetHarvestPlanRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHarvestPlanRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHarvestPlanRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHarvestPlanRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHarvestPlanRequest copyWith(
          void Function(GetHarvestPlanRequest) updates) =>
      super.copyWith((message) => updates(message as GetHarvestPlanRequest))
          as GetHarvestPlanRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHarvestPlanRequest create() => GetHarvestPlanRequest._();
  @$core.override
  GetHarvestPlanRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHarvestPlanRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHarvestPlanRequest>(create);
  static GetHarvestPlanRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetHarvestPlanResponse extends $pb.GeneratedMessage {
  factory GetHarvestPlanResponse({
    HarvestPlan? plan,
  }) {
    final result = create();
    if (plan != null) result.plan = plan;
    return result;
  }

  GetHarvestPlanResponse._();

  factory GetHarvestPlanResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHarvestPlanResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHarvestPlanResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOM<HarvestPlan>(1, _omitFieldNames ? '' : 'plan',
        subBuilder: HarvestPlan.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHarvestPlanResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHarvestPlanResponse copyWith(
          void Function(GetHarvestPlanResponse) updates) =>
      super.copyWith((message) => updates(message as GetHarvestPlanResponse))
          as GetHarvestPlanResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHarvestPlanResponse create() => GetHarvestPlanResponse._();
  @$core.override
  GetHarvestPlanResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHarvestPlanResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHarvestPlanResponse>(create);
  static GetHarvestPlanResponse? _defaultInstance;

  @$pb.TagNumber(1)
  HarvestPlan get plan => $_getN(0);
  @$pb.TagNumber(1)
  set plan(HarvestPlan value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPlan() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlan() => $_clearField(1);
  @$pb.TagNumber(1)
  HarvestPlan ensurePlan() => $_ensure(0);
}

class ListHarvestPlansRequest extends $pb.GeneratedMessage {
  factory ListHarvestPlansRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? season,
    $core.int? year,
    HarvestPlanStatus? status,
    $core.String? orderBy,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (status != null) result.status = status;
    if (orderBy != null) result.orderBy = orderBy;
    return result;
  }

  ListHarvestPlansRequest._();

  factory ListHarvestPlansRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListHarvestPlansRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListHarvestPlansRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'cropId')
    ..aOS(6, _omitFieldNames ? '' : 'season')
    ..aI(7, _omitFieldNames ? '' : 'year')
    ..aE<HarvestPlanStatus>(8, _omitFieldNames ? '' : 'status',
        enumValues: HarvestPlanStatus.values)
    ..aOS(9, _omitFieldNames ? '' : 'orderBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListHarvestPlansRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListHarvestPlansRequest copyWith(
          void Function(ListHarvestPlansRequest) updates) =>
      super.copyWith((message) => updates(message as ListHarvestPlansRequest))
          as ListHarvestPlansRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListHarvestPlansRequest create() => ListHarvestPlansRequest._();
  @$core.override
  ListHarvestPlansRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListHarvestPlansRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListHarvestPlansRequest>(create);
  static ListHarvestPlansRequest? _defaultInstance;

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
  $core.String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fieldId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fieldId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cropId => $_getSZ(4);
  @$pb.TagNumber(5)
  set cropId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCropId() => $_has(4);
  @$pb.TagNumber(5)
  void clearCropId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get season => $_getSZ(5);
  @$pb.TagNumber(6)
  set season($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSeason() => $_has(5);
  @$pb.TagNumber(6)
  void clearSeason() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get year => $_getIZ(6);
  @$pb.TagNumber(7)
  set year($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasYear() => $_has(6);
  @$pb.TagNumber(7)
  void clearYear() => $_clearField(7);

  @$pb.TagNumber(8)
  HarvestPlanStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(HarvestPlanStatus value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get orderBy => $_getSZ(8);
  @$pb.TagNumber(9)
  set orderBy($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOrderBy() => $_has(8);
  @$pb.TagNumber(9)
  void clearOrderBy() => $_clearField(9);
}

class ListHarvestPlansResponse extends $pb.GeneratedMessage {
  factory ListHarvestPlansResponse({
    $core.Iterable<HarvestPlan>? plans,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (plans != null) result.plans.addAll(plans);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListHarvestPlansResponse._();

  factory ListHarvestPlansResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListHarvestPlansResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListHarvestPlansResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..pPM<HarvestPlan>(1, _omitFieldNames ? '' : 'plans',
        subBuilder: HarvestPlan.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListHarvestPlansResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListHarvestPlansResponse copyWith(
          void Function(ListHarvestPlansResponse) updates) =>
      super.copyWith((message) => updates(message as ListHarvestPlansResponse))
          as ListHarvestPlansResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListHarvestPlansResponse create() => ListHarvestPlansResponse._();
  @$core.override
  ListHarvestPlansResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListHarvestPlansResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListHarvestPlansResponse>(create);
  static ListHarvestPlansResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<HarvestPlan> get plans => $_getList(0);

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

class GetCropPerformanceRequest extends $pb.GeneratedMessage {
  factory GetCropPerformanceRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? season,
    $core.int? year,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    return result;
  }

  GetCropPerformanceRequest._();

  factory GetCropPerformanceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCropPerformanceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCropPerformanceRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'cropId')
    ..aOS(4, _omitFieldNames ? '' : 'season')
    ..aI(5, _omitFieldNames ? '' : 'year')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropPerformanceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropPerformanceRequest copyWith(
          void Function(GetCropPerformanceRequest) updates) =>
      super.copyWith((message) => updates(message as GetCropPerformanceRequest))
          as GetCropPerformanceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCropPerformanceRequest create() => GetCropPerformanceRequest._();
  @$core.override
  GetCropPerformanceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCropPerformanceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCropPerformanceRequest>(create);
  static GetCropPerformanceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

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
  $core.String get season => $_getSZ(3);
  @$pb.TagNumber(4)
  set season($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSeason() => $_has(3);
  @$pb.TagNumber(4)
  void clearSeason() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get year => $_getIZ(4);
  @$pb.TagNumber(5)
  set year($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasYear() => $_has(4);
  @$pb.TagNumber(5)
  void clearYear() => $_clearField(5);
}

class GetCropPerformanceResponse extends $pb.GeneratedMessage {
  factory GetCropPerformanceResponse({
    CropPerformance? performance,
  }) {
    final result = create();
    if (performance != null) result.performance = performance;
    return result;
  }

  GetCropPerformanceResponse._();

  factory GetCropPerformanceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCropPerformanceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCropPerformanceResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOM<CropPerformance>(1, _omitFieldNames ? '' : 'performance',
        subBuilder: CropPerformance.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropPerformanceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCropPerformanceResponse copyWith(
          void Function(GetCropPerformanceResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetCropPerformanceResponse))
          as GetCropPerformanceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCropPerformanceResponse create() => GetCropPerformanceResponse._();
  @$core.override
  GetCropPerformanceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCropPerformanceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCropPerformanceResponse>(create);
  static GetCropPerformanceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CropPerformance get performance => $_getN(0);
  @$pb.TagNumber(1)
  set performance(CropPerformance value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPerformance() => $_has(0);
  @$pb.TagNumber(1)
  void clearPerformance() => $_clearField(1);
  @$pb.TagNumber(1)
  CropPerformance ensurePerformance() => $_ensure(0);
}

class CompareYieldsRequest extends $pb.GeneratedMessage {
  factory CompareYieldsRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.int? yearA,
    $core.String? seasonA,
    $core.int? yearB,
    $core.String? seasonB,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (yearA != null) result.yearA = yearA;
    if (seasonA != null) result.seasonA = seasonA;
    if (yearB != null) result.yearB = yearB;
    if (seasonB != null) result.seasonB = seasonB;
    return result;
  }

  CompareYieldsRequest._();

  factory CompareYieldsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CompareYieldsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CompareYieldsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'cropId')
    ..aI(4, _omitFieldNames ? '' : 'yearA')
    ..aOS(5, _omitFieldNames ? '' : 'seasonA')
    ..aI(6, _omitFieldNames ? '' : 'yearB')
    ..aOS(7, _omitFieldNames ? '' : 'seasonB')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompareYieldsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompareYieldsRequest copyWith(void Function(CompareYieldsRequest) updates) =>
      super.copyWith((message) => updates(message as CompareYieldsRequest))
          as CompareYieldsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CompareYieldsRequest create() => CompareYieldsRequest._();
  @$core.override
  CompareYieldsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CompareYieldsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CompareYieldsRequest>(create);
  static CompareYieldsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

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
  $core.int get yearA => $_getIZ(3);
  @$pb.TagNumber(4)
  set yearA($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasYearA() => $_has(3);
  @$pb.TagNumber(4)
  void clearYearA() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get seasonA => $_getSZ(4);
  @$pb.TagNumber(5)
  set seasonA($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSeasonA() => $_has(4);
  @$pb.TagNumber(5)
  void clearSeasonA() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get yearB => $_getIZ(5);
  @$pb.TagNumber(6)
  set yearB($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasYearB() => $_has(5);
  @$pb.TagNumber(6)
  void clearYearB() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get seasonB => $_getSZ(6);
  @$pb.TagNumber(7)
  set seasonB($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSeasonB() => $_has(6);
  @$pb.TagNumber(7)
  void clearSeasonB() => $_clearField(7);
}

class CompareYieldsResponse extends $pb.GeneratedMessage {
  factory CompareYieldsResponse({
    CropPerformance? performanceA,
    CropPerformance? performanceB,
    $core.double? yieldDifferenceKgPerHectare,
    $core.double? yieldDifferencePct,
    $core.double? profitDifferencePerHectare,
  }) {
    final result = create();
    if (performanceA != null) result.performanceA = performanceA;
    if (performanceB != null) result.performanceB = performanceB;
    if (yieldDifferenceKgPerHectare != null)
      result.yieldDifferenceKgPerHectare = yieldDifferenceKgPerHectare;
    if (yieldDifferencePct != null)
      result.yieldDifferencePct = yieldDifferencePct;
    if (profitDifferencePerHectare != null)
      result.profitDifferencePerHectare = profitDifferencePerHectare;
    return result;
  }

  CompareYieldsResponse._();

  factory CompareYieldsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CompareYieldsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CompareYieldsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.yield.v1'),
      createEmptyInstance: create)
    ..aOM<CropPerformance>(1, _omitFieldNames ? '' : 'performanceA',
        subBuilder: CropPerformance.create)
    ..aOM<CropPerformance>(2, _omitFieldNames ? '' : 'performanceB',
        subBuilder: CropPerformance.create)
    ..aD(3, _omitFieldNames ? '' : 'yieldDifferenceKgPerHectare')
    ..aD(4, _omitFieldNames ? '' : 'yieldDifferencePct')
    ..aD(5, _omitFieldNames ? '' : 'profitDifferencePerHectare')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompareYieldsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CompareYieldsResponse copyWith(
          void Function(CompareYieldsResponse) updates) =>
      super.copyWith((message) => updates(message as CompareYieldsResponse))
          as CompareYieldsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CompareYieldsResponse create() => CompareYieldsResponse._();
  @$core.override
  CompareYieldsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CompareYieldsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CompareYieldsResponse>(create);
  static CompareYieldsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CropPerformance get performanceA => $_getN(0);
  @$pb.TagNumber(1)
  set performanceA(CropPerformance value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPerformanceA() => $_has(0);
  @$pb.TagNumber(1)
  void clearPerformanceA() => $_clearField(1);
  @$pb.TagNumber(1)
  CropPerformance ensurePerformanceA() => $_ensure(0);

  @$pb.TagNumber(2)
  CropPerformance get performanceB => $_getN(1);
  @$pb.TagNumber(2)
  set performanceB(CropPerformance value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPerformanceB() => $_has(1);
  @$pb.TagNumber(2)
  void clearPerformanceB() => $_clearField(2);
  @$pb.TagNumber(2)
  CropPerformance ensurePerformanceB() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.double get yieldDifferenceKgPerHectare => $_getN(2);
  @$pb.TagNumber(3)
  set yieldDifferenceKgPerHectare($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasYieldDifferenceKgPerHectare() => $_has(2);
  @$pb.TagNumber(3)
  void clearYieldDifferenceKgPerHectare() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get yieldDifferencePct => $_getN(3);
  @$pb.TagNumber(4)
  set yieldDifferencePct($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasYieldDifferencePct() => $_has(3);
  @$pb.TagNumber(4)
  void clearYieldDifferencePct() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get profitDifferencePerHectare => $_getN(4);
  @$pb.TagNumber(5)
  set profitDifferencePerHectare($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProfitDifferencePerHectare() => $_has(4);
  @$pb.TagNumber(5)
  void clearProfitDifferencePerHectare() => $_clearField(5);
}

/// YieldService provides yield management and analytics operations.
class YieldServiceApi {
  final $pb.RpcClient _client;

  YieldServiceApi(this._client);

  /// PredictYield generates a yield prediction using multi-factor analysis.
  $async.Future<PredictYieldResponse> predictYield(
          $pb.ClientContext? ctx, PredictYieldRequest request) =>
      _client.invoke<PredictYieldResponse>(
          ctx, 'YieldService', 'PredictYield', request, PredictYieldResponse());

  /// GetPrediction retrieves a yield prediction by ID.
  $async.Future<GetPredictionResponse> getPrediction(
          $pb.ClientContext? ctx, GetPredictionRequest request) =>
      _client.invoke<GetPredictionResponse>(ctx, 'YieldService',
          'GetPrediction', request, GetPredictionResponse());

  /// ListPredictions lists yield predictions with filtering and pagination.
  $async.Future<ListPredictionsResponse> listPredictions(
          $pb.ClientContext? ctx, ListPredictionsRequest request) =>
      _client.invoke<ListPredictionsResponse>(ctx, 'YieldService',
          'ListPredictions', request, ListPredictionsResponse());

  /// RecordYield records an actual harvest yield.
  $async.Future<RecordYieldResponse> recordYield(
          $pb.ClientContext? ctx, RecordYieldRequest request) =>
      _client.invoke<RecordYieldResponse>(
          ctx, 'YieldService', 'RecordYield', request, RecordYieldResponse());

  /// GetYieldHistory retrieves historical yield records.
  $async.Future<GetYieldHistoryResponse> getYieldHistory(
          $pb.ClientContext? ctx, GetYieldHistoryRequest request) =>
      _client.invoke<GetYieldHistoryResponse>(ctx, 'YieldService',
          'GetYieldHistory', request, GetYieldHistoryResponse());

  /// CreateHarvestPlan creates a new harvest plan.
  $async.Future<CreateHarvestPlanResponse> createHarvestPlan(
          $pb.ClientContext? ctx, CreateHarvestPlanRequest request) =>
      _client.invoke<CreateHarvestPlanResponse>(ctx, 'YieldService',
          'CreateHarvestPlan', request, CreateHarvestPlanResponse());

  /// GetHarvestPlan retrieves a harvest plan by ID.
  $async.Future<GetHarvestPlanResponse> getHarvestPlan(
          $pb.ClientContext? ctx, GetHarvestPlanRequest request) =>
      _client.invoke<GetHarvestPlanResponse>(ctx, 'YieldService',
          'GetHarvestPlan', request, GetHarvestPlanResponse());

  /// ListHarvestPlans lists harvest plans with filtering and pagination.
  $async.Future<ListHarvestPlansResponse> listHarvestPlans(
          $pb.ClientContext? ctx, ListHarvestPlansRequest request) =>
      _client.invoke<ListHarvestPlansResponse>(ctx, 'YieldService',
          'ListHarvestPlans', request, ListHarvestPlansResponse());

  /// GetCropPerformance retrieves crop performance analytics.
  $async.Future<GetCropPerformanceResponse> getCropPerformance(
          $pb.ClientContext? ctx, GetCropPerformanceRequest request) =>
      _client.invoke<GetCropPerformanceResponse>(ctx, 'YieldService',
          'GetCropPerformance', request, GetCropPerformanceResponse());

  /// CompareYields compares yield performance between two seasons or years.
  $async.Future<CompareYieldsResponse> compareYields(
          $pb.ClientContext? ctx, CompareYieldsRequest request) =>
      _client.invoke<CompareYieldsResponse>(ctx, 'YieldService',
          'CompareYields', request, CompareYieldsResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
