// This is a generated file - do not edit.
//
// Generated from ai_gateway.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'ai_gateway.pb.dart' as $0;
import 'ai_gateway.pbjson.dart';

export 'ai_gateway.pb.dart';

abstract class AIGatewayServiceBase extends $pb.GeneratedService {
  $async.Future<$0.DiagnoseImageResponse> diagnoseImage(
      $pb.ServerContext ctx, $0.DiagnoseImageRequest request);
  $async.Future<$0.DetectPestsResponse> detectPests(
      $pb.ServerContext ctx, $0.DetectPestsRequest request);
  $async.Future<$0.DetectNutrientDeficiencyResponse> detectNutrientDeficiency(
      $pb.ServerContext ctx, $0.DetectNutrientDeficiencyRequest request);
  $async.Future<$0.ClassifyPlantResponse> classifyPlant(
      $pb.ServerContext ctx, $0.ClassifyPlantRequest request);
  $async.Future<$0.PredictYieldResponse> predictYield(
      $pb.ServerContext ctx, $0.PredictYieldRequest request);
  $async.Future<$0.SimulateCropGrowthResponse> simulateCropGrowth(
      $pb.ServerContext ctx, $0.SimulateCropGrowthRequest request);
  $async.Future<$0.ComputeNDVIResponse> computeNDVI(
      $pb.ServerContext ctx, $0.ComputeNDVIRequest request);
  $async.Future<$0.DetectVegetationStressResponse> detectVegetationStress(
      $pb.ServerContext ctx, $0.DetectVegetationStressRequest request);
  $async.Future<$0.RecommendCropsResponse> recommendCrops(
      $pb.ServerContext ctx, $0.RecommendCropsRequest request);
  $async.Future<$0.EvaluateFieldRiskResponse> evaluateFieldRisk(
      $pb.ServerContext ctx, $0.EvaluateFieldRiskRequest request);
  $async.Future<$0.ComputeFieldAnalyticsResponse> computeFieldAnalytics(
      $pb.ServerContext ctx, $0.ComputeFieldAnalyticsRequest request);
  $async.Future<$0.GeneratePrescriptionResponse> generatePrescription(
      $pb.ServerContext ctx, $0.GeneratePrescriptionRequest request);
  $async.Future<$0.AnalyzeTerrainResponse> analyzeTerrain(
      $pb.ServerContext ctx, $0.AnalyzeTerrainRequest request);
  $async.Future<$0.SimulateWaterFlowResponse> simulateWaterFlow(
      $pb.ServerContext ctx, $0.SimulateWaterFlowRequest request);
  $async.Future<$0.ListTrainingSamplesResponse> listTrainingSamples(
      $pb.ServerContext ctx, $0.ListTrainingSamplesRequest request);
  $async.Future<$0.SubmitLabelReviewResponse> submitLabelReview(
      $pb.ServerContext ctx, $0.SubmitLabelReviewRequest request);
  $async.Future<$0.GetTrainingSampleImageResponse> getTrainingSampleImage(
      $pb.ServerContext ctx, $0.GetTrainingSampleImageRequest request);
  $async.Future<$0.RequestSecondOpinionResponse> requestSecondOpinion(
      $pb.ServerContext ctx, $0.RequestSecondOpinionRequest request);
  $async.Future<$0.GetReviewAgreementResponse> getReviewAgreement(
      $pb.ServerContext ctx, $0.GetReviewAgreementRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'DiagnoseImage':
        return $0.DiagnoseImageRequest();
      case 'DetectPests':
        return $0.DetectPestsRequest();
      case 'DetectNutrientDeficiency':
        return $0.DetectNutrientDeficiencyRequest();
      case 'ClassifyPlant':
        return $0.ClassifyPlantRequest();
      case 'PredictYield':
        return $0.PredictYieldRequest();
      case 'SimulateCropGrowth':
        return $0.SimulateCropGrowthRequest();
      case 'ComputeNDVI':
        return $0.ComputeNDVIRequest();
      case 'DetectVegetationStress':
        return $0.DetectVegetationStressRequest();
      case 'RecommendCrops':
        return $0.RecommendCropsRequest();
      case 'EvaluateFieldRisk':
        return $0.EvaluateFieldRiskRequest();
      case 'ComputeFieldAnalytics':
        return $0.ComputeFieldAnalyticsRequest();
      case 'GeneratePrescription':
        return $0.GeneratePrescriptionRequest();
      case 'AnalyzeTerrain':
        return $0.AnalyzeTerrainRequest();
      case 'SimulateWaterFlow':
        return $0.SimulateWaterFlowRequest();
      case 'ListTrainingSamples':
        return $0.ListTrainingSamplesRequest();
      case 'SubmitLabelReview':
        return $0.SubmitLabelReviewRequest();
      case 'GetTrainingSampleImage':
        return $0.GetTrainingSampleImageRequest();
      case 'RequestSecondOpinion':
        return $0.RequestSecondOpinionRequest();
      case 'GetReviewAgreement':
        return $0.GetReviewAgreementRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'DiagnoseImage':
        return diagnoseImage(ctx, request as $0.DiagnoseImageRequest);
      case 'DetectPests':
        return detectPests(ctx, request as $0.DetectPestsRequest);
      case 'DetectNutrientDeficiency':
        return detectNutrientDeficiency(
            ctx, request as $0.DetectNutrientDeficiencyRequest);
      case 'ClassifyPlant':
        return classifyPlant(ctx, request as $0.ClassifyPlantRequest);
      case 'PredictYield':
        return predictYield(ctx, request as $0.PredictYieldRequest);
      case 'SimulateCropGrowth':
        return simulateCropGrowth(ctx, request as $0.SimulateCropGrowthRequest);
      case 'ComputeNDVI':
        return computeNDVI(ctx, request as $0.ComputeNDVIRequest);
      case 'DetectVegetationStress':
        return detectVegetationStress(
            ctx, request as $0.DetectVegetationStressRequest);
      case 'RecommendCrops':
        return recommendCrops(ctx, request as $0.RecommendCropsRequest);
      case 'EvaluateFieldRisk':
        return evaluateFieldRisk(ctx, request as $0.EvaluateFieldRiskRequest);
      case 'ComputeFieldAnalytics':
        return computeFieldAnalytics(
            ctx, request as $0.ComputeFieldAnalyticsRequest);
      case 'GeneratePrescription':
        return generatePrescription(
            ctx, request as $0.GeneratePrescriptionRequest);
      case 'AnalyzeTerrain':
        return analyzeTerrain(ctx, request as $0.AnalyzeTerrainRequest);
      case 'SimulateWaterFlow':
        return simulateWaterFlow(ctx, request as $0.SimulateWaterFlowRequest);
      case 'ListTrainingSamples':
        return listTrainingSamples(
            ctx, request as $0.ListTrainingSamplesRequest);
      case 'SubmitLabelReview':
        return submitLabelReview(ctx, request as $0.SubmitLabelReviewRequest);
      case 'GetTrainingSampleImage':
        return getTrainingSampleImage(
            ctx, request as $0.GetTrainingSampleImageRequest);
      case 'RequestSecondOpinion':
        return requestSecondOpinion(
            ctx, request as $0.RequestSecondOpinionRequest);
      case 'GetReviewAgreement':
        return getReviewAgreement(ctx, request as $0.GetReviewAgreementRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => AIGatewayServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => AIGatewayServiceBase$messageJson;
}
