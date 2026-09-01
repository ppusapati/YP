// This is a generated file - do not edit.
//
// Generated from yield.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// HarvestQualityGrade represents the quality classification of a harvest.
class HarvestQualityGrade extends $pb.ProtobufEnum {
  static const HarvestQualityGrade HARVEST_QUALITY_GRADE_UNSPECIFIED =
      HarvestQualityGrade._(
          0, _omitEnumNames ? '' : 'HARVEST_QUALITY_GRADE_UNSPECIFIED');
  static const HarvestQualityGrade HARVEST_QUALITY_GRADE_A =
      HarvestQualityGrade._(1, _omitEnumNames ? '' : 'HARVEST_QUALITY_GRADE_A');
  static const HarvestQualityGrade HARVEST_QUALITY_GRADE_B =
      HarvestQualityGrade._(2, _omitEnumNames ? '' : 'HARVEST_QUALITY_GRADE_B');
  static const HarvestQualityGrade HARVEST_QUALITY_GRADE_C =
      HarvestQualityGrade._(3, _omitEnumNames ? '' : 'HARVEST_QUALITY_GRADE_C');
  static const HarvestQualityGrade HARVEST_QUALITY_GRADE_D =
      HarvestQualityGrade._(4, _omitEnumNames ? '' : 'HARVEST_QUALITY_GRADE_D');

  static const $core.List<HarvestQualityGrade> values = <HarvestQualityGrade>[
    HARVEST_QUALITY_GRADE_UNSPECIFIED,
    HARVEST_QUALITY_GRADE_A,
    HARVEST_QUALITY_GRADE_B,
    HARVEST_QUALITY_GRADE_C,
    HARVEST_QUALITY_GRADE_D,
  ];

  static final $core.List<HarvestQualityGrade?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static HarvestQualityGrade? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const HarvestQualityGrade._(super.value, super.name);
}

/// PredictionStatus represents the status of a yield prediction.
class PredictionStatus extends $pb.ProtobufEnum {
  static const PredictionStatus PREDICTION_STATUS_UNSPECIFIED =
      PredictionStatus._(
          0, _omitEnumNames ? '' : 'PREDICTION_STATUS_UNSPECIFIED');
  static const PredictionStatus PREDICTION_STATUS_PENDING =
      PredictionStatus._(1, _omitEnumNames ? '' : 'PREDICTION_STATUS_PENDING');
  static const PredictionStatus PREDICTION_STATUS_COMPLETED =
      PredictionStatus._(
          2, _omitEnumNames ? '' : 'PREDICTION_STATUS_COMPLETED');
  static const PredictionStatus PREDICTION_STATUS_FAILED =
      PredictionStatus._(3, _omitEnumNames ? '' : 'PREDICTION_STATUS_FAILED');
  static const PredictionStatus PREDICTION_STATUS_SUPERSEDED =
      PredictionStatus._(
          4, _omitEnumNames ? '' : 'PREDICTION_STATUS_SUPERSEDED');

  static const $core.List<PredictionStatus> values = <PredictionStatus>[
    PREDICTION_STATUS_UNSPECIFIED,
    PREDICTION_STATUS_PENDING,
    PREDICTION_STATUS_COMPLETED,
    PREDICTION_STATUS_FAILED,
    PREDICTION_STATUS_SUPERSEDED,
  ];

  static final $core.List<PredictionStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static PredictionStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PredictionStatus._(super.value, super.name);
}

/// HarvestPlanStatus represents the status of a harvest plan.
class HarvestPlanStatus extends $pb.ProtobufEnum {
  static const HarvestPlanStatus HARVEST_PLAN_STATUS_UNSPECIFIED =
      HarvestPlanStatus._(
          0, _omitEnumNames ? '' : 'HARVEST_PLAN_STATUS_UNSPECIFIED');
  static const HarvestPlanStatus HARVEST_PLAN_STATUS_DRAFT =
      HarvestPlanStatus._(1, _omitEnumNames ? '' : 'HARVEST_PLAN_STATUS_DRAFT');
  static const HarvestPlanStatus HARVEST_PLAN_STATUS_SCHEDULED =
      HarvestPlanStatus._(
          2, _omitEnumNames ? '' : 'HARVEST_PLAN_STATUS_SCHEDULED');
  static const HarvestPlanStatus HARVEST_PLAN_STATUS_IN_PROGRESS =
      HarvestPlanStatus._(
          3, _omitEnumNames ? '' : 'HARVEST_PLAN_STATUS_IN_PROGRESS');
  static const HarvestPlanStatus HARVEST_PLAN_STATUS_COMPLETED =
      HarvestPlanStatus._(
          4, _omitEnumNames ? '' : 'HARVEST_PLAN_STATUS_COMPLETED');
  static const HarvestPlanStatus HARVEST_PLAN_STATUS_CANCELLED =
      HarvestPlanStatus._(
          5, _omitEnumNames ? '' : 'HARVEST_PLAN_STATUS_CANCELLED');

  static const $core.List<HarvestPlanStatus> values = <HarvestPlanStatus>[
    HARVEST_PLAN_STATUS_UNSPECIFIED,
    HARVEST_PLAN_STATUS_DRAFT,
    HARVEST_PLAN_STATUS_SCHEDULED,
    HARVEST_PLAN_STATUS_IN_PROGRESS,
    HARVEST_PLAN_STATUS_COMPLETED,
    HARVEST_PLAN_STATUS_CANCELLED,
  ];

  static final $core.List<HarvestPlanStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static HarvestPlanStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const HarvestPlanStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
