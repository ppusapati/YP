// This is a generated file - do not edit.
//
// Generated from ingestion.proto.

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

import 'ingestion.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'ingestion.pbenum.dart';

class IngestionTask extends $pb.GeneratedMessage {
  factory IngestionTask({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    SatelliteProvider? provider,
    $core.String? sceneId,
    IngestionStatus? status,
    $core.String? s3Bucket,
    $core.String? s3Key,
    $core.double? cloudCoverPercent,
    $core.double? resolutionMeters,
    $core.Iterable<SpectralBand>? bands,
    $core.String? bboxGeojson,
    $fixnum.Int64? fileSizeBytes,
    $core.String? checksumSha256,
    $core.String? errorMessage,
    $core.int? retryCount,
    $0.Timestamp? acquisitionDate,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $0.Timestamp? completedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (provider != null) result.provider = provider;
    if (sceneId != null) result.sceneId = sceneId;
    if (status != null) result.status = status;
    if (s3Bucket != null) result.s3Bucket = s3Bucket;
    if (s3Key != null) result.s3Key = s3Key;
    if (cloudCoverPercent != null) result.cloudCoverPercent = cloudCoverPercent;
    if (resolutionMeters != null) result.resolutionMeters = resolutionMeters;
    if (bands != null) result.bands.addAll(bands);
    if (bboxGeojson != null) result.bboxGeojson = bboxGeojson;
    if (fileSizeBytes != null) result.fileSizeBytes = fileSizeBytes;
    if (checksumSha256 != null) result.checksumSha256 = checksumSha256;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (retryCount != null) result.retryCount = retryCount;
    if (acquisitionDate != null) result.acquisitionDate = acquisitionDate;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (completedAt != null) result.completedAt = completedAt;
    return result;
  }

  IngestionTask._();

  factory IngestionTask.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IngestionTask.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IngestionTask',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.ingestion.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aE<SatelliteProvider>(4, _omitFieldNames ? '' : 'provider',
        enumValues: SatelliteProvider.values)
    ..aOS(5, _omitFieldNames ? '' : 'sceneId')
    ..aE<IngestionStatus>(6, _omitFieldNames ? '' : 'status',
        enumValues: IngestionStatus.values)
    ..aOS(7, _omitFieldNames ? '' : 's3Bucket')
    ..aOS(8, _omitFieldNames ? '' : 's3Key')
    ..aD(9, _omitFieldNames ? '' : 'cloudCoverPercent')
    ..aD(10, _omitFieldNames ? '' : 'resolutionMeters')
    ..pc<SpectralBand>(11, _omitFieldNames ? '' : 'bands', $pb.PbFieldType.KE,
        valueOf: SpectralBand.valueOf,
        enumValues: SpectralBand.values,
        defaultEnumValue: SpectralBand.SPECTRAL_BAND_UNSPECIFIED)
    ..aOS(12, _omitFieldNames ? '' : 'bboxGeojson')
    ..aInt64(13, _omitFieldNames ? '' : 'fileSizeBytes')
    ..aOS(14, _omitFieldNames ? '' : 'checksumSha256')
    ..aOS(15, _omitFieldNames ? '' : 'errorMessage')
    ..aI(16, _omitFieldNames ? '' : 'retryCount')
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'acquisitionDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(18, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(19, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(20, _omitFieldNames ? '' : 'completedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IngestionTask clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IngestionTask copyWith(void Function(IngestionTask) updates) =>
      super.copyWith((message) => updates(message as IngestionTask))
          as IngestionTask;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IngestionTask create() => IngestionTask._();
  @$core.override
  IngestionTask createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IngestionTask getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IngestionTask>(create);
  static IngestionTask? _defaultInstance;

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
  SatelliteProvider get provider => $_getN(3);
  @$pb.TagNumber(4)
  set provider(SatelliteProvider value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasProvider() => $_has(3);
  @$pb.TagNumber(4)
  void clearProvider() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get sceneId => $_getSZ(4);
  @$pb.TagNumber(5)
  set sceneId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSceneId() => $_has(4);
  @$pb.TagNumber(5)
  void clearSceneId() => $_clearField(5);

  @$pb.TagNumber(6)
  IngestionStatus get status => $_getN(5);
  @$pb.TagNumber(6)
  set status(IngestionStatus value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get s3Bucket => $_getSZ(6);
  @$pb.TagNumber(7)
  set s3Bucket($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasS3Bucket() => $_has(6);
  @$pb.TagNumber(7)
  void clearS3Bucket() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get s3Key => $_getSZ(7);
  @$pb.TagNumber(8)
  set s3Key($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasS3Key() => $_has(7);
  @$pb.TagNumber(8)
  void clearS3Key() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get cloudCoverPercent => $_getN(8);
  @$pb.TagNumber(9)
  set cloudCoverPercent($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCloudCoverPercent() => $_has(8);
  @$pb.TagNumber(9)
  void clearCloudCoverPercent() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get resolutionMeters => $_getN(9);
  @$pb.TagNumber(10)
  set resolutionMeters($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasResolutionMeters() => $_has(9);
  @$pb.TagNumber(10)
  void clearResolutionMeters() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbList<SpectralBand> get bands => $_getList(10);

  @$pb.TagNumber(12)
  $core.String get bboxGeojson => $_getSZ(11);
  @$pb.TagNumber(12)
  set bboxGeojson($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasBboxGeojson() => $_has(11);
  @$pb.TagNumber(12)
  void clearBboxGeojson() => $_clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get fileSizeBytes => $_getI64(12);
  @$pb.TagNumber(13)
  set fileSizeBytes($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasFileSizeBytes() => $_has(12);
  @$pb.TagNumber(13)
  void clearFileSizeBytes() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get checksumSha256 => $_getSZ(13);
  @$pb.TagNumber(14)
  set checksumSha256($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasChecksumSha256() => $_has(13);
  @$pb.TagNumber(14)
  void clearChecksumSha256() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get errorMessage => $_getSZ(14);
  @$pb.TagNumber(15)
  set errorMessage($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasErrorMessage() => $_has(14);
  @$pb.TagNumber(15)
  void clearErrorMessage() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.int get retryCount => $_getIZ(15);
  @$pb.TagNumber(16)
  set retryCount($core.int value) => $_setSignedInt32(15, value);
  @$pb.TagNumber(16)
  $core.bool hasRetryCount() => $_has(15);
  @$pb.TagNumber(16)
  void clearRetryCount() => $_clearField(16);

  @$pb.TagNumber(17)
  $0.Timestamp get acquisitionDate => $_getN(16);
  @$pb.TagNumber(17)
  set acquisitionDate($0.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasAcquisitionDate() => $_has(16);
  @$pb.TagNumber(17)
  void clearAcquisitionDate() => $_clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensureAcquisitionDate() => $_ensure(16);

  @$pb.TagNumber(18)
  $0.Timestamp get createdAt => $_getN(17);
  @$pb.TagNumber(18)
  set createdAt($0.Timestamp value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasCreatedAt() => $_has(17);
  @$pb.TagNumber(18)
  void clearCreatedAt() => $_clearField(18);
  @$pb.TagNumber(18)
  $0.Timestamp ensureCreatedAt() => $_ensure(17);

  @$pb.TagNumber(19)
  $0.Timestamp get updatedAt => $_getN(18);
  @$pb.TagNumber(19)
  set updatedAt($0.Timestamp value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasUpdatedAt() => $_has(18);
  @$pb.TagNumber(19)
  void clearUpdatedAt() => $_clearField(19);
  @$pb.TagNumber(19)
  $0.Timestamp ensureUpdatedAt() => $_ensure(18);

  @$pb.TagNumber(20)
  $0.Timestamp get completedAt => $_getN(19);
  @$pb.TagNumber(20)
  set completedAt($0.Timestamp value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasCompletedAt() => $_has(19);
  @$pb.TagNumber(20)
  void clearCompletedAt() => $_clearField(20);
  @$pb.TagNumber(20)
  $0.Timestamp ensureCompletedAt() => $_ensure(19);
}

class RequestIngestionRequest extends $pb.GeneratedMessage {
  factory RequestIngestionRequest({
    $core.String? farmId,
    SatelliteProvider? provider,
    $0.Timestamp? dateFrom,
    $0.Timestamp? dateTo,
    $core.double? maxCloudCover,
    $core.Iterable<SpectralBand>? bands,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (provider != null) result.provider = provider;
    if (dateFrom != null) result.dateFrom = dateFrom;
    if (dateTo != null) result.dateTo = dateTo;
    if (maxCloudCover != null) result.maxCloudCover = maxCloudCover;
    if (bands != null) result.bands.addAll(bands);
    return result;
  }

  RequestIngestionRequest._();

  factory RequestIngestionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestIngestionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestIngestionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.ingestion.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aE<SatelliteProvider>(2, _omitFieldNames ? '' : 'provider',
        enumValues: SatelliteProvider.values)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'dateFrom',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'dateTo',
        subBuilder: $0.Timestamp.create)
    ..aD(5, _omitFieldNames ? '' : 'maxCloudCover')
    ..pc<SpectralBand>(6, _omitFieldNames ? '' : 'bands', $pb.PbFieldType.KE,
        valueOf: SpectralBand.valueOf,
        enumValues: SpectralBand.values,
        defaultEnumValue: SpectralBand.SPECTRAL_BAND_UNSPECIFIED)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestIngestionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestIngestionRequest copyWith(
          void Function(RequestIngestionRequest) updates) =>
      super.copyWith((message) => updates(message as RequestIngestionRequest))
          as RequestIngestionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestIngestionRequest create() => RequestIngestionRequest._();
  @$core.override
  RequestIngestionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestIngestionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestIngestionRequest>(create);
  static RequestIngestionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

  @$pb.TagNumber(2)
  SatelliteProvider get provider => $_getN(1);
  @$pb.TagNumber(2)
  set provider(SatelliteProvider value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasProvider() => $_has(1);
  @$pb.TagNumber(2)
  void clearProvider() => $_clearField(2);

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

  @$pb.TagNumber(5)
  $core.double get maxCloudCover => $_getN(4);
  @$pb.TagNumber(5)
  set maxCloudCover($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMaxCloudCover() => $_has(4);
  @$pb.TagNumber(5)
  void clearMaxCloudCover() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<SpectralBand> get bands => $_getList(5);
}

class RequestIngestionResponse extends $pb.GeneratedMessage {
  factory RequestIngestionResponse({
    IngestionTask? task,
  }) {
    final result = create();
    if (task != null) result.task = task;
    return result;
  }

  RequestIngestionResponse._();

  factory RequestIngestionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestIngestionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestIngestionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.ingestion.v1'),
      createEmptyInstance: create)
    ..aOM<IngestionTask>(1, _omitFieldNames ? '' : 'task',
        subBuilder: IngestionTask.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestIngestionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestIngestionResponse copyWith(
          void Function(RequestIngestionResponse) updates) =>
      super.copyWith((message) => updates(message as RequestIngestionResponse))
          as RequestIngestionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestIngestionResponse create() => RequestIngestionResponse._();
  @$core.override
  RequestIngestionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestIngestionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestIngestionResponse>(create);
  static RequestIngestionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  IngestionTask get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(IngestionTask value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  IngestionTask ensureTask() => $_ensure(0);
}

class GetIngestionTaskRequest extends $pb.GeneratedMessage {
  factory GetIngestionTaskRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetIngestionTaskRequest._();

  factory GetIngestionTaskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetIngestionTaskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetIngestionTaskRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.ingestion.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIngestionTaskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIngestionTaskRequest copyWith(
          void Function(GetIngestionTaskRequest) updates) =>
      super.copyWith((message) => updates(message as GetIngestionTaskRequest))
          as GetIngestionTaskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetIngestionTaskRequest create() => GetIngestionTaskRequest._();
  @$core.override
  GetIngestionTaskRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetIngestionTaskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetIngestionTaskRequest>(create);
  static GetIngestionTaskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetIngestionTaskResponse extends $pb.GeneratedMessage {
  factory GetIngestionTaskResponse({
    IngestionTask? task,
  }) {
    final result = create();
    if (task != null) result.task = task;
    return result;
  }

  GetIngestionTaskResponse._();

  factory GetIngestionTaskResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetIngestionTaskResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetIngestionTaskResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.ingestion.v1'),
      createEmptyInstance: create)
    ..aOM<IngestionTask>(1, _omitFieldNames ? '' : 'task',
        subBuilder: IngestionTask.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIngestionTaskResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIngestionTaskResponse copyWith(
          void Function(GetIngestionTaskResponse) updates) =>
      super.copyWith((message) => updates(message as GetIngestionTaskResponse))
          as GetIngestionTaskResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetIngestionTaskResponse create() => GetIngestionTaskResponse._();
  @$core.override
  GetIngestionTaskResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetIngestionTaskResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetIngestionTaskResponse>(create);
  static GetIngestionTaskResponse? _defaultInstance;

  @$pb.TagNumber(1)
  IngestionTask get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(IngestionTask value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  IngestionTask ensureTask() => $_ensure(0);
}

class ListIngestionTasksRequest extends $pb.GeneratedMessage {
  factory ListIngestionTasksRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? farmId,
    SatelliteProvider? provider,
    IngestionStatus? status,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (farmId != null) result.farmId = farmId;
    if (provider != null) result.provider = provider;
    if (status != null) result.status = status;
    return result;
  }

  ListIngestionTasksRequest._();

  factory ListIngestionTasksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListIngestionTasksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListIngestionTasksRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.ingestion.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aE<SatelliteProvider>(4, _omitFieldNames ? '' : 'provider',
        enumValues: SatelliteProvider.values)
    ..aE<IngestionStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: IngestionStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListIngestionTasksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListIngestionTasksRequest copyWith(
          void Function(ListIngestionTasksRequest) updates) =>
      super.copyWith((message) => updates(message as ListIngestionTasksRequest))
          as ListIngestionTasksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListIngestionTasksRequest create() => ListIngestionTasksRequest._();
  @$core.override
  ListIngestionTasksRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListIngestionTasksRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListIngestionTasksRequest>(create);
  static ListIngestionTasksRequest? _defaultInstance;

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
  SatelliteProvider get provider => $_getN(3);
  @$pb.TagNumber(4)
  set provider(SatelliteProvider value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasProvider() => $_has(3);
  @$pb.TagNumber(4)
  void clearProvider() => $_clearField(4);

  @$pb.TagNumber(5)
  IngestionStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(IngestionStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);
}

class ListIngestionTasksResponse extends $pb.GeneratedMessage {
  factory ListIngestionTasksResponse({
    $core.Iterable<IngestionTask>? tasks,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (tasks != null) result.tasks.addAll(tasks);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListIngestionTasksResponse._();

  factory ListIngestionTasksResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListIngestionTasksResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListIngestionTasksResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.ingestion.v1'),
      createEmptyInstance: create)
    ..pPM<IngestionTask>(1, _omitFieldNames ? '' : 'tasks',
        subBuilder: IngestionTask.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListIngestionTasksResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListIngestionTasksResponse copyWith(
          void Function(ListIngestionTasksResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListIngestionTasksResponse))
          as ListIngestionTasksResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListIngestionTasksResponse create() => ListIngestionTasksResponse._();
  @$core.override
  ListIngestionTasksResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListIngestionTasksResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListIngestionTasksResponse>(create);
  static ListIngestionTasksResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<IngestionTask> get tasks => $_getList(0);

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

class CancelIngestionRequest extends $pb.GeneratedMessage {
  factory CancelIngestionRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  CancelIngestionRequest._();

  factory CancelIngestionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelIngestionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelIngestionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.ingestion.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelIngestionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelIngestionRequest copyWith(
          void Function(CancelIngestionRequest) updates) =>
      super.copyWith((message) => updates(message as CancelIngestionRequest))
          as CancelIngestionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelIngestionRequest create() => CancelIngestionRequest._();
  @$core.override
  CancelIngestionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelIngestionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelIngestionRequest>(create);
  static CancelIngestionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class CancelIngestionResponse extends $pb.GeneratedMessage {
  factory CancelIngestionResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  CancelIngestionResponse._();

  factory CancelIngestionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelIngestionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelIngestionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.ingestion.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelIngestionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelIngestionResponse copyWith(
          void Function(CancelIngestionResponse) updates) =>
      super.copyWith((message) => updates(message as CancelIngestionResponse))
          as CancelIngestionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelIngestionResponse create() => CancelIngestionResponse._();
  @$core.override
  CancelIngestionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelIngestionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelIngestionResponse>(create);
  static CancelIngestionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

class RetryIngestionRequest extends $pb.GeneratedMessage {
  factory RetryIngestionRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  RetryIngestionRequest._();

  factory RetryIngestionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RetryIngestionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RetryIngestionRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.ingestion.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RetryIngestionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RetryIngestionRequest copyWith(
          void Function(RetryIngestionRequest) updates) =>
      super.copyWith((message) => updates(message as RetryIngestionRequest))
          as RetryIngestionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RetryIngestionRequest create() => RetryIngestionRequest._();
  @$core.override
  RetryIngestionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RetryIngestionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RetryIngestionRequest>(create);
  static RetryIngestionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class RetryIngestionResponse extends $pb.GeneratedMessage {
  factory RetryIngestionResponse({
    IngestionTask? task,
  }) {
    final result = create();
    if (task != null) result.task = task;
    return result;
  }

  RetryIngestionResponse._();

  factory RetryIngestionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RetryIngestionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RetryIngestionResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.ingestion.v1'),
      createEmptyInstance: create)
    ..aOM<IngestionTask>(1, _omitFieldNames ? '' : 'task',
        subBuilder: IngestionTask.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RetryIngestionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RetryIngestionResponse copyWith(
          void Function(RetryIngestionResponse) updates) =>
      super.copyWith((message) => updates(message as RetryIngestionResponse))
          as RetryIngestionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RetryIngestionResponse create() => RetryIngestionResponse._();
  @$core.override
  RetryIngestionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RetryIngestionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RetryIngestionResponse>(create);
  static RetryIngestionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  IngestionTask get task => $_getN(0);
  @$pb.TagNumber(1)
  set task(IngestionTask value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);
  @$pb.TagNumber(1)
  IngestionTask ensureTask() => $_ensure(0);
}

class GetIngestionStatsRequest extends $pb.GeneratedMessage {
  factory GetIngestionStatsRequest({
    $core.String? farmId,
    SatelliteProvider? provider,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (provider != null) result.provider = provider;
    return result;
  }

  GetIngestionStatsRequest._();

  factory GetIngestionStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetIngestionStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetIngestionStatsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.ingestion.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aE<SatelliteProvider>(2, _omitFieldNames ? '' : 'provider',
        enumValues: SatelliteProvider.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIngestionStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIngestionStatsRequest copyWith(
          void Function(GetIngestionStatsRequest) updates) =>
      super.copyWith((message) => updates(message as GetIngestionStatsRequest))
          as GetIngestionStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetIngestionStatsRequest create() => GetIngestionStatsRequest._();
  @$core.override
  GetIngestionStatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetIngestionStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetIngestionStatsRequest>(create);
  static GetIngestionStatsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

  @$pb.TagNumber(2)
  SatelliteProvider get provider => $_getN(1);
  @$pb.TagNumber(2)
  set provider(SatelliteProvider value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasProvider() => $_has(1);
  @$pb.TagNumber(2)
  void clearProvider() => $_clearField(2);
}

class GetIngestionStatsResponse extends $pb.GeneratedMessage {
  factory GetIngestionStatsResponse({
    $fixnum.Int64? totalTasks,
    $fixnum.Int64? completedTasks,
    $fixnum.Int64? failedTasks,
    $fixnum.Int64? pendingTasks,
    $fixnum.Int64? totalBytesStored,
  }) {
    final result = create();
    if (totalTasks != null) result.totalTasks = totalTasks;
    if (completedTasks != null) result.completedTasks = completedTasks;
    if (failedTasks != null) result.failedTasks = failedTasks;
    if (pendingTasks != null) result.pendingTasks = pendingTasks;
    if (totalBytesStored != null) result.totalBytesStored = totalBytesStored;
    return result;
  }

  GetIngestionStatsResponse._();

  factory GetIngestionStatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetIngestionStatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetIngestionStatsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.ingestion.v1'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'totalTasks')
    ..aInt64(2, _omitFieldNames ? '' : 'completedTasks')
    ..aInt64(3, _omitFieldNames ? '' : 'failedTasks')
    ..aInt64(4, _omitFieldNames ? '' : 'pendingTasks')
    ..aInt64(5, _omitFieldNames ? '' : 'totalBytesStored')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIngestionStatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetIngestionStatsResponse copyWith(
          void Function(GetIngestionStatsResponse) updates) =>
      super.copyWith((message) => updates(message as GetIngestionStatsResponse))
          as GetIngestionStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetIngestionStatsResponse create() => GetIngestionStatsResponse._();
  @$core.override
  GetIngestionStatsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetIngestionStatsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetIngestionStatsResponse>(create);
  static GetIngestionStatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get totalTasks => $_getI64(0);
  @$pb.TagNumber(1)
  set totalTasks($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalTasks() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalTasks() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get completedTasks => $_getI64(1);
  @$pb.TagNumber(2)
  set completedTasks($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCompletedTasks() => $_has(1);
  @$pb.TagNumber(2)
  void clearCompletedTasks() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get failedTasks => $_getI64(2);
  @$pb.TagNumber(3)
  set failedTasks($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFailedTasks() => $_has(2);
  @$pb.TagNumber(3)
  void clearFailedTasks() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get pendingTasks => $_getI64(3);
  @$pb.TagNumber(4)
  set pendingTasks($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPendingTasks() => $_has(3);
  @$pb.TagNumber(4)
  void clearPendingTasks() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get totalBytesStored => $_getI64(4);
  @$pb.TagNumber(5)
  set totalBytesStored($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalBytesStored() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalBytesStored() => $_clearField(5);
}

class SatelliteIngestionServiceApi {
  final $pb.RpcClient _client;

  SatelliteIngestionServiceApi(this._client);

  $async.Future<RequestIngestionResponse> requestIngestion(
          $pb.ClientContext? ctx, RequestIngestionRequest request) =>
      _client.invoke<RequestIngestionResponse>(ctx, 'SatelliteIngestionService',
          'RequestIngestion', request, RequestIngestionResponse());
  $async.Future<GetIngestionTaskResponse> getIngestionTask(
          $pb.ClientContext? ctx, GetIngestionTaskRequest request) =>
      _client.invoke<GetIngestionTaskResponse>(ctx, 'SatelliteIngestionService',
          'GetIngestionTask', request, GetIngestionTaskResponse());
  $async.Future<ListIngestionTasksResponse> listIngestionTasks(
          $pb.ClientContext? ctx, ListIngestionTasksRequest request) =>
      _client.invoke<ListIngestionTasksResponse>(
          ctx,
          'SatelliteIngestionService',
          'ListIngestionTasks',
          request,
          ListIngestionTasksResponse());
  $async.Future<CancelIngestionResponse> cancelIngestion(
          $pb.ClientContext? ctx, CancelIngestionRequest request) =>
      _client.invoke<CancelIngestionResponse>(ctx, 'SatelliteIngestionService',
          'CancelIngestion', request, CancelIngestionResponse());
  $async.Future<RetryIngestionResponse> retryIngestion(
          $pb.ClientContext? ctx, RetryIngestionRequest request) =>
      _client.invoke<RetryIngestionResponse>(ctx, 'SatelliteIngestionService',
          'RetryIngestion', request, RetryIngestionResponse());
  $async.Future<GetIngestionStatsResponse> getIngestionStats(
          $pb.ClientContext? ctx, GetIngestionStatsRequest request) =>
      _client.invoke<GetIngestionStatsResponse>(
          ctx,
          'SatelliteIngestionService',
          'GetIngestionStats',
          request,
          GetIngestionStatsResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
