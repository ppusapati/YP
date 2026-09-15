// This is a generated file - do not edit.
//
// Generated from diagnosis.proto.

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

import 'diagnosis.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'diagnosis.pbenum.dart';

class DiagnosisImage extends $pb.GeneratedMessage {
  factory DiagnosisImage({
    $core.String? id,
    $core.String? imageUrl,
    ImageType? imageType,
    $fixnum.Int64? sizeBytes,
    $core.String? mimeType,
    $core.String? checksum,
    $0.Timestamp? uploadedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (imageType != null) result.imageType = imageType;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (mimeType != null) result.mimeType = mimeType;
    if (checksum != null) result.checksum = checksum;
    if (uploadedAt != null) result.uploadedAt = uploadedAt;
    return result;
  }

  DiagnosisImage._();

  factory DiagnosisImage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiagnosisImage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiagnosisImage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'imageUrl')
    ..aE<ImageType>(3, _omitFieldNames ? '' : 'imageType',
        enumValues: ImageType.values)
    ..aInt64(4, _omitFieldNames ? '' : 'sizeBytes')
    ..aOS(5, _omitFieldNames ? '' : 'mimeType')
    ..aOS(6, _omitFieldNames ? '' : 'checksum')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'uploadedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiagnosisImage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiagnosisImage copyWith(void Function(DiagnosisImage) updates) =>
      super.copyWith((message) => updates(message as DiagnosisImage))
          as DiagnosisImage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiagnosisImage create() => DiagnosisImage._();
  @$core.override
  DiagnosisImage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiagnosisImage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiagnosisImage>(create);
  static DiagnosisImage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get imageUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set imageUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasImageUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearImageUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  ImageType get imageType => $_getN(2);
  @$pb.TagNumber(3)
  set imageType(ImageType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasImageType() => $_has(2);
  @$pb.TagNumber(3)
  void clearImageType() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sizeBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set sizeBytes($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSizeBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearSizeBytes() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get mimeType => $_getSZ(4);
  @$pb.TagNumber(5)
  set mimeType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMimeType() => $_has(4);
  @$pb.TagNumber(5)
  void clearMimeType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get checksum => $_getSZ(5);
  @$pb.TagNumber(6)
  set checksum($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasChecksum() => $_has(5);
  @$pb.TagNumber(6)
  void clearChecksum() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get uploadedAt => $_getN(6);
  @$pb.TagNumber(7)
  set uploadedAt($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasUploadedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearUploadedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureUploadedAt() => $_ensure(6);
}

class DiseaseInfo extends $pb.GeneratedMessage {
  factory DiseaseInfo({
    $core.String? diseaseId,
    $core.String? diseaseName,
    $core.String? scientificName,
    $core.double? confidenceScore,
    Severity? severity,
    $core.String? description,
    $core.String? symptoms,
    $core.Iterable<$core.String>? treatmentOptions,
    $core.String? prevention,
  }) {
    final result = create();
    if (diseaseId != null) result.diseaseId = diseaseId;
    if (diseaseName != null) result.diseaseName = diseaseName;
    if (scientificName != null) result.scientificName = scientificName;
    if (confidenceScore != null) result.confidenceScore = confidenceScore;
    if (severity != null) result.severity = severity;
    if (description != null) result.description = description;
    if (symptoms != null) result.symptoms = symptoms;
    if (treatmentOptions != null)
      result.treatmentOptions.addAll(treatmentOptions);
    if (prevention != null) result.prevention = prevention;
    return result;
  }

  DiseaseInfo._();

  factory DiseaseInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiseaseInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiseaseInfo',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'diseaseId')
    ..aOS(2, _omitFieldNames ? '' : 'diseaseName')
    ..aOS(3, _omitFieldNames ? '' : 'scientificName')
    ..aD(4, _omitFieldNames ? '' : 'confidenceScore')
    ..aE<Severity>(5, _omitFieldNames ? '' : 'severity',
        enumValues: Severity.values)
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'symptoms')
    ..pPS(8, _omitFieldNames ? '' : 'treatmentOptions')
    ..aOS(9, _omitFieldNames ? '' : 'prevention')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiseaseInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiseaseInfo copyWith(void Function(DiseaseInfo) updates) =>
      super.copyWith((message) => updates(message as DiseaseInfo))
          as DiseaseInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiseaseInfo create() => DiseaseInfo._();
  @$core.override
  DiseaseInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiseaseInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiseaseInfo>(create);
  static DiseaseInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get diseaseId => $_getSZ(0);
  @$pb.TagNumber(1)
  set diseaseId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDiseaseId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDiseaseId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get diseaseName => $_getSZ(1);
  @$pb.TagNumber(2)
  set diseaseName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDiseaseName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDiseaseName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get scientificName => $_getSZ(2);
  @$pb.TagNumber(3)
  set scientificName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScientificName() => $_has(2);
  @$pb.TagNumber(3)
  void clearScientificName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get confidenceScore => $_getN(3);
  @$pb.TagNumber(4)
  set confidenceScore($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfidenceScore() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfidenceScore() => $_clearField(4);

  @$pb.TagNumber(5)
  Severity get severity => $_getN(4);
  @$pb.TagNumber(5)
  set severity(Severity value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSeverity() => $_has(4);
  @$pb.TagNumber(5)
  void clearSeverity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get symptoms => $_getSZ(6);
  @$pb.TagNumber(7)
  set symptoms($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSymptoms() => $_has(6);
  @$pb.TagNumber(7)
  void clearSymptoms() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get treatmentOptions => $_getList(7);

  @$pb.TagNumber(9)
  $core.String get prevention => $_getSZ(8);
  @$pb.TagNumber(9)
  set prevention($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPrevention() => $_has(8);
  @$pb.TagNumber(9)
  void clearPrevention() => $_clearField(9);
}

class NutrientDeficiency extends $pb.GeneratedMessage {
  factory NutrientDeficiency({
    $core.String? nutrient,
    $core.double? confidenceScore,
    Severity? severity,
    $core.String? description,
    $core.String? visualSymptoms,
    $core.Iterable<$core.String>? recommendedFertilizers,
    $core.String? applicationMethod,
  }) {
    final result = create();
    if (nutrient != null) result.nutrient = nutrient;
    if (confidenceScore != null) result.confidenceScore = confidenceScore;
    if (severity != null) result.severity = severity;
    if (description != null) result.description = description;
    if (visualSymptoms != null) result.visualSymptoms = visualSymptoms;
    if (recommendedFertilizers != null)
      result.recommendedFertilizers.addAll(recommendedFertilizers);
    if (applicationMethod != null) result.applicationMethod = applicationMethod;
    return result;
  }

  NutrientDeficiency._();

  factory NutrientDeficiency.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NutrientDeficiency.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NutrientDeficiency',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nutrient')
    ..aD(2, _omitFieldNames ? '' : 'confidenceScore')
    ..aE<Severity>(3, _omitFieldNames ? '' : 'severity',
        enumValues: Severity.values)
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'visualSymptoms')
    ..pPS(6, _omitFieldNames ? '' : 'recommendedFertilizers')
    ..aOS(7, _omitFieldNames ? '' : 'applicationMethod')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NutrientDeficiency clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NutrientDeficiency copyWith(void Function(NutrientDeficiency) updates) =>
      super.copyWith((message) => updates(message as NutrientDeficiency))
          as NutrientDeficiency;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NutrientDeficiency create() => NutrientDeficiency._();
  @$core.override
  NutrientDeficiency createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NutrientDeficiency getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NutrientDeficiency>(create);
  static NutrientDeficiency? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nutrient => $_getSZ(0);
  @$pb.TagNumber(1)
  set nutrient($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNutrient() => $_has(0);
  @$pb.TagNumber(1)
  void clearNutrient() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get confidenceScore => $_getN(1);
  @$pb.TagNumber(2)
  set confidenceScore($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConfidenceScore() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfidenceScore() => $_clearField(2);

  @$pb.TagNumber(3)
  Severity get severity => $_getN(2);
  @$pb.TagNumber(3)
  set severity(Severity value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSeverity() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeverity() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get visualSymptoms => $_getSZ(4);
  @$pb.TagNumber(5)
  set visualSymptoms($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVisualSymptoms() => $_has(4);
  @$pb.TagNumber(5)
  void clearVisualSymptoms() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get recommendedFertilizers => $_getList(5);

  @$pb.TagNumber(7)
  $core.String get applicationMethod => $_getSZ(6);
  @$pb.TagNumber(7)
  set applicationMethod($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasApplicationMethod() => $_has(6);
  @$pb.TagNumber(7)
  void clearApplicationMethod() => $_clearField(7);
}

class PestDamage extends $pb.GeneratedMessage {
  factory PestDamage({
    $core.String? pestId,
    $core.String? pestName,
    $core.String? scientificName,
    $core.double? confidenceScore,
    Severity? damageLevel,
    $core.String? description,
    $core.String? damagePattern,
    $core.Iterable<$core.String>? controlMethods,
  }) {
    final result = create();
    if (pestId != null) result.pestId = pestId;
    if (pestName != null) result.pestName = pestName;
    if (scientificName != null) result.scientificName = scientificName;
    if (confidenceScore != null) result.confidenceScore = confidenceScore;
    if (damageLevel != null) result.damageLevel = damageLevel;
    if (description != null) result.description = description;
    if (damagePattern != null) result.damagePattern = damagePattern;
    if (controlMethods != null) result.controlMethods.addAll(controlMethods);
    return result;
  }

  PestDamage._();

  factory PestDamage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PestDamage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PestDamage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pestId')
    ..aOS(2, _omitFieldNames ? '' : 'pestName')
    ..aOS(3, _omitFieldNames ? '' : 'scientificName')
    ..aD(4, _omitFieldNames ? '' : 'confidenceScore')
    ..aE<Severity>(5, _omitFieldNames ? '' : 'damageLevel',
        enumValues: Severity.values)
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'damagePattern')
    ..pPS(8, _omitFieldNames ? '' : 'controlMethods')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestDamage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestDamage copyWith(void Function(PestDamage) updates) =>
      super.copyWith((message) => updates(message as PestDamage)) as PestDamage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PestDamage create() => PestDamage._();
  @$core.override
  PestDamage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PestDamage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PestDamage>(create);
  static PestDamage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set pestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pestName => $_getSZ(1);
  @$pb.TagNumber(2)
  set pestName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPestName() => $_has(1);
  @$pb.TagNumber(2)
  void clearPestName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get scientificName => $_getSZ(2);
  @$pb.TagNumber(3)
  set scientificName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScientificName() => $_has(2);
  @$pb.TagNumber(3)
  void clearScientificName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get confidenceScore => $_getN(3);
  @$pb.TagNumber(4)
  set confidenceScore($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfidenceScore() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfidenceScore() => $_clearField(4);

  @$pb.TagNumber(5)
  Severity get damageLevel => $_getN(4);
  @$pb.TagNumber(5)
  set damageLevel(Severity value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDamageLevel() => $_has(4);
  @$pb.TagNumber(5)
  void clearDamageLevel() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get damagePattern => $_getSZ(6);
  @$pb.TagNumber(7)
  set damagePattern($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDamagePattern() => $_has(6);
  @$pb.TagNumber(7)
  void clearDamagePattern() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get controlMethods => $_getList(7);
}

class PlantSpecies extends $pb.GeneratedMessage {
  factory PlantSpecies({
    $core.String? id,
    $core.String? commonName,
    $core.String? scientificName,
    $core.String? family,
    $core.double? confidence,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (commonName != null) result.commonName = commonName;
    if (scientificName != null) result.scientificName = scientificName;
    if (family != null) result.family = family;
    if (confidence != null) result.confidence = confidence;
    return result;
  }

  PlantSpecies._();

  factory PlantSpecies.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PlantSpecies.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PlantSpecies',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'commonName')
    ..aOS(3, _omitFieldNames ? '' : 'scientificName')
    ..aOS(4, _omitFieldNames ? '' : 'family')
    ..aD(5, _omitFieldNames ? '' : 'confidence')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlantSpecies clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlantSpecies copyWith(void Function(PlantSpecies) updates) =>
      super.copyWith((message) => updates(message as PlantSpecies))
          as PlantSpecies;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlantSpecies create() => PlantSpecies._();
  @$core.override
  PlantSpecies createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PlantSpecies getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PlantSpecies>(create);
  static PlantSpecies? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commonName => $_getSZ(1);
  @$pb.TagNumber(2)
  set commonName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommonName() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommonName() => $_clearField(2);

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
  $core.double get confidence => $_getN(4);
  @$pb.TagNumber(5)
  set confidence($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConfidence() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfidence() => $_clearField(5);
}

class TreatmentPlan extends $pb.GeneratedMessage {
  factory TreatmentPlan({
    $core.String? id,
    $core.String? diagnosisId,
    $core.String? title,
    $core.String? description,
    Severity? priority,
    $core.Iterable<TreatmentStep>? steps,
    $core.String? estimatedCost,
    $core.int? estimatedDays,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (diagnosisId != null) result.diagnosisId = diagnosisId;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (priority != null) result.priority = priority;
    if (steps != null) result.steps.addAll(steps);
    if (estimatedCost != null) result.estimatedCost = estimatedCost;
    if (estimatedDays != null) result.estimatedDays = estimatedDays;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  TreatmentPlan._();

  factory TreatmentPlan.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TreatmentPlan.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreatmentPlan',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'diagnosisId')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aE<Severity>(5, _omitFieldNames ? '' : 'priority',
        enumValues: Severity.values)
    ..pPM<TreatmentStep>(6, _omitFieldNames ? '' : 'steps',
        subBuilder: TreatmentStep.create)
    ..aOS(7, _omitFieldNames ? '' : 'estimatedCost')
    ..aI(8, _omitFieldNames ? '' : 'estimatedDays')
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreatmentPlan clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreatmentPlan copyWith(void Function(TreatmentPlan) updates) =>
      super.copyWith((message) => updates(message as TreatmentPlan))
          as TreatmentPlan;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TreatmentPlan create() => TreatmentPlan._();
  @$core.override
  TreatmentPlan createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TreatmentPlan getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TreatmentPlan>(create);
  static TreatmentPlan? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get diagnosisId => $_getSZ(1);
  @$pb.TagNumber(2)
  set diagnosisId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDiagnosisId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDiagnosisId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  Severity get priority => $_getN(4);
  @$pb.TagNumber(5)
  set priority(Severity value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPriority() => $_has(4);
  @$pb.TagNumber(5)
  void clearPriority() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<TreatmentStep> get steps => $_getList(5);

  @$pb.TagNumber(7)
  $core.String get estimatedCost => $_getSZ(6);
  @$pb.TagNumber(7)
  set estimatedCost($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEstimatedCost() => $_has(6);
  @$pb.TagNumber(7)
  void clearEstimatedCost() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get estimatedDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set estimatedDays($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEstimatedDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearEstimatedDays() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(9)
  set createdAt($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureCreatedAt() => $_ensure(8);
}

class TreatmentStep extends $pb.GeneratedMessage {
  factory TreatmentStep({
    $core.int? stepNumber,
    $core.String? action,
    $core.String? product,
    $core.String? dosage,
    $core.String? frequency,
    $core.String? notes,
    $core.int? durationDays,
  }) {
    final result = create();
    if (stepNumber != null) result.stepNumber = stepNumber;
    if (action != null) result.action = action;
    if (product != null) result.product = product;
    if (dosage != null) result.dosage = dosage;
    if (frequency != null) result.frequency = frequency;
    if (notes != null) result.notes = notes;
    if (durationDays != null) result.durationDays = durationDays;
    return result;
  }

  TreatmentStep._();

  factory TreatmentStep.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TreatmentStep.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TreatmentStep',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'stepNumber')
    ..aOS(2, _omitFieldNames ? '' : 'action')
    ..aOS(3, _omitFieldNames ? '' : 'product')
    ..aOS(4, _omitFieldNames ? '' : 'dosage')
    ..aOS(5, _omitFieldNames ? '' : 'frequency')
    ..aOS(6, _omitFieldNames ? '' : 'notes')
    ..aI(7, _omitFieldNames ? '' : 'durationDays')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreatmentStep clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TreatmentStep copyWith(void Function(TreatmentStep) updates) =>
      super.copyWith((message) => updates(message as TreatmentStep))
          as TreatmentStep;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TreatmentStep create() => TreatmentStep._();
  @$core.override
  TreatmentStep createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TreatmentStep getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TreatmentStep>(create);
  static TreatmentStep? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get stepNumber => $_getIZ(0);
  @$pb.TagNumber(1)
  set stepNumber($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStepNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearStepNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get action => $_getSZ(1);
  @$pb.TagNumber(2)
  set action($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAction() => $_has(1);
  @$pb.TagNumber(2)
  void clearAction() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get product => $_getSZ(2);
  @$pb.TagNumber(3)
  set product($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProduct() => $_has(2);
  @$pb.TagNumber(3)
  void clearProduct() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get dosage => $_getSZ(3);
  @$pb.TagNumber(4)
  set dosage($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDosage() => $_has(3);
  @$pb.TagNumber(4)
  void clearDosage() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get frequency => $_getSZ(4);
  @$pb.TagNumber(5)
  set frequency($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFrequency() => $_has(4);
  @$pb.TagNumber(5)
  void clearFrequency() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get notes => $_getSZ(5);
  @$pb.TagNumber(6)
  set notes($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNotes() => $_has(5);
  @$pb.TagNumber(6)
  void clearNotes() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get durationDays => $_getIZ(6);
  @$pb.TagNumber(7)
  set durationDays($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDurationDays() => $_has(6);
  @$pb.TagNumber(7)
  void clearDurationDays() => $_clearField(7);
}

class DiagnosisResult extends $pb.GeneratedMessage {
  factory DiagnosisResult({
    $core.String? id,
    $core.String? diagnosisRequestId,
    PlantSpecies? identifiedSpecies,
    $core.Iterable<DiseaseInfo>? detectedDiseases,
    $core.Iterable<NutrientDeficiency>? nutrientDeficiencies,
    $core.Iterable<PestDamage>? pestDamage,
    $core.Iterable<$core.String>? treatmentRecommendations,
    $core.String? aiModelVersion,
    $fixnum.Int64? processingTimeMs,
    $core.double? overallHealthScore,
    $core.String? summary,
    $0.Timestamp? createdAt,
    $core.Iterable<Explanation>? explanations,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (diagnosisRequestId != null)
      result.diagnosisRequestId = diagnosisRequestId;
    if (identifiedSpecies != null) result.identifiedSpecies = identifiedSpecies;
    if (detectedDiseases != null)
      result.detectedDiseases.addAll(detectedDiseases);
    if (nutrientDeficiencies != null)
      result.nutrientDeficiencies.addAll(nutrientDeficiencies);
    if (pestDamage != null) result.pestDamage.addAll(pestDamage);
    if (treatmentRecommendations != null)
      result.treatmentRecommendations.addAll(treatmentRecommendations);
    if (aiModelVersion != null) result.aiModelVersion = aiModelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    if (overallHealthScore != null)
      result.overallHealthScore = overallHealthScore;
    if (summary != null) result.summary = summary;
    if (createdAt != null) result.createdAt = createdAt;
    if (explanations != null) result.explanations.addAll(explanations);
    return result;
  }

  DiagnosisResult._();

  factory DiagnosisResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiagnosisResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiagnosisResult',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'diagnosisRequestId')
    ..aOM<PlantSpecies>(3, _omitFieldNames ? '' : 'identifiedSpecies',
        subBuilder: PlantSpecies.create)
    ..pPM<DiseaseInfo>(4, _omitFieldNames ? '' : 'detectedDiseases',
        subBuilder: DiseaseInfo.create)
    ..pPM<NutrientDeficiency>(5, _omitFieldNames ? '' : 'nutrientDeficiencies',
        subBuilder: NutrientDeficiency.create)
    ..pPM<PestDamage>(6, _omitFieldNames ? '' : 'pestDamage',
        subBuilder: PestDamage.create)
    ..pPS(7, _omitFieldNames ? '' : 'treatmentRecommendations')
    ..aOS(8, _omitFieldNames ? '' : 'aiModelVersion')
    ..aInt64(9, _omitFieldNames ? '' : 'processingTimeMs')
    ..aD(10, _omitFieldNames ? '' : 'overallHealthScore')
    ..aOS(11, _omitFieldNames ? '' : 'summary')
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..pPM<Explanation>(13, _omitFieldNames ? '' : 'explanations',
        subBuilder: Explanation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiagnosisResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiagnosisResult copyWith(void Function(DiagnosisResult) updates) =>
      super.copyWith((message) => updates(message as DiagnosisResult))
          as DiagnosisResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiagnosisResult create() => DiagnosisResult._();
  @$core.override
  DiagnosisResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiagnosisResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiagnosisResult>(create);
  static DiagnosisResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get diagnosisRequestId => $_getSZ(1);
  @$pb.TagNumber(2)
  set diagnosisRequestId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDiagnosisRequestId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDiagnosisRequestId() => $_clearField(2);

  @$pb.TagNumber(3)
  PlantSpecies get identifiedSpecies => $_getN(2);
  @$pb.TagNumber(3)
  set identifiedSpecies(PlantSpecies value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasIdentifiedSpecies() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentifiedSpecies() => $_clearField(3);
  @$pb.TagNumber(3)
  PlantSpecies ensureIdentifiedSpecies() => $_ensure(2);

  @$pb.TagNumber(4)
  $pb.PbList<DiseaseInfo> get detectedDiseases => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<NutrientDeficiency> get nutrientDeficiencies => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<PestDamage> get pestDamage => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get treatmentRecommendations => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get aiModelVersion => $_getSZ(7);
  @$pb.TagNumber(8)
  set aiModelVersion($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAiModelVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearAiModelVersion() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get processingTimeMs => $_getI64(8);
  @$pb.TagNumber(9)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasProcessingTimeMs() => $_has(8);
  @$pb.TagNumber(9)
  void clearProcessingTimeMs() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get overallHealthScore => $_getN(9);
  @$pb.TagNumber(10)
  set overallHealthScore($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasOverallHealthScore() => $_has(9);
  @$pb.TagNumber(10)
  void clearOverallHealthScore() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get summary => $_getSZ(10);
  @$pb.TagNumber(11)
  set summary($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSummary() => $_has(10);
  @$pb.TagNumber(11)
  void clearSummary() => $_clearField(11);

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

  /// Per-image model explanations, one per analysed photo. Empty when the
  /// serving model could not explain itself.
  @$pb.TagNumber(13)
  $pb.PbList<Explanation> get explanations => $_getList(12);
}

class DiagnosisRequest extends $pb.GeneratedMessage {
  factory DiagnosisRequest({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? plantSpeciesId,
    $core.Iterable<DiagnosisImage>? images,
    DiagnosisStatus? status,
    DiagnosisResult? result,
    $core.String? notes,
    $core.String? createdBy,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $core.int? version,
  }) {
    final result$ = create();
    if (id != null) result$.id = id;
    if (tenantId != null) result$.tenantId = tenantId;
    if (farmId != null) result$.farmId = farmId;
    if (fieldId != null) result$.fieldId = fieldId;
    if (plantSpeciesId != null) result$.plantSpeciesId = plantSpeciesId;
    if (images != null) result$.images.addAll(images);
    if (status != null) result$.status = status;
    if (result != null) result$.result = result;
    if (notes != null) result$.notes = notes;
    if (createdBy != null) result$.createdBy = createdBy;
    if (createdAt != null) result$.createdAt = createdAt;
    if (updatedAt != null) result$.updatedAt = updatedAt;
    if (version != null) result$.version = version;
    return result$;
  }

  DiagnosisRequest._();

  factory DiagnosisRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiagnosisRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiagnosisRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'plantSpeciesId')
    ..pPM<DiagnosisImage>(6, _omitFieldNames ? '' : 'images',
        subBuilder: DiagnosisImage.create)
    ..aE<DiagnosisStatus>(7, _omitFieldNames ? '' : 'status',
        enumValues: DiagnosisStatus.values)
    ..aOM<DiagnosisResult>(8, _omitFieldNames ? '' : 'result',
        subBuilder: DiagnosisResult.create)
    ..aOS(9, _omitFieldNames ? '' : 'notes')
    ..aOS(10, _omitFieldNames ? '' : 'createdBy')
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aI(13, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiagnosisRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiagnosisRequest copyWith(void Function(DiagnosisRequest) updates) =>
      super.copyWith((message) => updates(message as DiagnosisRequest))
          as DiagnosisRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiagnosisRequest create() => DiagnosisRequest._();
  @$core.override
  DiagnosisRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiagnosisRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiagnosisRequest>(create);
  static DiagnosisRequest? _defaultInstance;

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
  $core.String get plantSpeciesId => $_getSZ(4);
  @$pb.TagNumber(5)
  set plantSpeciesId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPlantSpeciesId() => $_has(4);
  @$pb.TagNumber(5)
  void clearPlantSpeciesId() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<DiagnosisImage> get images => $_getList(5);

  @$pb.TagNumber(7)
  DiagnosisStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status(DiagnosisStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  DiagnosisResult get result => $_getN(7);
  @$pb.TagNumber(8)
  set result(DiagnosisResult value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasResult() => $_has(7);
  @$pb.TagNumber(8)
  void clearResult() => $_clearField(8);
  @$pb.TagNumber(8)
  DiagnosisResult ensureResult() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.String get notes => $_getSZ(8);
  @$pb.TagNumber(9)
  set notes($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasNotes() => $_has(8);
  @$pb.TagNumber(9)
  void clearNotes() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get createdBy => $_getSZ(9);
  @$pb.TagNumber(10)
  set createdBy($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedBy() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedBy() => $_clearField(10);

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

  @$pb.TagNumber(13)
  $core.int get version => $_getIZ(12);
  @$pb.TagNumber(13)
  set version($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasVersion() => $_has(12);
  @$pb.TagNumber(13)
  void clearVersion() => $_clearField(13);
}

class SubmitDiagnosisRequest extends $pb.GeneratedMessage {
  factory SubmitDiagnosisRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? plantSpeciesId,
    $core.Iterable<ImageInput>? images,
    $core.String? notes,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (plantSpeciesId != null) result.plantSpeciesId = plantSpeciesId;
    if (images != null) result.images.addAll(images);
    if (notes != null) result.notes = notes;
    return result;
  }

  SubmitDiagnosisRequest._();

  factory SubmitDiagnosisRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubmitDiagnosisRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmitDiagnosisRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'plantSpeciesId')
    ..pPM<ImageInput>(4, _omitFieldNames ? '' : 'images',
        subBuilder: ImageInput.create)
    ..aOS(5, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitDiagnosisRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitDiagnosisRequest copyWith(
          void Function(SubmitDiagnosisRequest) updates) =>
      super.copyWith((message) => updates(message as SubmitDiagnosisRequest))
          as SubmitDiagnosisRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitDiagnosisRequest create() => SubmitDiagnosisRequest._();
  @$core.override
  SubmitDiagnosisRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubmitDiagnosisRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitDiagnosisRequest>(create);
  static SubmitDiagnosisRequest? _defaultInstance;

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
  $core.String get plantSpeciesId => $_getSZ(2);
  @$pb.TagNumber(3)
  set plantSpeciesId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPlantSpeciesId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlantSpeciesId() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<ImageInput> get images => $_getList(3);

  @$pb.TagNumber(5)
  $core.String get notes => $_getSZ(4);
  @$pb.TagNumber(5)
  set notes($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNotes() => $_has(4);
  @$pb.TagNumber(5)
  void clearNotes() => $_clearField(5);
}

class ImageInput extends $pb.GeneratedMessage {
  factory ImageInput({
    $core.String? imageUrl,
    ImageType? imageType,
    $core.String? mimeType,
    $core.List<$core.int>? imageBytes,
  }) {
    final result = create();
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (imageType != null) result.imageType = imageType;
    if (mimeType != null) result.mimeType = mimeType;
    if (imageBytes != null) result.imageBytes = imageBytes;
    return result;
  }

  ImageInput._();

  factory ImageInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImageInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImageInput',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'imageUrl')
    ..aE<ImageType>(2, _omitFieldNames ? '' : 'imageType',
        enumValues: ImageType.values)
    ..aOS(3, _omitFieldNames ? '' : 'mimeType')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'imageBytes', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageInput copyWith(void Function(ImageInput) updates) =>
      super.copyWith((message) => updates(message as ImageInput)) as ImageInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImageInput create() => ImageInput._();
  @$core.override
  ImageInput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImageInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImageInput>(create);
  static ImageInput? _defaultInstance;

  /// Where the image lives, for callers that have already stored it. The
  /// service fetches the bytes behind it; only https and s3 are accepted.
  @$pb.TagNumber(1)
  $core.String get imageUrl => $_getSZ(0);
  @$pb.TagNumber(1)
  set imageUrl($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasImageUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearImageUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  ImageType get imageType => $_getN(1);
  @$pb.TagNumber(2)
  set imageType(ImageType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasImageType() => $_has(1);
  @$pb.TagNumber(2)
  void clearImageType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mimeType => $_getSZ(2);
  @$pb.TagNumber(3)
  set mimeType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMimeType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMimeType() => $_clearField(3);

  /// The image itself, for callers that have not stored it anywhere — which is
  /// every phone. A capture lives at a path on the device that no server can
  /// resolve, so before this field existed the mobile apps sent
  /// `/data/user/0/.../img.jpg` as the URL, it failed scheme validation, and
  /// the photo was never analysed.
  ///
  /// Set one or the other. When bytes are present the URL is not fetched, and
  /// the bytes are never persisted with the request record: they go to the
  /// gateway and are dropped.
  @$pb.TagNumber(4)
  $core.List<$core.int> get imageBytes => $_getN(3);
  @$pb.TagNumber(4)
  set imageBytes($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasImageBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearImageBytes() => $_clearField(4);
}

class SubmitDiagnosisResponse extends $pb.GeneratedMessage {
  factory SubmitDiagnosisResponse({
    DiagnosisRequest? diagnosis,
  }) {
    final result = create();
    if (diagnosis != null) result.diagnosis = diagnosis;
    return result;
  }

  SubmitDiagnosisResponse._();

  factory SubmitDiagnosisResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubmitDiagnosisResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmitDiagnosisResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOM<DiagnosisRequest>(1, _omitFieldNames ? '' : 'diagnosis',
        subBuilder: DiagnosisRequest.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitDiagnosisResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitDiagnosisResponse copyWith(
          void Function(SubmitDiagnosisResponse) updates) =>
      super.copyWith((message) => updates(message as SubmitDiagnosisResponse))
          as SubmitDiagnosisResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitDiagnosisResponse create() => SubmitDiagnosisResponse._();
  @$core.override
  SubmitDiagnosisResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubmitDiagnosisResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitDiagnosisResponse>(create);
  static SubmitDiagnosisResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DiagnosisRequest get diagnosis => $_getN(0);
  @$pb.TagNumber(1)
  set diagnosis(DiagnosisRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDiagnosis() => $_has(0);
  @$pb.TagNumber(1)
  void clearDiagnosis() => $_clearField(1);
  @$pb.TagNumber(1)
  DiagnosisRequest ensureDiagnosis() => $_ensure(0);
}

class GetDiagnosisRequest extends $pb.GeneratedMessage {
  factory GetDiagnosisRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetDiagnosisRequest._();

  factory GetDiagnosisRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDiagnosisRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDiagnosisRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDiagnosisRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDiagnosisRequest copyWith(void Function(GetDiagnosisRequest) updates) =>
      super.copyWith((message) => updates(message as GetDiagnosisRequest))
          as GetDiagnosisRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDiagnosisRequest create() => GetDiagnosisRequest._();
  @$core.override
  GetDiagnosisRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDiagnosisRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDiagnosisRequest>(create);
  static GetDiagnosisRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetDiagnosisResponse extends $pb.GeneratedMessage {
  factory GetDiagnosisResponse({
    DiagnosisRequest? diagnosis,
  }) {
    final result = create();
    if (diagnosis != null) result.diagnosis = diagnosis;
    return result;
  }

  GetDiagnosisResponse._();

  factory GetDiagnosisResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDiagnosisResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDiagnosisResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOM<DiagnosisRequest>(1, _omitFieldNames ? '' : 'diagnosis',
        subBuilder: DiagnosisRequest.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDiagnosisResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDiagnosisResponse copyWith(void Function(GetDiagnosisResponse) updates) =>
      super.copyWith((message) => updates(message as GetDiagnosisResponse))
          as GetDiagnosisResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDiagnosisResponse create() => GetDiagnosisResponse._();
  @$core.override
  GetDiagnosisResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDiagnosisResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDiagnosisResponse>(create);
  static GetDiagnosisResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DiagnosisRequest get diagnosis => $_getN(0);
  @$pb.TagNumber(1)
  set diagnosis(DiagnosisRequest value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDiagnosis() => $_has(0);
  @$pb.TagNumber(1)
  void clearDiagnosis() => $_clearField(1);
  @$pb.TagNumber(1)
  DiagnosisRequest ensureDiagnosis() => $_ensure(0);
}

class ListDiagnosesRequest extends $pb.GeneratedMessage {
  factory ListDiagnosesRequest({
    $core.String? farmId,
    $core.String? fieldId,
    DiagnosisStatus? status,
    $core.int? pageSize,
    $core.int? pageOffset,
    $core.String? sortBy,
    $core.bool? sortDesc,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (status != null) result.status = status;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    if (sortBy != null) result.sortBy = sortBy;
    if (sortDesc != null) result.sortDesc = sortDesc;
    return result;
  }

  ListDiagnosesRequest._();

  factory ListDiagnosesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListDiagnosesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListDiagnosesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aE<DiagnosisStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: DiagnosisStatus.values)
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aI(5, _omitFieldNames ? '' : 'pageOffset')
    ..aOS(6, _omitFieldNames ? '' : 'sortBy')
    ..aOB(7, _omitFieldNames ? '' : 'sortDesc')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDiagnosesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDiagnosesRequest copyWith(void Function(ListDiagnosesRequest) updates) =>
      super.copyWith((message) => updates(message as ListDiagnosesRequest))
          as ListDiagnosesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDiagnosesRequest create() => ListDiagnosesRequest._();
  @$core.override
  ListDiagnosesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListDiagnosesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDiagnosesRequest>(create);
  static ListDiagnosesRequest? _defaultInstance;

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
  DiagnosisStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(DiagnosisStatus value) => $_setField(3, value);
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

  @$pb.TagNumber(6)
  $core.String get sortBy => $_getSZ(5);
  @$pb.TagNumber(6)
  set sortBy($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSortBy() => $_has(5);
  @$pb.TagNumber(6)
  void clearSortBy() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get sortDesc => $_getBF(6);
  @$pb.TagNumber(7)
  set sortDesc($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSortDesc() => $_has(6);
  @$pb.TagNumber(7)
  void clearSortDesc() => $_clearField(7);
}

class ListDiagnosesResponse extends $pb.GeneratedMessage {
  factory ListDiagnosesResponse({
    $core.Iterable<DiagnosisRequest>? diagnoses,
    $core.int? totalCount,
  }) {
    final result = create();
    if (diagnoses != null) result.diagnoses.addAll(diagnoses);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListDiagnosesResponse._();

  factory ListDiagnosesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListDiagnosesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListDiagnosesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..pPM<DiagnosisRequest>(1, _omitFieldNames ? '' : 'diagnoses',
        subBuilder: DiagnosisRequest.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDiagnosesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDiagnosesResponse copyWith(
          void Function(ListDiagnosesResponse) updates) =>
      super.copyWith((message) => updates(message as ListDiagnosesResponse))
          as ListDiagnosesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDiagnosesResponse create() => ListDiagnosesResponse._();
  @$core.override
  ListDiagnosesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListDiagnosesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDiagnosesResponse>(create);
  static ListDiagnosesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DiagnosisRequest> get diagnoses => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class GetDiseaseInfoRequest extends $pb.GeneratedMessage {
  factory GetDiseaseInfoRequest({
    $core.String? diseaseId,
  }) {
    final result = create();
    if (diseaseId != null) result.diseaseId = diseaseId;
    return result;
  }

  GetDiseaseInfoRequest._();

  factory GetDiseaseInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDiseaseInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDiseaseInfoRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'diseaseId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDiseaseInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDiseaseInfoRequest copyWith(
          void Function(GetDiseaseInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetDiseaseInfoRequest))
          as GetDiseaseInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDiseaseInfoRequest create() => GetDiseaseInfoRequest._();
  @$core.override
  GetDiseaseInfoRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDiseaseInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDiseaseInfoRequest>(create);
  static GetDiseaseInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get diseaseId => $_getSZ(0);
  @$pb.TagNumber(1)
  set diseaseId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDiseaseId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDiseaseId() => $_clearField(1);
}

class GetDiseaseInfoResponse extends $pb.GeneratedMessage {
  factory GetDiseaseInfoResponse({
    DiseaseInfo? disease,
  }) {
    final result = create();
    if (disease != null) result.disease = disease;
    return result;
  }

  GetDiseaseInfoResponse._();

  factory GetDiseaseInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetDiseaseInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetDiseaseInfoResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOM<DiseaseInfo>(1, _omitFieldNames ? '' : 'disease',
        subBuilder: DiseaseInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDiseaseInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDiseaseInfoResponse copyWith(
          void Function(GetDiseaseInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetDiseaseInfoResponse))
          as GetDiseaseInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDiseaseInfoResponse create() => GetDiseaseInfoResponse._();
  @$core.override
  GetDiseaseInfoResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetDiseaseInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDiseaseInfoResponse>(create);
  static GetDiseaseInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DiseaseInfo get disease => $_getN(0);
  @$pb.TagNumber(1)
  set disease(DiseaseInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDisease() => $_has(0);
  @$pb.TagNumber(1)
  void clearDisease() => $_clearField(1);
  @$pb.TagNumber(1)
  DiseaseInfo ensureDisease() => $_ensure(0);
}

class ListDiseasesRequest extends $pb.GeneratedMessage {
  factory ListDiseasesRequest({
    $core.String? searchTerm,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (searchTerm != null) result.searchTerm = searchTerm;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListDiseasesRequest._();

  factory ListDiseasesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListDiseasesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListDiseasesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'searchTerm')
    ..aI(2, _omitFieldNames ? '' : 'pageSize')
    ..aI(3, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDiseasesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDiseasesRequest copyWith(void Function(ListDiseasesRequest) updates) =>
      super.copyWith((message) => updates(message as ListDiseasesRequest))
          as ListDiseasesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDiseasesRequest create() => ListDiseasesRequest._();
  @$core.override
  ListDiseasesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListDiseasesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDiseasesRequest>(create);
  static ListDiseasesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get searchTerm => $_getSZ(0);
  @$pb.TagNumber(1)
  set searchTerm($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSearchTerm() => $_has(0);
  @$pb.TagNumber(1)
  void clearSearchTerm() => $_clearField(1);

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

class ListDiseasesResponse extends $pb.GeneratedMessage {
  factory ListDiseasesResponse({
    $core.Iterable<DiseaseInfo>? diseases,
    $core.int? totalCount,
  }) {
    final result = create();
    if (diseases != null) result.diseases.addAll(diseases);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListDiseasesResponse._();

  factory ListDiseasesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListDiseasesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListDiseasesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..pPM<DiseaseInfo>(1, _omitFieldNames ? '' : 'diseases',
        subBuilder: DiseaseInfo.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDiseasesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDiseasesResponse copyWith(void Function(ListDiseasesResponse) updates) =>
      super.copyWith((message) => updates(message as ListDiseasesResponse))
          as ListDiseasesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDiseasesResponse create() => ListDiseasesResponse._();
  @$core.override
  ListDiseasesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListDiseasesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDiseasesResponse>(create);
  static ListDiseasesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DiseaseInfo> get diseases => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class GetTreatmentPlanRequest extends $pb.GeneratedMessage {
  factory GetTreatmentPlanRequest({
    $core.String? diagnosisId,
  }) {
    final result = create();
    if (diagnosisId != null) result.diagnosisId = diagnosisId;
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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'diagnosisId')
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
  $core.String get diagnosisId => $_getSZ(0);
  @$pb.TagNumber(1)
  set diagnosisId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDiagnosisId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDiagnosisId() => $_clearField(1);
}

class GetTreatmentPlanResponse extends $pb.GeneratedMessage {
  factory GetTreatmentPlanResponse({
    TreatmentPlan? treatmentPlan,
  }) {
    final result = create();
    if (treatmentPlan != null) result.treatmentPlan = treatmentPlan;
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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOM<TreatmentPlan>(1, _omitFieldNames ? '' : 'treatmentPlan',
        subBuilder: TreatmentPlan.create)
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
  TreatmentPlan get treatmentPlan => $_getN(0);
  @$pb.TagNumber(1)
  set treatmentPlan(TreatmentPlan value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTreatmentPlan() => $_has(0);
  @$pb.TagNumber(1)
  void clearTreatmentPlan() => $_clearField(1);
  @$pb.TagNumber(1)
  TreatmentPlan ensureTreatmentPlan() => $_ensure(0);
}

class IdentifySpeciesRequest extends $pb.GeneratedMessage {
  factory IdentifySpeciesRequest({
    $core.Iterable<ImageInput>? images,
  }) {
    final result = create();
    if (images != null) result.images.addAll(images);
    return result;
  }

  IdentifySpeciesRequest._();

  factory IdentifySpeciesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IdentifySpeciesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IdentifySpeciesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..pPM<ImageInput>(1, _omitFieldNames ? '' : 'images',
        subBuilder: ImageInput.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdentifySpeciesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdentifySpeciesRequest copyWith(
          void Function(IdentifySpeciesRequest) updates) =>
      super.copyWith((message) => updates(message as IdentifySpeciesRequest))
          as IdentifySpeciesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IdentifySpeciesRequest create() => IdentifySpeciesRequest._();
  @$core.override
  IdentifySpeciesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IdentifySpeciesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IdentifySpeciesRequest>(create);
  static IdentifySpeciesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ImageInput> get images => $_getList(0);
}

class IdentifySpeciesResponse extends $pb.GeneratedMessage {
  factory IdentifySpeciesResponse({
    $core.Iterable<PlantSpecies>? species,
    $core.String? aiModelVersion,
    $fixnum.Int64? processingTimeMs,
  }) {
    final result = create();
    if (species != null) result.species.addAll(species);
    if (aiModelVersion != null) result.aiModelVersion = aiModelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    return result;
  }

  IdentifySpeciesResponse._();

  factory IdentifySpeciesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IdentifySpeciesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IdentifySpeciesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..pPM<PlantSpecies>(1, _omitFieldNames ? '' : 'species',
        subBuilder: PlantSpecies.create)
    ..aOS(2, _omitFieldNames ? '' : 'aiModelVersion')
    ..aInt64(3, _omitFieldNames ? '' : 'processingTimeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdentifySpeciesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IdentifySpeciesResponse copyWith(
          void Function(IdentifySpeciesResponse) updates) =>
      super.copyWith((message) => updates(message as IdentifySpeciesResponse))
          as IdentifySpeciesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IdentifySpeciesResponse create() => IdentifySpeciesResponse._();
  @$core.override
  IdentifySpeciesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IdentifySpeciesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IdentifySpeciesResponse>(create);
  static IdentifySpeciesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PlantSpecies> get species => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get aiModelVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set aiModelVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAiModelVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearAiModelVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get processingTimeMs => $_getI64(2);
  @$pb.TagNumber(3)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProcessingTimeMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearProcessingTimeMs() => $_clearField(3);
}

/// Why a vision model answered the way it did.
///
/// Produced by Grad-CAM over the serving model's feature map: a heatmap of what
/// the model actually looked at, plus the region it keyed on and a sentence
/// describing it. Absent when the answer came from a model that cannot explain
/// itself — a demo detector or an external provider.
class Explanation extends $pb.GeneratedMessage {
  factory Explanation({
    $core.String? task,
    $core.String? className,
    $core.List<$core.int>? heatmapPng,
    $core.int? heatmapWidth,
    $core.int? heatmapHeight,
    $core.double? focusX,
    $core.double? focusY,
    $core.double? focusWidth,
    $core.double? focusHeight,
    $core.double? focusCoverage,
    $core.String? summary,
    $core.String? method,
    $core.bool? localised,
  }) {
    final result = create();
    if (task != null) result.task = task;
    if (className != null) result.className = className;
    if (heatmapPng != null) result.heatmapPng = heatmapPng;
    if (heatmapWidth != null) result.heatmapWidth = heatmapWidth;
    if (heatmapHeight != null) result.heatmapHeight = heatmapHeight;
    if (focusX != null) result.focusX = focusX;
    if (focusY != null) result.focusY = focusY;
    if (focusWidth != null) result.focusWidth = focusWidth;
    if (focusHeight != null) result.focusHeight = focusHeight;
    if (focusCoverage != null) result.focusCoverage = focusCoverage;
    if (summary != null) result.summary = summary;
    if (method != null) result.method = method;
    if (localised != null) result.localised = localised;
    return result;
  }

  Explanation._();

  factory Explanation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Explanation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Explanation',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'task')
    ..aOS(2, _omitFieldNames ? '' : 'className')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'heatmapPng', $pb.PbFieldType.OY)
    ..aI(4, _omitFieldNames ? '' : 'heatmapWidth')
    ..aI(5, _omitFieldNames ? '' : 'heatmapHeight')
    ..aD(6, _omitFieldNames ? '' : 'focusX')
    ..aD(7, _omitFieldNames ? '' : 'focusY')
    ..aD(8, _omitFieldNames ? '' : 'focusWidth')
    ..aD(9, _omitFieldNames ? '' : 'focusHeight')
    ..aD(10, _omitFieldNames ? '' : 'focusCoverage')
    ..aOS(11, _omitFieldNames ? '' : 'summary')
    ..aOS(12, _omitFieldNames ? '' : 'method')
    ..aOB(13, _omitFieldNames ? '' : 'localised')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Explanation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Explanation copyWith(void Function(Explanation) updates) =>
      super.copyWith((message) => updates(message as Explanation))
          as Explanation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Explanation create() => Explanation._();
  @$core.override
  Explanation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Explanation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Explanation>(create);
  static Explanation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get task => $_getSZ(0);
  @$pb.TagNumber(1)
  set task($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get className => $_getSZ(1);
  @$pb.TagNumber(2)
  set className($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClassName() => $_has(1);
  @$pb.TagNumber(2)
  void clearClassName() => $_clearField(2);

  /// Greyscale PNG, brightest where the evidence is.
  @$pb.TagNumber(3)
  $core.List<$core.int> get heatmapPng => $_getN(2);
  @$pb.TagNumber(3)
  set heatmapPng($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeatmapPng() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeatmapPng() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get heatmapWidth => $_getIZ(3);
  @$pb.TagNumber(4)
  set heatmapWidth($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeatmapWidth() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeatmapWidth() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get heatmapHeight => $_getIZ(4);
  @$pb.TagNumber(5)
  set heatmapHeight($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHeatmapHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeatmapHeight() => $_clearField(5);

  /// Region the model keyed on, normalised to [0,1] from the top left so it
  /// survives any resize of the image it is drawn over.
  @$pb.TagNumber(6)
  $core.double get focusX => $_getN(5);
  @$pb.TagNumber(6)
  set focusX($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFocusX() => $_has(5);
  @$pb.TagNumber(6)
  void clearFocusX() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get focusY => $_getN(6);
  @$pb.TagNumber(7)
  set focusY($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFocusY() => $_has(6);
  @$pb.TagNumber(7)
  void clearFocusY() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get focusWidth => $_getN(7);
  @$pb.TagNumber(8)
  set focusWidth($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFocusWidth() => $_has(7);
  @$pb.TagNumber(8)
  void clearFocusWidth() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get focusHeight => $_getN(8);
  @$pb.TagNumber(9)
  set focusHeight($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFocusHeight() => $_has(8);
  @$pb.TagNumber(9)
  void clearFocusHeight() => $_clearField(9);

  /// Share of the image inside that region; near 1 means nothing in particular
  /// was located.
  @$pb.TagNumber(10)
  $core.double get focusCoverage => $_getN(9);
  @$pb.TagNumber(10)
  set focusCoverage($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasFocusCoverage() => $_has(9);
  @$pb.TagNumber(10)
  void clearFocusCoverage() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get summary => $_getSZ(10);
  @$pb.TagNumber(11)
  set summary($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSummary() => $_has(10);
  @$pb.TagNumber(11)
  void clearSummary() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get method => $_getSZ(11);
  @$pb.TagNumber(12)
  set method($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasMethod() => $_has(11);
  @$pb.TagNumber(12)
  void clearMethod() => $_clearField(12);

  /// False when the map was flat and there is nothing to point at.
  @$pb.TagNumber(13)
  $core.bool get localised => $_getBF(12);
  @$pb.TagNumber(13)
  set localised($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasLocalised() => $_has(12);
  @$pb.TagNumber(13)
  void clearLocalised() => $_clearField(13);
}

class DetectNutrientDeficiencyRequest extends $pb.GeneratedMessage {
  factory DetectNutrientDeficiencyRequest({
    $core.String? plantSpeciesId,
    $core.Iterable<ImageInput>? images,
  }) {
    final result = create();
    if (plantSpeciesId != null) result.plantSpeciesId = plantSpeciesId;
    if (images != null) result.images.addAll(images);
    return result;
  }

  DetectNutrientDeficiencyRequest._();

  factory DetectNutrientDeficiencyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectNutrientDeficiencyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectNutrientDeficiencyRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'plantSpeciesId')
    ..pPM<ImageInput>(2, _omitFieldNames ? '' : 'images',
        subBuilder: ImageInput.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectNutrientDeficiencyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectNutrientDeficiencyRequest copyWith(
          void Function(DetectNutrientDeficiencyRequest) updates) =>
      super.copyWith(
              (message) => updates(message as DetectNutrientDeficiencyRequest))
          as DetectNutrientDeficiencyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectNutrientDeficiencyRequest create() =>
      DetectNutrientDeficiencyRequest._();
  @$core.override
  DetectNutrientDeficiencyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectNutrientDeficiencyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectNutrientDeficiencyRequest>(
          create);
  static DetectNutrientDeficiencyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get plantSpeciesId => $_getSZ(0);
  @$pb.TagNumber(1)
  set plantSpeciesId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlantSpeciesId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlantSpeciesId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<ImageInput> get images => $_getList(1);
}

class DetectNutrientDeficiencyResponse extends $pb.GeneratedMessage {
  factory DetectNutrientDeficiencyResponse({
    $core.Iterable<NutrientDeficiency>? deficiencies,
    $core.String? aiModelVersion,
    $fixnum.Int64? processingTimeMs,
    $core.Iterable<Explanation>? explanations,
  }) {
    final result = create();
    if (deficiencies != null) result.deficiencies.addAll(deficiencies);
    if (aiModelVersion != null) result.aiModelVersion = aiModelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    if (explanations != null) result.explanations.addAll(explanations);
    return result;
  }

  DetectNutrientDeficiencyResponse._();

  factory DetectNutrientDeficiencyResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectNutrientDeficiencyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectNutrientDeficiencyResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..pPM<NutrientDeficiency>(1, _omitFieldNames ? '' : 'deficiencies',
        subBuilder: NutrientDeficiency.create)
    ..aOS(2, _omitFieldNames ? '' : 'aiModelVersion')
    ..aInt64(3, _omitFieldNames ? '' : 'processingTimeMs')
    ..pPM<Explanation>(4, _omitFieldNames ? '' : 'explanations',
        subBuilder: Explanation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectNutrientDeficiencyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectNutrientDeficiencyResponse copyWith(
          void Function(DetectNutrientDeficiencyResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DetectNutrientDeficiencyResponse))
          as DetectNutrientDeficiencyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectNutrientDeficiencyResponse create() =>
      DetectNutrientDeficiencyResponse._();
  @$core.override
  DetectNutrientDeficiencyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectNutrientDeficiencyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectNutrientDeficiencyResponse>(
          create);
  static DetectNutrientDeficiencyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<NutrientDeficiency> get deficiencies => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get aiModelVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set aiModelVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAiModelVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearAiModelVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get processingTimeMs => $_getI64(2);
  @$pb.TagNumber(3)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProcessingTimeMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearProcessingTimeMs() => $_clearField(3);

  /// One per analysed image, in request order.
  @$pb.TagNumber(4)
  $pb.PbList<Explanation> get explanations => $_getList(3);
}

class DetectPestDamageRequest extends $pb.GeneratedMessage {
  factory DetectPestDamageRequest({
    $core.String? plantSpeciesId,
    $core.Iterable<ImageInput>? images,
  }) {
    final result = create();
    if (plantSpeciesId != null) result.plantSpeciesId = plantSpeciesId;
    if (images != null) result.images.addAll(images);
    return result;
  }

  DetectPestDamageRequest._();

  factory DetectPestDamageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectPestDamageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectPestDamageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'plantSpeciesId')
    ..pPM<ImageInput>(2, _omitFieldNames ? '' : 'images',
        subBuilder: ImageInput.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectPestDamageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectPestDamageRequest copyWith(
          void Function(DetectPestDamageRequest) updates) =>
      super.copyWith((message) => updates(message as DetectPestDamageRequest))
          as DetectPestDamageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectPestDamageRequest create() => DetectPestDamageRequest._();
  @$core.override
  DetectPestDamageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectPestDamageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectPestDamageRequest>(create);
  static DetectPestDamageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get plantSpeciesId => $_getSZ(0);
  @$pb.TagNumber(1)
  set plantSpeciesId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlantSpeciesId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlantSpeciesId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<ImageInput> get images => $_getList(1);
}

class DetectPestDamageResponse extends $pb.GeneratedMessage {
  factory DetectPestDamageResponse({
    $core.Iterable<PestDamage>? pests,
    $core.String? aiModelVersion,
    $fixnum.Int64? processingTimeMs,
    $core.Iterable<Explanation>? explanations,
  }) {
    final result = create();
    if (pests != null) result.pests.addAll(pests);
    if (aiModelVersion != null) result.aiModelVersion = aiModelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    if (explanations != null) result.explanations.addAll(explanations);
    return result;
  }

  DetectPestDamageResponse._();

  factory DetectPestDamageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectPestDamageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectPestDamageResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..pPM<PestDamage>(1, _omitFieldNames ? '' : 'pests',
        subBuilder: PestDamage.create)
    ..aOS(2, _omitFieldNames ? '' : 'aiModelVersion')
    ..aInt64(3, _omitFieldNames ? '' : 'processingTimeMs')
    ..pPM<Explanation>(4, _omitFieldNames ? '' : 'explanations',
        subBuilder: Explanation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectPestDamageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectPestDamageResponse copyWith(
          void Function(DetectPestDamageResponse) updates) =>
      super.copyWith((message) => updates(message as DetectPestDamageResponse))
          as DetectPestDamageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectPestDamageResponse create() => DetectPestDamageResponse._();
  @$core.override
  DetectPestDamageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectPestDamageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectPestDamageResponse>(create);
  static DetectPestDamageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PestDamage> get pests => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get aiModelVersion => $_getSZ(1);
  @$pb.TagNumber(2)
  set aiModelVersion($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAiModelVersion() => $_has(1);
  @$pb.TagNumber(2)
  void clearAiModelVersion() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get processingTimeMs => $_getI64(2);
  @$pb.TagNumber(3)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProcessingTimeMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearProcessingTimeMs() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<Explanation> get explanations => $_getList(3);
}

class TrainingLabel extends $pb.GeneratedMessage {
  factory TrainingLabel({
    $core.String? name,
    $core.double? confidence,
    $core.String? category,
    $core.String? severity,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (confidence != null) result.confidence = confidence;
    if (category != null) result.category = category;
    if (severity != null) result.severity = severity;
    return result;
  }

  TrainingLabel._();

  factory TrainingLabel.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TrainingLabel.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TrainingLabel',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aD(2, _omitFieldNames ? '' : 'confidence')
    ..aOS(3, _omitFieldNames ? '' : 'category')
    ..aOS(4, _omitFieldNames ? '' : 'severity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrainingLabel clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrainingLabel copyWith(void Function(TrainingLabel) updates) =>
      super.copyWith((message) => updates(message as TrainingLabel))
          as TrainingLabel;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrainingLabel create() => TrainingLabel._();
  @$core.override
  TrainingLabel createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TrainingLabel getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TrainingLabel>(create);
  static TrainingLabel? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get confidence => $_getN(1);
  @$pb.TagNumber(2)
  set confidence($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConfidence() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfidence() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get category => $_getSZ(2);
  @$pb.TagNumber(3)
  set category($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCategory() => $_has(2);
  @$pb.TagNumber(3)
  void clearCategory() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get severity => $_getSZ(3);
  @$pb.TagNumber(4)
  set severity($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSeverity() => $_has(3);
  @$pb.TagNumber(4)
  void clearSeverity() => $_clearField(4);
}

class LabelReview extends $pb.GeneratedMessage {
  factory LabelReview({
    LabelReviewDecision? decision,
    $core.String? correctedLabel,
    $core.String? reviewerId,
    $core.String? notes,
    $0.Timestamp? reviewedAt,
  }) {
    final result = create();
    if (decision != null) result.decision = decision;
    if (correctedLabel != null) result.correctedLabel = correctedLabel;
    if (reviewerId != null) result.reviewerId = reviewerId;
    if (notes != null) result.notes = notes;
    if (reviewedAt != null) result.reviewedAt = reviewedAt;
    return result;
  }

  LabelReview._();

  factory LabelReview.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LabelReview.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LabelReview',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aE<LabelReviewDecision>(1, _omitFieldNames ? '' : 'decision',
        enumValues: LabelReviewDecision.values)
    ..aOS(2, _omitFieldNames ? '' : 'correctedLabel')
    ..aOS(3, _omitFieldNames ? '' : 'reviewerId')
    ..aOS(4, _omitFieldNames ? '' : 'notes')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'reviewedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelReview clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelReview copyWith(void Function(LabelReview) updates) =>
      super.copyWith((message) => updates(message as LabelReview))
          as LabelReview;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LabelReview create() => LabelReview._();
  @$core.override
  LabelReview createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LabelReview getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LabelReview>(create);
  static LabelReview? _defaultInstance;

  @$pb.TagNumber(1)
  LabelReviewDecision get decision => $_getN(0);
  @$pb.TagNumber(1)
  set decision(LabelReviewDecision value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDecision() => $_has(0);
  @$pb.TagNumber(1)
  void clearDecision() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get correctedLabel => $_getSZ(1);
  @$pb.TagNumber(2)
  set correctedLabel($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCorrectedLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearCorrectedLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get reviewerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set reviewerId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReviewerId() => $_has(2);
  @$pb.TagNumber(3)
  void clearReviewerId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get notes => $_getSZ(3);
  @$pb.TagNumber(4)
  set notes($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNotes() => $_has(3);
  @$pb.TagNumber(4)
  void clearNotes() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get reviewedAt => $_getN(4);
  @$pb.TagNumber(5)
  set reviewedAt($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasReviewedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearReviewedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureReviewedAt() => $_ensure(4);
}

/// A trained model's confident disagreement with a stored label.
///
/// Worth a reviewer's attention ahead of merely low-confidence samples: a wrong
/// label does not just waste one example, it teaches the next model the same
/// mistake and counts as an error against any model that gets it right.
class LabelSuspicion extends $pb.GeneratedMessage {
  factory LabelSuspicion({
    $core.String? predicted,
    $core.double? predictedProb,
    $core.double? labelProb,
    $core.String? modelVersion,
    $core.String? flaggedAt,
  }) {
    final result = create();
    if (predicted != null) result.predicted = predicted;
    if (predictedProb != null) result.predictedProb = predictedProb;
    if (labelProb != null) result.labelProb = labelProb;
    if (modelVersion != null) result.modelVersion = modelVersion;
    if (flaggedAt != null) result.flaggedAt = flaggedAt;
    return result;
  }

  LabelSuspicion._();

  factory LabelSuspicion.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LabelSuspicion.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LabelSuspicion',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'predicted')
    ..aD(2, _omitFieldNames ? '' : 'predictedProb')
    ..aD(3, _omitFieldNames ? '' : 'labelProb')
    ..aOS(4, _omitFieldNames ? '' : 'modelVersion')
    ..aOS(5, _omitFieldNames ? '' : 'flaggedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelSuspicion clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelSuspicion copyWith(void Function(LabelSuspicion) updates) =>
      super.copyWith((message) => updates(message as LabelSuspicion))
          as LabelSuspicion;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LabelSuspicion create() => LabelSuspicion._();
  @$core.override
  LabelSuspicion createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LabelSuspicion getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LabelSuspicion>(create);
  static LabelSuspicion? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get predicted => $_getSZ(0);
  @$pb.TagNumber(1)
  set predicted($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPredicted() => $_has(0);
  @$pb.TagNumber(1)
  void clearPredicted() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get predictedProb => $_getN(1);
  @$pb.TagNumber(2)
  set predictedProb($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPredictedProb() => $_has(1);
  @$pb.TagNumber(2)
  void clearPredictedProb() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get labelProb => $_getN(2);
  @$pb.TagNumber(3)
  set labelProb($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLabelProb() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabelProb() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get modelVersion => $_getSZ(3);
  @$pb.TagNumber(4)
  set modelVersion($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasModelVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearModelVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get flaggedAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set flaggedAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFlaggedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearFlaggedAt() => $_clearField(5);
}

class LabelReviewSample extends $pb.GeneratedMessage {
  factory LabelReviewSample({
    $core.String? id,
    $core.String? task,
    $0.Timestamp? collectedAt,
    $core.String? provenance,
    $core.String? provider,
    $core.Iterable<TrainingLabel>? labels,
    $core.double? topConfidence,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? crop,
    $core.String? submittedBy,
    LabelReview? review,
    $core.String? effectiveLabel,
    LabelSuspicion? suspect,
    $core.bool? needsSecondOpinion,
    $core.Iterable<LabelReview>? reviews,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (task != null) result.task = task;
    if (collectedAt != null) result.collectedAt = collectedAt;
    if (provenance != null) result.provenance = provenance;
    if (provider != null) result.provider = provider;
    if (labels != null) result.labels.addAll(labels);
    if (topConfidence != null) result.topConfidence = topConfidence;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (crop != null) result.crop = crop;
    if (submittedBy != null) result.submittedBy = submittedBy;
    if (review != null) result.review = review;
    if (effectiveLabel != null) result.effectiveLabel = effectiveLabel;
    if (suspect != null) result.suspect = suspect;
    if (needsSecondOpinion != null)
      result.needsSecondOpinion = needsSecondOpinion;
    if (reviews != null) result.reviews.addAll(reviews);
    return result;
  }

  LabelReviewSample._();

  factory LabelReviewSample.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LabelReviewSample.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LabelReviewSample',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'task')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'collectedAt',
        subBuilder: $0.Timestamp.create)
    ..aOS(4, _omitFieldNames ? '' : 'provenance')
    ..aOS(5, _omitFieldNames ? '' : 'provider')
    ..pPM<TrainingLabel>(6, _omitFieldNames ? '' : 'labels',
        subBuilder: TrainingLabel.create)
    ..aD(7, _omitFieldNames ? '' : 'topConfidence')
    ..aOS(8, _omitFieldNames ? '' : 'farmId')
    ..aOS(9, _omitFieldNames ? '' : 'fieldId')
    ..aOS(10, _omitFieldNames ? '' : 'crop')
    ..aOS(11, _omitFieldNames ? '' : 'submittedBy')
    ..aOM<LabelReview>(12, _omitFieldNames ? '' : 'review',
        subBuilder: LabelReview.create)
    ..aOS(13, _omitFieldNames ? '' : 'effectiveLabel')
    ..aOM<LabelSuspicion>(14, _omitFieldNames ? '' : 'suspect',
        subBuilder: LabelSuspicion.create)
    ..aOB(15, _omitFieldNames ? '' : 'needsSecondOpinion')
    ..pPM<LabelReview>(16, _omitFieldNames ? '' : 'reviews',
        subBuilder: LabelReview.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelReviewSample clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelReviewSample copyWith(void Function(LabelReviewSample) updates) =>
      super.copyWith((message) => updates(message as LabelReviewSample))
          as LabelReviewSample;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LabelReviewSample create() => LabelReviewSample._();
  @$core.override
  LabelReviewSample createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LabelReviewSample getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LabelReviewSample>(create);
  static LabelReviewSample? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get task => $_getSZ(1);
  @$pb.TagNumber(2)
  set task($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTask() => $_has(1);
  @$pb.TagNumber(2)
  void clearTask() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get collectedAt => $_getN(2);
  @$pb.TagNumber(3)
  set collectedAt($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCollectedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearCollectedAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureCollectedAt() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get provenance => $_getSZ(3);
  @$pb.TagNumber(4)
  set provenance($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProvenance() => $_has(3);
  @$pb.TagNumber(4)
  void clearProvenance() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get provider => $_getSZ(4);
  @$pb.TagNumber(5)
  set provider($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProvider() => $_has(4);
  @$pb.TagNumber(5)
  void clearProvider() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<TrainingLabel> get labels => $_getList(5);

  @$pb.TagNumber(7)
  $core.double get topConfidence => $_getN(6);
  @$pb.TagNumber(7)
  set topConfidence($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTopConfidence() => $_has(6);
  @$pb.TagNumber(7)
  void clearTopConfidence() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get farmId => $_getSZ(7);
  @$pb.TagNumber(8)
  set farmId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFarmId() => $_has(7);
  @$pb.TagNumber(8)
  void clearFarmId() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get fieldId => $_getSZ(8);
  @$pb.TagNumber(9)
  set fieldId($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFieldId() => $_has(8);
  @$pb.TagNumber(9)
  void clearFieldId() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get crop => $_getSZ(9);
  @$pb.TagNumber(10)
  set crop($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCrop() => $_has(9);
  @$pb.TagNumber(10)
  void clearCrop() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get submittedBy => $_getSZ(10);
  @$pb.TagNumber(11)
  set submittedBy($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSubmittedBy() => $_has(10);
  @$pb.TagNumber(11)
  void clearSubmittedBy() => $_clearField(11);

  @$pb.TagNumber(12)
  LabelReview get review => $_getN(11);
  @$pb.TagNumber(12)
  set review(LabelReview value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasReview() => $_has(11);
  @$pb.TagNumber(12)
  void clearReview() => $_clearField(12);
  @$pb.TagNumber(12)
  LabelReview ensureReview() => $_ensure(11);

  @$pb.TagNumber(13)
  $core.String get effectiveLabel => $_getSZ(12);
  @$pb.TagNumber(13)
  set effectiveLabel($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasEffectiveLabel() => $_has(12);
  @$pb.TagNumber(13)
  void clearEffectiveLabel() => $_clearField(13);

  @$pb.TagNumber(14)
  LabelSuspicion get suspect => $_getN(13);
  @$pb.TagNumber(14)
  set suspect(LabelSuspicion value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasSuspect() => $_has(13);
  @$pb.TagNumber(14)
  void clearSuspect() => $_clearField(14);
  @$pb.TagNumber(14)
  LabelSuspicion ensureSuspect() => $_ensure(13);

  /// True when this sample wants another pair of eyes, because a reviewer asked
  /// or because two reviewers already disagreed.
  @$pb.TagNumber(15)
  $core.bool get needsSecondOpinion => $_getBF(14);
  @$pb.TagNumber(15)
  set needsSecondOpinion($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasNeedsSecondOpinion() => $_has(14);
  @$pb.TagNumber(15)
  void clearNeedsSecondOpinion() => $_clearField(15);

  /// Every review, oldest first. `review` above stays the most recent.
  @$pb.TagNumber(16)
  $pb.PbList<LabelReview> get reviews => $_getList(15);
}

/// How much two reviewers agree, and whether that is more than chance.
///
/// Raw agreement flatters an imbalanced task: two reviewers who both answer
/// "healthy" on a set that is ninety percent healthy agree ninety percent of the
/// time having demonstrated nothing.
class ReviewAgreement extends $pb.GeneratedMessage {
  factory ReviewAgreement({
    $core.int? compared,
    $core.double? rawAgreement,
    $core.double? kappa,
    $core.String? strength,
    $core.Iterable<LabelDisagreement>? disagreements,
  }) {
    final result = create();
    if (compared != null) result.compared = compared;
    if (rawAgreement != null) result.rawAgreement = rawAgreement;
    if (kappa != null) result.kappa = kappa;
    if (strength != null) result.strength = strength;
    if (disagreements != null) result.disagreements.addAll(disagreements);
    return result;
  }

  ReviewAgreement._();

  factory ReviewAgreement.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReviewAgreement.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReviewAgreement',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'compared')
    ..aD(2, _omitFieldNames ? '' : 'rawAgreement')
    ..aD(3, _omitFieldNames ? '' : 'kappa')
    ..aOS(4, _omitFieldNames ? '' : 'strength')
    ..pPM<LabelDisagreement>(5, _omitFieldNames ? '' : 'disagreements',
        subBuilder: LabelDisagreement.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReviewAgreement clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReviewAgreement copyWith(void Function(ReviewAgreement) updates) =>
      super.copyWith((message) => updates(message as ReviewAgreement))
          as ReviewAgreement;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReviewAgreement create() => ReviewAgreement._();
  @$core.override
  ReviewAgreement createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReviewAgreement getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReviewAgreement>(create);
  static ReviewAgreement? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get compared => $_getIZ(0);
  @$pb.TagNumber(1)
  set compared($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCompared() => $_has(0);
  @$pb.TagNumber(1)
  void clearCompared() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get rawAgreement => $_getN(1);
  @$pb.TagNumber(2)
  set rawAgreement($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRawAgreement() => $_has(1);
  @$pb.TagNumber(2)
  void clearRawAgreement() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get kappa => $_getN(2);
  @$pb.TagNumber(3)
  set kappa($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKappa() => $_has(2);
  @$pb.TagNumber(3)
  void clearKappa() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get strength => $_getSZ(3);
  @$pb.TagNumber(4)
  set strength($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStrength() => $_has(3);
  @$pb.TagNumber(4)
  void clearStrength() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<LabelDisagreement> get disagreements => $_getList(4);
}

class LabelDisagreement extends $pb.GeneratedMessage {
  factory LabelDisagreement({
    $core.String? first,
    $core.String? second,
    $core.int? count,
  }) {
    final result = create();
    if (first != null) result.first = first;
    if (second != null) result.second = second;
    if (count != null) result.count = count;
    return result;
  }

  LabelDisagreement._();

  factory LabelDisagreement.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LabelDisagreement.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LabelDisagreement',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'first')
    ..aOS(2, _omitFieldNames ? '' : 'second')
    ..aI(3, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelDisagreement clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelDisagreement copyWith(void Function(LabelDisagreement) updates) =>
      super.copyWith((message) => updates(message as LabelDisagreement))
          as LabelDisagreement;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LabelDisagreement create() => LabelDisagreement._();
  @$core.override
  LabelDisagreement createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LabelDisagreement getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LabelDisagreement>(create);
  static LabelDisagreement? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get first => $_getSZ(0);
  @$pb.TagNumber(1)
  set first($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFirst() => $_has(0);
  @$pb.TagNumber(1)
  void clearFirst() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get second => $_getSZ(1);
  @$pb.TagNumber(2)
  set second($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSecond() => $_has(1);
  @$pb.TagNumber(2)
  void clearSecond() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get count => $_getIZ(2);
  @$pb.TagNumber(3)
  set count($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearCount() => $_clearField(3);
}

class RequestSecondOpinionRequest extends $pb.GeneratedMessage {
  factory RequestSecondOpinionRequest({
    $core.String? task,
    $core.String? sampleId,
    $core.bool? wanted,
  }) {
    final result = create();
    if (task != null) result.task = task;
    if (sampleId != null) result.sampleId = sampleId;
    if (wanted != null) result.wanted = wanted;
    return result;
  }

  RequestSecondOpinionRequest._();

  factory RequestSecondOpinionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestSecondOpinionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestSecondOpinionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'task')
    ..aOS(2, _omitFieldNames ? '' : 'sampleId')
    ..aOB(3, _omitFieldNames ? '' : 'wanted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestSecondOpinionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestSecondOpinionRequest copyWith(
          void Function(RequestSecondOpinionRequest) updates) =>
      super.copyWith(
              (message) => updates(message as RequestSecondOpinionRequest))
          as RequestSecondOpinionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestSecondOpinionRequest create() =>
      RequestSecondOpinionRequest._();
  @$core.override
  RequestSecondOpinionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestSecondOpinionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestSecondOpinionRequest>(create);
  static RequestSecondOpinionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get task => $_getSZ(0);
  @$pb.TagNumber(1)
  set task($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sampleId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sampleId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSampleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSampleId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get wanted => $_getBF(2);
  @$pb.TagNumber(3)
  set wanted($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWanted() => $_has(2);
  @$pb.TagNumber(3)
  void clearWanted() => $_clearField(3);
}

class RequestSecondOpinionResponse extends $pb.GeneratedMessage {
  factory RequestSecondOpinionResponse({
    LabelReviewSample? sample,
  }) {
    final result = create();
    if (sample != null) result.sample = sample;
    return result;
  }

  RequestSecondOpinionResponse._();

  factory RequestSecondOpinionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestSecondOpinionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestSecondOpinionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOM<LabelReviewSample>(1, _omitFieldNames ? '' : 'sample',
        subBuilder: LabelReviewSample.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestSecondOpinionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestSecondOpinionResponse copyWith(
          void Function(RequestSecondOpinionResponse) updates) =>
      super.copyWith(
              (message) => updates(message as RequestSecondOpinionResponse))
          as RequestSecondOpinionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestSecondOpinionResponse create() =>
      RequestSecondOpinionResponse._();
  @$core.override
  RequestSecondOpinionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestSecondOpinionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestSecondOpinionResponse>(create);
  static RequestSecondOpinionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LabelReviewSample get sample => $_getN(0);
  @$pb.TagNumber(1)
  set sample(LabelReviewSample value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSample() => $_has(0);
  @$pb.TagNumber(1)
  void clearSample() => $_clearField(1);
  @$pb.TagNumber(1)
  LabelReviewSample ensureSample() => $_ensure(0);
}

class GetReviewAgreementRequest extends $pb.GeneratedMessage {
  factory GetReviewAgreementRequest({
    $core.String? task,
  }) {
    final result = create();
    if (task != null) result.task = task;
    return result;
  }

  GetReviewAgreementRequest._();

  factory GetReviewAgreementRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReviewAgreementRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReviewAgreementRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'task')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReviewAgreementRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReviewAgreementRequest copyWith(
          void Function(GetReviewAgreementRequest) updates) =>
      super.copyWith((message) => updates(message as GetReviewAgreementRequest))
          as GetReviewAgreementRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReviewAgreementRequest create() => GetReviewAgreementRequest._();
  @$core.override
  GetReviewAgreementRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReviewAgreementRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReviewAgreementRequest>(create);
  static GetReviewAgreementRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get task => $_getSZ(0);
  @$pb.TagNumber(1)
  set task($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
}

class GetReviewAgreementResponse extends $pb.GeneratedMessage {
  factory GetReviewAgreementResponse({
    ReviewAgreement? agreement,
  }) {
    final result = create();
    if (agreement != null) result.agreement = agreement;
    return result;
  }

  GetReviewAgreementResponse._();

  factory GetReviewAgreementResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReviewAgreementResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReviewAgreementResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOM<ReviewAgreement>(1, _omitFieldNames ? '' : 'agreement',
        subBuilder: ReviewAgreement.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReviewAgreementResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReviewAgreementResponse copyWith(
          void Function(GetReviewAgreementResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetReviewAgreementResponse))
          as GetReviewAgreementResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReviewAgreementResponse create() => GetReviewAgreementResponse._();
  @$core.override
  GetReviewAgreementResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReviewAgreementResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReviewAgreementResponse>(create);
  static GetReviewAgreementResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ReviewAgreement get agreement => $_getN(0);
  @$pb.TagNumber(1)
  set agreement(ReviewAgreement value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAgreement() => $_has(0);
  @$pb.TagNumber(1)
  void clearAgreement() => $_clearField(1);
  @$pb.TagNumber(1)
  ReviewAgreement ensureAgreement() => $_ensure(0);
}

class ListLabelReviewQueueRequest extends $pb.GeneratedMessage {
  factory ListLabelReviewQueueRequest({
    $core.String? task,
    $core.bool? includeReviewed,
    $core.double? maxConfidence,
    $core.String? provenance,
    $core.int? pageSize,
    $core.int? pageOffset,
    $core.bool? newestFirst,
    $core.bool? suspectOnly,
    $core.bool? secondOpinionOnly,
  }) {
    final result = create();
    if (task != null) result.task = task;
    if (includeReviewed != null) result.includeReviewed = includeReviewed;
    if (maxConfidence != null) result.maxConfidence = maxConfidence;
    if (provenance != null) result.provenance = provenance;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    if (newestFirst != null) result.newestFirst = newestFirst;
    if (suspectOnly != null) result.suspectOnly = suspectOnly;
    if (secondOpinionOnly != null) result.secondOpinionOnly = secondOpinionOnly;
    return result;
  }

  ListLabelReviewQueueRequest._();

  factory ListLabelReviewQueueRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListLabelReviewQueueRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListLabelReviewQueueRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'task')
    ..aOB(2, _omitFieldNames ? '' : 'includeReviewed')
    ..aD(3, _omitFieldNames ? '' : 'maxConfidence')
    ..aOS(4, _omitFieldNames ? '' : 'provenance')
    ..aI(5, _omitFieldNames ? '' : 'pageSize')
    ..aI(6, _omitFieldNames ? '' : 'pageOffset')
    ..aOB(7, _omitFieldNames ? '' : 'newestFirst')
    ..aOB(8, _omitFieldNames ? '' : 'suspectOnly')
    ..aOB(9, _omitFieldNames ? '' : 'secondOpinionOnly')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLabelReviewQueueRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLabelReviewQueueRequest copyWith(
          void Function(ListLabelReviewQueueRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ListLabelReviewQueueRequest))
          as ListLabelReviewQueueRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListLabelReviewQueueRequest create() =>
      ListLabelReviewQueueRequest._();
  @$core.override
  ListLabelReviewQueueRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListLabelReviewQueueRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListLabelReviewQueueRequest>(create);
  static ListLabelReviewQueueRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get task => $_getSZ(0);
  @$pb.TagNumber(1)
  set task($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get includeReviewed => $_getBF(1);
  @$pb.TagNumber(2)
  set includeReviewed($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIncludeReviewed() => $_has(1);
  @$pb.TagNumber(2)
  void clearIncludeReviewed() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get maxConfidence => $_getN(2);
  @$pb.TagNumber(3)
  set maxConfidence($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxConfidence() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxConfidence() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get provenance => $_getSZ(3);
  @$pb.TagNumber(4)
  set provenance($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProvenance() => $_has(3);
  @$pb.TagNumber(4)
  void clearProvenance() => $_clearField(4);

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

  @$pb.TagNumber(7)
  $core.bool get newestFirst => $_getBF(6);
  @$pb.TagNumber(7)
  set newestFirst($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNewestFirst() => $_has(6);
  @$pb.TagNumber(7)
  void clearNewestFirst() => $_clearField(7);

  /// Only labels a trained model contradicted, worst disagreement first. These
  /// are where the data is probably wrong rather than merely hard.
  @$pb.TagNumber(8)
  $core.bool get suspectOnly => $_getBF(7);
  @$pb.TagNumber(8)
  set suspectOnly($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSuspectOnly() => $_has(7);
  @$pb.TagNumber(8)
  void clearSuspectOnly() => $_clearField(8);

  /// Only samples waiting on another reviewer.
  @$pb.TagNumber(9)
  $core.bool get secondOpinionOnly => $_getBF(8);
  @$pb.TagNumber(9)
  set secondOpinionOnly($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSecondOpinionOnly() => $_has(8);
  @$pb.TagNumber(9)
  void clearSecondOpinionOnly() => $_clearField(9);
}

class ListLabelReviewQueueResponse extends $pb.GeneratedMessage {
  factory ListLabelReviewQueueResponse({
    $core.Iterable<LabelReviewSample>? samples,
    $core.int? totalCount,
    $core.int? unreviewedCount,
  }) {
    final result = create();
    if (samples != null) result.samples.addAll(samples);
    if (totalCount != null) result.totalCount = totalCount;
    if (unreviewedCount != null) result.unreviewedCount = unreviewedCount;
    return result;
  }

  ListLabelReviewQueueResponse._();

  factory ListLabelReviewQueueResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListLabelReviewQueueResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListLabelReviewQueueResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..pPM<LabelReviewSample>(1, _omitFieldNames ? '' : 'samples',
        subBuilder: LabelReviewSample.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..aI(3, _omitFieldNames ? '' : 'unreviewedCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLabelReviewQueueResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLabelReviewQueueResponse copyWith(
          void Function(ListLabelReviewQueueResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListLabelReviewQueueResponse))
          as ListLabelReviewQueueResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListLabelReviewQueueResponse create() =>
      ListLabelReviewQueueResponse._();
  @$core.override
  ListLabelReviewQueueResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListLabelReviewQueueResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListLabelReviewQueueResponse>(create);
  static ListLabelReviewQueueResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LabelReviewSample> get samples => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get unreviewedCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set unreviewedCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnreviewedCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnreviewedCount() => $_clearField(3);
}

class SubmitLabelReviewRequest extends $pb.GeneratedMessage {
  factory SubmitLabelReviewRequest({
    $core.String? task,
    $core.String? sampleId,
    LabelReviewDecision? decision,
    $core.String? correctedLabel,
    $core.String? notes,
  }) {
    final result = create();
    if (task != null) result.task = task;
    if (sampleId != null) result.sampleId = sampleId;
    if (decision != null) result.decision = decision;
    if (correctedLabel != null) result.correctedLabel = correctedLabel;
    if (notes != null) result.notes = notes;
    return result;
  }

  SubmitLabelReviewRequest._();

  factory SubmitLabelReviewRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubmitLabelReviewRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmitLabelReviewRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'task')
    ..aOS(2, _omitFieldNames ? '' : 'sampleId')
    ..aE<LabelReviewDecision>(3, _omitFieldNames ? '' : 'decision',
        enumValues: LabelReviewDecision.values)
    ..aOS(4, _omitFieldNames ? '' : 'correctedLabel')
    ..aOS(5, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitLabelReviewRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitLabelReviewRequest copyWith(
          void Function(SubmitLabelReviewRequest) updates) =>
      super.copyWith((message) => updates(message as SubmitLabelReviewRequest))
          as SubmitLabelReviewRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitLabelReviewRequest create() => SubmitLabelReviewRequest._();
  @$core.override
  SubmitLabelReviewRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubmitLabelReviewRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitLabelReviewRequest>(create);
  static SubmitLabelReviewRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get task => $_getSZ(0);
  @$pb.TagNumber(1)
  set task($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sampleId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sampleId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSampleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSampleId() => $_clearField(2);

  @$pb.TagNumber(3)
  LabelReviewDecision get decision => $_getN(2);
  @$pb.TagNumber(3)
  set decision(LabelReviewDecision value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDecision() => $_has(2);
  @$pb.TagNumber(3)
  void clearDecision() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get correctedLabel => $_getSZ(3);
  @$pb.TagNumber(4)
  set correctedLabel($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCorrectedLabel() => $_has(3);
  @$pb.TagNumber(4)
  void clearCorrectedLabel() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get notes => $_getSZ(4);
  @$pb.TagNumber(5)
  set notes($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNotes() => $_has(4);
  @$pb.TagNumber(5)
  void clearNotes() => $_clearField(5);
}

class SubmitLabelReviewResponse extends $pb.GeneratedMessage {
  factory SubmitLabelReviewResponse({
    LabelReviewSample? sample,
  }) {
    final result = create();
    if (sample != null) result.sample = sample;
    return result;
  }

  SubmitLabelReviewResponse._();

  factory SubmitLabelReviewResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubmitLabelReviewResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmitLabelReviewResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOM<LabelReviewSample>(1, _omitFieldNames ? '' : 'sample',
        subBuilder: LabelReviewSample.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitLabelReviewResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitLabelReviewResponse copyWith(
          void Function(SubmitLabelReviewResponse) updates) =>
      super.copyWith((message) => updates(message as SubmitLabelReviewResponse))
          as SubmitLabelReviewResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitLabelReviewResponse create() => SubmitLabelReviewResponse._();
  @$core.override
  SubmitLabelReviewResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubmitLabelReviewResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitLabelReviewResponse>(create);
  static SubmitLabelReviewResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LabelReviewSample get sample => $_getN(0);
  @$pb.TagNumber(1)
  set sample(LabelReviewSample value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSample() => $_has(0);
  @$pb.TagNumber(1)
  void clearSample() => $_clearField(1);
  @$pb.TagNumber(1)
  LabelReviewSample ensureSample() => $_ensure(0);
}

class GetLabelReviewImageRequest extends $pb.GeneratedMessage {
  factory GetLabelReviewImageRequest({
    $core.String? task,
    $core.String? sampleId,
  }) {
    final result = create();
    if (task != null) result.task = task;
    if (sampleId != null) result.sampleId = sampleId;
    return result;
  }

  GetLabelReviewImageRequest._();

  factory GetLabelReviewImageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLabelReviewImageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLabelReviewImageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'task')
    ..aOS(2, _omitFieldNames ? '' : 'sampleId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLabelReviewImageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLabelReviewImageRequest copyWith(
          void Function(GetLabelReviewImageRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetLabelReviewImageRequest))
          as GetLabelReviewImageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLabelReviewImageRequest create() => GetLabelReviewImageRequest._();
  @$core.override
  GetLabelReviewImageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLabelReviewImageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLabelReviewImageRequest>(create);
  static GetLabelReviewImageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get task => $_getSZ(0);
  @$pb.TagNumber(1)
  set task($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sampleId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sampleId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSampleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSampleId() => $_clearField(2);
}

class GetLabelReviewImageResponse extends $pb.GeneratedMessage {
  factory GetLabelReviewImageResponse({
    $core.List<$core.int>? imageBytes,
    $core.String? mimeType,
  }) {
    final result = create();
    if (imageBytes != null) result.imageBytes = imageBytes;
    if (mimeType != null) result.mimeType = mimeType;
    return result;
  }

  GetLabelReviewImageResponse._();

  factory GetLabelReviewImageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetLabelReviewImageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetLabelReviewImageResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.diagnosis.v1'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'imageBytes', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'mimeType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLabelReviewImageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetLabelReviewImageResponse copyWith(
          void Function(GetLabelReviewImageResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetLabelReviewImageResponse))
          as GetLabelReviewImageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetLabelReviewImageResponse create() =>
      GetLabelReviewImageResponse._();
  @$core.override
  GetLabelReviewImageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetLabelReviewImageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetLabelReviewImageResponse>(create);
  static GetLabelReviewImageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get imageBytes => $_getN(0);
  @$pb.TagNumber(1)
  set imageBytes($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasImageBytes() => $_has(0);
  @$pb.TagNumber(1)
  void clearImageBytes() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get mimeType => $_getSZ(1);
  @$pb.TagNumber(2)
  set mimeType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMimeType() => $_has(1);
  @$pb.TagNumber(2)
  void clearMimeType() => $_clearField(2);
}

class PlantDiagnosisServiceApi {
  final $pb.RpcClient _client;

  PlantDiagnosisServiceApi(this._client);

  /// Submit a new plant diagnosis request with images
  $async.Future<SubmitDiagnosisResponse> submitDiagnosis(
          $pb.ClientContext? ctx, SubmitDiagnosisRequest request) =>
      _client.invoke<SubmitDiagnosisResponse>(ctx, 'PlantDiagnosisService',
          'SubmitDiagnosis', request, SubmitDiagnosisResponse());

  /// Get a diagnosis by ID
  $async.Future<GetDiagnosisResponse> getDiagnosis(
          $pb.ClientContext? ctx, GetDiagnosisRequest request) =>
      _client.invoke<GetDiagnosisResponse>(ctx, 'PlantDiagnosisService',
          'GetDiagnosis', request, GetDiagnosisResponse());

  /// List diagnoses with filtering
  $async.Future<ListDiagnosesResponse> listDiagnoses(
          $pb.ClientContext? ctx, ListDiagnosesRequest request) =>
      _client.invoke<ListDiagnosesResponse>(ctx, 'PlantDiagnosisService',
          'ListDiagnoses', request, ListDiagnosesResponse());

  /// Get disease information by ID
  $async.Future<GetDiseaseInfoResponse> getDiseaseInfo(
          $pb.ClientContext? ctx, GetDiseaseInfoRequest request) =>
      _client.invoke<GetDiseaseInfoResponse>(ctx, 'PlantDiagnosisService',
          'GetDiseaseInfo', request, GetDiseaseInfoResponse());

  /// Get treatment plan for a diagnosis
  $async.Future<GetTreatmentPlanResponse> getTreatmentPlan(
          $pb.ClientContext? ctx, GetTreatmentPlanRequest request) =>
      _client.invoke<GetTreatmentPlanResponse>(ctx, 'PlantDiagnosisService',
          'GetTreatmentPlan', request, GetTreatmentPlanResponse());

  /// List all known diseases
  $async.Future<ListDiseasesResponse> listDiseases(
          $pb.ClientContext? ctx, ListDiseasesRequest request) =>
      _client.invoke<ListDiseasesResponse>(ctx, 'PlantDiagnosisService',
          'ListDiseases', request, ListDiseasesResponse());

  /// Identify plant species from images
  $async.Future<IdentifySpeciesResponse> identifySpecies(
          $pb.ClientContext? ctx, IdentifySpeciesRequest request) =>
      _client.invoke<IdentifySpeciesResponse>(ctx, 'PlantDiagnosisService',
          'IdentifySpecies', request, IdentifySpeciesResponse());

  /// Detect nutrient deficiencies from images
  $async.Future<DetectNutrientDeficiencyResponse> detectNutrientDeficiency(
          $pb.ClientContext? ctx, DetectNutrientDeficiencyRequest request) =>
      _client.invoke<DetectNutrientDeficiencyResponse>(
          ctx,
          'PlantDiagnosisService',
          'DetectNutrientDeficiency',
          request,
          DetectNutrientDeficiencyResponse());

  /// Detect pest damage from images
  $async.Future<DetectPestDamageResponse> detectPestDamage(
          $pb.ClientContext? ctx, DetectPestDamageRequest request) =>
      _client.invoke<DetectPestDamageResponse>(ctx, 'PlantDiagnosisService',
          'DetectPestDamage', request, DetectPestDamageResponse());

  /// List auto-labelled training samples awaiting human review (tenant-scoped)
  $async.Future<ListLabelReviewQueueResponse> listLabelReviewQueue(
          $pb.ClientContext? ctx, ListLabelReviewQueueRequest request) =>
      _client.invoke<ListLabelReviewQueueResponse>(ctx, 'PlantDiagnosisService',
          'ListLabelReviewQueue', request, ListLabelReviewQueueResponse());

  /// Confirm, correct, or reject an auto-label
  $async.Future<SubmitLabelReviewResponse> submitLabelReview(
          $pb.ClientContext? ctx, SubmitLabelReviewRequest request) =>
      _client.invoke<SubmitLabelReviewResponse>(ctx, 'PlantDiagnosisService',
          'SubmitLabelReview', request, SubmitLabelReviewResponse());

  /// Fetch the image behind a review-queue sample
  $async.Future<GetLabelReviewImageResponse> getLabelReviewImage(
          $pb.ClientContext? ctx, GetLabelReviewImageRequest request) =>
      _client.invoke<GetLabelReviewImageResponse>(ctx, 'PlantDiagnosisService',
          'GetLabelReviewImage', request, GetLabelReviewImageResponse());
  $async.Future<RequestSecondOpinionResponse> requestSecondOpinion(
          $pb.ClientContext? ctx, RequestSecondOpinionRequest request) =>
      _client.invoke<RequestSecondOpinionResponse>(ctx, 'PlantDiagnosisService',
          'RequestSecondOpinion', request, RequestSecondOpinionResponse());
  $async.Future<GetReviewAgreementResponse> getReviewAgreement(
          $pb.ClientContext? ctx, GetReviewAgreementRequest request) =>
      _client.invoke<GetReviewAgreementResponse>(ctx, 'PlantDiagnosisService',
          'GetReviewAgreement', request, GetReviewAgreementResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
