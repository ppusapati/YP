import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/alert.pb.dart' as alert_pb;
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

  /// Irrigation alerts live in alert-service, not the irrigation service.
  static const _alertBasePath = '/agriculture.alert.v1.AlertService';

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

  /// Irrigation alerts for a zone.
  ///
  /// This used to return an empty list without making a call at all, which is
  /// the worst available answer: the alerts screen showed "no alerts" for a
  /// zone whose pump had failed, and there was no error anywhere to suggest
  /// otherwise. A farmer reading that screen concludes the irrigation is fine.
  ///
  /// The irrigation proto still has no ListAlerts RPC, and adding one needs the
  /// Dart client regenerated. It does not need one: alert-service already
  /// stores every alert including the irrigation ones, and its ListAlerts
  /// filters by field. So this resolves the zone to its field and asks the
  /// service that actually owns alerts.
  @override
  Future<List<Map<String, dynamic>>> getAlerts({String? zoneId}) async {
    String? fieldId;
    if (zoneId != null && zoneId.isNotEmpty) {
      // Zones do not appear in an alert; fields do. Resolving one to the other
      // is what lets an alert be attributed back to the zone the caller asked
      // about.
      final zone = await getZoneById(zoneId);
      fieldId = zone.fieldId;
    }

    final request = alert_pb.ListAlertsRequest();
    if (fieldId != null && fieldId.isNotEmpty) {
      request.fieldId = fieldId;
    }

    final response = await _client.unary(
      '$_alertBasePath/ListAlerts',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      // Thrown rather than swallowed into an empty list. A failed call and a
      // zone with nothing wrong must not look identical on this screen.
      throw ConnectException(
        code: 'internal',
        message: '$_alertBasePath/ListAlerts failed',
        statusCode: response.statusCode,
      );
    }

    final pbResponse = alert_pb.ListAlertsResponse.fromBuffer(response.body);
    return pbResponse.alerts
        .where(_isIrrigationAlert)
        .map((a) => _alertToMap(a, zoneId ?? ''))
        .toList();
  }

  /// Whether an alert belongs on the irrigation screen.
  ///
  /// alert-service carries alerts from every source — weather, pests, sensors —
  /// on one field. Matching on the type string keeps the pest alerts off a
  /// screen about water without needing a separate topic per source.
  static bool _isIrrigationAlert(alert_pb.Alert alert) {
    final type = alert.type.toLowerCase();
    return type.contains('irrigation') ||
        type.contains('moisture') ||
        type.contains('water') ||
        type.contains('pressure') ||
        type.contains('sensor_offline');
  }

  static Map<String, dynamic> _alertToMap(alert_pb.Alert alert, String zoneId) {
    return <String, dynamic>{
      'id': alert.id,
      'zone_id': zoneId,
      'type': _irrigationAlertType(alert.type),
      'message': alert.message.isNotEmpty ? alert.message : alert.title,
      'severity': _irrigationSeverity(alert.severity),
      'timestamp': alert.hasTimestamp()
          ? _timestampToDateTime(alert.timestamp).toIso8601String()
          // Never null: the repository parses this unconditionally, and a null
          // here would turn one undated alert into a crash that hides all of
          // them.
          : DateTime.now().toIso8601String(),
      'is_read': alert.read,
    };
  }

  /// Maps the service's free-text type onto the app's AlertType names.
  ///
  /// Returns the name rather than the enum because the repository resolves it
  /// by name, with systemFailure as its fallback — which is the right default
  /// for an unrecognised irrigation alert: it errs towards showing the farmer
  /// something rather than towards silence.
  static String _irrigationAlertType(String serviceType) {
    final type = serviceType.toLowerCase();
    if (type.contains('low') && type.contains('moisture')) return 'lowMoisture';
    if (type.contains('high') && type.contains('moisture')) {
      return 'highMoisture';
    }
    if (type.contains('pressure')) return 'waterPressureLow';
    if (type.contains('schedule')) return 'scheduleConflict';
    if (type.contains('sensor') && type.contains('offline')) {
      return 'sensorOffline';
    }
    return 'systemFailure';
  }

  /// Maps the service's severity onto the app's three levels.
  ///
  /// By name, like _mapScheduleStatus above, rather than by switching on the
  /// generated constants — protobuf enums are classes here, not Dart enums.
  static String _irrigationSeverity(alert_pb.AlertSeverity severity) {
    final name =
        severity.name.replaceFirst('ALERT_SEVERITY_', '').toLowerCase();
    if (name == 'warning') return 'warning';
    // The app has no level above critical. Folding emergency down into it
    // rather than letting it fall through to info: under-reporting a failing
    // pump is the expensive direction of that error.
    if (name == 'critical' || name == 'emergency') return 'critical';
    return 'info';
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
