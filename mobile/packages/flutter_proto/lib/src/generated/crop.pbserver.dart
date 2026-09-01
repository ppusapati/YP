// This is a generated file - do not edit.
//
// Generated from crop.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'crop.pb.dart' as $2;
import 'crop.pbjson.dart';

export 'crop.pb.dart';

abstract class CropServiceBase extends $pb.GeneratedService {
  $async.Future<$2.CreateCropResponse> createCrop(
      $pb.ServerContext ctx, $2.CreateCropRequest request);
  $async.Future<$2.GetCropResponse> getCrop(
      $pb.ServerContext ctx, $2.GetCropRequest request);
  $async.Future<$2.ListCropsResponse> listCrops(
      $pb.ServerContext ctx, $2.ListCropsRequest request);
  $async.Future<$2.UpdateCropResponse> updateCrop(
      $pb.ServerContext ctx, $2.UpdateCropRequest request);
  $async.Future<$2.DeleteCropResponse> deleteCrop(
      $pb.ServerContext ctx, $2.DeleteCropRequest request);
  $async.Future<$2.AddVarietyResponse> addVariety(
      $pb.ServerContext ctx, $2.AddVarietyRequest request);
  $async.Future<$2.ListVarietiesResponse> listVarieties(
      $pb.ServerContext ctx, $2.ListVarietiesRequest request);
  $async.Future<$2.GetGrowthStagesResponse> getGrowthStages(
      $pb.ServerContext ctx, $2.GetGrowthStagesRequest request);
  $async.Future<$2.GetCropRequirementsResponse> getCropRequirements(
      $pb.ServerContext ctx, $2.GetCropRequirementsRequest request);
  $async.Future<$2.GenerateRecommendationResponse> generateRecommendation(
      $pb.ServerContext ctx, $2.GenerateRecommendationRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateCrop':
        return $2.CreateCropRequest();
      case 'GetCrop':
        return $2.GetCropRequest();
      case 'ListCrops':
        return $2.ListCropsRequest();
      case 'UpdateCrop':
        return $2.UpdateCropRequest();
      case 'DeleteCrop':
        return $2.DeleteCropRequest();
      case 'AddVariety':
        return $2.AddVarietyRequest();
      case 'ListVarieties':
        return $2.ListVarietiesRequest();
      case 'GetGrowthStages':
        return $2.GetGrowthStagesRequest();
      case 'GetCropRequirements':
        return $2.GetCropRequirementsRequest();
      case 'GenerateRecommendation':
        return $2.GenerateRecommendationRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateCrop':
        return createCrop(ctx, request as $2.CreateCropRequest);
      case 'GetCrop':
        return getCrop(ctx, request as $2.GetCropRequest);
      case 'ListCrops':
        return listCrops(ctx, request as $2.ListCropsRequest);
      case 'UpdateCrop':
        return updateCrop(ctx, request as $2.UpdateCropRequest);
      case 'DeleteCrop':
        return deleteCrop(ctx, request as $2.DeleteCropRequest);
      case 'AddVariety':
        return addVariety(ctx, request as $2.AddVarietyRequest);
      case 'ListVarieties':
        return listVarieties(ctx, request as $2.ListVarietiesRequest);
      case 'GetGrowthStages':
        return getGrowthStages(ctx, request as $2.GetGrowthStagesRequest);
      case 'GetCropRequirements':
        return getCropRequirements(
            ctx, request as $2.GetCropRequirementsRequest);
      case 'GenerateRecommendation':
        return generateRecommendation(
            ctx, request as $2.GenerateRecommendationRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => CropServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => CropServiceBase$messageJson;
}
