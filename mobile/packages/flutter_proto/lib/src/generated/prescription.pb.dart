// This is a generated file - do not edit.
//
// Generated from prescription.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'prescription.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'prescription.pbenum.dart';

/// RateRow is a single row of rate values (used to represent a 2D grid).
class RateRow extends $pb.GeneratedMessage {
  factory RateRow({
    $core.Iterable<$core.double>? values,
  }) {
    final result = create();
    if (values != null) result.values.addAll(values);
    return result;
  }

  RateRow._();

  factory RateRow.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RateRow.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RateRow',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.prescription.v1'),
      createEmptyInstance: create)
    ..p<$core.double>(1, _omitFieldNames ? '' : 'values', $pb.PbFieldType.KD)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RateRow clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RateRow copyWith(void Function(RateRow) updates) =>
      super.copyWith((message) => updates(message as RateRow)) as RateRow;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RateRow create() => RateRow._();
  @$core.override
  RateRow createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RateRow getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RateRow>(create);
  static RateRow? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.double> get values => $_getList(0);
}

/// SoilDataRow is a single row of soil data values.
class SoilDataRow extends $pb.GeneratedMessage {
  factory SoilDataRow({
    $core.Iterable<$core.double>? values,
  }) {
    final result = create();
    if (values != null) result.values.addAll(values);
    return result;
  }

  SoilDataRow._();

  factory SoilDataRow.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SoilDataRow.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SoilDataRow',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.prescription.v1'),
      createEmptyInstance: create)
    ..p<$core.double>(1, _omitFieldNames ? '' : 'values', $pb.PbFieldType.KD)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilDataRow clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilDataRow copyWith(void Function(SoilDataRow) updates) =>
      super.copyWith((message) => updates(message as SoilDataRow))
          as SoilDataRow;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SoilDataRow create() => SoilDataRow._();
  @$core.override
  SoilDataRow createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SoilDataRow getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SoilDataRow>(create);
  static SoilDataRow? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.double> get values => $_getList(0);
}

/// PrescriptionMap represents one prescription layer (e.g. fertilizer rates).
class PrescriptionMap extends $pb.GeneratedMessage {
  factory PrescriptionMap({
    $core.String? id,
    PrescriptionType? prescriptionType,
    $core.String? unit,
    $core.Iterable<RateRow>? rates,
    $core.double? avgRate,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (prescriptionType != null) result.prescriptionType = prescriptionType;
    if (unit != null) result.unit = unit;
    if (rates != null) result.rates.addAll(rates);
    if (avgRate != null) result.avgRate = avgRate;
    return result;
  }

  PrescriptionMap._();

  factory PrescriptionMap.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PrescriptionMap.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrescriptionMap',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.prescription.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<PrescriptionType>(2, _omitFieldNames ? '' : 'prescriptionType',
        enumValues: PrescriptionType.values)
    ..aOS(3, _omitFieldNames ? '' : 'unit')
    ..pPM<RateRow>(4, _omitFieldNames ? '' : 'rates',
        subBuilder: RateRow.create)
    ..aD(5, _omitFieldNames ? '' : 'avgRate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrescriptionMap clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrescriptionMap copyWith(void Function(PrescriptionMap) updates) =>
      super.copyWith((message) => updates(message as PrescriptionMap))
          as PrescriptionMap;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PrescriptionMap create() => PrescriptionMap._();
  @$core.override
  PrescriptionMap createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PrescriptionMap getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PrescriptionMap>(create);
  static PrescriptionMap? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  PrescriptionType get prescriptionType => $_getN(1);
  @$pb.TagNumber(2)
  set prescriptionType(PrescriptionType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPrescriptionType() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrescriptionType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get unit => $_getSZ(2);
  @$pb.TagNumber(3)
  set unit($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnit() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnit() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<RateRow> get rates => $_getList(3);

  @$pb.TagNumber(5)
  $core.double get avgRate => $_getN(4);
  @$pb.TagNumber(5)
  set avgRate($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAvgRate() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvgRate() => $_clearField(5);
}

/// ZoneSummary summarises prescription rates within a management zone.
class ZoneSummary extends $pb.GeneratedMessage {
  factory ZoneSummary({
    $core.String? zone,
    PrescriptionType? prescriptionType,
    $core.double? areaHectares,
    $core.double? minRate,
    $core.double? meanRate,
    $core.double? maxRate,
    $core.double? totalAmount,
  }) {
    final result = create();
    if (zone != null) result.zone = zone;
    if (prescriptionType != null) result.prescriptionType = prescriptionType;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (minRate != null) result.minRate = minRate;
    if (meanRate != null) result.meanRate = meanRate;
    if (maxRate != null) result.maxRate = maxRate;
    if (totalAmount != null) result.totalAmount = totalAmount;
    return result;
  }

  ZoneSummary._();

  factory ZoneSummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ZoneSummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ZoneSummary',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.prescription.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'zone')
    ..aE<PrescriptionType>(2, _omitFieldNames ? '' : 'prescriptionType',
        enumValues: PrescriptionType.values)
    ..aD(3, _omitFieldNames ? '' : 'areaHectares')
    ..aD(4, _omitFieldNames ? '' : 'minRate')
    ..aD(5, _omitFieldNames ? '' : 'meanRate')
    ..aD(6, _omitFieldNames ? '' : 'maxRate')
    ..aD(7, _omitFieldNames ? '' : 'totalAmount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ZoneSummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ZoneSummary copyWith(void Function(ZoneSummary) updates) =>
      super.copyWith((message) => updates(message as ZoneSummary))
          as ZoneSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ZoneSummary create() => ZoneSummary._();
  @$core.override
  ZoneSummary createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ZoneSummary getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ZoneSummary>(create);
  static ZoneSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get zone => $_getSZ(0);
  @$pb.TagNumber(1)
  set zone($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasZone() => $_has(0);
  @$pb.TagNumber(1)
  void clearZone() => $_clearField(1);

  @$pb.TagNumber(2)
  PrescriptionType get prescriptionType => $_getN(1);
  @$pb.TagNumber(2)
  set prescriptionType(PrescriptionType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPrescriptionType() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrescriptionType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get areaHectares => $_getN(2);
  @$pb.TagNumber(3)
  set areaHectares($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAreaHectares() => $_has(2);
  @$pb.TagNumber(3)
  void clearAreaHectares() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get minRate => $_getN(3);
  @$pb.TagNumber(4)
  set minRate($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMinRate() => $_has(3);
  @$pb.TagNumber(4)
  void clearMinRate() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get meanRate => $_getN(4);
  @$pb.TagNumber(5)
  set meanRate($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMeanRate() => $_has(4);
  @$pb.TagNumber(5)
  void clearMeanRate() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get maxRate => $_getN(5);
  @$pb.TagNumber(6)
  set maxRate($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxRate() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxRate() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get totalAmount => $_getN(6);
  @$pb.TagNumber(7)
  set totalAmount($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTotalAmount() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalAmount() => $_clearField(7);
}

/// PrescriptionBundle is the top-level prescription output for a field.
class PrescriptionBundle extends $pb.GeneratedMessage {
  factory PrescriptionBundle({
    $core.String? id,
    $core.String? fieldId,
    $core.String? fieldName,
    $core.String? cropType,
    $core.double? targetYield,
    $core.String? createdAt,
    $core.double? estimatedCostSavings,
    $core.double? estimatedYieldGain,
    $core.Iterable<PrescriptionMap>? prescriptions,
    $core.Iterable<ZoneSummary>? zoneSummaries,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fieldId != null) result.fieldId = fieldId;
    if (fieldName != null) result.fieldName = fieldName;
    if (cropType != null) result.cropType = cropType;
    if (targetYield != null) result.targetYield = targetYield;
    if (createdAt != null) result.createdAt = createdAt;
    if (estimatedCostSavings != null)
      result.estimatedCostSavings = estimatedCostSavings;
    if (estimatedYieldGain != null)
      result.estimatedYieldGain = estimatedYieldGain;
    if (prescriptions != null) result.prescriptions.addAll(prescriptions);
    if (zoneSummaries != null) result.zoneSummaries.addAll(zoneSummaries);
    return result;
  }

  PrescriptionBundle._();

  factory PrescriptionBundle.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PrescriptionBundle.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrescriptionBundle',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.prescription.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldName')
    ..aOS(4, _omitFieldNames ? '' : 'cropType')
    ..aD(5, _omitFieldNames ? '' : 'targetYield')
    ..aOS(6, _omitFieldNames ? '' : 'createdAt')
    ..aD(7, _omitFieldNames ? '' : 'estimatedCostSavings')
    ..aD(8, _omitFieldNames ? '' : 'estimatedYieldGain')
    ..pPM<PrescriptionMap>(9, _omitFieldNames ? '' : 'prescriptions',
        subBuilder: PrescriptionMap.create)
    ..pPM<ZoneSummary>(10, _omitFieldNames ? '' : 'zoneSummaries',
        subBuilder: ZoneSummary.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrescriptionBundle clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrescriptionBundle copyWith(void Function(PrescriptionBundle) updates) =>
      super.copyWith((message) => updates(message as PrescriptionBundle))
          as PrescriptionBundle;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PrescriptionBundle create() => PrescriptionBundle._();
  @$core.override
  PrescriptionBundle createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PrescriptionBundle getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PrescriptionBundle>(create);
  static PrescriptionBundle? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fieldName => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldName() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get cropType => $_getSZ(3);
  @$pb.TagNumber(4)
  set cropType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCropType() => $_has(3);
  @$pb.TagNumber(4)
  void clearCropType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get targetYield => $_getN(4);
  @$pb.TagNumber(5)
  set targetYield($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTargetYield() => $_has(4);
  @$pb.TagNumber(5)
  void clearTargetYield() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get createdAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set createdAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get estimatedCostSavings => $_getN(6);
  @$pb.TagNumber(7)
  set estimatedCostSavings($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEstimatedCostSavings() => $_has(6);
  @$pb.TagNumber(7)
  void clearEstimatedCostSavings() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get estimatedYieldGain => $_getN(7);
  @$pb.TagNumber(8)
  set estimatedYieldGain($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEstimatedYieldGain() => $_has(7);
  @$pb.TagNumber(8)
  void clearEstimatedYieldGain() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<PrescriptionMap> get prescriptions => $_getList(8);

  @$pb.TagNumber(10)
  $pb.PbList<ZoneSummary> get zoneSummaries => $_getList(9);
}

class ListPrescriptionsRequest extends $pb.GeneratedMessage {
  factory ListPrescriptionsRequest({
    PrescriptionType? prescriptionType,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (prescriptionType != null) result.prescriptionType = prescriptionType;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListPrescriptionsRequest._();

  factory ListPrescriptionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPrescriptionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPrescriptionsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.prescription.v1'),
      createEmptyInstance: create)
    ..aE<PrescriptionType>(1, _omitFieldNames ? '' : 'prescriptionType',
        enumValues: PrescriptionType.values)
    ..aI(2, _omitFieldNames ? '' : 'pageSize')
    ..aOS(3, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPrescriptionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPrescriptionsRequest copyWith(
          void Function(ListPrescriptionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListPrescriptionsRequest))
          as ListPrescriptionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPrescriptionsRequest create() => ListPrescriptionsRequest._();
  @$core.override
  ListPrescriptionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPrescriptionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPrescriptionsRequest>(create);
  static ListPrescriptionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  PrescriptionType get prescriptionType => $_getN(0);
  @$pb.TagNumber(1)
  set prescriptionType(PrescriptionType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPrescriptionType() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrescriptionType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get pageToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set pageToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageToken() => $_clearField(3);
}

class ListPrescriptionsResponse extends $pb.GeneratedMessage {
  factory ListPrescriptionsResponse({
    $core.Iterable<PrescriptionBundle>? prescriptions,
    $core.String? nextPageToken,
  }) {
    final result = create();
    if (prescriptions != null) result.prescriptions.addAll(prescriptions);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    return result;
  }

  ListPrescriptionsResponse._();

  factory ListPrescriptionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPrescriptionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPrescriptionsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.prescription.v1'),
      createEmptyInstance: create)
    ..pPM<PrescriptionBundle>(1, _omitFieldNames ? '' : 'prescriptions',
        subBuilder: PrescriptionBundle.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPrescriptionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPrescriptionsResponse copyWith(
          void Function(ListPrescriptionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListPrescriptionsResponse))
          as ListPrescriptionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPrescriptionsResponse create() => ListPrescriptionsResponse._();
  @$core.override
  ListPrescriptionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPrescriptionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPrescriptionsResponse>(create);
  static ListPrescriptionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PrescriptionBundle> get prescriptions => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);
}

class GetPrescriptionRequest extends $pb.GeneratedMessage {
  factory GetPrescriptionRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetPrescriptionRequest._();

  factory GetPrescriptionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPrescriptionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPrescriptionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.prescription.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPrescriptionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPrescriptionRequest copyWith(
          void Function(GetPrescriptionRequest) updates) =>
      super.copyWith((message) => updates(message as GetPrescriptionRequest))
          as GetPrescriptionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPrescriptionRequest create() => GetPrescriptionRequest._();
  @$core.override
  GetPrescriptionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPrescriptionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPrescriptionRequest>(create);
  static GetPrescriptionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetPrescriptionResponse extends $pb.GeneratedMessage {
  factory GetPrescriptionResponse({
    PrescriptionBundle? prescription,
  }) {
    final result = create();
    if (prescription != null) result.prescription = prescription;
    return result;
  }

  GetPrescriptionResponse._();

  factory GetPrescriptionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPrescriptionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPrescriptionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.prescription.v1'),
      createEmptyInstance: create)
    ..aOM<PrescriptionBundle>(1, _omitFieldNames ? '' : 'prescription',
        subBuilder: PrescriptionBundle.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPrescriptionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPrescriptionResponse copyWith(
          void Function(GetPrescriptionResponse) updates) =>
      super.copyWith((message) => updates(message as GetPrescriptionResponse))
          as GetPrescriptionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPrescriptionResponse create() => GetPrescriptionResponse._();
  @$core.override
  GetPrescriptionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPrescriptionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPrescriptionResponse>(create);
  static GetPrescriptionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PrescriptionBundle get prescription => $_getN(0);
  @$pb.TagNumber(1)
  set prescription(PrescriptionBundle value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPrescription() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrescription() => $_clearField(1);
  @$pb.TagNumber(1)
  PrescriptionBundle ensurePrescription() => $_ensure(0);
}

class GeneratePrescriptionRequest extends $pb.GeneratedMessage {
  factory GeneratePrescriptionRequest({
    $core.String? fieldId,
    $core.String? cropType,
    $core.double? targetYield,
    $core.Iterable<SoilDataRow>? soilData,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (cropType != null) result.cropType = cropType;
    if (targetYield != null) result.targetYield = targetYield;
    if (soilData != null) result.soilData.addAll(soilData);
    return result;
  }

  GeneratePrescriptionRequest._();

  factory GeneratePrescriptionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GeneratePrescriptionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GeneratePrescriptionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.prescription.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'cropType')
    ..aD(3, _omitFieldNames ? '' : 'targetYield')
    ..pPM<SoilDataRow>(4, _omitFieldNames ? '' : 'soilData',
        subBuilder: SoilDataRow.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeneratePrescriptionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeneratePrescriptionRequest copyWith(
          void Function(GeneratePrescriptionRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GeneratePrescriptionRequest))
          as GeneratePrescriptionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GeneratePrescriptionRequest create() =>
      GeneratePrescriptionRequest._();
  @$core.override
  GeneratePrescriptionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GeneratePrescriptionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GeneratePrescriptionRequest>(create);
  static GeneratePrescriptionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cropType => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropType() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get targetYield => $_getN(2);
  @$pb.TagNumber(3)
  set targetYield($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTargetYield() => $_has(2);
  @$pb.TagNumber(3)
  void clearTargetYield() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<SoilDataRow> get soilData => $_getList(3);
}

class GeneratePrescriptionResponse extends $pb.GeneratedMessage {
  factory GeneratePrescriptionResponse({
    PrescriptionBundle? prescription,
  }) {
    final result = create();
    if (prescription != null) result.prescription = prescription;
    return result;
  }

  GeneratePrescriptionResponse._();

  factory GeneratePrescriptionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GeneratePrescriptionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GeneratePrescriptionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.prescription.v1'),
      createEmptyInstance: create)
    ..aOM<PrescriptionBundle>(1, _omitFieldNames ? '' : 'prescription',
        subBuilder: PrescriptionBundle.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeneratePrescriptionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeneratePrescriptionResponse copyWith(
          void Function(GeneratePrescriptionResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GeneratePrescriptionResponse))
          as GeneratePrescriptionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GeneratePrescriptionResponse create() =>
      GeneratePrescriptionResponse._();
  @$core.override
  GeneratePrescriptionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GeneratePrescriptionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GeneratePrescriptionResponse>(create);
  static GeneratePrescriptionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PrescriptionBundle get prescription => $_getN(0);
  @$pb.TagNumber(1)
  set prescription(PrescriptionBundle value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPrescription() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrescription() => $_clearField(1);
  @$pb.TagNumber(1)
  PrescriptionBundle ensurePrescription() => $_ensure(0);
}

class ExportPrescriptionRequest extends $pb.GeneratedMessage {
  factory ExportPrescriptionRequest({
    $core.String? id,
    $core.String? format,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (format != null) result.format = format;
    return result;
  }

  ExportPrescriptionRequest._();

  factory ExportPrescriptionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExportPrescriptionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportPrescriptionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.prescription.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'format')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportPrescriptionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportPrescriptionRequest copyWith(
          void Function(ExportPrescriptionRequest) updates) =>
      super.copyWith((message) => updates(message as ExportPrescriptionRequest))
          as ExportPrescriptionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportPrescriptionRequest create() => ExportPrescriptionRequest._();
  @$core.override
  ExportPrescriptionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExportPrescriptionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportPrescriptionRequest>(create);
  static ExportPrescriptionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get format => $_getSZ(1);
  @$pb.TagNumber(2)
  set format($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFormat() => $_has(1);
  @$pb.TagNumber(2)
  void clearFormat() => $_clearField(2);
}

class ExportPrescriptionResponse extends $pb.GeneratedMessage {
  factory ExportPrescriptionResponse({
    $core.String? downloadUrl,
    $core.String? fileName,
  }) {
    final result = create();
    if (downloadUrl != null) result.downloadUrl = downloadUrl;
    if (fileName != null) result.fileName = fileName;
    return result;
  }

  ExportPrescriptionResponse._();

  factory ExportPrescriptionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExportPrescriptionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportPrescriptionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.prescription.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'downloadUrl')
    ..aOS(2, _omitFieldNames ? '' : 'fileName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportPrescriptionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportPrescriptionResponse copyWith(
          void Function(ExportPrescriptionResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ExportPrescriptionResponse))
          as ExportPrescriptionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportPrescriptionResponse create() => ExportPrescriptionResponse._();
  @$core.override
  ExportPrescriptionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExportPrescriptionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportPrescriptionResponse>(create);
  static ExportPrescriptionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get downloadUrl => $_getSZ(0);
  @$pb.TagNumber(1)
  set downloadUrl($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDownloadUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearDownloadUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fileName => $_getSZ(1);
  @$pb.TagNumber(2)
  set fileName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFileName() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileName() => $_clearField(2);
}

class PrescriptionServiceApi {
  final $pb.RpcClient _client;

  PrescriptionServiceApi(this._client);

  /// ListPrescriptions lists prescriptions with optional type filter and
  /// pagination.
  $async.Future<ListPrescriptionsResponse> listPrescriptions(
          $pb.ClientContext? ctx, ListPrescriptionsRequest request) =>
      _client.invoke<ListPrescriptionsResponse>(ctx, 'PrescriptionService',
          'ListPrescriptions', request, ListPrescriptionsResponse());

  /// GetPrescription returns a single prescription bundle by ID.
  $async.Future<GetPrescriptionResponse> getPrescription(
          $pb.ClientContext? ctx, GetPrescriptionRequest request) =>
      _client.invoke<GetPrescriptionResponse>(ctx, 'PrescriptionService',
          'GetPrescription', request, GetPrescriptionResponse());

  /// GeneratePrescription generates a new variable-rate prescription for a
  /// field.
  $async.Future<GeneratePrescriptionResponse> generatePrescription(
          $pb.ClientContext? ctx, GeneratePrescriptionRequest request) =>
      _client.invoke<GeneratePrescriptionResponse>(ctx, 'PrescriptionService',
          'GeneratePrescription', request, GeneratePrescriptionResponse());

  /// ExportPrescription exports a prescription in the requested format and
  /// returns a download URL.
  $async.Future<ExportPrescriptionResponse> exportPrescription(
          $pb.ClientContext? ctx, ExportPrescriptionRequest request) =>
      _client.invoke<ExportPrescriptionResponse>(ctx, 'PrescriptionService',
          'ExportPrescription', request, ExportPrescriptionResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
