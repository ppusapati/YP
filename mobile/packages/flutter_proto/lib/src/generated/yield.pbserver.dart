// This is a generated file - do not edit.
//
// Generated from yield.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'yield.pb.dart' as $1;
import 'yield.pbjson.dart';

export 'yield.pb.dart';

abstract class YieldServiceBase extends $pb.GeneratedService {
  $async.Future<$1.PredictYieldResponse> predictYield(
      $pb.ServerContext ctx, $1.PredictYieldRequest request);
  $async.Future<$1.GetPredictionResponse> getPrediction(
      $pb.ServerContext ctx, $1.GetPredictionRequest request);
  $async.Future<$1.ListPredictionsResponse> listPredictions(
      $pb.ServerContext ctx, $1.ListPredictionsRequest request);
  $async.Future<$1.RecordYieldResponse> recordYield(
      $pb.ServerContext ctx, $1.RecordYieldRequest request);
  $async.Future<$1.GetYieldHistoryResponse> getYieldHistory(
      $pb.ServerContext ctx, $1.GetYieldHistoryRequest request);
  $async.Future<$1.CreateHarvestPlanResponse> createHarvestPlan(
      $pb.ServerContext ctx, $1.CreateHarvestPlanRequest request);
  $async.Future<$1.GetHarvestPlanResponse> getHarvestPlan(
      $pb.ServerContext ctx, $1.GetHarvestPlanRequest request);
  $async.Future<$1.ListHarvestPlansResponse> listHarvestPlans(
      $pb.ServerContext ctx, $1.ListHarvestPlansRequest request);
  $async.Future<$1.GetCropPerformanceResponse> getCropPerformance(
      $pb.ServerContext ctx, $1.GetCropPerformanceRequest request);
  $async.Future<$1.CompareYieldsResponse> compareYields(
      $pb.ServerContext ctx, $1.CompareYieldsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'PredictYield':
        return $1.PredictYieldRequest();
      case 'GetPrediction':
        return $1.GetPredictionRequest();
      case 'ListPredictions':
        return $1.ListPredictionsRequest();
      case 'RecordYield':
        return $1.RecordYieldRequest();
      case 'GetYieldHistory':
        return $1.GetYieldHistoryRequest();
      case 'CreateHarvestPlan':
        return $1.CreateHarvestPlanRequest();
      case 'GetHarvestPlan':
        return $1.GetHarvestPlanRequest();
      case 'ListHarvestPlans':
        return $1.ListHarvestPlansRequest();
      case 'GetCropPerformance':
        return $1.GetCropPerformanceRequest();
      case 'CompareYields':
        return $1.CompareYieldsRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'PredictYield':
        return predictYield(ctx, request as $1.PredictYieldRequest);
      case 'GetPrediction':
        return getPrediction(ctx, request as $1.GetPredictionRequest);
      case 'ListPredictions':
        return listPredictions(ctx, request as $1.ListPredictionsRequest);
      case 'RecordYield':
        return recordYield(ctx, request as $1.RecordYieldRequest);
      case 'GetYieldHistory':
        return getYieldHistory(ctx, request as $1.GetYieldHistoryRequest);
      case 'CreateHarvestPlan':
        return createHarvestPlan(ctx, request as $1.CreateHarvestPlanRequest);
      case 'GetHarvestPlan':
        return getHarvestPlan(ctx, request as $1.GetHarvestPlanRequest);
      case 'ListHarvestPlans':
        return listHarvestPlans(ctx, request as $1.ListHarvestPlansRequest);
      case 'GetCropPerformance':
        return getCropPerformance(ctx, request as $1.GetCropPerformanceRequest);
      case 'CompareYields':
        return compareYields(ctx, request as $1.CompareYieldsRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => YieldServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => YieldServiceBase$messageJson;
}
