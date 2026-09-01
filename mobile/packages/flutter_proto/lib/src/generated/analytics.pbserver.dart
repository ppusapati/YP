// This is a generated file - do not edit.
//
// Generated from analytics.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'analytics.pb.dart' as $1;
import 'analytics.pbjson.dart';

export 'analytics.pb.dart';

abstract class SatelliteAnalyticsServiceBase extends $pb.GeneratedService {
  $async.Future<$1.DetectStressResponse> detectStress(
      $pb.ServerContext ctx, $1.DetectStressRequest request);
  $async.Future<$1.ListStressAlertsResponse> listStressAlerts(
      $pb.ServerContext ctx, $1.ListStressAlertsRequest request);
  $async.Future<$1.AcknowledgeAlertResponse> acknowledgeAlert(
      $pb.ServerContext ctx, $1.AcknowledgeAlertRequest request);
  $async.Future<$1.RunTemporalAnalysisResponse> runTemporalAnalysis(
      $pb.ServerContext ctx, $1.RunTemporalAnalysisRequest request);
  $async.Future<$1.GetFieldAnalyticsSummaryResponse> getFieldAnalyticsSummary(
      $pb.ServerContext ctx, $1.GetFieldAnalyticsSummaryRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'DetectStress':
        return $1.DetectStressRequest();
      case 'ListStressAlerts':
        return $1.ListStressAlertsRequest();
      case 'AcknowledgeAlert':
        return $1.AcknowledgeAlertRequest();
      case 'RunTemporalAnalysis':
        return $1.RunTemporalAnalysisRequest();
      case 'GetFieldAnalyticsSummary':
        return $1.GetFieldAnalyticsSummaryRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'DetectStress':
        return detectStress(ctx, request as $1.DetectStressRequest);
      case 'ListStressAlerts':
        return listStressAlerts(ctx, request as $1.ListStressAlertsRequest);
      case 'AcknowledgeAlert':
        return acknowledgeAlert(ctx, request as $1.AcknowledgeAlertRequest);
      case 'RunTemporalAnalysis':
        return runTemporalAnalysis(
            ctx, request as $1.RunTemporalAnalysisRequest);
      case 'GetFieldAnalyticsSummary':
        return getFieldAnalyticsSummary(
            ctx, request as $1.GetFieldAnalyticsSummaryRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      SatelliteAnalyticsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => SatelliteAnalyticsServiceBase$messageJson;
}
