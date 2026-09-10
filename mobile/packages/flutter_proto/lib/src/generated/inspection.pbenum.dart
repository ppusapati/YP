// This is a generated file - do not edit.
//
// Generated from inspection.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class InspectionStatus extends $pb.ProtobufEnum {
  static const InspectionStatus INSPECTION_STATUS_UNSPECIFIED =
      InspectionStatus._(
          0, _omitEnumNames ? '' : 'INSPECTION_STATUS_UNSPECIFIED');
  static const InspectionStatus INSPECTION_STATUS_DRAFT =
      InspectionStatus._(1, _omitEnumNames ? '' : 'INSPECTION_STATUS_DRAFT');
  static const InspectionStatus INSPECTION_STATUS_SUBMITTED =
      InspectionStatus._(
          2, _omitEnumNames ? '' : 'INSPECTION_STATUS_SUBMITTED');
  static const InspectionStatus INSPECTION_STATUS_REVIEWED =
      InspectionStatus._(
          3, _omitEnumNames ? '' : 'INSPECTION_STATUS_REVIEWED');

  static const $core.List<InspectionStatus> values = <InspectionStatus>[
    INSPECTION_STATUS_UNSPECIFIED,
    INSPECTION_STATUS_DRAFT,
    INSPECTION_STATUS_SUBMITTED,
    INSPECTION_STATUS_REVIEWED,
  ];

  static final $core.List<InspectionStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static InspectionStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const InspectionStatus._(super.value, super.name);
}

class IssueSeverity extends $pb.ProtobufEnum {
  static const IssueSeverity ISSUE_SEVERITY_UNSPECIFIED =
      IssueSeverity._(0, _omitEnumNames ? '' : 'ISSUE_SEVERITY_UNSPECIFIED');
  static const IssueSeverity ISSUE_SEVERITY_LOW =
      IssueSeverity._(1, _omitEnumNames ? '' : 'ISSUE_SEVERITY_LOW');
  static const IssueSeverity ISSUE_SEVERITY_MEDIUM =
      IssueSeverity._(2, _omitEnumNames ? '' : 'ISSUE_SEVERITY_MEDIUM');
  static const IssueSeverity ISSUE_SEVERITY_HIGH =
      IssueSeverity._(3, _omitEnumNames ? '' : 'ISSUE_SEVERITY_HIGH');
  static const IssueSeverity ISSUE_SEVERITY_CRITICAL =
      IssueSeverity._(4, _omitEnumNames ? '' : 'ISSUE_SEVERITY_CRITICAL');

  static const $core.List<IssueSeverity> values = <IssueSeverity>[
    ISSUE_SEVERITY_UNSPECIFIED,
    ISSUE_SEVERITY_LOW,
    ISSUE_SEVERITY_MEDIUM,
    ISSUE_SEVERITY_HIGH,
    ISSUE_SEVERITY_CRITICAL,
  ];

  static final $core.List<IssueSeverity?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static IssueSeverity? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const IssueSeverity._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
