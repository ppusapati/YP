/// Simulated protobuf generated code for irrigation models.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import 'farm.pb.dart';

/// An irrigation zone within a field.
class IrrigationZone extends $pb.GeneratedMessage {
  factory IrrigationZone({
    String? id,
    String? fieldId,
    List<LatLng>? polygon,
    double? moistureLevel,
    IrrigationSchedule? schedule,
  }) {
    final msg = IrrigationZone._();
    if (id != null) msg.id = id;
    if (fieldId != null) msg.fieldId = fieldId;
    if (polygon != null) msg.polygon.addAll(polygon);
    if (moistureLevel != null) msg.moistureLevel = moistureLevel;
    if (schedule != null) msg.schedule = schedule;
    return msg;
  }

  IrrigationZone._() : super();

  factory IrrigationZone.fromBuffer(List<int> data) =>
      IrrigationZone._()..mergeFromBuffer(data);
  factory IrrigationZone.fromJson(String json) =>
      IrrigationZone._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'IrrigationZone',
    package: const $pb.PackageName('yieldpoint.irrigation.v1'),
    createEmptyInstance: () => IrrigationZone._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'fieldId', protoName: 'fieldId')
    ..pc<LatLng>(3, 'polygon', $pb.PbFieldType.PM, subBuilder: LatLng._)
    ..a<double>(4, 'moistureLevel', $pb.PbFieldType.OD,
        protoName: 'moistureLevel')
    ..aOM<IrrigationSchedule>(5, 'schedule',
        subBuilder: IrrigationSchedule._)
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  IrrigationZone createEmptyInstance() => IrrigationZone._();
  static IrrigationZone getDefault() =>
      _defaultInstance ??= IrrigationZone._();
  static IrrigationZone? _defaultInstance;

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
  $pb.PbList<LatLng> get polygon => $_getList(2);

  @$pb.TagNumber(4)
  double get moistureLevel => $_getN(3);
  @$pb.TagNumber(4)
  set moistureLevel(double v) => $_setDouble(3, v);
  @$pb.TagNumber(4)
  bool hasMoistureLevel() => $_has(3);
  @$pb.TagNumber(4)
  void clearMoistureLevel() => clearField(4);

  @$pb.TagNumber(5)
  IrrigationSchedule get schedule => $_getN(4);
  @$pb.TagNumber(5)
  set schedule(IrrigationSchedule v) => setField(5, v);
  @$pb.TagNumber(5)
  bool hasSchedule() => $_has(4);
  @$pb.TagNumber(5)
  void clearSchedule() => clearField(5);
  @$pb.TagNumber(5)
  IrrigationSchedule ensureSchedule() => $_ensure(4);
}

/// A scheduled irrigation event.
class IrrigationSchedule extends $pb.GeneratedMessage {
  factory IrrigationSchedule({
    String? zoneId,
    Int64? startTime,
    int? duration,
    double? waterVolume,
  }) {
    final msg = IrrigationSchedule._();
    if (zoneId != null) msg.zoneId = zoneId;
    if (startTime != null) msg.startTime = startTime;
    if (duration != null) msg.duration = duration;
    if (waterVolume != null) msg.waterVolume = waterVolume;
    return msg;
  }

  IrrigationSchedule._() : super();

  factory IrrigationSchedule.fromBuffer(List<int> data) =>
      IrrigationSchedule._()..mergeFromBuffer(data);
  factory IrrigationSchedule.fromJson(String json) =>
      IrrigationSchedule._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'IrrigationSchedule',
    package: const $pb.PackageName('yieldpoint.irrigation.v1'),
    createEmptyInstance: () => IrrigationSchedule._(),
  )
    ..aOS(1, 'zoneId', protoName: 'zoneId')
    ..aInt64(2, 'startTime', protoName: 'startTime')
    ..a<int>(3, 'duration', $pb.PbFieldType.O3)
    ..a<double>(4, 'waterVolume', $pb.PbFieldType.OD, protoName: 'waterVolume')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  IrrigationSchedule createEmptyInstance() => IrrigationSchedule._();
  static IrrigationSchedule getDefault() =>
      _defaultInstance ??= IrrigationSchedule._();
  static IrrigationSchedule? _defaultInstance;

  @$pb.TagNumber(1)
  String get zoneId => $_getSZ(0);
  @$pb.TagNumber(1)
  set zoneId(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  Int64 get startTime => $_getI64(1);
  @$pb.TagNumber(2)
  set startTime(Int64 v) => $_setInt64(1, v);

  @$pb.TagNumber(3)
  int get duration => $_getIZ(2);
  @$pb.TagNumber(3)
  set duration(int v) => $_setSignedInt32(2, v);

  @$pb.TagNumber(4)
  double get waterVolume => $_getN(3);
  @$pb.TagNumber(4)
  set waterVolume(double v) => $_setDouble(3, v);
}

/// An irrigation alert.
class IrrigationAlert extends $pb.GeneratedMessage {
  factory IrrigationAlert({
    String? zoneId,
    String? alertType,
    String? message,
    String? severity,
  }) {
    final msg = IrrigationAlert._();
    if (zoneId != null) msg.zoneId = zoneId;
    if (alertType != null) msg.alertType = alertType;
    if (message != null) msg.message = message;
    if (severity != null) msg.severity = severity;
    return msg;
  }

  IrrigationAlert._() : super();

  factory IrrigationAlert.fromBuffer(List<int> data) =>
      IrrigationAlert._()..mergeFromBuffer(data);
  factory IrrigationAlert.fromJson(String json) =>
      IrrigationAlert._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'IrrigationAlert',
    package: const $pb.PackageName('yieldpoint.irrigation.v1'),
    createEmptyInstance: () => IrrigationAlert._(),
  )
    ..aOS(1, 'zoneId', protoName: 'zoneId')
    ..aOS(2, 'alertType', protoName: 'alertType')
    ..aOS(3, 'message')
    ..aOS(4, 'severity')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  IrrigationAlert createEmptyInstance() => IrrigationAlert._();
  static IrrigationAlert getDefault() =>
      _defaultInstance ??= IrrigationAlert._();
  static IrrigationAlert? _defaultInstance;

  @$pb.TagNumber(1)
  String get zoneId => $_getSZ(0);
  @$pb.TagNumber(1)
  set zoneId(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get alertType => $_getSZ(1);
  @$pb.TagNumber(2)
  set alertType(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  String get severity => $_getSZ(3);
  @$pb.TagNumber(4)
  set severity(String v) => $_setString(3, v);
}
