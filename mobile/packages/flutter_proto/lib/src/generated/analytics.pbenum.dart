// This is a generated file - do not edit.
//
// Generated from analytics.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class StressType extends $pb.ProtobufEnum {
  static const StressType STRESS_TYPE_UNSPECIFIED =
      StressType._(0, _omitEnumNames ? '' : 'STRESS_TYPE_UNSPECIFIED');
  static const StressType STRESS_TYPE_WATER =
      StressType._(1, _omitEnumNames ? '' : 'STRESS_TYPE_WATER');
  static const StressType STRESS_TYPE_NUTRIENT =
      StressType._(2, _omitEnumNames ? '' : 'STRESS_TYPE_NUTRIENT');
  static const StressType STRESS_TYPE_DISEASE =
      StressType._(3, _omitEnumNames ? '' : 'STRESS_TYPE_DISEASE');
  static const StressType STRESS_TYPE_PEST =
      StressType._(4, _omitEnumNames ? '' : 'STRESS_TYPE_PEST');
  static const StressType STRESS_TYPE_HEAT =
      StressType._(5, _omitEnumNames ? '' : 'STRESS_TYPE_HEAT');
  static const StressType STRESS_TYPE_FROST =
      StressType._(6, _omitEnumNames ? '' : 'STRESS_TYPE_FROST');

  static const $core.List<StressType> values = <StressType>[
    STRESS_TYPE_UNSPECIFIED,
    STRESS_TYPE_WATER,
    STRESS_TYPE_NUTRIENT,
    STRESS_TYPE_DISEASE,
    STRESS_TYPE_PEST,
    STRESS_TYPE_HEAT,
    STRESS_TYPE_FROST,
  ];

  static final $core.List<StressType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static StressType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const StressType._(super.value, super.name);
}

class SeverityLevel extends $pb.ProtobufEnum {
  static const SeverityLevel SEVERITY_LEVEL_UNSPECIFIED =
      SeverityLevel._(0, _omitEnumNames ? '' : 'SEVERITY_LEVEL_UNSPECIFIED');
  static const SeverityLevel SEVERITY_LEVEL_LOW =
      SeverityLevel._(1, _omitEnumNames ? '' : 'SEVERITY_LEVEL_LOW');
  static const SeverityLevel SEVERITY_LEVEL_MEDIUM =
      SeverityLevel._(2, _omitEnumNames ? '' : 'SEVERITY_LEVEL_MEDIUM');
  static const SeverityLevel SEVERITY_LEVEL_HIGH =
      SeverityLevel._(3, _omitEnumNames ? '' : 'SEVERITY_LEVEL_HIGH');
  static const SeverityLevel SEVERITY_LEVEL_CRITICAL =
      SeverityLevel._(4, _omitEnumNames ? '' : 'SEVERITY_LEVEL_CRITICAL');

  static const $core.List<SeverityLevel> values = <SeverityLevel>[
    SEVERITY_LEVEL_UNSPECIFIED,
    SEVERITY_LEVEL_LOW,
    SEVERITY_LEVEL_MEDIUM,
    SEVERITY_LEVEL_HIGH,
    SEVERITY_LEVEL_CRITICAL,
  ];

  static final $core.List<SeverityLevel?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static SeverityLevel? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SeverityLevel._(super.value, super.name);
}

class AnalysisType extends $pb.ProtobufEnum {
  static const AnalysisType ANALYSIS_TYPE_UNSPECIFIED =
      AnalysisType._(0, _omitEnumNames ? '' : 'ANALYSIS_TYPE_UNSPECIFIED');
  static const AnalysisType ANALYSIS_TYPE_STRESS_DETECTION =
      AnalysisType._(1, _omitEnumNames ? '' : 'ANALYSIS_TYPE_STRESS_DETECTION');
  static const AnalysisType ANALYSIS_TYPE_CHANGE_DETECTION =
      AnalysisType._(2, _omitEnumNames ? '' : 'ANALYSIS_TYPE_CHANGE_DETECTION');
  static const AnalysisType ANALYSIS_TYPE_TEMPORAL_TREND =
      AnalysisType._(3, _omitEnumNames ? '' : 'ANALYSIS_TYPE_TEMPORAL_TREND');
  static const AnalysisType ANALYSIS_TYPE_ANOMALY_DETECTION = AnalysisType._(
      4, _omitEnumNames ? '' : 'ANALYSIS_TYPE_ANOMALY_DETECTION');
  static const AnalysisType ANALYSIS_TYPE_CROP_CLASSIFICATION = AnalysisType._(
      5, _omitEnumNames ? '' : 'ANALYSIS_TYPE_CROP_CLASSIFICATION');

  static const $core.List<AnalysisType> values = <AnalysisType>[
    ANALYSIS_TYPE_UNSPECIFIED,
    ANALYSIS_TYPE_STRESS_DETECTION,
    ANALYSIS_TYPE_CHANGE_DETECTION,
    ANALYSIS_TYPE_TEMPORAL_TREND,
    ANALYSIS_TYPE_ANOMALY_DETECTION,
    ANALYSIS_TYPE_CROP_CLASSIFICATION,
  ];

  static final $core.List<AnalysisType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static AnalysisType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AnalysisType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
