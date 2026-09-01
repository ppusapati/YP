// This is a generated file - do not edit.
//
// Generated from sensor.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'sensor.pb.dart' as $2;
import 'sensor.pbjson.dart';

export 'sensor.pb.dart';

abstract class SensorServiceBase extends $pb.GeneratedService {
  $async.Future<$2.RegisterSensorResponse> registerSensor(
      $pb.ServerContext ctx, $2.RegisterSensorRequest request);
  $async.Future<$2.GetSensorResponse> getSensor(
      $pb.ServerContext ctx, $2.GetSensorRequest request);
  $async.Future<$2.ListSensorsResponse> listSensors(
      $pb.ServerContext ctx, $2.ListSensorsRequest request);
  $async.Future<$2.UpdateSensorResponse> updateSensor(
      $pb.ServerContext ctx, $2.UpdateSensorRequest request);
  $async.Future<$2.DecommissionSensorResponse> decommissionSensor(
      $pb.ServerContext ctx, $2.DecommissionSensorRequest request);
  $async.Future<$2.IngestReadingResponse> ingestReading(
      $pb.ServerContext ctx, $2.IngestReadingRequest request);
  $async.Future<$2.BatchIngestReadingsResponse> batchIngestReadings(
      $pb.ServerContext ctx, $2.BatchIngestReadingsRequest request);
  $async.Future<$2.GetLatestReadingResponse> getLatestReading(
      $pb.ServerContext ctx, $2.GetLatestReadingRequest request);
  $async.Future<$2.GetReadingHistoryResponse> getReadingHistory(
      $pb.ServerContext ctx, $2.GetReadingHistoryRequest request);
  $async.Future<$2.CreateAlertResponse> createAlert(
      $pb.ServerContext ctx, $2.CreateAlertRequest request);
  $async.Future<$2.ListAlertsResponse> listAlerts(
      $pb.ServerContext ctx, $2.ListAlertsRequest request);
  $async.Future<$2.AcknowledgeAlertResponse> acknowledgeAlert(
      $pb.ServerContext ctx, $2.AcknowledgeAlertRequest request);
  $async.Future<$2.GetSensorNetworkResponse> getSensorNetwork(
      $pb.ServerContext ctx, $2.GetSensorNetworkRequest request);
  $async.Future<$2.CalibrateSensorResponse> calibrateSensor(
      $pb.ServerContext ctx, $2.CalibrateSensorRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'RegisterSensor':
        return $2.RegisterSensorRequest();
      case 'GetSensor':
        return $2.GetSensorRequest();
      case 'ListSensors':
        return $2.ListSensorsRequest();
      case 'UpdateSensor':
        return $2.UpdateSensorRequest();
      case 'DecommissionSensor':
        return $2.DecommissionSensorRequest();
      case 'IngestReading':
        return $2.IngestReadingRequest();
      case 'BatchIngestReadings':
        return $2.BatchIngestReadingsRequest();
      case 'GetLatestReading':
        return $2.GetLatestReadingRequest();
      case 'GetReadingHistory':
        return $2.GetReadingHistoryRequest();
      case 'CreateAlert':
        return $2.CreateAlertRequest();
      case 'ListAlerts':
        return $2.ListAlertsRequest();
      case 'AcknowledgeAlert':
        return $2.AcknowledgeAlertRequest();
      case 'GetSensorNetwork':
        return $2.GetSensorNetworkRequest();
      case 'CalibrateSensor':
        return $2.CalibrateSensorRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'RegisterSensor':
        return registerSensor(ctx, request as $2.RegisterSensorRequest);
      case 'GetSensor':
        return getSensor(ctx, request as $2.GetSensorRequest);
      case 'ListSensors':
        return listSensors(ctx, request as $2.ListSensorsRequest);
      case 'UpdateSensor':
        return updateSensor(ctx, request as $2.UpdateSensorRequest);
      case 'DecommissionSensor':
        return decommissionSensor(ctx, request as $2.DecommissionSensorRequest);
      case 'IngestReading':
        return ingestReading(ctx, request as $2.IngestReadingRequest);
      case 'BatchIngestReadings':
        return batchIngestReadings(
            ctx, request as $2.BatchIngestReadingsRequest);
      case 'GetLatestReading':
        return getLatestReading(ctx, request as $2.GetLatestReadingRequest);
      case 'GetReadingHistory':
        return getReadingHistory(ctx, request as $2.GetReadingHistoryRequest);
      case 'CreateAlert':
        return createAlert(ctx, request as $2.CreateAlertRequest);
      case 'ListAlerts':
        return listAlerts(ctx, request as $2.ListAlertsRequest);
      case 'AcknowledgeAlert':
        return acknowledgeAlert(ctx, request as $2.AcknowledgeAlertRequest);
      case 'GetSensorNetwork':
        return getSensorNetwork(ctx, request as $2.GetSensorNetworkRequest);
      case 'CalibrateSensor':
        return calibrateSensor(ctx, request as $2.CalibrateSensorRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SensorServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => SensorServiceBase$messageJson;
}
