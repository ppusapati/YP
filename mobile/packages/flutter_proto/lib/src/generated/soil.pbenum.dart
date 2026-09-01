// This is a generated file - do not edit.
//
// Generated from soil.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class SoilTexture extends $pb.ProtobufEnum {
  static const SoilTexture SOIL_TEXTURE_UNSPECIFIED =
      SoilTexture._(0, _omitEnumNames ? '' : 'SOIL_TEXTURE_UNSPECIFIED');
  static const SoilTexture SOIL_TEXTURE_SANDY =
      SoilTexture._(1, _omitEnumNames ? '' : 'SOIL_TEXTURE_SANDY');
  static const SoilTexture SOIL_TEXTURE_LOAMY =
      SoilTexture._(2, _omitEnumNames ? '' : 'SOIL_TEXTURE_LOAMY');
  static const SoilTexture SOIL_TEXTURE_CLAY =
      SoilTexture._(3, _omitEnumNames ? '' : 'SOIL_TEXTURE_CLAY');
  static const SoilTexture SOIL_TEXTURE_SILT =
      SoilTexture._(4, _omitEnumNames ? '' : 'SOIL_TEXTURE_SILT');
  static const SoilTexture SOIL_TEXTURE_PEAT =
      SoilTexture._(5, _omitEnumNames ? '' : 'SOIL_TEXTURE_PEAT');
  static const SoilTexture SOIL_TEXTURE_CHALK =
      SoilTexture._(6, _omitEnumNames ? '' : 'SOIL_TEXTURE_CHALK');

  static const $core.List<SoilTexture> values = <SoilTexture>[
    SOIL_TEXTURE_UNSPECIFIED,
    SOIL_TEXTURE_SANDY,
    SOIL_TEXTURE_LOAMY,
    SOIL_TEXTURE_CLAY,
    SOIL_TEXTURE_SILT,
    SOIL_TEXTURE_PEAT,
    SOIL_TEXTURE_CHALK,
  ];

  static final $core.List<SoilTexture?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static SoilTexture? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SoilTexture._(super.value, super.name);
}

class AnalysisStatus extends $pb.ProtobufEnum {
  static const AnalysisStatus ANALYSIS_STATUS_UNSPECIFIED =
      AnalysisStatus._(0, _omitEnumNames ? '' : 'ANALYSIS_STATUS_UNSPECIFIED');
  static const AnalysisStatus ANALYSIS_STATUS_PENDING =
      AnalysisStatus._(1, _omitEnumNames ? '' : 'ANALYSIS_STATUS_PENDING');
  static const AnalysisStatus ANALYSIS_STATUS_IN_PROGRESS =
      AnalysisStatus._(2, _omitEnumNames ? '' : 'ANALYSIS_STATUS_IN_PROGRESS');
  static const AnalysisStatus ANALYSIS_STATUS_COMPLETED =
      AnalysisStatus._(3, _omitEnumNames ? '' : 'ANALYSIS_STATUS_COMPLETED');
  static const AnalysisStatus ANALYSIS_STATUS_FAILED =
      AnalysisStatus._(4, _omitEnumNames ? '' : 'ANALYSIS_STATUS_FAILED');

  static const $core.List<AnalysisStatus> values = <AnalysisStatus>[
    ANALYSIS_STATUS_UNSPECIFIED,
    ANALYSIS_STATUS_PENDING,
    ANALYSIS_STATUS_IN_PROGRESS,
    ANALYSIS_STATUS_COMPLETED,
    ANALYSIS_STATUS_FAILED,
  ];

  static final $core.List<AnalysisStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static AnalysisStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AnalysisStatus._(super.value, super.name);
}

class NutrientLevel extends $pb.ProtobufEnum {
  static const NutrientLevel NUTRIENT_LEVEL_UNSPECIFIED =
      NutrientLevel._(0, _omitEnumNames ? '' : 'NUTRIENT_LEVEL_UNSPECIFIED');
  static const NutrientLevel NUTRIENT_LEVEL_DEFICIENT =
      NutrientLevel._(1, _omitEnumNames ? '' : 'NUTRIENT_LEVEL_DEFICIENT');
  static const NutrientLevel NUTRIENT_LEVEL_LOW =
      NutrientLevel._(2, _omitEnumNames ? '' : 'NUTRIENT_LEVEL_LOW');
  static const NutrientLevel NUTRIENT_LEVEL_ADEQUATE =
      NutrientLevel._(3, _omitEnumNames ? '' : 'NUTRIENT_LEVEL_ADEQUATE');
  static const NutrientLevel NUTRIENT_LEVEL_HIGH =
      NutrientLevel._(4, _omitEnumNames ? '' : 'NUTRIENT_LEVEL_HIGH');
  static const NutrientLevel NUTRIENT_LEVEL_EXCESSIVE =
      NutrientLevel._(5, _omitEnumNames ? '' : 'NUTRIENT_LEVEL_EXCESSIVE');

  static const $core.List<NutrientLevel> values = <NutrientLevel>[
    NUTRIENT_LEVEL_UNSPECIFIED,
    NUTRIENT_LEVEL_DEFICIENT,
    NUTRIENT_LEVEL_LOW,
    NUTRIENT_LEVEL_ADEQUATE,
    NUTRIENT_LEVEL_HIGH,
    NUTRIENT_LEVEL_EXCESSIVE,
  ];

  static final $core.List<NutrientLevel?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static NutrientLevel? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NutrientLevel._(super.value, super.name);
}

class HealthCategory extends $pb.ProtobufEnum {
  static const HealthCategory HEALTH_CATEGORY_UNSPECIFIED =
      HealthCategory._(0, _omitEnumNames ? '' : 'HEALTH_CATEGORY_UNSPECIFIED');
  static const HealthCategory HEALTH_CATEGORY_CRITICAL =
      HealthCategory._(1, _omitEnumNames ? '' : 'HEALTH_CATEGORY_CRITICAL');
  static const HealthCategory HEALTH_CATEGORY_POOR =
      HealthCategory._(2, _omitEnumNames ? '' : 'HEALTH_CATEGORY_POOR');
  static const HealthCategory HEALTH_CATEGORY_FAIR =
      HealthCategory._(3, _omitEnumNames ? '' : 'HEALTH_CATEGORY_FAIR');
  static const HealthCategory HEALTH_CATEGORY_GOOD =
      HealthCategory._(4, _omitEnumNames ? '' : 'HEALTH_CATEGORY_GOOD');
  static const HealthCategory HEALTH_CATEGORY_EXCELLENT =
      HealthCategory._(5, _omitEnumNames ? '' : 'HEALTH_CATEGORY_EXCELLENT');

  static const $core.List<HealthCategory> values = <HealthCategory>[
    HEALTH_CATEGORY_UNSPECIFIED,
    HEALTH_CATEGORY_CRITICAL,
    HEALTH_CATEGORY_POOR,
    HEALTH_CATEGORY_FAIR,
    HEALTH_CATEGORY_GOOD,
    HEALTH_CATEGORY_EXCELLENT,
  ];

  static final $core.List<HealthCategory?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static HealthCategory? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const HealthCategory._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
