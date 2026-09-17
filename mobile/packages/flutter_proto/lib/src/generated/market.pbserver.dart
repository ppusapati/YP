// This is a generated file - do not edit.
//
// Generated from market.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'market.pb.dart' as $1;
import 'market.pbjson.dart';

export 'market.pb.dart';

abstract class MarketServiceBase extends $pb.GeneratedService {
  $async.Future<$1.ListMarketsResponse> listMarkets(
      $pb.ServerContext ctx, $1.ListMarketsRequest request);
  $async.Future<$1.RecordQuotesResponse> recordQuotes(
      $pb.ServerContext ctx, $1.RecordQuotesRequest request);
  $async.Future<$1.ListQuotesResponse> listQuotes(
      $pb.ServerContext ctx, $1.ListQuotesRequest request);
  $async.Future<$1.GetPriceStatisticsResponse> getPriceStatistics(
      $pb.ServerContext ctx, $1.GetPriceStatisticsRequest request);
  $async.Future<$1.GetSellSignalResponse> getSellSignal(
      $pb.ServerContext ctx, $1.GetSellSignalRequest request);
  $async.Future<$1.CreatePriceAlertResponse> createPriceAlert(
      $pb.ServerContext ctx, $1.CreatePriceAlertRequest request);
  $async.Future<$1.ListPriceAlertsResponse> listPriceAlerts(
      $pb.ServerContext ctx, $1.ListPriceAlertsRequest request);
  $async.Future<$1.DeletePriceAlertResponse> deletePriceAlert(
      $pb.ServerContext ctx, $1.DeletePriceAlertRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListMarkets':
        return $1.ListMarketsRequest();
      case 'RecordQuotes':
        return $1.RecordQuotesRequest();
      case 'ListQuotes':
        return $1.ListQuotesRequest();
      case 'GetPriceStatistics':
        return $1.GetPriceStatisticsRequest();
      case 'GetSellSignal':
        return $1.GetSellSignalRequest();
      case 'CreatePriceAlert':
        return $1.CreatePriceAlertRequest();
      case 'ListPriceAlerts':
        return $1.ListPriceAlertsRequest();
      case 'DeletePriceAlert':
        return $1.DeletePriceAlertRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListMarkets':
        return listMarkets(ctx, request as $1.ListMarketsRequest);
      case 'RecordQuotes':
        return recordQuotes(ctx, request as $1.RecordQuotesRequest);
      case 'ListQuotes':
        return listQuotes(ctx, request as $1.ListQuotesRequest);
      case 'GetPriceStatistics':
        return getPriceStatistics(ctx, request as $1.GetPriceStatisticsRequest);
      case 'GetSellSignal':
        return getSellSignal(ctx, request as $1.GetSellSignalRequest);
      case 'CreatePriceAlert':
        return createPriceAlert(ctx, request as $1.CreatePriceAlertRequest);
      case 'ListPriceAlerts':
        return listPriceAlerts(ctx, request as $1.ListPriceAlertsRequest);
      case 'DeletePriceAlert':
        return deletePriceAlert(ctx, request as $1.DeletePriceAlertRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => MarketServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => MarketServiceBase$messageJson;
}
