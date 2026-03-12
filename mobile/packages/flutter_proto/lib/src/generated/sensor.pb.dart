/// Simulated protobuf generated code for sensor data models.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import 'farm.pb.dart';

/// Enum representing the type of sensor.
class SensorType extends $pb.ProtobufEnum {
  static const SensorType SOIL_MOISTURE =
      SensorType._(0, 'SOIL_MOISTURE');
  static const SensorType TEMPERATURE =
      SensorType._(1, 'TEMPERATURE');
  static const SensorType HUMIDITY =
      SensorType._(2, 'HUMIDITY');
  static const SensorType RAINFALL =
      SensorType._(3, 'RAINFALL');
  static const SensorType SOIL_PH =
      SensorType._(4, 'SOIL_PH');

  static const List<SensorType> values = [
    SOIL_MOISTURE,
    TEMPERATURE,
    HUMIDITY,
    RAINFALL,
    SOIL_PH,
  ];

  static final Map<int, SensorType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SensorType? valueOf(int value) => _byValue[value];

  const SensorType._(int v, String n) : super(v, n);
}

/// A single sensor reading.
class SensorReading extends $pb.GeneratedMessage {
  factory SensorReading({
    String? sensorId,
    SensorType? type,
    double? value,
    String? unit,
    Int64? timestamp,
    LatLng? location,
  }) {
    final msg = SensorReading._();
    if (sensorId != null) msg.sensorId = sensorId;
    if (type != null) msg.type = type;
    if (value != null) msg.value = value;
    if (unit != null) msg.unit = unit;
    if (timestamp != null) msg.timestamp = timestamp;
    if (location != null) msg.location = location;
    return msg;
  }

  SensorReading._() : super();

  factory SensorReading.fromBuffer(List<int> data) =>
      SensorReading._()..mergeFromBuffer(data);
  factory SensorReading.fromJson(String json) =>
      SensorReading._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'SensorReading',
    package: const $pb.PackageName('yieldpoint.sensor.v1'),
    createEmptyInstance: () => SensorReading._(),
  )
    ..aOS(1, 'sensorId', protoName: 'sensorId')
    ..e<SensorType>(2, 'type', $pb.PbFieldType.OE,
        defaultOrMaker: SensorType.SOIL_MOISTURE,
        valueOf: SensorType.valueOf,
        enumValues: SensorType.values)
    ..a<double>(3, 'value', $pb.PbFieldType.OD)
    ..aOS(4, 'unit')
    ..aInt64(5, 'timestamp')
    ..aOM<LatLng>(6, 'location', subBuilder: LatLng._)
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  SensorReading createEmptyInstance() => SensorReading._();
  static SensorReading getDefault() => _defaultInstance ??= SensorReading._();
  static SensorReading? _defaultInstance;

  @$pb.TagNumber(1)
  String get sensorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sensorId(String v) => $_setString(0, v);
  @$pb.TagNumber(1)
  bool hasSensorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSensorId() => clearField(1);

  @$pb.TagNumber(2)
  SensorType get type => $_getN(1);
  @$pb.TagNumber(2)
  set type(SensorType v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  bool hasType() => $_has(1);
  @$pb.TagNumber(2)
  void clearType() => clearField(2);

  @$pb.TagNumber(3)
  double get value => $_getN(2);
  @$pb.TagNumber(3)
  set value(double v) => $_setDouble(2, v);
  @$pb.TagNumber(3)
  bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => clearField(3);

  @$pb.TagNumber(4)
  String get unit => $_getSZ(3);
  @$pb.TagNumber(4)
  set unit(String v) => $_setString(3, v);
  @$pb.TagNumber(4)
  bool hasUnit() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnit() => clearField(4);

  @$pb.TagNumber(5)
  Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp(Int64 v) => $_setInt64(4, v);
  @$pb.TagNumber(5)
  bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => clearField(5);

  @$pb.TagNumber(6)
  LatLng get location => $_getN(5);
  @$pb.TagNumber(6)
  set location(LatLng v) {
    setField(6, v);
  }

  @$pb.TagNumber(6)
  bool hasLocation() => $_has(5);
  @$pb.TagNumber(6)
  void clearLocation() => clearField(6);
  @$pb.TagNumber(6)
  LatLng ensureLocation() => $_ensure(5);
}

/// Aggregated statistics for a sensor.
class SensorStats extends $pb.GeneratedMessage {
  factory SensorStats({
    double? min,
    double? max,
    double? mean,
    double? latest,
  }) {
    final msg = SensorStats._();
    if (min != null) msg.min = min;
    if (max != null) msg.max = max;
    if (mean != null) msg.mean = mean;
    if (latest != null) msg.latest = latest;
    return msg;
  }

  SensorStats._() : super();

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'SensorStats',
    package: const $pb.PackageName('yieldpoint.sensor.v1'),
    createEmptyInstance: () => SensorStats._(),
  )
    ..a<double>(1, 'min', $pb.PbFieldType.OD)
    ..a<double>(2, 'max', $pb.PbFieldType.OD)
    ..a<double>(3, 'mean', $pb.PbFieldType.OD)
    ..a<double>(4, 'latest', $pb.PbFieldType.OD)
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  SensorStats createEmptyInstance() => SensorStats._();
  static SensorStats getDefault() => _defaultInstance ??= SensorStats._();
  static SensorStats? _defaultInstance;

  @$pb.TagNumber(1)
  double get min => $_getN(0);
  @$pb.TagNumber(1)
  set min(double v) => $_setDouble(0, v);

  @$pb.TagNumber(2)
  double get max => $_getN(1);
  @$pb.TagNumber(2)
  set max(double v) => $_setDouble(1, v);

  @$pb.TagNumber(3)
  double get mean => $_getN(2);
  @$pb.TagNumber(3)
  set mean(double v) => $_setDouble(2, v);

  @$pb.TagNumber(4)
  double get latest => $_getN(3);
  @$pb.TagNumber(4)
  set latest(double v) => $_setDouble(3, v);
}

/// Dashboard data for a single sensor.
class SensorDashboard extends $pb.GeneratedMessage {
  factory SensorDashboard({
    String? sensorId,
    List<SensorReading>? readings,
    SensorStats? stats,
  }) {
    final msg = SensorDashboard._();
    if (sensorId != null) msg.sensorId = sensorId;
    if (readings != null) msg.readings.addAll(readings);
    if (stats != null) msg.stats = stats;
    return msg;
  }

  SensorDashboard._() : super();

  factory SensorDashboard.fromBuffer(List<int> data) =>
      SensorDashboard._()..mergeFromBuffer(data);
  factory SensorDashboard.fromJson(String json) =>
      SensorDashboard._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'SensorDashboard',
    package: const $pb.PackageName('yieldpoint.sensor.v1'),
    createEmptyInstance: () => SensorDashboard._(),
  )
    ..aOS(1, 'sensorId', protoName: 'sensorId')
    ..pc<SensorReading>(2, 'readings', $pb.PbFieldType.PM,
        subBuilder: SensorReading._)
    ..aOM<SensorStats>(3, 'stats', subBuilder: SensorStats._)
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  SensorDashboard createEmptyInstance() => SensorDashboard._();
  static SensorDashboard getDefault() =>
      _defaultInstance ??= SensorDashboard._();
  static SensorDashboard? _defaultInstance;

  @$pb.TagNumber(1)
  String get sensorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set sensorId(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  $pb.PbList<SensorReading> get readings => $_getList(1);

  @$pb.TagNumber(3)
  SensorStats get stats => $_getN(2);
  @$pb.TagNumber(3)
  set stats(SensorStats v) => setField(3, v);
  @$pb.TagNumber(3)
  bool hasStats() => $_has(2);
  @$pb.TagNumber(3)
  void clearStats() => clearField(3);
  @$pb.TagNumber(3)
  SensorStats ensureStats() => $_ensure(2);
}
