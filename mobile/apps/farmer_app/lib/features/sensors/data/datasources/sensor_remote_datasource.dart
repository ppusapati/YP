import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/sensor.pb.dart' as sensor_pb;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as timestamp_pb;

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

  static const _basePath = '/agriculture.sensor.v1.SensorService';

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
  Future<List<SensorModel>> getSensors() async {
    final request = sensor_pb.ListSensorsRequest();

    final response = await _call('ListSensors', request);

    final pbResponse =
        sensor_pb.ListSensorsResponse.fromBuffer(response.body);
    return pbResponse.sensors.map(_sensorFromPb).toList();
  }

  @override
  Future<List<SensorModel>> getSensorsByType(String type) async {
    final request = sensor_pb.ListSensorsRequest()
      ..sensorType = _parsePbSensorType(type);

    final response = await _call('ListSensors', request);

    final pbResponse =
        sensor_pb.ListSensorsResponse.fromBuffer(response.body);
    return pbResponse.sensors.map(_sensorFromPb).toList();
  }

  @override
  Future<SensorModel> getSensorById(String sensorId) async {
    final request = sensor_pb.GetSensorRequest()..id = sensorId;

    final response = await _call('GetSensor', request);

    final pbResponse =
        sensor_pb.GetSensorResponse.fromBuffer(response.body);
    return _sensorFromPb(pbResponse.sensor);
  }

  @override
  Future<List<SensorReadingModel>> getSensorReadings(
    String sensorId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final request = sensor_pb.GetReadingHistoryRequest()
      ..sensorId = sensorId;
    if (from != null) {
      request.startTime = _dateTimeToTimestamp(from);
    }
    if (to != null) {
      request.endTime = _dateTimeToTimestamp(to);
    }

    final response = await _call('GetReadingHistory', request);

    final pbResponse =
        sensor_pb.GetReadingHistoryResponse.fromBuffer(response.body);
    return pbResponse.readings.map(_readingFromPb).toList();
  }

  @override
  Future<Map<String, SensorModel>> getSensorDashboard() async {
    // TODO: GetDashboard RPC does not exist in the sensor proto.
    // Falling back to ListSensors and indexing by id.
    final request = sensor_pb.ListSensorsRequest();

    final response = await _call('ListSensors', request);

    final pbResponse =
        sensor_pb.ListSensorsResponse.fromBuffer(response.body);
    return {
      for (final s in pbResponse.sensors) s.id: _sensorFromPb(s),
    };
  }

  @override
  Future<void> refreshSensor(String sensorId) async {
    // TODO: RefreshSensor RPC does not exist in the sensor proto.
    // Using GetSensor as a read-through refresh until the RPC is added.
    final request = sensor_pb.GetSensorRequest()..id = sensorId;
    await _call('GetSensor', request);
  }

  // ---------------------------------------------------------------------------
  // Protobuf-to-model helpers
  // ---------------------------------------------------------------------------

  static SensorModel _sensorFromPb(sensor_pb.Sensor pb) {
    return SensorModel(
      id: pb.id,
      name: pb.deviceId.isNotEmpty ? pb.deviceId : '${pb.manufacturer} ${pb.model}'.trim(),
      type: _mapSensorType(pb.sensorType),
      location: SensorLocationModel(
        latitude: pb.hasLocation() ? pb.location.latitude : 0,
        longitude: pb.hasLocation() ? pb.location.longitude : 0,
        fieldId: pb.fieldId.isNotEmpty ? pb.fieldId : null,
      ),
      status: _mapSensorStatus(pb.status),
      lastReading: 0,
      batteryLevel: pb.batteryLevelPct.toInt(),
    );
  }

  static SensorReadingModel _readingFromPb(sensor_pb.SensorReading pb) {
    return SensorReadingModel(
      sensorId: pb.sensorId,
      type: SensorType.temperature, // SensorReading pb has no type field
      value: pb.value,
      unit: pb.unit,
      timestamp: pb.hasTimestamp()
          ? _timestampToDateTime(pb.timestamp)
          : DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Enum mapping helpers
  // ---------------------------------------------------------------------------

  static SensorType _mapSensorType(sensor_pb.SensorType pbType) {
    final name = pbType.name
        .replaceFirst('SENSOR_TYPE_', '')
        .toLowerCase();
    return SensorType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => SensorType.temperature,
    );
  }

  static SensorStatus _mapSensorStatus(sensor_pb.SensorStatus pbStatus) {
    final name = pbStatus.name
        .replaceFirst('SENSOR_STATUS_', '')
        .toLowerCase();
    return SensorStatus.values.firstWhere(
      (e) => e.name == name,
      orElse: () => SensorStatus.offline,
    );
  }

  static sensor_pb.SensorType _parsePbSensorType(String type) {
    final upper = 'SENSOR_TYPE_${type.toUpperCase()}';
    return sensor_pb.SensorType.values.firstWhere(
      (e) => e.name == upper,
      orElse: () => sensor_pb.SensorType.SENSOR_TYPE_UNSPECIFIED,
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
