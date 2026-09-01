// This is a generated file - do not edit.
//
// Generated from pest.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'pest.pb.dart' as $1;
import 'pest.pbjson.dart';

export 'pest.pb.dart';

abstract class PestPredictionServiceBase extends $pb.GeneratedService {
  $async.Future<$1.PredictPestRiskResponse> predictPestRisk(
      $pb.ServerContext ctx, $1.PredictPestRiskRequest request);
  $async.Future<$1.GetPredictionResponse> getPrediction(
      $pb.ServerContext ctx, $1.GetPredictionRequest request);
  $async.Future<$1.ListPredictionsResponse> listPredictions(
      $pb.ServerContext ctx, $1.ListPredictionsRequest request);
  $async.Future<$1.ReportObservationResponse> reportObservation(
      $pb.ServerContext ctx, $1.ReportObservationRequest request);
  $async.Future<$1.ListObservationsResponse> listObservations(
      $pb.ServerContext ctx, $1.ListObservationsRequest request);
  $async.Future<$1.GetPestSpeciesResponse> getPestSpecies(
      $pb.ServerContext ctx, $1.GetPestSpeciesRequest request);
  $async.Future<$1.ListPestSpeciesResponse> listPestSpecies(
      $pb.ServerContext ctx, $1.ListPestSpeciesRequest request);
  $async.Future<$1.GetTreatmentPlanResponse> getTreatmentPlan(
      $pb.ServerContext ctx, $1.GetTreatmentPlanRequest request);
  $async.Future<$1.GetRiskMapResponse> getRiskMap(
      $pb.ServerContext ctx, $1.GetRiskMapRequest request);
  $async.Future<$1.ListAlertsResponse> listAlerts(
      $pb.ServerContext ctx, $1.ListAlertsRequest request);
  $async.Future<$1.AcknowledgeAlertResponse> acknowledgeAlert(
      $pb.ServerContext ctx, $1.AcknowledgeAlertRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'PredictPestRisk':
        return $1.PredictPestRiskRequest();
      case 'GetPrediction':
        return $1.GetPredictionRequest();
      case 'ListPredictions':
        return $1.ListPredictionsRequest();
      case 'ReportObservation':
        return $1.ReportObservationRequest();
      case 'ListObservations':
        return $1.ListObservationsRequest();
      case 'GetPestSpecies':
        return $1.GetPestSpeciesRequest();
      case 'ListPestSpecies':
        return $1.ListPestSpeciesRequest();
      case 'GetTreatmentPlan':
        return $1.GetTreatmentPlanRequest();
      case 'GetRiskMap':
        return $1.GetRiskMapRequest();
      case 'ListAlerts':
        return $1.ListAlertsRequest();
      case 'AcknowledgeAlert':
        return $1.AcknowledgeAlertRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'PredictPestRisk':
        return predictPestRisk(ctx, request as $1.PredictPestRiskRequest);
      case 'GetPrediction':
        return getPrediction(ctx, request as $1.GetPredictionRequest);
      case 'ListPredictions':
        return listPredictions(ctx, request as $1.ListPredictionsRequest);
      case 'ReportObservation':
        return reportObservation(ctx, request as $1.ReportObservationRequest);
      case 'ListObservations':
        return listObservations(ctx, request as $1.ListObservationsRequest);
      case 'GetPestSpecies':
        return getPestSpecies(ctx, request as $1.GetPestSpeciesRequest);
      case 'ListPestSpecies':
        return listPestSpecies(ctx, request as $1.ListPestSpeciesRequest);
      case 'GetTreatmentPlan':
        return getTreatmentPlan(ctx, request as $1.GetTreatmentPlanRequest);
      case 'GetRiskMap':
        return getRiskMap(ctx, request as $1.GetRiskMapRequest);
      case 'ListAlerts':
        return listAlerts(ctx, request as $1.ListAlertsRequest);
      case 'AcknowledgeAlert':
        return acknowledgeAlert(ctx, request as $1.AcknowledgeAlertRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      PestPredictionServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => PestPredictionServiceBase$messageJson;
}
