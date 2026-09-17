// This is a generated file - do not edit.
//
// Generated from soillab.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'soillab.pb.dart' as $1;
import 'soillab.pbjson.dart';

export 'soillab.pb.dart';

abstract class SoilLabServiceBase extends $pb.GeneratedService {
  $async.Future<$1.RegisterLabResponse> registerLab(
      $pb.ServerContext ctx, $1.RegisterLabRequest request);
  $async.Future<$1.ListLabsResponse> listLabs(
      $pb.ServerContext ctx, $1.ListLabsRequest request);
  $async.Future<$1.UploadReportResponse> uploadReport(
      $pb.ServerContext ctx, $1.UploadReportRequest request);
  $async.Future<$1.GetReportResponse> getReport(
      $pb.ServerContext ctx, $1.GetReportRequest request);
  $async.Future<$1.ListReportsResponse> listReports(
      $pb.ServerContext ctx, $1.ListReportsRequest request);
  $async.Future<$1.ApplyReportResponse> applyReport(
      $pb.ServerContext ctx, $1.ApplyReportRequest request);
  $async.Future<$1.RejectReportResponse> rejectReport(
      $pb.ServerContext ctx, $1.RejectReportRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'RegisterLab':
        return $1.RegisterLabRequest();
      case 'ListLabs':
        return $1.ListLabsRequest();
      case 'UploadReport':
        return $1.UploadReportRequest();
      case 'GetReport':
        return $1.GetReportRequest();
      case 'ListReports':
        return $1.ListReportsRequest();
      case 'ApplyReport':
        return $1.ApplyReportRequest();
      case 'RejectReport':
        return $1.RejectReportRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'RegisterLab':
        return registerLab(ctx, request as $1.RegisterLabRequest);
      case 'ListLabs':
        return listLabs(ctx, request as $1.ListLabsRequest);
      case 'UploadReport':
        return uploadReport(ctx, request as $1.UploadReportRequest);
      case 'GetReport':
        return getReport(ctx, request as $1.GetReportRequest);
      case 'ListReports':
        return listReports(ctx, request as $1.ListReportsRequest);
      case 'ApplyReport':
        return applyReport(ctx, request as $1.ApplyReportRequest);
      case 'RejectReport':
        return rejectReport(ctx, request as $1.RejectReportRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => SoilLabServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => SoilLabServiceBase$messageJson;
}
