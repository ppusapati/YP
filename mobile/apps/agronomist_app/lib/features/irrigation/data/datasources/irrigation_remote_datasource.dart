import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';
import 'package:logging/logging.dart';

import '../models/irrigation_model.dart';

abstract class IrrigationRemoteDataSource {
  Future<List<IrrigationZoneModel>> getZones(String fieldId);
  Future<IrrigationScheduleModel> updateSchedule(IrrigationScheduleModel schedule);
  Future<List<IrrigationScheduleModel>> getSchedules(String zoneId);
}

class IrrigationRemoteDataSourceImpl implements IrrigationRemoteDataSource {
  final ConnectClient _client;
  final _log = Logger('IrrigationRemoteDataSource');

  IrrigationRemoteDataSourceImpl(this._client);

  Future<Map<String, dynamic>> _post(String method, Map<String, dynamic> body) async {
    final path = '/agriculture.irrigation.v1.IrrigationService/$method';
    _log.fine('POST $path');
    final response = await _client.unary(path,
      body: Uint8List.fromList(utf8.encode(jsonEncode(body))),
      headers: {'Content-Type': 'application/json'});
    if (!response.isSuccess) throw Exception('IrrigationService/$method failed');
    return jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
  }

  @override
  Future<List<IrrigationZoneModel>> getZones(String fieldId) async {
    final data = await _post('ListZones', {'field_id': fieldId});
    final list = data['zones'] as List<dynamic>? ?? [];
    return list.map((e) => IrrigationZoneModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<IrrigationScheduleModel> updateSchedule(IrrigationScheduleModel schedule) async {
    final data = await _post('UpdateSchedule', {'schedule': schedule.toJson()});
    return IrrigationScheduleModel.fromJson(data['schedule'] as Map<String, dynamic>);
  }

  @override
  Future<List<IrrigationScheduleModel>> getSchedules(String zoneId) async {
    final data = await _post('ListSchedules', {'zone_id': zoneId});
    final list = data['schedules'] as List<dynamic>? ?? [];
    return list.map((e) => IrrigationScheduleModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
