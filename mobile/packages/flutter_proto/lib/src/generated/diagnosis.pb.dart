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
  }) {
    final result = create();
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (imageType != null) result.imageType = imageType;
    if (mimeType != null) result.mimeType = mimeType;
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
  }) {
    final result = create();
    if (deficiencies != null) result.deficiencies.addAll(deficiencies);
    if (aiModelVersion != null) result.aiModelVersion = aiModelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
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
  }) {
    final result = create();
    if (pests != null) result.pests.addAll(pests);
    if (aiModelVersion != null) result.aiModelVersion = aiModelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
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
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
