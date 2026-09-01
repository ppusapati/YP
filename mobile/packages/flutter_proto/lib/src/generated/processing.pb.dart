// This is a generated file - do not edit.
//
// Generated from processing.proto.

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

import 'processing.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'processing.pbenum.dart';

class ProcessingJob extends $pb.GeneratedMessage {
  factory ProcessingJob({
    $core.String? id,
    $core.String? tenantId,
    $core.String? ingestionTaskId,
    $core.String? farmId,
    ProcessingStatus? status,
    ProcessingLevel? inputLevel,
    ProcessingLevel? outputLevel,
    CorrectionAlgorithm? algorithm,
    $core.String? inputS3Key,
    $core.String? outputS3Key,
    $core.double? cloudMaskThreshold,
    $core.bool? applyAtmosphericCorrection,
    $core.bool? applyCloudMasking,
    $core.bool? applyOrthorectification,
    $core.int? outputResolutionMeters,
    $core.String? outputCrs,
    $core.String? errorMessage,
    $core.double? processingTimeSeconds,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $0.Timestamp? completedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (ingestionTaskId != null) result.ingestionTaskId = ingestionTaskId;
    if (farmId != null) result.farmId = farmId;
    if (status != null) result.status = status;
    if (inputLevel != null) result.inputLevel = inputLevel;
    if (outputLevel != null) result.outputLevel = outputLevel;
    if (algorithm != null) result.algorithm = algorithm;
    if (inputS3Key != null) result.inputS3Key = inputS3Key;
    if (outputS3Key != null) result.outputS3Key = outputS3Key;
    if (cloudMaskThreshold != null)
      result.cloudMaskThreshold = cloudMaskThreshold;
    if (applyAtmosphericCorrection != null)
      result.applyAtmosphericCorrection = applyAtmosphericCorrection;
    if (applyCloudMasking != null) result.applyCloudMasking = applyCloudMasking;
    if (applyOrthorectification != null)
      result.applyOrthorectification = applyOrthorectification;
    if (outputResolutionMeters != null)
      result.outputResolutionMeters = outputResolutionMeters;
    if (outputCrs != null) result.outputCrs = outputCrs;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (processingTimeSeconds != null)
      result.processingTimeSeconds = processingTimeSeconds;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (completedAt != null) result.completedAt = completedAt;
    return result;
  }

  ProcessingJob._();

  factory ProcessingJob.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProcessingJob.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProcessingJob',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.processing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'ingestionTaskId')
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..aE<ProcessingStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: ProcessingStatus.values)
    ..aE<ProcessingLevel>(6, _omitFieldNames ? '' : 'inputLevel',
        enumValues: ProcessingLevel.values)
    ..aE<ProcessingLevel>(7, _omitFieldNames ? '' : 'outputLevel',
        enumValues: ProcessingLevel.values)
    ..aE<CorrectionAlgorithm>(8, _omitFieldNames ? '' : 'algorithm',
        enumValues: CorrectionAlgorithm.values)
    ..aOS(9, _omitFieldNames ? '' : 'inputS3Key')
    ..aOS(10, _omitFieldNames ? '' : 'outputS3Key')
    ..aD(11, _omitFieldNames ? '' : 'cloudMaskThreshold')
    ..aOB(12, _omitFieldNames ? '' : 'applyAtmosphericCorrection')
    ..aOB(13, _omitFieldNames ? '' : 'applyCloudMasking')
    ..aOB(14, _omitFieldNames ? '' : 'applyOrthorectification')
    ..aI(15, _omitFieldNames ? '' : 'outputResolutionMeters')
    ..aOS(16, _omitFieldNames ? '' : 'outputCrs')
    ..aOS(17, _omitFieldNames ? '' : 'errorMessage')
    ..aD(18, _omitFieldNames ? '' : 'processingTimeSeconds')
    ..aOM<$0.Timestamp>(19, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(20, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(21, _omitFieldNames ? '' : 'completedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessingJob clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessingJob copyWith(void Function(ProcessingJob) updates) =>
      super.copyWith((message) => updates(message as ProcessingJob))
          as ProcessingJob;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProcessingJob create() => ProcessingJob._();
  @$core.override
  ProcessingJob createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProcessingJob getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProcessingJob>(create);
  static ProcessingJob? _defaultInstance;

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
  $core.String get ingestionTaskId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ingestionTaskId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIngestionTaskId() => $_has(2);
  @$pb.TagNumber(3)
  void clearIngestionTaskId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get farmId => $_getSZ(3);
  @$pb.TagNumber(4)
  set farmId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFarmId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFarmId() => $_clearField(4);

  @$pb.TagNumber(5)
  ProcessingStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(ProcessingStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  ProcessingLevel get inputLevel => $_getN(5);
  @$pb.TagNumber(6)
  set inputLevel(ProcessingLevel value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasInputLevel() => $_has(5);
  @$pb.TagNumber(6)
  void clearInputLevel() => $_clearField(6);

  @$pb.TagNumber(7)
  ProcessingLevel get outputLevel => $_getN(6);
  @$pb.TagNumber(7)
  set outputLevel(ProcessingLevel value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasOutputLevel() => $_has(6);
  @$pb.TagNumber(7)
  void clearOutputLevel() => $_clearField(7);

  @$pb.TagNumber(8)
  CorrectionAlgorithm get algorithm => $_getN(7);
  @$pb.TagNumber(8)
  set algorithm(CorrectionAlgorithm value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasAlgorithm() => $_has(7);
  @$pb.TagNumber(8)
  void clearAlgorithm() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get inputS3Key => $_getSZ(8);
  @$pb.TagNumber(9)
  set inputS3Key($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasInputS3Key() => $_has(8);
  @$pb.TagNumber(9)
  void clearInputS3Key() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get outputS3Key => $_getSZ(9);
  @$pb.TagNumber(10)
  set outputS3Key($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasOutputS3Key() => $_has(9);
  @$pb.TagNumber(10)
  void clearOutputS3Key() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get cloudMaskThreshold => $_getN(10);
  @$pb.TagNumber(11)
  set cloudMaskThreshold($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCloudMaskThreshold() => $_has(10);
  @$pb.TagNumber(11)
  void clearCloudMaskThreshold() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get applyAtmosphericCorrection => $_getBF(11);
  @$pb.TagNumber(12)
  set applyAtmosphericCorrection($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasApplyAtmosphericCorrection() => $_has(11);
  @$pb.TagNumber(12)
  void clearApplyAtmosphericCorrection() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get applyCloudMasking => $_getBF(12);
  @$pb.TagNumber(13)
  set applyCloudMasking($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasApplyCloudMasking() => $_has(12);
  @$pb.TagNumber(13)
  void clearApplyCloudMasking() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get applyOrthorectification => $_getBF(13);
  @$pb.TagNumber(14)
  set applyOrthorectification($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasApplyOrthorectification() => $_has(13);
  @$pb.TagNumber(14)
  void clearApplyOrthorectification() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get outputResolutionMeters => $_getIZ(14);
  @$pb.TagNumber(15)
  set outputResolutionMeters($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasOutputResolutionMeters() => $_has(14);
  @$pb.TagNumber(15)
  void clearOutputResolutionMeters() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get outputCrs => $_getSZ(15);
  @$pb.TagNumber(16)
  set outputCrs($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasOutputCrs() => $_has(15);
  @$pb.TagNumber(16)
  void clearOutputCrs() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get errorMessage => $_getSZ(16);
  @$pb.TagNumber(17)
  set errorMessage($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasErrorMessage() => $_has(16);
  @$pb.TagNumber(17)
  void clearErrorMessage() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.double get processingTimeSeconds => $_getN(17);
  @$pb.TagNumber(18)
  set processingTimeSeconds($core.double value) => $_setDouble(17, value);
  @$pb.TagNumber(18)
  $core.bool hasProcessingTimeSeconds() => $_has(17);
  @$pb.TagNumber(18)
  void clearProcessingTimeSeconds() => $_clearField(18);

  @$pb.TagNumber(19)
  $0.Timestamp get createdAt => $_getN(18);
  @$pb.TagNumber(19)
  set createdAt($0.Timestamp value) => $_setField(19, value);
  @$pb.TagNumber(19)
  $core.bool hasCreatedAt() => $_has(18);
  @$pb.TagNumber(19)
  void clearCreatedAt() => $_clearField(19);
  @$pb.TagNumber(19)
  $0.Timestamp ensureCreatedAt() => $_ensure(18);

  @$pb.TagNumber(20)
  $0.Timestamp get updatedAt => $_getN(19);
  @$pb.TagNumber(20)
  set updatedAt($0.Timestamp value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasUpdatedAt() => $_has(19);
  @$pb.TagNumber(20)
  void clearUpdatedAt() => $_clearField(20);
  @$pb.TagNumber(20)
  $0.Timestamp ensureUpdatedAt() => $_ensure(19);

  @$pb.TagNumber(21)
  $0.Timestamp get completedAt => $_getN(20);
  @$pb.TagNumber(21)
  set completedAt($0.Timestamp value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasCompletedAt() => $_has(20);
  @$pb.TagNumber(21)
  void clearCompletedAt() => $_clearField(21);
  @$pb.TagNumber(21)
  $0.Timestamp ensureCompletedAt() => $_ensure(20);
}

class SubmitProcessingJobRequest extends $pb.GeneratedMessage {
  factory SubmitProcessingJobRequest({
    $core.String? ingestionTaskId,
    $core.String? farmId,
    ProcessingLevel? outputLevel,
    CorrectionAlgorithm? algorithm,
    $core.double? cloudMaskThreshold,
    $core.bool? applyAtmosphericCorrection,
    $core.bool? applyCloudMasking,
    $core.bool? applyOrthorectification,
    $core.int? outputResolutionMeters,
    $core.String? outputCrs,
  }) {
    final result = create();
    if (ingestionTaskId != null) result.ingestionTaskId = ingestionTaskId;
    if (farmId != null) result.farmId = farmId;
    if (outputLevel != null) result.outputLevel = outputLevel;
    if (algorithm != null) result.algorithm = algorithm;
    if (cloudMaskThreshold != null)
      result.cloudMaskThreshold = cloudMaskThreshold;
    if (applyAtmosphericCorrection != null)
      result.applyAtmosphericCorrection = applyAtmosphericCorrection;
    if (applyCloudMasking != null) result.applyCloudMasking = applyCloudMasking;
    if (applyOrthorectification != null)
      result.applyOrthorectification = applyOrthorectification;
    if (outputResolutionMeters != null)
      result.outputResolutionMeters = outputResolutionMeters;
    if (outputCrs != null) result.outputCrs = outputCrs;
    return result;
  }

  SubmitProcessingJobRequest._();

  factory SubmitProcessingJobRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubmitProcessingJobRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmitProcessingJobRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.processing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'ingestionTaskId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aE<ProcessingLevel>(3, _omitFieldNames ? '' : 'outputLevel',
        enumValues: ProcessingLevel.values)
    ..aE<CorrectionAlgorithm>(4, _omitFieldNames ? '' : 'algorithm',
        enumValues: CorrectionAlgorithm.values)
    ..aD(5, _omitFieldNames ? '' : 'cloudMaskThreshold')
    ..aOB(6, _omitFieldNames ? '' : 'applyAtmosphericCorrection')
    ..aOB(7, _omitFieldNames ? '' : 'applyCloudMasking')
    ..aOB(8, _omitFieldNames ? '' : 'applyOrthorectification')
    ..aI(9, _omitFieldNames ? '' : 'outputResolutionMeters')
    ..aOS(10, _omitFieldNames ? '' : 'outputCrs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitProcessingJobRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitProcessingJobRequest copyWith(
          void Function(SubmitProcessingJobRequest) updates) =>
      super.copyWith(
              (message) => updates(message as SubmitProcessingJobRequest))
          as SubmitProcessingJobRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitProcessingJobRequest create() => SubmitProcessingJobRequest._();
  @$core.override
  SubmitProcessingJobRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubmitProcessingJobRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitProcessingJobRequest>(create);
  static SubmitProcessingJobRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get ingestionTaskId => $_getSZ(0);
  @$pb.TagNumber(1)
  set ingestionTaskId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIngestionTaskId() => $_has(0);
  @$pb.TagNumber(1)
  void clearIngestionTaskId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFarmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFarmId() => $_clearField(2);

  @$pb.TagNumber(3)
  ProcessingLevel get outputLevel => $_getN(2);
  @$pb.TagNumber(3)
  set outputLevel(ProcessingLevel value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOutputLevel() => $_has(2);
  @$pb.TagNumber(3)
  void clearOutputLevel() => $_clearField(3);

  @$pb.TagNumber(4)
  CorrectionAlgorithm get algorithm => $_getN(3);
  @$pb.TagNumber(4)
  set algorithm(CorrectionAlgorithm value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAlgorithm() => $_has(3);
  @$pb.TagNumber(4)
  void clearAlgorithm() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get cloudMaskThreshold => $_getN(4);
  @$pb.TagNumber(5)
  set cloudMaskThreshold($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCloudMaskThreshold() => $_has(4);
  @$pb.TagNumber(5)
  void clearCloudMaskThreshold() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get applyAtmosphericCorrection => $_getBF(5);
  @$pb.TagNumber(6)
  set applyAtmosphericCorrection($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasApplyAtmosphericCorrection() => $_has(5);
  @$pb.TagNumber(6)
  void clearApplyAtmosphericCorrection() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get applyCloudMasking => $_getBF(6);
  @$pb.TagNumber(7)
  set applyCloudMasking($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasApplyCloudMasking() => $_has(6);
  @$pb.TagNumber(7)
  void clearApplyCloudMasking() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get applyOrthorectification => $_getBF(7);
  @$pb.TagNumber(8)
  set applyOrthorectification($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasApplyOrthorectification() => $_has(7);
  @$pb.TagNumber(8)
  void clearApplyOrthorectification() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get outputResolutionMeters => $_getIZ(8);
  @$pb.TagNumber(9)
  set outputResolutionMeters($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOutputResolutionMeters() => $_has(8);
  @$pb.TagNumber(9)
  void clearOutputResolutionMeters() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get outputCrs => $_getSZ(9);
  @$pb.TagNumber(10)
  set outputCrs($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasOutputCrs() => $_has(9);
  @$pb.TagNumber(10)
  void clearOutputCrs() => $_clearField(10);
}

class SubmitProcessingJobResponse extends $pb.GeneratedMessage {
  factory SubmitProcessingJobResponse({
    ProcessingJob? job,
  }) {
    final result = create();
    if (job != null) result.job = job;
    return result;
  }

  SubmitProcessingJobResponse._();

  factory SubmitProcessingJobResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubmitProcessingJobResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmitProcessingJobResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.processing.v1'),
      createEmptyInstance: create)
    ..aOM<ProcessingJob>(1, _omitFieldNames ? '' : 'job',
        subBuilder: ProcessingJob.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitProcessingJobResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitProcessingJobResponse copyWith(
          void Function(SubmitProcessingJobResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SubmitProcessingJobResponse))
          as SubmitProcessingJobResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitProcessingJobResponse create() =>
      SubmitProcessingJobResponse._();
  @$core.override
  SubmitProcessingJobResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubmitProcessingJobResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitProcessingJobResponse>(create);
  static SubmitProcessingJobResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ProcessingJob get job => $_getN(0);
  @$pb.TagNumber(1)
  set job(ProcessingJob value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasJob() => $_has(0);
  @$pb.TagNumber(1)
  void clearJob() => $_clearField(1);
  @$pb.TagNumber(1)
  ProcessingJob ensureJob() => $_ensure(0);
}

class GetProcessingJobRequest extends $pb.GeneratedMessage {
  factory GetProcessingJobRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetProcessingJobRequest._();

  factory GetProcessingJobRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetProcessingJobRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProcessingJobRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.processing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProcessingJobRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProcessingJobRequest copyWith(
          void Function(GetProcessingJobRequest) updates) =>
      super.copyWith((message) => updates(message as GetProcessingJobRequest))
          as GetProcessingJobRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProcessingJobRequest create() => GetProcessingJobRequest._();
  @$core.override
  GetProcessingJobRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetProcessingJobRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProcessingJobRequest>(create);
  static GetProcessingJobRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetProcessingJobResponse extends $pb.GeneratedMessage {
  factory GetProcessingJobResponse({
    ProcessingJob? job,
  }) {
    final result = create();
    if (job != null) result.job = job;
    return result;
  }

  GetProcessingJobResponse._();

  factory GetProcessingJobResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetProcessingJobResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProcessingJobResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.processing.v1'),
      createEmptyInstance: create)
    ..aOM<ProcessingJob>(1, _omitFieldNames ? '' : 'job',
        subBuilder: ProcessingJob.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProcessingJobResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProcessingJobResponse copyWith(
          void Function(GetProcessingJobResponse) updates) =>
      super.copyWith((message) => updates(message as GetProcessingJobResponse))
          as GetProcessingJobResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProcessingJobResponse create() => GetProcessingJobResponse._();
  @$core.override
  GetProcessingJobResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetProcessingJobResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProcessingJobResponse>(create);
  static GetProcessingJobResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ProcessingJob get job => $_getN(0);
  @$pb.TagNumber(1)
  set job(ProcessingJob value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasJob() => $_has(0);
  @$pb.TagNumber(1)
  void clearJob() => $_clearField(1);
  @$pb.TagNumber(1)
  ProcessingJob ensureJob() => $_ensure(0);
}

class ListProcessingJobsRequest extends $pb.GeneratedMessage {
  factory ListProcessingJobsRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? farmId,
    ProcessingStatus? status,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (farmId != null) result.farmId = farmId;
    if (status != null) result.status = status;
    return result;
  }

  ListProcessingJobsRequest._();

  factory ListProcessingJobsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListProcessingJobsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProcessingJobsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.processing.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aE<ProcessingStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: ProcessingStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProcessingJobsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProcessingJobsRequest copyWith(
          void Function(ListProcessingJobsRequest) updates) =>
      super.copyWith((message) => updates(message as ListProcessingJobsRequest))
          as ListProcessingJobsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProcessingJobsRequest create() => ListProcessingJobsRequest._();
  @$core.override
  ListProcessingJobsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListProcessingJobsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListProcessingJobsRequest>(create);
  static ListProcessingJobsRequest? _defaultInstance;

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
  ProcessingStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(ProcessingStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);
}

class ListProcessingJobsResponse extends $pb.GeneratedMessage {
  factory ListProcessingJobsResponse({
    $core.Iterable<ProcessingJob>? jobs,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (jobs != null) result.jobs.addAll(jobs);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListProcessingJobsResponse._();

  factory ListProcessingJobsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListProcessingJobsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListProcessingJobsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.processing.v1'),
      createEmptyInstance: create)
    ..pPM<ProcessingJob>(1, _omitFieldNames ? '' : 'jobs',
        subBuilder: ProcessingJob.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProcessingJobsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListProcessingJobsResponse copyWith(
          void Function(ListProcessingJobsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListProcessingJobsResponse))
          as ListProcessingJobsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListProcessingJobsResponse create() => ListProcessingJobsResponse._();
  @$core.override
  ListProcessingJobsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListProcessingJobsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListProcessingJobsResponse>(create);
  static ListProcessingJobsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ProcessingJob> get jobs => $_getList(0);

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

class CancelProcessingJobRequest extends $pb.GeneratedMessage {
  factory CancelProcessingJobRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  CancelProcessingJobRequest._();

  factory CancelProcessingJobRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelProcessingJobRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelProcessingJobRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.processing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelProcessingJobRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelProcessingJobRequest copyWith(
          void Function(CancelProcessingJobRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CancelProcessingJobRequest))
          as CancelProcessingJobRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelProcessingJobRequest create() => CancelProcessingJobRequest._();
  @$core.override
  CancelProcessingJobRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelProcessingJobRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelProcessingJobRequest>(create);
  static CancelProcessingJobRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class CancelProcessingJobResponse extends $pb.GeneratedMessage {
  factory CancelProcessingJobResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  CancelProcessingJobResponse._();

  factory CancelProcessingJobResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CancelProcessingJobResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CancelProcessingJobResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.processing.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelProcessingJobResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelProcessingJobResponse copyWith(
          void Function(CancelProcessingJobResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CancelProcessingJobResponse))
          as CancelProcessingJobResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelProcessingJobResponse create() =>
      CancelProcessingJobResponse._();
  @$core.override
  CancelProcessingJobResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CancelProcessingJobResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelProcessingJobResponse>(create);
  static CancelProcessingJobResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

class GetProcessingStatsRequest extends $pb.GeneratedMessage {
  factory GetProcessingStatsRequest({
    $core.String? farmId,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    return result;
  }

  GetProcessingStatsRequest._();

  factory GetProcessingStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetProcessingStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProcessingStatsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.processing.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProcessingStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProcessingStatsRequest copyWith(
          void Function(GetProcessingStatsRequest) updates) =>
      super.copyWith((message) => updates(message as GetProcessingStatsRequest))
          as GetProcessingStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProcessingStatsRequest create() => GetProcessingStatsRequest._();
  @$core.override
  GetProcessingStatsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetProcessingStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProcessingStatsRequest>(create);
  static GetProcessingStatsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);
}

class GetProcessingStatsResponse extends $pb.GeneratedMessage {
  factory GetProcessingStatsResponse({
    $fixnum.Int64? totalJobs,
    $fixnum.Int64? completedJobs,
    $fixnum.Int64? failedJobs,
    $fixnum.Int64? pendingJobs,
    $core.double? avgProcessingTimeSeconds,
  }) {
    final result = create();
    if (totalJobs != null) result.totalJobs = totalJobs;
    if (completedJobs != null) result.completedJobs = completedJobs;
    if (failedJobs != null) result.failedJobs = failedJobs;
    if (pendingJobs != null) result.pendingJobs = pendingJobs;
    if (avgProcessingTimeSeconds != null)
      result.avgProcessingTimeSeconds = avgProcessingTimeSeconds;
    return result;
  }

  GetProcessingStatsResponse._();

  factory GetProcessingStatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetProcessingStatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetProcessingStatsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.processing.v1'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'totalJobs')
    ..aInt64(2, _omitFieldNames ? '' : 'completedJobs')
    ..aInt64(3, _omitFieldNames ? '' : 'failedJobs')
    ..aInt64(4, _omitFieldNames ? '' : 'pendingJobs')
    ..aD(5, _omitFieldNames ? '' : 'avgProcessingTimeSeconds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProcessingStatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetProcessingStatsResponse copyWith(
          void Function(GetProcessingStatsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetProcessingStatsResponse))
          as GetProcessingStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetProcessingStatsResponse create() => GetProcessingStatsResponse._();
  @$core.override
  GetProcessingStatsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetProcessingStatsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetProcessingStatsResponse>(create);
  static GetProcessingStatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get totalJobs => $_getI64(0);
  @$pb.TagNumber(1)
  set totalJobs($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalJobs() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalJobs() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get completedJobs => $_getI64(1);
  @$pb.TagNumber(2)
  set completedJobs($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCompletedJobs() => $_has(1);
  @$pb.TagNumber(2)
  void clearCompletedJobs() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get failedJobs => $_getI64(2);
  @$pb.TagNumber(3)
  set failedJobs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFailedJobs() => $_has(2);
  @$pb.TagNumber(3)
  void clearFailedJobs() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get pendingJobs => $_getI64(3);
  @$pb.TagNumber(4)
  set pendingJobs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPendingJobs() => $_has(3);
  @$pb.TagNumber(4)
  void clearPendingJobs() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get avgProcessingTimeSeconds => $_getN(4);
  @$pb.TagNumber(5)
  set avgProcessingTimeSeconds($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAvgProcessingTimeSeconds() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvgProcessingTimeSeconds() => $_clearField(5);
}

class SatelliteProcessingServiceApi {
  final $pb.RpcClient _client;

  SatelliteProcessingServiceApi(this._client);

  $async.Future<SubmitProcessingJobResponse> submitProcessingJob(
          $pb.ClientContext? ctx, SubmitProcessingJobRequest request) =>
      _client.invoke<SubmitProcessingJobResponse>(
          ctx,
          'SatelliteProcessingService',
          'SubmitProcessingJob',
          request,
          SubmitProcessingJobResponse());
  $async.Future<GetProcessingJobResponse> getProcessingJob(
          $pb.ClientContext? ctx, GetProcessingJobRequest request) =>
      _client.invoke<GetProcessingJobResponse>(
          ctx,
          'SatelliteProcessingService',
          'GetProcessingJob',
          request,
          GetProcessingJobResponse());
  $async.Future<ListProcessingJobsResponse> listProcessingJobs(
          $pb.ClientContext? ctx, ListProcessingJobsRequest request) =>
      _client.invoke<ListProcessingJobsResponse>(
          ctx,
          'SatelliteProcessingService',
          'ListProcessingJobs',
          request,
          ListProcessingJobsResponse());
  $async.Future<CancelProcessingJobResponse> cancelProcessingJob(
          $pb.ClientContext? ctx, CancelProcessingJobRequest request) =>
      _client.invoke<CancelProcessingJobResponse>(
          ctx,
          'SatelliteProcessingService',
          'CancelProcessingJob',
          request,
          CancelProcessingJobResponse());
  $async.Future<GetProcessingStatsResponse> getProcessingStats(
          $pb.ClientContext? ctx, GetProcessingStatsRequest request) =>
      _client.invoke<GetProcessingStatsResponse>(
          ctx,
          'SatelliteProcessingService',
          'GetProcessingStats',
          request,
          GetProcessingStatsResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
