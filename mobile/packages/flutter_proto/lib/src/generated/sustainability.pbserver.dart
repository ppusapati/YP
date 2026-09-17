// This is a generated file - do not edit.
//
// Generated from sustainability.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'sustainability.pb.dart' as $1;
import 'sustainability.pbjson.dart';

export 'sustainability.pb.dart';

abstract class SustainabilityServiceBase extends $pb.GeneratedService {
  $async.Future<$1.RecordInputUseResponse> recordInputUse(
      $pb.ServerContext ctx, $1.RecordInputUseRequest request);
  $async.Future<$1.ListInputUseResponse> listInputUse(
      $pb.ServerContext ctx, $1.ListInputUseRequest request);
  $async.Future<$1.ComputeFootprintResponse> computeFootprint(
      $pb.ServerContext ctx, $1.ComputeFootprintRequest request);
  $async.Future<$1.GetFootprintResponse> getFootprint(
      $pb.ServerContext ctx, $1.GetFootprintRequest request);
  $async.Future<$1.ListFootprintsResponse> listFootprints(
      $pb.ServerContext ctx, $1.ListFootprintsRequest request);
  $async.Future<$1.CheckCertificationResponse> checkCertification(
      $pb.ServerContext ctx, $1.CheckCertificationRequest request);
  $async.Future<$1.ExportCertificationPackResponse> exportCertificationPack(
      $pb.ServerContext ctx, $1.ExportCertificationPackRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'RecordInputUse':
        return $1.RecordInputUseRequest();
      case 'ListInputUse':
        return $1.ListInputUseRequest();
      case 'ComputeFootprint':
        return $1.ComputeFootprintRequest();
      case 'GetFootprint':
        return $1.GetFootprintRequest();
      case 'ListFootprints':
        return $1.ListFootprintsRequest();
      case 'CheckCertification':
        return $1.CheckCertificationRequest();
      case 'ExportCertificationPack':
        return $1.ExportCertificationPackRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'RecordInputUse':
        return recordInputUse(ctx, request as $1.RecordInputUseRequest);
      case 'ListInputUse':
        return listInputUse(ctx, request as $1.ListInputUseRequest);
      case 'ComputeFootprint':
        return computeFootprint(ctx, request as $1.ComputeFootprintRequest);
      case 'GetFootprint':
        return getFootprint(ctx, request as $1.GetFootprintRequest);
      case 'ListFootprints':
        return listFootprints(ctx, request as $1.ListFootprintsRequest);
      case 'CheckCertification':
        return checkCertification(ctx, request as $1.CheckCertificationRequest);
      case 'ExportCertificationPack':
        return exportCertificationPack(
            ctx, request as $1.ExportCertificationPackRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      SustainabilityServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => SustainabilityServiceBase$messageJson;
}
