import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_network/flutter_network.dart';

import '../models/sensor_reading_model.dart';

abstract class SensorRemoteDataSource {
  Future<List<SensorReadingModel>> getSensorReadings(String fieldId);
}

class SensorRemoteDataSourceImpl implements SensorRemoteDataSource {
  final ConnectClient _client;
  SensorRemoteDataSourceImpl(this._client);

  @override
  Future<List<SensorReadingModel>> getSensorReadings(String fieldId) async {
    final response = await _client.unary(
      '/agriculture.sensor.v1.SensorService/ListReadings',
      body: Uint8List.fromList(utf8.encode(jsonEncode({'field_id': fieldId}))),
      headers: {'Content-Type': 'application/json'},
    );
    if (!response.isSuccess) throw Exception('SensorService/ListReadings failed');
    final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final list = data['readings'] as List<dynamic>? ?? [];
    return list.map((e) => SensorReadingModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
