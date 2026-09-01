// This is a generated file - do not edit.
//
// Generated from satellite.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'satellite.pb.dart' as $1;
import 'satellite.pbjson.dart';

export 'satellite.pb.dart';

abstract class SatelliteServiceBase extends $pb.GeneratedService {
  $async.Future<$1.RequestImageryResponse> requestImagery(
      $pb.ServerContext ctx, $1.RequestImageryRequest request);
  $async.Future<$1.GetImageResponse> getImage(
      $pb.ServerContext ctx, $1.GetImageRequest request);
  $async.Future<$1.ListImagesResponse> listImages(
      $pb.ServerContext ctx, $1.ListImagesRequest request);
  $async.Future<$1.ComputeIndexResponse> computeNDVI(
      $pb.ServerContext ctx, $1.ComputeIndexRequest request);
  $async.Future<$1.ComputeIndexResponse> computeNDWI(
      $pb.ServerContext ctx, $1.ComputeIndexRequest request);
  $async.Future<$1.ComputeIndexResponse> computeEVI(
      $pb.ServerContext ctx, $1.ComputeIndexRequest request);
  $async.Future<$1.GetVegetationIndicesResponse> getVegetationIndices(
      $pb.ServerContext ctx, $1.GetVegetationIndicesRequest request);
  $async.Future<$1.DetectCropStressResponse> detectCropStress(
      $pb.ServerContext ctx, $1.DetectCropStressRequest request);
  $async.Future<$1.GetTemporalAnalysisResponse> getTemporalAnalysis(
      $pb.ServerContext ctx, $1.GetTemporalAnalysisRequest request);
  $async.Future<$1.ListAlertsResponse> listAlerts(
      $pb.ServerContext ctx, $1.ListAlertsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'RequestImagery':
        return $1.RequestImageryRequest();
      case 'GetImage':
        return $1.GetImageRequest();
      case 'ListImages':
        return $1.ListImagesRequest();
      case 'ComputeNDVI':
        return $1.ComputeIndexRequest();
      case 'ComputeNDWI':
        return $1.ComputeIndexRequest();
      case 'ComputeEVI':
        return $1.ComputeIndexRequest();
      case 'GetVegetationIndices':
        return $1.GetVegetationIndicesRequest();
      case 'DetectCropStress':
        return $1.DetectCropStressRequest();
      case 'GetTemporalAnalysis':
        return $1.GetTemporalAnalysisRequest();
      case 'ListAlerts':
        return $1.ListAlertsRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'RequestImagery':
        return requestImagery(ctx, request as $1.RequestImageryRequest);
      case 'GetImage':
        return getImage(ctx, request as $1.GetImageRequest);
      case 'ListImages':
        return listImages(ctx, request as $1.ListImagesRequest);
      case 'ComputeNDVI':
        return computeNDVI(ctx, request as $1.ComputeIndexRequest);
      case 'ComputeNDWI':
        return computeNDWI(ctx, request as $1.ComputeIndexRequest);
      case 'ComputeEVI':
        return computeEVI(ctx, request as $1.ComputeIndexRequest);
      case 'GetVegetationIndices':
        return getVegetationIndices(
            ctx, request as $1.GetVegetationIndicesRequest);
      case 'DetectCropStress':
        return detectCropStress(ctx, request as $1.DetectCropStressRequest);
      case 'GetTemporalAnalysis':
        return getTemporalAnalysis(
            ctx, request as $1.GetTemporalAnalysisRequest);
      case 'ListAlerts':
        return listAlerts(ctx, request as $1.ListAlertsRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SatelliteServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => SatelliteServiceBase$messageJson;
}
