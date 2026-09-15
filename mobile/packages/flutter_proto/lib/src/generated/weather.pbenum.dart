// This is a generated file - do not edit.
//
// Generated from weather.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class WeatherProvider extends $pb.ProtobufEnum {
  static const WeatherProvider WEATHER_PROVIDER_UNSPECIFIED = WeatherProvider._(
      0, _omitEnumNames ? '' : 'WEATHER_PROVIDER_UNSPECIFIED');
  static const WeatherProvider WEATHER_PROVIDER_OPEN_METEO =
      WeatherProvider._(1, _omitEnumNames ? '' : 'WEATHER_PROVIDER_OPEN_METEO');
  static const WeatherProvider WEATHER_PROVIDER_OPENWEATHER = WeatherProvider._(
      2, _omitEnumNames ? '' : 'WEATHER_PROVIDER_OPENWEATHER');
  static const WeatherProvider WEATHER_PROVIDER_IMD =
      WeatherProvider._(3, _omitEnumNames ? '' : 'WEATHER_PROVIDER_IMD');

  static const $core.List<WeatherProvider> values = <WeatherProvider>[
    WEATHER_PROVIDER_UNSPECIFIED,
    WEATHER_PROVIDER_OPEN_METEO,
    WEATHER_PROVIDER_OPENWEATHER,
    WEATHER_PROVIDER_IMD,
  ];

  static final $core.List<WeatherProvider?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static WeatherProvider? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const WeatherProvider._(super.value, super.name);
}

class WeatherAlertType extends $pb.ProtobufEnum {
  static const WeatherAlertType WEATHER_ALERT_TYPE_UNSPECIFIED =
      WeatherAlertType._(
          0, _omitEnumNames ? '' : 'WEATHER_ALERT_TYPE_UNSPECIFIED');
  static const WeatherAlertType WEATHER_ALERT_TYPE_FROST =
      WeatherAlertType._(1, _omitEnumNames ? '' : 'WEATHER_ALERT_TYPE_FROST');
  static const WeatherAlertType WEATHER_ALERT_TYPE_HEAT_STRESS =
      WeatherAlertType._(
          2, _omitEnumNames ? '' : 'WEATHER_ALERT_TYPE_HEAT_STRESS');
  static const WeatherAlertType WEATHER_ALERT_TYPE_HEAVY_RAINFALL =
      WeatherAlertType._(
          3, _omitEnumNames ? '' : 'WEATHER_ALERT_TYPE_HEAVY_RAINFALL');
  static const WeatherAlertType WEATHER_ALERT_TYPE_HIGH_WIND =
      WeatherAlertType._(
          4, _omitEnumNames ? '' : 'WEATHER_ALERT_TYPE_HIGH_WIND');
  static const WeatherAlertType WEATHER_ALERT_TYPE_DROUGHT =
      WeatherAlertType._(5, _omitEnumNames ? '' : 'WEATHER_ALERT_TYPE_DROUGHT');

  static const $core.List<WeatherAlertType> values = <WeatherAlertType>[
    WEATHER_ALERT_TYPE_UNSPECIFIED,
    WEATHER_ALERT_TYPE_FROST,
    WEATHER_ALERT_TYPE_HEAT_STRESS,
    WEATHER_ALERT_TYPE_HEAVY_RAINFALL,
    WEATHER_ALERT_TYPE_HIGH_WIND,
    WEATHER_ALERT_TYPE_DROUGHT,
  ];

  static final $core.List<WeatherAlertType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static WeatherAlertType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const WeatherAlertType._(super.value, super.name);
}

class AlertSeverity extends $pb.ProtobufEnum {
  static const AlertSeverity ALERT_SEVERITY_UNSPECIFIED =
      AlertSeverity._(0, _omitEnumNames ? '' : 'ALERT_SEVERITY_UNSPECIFIED');
  static const AlertSeverity ALERT_SEVERITY_INFO =
      AlertSeverity._(1, _omitEnumNames ? '' : 'ALERT_SEVERITY_INFO');
  static const AlertSeverity ALERT_SEVERITY_WARNING =
      AlertSeverity._(2, _omitEnumNames ? '' : 'ALERT_SEVERITY_WARNING');
  static const AlertSeverity ALERT_SEVERITY_CRITICAL =
      AlertSeverity._(3, _omitEnumNames ? '' : 'ALERT_SEVERITY_CRITICAL');

  static const $core.List<AlertSeverity> values = <AlertSeverity>[
    ALERT_SEVERITY_UNSPECIFIED,
    ALERT_SEVERITY_INFO,
    ALERT_SEVERITY_WARNING,
    ALERT_SEVERITY_CRITICAL,
  ];

  static final $core.List<AlertSeverity?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static AlertSeverity? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AlertSeverity._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
