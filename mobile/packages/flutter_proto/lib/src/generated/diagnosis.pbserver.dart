// This is a generated file - do not edit.
//
// Generated from diagnosis.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'diagnosis.pb.dart' as $1;
import 'diagnosis.pbjson.dart';

export 'diagnosis.pb.dart';

abstract class PlantDiagnosisServiceBase extends $pb.GeneratedService {
  $async.Future<$1.SubmitDiagnosisResponse> submitDiagnosis(
      $pb.ServerContext ctx, $1.SubmitDiagnosisRequest request);
  $async.Future<$1.GetDiagnosisResponse> getDiagnosis(
      $pb.ServerContext ctx, $1.GetDiagnosisRequest request);
  $async.Future<$1.ListDiagnosesResponse> listDiagnoses(
      $pb.ServerContext ctx, $1.ListDiagnosesRequest request);
  $async.Future<$1.GetDiseaseInfoResponse> getDiseaseInfo(
      $pb.ServerContext ctx, $1.GetDiseaseInfoRequest request);
  $async.Future<$1.GetTreatmentPlanResponse> getTreatmentPlan(
      $pb.ServerContext ctx, $1.GetTreatmentPlanRequest request);
  $async.Future<$1.ListDiseasesResponse> listDiseases(
      $pb.ServerContext ctx, $1.ListDiseasesRequest request);
  $async.Future<$1.IdentifySpeciesResponse> identifySpecies(
      $pb.ServerContext ctx, $1.IdentifySpeciesRequest request);
  $async.Future<$1.DetectNutrientDeficiencyResponse> detectNutrientDeficiency(
      $pb.ServerContext ctx, $1.DetectNutrientDeficiencyRequest request);
  $async.Future<$1.DetectPestDamageResponse> detectPestDamage(
      $pb.ServerContext ctx, $1.DetectPestDamageRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'SubmitDiagnosis':
        return $1.SubmitDiagnosisRequest();
      case 'GetDiagnosis':
        return $1.GetDiagnosisRequest();
      case 'ListDiagnoses':
        return $1.ListDiagnosesRequest();
      case 'GetDiseaseInfo':
        return $1.GetDiseaseInfoRequest();
      case 'GetTreatmentPlan':
        return $1.GetTreatmentPlanRequest();
      case 'ListDiseases':
        return $1.ListDiseasesRequest();
      case 'IdentifySpecies':
        return $1.IdentifySpeciesRequest();
      case 'DetectNutrientDeficiency':
        return $1.DetectNutrientDeficiencyRequest();
      case 'DetectPestDamage':
        return $1.DetectPestDamageRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'SubmitDiagnosis':
        return submitDiagnosis(ctx, request as $1.SubmitDiagnosisRequest);
      case 'GetDiagnosis':
        return getDiagnosis(ctx, request as $1.GetDiagnosisRequest);
      case 'ListDiagnoses':
        return listDiagnoses(ctx, request as $1.ListDiagnosesRequest);
      case 'GetDiseaseInfo':
        return getDiseaseInfo(ctx, request as $1.GetDiseaseInfoRequest);
      case 'GetTreatmentPlan':
        return getTreatmentPlan(ctx, request as $1.GetTreatmentPlanRequest);
      case 'ListDiseases':
        return listDiseases(ctx, request as $1.ListDiseasesRequest);
      case 'IdentifySpecies':
        return identifySpecies(ctx, request as $1.IdentifySpeciesRequest);
      case 'DetectNutrientDeficiency':
        return detectNutrientDeficiency(
            ctx, request as $1.DetectNutrientDeficiencyRequest);
      case 'DetectPestDamage':
        return detectPestDamage(ctx, request as $1.DetectPestDamageRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      PlantDiagnosisServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => PlantDiagnosisServiceBase$messageJson;
}
