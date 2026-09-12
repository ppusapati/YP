// This is a generated file - do not edit.
//
// Generated from advisory.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class AdvisorySeverity extends $pb.ProtobufEnum {
  static const AdvisorySeverity ADVISORY_SEVERITY_UNSPECIFIED =
      AdvisorySeverity._(
          0, _omitEnumNames ? '' : 'ADVISORY_SEVERITY_UNSPECIFIED');
  static const AdvisorySeverity ADVISORY_SEVERITY_LOW =
      AdvisorySeverity._(1, _omitEnumNames ? '' : 'ADVISORY_SEVERITY_LOW');
  static const AdvisorySeverity ADVISORY_SEVERITY_MEDIUM =
      AdvisorySeverity._(2, _omitEnumNames ? '' : 'ADVISORY_SEVERITY_MEDIUM');
  static const AdvisorySeverity ADVISORY_SEVERITY_HIGH =
      AdvisorySeverity._(3, _omitEnumNames ? '' : 'ADVISORY_SEVERITY_HIGH');
  static const AdvisorySeverity ADVISORY_SEVERITY_CRITICAL =
      AdvisorySeverity._(4, _omitEnumNames ? '' : 'ADVISORY_SEVERITY_CRITICAL');

  static const $core.List<AdvisorySeverity> values = <AdvisorySeverity>[
    ADVISORY_SEVERITY_UNSPECIFIED,
    ADVISORY_SEVERITY_LOW,
    ADVISORY_SEVERITY_MEDIUM,
    ADVISORY_SEVERITY_HIGH,
    ADVISORY_SEVERITY_CRITICAL,
  ];

  static final $core.List<AdvisorySeverity?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static AdvisorySeverity? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AdvisorySeverity._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
