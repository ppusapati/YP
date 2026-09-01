// This is a generated file - do not edit.
//
// Generated from ingestion.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'ingestion.pb.dart' as $1;
import 'ingestion.pbjson.dart';

export 'ingestion.pb.dart';

abstract class SatelliteIngestionServiceBase extends $pb.GeneratedService {
  $async.Future<$1.RequestIngestionResponse> requestIngestion(
      $pb.ServerContext ctx, $1.RequestIngestionRequest request);
  $async.Future<$1.GetIngestionTaskResponse> getIngestionTask(
      $pb.ServerContext ctx, $1.GetIngestionTaskRequest request);
  $async.Future<$1.ListIngestionTasksResponse> listIngestionTasks(
      $pb.ServerContext ctx, $1.ListIngestionTasksRequest request);
  $async.Future<$1.CancelIngestionResponse> cancelIngestion(
      $pb.ServerContext ctx, $1.CancelIngestionRequest request);
  $async.Future<$1.RetryIngestionResponse> retryIngestion(
      $pb.ServerContext ctx, $1.RetryIngestionRequest request);
  $async.Future<$1.GetIngestionStatsResponse> getIngestionStats(
      $pb.ServerContext ctx, $1.GetIngestionStatsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'RequestIngestion':
        return $1.RequestIngestionRequest();
      case 'GetIngestionTask':
        return $1.GetIngestionTaskRequest();
      case 'ListIngestionTasks':
        return $1.ListIngestionTasksRequest();
      case 'CancelIngestion':
        return $1.CancelIngestionRequest();
      case 'RetryIngestion':
        return $1.RetryIngestionRequest();
      case 'GetIngestionStats':
        return $1.GetIngestionStatsRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'RequestIngestion':
        return requestIngestion(ctx, request as $1.RequestIngestionRequest);
      case 'GetIngestionTask':
        return getIngestionTask(ctx, request as $1.GetIngestionTaskRequest);
      case 'ListIngestionTasks':
        return listIngestionTasks(ctx, request as $1.ListIngestionTasksRequest);
      case 'CancelIngestion':
        return cancelIngestion(ctx, request as $1.CancelIngestionRequest);
      case 'RetryIngestion':
        return retryIngestion(ctx, request as $1.RetryIngestionRequest);
      case 'GetIngestionStats':
        return getIngestionStats(ctx, request as $1.GetIngestionStatsRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      SatelliteIngestionServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => SatelliteIngestionServiceBase$messageJson;
}
