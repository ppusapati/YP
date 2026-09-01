import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/irrigation.pb.dart' as irrigation_pb;
import 'package:protobuf/protobuf.dart' as $pb;

import '../models/irrigation_model.dart';

abstract class IrrigationRemoteDataSource {
  Future<List<IrrigationZoneModel>> getZones(String fieldId);
  Future<IrrigationScheduleModel> updateSchedule(IrrigationScheduleModel schedule);
  Future<List<IrrigationScheduleModel>> getSchedules(String zoneId);
}

class IrrigationRemoteDataSourceImpl implements IrrigationRemoteDataSource {
  final ConnectClient _client;

  static const _basePath = '/agriculture.irrigation.v1.IrrigationService';

  IrrigationRemoteDataSourceImpl(this._client);

  Future<ConnectResponse> _call(
      String method, $pb.GeneratedMessage request) async {
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
    final request = irrigation_pb.ListZonesRequest(fieldId: fieldId);
    final response = await _call('ListZones', request);
    final pbResponse = irrigation_pb.ListZonesResponse.fromBuffer(response.body);
    return pbResponse.zones.map(_zoneFromProto).toList();
  }

  @override
  Future<IrrigationScheduleModel> updateSchedule(
      IrrigationScheduleModel schedule) async {
    final pbSchedule = _scheduleToProto(schedule);
    final request = irrigation_pb.UpdateScheduleRequest(schedule: pbSchedule);
    final response = await _call('UpdateSchedule', request);
    final pbResponse =
        irrigation_pb.UpdateScheduleResponse.fromBuffer(response.body);
    return _scheduleFromProto(pbResponse.schedule);
  }

  @override
  Future<List<IrrigationScheduleModel>> getSchedules(String zoneId) async {
    final request = irrigation_pb.ListSchedulesRequest(zoneId: zoneId);
    final response = await _call('ListSchedules', request);
    final pbResponse =
        irrigation_pb.ListSchedulesResponse.fromBuffer(response.body);
    return pbResponse.schedules.map(_scheduleFromProto).toList();
  }

  /// Converts a protobuf [irrigation_pb.IrrigationZone] to [IrrigationZoneModel].
  static IrrigationZoneModel _zoneFromProto(irrigation_pb.IrrigationZone pb) {
    return IrrigationZoneModel(
      id: pb.id,
      fieldId: pb.fieldId,
      name: pb.name,
      waterSource: pb.soilType,
      areaHectares: pb.areaHectares,
      status: pb.isActive ? 'active' : 'inactive',
      flowRate: 0,
    );
  }

  /// Converts a protobuf [irrigation_pb.IrrigationSchedule] to [IrrigationScheduleModel].
  static IrrigationScheduleModel _scheduleFromProto(
      irrigation_pb.IrrigationSchedule pb) {
    final startTime = pb.hasStartTime()
        ? DateTime.fromMillisecondsSinceEpoch(
            pb.startTime.seconds.toInt() * 1000)
        : DateTime.now();
    return IrrigationScheduleModel(
      id: pb.id,
      zoneId: pb.zoneId,
      startTime: startTime,
      durationMinutes: pb.durationMinutes,
      frequency: pb.frequency.name,
      enabled: pb.status == irrigation_pb.IrrigationStatus.IRRIGATION_STATUS_ACTIVE,
    );
  }

  /// Converts an [IrrigationScheduleModel] to a protobuf [irrigation_pb.IrrigationSchedule].
  static irrigation_pb.IrrigationSchedule _scheduleToProto(
      IrrigationScheduleModel model) {
    return irrigation_pb.IrrigationSchedule(
      id: model.id,
      zoneId: model.zoneId,
      durationMinutes: model.durationMinutes,
    );
  }
}
