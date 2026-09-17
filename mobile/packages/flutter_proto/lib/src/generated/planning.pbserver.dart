// This is a generated file - do not edit.
//
// Generated from planning.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'planning.pb.dart' as $1;
import 'planning.pbjson.dart';

export 'planning.pb.dart';

abstract class PlanningServiceBase extends $pb.GeneratedService {
  $async.Future<$1.CreatePlanResponse> createPlan(
      $pb.ServerContext ctx, $1.CreatePlanRequest request);
  $async.Future<$1.GetPlanResponse> getPlan(
      $pb.ServerContext ctx, $1.GetPlanRequest request);
  $async.Future<$1.ListPlansResponse> listPlans(
      $pb.ServerContext ctx, $1.ListPlansRequest request);
  $async.Future<$1.UpdatePlanResponse> updatePlan(
      $pb.ServerContext ctx, $1.UpdatePlanRequest request);
  $async.Future<$1.CommitPlanResponse> commitPlan(
      $pb.ServerContext ctx, $1.CommitPlanRequest request);
  $async.Future<$1.CheckRotationResponse> checkRotation(
      $pb.ServerContext ctx, $1.CheckRotationRequest request);
  $async.Future<$1.GetSowingWindowResponse> getSowingWindow(
      $pb.ServerContext ctx, $1.GetSowingWindowRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreatePlan':
        return $1.CreatePlanRequest();
      case 'GetPlan':
        return $1.GetPlanRequest();
      case 'ListPlans':
        return $1.ListPlansRequest();
      case 'UpdatePlan':
        return $1.UpdatePlanRequest();
      case 'CommitPlan':
        return $1.CommitPlanRequest();
      case 'CheckRotation':
        return $1.CheckRotationRequest();
      case 'GetSowingWindow':
        return $1.GetSowingWindowRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreatePlan':
        return createPlan(ctx, request as $1.CreatePlanRequest);
      case 'GetPlan':
        return getPlan(ctx, request as $1.GetPlanRequest);
      case 'ListPlans':
        return listPlans(ctx, request as $1.ListPlansRequest);
      case 'UpdatePlan':
        return updatePlan(ctx, request as $1.UpdatePlanRequest);
      case 'CommitPlan':
        return commitPlan(ctx, request as $1.CommitPlanRequest);
      case 'CheckRotation':
        return checkRotation(ctx, request as $1.CheckRotationRequest);
      case 'GetSowingWindow':
        return getSowingWindow(ctx, request as $1.GetSowingWindowRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => PlanningServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => PlanningServiceBase$messageJson;
}
