import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/irrigation.pb.dart' as irrigation_pb;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as timestamp_pb;

import '../models/irrigation_schedule_model.dart';
import '../models/irrigation_zone_model.dart';

abstract class IrrigationRemoteDataSource {
  Future<List<IrrigationZoneModel>> getZones(String fieldId);
  Future<IrrigationZoneModel> getZoneById(String zoneId);
  Future<List<IrrigationScheduleModel>> getSchedules(String zoneId);
  Future<IrrigationScheduleModel> updateSchedule(
      IrrigationScheduleModel schedule);
  Future<void> deleteSchedule(String scheduleId);
  Future<List<Map<String, dynamic>>> getAlerts({String? zoneId});
}

class IrrigationRemoteDataSourceImpl implements IrrigationRemoteDataSource {
  const IrrigationRemoteDataSourceImpl(this._client);

  final ConnectClient _client;

  static const _basePath = '/agriculture.irrigation.v1.IrrigationService';

  Future<ConnectResponse> _call(
    String method,
    $pb.GeneratedMessage request,
  ) async {
    final response = await _client.unary(
      '$_basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw ConnectException(
        code: 'internal',
        message: '$_basePath/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<List<IrrigationZoneModel>> getZones(String fieldId) async {
    final request = irrigation_pb.ListZonesRequest()..fieldId = fieldId;

    final response = await _call('ListZones', request);

    final pbResponse =
        irrigation_pb.ListZonesResponse.fromBuffer(response.body);
    return pbResponse.zones.map(_zoneFromPb).toList();
  }

  @override
  Future<IrrigationZoneModel> getZoneById(String zoneId) async {
    // TODO: GetZone RPC does not exist in the irrigation proto.
    // Falling back to ListZones and filtering by id.
    final request = irrigation_pb.ListZonesRequest();

    final response = await _call('ListZones', request);

    final pbResponse =
        irrigation_pb.ListZonesResponse.fromBuffer(response.body);
    final match = pbResponse.zones.where((z) => z.id == zoneId);
    if (match.isEmpty) {
      throw const ConnectException(
        code: 'not_found',
        message: 'Irrigation zone not found',
      );
    }
    return _zoneFromPb(match.first);
  }

  @override
  Future<List<IrrigationScheduleModel>> getSchedules(String zoneId) async {
    final request = irrigation_pb.ListSchedulesRequest()..zoneId = zoneId;

    final response = await _call('ListSchedules', request);

    final pbResponse =
        irrigation_pb.ListSchedulesResponse.fromBuffer(response.body);
    return pbResponse.schedules.map(_scheduleFromPb).toList();
  }

  @override
  Future<IrrigationScheduleModel> updateSchedule(
      IrrigationScheduleModel schedule) async {
    final pbSchedule = irrigation_pb.IrrigationSchedule()
      ..id = schedule.id
      ..zoneId = schedule.zoneId
      ..durationMinutes = schedule.duration.inMinutes
      ..waterQuantityLiters = schedule.waterVolume
      ..startTime = _dateTimeToTimestamp(schedule.startTime);

    final request = irrigation_pb.UpdateScheduleRequest()
      ..schedule = pbSchedule;

    final response = await _call('UpdateSchedule', request);

    final pbResponse =
        irrigation_pb.UpdateScheduleResponse.fromBuffer(response.body);
    return _scheduleFromPb(pbResponse.schedule);
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    final request = irrigation_pb.DeleteScheduleRequest()..id = scheduleId;

    await _call('DeleteSchedule', request);
  }

  @override
  Future<List<Map<String, dynamic>>> getAlerts({String? zoneId}) async {
    // TODO: ListAlerts RPC does not exist in the irrigation proto.
    // Returning an empty list until the RPC is added.
    return <Map<String, dynamic>>[];
  }

  // ---------------------------------------------------------------------------
  // Protobuf-to-model helpers
  // ---------------------------------------------------------------------------

  static IrrigationZoneModel _zoneFromPb(irrigation_pb.IrrigationZone pb) {
    return IrrigationZoneModel(
      id: pb.id,
      fieldId: pb.fieldId,
      name: pb.name,
      polygon: [
        LatLngPointModel(
          latitude: pb.latitude,
          longitude: pb.longitude,
        ),
      ],
      currentMoisture: 0,
      targetMoisture: 0,
      status: pb.isActive
          ? IrrigationZoneStatus.active
          : IrrigationZoneStatus.inactive,
    );
  }

  static IrrigationScheduleModel _scheduleFromPb(
      irrigation_pb.IrrigationSchedule pb) {
    return IrrigationScheduleModel(
      id: pb.id,
      zoneId: pb.zoneId,
      startTime: pb.hasStartTime()
          ? _timestampToDateTime(pb.startTime)
          : DateTime.now(),
      duration: Duration(minutes: pb.durationMinutes),
      waterVolume: pb.waterQuantityLiters,
      status: _mapScheduleStatus(pb.status),
    );
  }

  // ---------------------------------------------------------------------------
  // Enum mapping helpers
  // ---------------------------------------------------------------------------

  static ScheduleStatus _mapScheduleStatus(
      irrigation_pb.IrrigationStatus pbStatus) {
    final name = pbStatus.name
        .replaceFirst('IRRIGATION_STATUS_', '')
        .toLowerCase();
    return ScheduleStatus.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ScheduleStatus.pending,
    );
  }

  // ---------------------------------------------------------------------------
  // Timestamp helpers
  // ---------------------------------------------------------------------------

  static timestamp_pb.Timestamp _dateTimeToTimestamp(DateTime dt) {
    final ms = dt.millisecondsSinceEpoch;
    return timestamp_pb.Timestamp()
      ..seconds = fixnum.Int64(ms ~/ 1000)
      ..nanos = (ms % 1000) * 1000000;
  }

  static DateTime _timestampToDateTime(timestamp_pb.Timestamp ts) {
    return DateTime.fromMillisecondsSinceEpoch(
      ts.seconds.toInt() * 1000 + ts.nanos ~/ 1000000,
    );
  }
}
