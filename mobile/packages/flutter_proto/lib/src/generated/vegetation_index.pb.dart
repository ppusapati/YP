/// Simulated protobuf generated code for vegetation index models.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

/// A computed vegetation index for a field.
class VegetationIndex extends $pb.GeneratedMessage {
  factory VegetationIndex({
    String? id,
    String? processingJobId,
    String? farmId,
    String? fieldId,
    String? indexType,
    double? meanValue,
    double? minValue,
    double? maxValue,
    double? stdDeviation,
    Int64? computedAt,
  }) {
    final msg = VegetationIndex._();
    if (id != null) msg.id = id;
    if (processingJobId != null) msg.processingJobId = processingJobId;
    if (farmId != null) msg.farmId = farmId;
    if (fieldId != null) msg.fieldId = fieldId;
    if (indexType != null) msg.indexType = indexType;
    if (meanValue != null) msg.meanValue = meanValue;
    if (minValue != null) msg.minValue = minValue;
    if (maxValue != null) msg.maxValue = maxValue;
    if (stdDeviation != null) msg.stdDeviation = stdDeviation;
    if (computedAt != null) msg.computedAt = computedAt;
    return msg;
  }

  VegetationIndex._() : super();

  factory VegetationIndex.fromBuffer(List<int> data) =>
      VegetationIndex._()..mergeFromBuffer(data);
  factory VegetationIndex.fromJson(String json) =>
      VegetationIndex._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'VegetationIndex',
    package: const $pb.PackageName('yieldpoint.satellite.vegetation.v1'),
    createEmptyInstance: () => VegetationIndex._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'processingJobId', protoName: 'processingJobId')
    ..aOS(3, 'farmId', protoName: 'farmId')
    ..aOS(4, 'fieldId', protoName: 'fieldId')
    ..aOS(5, 'indexType', protoName: 'indexType')
    ..a<double>(6, 'meanValue', $pb.PbFieldType.OD, protoName: 'meanValue')
    ..a<double>(7, 'minValue', $pb.PbFieldType.OD, protoName: 'minValue')
    ..a<double>(8, 'maxValue', $pb.PbFieldType.OD, protoName: 'maxValue')
    ..a<double>(9, 'stdDeviation', $pb.PbFieldType.OD,
        protoName: 'stdDeviation')
    ..aInt64(10, 'computedAt', protoName: 'computedAt')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  VegetationIndex createEmptyInstance() => VegetationIndex._();
  static VegetationIndex getDefault() =>
      _defaultInstance ??= VegetationIndex._();
  static VegetationIndex? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get processingJobId => $_getSZ(1);
  @$pb.TagNumber(2)
  set processingJobId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  String get fieldId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fieldId(String v) => $_setString(3, v);

  @$pb.TagNumber(5)
  String get indexType => $_getSZ(4);
  @$pb.TagNumber(5)
  set indexType(String v) => $_setString(4, v);

  @$pb.TagNumber(6)
  double get meanValue => $_getN(5);
  @$pb.TagNumber(6)
  set meanValue(double v) => $_setDouble(5, v);

  @$pb.TagNumber(7)
  double get minValue => $_getN(6);
  @$pb.TagNumber(7)
  set minValue(double v) => $_setDouble(6, v);

  @$pb.TagNumber(8)
  double get maxValue => $_getN(7);
  @$pb.TagNumber(8)
  set maxValue(double v) => $_setDouble(7, v);

  @$pb.TagNumber(9)
  double get stdDeviation => $_getN(8);
  @$pb.TagNumber(9)
  set stdDeviation(double v) => $_setDouble(8, v);

  @$pb.TagNumber(10)
  Int64 get computedAt => $_getI64(9);
  @$pb.TagNumber(10)
  set computedAt(Int64 v) => $_setInt64(9, v);
}

/// A single NDVI time series data point.
class NDVITimeSeriesEntry extends $pb.GeneratedMessage {
  factory NDVITimeSeriesEntry({
    Int64? date,
    double? ndviMean,
    double? ndviMin,
    double? ndviMax,
    double? cloudCoverPct,
  }) {
    final msg = NDVITimeSeriesEntry._();
    if (date != null) msg.date = date;
    if (ndviMean != null) msg.ndviMean = ndviMean;
    if (ndviMin != null) msg.ndviMin = ndviMin;
    if (ndviMax != null) msg.ndviMax = ndviMax;
    if (cloudCoverPct != null) msg.cloudCoverPct = cloudCoverPct;
    return msg;
  }

  NDVITimeSeriesEntry._() : super();

  factory NDVITimeSeriesEntry.fromBuffer(List<int> data) =>
      NDVITimeSeriesEntry._()..mergeFromBuffer(data);
  factory NDVITimeSeriesEntry.fromJson(String json) =>
      NDVITimeSeriesEntry._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'NDVITimeSeriesEntry',
    package: const $pb.PackageName('yieldpoint.satellite.vegetation.v1'),
    createEmptyInstance: () => NDVITimeSeriesEntry._(),
  )
    ..aInt64(1, 'date')
    ..a<double>(2, 'ndviMean', $pb.PbFieldType.OD, protoName: 'ndviMean')
    ..a<double>(3, 'ndviMin', $pb.PbFieldType.OD, protoName: 'ndviMin')
    ..a<double>(4, 'ndviMax', $pb.PbFieldType.OD, protoName: 'ndviMax')
    ..a<double>(5, 'cloudCoverPct', $pb.PbFieldType.OD,
        protoName: 'cloudCoverPct')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  NDVITimeSeriesEntry createEmptyInstance() => NDVITimeSeriesEntry._();
  static NDVITimeSeriesEntry getDefault() =>
      _defaultInstance ??= NDVITimeSeriesEntry._();
  static NDVITimeSeriesEntry? _defaultInstance;

  @$pb.TagNumber(1)
  Int64 get date => $_getI64(0);
  @$pb.TagNumber(1)
  set date(Int64 v) => $_setInt64(0, v);

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

  @$pb.TagNumber(5)
  double get cloudCoverPct => $_getN(4);
  @$pb.TagNumber(5)
  set cloudCoverPct(double v) => $_setDouble(4, v);
}

/// Field health assessment based on vegetation indices.
class FieldHealth extends $pb.GeneratedMessage {
  factory FieldHealth({
    String? farmId,
    String? fieldId,
    double? currentNdvi,
    String? ndviTrend,
    double? healthScore,
    String? healthCategory,
    Int64? lastComputed,
  }) {
    final msg = FieldHealth._();
    if (farmId != null) msg.farmId = farmId;
    if (fieldId != null) msg.fieldId = fieldId;
    if (currentNdvi != null) msg.currentNdvi = currentNdvi;
    if (ndviTrend != null) msg.ndviTrend = ndviTrend;
    if (healthScore != null) msg.healthScore = healthScore;
    if (healthCategory != null) msg.healthCategory = healthCategory;
    if (lastComputed != null) msg.lastComputed = lastComputed;
    return msg;
  }

  FieldHealth._() : super();

  factory FieldHealth.fromBuffer(List<int> data) =>
      FieldHealth._()..mergeFromBuffer(data);
  factory FieldHealth.fromJson(String json) =>
      FieldHealth._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'FieldHealth',
    package: const $pb.PackageName('yieldpoint.satellite.vegetation.v1'),
    createEmptyInstance: () => FieldHealth._(),
  )
    ..aOS(1, 'farmId', protoName: 'farmId')
    ..aOS(2, 'fieldId', protoName: 'fieldId')
    ..a<double>(3, 'currentNdvi', $pb.PbFieldType.OD, protoName: 'currentNdvi')
    ..aOS(4, 'ndviTrend', protoName: 'ndviTrend')
    ..a<double>(5, 'healthScore', $pb.PbFieldType.OD, protoName: 'healthScore')
    ..aOS(6, 'healthCategory', protoName: 'healthCategory')
    ..aInt64(7, 'lastComputed', protoName: 'lastComputed')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  FieldHealth createEmptyInstance() => FieldHealth._();
  static FieldHealth getDefault() => _defaultInstance ??= FieldHealth._();
  static FieldHealth? _defaultInstance;

  @$pb.TagNumber(1)
  String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  double get currentNdvi => $_getN(2);
  @$pb.TagNumber(3)
  set currentNdvi(double v) => $_setDouble(2, v);

  @$pb.TagNumber(4)
  String get ndviTrend => $_getSZ(3);
  @$pb.TagNumber(4)
  set ndviTrend(String v) => $_setString(3, v);

  @$pb.TagNumber(5)
  double get healthScore => $_getN(4);
  @$pb.TagNumber(5)
  set healthScore(double v) => $_setDouble(4, v);

  @$pb.TagNumber(6)
  String get healthCategory => $_getSZ(5);
  @$pb.TagNumber(6)
  set healthCategory(String v) => $_setString(5, v);

  @$pb.TagNumber(7)
  Int64 get lastComputed => $_getI64(6);
  @$pb.TagNumber(7)
  set lastComputed(Int64 v) => $_setInt64(6, v);
}
