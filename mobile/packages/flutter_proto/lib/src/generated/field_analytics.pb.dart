// This is a generated file - do not edit.
//
// Generated from field_analytics.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// FieldAnalyticsSummary contains aggregated analytics for a single field.
class FieldAnalyticsSummary extends $pb.GeneratedMessage {
  factory FieldAnalyticsSummary({
    $core.String? fieldId,
    $core.String? fieldName,
    $core.double? meanYield,
    $core.double? peakYield,
    $core.String? yieldTrend,
    $core.double? avgStressDays,
    $core.double? avgNdvi,
    $core.int? seasonsAnalyzed,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (fieldName != null) result.fieldName = fieldName;
    if (meanYield != null) result.meanYield = meanYield;
    if (peakYield != null) result.peakYield = peakYield;
    if (yieldTrend != null) result.yieldTrend = yieldTrend;
    if (avgStressDays != null) result.avgStressDays = avgStressDays;
    if (avgNdvi != null) result.avgNdvi = avgNdvi;
    if (seasonsAnalyzed != null) result.seasonsAnalyzed = seasonsAnalyzed;
    return result;
  }

  FieldAnalyticsSummary._();

  factory FieldAnalyticsSummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FieldAnalyticsSummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldAnalyticsSummary',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldName')
    ..aD(3, _omitFieldNames ? '' : 'meanYield')
    ..aD(4, _omitFieldNames ? '' : 'peakYield')
    ..aOS(5, _omitFieldNames ? '' : 'yieldTrend')
    ..aD(6, _omitFieldNames ? '' : 'avgStressDays')
    ..aD(7, _omitFieldNames ? '' : 'avgNdvi')
    ..aI(8, _omitFieldNames ? '' : 'seasonsAnalyzed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldAnalyticsSummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldAnalyticsSummary copyWith(
          void Function(FieldAnalyticsSummary) updates) =>
      super.copyWith((message) => updates(message as FieldAnalyticsSummary))
          as FieldAnalyticsSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FieldAnalyticsSummary create() => FieldAnalyticsSummary._();
  @$core.override
  FieldAnalyticsSummary createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FieldAnalyticsSummary getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldAnalyticsSummary>(create);
  static FieldAnalyticsSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldName => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldName() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get meanYield => $_getN(2);
  @$pb.TagNumber(3)
  set meanYield($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMeanYield() => $_has(2);
  @$pb.TagNumber(3)
  void clearMeanYield() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get peakYield => $_getN(3);
  @$pb.TagNumber(4)
  set peakYield($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPeakYield() => $_has(3);
  @$pb.TagNumber(4)
  void clearPeakYield() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get yieldTrend => $_getSZ(4);
  @$pb.TagNumber(5)
  set yieldTrend($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasYieldTrend() => $_has(4);
  @$pb.TagNumber(5)
  void clearYieldTrend() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get avgStressDays => $_getN(5);
  @$pb.TagNumber(6)
  set avgStressDays($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAvgStressDays() => $_has(5);
  @$pb.TagNumber(6)
  void clearAvgStressDays() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get avgNdvi => $_getN(6);
  @$pb.TagNumber(7)
  set avgNdvi($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAvgNdvi() => $_has(6);
  @$pb.TagNumber(7)
  void clearAvgNdvi() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get seasonsAnalyzed => $_getIZ(7);
  @$pb.TagNumber(8)
  set seasonsAnalyzed($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSeasonsAnalyzed() => $_has(7);
  @$pb.TagNumber(8)
  void clearSeasonsAnalyzed() => $_clearField(8);
}

/// YieldTrendPoint represents a single data point in a yield trend series.
class YieldTrendPoint extends $pb.GeneratedMessage {
  factory YieldTrendPoint({
    $core.String? season,
    $core.String? crop,
    $core.double? yieldValue,
    $core.double? ndvi,
  }) {
    final result = create();
    if (season != null) result.season = season;
    if (crop != null) result.crop = crop;
    if (yieldValue != null) result.yieldValue = yieldValue;
    if (ndvi != null) result.ndvi = ndvi;
    return result;
  }

  YieldTrendPoint._();

  factory YieldTrendPoint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory YieldTrendPoint.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'YieldTrendPoint',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'season')
    ..aOS(2, _omitFieldNames ? '' : 'crop')
    ..aD(3, _omitFieldNames ? '' : 'yieldValue')
    ..aD(4, _omitFieldNames ? '' : 'ndvi')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  YieldTrendPoint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  YieldTrendPoint copyWith(void Function(YieldTrendPoint) updates) =>
      super.copyWith((message) => updates(message as YieldTrendPoint))
          as YieldTrendPoint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static YieldTrendPoint create() => YieldTrendPoint._();
  @$core.override
  YieldTrendPoint createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static YieldTrendPoint getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<YieldTrendPoint>(create);
  static YieldTrendPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get season => $_getSZ(0);
  @$pb.TagNumber(1)
  set season($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeason() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeason() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get crop => $_getSZ(1);
  @$pb.TagNumber(2)
  set crop($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCrop() => $_has(1);
  @$pb.TagNumber(2)
  void clearCrop() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get yieldValue => $_getN(2);
  @$pb.TagNumber(3)
  set yieldValue($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasYieldValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearYieldValue() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get ndvi => $_getN(3);
  @$pb.TagNumber(4)
  set ndvi($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNdvi() => $_has(3);
  @$pb.TagNumber(4)
  void clearNdvi() => $_clearField(4);
}

/// SeasonComparison contains a season-by-season comparison for a field.
class SeasonComparison extends $pb.GeneratedMessage {
  factory SeasonComparison({
    $core.String? season,
    $core.String? crop,
    $core.double? yieldValue,
    $core.double? yieldVsMeanPct,
    $core.int? stressDays,
    $core.double? stressVsMeanPct,
    $core.double? ndviPeak,
    $core.double? ndviVsMeanPct,
    $core.Iterable<$core.String>? notableEvents,
  }) {
    final result = create();
    if (season != null) result.season = season;
    if (crop != null) result.crop = crop;
    if (yieldValue != null) result.yieldValue = yieldValue;
    if (yieldVsMeanPct != null) result.yieldVsMeanPct = yieldVsMeanPct;
    if (stressDays != null) result.stressDays = stressDays;
    if (stressVsMeanPct != null) result.stressVsMeanPct = stressVsMeanPct;
    if (ndviPeak != null) result.ndviPeak = ndviPeak;
    if (ndviVsMeanPct != null) result.ndviVsMeanPct = ndviVsMeanPct;
    if (notableEvents != null) result.notableEvents.addAll(notableEvents);
    return result;
  }

  SeasonComparison._();

  factory SeasonComparison.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SeasonComparison.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SeasonComparison',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'season')
    ..aOS(2, _omitFieldNames ? '' : 'crop')
    ..aD(3, _omitFieldNames ? '' : 'yieldValue')
    ..aD(4, _omitFieldNames ? '' : 'yieldVsMeanPct')
    ..aI(5, _omitFieldNames ? '' : 'stressDays')
    ..aD(6, _omitFieldNames ? '' : 'stressVsMeanPct')
    ..aD(7, _omitFieldNames ? '' : 'ndviPeak')
    ..aD(8, _omitFieldNames ? '' : 'ndviVsMeanPct')
    ..pPS(9, _omitFieldNames ? '' : 'notableEvents')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SeasonComparison clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SeasonComparison copyWith(void Function(SeasonComparison) updates) =>
      super.copyWith((message) => updates(message as SeasonComparison))
          as SeasonComparison;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SeasonComparison create() => SeasonComparison._();
  @$core.override
  SeasonComparison createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SeasonComparison getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SeasonComparison>(create);
  static SeasonComparison? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get season => $_getSZ(0);
  @$pb.TagNumber(1)
  set season($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeason() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeason() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get crop => $_getSZ(1);
  @$pb.TagNumber(2)
  set crop($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCrop() => $_has(1);
  @$pb.TagNumber(2)
  void clearCrop() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get yieldValue => $_getN(2);
  @$pb.TagNumber(3)
  set yieldValue($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasYieldValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearYieldValue() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get yieldVsMeanPct => $_getN(3);
  @$pb.TagNumber(4)
  set yieldVsMeanPct($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasYieldVsMeanPct() => $_has(3);
  @$pb.TagNumber(4)
  void clearYieldVsMeanPct() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get stressDays => $_getIZ(4);
  @$pb.TagNumber(5)
  set stressDays($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStressDays() => $_has(4);
  @$pb.TagNumber(5)
  void clearStressDays() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get stressVsMeanPct => $_getN(5);
  @$pb.TagNumber(6)
  set stressVsMeanPct($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStressVsMeanPct() => $_has(5);
  @$pb.TagNumber(6)
  void clearStressVsMeanPct() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get ndviPeak => $_getN(6);
  @$pb.TagNumber(7)
  set ndviPeak($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNdviPeak() => $_has(6);
  @$pb.TagNumber(7)
  void clearNdviPeak() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get ndviVsMeanPct => $_getN(7);
  @$pb.TagNumber(8)
  set ndviVsMeanPct($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNdviVsMeanPct() => $_has(7);
  @$pb.TagNumber(8)
  void clearNdviVsMeanPct() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<$core.String> get notableEvents => $_getList(8);
}

/// RotationAnalysis holds crop rotation analysis results for a field.
class RotationAnalysis extends $pb.GeneratedMessage {
  factory RotationAnalysis({
    $core.double? effectivenessScore,
    $core.double? diversityIndex,
    $core.int? rotationLength,
    $core.String? soilHealthImpact,
    $core.Iterable<$core.String>? rotationPattern,
    $core.Iterable<$core.String>? recommendations,
  }) {
    final result = create();
    if (effectivenessScore != null)
      result.effectivenessScore = effectivenessScore;
    if (diversityIndex != null) result.diversityIndex = diversityIndex;
    if (rotationLength != null) result.rotationLength = rotationLength;
    if (soilHealthImpact != null) result.soilHealthImpact = soilHealthImpact;
    if (rotationPattern != null) result.rotationPattern.addAll(rotationPattern);
    if (recommendations != null) result.recommendations.addAll(recommendations);
    return result;
  }

  RotationAnalysis._();

  factory RotationAnalysis.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RotationAnalysis.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RotationAnalysis',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'effectivenessScore')
    ..aD(2, _omitFieldNames ? '' : 'diversityIndex')
    ..aI(3, _omitFieldNames ? '' : 'rotationLength')
    ..aOS(4, _omitFieldNames ? '' : 'soilHealthImpact')
    ..pPS(5, _omitFieldNames ? '' : 'rotationPattern')
    ..pPS(6, _omitFieldNames ? '' : 'recommendations')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RotationAnalysis clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RotationAnalysis copyWith(void Function(RotationAnalysis) updates) =>
      super.copyWith((message) => updates(message as RotationAnalysis))
          as RotationAnalysis;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RotationAnalysis create() => RotationAnalysis._();
  @$core.override
  RotationAnalysis createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RotationAnalysis getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RotationAnalysis>(create);
  static RotationAnalysis? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get effectivenessScore => $_getN(0);
  @$pb.TagNumber(1)
  set effectivenessScore($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEffectivenessScore() => $_has(0);
  @$pb.TagNumber(1)
  void clearEffectivenessScore() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get diversityIndex => $_getN(1);
  @$pb.TagNumber(2)
  set diversityIndex($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDiversityIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearDiversityIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get rotationLength => $_getIZ(2);
  @$pb.TagNumber(3)
  set rotationLength($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRotationLength() => $_has(2);
  @$pb.TagNumber(3)
  void clearRotationLength() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get soilHealthImpact => $_getSZ(3);
  @$pb.TagNumber(4)
  set soilHealthImpact($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSoilHealthImpact() => $_has(3);
  @$pb.TagNumber(4)
  void clearSoilHealthImpact() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get rotationPattern => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get recommendations => $_getList(5);
}

/// HistoricalMetrics contains aggregate metrics across fields.
class HistoricalMetrics extends $pb.GeneratedMessage {
  factory HistoricalMetrics({
    $core.double? meanYield,
    $core.double? peakYield,
    $core.String? yieldTrend,
    $core.double? avgStressDays,
    $core.double? avgNdvi,
    $core.int? seasonsAnalyzed,
    $core.Iterable<FieldAnalyticsSummary>? fields,
  }) {
    final result = create();
    if (meanYield != null) result.meanYield = meanYield;
    if (peakYield != null) result.peakYield = peakYield;
    if (yieldTrend != null) result.yieldTrend = yieldTrend;
    if (avgStressDays != null) result.avgStressDays = avgStressDays;
    if (avgNdvi != null) result.avgNdvi = avgNdvi;
    if (seasonsAnalyzed != null) result.seasonsAnalyzed = seasonsAnalyzed;
    if (fields != null) result.fields.addAll(fields);
    return result;
  }

  HistoricalMetrics._();

  factory HistoricalMetrics.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory HistoricalMetrics.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'HistoricalMetrics',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'meanYield')
    ..aD(2, _omitFieldNames ? '' : 'peakYield')
    ..aOS(3, _omitFieldNames ? '' : 'yieldTrend')
    ..aD(4, _omitFieldNames ? '' : 'avgStressDays')
    ..aD(5, _omitFieldNames ? '' : 'avgNdvi')
    ..aI(6, _omitFieldNames ? '' : 'seasonsAnalyzed')
    ..pPM<FieldAnalyticsSummary>(7, _omitFieldNames ? '' : 'fields',
        subBuilder: FieldAnalyticsSummary.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HistoricalMetrics clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HistoricalMetrics copyWith(void Function(HistoricalMetrics) updates) =>
      super.copyWith((message) => updates(message as HistoricalMetrics))
          as HistoricalMetrics;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static HistoricalMetrics create() => HistoricalMetrics._();
  @$core.override
  HistoricalMetrics createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static HistoricalMetrics getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HistoricalMetrics>(create);
  static HistoricalMetrics? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get meanYield => $_getN(0);
  @$pb.TagNumber(1)
  set meanYield($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMeanYield() => $_has(0);
  @$pb.TagNumber(1)
  void clearMeanYield() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get peakYield => $_getN(1);
  @$pb.TagNumber(2)
  set peakYield($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPeakYield() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeakYield() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get yieldTrend => $_getSZ(2);
  @$pb.TagNumber(3)
  set yieldTrend($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasYieldTrend() => $_has(2);
  @$pb.TagNumber(3)
  void clearYieldTrend() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get avgStressDays => $_getN(3);
  @$pb.TagNumber(4)
  set avgStressDays($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAvgStressDays() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvgStressDays() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get avgNdvi => $_getN(4);
  @$pb.TagNumber(5)
  set avgNdvi($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAvgNdvi() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvgNdvi() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get seasonsAnalyzed => $_getIZ(5);
  @$pb.TagNumber(6)
  set seasonsAnalyzed($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSeasonsAnalyzed() => $_has(5);
  @$pb.TagNumber(6)
  void clearSeasonsAnalyzed() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<FieldAnalyticsSummary> get fields => $_getList(6);
}

/// CrossFieldTrendPoint represents trend data for a single field in a
/// cross-field comparison.
class CrossFieldTrendPoint extends $pb.GeneratedMessage {
  factory CrossFieldTrendPoint({
    $core.String? fieldId,
    $core.String? fieldName,
    $core.Iterable<$core.double>? values,
    $core.Iterable<$core.String>? labels,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (fieldName != null) result.fieldName = fieldName;
    if (values != null) result.values.addAll(values);
    if (labels != null) result.labels.addAll(labels);
    return result;
  }

  CrossFieldTrendPoint._();

  factory CrossFieldTrendPoint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CrossFieldTrendPoint.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CrossFieldTrendPoint',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldName')
    ..p<$core.double>(3, _omitFieldNames ? '' : 'values', $pb.PbFieldType.KD)
    ..pPS(4, _omitFieldNames ? '' : 'labels')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CrossFieldTrendPoint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CrossFieldTrendPoint copyWith(void Function(CrossFieldTrendPoint) updates) =>
      super.copyWith((message) => updates(message as CrossFieldTrendPoint))
          as CrossFieldTrendPoint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CrossFieldTrendPoint create() => CrossFieldTrendPoint._();
  @$core.override
  CrossFieldTrendPoint createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CrossFieldTrendPoint getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CrossFieldTrendPoint>(create);
  static CrossFieldTrendPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldName => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldName() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldName() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.double> get values => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get labels => $_getList(3);
}

class GetHistoricalMetricsRequest extends $pb.GeneratedMessage {
  factory GetHistoricalMetricsRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? timePeriod,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (timePeriod != null) result.timePeriod = timePeriod;
    return result;
  }

  GetHistoricalMetricsRequest._();

  factory GetHistoricalMetricsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHistoricalMetricsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHistoricalMetricsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'timePeriod')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoricalMetricsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoricalMetricsRequest copyWith(
          void Function(GetHistoricalMetricsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetHistoricalMetricsRequest))
          as GetHistoricalMetricsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHistoricalMetricsRequest create() =>
      GetHistoricalMetricsRequest._();
  @$core.override
  GetHistoricalMetricsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHistoricalMetricsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHistoricalMetricsRequest>(create);
  static GetHistoricalMetricsRequest? _defaultInstance;

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
  $core.String get timePeriod => $_getSZ(2);
  @$pb.TagNumber(3)
  set timePeriod($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimePeriod() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimePeriod() => $_clearField(3);
}

class GetHistoricalMetricsResponse extends $pb.GeneratedMessage {
  factory GetHistoricalMetricsResponse({
    HistoricalMetrics? metrics,
  }) {
    final result = create();
    if (metrics != null) result.metrics = metrics;
    return result;
  }

  GetHistoricalMetricsResponse._();

  factory GetHistoricalMetricsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetHistoricalMetricsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetHistoricalMetricsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..aOM<HistoricalMetrics>(1, _omitFieldNames ? '' : 'metrics',
        subBuilder: HistoricalMetrics.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoricalMetricsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHistoricalMetricsResponse copyWith(
          void Function(GetHistoricalMetricsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetHistoricalMetricsResponse))
          as GetHistoricalMetricsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetHistoricalMetricsResponse create() =>
      GetHistoricalMetricsResponse._();
  @$core.override
  GetHistoricalMetricsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetHistoricalMetricsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHistoricalMetricsResponse>(create);
  static GetHistoricalMetricsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  HistoricalMetrics get metrics => $_getN(0);
  @$pb.TagNumber(1)
  set metrics(HistoricalMetrics value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMetrics() => $_has(0);
  @$pb.TagNumber(1)
  void clearMetrics() => $_clearField(1);
  @$pb.TagNumber(1)
  HistoricalMetrics ensureMetrics() => $_ensure(0);
}

class ListFieldAnalyticsRequest extends $pb.GeneratedMessage {
  factory ListFieldAnalyticsRequest({
    $core.String? farmId,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    return result;
  }

  ListFieldAnalyticsRequest._();

  factory ListFieldAnalyticsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListFieldAnalyticsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFieldAnalyticsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldAnalyticsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldAnalyticsRequest copyWith(
          void Function(ListFieldAnalyticsRequest) updates) =>
      super.copyWith((message) => updates(message as ListFieldAnalyticsRequest))
          as ListFieldAnalyticsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFieldAnalyticsRequest create() => ListFieldAnalyticsRequest._();
  @$core.override
  ListFieldAnalyticsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListFieldAnalyticsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFieldAnalyticsRequest>(create);
  static ListFieldAnalyticsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);
}

class ListFieldAnalyticsResponse extends $pb.GeneratedMessage {
  factory ListFieldAnalyticsResponse({
    $core.Iterable<FieldAnalyticsSummary>? summaries,
  }) {
    final result = create();
    if (summaries != null) result.summaries.addAll(summaries);
    return result;
  }

  ListFieldAnalyticsResponse._();

  factory ListFieldAnalyticsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListFieldAnalyticsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFieldAnalyticsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..pPM<FieldAnalyticsSummary>(1, _omitFieldNames ? '' : 'summaries',
        subBuilder: FieldAnalyticsSummary.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldAnalyticsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldAnalyticsResponse copyWith(
          void Function(ListFieldAnalyticsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListFieldAnalyticsResponse))
          as ListFieldAnalyticsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFieldAnalyticsResponse create() => ListFieldAnalyticsResponse._();
  @$core.override
  ListFieldAnalyticsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListFieldAnalyticsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFieldAnalyticsResponse>(create);
  static ListFieldAnalyticsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FieldAnalyticsSummary> get summaries => $_getList(0);
}

class GetFieldAnalyticsRequest extends $pb.GeneratedMessage {
  factory GetFieldAnalyticsRequest({
    $core.String? fieldId,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    return result;
  }

  GetFieldAnalyticsRequest._();

  factory GetFieldAnalyticsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFieldAnalyticsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFieldAnalyticsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldAnalyticsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldAnalyticsRequest copyWith(
          void Function(GetFieldAnalyticsRequest) updates) =>
      super.copyWith((message) => updates(message as GetFieldAnalyticsRequest))
          as GetFieldAnalyticsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFieldAnalyticsRequest create() => GetFieldAnalyticsRequest._();
  @$core.override
  GetFieldAnalyticsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFieldAnalyticsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFieldAnalyticsRequest>(create);
  static GetFieldAnalyticsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);
}

class GetFieldAnalyticsResponse extends $pb.GeneratedMessage {
  factory GetFieldAnalyticsResponse({
    FieldAnalyticsSummary? summary,
    $core.Iterable<YieldTrendPoint>? yieldTrends,
  }) {
    final result = create();
    if (summary != null) result.summary = summary;
    if (yieldTrends != null) result.yieldTrends.addAll(yieldTrends);
    return result;
  }

  GetFieldAnalyticsResponse._();

  factory GetFieldAnalyticsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFieldAnalyticsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFieldAnalyticsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..aOM<FieldAnalyticsSummary>(1, _omitFieldNames ? '' : 'summary',
        subBuilder: FieldAnalyticsSummary.create)
    ..pPM<YieldTrendPoint>(2, _omitFieldNames ? '' : 'yieldTrends',
        subBuilder: YieldTrendPoint.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldAnalyticsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldAnalyticsResponse copyWith(
          void Function(GetFieldAnalyticsResponse) updates) =>
      super.copyWith((message) => updates(message as GetFieldAnalyticsResponse))
          as GetFieldAnalyticsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFieldAnalyticsResponse create() => GetFieldAnalyticsResponse._();
  @$core.override
  GetFieldAnalyticsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFieldAnalyticsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFieldAnalyticsResponse>(create);
  static GetFieldAnalyticsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FieldAnalyticsSummary get summary => $_getN(0);
  @$pb.TagNumber(1)
  set summary(FieldAnalyticsSummary value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSummary() => $_has(0);
  @$pb.TagNumber(1)
  void clearSummary() => $_clearField(1);
  @$pb.TagNumber(1)
  FieldAnalyticsSummary ensureSummary() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<YieldTrendPoint> get yieldTrends => $_getList(1);
}

class GetSeasonComparisonsRequest extends $pb.GeneratedMessage {
  factory GetSeasonComparisonsRequest({
    $core.String? fieldId,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    return result;
  }

  GetSeasonComparisonsRequest._();

  factory GetSeasonComparisonsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSeasonComparisonsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSeasonComparisonsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSeasonComparisonsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSeasonComparisonsRequest copyWith(
          void Function(GetSeasonComparisonsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetSeasonComparisonsRequest))
          as GetSeasonComparisonsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSeasonComparisonsRequest create() =>
      GetSeasonComparisonsRequest._();
  @$core.override
  GetSeasonComparisonsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSeasonComparisonsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSeasonComparisonsRequest>(create);
  static GetSeasonComparisonsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);
}

class GetSeasonComparisonsResponse extends $pb.GeneratedMessage {
  factory GetSeasonComparisonsResponse({
    $core.Iterable<SeasonComparison>? comparisons,
  }) {
    final result = create();
    if (comparisons != null) result.comparisons.addAll(comparisons);
    return result;
  }

  GetSeasonComparisonsResponse._();

  factory GetSeasonComparisonsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSeasonComparisonsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSeasonComparisonsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..pPM<SeasonComparison>(1, _omitFieldNames ? '' : 'comparisons',
        subBuilder: SeasonComparison.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSeasonComparisonsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSeasonComparisonsResponse copyWith(
          void Function(GetSeasonComparisonsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetSeasonComparisonsResponse))
          as GetSeasonComparisonsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSeasonComparisonsResponse create() =>
      GetSeasonComparisonsResponse._();
  @$core.override
  GetSeasonComparisonsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSeasonComparisonsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSeasonComparisonsResponse>(create);
  static GetSeasonComparisonsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SeasonComparison> get comparisons => $_getList(0);
}

class GetRotationAnalysisRequest extends $pb.GeneratedMessage {
  factory GetRotationAnalysisRequest({
    $core.String? fieldId,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    return result;
  }

  GetRotationAnalysisRequest._();

  factory GetRotationAnalysisRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRotationAnalysisRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRotationAnalysisRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRotationAnalysisRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRotationAnalysisRequest copyWith(
          void Function(GetRotationAnalysisRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetRotationAnalysisRequest))
          as GetRotationAnalysisRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRotationAnalysisRequest create() => GetRotationAnalysisRequest._();
  @$core.override
  GetRotationAnalysisRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRotationAnalysisRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRotationAnalysisRequest>(create);
  static GetRotationAnalysisRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);
}

class GetRotationAnalysisResponse extends $pb.GeneratedMessage {
  factory GetRotationAnalysisResponse({
    RotationAnalysis? analysis,
  }) {
    final result = create();
    if (analysis != null) result.analysis = analysis;
    return result;
  }

  GetRotationAnalysisResponse._();

  factory GetRotationAnalysisResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRotationAnalysisResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRotationAnalysisResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..aOM<RotationAnalysis>(1, _omitFieldNames ? '' : 'analysis',
        subBuilder: RotationAnalysis.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRotationAnalysisResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRotationAnalysisResponse copyWith(
          void Function(GetRotationAnalysisResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetRotationAnalysisResponse))
          as GetRotationAnalysisResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRotationAnalysisResponse create() =>
      GetRotationAnalysisResponse._();
  @$core.override
  GetRotationAnalysisResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRotationAnalysisResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRotationAnalysisResponse>(create);
  static GetRotationAnalysisResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RotationAnalysis get analysis => $_getN(0);
  @$pb.TagNumber(1)
  set analysis(RotationAnalysis value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAnalysis() => $_has(0);
  @$pb.TagNumber(1)
  void clearAnalysis() => $_clearField(1);
  @$pb.TagNumber(1)
  RotationAnalysis ensureAnalysis() => $_ensure(0);
}

class GetCrossFieldTrendsRequest extends $pb.GeneratedMessage {
  factory GetCrossFieldTrendsRequest({
    $core.Iterable<$core.String>? fieldIds,
    $core.String? metric,
  }) {
    final result = create();
    if (fieldIds != null) result.fieldIds.addAll(fieldIds);
    if (metric != null) result.metric = metric;
    return result;
  }

  GetCrossFieldTrendsRequest._();

  factory GetCrossFieldTrendsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCrossFieldTrendsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCrossFieldTrendsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'fieldIds')
    ..aOS(2, _omitFieldNames ? '' : 'metric')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCrossFieldTrendsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCrossFieldTrendsRequest copyWith(
          void Function(GetCrossFieldTrendsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetCrossFieldTrendsRequest))
          as GetCrossFieldTrendsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCrossFieldTrendsRequest create() => GetCrossFieldTrendsRequest._();
  @$core.override
  GetCrossFieldTrendsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCrossFieldTrendsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCrossFieldTrendsRequest>(create);
  static GetCrossFieldTrendsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get fieldIds => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get metric => $_getSZ(1);
  @$pb.TagNumber(2)
  set metric($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMetric() => $_has(1);
  @$pb.TagNumber(2)
  void clearMetric() => $_clearField(2);
}

class GetCrossFieldTrendsResponse extends $pb.GeneratedMessage {
  factory GetCrossFieldTrendsResponse({
    $core.Iterable<CrossFieldTrendPoint>? trends,
  }) {
    final result = create();
    if (trends != null) result.trends.addAll(trends);
    return result;
  }

  GetCrossFieldTrendsResponse._();

  factory GetCrossFieldTrendsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCrossFieldTrendsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCrossFieldTrendsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.field.analytics.v1'),
      createEmptyInstance: create)
    ..pPM<CrossFieldTrendPoint>(1, _omitFieldNames ? '' : 'trends',
        subBuilder: CrossFieldTrendPoint.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCrossFieldTrendsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCrossFieldTrendsResponse copyWith(
          void Function(GetCrossFieldTrendsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetCrossFieldTrendsResponse))
          as GetCrossFieldTrendsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCrossFieldTrendsResponse create() =>
      GetCrossFieldTrendsResponse._();
  @$core.override
  GetCrossFieldTrendsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCrossFieldTrendsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCrossFieldTrendsResponse>(create);
  static GetCrossFieldTrendsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CrossFieldTrendPoint> get trends => $_getList(0);
}

class FieldAnalyticsServiceApi {
  final $pb.RpcClient _client;

  FieldAnalyticsServiceApi(this._client);

  /// GetHistoricalMetrics returns aggregate metrics with optional farm/field
  /// and time-period filters.
  $async.Future<GetHistoricalMetricsResponse> getHistoricalMetrics(
          $pb.ClientContext? ctx, GetHistoricalMetricsRequest request) =>
      _client.invoke<GetHistoricalMetricsResponse>(ctx, 'FieldAnalyticsService',
          'GetHistoricalMetrics', request, GetHistoricalMetricsResponse());

  /// ListFieldAnalytics lists analytics summaries for all fields, optionally
  /// filtered by farm.
  $async.Future<ListFieldAnalyticsResponse> listFieldAnalytics(
          $pb.ClientContext? ctx, ListFieldAnalyticsRequest request) =>
      _client.invoke<ListFieldAnalyticsResponse>(ctx, 'FieldAnalyticsService',
          'ListFieldAnalytics', request, ListFieldAnalyticsResponse());

  /// GetFieldAnalytics returns detailed analytics for a single field.
  $async.Future<GetFieldAnalyticsResponse> getFieldAnalytics(
          $pb.ClientContext? ctx, GetFieldAnalyticsRequest request) =>
      _client.invoke<GetFieldAnalyticsResponse>(ctx, 'FieldAnalyticsService',
          'GetFieldAnalytics', request, GetFieldAnalyticsResponse());

  /// GetSeasonComparisons returns season-by-season comparison data for a field.
  $async.Future<GetSeasonComparisonsResponse> getSeasonComparisons(
          $pb.ClientContext? ctx, GetSeasonComparisonsRequest request) =>
      _client.invoke<GetSeasonComparisonsResponse>(ctx, 'FieldAnalyticsService',
          'GetSeasonComparisons', request, GetSeasonComparisonsResponse());

  /// GetRotationAnalysis returns crop rotation analysis for a field.
  $async.Future<GetRotationAnalysisResponse> getRotationAnalysis(
          $pb.ClientContext? ctx, GetRotationAnalysisRequest request) =>
      _client.invoke<GetRotationAnalysisResponse>(ctx, 'FieldAnalyticsService',
          'GetRotationAnalysis', request, GetRotationAnalysisResponse());

  /// GetCrossFieldTrends returns multi-field trend comparison data.
  $async.Future<GetCrossFieldTrendsResponse> getCrossFieldTrends(
          $pb.ClientContext? ctx, GetCrossFieldTrendsRequest request) =>
      _client.invoke<GetCrossFieldTrendsResponse>(ctx, 'FieldAnalyticsService',
          'GetCrossFieldTrends', request, GetCrossFieldTrendsResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
