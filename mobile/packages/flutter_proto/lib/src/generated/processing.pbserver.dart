// This is a generated file - do not edit.
//
// Generated from processing.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'processing.pb.dart' as $1;
import 'processing.pbjson.dart';

export 'processing.pb.dart';

abstract class SatelliteProcessingServiceBase extends $pb.GeneratedService {
  $async.Future<$1.SubmitProcessingJobResponse> submitProcessingJob(
      $pb.ServerContext ctx, $1.SubmitProcessingJobRequest request);
  $async.Future<$1.GetProcessingJobResponse> getProcessingJob(
      $pb.ServerContext ctx, $1.GetProcessingJobRequest request);
  $async.Future<$1.ListProcessingJobsResponse> listProcessingJobs(
      $pb.ServerContext ctx, $1.ListProcessingJobsRequest request);
  $async.Future<$1.CancelProcessingJobResponse> cancelProcessingJob(
      $pb.ServerContext ctx, $1.CancelProcessingJobRequest request);
  $async.Future<$1.GetProcessingStatsResponse> getProcessingStats(
      $pb.ServerContext ctx, $1.GetProcessingStatsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'SubmitProcessingJob':
        return $1.SubmitProcessingJobRequest();
      case 'GetProcessingJob':
        return $1.GetProcessingJobRequest();
      case 'ListProcessingJobs':
        return $1.ListProcessingJobsRequest();
      case 'CancelProcessingJob':
        return $1.CancelProcessingJobRequest();
      case 'GetProcessingStats':
        return $1.GetProcessingStatsRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'SubmitProcessingJob':
        return submitProcessingJob(
            ctx, request as $1.SubmitProcessingJobRequest);
      case 'GetProcessingJob':
        return getProcessingJob(ctx, request as $1.GetProcessingJobRequest);
      case 'ListProcessingJobs':
        return listProcessingJobs(ctx, request as $1.ListProcessingJobsRequest);
      case 'CancelProcessingJob':
        return cancelProcessingJob(
            ctx, request as $1.CancelProcessingJobRequest);
      case 'GetProcessingStats':
        return getProcessingStats(ctx, request as $1.GetProcessingStatsRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      SatelliteProcessingServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => SatelliteProcessingServiceBase$messageJson;
}
