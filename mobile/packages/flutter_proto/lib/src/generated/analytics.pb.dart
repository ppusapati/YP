// This is a generated file - do not edit.
//
// Generated from analytics.proto.

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

import 'analytics.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'analytics.pbenum.dart';

class StressAlert extends $pb.GeneratedMessage {
  factory StressAlert({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? fieldId,
    StressType? stressType,
    SeverityLevel? severity,
    $core.double? confidence,
    $core.double? affectedAreaHectares,
    $core.double? affectedPercentage,
    $core.String? bboxGeojson,
    $core.String? description,
    $core.String? recommendation,
    $core.bool? acknowledged,
    $0.Timestamp? detectedAt,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (stressType != null) result.stressType = stressType;
    if (severity != null) result.severity = severity;
    if (confidence != null) result.confidence = confidence;
    if (affectedAreaHectares != null)
      result.affectedAreaHectares = affectedAreaHectares;
    if (affectedPercentage != null)
      result.affectedPercentage = affectedPercentage;
    if (bboxGeojson != null) result.bboxGeojson = bboxGeojson;
    if (description != null) result.description = description;
    if (recommendation != null) result.recommendation = recommendation;
    if (acknowledged != null) result.acknowledged = acknowledged;
    if (detectedAt != null) result.detectedAt = detectedAt;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  StressAlert._();

  factory StressAlert.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StressAlert.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StressAlert',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.analytics.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aE<StressType>(5, _omitFieldNames ? '' : 'stressType',
        enumValues: StressType.values)
    ..aE<SeverityLevel>(6, _omitFieldNames ? '' : 'severity',
        enumValues: SeverityLevel.values)
    ..aD(7, _omitFieldNames ? '' : 'confidence')
    ..aD(8, _omitFieldNames ? '' : 'affectedAreaHectares')
    ..aD(9, _omitFieldNames ? '' : 'affectedPercentage')
    ..aOS(10, _omitFieldNames ? '' : 'bboxGeojson')
    ..aOS(11, _omitFieldNames ? '' : 'description')
    ..aOS(12, _omitFieldNames ? '' : 'recommendation')
    ..aOB(13, _omitFieldNames ? '' : 'acknowledged')
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'detectedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StressAlert clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StressAlert copyWith(void Function(StressAlert) updates) =>
      super.copyWith((message) => updates(message as StressAlert))
          as StressAlert;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StressAlert create() => StressAlert._();
  @$core.override
  StressAlert createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StressAlert getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StressAlert>(create);
  static StressAlert? _defaultInstance;

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
  StressType get stressType => $_getN(4);
  @$pb.TagNumber(5)
  set stressType(StressType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStressType() => $_has(4);
  @$pb.TagNumber(5)
  void clearStressType() => $_clearField(5);

  @$pb.TagNumber(6)
  SeverityLevel get severity => $_getN(5);
  @$pb.TagNumber(6)
  set severity(SeverityLevel value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSeverity() => $_has(5);
  @$pb.TagNumber(6)
  void clearSeverity() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get confidence => $_getN(6);
  @$pb.TagNumber(7)
  set confidence($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasConfidence() => $_has(6);
  @$pb.TagNumber(7)
  void clearConfidence() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get affectedAreaHectares => $_getN(7);
  @$pb.TagNumber(8)
  set affectedAreaHectares($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAffectedAreaHectares() => $_has(7);
  @$pb.TagNumber(8)
  void clearAffectedAreaHectares() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get affectedPercentage => $_getN(8);
  @$pb.TagNumber(9)
  set affectedPercentage($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasAffectedPercentage() => $_has(8);
  @$pb.TagNumber(9)
  void clearAffectedPercentage() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get bboxGeojson => $_getSZ(9);
  @$pb.TagNumber(10)
  set bboxGeojson($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasBboxGeojson() => $_has(9);
  @$pb.TagNumber(10)
  void clearBboxGeojson() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get description => $_getSZ(10);
  @$pb.TagNumber(11)
  set description($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDescription() => $_has(10);
  @$pb.TagNumber(11)
  void clearDescription() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get recommendation => $_getSZ(11);
  @$pb.TagNumber(12)
  set recommendation($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasRecommendation() => $_has(11);
  @$pb.TagNumber(12)
  void clearRecommendation() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get acknowledged => $_getBF(12);
  @$pb.TagNumber(13)
  set acknowledged($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasAcknowledged() => $_has(12);
  @$pb.TagNumber(13)
  void clearAcknowledged() => $_clearField(13);

  @$pb.TagNumber(14)
  $0.Timestamp get detectedAt => $_getN(13);
  @$pb.TagNumber(14)
  set detectedAt($0.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasDetectedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearDetectedAt() => $_clearField(14);
  @$pb.TagNumber(14)
  $0.Timestamp ensureDetectedAt() => $_ensure(13);

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

class TemporalAnalysis extends $pb.GeneratedMessage {
  factory TemporalAnalysis({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? fieldId,
    AnalysisType? analysisType,
    $core.String? metricName,
    $core.double? trendSlope,
    $core.double? trendRSquared,
    $core.double? currentValue,
    $core.double? baselineValue,
    $core.double? deviationPercent,
    $0.Timestamp? periodStart,
    $0.Timestamp? periodEnd,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (analysisType != null) result.analysisType = analysisType;
    if (metricName != null) result.metricName = metricName;
    if (trendSlope != null) result.trendSlope = trendSlope;
    if (trendRSquared != null) result.trendRSquared = trendRSquared;
    if (currentValue != null) result.currentValue = currentValue;
    if (baselineValue != null) result.baselineValue = baselineValue;
    if (deviationPercent != null) result.deviationPercent = deviationPercent;
    if (periodStart != null) result.periodStart = periodStart;
    if (periodEnd != null) result.periodEnd = periodEnd;
    if (createdAt != null) result.createdAt = createdAt;
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
          _omitMessageNames ? '' : 'agriculture.satellite.analytics.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aE<AnalysisType>(5, _omitFieldNames ? '' : 'analysisType',
        enumValues: AnalysisType.values)
    ..aOS(6, _omitFieldNames ? '' : 'metricName')
    ..aD(7, _omitFieldNames ? '' : 'trendSlope')
    ..aD(8, _omitFieldNames ? '' : 'trendRSquared')
    ..aD(9, _omitFieldNames ? '' : 'currentValue')
    ..aD(10, _omitFieldNames ? '' : 'baselineValue')
    ..aD(11, _omitFieldNames ? '' : 'deviationPercent')
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'periodStart',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'periodEnd',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'createdAt',
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
  AnalysisType get analysisType => $_getN(4);
  @$pb.TagNumber(5)
  set analysisType(AnalysisType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasAnalysisType() => $_has(4);
  @$pb.TagNumber(5)
  void clearAnalysisType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get metricName => $_getSZ(5);
  @$pb.TagNumber(6)
  set metricName($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMetricName() => $_has(5);
  @$pb.TagNumber(6)
  void clearMetricName() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get trendSlope => $_getN(6);
  @$pb.TagNumber(7)
  set trendSlope($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTrendSlope() => $_has(6);
  @$pb.TagNumber(7)
  void clearTrendSlope() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get trendRSquared => $_getN(7);
  @$pb.TagNumber(8)
  set trendRSquared($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTrendRSquared() => $_has(7);
  @$pb.TagNumber(8)
  void clearTrendRSquared() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get currentValue => $_getN(8);
  @$pb.TagNumber(9)
  set currentValue($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCurrentValue() => $_has(8);
  @$pb.TagNumber(9)
  void clearCurrentValue() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get baselineValue => $_getN(9);
  @$pb.TagNumber(10)
  set baselineValue($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasBaselineValue() => $_has(9);
  @$pb.TagNumber(10)
  void clearBaselineValue() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get deviationPercent => $_getN(10);
  @$pb.TagNumber(11)
  set deviationPercent($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDeviationPercent() => $_has(10);
  @$pb.TagNumber(11)
  void clearDeviationPercent() => $_clearField(11);

  @$pb.TagNumber(12)
  $0.Timestamp get periodStart => $_getN(11);
  @$pb.TagNumber(12)
  set periodStart($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasPeriodStart() => $_has(11);
  @$pb.TagNumber(12)
  void clearPeriodStart() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensurePeriodStart() => $_ensure(11);

  @$pb.TagNumber(13)
  $0.Timestamp get periodEnd => $_getN(12);
  @$pb.TagNumber(13)
  set periodEnd($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasPeriodEnd() => $_has(12);
  @$pb.TagNumber(13)
  void clearPeriodEnd() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensurePeriodEnd() => $_ensure(12);

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
}

class DetectStressRequest extends $pb.GeneratedMessage {
  factory DetectStressRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? processingJobId,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (processingJobId != null) result.processingJobId = processingJobId;
    return result;
  }

  DetectStressRequest._();

  factory DetectStressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectStressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectStressRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.analytics.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'processingJobId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectStressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectStressRequest copyWith(void Function(DetectStressRequest) updates) =>
      super.copyWith((message) => updates(message as DetectStressRequest))
          as DetectStressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectStressRequest create() => DetectStressRequest._();
  @$core.override
  DetectStressRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectStressRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectStressRequest>(create);
  static DetectStressRequest? _defaultInstance;

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
  $core.String get processingJobId => $_getSZ(2);
  @$pb.TagNumber(3)
  set processingJobId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasProcessingJobId() => $_has(2);
  @$pb.TagNumber(3)
  void clearProcessingJobId() => $_clearField(3);
}

class DetectStressResponse extends $pb.GeneratedMessage {
  factory DetectStressResponse({
    $core.Iterable<StressAlert>? alerts,
  }) {
    final result = create();
    if (alerts != null) result.alerts.addAll(alerts);
    return result;
  }

  DetectStressResponse._();

  factory DetectStressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectStressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectStressResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.analytics.v1'),
      createEmptyInstance: create)
    ..pPM<StressAlert>(1, _omitFieldNames ? '' : 'alerts',
        subBuilder: StressAlert.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectStressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectStressResponse copyWith(void Function(DetectStressResponse) updates) =>
      super.copyWith((message) => updates(message as DetectStressResponse))
          as DetectStressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectStressResponse create() => DetectStressResponse._();
  @$core.override
  DetectStressResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectStressResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectStressResponse>(create);
  static DetectStressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<StressAlert> get alerts => $_getList(0);
}

class ListStressAlertsRequest extends $pb.GeneratedMessage {
  factory ListStressAlertsRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? farmId,
    StressType? stressType,
    SeverityLevel? minSeverity,
    $core.bool? unacknowledgedOnly,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (farmId != null) result.farmId = farmId;
    if (stressType != null) result.stressType = stressType;
    if (minSeverity != null) result.minSeverity = minSeverity;
    if (unacknowledgedOnly != null)
      result.unacknowledgedOnly = unacknowledgedOnly;
    return result;
  }

  ListStressAlertsRequest._();

  factory ListStressAlertsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListStressAlertsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListStressAlertsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.analytics.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aE<StressType>(4, _omitFieldNames ? '' : 'stressType',
        enumValues: StressType.values)
    ..aE<SeverityLevel>(5, _omitFieldNames ? '' : 'minSeverity',
        enumValues: SeverityLevel.values)
    ..aOB(6, _omitFieldNames ? '' : 'unacknowledgedOnly')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListStressAlertsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListStressAlertsRequest copyWith(
          void Function(ListStressAlertsRequest) updates) =>
      super.copyWith((message) => updates(message as ListStressAlertsRequest))
          as ListStressAlertsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListStressAlertsRequest create() => ListStressAlertsRequest._();
  @$core.override
  ListStressAlertsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListStressAlertsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListStressAlertsRequest>(create);
  static ListStressAlertsRequest? _defaultInstance;

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
  StressType get stressType => $_getN(3);
  @$pb.TagNumber(4)
  set stressType(StressType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStressType() => $_has(3);
  @$pb.TagNumber(4)
  void clearStressType() => $_clearField(4);

  @$pb.TagNumber(5)
  SeverityLevel get minSeverity => $_getN(4);
  @$pb.TagNumber(5)
  set minSeverity(SeverityLevel value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasMinSeverity() => $_has(4);
  @$pb.TagNumber(5)
  void clearMinSeverity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get unacknowledgedOnly => $_getBF(5);
  @$pb.TagNumber(6)
  set unacknowledgedOnly($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUnacknowledgedOnly() => $_has(5);
  @$pb.TagNumber(6)
  void clearUnacknowledgedOnly() => $_clearField(6);
}

class ListStressAlertsResponse extends $pb.GeneratedMessage {
  factory ListStressAlertsResponse({
    $core.Iterable<StressAlert>? alerts,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (alerts != null) result.alerts.addAll(alerts);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListStressAlertsResponse._();

  factory ListStressAlertsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListStressAlertsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListStressAlertsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.analytics.v1'),
      createEmptyInstance: create)
    ..pPM<StressAlert>(1, _omitFieldNames ? '' : 'alerts',
        subBuilder: StressAlert.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListStressAlertsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListStressAlertsResponse copyWith(
          void Function(ListStressAlertsResponse) updates) =>
      super.copyWith((message) => updates(message as ListStressAlertsResponse))
          as ListStressAlertsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListStressAlertsResponse create() => ListStressAlertsResponse._();
  @$core.override
  ListStressAlertsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListStressAlertsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListStressAlertsResponse>(create);
  static ListStressAlertsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<StressAlert> get alerts => $_getList(0);

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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.analytics.v1'),
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
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.analytics.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
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
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

class RunTemporalAnalysisRequest extends $pb.GeneratedMessage {
  factory RunTemporalAnalysisRequest({
    $core.String? farmId,
    $core.String? fieldId,
    AnalysisType? analysisType,
    $0.Timestamp? periodStart,
    $0.Timestamp? periodEnd,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (analysisType != null) result.analysisType = analysisType;
    if (periodStart != null) result.periodStart = periodStart;
    if (periodEnd != null) result.periodEnd = periodEnd;
    return result;
  }

  RunTemporalAnalysisRequest._();

  factory RunTemporalAnalysisRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RunTemporalAnalysisRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RunTemporalAnalysisRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.analytics.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aE<AnalysisType>(3, _omitFieldNames ? '' : 'analysisType',
        enumValues: AnalysisType.values)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'periodStart',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'periodEnd',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RunTemporalAnalysisRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RunTemporalAnalysisRequest copyWith(
          void Function(RunTemporalAnalysisRequest) updates) =>
      super.copyWith(
              (message) => updates(message as RunTemporalAnalysisRequest))
          as RunTemporalAnalysisRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RunTemporalAnalysisRequest create() => RunTemporalAnalysisRequest._();
  @$core.override
  RunTemporalAnalysisRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RunTemporalAnalysisRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RunTemporalAnalysisRequest>(create);
  static RunTemporalAnalysisRequest? _defaultInstance;

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
  AnalysisType get analysisType => $_getN(2);
  @$pb.TagNumber(3)
  set analysisType(AnalysisType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasAnalysisType() => $_has(2);
  @$pb.TagNumber(3)
  void clearAnalysisType() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get periodStart => $_getN(3);
  @$pb.TagNumber(4)
  set periodStart($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasPeriodStart() => $_has(3);
  @$pb.TagNumber(4)
  void clearPeriodStart() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensurePeriodStart() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Timestamp get periodEnd => $_getN(4);
  @$pb.TagNumber(5)
  set periodEnd($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasPeriodEnd() => $_has(4);
  @$pb.TagNumber(5)
  void clearPeriodEnd() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensurePeriodEnd() => $_ensure(4);
}

class RunTemporalAnalysisResponse extends $pb.GeneratedMessage {
  factory RunTemporalAnalysisResponse({
    TemporalAnalysis? analysis,
  }) {
    final result = create();
    if (analysis != null) result.analysis = analysis;
    return result;
  }

  RunTemporalAnalysisResponse._();

  factory RunTemporalAnalysisResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RunTemporalAnalysisResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RunTemporalAnalysisResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.analytics.v1'),
      createEmptyInstance: create)
    ..aOM<TemporalAnalysis>(1, _omitFieldNames ? '' : 'analysis',
        subBuilder: TemporalAnalysis.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RunTemporalAnalysisResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RunTemporalAnalysisResponse copyWith(
          void Function(RunTemporalAnalysisResponse) updates) =>
      super.copyWith(
              (message) => updates(message as RunTemporalAnalysisResponse))
          as RunTemporalAnalysisResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RunTemporalAnalysisResponse create() =>
      RunTemporalAnalysisResponse._();
  @$core.override
  RunTemporalAnalysisResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RunTemporalAnalysisResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RunTemporalAnalysisResponse>(create);
  static RunTemporalAnalysisResponse? _defaultInstance;

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

class GetFieldAnalyticsSummaryRequest extends $pb.GeneratedMessage {
  factory GetFieldAnalyticsSummaryRequest({
    $core.String? farmId,
    $core.String? fieldId,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    return result;
  }

  GetFieldAnalyticsSummaryRequest._();

  factory GetFieldAnalyticsSummaryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFieldAnalyticsSummaryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFieldAnalyticsSummaryRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.analytics.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldAnalyticsSummaryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldAnalyticsSummaryRequest copyWith(
          void Function(GetFieldAnalyticsSummaryRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetFieldAnalyticsSummaryRequest))
          as GetFieldAnalyticsSummaryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFieldAnalyticsSummaryRequest create() =>
      GetFieldAnalyticsSummaryRequest._();
  @$core.override
  GetFieldAnalyticsSummaryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFieldAnalyticsSummaryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFieldAnalyticsSummaryRequest>(
          create);
  static GetFieldAnalyticsSummaryRequest? _defaultInstance;

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

class GetFieldAnalyticsSummaryResponse extends $pb.GeneratedMessage {
  factory GetFieldAnalyticsSummaryResponse({
    $core.int? activeStressAlerts,
    $core.double? healthScore,
    $core.double? ndviTrend,
    $core.String? dominantStressType,
    $0.Timestamp? lastAnalysis,
  }) {
    final result = create();
    if (activeStressAlerts != null)
      result.activeStressAlerts = activeStressAlerts;
    if (healthScore != null) result.healthScore = healthScore;
    if (ndviTrend != null) result.ndviTrend = ndviTrend;
    if (dominantStressType != null)
      result.dominantStressType = dominantStressType;
    if (lastAnalysis != null) result.lastAnalysis = lastAnalysis;
    return result;
  }

  GetFieldAnalyticsSummaryResponse._();

  factory GetFieldAnalyticsSummaryResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFieldAnalyticsSummaryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFieldAnalyticsSummaryResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.analytics.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'activeStressAlerts')
    ..aD(2, _omitFieldNames ? '' : 'healthScore')
    ..aD(3, _omitFieldNames ? '' : 'ndviTrend')
    ..aOS(4, _omitFieldNames ? '' : 'dominantStressType')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'lastAnalysis',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldAnalyticsSummaryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldAnalyticsSummaryResponse copyWith(
          void Function(GetFieldAnalyticsSummaryResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetFieldAnalyticsSummaryResponse))
          as GetFieldAnalyticsSummaryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFieldAnalyticsSummaryResponse create() =>
      GetFieldAnalyticsSummaryResponse._();
  @$core.override
  GetFieldAnalyticsSummaryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFieldAnalyticsSummaryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFieldAnalyticsSummaryResponse>(
          create);
  static GetFieldAnalyticsSummaryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get activeStressAlerts => $_getIZ(0);
  @$pb.TagNumber(1)
  set activeStressAlerts($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasActiveStressAlerts() => $_has(0);
  @$pb.TagNumber(1)
  void clearActiveStressAlerts() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get healthScore => $_getN(1);
  @$pb.TagNumber(2)
  set healthScore($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHealthScore() => $_has(1);
  @$pb.TagNumber(2)
  void clearHealthScore() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get ndviTrend => $_getN(2);
  @$pb.TagNumber(3)
  set ndviTrend($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNdviTrend() => $_has(2);
  @$pb.TagNumber(3)
  void clearNdviTrend() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get dominantStressType => $_getSZ(3);
  @$pb.TagNumber(4)
  set dominantStressType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDominantStressType() => $_has(3);
  @$pb.TagNumber(4)
  void clearDominantStressType() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get lastAnalysis => $_getN(4);
  @$pb.TagNumber(5)
  set lastAnalysis($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLastAnalysis() => $_has(4);
  @$pb.TagNumber(5)
  void clearLastAnalysis() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureLastAnalysis() => $_ensure(4);
}

class SatelliteAnalyticsServiceApi {
  final $pb.RpcClient _client;

  SatelliteAnalyticsServiceApi(this._client);

  $async.Future<DetectStressResponse> detectStress(
          $pb.ClientContext? ctx, DetectStressRequest request) =>
      _client.invoke<DetectStressResponse>(ctx, 'SatelliteAnalyticsService',
          'DetectStress', request, DetectStressResponse());
  $async.Future<ListStressAlertsResponse> listStressAlerts(
          $pb.ClientContext? ctx, ListStressAlertsRequest request) =>
      _client.invoke<ListStressAlertsResponse>(ctx, 'SatelliteAnalyticsService',
          'ListStressAlerts', request, ListStressAlertsResponse());
  $async.Future<AcknowledgeAlertResponse> acknowledgeAlert(
          $pb.ClientContext? ctx, AcknowledgeAlertRequest request) =>
      _client.invoke<AcknowledgeAlertResponse>(ctx, 'SatelliteAnalyticsService',
          'AcknowledgeAlert', request, AcknowledgeAlertResponse());
  $async.Future<RunTemporalAnalysisResponse> runTemporalAnalysis(
          $pb.ClientContext? ctx, RunTemporalAnalysisRequest request) =>
      _client.invoke<RunTemporalAnalysisResponse>(
          ctx,
          'SatelliteAnalyticsService',
          'RunTemporalAnalysis',
          request,
          RunTemporalAnalysisResponse());
  $async.Future<GetFieldAnalyticsSummaryResponse> getFieldAnalyticsSummary(
          $pb.ClientContext? ctx, GetFieldAnalyticsSummaryRequest request) =>
      _client.invoke<GetFieldAnalyticsSummaryResponse>(
          ctx,
          'SatelliteAnalyticsService',
          'GetFieldAnalyticsSummary',
          request,
          GetFieldAnalyticsSummaryResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
