// This is a generated file - do not edit.
//
// Generated from alert.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'alert.pb.dart' as $1;
import 'alert.pbjson.dart';

export 'alert.pb.dart';

abstract class AlertServiceBase extends $pb.GeneratedService {
  $async.Future<$1.ListAlertsResponse> listAlerts(
      $pb.ServerContext ctx, $1.ListAlertsRequest request);
  $async.Future<$1.GetAlertResponse> getAlert(
      $pb.ServerContext ctx, $1.GetAlertRequest request);
  $async.Future<$1.AcknowledgeAlertResponse> acknowledgeAlert(
      $pb.ServerContext ctx, $1.AcknowledgeAlertRequest request);
  $async.Future<$1.ResolveAlertResponse> resolveAlert(
      $pb.ServerContext ctx, $1.ResolveAlertRequest request);
  $async.Future<$1.MarkAlertReadResponse> markAlertRead(
      $pb.ServerContext ctx, $1.MarkAlertReadRequest request);
  $async.Future<$1.MarkAllAlertsReadResponse> markAllAlertsRead(
      $pb.ServerContext ctx, $1.MarkAllAlertsReadRequest request);
  $async.Future<$1.GetUnreadCountResponse> getUnreadCount(
      $pb.ServerContext ctx, $1.GetUnreadCountRequest request);
  $async.Future<$1.ListAlertRulesResponse> listAlertRules(
      $pb.ServerContext ctx, $1.ListAlertRulesRequest request);
  $async.Future<$1.CreateAlertRuleResponse> createAlertRule(
      $pb.ServerContext ctx, $1.CreateAlertRuleRequest request);
  $async.Future<$1.UpdateAlertRuleResponse> updateAlertRule(
      $pb.ServerContext ctx, $1.UpdateAlertRuleRequest request);
  $async.Future<$1.GetFieldRiskResponse> getFieldRisk(
      $pb.ServerContext ctx, $1.GetFieldRiskRequest request);
  $async.Future<$1.ListFieldRisksResponse> listFieldRisks(
      $pb.ServerContext ctx, $1.ListFieldRisksRequest request);
  $async.Future<$1.ListAlertHistoryResponse> listAlertHistory(
      $pb.ServerContext ctx, $1.ListAlertHistoryRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListAlerts':
        return $1.ListAlertsRequest();
      case 'GetAlert':
        return $1.GetAlertRequest();
      case 'AcknowledgeAlert':
        return $1.AcknowledgeAlertRequest();
      case 'ResolveAlert':
        return $1.ResolveAlertRequest();
      case 'MarkAlertRead':
        return $1.MarkAlertReadRequest();
      case 'MarkAllAlertsRead':
        return $1.MarkAllAlertsReadRequest();
      case 'GetUnreadCount':
        return $1.GetUnreadCountRequest();
      case 'ListAlertRules':
        return $1.ListAlertRulesRequest();
      case 'CreateAlertRule':
        return $1.CreateAlertRuleRequest();
      case 'UpdateAlertRule':
        return $1.UpdateAlertRuleRequest();
      case 'GetFieldRisk':
        return $1.GetFieldRiskRequest();
      case 'ListFieldRisks':
        return $1.ListFieldRisksRequest();
      case 'ListAlertHistory':
        return $1.ListAlertHistoryRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListAlerts':
        return listAlerts(ctx, request as $1.ListAlertsRequest);
      case 'GetAlert':
        return getAlert(ctx, request as $1.GetAlertRequest);
      case 'AcknowledgeAlert':
        return acknowledgeAlert(ctx, request as $1.AcknowledgeAlertRequest);
      case 'ResolveAlert':
        return resolveAlert(ctx, request as $1.ResolveAlertRequest);
      case 'MarkAlertRead':
        return markAlertRead(ctx, request as $1.MarkAlertReadRequest);
      case 'MarkAllAlertsRead':
        return markAllAlertsRead(ctx, request as $1.MarkAllAlertsReadRequest);
      case 'GetUnreadCount':
        return getUnreadCount(ctx, request as $1.GetUnreadCountRequest);
      case 'ListAlertRules':
        return listAlertRules(ctx, request as $1.ListAlertRulesRequest);
      case 'CreateAlertRule':
        return createAlertRule(ctx, request as $1.CreateAlertRuleRequest);
      case 'UpdateAlertRule':
        return updateAlertRule(ctx, request as $1.UpdateAlertRuleRequest);
      case 'GetFieldRisk':
        return getFieldRisk(ctx, request as $1.GetFieldRiskRequest);
      case 'ListFieldRisks':
        return listFieldRisks(ctx, request as $1.ListFieldRisksRequest);
      case 'ListAlertHistory':
        return listAlertHistory(ctx, request as $1.ListAlertHistoryRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => AlertServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => AlertServiceBase$messageJson;
}
