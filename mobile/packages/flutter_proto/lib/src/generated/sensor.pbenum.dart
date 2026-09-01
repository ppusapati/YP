// This is a generated file - do not edit.
//
// Generated from sensor.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class SensorType extends $pb.ProtobufEnum {
  static const SensorType SENSOR_TYPE_UNSPECIFIED =
      SensorType._(0, _omitEnumNames ? '' : 'SENSOR_TYPE_UNSPECIFIED');
  static const SensorType SENSOR_TYPE_SOIL_MOISTURE =
      SensorType._(1, _omitEnumNames ? '' : 'SENSOR_TYPE_SOIL_MOISTURE');
  static const SensorType SENSOR_TYPE_SOIL_PH =
      SensorType._(2, _omitEnumNames ? '' : 'SENSOR_TYPE_SOIL_PH');
  static const SensorType SENSOR_TYPE_TEMPERATURE =
      SensorType._(3, _omitEnumNames ? '' : 'SENSOR_TYPE_TEMPERATURE');
  static const SensorType SENSOR_TYPE_HUMIDITY =
      SensorType._(4, _omitEnumNames ? '' : 'SENSOR_TYPE_HUMIDITY');
  static const SensorType SENSOR_TYPE_RAINFALL =
      SensorType._(5, _omitEnumNames ? '' : 'SENSOR_TYPE_RAINFALL');
  static const SensorType SENSOR_TYPE_WIND_SPEED =
      SensorType._(6, _omitEnumNames ? '' : 'SENSOR_TYPE_WIND_SPEED');
  static const SensorType SENSOR_TYPE_WIND_DIRECTION =
      SensorType._(7, _omitEnumNames ? '' : 'SENSOR_TYPE_WIND_DIRECTION');
  static const SensorType SENSOR_TYPE_LIGHT_INTENSITY =
      SensorType._(8, _omitEnumNames ? '' : 'SENSOR_TYPE_LIGHT_INTENSITY');
  static const SensorType SENSOR_TYPE_LEAF_WETNESS =
      SensorType._(9, _omitEnumNames ? '' : 'SENSOR_TYPE_LEAF_WETNESS');

  static const $core.List<SensorType> values = <SensorType>[
    SENSOR_TYPE_UNSPECIFIED,
    SENSOR_TYPE_SOIL_MOISTURE,
    SENSOR_TYPE_SOIL_PH,
    SENSOR_TYPE_TEMPERATURE,
    SENSOR_TYPE_HUMIDITY,
    SENSOR_TYPE_RAINFALL,
    SENSOR_TYPE_WIND_SPEED,
    SENSOR_TYPE_WIND_DIRECTION,
    SENSOR_TYPE_LIGHT_INTENSITY,
    SENSOR_TYPE_LEAF_WETNESS,
  ];

  static final $core.List<SensorType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 9);
  static SensorType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SensorType._(super.value, super.name);
}

class SensorStatus extends $pb.ProtobufEnum {
  static const SensorStatus SENSOR_STATUS_UNSPECIFIED =
      SensorStatus._(0, _omitEnumNames ? '' : 'SENSOR_STATUS_UNSPECIFIED');
  static const SensorStatus SENSOR_STATUS_ACTIVE =
      SensorStatus._(1, _omitEnumNames ? '' : 'SENSOR_STATUS_ACTIVE');
  static const SensorStatus SENSOR_STATUS_INACTIVE =
      SensorStatus._(2, _omitEnumNames ? '' : 'SENSOR_STATUS_INACTIVE');
  static const SensorStatus SENSOR_STATUS_MAINTENANCE =
      SensorStatus._(3, _omitEnumNames ? '' : 'SENSOR_STATUS_MAINTENANCE');
  static const SensorStatus SENSOR_STATUS_DECOMMISSIONED =
      SensorStatus._(4, _omitEnumNames ? '' : 'SENSOR_STATUS_DECOMMISSIONED');

  static const $core.List<SensorStatus> values = <SensorStatus>[
    SENSOR_STATUS_UNSPECIFIED,
    SENSOR_STATUS_ACTIVE,
    SENSOR_STATUS_INACTIVE,
    SENSOR_STATUS_MAINTENANCE,
    SENSOR_STATUS_DECOMMISSIONED,
  ];

  static final $core.List<SensorStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static SensorStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SensorStatus._(super.value, super.name);
}

class SensorProtocol extends $pb.ProtobufEnum {
  static const SensorProtocol SENSOR_PROTOCOL_UNSPECIFIED =
      SensorProtocol._(0, _omitEnumNames ? '' : 'SENSOR_PROTOCOL_UNSPECIFIED');
  static const SensorProtocol SENSOR_PROTOCOL_MQTT =
      SensorProtocol._(1, _omitEnumNames ? '' : 'SENSOR_PROTOCOL_MQTT');
  static const SensorProtocol SENSOR_PROTOCOL_LORAWAN =
      SensorProtocol._(2, _omitEnumNames ? '' : 'SENSOR_PROTOCOL_LORAWAN');
  static const SensorProtocol SENSOR_PROTOCOL_ZIGBEE =
      SensorProtocol._(3, _omitEnumNames ? '' : 'SENSOR_PROTOCOL_ZIGBEE');
  static const SensorProtocol SENSOR_PROTOCOL_WIFI =
      SensorProtocol._(4, _omitEnumNames ? '' : 'SENSOR_PROTOCOL_WIFI');
  static const SensorProtocol SENSOR_PROTOCOL_CELLULAR =
      SensorProtocol._(5, _omitEnumNames ? '' : 'SENSOR_PROTOCOL_CELLULAR');

  static const $core.List<SensorProtocol> values = <SensorProtocol>[
    SENSOR_PROTOCOL_UNSPECIFIED,
    SENSOR_PROTOCOL_MQTT,
    SENSOR_PROTOCOL_LORAWAN,
    SENSOR_PROTOCOL_ZIGBEE,
    SENSOR_PROTOCOL_WIFI,
    SENSOR_PROTOCOL_CELLULAR,
  ];

  static final $core.List<SensorProtocol?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static SensorProtocol? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SensorProtocol._(super.value, super.name);
}

class ReadingQuality extends $pb.ProtobufEnum {
  static const ReadingQuality READING_QUALITY_UNSPECIFIED =
      ReadingQuality._(0, _omitEnumNames ? '' : 'READING_QUALITY_UNSPECIFIED');
  static const ReadingQuality READING_QUALITY_GOOD =
      ReadingQuality._(1, _omitEnumNames ? '' : 'READING_QUALITY_GOOD');
  static const ReadingQuality READING_QUALITY_SUSPECT =
      ReadingQuality._(2, _omitEnumNames ? '' : 'READING_QUALITY_SUSPECT');
  static const ReadingQuality READING_QUALITY_BAD =
      ReadingQuality._(3, _omitEnumNames ? '' : 'READING_QUALITY_BAD');

  static const $core.List<ReadingQuality> values = <ReadingQuality>[
    READING_QUALITY_UNSPECIFIED,
    READING_QUALITY_GOOD,
    READING_QUALITY_SUSPECT,
    READING_QUALITY_BAD,
  ];

  static final $core.List<ReadingQuality?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ReadingQuality? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ReadingQuality._(super.value, super.name);
}

class AlertCondition extends $pb.ProtobufEnum {
  static const AlertCondition ALERT_CONDITION_UNSPECIFIED =
      AlertCondition._(0, _omitEnumNames ? '' : 'ALERT_CONDITION_UNSPECIFIED');
  static const AlertCondition ALERT_CONDITION_GT =
      AlertCondition._(1, _omitEnumNames ? '' : 'ALERT_CONDITION_GT');
  static const AlertCondition ALERT_CONDITION_LT =
      AlertCondition._(2, _omitEnumNames ? '' : 'ALERT_CONDITION_LT');
  static const AlertCondition ALERT_CONDITION_EQ =
      AlertCondition._(3, _omitEnumNames ? '' : 'ALERT_CONDITION_EQ');
  static const AlertCondition ALERT_CONDITION_GTE =
      AlertCondition._(4, _omitEnumNames ? '' : 'ALERT_CONDITION_GTE');
  static const AlertCondition ALERT_CONDITION_LTE =
      AlertCondition._(5, _omitEnumNames ? '' : 'ALERT_CONDITION_LTE');

  static const $core.List<AlertCondition> values = <AlertCondition>[
    ALERT_CONDITION_UNSPECIFIED,
    ALERT_CONDITION_GT,
    ALERT_CONDITION_LT,
    ALERT_CONDITION_EQ,
    ALERT_CONDITION_GTE,
    ALERT_CONDITION_LTE,
  ];

  static final $core.List<AlertCondition?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static AlertCondition? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AlertCondition._(super.value, super.name);
}

class AlertSeverity extends $pb.ProtobufEnum {
  static const AlertSeverity ALERT_SEVERITY_UNSPECIFIED =
      AlertSeverity._(0, _omitEnumNames ? '' : 'ALERT_SEVERITY_UNSPECIFIED');
  static const AlertSeverity ALERT_SEVERITY_LOW =
      AlertSeverity._(1, _omitEnumNames ? '' : 'ALERT_SEVERITY_LOW');
  static const AlertSeverity ALERT_SEVERITY_MEDIUM =
      AlertSeverity._(2, _omitEnumNames ? '' : 'ALERT_SEVERITY_MEDIUM');
  static const AlertSeverity ALERT_SEVERITY_HIGH =
      AlertSeverity._(3, _omitEnumNames ? '' : 'ALERT_SEVERITY_HIGH');
  static const AlertSeverity ALERT_SEVERITY_CRITICAL =
      AlertSeverity._(4, _omitEnumNames ? '' : 'ALERT_SEVERITY_CRITICAL');

  static const $core.List<AlertSeverity> values = <AlertSeverity>[
    ALERT_SEVERITY_UNSPECIFIED,
    ALERT_SEVERITY_LOW,
    ALERT_SEVERITY_MEDIUM,
    ALERT_SEVERITY_HIGH,
    ALERT_SEVERITY_CRITICAL,
  ];

  static final $core.List<AlertSeverity?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static AlertSeverity? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AlertSeverity._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
