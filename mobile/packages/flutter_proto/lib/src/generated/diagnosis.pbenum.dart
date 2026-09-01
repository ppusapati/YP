// This is a generated file - do not edit.
//
// Generated from diagnosis.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ImageType extends $pb.ProtobufEnum {
  static const ImageType IMAGE_TYPE_UNSPECIFIED =
      ImageType._(0, _omitEnumNames ? '' : 'IMAGE_TYPE_UNSPECIFIED');
  static const ImageType IMAGE_TYPE_LEAF =
      ImageType._(1, _omitEnumNames ? '' : 'IMAGE_TYPE_LEAF');
  static const ImageType IMAGE_TYPE_STEM =
      ImageType._(2, _omitEnumNames ? '' : 'IMAGE_TYPE_STEM');
  static const ImageType IMAGE_TYPE_FRUIT =
      ImageType._(3, _omitEnumNames ? '' : 'IMAGE_TYPE_FRUIT');
  static const ImageType IMAGE_TYPE_WHOLE_PLANT =
      ImageType._(4, _omitEnumNames ? '' : 'IMAGE_TYPE_WHOLE_PLANT');
  static const ImageType IMAGE_TYPE_ROOT =
      ImageType._(5, _omitEnumNames ? '' : 'IMAGE_TYPE_ROOT');

  static const $core.List<ImageType> values = <ImageType>[
    IMAGE_TYPE_UNSPECIFIED,
    IMAGE_TYPE_LEAF,
    IMAGE_TYPE_STEM,
    IMAGE_TYPE_FRUIT,
    IMAGE_TYPE_WHOLE_PLANT,
    IMAGE_TYPE_ROOT,
  ];

  static final $core.List<ImageType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static ImageType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ImageType._(super.value, super.name);
}

class DiagnosisStatus extends $pb.ProtobufEnum {
  static const DiagnosisStatus DIAGNOSIS_STATUS_UNSPECIFIED = DiagnosisStatus._(
      0, _omitEnumNames ? '' : 'DIAGNOSIS_STATUS_UNSPECIFIED');
  static const DiagnosisStatus DIAGNOSIS_STATUS_PENDING =
      DiagnosisStatus._(1, _omitEnumNames ? '' : 'DIAGNOSIS_STATUS_PENDING');
  static const DiagnosisStatus DIAGNOSIS_STATUS_ANALYZING =
      DiagnosisStatus._(2, _omitEnumNames ? '' : 'DIAGNOSIS_STATUS_ANALYZING');
  static const DiagnosisStatus DIAGNOSIS_STATUS_COMPLETED =
      DiagnosisStatus._(3, _omitEnumNames ? '' : 'DIAGNOSIS_STATUS_COMPLETED');
  static const DiagnosisStatus DIAGNOSIS_STATUS_FAILED =
      DiagnosisStatus._(4, _omitEnumNames ? '' : 'DIAGNOSIS_STATUS_FAILED');

  static const $core.List<DiagnosisStatus> values = <DiagnosisStatus>[
    DIAGNOSIS_STATUS_UNSPECIFIED,
    DIAGNOSIS_STATUS_PENDING,
    DIAGNOSIS_STATUS_ANALYZING,
    DIAGNOSIS_STATUS_COMPLETED,
    DIAGNOSIS_STATUS_FAILED,
  ];

  static final $core.List<DiagnosisStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static DiagnosisStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DiagnosisStatus._(super.value, super.name);
}

class Severity extends $pb.ProtobufEnum {
  static const Severity SEVERITY_UNSPECIFIED =
      Severity._(0, _omitEnumNames ? '' : 'SEVERITY_UNSPECIFIED');
  static const Severity SEVERITY_MILD =
      Severity._(1, _omitEnumNames ? '' : 'SEVERITY_MILD');
  static const Severity SEVERITY_MODERATE =
      Severity._(2, _omitEnumNames ? '' : 'SEVERITY_MODERATE');
  static const Severity SEVERITY_SEVERE =
      Severity._(3, _omitEnumNames ? '' : 'SEVERITY_SEVERE');
  static const Severity SEVERITY_CRITICAL =
      Severity._(4, _omitEnumNames ? '' : 'SEVERITY_CRITICAL');

  static const $core.List<Severity> values = <Severity>[
    SEVERITY_UNSPECIFIED,
    SEVERITY_MILD,
    SEVERITY_MODERATE,
    SEVERITY_SEVERE,
    SEVERITY_CRITICAL,
  ];

  static final $core.List<Severity?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static Severity? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Severity._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
