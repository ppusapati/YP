// This is a generated file - do not edit.
//
// Generated from field_analytics.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'field_analytics.pb.dart' as $0;
import 'field_analytics.pbjson.dart';

export 'field_analytics.pb.dart';

abstract class FieldAnalyticsServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GetHistoricalMetricsResponse> getHistoricalMetrics(
      $pb.ServerContext ctx, $0.GetHistoricalMetricsRequest request);
  $async.Future<$0.ListFieldAnalyticsResponse> listFieldAnalytics(
      $pb.ServerContext ctx, $0.ListFieldAnalyticsRequest request);
  $async.Future<$0.GetFieldAnalyticsResponse> getFieldAnalytics(
      $pb.ServerContext ctx, $0.GetFieldAnalyticsRequest request);
  $async.Future<$0.GetSeasonComparisonsResponse> getSeasonComparisons(
      $pb.ServerContext ctx, $0.GetSeasonComparisonsRequest request);
  $async.Future<$0.GetRotationAnalysisResponse> getRotationAnalysis(
      $pb.ServerContext ctx, $0.GetRotationAnalysisRequest request);
  $async.Future<$0.GetCrossFieldTrendsResponse> getCrossFieldTrends(
      $pb.ServerContext ctx, $0.GetCrossFieldTrendsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetHistoricalMetrics':
        return $0.GetHistoricalMetricsRequest();
      case 'ListFieldAnalytics':
        return $0.ListFieldAnalyticsRequest();
      case 'GetFieldAnalytics':
        return $0.GetFieldAnalyticsRequest();
      case 'GetSeasonComparisons':
        return $0.GetSeasonComparisonsRequest();
      case 'GetRotationAnalysis':
        return $0.GetRotationAnalysisRequest();
      case 'GetCrossFieldTrends':
        return $0.GetCrossFieldTrendsRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetHistoricalMetrics':
        return getHistoricalMetrics(
            ctx, request as $0.GetHistoricalMetricsRequest);
      case 'ListFieldAnalytics':
        return listFieldAnalytics(ctx, request as $0.ListFieldAnalyticsRequest);
      case 'GetFieldAnalytics':
        return getFieldAnalytics(ctx, request as $0.GetFieldAnalyticsRequest);
      case 'GetSeasonComparisons':
        return getSeasonComparisons(
            ctx, request as $0.GetSeasonComparisonsRequest);
      case 'GetRotationAnalysis':
        return getRotationAnalysis(
            ctx, request as $0.GetRotationAnalysisRequest);
      case 'GetCrossFieldTrends':
        return getCrossFieldTrends(
            ctx, request as $0.GetCrossFieldTrendsRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      FieldAnalyticsServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => FieldAnalyticsServiceBase$messageJson;
}
