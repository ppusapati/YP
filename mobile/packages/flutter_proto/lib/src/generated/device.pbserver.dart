// This is a generated file - do not edit.
//
// Generated from device.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'device.pb.dart' as $1;
import 'device.pbjson.dart';

export 'device.pb.dart';

abstract class DeviceServiceBase extends $pb.GeneratedService {
  $async.Future<$1.ProvisionDeviceResponse> provisionDevice(
      $pb.ServerContext ctx, $1.ProvisionDeviceRequest request);
  $async.Future<$1.GetDeviceResponse> getDevice(
      $pb.ServerContext ctx, $1.GetDeviceRequest request);
  $async.Future<$1.ListDevicesResponse> listDevices(
      $pb.ServerContext ctx, $1.ListDevicesRequest request);
  $async.Future<$1.RecordHeartbeatsResponse> recordHeartbeats(
      $pb.ServerContext ctx, $1.RecordHeartbeatsRequest request);
  $async.Future<$1.RetireDeviceResponse> retireDevice(
      $pb.ServerContext ctx, $1.RetireDeviceRequest request);
  $async.Future<$1.GetFleetHealthResponse> getFleetHealth(
      $pb.ServerContext ctx, $1.GetFleetHealthRequest request);
  $async.Future<$1.CreateRolloutResponse> createRollout(
      $pb.ServerContext ctx, $1.CreateRolloutRequest request);
  $async.Future<$1.AdvanceRolloutResponse> advanceRollout(
      $pb.ServerContext ctx, $1.AdvanceRolloutRequest request);
  $async.Future<$1.ReportUpdateResponse> reportUpdate(
      $pb.ServerContext ctx, $1.ReportUpdateRequest request);
  $async.Future<$1.ListRolloutsResponse> listRollouts(
      $pb.ServerContext ctx, $1.ListRolloutsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ProvisionDevice':
        return $1.ProvisionDeviceRequest();
      case 'GetDevice':
        return $1.GetDeviceRequest();
      case 'ListDevices':
        return $1.ListDevicesRequest();
      case 'RecordHeartbeats':
        return $1.RecordHeartbeatsRequest();
      case 'RetireDevice':
        return $1.RetireDeviceRequest();
      case 'GetFleetHealth':
        return $1.GetFleetHealthRequest();
      case 'CreateRollout':
        return $1.CreateRolloutRequest();
      case 'AdvanceRollout':
        return $1.AdvanceRolloutRequest();
      case 'ReportUpdate':
        return $1.ReportUpdateRequest();
      case 'ListRollouts':
        return $1.ListRolloutsRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ProvisionDevice':
        return provisionDevice(ctx, request as $1.ProvisionDeviceRequest);
      case 'GetDevice':
        return getDevice(ctx, request as $1.GetDeviceRequest);
      case 'ListDevices':
        return listDevices(ctx, request as $1.ListDevicesRequest);
      case 'RecordHeartbeats':
        return recordHeartbeats(ctx, request as $1.RecordHeartbeatsRequest);
      case 'RetireDevice':
        return retireDevice(ctx, request as $1.RetireDeviceRequest);
      case 'GetFleetHealth':
        return getFleetHealth(ctx, request as $1.GetFleetHealthRequest);
      case 'CreateRollout':
        return createRollout(ctx, request as $1.CreateRolloutRequest);
      case 'AdvanceRollout':
        return advanceRollout(ctx, request as $1.AdvanceRolloutRequest);
      case 'ReportUpdate':
        return reportUpdate(ctx, request as $1.ReportUpdateRequest);
      case 'ListRollouts':
        return listRollouts(ctx, request as $1.ListRolloutsRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => DeviceServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => DeviceServiceBase$messageJson;
}
