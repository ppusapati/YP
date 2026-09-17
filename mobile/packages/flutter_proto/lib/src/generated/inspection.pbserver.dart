// This is a generated file - do not edit.
//
// Generated from inspection.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'inspection.pb.dart' as $1;
import 'inspection.pbjson.dart';

export 'inspection.pb.dart';

abstract class InspectionServiceBase extends $pb.GeneratedService {
  $async.Future<$1.GetInspectionResponse> getInspection(
      $pb.ServerContext ctx, $1.GetInspectionRequest request);
  $async.Future<$1.ListInspectionsResponse> listInspections(
      $pb.ServerContext ctx, $1.ListInspectionsRequest request);
  $async.Future<$1.CreateInspectionResponse> createInspection(
      $pb.ServerContext ctx, $1.CreateInspectionRequest request);
  $async.Future<$1.UpdateInspectionResponse> updateInspection(
      $pb.ServerContext ctx, $1.UpdateInspectionRequest request);
  $async.Future<$1.SubmitInspectionResponse> submitInspection(
      $pb.ServerContext ctx, $1.SubmitInspectionRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetInspection':
        return $1.GetInspectionRequest();
      case 'ListInspections':
        return $1.ListInspectionsRequest();
      case 'CreateInspection':
        return $1.CreateInspectionRequest();
      case 'UpdateInspection':
        return $1.UpdateInspectionRequest();
      case 'SubmitInspection':
        return $1.SubmitInspectionRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetInspection':
        return getInspection(ctx, request as $1.GetInspectionRequest);
      case 'ListInspections':
        return listInspections(ctx, request as $1.ListInspectionsRequest);
      case 'CreateInspection':
        return createInspection(ctx, request as $1.CreateInspectionRequest);
      case 'UpdateInspection':
        return updateInspection(ctx, request as $1.UpdateInspectionRequest);
      case 'SubmitInspection':
        return submitInspection(ctx, request as $1.SubmitInspectionRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      InspectionServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => InspectionServiceBase$messageJson;
}
