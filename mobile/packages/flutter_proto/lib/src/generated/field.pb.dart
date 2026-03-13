/// Simulated protobuf generated code for field boundary and segment models.
import 'package:protobuf/protobuf.dart' as $pb;

import 'farm.pb.dart';

/// Boundary coordinates for a field.
class FieldBoundary extends $pb.GeneratedMessage {
  factory FieldBoundary({
    String? fieldId,
    List<LatLng>? coordinates,
  }) {
    final msg = FieldBoundary._();
    if (fieldId != null) msg.fieldId = fieldId;
    if (coordinates != null) msg.coordinates.addAll(coordinates);
    return msg;
  }

  FieldBoundary._() : super();

  factory FieldBoundary.fromBuffer(List<int> data) =>
      FieldBoundary._()..mergeFromBuffer(data);
  factory FieldBoundary.fromJson(String json) =>
      FieldBoundary._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'FieldBoundary',
    package: const $pb.PackageName('yieldpoint.field.v1'),
    createEmptyInstance: () => FieldBoundary._(),
  )
    ..aOS(1, 'fieldId', protoName: 'fieldId')
    ..pc<LatLng>(2, 'coordinates', $pb.PbFieldType.PM,
        subBuilder: LatLng._)
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  FieldBoundary createEmptyInstance() => FieldBoundary._();
  static FieldBoundary getDefault() => _defaultInstance ??= FieldBoundary._();
  static FieldBoundary? _defaultInstance;

  @$pb.TagNumber(1)
  String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  $pb.PbList<LatLng> get coordinates => $_getList(1);
}

/// A segment within a field.
class FieldSegment extends $pb.GeneratedMessage {
  factory FieldSegment({
    String? id,
    String? fieldId,
    String? name,
    double? area,
    String? soilType,
  }) {
    final msg = FieldSegment._();
    if (id != null) msg.id = id;
    if (fieldId != null) msg.fieldId = fieldId;
    if (name != null) msg.name = name;
    if (area != null) msg.area = area;
    if (soilType != null) msg.soilType = soilType;
    return msg;
  }

  FieldSegment._() : super();

  factory FieldSegment.fromBuffer(List<int> data) =>
      FieldSegment._()..mergeFromBuffer(data);
  factory FieldSegment.fromJson(String json) =>
      FieldSegment._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'FieldSegment',
    package: const $pb.PackageName('yieldpoint.field.v1'),
    createEmptyInstance: () => FieldSegment._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'fieldId', protoName: 'fieldId')
    ..aOS(3, 'name')
    ..a<double>(4, 'area', $pb.PbFieldType.OD)
    ..aOS(5, 'soilType', protoName: 'soilType')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  FieldSegment createEmptyInstance() => FieldSegment._();
  static FieldSegment getDefault() => _defaultInstance ??= FieldSegment._();
  static FieldSegment? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  double get area => $_getN(3);
  @$pb.TagNumber(4)
  set area(double v) => $_setDouble(3, v);

  @$pb.TagNumber(5)
  String get soilType => $_getSZ(4);
  @$pb.TagNumber(5)
  set soilType(String v) => $_setString(4, v);
}

/// A crop assignment to a field.
class CropAssignment extends $pb.GeneratedMessage {
  factory CropAssignment({
    String? fieldId,
    String? cropId,
    String? assignedAt,
    String? season,
  }) {
    final msg = CropAssignment._();
    if (fieldId != null) msg.fieldId = fieldId;
    if (cropId != null) msg.cropId = cropId;
    if (assignedAt != null) msg.assignedAt = assignedAt;
    if (season != null) msg.season = season;
    return msg;
  }

  CropAssignment._() : super();

  factory CropAssignment.fromBuffer(List<int> data) =>
      CropAssignment._()..mergeFromBuffer(data);
  factory CropAssignment.fromJson(String json) =>
      CropAssignment._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'CropAssignment',
    package: const $pb.PackageName('yieldpoint.field.v1'),
    createEmptyInstance: () => CropAssignment._(),
  )
    ..aOS(1, 'fieldId', protoName: 'fieldId')
    ..aOS(2, 'cropId', protoName: 'cropId')
    ..aOS(3, 'assignedAt', protoName: 'assignedAt')
    ..aOS(4, 'season')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  CropAssignment createEmptyInstance() => CropAssignment._();
  static CropAssignment getDefault() =>
      _defaultInstance ??= CropAssignment._();
  static CropAssignment? _defaultInstance;

  @$pb.TagNumber(1)
  String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get cropId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get assignedAt => $_getSZ(2);
  @$pb.TagNumber(3)
  set assignedAt(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  String get season => $_getSZ(3);
  @$pb.TagNumber(4)
  set season(String v) => $_setString(3, v);
}

/// A historical crop entry for a field.
class CropHistoryEntry extends $pb.GeneratedMessage {
  factory CropHistoryEntry({
    String? fieldId,
    String? cropId,
    String? cropName,
    String? season,
    double? yieldAmount,
  }) {
    final msg = CropHistoryEntry._();
    if (fieldId != null) msg.fieldId = fieldId;
    if (cropId != null) msg.cropId = cropId;
    if (cropName != null) msg.cropName = cropName;
    if (season != null) msg.season = season;
    if (yieldAmount != null) msg.yieldAmount = yieldAmount;
    return msg;
  }

  CropHistoryEntry._() : super();

  factory CropHistoryEntry.fromBuffer(List<int> data) =>
      CropHistoryEntry._()..mergeFromBuffer(data);
  factory CropHistoryEntry.fromJson(String json) =>
      CropHistoryEntry._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'CropHistoryEntry',
    package: const $pb.PackageName('yieldpoint.field.v1'),
    createEmptyInstance: () => CropHistoryEntry._(),
  )
    ..aOS(1, 'fieldId', protoName: 'fieldId')
    ..aOS(2, 'cropId', protoName: 'cropId')
    ..aOS(3, 'cropName', protoName: 'cropName')
    ..aOS(4, 'season')
    ..a<double>(5, 'yieldAmount', $pb.PbFieldType.OD,
        protoName: 'yieldAmount')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  CropHistoryEntry createEmptyInstance() => CropHistoryEntry._();
  static CropHistoryEntry getDefault() =>
      _defaultInstance ??= CropHistoryEntry._();
  static CropHistoryEntry? _defaultInstance;

  @$pb.TagNumber(1)
  String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get cropId => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get cropName => $_getSZ(2);
  @$pb.TagNumber(3)
  set cropName(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  String get season => $_getSZ(3);
  @$pb.TagNumber(4)
  set season(String v) => $_setString(3, v);

  @$pb.TagNumber(5)
  double get yieldAmount => $_getN(4);
  @$pb.TagNumber(5)
  set yieldAmount(double v) => $_setDouble(4, v);
}
