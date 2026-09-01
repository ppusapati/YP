// This is a generated file - do not edit.
//
// Generated from satellite.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'satellite.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'satellite.pbenum.dart';

class BoundingBox extends $pb.GeneratedMessage {
  factory BoundingBox({
    $core.double? minLat,
    $core.double? minLon,
    $core.double? maxLat,
    $core.double? maxLon,
  }) {
    final result = create();
    if (minLat != null) result.minLat = minLat;
    if (minLon != null) result.minLon = minLon;
    if (maxLat != null) result.maxLat = maxLat;
    if (maxLon != null) result.maxLon = maxLon;
    return result;
  }

  BoundingBox._();

  factory BoundingBox.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BoundingBox.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoundingBox',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'minLat')
    ..aD(2, _omitFieldNames ? '' : 'minLon')
    ..aD(3, _omitFieldNames ? '' : 'maxLat')
    ..aD(4, _omitFieldNames ? '' : 'maxLon')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoundingBox clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoundingBox copyWith(void Function(BoundingBox) updates) =>
      super.copyWith((message) => updates(message as BoundingBox))
          as BoundingBox;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BoundingBox create() => BoundingBox._();
  @$core.override
  BoundingBox createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BoundingBox getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BoundingBox>(create);
  static BoundingBox? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get minLat => $_getN(0);
  @$pb.TagNumber(1)
  set minLat($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMinLat() => $_has(0);
  @$pb.TagNumber(1)
  void clearMinLat() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get minLon => $_getN(1);
  @$pb.TagNumber(2)
  set minLon($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMinLon() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinLon() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get maxLat => $_getN(2);
  @$pb.TagNumber(3)
  set maxLat($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxLat() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxLat() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get maxLon => $_getN(3);
  @$pb.TagNumber(4)
  set maxLon($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxLon() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxLon() => $_clearField(4);
}

class SatelliteImage extends $pb.GeneratedMessage {
  factory SatelliteImage({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? farmId,
    SatelliteProvider? satelliteProvider,
    $0.Timestamp? acquisitionDate,
    $core.double? cloudCoverPct,
    $core.double? resolutionMeters,
    $core.Iterable<SpectralBand>? bands,
    BoundingBox? bbox,
    $core.String? imageUrl,
    ProcessingStatus? processingStatus,
    $core.int? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (satelliteProvider != null) result.satelliteProvider = satelliteProvider;
    if (acquisitionDate != null) result.acquisitionDate = acquisitionDate;
    if (cloudCoverPct != null) result.cloudCoverPct = cloudCoverPct;
    if (resolutionMeters != null) result.resolutionMeters = resolutionMeters;
    if (bands != null) result.bands.addAll(bands);
    if (bbox != null) result.bbox = bbox;
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (processingStatus != null) result.processingStatus = processingStatus;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  SatelliteImage._();

  factory SatelliteImage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SatelliteImage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatelliteImage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..aE<SatelliteProvider>(5, _omitFieldNames ? '' : 'satelliteProvider',
        enumValues: SatelliteProvider.values)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'acquisitionDate',
        subBuilder: $0.Timestamp.create)
    ..aD(7, _omitFieldNames ? '' : 'cloudCoverPct')
    ..aD(8, _omitFieldNames ? '' : 'resolutionMeters')
    ..pc<SpectralBand>(9, _omitFieldNames ? '' : 'bands', $pb.PbFieldType.KE,
        valueOf: SpectralBand.valueOf,
        enumValues: SpectralBand.values,
        defaultEnumValue: SpectralBand.SPECTRAL_BAND_UNSPECIFIED)
    ..aOM<BoundingBox>(10, _omitFieldNames ? '' : 'bbox',
        subBuilder: BoundingBox.create)
    ..aOS(11, _omitFieldNames ? '' : 'imageUrl')
    ..aE<ProcessingStatus>(12, _omitFieldNames ? '' : 'processingStatus',
        enumValues: ProcessingStatus.values)
    ..aI(13, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SatelliteImage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SatelliteImage copyWith(void Function(SatelliteImage) updates) =>
      super.copyWith((message) => updates(message as SatelliteImage))
          as SatelliteImage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatelliteImage create() => SatelliteImage._();
  @$core.override
  SatelliteImage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SatelliteImage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatelliteImage>(create);
  static SatelliteImage? _defaultInstance;

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
  SatelliteProvider get satelliteProvider => $_getN(4);
  @$pb.TagNumber(5)
  set satelliteProvider(SatelliteProvider value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSatelliteProvider() => $_has(4);
  @$pb.TagNumber(5)
  void clearSatelliteProvider() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get acquisitionDate => $_getN(5);
  @$pb.TagNumber(6)
  set acquisitionDate($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAcquisitionDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearAcquisitionDate() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureAcquisitionDate() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.double get cloudCoverPct => $_getN(6);
  @$pb.TagNumber(7)
  set cloudCoverPct($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCloudCoverPct() => $_has(6);
  @$pb.TagNumber(7)
  void clearCloudCoverPct() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get resolutionMeters => $_getN(7);
  @$pb.TagNumber(8)
  set resolutionMeters($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasResolutionMeters() => $_has(7);
  @$pb.TagNumber(8)
  void clearResolutionMeters() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<SpectralBand> get bands => $_getList(8);

  @$pb.TagNumber(10)
  BoundingBox get bbox => $_getN(9);
  @$pb.TagNumber(10)
  set bbox(BoundingBox value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasBbox() => $_has(9);
  @$pb.TagNumber(10)
  void clearBbox() => $_clearField(10);
  @$pb.TagNumber(10)
  BoundingBox ensureBbox() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.String get imageUrl => $_getSZ(10);
  @$pb.TagNumber(11)
  set imageUrl($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasImageUrl() => $_has(10);
  @$pb.TagNumber(11)
  void clearImageUrl() => $_clearField(11);

  @$pb.TagNumber(12)
  ProcessingStatus get processingStatus => $_getN(11);
  @$pb.TagNumber(12)
  set processingStatus(ProcessingStatus value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasProcessingStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearProcessingStatus() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get version => $_getIZ(12);
  @$pb.TagNumber(13)
  set version($core.int value) => $_setSignedInt32(12, value);
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

class VegetationIndex extends $pb.GeneratedMessage {
  factory VegetationIndex({
    $core.String? id,
    $core.String? tenantId,
    $core.String? imageId,
    $core.String? fieldId,
    $core.String? indexType,
    $core.double? minValue,
    $core.double? maxValue,
    $core.double? meanValue,
    $core.double? stdDev,
    $core.String? rasterUrl,
    $0.Timestamp? computedAt,
    $core.int? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (imageId != null) result.imageId = imageId;
    if (fieldId != null) result.fieldId = fieldId;
    if (indexType != null) result.indexType = indexType;
    if (minValue != null) result.minValue = minValue;
    if (maxValue != null) result.maxValue = maxValue;
    if (meanValue != null) result.meanValue = meanValue;
    if (stdDev != null) result.stdDev = stdDev;
    if (rasterUrl != null) result.rasterUrl = rasterUrl;
    if (computedAt != null) result.computedAt = computedAt;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  VegetationIndex._();

  factory VegetationIndex.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VegetationIndex.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VegetationIndex',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'imageId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'indexType')
    ..aD(6, _omitFieldNames ? '' : 'minValue')
    ..aD(7, _omitFieldNames ? '' : 'maxValue')
    ..aD(8, _omitFieldNames ? '' : 'meanValue')
    ..aD(9, _omitFieldNames ? '' : 'stdDev')
    ..aOS(10, _omitFieldNames ? '' : 'rasterUrl')
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'computedAt',
        subBuilder: $0.Timestamp.create)
    ..aI(12, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VegetationIndex clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VegetationIndex copyWith(void Function(VegetationIndex) updates) =>
      super.copyWith((message) => updates(message as VegetationIndex))
          as VegetationIndex;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VegetationIndex create() => VegetationIndex._();
  @$core.override
  VegetationIndex createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VegetationIndex getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VegetationIndex>(create);
  static VegetationIndex? _defaultInstance;

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
  $core.String get imageId => $_getSZ(2);
  @$pb.TagNumber(3)
  set imageId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasImageId() => $_has(2);
  @$pb.TagNumber(3)
  void clearImageId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fieldId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fieldId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get indexType => $_getSZ(4);
  @$pb.TagNumber(5)
  set indexType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIndexType() => $_has(4);
  @$pb.TagNumber(5)
  void clearIndexType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get minValue => $_getN(5);
  @$pb.TagNumber(6)
  set minValue($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMinValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearMinValue() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get maxValue => $_getN(6);
  @$pb.TagNumber(7)
  set maxValue($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMaxValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearMaxValue() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get meanValue => $_getN(7);
  @$pb.TagNumber(8)
  set meanValue($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMeanValue() => $_has(7);
  @$pb.TagNumber(8)
  void clearMeanValue() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get stdDev => $_getN(8);
  @$pb.TagNumber(9)
  set stdDev($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasStdDev() => $_has(8);
  @$pb.TagNumber(9)
  void clearStdDev() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get rasterUrl => $_getSZ(9);
  @$pb.TagNumber(10)
  set rasterUrl($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRasterUrl() => $_has(9);
  @$pb.TagNumber(10)
  void clearRasterUrl() => $_clearField(10);

  @$pb.TagNumber(11)
  $0.Timestamp get computedAt => $_getN(10);
  @$pb.TagNumber(11)
  set computedAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasComputedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearComputedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureComputedAt() => $_ensure(10);

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
}

class CropStressAlert extends $pb.GeneratedMessage {
  factory CropStressAlert({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? imageId,
    $core.bool? stressDetected,
    StressType? stressType,
    $core.double? stressSeverity,
    $core.double? affectedAreaPct,
    $core.String? description,
    $core.String? recommendation,
    BoundingBox? affectedBbox,
    $core.int? version,
    $0.Timestamp? detectedAt,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (imageId != null) result.imageId = imageId;
    if (stressDetected != null) result.stressDetected = stressDetected;
    if (stressType != null) result.stressType = stressType;
    if (stressSeverity != null) result.stressSeverity = stressSeverity;
    if (affectedAreaPct != null) result.affectedAreaPct = affectedAreaPct;
    if (description != null) result.description = description;
    if (recommendation != null) result.recommendation = recommendation;
    if (affectedBbox != null) result.affectedBbox = affectedBbox;
    if (version != null) result.version = version;
    if (detectedAt != null) result.detectedAt = detectedAt;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  CropStressAlert._();

  factory CropStressAlert.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CropStressAlert.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CropStressAlert',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'imageId')
    ..aOB(5, _omitFieldNames ? '' : 'stressDetected')
    ..aE<StressType>(6, _omitFieldNames ? '' : 'stressType',
        enumValues: StressType.values)
    ..aD(7, _omitFieldNames ? '' : 'stressSeverity')
    ..aD(8, _omitFieldNames ? '' : 'affectedAreaPct')
    ..aOS(9, _omitFieldNames ? '' : 'description')
    ..aOS(10, _omitFieldNames ? '' : 'recommendation')
    ..aOM<BoundingBox>(11, _omitFieldNames ? '' : 'affectedBbox',
        subBuilder: BoundingBox.create)
    ..aI(12, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'detectedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CropStressAlert clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CropStressAlert copyWith(void Function(CropStressAlert) updates) =>
      super.copyWith((message) => updates(message as CropStressAlert))
          as CropStressAlert;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CropStressAlert create() => CropStressAlert._();
  @$core.override
  CropStressAlert createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CropStressAlert getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CropStressAlert>(create);
  static CropStressAlert? _defaultInstance;

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
  $core.String get imageId => $_getSZ(3);
  @$pb.TagNumber(4)
  set imageId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasImageId() => $_has(3);
  @$pb.TagNumber(4)
  void clearImageId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get stressDetected => $_getBF(4);
  @$pb.TagNumber(5)
  set stressDetected($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStressDetected() => $_has(4);
  @$pb.TagNumber(5)
  void clearStressDetected() => $_clearField(5);

  @$pb.TagNumber(6)
  StressType get stressType => $_getN(5);
  @$pb.TagNumber(6)
  set stressType(StressType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStressType() => $_has(5);
  @$pb.TagNumber(6)
  void clearStressType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get stressSeverity => $_getN(6);
  @$pb.TagNumber(7)
  set stressSeverity($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStressSeverity() => $_has(6);
  @$pb.TagNumber(7)
  void clearStressSeverity() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get affectedAreaPct => $_getN(7);
  @$pb.TagNumber(8)
  set affectedAreaPct($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAffectedAreaPct() => $_has(7);
  @$pb.TagNumber(8)
  void clearAffectedAreaPct() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get description => $_getSZ(8);
  @$pb.TagNumber(9)
  set description($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDescription() => $_has(8);
  @$pb.TagNumber(9)
  void clearDescription() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get recommendation => $_getSZ(9);
  @$pb.TagNumber(10)
  set recommendation($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasRecommendation() => $_has(9);
  @$pb.TagNumber(10)
  void clearRecommendation() => $_clearField(10);

  @$pb.TagNumber(11)
  BoundingBox get affectedBbox => $_getN(10);
  @$pb.TagNumber(11)
  set affectedBbox(BoundingBox value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasAffectedBbox() => $_has(10);
  @$pb.TagNumber(11)
  void clearAffectedBbox() => $_clearField(11);
  @$pb.TagNumber(11)
  BoundingBox ensureAffectedBbox() => $_ensure(10);

  @$pb.TagNumber(12)
  $core.int get version => $_getIZ(11);
  @$pb.TagNumber(12)
  set version($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasVersion() => $_has(11);
  @$pb.TagNumber(12)
  void clearVersion() => $_clearField(12);

  @$pb.TagNumber(13)
  $0.Timestamp get detectedAt => $_getN(12);
  @$pb.TagNumber(13)
  set detectedAt($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasDetectedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearDetectedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureDetectedAt() => $_ensure(12);

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

class TemporalAnalysis extends $pb.GeneratedMessage {
  factory TemporalAnalysis({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? indexType,
    $0.Timestamp? startDate,
    $0.Timestamp? endDate,
    $core.Iterable<TemporalDataPoint>? dataPoints,
    $core.double? trendSlope,
    $core.String? trendDirection,
    $core.double? changePct,
    $core.int? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (indexType != null) result.indexType = indexType;
    if (startDate != null) result.startDate = startDate;
    if (endDate != null) result.endDate = endDate;
    if (dataPoints != null) result.dataPoints.addAll(dataPoints);
    if (trendSlope != null) result.trendSlope = trendSlope;
    if (trendDirection != null) result.trendDirection = trendDirection;
    if (changePct != null) result.changePct = changePct;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  TemporalAnalysis._();

  factory TemporalAnalysis.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TemporalAnalysis.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemporalAnalysis',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'indexType')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'startDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'endDate',
        subBuilder: $0.Timestamp.create)
    ..pPM<TemporalDataPoint>(7, _omitFieldNames ? '' : 'dataPoints',
        subBuilder: TemporalDataPoint.create)
    ..aD(8, _omitFieldNames ? '' : 'trendSlope')
    ..aOS(9, _omitFieldNames ? '' : 'trendDirection')
    ..aD(10, _omitFieldNames ? '' : 'changePct')
    ..aI(11, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemporalAnalysis clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemporalAnalysis copyWith(void Function(TemporalAnalysis) updates) =>
      super.copyWith((message) => updates(message as TemporalAnalysis))
          as TemporalAnalysis;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TemporalAnalysis create() => TemporalAnalysis._();
  @$core.override
  TemporalAnalysis createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TemporalAnalysis getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemporalAnalysis>(create);
  static TemporalAnalysis? _defaultInstance;

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
  $core.String get indexType => $_getSZ(3);
  @$pb.TagNumber(4)
  set indexType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIndexType() => $_has(3);
  @$pb.TagNumber(4)
  void clearIndexType() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get startDate => $_getN(4);
  @$pb.TagNumber(5)
  set startDate($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStartDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearStartDate() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureStartDate() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.Timestamp get endDate => $_getN(5);
  @$pb.TagNumber(6)
  set endDate($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasEndDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearEndDate() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureEndDate() => $_ensure(5);

  @$pb.TagNumber(7)
  $pb.PbList<TemporalDataPoint> get dataPoints => $_getList(6);

  @$pb.TagNumber(8)
  $core.double get trendSlope => $_getN(7);
  @$pb.TagNumber(8)
  set trendSlope($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTrendSlope() => $_has(7);
  @$pb.TagNumber(8)
  void clearTrendSlope() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get trendDirection => $_getSZ(8);
  @$pb.TagNumber(9)
  set trendDirection($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTrendDirection() => $_has(8);
  @$pb.TagNumber(9)
  void clearTrendDirection() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get changePct => $_getN(9);
  @$pb.TagNumber(10)
  set changePct($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasChangePct() => $_has(9);
  @$pb.TagNumber(10)
  void clearChangePct() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get version => $_getIZ(10);
  @$pb.TagNumber(11)
  set version($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasVersion() => $_has(10);
  @$pb.TagNumber(11)
  void clearVersion() => $_clearField(11);

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

class TemporalDataPoint extends $pb.GeneratedMessage {
  factory TemporalDataPoint({
    $0.Timestamp? date,
    $core.double? meanValue,
    $core.double? minValue,
    $core.double? maxValue,
  }) {
    final result = create();
    if (date != null) result.date = date;
    if (meanValue != null) result.meanValue = meanValue;
    if (minValue != null) result.minValue = minValue;
    if (maxValue != null) result.maxValue = maxValue;
    return result;
  }

  TemporalDataPoint._();

  factory TemporalDataPoint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TemporalDataPoint.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemporalDataPoint',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'date',
        subBuilder: $0.Timestamp.create)
    ..aD(2, _omitFieldNames ? '' : 'meanValue')
    ..aD(3, _omitFieldNames ? '' : 'minValue')
    ..aD(4, _omitFieldNames ? '' : 'maxValue')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemporalDataPoint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemporalDataPoint copyWith(void Function(TemporalDataPoint) updates) =>
      super.copyWith((message) => updates(message as TemporalDataPoint))
          as TemporalDataPoint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TemporalDataPoint create() => TemporalDataPoint._();
  @$core.override
  TemporalDataPoint createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TemporalDataPoint getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemporalDataPoint>(create);
  static TemporalDataPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Timestamp get date => $_getN(0);
  @$pb.TagNumber(1)
  set date($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureDate() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.double get meanValue => $_getN(1);
  @$pb.TagNumber(2)
  set meanValue($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMeanValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearMeanValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get minValue => $_getN(2);
  @$pb.TagNumber(3)
  set minValue($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMinValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearMinValue() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get maxValue => $_getN(3);
  @$pb.TagNumber(4)
  set maxValue($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxValue() => $_clearField(4);
}

class SatelliteTask extends $pb.GeneratedMessage {
  factory SatelliteTask({
    $core.String? id,
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? taskType,
    ProcessingStatus? status,
    $core.String? inputImageId,
    $core.String? resultId,
    $core.String? errorMessage,
    $core.int? retryCount,
    $core.int? version,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (taskType != null) result.taskType = taskType;
    if (status != null) result.status = status;
    if (inputImageId != null) result.inputImageId = inputImageId;
    if (resultId != null) result.resultId = resultId;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (retryCount != null) result.retryCount = retryCount;
    if (version != null) result.version = version;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  SatelliteTask._();

  factory SatelliteTask.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SatelliteTask.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SatelliteTask',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'taskType')
    ..aE<ProcessingStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: ProcessingStatus.values)
    ..aOS(6, _omitFieldNames ? '' : 'inputImageId')
    ..aOS(7, _omitFieldNames ? '' : 'resultId')
    ..aOS(8, _omitFieldNames ? '' : 'errorMessage')
    ..aI(9, _omitFieldNames ? '' : 'retryCount')
    ..aI(10, _omitFieldNames ? '' : 'version')
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SatelliteTask clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SatelliteTask copyWith(void Function(SatelliteTask) updates) =>
      super.copyWith((message) => updates(message as SatelliteTask))
          as SatelliteTask;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SatelliteTask create() => SatelliteTask._();
  @$core.override
  SatelliteTask createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SatelliteTask getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SatelliteTask>(create);
  static SatelliteTask? _defaultInstance;

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
  $core.String get taskType => $_getSZ(3);
  @$pb.TagNumber(4)
  set taskType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTaskType() => $_has(3);
  @$pb.TagNumber(4)
  void clearTaskType() => $_clearField(4);

  @$pb.TagNumber(5)
  ProcessingStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(ProcessingStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get inputImageId => $_getSZ(5);
  @$pb.TagNumber(6)
  set inputImageId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasInputImageId() => $_has(5);
  @$pb.TagNumber(6)
  void clearInputImageId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get resultId => $_getSZ(6);
  @$pb.TagNumber(7)
  set resultId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasResultId() => $_has(6);
  @$pb.TagNumber(7)
  void clearResultId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get errorMessage => $_getSZ(7);
  @$pb.TagNumber(8)
  set errorMessage($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasErrorMessage() => $_has(7);
  @$pb.TagNumber(8)
  void clearErrorMessage() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get retryCount => $_getIZ(8);
  @$pb.TagNumber(9)
  set retryCount($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRetryCount() => $_has(8);
  @$pb.TagNumber(9)
  void clearRetryCount() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get version => $_getIZ(9);
  @$pb.TagNumber(10)
  set version($core.int value) => $_setSignedInt32(9, value);
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

class RequestImageryRequest extends $pb.GeneratedMessage {
  factory RequestImageryRequest({
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? farmId,
    SatelliteProvider? satelliteProvider,
    BoundingBox? bbox,
    $core.double? maxCloudCoverPct,
    $core.double? resolutionMeters,
    $core.Iterable<SpectralBand>? bands,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (satelliteProvider != null) result.satelliteProvider = satelliteProvider;
    if (bbox != null) result.bbox = bbox;
    if (maxCloudCoverPct != null) result.maxCloudCoverPct = maxCloudCoverPct;
    if (resolutionMeters != null) result.resolutionMeters = resolutionMeters;
    if (bands != null) result.bands.addAll(bands);
    return result;
  }

  RequestImageryRequest._();

  factory RequestImageryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestImageryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestImageryRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aE<SatelliteProvider>(4, _omitFieldNames ? '' : 'satelliteProvider',
        enumValues: SatelliteProvider.values)
    ..aOM<BoundingBox>(5, _omitFieldNames ? '' : 'bbox',
        subBuilder: BoundingBox.create)
    ..aD(6, _omitFieldNames ? '' : 'maxCloudCoverPct')
    ..aD(7, _omitFieldNames ? '' : 'resolutionMeters')
    ..pc<SpectralBand>(8, _omitFieldNames ? '' : 'bands', $pb.PbFieldType.KE,
        valueOf: SpectralBand.valueOf,
        enumValues: SpectralBand.values,
        defaultEnumValue: SpectralBand.SPECTRAL_BAND_UNSPECIFIED)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestImageryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestImageryRequest copyWith(
          void Function(RequestImageryRequest) updates) =>
      super.copyWith((message) => updates(message as RequestImageryRequest))
          as RequestImageryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestImageryRequest create() => RequestImageryRequest._();
  @$core.override
  RequestImageryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestImageryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestImageryRequest>(create);
  static RequestImageryRequest? _defaultInstance;

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
  SatelliteProvider get satelliteProvider => $_getN(3);
  @$pb.TagNumber(4)
  set satelliteProvider(SatelliteProvider value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSatelliteProvider() => $_has(3);
  @$pb.TagNumber(4)
  void clearSatelliteProvider() => $_clearField(4);

  @$pb.TagNumber(5)
  BoundingBox get bbox => $_getN(4);
  @$pb.TagNumber(5)
  set bbox(BoundingBox value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasBbox() => $_has(4);
  @$pb.TagNumber(5)
  void clearBbox() => $_clearField(5);
  @$pb.TagNumber(5)
  BoundingBox ensureBbox() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.double get maxCloudCoverPct => $_getN(5);
  @$pb.TagNumber(6)
  set maxCloudCoverPct($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxCloudCoverPct() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxCloudCoverPct() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get resolutionMeters => $_getN(6);
  @$pb.TagNumber(7)
  set resolutionMeters($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasResolutionMeters() => $_has(6);
  @$pb.TagNumber(7)
  void clearResolutionMeters() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<SpectralBand> get bands => $_getList(7);
}

class RequestImageryResponse extends $pb.GeneratedMessage {
  factory RequestImageryResponse({
    SatelliteTask? task,
    $core.String? message,
  }) {
    final result = create();
    if (task != null) result.task = task;
    if (message != null) result.message = message;
    return result;
  }

  RequestImageryResponse._();

  factory RequestImageryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestImageryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestImageryResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOM<SatelliteTask>(1, _omitFieldNames ? '' : 'task',
        subBuilder: SatelliteTask.create)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestImageryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestImageryResponse copyWith(
          void Function(RequestImageryResponse) updates) =>
      super.copyWith((message) => updates(message as RequestImageryResponse))
          as RequestImageryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestImageryResponse create() => RequestImageryResponse._();
  @$core.override
  RequestImageryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestImageryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestImageryResponse>(create);
  static RequestImageryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SatelliteTask get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(SatelliteTask value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  SatelliteTask ensureTask() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class GetImageRequest extends $pb.GeneratedMessage {
  factory GetImageRequest({
    $core.String? id,
    $core.String? tenantId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    return result;
  }

  GetImageRequest._();

  factory GetImageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetImageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetImageRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetImageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetImageRequest copyWith(void Function(GetImageRequest) updates) =>
      super.copyWith((message) => updates(message as GetImageRequest))
          as GetImageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetImageRequest create() => GetImageRequest._();
  @$core.override
  GetImageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetImageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetImageRequest>(create);
  static GetImageRequest? _defaultInstance;

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

class GetImageResponse extends $pb.GeneratedMessage {
  factory GetImageResponse({
    SatelliteImage? image,
  }) {
    final result = create();
    if (image != null) result.image = image;
    return result;
  }

  GetImageResponse._();

  factory GetImageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetImageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetImageResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOM<SatelliteImage>(1, _omitFieldNames ? '' : 'image',
        subBuilder: SatelliteImage.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetImageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetImageResponse copyWith(void Function(GetImageResponse) updates) =>
      super.copyWith((message) => updates(message as GetImageResponse))
          as GetImageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetImageResponse create() => GetImageResponse._();
  @$core.override
  GetImageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetImageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetImageResponse>(create);
  static GetImageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SatelliteImage get image => $_getN(0);
  @$pb.TagNumber(1)
  set image(SatelliteImage value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasImage() => $_has(0);
  @$pb.TagNumber(1)
  void clearImage() => $_clearField(1);
  @$pb.TagNumber(1)
  SatelliteImage ensureImage() => $_ensure(0);
}

class ListImagesRequest extends $pb.GeneratedMessage {
  factory ListImagesRequest({
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? farmId,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListImagesRequest._();

  factory ListImagesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListImagesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListImagesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aI(5, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListImagesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListImagesRequest copyWith(void Function(ListImagesRequest) updates) =>
      super.copyWith((message) => updates(message as ListImagesRequest))
          as ListImagesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListImagesRequest create() => ListImagesRequest._();
  @$core.override
  ListImagesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListImagesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListImagesRequest>(create);
  static ListImagesRequest? _defaultInstance;

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
}

class ListImagesResponse extends $pb.GeneratedMessage {
  factory ListImagesResponse({
    $core.Iterable<SatelliteImage>? images,
    $core.int? totalCount,
  }) {
    final result = create();
    if (images != null) result.images.addAll(images);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListImagesResponse._();

  factory ListImagesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListImagesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListImagesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..pPM<SatelliteImage>(1, _omitFieldNames ? '' : 'images',
        subBuilder: SatelliteImage.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListImagesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListImagesResponse copyWith(void Function(ListImagesResponse) updates) =>
      super.copyWith((message) => updates(message as ListImagesResponse))
          as ListImagesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListImagesResponse create() => ListImagesResponse._();
  @$core.override
  ListImagesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListImagesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListImagesResponse>(create);
  static ListImagesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SatelliteImage> get images => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class ComputeIndexRequest extends $pb.GeneratedMessage {
  factory ComputeIndexRequest({
    $core.String? tenantId,
    $core.String? imageId,
    $core.String? fieldId,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    if (imageId != null) result.imageId = imageId;
    if (fieldId != null) result.fieldId = fieldId;
    return result;
  }

  ComputeIndexRequest._();

  factory ComputeIndexRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ComputeIndexRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ComputeIndexRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aOS(2, _omitFieldNames ? '' : 'imageId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeIndexRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeIndexRequest copyWith(void Function(ComputeIndexRequest) updates) =>
      super.copyWith((message) => updates(message as ComputeIndexRequest))
          as ComputeIndexRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ComputeIndexRequest create() => ComputeIndexRequest._();
  @$core.override
  ComputeIndexRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ComputeIndexRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ComputeIndexRequest>(create);
  static ComputeIndexRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get imageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set imageId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasImageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearImageId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fieldId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldId() => $_clearField(3);
}

class ComputeIndexResponse extends $pb.GeneratedMessage {
  factory ComputeIndexResponse({
    VegetationIndex? index,
    $core.String? message,
  }) {
    final result = create();
    if (index != null) result.index = index;
    if (message != null) result.message = message;
    return result;
  }

  ComputeIndexResponse._();

  factory ComputeIndexResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ComputeIndexResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ComputeIndexResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOM<VegetationIndex>(1, _omitFieldNames ? '' : 'index',
        subBuilder: VegetationIndex.create)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeIndexResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeIndexResponse copyWith(void Function(ComputeIndexResponse) updates) =>
      super.copyWith((message) => updates(message as ComputeIndexResponse))
          as ComputeIndexResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ComputeIndexResponse create() => ComputeIndexResponse._();
  @$core.override
  ComputeIndexResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ComputeIndexResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ComputeIndexResponse>(create);
  static ComputeIndexResponse? _defaultInstance;

  @$pb.TagNumber(1)
  VegetationIndex get index => $_getN(0);
  @$pb.TagNumber(1)
  set index(VegetationIndex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => $_clearField(1);
  @$pb.TagNumber(1)
  VegetationIndex ensureIndex() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class GetVegetationIndicesRequest extends $pb.GeneratedMessage {
  factory GetVegetationIndicesRequest({
    $core.String? tenantId,
    $core.String? imageId,
    $core.String? fieldId,
    $core.String? indexType,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    if (imageId != null) result.imageId = imageId;
    if (fieldId != null) result.fieldId = fieldId;
    if (indexType != null) result.indexType = indexType;
    return result;
  }

  GetVegetationIndicesRequest._();

  factory GetVegetationIndicesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetVegetationIndicesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetVegetationIndicesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aOS(2, _omitFieldNames ? '' : 'imageId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'indexType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVegetationIndicesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVegetationIndicesRequest copyWith(
          void Function(GetVegetationIndicesRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetVegetationIndicesRequest))
          as GetVegetationIndicesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetVegetationIndicesRequest create() =>
      GetVegetationIndicesRequest._();
  @$core.override
  GetVegetationIndicesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetVegetationIndicesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetVegetationIndicesRequest>(create);
  static GetVegetationIndicesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get imageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set imageId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasImageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearImageId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fieldId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get indexType => $_getSZ(3);
  @$pb.TagNumber(4)
  set indexType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIndexType() => $_has(3);
  @$pb.TagNumber(4)
  void clearIndexType() => $_clearField(4);
}

class GetVegetationIndicesResponse extends $pb.GeneratedMessage {
  factory GetVegetationIndicesResponse({
    $core.Iterable<VegetationIndex>? indices,
  }) {
    final result = create();
    if (indices != null) result.indices.addAll(indices);
    return result;
  }

  GetVegetationIndicesResponse._();

  factory GetVegetationIndicesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetVegetationIndicesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetVegetationIndicesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..pPM<VegetationIndex>(1, _omitFieldNames ? '' : 'indices',
        subBuilder: VegetationIndex.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVegetationIndicesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVegetationIndicesResponse copyWith(
          void Function(GetVegetationIndicesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetVegetationIndicesResponse))
          as GetVegetationIndicesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetVegetationIndicesResponse create() =>
      GetVegetationIndicesResponse._();
  @$core.override
  GetVegetationIndicesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetVegetationIndicesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetVegetationIndicesResponse>(create);
  static GetVegetationIndicesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<VegetationIndex> get indices => $_getList(0);
}

class DetectCropStressRequest extends $pb.GeneratedMessage {
  factory DetectCropStressRequest({
    $core.String? tenantId,
    $core.String? imageId,
    $core.String? fieldId,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    if (imageId != null) result.imageId = imageId;
    if (fieldId != null) result.fieldId = fieldId;
    return result;
  }

  DetectCropStressRequest._();

  factory DetectCropStressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectCropStressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectCropStressRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aOS(2, _omitFieldNames ? '' : 'imageId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectCropStressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectCropStressRequest copyWith(
          void Function(DetectCropStressRequest) updates) =>
      super.copyWith((message) => updates(message as DetectCropStressRequest))
          as DetectCropStressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectCropStressRequest create() => DetectCropStressRequest._();
  @$core.override
  DetectCropStressRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectCropStressRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectCropStressRequest>(create);
  static DetectCropStressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get imageId => $_getSZ(1);
  @$pb.TagNumber(2)
  set imageId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasImageId() => $_has(1);
  @$pb.TagNumber(2)
  void clearImageId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fieldId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldId() => $_clearField(3);
}

class DetectCropStressResponse extends $pb.GeneratedMessage {
  factory DetectCropStressResponse({
    CropStressAlert? alert,
    $core.String? message,
  }) {
    final result = create();
    if (alert != null) result.alert = alert;
    if (message != null) result.message = message;
    return result;
  }

  DetectCropStressResponse._();

  factory DetectCropStressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectCropStressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectCropStressResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOM<CropStressAlert>(1, _omitFieldNames ? '' : 'alert',
        subBuilder: CropStressAlert.create)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectCropStressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectCropStressResponse copyWith(
          void Function(DetectCropStressResponse) updates) =>
      super.copyWith((message) => updates(message as DetectCropStressResponse))
          as DetectCropStressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectCropStressResponse create() => DetectCropStressResponse._();
  @$core.override
  DetectCropStressResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectCropStressResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectCropStressResponse>(create);
  static DetectCropStressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CropStressAlert get alert => $_getN(0);
  @$pb.TagNumber(1)
  set alert(CropStressAlert value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAlert() => $_has(0);
  @$pb.TagNumber(1)
  void clearAlert() => $_clearField(1);
  @$pb.TagNumber(1)
  CropStressAlert ensureAlert() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class GetTemporalAnalysisRequest extends $pb.GeneratedMessage {
  factory GetTemporalAnalysisRequest({
    $core.String? tenantId,
    $core.String? fieldId,
    $core.String? indexType,
    $0.Timestamp? startDate,
    $0.Timestamp? endDate,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
    if (indexType != null) result.indexType = indexType;
    if (startDate != null) result.startDate = startDate;
    if (endDate != null) result.endDate = endDate;
    return result;
  }

  GetTemporalAnalysisRequest._();

  factory GetTemporalAnalysisRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTemporalAnalysisRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTemporalAnalysisRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'indexType')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'startDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'endDate',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTemporalAnalysisRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTemporalAnalysisRequest copyWith(
          void Function(GetTemporalAnalysisRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetTemporalAnalysisRequest))
          as GetTemporalAnalysisRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTemporalAnalysisRequest create() => GetTemporalAnalysisRequest._();
  @$core.override
  GetTemporalAnalysisRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTemporalAnalysisRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTemporalAnalysisRequest>(create);
  static GetTemporalAnalysisRequest? _defaultInstance;

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
  $core.String get indexType => $_getSZ(2);
  @$pb.TagNumber(3)
  set indexType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIndexType() => $_has(2);
  @$pb.TagNumber(3)
  void clearIndexType() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get startDate => $_getN(3);
  @$pb.TagNumber(4)
  set startDate($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStartDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearStartDate() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureStartDate() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Timestamp get endDate => $_getN(4);
  @$pb.TagNumber(5)
  set endDate($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasEndDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearEndDate() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureEndDate() => $_ensure(4);
}

class GetTemporalAnalysisResponse extends $pb.GeneratedMessage {
  factory GetTemporalAnalysisResponse({
    TemporalAnalysis? analysis,
  }) {
    final result = create();
    if (analysis != null) result.analysis = analysis;
    return result;
  }

  GetTemporalAnalysisResponse._();

  factory GetTemporalAnalysisResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTemporalAnalysisResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTemporalAnalysisResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOM<TemporalAnalysis>(1, _omitFieldNames ? '' : 'analysis',
        subBuilder: TemporalAnalysis.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTemporalAnalysisResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTemporalAnalysisResponse copyWith(
          void Function(GetTemporalAnalysisResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetTemporalAnalysisResponse))
          as GetTemporalAnalysisResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTemporalAnalysisResponse create() =>
      GetTemporalAnalysisResponse._();
  @$core.override
  GetTemporalAnalysisResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTemporalAnalysisResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTemporalAnalysisResponse>(create);
  static GetTemporalAnalysisResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TemporalAnalysis get analysis => $_getN(0);
  @$pb.TagNumber(1)
  set analysis(TemporalAnalysis value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAnalysis() => $_has(0);
  @$pb.TagNumber(1)
  void clearAnalysis() => $_clearField(1);
  @$pb.TagNumber(1)
  TemporalAnalysis ensureAnalysis() => $_ensure(0);
}

class ListAlertsRequest extends $pb.GeneratedMessage {
  factory ListAlertsRequest({
    $core.String? tenantId,
    $core.String? fieldId,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    if (fieldId != null) result.fieldId = fieldId;
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
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aI(3, _omitFieldNames ? '' : 'pageSize')
    ..aI(4, _omitFieldNames ? '' : 'pageOffset')
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

class ListAlertsResponse extends $pb.GeneratedMessage {
  factory ListAlertsResponse({
    $core.Iterable<CropStressAlert>? alerts,
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
          _omitMessageNames ? '' : 'agriculture.satellite.v1'),
      createEmptyInstance: create)
    ..pPM<CropStressAlert>(1, _omitFieldNames ? '' : 'alerts',
        subBuilder: CropStressAlert.create)
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
  $pb.PbList<CropStressAlert> get alerts => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class SatelliteServiceApi {
  final $pb.RpcClient _client;

  SatelliteServiceApi(this._client);

  $async.Future<RequestImageryResponse> requestImagery(
          $pb.ClientContext? ctx, RequestImageryRequest request) =>
      _client.invoke<RequestImageryResponse>(ctx, 'SatelliteService',
          'RequestImagery', request, RequestImageryResponse());
  $async.Future<GetImageResponse> getImage(
          $pb.ClientContext? ctx, GetImageRequest request) =>
      _client.invoke<GetImageResponse>(
          ctx, 'SatelliteService', 'GetImage', request, GetImageResponse());
  $async.Future<ListImagesResponse> listImages(
          $pb.ClientContext? ctx, ListImagesRequest request) =>
      _client.invoke<ListImagesResponse>(
          ctx, 'SatelliteService', 'ListImages', request, ListImagesResponse());
  $async.Future<ComputeIndexResponse> computeNDVI(
          $pb.ClientContext? ctx, ComputeIndexRequest request) =>
      _client.invoke<ComputeIndexResponse>(ctx, 'SatelliteService',
          'ComputeNDVI', request, ComputeIndexResponse());
  $async.Future<ComputeIndexResponse> computeNDWI(
          $pb.ClientContext? ctx, ComputeIndexRequest request) =>
      _client.invoke<ComputeIndexResponse>(ctx, 'SatelliteService',
          'ComputeNDWI', request, ComputeIndexResponse());
  $async.Future<ComputeIndexResponse> computeEVI(
          $pb.ClientContext? ctx, ComputeIndexRequest request) =>
      _client.invoke<ComputeIndexResponse>(ctx, 'SatelliteService',
          'ComputeEVI', request, ComputeIndexResponse());
  $async.Future<GetVegetationIndicesResponse> getVegetationIndices(
          $pb.ClientContext? ctx, GetVegetationIndicesRequest request) =>
      _client.invoke<GetVegetationIndicesResponse>(ctx, 'SatelliteService',
          'GetVegetationIndices', request, GetVegetationIndicesResponse());
  $async.Future<DetectCropStressResponse> detectCropStress(
          $pb.ClientContext? ctx, DetectCropStressRequest request) =>
      _client.invoke<DetectCropStressResponse>(ctx, 'SatelliteService',
          'DetectCropStress', request, DetectCropStressResponse());
  $async.Future<GetTemporalAnalysisResponse> getTemporalAnalysis(
          $pb.ClientContext? ctx, GetTemporalAnalysisRequest request) =>
      _client.invoke<GetTemporalAnalysisResponse>(ctx, 'SatelliteService',
          'GetTemporalAnalysis', request, GetTemporalAnalysisResponse());
  $async.Future<ListAlertsResponse> listAlerts(
          $pb.ClientContext? ctx, ListAlertsRequest request) =>
      _client.invoke<ListAlertsResponse>(
          ctx, 'SatelliteService', 'ListAlerts', request, ListAlertsResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
