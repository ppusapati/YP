// This is a generated file - do not edit.
//
// Generated from soil.proto.

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

import 'soil.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'soil.pbenum.dart';

class Location extends $pb.GeneratedMessage {
  factory Location({
    $core.double? latitude,
    $core.double? longitude,
  }) {
    final result = create();
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    return result;
  }

  Location._();

  factory Location.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Location.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Location',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'latitude')
    ..aD(2, _omitFieldNames ? '' : 'longitude')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Location clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Location copyWith(void Function(Location) updates) =>
      super.copyWith((message) => updates(message as Location)) as Location;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Location create() => Location._();
  @$core.override
  Location createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Location getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Location>(create);
  static Location? _defaultInstance;

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
}

class SoilSample extends $pb.GeneratedMessage {
  factory SoilSample({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? farmId,
    Location? sampleLocation,
    $core.double? sampleDepthCm,
    $0.Timestamp? collectionDate,
    $core.double? pH,
    $core.double? organicMatterPct,
    $core.double? nitrogenPpm,
    $core.double? phosphorusPpm,
    $core.double? potassiumPpm,
    $core.double? calciumPpm,
    $core.double? magnesiumPpm,
    $core.double? sulfurPpm,
    $core.double? ironPpm,
    $core.double? manganesePpm,
    $core.double? zincPpm,
    $core.double? copperPpm,
    $core.double? boronPpm,
    $core.double? moisturePct,
    SoilTexture? texture,
    $core.double? bulkDensity,
    $core.double? cationExchangeCapacity,
    $core.double? electricalConductivity,
    $core.String? collectedBy,
    $core.String? notes,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (sampleLocation != null) result.sampleLocation = sampleLocation;
    if (sampleDepthCm != null) result.sampleDepthCm = sampleDepthCm;
    if (collectionDate != null) result.collectionDate = collectionDate;
    if (pH != null) result.pH = pH;
    if (organicMatterPct != null) result.organicMatterPct = organicMatterPct;
    if (nitrogenPpm != null) result.nitrogenPpm = nitrogenPpm;
    if (phosphorusPpm != null) result.phosphorusPpm = phosphorusPpm;
    if (potassiumPpm != null) result.potassiumPpm = potassiumPpm;
    if (calciumPpm != null) result.calciumPpm = calciumPpm;
    if (magnesiumPpm != null) result.magnesiumPpm = magnesiumPpm;
    if (sulfurPpm != null) result.sulfurPpm = sulfurPpm;
    if (ironPpm != null) result.ironPpm = ironPpm;
    if (manganesePpm != null) result.manganesePpm = manganesePpm;
    if (zincPpm != null) result.zincPpm = zincPpm;
    if (copperPpm != null) result.copperPpm = copperPpm;
    if (boronPpm != null) result.boronPpm = boronPpm;
    if (moisturePct != null) result.moisturePct = moisturePct;
    if (texture != null) result.texture = texture;
    if (bulkDensity != null) result.bulkDensity = bulkDensity;
    if (cationExchangeCapacity != null)
      result.cationExchangeCapacity = cationExchangeCapacity;
    if (electricalConductivity != null)
      result.electricalConductivity = electricalConductivity;
    if (collectedBy != null) result.collectedBy = collectedBy;
    if (notes != null) result.notes = notes;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (version != null) result.version = version;
    return result;
  }

  SoilSample._();

  factory SoilSample.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SoilSample.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SoilSample',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..aOM<Location>(5, _omitFieldNames ? '' : 'sampleLocation',
        subBuilder: Location.create)
    ..aD(6, _omitFieldNames ? '' : 'sampleDepthCm')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'collectionDate',
        subBuilder: $0.Timestamp.create)
    ..aD(8, _omitFieldNames ? '' : 'pH', protoName: 'pH')
    ..aD(9, _omitFieldNames ? '' : 'organicMatterPct')
    ..aD(10, _omitFieldNames ? '' : 'nitrogenPpm')
    ..aD(11, _omitFieldNames ? '' : 'phosphorusPpm')
    ..aD(12, _omitFieldNames ? '' : 'potassiumPpm')
    ..aD(13, _omitFieldNames ? '' : 'calciumPpm')
    ..aD(14, _omitFieldNames ? '' : 'magnesiumPpm')
    ..aD(15, _omitFieldNames ? '' : 'sulfurPpm')
    ..aD(16, _omitFieldNames ? '' : 'ironPpm')
    ..aD(17, _omitFieldNames ? '' : 'manganesePpm')
    ..aD(18, _omitFieldNames ? '' : 'zincPpm')
    ..aD(19, _omitFieldNames ? '' : 'copperPpm')
    ..aD(20, _omitFieldNames ? '' : 'boronPpm')
    ..aD(21, _omitFieldNames ? '' : 'moisturePct')
    ..aE<SoilTexture>(22, _omitFieldNames ? '' : 'texture',
        enumValues: SoilTexture.values)
    ..aD(23, _omitFieldNames ? '' : 'bulkDensity')
    ..aD(24, _omitFieldNames ? '' : 'cationExchangeCapacity')
    ..aD(25, _omitFieldNames ? '' : 'electricalConductivity')
    ..aOS(26, _omitFieldNames ? '' : 'collectedBy')
    ..aOS(27, _omitFieldNames ? '' : 'notes')
    ..aOM<$0.Timestamp>(28, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(29, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aInt64(30, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilSample clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilSample copyWith(void Function(SoilSample) updates) =>
      super.copyWith((message) => updates(message as SoilSample)) as SoilSample;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SoilSample create() => SoilSample._();
  @$core.override
  SoilSample createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SoilSample getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SoilSample>(create);
  static SoilSample? _defaultInstance;

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
  Location get sampleLocation => $_getN(4);
  @$pb.TagNumber(5)
  set sampleLocation(Location value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSampleLocation() => $_has(4);
  @$pb.TagNumber(5)
  void clearSampleLocation() => $_clearField(5);
  @$pb.TagNumber(5)
  Location ensureSampleLocation() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.double get sampleDepthCm => $_getN(5);
  @$pb.TagNumber(6)
  set sampleDepthCm($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSampleDepthCm() => $_has(5);
  @$pb.TagNumber(6)
  void clearSampleDepthCm() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get collectionDate => $_getN(6);
  @$pb.TagNumber(7)
  set collectionDate($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCollectionDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearCollectionDate() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureCollectionDate() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.double get pH => $_getN(7);
  @$pb.TagNumber(8)
  set pH($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPH() => $_has(7);
  @$pb.TagNumber(8)
  void clearPH() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get organicMatterPct => $_getN(8);
  @$pb.TagNumber(9)
  set organicMatterPct($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOrganicMatterPct() => $_has(8);
  @$pb.TagNumber(9)
  void clearOrganicMatterPct() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get nitrogenPpm => $_getN(9);
  @$pb.TagNumber(10)
  set nitrogenPpm($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNitrogenPpm() => $_has(9);
  @$pb.TagNumber(10)
  void clearNitrogenPpm() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get phosphorusPpm => $_getN(10);
  @$pb.TagNumber(11)
  set phosphorusPpm($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPhosphorusPpm() => $_has(10);
  @$pb.TagNumber(11)
  void clearPhosphorusPpm() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get potassiumPpm => $_getN(11);
  @$pb.TagNumber(12)
  set potassiumPpm($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPotassiumPpm() => $_has(11);
  @$pb.TagNumber(12)
  void clearPotassiumPpm() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get calciumPpm => $_getN(12);
  @$pb.TagNumber(13)
  set calciumPpm($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCalciumPpm() => $_has(12);
  @$pb.TagNumber(13)
  void clearCalciumPpm() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get magnesiumPpm => $_getN(13);
  @$pb.TagNumber(14)
  set magnesiumPpm($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasMagnesiumPpm() => $_has(13);
  @$pb.TagNumber(14)
  void clearMagnesiumPpm() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get sulfurPpm => $_getN(14);
  @$pb.TagNumber(15)
  set sulfurPpm($core.double value) => $_setDouble(14, value);
  @$pb.TagNumber(15)
  $core.bool hasSulfurPpm() => $_has(14);
  @$pb.TagNumber(15)
  void clearSulfurPpm() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.double get ironPpm => $_getN(15);
  @$pb.TagNumber(16)
  set ironPpm($core.double value) => $_setDouble(15, value);
  @$pb.TagNumber(16)
  $core.bool hasIronPpm() => $_has(15);
  @$pb.TagNumber(16)
  void clearIronPpm() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.double get manganesePpm => $_getN(16);
  @$pb.TagNumber(17)
  set manganesePpm($core.double value) => $_setDouble(16, value);
  @$pb.TagNumber(17)
  $core.bool hasManganesePpm() => $_has(16);
  @$pb.TagNumber(17)
  void clearManganesePpm() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.double get zincPpm => $_getN(17);
  @$pb.TagNumber(18)
  set zincPpm($core.double value) => $_setDouble(17, value);
  @$pb.TagNumber(18)
  $core.bool hasZincPpm() => $_has(17);
  @$pb.TagNumber(18)
  void clearZincPpm() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.double get copperPpm => $_getN(18);
  @$pb.TagNumber(19)
  set copperPpm($core.double value) => $_setDouble(18, value);
  @$pb.TagNumber(19)
  $core.bool hasCopperPpm() => $_has(18);
  @$pb.TagNumber(19)
  void clearCopperPpm() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.double get boronPpm => $_getN(19);
  @$pb.TagNumber(20)
  set boronPpm($core.double value) => $_setDouble(19, value);
  @$pb.TagNumber(20)
  $core.bool hasBoronPpm() => $_has(19);
  @$pb.TagNumber(20)
  void clearBoronPpm() => $_clearField(20);

  @$pb.TagNumber(21)
  $core.double get moisturePct => $_getN(20);
  @$pb.TagNumber(21)
  set moisturePct($core.double value) => $_setDouble(20, value);
  @$pb.TagNumber(21)
  $core.bool hasMoisturePct() => $_has(20);
  @$pb.TagNumber(21)
  void clearMoisturePct() => $_clearField(21);

  @$pb.TagNumber(22)
  SoilTexture get texture => $_getN(21);
  @$pb.TagNumber(22)
  set texture(SoilTexture value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasTexture() => $_has(21);
  @$pb.TagNumber(22)
  void clearTexture() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.double get bulkDensity => $_getN(22);
  @$pb.TagNumber(23)
  set bulkDensity($core.double value) => $_setDouble(22, value);
  @$pb.TagNumber(23)
  $core.bool hasBulkDensity() => $_has(22);
  @$pb.TagNumber(23)
  void clearBulkDensity() => $_clearField(23);

  @$pb.TagNumber(24)
  $core.double get cationExchangeCapacity => $_getN(23);
  @$pb.TagNumber(24)
  set cationExchangeCapacity($core.double value) => $_setDouble(23, value);
  @$pb.TagNumber(24)
  $core.bool hasCationExchangeCapacity() => $_has(23);
  @$pb.TagNumber(24)
  void clearCationExchangeCapacity() => $_clearField(24);

  @$pb.TagNumber(25)
  $core.double get electricalConductivity => $_getN(24);
  @$pb.TagNumber(25)
  set electricalConductivity($core.double value) => $_setDouble(24, value);
  @$pb.TagNumber(25)
  $core.bool hasElectricalConductivity() => $_has(24);
  @$pb.TagNumber(25)
  void clearElectricalConductivity() => $_clearField(25);

  @$pb.TagNumber(26)
  $core.String get collectedBy => $_getSZ(25);
  @$pb.TagNumber(26)
  set collectedBy($core.String value) => $_setString(25, value);
  @$pb.TagNumber(26)
  $core.bool hasCollectedBy() => $_has(25);
  @$pb.TagNumber(26)
  void clearCollectedBy() => $_clearField(26);

  @$pb.TagNumber(27)
  $core.String get notes => $_getSZ(26);
  @$pb.TagNumber(27)
  set notes($core.String value) => $_setString(26, value);
  @$pb.TagNumber(27)
  $core.bool hasNotes() => $_has(26);
  @$pb.TagNumber(27)
  void clearNotes() => $_clearField(27);

  @$pb.TagNumber(28)
  $0.Timestamp get createdAt => $_getN(27);
  @$pb.TagNumber(28)
  set createdAt($0.Timestamp value) => $_setField(28, value);
  @$pb.TagNumber(28)
  $core.bool hasCreatedAt() => $_has(27);
  @$pb.TagNumber(28)
  void clearCreatedAt() => $_clearField(28);
  @$pb.TagNumber(28)
  $0.Timestamp ensureCreatedAt() => $_ensure(27);

  @$pb.TagNumber(29)
  $0.Timestamp get updatedAt => $_getN(28);
  @$pb.TagNumber(29)
  set updatedAt($0.Timestamp value) => $_setField(29, value);
  @$pb.TagNumber(29)
  $core.bool hasUpdatedAt() => $_has(28);
  @$pb.TagNumber(29)
  void clearUpdatedAt() => $_clearField(29);
  @$pb.TagNumber(29)
  $0.Timestamp ensureUpdatedAt() => $_ensure(28);

  @$pb.TagNumber(30)
  $fixnum.Int64 get version => $_getI64(29);
  @$pb.TagNumber(30)
  set version($fixnum.Int64 value) => $_setInt64(29, value);
  @$pb.TagNumber(30)
  $core.bool hasVersion() => $_has(29);
  @$pb.TagNumber(30)
  void clearVersion() => $_clearField(30);
}

class SoilAnalysis extends $pb.GeneratedMessage {
  factory SoilAnalysis({
    $core.String? id,
    $core.String? tenantId,
    $core.String? sampleId,
    $core.String? fieldId,
    $core.String? farmId,
    AnalysisStatus? status,
    $core.String? analysisType,
    $core.double? soilHealthScore,
    HealthCategory? healthCategory,
    $core.Iterable<$core.String>? recommendations,
    $core.String? analyzedBy,
    $0.Timestamp? analyzedAt,
    $core.String? summary,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (sampleId != null) result.sampleId = sampleId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (status != null) result.status = status;
    if (analysisType != null) result.analysisType = analysisType;
    if (soilHealthScore != null) result.soilHealthScore = soilHealthScore;
    if (healthCategory != null) result.healthCategory = healthCategory;
    if (recommendations != null) result.recommendations.addAll(recommendations);
    if (analyzedBy != null) result.analyzedBy = analyzedBy;
    if (analyzedAt != null) result.analyzedAt = analyzedAt;
    if (summary != null) result.summary = summary;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (version != null) result.version = version;
    return result;
  }

  SoilAnalysis._();

  factory SoilAnalysis.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SoilAnalysis.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SoilAnalysis',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'sampleId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'farmId')
    ..aE<AnalysisStatus>(6, _omitFieldNames ? '' : 'status',
        enumValues: AnalysisStatus.values)
    ..aOS(7, _omitFieldNames ? '' : 'analysisType')
    ..aD(8, _omitFieldNames ? '' : 'soilHealthScore')
    ..aE<HealthCategory>(9, _omitFieldNames ? '' : 'healthCategory',
        enumValues: HealthCategory.values)
    ..pPS(10, _omitFieldNames ? '' : 'recommendations')
    ..aOS(11, _omitFieldNames ? '' : 'analyzedBy')
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'analyzedAt',
        subBuilder: $0.Timestamp.create)
    ..aOS(13, _omitFieldNames ? '' : 'summary')
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aInt64(16, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilAnalysis clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilAnalysis copyWith(void Function(SoilAnalysis) updates) =>
      super.copyWith((message) => updates(message as SoilAnalysis))
          as SoilAnalysis;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SoilAnalysis create() => SoilAnalysis._();
  @$core.override
  SoilAnalysis createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SoilAnalysis getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SoilAnalysis>(create);
  static SoilAnalysis? _defaultInstance;

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
  $core.String get sampleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sampleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSampleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSampleId() => $_clearField(3);

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
  AnalysisStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(AnalysisStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get analysisType => $_getSZ(6);
  @$pb.TagNumber(7)
  set analysisType($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAnalysisType() => $_has(6);
  @$pb.TagNumber(7)
  void clearAnalysisType() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get soilHealthScore => $_getN(7);
  @$pb.TagNumber(8)
  set soilHealthScore($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSoilHealthScore() => $_has(7);
  @$pb.TagNumber(8)
  void clearSoilHealthScore() => $_clearField(8);

  @$pb.TagNumber(9)
  HealthCategory get healthCategory => $_getN(8);
  @$pb.TagNumber(9)
  set healthCategory(HealthCategory value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasHealthCategory() => $_has(8);
  @$pb.TagNumber(9)
  void clearHealthCategory() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get recommendations => $_getList(9);

  @$pb.TagNumber(11)
  $core.String get analyzedBy => $_getSZ(10);
  @$pb.TagNumber(11)
  set analyzedBy($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAnalyzedBy() => $_has(10);
  @$pb.TagNumber(11)
  void clearAnalyzedBy() => $_clearField(11);

  @$pb.TagNumber(12)
  $0.Timestamp get analyzedAt => $_getN(11);
  @$pb.TagNumber(12)
  set analyzedAt($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasAnalyzedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearAnalyzedAt() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureAnalyzedAt() => $_ensure(11);

  @$pb.TagNumber(13)
  $core.String get summary => $_getSZ(12);
  @$pb.TagNumber(13)
  set summary($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasSummary() => $_has(12);
  @$pb.TagNumber(13)
  void clearSummary() => $_clearField(13);

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

  @$pb.TagNumber(16)
  $fixnum.Int64 get version => $_getI64(15);
  @$pb.TagNumber(16)
  set version($fixnum.Int64 value) => $_setInt64(15, value);
  @$pb.TagNumber(16)
  $core.bool hasVersion() => $_has(15);
  @$pb.TagNumber(16)
  void clearVersion() => $_clearField(16);
}

class SoilMap extends $pb.GeneratedMessage {
  factory SoilMap({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? farmId,
    $core.String? mapType,
    $core.List<$core.int>? rasterData,
    $core.String? crs,
    $core.double? resolution,
    Location? bboxMin,
    Location? bboxMax,
    $core.String? generatedBy,
    $0.Timestamp? generatedAt,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (mapType != null) result.mapType = mapType;
    if (rasterData != null) result.rasterData = rasterData;
    if (crs != null) result.crs = crs;
    if (resolution != null) result.resolution = resolution;
    if (bboxMin != null) result.bboxMin = bboxMin;
    if (bboxMax != null) result.bboxMax = bboxMax;
    if (generatedBy != null) result.generatedBy = generatedBy;
    if (generatedAt != null) result.generatedAt = generatedAt;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (version != null) result.version = version;
    return result;
  }

  SoilMap._();

  factory SoilMap.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SoilMap.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SoilMap',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..aOS(5, _omitFieldNames ? '' : 'mapType')
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'rasterData', $pb.PbFieldType.OY)
    ..aOS(7, _omitFieldNames ? '' : 'crs')
    ..aD(8, _omitFieldNames ? '' : 'resolution')
    ..aOM<Location>(9, _omitFieldNames ? '' : 'bboxMin',
        subBuilder: Location.create)
    ..aOM<Location>(10, _omitFieldNames ? '' : 'bboxMax',
        subBuilder: Location.create)
    ..aOS(11, _omitFieldNames ? '' : 'generatedBy')
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'generatedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aInt64(15, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilMap clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilMap copyWith(void Function(SoilMap) updates) =>
      super.copyWith((message) => updates(message as SoilMap)) as SoilMap;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SoilMap create() => SoilMap._();
  @$core.override
  SoilMap createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SoilMap getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SoilMap>(create);
  static SoilMap? _defaultInstance;

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
  $core.String get mapType => $_getSZ(4);
  @$pb.TagNumber(5)
  set mapType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMapType() => $_has(4);
  @$pb.TagNumber(5)
  void clearMapType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get rasterData => $_getN(5);
  @$pb.TagNumber(6)
  set rasterData($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRasterData() => $_has(5);
  @$pb.TagNumber(6)
  void clearRasterData() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get crs => $_getSZ(6);
  @$pb.TagNumber(7)
  set crs($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCrs() => $_has(6);
  @$pb.TagNumber(7)
  void clearCrs() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get resolution => $_getN(7);
  @$pb.TagNumber(8)
  set resolution($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasResolution() => $_has(7);
  @$pb.TagNumber(8)
  void clearResolution() => $_clearField(8);

  @$pb.TagNumber(9)
  Location get bboxMin => $_getN(8);
  @$pb.TagNumber(9)
  set bboxMin(Location value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasBboxMin() => $_has(8);
  @$pb.TagNumber(9)
  void clearBboxMin() => $_clearField(9);
  @$pb.TagNumber(9)
  Location ensureBboxMin() => $_ensure(8);

  @$pb.TagNumber(10)
  Location get bboxMax => $_getN(9);
  @$pb.TagNumber(10)
  set bboxMax(Location value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasBboxMax() => $_has(9);
  @$pb.TagNumber(10)
  void clearBboxMax() => $_clearField(10);
  @$pb.TagNumber(10)
  Location ensureBboxMax() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.String get generatedBy => $_getSZ(10);
  @$pb.TagNumber(11)
  set generatedBy($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasGeneratedBy() => $_has(10);
  @$pb.TagNumber(11)
  void clearGeneratedBy() => $_clearField(11);

  @$pb.TagNumber(12)
  $0.Timestamp get generatedAt => $_getN(11);
  @$pb.TagNumber(12)
  set generatedAt($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasGeneratedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearGeneratedAt() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureGeneratedAt() => $_ensure(11);

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

  @$pb.TagNumber(15)
  $fixnum.Int64 get version => $_getI64(14);
  @$pb.TagNumber(15)
  set version($fixnum.Int64 value) => $_setInt64(14, value);
  @$pb.TagNumber(15)
  $core.bool hasVersion() => $_has(14);
  @$pb.TagNumber(15)
  void clearVersion() => $_clearField(15);
}

class SoilNutrient extends $pb.GeneratedMessage {
  factory SoilNutrient({
    $core.String? id,
    $core.String? tenantId,
    $core.String? sampleId,
    $core.String? nutrientName,
    $core.double? valuePpm,
    NutrientLevel? level,
    $core.double? optimalMin,
    $core.double? optimalMax,
    $core.String? unit,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (sampleId != null) result.sampleId = sampleId;
    if (nutrientName != null) result.nutrientName = nutrientName;
    if (valuePpm != null) result.valuePpm = valuePpm;
    if (level != null) result.level = level;
    if (optimalMin != null) result.optimalMin = optimalMin;
    if (optimalMax != null) result.optimalMax = optimalMax;
    if (unit != null) result.unit = unit;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  SoilNutrient._();

  factory SoilNutrient.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SoilNutrient.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SoilNutrient',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'sampleId')
    ..aOS(4, _omitFieldNames ? '' : 'nutrientName')
    ..aD(5, _omitFieldNames ? '' : 'valuePpm')
    ..aE<NutrientLevel>(6, _omitFieldNames ? '' : 'level',
        enumValues: NutrientLevel.values)
    ..aD(7, _omitFieldNames ? '' : 'optimalMin')
    ..aD(8, _omitFieldNames ? '' : 'optimalMax')
    ..aOS(9, _omitFieldNames ? '' : 'unit')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilNutrient clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilNutrient copyWith(void Function(SoilNutrient) updates) =>
      super.copyWith((message) => updates(message as SoilNutrient))
          as SoilNutrient;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SoilNutrient create() => SoilNutrient._();
  @$core.override
  SoilNutrient createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SoilNutrient getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SoilNutrient>(create);
  static SoilNutrient? _defaultInstance;

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
  $core.String get sampleId => $_getSZ(2);
  @$pb.TagNumber(3)
  set sampleId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSampleId() => $_has(2);
  @$pb.TagNumber(3)
  void clearSampleId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get nutrientName => $_getSZ(3);
  @$pb.TagNumber(4)
  set nutrientName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNutrientName() => $_has(3);
  @$pb.TagNumber(4)
  void clearNutrientName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get valuePpm => $_getN(4);
  @$pb.TagNumber(5)
  set valuePpm($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasValuePpm() => $_has(4);
  @$pb.TagNumber(5)
  void clearValuePpm() => $_clearField(5);

  @$pb.TagNumber(6)
  NutrientLevel get level => $_getN(5);
  @$pb.TagNumber(6)
  set level(NutrientLevel value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasLevel() => $_has(5);
  @$pb.TagNumber(6)
  void clearLevel() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get optimalMin => $_getN(6);
  @$pb.TagNumber(7)
  set optimalMin($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOptimalMin() => $_has(6);
  @$pb.TagNumber(7)
  void clearOptimalMin() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get optimalMax => $_getN(7);
  @$pb.TagNumber(8)
  set optimalMax($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasOptimalMax() => $_has(7);
  @$pb.TagNumber(8)
  void clearOptimalMax() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get unit => $_getSZ(8);
  @$pb.TagNumber(9)
  set unit($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasUnit() => $_has(8);
  @$pb.TagNumber(9)
  void clearUnit() => $_clearField(9);

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

class SoilHealthScore extends $pb.GeneratedMessage {
  factory SoilHealthScore({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? farmId,
    $core.double? overallScore,
    HealthCategory? category,
    $core.double? physicalScore,
    $core.double? chemicalScore,
    $core.double? biologicalScore,
    $core.Iterable<$core.String>? recommendations,
    $core.Iterable<NutrientDeficiency>? deficiencies,
    $0.Timestamp? assessedAt,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (overallScore != null) result.overallScore = overallScore;
    if (category != null) result.category = category;
    if (physicalScore != null) result.physicalScore = physicalScore;
    if (chemicalScore != null) result.chemicalScore = chemicalScore;
    if (biologicalScore != null) result.biologicalScore = biologicalScore;
    if (recommendations != null) result.recommendations.addAll(recommendations);
    if (deficiencies != null) result.deficiencies.addAll(deficiencies);
    if (assessedAt != null) result.assessedAt = assessedAt;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (version != null) result.version = version;
    return result;
  }

  SoilHealthScore._();

  factory SoilHealthScore.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SoilHealthScore.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SoilHealthScore',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..aD(5, _omitFieldNames ? '' : 'overallScore')
    ..aE<HealthCategory>(6, _omitFieldNames ? '' : 'category',
        enumValues: HealthCategory.values)
    ..aD(7, _omitFieldNames ? '' : 'physicalScore')
    ..aD(8, _omitFieldNames ? '' : 'chemicalScore')
    ..aD(9, _omitFieldNames ? '' : 'biologicalScore')
    ..pPS(10, _omitFieldNames ? '' : 'recommendations')
    ..pPM<NutrientDeficiency>(11, _omitFieldNames ? '' : 'deficiencies',
        subBuilder: NutrientDeficiency.create)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'assessedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aInt64(15, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilHealthScore clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilHealthScore copyWith(void Function(SoilHealthScore) updates) =>
      super.copyWith((message) => updates(message as SoilHealthScore))
          as SoilHealthScore;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SoilHealthScore create() => SoilHealthScore._();
  @$core.override
  SoilHealthScore createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SoilHealthScore getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SoilHealthScore>(create);
  static SoilHealthScore? _defaultInstance;

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
  $core.double get overallScore => $_getN(4);
  @$pb.TagNumber(5)
  set overallScore($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOverallScore() => $_has(4);
  @$pb.TagNumber(5)
  void clearOverallScore() => $_clearField(5);

  @$pb.TagNumber(6)
  HealthCategory get category => $_getN(5);
  @$pb.TagNumber(6)
  set category(HealthCategory value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCategory() => $_has(5);
  @$pb.TagNumber(6)
  void clearCategory() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get physicalScore => $_getN(6);
  @$pb.TagNumber(7)
  set physicalScore($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPhysicalScore() => $_has(6);
  @$pb.TagNumber(7)
  void clearPhysicalScore() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get chemicalScore => $_getN(7);
  @$pb.TagNumber(8)
  set chemicalScore($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasChemicalScore() => $_has(7);
  @$pb.TagNumber(8)
  void clearChemicalScore() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get biologicalScore => $_getN(8);
  @$pb.TagNumber(9)
  set biologicalScore($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasBiologicalScore() => $_has(8);
  @$pb.TagNumber(9)
  void clearBiologicalScore() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get recommendations => $_getList(9);

  @$pb.TagNumber(11)
  $pb.PbList<NutrientDeficiency> get deficiencies => $_getList(10);

  @$pb.TagNumber(12)
  $0.Timestamp get assessedAt => $_getN(11);
  @$pb.TagNumber(12)
  set assessedAt($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasAssessedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearAssessedAt() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureAssessedAt() => $_ensure(11);

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

  @$pb.TagNumber(15)
  $fixnum.Int64 get version => $_getI64(14);
  @$pb.TagNumber(15)
  set version($fixnum.Int64 value) => $_setInt64(14, value);
  @$pb.TagNumber(15)
  $core.bool hasVersion() => $_has(14);
  @$pb.TagNumber(15)
  void clearVersion() => $_clearField(15);
}

class NutrientDeficiency extends $pb.GeneratedMessage {
  factory NutrientDeficiency({
    $core.String? nutrientName,
    $core.double? currentValue,
    $core.double? optimalValue,
    NutrientLevel? level,
    $core.String? recommendation,
  }) {
    final result = create();
    if (nutrientName != null) result.nutrientName = nutrientName;
    if (currentValue != null) result.currentValue = currentValue;
    if (optimalValue != null) result.optimalValue = optimalValue;
    if (level != null) result.level = level;
    if (recommendation != null) result.recommendation = recommendation;
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
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nutrientName')
    ..aD(2, _omitFieldNames ? '' : 'currentValue')
    ..aD(3, _omitFieldNames ? '' : 'optimalValue')
    ..aE<NutrientLevel>(4, _omitFieldNames ? '' : 'level',
        enumValues: NutrientLevel.values)
    ..aOS(5, _omitFieldNames ? '' : 'recommendation')
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
  $core.String get nutrientName => $_getSZ(0);
  @$pb.TagNumber(1)
  set nutrientName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNutrientName() => $_has(0);
  @$pb.TagNumber(1)
  void clearNutrientName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get currentValue => $_getN(1);
  @$pb.TagNumber(2)
  set currentValue($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCurrentValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearCurrentValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get optimalValue => $_getN(2);
  @$pb.TagNumber(3)
  set optimalValue($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOptimalValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearOptimalValue() => $_clearField(3);

  @$pb.TagNumber(4)
  NutrientLevel get level => $_getN(3);
  @$pb.TagNumber(4)
  set level(NutrientLevel value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLevel() => $_has(3);
  @$pb.TagNumber(4)
  void clearLevel() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get recommendation => $_getSZ(4);
  @$pb.TagNumber(5)
  set recommendation($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRecommendation() => $_has(4);
  @$pb.TagNumber(5)
  void clearRecommendation() => $_clearField(5);
}

class SoilReport extends $pb.GeneratedMessage {
  factory SoilReport({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? farmId,
    SoilSample? sample,
    SoilAnalysis? analysis,
    SoilHealthScore? healthScore,
    $core.Iterable<SoilNutrient>? nutrients,
    $core.Iterable<$core.String>? recommendations,
    $0.Timestamp? generatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (sample != null) result.sample = sample;
    if (analysis != null) result.analysis = analysis;
    if (healthScore != null) result.healthScore = healthScore;
    if (nutrients != null) result.nutrients.addAll(nutrients);
    if (recommendations != null) result.recommendations.addAll(recommendations);
    if (generatedAt != null) result.generatedAt = generatedAt;
    return result;
  }

  SoilReport._();

  factory SoilReport.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SoilReport.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SoilReport',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..aOM<SoilSample>(5, _omitFieldNames ? '' : 'sample',
        subBuilder: SoilSample.create)
    ..aOM<SoilAnalysis>(6, _omitFieldNames ? '' : 'analysis',
        subBuilder: SoilAnalysis.create)
    ..aOM<SoilHealthScore>(7, _omitFieldNames ? '' : 'healthScore',
        subBuilder: SoilHealthScore.create)
    ..pPM<SoilNutrient>(8, _omitFieldNames ? '' : 'nutrients',
        subBuilder: SoilNutrient.create)
    ..pPS(9, _omitFieldNames ? '' : 'recommendations')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'generatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilReport clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilReport copyWith(void Function(SoilReport) updates) =>
      super.copyWith((message) => updates(message as SoilReport)) as SoilReport;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SoilReport create() => SoilReport._();
  @$core.override
  SoilReport createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SoilReport getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SoilReport>(create);
  static SoilReport? _defaultInstance;

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
  SoilSample get sample => $_getN(4);
  @$pb.TagNumber(5)
  set sample(SoilSample value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSample() => $_has(4);
  @$pb.TagNumber(5)
  void clearSample() => $_clearField(5);
  @$pb.TagNumber(5)
  SoilSample ensureSample() => $_ensure(4);

  @$pb.TagNumber(6)
  SoilAnalysis get analysis => $_getN(5);
  @$pb.TagNumber(6)
  set analysis(SoilAnalysis value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAnalysis() => $_has(5);
  @$pb.TagNumber(6)
  void clearAnalysis() => $_clearField(6);
  @$pb.TagNumber(6)
  SoilAnalysis ensureAnalysis() => $_ensure(5);

  @$pb.TagNumber(7)
  SoilHealthScore get healthScore => $_getN(6);
  @$pb.TagNumber(7)
  set healthScore(SoilHealthScore value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasHealthScore() => $_has(6);
  @$pb.TagNumber(7)
  void clearHealthScore() => $_clearField(7);
  @$pb.TagNumber(7)
  SoilHealthScore ensureHealthScore() => $_ensure(6);

  @$pb.TagNumber(8)
  $pb.PbList<SoilNutrient> get nutrients => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get recommendations => $_getList(8);

  @$pb.TagNumber(10)
  $0.Timestamp get generatedAt => $_getN(9);
  @$pb.TagNumber(10)
  set generatedAt($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasGeneratedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearGeneratedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureGeneratedAt() => $_ensure(9);
}

class CreateSoilSampleRequest extends $pb.GeneratedMessage {
  factory CreateSoilSampleRequest({
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? farmId,
    Location? sampleLocation,
    $core.double? sampleDepthCm,
    $0.Timestamp? collectionDate,
    $core.double? pH,
    $core.double? organicMatterPct,
    $core.double? nitrogenPpm,
    $core.double? phosphorusPpm,
    $core.double? potassiumPpm,
    $core.double? calciumPpm,
    $core.double? magnesiumPpm,
    $core.double? sulfurPpm,
    $core.double? ironPpm,
    $core.double? manganesePpm,
    $core.double? zincPpm,
    $core.double? copperPpm,
    $core.double? boronPpm,
    $core.double? moisturePct,
    SoilTexture? texture,
    $core.double? bulkDensity,
    $core.double? cationExchangeCapacity,
    $core.double? electricalConductivity,
    $core.String? notes,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (sampleLocation != null) result.sampleLocation = sampleLocation;
    if (sampleDepthCm != null) result.sampleDepthCm = sampleDepthCm;
    if (collectionDate != null) result.collectionDate = collectionDate;
    if (pH != null) result.pH = pH;
    if (organicMatterPct != null) result.organicMatterPct = organicMatterPct;
    if (nitrogenPpm != null) result.nitrogenPpm = nitrogenPpm;
    if (phosphorusPpm != null) result.phosphorusPpm = phosphorusPpm;
    if (potassiumPpm != null) result.potassiumPpm = potassiumPpm;
    if (calciumPpm != null) result.calciumPpm = calciumPpm;
    if (magnesiumPpm != null) result.magnesiumPpm = magnesiumPpm;
    if (sulfurPpm != null) result.sulfurPpm = sulfurPpm;
    if (ironPpm != null) result.ironPpm = ironPpm;
    if (manganesePpm != null) result.manganesePpm = manganesePpm;
    if (zincPpm != null) result.zincPpm = zincPpm;
    if (copperPpm != null) result.copperPpm = copperPpm;
    if (boronPpm != null) result.boronPpm = boronPpm;
    if (moisturePct != null) result.moisturePct = moisturePct;
    if (texture != null) result.texture = texture;
    if (bulkDensity != null) result.bulkDensity = bulkDensity;
    if (cationExchangeCapacity != null)
      result.cationExchangeCapacity = cationExchangeCapacity;
    if (electricalConductivity != null)
      result.electricalConductivity = electricalConductivity;
    if (notes != null) result.notes = notes;
    return result;
  }

  CreateSoilSampleRequest._();

  factory CreateSoilSampleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateSoilSampleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateSoilSampleRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOM<Location>(4, _omitFieldNames ? '' : 'sampleLocation',
        subBuilder: Location.create)
    ..aD(5, _omitFieldNames ? '' : 'sampleDepthCm')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'collectionDate',
        subBuilder: $0.Timestamp.create)
    ..aD(7, _omitFieldNames ? '' : 'pH', protoName: 'pH')
    ..aD(8, _omitFieldNames ? '' : 'organicMatterPct')
    ..aD(9, _omitFieldNames ? '' : 'nitrogenPpm')
    ..aD(10, _omitFieldNames ? '' : 'phosphorusPpm')
    ..aD(11, _omitFieldNames ? '' : 'potassiumPpm')
    ..aD(12, _omitFieldNames ? '' : 'calciumPpm')
    ..aD(13, _omitFieldNames ? '' : 'magnesiumPpm')
    ..aD(14, _omitFieldNames ? '' : 'sulfurPpm')
    ..aD(15, _omitFieldNames ? '' : 'ironPpm')
    ..aD(16, _omitFieldNames ? '' : 'manganesePpm')
    ..aD(17, _omitFieldNames ? '' : 'zincPpm')
    ..aD(18, _omitFieldNames ? '' : 'copperPpm')
    ..aD(19, _omitFieldNames ? '' : 'boronPpm')
    ..aD(20, _omitFieldNames ? '' : 'moisturePct')
    ..aE<SoilTexture>(21, _omitFieldNames ? '' : 'texture',
        enumValues: SoilTexture.values)
    ..aD(22, _omitFieldNames ? '' : 'bulkDensity')
    ..aD(23, _omitFieldNames ? '' : 'cationExchangeCapacity')
    ..aD(24, _omitFieldNames ? '' : 'electricalConductivity')
    ..aOS(25, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSoilSampleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSoilSampleRequest copyWith(
          void Function(CreateSoilSampleRequest) updates) =>
      super.copyWith((message) => updates(message as CreateSoilSampleRequest))
          as CreateSoilSampleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSoilSampleRequest create() => CreateSoilSampleRequest._();
  @$core.override
  CreateSoilSampleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateSoilSampleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSoilSampleRequest>(create);
  static CreateSoilSampleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmId() => $_clearField(3);

  @$pb.TagNumber(4)
  Location get sampleLocation => $_getN(3);
  @$pb.TagNumber(4)
  set sampleLocation(Location value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSampleLocation() => $_has(3);
  @$pb.TagNumber(4)
  void clearSampleLocation() => $_clearField(4);
  @$pb.TagNumber(4)
  Location ensureSampleLocation() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.double get sampleDepthCm => $_getN(4);
  @$pb.TagNumber(5)
  set sampleDepthCm($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSampleDepthCm() => $_has(4);
  @$pb.TagNumber(5)
  void clearSampleDepthCm() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get collectionDate => $_getN(5);
  @$pb.TagNumber(6)
  set collectionDate($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCollectionDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearCollectionDate() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureCollectionDate() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.double get pH => $_getN(6);
  @$pb.TagNumber(7)
  set pH($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPH() => $_has(6);
  @$pb.TagNumber(7)
  void clearPH() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get organicMatterPct => $_getN(7);
  @$pb.TagNumber(8)
  set organicMatterPct($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasOrganicMatterPct() => $_has(7);
  @$pb.TagNumber(8)
  void clearOrganicMatterPct() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get nitrogenPpm => $_getN(8);
  @$pb.TagNumber(9)
  set nitrogenPpm($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasNitrogenPpm() => $_has(8);
  @$pb.TagNumber(9)
  void clearNitrogenPpm() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get phosphorusPpm => $_getN(9);
  @$pb.TagNumber(10)
  set phosphorusPpm($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasPhosphorusPpm() => $_has(9);
  @$pb.TagNumber(10)
  void clearPhosphorusPpm() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get potassiumPpm => $_getN(10);
  @$pb.TagNumber(11)
  set potassiumPpm($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPotassiumPpm() => $_has(10);
  @$pb.TagNumber(11)
  void clearPotassiumPpm() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get calciumPpm => $_getN(11);
  @$pb.TagNumber(12)
  set calciumPpm($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasCalciumPpm() => $_has(11);
  @$pb.TagNumber(12)
  void clearCalciumPpm() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get magnesiumPpm => $_getN(12);
  @$pb.TagNumber(13)
  set magnesiumPpm($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasMagnesiumPpm() => $_has(12);
  @$pb.TagNumber(13)
  void clearMagnesiumPpm() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.double get sulfurPpm => $_getN(13);
  @$pb.TagNumber(14)
  set sulfurPpm($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasSulfurPpm() => $_has(13);
  @$pb.TagNumber(14)
  void clearSulfurPpm() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get ironPpm => $_getN(14);
  @$pb.TagNumber(15)
  set ironPpm($core.double value) => $_setDouble(14, value);
  @$pb.TagNumber(15)
  $core.bool hasIronPpm() => $_has(14);
  @$pb.TagNumber(15)
  void clearIronPpm() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.double get manganesePpm => $_getN(15);
  @$pb.TagNumber(16)
  set manganesePpm($core.double value) => $_setDouble(15, value);
  @$pb.TagNumber(16)
  $core.bool hasManganesePpm() => $_has(15);
  @$pb.TagNumber(16)
  void clearManganesePpm() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.double get zincPpm => $_getN(16);
  @$pb.TagNumber(17)
  set zincPpm($core.double value) => $_setDouble(16, value);
  @$pb.TagNumber(17)
  $core.bool hasZincPpm() => $_has(16);
  @$pb.TagNumber(17)
  void clearZincPpm() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.double get copperPpm => $_getN(17);
  @$pb.TagNumber(18)
  set copperPpm($core.double value) => $_setDouble(17, value);
  @$pb.TagNumber(18)
  $core.bool hasCopperPpm() => $_has(17);
  @$pb.TagNumber(18)
  void clearCopperPpm() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.double get boronPpm => $_getN(18);
  @$pb.TagNumber(19)
  set boronPpm($core.double value) => $_setDouble(18, value);
  @$pb.TagNumber(19)
  $core.bool hasBoronPpm() => $_has(18);
  @$pb.TagNumber(19)
  void clearBoronPpm() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.double get moisturePct => $_getN(19);
  @$pb.TagNumber(20)
  set moisturePct($core.double value) => $_setDouble(19, value);
  @$pb.TagNumber(20)
  $core.bool hasMoisturePct() => $_has(19);
  @$pb.TagNumber(20)
  void clearMoisturePct() => $_clearField(20);

  @$pb.TagNumber(21)
  SoilTexture get texture => $_getN(20);
  @$pb.TagNumber(21)
  set texture(SoilTexture value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasTexture() => $_has(20);
  @$pb.TagNumber(21)
  void clearTexture() => $_clearField(21);

  @$pb.TagNumber(22)
  $core.double get bulkDensity => $_getN(21);
  @$pb.TagNumber(22)
  set bulkDensity($core.double value) => $_setDouble(21, value);
  @$pb.TagNumber(22)
  $core.bool hasBulkDensity() => $_has(21);
  @$pb.TagNumber(22)
  void clearBulkDensity() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.double get cationExchangeCapacity => $_getN(22);
  @$pb.TagNumber(23)
  set cationExchangeCapacity($core.double value) => $_setDouble(22, value);
  @$pb.TagNumber(23)
  $core.bool hasCationExchangeCapacity() => $_has(22);
  @$pb.TagNumber(23)
  void clearCationExchangeCapacity() => $_clearField(23);

  @$pb.TagNumber(24)
  $core.double get electricalConductivity => $_getN(23);
  @$pb.TagNumber(24)
  set electricalConductivity($core.double value) => $_setDouble(23, value);
  @$pb.TagNumber(24)
  $core.bool hasElectricalConductivity() => $_has(23);
  @$pb.TagNumber(24)
  void clearElectricalConductivity() => $_clearField(24);

  @$pb.TagNumber(25)
  $core.String get notes => $_getSZ(24);
  @$pb.TagNumber(25)
  set notes($core.String value) => $_setString(24, value);
  @$pb.TagNumber(25)
  $core.bool hasNotes() => $_has(24);
  @$pb.TagNumber(25)
  void clearNotes() => $_clearField(25);
}

class CreateSoilSampleResponse extends $pb.GeneratedMessage {
  factory CreateSoilSampleResponse({
    SoilSample? sample,
  }) {
    final result = create();
    if (sample != null) result.sample = sample;
    return result;
  }

  CreateSoilSampleResponse._();

  factory CreateSoilSampleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateSoilSampleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateSoilSampleResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOM<SoilSample>(1, _omitFieldNames ? '' : 'sample',
        subBuilder: SoilSample.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSoilSampleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSoilSampleResponse copyWith(
          void Function(CreateSoilSampleResponse) updates) =>
      super.copyWith((message) => updates(message as CreateSoilSampleResponse))
          as CreateSoilSampleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSoilSampleResponse create() => CreateSoilSampleResponse._();
  @$core.override
  CreateSoilSampleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateSoilSampleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSoilSampleResponse>(create);
  static CreateSoilSampleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SoilSample get sample => $_getN(0);
  @$pb.TagNumber(1)
  set sample(SoilSample value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSample() => $_has(0);
  @$pb.TagNumber(1)
  void clearSample() => $_clearField(1);
  @$pb.TagNumber(1)
  SoilSample ensureSample() => $_ensure(0);
}

class GetSoilSampleRequest extends $pb.GeneratedMessage {
  factory GetSoilSampleRequest({
    $core.String? id,
    $core.String? tenantId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    return result;
  }

  GetSoilSampleRequest._();

  factory GetSoilSampleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSoilSampleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSoilSampleRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSoilSampleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSoilSampleRequest copyWith(void Function(GetSoilSampleRequest) updates) =>
      super.copyWith((message) => updates(message as GetSoilSampleRequest))
          as GetSoilSampleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSoilSampleRequest create() => GetSoilSampleRequest._();
  @$core.override
  GetSoilSampleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSoilSampleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSoilSampleRequest>(create);
  static GetSoilSampleRequest? _defaultInstance;

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

class GetSoilSampleResponse extends $pb.GeneratedMessage {
  factory GetSoilSampleResponse({
    SoilSample? sample,
  }) {
    final result = create();
    if (sample != null) result.sample = sample;
    return result;
  }

  GetSoilSampleResponse._();

  factory GetSoilSampleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSoilSampleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSoilSampleResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOM<SoilSample>(1, _omitFieldNames ? '' : 'sample',
        subBuilder: SoilSample.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSoilSampleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSoilSampleResponse copyWith(
          void Function(GetSoilSampleResponse) updates) =>
      super.copyWith((message) => updates(message as GetSoilSampleResponse))
          as GetSoilSampleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSoilSampleResponse create() => GetSoilSampleResponse._();
  @$core.override
  GetSoilSampleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSoilSampleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSoilSampleResponse>(create);
  static GetSoilSampleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SoilSample get sample => $_getN(0);
  @$pb.TagNumber(1)
  set sample(SoilSample value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSample() => $_has(0);
  @$pb.TagNumber(1)
  void clearSample() => $_clearField(1);
  @$pb.TagNumber(1)
  SoilSample ensureSample() => $_ensure(0);
}

class ListSoilSamplesRequest extends $pb.GeneratedMessage {
  factory ListSoilSamplesRequest({
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? farmId,
    $core.int? pageSize,
    $core.int? pageOffset,
    $core.Iterable<$core.String>? sort,
    $1.FieldMask? fields,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    if (sort != null) result.sort.addAll(sort);
    if (fields != null) result.fields = fields;
    return result;
  }

  ListSoilSamplesRequest._();

  factory ListSoilSamplesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSoilSamplesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSoilSamplesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aI(5, _omitFieldNames ? '' : 'pageOffset')
    ..pPS(6, _omitFieldNames ? '' : 'sort')
    ..aOM<$1.FieldMask>(7, _omitFieldNames ? '' : 'fields',
        subBuilder: $1.FieldMask.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSoilSamplesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSoilSamplesRequest copyWith(
          void Function(ListSoilSamplesRequest) updates) =>
      super.copyWith((message) => updates(message as ListSoilSamplesRequest))
          as ListSoilSamplesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSoilSamplesRequest create() => ListSoilSamplesRequest._();
  @$core.override
  ListSoilSamplesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSoilSamplesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSoilSamplesRequest>(create);
  static ListSoilSamplesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmId() => $_clearField(3);

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
  $1.FieldMask get fields => $_getN(6);
  @$pb.TagNumber(7)
  set fields($1.FieldMask value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasFields() => $_has(6);
  @$pb.TagNumber(7)
  void clearFields() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.FieldMask ensureFields() => $_ensure(6);
}

class ListSoilSamplesResponse extends $pb.GeneratedMessage {
  factory ListSoilSamplesResponse({
    $core.Iterable<SoilSample>? samples,
    $core.int? totalCount,
    $core.bool? hasNext,
  }) {
    final result = create();
    if (samples != null) result.samples.addAll(samples);
    if (totalCount != null) result.totalCount = totalCount;
    if (hasNext != null) result.hasNext = hasNext;
    return result;
  }

  ListSoilSamplesResponse._();

  factory ListSoilSamplesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSoilSamplesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSoilSamplesResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..pPM<SoilSample>(1, _omitFieldNames ? '' : 'samples',
        subBuilder: SoilSample.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..aOB(3, _omitFieldNames ? '' : 'hasNext')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSoilSamplesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSoilSamplesResponse copyWith(
          void Function(ListSoilSamplesResponse) updates) =>
      super.copyWith((message) => updates(message as ListSoilSamplesResponse))
          as ListSoilSamplesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSoilSamplesResponse create() => ListSoilSamplesResponse._();
  @$core.override
  ListSoilSamplesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSoilSamplesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSoilSamplesResponse>(create);
  static ListSoilSamplesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SoilSample> get samples => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get hasNext => $_getBF(2);
  @$pb.TagNumber(3)
  set hasNext($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHasNext() => $_has(2);
  @$pb.TagNumber(3)
  void clearHasNext() => $_clearField(3);
}

class AnalyzeSoilRequest extends $pb.GeneratedMessage {
  factory AnalyzeSoilRequest({
    $core.String? sampleId,
    $core.String? tenantId,
    $core.String? analysisType,
  }) {
    final result = create();
    if (sampleId != null) result.sampleId = sampleId;
    if (tenantId != null) result.tenantId = tenantId;
    if (analysisType != null) result.analysisType = analysisType;
    return result;
  }

  AnalyzeSoilRequest._();

  factory AnalyzeSoilRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AnalyzeSoilRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnalyzeSoilRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sampleId')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'analysisType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzeSoilRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzeSoilRequest copyWith(void Function(AnalyzeSoilRequest) updates) =>
      super.copyWith((message) => updates(message as AnalyzeSoilRequest))
          as AnalyzeSoilRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyzeSoilRequest create() => AnalyzeSoilRequest._();
  @$core.override
  AnalyzeSoilRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AnalyzeSoilRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnalyzeSoilRequest>(create);
  static AnalyzeSoilRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sampleId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sampleId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSampleId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSampleId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get analysisType => $_getSZ(2);
  @$pb.TagNumber(3)
  set analysisType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAnalysisType() => $_has(2);
  @$pb.TagNumber(3)
  void clearAnalysisType() => $_clearField(3);
}

class AnalyzeSoilResponse extends $pb.GeneratedMessage {
  factory AnalyzeSoilResponse({
    SoilAnalysis? analysis,
  }) {
    final result = create();
    if (analysis != null) result.analysis = analysis;
    return result;
  }

  AnalyzeSoilResponse._();

  factory AnalyzeSoilResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AnalyzeSoilResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnalyzeSoilResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOM<SoilAnalysis>(1, _omitFieldNames ? '' : 'analysis',
        subBuilder: SoilAnalysis.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzeSoilResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzeSoilResponse copyWith(void Function(AnalyzeSoilResponse) updates) =>
      super.copyWith((message) => updates(message as AnalyzeSoilResponse))
          as AnalyzeSoilResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyzeSoilResponse create() => AnalyzeSoilResponse._();
  @$core.override
  AnalyzeSoilResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AnalyzeSoilResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnalyzeSoilResponse>(create);
  static AnalyzeSoilResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SoilAnalysis get analysis => $_getN(0);
  @$pb.TagNumber(1)
  set analysis(SoilAnalysis value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAnalysis() => $_has(0);
  @$pb.TagNumber(1)
  void clearAnalysis() => $_clearField(1);
  @$pb.TagNumber(1)
  SoilAnalysis ensureAnalysis() => $_ensure(0);
}

class ListSoilAnalysesRequest extends $pb.GeneratedMessage {
  factory ListSoilAnalysesRequest({
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? farmId,
    $core.String? sampleId,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (sampleId != null) result.sampleId = sampleId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListSoilAnalysesRequest._();

  factory ListSoilAnalysesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSoilAnalysesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSoilAnalysesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'sampleId')
    ..aI(5, _omitFieldNames ? '' : 'pageSize')
    ..aI(6, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSoilAnalysesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSoilAnalysesRequest copyWith(
          void Function(ListSoilAnalysesRequest) updates) =>
      super.copyWith((message) => updates(message as ListSoilAnalysesRequest))
          as ListSoilAnalysesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSoilAnalysesRequest create() => ListSoilAnalysesRequest._();
  @$core.override
  ListSoilAnalysesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSoilAnalysesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSoilAnalysesRequest>(create);
  static ListSoilAnalysesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get sampleId => $_getSZ(3);
  @$pb.TagNumber(4)
  set sampleId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSampleId() => $_has(3);
  @$pb.TagNumber(4)
  void clearSampleId() => $_clearField(4);

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

class ListSoilAnalysesResponse extends $pb.GeneratedMessage {
  factory ListSoilAnalysesResponse({
    $core.Iterable<SoilAnalysis>? analyses,
    $core.int? totalCount,
    $core.bool? hasNext,
  }) {
    final result = create();
    if (analyses != null) result.analyses.addAll(analyses);
    if (totalCount != null) result.totalCount = totalCount;
    if (hasNext != null) result.hasNext = hasNext;
    return result;
  }

  ListSoilAnalysesResponse._();

  factory ListSoilAnalysesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListSoilAnalysesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListSoilAnalysesResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..pPM<SoilAnalysis>(1, _omitFieldNames ? '' : 'analyses',
        subBuilder: SoilAnalysis.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..aOB(3, _omitFieldNames ? '' : 'hasNext')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSoilAnalysesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSoilAnalysesResponse copyWith(
          void Function(ListSoilAnalysesResponse) updates) =>
      super.copyWith((message) => updates(message as ListSoilAnalysesResponse))
          as ListSoilAnalysesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSoilAnalysesResponse create() => ListSoilAnalysesResponse._();
  @$core.override
  ListSoilAnalysesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListSoilAnalysesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSoilAnalysesResponse>(create);
  static ListSoilAnalysesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SoilAnalysis> get analyses => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get hasNext => $_getBF(2);
  @$pb.TagNumber(3)
  set hasNext($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHasNext() => $_has(2);
  @$pb.TagNumber(3)
  void clearHasNext() => $_clearField(3);
}

class GetSoilMapRequest extends $pb.GeneratedMessage {
  factory GetSoilMapRequest({
    $core.String? fieldId,
    $core.String? tenantId,
    $core.String? mapType,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (tenantId != null) result.tenantId = tenantId;
    if (mapType != null) result.mapType = mapType;
    return result;
  }

  GetSoilMapRequest._();

  factory GetSoilMapRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSoilMapRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSoilMapRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'mapType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSoilMapRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSoilMapRequest copyWith(void Function(GetSoilMapRequest) updates) =>
      super.copyWith((message) => updates(message as GetSoilMapRequest))
          as GetSoilMapRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSoilMapRequest create() => GetSoilMapRequest._();
  @$core.override
  GetSoilMapRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSoilMapRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSoilMapRequest>(create);
  static GetSoilMapRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mapType => $_getSZ(2);
  @$pb.TagNumber(3)
  set mapType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMapType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMapType() => $_clearField(3);
}

class GetSoilMapResponse extends $pb.GeneratedMessage {
  factory GetSoilMapResponse({
    SoilMap? soilMap,
  }) {
    final result = create();
    if (soilMap != null) result.soilMap = soilMap;
    return result;
  }

  GetSoilMapResponse._();

  factory GetSoilMapResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSoilMapResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSoilMapResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOM<SoilMap>(1, _omitFieldNames ? '' : 'soilMap',
        subBuilder: SoilMap.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSoilMapResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSoilMapResponse copyWith(void Function(GetSoilMapResponse) updates) =>
      super.copyWith((message) => updates(message as GetSoilMapResponse))
          as GetSoilMapResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSoilMapResponse create() => GetSoilMapResponse._();
  @$core.override
  GetSoilMapResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSoilMapResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSoilMapResponse>(create);
  static GetSoilMapResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SoilMap get soilMap => $_getN(0);
  @$pb.TagNumber(1)
  set soilMap(SoilMap value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSoilMap() => $_has(0);
  @$pb.TagNumber(1)
  void clearSoilMap() => $_clearField(1);
  @$pb.TagNumber(1)
  SoilMap ensureSoilMap() => $_ensure(0);
}

class GetSoilHealthRequest extends $pb.GeneratedMessage {
  factory GetSoilHealthRequest({
    $core.String? fieldId,
    $core.String? tenantId,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (tenantId != null) result.tenantId = tenantId;
    return result;
  }

  GetSoilHealthRequest._();

  factory GetSoilHealthRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSoilHealthRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSoilHealthRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSoilHealthRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSoilHealthRequest copyWith(void Function(GetSoilHealthRequest) updates) =>
      super.copyWith((message) => updates(message as GetSoilHealthRequest))
          as GetSoilHealthRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSoilHealthRequest create() => GetSoilHealthRequest._();
  @$core.override
  GetSoilHealthRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSoilHealthRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSoilHealthRequest>(create);
  static GetSoilHealthRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);
}

class GetSoilHealthResponse extends $pb.GeneratedMessage {
  factory GetSoilHealthResponse({
    SoilHealthScore? healthScore,
  }) {
    final result = create();
    if (healthScore != null) result.healthScore = healthScore;
    return result;
  }

  GetSoilHealthResponse._();

  factory GetSoilHealthResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSoilHealthResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSoilHealthResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOM<SoilHealthScore>(1, _omitFieldNames ? '' : 'healthScore',
        subBuilder: SoilHealthScore.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSoilHealthResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSoilHealthResponse copyWith(
          void Function(GetSoilHealthResponse) updates) =>
      super.copyWith((message) => updates(message as GetSoilHealthResponse))
          as GetSoilHealthResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSoilHealthResponse create() => GetSoilHealthResponse._();
  @$core.override
  GetSoilHealthResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSoilHealthResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSoilHealthResponse>(create);
  static GetSoilHealthResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SoilHealthScore get healthScore => $_getN(0);
  @$pb.TagNumber(1)
  set healthScore(SoilHealthScore value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHealthScore() => $_has(0);
  @$pb.TagNumber(1)
  void clearHealthScore() => $_clearField(1);
  @$pb.TagNumber(1)
  SoilHealthScore ensureHealthScore() => $_ensure(0);
}

class GetNutrientLevelsRequest extends $pb.GeneratedMessage {
  factory GetNutrientLevelsRequest({
    $core.String? sampleId,
    $core.String? tenantId,
  }) {
    final result = create();
    if (sampleId != null) result.sampleId = sampleId;
    if (tenantId != null) result.tenantId = tenantId;
    return result;
  }

  GetNutrientLevelsRequest._();

  factory GetNutrientLevelsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNutrientLevelsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNutrientLevelsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sampleId')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNutrientLevelsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNutrientLevelsRequest copyWith(
          void Function(GetNutrientLevelsRequest) updates) =>
      super.copyWith((message) => updates(message as GetNutrientLevelsRequest))
          as GetNutrientLevelsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNutrientLevelsRequest create() => GetNutrientLevelsRequest._();
  @$core.override
  GetNutrientLevelsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNutrientLevelsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNutrientLevelsRequest>(create);
  static GetNutrientLevelsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get sampleId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sampleId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSampleId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSampleId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);
}

class GetNutrientLevelsResponse extends $pb.GeneratedMessage {
  factory GetNutrientLevelsResponse({
    $core.Iterable<SoilNutrient>? nutrients,
  }) {
    final result = create();
    if (nutrients != null) result.nutrients.addAll(nutrients);
    return result;
  }

  GetNutrientLevelsResponse._();

  factory GetNutrientLevelsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNutrientLevelsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNutrientLevelsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..pPM<SoilNutrient>(1, _omitFieldNames ? '' : 'nutrients',
        subBuilder: SoilNutrient.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNutrientLevelsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNutrientLevelsResponse copyWith(
          void Function(GetNutrientLevelsResponse) updates) =>
      super.copyWith((message) => updates(message as GetNutrientLevelsResponse))
          as GetNutrientLevelsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNutrientLevelsResponse create() => GetNutrientLevelsResponse._();
  @$core.override
  GetNutrientLevelsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNutrientLevelsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNutrientLevelsResponse>(create);
  static GetNutrientLevelsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SoilNutrient> get nutrients => $_getList(0);
}

class GenerateSoilReportRequest extends $pb.GeneratedMessage {
  factory GenerateSoilReportRequest({
    $core.String? fieldId,
    $core.String? tenantId,
    $core.String? farmId,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    return result;
  }

  GenerateSoilReportRequest._();

  factory GenerateSoilReportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateSoilReportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateSoilReportRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateSoilReportRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateSoilReportRequest copyWith(
          void Function(GenerateSoilReportRequest) updates) =>
      super.copyWith((message) => updates(message as GenerateSoilReportRequest))
          as GenerateSoilReportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateSoilReportRequest create() => GenerateSoilReportRequest._();
  @$core.override
  GenerateSoilReportRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateSoilReportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateSoilReportRequest>(create);
  static GenerateSoilReportRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

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
}

class GenerateSoilReportResponse extends $pb.GeneratedMessage {
  factory GenerateSoilReportResponse({
    SoilReport? report,
  }) {
    final result = create();
    if (report != null) result.report = report;
    return result;
  }

  GenerateSoilReportResponse._();

  factory GenerateSoilReportResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateSoilReportResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateSoilReportResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.soil.v1'),
      createEmptyInstance: create)
    ..aOM<SoilReport>(1, _omitFieldNames ? '' : 'report',
        subBuilder: SoilReport.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateSoilReportResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateSoilReportResponse copyWith(
          void Function(GenerateSoilReportResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GenerateSoilReportResponse))
          as GenerateSoilReportResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateSoilReportResponse create() => GenerateSoilReportResponse._();
  @$core.override
  GenerateSoilReportResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateSoilReportResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateSoilReportResponse>(create);
  static GenerateSoilReportResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SoilReport get report => $_getN(0);
  @$pb.TagNumber(1)
  set report(SoilReport value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReport() => $_has(0);
  @$pb.TagNumber(1)
  void clearReport() => $_clearField(1);
  @$pb.TagNumber(1)
  SoilReport ensureReport() => $_ensure(0);
}

class SoilServiceApi {
  final $pb.RpcClient _client;

  SoilServiceApi(this._client);

  $async.Future<CreateSoilSampleResponse> createSoilSample(
          $pb.ClientContext? ctx, CreateSoilSampleRequest request) =>
      _client.invoke<CreateSoilSampleResponse>(ctx, 'SoilService',
          'CreateSoilSample', request, CreateSoilSampleResponse());
  $async.Future<GetSoilSampleResponse> getSoilSample(
          $pb.ClientContext? ctx, GetSoilSampleRequest request) =>
      _client.invoke<GetSoilSampleResponse>(ctx, 'SoilService', 'GetSoilSample',
          request, GetSoilSampleResponse());
  $async.Future<ListSoilSamplesResponse> listSoilSamples(
          $pb.ClientContext? ctx, ListSoilSamplesRequest request) =>
      _client.invoke<ListSoilSamplesResponse>(ctx, 'SoilService',
          'ListSoilSamples', request, ListSoilSamplesResponse());
  $async.Future<AnalyzeSoilResponse> analyzeSoil(
          $pb.ClientContext? ctx, AnalyzeSoilRequest request) =>
      _client.invoke<AnalyzeSoilResponse>(
          ctx, 'SoilService', 'AnalyzeSoil', request, AnalyzeSoilResponse());
  $async.Future<ListSoilAnalysesResponse> listSoilAnalyses(
          $pb.ClientContext? ctx, ListSoilAnalysesRequest request) =>
      _client.invoke<ListSoilAnalysesResponse>(ctx, 'SoilService',
          'ListSoilAnalyses', request, ListSoilAnalysesResponse());
  $async.Future<GetSoilMapResponse> getSoilMap(
          $pb.ClientContext? ctx, GetSoilMapRequest request) =>
      _client.invoke<GetSoilMapResponse>(
          ctx, 'SoilService', 'GetSoilMap', request, GetSoilMapResponse());
  $async.Future<GetSoilHealthResponse> getSoilHealth(
          $pb.ClientContext? ctx, GetSoilHealthRequest request) =>
      _client.invoke<GetSoilHealthResponse>(ctx, 'SoilService', 'GetSoilHealth',
          request, GetSoilHealthResponse());
  $async.Future<GetNutrientLevelsResponse> getNutrientLevels(
          $pb.ClientContext? ctx, GetNutrientLevelsRequest request) =>
      _client.invoke<GetNutrientLevelsResponse>(ctx, 'SoilService',
          'GetNutrientLevels', request, GetNutrientLevelsResponse());
  $async.Future<GenerateSoilReportResponse> generateSoilReport(
          $pb.ClientContext? ctx, GenerateSoilReportRequest request) =>
      _client.invoke<GenerateSoilReportResponse>(ctx, 'SoilService',
          'GenerateSoilReport', request, GenerateSoilReportResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
