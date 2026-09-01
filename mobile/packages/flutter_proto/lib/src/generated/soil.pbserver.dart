// This is a generated file - do not edit.
//
// Generated from soil.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'soil.pb.dart' as $2;
import 'soil.pbjson.dart';

export 'soil.pb.dart';

abstract class SoilServiceBase extends $pb.GeneratedService {
  $async.Future<$2.CreateSoilSampleResponse> createSoilSample(
      $pb.ServerContext ctx, $2.CreateSoilSampleRequest request);
  $async.Future<$2.GetSoilSampleResponse> getSoilSample(
      $pb.ServerContext ctx, $2.GetSoilSampleRequest request);
  $async.Future<$2.ListSoilSamplesResponse> listSoilSamples(
      $pb.ServerContext ctx, $2.ListSoilSamplesRequest request);
  $async.Future<$2.AnalyzeSoilResponse> analyzeSoil(
      $pb.ServerContext ctx, $2.AnalyzeSoilRequest request);
  $async.Future<$2.ListSoilAnalysesResponse> listSoilAnalyses(
      $pb.ServerContext ctx, $2.ListSoilAnalysesRequest request);
  $async.Future<$2.GetSoilMapResponse> getSoilMap(
      $pb.ServerContext ctx, $2.GetSoilMapRequest request);
  $async.Future<$2.GetSoilHealthResponse> getSoilHealth(
      $pb.ServerContext ctx, $2.GetSoilHealthRequest request);
  $async.Future<$2.GetNutrientLevelsResponse> getNutrientLevels(
      $pb.ServerContext ctx, $2.GetNutrientLevelsRequest request);
  $async.Future<$2.GenerateSoilReportResponse> generateSoilReport(
      $pb.ServerContext ctx, $2.GenerateSoilReportRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'CreateSoilSample':
        return $2.CreateSoilSampleRequest();
      case 'GetSoilSample':
        return $2.GetSoilSampleRequest();
      case 'ListSoilSamples':
        return $2.ListSoilSamplesRequest();
      case 'AnalyzeSoil':
        return $2.AnalyzeSoilRequest();
      case 'ListSoilAnalyses':
        return $2.ListSoilAnalysesRequest();
      case 'GetSoilMap':
        return $2.GetSoilMapRequest();
      case 'GetSoilHealth':
        return $2.GetSoilHealthRequest();
      case 'GetNutrientLevels':
        return $2.GetNutrientLevelsRequest();
      case 'GenerateSoilReport':
        return $2.GenerateSoilReportRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'CreateSoilSample':
        return createSoilSample(ctx, request as $2.CreateSoilSampleRequest);
      case 'GetSoilSample':
        return getSoilSample(ctx, request as $2.GetSoilSampleRequest);
      case 'ListSoilSamples':
        return listSoilSamples(ctx, request as $2.ListSoilSamplesRequest);
      case 'AnalyzeSoil':
        return analyzeSoil(ctx, request as $2.AnalyzeSoilRequest);
      case 'ListSoilAnalyses':
        return listSoilAnalyses(ctx, request as $2.ListSoilAnalysesRequest);
      case 'GetSoilMap':
        return getSoilMap(ctx, request as $2.GetSoilMapRequest);
      case 'GetSoilHealth':
        return getSoilHealth(ctx, request as $2.GetSoilHealthRequest);
      case 'GetNutrientLevels':
        return getNutrientLevels(ctx, request as $2.GetNutrientLevelsRequest);
      case 'GenerateSoilReport':
        return generateSoilReport(ctx, request as $2.GenerateSoilReportRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SoilServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => SoilServiceBase$messageJson;
}
