import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';

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

  @override
  Future<List<IrrigationZoneModel>> getZones(String fieldId) async {
    final body = jsonEncode({'field_id': fieldId});

    final response = await _client.unary(
      '$_basePath/ListZones',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch irrigation zones',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final zones = data['zones'] as List<dynamic>? ?? [];
    return zones
        .map((e) => IrrigationZoneModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<IrrigationZoneModel> getZoneById(String zoneId) async {
    final body = jsonEncode({'zone_id': zoneId});

    final response = await _client.unary(
      '$_basePath/GetZone',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'not_found',
        message: 'Irrigation zone not found',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    return IrrigationZoneModel.fromJson(data);
  }

  @override
  Future<List<IrrigationScheduleModel>> getSchedules(String zoneId) async {
    final body = jsonEncode({'zone_id': zoneId});

    final response = await _client.unary(
      '$_basePath/ListSchedules',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch irrigation schedules',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final schedules = data['schedules'] as List<dynamic>? ?? [];
    return schedules
        .map(
            (e) => IrrigationScheduleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<IrrigationScheduleModel> updateSchedule(
      IrrigationScheduleModel schedule) async {
    final body = jsonEncode(schedule.toJson());

    final response = await _client.unary(
      '$_basePath/UpdateSchedule',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to update irrigation schedule',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    return IrrigationScheduleModel.fromJson(data);
  }

  @override
  Future<void> deleteSchedule(String scheduleId) async {
    final body = jsonEncode({'schedule_id': scheduleId});

    final response = await _client.unary(
      '$_basePath/DeleteSchedule',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to delete irrigation schedule',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAlerts({String? zoneId}) async {
    final reqBody = <String, dynamic>{};
    if (zoneId != null) reqBody['zone_id'] = zoneId;

    final response = await _client.unary(
      '$_basePath/ListAlerts',
      body: utf8.encoder.convert(jsonEncode(reqBody)),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch irrigation alerts',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final alerts = data['alerts'] as List<dynamic>? ?? [];
    return alerts.cast<Map<String, dynamic>>();
  }
}
