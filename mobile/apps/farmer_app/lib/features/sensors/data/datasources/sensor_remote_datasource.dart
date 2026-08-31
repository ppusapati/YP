import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';

import '../models/sensor_model.dart';
import '../models/sensor_reading_model.dart';

abstract class SensorRemoteDataSource {
  Future<List<SensorModel>> getSensors();
  Future<List<SensorModel>> getSensorsByType(String type);
  Future<SensorModel> getSensorById(String sensorId);
  Future<List<SensorReadingModel>> getSensorReadings(
    String sensorId, {
    DateTime? from,
    DateTime? to,
  });
  Future<Map<String, SensorModel>> getSensorDashboard();
  Future<void> refreshSensor(String sensorId);
}

class SensorRemoteDataSourceImpl implements SensorRemoteDataSource {
  const SensorRemoteDataSourceImpl(this._client);

  final ConnectClient _client;

  static const _basePath = '/yieldpoint.sensor.v1.SensorService';

  @override
  Future<List<SensorModel>> getSensors() async {
    final response = await _client.unary(
      '$_basePath/ListSensors',
      body: utf8.encoder.convert(jsonEncode(<String, dynamic>{})),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch sensors',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final sensors = data['sensors'] as List<dynamic>? ?? [];
    return sensors
        .map((e) => SensorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SensorModel>> getSensorsByType(String type) async {
    final body = jsonEncode({'type': type});

    final response = await _client.unary(
      '$_basePath/ListSensors',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch sensors by type',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final sensors = data['sensors'] as List<dynamic>? ?? [];
    return sensors
        .map((e) => SensorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<SensorModel> getSensorById(String sensorId) async {
    final body = jsonEncode({'sensor_id': sensorId});

    final response = await _client.unary(
      '$_basePath/GetSensor',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'not_found',
        message: 'Sensor not found',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    return SensorModel.fromJson(data);
  }

  @override
  Future<List<SensorReadingModel>> getSensorReadings(
    String sensorId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final reqBody = <String, dynamic>{'sensor_id': sensorId};
    if (from != null) reqBody['from'] = from.toIso8601String();
    if (to != null) reqBody['to'] = to.toIso8601String();

    final response = await _client.unary(
      '$_basePath/ListReadings',
      body: utf8.encoder.convert(jsonEncode(reqBody)),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch sensor readings',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final readings = data['readings'] as List<dynamic>? ?? [];
    return readings
        .map((e) => SensorReadingModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Map<String, SensorModel>> getSensorDashboard() async {
    final response = await _client.unary(
      '$_basePath/GetDashboard',
      body: utf8.encoder.convert(jsonEncode(<String, dynamic>{})),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch sensor dashboard',
      );
    }

    final data =
        jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final sensors = data['sensors'] as Map<String, dynamic>? ?? {};
    return sensors.map(
      (key, value) =>
          MapEntry(key, SensorModel.fromJson(value as Map<String, dynamic>)),
    );
  }

  @override
  Future<void> refreshSensor(String sensorId) async {
    final body = jsonEncode({'sensor_id': sensorId});

    final response = await _client.unary(
      '$_basePath/RefreshSensor',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to refresh sensor',
      );
    }
  }
}
