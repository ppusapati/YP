// This is a generated file - do not edit.
//
// Generated from inspection.proto.

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

import 'inspection.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'inspection.pbenum.dart';

/// InspectionIssue represents a single issue found during a field inspection.
class InspectionIssue extends $pb.GeneratedMessage {
  factory InspectionIssue({
    $core.String? description,
    IssueSeverity? severity,
    $core.String? photoUrl,
  }) {
    final result = create();
    if (description != null) result.description = description;
    if (severity != null) result.severity = severity;
    if (photoUrl != null) result.photoUrl = photoUrl;
    return result;
  }

  InspectionIssue._();

  factory InspectionIssue.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InspectionIssue.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InspectionIssue',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'description')
    ..aE<IssueSeverity>(2, _omitFieldNames ? '' : 'severity',
        enumValues: IssueSeverity.values)
    ..aOS(3, _omitFieldNames ? '' : 'photoUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InspectionIssue clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InspectionIssue copyWith(void Function(InspectionIssue) updates) =>
      super.copyWith((message) => updates(message as InspectionIssue))
          as InspectionIssue;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InspectionIssue create() => InspectionIssue._();
  @$core.override
  InspectionIssue createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InspectionIssue getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InspectionIssue>(create);
  static InspectionIssue? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get description => $_getSZ(0);
  @$pb.TagNumber(1)
  set description($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDescription() => $_has(0);
  @$pb.TagNumber(1)
  void clearDescription() => $_clearField(1);

  @$pb.TagNumber(2)
  IssueSeverity get severity => $_getN(1);
  @$pb.TagNumber(2)
  set severity(IssueSeverity value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSeverity() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeverity() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get photoUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set photoUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPhotoUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearPhotoUrl() => $_clearField(3);
}

/// Inspection represents a field inspection performed by an agronomist.
class Inspection extends $pb.GeneratedMessage {
  factory Inspection({
    $core.String? id,
    $core.String? fieldId,
    $core.String? farmId,
    $core.String? inspectorId,
    InspectionStatus? status,
    $core.String? findings,
    $core.Iterable<$core.String>? photos,
    $core.Iterable<$core.String>? recommendations,
    $core.Iterable<InspectionIssue>? issues,
    $core.double? healthScore,
    $core.String? notes,
    $0.Timestamp? inspectionDate,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (inspectorId != null) result.inspectorId = inspectorId;
    if (status != null) result.status = status;
    if (findings != null) result.findings = findings;
    if (photos != null) result.photos.addAll(photos);
    if (recommendations != null) result.recommendations.addAll(recommendations);
    if (issues != null) result.issues.addAll(issues);
    if (healthScore != null) result.healthScore = healthScore;
    if (notes != null) result.notes = notes;
    if (inspectionDate != null) result.inspectionDate = inspectionDate;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  Inspection._();

  factory Inspection.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Inspection.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Inspection',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'inspectorId')
    ..aE<InspectionStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: InspectionStatus.values)
    ..aOS(6, _omitFieldNames ? '' : 'findings')
    ..pPS(7, _omitFieldNames ? '' : 'photos')
    ..pPS(8, _omitFieldNames ? '' : 'recommendations')
    ..pPM<InspectionIssue>(9, _omitFieldNames ? '' : 'issues',
        subBuilder: InspectionIssue.create)
    ..aD(10, _omitFieldNames ? '' : 'healthScore')
    ..aOS(11, _omitFieldNames ? '' : 'notes')
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'inspectionDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Inspection clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Inspection copyWith(void Function(Inspection) updates) =>
      super.copyWith((message) => updates(message as Inspection)) as Inspection;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Inspection create() => Inspection._();
  @$core.override
  Inspection createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Inspection getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Inspection>(create);
  static Inspection? _defaultInstance;

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
  $core.String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get inspectorId => $_getSZ(3);
  @$pb.TagNumber(4)
  set inspectorId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasInspectorId() => $_has(3);
  @$pb.TagNumber(4)
  void clearInspectorId() => $_clearField(4);

  @$pb.TagNumber(5)
  InspectionStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(InspectionStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get findings => $_getSZ(5);
  @$pb.TagNumber(6)
  set findings($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFindings() => $_has(5);
  @$pb.TagNumber(6)
  void clearFindings() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get photos => $_getList(6);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get recommendations => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<InspectionIssue> get issues => $_getList(8);

  @$pb.TagNumber(10)
  $core.double get healthScore => $_getN(9);
  @$pb.TagNumber(10)
  set healthScore($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasHealthScore() => $_has(9);
  @$pb.TagNumber(10)
  void clearHealthScore() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get notes => $_getSZ(10);
  @$pb.TagNumber(11)
  set notes($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasNotes() => $_has(10);
  @$pb.TagNumber(11)
  void clearNotes() => $_clearField(11);

  @$pb.TagNumber(12)
  $0.Timestamp get inspectionDate => $_getN(11);
  @$pb.TagNumber(12)
  set inspectionDate($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasInspectionDate() => $_has(11);
  @$pb.TagNumber(12)
  void clearInspectionDate() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureInspectionDate() => $_ensure(11);

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

class GetInspectionRequest extends $pb.GeneratedMessage {
  factory GetInspectionRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetInspectionRequest._();

  factory GetInspectionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetInspectionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetInspectionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetInspectionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetInspectionRequest copyWith(void Function(GetInspectionRequest) updates) =>
      super.copyWith((message) => updates(message as GetInspectionRequest))
          as GetInspectionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetInspectionRequest create() => GetInspectionRequest._();
  @$core.override
  GetInspectionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetInspectionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetInspectionRequest>(create);
  static GetInspectionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetInspectionResponse extends $pb.GeneratedMessage {
  factory GetInspectionResponse({
    Inspection? inspection,
  }) {
    final result = create();
    if (inspection != null) result.inspection = inspection;
    return result;
  }

  GetInspectionResponse._();

  factory GetInspectionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetInspectionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetInspectionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOM<Inspection>(1, _omitFieldNames ? '' : 'inspection',
        subBuilder: Inspection.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetInspectionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetInspectionResponse copyWith(
          void Function(GetInspectionResponse) updates) =>
      super.copyWith((message) => updates(message as GetInspectionResponse))
          as GetInspectionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetInspectionResponse create() => GetInspectionResponse._();
  @$core.override
  GetInspectionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetInspectionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetInspectionResponse>(create);
  static GetInspectionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Inspection get inspection => $_getN(0);
  @$pb.TagNumber(1)
  set inspection(Inspection value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasInspection() => $_has(0);
  @$pb.TagNumber(1)
  void clearInspection() => $_clearField(1);
  @$pb.TagNumber(1)
  Inspection ensureInspection() => $_ensure(0);
}

class ListInspectionsRequest extends $pb.GeneratedMessage {
  factory ListInspectionsRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? inspectorId,
    InspectionStatus? status,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (inspectorId != null) result.inspectorId = inspectorId;
    if (status != null) result.status = status;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListInspectionsRequest._();

  factory ListInspectionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListInspectionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListInspectionsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'inspectorId')
    ..aE<InspectionStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: InspectionStatus.values)
    ..aI(5, _omitFieldNames ? '' : 'pageSize')
    ..aOS(6, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInspectionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInspectionsRequest copyWith(
          void Function(ListInspectionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListInspectionsRequest))
          as ListInspectionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListInspectionsRequest create() => ListInspectionsRequest._();
  @$core.override
  ListInspectionsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListInspectionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListInspectionsRequest>(create);
  static ListInspectionsRequest? _defaultInstance;

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
  $core.String get inspectorId => $_getSZ(2);
  @$pb.TagNumber(3)
  set inspectorId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInspectorId() => $_has(2);
  @$pb.TagNumber(3)
  void clearInspectorId() => $_clearField(3);

  @$pb.TagNumber(4)
  InspectionStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(InspectionStatus value) => $_setField(4, value);
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

class ListInspectionsResponse extends $pb.GeneratedMessage {
  factory ListInspectionsResponse({
    $core.Iterable<Inspection>? inspections,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (inspections != null) result.inspections.addAll(inspections);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListInspectionsResponse._();

  factory ListInspectionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListInspectionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListInspectionsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..pPM<Inspection>(1, _omitFieldNames ? '' : 'inspections',
        subBuilder: Inspection.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInspectionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInspectionsResponse copyWith(
          void Function(ListInspectionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListInspectionsResponse))
          as ListInspectionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListInspectionsResponse create() => ListInspectionsResponse._();
  @$core.override
  ListInspectionsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListInspectionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListInspectionsResponse>(create);
  static ListInspectionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Inspection> get inspections => $_getList(0);

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

class CreateInspectionRequest extends $pb.GeneratedMessage {
  factory CreateInspectionRequest({
    $core.String? fieldId,
    $core.String? farmId,
    $core.String? findings,
    $core.Iterable<$core.String>? photos,
    $core.Iterable<$core.String>? recommendations,
    $core.Iterable<InspectionIssue>? issues,
    $core.double? healthScore,
    $core.String? notes,
    $0.Timestamp? inspectionDate,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (findings != null) result.findings = findings;
    if (photos != null) result.photos.addAll(photos);
    if (recommendations != null) result.recommendations.addAll(recommendations);
    if (issues != null) result.issues.addAll(issues);
    if (healthScore != null) result.healthScore = healthScore;
    if (notes != null) result.notes = notes;
    if (inspectionDate != null) result.inspectionDate = inspectionDate;
    return result;
  }

  CreateInspectionRequest._();

  factory CreateInspectionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateInspectionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateInspectionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aOS(3, _omitFieldNames ? '' : 'findings')
    ..pPS(4, _omitFieldNames ? '' : 'photos')
    ..pPS(5, _omitFieldNames ? '' : 'recommendations')
    ..pPM<InspectionIssue>(6, _omitFieldNames ? '' : 'issues',
        subBuilder: InspectionIssue.create)
    ..aD(7, _omitFieldNames ? '' : 'healthScore')
    ..aOS(8, _omitFieldNames ? '' : 'notes')
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'inspectionDate',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateInspectionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateInspectionRequest copyWith(
          void Function(CreateInspectionRequest) updates) =>
      super.copyWith((message) => updates(message as CreateInspectionRequest))
          as CreateInspectionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateInspectionRequest create() => CreateInspectionRequest._();
  @$core.override
  CreateInspectionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateInspectionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateInspectionRequest>(create);
  static CreateInspectionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFarmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFarmId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get findings => $_getSZ(2);
  @$pb.TagNumber(3)
  set findings($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFindings() => $_has(2);
  @$pb.TagNumber(3)
  void clearFindings() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get photos => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get recommendations => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<InspectionIssue> get issues => $_getList(5);

  @$pb.TagNumber(7)
  $core.double get healthScore => $_getN(6);
  @$pb.TagNumber(7)
  set healthScore($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHealthScore() => $_has(6);
  @$pb.TagNumber(7)
  void clearHealthScore() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get notes => $_getSZ(7);
  @$pb.TagNumber(8)
  set notes($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNotes() => $_has(7);
  @$pb.TagNumber(8)
  void clearNotes() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get inspectionDate => $_getN(8);
  @$pb.TagNumber(9)
  set inspectionDate($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasInspectionDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearInspectionDate() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureInspectionDate() => $_ensure(8);
}

class CreateInspectionResponse extends $pb.GeneratedMessage {
  factory CreateInspectionResponse({
    Inspection? inspection,
  }) {
    final result = create();
    if (inspection != null) result.inspection = inspection;
    return result;
  }

  CreateInspectionResponse._();

  factory CreateInspectionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateInspectionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateInspectionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOM<Inspection>(1, _omitFieldNames ? '' : 'inspection',
        subBuilder: Inspection.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateInspectionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateInspectionResponse copyWith(
          void Function(CreateInspectionResponse) updates) =>
      super.copyWith((message) => updates(message as CreateInspectionResponse))
          as CreateInspectionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateInspectionResponse create() => CreateInspectionResponse._();
  @$core.override
  CreateInspectionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateInspectionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateInspectionResponse>(create);
  static CreateInspectionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Inspection get inspection => $_getN(0);
  @$pb.TagNumber(1)
  set inspection(Inspection value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasInspection() => $_has(0);
  @$pb.TagNumber(1)
  void clearInspection() => $_clearField(1);
  @$pb.TagNumber(1)
  Inspection ensureInspection() => $_ensure(0);
}

class SubmitInspectionRequest extends $pb.GeneratedMessage {
  factory SubmitInspectionRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  SubmitInspectionRequest._();

  factory SubmitInspectionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubmitInspectionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmitInspectionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitInspectionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitInspectionRequest copyWith(
          void Function(SubmitInspectionRequest) updates) =>
      super.copyWith((message) => updates(message as SubmitInspectionRequest))
          as SubmitInspectionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitInspectionRequest create() => SubmitInspectionRequest._();
  @$core.override
  SubmitInspectionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubmitInspectionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitInspectionRequest>(create);
  static SubmitInspectionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class SubmitInspectionResponse extends $pb.GeneratedMessage {
  factory SubmitInspectionResponse({
    Inspection? inspection,
  }) {
    final result = create();
    if (inspection != null) result.inspection = inspection;
    return result;
  }

  SubmitInspectionResponse._();

  factory SubmitInspectionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubmitInspectionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmitInspectionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOM<Inspection>(1, _omitFieldNames ? '' : 'inspection',
        subBuilder: Inspection.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitInspectionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitInspectionResponse copyWith(
          void Function(SubmitInspectionResponse) updates) =>
      super.copyWith((message) => updates(message as SubmitInspectionResponse))
          as SubmitInspectionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitInspectionResponse create() => SubmitInspectionResponse._();
  @$core.override
  SubmitInspectionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubmitInspectionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitInspectionResponse>(create);
  static SubmitInspectionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Inspection get inspection => $_getN(0);
  @$pb.TagNumber(1)
  set inspection(Inspection value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasInspection() => $_has(0);
  @$pb.TagNumber(1)
  void clearInspection() => $_clearField(1);
  @$pb.TagNumber(1)
  Inspection ensureInspection() => $_ensure(0);
}

/// InspectionService provides field inspection management operations.
class InspectionServiceApi {
  final $pb.RpcClient _client;

  InspectionServiceApi(this._client);

  $async.Future<GetInspectionResponse> getInspection(
          $pb.ClientContext? ctx, GetInspectionRequest request) =>
      _client.invoke<GetInspectionResponse>(ctx, 'InspectionService',
          'GetInspection', request, GetInspectionResponse());

  $async.Future<ListInspectionsResponse> listInspections(
          $pb.ClientContext? ctx, ListInspectionsRequest request) =>
      _client.invoke<ListInspectionsResponse>(ctx, 'InspectionService',
          'ListInspections', request, ListInspectionsResponse());

  $async.Future<CreateInspectionResponse> createInspection(
          $pb.ClientContext? ctx, CreateInspectionRequest request) =>
      _client.invoke<CreateInspectionResponse>(ctx, 'InspectionService',
          'CreateInspection', request, CreateInspectionResponse());

  $async.Future<SubmitInspectionResponse> submitInspection(
          $pb.ClientContext? ctx, SubmitInspectionRequest request) =>
      _client.invoke<SubmitInspectionResponse>(ctx, 'InspectionService',
          'SubmitInspection', request, SubmitInspectionResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
