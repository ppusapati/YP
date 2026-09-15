// This is a generated file - do not edit.
//
// Generated from advisory.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'advisory.pb.dart' as $1;
import 'advisory.pbjson.dart';

export 'advisory.pb.dart';

abstract class AdvisoryServiceBase extends $pb.GeneratedService {
  $async.Future<$1.GetAdvisoryResponse> getAdvisory(
      $pb.ServerContext ctx, $1.GetAdvisoryRequest request);
  $async.Future<$1.ListAdvisoriesResponse> listAdvisories(
      $pb.ServerContext ctx, $1.ListAdvisoriesRequest request);
  $async.Future<$1.CreateAdvisoryResponse> createAdvisory(
      $pb.ServerContext ctx, $1.CreateAdvisoryRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetAdvisory':
        return $1.GetAdvisoryRequest();
      case 'ListAdvisories':
        return $1.ListAdvisoriesRequest();
      case 'CreateAdvisory':
        return $1.CreateAdvisoryRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetAdvisory':
        return getAdvisory(ctx, request as $1.GetAdvisoryRequest);
      case 'ListAdvisories':
        return listAdvisories(ctx, request as $1.ListAdvisoriesRequest);
      case 'CreateAdvisory':
        return createAdvisory(ctx, request as $1.CreateAdvisoryRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => AdvisoryServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => AdvisoryServiceBase$messageJson;
}
