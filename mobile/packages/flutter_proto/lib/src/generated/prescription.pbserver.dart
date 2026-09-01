// This is a generated file - do not edit.
//
// Generated from prescription.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'prescription.pb.dart' as $0;
import 'prescription.pbjson.dart';

export 'prescription.pb.dart';

abstract class PrescriptionServiceBase extends $pb.GeneratedService {
  $async.Future<$0.ListPrescriptionsResponse> listPrescriptions(
      $pb.ServerContext ctx, $0.ListPrescriptionsRequest request);
  $async.Future<$0.GetPrescriptionResponse> getPrescription(
      $pb.ServerContext ctx, $0.GetPrescriptionRequest request);
  $async.Future<$0.GeneratePrescriptionResponse> generatePrescription(
      $pb.ServerContext ctx, $0.GeneratePrescriptionRequest request);
  $async.Future<$0.ExportPrescriptionResponse> exportPrescription(
      $pb.ServerContext ctx, $0.ExportPrescriptionRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListPrescriptions':
        return $0.ListPrescriptionsRequest();
      case 'GetPrescription':
        return $0.GetPrescriptionRequest();
      case 'GeneratePrescription':
        return $0.GeneratePrescriptionRequest();
      case 'ExportPrescription':
        return $0.ExportPrescriptionRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListPrescriptions':
        return listPrescriptions(ctx, request as $0.ListPrescriptionsRequest);
      case 'GetPrescription':
        return getPrescription(ctx, request as $0.GetPrescriptionRequest);
      case 'GeneratePrescription':
        return generatePrescription(
            ctx, request as $0.GeneratePrescriptionRequest);
      case 'ExportPrescription':
        return exportPrescription(ctx, request as $0.ExportPrescriptionRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      PrescriptionServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => PrescriptionServiceBase$messageJson;
}
