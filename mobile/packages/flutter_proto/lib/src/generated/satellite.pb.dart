/// Simulated protobuf generated code for satellite imagery models.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import 'farm.pb.dart';

/// A satellite imagery tile for a field.
class SatelliteTile extends $pb.GeneratedMessage {
  factory SatelliteTile({
    String? id,
    String? fieldId,
    String? tileUrl,
    Int64? captureDate,
    String? indexType,
    List<LatLng>? bounds,
  }) {
    final msg = SatelliteTile._();
    if (id != null) msg.id = id;
    if (fieldId != null) msg.fieldId = fieldId;
    if (tileUrl != null) msg.tileUrl = tileUrl;
    if (captureDate != null) msg.captureDate = captureDate;
    if (indexType != null) msg.indexType = indexType;
    if (bounds != null) msg.bounds.addAll(bounds);
    return msg;
  }

  SatelliteTile._() : super();

  factory SatelliteTile.fromBuffer(List<int> data) =>
      SatelliteTile._()..mergeFromBuffer(data);
  factory SatelliteTile.fromJson(String json) =>
      SatelliteTile._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'SatelliteTile',
    package: const $pb.PackageName('yieldpoint.satellite.v1'),
    createEmptyInstance: () => SatelliteTile._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'fieldId', protoName: 'fieldId')
    ..aOS(3, 'tileUrl', protoName: 'tileUrl')
    ..aInt64(4, 'captureDate', protoName: 'captureDate')
    ..aOS(5, 'indexType', protoName: 'indexType')
    ..pc<LatLng>(6, 'bounds', $pb.PbFieldType.PM, subBuilder: LatLng._)
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  SatelliteTile createEmptyInstance() => SatelliteTile._();
  static SatelliteTile getDefault() => _defaultInstance ??= SatelliteTile._();
  static SatelliteTile? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);
  @$pb.TagNumber(1)
  bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId(String v) => $_setString(1, v);
  @$pb.TagNumber(2)
  bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => clearField(2);

  @$pb.TagNumber(3)
  String get tileUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set tileUrl(String v) => $_setString(2, v);
  @$pb.TagNumber(3)
  bool hasTileUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearTileUrl() => clearField(3);

  @$pb.TagNumber(4)
  Int64 get captureDate => $_getI64(3);
  @$pb.TagNumber(4)
  set captureDate(Int64 v) => $_setInt64(3, v);
  @$pb.TagNumber(4)
  bool hasCaptureDate() => $_has(3);
  @$pb.TagNumber(4)
  void clearCaptureDate() => clearField(4);

  @$pb.TagNumber(5)
  String get indexType => $_getSZ(4);
  @$pb.TagNumber(5)
  set indexType(String v) => $_setString(4, v);
  @$pb.TagNumber(5)
  bool hasIndexType() => $_has(4);
  @$pb.TagNumber(5)
  void clearIndexType() => clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<LatLng> get bounds => $_getList(5);
}

/// NDVI vegetation index data for a field.
class NDVIData extends $pb.GeneratedMessage {
  factory NDVIData({
    String? fieldId,
    List<double>? values,
    Int64? timestamp,
    double? resolution,
  }) {
    final msg = NDVIData._();
    if (fieldId != null) msg.fieldId = fieldId;
    if (values != null) msg.values.addAll(values);
    if (timestamp != null) msg.timestamp = timestamp;
    if (resolution != null) msg.resolution = resolution;
    return msg;
  }

  NDVIData._() : super();

  factory NDVIData.fromBuffer(List<int> data) =>
      NDVIData._()..mergeFromBuffer(data);
  factory NDVIData.fromJson(String json) =>
      NDVIData._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'NDVIData',
    package: const $pb.PackageName('yieldpoint.satellite.v1'),
    createEmptyInstance: () => NDVIData._(),
  )
    ..aOS(1, 'fieldId', protoName: 'fieldId')
    ..p<double>(2, 'values', $pb.PbFieldType.KD)
    ..aInt64(3, 'timestamp')
    ..a<double>(4, 'resolution', $pb.PbFieldType.OD)
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  NDVIData createEmptyInstance() => NDVIData._();
  static NDVIData getDefault() => _defaultInstance ??= NDVIData._();
  static NDVIData? _defaultInstance;

  @$pb.TagNumber(1)
  String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId(String v) => $_setString(0, v);
  @$pb.TagNumber(1)
  bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<double> get values => $_getList(1);

  @$pb.TagNumber(3)
  Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp(Int64 v) => $_setInt64(2, v);
  @$pb.TagNumber(3)
  bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => clearField(3);

  @$pb.TagNumber(4)
  double get resolution => $_getN(3);
  @$pb.TagNumber(4)
  set resolution(double v) => $_setDouble(3, v);
  @$pb.TagNumber(4)
  bool hasResolution() => $_has(3);
  @$pb.TagNumber(4)
  void clearResolution() => clearField(4);
}

/// A single data point in a crop health time series.
class CropHealthDataPoint extends $pb.GeneratedMessage {
  factory CropHealthDataPoint({
    Int64? timestamp,
    double? ndviMean,
    double? ndviMin,
    double? ndviMax,
  }) {
    final msg = CropHealthDataPoint._();
    if (timestamp != null) msg.timestamp = timestamp;
    if (ndviMean != null) msg.ndviMean = ndviMean;
    if (ndviMin != null) msg.ndviMin = ndviMin;
    if (ndviMax != null) msg.ndviMax = ndviMax;
    return msg;
  }

  CropHealthDataPoint._() : super();

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'CropHealthDataPoint',
    package: const $pb.PackageName('yieldpoint.satellite.v1'),
    createEmptyInstance: () => CropHealthDataPoint._(),
  )
    ..aInt64(1, 'timestamp')
    ..a<double>(2, 'ndviMean', $pb.PbFieldType.OD, protoName: 'ndviMean')
    ..a<double>(3, 'ndviMin', $pb.PbFieldType.OD, protoName: 'ndviMin')
    ..a<double>(4, 'ndviMax', $pb.PbFieldType.OD, protoName: 'ndviMax')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  CropHealthDataPoint createEmptyInstance() => CropHealthDataPoint._();
  static CropHealthDataPoint getDefault() =>
      _defaultInstance ??= CropHealthDataPoint._();
  static CropHealthDataPoint? _defaultInstance;

  @$pb.TagNumber(1)
  Int64 get timestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set timestamp(Int64 v) => $_setInt64(0, v);

  @$pb.TagNumber(2)
  double get ndviMean => $_getN(1);
  @$pb.TagNumber(2)
  set ndviMean(double v) => $_setDouble(1, v);

  @$pb.TagNumber(3)
  double get ndviMin => $_getN(2);
  @$pb.TagNumber(3)
  set ndviMin(double v) => $_setDouble(2, v);

  @$pb.TagNumber(4)
  double get ndviMax => $_getN(3);
  @$pb.TagNumber(4)
  set ndviMax(double v) => $_setDouble(3, v);
}

/// Crop health time series for a field.
class CropHealthTimeSeries extends $pb.GeneratedMessage {
  factory CropHealthTimeSeries({
    String? fieldId,
    List<CropHealthDataPoint>? dataPoints,
  }) {
    final msg = CropHealthTimeSeries._();
    if (fieldId != null) msg.fieldId = fieldId;
    if (dataPoints != null) msg.dataPoints.addAll(dataPoints);
    return msg;
  }

  CropHealthTimeSeries._() : super();

  factory CropHealthTimeSeries.fromBuffer(List<int> data) =>
      CropHealthTimeSeries._()..mergeFromBuffer(data);
  factory CropHealthTimeSeries.fromJson(String json) =>
      CropHealthTimeSeries._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'CropHealthTimeSeries',
    package: const $pb.PackageName('yieldpoint.satellite.v1'),
    createEmptyInstance: () => CropHealthTimeSeries._(),
  )
    ..aOS(1, 'fieldId', protoName: 'fieldId')
    ..pc<CropHealthDataPoint>(2, 'dataPoints', $pb.PbFieldType.PM,
        protoName: 'dataPoints', subBuilder: CropHealthDataPoint._)
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  CropHealthTimeSeries createEmptyInstance() => CropHealthTimeSeries._();
  static CropHealthTimeSeries getDefault() =>
      _defaultInstance ??= CropHealthTimeSeries._();
  static CropHealthTimeSeries? _defaultInstance;

  @$pb.TagNumber(1)
  String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId(String v) => $_setString(0, v);
  @$pb.TagNumber(1)
  bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<CropHealthDataPoint> get dataPoints => $_getList(1);
}
