// This is a generated file - do not edit.
//
// Generated from advisory.proto.

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

import 'advisory.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'advisory.pbenum.dart';

/// Advisory represents a crop advisory issued by an agronomist.
class Advisory extends $pb.GeneratedMessage {
  factory Advisory({
    $core.String? id,
    $core.String? title,
    $core.String? content,
    $core.String? cropType,
    AdvisorySeverity? severity,
    $core.String? region,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? createdBy,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (title != null) result.title = title;
    if (content != null) result.content = content;
    if (cropType != null) result.cropType = cropType;
    if (severity != null) result.severity = severity;
    if (region != null) result.region = region;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (createdBy != null) result.createdBy = createdBy;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  Advisory._();

  factory Advisory.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Advisory.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Advisory',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'content')
    ..aOS(4, _omitFieldNames ? '' : 'cropType')
    ..aE<AdvisorySeverity>(5, _omitFieldNames ? '' : 'severity',
        enumValues: AdvisorySeverity.values)
    ..aOS(6, _omitFieldNames ? '' : 'region')
    ..aOS(7, _omitFieldNames ? '' : 'farmId')
    ..aOS(8, _omitFieldNames ? '' : 'fieldId')
    ..aOS(9, _omitFieldNames ? '' : 'createdBy')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Advisory clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Advisory copyWith(void Function(Advisory) updates) =>
      super.copyWith((message) => updates(message as Advisory)) as Advisory;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Advisory create() => Advisory._();
  @$core.override
  Advisory createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Advisory getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Advisory>(create);
  static Advisory? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get content => $_getSZ(2);
  @$pb.TagNumber(3)
  set content($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get cropType => $_getSZ(3);
  @$pb.TagNumber(4)
  set cropType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCropType() => $_has(3);
  @$pb.TagNumber(4)
  void clearCropType() => $_clearField(4);

  @$pb.TagNumber(5)
  AdvisorySeverity get severity => $_getN(4);
  @$pb.TagNumber(5)
  set severity(AdvisorySeverity value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSeverity() => $_has(4);
  @$pb.TagNumber(5)
  void clearSeverity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get region => $_getSZ(5);
  @$pb.TagNumber(6)
  set region($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRegion() => $_has(5);
  @$pb.TagNumber(6)
  void clearRegion() => $_clearField(6);

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
  $core.String get createdBy => $_getSZ(8);
  @$pb.TagNumber(9)
  set createdBy($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCreatedBy() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedBy() => $_clearField(9);

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

  @$pb.TagNumber(11)
  $0.Timestamp get updatedAt => $_getN(10);
  @$pb.TagNumber(11)
  set updatedAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasUpdatedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearUpdatedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureUpdatedAt() => $_ensure(10);
}

class GetAdvisoryRequest extends $pb.GeneratedMessage {
  factory GetAdvisoryRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetAdvisoryRequest._();

  factory GetAdvisoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAdvisoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAdvisoryRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAdvisoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAdvisoryRequest copyWith(void Function(GetAdvisoryRequest) updates) =>
      super.copyWith((message) => updates(message as GetAdvisoryRequest))
          as GetAdvisoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAdvisoryRequest create() => GetAdvisoryRequest._();
  @$core.override
  GetAdvisoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAdvisoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAdvisoryRequest>(create);
  static GetAdvisoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetAdvisoryResponse extends $pb.GeneratedMessage {
  factory GetAdvisoryResponse({
    Advisory? advisory,
  }) {
    final result = create();
    if (advisory != null) result.advisory = advisory;
    return result;
  }

  GetAdvisoryResponse._();

  factory GetAdvisoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetAdvisoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetAdvisoryResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOM<Advisory>(1, _omitFieldNames ? '' : 'advisory',
        subBuilder: Advisory.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAdvisoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAdvisoryResponse copyWith(void Function(GetAdvisoryResponse) updates) =>
      super.copyWith((message) => updates(message as GetAdvisoryResponse))
          as GetAdvisoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAdvisoryResponse create() => GetAdvisoryResponse._();
  @$core.override
  GetAdvisoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetAdvisoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAdvisoryResponse>(create);
  static GetAdvisoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Advisory get advisory => $_getN(0);
  @$pb.TagNumber(1)
  set advisory(Advisory value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAdvisory() => $_has(0);
  @$pb.TagNumber(1)
  void clearAdvisory() => $_clearField(1);
  @$pb.TagNumber(1)
  Advisory ensureAdvisory() => $_ensure(0);
}

class ListAdvisoriesRequest extends $pb.GeneratedMessage {
  factory ListAdvisoriesRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropType,
    AdvisorySeverity? severity,
    $core.String? region,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropType != null) result.cropType = cropType;
    if (severity != null) result.severity = severity;
    if (region != null) result.region = region;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListAdvisoriesRequest._();

  factory ListAdvisoriesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAdvisoriesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAdvisoriesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'cropType')
    ..aE<AdvisorySeverity>(4, _omitFieldNames ? '' : 'severity',
        enumValues: AdvisorySeverity.values)
    ..aOS(5, _omitFieldNames ? '' : 'region')
    ..aI(6, _omitFieldNames ? '' : 'pageSize')
    ..aOS(7, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAdvisoriesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAdvisoriesRequest copyWith(
          void Function(ListAdvisoriesRequest) updates) =>
      super.copyWith((message) => updates(message as ListAdvisoriesRequest))
          as ListAdvisoriesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAdvisoriesRequest create() => ListAdvisoriesRequest._();
  @$core.override
  ListAdvisoriesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAdvisoriesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAdvisoriesRequest>(create);
  static ListAdvisoriesRequest? _defaultInstance;

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
  $core.String get cropType => $_getSZ(2);
  @$pb.TagNumber(3)
  set cropType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCropType() => $_has(2);
  @$pb.TagNumber(3)
  void clearCropType() => $_clearField(3);

  @$pb.TagNumber(4)
  AdvisorySeverity get severity => $_getN(3);
  @$pb.TagNumber(4)
  set severity(AdvisorySeverity value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSeverity() => $_has(3);
  @$pb.TagNumber(4)
  void clearSeverity() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get region => $_getSZ(4);
  @$pb.TagNumber(5)
  set region($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRegion() => $_has(4);
  @$pb.TagNumber(5)
  void clearRegion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get pageSize => $_getIZ(5);
  @$pb.TagNumber(6)
  set pageSize($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageSize() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get pageToken => $_getSZ(6);
  @$pb.TagNumber(7)
  set pageToken($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPageToken() => $_has(6);
  @$pb.TagNumber(7)
  void clearPageToken() => $_clearField(7);
}

class ListAdvisoriesResponse extends $pb.GeneratedMessage {
  factory ListAdvisoriesResponse({
    $core.Iterable<Advisory>? advisories,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (advisories != null) result.advisories.addAll(advisories);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListAdvisoriesResponse._();

  factory ListAdvisoriesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListAdvisoriesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListAdvisoriesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..pPM<Advisory>(1, _omitFieldNames ? '' : 'advisories',
        subBuilder: Advisory.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAdvisoriesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAdvisoriesResponse copyWith(
          void Function(ListAdvisoriesResponse) updates) =>
      super.copyWith((message) => updates(message as ListAdvisoriesResponse))
          as ListAdvisoriesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAdvisoriesResponse create() => ListAdvisoriesResponse._();
  @$core.override
  ListAdvisoriesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListAdvisoriesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAdvisoriesResponse>(create);
  static ListAdvisoriesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Advisory> get advisories => $_getList(0);

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

class CreateAdvisoryRequest extends $pb.GeneratedMessage {
  factory CreateAdvisoryRequest({
    $core.String? title,
    $core.String? content,
    $core.String? cropType,
    AdvisorySeverity? severity,
    $core.String? region,
    $core.String? farmId,
    $core.String? fieldId,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (content != null) result.content = content;
    if (cropType != null) result.cropType = cropType;
    if (severity != null) result.severity = severity;
    if (region != null) result.region = region;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    return result;
  }

  CreateAdvisoryRequest._();

  factory CreateAdvisoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateAdvisoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateAdvisoryRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'content')
    ..aOS(3, _omitFieldNames ? '' : 'cropType')
    ..aE<AdvisorySeverity>(4, _omitFieldNames ? '' : 'severity',
        enumValues: AdvisorySeverity.values)
    ..aOS(5, _omitFieldNames ? '' : 'region')
    ..aOS(6, _omitFieldNames ? '' : 'farmId')
    ..aOS(7, _omitFieldNames ? '' : 'fieldId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAdvisoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAdvisoryRequest copyWith(
          void Function(CreateAdvisoryRequest) updates) =>
      super.copyWith((message) => updates(message as CreateAdvisoryRequest))
          as CreateAdvisoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateAdvisoryRequest create() => CreateAdvisoryRequest._();
  @$core.override
  CreateAdvisoryRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateAdvisoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateAdvisoryRequest>(create);
  static CreateAdvisoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get content => $_getSZ(1);
  @$pb.TagNumber(2)
  set content($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get cropType => $_getSZ(2);
  @$pb.TagNumber(3)
  set cropType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCropType() => $_has(2);
  @$pb.TagNumber(3)
  void clearCropType() => $_clearField(3);

  @$pb.TagNumber(4)
  AdvisorySeverity get severity => $_getN(3);
  @$pb.TagNumber(4)
  set severity(AdvisorySeverity value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSeverity() => $_has(3);
  @$pb.TagNumber(4)
  void clearSeverity() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get region => $_getSZ(4);
  @$pb.TagNumber(5)
  set region($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRegion() => $_has(4);
  @$pb.TagNumber(5)
  void clearRegion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get farmId => $_getSZ(5);
  @$pb.TagNumber(6)
  set farmId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFarmId() => $_has(5);
  @$pb.TagNumber(6)
  void clearFarmId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get fieldId => $_getSZ(6);
  @$pb.TagNumber(7)
  set fieldId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFieldId() => $_has(6);
  @$pb.TagNumber(7)
  void clearFieldId() => $_clearField(7);
}

class CreateAdvisoryResponse extends $pb.GeneratedMessage {
  factory CreateAdvisoryResponse({
    Advisory? advisory,
  }) {
    final result = create();
    if (advisory != null) result.advisory = advisory;
    return result;
  }

  CreateAdvisoryResponse._();

  factory CreateAdvisoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateAdvisoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateAdvisoryResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.agronomy.v1'),
      createEmptyInstance: create)
    ..aOM<Advisory>(1, _omitFieldNames ? '' : 'advisory',
        subBuilder: Advisory.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAdvisoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAdvisoryResponse copyWith(
          void Function(CreateAdvisoryResponse) updates) =>
      super.copyWith((message) => updates(message as CreateAdvisoryResponse))
          as CreateAdvisoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateAdvisoryResponse create() => CreateAdvisoryResponse._();
  @$core.override
  CreateAdvisoryResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateAdvisoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateAdvisoryResponse>(create);
  static CreateAdvisoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Advisory get advisory => $_getN(0);
  @$pb.TagNumber(1)
  set advisory(Advisory value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAdvisory() => $_has(0);
  @$pb.TagNumber(1)
  void clearAdvisory() => $_clearField(1);
  @$pb.TagNumber(1)
  Advisory ensureAdvisory() => $_ensure(0);
}

/// AdvisoryService provides crop advisory management operations.
class AdvisoryServiceApi {
  final $pb.RpcClient _client;

  AdvisoryServiceApi(this._client);

  $async.Future<GetAdvisoryResponse> getAdvisory(
          $pb.ClientContext? ctx, GetAdvisoryRequest request) =>
      _client.invoke<GetAdvisoryResponse>(ctx, 'AdvisoryService', 'GetAdvisory',
          request, GetAdvisoryResponse());

  $async.Future<ListAdvisoriesResponse> listAdvisories(
          $pb.ClientContext? ctx, ListAdvisoriesRequest request) =>
      _client.invoke<ListAdvisoriesResponse>(ctx, 'AdvisoryService',
          'ListAdvisories', request, ListAdvisoriesResponse());

  $async.Future<CreateAdvisoryResponse> createAdvisory(
          $pb.ClientContext? ctx, CreateAdvisoryRequest request) =>
      _client.invoke<CreateAdvisoryResponse>(ctx, 'AdvisoryService',
          'CreateAdvisory', request, CreateAdvisoryResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
