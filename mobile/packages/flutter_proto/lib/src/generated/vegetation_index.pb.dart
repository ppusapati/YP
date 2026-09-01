// This is a generated file - do not edit.
//
// Generated from vegetation_index.proto.

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

import 'vegetation_index.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'vegetation_index.pbenum.dart';

class VegetationIndex extends $pb.GeneratedMessage {
  factory VegetationIndex({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? processingJobId,
    VegetationIndexType? indexType,
    $core.double? meanValue,
    $core.double? minValue,
    $core.double? maxValue,
    $core.double? stdDeviation,
    $core.double? medianValue,
    $fixnum.Int64? pixelCount,
    $core.double? coveragePercent,
    $core.String? rasterS3Key,
    $0.Timestamp? acquisitionDate,
    $0.Timestamp? computedAt,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (processingJobId != null) result.processingJobId = processingJobId;
    if (indexType != null) result.indexType = indexType;
    if (meanValue != null) result.meanValue = meanValue;
    if (minValue != null) result.minValue = minValue;
    if (maxValue != null) result.maxValue = maxValue;
    if (stdDeviation != null) result.stdDeviation = stdDeviation;
    if (medianValue != null) result.medianValue = medianValue;
    if (pixelCount != null) result.pixelCount = pixelCount;
    if (coveragePercent != null) result.coveragePercent = coveragePercent;
    if (rasterS3Key != null) result.rasterS3Key = rasterS3Key;
    if (acquisitionDate != null) result.acquisitionDate = acquisitionDate;
    if (computedAt != null) result.computedAt = computedAt;
    if (createdAt != null) result.createdAt = createdAt;
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
          _omitMessageNames ? '' : 'agriculture.satellite.vegetation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'processingJobId')
    ..aE<VegetationIndexType>(6, _omitFieldNames ? '' : 'indexType',
        enumValues: VegetationIndexType.values)
    ..aD(7, _omitFieldNames ? '' : 'meanValue')
    ..aD(8, _omitFieldNames ? '' : 'minValue')
    ..aD(9, _omitFieldNames ? '' : 'maxValue')
    ..aD(10, _omitFieldNames ? '' : 'stdDeviation')
    ..aD(11, _omitFieldNames ? '' : 'medianValue')
    ..aInt64(12, _omitFieldNames ? '' : 'pixelCount')
    ..aD(13, _omitFieldNames ? '' : 'coveragePercent')
    ..aOS(14, _omitFieldNames ? '' : 'rasterS3Key')
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'acquisitionDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(16, _omitFieldNames ? '' : 'computedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'createdAt',
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
  $core.String get processingJobId => $_getSZ(4);
  @$pb.TagNumber(5)
  set processingJobId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProcessingJobId() => $_has(4);
  @$pb.TagNumber(5)
  void clearProcessingJobId() => $_clearField(5);

  @$pb.TagNumber(6)
  VegetationIndexType get indexType => $_getN(5);
  @$pb.TagNumber(6)
  set indexType(VegetationIndexType value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasIndexType() => $_has(5);
  @$pb.TagNumber(6)
  void clearIndexType() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get meanValue => $_getN(6);
  @$pb.TagNumber(7)
  set meanValue($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMeanValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearMeanValue() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get minValue => $_getN(7);
  @$pb.TagNumber(8)
  set minValue($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMinValue() => $_has(7);
  @$pb.TagNumber(8)
  void clearMinValue() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get maxValue => $_getN(8);
  @$pb.TagNumber(9)
  set maxValue($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMaxValue() => $_has(8);
  @$pb.TagNumber(9)
  void clearMaxValue() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get stdDeviation => $_getN(9);
  @$pb.TagNumber(10)
  set stdDeviation($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasStdDeviation() => $_has(9);
  @$pb.TagNumber(10)
  void clearStdDeviation() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get medianValue => $_getN(10);
  @$pb.TagNumber(11)
  set medianValue($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasMedianValue() => $_has(10);
  @$pb.TagNumber(11)
  void clearMedianValue() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get pixelCount => $_getI64(11);
  @$pb.TagNumber(12)
  set pixelCount($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPixelCount() => $_has(11);
  @$pb.TagNumber(12)
  void clearPixelCount() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get coveragePercent => $_getN(12);
  @$pb.TagNumber(13)
  set coveragePercent($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCoveragePercent() => $_has(12);
  @$pb.TagNumber(13)
  void clearCoveragePercent() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get rasterS3Key => $_getSZ(13);
  @$pb.TagNumber(14)
  set rasterS3Key($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasRasterS3Key() => $_has(13);
  @$pb.TagNumber(14)
  void clearRasterS3Key() => $_clearField(14);

  @$pb.TagNumber(15)
  $0.Timestamp get acquisitionDate => $_getN(14);
  @$pb.TagNumber(15)
  set acquisitionDate($0.Timestamp value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasAcquisitionDate() => $_has(14);
  @$pb.TagNumber(15)
  void clearAcquisitionDate() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Timestamp ensureAcquisitionDate() => $_ensure(14);

  @$pb.TagNumber(16)
  $0.Timestamp get computedAt => $_getN(15);
  @$pb.TagNumber(16)
  set computedAt($0.Timestamp value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasComputedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearComputedAt() => $_clearField(16);
  @$pb.TagNumber(16)
  $0.Timestamp ensureComputedAt() => $_ensure(15);

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
}

class ComputeTask extends $pb.GeneratedMessage {
  factory ComputeTask({
    $core.String? id,
    $core.String? tenantId,
    $core.String? processingJobId,
    $core.String? farmId,
    $core.Iterable<VegetationIndexType>? indexTypes,
    ComputeStatus? status,
    $core.String? errorMessage,
    $core.double? computeTimeSeconds,
    $0.Timestamp? createdAt,
    $0.Timestamp? completedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (processingJobId != null) result.processingJobId = processingJobId;
    if (farmId != null) result.farmId = farmId;
    if (indexTypes != null) result.indexTypes.addAll(indexTypes);
    if (status != null) result.status = status;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (computeTimeSeconds != null)
      result.computeTimeSeconds = computeTimeSeconds;
    if (createdAt != null) result.createdAt = createdAt;
    if (completedAt != null) result.completedAt = completedAt;
    return result;
  }

  ComputeTask._();

  factory ComputeTask.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ComputeTask.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ComputeTask',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.vegetation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'processingJobId')
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..pc<VegetationIndexType>(
        5, _omitFieldNames ? '' : 'indexTypes', $pb.PbFieldType.KE,
        valueOf: VegetationIndexType.valueOf,
        enumValues: VegetationIndexType.values,
        defaultEnumValue: VegetationIndexType.VEGETATION_INDEX_TYPE_UNSPECIFIED)
    ..aE<ComputeStatus>(6, _omitFieldNames ? '' : 'status',
        enumValues: ComputeStatus.values)
    ..aOS(7, _omitFieldNames ? '' : 'errorMessage')
    ..aD(8, _omitFieldNames ? '' : 'computeTimeSeconds')
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'completedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeTask clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeTask copyWith(void Function(ComputeTask) updates) =>
      super.copyWith((message) => updates(message as ComputeTask))
          as ComputeTask;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ComputeTask create() => ComputeTask._();
  @$core.override
  ComputeTask createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ComputeTask getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ComputeTask>(create);
  static ComputeTask? _defaultInstance;

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
  $core.String get processingJobId => $_getSZ(2);
  @$pb.TagNumber(3)
  set processingJobId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProcessingJobId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProcessingJobId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get farmId => $_getSZ(3);
  @$pb.TagNumber(4)
  set farmId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFarmId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFarmId() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<VegetationIndexType> get indexTypes => $_getList(4);

  @$pb.TagNumber(6)
  ComputeStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(ComputeStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get errorMessage => $_getSZ(6);
  @$pb.TagNumber(7)
  set errorMessage($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasErrorMessage() => $_has(6);
  @$pb.TagNumber(7)
  void clearErrorMessage() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get computeTimeSeconds => $_getN(7);
  @$pb.TagNumber(8)
  set computeTimeSeconds($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasComputeTimeSeconds() => $_has(7);
  @$pb.TagNumber(8)
  void clearComputeTimeSeconds() => $_clearField(8);

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

  @$pb.TagNumber(10)
  $0.Timestamp get completedAt => $_getN(9);
  @$pb.TagNumber(10)
  set completedAt($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCompletedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCompletedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureCompletedAt() => $_ensure(9);
}

class NDVITimeSeries extends $pb.GeneratedMessage {
  factory NDVITimeSeries({
    $core.String? farmId,
    $core.String? fieldId,
    $core.Iterable<TimeSeriesPoint>? points,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (points != null) result.points.addAll(points);
    return result;
  }

  NDVITimeSeries._();

  factory NDVITimeSeries.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NDVITimeSeries.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NDVITimeSeries',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.vegetation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..pPM<TimeSeriesPoint>(3, _omitFieldNames ? '' : 'points',
        subBuilder: TimeSeriesPoint.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NDVITimeSeries clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NDVITimeSeries copyWith(void Function(NDVITimeSeries) updates) =>
      super.copyWith((message) => updates(message as NDVITimeSeries))
          as NDVITimeSeries;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NDVITimeSeries create() => NDVITimeSeries._();
  @$core.override
  NDVITimeSeries createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NDVITimeSeries getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NDVITimeSeries>(create);
  static NDVITimeSeries? _defaultInstance;

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
  $pb.PbList<TimeSeriesPoint> get points => $_getList(2);
}

class TimeSeriesPoint extends $pb.GeneratedMessage {
  factory TimeSeriesPoint({
    $0.Timestamp? date,
    $core.double? value,
    $core.double? stdDeviation,
  }) {
    final result = create();
    if (date != null) result.date = date;
    if (value != null) result.value = value;
    if (stdDeviation != null) result.stdDeviation = stdDeviation;
    return result;
  }

  TimeSeriesPoint._();

  factory TimeSeriesPoint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TimeSeriesPoint.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeSeriesPoint',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.vegetation.v1'),
      createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'date',
        subBuilder: $0.Timestamp.create)
    ..aD(2, _omitFieldNames ? '' : 'value')
    ..aD(3, _omitFieldNames ? '' : 'stdDeviation')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeSeriesPoint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeSeriesPoint copyWith(void Function(TimeSeriesPoint) updates) =>
      super.copyWith((message) => updates(message as TimeSeriesPoint))
          as TimeSeriesPoint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TimeSeriesPoint create() => TimeSeriesPoint._();
  @$core.override
  TimeSeriesPoint createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TimeSeriesPoint getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimeSeriesPoint>(create);
  static TimeSeriesPoint? _defaultInstance;

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
  $core.double get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get stdDeviation => $_getN(2);
  @$pb.TagNumber(3)
  set stdDeviation($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStdDeviation() => $_has(2);
  @$pb.TagNumber(3)
  void clearStdDeviation() => $_clearField(3);
}

class ComputeIndicesRequest extends $pb.GeneratedMessage {
  factory ComputeIndicesRequest({
    $core.String? processingJobId,
    $core.String? farmId,
    $core.Iterable<VegetationIndexType>? indexTypes,
  }) {
    final result = create();
    if (processingJobId != null) result.processingJobId = processingJobId;
    if (farmId != null) result.farmId = farmId;
    if (indexTypes != null) result.indexTypes.addAll(indexTypes);
    return result;
  }

  ComputeIndicesRequest._();

  factory ComputeIndicesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ComputeIndicesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ComputeIndicesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.vegetation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'processingJobId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..pc<VegetationIndexType>(
        3, _omitFieldNames ? '' : 'indexTypes', $pb.PbFieldType.KE,
        valueOf: VegetationIndexType.valueOf,
        enumValues: VegetationIndexType.values,
        defaultEnumValue: VegetationIndexType.VEGETATION_INDEX_TYPE_UNSPECIFIED)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeIndicesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeIndicesRequest copyWith(
          void Function(ComputeIndicesRequest) updates) =>
      super.copyWith((message) => updates(message as ComputeIndicesRequest))
          as ComputeIndicesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ComputeIndicesRequest create() => ComputeIndicesRequest._();
  @$core.override
  ComputeIndicesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ComputeIndicesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ComputeIndicesRequest>(create);
  static ComputeIndicesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get processingJobId => $_getSZ(0);
  @$pb.TagNumber(1)
  set processingJobId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProcessingJobId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProcessingJobId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFarmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFarmId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<VegetationIndexType> get indexTypes => $_getList(2);
}

class ComputeIndicesResponse extends $pb.GeneratedMessage {
  factory ComputeIndicesResponse({
    ComputeTask? task,
  }) {
    final result = create();
    if (task != null) result.task = task;
    return result;
  }

  ComputeIndicesResponse._();

  factory ComputeIndicesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ComputeIndicesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ComputeIndicesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.vegetation.v1'),
      createEmptyInstance: create)
    ..aOM<ComputeTask>(1, _omitFieldNames ? '' : 'task',
        subBuilder: ComputeTask.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeIndicesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeIndicesResponse copyWith(
          void Function(ComputeIndicesResponse) updates) =>
      super.copyWith((message) => updates(message as ComputeIndicesResponse))
          as ComputeIndicesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ComputeIndicesResponse create() => ComputeIndicesResponse._();
  @$core.override
  ComputeIndicesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ComputeIndicesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ComputeIndicesResponse>(create);
  static ComputeIndicesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ComputeTask get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(ComputeTask value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  ComputeTask ensureTask() => $_ensure(0);
}

class GetVegetationIndexRequest extends $pb.GeneratedMessage {
  factory GetVegetationIndexRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetVegetationIndexRequest._();

  factory GetVegetationIndexRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetVegetationIndexRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetVegetationIndexRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.vegetation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVegetationIndexRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVegetationIndexRequest copyWith(
          void Function(GetVegetationIndexRequest) updates) =>
      super.copyWith((message) => updates(message as GetVegetationIndexRequest))
          as GetVegetationIndexRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetVegetationIndexRequest create() => GetVegetationIndexRequest._();
  @$core.override
  GetVegetationIndexRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetVegetationIndexRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetVegetationIndexRequest>(create);
  static GetVegetationIndexRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetVegetationIndexResponse extends $pb.GeneratedMessage {
  factory GetVegetationIndexResponse({
    VegetationIndex? index,
  }) {
    final result = create();
    if (index != null) result.index = index;
    return result;
  }

  GetVegetationIndexResponse._();

  factory GetVegetationIndexResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetVegetationIndexResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetVegetationIndexResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.vegetation.v1'),
      createEmptyInstance: create)
    ..aOM<VegetationIndex>(1, _omitFieldNames ? '' : 'index',
        subBuilder: VegetationIndex.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVegetationIndexResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVegetationIndexResponse copyWith(
          void Function(GetVegetationIndexResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetVegetationIndexResponse))
          as GetVegetationIndexResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetVegetationIndexResponse create() => GetVegetationIndexResponse._();
  @$core.override
  GetVegetationIndexResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetVegetationIndexResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetVegetationIndexResponse>(create);
  static GetVegetationIndexResponse? _defaultInstance;

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
}

class ListVegetationIndicesRequest extends $pb.GeneratedMessage {
  factory ListVegetationIndicesRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? farmId,
    $core.String? fieldId,
    VegetationIndexType? indexType,
    $0.Timestamp? dateFrom,
    $0.Timestamp? dateTo,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (indexType != null) result.indexType = indexType;
    if (dateFrom != null) result.dateFrom = dateFrom;
    if (dateTo != null) result.dateTo = dateTo;
    return result;
  }

  ListVegetationIndicesRequest._();

  factory ListVegetationIndicesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListVegetationIndicesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListVegetationIndicesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.vegetation.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aE<VegetationIndexType>(5, _omitFieldNames ? '' : 'indexType',
        enumValues: VegetationIndexType.values)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'dateFrom',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'dateTo',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListVegetationIndicesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListVegetationIndicesRequest copyWith(
          void Function(ListVegetationIndicesRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ListVegetationIndicesRequest))
          as ListVegetationIndicesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListVegetationIndicesRequest create() =>
      ListVegetationIndicesRequest._();
  @$core.override
  ListVegetationIndicesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListVegetationIndicesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListVegetationIndicesRequest>(create);
  static ListVegetationIndicesRequest? _defaultInstance;

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
  VegetationIndexType get indexType => $_getN(4);
  @$pb.TagNumber(5)
  set indexType(VegetationIndexType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasIndexType() => $_has(4);
  @$pb.TagNumber(5)
  void clearIndexType() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get dateFrom => $_getN(5);
  @$pb.TagNumber(6)
  set dateFrom($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasDateFrom() => $_has(5);
  @$pb.TagNumber(6)
  void clearDateFrom() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureDateFrom() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Timestamp get dateTo => $_getN(6);
  @$pb.TagNumber(7)
  set dateTo($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasDateTo() => $_has(6);
  @$pb.TagNumber(7)
  void clearDateTo() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureDateTo() => $_ensure(6);
}

class ListVegetationIndicesResponse extends $pb.GeneratedMessage {
  factory ListVegetationIndicesResponse({
    $core.Iterable<VegetationIndex>? indices,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (indices != null) result.indices.addAll(indices);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListVegetationIndicesResponse._();

  factory ListVegetationIndicesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListVegetationIndicesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListVegetationIndicesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.vegetation.v1'),
      createEmptyInstance: create)
    ..pPM<VegetationIndex>(1, _omitFieldNames ? '' : 'indices',
        subBuilder: VegetationIndex.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListVegetationIndicesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListVegetationIndicesResponse copyWith(
          void Function(ListVegetationIndicesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListVegetationIndicesResponse))
          as ListVegetationIndicesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListVegetationIndicesResponse create() =>
      ListVegetationIndicesResponse._();
  @$core.override
  ListVegetationIndicesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListVegetationIndicesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListVegetationIndicesResponse>(create);
  static ListVegetationIndicesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<VegetationIndex> get indices => $_getList(0);

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

class GetNDVITimeSeriesRequest extends $pb.GeneratedMessage {
  factory GetNDVITimeSeriesRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $0.Timestamp? dateFrom,
    $0.Timestamp? dateTo,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (dateFrom != null) result.dateFrom = dateFrom;
    if (dateTo != null) result.dateTo = dateTo;
    return result;
  }

  GetNDVITimeSeriesRequest._();

  factory GetNDVITimeSeriesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNDVITimeSeriesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNDVITimeSeriesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.vegetation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'dateFrom',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'dateTo',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNDVITimeSeriesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNDVITimeSeriesRequest copyWith(
          void Function(GetNDVITimeSeriesRequest) updates) =>
      super.copyWith((message) => updates(message as GetNDVITimeSeriesRequest))
          as GetNDVITimeSeriesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNDVITimeSeriesRequest create() => GetNDVITimeSeriesRequest._();
  @$core.override
  GetNDVITimeSeriesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNDVITimeSeriesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNDVITimeSeriesRequest>(create);
  static GetNDVITimeSeriesRequest? _defaultInstance;

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
  $0.Timestamp get dateFrom => $_getN(2);
  @$pb.TagNumber(3)
  set dateFrom($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDateFrom() => $_has(2);
  @$pb.TagNumber(3)
  void clearDateFrom() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureDateFrom() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Timestamp get dateTo => $_getN(3);
  @$pb.TagNumber(4)
  set dateTo($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDateTo() => $_has(3);
  @$pb.TagNumber(4)
  void clearDateTo() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureDateTo() => $_ensure(3);
}

class GetNDVITimeSeriesResponse extends $pb.GeneratedMessage {
  factory GetNDVITimeSeriesResponse({
    NDVITimeSeries? timeSeries,
  }) {
    final result = create();
    if (timeSeries != null) result.timeSeries = timeSeries;
    return result;
  }

  GetNDVITimeSeriesResponse._();

  factory GetNDVITimeSeriesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetNDVITimeSeriesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetNDVITimeSeriesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.vegetation.v1'),
      createEmptyInstance: create)
    ..aOM<NDVITimeSeries>(1, _omitFieldNames ? '' : 'timeSeries',
        subBuilder: NDVITimeSeries.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNDVITimeSeriesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNDVITimeSeriesResponse copyWith(
          void Function(GetNDVITimeSeriesResponse) updates) =>
      super.copyWith((message) => updates(message as GetNDVITimeSeriesResponse))
          as GetNDVITimeSeriesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNDVITimeSeriesResponse create() => GetNDVITimeSeriesResponse._();
  @$core.override
  GetNDVITimeSeriesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetNDVITimeSeriesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNDVITimeSeriesResponse>(create);
  static GetNDVITimeSeriesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  NDVITimeSeries get timeSeries => $_getN(0);
  @$pb.TagNumber(1)
  set timeSeries(NDVITimeSeries value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTimeSeries() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimeSeries() => $_clearField(1);
  @$pb.TagNumber(1)
  NDVITimeSeries ensureTimeSeries() => $_ensure(0);
}

class GetFieldHealthRequest extends $pb.GeneratedMessage {
  factory GetFieldHealthRequest({
    $core.String? farmId,
    $core.String? fieldId,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    return result;
  }

  GetFieldHealthRequest._();

  factory GetFieldHealthRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFieldHealthRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFieldHealthRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.vegetation.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldHealthRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldHealthRequest copyWith(
          void Function(GetFieldHealthRequest) updates) =>
      super.copyWith((message) => updates(message as GetFieldHealthRequest))
          as GetFieldHealthRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFieldHealthRequest create() => GetFieldHealthRequest._();
  @$core.override
  GetFieldHealthRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFieldHealthRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFieldHealthRequest>(create);
  static GetFieldHealthRequest? _defaultInstance;

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
}

class GetFieldHealthResponse extends $pb.GeneratedMessage {
  factory GetFieldHealthResponse({
    $core.double? currentNdvi,
    $core.double? ndviTrend,
    $core.double? healthScore,
    $core.String? healthCategory,
    $0.Timestamp? lastComputed,
  }) {
    final result = create();
    if (currentNdvi != null) result.currentNdvi = currentNdvi;
    if (ndviTrend != null) result.ndviTrend = ndviTrend;
    if (healthScore != null) result.healthScore = healthScore;
    if (healthCategory != null) result.healthCategory = healthCategory;
    if (lastComputed != null) result.lastComputed = lastComputed;
    return result;
  }

  GetFieldHealthResponse._();

  factory GetFieldHealthResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFieldHealthResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFieldHealthResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.vegetation.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'currentNdvi')
    ..aD(2, _omitFieldNames ? '' : 'ndviTrend')
    ..aD(3, _omitFieldNames ? '' : 'healthScore')
    ..aOS(4, _omitFieldNames ? '' : 'healthCategory')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'lastComputed',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldHealthResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldHealthResponse copyWith(
          void Function(GetFieldHealthResponse) updates) =>
      super.copyWith((message) => updates(message as GetFieldHealthResponse))
          as GetFieldHealthResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFieldHealthResponse create() => GetFieldHealthResponse._();
  @$core.override
  GetFieldHealthResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFieldHealthResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFieldHealthResponse>(create);
  static GetFieldHealthResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get currentNdvi => $_getN(0);
  @$pb.TagNumber(1)
  set currentNdvi($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCurrentNdvi() => $_has(0);
  @$pb.TagNumber(1)
  void clearCurrentNdvi() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get ndviTrend => $_getN(1);
  @$pb.TagNumber(2)
  set ndviTrend($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNdviTrend() => $_has(1);
  @$pb.TagNumber(2)
  void clearNdviTrend() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get healthScore => $_getN(2);
  @$pb.TagNumber(3)
  set healthScore($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHealthScore() => $_has(2);
  @$pb.TagNumber(3)
  void clearHealthScore() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get healthCategory => $_getSZ(3);
  @$pb.TagNumber(4)
  set healthCategory($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHealthCategory() => $_has(3);
  @$pb.TagNumber(4)
  void clearHealthCategory() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get lastComputed => $_getN(4);
  @$pb.TagNumber(5)
  set lastComputed($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLastComputed() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastComputed() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureLastComputed() => $_ensure(4);
}

class VegetationIndexServiceApi {
  final $pb.RpcClient _client;

  VegetationIndexServiceApi(this._client);

  $async.Future<ComputeIndicesResponse> computeIndices(
          $pb.ClientContext? ctx, ComputeIndicesRequest request) =>
      _client.invoke<ComputeIndicesResponse>(ctx, 'VegetationIndexService',
          'ComputeIndices', request, ComputeIndicesResponse());
  $async.Future<GetVegetationIndexResponse> getVegetationIndex(
          $pb.ClientContext? ctx, GetVegetationIndexRequest request) =>
      _client.invoke<GetVegetationIndexResponse>(ctx, 'VegetationIndexService',
          'GetVegetationIndex', request, GetVegetationIndexResponse());
  $async.Future<ListVegetationIndicesResponse> listVegetationIndices(
          $pb.ClientContext? ctx, ListVegetationIndicesRequest request) =>
      _client.invoke<ListVegetationIndicesResponse>(
          ctx,
          'VegetationIndexService',
          'ListVegetationIndices',
          request,
          ListVegetationIndicesResponse());
  $async.Future<GetNDVITimeSeriesResponse> getNDVITimeSeries(
          $pb.ClientContext? ctx, GetNDVITimeSeriesRequest request) =>
      _client.invoke<GetNDVITimeSeriesResponse>(ctx, 'VegetationIndexService',
          'GetNDVITimeSeries', request, GetNDVITimeSeriesResponse());
  $async.Future<GetFieldHealthResponse> getFieldHealth(
          $pb.ClientContext? ctx, GetFieldHealthRequest request) =>
      _client.invoke<GetFieldHealthResponse>(ctx, 'VegetationIndexService',
          'GetFieldHealth', request, GetFieldHealthResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
