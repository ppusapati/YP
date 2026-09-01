// This is a generated file - do not edit.
//
// Generated from alert.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class AlertSeverity extends $pb.ProtobufEnum {
  static const AlertSeverity ALERT_SEVERITY_UNSPECIFIED =
      AlertSeverity._(0, _omitEnumNames ? '' : 'ALERT_SEVERITY_UNSPECIFIED');
  static const AlertSeverity ALERT_SEVERITY_INFO =
      AlertSeverity._(1, _omitEnumNames ? '' : 'ALERT_SEVERITY_INFO');
  static const AlertSeverity ALERT_SEVERITY_WARNING =
      AlertSeverity._(2, _omitEnumNames ? '' : 'ALERT_SEVERITY_WARNING');
  static const AlertSeverity ALERT_SEVERITY_CRITICAL =
      AlertSeverity._(3, _omitEnumNames ? '' : 'ALERT_SEVERITY_CRITICAL');
  static const AlertSeverity ALERT_SEVERITY_EMERGENCY =
      AlertSeverity._(4, _omitEnumNames ? '' : 'ALERT_SEVERITY_EMERGENCY');

  static const $core.List<AlertSeverity> values = <AlertSeverity>[
    ALERT_SEVERITY_UNSPECIFIED,
    ALERT_SEVERITY_INFO,
    ALERT_SEVERITY_WARNING,
    ALERT_SEVERITY_CRITICAL,
    ALERT_SEVERITY_EMERGENCY,
  ];

  static final $core.List<AlertSeverity?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static AlertSeverity? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AlertSeverity._(super.value, super.name);
}

class AlertStatus extends $pb.ProtobufEnum {
  static const AlertStatus ALERT_STATUS_UNSPECIFIED =
      AlertStatus._(0, _omitEnumNames ? '' : 'ALERT_STATUS_UNSPECIFIED');
  static const AlertStatus ALERT_STATUS_ACTIVE =
      AlertStatus._(1, _omitEnumNames ? '' : 'ALERT_STATUS_ACTIVE');
  static const AlertStatus ALERT_STATUS_ACKNOWLEDGED =
      AlertStatus._(2, _omitEnumNames ? '' : 'ALERT_STATUS_ACKNOWLEDGED');
  static const AlertStatus ALERT_STATUS_RESOLVED =
      AlertStatus._(3, _omitEnumNames ? '' : 'ALERT_STATUS_RESOLVED');

  static const $core.List<AlertStatus> values = <AlertStatus>[
    ALERT_STATUS_UNSPECIFIED,
    ALERT_STATUS_ACTIVE,
    ALERT_STATUS_ACKNOWLEDGED,
    ALERT_STATUS_RESOLVED,
  ];

  static final $core.List<AlertStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static AlertStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AlertStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
