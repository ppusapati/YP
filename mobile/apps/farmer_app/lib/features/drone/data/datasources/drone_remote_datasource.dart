import 'dart:convert';

import 'package:flutter_network/flutter_network.dart';

import '../models/drone_layer_model.dart';

abstract class DroneRemoteDataSource {
  Future<List<DroneLayerModel>> getDroneLayers({
    required String fieldId,
    String? layerType,
  });
  Future<List<DroneFlightModel>> getDroneFlights({required String fieldId});
  Future<List<DroneLayerModel>> getLayersForFlight(String flightId);
}

class DroneRemoteDataSourceImpl implements DroneRemoteDataSource {
  const DroneRemoteDataSourceImpl(this._client);

  final ConnectClient _client;

  static const _basePath = '/yieldpoint.drone.v1.DroneService';

  @override
  Future<List<DroneLayerModel>> getDroneLayers({
    required String fieldId,
    String? layerType,
  }) async {
    final body = <String, dynamic>{'field_id': fieldId};
    if (layerType != null) body['layer_type'] = layerType;

    final response = await _client.unary(
      '$_basePath/ListDroneLayers',
      body: utf8.encoder.convert(jsonEncode(body)),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch drone layers',
      );
    }

    final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final layers = data['layers'] as List<dynamic>? ?? [];
    return layers
        .map((e) => DroneLayerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DroneFlightModel>> getDroneFlights({
    required String fieldId,
  }) async {
    final body = jsonEncode({'field_id': fieldId});

    final response = await _client.unary(
      '$_basePath/ListDroneFlights',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch drone flights',
      );
    }

    final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final flights = data['flights'] as List<dynamic>? ?? [];
    return flights
        .map((e) => DroneFlightModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DroneLayerModel>> getLayersForFlight(String flightId) async {
    final body = jsonEncode({'flight_id': flightId});

    final response = await _client.unary(
      '$_basePath/GetFlightLayers',
      body: utf8.encoder.convert(body),
      headers: {'Content-Type': 'application/json'},
    );

    if (!response.isSuccess) {
      throw const ConnectException(
        code: 'internal',
        message: 'Failed to fetch flight layers',
      );
    }

    final data = jsonDecode(utf8.decode(response.body)) as Map<String, dynamic>;
    final layers = data['layers'] as List<dynamic>? ?? [];
    return layers
        .map((e) => DroneLayerModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
