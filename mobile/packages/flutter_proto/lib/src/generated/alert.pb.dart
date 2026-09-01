// This is a generated file - do not edit.
//
// Generated from alert.proto.

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

import 'alert.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'alert.pbenum.dart';

class Alert extends $pb.GeneratedMessage {
  factory Alert({
    $core.String? id,
    $core.String? type,
    $core.String? title,
    $core.String? message,
    AlertSeverity? severity,
    AlertStatus? status,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? fieldName,
    $0.Timestamp? timestamp,
    $core.bool? read,
    $core.String? actionUrl,
    $core.Iterable<$core.String>? recommendations,
    $0.Timestamp? acknowledgedAt,
    $core.String? acknowledgedBy,
    $core.Iterable<$core.MapEntry<$core.String, $core.double>>? metrics,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (title != null) result.title = title;
    if (message != null) result.message = message;
    if (severity != null) result.severity = severity;
    if (status != null) result.status = status;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (fieldName != null) result.fieldName = fieldName;
    if (timestamp != null) result.timestamp = timestamp;
    if (read != null) result.read = read;
    if (actionUrl != null) result.actionUrl = actionUrl;
    if (recommendations != null) result.recommendations.addAll(recommendations);
    if (acknowledgedAt != null) result.acknowledgedAt = acknowledgedAt;
    if (acknowledgedBy != null) result.acknowledgedBy = acknowledgedBy;
    if (metrics != null) result.metrics.addEntries(metrics);
    return result;
  }

  Alert._();

  factory Alert.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Alert.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Alert',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'type')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..aE<AlertSeverity>(5, _omitFieldNames ? '' : 'severity',
        enumValues: AlertSeverity.values)
    ..aE<AlertStatus>(6, _omitFieldNames ? '' : 'status',
        enumValues: AlertStatus.values)
    ..aOS(7, _omitFieldNames ? '' : 'farmId')
    ..aOS(8, _omitFieldNames ? '' : 'fieldId')
    ..aOS(9, _omitFieldNames ? '' : 'fieldName')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOB(11, _omitFieldNames ? '' : 'read')
    ..aOS(12, _omitFieldNames ? '' : 'actionUrl')
    ..pPS(13, _omitFieldNames ? '' : 'recommendations')
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'acknowledgedAt',
        subBuilder: $0.Timestamp.create)
    ..aOS(15, _omitFieldNames ? '' : 'acknowledgedBy')
    ..m<$core.String, $core.double>(16, _omitFieldNames ? '' : 'metrics',
        entryClassName: 'Alert.MetricsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OD,
        packageName: const $pb.PackageName('agriculture.alert.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Alert clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Alert copyWith(void Function(Alert) updates) =>
      super.copyWith((message) => updates(message as Alert)) as Alert;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Alert create() => Alert._();
  @$core.override
  Alert createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Alert getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Alert>(create);
  static Alert? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get type => $_getSZ(1);
  @$pb.TagNumber(2)
  set type($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => $_clearField(4);

  @$pb.TagNumber(5)
  AlertSeverity get severity => $_getN(4);
  @$pb.TagNumber(5)
  set severity(AlertSeverity value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSeverity() => $_has(4);
  @$pb.TagNumber(5)
  void clearSeverity() => $_clearField(5);

  @$pb.TagNumber(6)
  AlertStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(AlertStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get farmId => $_getSZ(6);
  @$pb.TagNumber(7)
  set farmId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFarmId() => $_has(6);
  @$pb.TagNumber(7)
  void clearFarmId() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get fieldId => $_getSZ(7);
  @$pb.TagNumber(8)
  set fieldId($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFieldId() => $_has(7);
  @$pb.TagNumber(8)
  void clearFieldId() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get fieldName => $_getSZ(8);
  @$pb.TagNumber(9)
  set fieldName($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFieldName() => $_has(8);
  @$pb.TagNumber(9)
  void clearFieldName() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Timestamp get timestamp => $_getN(9);
  @$pb.TagNumber(10)
  set timestamp($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasTimestamp() => $_has(9);
  @$pb.TagNumber(10)
  void clearTimestamp() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureTimestamp() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.bool get read => $_getBF(10);
  @$pb.TagNumber(11)
  set read($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasRead() => $_has(10);
  @$pb.TagNumber(11)
  void clearRead() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get actionUrl => $_getSZ(11);
  @$pb.TagNumber(12)
  set actionUrl($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasActionUrl() => $_has(11);
  @$pb.TagNumber(12)
  void clearActionUrl() => $_clearField(12);

  @$pb.TagNumber(13)
  $pb.PbList<$core.String> get recommendations => $_getList(12);

  @$pb.TagNumber(14)
  $0.Timestamp get acknowledgedAt => $_getN(13);
  @$pb.TagNumber(14)
  set acknowledgedAt($0.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasAcknowledgedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearAcknowledgedAt() => $_clearField(14);
  @$pb.TagNumber(14)
  $0.Timestamp ensureAcknowledgedAt() => $_ensure(13);

  @$pb.TagNumber(15)
  $core.String get acknowledgedBy => $_getSZ(14);
  @$pb.TagNumber(15)
  set acknowledgedBy($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasAcknowledgedBy() => $_has(14);
  @$pb.TagNumber(15)
  void clearAcknowledgedBy() => $_clearField(15);

  @$pb.TagNumber(16)
  $pb.PbMap<$core.String, $core.double> get metrics => $_getMap(15);
}

class AlertRule extends $pb.GeneratedMessage {
  factory AlertRule({
    $core.String? id,
    $core.String? fieldId,
    $core.String? metric,
    $core.String? condition,
    $core.double? threshold,
    AlertSeverity? severity,
    $core.bool? enabled,
    $core.Iterable<$core.String>? notifyChannels,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fieldId != null) result.fieldId = fieldId;
    if (metric != null) result.metric = metric;
    if (condition != null) result.condition = condition;
    if (threshold != null) result.threshold = threshold;
    if (severity != null) result.severity = severity;
    if (enabled != null) result.enabled = enabled;
    if (notifyChannels != null) result.notifyChannels.addAll(notifyChannels);
    return result;
  }

  AlertRule._();

  factory AlertRule.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AlertRule.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AlertRule',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'metric')
    ..aOS(4, _omitFieldNames ? '' : 'condition')
    ..aD(5, _omitFieldNames ? '' : 'threshold')
    ..aE<AlertSeverity>(6, _omitFieldNames ? '' : 'severity',
        enumValues: AlertSeverity.values)
    ..aOB(7, _omitFieldNames ? '' : 'enabled')
    ..pPS(8, _omitFieldNames ? '' : 'notifyChannels')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlertRule clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AlertRule copyWith(void Function(AlertRule) updates) =>
      super.copyWith((message) => updates(message as AlertRule)) as AlertRule;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AlertRule create() => AlertRule._();
  @$core.override
  AlertRule createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AlertRule getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AlertRule>(create);
  static AlertRule? _defaultInstance;

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
  $core.String get metric => $_getSZ(2);
  @$pb.TagNumber(3)
  set metric($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMetric() => $_has(2);
  @$pb.TagNumber(3)
  void clearMetric() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get condition => $_getSZ(3);
  @$pb.TagNumber(4)
  set condition($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCondition() => $_has(3);
  @$pb.TagNumber(4)
  void clearCondition() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get threshold => $_getN(4);
  @$pb.TagNumber(5)
  set threshold($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasThreshold() => $_has(4);
  @$pb.TagNumber(5)
  void clearThreshold() => $_clearField(5);

  @$pb.TagNumber(6)
  AlertSeverity get severity => $_getN(5);
  @$pb.TagNumber(6)
  set severity(AlertSeverity value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSeverity() => $_has(5);
  @$pb.TagNumber(6)
  void clearSeverity() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get enabled => $_getBF(6);
  @$pb.TagNumber(7)
  set enabled($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasEnabled() => $_has(6);
  @$pb.TagNumber(7)
  void clearEnabled() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get notifyChannels => $_getList(7);
}

class FieldRiskScore extends $pb.GeneratedMessage {
  factory FieldRiskScore({
    $core.String? fieldId,
    $core.String? fieldName,
    $core.double? overallScore,
    $core.Iterable<$core.MapEntry<$core.String, $core.double>>? riskFactors,
    $core.String? calculatedAt,
    $core.String? trend,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (fieldName != null) result.fieldName = fieldName;
    if (overallScore != null) result.overallScore = overallScore;
    if (riskFactors != null) result.riskFactors.addEntries(riskFactors);
    if (calculatedAt != null) result.calculatedAt = calculatedAt;
    if (trend != null) result.trend = trend;
    return result;
  }

  FieldRiskScore._();

  factory FieldRiskScore.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FieldRiskScore.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldRiskScore',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldName')
    ..aD(3, _omitFieldNames ? '' : 'overallScore')
    ..m<$core.String, $core.double>(4, _omitFieldNames ? '' : 'riskFactors',
        entryClassName: 'FieldRiskScore.RiskFactorsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OD,
        packageName: const $pb.PackageName('agriculture.alert.v1'))
    ..aOS(5, _omitFieldNames ? '' : 'calculatedAt')
    ..aOS(6, _omitFieldNames ? '' : 'trend')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldRiskScore clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldRiskScore copyWith(void Function(FieldRiskScore) updates) =>
      super.copyWith((message) => updates(message as FieldRiskScore))
          as FieldRiskScore;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FieldRiskScore create() => FieldRiskScore._();
  @$core.override
  FieldRiskScore createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FieldRiskScore getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldRiskScore>(create);
  static FieldRiskScore? _defaultInstance;

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
  $core.double get overallScore => $_getN(2);
  @$pb.TagNumber(3)
  set overallScore($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOverallScore() => $_has(2);
  @$pb.TagNumber(3)
  void clearOverallScore() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, $core.double> get riskFactors => $_getMap(3);

  @$pb.TagNumber(5)
  $core.String get calculatedAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set calculatedAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCalculatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCalculatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get trend => $_getSZ(5);
  @$pb.TagNumber(6)
  set trend($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTrend() => $_has(5);
  @$pb.TagNumber(6)
  void clearTrend() => $_clearField(6);
}

class ListAlertsRequest extends $pb.GeneratedMessage {
  factory ListAlertsRequest({
    $core.String? farmId,
    $core.String? fieldId,
    AlertSeverity? severity,
    AlertStatus? status,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (severity != null) result.severity = severity;
    if (status != null) result.status = status;
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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aE<AlertSeverity>(3, _omitFieldNames ? '' : 'severity',
        enumValues: AlertSeverity.values)
    ..aE<AlertStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: AlertStatus.values)
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
  AlertSeverity get severity => $_getN(2);
  @$pb.TagNumber(3)
  set severity(AlertSeverity value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSeverity() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeverity() => $_clearField(3);

  @$pb.TagNumber(4)
  AlertStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(AlertStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

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
    $core.Iterable<Alert>? alerts,
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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..pPM<Alert>(1, _omitFieldNames ? '' : 'alerts', subBuilder: Alert.create)
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
  $pb.PbList<Alert> get alerts => $_getList(0);

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

class GetAlertRequest extends $pb.GeneratedMessage {
  factory GetAlertRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetAlertRequest._();

  factory GetAlertRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAlertRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAlertRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAlertRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAlertRequest copyWith(void Function(GetAlertRequest) updates) =>
      super.copyWith((message) => updates(message as GetAlertRequest))
          as GetAlertRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAlertRequest create() => GetAlertRequest._();
  @$core.override
  GetAlertRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAlertRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAlertRequest>(create);
  static GetAlertRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetAlertResponse extends $pb.GeneratedMessage {
  factory GetAlertResponse({
    Alert? alert,
  }) {
    final result = create();
    if (alert != null) result.alert = alert;
    return result;
  }

  GetAlertResponse._();

  factory GetAlertResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAlertResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAlertResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOM<Alert>(1, _omitFieldNames ? '' : 'alert', subBuilder: Alert.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAlertResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAlertResponse copyWith(void Function(GetAlertResponse) updates) =>
      super.copyWith((message) => updates(message as GetAlertResponse))
          as GetAlertResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAlertResponse create() => GetAlertResponse._();
  @$core.override
  GetAlertResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAlertResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAlertResponse>(create);
  static GetAlertResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Alert get alert => $_getN(0);
  @$pb.TagNumber(1)
  set alert(Alert value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAlert() => $_has(0);
  @$pb.TagNumber(1)
  void clearAlert() => $_clearField(1);
  @$pb.TagNumber(1)
  Alert ensureAlert() => $_ensure(0);
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
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
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
    Alert? alert,
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
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOM<Alert>(1, _omitFieldNames ? '' : 'alert', subBuilder: Alert.create)
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
  Alert get alert => $_getN(0);
  @$pb.TagNumber(1)
  set alert(Alert value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAlert() => $_has(0);
  @$pb.TagNumber(1)
  void clearAlert() => $_clearField(1);
  @$pb.TagNumber(1)
  Alert ensureAlert() => $_ensure(0);
}

class ResolveAlertRequest extends $pb.GeneratedMessage {
  factory ResolveAlertRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  ResolveAlertRequest._();

  factory ResolveAlertRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResolveAlertRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolveAlertRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveAlertRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveAlertRequest copyWith(void Function(ResolveAlertRequest) updates) =>
      super.copyWith((message) => updates(message as ResolveAlertRequest))
          as ResolveAlertRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResolveAlertRequest create() => ResolveAlertRequest._();
  @$core.override
  ResolveAlertRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResolveAlertRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveAlertRequest>(create);
  static ResolveAlertRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ResolveAlertResponse extends $pb.GeneratedMessage {
  factory ResolveAlertResponse({
    Alert? alert,
  }) {
    final result = create();
    if (alert != null) result.alert = alert;
    return result;
  }

  ResolveAlertResponse._();

  factory ResolveAlertResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ResolveAlertResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ResolveAlertResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOM<Alert>(1, _omitFieldNames ? '' : 'alert', subBuilder: Alert.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveAlertResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResolveAlertResponse copyWith(void Function(ResolveAlertResponse) updates) =>
      super.copyWith((message) => updates(message as ResolveAlertResponse))
          as ResolveAlertResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ResolveAlertResponse create() => ResolveAlertResponse._();
  @$core.override
  ResolveAlertResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ResolveAlertResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ResolveAlertResponse>(create);
  static ResolveAlertResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Alert get alert => $_getN(0);
  @$pb.TagNumber(1)
  set alert(Alert value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAlert() => $_has(0);
  @$pb.TagNumber(1)
  void clearAlert() => $_clearField(1);
  @$pb.TagNumber(1)
  Alert ensureAlert() => $_ensure(0);
}

class MarkAlertReadRequest extends $pb.GeneratedMessage {
  factory MarkAlertReadRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  MarkAlertReadRequest._();

  factory MarkAlertReadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkAlertReadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkAlertReadRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAlertReadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAlertReadRequest copyWith(void Function(MarkAlertReadRequest) updates) =>
      super.copyWith((message) => updates(message as MarkAlertReadRequest))
          as MarkAlertReadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkAlertReadRequest create() => MarkAlertReadRequest._();
  @$core.override
  MarkAlertReadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkAlertReadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkAlertReadRequest>(create);
  static MarkAlertReadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class MarkAlertReadResponse extends $pb.GeneratedMessage {
  factory MarkAlertReadResponse({
    Alert? alert,
  }) {
    final result = create();
    if (alert != null) result.alert = alert;
    return result;
  }

  MarkAlertReadResponse._();

  factory MarkAlertReadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkAlertReadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkAlertReadResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOM<Alert>(1, _omitFieldNames ? '' : 'alert', subBuilder: Alert.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAlertReadResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAlertReadResponse copyWith(
          void Function(MarkAlertReadResponse) updates) =>
      super.copyWith((message) => updates(message as MarkAlertReadResponse))
          as MarkAlertReadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkAlertReadResponse create() => MarkAlertReadResponse._();
  @$core.override
  MarkAlertReadResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkAlertReadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkAlertReadResponse>(create);
  static MarkAlertReadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Alert get alert => $_getN(0);
  @$pb.TagNumber(1)
  set alert(Alert value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAlert() => $_has(0);
  @$pb.TagNumber(1)
  void clearAlert() => $_clearField(1);
  @$pb.TagNumber(1)
  Alert ensureAlert() => $_ensure(0);
}

class MarkAllAlertsReadRequest extends $pb.GeneratedMessage {
  factory MarkAllAlertsReadRequest({
    $core.String? farmId,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    return result;
  }

  MarkAllAlertsReadRequest._();

  factory MarkAllAlertsReadRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkAllAlertsReadRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkAllAlertsReadRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAllAlertsReadRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAllAlertsReadRequest copyWith(
          void Function(MarkAllAlertsReadRequest) updates) =>
      super.copyWith((message) => updates(message as MarkAllAlertsReadRequest))
          as MarkAllAlertsReadRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkAllAlertsReadRequest create() => MarkAllAlertsReadRequest._();
  @$core.override
  MarkAllAlertsReadRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkAllAlertsReadRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkAllAlertsReadRequest>(create);
  static MarkAllAlertsReadRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);
}

class MarkAllAlertsReadResponse extends $pb.GeneratedMessage {
  factory MarkAllAlertsReadResponse({
    $core.int? updatedCount,
  }) {
    final result = create();
    if (updatedCount != null) result.updatedCount = updatedCount;
    return result;
  }

  MarkAllAlertsReadResponse._();

  factory MarkAllAlertsReadResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MarkAllAlertsReadResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MarkAllAlertsReadResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'updatedCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAllAlertsReadResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MarkAllAlertsReadResponse copyWith(
          void Function(MarkAllAlertsReadResponse) updates) =>
      super.copyWith((message) => updates(message as MarkAllAlertsReadResponse))
          as MarkAllAlertsReadResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MarkAllAlertsReadResponse create() => MarkAllAlertsReadResponse._();
  @$core.override
  MarkAllAlertsReadResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MarkAllAlertsReadResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MarkAllAlertsReadResponse>(create);
  static MarkAllAlertsReadResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get updatedCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set updatedCount($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUpdatedCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearUpdatedCount() => $_clearField(1);
}

class GetUnreadCountRequest extends $pb.GeneratedMessage {
  factory GetUnreadCountRequest({
    $core.String? farmId,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    return result;
  }

  GetUnreadCountRequest._();

  factory GetUnreadCountRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUnreadCountRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUnreadCountRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUnreadCountRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUnreadCountRequest copyWith(
          void Function(GetUnreadCountRequest) updates) =>
      super.copyWith((message) => updates(message as GetUnreadCountRequest))
          as GetUnreadCountRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUnreadCountRequest create() => GetUnreadCountRequest._();
  @$core.override
  GetUnreadCountRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUnreadCountRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUnreadCountRequest>(create);
  static GetUnreadCountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);
}

class GetUnreadCountResponse extends $pb.GeneratedMessage {
  factory GetUnreadCountResponse({
    $core.int? count,
  }) {
    final result = create();
    if (count != null) result.count = count;
    return result;
  }

  GetUnreadCountResponse._();

  factory GetUnreadCountResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetUnreadCountResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetUnreadCountResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUnreadCountResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUnreadCountResponse copyWith(
          void Function(GetUnreadCountResponse) updates) =>
      super.copyWith((message) => updates(message as GetUnreadCountResponse))
          as GetUnreadCountResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUnreadCountResponse create() => GetUnreadCountResponse._();
  @$core.override
  GetUnreadCountResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetUnreadCountResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetUnreadCountResponse>(create);
  static GetUnreadCountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get count => $_getIZ(0);
  @$pb.TagNumber(1)
  set count($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => $_clearField(1);
}

class ListAlertRulesRequest extends $pb.GeneratedMessage {
  factory ListAlertRulesRequest({
    $core.String? fieldId,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    return result;
  }

  ListAlertRulesRequest._();

  factory ListAlertRulesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAlertRulesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAlertRulesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAlertRulesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAlertRulesRequest copyWith(
          void Function(ListAlertRulesRequest) updates) =>
      super.copyWith((message) => updates(message as ListAlertRulesRequest))
          as ListAlertRulesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAlertRulesRequest create() => ListAlertRulesRequest._();
  @$core.override
  ListAlertRulesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAlertRulesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAlertRulesRequest>(create);
  static ListAlertRulesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);
}

class ListAlertRulesResponse extends $pb.GeneratedMessage {
  factory ListAlertRulesResponse({
    $core.Iterable<AlertRule>? rules,
  }) {
    final result = create();
    if (rules != null) result.rules.addAll(rules);
    return result;
  }

  ListAlertRulesResponse._();

  factory ListAlertRulesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAlertRulesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAlertRulesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..pPM<AlertRule>(1, _omitFieldNames ? '' : 'rules',
        subBuilder: AlertRule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAlertRulesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAlertRulesResponse copyWith(
          void Function(ListAlertRulesResponse) updates) =>
      super.copyWith((message) => updates(message as ListAlertRulesResponse))
          as ListAlertRulesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAlertRulesResponse create() => ListAlertRulesResponse._();
  @$core.override
  ListAlertRulesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAlertRulesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAlertRulesResponse>(create);
  static ListAlertRulesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AlertRule> get rules => $_getList(0);
}

class CreateAlertRuleRequest extends $pb.GeneratedMessage {
  factory CreateAlertRuleRequest({
    AlertRule? rule,
  }) {
    final result = create();
    if (rule != null) result.rule = rule;
    return result;
  }

  CreateAlertRuleRequest._();

  factory CreateAlertRuleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateAlertRuleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateAlertRuleRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOM<AlertRule>(1, _omitFieldNames ? '' : 'rule',
        subBuilder: AlertRule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAlertRuleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAlertRuleRequest copyWith(
          void Function(CreateAlertRuleRequest) updates) =>
      super.copyWith((message) => updates(message as CreateAlertRuleRequest))
          as CreateAlertRuleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateAlertRuleRequest create() => CreateAlertRuleRequest._();
  @$core.override
  CreateAlertRuleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateAlertRuleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateAlertRuleRequest>(create);
  static CreateAlertRuleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  AlertRule get rule => $_getN(0);
  @$pb.TagNumber(1)
  set rule(AlertRule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRule() => $_has(0);
  @$pb.TagNumber(1)
  void clearRule() => $_clearField(1);
  @$pb.TagNumber(1)
  AlertRule ensureRule() => $_ensure(0);
}

class CreateAlertRuleResponse extends $pb.GeneratedMessage {
  factory CreateAlertRuleResponse({
    AlertRule? rule,
  }) {
    final result = create();
    if (rule != null) result.rule = rule;
    return result;
  }

  CreateAlertRuleResponse._();

  factory CreateAlertRuleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateAlertRuleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateAlertRuleResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOM<AlertRule>(1, _omitFieldNames ? '' : 'rule',
        subBuilder: AlertRule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAlertRuleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAlertRuleResponse copyWith(
          void Function(CreateAlertRuleResponse) updates) =>
      super.copyWith((message) => updates(message as CreateAlertRuleResponse))
          as CreateAlertRuleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateAlertRuleResponse create() => CreateAlertRuleResponse._();
  @$core.override
  CreateAlertRuleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateAlertRuleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateAlertRuleResponse>(create);
  static CreateAlertRuleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AlertRule get rule => $_getN(0);
  @$pb.TagNumber(1)
  set rule(AlertRule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRule() => $_has(0);
  @$pb.TagNumber(1)
  void clearRule() => $_clearField(1);
  @$pb.TagNumber(1)
  AlertRule ensureRule() => $_ensure(0);
}

class UpdateAlertRuleRequest extends $pb.GeneratedMessage {
  factory UpdateAlertRuleRequest({
    AlertRule? rule,
  }) {
    final result = create();
    if (rule != null) result.rule = rule;
    return result;
  }

  UpdateAlertRuleRequest._();

  factory UpdateAlertRuleRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateAlertRuleRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateAlertRuleRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOM<AlertRule>(1, _omitFieldNames ? '' : 'rule',
        subBuilder: AlertRule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateAlertRuleRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateAlertRuleRequest copyWith(
          void Function(UpdateAlertRuleRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateAlertRuleRequest))
          as UpdateAlertRuleRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateAlertRuleRequest create() => UpdateAlertRuleRequest._();
  @$core.override
  UpdateAlertRuleRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateAlertRuleRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateAlertRuleRequest>(create);
  static UpdateAlertRuleRequest? _defaultInstance;

  @$pb.TagNumber(1)
  AlertRule get rule => $_getN(0);
  @$pb.TagNumber(1)
  set rule(AlertRule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRule() => $_has(0);
  @$pb.TagNumber(1)
  void clearRule() => $_clearField(1);
  @$pb.TagNumber(1)
  AlertRule ensureRule() => $_ensure(0);
}

class UpdateAlertRuleResponse extends $pb.GeneratedMessage {
  factory UpdateAlertRuleResponse({
    AlertRule? rule,
  }) {
    final result = create();
    if (rule != null) result.rule = rule;
    return result;
  }

  UpdateAlertRuleResponse._();

  factory UpdateAlertRuleResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateAlertRuleResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateAlertRuleResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOM<AlertRule>(1, _omitFieldNames ? '' : 'rule',
        subBuilder: AlertRule.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateAlertRuleResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateAlertRuleResponse copyWith(
          void Function(UpdateAlertRuleResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateAlertRuleResponse))
          as UpdateAlertRuleResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateAlertRuleResponse create() => UpdateAlertRuleResponse._();
  @$core.override
  UpdateAlertRuleResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateAlertRuleResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateAlertRuleResponse>(create);
  static UpdateAlertRuleResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AlertRule get rule => $_getN(0);
  @$pb.TagNumber(1)
  set rule(AlertRule value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRule() => $_has(0);
  @$pb.TagNumber(1)
  void clearRule() => $_clearField(1);
  @$pb.TagNumber(1)
  AlertRule ensureRule() => $_ensure(0);
}

class GetFieldRiskRequest extends $pb.GeneratedMessage {
  factory GetFieldRiskRequest({
    $core.String? fieldId,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    return result;
  }

  GetFieldRiskRequest._();

  factory GetFieldRiskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFieldRiskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFieldRiskRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldRiskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldRiskRequest copyWith(void Function(GetFieldRiskRequest) updates) =>
      super.copyWith((message) => updates(message as GetFieldRiskRequest))
          as GetFieldRiskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFieldRiskRequest create() => GetFieldRiskRequest._();
  @$core.override
  GetFieldRiskRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFieldRiskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFieldRiskRequest>(create);
  static GetFieldRiskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);
}

class GetFieldRiskResponse extends $pb.GeneratedMessage {
  factory GetFieldRiskResponse({
    FieldRiskScore? riskScore,
  }) {
    final result = create();
    if (riskScore != null) result.riskScore = riskScore;
    return result;
  }

  GetFieldRiskResponse._();

  factory GetFieldRiskResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFieldRiskResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFieldRiskResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOM<FieldRiskScore>(1, _omitFieldNames ? '' : 'riskScore',
        subBuilder: FieldRiskScore.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldRiskResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFieldRiskResponse copyWith(void Function(GetFieldRiskResponse) updates) =>
      super.copyWith((message) => updates(message as GetFieldRiskResponse))
          as GetFieldRiskResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFieldRiskResponse create() => GetFieldRiskResponse._();
  @$core.override
  GetFieldRiskResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFieldRiskResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFieldRiskResponse>(create);
  static GetFieldRiskResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FieldRiskScore get riskScore => $_getN(0);
  @$pb.TagNumber(1)
  set riskScore(FieldRiskScore value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRiskScore() => $_has(0);
  @$pb.TagNumber(1)
  void clearRiskScore() => $_clearField(1);
  @$pb.TagNumber(1)
  FieldRiskScore ensureRiskScore() => $_ensure(0);
}

class ListFieldRisksRequest extends $pb.GeneratedMessage {
  factory ListFieldRisksRequest() => create();

  ListFieldRisksRequest._();

  factory ListFieldRisksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListFieldRisksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFieldRisksRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldRisksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldRisksRequest copyWith(
          void Function(ListFieldRisksRequest) updates) =>
      super.copyWith((message) => updates(message as ListFieldRisksRequest))
          as ListFieldRisksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFieldRisksRequest create() => ListFieldRisksRequest._();
  @$core.override
  ListFieldRisksRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListFieldRisksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFieldRisksRequest>(create);
  static ListFieldRisksRequest? _defaultInstance;
}

class ListFieldRisksResponse extends $pb.GeneratedMessage {
  factory ListFieldRisksResponse({
    $core.Iterable<FieldRiskScore>? riskScores,
  }) {
    final result = create();
    if (riskScores != null) result.riskScores.addAll(riskScores);
    return result;
  }

  ListFieldRisksResponse._();

  factory ListFieldRisksResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListFieldRisksResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFieldRisksResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..pPM<FieldRiskScore>(1, _omitFieldNames ? '' : 'riskScores',
        subBuilder: FieldRiskScore.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldRisksResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFieldRisksResponse copyWith(
          void Function(ListFieldRisksResponse) updates) =>
      super.copyWith((message) => updates(message as ListFieldRisksResponse))
          as ListFieldRisksResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFieldRisksResponse create() => ListFieldRisksResponse._();
  @$core.override
  ListFieldRisksResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListFieldRisksResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFieldRisksResponse>(create);
  static ListFieldRisksResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FieldRiskScore> get riskScores => $_getList(0);
}

class ListAlertHistoryRequest extends $pb.GeneratedMessage {
  factory ListAlertHistoryRequest({
    $core.String? startDate,
    $core.String? endDate,
    $core.String? farmId,
    $core.String? fieldId,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (startDate != null) result.startDate = startDate;
    if (endDate != null) result.endDate = endDate;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListAlertHistoryRequest._();

  factory ListAlertHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAlertHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAlertHistoryRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'startDate')
    ..aOS(2, _omitFieldNames ? '' : 'endDate')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aI(5, _omitFieldNames ? '' : 'pageSize')
    ..aOS(6, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAlertHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAlertHistoryRequest copyWith(
          void Function(ListAlertHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as ListAlertHistoryRequest))
          as ListAlertHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAlertHistoryRequest create() => ListAlertHistoryRequest._();
  @$core.override
  ListAlertHistoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAlertHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAlertHistoryRequest>(create);
  static ListAlertHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get startDate => $_getSZ(0);
  @$pb.TagNumber(1)
  set startDate($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStartDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartDate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get endDate => $_getSZ(1);
  @$pb.TagNumber(2)
  set endDate($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEndDate() => $_has(1);
  @$pb.TagNumber(2)
  void clearEndDate() => $_clearField(2);

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

class ListAlertHistoryResponse extends $pb.GeneratedMessage {
  factory ListAlertHistoryResponse({
    $core.Iterable<Alert>? alerts,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (alerts != null) result.alerts.addAll(alerts);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListAlertHistoryResponse._();

  factory ListAlertHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAlertHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAlertHistoryResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.alert.v1'),
      createEmptyInstance: create)
    ..pPM<Alert>(1, _omitFieldNames ? '' : 'alerts', subBuilder: Alert.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAlertHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAlertHistoryResponse copyWith(
          void Function(ListAlertHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as ListAlertHistoryResponse))
          as ListAlertHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAlertHistoryResponse create() => ListAlertHistoryResponse._();
  @$core.override
  ListAlertHistoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAlertHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAlertHistoryResponse>(create);
  static ListAlertHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Alert> get alerts => $_getList(0);

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

class AlertServiceApi {
  final $pb.RpcClient _client;

  AlertServiceApi(this._client);

  $async.Future<ListAlertsResponse> listAlerts(
          $pb.ClientContext? ctx, ListAlertsRequest request) =>
      _client.invoke<ListAlertsResponse>(
          ctx, 'AlertService', 'ListAlerts', request, ListAlertsResponse());
  $async.Future<GetAlertResponse> getAlert(
          $pb.ClientContext? ctx, GetAlertRequest request) =>
      _client.invoke<GetAlertResponse>(
          ctx, 'AlertService', 'GetAlert', request, GetAlertResponse());
  $async.Future<AcknowledgeAlertResponse> acknowledgeAlert(
          $pb.ClientContext? ctx, AcknowledgeAlertRequest request) =>
      _client.invoke<AcknowledgeAlertResponse>(ctx, 'AlertService',
          'AcknowledgeAlert', request, AcknowledgeAlertResponse());
  $async.Future<ResolveAlertResponse> resolveAlert(
          $pb.ClientContext? ctx, ResolveAlertRequest request) =>
      _client.invoke<ResolveAlertResponse>(
          ctx, 'AlertService', 'ResolveAlert', request, ResolveAlertResponse());
  $async.Future<MarkAlertReadResponse> markAlertRead(
          $pb.ClientContext? ctx, MarkAlertReadRequest request) =>
      _client.invoke<MarkAlertReadResponse>(ctx, 'AlertService',
          'MarkAlertRead', request, MarkAlertReadResponse());
  $async.Future<MarkAllAlertsReadResponse> markAllAlertsRead(
          $pb.ClientContext? ctx, MarkAllAlertsReadRequest request) =>
      _client.invoke<MarkAllAlertsReadResponse>(ctx, 'AlertService',
          'MarkAllAlertsRead', request, MarkAllAlertsReadResponse());
  $async.Future<GetUnreadCountResponse> getUnreadCount(
          $pb.ClientContext? ctx, GetUnreadCountRequest request) =>
      _client.invoke<GetUnreadCountResponse>(ctx, 'AlertService',
          'GetUnreadCount', request, GetUnreadCountResponse());
  $async.Future<ListAlertRulesResponse> listAlertRules(
          $pb.ClientContext? ctx, ListAlertRulesRequest request) =>
      _client.invoke<ListAlertRulesResponse>(ctx, 'AlertService',
          'ListAlertRules', request, ListAlertRulesResponse());
  $async.Future<CreateAlertRuleResponse> createAlertRule(
          $pb.ClientContext? ctx, CreateAlertRuleRequest request) =>
      _client.invoke<CreateAlertRuleResponse>(ctx, 'AlertService',
          'CreateAlertRule', request, CreateAlertRuleResponse());
  $async.Future<UpdateAlertRuleResponse> updateAlertRule(
          $pb.ClientContext? ctx, UpdateAlertRuleRequest request) =>
      _client.invoke<UpdateAlertRuleResponse>(ctx, 'AlertService',
          'UpdateAlertRule', request, UpdateAlertRuleResponse());
  $async.Future<GetFieldRiskResponse> getFieldRisk(
          $pb.ClientContext? ctx, GetFieldRiskRequest request) =>
      _client.invoke<GetFieldRiskResponse>(
          ctx, 'AlertService', 'GetFieldRisk', request, GetFieldRiskResponse());
  $async.Future<ListFieldRisksResponse> listFieldRisks(
          $pb.ClientContext? ctx, ListFieldRisksRequest request) =>
      _client.invoke<ListFieldRisksResponse>(ctx, 'AlertService',
          'ListFieldRisks', request, ListFieldRisksResponse());
  $async.Future<ListAlertHistoryResponse> listAlertHistory(
          $pb.ClientContext? ctx, ListAlertHistoryRequest request) =>
      _client.invoke<ListAlertHistoryResponse>(ctx, 'AlertService',
          'ListAlertHistory', request, ListAlertHistoryResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
