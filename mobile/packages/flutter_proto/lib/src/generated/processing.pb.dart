/// Simulated protobuf generated code for satellite processing models.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

/// A satellite imagery processing job.
class ProcessingJob extends $pb.GeneratedMessage {
  factory ProcessingJob({
    String? id,
    String? ingestionTaskId,
    String? farmId,
    String? status,
    String? outputCrs,
    double? cloudMaskThreshold,
    bool? applyAtmosphericCorrection,
    bool? applyCloudMasking,
    Int64? createdAt,
    Int64? completedAt,
  }) {
    final msg = ProcessingJob._();
    if (id != null) msg.id = id;
    if (ingestionTaskId != null) msg.ingestionTaskId = ingestionTaskId;
    if (farmId != null) msg.farmId = farmId;
    if (status != null) msg.status = status;
    if (outputCrs != null) msg.outputCrs = outputCrs;
    if (cloudMaskThreshold != null) {
      msg.cloudMaskThreshold = cloudMaskThreshold;
    }
    if (applyAtmosphericCorrection != null) {
      msg.applyAtmosphericCorrection = applyAtmosphericCorrection;
    }
    if (applyCloudMasking != null) msg.applyCloudMasking = applyCloudMasking;
    if (createdAt != null) msg.createdAt = createdAt;
    if (completedAt != null) msg.completedAt = completedAt;
    return msg;
  }

  ProcessingJob._() : super();

  factory ProcessingJob.fromBuffer(List<int> data) =>
      ProcessingJob._()..mergeFromBuffer(data);
  factory ProcessingJob.fromJson(String json) =>
      ProcessingJob._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'ProcessingJob',
    package: const $pb.PackageName('yieldpoint.satellite.processing.v1'),
    createEmptyInstance: () => ProcessingJob._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'ingestionTaskId', protoName: 'ingestionTaskId')
    ..aOS(3, 'farmId', protoName: 'farmId')
    ..aOS(4, 'status')
    ..aOS(5, 'outputCrs', protoName: 'outputCrs')
    ..a<double>(6, 'cloudMaskThreshold', $pb.PbFieldType.OD,
        protoName: 'cloudMaskThreshold')
    ..aOB(7, 'applyAtmosphericCorrection',
        protoName: 'applyAtmosphericCorrection')
    ..aOB(8, 'applyCloudMasking', protoName: 'applyCloudMasking')
    ..aInt64(9, 'createdAt', protoName: 'createdAt')
    ..aInt64(10, 'completedAt', protoName: 'completedAt')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  ProcessingJob createEmptyInstance() => ProcessingJob._();
  static ProcessingJob getDefault() => _defaultInstance ??= ProcessingJob._();
  static ProcessingJob? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get ingestionTaskId => $_getSZ(1);
  @$pb.TagNumber(2)
  set ingestionTaskId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  String get status => $_getSZ(3);
  @$pb.TagNumber(4)
  set status(String v) => $_setString(3, v);

  @$pb.TagNumber(5)
  String get outputCrs => $_getSZ(4);
  @$pb.TagNumber(5)
  set outputCrs(String v) => $_setString(4, v);

  @$pb.TagNumber(6)
  double get cloudMaskThreshold => $_getN(5);
  @$pb.TagNumber(6)
  set cloudMaskThreshold(double v) => $_setDouble(5, v);

  @$pb.TagNumber(7)
  bool get applyAtmosphericCorrection => $_getBF(6);
  @$pb.TagNumber(7)
  set applyAtmosphericCorrection(bool v) => $_setBool(6, v);

  @$pb.TagNumber(8)
  bool get applyCloudMasking => $_getBF(7);
  @$pb.TagNumber(8)
  set applyCloudMasking(bool v) => $_setBool(7, v);

  @$pb.TagNumber(9)
  Int64 get createdAt => $_getI64(8);
  @$pb.TagNumber(9)
  set createdAt(Int64 v) => $_setInt64(8, v);

  @$pb.TagNumber(10)
  Int64 get completedAt => $_getI64(9);
  @$pb.TagNumber(10)
  set completedAt(Int64 v) => $_setInt64(9, v);
}

/// Statistics for processing jobs.
class ProcessingStats extends $pb.GeneratedMessage {
  factory ProcessingStats({
    int? totalJobs,
    int? completedJobs,
    int? failedJobs,
    int? pendingJobs,
    Int64? avgProcessingTimeMs,
  }) {
    final msg = ProcessingStats._();
    if (totalJobs != null) msg.totalJobs = totalJobs;
    if (completedJobs != null) msg.completedJobs = completedJobs;
    if (failedJobs != null) msg.failedJobs = failedJobs;
    if (pendingJobs != null) msg.pendingJobs = pendingJobs;
    if (avgProcessingTimeMs != null) {
      msg.avgProcessingTimeMs = avgProcessingTimeMs;
    }
    return msg;
  }

  ProcessingStats._() : super();

  factory ProcessingStats.fromBuffer(List<int> data) =>
      ProcessingStats._()..mergeFromBuffer(data);
  factory ProcessingStats.fromJson(String json) =>
      ProcessingStats._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'ProcessingStats',
    package: const $pb.PackageName('yieldpoint.satellite.processing.v1'),
    createEmptyInstance: () => ProcessingStats._(),
  )
    ..a<int>(1, 'totalJobs', $pb.PbFieldType.O3, protoName: 'totalJobs')
    ..a<int>(2, 'completedJobs', $pb.PbFieldType.O3,
        protoName: 'completedJobs')
    ..a<int>(3, 'failedJobs', $pb.PbFieldType.O3, protoName: 'failedJobs')
    ..a<int>(4, 'pendingJobs', $pb.PbFieldType.O3, protoName: 'pendingJobs')
    ..aInt64(5, 'avgProcessingTimeMs', protoName: 'avgProcessingTimeMs')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  ProcessingStats createEmptyInstance() => ProcessingStats._();
  static ProcessingStats getDefault() =>
      _defaultInstance ??= ProcessingStats._();
  static ProcessingStats? _defaultInstance;

  @$pb.TagNumber(1)
  int get totalJobs => $_getIZ(0);
  @$pb.TagNumber(1)
  set totalJobs(int v) => $_setSignedInt32(0, v);

  @$pb.TagNumber(2)
  int get completedJobs => $_getIZ(1);
  @$pb.TagNumber(2)
  set completedJobs(int v) => $_setSignedInt32(1, v);

  @$pb.TagNumber(3)
  int get failedJobs => $_getIZ(2);
  @$pb.TagNumber(3)
  set failedJobs(int v) => $_setSignedInt32(2, v);

  @$pb.TagNumber(4)
  int get pendingJobs => $_getIZ(3);
  @$pb.TagNumber(4)
  set pendingJobs(int v) => $_setSignedInt32(3, v);

  @$pb.TagNumber(5)
  Int64 get avgProcessingTimeMs => $_getI64(4);
  @$pb.TagNumber(5)
  set avgProcessingTimeMs(Int64 v) => $_setInt64(4, v);
}
