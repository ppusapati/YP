// This is a generated file - do not edit.
//
// Generated from prescription.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class PrescriptionType extends $pb.ProtobufEnum {
  static const PrescriptionType PRESCRIPTION_TYPE_UNSPECIFIED =
      PrescriptionType._(
          0, _omitEnumNames ? '' : 'PRESCRIPTION_TYPE_UNSPECIFIED');
  static const PrescriptionType PRESCRIPTION_TYPE_FERTILIZER =
      PrescriptionType._(
          1, _omitEnumNames ? '' : 'PRESCRIPTION_TYPE_FERTILIZER');
  static const PrescriptionType PRESCRIPTION_TYPE_IRRIGATION =
      PrescriptionType._(
          2, _omitEnumNames ? '' : 'PRESCRIPTION_TYPE_IRRIGATION');
  static const PrescriptionType PRESCRIPTION_TYPE_SEEDING =
      PrescriptionType._(3, _omitEnumNames ? '' : 'PRESCRIPTION_TYPE_SEEDING');
  static const PrescriptionType PRESCRIPTION_TYPE_LIMING =
      PrescriptionType._(4, _omitEnumNames ? '' : 'PRESCRIPTION_TYPE_LIMING');

  static const $core.List<PrescriptionType> values = <PrescriptionType>[
    PRESCRIPTION_TYPE_UNSPECIFIED,
    PRESCRIPTION_TYPE_FERTILIZER,
    PRESCRIPTION_TYPE_IRRIGATION,
    PRESCRIPTION_TYPE_SEEDING,
    PRESCRIPTION_TYPE_LIMING,
  ];

  static final $core.List<PrescriptionType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static PrescriptionType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PrescriptionType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
