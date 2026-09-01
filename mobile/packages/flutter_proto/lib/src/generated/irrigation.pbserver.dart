// This is a generated file - do not edit.
//
// Generated from irrigation.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'irrigation.pb.dart' as $1;
import 'irrigation.pbjson.dart';

export 'irrigation.pb.dart';

abstract class IrrigationServiceBase extends $pb.GeneratedService {
  $async.Future<$1.CreateScheduleResponse> createSchedule(
      $pb.ServerContext ctx, $1.CreateScheduleRequest request);
  $async.Future<$1.GetScheduleResponse> getSchedule(
      $pb.ServerContext ctx, $1.GetScheduleRequest request);
  $async.Future<$1.ListSchedulesResponse> listSchedules(
      $pb.ServerContext ctx, $1.ListSchedulesRequest request);
  $async.Future<$1.UpdateScheduleResponse> updateSchedule(
      $pb.ServerContext ctx, $1.UpdateScheduleRequest request);
  $async.Future<$1.DeleteScheduleResponse> deleteSchedule(
      $pb.ServerContext ctx, $1.DeleteScheduleRequest request);
  $async.Future<$1.GenerateIrrigationDecisionResponse>
      generateIrrigationDecision(
          $pb.ServerContext ctx, $1.GenerateIrrigationDecisionRequest request);
  $async.Future<$1.CreateZoneResponse> createZone(
      $pb.ServerContext ctx, $1.CreateZoneRequest request);
  $async.Future<$1.ListZonesResponse> listZones(
      $pb.ServerContext ctx, $1.ListZonesRequest request);
  $async.Future<$1.RegisterControllerResponse> registerController(
      $pb.ServerContext ctx, $1.RegisterControllerRequest request);
  $async.Future<$1.ListControllersResponse> listControllers(
      $pb.ServerContext ctx, $1.ListControllersRequest request);
  $async.Future<$1.TriggerIrrigationResponse> triggerIrrigation(
      $pb.ServerContext ctx, $1.TriggerIrrigationRequest request);
  $async.Future<$1.StopIrrigationResponse> stopIrrigation(
      $pb.ServerContext ctx, $1.StopIrrigationRequest request);
  $async.Future<$1.GetWaterUsageResponse> getWaterUsage(
      $pb.ServerContext ctx, $1.GetWaterUsageRequest request);
  $async.Future<$1.GetIrrigationHistoryResponse> getIrrigationHistory(
      $pb.ServerContext ctx, $1.GetIrrigationHistoryRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateSchedule':
        return $1.CreateScheduleRequest();
      case 'GetSchedule':
        return $1.GetScheduleRequest();
      case 'ListSchedules':
        return $1.ListSchedulesRequest();
      case 'UpdateSchedule':
        return $1.UpdateScheduleRequest();
      case 'DeleteSchedule':
        return $1.DeleteScheduleRequest();
      case 'GenerateIrrigationDecision':
        return $1.GenerateIrrigationDecisionRequest();
      case 'CreateZone':
        return $1.CreateZoneRequest();
      case 'ListZones':
        return $1.ListZonesRequest();
      case 'RegisterController':
        return $1.RegisterControllerRequest();
      case 'ListControllers':
        return $1.ListControllersRequest();
      case 'TriggerIrrigation':
        return $1.TriggerIrrigationRequest();
      case 'StopIrrigation':
        return $1.StopIrrigationRequest();
      case 'GetWaterUsage':
        return $1.GetWaterUsageRequest();
      case 'GetIrrigationHistory':
        return $1.GetIrrigationHistoryRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateSchedule':
        return createSchedule(ctx, request as $1.CreateScheduleRequest);
      case 'GetSchedule':
        return getSchedule(ctx, request as $1.GetScheduleRequest);
      case 'ListSchedules':
        return listSchedules(ctx, request as $1.ListSchedulesRequest);
      case 'UpdateSchedule':
        return updateSchedule(ctx, request as $1.UpdateScheduleRequest);
      case 'DeleteSchedule':
        return deleteSchedule(ctx, request as $1.DeleteScheduleRequest);
      case 'GenerateIrrigationDecision':
        return generateIrrigationDecision(
            ctx, request as $1.GenerateIrrigationDecisionRequest);
      case 'CreateZone':
        return createZone(ctx, request as $1.CreateZoneRequest);
      case 'ListZones':
        return listZones(ctx, request as $1.ListZonesRequest);
      case 'RegisterController':
        return registerController(ctx, request as $1.RegisterControllerRequest);
      case 'ListControllers':
        return listControllers(ctx, request as $1.ListControllersRequest);
      case 'TriggerIrrigation':
        return triggerIrrigation(ctx, request as $1.TriggerIrrigationRequest);
      case 'StopIrrigation':
        return stopIrrigation(ctx, request as $1.StopIrrigationRequest);
      case 'GetWaterUsage':
        return getWaterUsage(ctx, request as $1.GetWaterUsageRequest);
      case 'GetIrrigationHistory':
        return getIrrigationHistory(
            ctx, request as $1.GetIrrigationHistoryRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      IrrigationServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => IrrigationServiceBase$messageJson;
}
