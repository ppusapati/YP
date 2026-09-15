// This is a generated file - do not edit.
//
// Generated from weather.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'weather.pb.dart' as $1;
import 'weather.pbjson.dart';

export 'weather.pb.dart';

abstract class WeatherServiceBase extends $pb.GeneratedService {
  $async.Future<$1.RegisterFieldLocationResponse> registerFieldLocation(
      $pb.ServerContext ctx, $1.RegisterFieldLocationRequest request);
  $async.Future<$1.GetFieldLocationResponse> getFieldLocation(
      $pb.ServerContext ctx, $1.GetFieldLocationRequest request);
  $async.Future<$1.ListFieldLocationsResponse> listFieldLocations(
      $pb.ServerContext ctx, $1.ListFieldLocationsRequest request);
  $async.Future<$1.GetCurrentWeatherResponse> getCurrentWeather(
      $pb.ServerContext ctx, $1.GetCurrentWeatherRequest request);
  $async.Future<$1.GetForecastResponse> getForecast(
      $pb.ServerContext ctx, $1.GetForecastRequest request);
  $async.Future<$1.ListObservationsResponse> listObservations(
      $pb.ServerContext ctx, $1.ListObservationsRequest request);
  $async.Future<$1.GetAgroMetricsResponse> getAgroMetrics(
      $pb.ServerContext ctx, $1.GetAgroMetricsRequest request);
  $async.Future<$1.RefreshFieldWeatherResponse> refreshFieldWeather(
      $pb.ServerContext ctx, $1.RefreshFieldWeatherRequest request);
  $async.Future<$1.BackfillHistoryResponse> backfillHistory(
      $pb.ServerContext ctx, $1.BackfillHistoryRequest request);
  $async.Future<$1.ListWeatherAlertsResponse> listWeatherAlerts(
      $pb.ServerContext ctx, $1.ListWeatherAlertsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'RegisterFieldLocation':
        return $1.RegisterFieldLocationRequest();
      case 'GetFieldLocation':
        return $1.GetFieldLocationRequest();
      case 'ListFieldLocations':
        return $1.ListFieldLocationsRequest();
      case 'GetCurrentWeather':
        return $1.GetCurrentWeatherRequest();
      case 'GetForecast':
        return $1.GetForecastRequest();
      case 'ListObservations':
        return $1.ListObservationsRequest();
      case 'GetAgroMetrics':
        return $1.GetAgroMetricsRequest();
      case 'RefreshFieldWeather':
        return $1.RefreshFieldWeatherRequest();
      case 'BackfillHistory':
        return $1.BackfillHistoryRequest();
      case 'ListWeatherAlerts':
        return $1.ListWeatherAlertsRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'RegisterFieldLocation':
        return registerFieldLocation(
            ctx, request as $1.RegisterFieldLocationRequest);
      case 'GetFieldLocation':
        return getFieldLocation(ctx, request as $1.GetFieldLocationRequest);
      case 'ListFieldLocations':
        return listFieldLocations(ctx, request as $1.ListFieldLocationsRequest);
      case 'GetCurrentWeather':
        return getCurrentWeather(ctx, request as $1.GetCurrentWeatherRequest);
      case 'GetForecast':
        return getForecast(ctx, request as $1.GetForecastRequest);
      case 'ListObservations':
        return listObservations(ctx, request as $1.ListObservationsRequest);
      case 'GetAgroMetrics':
        return getAgroMetrics(ctx, request as $1.GetAgroMetricsRequest);
      case 'RefreshFieldWeather':
        return refreshFieldWeather(
            ctx, request as $1.RefreshFieldWeatherRequest);
      case 'BackfillHistory':
        return backfillHistory(ctx, request as $1.BackfillHistoryRequest);
      case 'ListWeatherAlerts':
        return listWeatherAlerts(ctx, request as $1.ListWeatherAlertsRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WeatherServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => WeatherServiceBase$messageJson;
}
