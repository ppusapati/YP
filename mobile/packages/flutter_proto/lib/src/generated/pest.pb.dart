// This is a generated file - do not edit.
//
// Generated from pest.proto.

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

import 'pest.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'pest.pbenum.dart';

/// WeatherFactors describes weather conditions relevant to pest prediction.
class WeatherFactors extends $pb.GeneratedMessage {
  factory WeatherFactors({
    $core.double? temperatureCelsius,
    $core.double? humidityPct,
    $core.double? rainfallMm,
    $core.double? windSpeedKmh,
  }) {
    final result = create();
    if (temperatureCelsius != null)
      result.temperatureCelsius = temperatureCelsius;
    if (humidityPct != null) result.humidityPct = humidityPct;
    if (rainfallMm != null) result.rainfallMm = rainfallMm;
    if (windSpeedKmh != null) result.windSpeedKmh = windSpeedKmh;
    return result;
  }

  WeatherFactors._();

  factory WeatherFactors.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WeatherFactors.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WeatherFactors',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'temperatureCelsius')
    ..aD(2, _omitFieldNames ? '' : 'humidityPct')
    ..aD(3, _omitFieldNames ? '' : 'rainfallMm')
    ..aD(4, _omitFieldNames ? '' : 'windSpeedKmh')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WeatherFactors clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WeatherFactors copyWith(void Function(WeatherFactors) updates) =>
      super.copyWith((message) => updates(message as WeatherFactors))
          as WeatherFactors;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WeatherFactors create() => WeatherFactors._();
  @$core.override
  WeatherFactors createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WeatherFactors getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WeatherFactors>(create);
  static WeatherFactors? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get temperatureCelsius => $_getN(0);
  @$pb.TagNumber(1)
  set temperatureCelsius($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTemperatureCelsius() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemperatureCelsius() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get humidityPct => $_getN(1);
  @$pb.TagNumber(2)
  set humidityPct($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHumidityPct() => $_has(1);
  @$pb.TagNumber(2)
  void clearHumidityPct() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get rainfallMm => $_getN(2);
  @$pb.TagNumber(3)
  set rainfallMm($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRainfallMm() => $_has(2);
  @$pb.TagNumber(3)
  void clearRainfallMm() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get windSpeedKmh => $_getN(3);
  @$pb.TagNumber(4)
  set windSpeedKmh($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWindSpeedKmh() => $_has(3);
  @$pb.TagNumber(4)
  void clearWindSpeedKmh() => $_clearField(4);
}

/// RecommendedTreatment is a single recommended treatment action.
class RecommendedTreatment extends $pb.GeneratedMessage {
  factory RecommendedTreatment({
    TreatmentType? treatmentType,
    $core.String? productName,
    $core.String? applicationRate,
    $core.String? applicationMethod,
    $core.String? timing,
    $core.String? safetyInterval,
  }) {
    final result = create();
    if (treatmentType != null) result.treatmentType = treatmentType;
    if (productName != null) result.productName = productName;
    if (applicationRate != null) result.applicationRate = applicationRate;
    if (applicationMethod != null) result.applicationMethod = applicationMethod;
    if (timing != null) result.timing = timing;
    if (safetyInterval != null) result.safetyInterval = safetyInterval;
    return result;
  }

  RecommendedTreatment._();

  factory RecommendedTreatment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecommendedTreatment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecommendedTreatment',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aE<TreatmentType>(1, _omitFieldNames ? '' : 'treatmentType',
        enumValues: TreatmentType.values)
    ..aOS(2, _omitFieldNames ? '' : 'productName')
    ..aOS(3, _omitFieldNames ? '' : 'applicationRate')
    ..aOS(4, _omitFieldNames ? '' : 'applicationMethod')
    ..aOS(5, _omitFieldNames ? '' : 'timing')
    ..aOS(6, _omitFieldNames ? '' : 'safetyInterval')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecommendedTreatment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecommendedTreatment copyWith(void Function(RecommendedTreatment) updates) =>
      super.copyWith((message) => updates(message as RecommendedTreatment))
          as RecommendedTreatment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecommendedTreatment create() => RecommendedTreatment._();
  @$core.override
  RecommendedTreatment createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecommendedTreatment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecommendedTreatment>(create);
  static RecommendedTreatment? _defaultInstance;

  @$pb.TagNumber(1)
  TreatmentType get treatmentType => $_getN(0);
  @$pb.TagNumber(1)
  set treatmentType(TreatmentType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTreatmentType() => $_has(0);
  @$pb.TagNumber(1)
  void clearTreatmentType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get productName => $_getSZ(1);
  @$pb.TagNumber(2)
  set productName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductName() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get applicationRate => $_getSZ(2);
  @$pb.TagNumber(3)
  set applicationRate($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasApplicationRate() => $_has(2);
  @$pb.TagNumber(3)
  void clearApplicationRate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get applicationMethod => $_getSZ(3);
  @$pb.TagNumber(4)
  set applicationMethod($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasApplicationMethod() => $_has(3);
  @$pb.TagNumber(4)
  void clearApplicationMethod() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get timing => $_getSZ(4);
  @$pb.TagNumber(5)
  set timing($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTiming() => $_has(4);
  @$pb.TagNumber(5)
  void clearTiming() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get safetyInterval => $_getSZ(5);
  @$pb.TagNumber(6)
  set safetyInterval($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSafetyInterval() => $_has(5);
  @$pb.TagNumber(6)
  void clearSafetyInterval() => $_clearField(6);
}

/// PestSpecies describes a known pest species in the catalogue.
class PestSpecies extends $pb.GeneratedMessage {
  factory PestSpecies({
    $core.String? id,
    $core.String? tenantId,
    $core.String? commonName,
    $core.String? scientificName,
    $core.String? family,
    $core.String? description,
    $core.Iterable<$core.String>? affectedCrops,
    $core.Iterable<$core.String>? favorableConditions,
    $core.String? imageUrl,
    $fixnum.Int64? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (commonName != null) result.commonName = commonName;
    if (scientificName != null) result.scientificName = scientificName;
    if (family != null) result.family = family;
    if (description != null) result.description = description;
    if (affectedCrops != null) result.affectedCrops.addAll(affectedCrops);
    if (favorableConditions != null)
      result.favorableConditions.addAll(favorableConditions);
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  PestSpecies._();

  factory PestSpecies.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PestSpecies.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PestSpecies',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'commonName')
    ..aOS(4, _omitFieldNames ? '' : 'scientificName')
    ..aOS(5, _omitFieldNames ? '' : 'family')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..pPS(7, _omitFieldNames ? '' : 'affectedCrops')
    ..pPS(8, _omitFieldNames ? '' : 'favorableConditions')
    ..aOS(9, _omitFieldNames ? '' : 'imageUrl')
    ..aInt64(10, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestSpecies clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestSpecies copyWith(void Function(PestSpecies) updates) =>
      super.copyWith((message) => updates(message as PestSpecies))
          as PestSpecies;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PestSpecies create() => PestSpecies._();
  @$core.override
  PestSpecies createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PestSpecies getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PestSpecies>(create);
  static PestSpecies? _defaultInstance;

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
  $core.String get commonName => $_getSZ(2);
  @$pb.TagNumber(3)
  set commonName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCommonName() => $_has(2);
  @$pb.TagNumber(3)
  void clearCommonName() => $_clearField(3);

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
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get affectedCrops => $_getList(6);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get favorableConditions => $_getList(7);

  @$pb.TagNumber(9)
  $core.String get imageUrl => $_getSZ(8);
  @$pb.TagNumber(9)
  set imageUrl($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasImageUrl() => $_has(8);
  @$pb.TagNumber(9)
  void clearImageUrl() => $_clearField(9);

  @$pb.TagNumber(10)
  $fixnum.Int64 get version => $_getI64(9);
  @$pb.TagNumber(10)
  set version($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasVersion() => $_has(9);
  @$pb.TagNumber(10)
  void clearVersion() => $_clearField(10);

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

/// PestPrediction is the main prediction entity.
class PestPrediction extends $pb.GeneratedMessage {
  factory PestPrediction({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? pestSpeciesId,
    $0.Timestamp? predictionDate,
    RiskLevel? riskLevel,
    $core.int? riskScore,
    $core.double? confidencePct,
    WeatherFactors? weatherFactors,
    $core.String? cropType,
    GrowthStage? growthStage,
    $core.double? geographicRiskFactor,
    $core.int? historicalOccurrenceCount,
    $0.Timestamp? predictedOnsetDate,
    $0.Timestamp? predictedPeakDate,
    $0.Timestamp? treatmentWindowStart,
    $0.Timestamp? treatmentWindowEnd,
    $core.Iterable<RecommendedTreatment>? recommendedTreatments,
    $fixnum.Int64? version,
    $core.String? createdBy,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (pestSpeciesId != null) result.pestSpeciesId = pestSpeciesId;
    if (predictionDate != null) result.predictionDate = predictionDate;
    if (riskLevel != null) result.riskLevel = riskLevel;
    if (riskScore != null) result.riskScore = riskScore;
    if (confidencePct != null) result.confidencePct = confidencePct;
    if (weatherFactors != null) result.weatherFactors = weatherFactors;
    if (cropType != null) result.cropType = cropType;
    if (growthStage != null) result.growthStage = growthStage;
    if (geographicRiskFactor != null)
      result.geographicRiskFactor = geographicRiskFactor;
    if (historicalOccurrenceCount != null)
      result.historicalOccurrenceCount = historicalOccurrenceCount;
    if (predictedOnsetDate != null)
      result.predictedOnsetDate = predictedOnsetDate;
    if (predictedPeakDate != null) result.predictedPeakDate = predictedPeakDate;
    if (treatmentWindowStart != null)
      result.treatmentWindowStart = treatmentWindowStart;
    if (treatmentWindowEnd != null)
      result.treatmentWindowEnd = treatmentWindowEnd;
    if (recommendedTreatments != null)
      result.recommendedTreatments.addAll(recommendedTreatments);
    if (version != null) result.version = version;
    if (createdBy != null) result.createdBy = createdBy;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  PestPrediction._();

  factory PestPrediction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PestPrediction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PestPrediction',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'pestSpeciesId')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'predictionDate',
        subBuilder: $0.Timestamp.create)
    ..aE<RiskLevel>(7, _omitFieldNames ? '' : 'riskLevel',
        enumValues: RiskLevel.values)
    ..aI(8, _omitFieldNames ? '' : 'riskScore')
    ..aD(9, _omitFieldNames ? '' : 'confidencePct')
    ..aOM<WeatherFactors>(10, _omitFieldNames ? '' : 'weatherFactors',
        subBuilder: WeatherFactors.create)
    ..aOS(11, _omitFieldNames ? '' : 'cropType')
    ..aE<GrowthStage>(12, _omitFieldNames ? '' : 'growthStage',
        enumValues: GrowthStage.values)
    ..aD(13, _omitFieldNames ? '' : 'geographicRiskFactor')
    ..aI(14, _omitFieldNames ? '' : 'historicalOccurrenceCount')
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'predictedOnsetDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(16, _omitFieldNames ? '' : 'predictedPeakDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'treatmentWindowStart',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(18, _omitFieldNames ? '' : 'treatmentWindowEnd',
        subBuilder: $0.Timestamp.create)
    ..pPM<RecommendedTreatment>(
        19, _omitFieldNames ? '' : 'recommendedTreatments',
        subBuilder: RecommendedTreatment.create)
    ..aInt64(20, _omitFieldNames ? '' : 'version')
    ..aOS(21, _omitFieldNames ? '' : 'createdBy')
    ..aOM<$0.Timestamp>(22, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(23, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestPrediction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestPrediction copyWith(void Function(PestPrediction) updates) =>
      super.copyWith((message) => updates(message as PestPrediction))
          as PestPrediction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PestPrediction create() => PestPrediction._();
  @$core.override
  PestPrediction createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PestPrediction getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PestPrediction>(create);
  static PestPrediction? _defaultInstance;

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
  $core.String get pestSpeciesId => $_getSZ(4);
  @$pb.TagNumber(5)
  set pestSpeciesId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPestSpeciesId() => $_has(4);
  @$pb.TagNumber(5)
  void clearPestSpeciesId() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get predictionDate => $_getN(5);
  @$pb.TagNumber(6)
  set predictionDate($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasPredictionDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearPredictionDate() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensurePredictionDate() => $_ensure(5);

  @$pb.TagNumber(7)
  RiskLevel get riskLevel => $_getN(6);
  @$pb.TagNumber(7)
  set riskLevel(RiskLevel value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasRiskLevel() => $_has(6);
  @$pb.TagNumber(7)
  void clearRiskLevel() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get riskScore => $_getIZ(7);
  @$pb.TagNumber(8)
  set riskScore($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRiskScore() => $_has(7);
  @$pb.TagNumber(8)
  void clearRiskScore() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get confidencePct => $_getN(8);
  @$pb.TagNumber(9)
  set confidencePct($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasConfidencePct() => $_has(8);
  @$pb.TagNumber(9)
  void clearConfidencePct() => $_clearField(9);

  @$pb.TagNumber(10)
  WeatherFactors get weatherFactors => $_getN(9);
  @$pb.TagNumber(10)
  set weatherFactors(WeatherFactors value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasWeatherFactors() => $_has(9);
  @$pb.TagNumber(10)
  void clearWeatherFactors() => $_clearField(10);
  @$pb.TagNumber(10)
  WeatherFactors ensureWeatherFactors() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.String get cropType => $_getSZ(10);
  @$pb.TagNumber(11)
  set cropType($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCropType() => $_has(10);
  @$pb.TagNumber(11)
  void clearCropType() => $_clearField(11);

  @$pb.TagNumber(12)
  GrowthStage get growthStage => $_getN(11);
  @$pb.TagNumber(12)
  set growthStage(GrowthStage value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasGrowthStage() => $_has(11);
  @$pb.TagNumber(12)
  void clearGrowthStage() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get geographicRiskFactor => $_getN(12);
  @$pb.TagNumber(13)
  set geographicRiskFactor($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasGeographicRiskFactor() => $_has(12);
  @$pb.TagNumber(13)
  void clearGeographicRiskFactor() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get historicalOccurrenceCount => $_getIZ(13);
  @$pb.TagNumber(14)
  set historicalOccurrenceCount($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasHistoricalOccurrenceCount() => $_has(13);
  @$pb.TagNumber(14)
  void clearHistoricalOccurrenceCount() => $_clearField(14);

  @$pb.TagNumber(15)
  $0.Timestamp get predictedOnsetDate => $_getN(14);
  @$pb.TagNumber(15)
  set predictedOnsetDate($0.Timestamp value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasPredictedOnsetDate() => $_has(14);
  @$pb.TagNumber(15)
  void clearPredictedOnsetDate() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Timestamp ensurePredictedOnsetDate() => $_ensure(14);

  @$pb.TagNumber(16)
  $0.Timestamp get predictedPeakDate => $_getN(15);
  @$pb.TagNumber(16)
  set predictedPeakDate($0.Timestamp value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasPredictedPeakDate() => $_has(15);
  @$pb.TagNumber(16)
  void clearPredictedPeakDate() => $_clearField(16);
  @$pb.TagNumber(16)
  $0.Timestamp ensurePredictedPeakDate() => $_ensure(15);

  @$pb.TagNumber(17)
  $0.Timestamp get treatmentWindowStart => $_getN(16);
  @$pb.TagNumber(17)
  set treatmentWindowStart($0.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasTreatmentWindowStart() => $_has(16);
  @$pb.TagNumber(17)
  void clearTreatmentWindowStart() => $_clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensureTreatmentWindowStart() => $_ensure(16);

  @$pb.TagNumber(18)
  $0.Timestamp get treatmentWindowEnd => $_getN(17);
  @$pb.TagNumber(18)
  set treatmentWindowEnd($0.Timestamp value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasTreatmentWindowEnd() => $_has(17);
  @$pb.TagNumber(18)
  void clearTreatmentWindowEnd() => $_clearField(18);
  @$pb.TagNumber(18)
  $0.Timestamp ensureTreatmentWindowEnd() => $_ensure(17);

  @$pb.TagNumber(19)
  $pb.PbList<RecommendedTreatment> get recommendedTreatments => $_getList(18);

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
  $0.Timestamp get createdAt => $_getN(21);
  @$pb.TagNumber(22)
  set createdAt($0.Timestamp value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasCreatedAt() => $_has(21);
  @$pb.TagNumber(22)
  void clearCreatedAt() => $_clearField(22);
  @$pb.TagNumber(22)
  $0.Timestamp ensureCreatedAt() => $_ensure(21);

  @$pb.TagNumber(23)
  $0.Timestamp get updatedAt => $_getN(22);
  @$pb.TagNumber(23)
  set updatedAt($0.Timestamp value) => $_setField(23, value);
  @$pb.TagNumber(23)
  $core.bool hasUpdatedAt() => $_has(22);
  @$pb.TagNumber(23)
  void clearUpdatedAt() => $_clearField(23);
  @$pb.TagNumber(23)
  $0.Timestamp ensureUpdatedAt() => $_ensure(22);
}

/// PestAlert represents an early warning alert for pest risk.
class PestAlert extends $pb.GeneratedMessage {
  factory PestAlert({
    $core.String? id,
    $core.String? tenantId,
    $core.String? predictionId,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? pestSpeciesId,
    RiskLevel? riskLevel,
    AlertStatus? status,
    $core.String? title,
    $core.String? message,
    $0.Timestamp? acknowledgedAt,
    $core.String? acknowledgedBy,
    $fixnum.Int64? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (predictionId != null) result.predictionId = predictionId;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (pestSpeciesId != null) result.pestSpeciesId = pestSpeciesId;
    if (riskLevel != null) result.riskLevel = riskLevel;
    if (status != null) result.status = status;
    if (title != null) result.title = title;
    if (message != null) result.message = message;
    if (acknowledgedAt != null) result.acknowledgedAt = acknowledgedAt;
    if (acknowledgedBy != null) result.acknowledgedBy = acknowledgedBy;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  PestAlert._();

  factory PestAlert.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PestAlert.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PestAlert',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'predictionId')
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..aOS(5, _omitFieldNames ? '' : 'fieldId')
    ..aOS(6, _omitFieldNames ? '' : 'pestSpeciesId')
    ..aE<RiskLevel>(7, _omitFieldNames ? '' : 'riskLevel',
        enumValues: RiskLevel.values)
    ..aE<AlertStatus>(8, _omitFieldNames ? '' : 'status',
        enumValues: AlertStatus.values)
    ..aOS(9, _omitFieldNames ? '' : 'title')
    ..aOS(10, _omitFieldNames ? '' : 'message')
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'acknowledgedAt',
        subBuilder: $0.Timestamp.create)
    ..aOS(12, _omitFieldNames ? '' : 'acknowledgedBy')
    ..aInt64(13, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestAlert clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestAlert copyWith(void Function(PestAlert) updates) =>
      super.copyWith((message) => updates(message as PestAlert)) as PestAlert;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PestAlert create() => PestAlert._();
  @$core.override
  PestAlert createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PestAlert getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PestAlert>(create);
  static PestAlert? _defaultInstance;

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
  $core.String get predictionId => $_getSZ(2);
  @$pb.TagNumber(3)
  set predictionId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPredictionId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPredictionId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get farmId => $_getSZ(3);
  @$pb.TagNumber(4)
  set farmId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFarmId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFarmId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get fieldId => $_getSZ(4);
  @$pb.TagNumber(5)
  set fieldId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFieldId() => $_has(4);
  @$pb.TagNumber(5)
  void clearFieldId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get pestSpeciesId => $_getSZ(5);
  @$pb.TagNumber(6)
  set pestSpeciesId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPestSpeciesId() => $_has(5);
  @$pb.TagNumber(6)
  void clearPestSpeciesId() => $_clearField(6);

  @$pb.TagNumber(7)
  RiskLevel get riskLevel => $_getN(6);
  @$pb.TagNumber(7)
  set riskLevel(RiskLevel value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasRiskLevel() => $_has(6);
  @$pb.TagNumber(7)
  void clearRiskLevel() => $_clearField(7);

  @$pb.TagNumber(8)
  AlertStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(AlertStatus value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get title => $_getSZ(8);
  @$pb.TagNumber(9)
  set title($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTitle() => $_has(8);
  @$pb.TagNumber(9)
  void clearTitle() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get message => $_getSZ(9);
  @$pb.TagNumber(10)
  set message($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMessage() => $_has(9);
  @$pb.TagNumber(10)
  void clearMessage() => $_clearField(10);

  @$pb.TagNumber(11)
  $0.Timestamp get acknowledgedAt => $_getN(10);
  @$pb.TagNumber(11)
  set acknowledgedAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasAcknowledgedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearAcknowledgedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureAcknowledgedAt() => $_ensure(10);

  @$pb.TagNumber(12)
  $core.String get acknowledgedBy => $_getSZ(11);
  @$pb.TagNumber(12)
  set acknowledgedBy($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasAcknowledgedBy() => $_has(11);
  @$pb.TagNumber(12)
  void clearAcknowledgedBy() => $_clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get version => $_getI64(12);
  @$pb.TagNumber(13)
  set version($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasVersion() => $_has(12);
  @$pb.TagNumber(13)
  void clearVersion() => $_clearField(13);

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

/// PestObservation records a field observation of pest activity.
class PestObservation extends $pb.GeneratedMessage {
  factory PestObservation({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? pestSpeciesId,
    $core.int? pestCount,
    DamageLevel? damageLevel,
    $core.String? trapType,
    $core.String? imageUrl,
    $core.double? latitude,
    $core.double? longitude,
    $core.String? notes,
    $core.String? observedBy,
    $0.Timestamp? observedAt,
    $fixnum.Int64? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (pestSpeciesId != null) result.pestSpeciesId = pestSpeciesId;
    if (pestCount != null) result.pestCount = pestCount;
    if (damageLevel != null) result.damageLevel = damageLevel;
    if (trapType != null) result.trapType = trapType;
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (notes != null) result.notes = notes;
    if (observedBy != null) result.observedBy = observedBy;
    if (observedAt != null) result.observedAt = observedAt;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  PestObservation._();

  factory PestObservation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PestObservation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PestObservation',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'pestSpeciesId')
    ..aI(6, _omitFieldNames ? '' : 'pestCount')
    ..aE<DamageLevel>(7, _omitFieldNames ? '' : 'damageLevel',
        enumValues: DamageLevel.values)
    ..aOS(8, _omitFieldNames ? '' : 'trapType')
    ..aOS(9, _omitFieldNames ? '' : 'imageUrl')
    ..aD(10, _omitFieldNames ? '' : 'latitude')
    ..aD(11, _omitFieldNames ? '' : 'longitude')
    ..aOS(12, _omitFieldNames ? '' : 'notes')
    ..aOS(13, _omitFieldNames ? '' : 'observedBy')
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'observedAt',
        subBuilder: $0.Timestamp.create)
    ..aInt64(15, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(16, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestObservation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestObservation copyWith(void Function(PestObservation) updates) =>
      super.copyWith((message) => updates(message as PestObservation))
          as PestObservation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PestObservation create() => PestObservation._();
  @$core.override
  PestObservation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PestObservation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PestObservation>(create);
  static PestObservation? _defaultInstance;

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
  $core.String get pestSpeciesId => $_getSZ(4);
  @$pb.TagNumber(5)
  set pestSpeciesId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPestSpeciesId() => $_has(4);
  @$pb.TagNumber(5)
  void clearPestSpeciesId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get pestCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set pestCount($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPestCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearPestCount() => $_clearField(6);

  @$pb.TagNumber(7)
  DamageLevel get damageLevel => $_getN(6);
  @$pb.TagNumber(7)
  set damageLevel(DamageLevel value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasDamageLevel() => $_has(6);
  @$pb.TagNumber(7)
  void clearDamageLevel() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get trapType => $_getSZ(7);
  @$pb.TagNumber(8)
  set trapType($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTrapType() => $_has(7);
  @$pb.TagNumber(8)
  void clearTrapType() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get imageUrl => $_getSZ(8);
  @$pb.TagNumber(9)
  set imageUrl($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasImageUrl() => $_has(8);
  @$pb.TagNumber(9)
  void clearImageUrl() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get latitude => $_getN(9);
  @$pb.TagNumber(10)
  set latitude($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasLatitude() => $_has(9);
  @$pb.TagNumber(10)
  void clearLatitude() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get longitude => $_getN(10);
  @$pb.TagNumber(11)
  set longitude($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasLongitude() => $_has(10);
  @$pb.TagNumber(11)
  void clearLongitude() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get notes => $_getSZ(11);
  @$pb.TagNumber(12)
  set notes($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasNotes() => $_has(11);
  @$pb.TagNumber(12)
  void clearNotes() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get observedBy => $_getSZ(12);
  @$pb.TagNumber(13)
  set observedBy($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasObservedBy() => $_has(12);
  @$pb.TagNumber(13)
  void clearObservedBy() => $_clearField(13);

  @$pb.TagNumber(14)
  $0.Timestamp get observedAt => $_getN(13);
  @$pb.TagNumber(14)
  set observedAt($0.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasObservedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearObservedAt() => $_clearField(14);
  @$pb.TagNumber(14)
  $0.Timestamp ensureObservedAt() => $_ensure(13);

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

/// PestTreatment records an applied treatment.
class PestTreatment extends $pb.GeneratedMessage {
  factory PestTreatment({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? pestSpeciesId,
    $core.String? predictionId,
    TreatmentType? treatmentType,
    $core.String? productName,
    $core.String? applicationRate,
    $core.String? applicationMethod,
    $core.double? cost,
    $core.String? effectivenessRating,
    $core.String? appliedBy,
    $0.Timestamp? appliedAt,
    $core.String? notes,
    $fixnum.Int64? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (pestSpeciesId != null) result.pestSpeciesId = pestSpeciesId;
    if (predictionId != null) result.predictionId = predictionId;
    if (treatmentType != null) result.treatmentType = treatmentType;
    if (productName != null) result.productName = productName;
    if (applicationRate != null) result.applicationRate = applicationRate;
    if (applicationMethod != null) result.applicationMethod = applicationMethod;
    if (cost != null) result.cost = cost;
    if (effectivenessRating != null)
      result.effectivenessRating = effectivenessRating;
    if (appliedBy != null) result.appliedBy = appliedBy;
    if (appliedAt != null) result.appliedAt = appliedAt;
    if (notes != null) result.notes = notes;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  PestTreatment._();

  factory PestTreatment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PestTreatment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PestTreatment',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'pestSpeciesId')
    ..aOS(6, _omitFieldNames ? '' : 'predictionId')
    ..aE<TreatmentType>(7, _omitFieldNames ? '' : 'treatmentType',
        enumValues: TreatmentType.values)
    ..aOS(8, _omitFieldNames ? '' : 'productName')
    ..aOS(9, _omitFieldNames ? '' : 'applicationRate')
    ..aOS(10, _omitFieldNames ? '' : 'applicationMethod')
    ..aD(11, _omitFieldNames ? '' : 'cost')
    ..aOS(12, _omitFieldNames ? '' : 'effectivenessRating')
    ..aOS(13, _omitFieldNames ? '' : 'appliedBy')
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'appliedAt',
        subBuilder: $0.Timestamp.create)
    ..aOS(15, _omitFieldNames ? '' : 'notes')
    ..aInt64(16, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(18, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestTreatment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestTreatment copyWith(void Function(PestTreatment) updates) =>
      super.copyWith((message) => updates(message as PestTreatment))
          as PestTreatment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PestTreatment create() => PestTreatment._();
  @$core.override
  PestTreatment createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PestTreatment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PestTreatment>(create);
  static PestTreatment? _defaultInstance;

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
  $core.String get pestSpeciesId => $_getSZ(4);
  @$pb.TagNumber(5)
  set pestSpeciesId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPestSpeciesId() => $_has(4);
  @$pb.TagNumber(5)
  void clearPestSpeciesId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get predictionId => $_getSZ(5);
  @$pb.TagNumber(6)
  set predictionId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPredictionId() => $_has(5);
  @$pb.TagNumber(6)
  void clearPredictionId() => $_clearField(6);

  @$pb.TagNumber(7)
  TreatmentType get treatmentType => $_getN(6);
  @$pb.TagNumber(7)
  set treatmentType(TreatmentType value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasTreatmentType() => $_has(6);
  @$pb.TagNumber(7)
  void clearTreatmentType() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get productName => $_getSZ(7);
  @$pb.TagNumber(8)
  set productName($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasProductName() => $_has(7);
  @$pb.TagNumber(8)
  void clearProductName() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get applicationRate => $_getSZ(8);
  @$pb.TagNumber(9)
  set applicationRate($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasApplicationRate() => $_has(8);
  @$pb.TagNumber(9)
  void clearApplicationRate() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get applicationMethod => $_getSZ(9);
  @$pb.TagNumber(10)
  set applicationMethod($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasApplicationMethod() => $_has(9);
  @$pb.TagNumber(10)
  void clearApplicationMethod() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get cost => $_getN(10);
  @$pb.TagNumber(11)
  set cost($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCost() => $_has(10);
  @$pb.TagNumber(11)
  void clearCost() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get effectivenessRating => $_getSZ(11);
  @$pb.TagNumber(12)
  set effectivenessRating($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasEffectivenessRating() => $_has(11);
  @$pb.TagNumber(12)
  void clearEffectivenessRating() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get appliedBy => $_getSZ(12);
  @$pb.TagNumber(13)
  set appliedBy($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasAppliedBy() => $_has(12);
  @$pb.TagNumber(13)
  void clearAppliedBy() => $_clearField(13);

  @$pb.TagNumber(14)
  $0.Timestamp get appliedAt => $_getN(13);
  @$pb.TagNumber(14)
  set appliedAt($0.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasAppliedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearAppliedAt() => $_clearField(14);
  @$pb.TagNumber(14)
  $0.Timestamp ensureAppliedAt() => $_ensure(13);

  @$pb.TagNumber(15)
  $core.String get notes => $_getSZ(14);
  @$pb.TagNumber(15)
  set notes($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasNotes() => $_has(14);
  @$pb.TagNumber(15)
  void clearNotes() => $_clearField(15);

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

/// PestRiskMap represents a geographic risk map for a region.
class PestRiskMap extends $pb.GeneratedMessage {
  factory PestRiskMap({
    $core.String? id,
    $core.String? tenantId,
    $core.String? pestSpeciesId,
    $core.String? region,
    RiskLevel? overallRiskLevel,
    $core.String? geojson,
    $0.Timestamp? validFrom,
    $0.Timestamp? validUntil,
    $fixnum.Int64? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (pestSpeciesId != null) result.pestSpeciesId = pestSpeciesId;
    if (region != null) result.region = region;
    if (overallRiskLevel != null) result.overallRiskLevel = overallRiskLevel;
    if (geojson != null) result.geojson = geojson;
    if (validFrom != null) result.validFrom = validFrom;
    if (validUntil != null) result.validUntil = validUntil;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  PestRiskMap._();

  factory PestRiskMap.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PestRiskMap.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PestRiskMap',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'pestSpeciesId')
    ..aOS(4, _omitFieldNames ? '' : 'region')
    ..aE<RiskLevel>(5, _omitFieldNames ? '' : 'overallRiskLevel',
        enumValues: RiskLevel.values)
    ..aOS(6, _omitFieldNames ? '' : 'geojson')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'validFrom',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'validUntil',
        subBuilder: $0.Timestamp.create)
    ..aInt64(9, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestRiskMap clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestRiskMap copyWith(void Function(PestRiskMap) updates) =>
      super.copyWith((message) => updates(message as PestRiskMap))
          as PestRiskMap;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PestRiskMap create() => PestRiskMap._();
  @$core.override
  PestRiskMap createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PestRiskMap getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PestRiskMap>(create);
  static PestRiskMap? _defaultInstance;

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
  $core.String get pestSpeciesId => $_getSZ(2);
  @$pb.TagNumber(3)
  set pestSpeciesId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPestSpeciesId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPestSpeciesId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get region => $_getSZ(3);
  @$pb.TagNumber(4)
  set region($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRegion() => $_has(3);
  @$pb.TagNumber(4)
  void clearRegion() => $_clearField(4);

  @$pb.TagNumber(5)
  RiskLevel get overallRiskLevel => $_getN(4);
  @$pb.TagNumber(5)
  set overallRiskLevel(RiskLevel value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasOverallRiskLevel() => $_has(4);
  @$pb.TagNumber(5)
  void clearOverallRiskLevel() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get geojson => $_getSZ(5);
  @$pb.TagNumber(6)
  set geojson($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGeojson() => $_has(5);
  @$pb.TagNumber(6)
  void clearGeojson() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get validFrom => $_getN(6);
  @$pb.TagNumber(7)
  set validFrom($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasValidFrom() => $_has(6);
  @$pb.TagNumber(7)
  void clearValidFrom() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureValidFrom() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get validUntil => $_getN(7);
  @$pb.TagNumber(8)
  set validUntil($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasValidUntil() => $_has(7);
  @$pb.TagNumber(8)
  void clearValidUntil() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureValidUntil() => $_ensure(7);

  @$pb.TagNumber(9)
  $fixnum.Int64 get version => $_getI64(8);
  @$pb.TagNumber(9)
  set version($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasVersion() => $_has(8);
  @$pb.TagNumber(9)
  void clearVersion() => $_clearField(9);

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

class PredictPestRiskRequest extends $pb.GeneratedMessage {
  factory PredictPestRiskRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? pestSpeciesId,
    $core.String? cropType,
    GrowthStage? growthStage,
    WeatherFactors? weather,
    $core.double? latitude,
    $core.double? longitude,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (pestSpeciesId != null) result.pestSpeciesId = pestSpeciesId;
    if (cropType != null) result.cropType = cropType;
    if (growthStage != null) result.growthStage = growthStage;
    if (weather != null) result.weather = weather;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    return result;
  }

  PredictPestRiskRequest._();

  factory PredictPestRiskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PredictPestRiskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PredictPestRiskRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'pestSpeciesId')
    ..aOS(4, _omitFieldNames ? '' : 'cropType')
    ..aE<GrowthStage>(5, _omitFieldNames ? '' : 'growthStage',
        enumValues: GrowthStage.values)
    ..aOM<WeatherFactors>(6, _omitFieldNames ? '' : 'weather',
        subBuilder: WeatherFactors.create)
    ..aD(7, _omitFieldNames ? '' : 'latitude')
    ..aD(8, _omitFieldNames ? '' : 'longitude')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PredictPestRiskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PredictPestRiskRequest copyWith(
          void Function(PredictPestRiskRequest) updates) =>
      super.copyWith((message) => updates(message as PredictPestRiskRequest))
          as PredictPestRiskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PredictPestRiskRequest create() => PredictPestRiskRequest._();
  @$core.override
  PredictPestRiskRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PredictPestRiskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PredictPestRiskRequest>(create);
  static PredictPestRiskRequest? _defaultInstance;

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
  $core.String get pestSpeciesId => $_getSZ(2);
  @$pb.TagNumber(3)
  set pestSpeciesId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPestSpeciesId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPestSpeciesId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get cropType => $_getSZ(3);
  @$pb.TagNumber(4)
  set cropType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCropType() => $_has(3);
  @$pb.TagNumber(4)
  void clearCropType() => $_clearField(4);

  @$pb.TagNumber(5)
  GrowthStage get growthStage => $_getN(4);
  @$pb.TagNumber(5)
  set growthStage(GrowthStage value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasGrowthStage() => $_has(4);
  @$pb.TagNumber(5)
  void clearGrowthStage() => $_clearField(5);

  @$pb.TagNumber(6)
  WeatherFactors get weather => $_getN(5);
  @$pb.TagNumber(6)
  set weather(WeatherFactors value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasWeather() => $_has(5);
  @$pb.TagNumber(6)
  void clearWeather() => $_clearField(6);
  @$pb.TagNumber(6)
  WeatherFactors ensureWeather() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.double get latitude => $_getN(6);
  @$pb.TagNumber(7)
  set latitude($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLatitude() => $_has(6);
  @$pb.TagNumber(7)
  void clearLatitude() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get longitude => $_getN(7);
  @$pb.TagNumber(8)
  set longitude($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLongitude() => $_has(7);
  @$pb.TagNumber(8)
  void clearLongitude() => $_clearField(8);
}

class PredictPestRiskResponse extends $pb.GeneratedMessage {
  factory PredictPestRiskResponse({
    PestPrediction? prediction,
  }) {
    final result = create();
    if (prediction != null) result.prediction = prediction;
    return result;
  }

  PredictPestRiskResponse._();

  factory PredictPestRiskResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PredictPestRiskResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PredictPestRiskResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOM<PestPrediction>(1, _omitFieldNames ? '' : 'prediction',
        subBuilder: PestPrediction.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PredictPestRiskResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PredictPestRiskResponse copyWith(
          void Function(PredictPestRiskResponse) updates) =>
      super.copyWith((message) => updates(message as PredictPestRiskResponse))
          as PredictPestRiskResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PredictPestRiskResponse create() => PredictPestRiskResponse._();
  @$core.override
  PredictPestRiskResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PredictPestRiskResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PredictPestRiskResponse>(create);
  static PredictPestRiskResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PestPrediction get prediction => $_getN(0);
  @$pb.TagNumber(1)
  set prediction(PestPrediction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPrediction() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrediction() => $_clearField(1);
  @$pb.TagNumber(1)
  PestPrediction ensurePrediction() => $_ensure(0);
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
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
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
    PestPrediction? prediction,
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
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOM<PestPrediction>(1, _omitFieldNames ? '' : 'prediction',
        subBuilder: PestPrediction.create)
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
  PestPrediction get prediction => $_getN(0);
  @$pb.TagNumber(1)
  set prediction(PestPrediction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPrediction() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrediction() => $_clearField(1);
  @$pb.TagNumber(1)
  PestPrediction ensurePrediction() => $_ensure(0);
}

class ListPredictionsRequest extends $pb.GeneratedMessage {
  factory ListPredictionsRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? pestSpeciesId,
    RiskLevel? minRiskLevel,
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? orderBy,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (pestSpeciesId != null) result.pestSpeciesId = pestSpeciesId;
    if (minRiskLevel != null) result.minRiskLevel = minRiskLevel;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
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
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'pestSpeciesId')
    ..aE<RiskLevel>(4, _omitFieldNames ? '' : 'minRiskLevel',
        enumValues: RiskLevel.values)
    ..aI(5, _omitFieldNames ? '' : 'pageSize')
    ..aOS(6, _omitFieldNames ? '' : 'pageToken')
    ..aOS(7, _omitFieldNames ? '' : 'orderBy')
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
  $core.String get pestSpeciesId => $_getSZ(2);
  @$pb.TagNumber(3)
  set pestSpeciesId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPestSpeciesId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPestSpeciesId() => $_clearField(3);

  @$pb.TagNumber(4)
  RiskLevel get minRiskLevel => $_getN(3);
  @$pb.TagNumber(4)
  set minRiskLevel(RiskLevel value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMinRiskLevel() => $_has(3);
  @$pb.TagNumber(4)
  void clearMinRiskLevel() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pageSize => $_getIZ(4);
  @$pb.TagNumber(5)
  set pageSize($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageSize() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get pageToken => $_getSZ(5);
  @$pb.TagNumber(6)
  set pageToken($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageToken() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageToken() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get orderBy => $_getSZ(6);
  @$pb.TagNumber(7)
  set orderBy($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOrderBy() => $_has(6);
  @$pb.TagNumber(7)
  void clearOrderBy() => $_clearField(7);
}

class ListPredictionsResponse extends $pb.GeneratedMessage {
  factory ListPredictionsResponse({
    $core.Iterable<PestPrediction>? predictions,
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
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..pPM<PestPrediction>(1, _omitFieldNames ? '' : 'predictions',
        subBuilder: PestPrediction.create)
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
  $pb.PbList<PestPrediction> get predictions => $_getList(0);

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

class ReportObservationRequest extends $pb.GeneratedMessage {
  factory ReportObservationRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? pestSpeciesId,
    $core.int? pestCount,
    DamageLevel? damageLevel,
    $core.String? trapType,
    $core.String? imageUrl,
    $core.double? latitude,
    $core.double? longitude,
    $core.String? notes,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (pestSpeciesId != null) result.pestSpeciesId = pestSpeciesId;
    if (pestCount != null) result.pestCount = pestCount;
    if (damageLevel != null) result.damageLevel = damageLevel;
    if (trapType != null) result.trapType = trapType;
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (notes != null) result.notes = notes;
    return result;
  }

  ReportObservationRequest._();

  factory ReportObservationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReportObservationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReportObservationRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'pestSpeciesId')
    ..aI(4, _omitFieldNames ? '' : 'pestCount')
    ..aE<DamageLevel>(5, _omitFieldNames ? '' : 'damageLevel',
        enumValues: DamageLevel.values)
    ..aOS(6, _omitFieldNames ? '' : 'trapType')
    ..aOS(7, _omitFieldNames ? '' : 'imageUrl')
    ..aD(8, _omitFieldNames ? '' : 'latitude')
    ..aD(9, _omitFieldNames ? '' : 'longitude')
    ..aOS(10, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReportObservationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReportObservationRequest copyWith(
          void Function(ReportObservationRequest) updates) =>
      super.copyWith((message) => updates(message as ReportObservationRequest))
          as ReportObservationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReportObservationRequest create() => ReportObservationRequest._();
  @$core.override
  ReportObservationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReportObservationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReportObservationRequest>(create);
  static ReportObservationRequest? _defaultInstance;

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
  $core.String get pestSpeciesId => $_getSZ(2);
  @$pb.TagNumber(3)
  set pestSpeciesId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPestSpeciesId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPestSpeciesId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pestCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set pestCount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPestCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearPestCount() => $_clearField(4);

  @$pb.TagNumber(5)
  DamageLevel get damageLevel => $_getN(4);
  @$pb.TagNumber(5)
  set damageLevel(DamageLevel value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDamageLevel() => $_has(4);
  @$pb.TagNumber(5)
  void clearDamageLevel() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get trapType => $_getSZ(5);
  @$pb.TagNumber(6)
  set trapType($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTrapType() => $_has(5);
  @$pb.TagNumber(6)
  void clearTrapType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get imageUrl => $_getSZ(6);
  @$pb.TagNumber(7)
  set imageUrl($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasImageUrl() => $_has(6);
  @$pb.TagNumber(7)
  void clearImageUrl() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get latitude => $_getN(7);
  @$pb.TagNumber(8)
  set latitude($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLatitude() => $_has(7);
  @$pb.TagNumber(8)
  void clearLatitude() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get longitude => $_getN(8);
  @$pb.TagNumber(9)
  set longitude($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLongitude() => $_has(8);
  @$pb.TagNumber(9)
  void clearLongitude() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get notes => $_getSZ(9);
  @$pb.TagNumber(10)
  set notes($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNotes() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotes() => $_clearField(10);
}

class ReportObservationResponse extends $pb.GeneratedMessage {
  factory ReportObservationResponse({
    PestObservation? observation,
  }) {
    final result = create();
    if (observation != null) result.observation = observation;
    return result;
  }

  ReportObservationResponse._();

  factory ReportObservationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReportObservationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReportObservationResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOM<PestObservation>(1, _omitFieldNames ? '' : 'observation',
        subBuilder: PestObservation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReportObservationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReportObservationResponse copyWith(
          void Function(ReportObservationResponse) updates) =>
      super.copyWith((message) => updates(message as ReportObservationResponse))
          as ReportObservationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReportObservationResponse create() => ReportObservationResponse._();
  @$core.override
  ReportObservationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReportObservationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReportObservationResponse>(create);
  static ReportObservationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PestObservation get observation => $_getN(0);
  @$pb.TagNumber(1)
  set observation(PestObservation value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasObservation() => $_has(0);
  @$pb.TagNumber(1)
  void clearObservation() => $_clearField(1);
  @$pb.TagNumber(1)
  PestObservation ensureObservation() => $_ensure(0);
}

class ListObservationsRequest extends $pb.GeneratedMessage {
  factory ListObservationsRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? pestSpeciesId,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (pestSpeciesId != null) result.pestSpeciesId = pestSpeciesId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListObservationsRequest._();

  factory ListObservationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListObservationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListObservationsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'pestSpeciesId')
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aOS(5, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListObservationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListObservationsRequest copyWith(
          void Function(ListObservationsRequest) updates) =>
      super.copyWith((message) => updates(message as ListObservationsRequest))
          as ListObservationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListObservationsRequest create() => ListObservationsRequest._();
  @$core.override
  ListObservationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListObservationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListObservationsRequest>(create);
  static ListObservationsRequest? _defaultInstance;

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
  $core.String get pestSpeciesId => $_getSZ(2);
  @$pb.TagNumber(3)
  set pestSpeciesId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPestSpeciesId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPestSpeciesId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pageSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageSize($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get pageToken => $_getSZ(4);
  @$pb.TagNumber(5)
  set pageToken($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageToken() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageToken() => $_clearField(5);
}

class ListObservationsResponse extends $pb.GeneratedMessage {
  factory ListObservationsResponse({
    $core.Iterable<PestObservation>? observations,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (observations != null) result.observations.addAll(observations);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListObservationsResponse._();

  factory ListObservationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListObservationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListObservationsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..pPM<PestObservation>(1, _omitFieldNames ? '' : 'observations',
        subBuilder: PestObservation.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListObservationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListObservationsResponse copyWith(
          void Function(ListObservationsResponse) updates) =>
      super.copyWith((message) => updates(message as ListObservationsResponse))
          as ListObservationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListObservationsResponse create() => ListObservationsResponse._();
  @$core.override
  ListObservationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListObservationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListObservationsResponse>(create);
  static ListObservationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PestObservation> get observations => $_getList(0);

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

class GetPestSpeciesRequest extends $pb.GeneratedMessage {
  factory GetPestSpeciesRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetPestSpeciesRequest._();

  factory GetPestSpeciesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPestSpeciesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPestSpeciesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPestSpeciesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPestSpeciesRequest copyWith(
          void Function(GetPestSpeciesRequest) updates) =>
      super.copyWith((message) => updates(message as GetPestSpeciesRequest))
          as GetPestSpeciesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPestSpeciesRequest create() => GetPestSpeciesRequest._();
  @$core.override
  GetPestSpeciesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPestSpeciesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPestSpeciesRequest>(create);
  static GetPestSpeciesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetPestSpeciesResponse extends $pb.GeneratedMessage {
  factory GetPestSpeciesResponse({
    PestSpecies? species,
  }) {
    final result = create();
    if (species != null) result.species = species;
    return result;
  }

  GetPestSpeciesResponse._();

  factory GetPestSpeciesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPestSpeciesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPestSpeciesResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOM<PestSpecies>(1, _omitFieldNames ? '' : 'species',
        subBuilder: PestSpecies.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPestSpeciesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPestSpeciesResponse copyWith(
          void Function(GetPestSpeciesResponse) updates) =>
      super.copyWith((message) => updates(message as GetPestSpeciesResponse))
          as GetPestSpeciesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPestSpeciesResponse create() => GetPestSpeciesResponse._();
  @$core.override
  GetPestSpeciesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPestSpeciesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPestSpeciesResponse>(create);
  static GetPestSpeciesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PestSpecies get species => $_getN(0);
  @$pb.TagNumber(1)
  set species(PestSpecies value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSpecies() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpecies() => $_clearField(1);
  @$pb.TagNumber(1)
  PestSpecies ensureSpecies() => $_ensure(0);
}

class ListPestSpeciesRequest extends $pb.GeneratedMessage {
  factory ListPestSpeciesRequest({
    $core.String? search,
    $core.String? cropType,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (search != null) result.search = search;
    if (cropType != null) result.cropType = cropType;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListPestSpeciesRequest._();

  factory ListPestSpeciesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPestSpeciesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPestSpeciesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'search')
    ..aOS(2, _omitFieldNames ? '' : 'cropType')
    ..aI(3, _omitFieldNames ? '' : 'pageSize')
    ..aOS(4, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPestSpeciesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPestSpeciesRequest copyWith(
          void Function(ListPestSpeciesRequest) updates) =>
      super.copyWith((message) => updates(message as ListPestSpeciesRequest))
          as ListPestSpeciesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPestSpeciesRequest create() => ListPestSpeciesRequest._();
  @$core.override
  ListPestSpeciesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPestSpeciesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPestSpeciesRequest>(create);
  static ListPestSpeciesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get search => $_getSZ(0);
  @$pb.TagNumber(1)
  set search($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSearch() => $_has(0);
  @$pb.TagNumber(1)
  void clearSearch() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cropType => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropType() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get pageToken => $_getSZ(3);
  @$pb.TagNumber(4)
  set pageToken($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageToken() => $_clearField(4);
}

class ListPestSpeciesResponse extends $pb.GeneratedMessage {
  factory ListPestSpeciesResponse({
    $core.Iterable<PestSpecies>? species,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (species != null) result.species.addAll(species);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListPestSpeciesResponse._();

  factory ListPestSpeciesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPestSpeciesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPestSpeciesResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..pPM<PestSpecies>(1, _omitFieldNames ? '' : 'species',
        subBuilder: PestSpecies.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPestSpeciesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPestSpeciesResponse copyWith(
          void Function(ListPestSpeciesResponse) updates) =>
      super.copyWith((message) => updates(message as ListPestSpeciesResponse))
          as ListPestSpeciesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPestSpeciesResponse create() => ListPestSpeciesResponse._();
  @$core.override
  ListPestSpeciesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPestSpeciesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPestSpeciesResponse>(create);
  static ListPestSpeciesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PestSpecies> get species => $_getList(0);

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

class GetTreatmentPlanRequest extends $pb.GeneratedMessage {
  factory GetTreatmentPlanRequest({
    $core.String? predictionId,
  }) {
    final result = create();
    if (predictionId != null) result.predictionId = predictionId;
    return result;
  }

  GetTreatmentPlanRequest._();

  factory GetTreatmentPlanRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTreatmentPlanRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTreatmentPlanRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'predictionId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreatmentPlanRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreatmentPlanRequest copyWith(
          void Function(GetTreatmentPlanRequest) updates) =>
      super.copyWith((message) => updates(message as GetTreatmentPlanRequest))
          as GetTreatmentPlanRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTreatmentPlanRequest create() => GetTreatmentPlanRequest._();
  @$core.override
  GetTreatmentPlanRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTreatmentPlanRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTreatmentPlanRequest>(create);
  static GetTreatmentPlanRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get predictionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set predictionId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPredictionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPredictionId() => $_clearField(1);
}

class GetTreatmentPlanResponse extends $pb.GeneratedMessage {
  factory GetTreatmentPlanResponse({
    PestPrediction? prediction,
    $core.Iterable<RecommendedTreatment>? treatments,
  }) {
    final result = create();
    if (prediction != null) result.prediction = prediction;
    if (treatments != null) result.treatments.addAll(treatments);
    return result;
  }

  GetTreatmentPlanResponse._();

  factory GetTreatmentPlanResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTreatmentPlanResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTreatmentPlanResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOM<PestPrediction>(1, _omitFieldNames ? '' : 'prediction',
        subBuilder: PestPrediction.create)
    ..pPM<RecommendedTreatment>(2, _omitFieldNames ? '' : 'treatments',
        subBuilder: RecommendedTreatment.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreatmentPlanResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTreatmentPlanResponse copyWith(
          void Function(GetTreatmentPlanResponse) updates) =>
      super.copyWith((message) => updates(message as GetTreatmentPlanResponse))
          as GetTreatmentPlanResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTreatmentPlanResponse create() => GetTreatmentPlanResponse._();
  @$core.override
  GetTreatmentPlanResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTreatmentPlanResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTreatmentPlanResponse>(create);
  static GetTreatmentPlanResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PestPrediction get prediction => $_getN(0);
  @$pb.TagNumber(1)
  set prediction(PestPrediction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPrediction() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrediction() => $_clearField(1);
  @$pb.TagNumber(1)
  PestPrediction ensurePrediction() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<RecommendedTreatment> get treatments => $_getList(1);
}

class GetRiskMapRequest extends $pb.GeneratedMessage {
  factory GetRiskMapRequest({
    $core.String? pestSpeciesId,
    $core.String? region,
  }) {
    final result = create();
    if (pestSpeciesId != null) result.pestSpeciesId = pestSpeciesId;
    if (region != null) result.region = region;
    return result;
  }

  GetRiskMapRequest._();

  factory GetRiskMapRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRiskMapRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRiskMapRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pestSpeciesId')
    ..aOS(2, _omitFieldNames ? '' : 'region')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRiskMapRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRiskMapRequest copyWith(void Function(GetRiskMapRequest) updates) =>
      super.copyWith((message) => updates(message as GetRiskMapRequest))
          as GetRiskMapRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRiskMapRequest create() => GetRiskMapRequest._();
  @$core.override
  GetRiskMapRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRiskMapRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRiskMapRequest>(create);
  static GetRiskMapRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pestSpeciesId => $_getSZ(0);
  @$pb.TagNumber(1)
  set pestSpeciesId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPestSpeciesId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPestSpeciesId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get region => $_getSZ(1);
  @$pb.TagNumber(2)
  set region($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRegion() => $_has(1);
  @$pb.TagNumber(2)
  void clearRegion() => $_clearField(2);
}

class GetRiskMapResponse extends $pb.GeneratedMessage {
  factory GetRiskMapResponse({
    PestRiskMap? riskMap,
  }) {
    final result = create();
    if (riskMap != null) result.riskMap = riskMap;
    return result;
  }

  GetRiskMapResponse._();

  factory GetRiskMapResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRiskMapResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRiskMapResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOM<PestRiskMap>(1, _omitFieldNames ? '' : 'riskMap',
        subBuilder: PestRiskMap.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRiskMapResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRiskMapResponse copyWith(void Function(GetRiskMapResponse) updates) =>
      super.copyWith((message) => updates(message as GetRiskMapResponse))
          as GetRiskMapResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRiskMapResponse create() => GetRiskMapResponse._();
  @$core.override
  GetRiskMapResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRiskMapResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRiskMapResponse>(create);
  static GetRiskMapResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PestRiskMap get riskMap => $_getN(0);
  @$pb.TagNumber(1)
  set riskMap(PestRiskMap value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRiskMap() => $_has(0);
  @$pb.TagNumber(1)
  void clearRiskMap() => $_clearField(1);
  @$pb.TagNumber(1)
  PestRiskMap ensureRiskMap() => $_ensure(0);
}

class ListAlertsRequest extends $pb.GeneratedMessage {
  factory ListAlertsRequest({
    $core.String? farmId,
    $core.String? fieldId,
    AlertStatus? status,
    RiskLevel? minRiskLevel,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (status != null) result.status = status;
    if (minRiskLevel != null) result.minRiskLevel = minRiskLevel;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
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
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aE<AlertStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: AlertStatus.values)
    ..aE<RiskLevel>(4, _omitFieldNames ? '' : 'minRiskLevel',
        enumValues: RiskLevel.values)
    ..aI(5, _omitFieldNames ? '' : 'pageSize')
    ..aOS(6, _omitFieldNames ? '' : 'pageToken')
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
  AlertStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(AlertStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  RiskLevel get minRiskLevel => $_getN(3);
  @$pb.TagNumber(4)
  set minRiskLevel(RiskLevel value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMinRiskLevel() => $_has(3);
  @$pb.TagNumber(4)
  void clearMinRiskLevel() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pageSize => $_getIZ(4);
  @$pb.TagNumber(5)
  set pageSize($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageSize() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get pageToken => $_getSZ(5);
  @$pb.TagNumber(6)
  set pageToken($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageToken() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageToken() => $_clearField(6);
}

class ListAlertsResponse extends $pb.GeneratedMessage {
  factory ListAlertsResponse({
    $core.Iterable<PestAlert>? alerts,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (alerts != null) result.alerts.addAll(alerts);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
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
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..pPM<PestAlert>(1, _omitFieldNames ? '' : 'alerts',
        subBuilder: PestAlert.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
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
  $pb.PbList<PestAlert> get alerts => $_getList(0);

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

class AcknowledgeAlertRequest extends $pb.GeneratedMessage {
  factory AcknowledgeAlertRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
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
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
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
}

class AcknowledgeAlertResponse extends $pb.GeneratedMessage {
  factory AcknowledgeAlertResponse({
    PestAlert? alert,
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
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.pest.v1'),
      createEmptyInstance: create)
    ..aOM<PestAlert>(1, _omitFieldNames ? '' : 'alert',
        subBuilder: PestAlert.create)
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
  PestAlert get alert => $_getN(0);
  @$pb.TagNumber(1)
  set alert(PestAlert value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAlert() => $_has(0);
  @$pb.TagNumber(1)
  void clearAlert() => $_clearField(1);
  @$pb.TagNumber(1)
  PestAlert ensureAlert() => $_ensure(0);
}

/// PestPredictionService provides pest outbreak prediction and management.
class PestPredictionServiceApi {
  final $pb.RpcClient _client;

  PestPredictionServiceApi(this._client);

  /// PredictPestRisk generates a pest risk prediction for a field.
  $async.Future<PredictPestRiskResponse> predictPestRisk(
          $pb.ClientContext? ctx, PredictPestRiskRequest request) =>
      _client.invoke<PredictPestRiskResponse>(ctx, 'PestPredictionService',
          'PredictPestRisk', request, PredictPestRiskResponse());

  /// GetPrediction retrieves a prediction by ID.
  $async.Future<GetPredictionResponse> getPrediction(
          $pb.ClientContext? ctx, GetPredictionRequest request) =>
      _client.invoke<GetPredictionResponse>(ctx, 'PestPredictionService',
          'GetPrediction', request, GetPredictionResponse());

  /// ListPredictions lists predictions with filtering and pagination.
  $async.Future<ListPredictionsResponse> listPredictions(
          $pb.ClientContext? ctx, ListPredictionsRequest request) =>
      _client.invoke<ListPredictionsResponse>(ctx, 'PestPredictionService',
          'ListPredictions', request, ListPredictionsResponse());

  /// ReportObservation records a field pest observation.
  $async.Future<ReportObservationResponse> reportObservation(
          $pb.ClientContext? ctx, ReportObservationRequest request) =>
      _client.invoke<ReportObservationResponse>(ctx, 'PestPredictionService',
          'ReportObservation', request, ReportObservationResponse());

  /// ListObservations lists pest observations with filtering and pagination.
  $async.Future<ListObservationsResponse> listObservations(
          $pb.ClientContext? ctx, ListObservationsRequest request) =>
      _client.invoke<ListObservationsResponse>(ctx, 'PestPredictionService',
          'ListObservations', request, ListObservationsResponse());

  /// GetPestSpecies retrieves a pest species by ID.
  $async.Future<GetPestSpeciesResponse> getPestSpecies(
          $pb.ClientContext? ctx, GetPestSpeciesRequest request) =>
      _client.invoke<GetPestSpeciesResponse>(ctx, 'PestPredictionService',
          'GetPestSpecies', request, GetPestSpeciesResponse());

  /// ListPestSpecies lists pest species with filtering and pagination.
  $async.Future<ListPestSpeciesResponse> listPestSpecies(
          $pb.ClientContext? ctx, ListPestSpeciesRequest request) =>
      _client.invoke<ListPestSpeciesResponse>(ctx, 'PestPredictionService',
          'ListPestSpecies', request, ListPestSpeciesResponse());

  /// GetTreatmentPlan retrieves recommended treatments for a prediction.
  $async.Future<GetTreatmentPlanResponse> getTreatmentPlan(
          $pb.ClientContext? ctx, GetTreatmentPlanRequest request) =>
      _client.invoke<GetTreatmentPlanResponse>(ctx, 'PestPredictionService',
          'GetTreatmentPlan', request, GetTreatmentPlanResponse());

  /// GetRiskMap retrieves a geographic risk map for a pest species in a region.
  $async.Future<GetRiskMapResponse> getRiskMap(
          $pb.ClientContext? ctx, GetRiskMapRequest request) =>
      _client.invoke<GetRiskMapResponse>(ctx, 'PestPredictionService',
          'GetRiskMap', request, GetRiskMapResponse());

  /// ListAlerts lists pest alerts with filtering and pagination.
  $async.Future<ListAlertsResponse> listAlerts(
          $pb.ClientContext? ctx, ListAlertsRequest request) =>
      _client.invoke<ListAlertsResponse>(ctx, 'PestPredictionService',
          'ListAlerts', request, ListAlertsResponse());

  /// AcknowledgeAlert marks an alert as acknowledged.
  $async.Future<AcknowledgeAlertResponse> acknowledgeAlert(
          $pb.ClientContext? ctx, AcknowledgeAlertRequest request) =>
      _client.invoke<AcknowledgeAlertResponse>(ctx, 'PestPredictionService',
          'AcknowledgeAlert', request, AcknowledgeAlertResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
