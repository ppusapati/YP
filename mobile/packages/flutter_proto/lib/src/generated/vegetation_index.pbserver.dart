// This is a generated file - do not edit.
//
// Generated from vegetation_index.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'vegetation_index.pb.dart' as $1;
import 'vegetation_index.pbjson.dart';

export 'vegetation_index.pb.dart';

abstract class VegetationIndexServiceBase extends $pb.GeneratedService {
  $async.Future<$1.ComputeIndicesResponse> computeIndices(
      $pb.ServerContext ctx, $1.ComputeIndicesRequest request);
  $async.Future<$1.GetVegetationIndexResponse> getVegetationIndex(
      $pb.ServerContext ctx, $1.GetVegetationIndexRequest request);
  $async.Future<$1.ListVegetationIndicesResponse> listVegetationIndices(
      $pb.ServerContext ctx, $1.ListVegetationIndicesRequest request);
  $async.Future<$1.GetNDVITimeSeriesResponse> getNDVITimeSeries(
      $pb.ServerContext ctx, $1.GetNDVITimeSeriesRequest request);
  $async.Future<$1.GetFieldHealthResponse> getFieldHealth(
      $pb.ServerContext ctx, $1.GetFieldHealthRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ComputeIndices':
        return $1.ComputeIndicesRequest();
      case 'GetVegetationIndex':
        return $1.GetVegetationIndexRequest();
      case 'ListVegetationIndices':
        return $1.ListVegetationIndicesRequest();
      case 'GetNDVITimeSeries':
        return $1.GetNDVITimeSeriesRequest();
      case 'GetFieldHealth':
        return $1.GetFieldHealthRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ComputeIndices':
        return computeIndices(ctx, request as $1.ComputeIndicesRequest);
      case 'GetVegetationIndex':
        return getVegetationIndex(ctx, request as $1.GetVegetationIndexRequest);
      case 'ListVegetationIndices':
        return listVegetationIndices(
            ctx, request as $1.ListVegetationIndicesRequest);
      case 'GetNDVITimeSeries':
        return getNDVITimeSeries(ctx, request as $1.GetNDVITimeSeriesRequest);
      case 'GetFieldHealth':
        return getFieldHealth(ctx, request as $1.GetFieldHealthRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      VegetationIndexServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => VegetationIndexServiceBase$messageJson;
}
