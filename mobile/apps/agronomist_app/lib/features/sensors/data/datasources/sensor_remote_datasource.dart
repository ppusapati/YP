import 'package:flutter_network/flutter_network.dart';

import '../models/sensor_reading_model.dart';

abstract class SensorRemoteDataSource {
  Future<List<SensorReadingModel>> getSensorReadings(String fieldId);
}

class SensorRemoteDataSourceImpl implements SensorRemoteDataSource {
  // Unused while getSensorReadings is unimplemented below; it is what the
  // replacement call will go through.
  // ignore: unused_field
  final ConnectClient _client;
  SensorRemoteDataSourceImpl(this._client);

  // The generated SensorService proto has GetReadingHistory (requires sensorId)
  // but no RPC that lists readings by fieldId. The old code called a
  // ListReadings endpoint that has no generated protobuf request type.
  @override
  Future<List<SensorReadingModel>> getSensorReadings(String fieldId) {
    throw UnimplementedError(
      'SensorService/ListReadings has no generated protobuf request type. '
      'Use GetReadingHistory with a sensorId instead.',
    );
  }
}
