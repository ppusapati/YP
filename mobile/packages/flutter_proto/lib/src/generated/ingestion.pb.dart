/// Simulated protobuf generated code for satellite ingestion models.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

/// A satellite imagery ingestion task.
class IngestionTask extends $pb.GeneratedMessage {
  factory IngestionTask({
    String? id,
    String? farmId,
    String? provider,
    String? status,
    double? cloudCoverPercent,
    Int64? acquisitionDate,
    Int64? createdAt,
    Int64? dateFrom,
    Int64? dateTo,
  }) {
    final msg = IngestionTask._();
    if (id != null) msg.id = id;
    if (farmId != null) msg.farmId = farmId;
    if (provider != null) msg.provider = provider;
    if (status != null) msg.status = status;
    if (cloudCoverPercent != null) msg.cloudCoverPercent = cloudCoverPercent;
    if (acquisitionDate != null) msg.acquisitionDate = acquisitionDate;
    if (createdAt != null) msg.createdAt = createdAt;
    if (dateFrom != null) msg.dateFrom = dateFrom;
    if (dateTo != null) msg.dateTo = dateTo;
    return msg;
  }

  IngestionTask._() : super();

  factory IngestionTask.fromBuffer(List<int> data) =>
      IngestionTask._()..mergeFromBuffer(data);
  factory IngestionTask.fromJson(String json) =>
      IngestionTask._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'IngestionTask',
    package: const $pb.PackageName('yieldpoint.satellite.ingestion.v1'),
    createEmptyInstance: () => IngestionTask._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'farmId', protoName: 'farmId')
    ..aOS(3, 'provider')
    ..aOS(4, 'status')
    ..a<double>(5, 'cloudCoverPercent', $pb.PbFieldType.OD,
        protoName: 'cloudCoverPercent')
    ..aInt64(6, 'acquisitionDate', protoName: 'acquisitionDate')
    ..aInt64(7, 'createdAt', protoName: 'createdAt')
    ..aInt64(8, 'dateFrom', protoName: 'dateFrom')
    ..aInt64(9, 'dateTo', protoName: 'dateTo')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  IngestionTask createEmptyInstance() => IngestionTask._();
  static IngestionTask getDefault() => _defaultInstance ??= IngestionTask._();
  static IngestionTask? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get provider => $_getSZ(2);
  @$pb.TagNumber(3)
  set provider(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  String get status => $_getSZ(3);
  @$pb.TagNumber(4)
  set status(String v) => $_setString(3, v);

  @$pb.TagNumber(5)
  double get cloudCoverPercent => $_getN(4);
  @$pb.TagNumber(5)
  set cloudCoverPercent(double v) => $_setDouble(4, v);

  @$pb.TagNumber(6)
  Int64 get acquisitionDate => $_getI64(5);
  @$pb.TagNumber(6)
  set acquisitionDate(Int64 v) => $_setInt64(5, v);

  @$pb.TagNumber(7)
  Int64 get createdAt => $_getI64(6);
  @$pb.TagNumber(7)
  set createdAt(Int64 v) => $_setInt64(6, v);

  @$pb.TagNumber(8)
  Int64 get dateFrom => $_getI64(7);
  @$pb.TagNumber(8)
  set dateFrom(Int64 v) => $_setInt64(7, v);

  @$pb.TagNumber(9)
  Int64 get dateTo => $_getI64(8);
  @$pb.TagNumber(9)
  set dateTo(Int64 v) => $_setInt64(8, v);
}

/// Statistics for ingestion tasks.
class IngestionStats extends $pb.GeneratedMessage {
  factory IngestionStats({
    int? totalTasks,
    int? completedTasks,
    int? failedTasks,
    int? pendingTasks,
    Int64? totalSizeBytes,
  }) {
    final msg = IngestionStats._();
    if (totalTasks != null) msg.totalTasks = totalTasks;
    if (completedTasks != null) msg.completedTasks = completedTasks;
    if (failedTasks != null) msg.failedTasks = failedTasks;
    if (pendingTasks != null) msg.pendingTasks = pendingTasks;
    if (totalSizeBytes != null) msg.totalSizeBytes = totalSizeBytes;
    return msg;
  }

  IngestionStats._() : super();

  factory IngestionStats.fromBuffer(List<int> data) =>
      IngestionStats._()..mergeFromBuffer(data);
  factory IngestionStats.fromJson(String json) =>
      IngestionStats._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'IngestionStats',
    package: const $pb.PackageName('yieldpoint.satellite.ingestion.v1'),
    createEmptyInstance: () => IngestionStats._(),
  )
    ..a<int>(1, 'totalTasks', $pb.PbFieldType.O3, protoName: 'totalTasks')
    ..a<int>(2, 'completedTasks', $pb.PbFieldType.O3,
        protoName: 'completedTasks')
    ..a<int>(3, 'failedTasks', $pb.PbFieldType.O3, protoName: 'failedTasks')
    ..a<int>(4, 'pendingTasks', $pb.PbFieldType.O3, protoName: 'pendingTasks')
    ..aInt64(5, 'totalSizeBytes', protoName: 'totalSizeBytes')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  IngestionStats createEmptyInstance() => IngestionStats._();
  static IngestionStats getDefault() =>
      _defaultInstance ??= IngestionStats._();
  static IngestionStats? _defaultInstance;

  @$pb.TagNumber(1)
  int get totalTasks => $_getIZ(0);
  @$pb.TagNumber(1)
  set totalTasks(int v) => $_setSignedInt32(0, v);

  @$pb.TagNumber(2)
  int get completedTasks => $_getIZ(1);
  @$pb.TagNumber(2)
  set completedTasks(int v) => $_setSignedInt32(1, v);

  @$pb.TagNumber(3)
  int get failedTasks => $_getIZ(2);
  @$pb.TagNumber(3)
  set failedTasks(int v) => $_setSignedInt32(2, v);

  @$pb.TagNumber(4)
  int get pendingTasks => $_getIZ(3);
  @$pb.TagNumber(4)
  set pendingTasks(int v) => $_setSignedInt32(3, v);

  @$pb.TagNumber(5)
  Int64 get totalSizeBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set totalSizeBytes(Int64 v) => $_setInt64(4, v);
}
