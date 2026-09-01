// This is a generated file - do not edit.
//
// Generated from processing.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class ProcessingStatus extends $pb.ProtobufEnum {
  static const ProcessingStatus PROCESSING_STATUS_UNSPECIFIED =
      ProcessingStatus._(
          0, _omitEnumNames ? '' : 'PROCESSING_STATUS_UNSPECIFIED');
  static const ProcessingStatus PROCESSING_STATUS_QUEUED =
      ProcessingStatus._(1, _omitEnumNames ? '' : 'PROCESSING_STATUS_QUEUED');
  static const ProcessingStatus PROCESSING_STATUS_PREPROCESSING =
      ProcessingStatus._(
          2, _omitEnumNames ? '' : 'PROCESSING_STATUS_PREPROCESSING');
  static const ProcessingStatus PROCESSING_STATUS_ATMOSPHERIC_CORRECTION =
      ProcessingStatus._(
          3, _omitEnumNames ? '' : 'PROCESSING_STATUS_ATMOSPHERIC_CORRECTION');
  static const ProcessingStatus PROCESSING_STATUS_CLOUD_MASKING =
      ProcessingStatus._(
          4, _omitEnumNames ? '' : 'PROCESSING_STATUS_CLOUD_MASKING');
  static const ProcessingStatus PROCESSING_STATUS_ORTHORECTIFICATION =
      ProcessingStatus._(
          5, _omitEnumNames ? '' : 'PROCESSING_STATUS_ORTHORECTIFICATION');
  static const ProcessingStatus PROCESSING_STATUS_BAND_MATH =
      ProcessingStatus._(
          6, _omitEnumNames ? '' : 'PROCESSING_STATUS_BAND_MATH');
  static const ProcessingStatus PROCESSING_STATUS_COMPLETED =
      ProcessingStatus._(
          7, _omitEnumNames ? '' : 'PROCESSING_STATUS_COMPLETED');
  static const ProcessingStatus PROCESSING_STATUS_FAILED =
      ProcessingStatus._(8, _omitEnumNames ? '' : 'PROCESSING_STATUS_FAILED');

  static const $core.List<ProcessingStatus> values = <ProcessingStatus>[
    PROCESSING_STATUS_UNSPECIFIED,
    PROCESSING_STATUS_QUEUED,
    PROCESSING_STATUS_PREPROCESSING,
    PROCESSING_STATUS_ATMOSPHERIC_CORRECTION,
    PROCESSING_STATUS_CLOUD_MASKING,
    PROCESSING_STATUS_ORTHORECTIFICATION,
    PROCESSING_STATUS_BAND_MATH,
    PROCESSING_STATUS_COMPLETED,
    PROCESSING_STATUS_FAILED,
  ];

  static final $core.List<ProcessingStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static ProcessingStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ProcessingStatus._(super.value, super.name);
}

class ProcessingLevel extends $pb.ProtobufEnum {
  static const ProcessingLevel PROCESSING_LEVEL_UNSPECIFIED = ProcessingLevel._(
      0, _omitEnumNames ? '' : 'PROCESSING_LEVEL_UNSPECIFIED');
  static const ProcessingLevel PROCESSING_LEVEL_L1C =
      ProcessingLevel._(1, _omitEnumNames ? '' : 'PROCESSING_LEVEL_L1C');
  static const ProcessingLevel PROCESSING_LEVEL_L2A =
      ProcessingLevel._(2, _omitEnumNames ? '' : 'PROCESSING_LEVEL_L2A');
  static const ProcessingLevel PROCESSING_LEVEL_L3 =
      ProcessingLevel._(3, _omitEnumNames ? '' : 'PROCESSING_LEVEL_L3');

  static const $core.List<ProcessingLevel> values = <ProcessingLevel>[
    PROCESSING_LEVEL_UNSPECIFIED,
    PROCESSING_LEVEL_L1C,
    PROCESSING_LEVEL_L2A,
    PROCESSING_LEVEL_L3,
  ];

  static final $core.List<ProcessingLevel?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ProcessingLevel? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ProcessingLevel._(super.value, super.name);
}

class CorrectionAlgorithm extends $pb.ProtobufEnum {
  static const CorrectionAlgorithm CORRECTION_ALGORITHM_UNSPECIFIED =
      CorrectionAlgorithm._(
          0, _omitEnumNames ? '' : 'CORRECTION_ALGORITHM_UNSPECIFIED');
  static const CorrectionAlgorithm CORRECTION_ALGORITHM_SEN2COR =
      CorrectionAlgorithm._(
          1, _omitEnumNames ? '' : 'CORRECTION_ALGORITHM_SEN2COR');
  static const CorrectionAlgorithm CORRECTION_ALGORITHM_LASRC =
      CorrectionAlgorithm._(
          2, _omitEnumNames ? '' : 'CORRECTION_ALGORITHM_LASRC');
  static const CorrectionAlgorithm CORRECTION_ALGORITHM_FLAASH =
      CorrectionAlgorithm._(
          3, _omitEnumNames ? '' : 'CORRECTION_ALGORITHM_FLAASH');
  static const CorrectionAlgorithm CORRECTION_ALGORITHM_DOS =
      CorrectionAlgorithm._(
          4, _omitEnumNames ? '' : 'CORRECTION_ALGORITHM_DOS');

  static const $core.List<CorrectionAlgorithm> values = <CorrectionAlgorithm>[
    CORRECTION_ALGORITHM_UNSPECIFIED,
    CORRECTION_ALGORITHM_SEN2COR,
    CORRECTION_ALGORITHM_LASRC,
    CORRECTION_ALGORITHM_FLAASH,
    CORRECTION_ALGORITHM_DOS,
  ];

  static final $core.List<CorrectionAlgorithm?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static CorrectionAlgorithm? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CorrectionAlgorithm._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
