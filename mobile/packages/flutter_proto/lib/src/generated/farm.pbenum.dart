// This is a generated file - do not edit.
//
// Generated from farm.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// FarmType represents the type of farming operation.
class FarmType extends $pb.ProtobufEnum {
  static const FarmType FARM_TYPE_UNSPECIFIED =
      FarmType._(0, _omitEnumNames ? '' : 'FARM_TYPE_UNSPECIFIED');
  static const FarmType FARM_TYPE_CROP =
      FarmType._(1, _omitEnumNames ? '' : 'FARM_TYPE_CROP');
  static const FarmType FARM_TYPE_LIVESTOCK =
      FarmType._(2, _omitEnumNames ? '' : 'FARM_TYPE_LIVESTOCK');
  static const FarmType FARM_TYPE_MIXED =
      FarmType._(3, _omitEnumNames ? '' : 'FARM_TYPE_MIXED');
  static const FarmType FARM_TYPE_AQUACULTURE =
      FarmType._(4, _omitEnumNames ? '' : 'FARM_TYPE_AQUACULTURE');

  static const $core.List<FarmType> values = <FarmType>[
    FARM_TYPE_UNSPECIFIED,
    FARM_TYPE_CROP,
    FARM_TYPE_LIVESTOCK,
    FARM_TYPE_MIXED,
    FARM_TYPE_AQUACULTURE,
  ];

  static final $core.List<FarmType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static FarmType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FarmType._(super.value, super.name);
}

/// FarmStatus represents the operational status of a farm.
class FarmStatus extends $pb.ProtobufEnum {
  static const FarmStatus FARM_STATUS_UNSPECIFIED =
      FarmStatus._(0, _omitEnumNames ? '' : 'FARM_STATUS_UNSPECIFIED');
  static const FarmStatus FARM_STATUS_ACTIVE =
      FarmStatus._(1, _omitEnumNames ? '' : 'FARM_STATUS_ACTIVE');
  static const FarmStatus FARM_STATUS_INACTIVE =
      FarmStatus._(2, _omitEnumNames ? '' : 'FARM_STATUS_INACTIVE');
  static const FarmStatus FARM_STATUS_PENDING =
      FarmStatus._(3, _omitEnumNames ? '' : 'FARM_STATUS_PENDING');
  static const FarmStatus FARM_STATUS_SUSPENDED =
      FarmStatus._(4, _omitEnumNames ? '' : 'FARM_STATUS_SUSPENDED');
  static const FarmStatus FARM_STATUS_ARCHIVED =
      FarmStatus._(5, _omitEnumNames ? '' : 'FARM_STATUS_ARCHIVED');

  static const $core.List<FarmStatus> values = <FarmStatus>[
    FARM_STATUS_UNSPECIFIED,
    FARM_STATUS_ACTIVE,
    FARM_STATUS_INACTIVE,
    FARM_STATUS_PENDING,
    FARM_STATUS_SUSPENDED,
    FARM_STATUS_ARCHIVED,
  ];

  static final $core.List<FarmStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static FarmStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FarmStatus._(super.value, super.name);
}

/// SoilType represents the soil classification of a farm.
class SoilType extends $pb.ProtobufEnum {
  static const SoilType SOIL_TYPE_UNSPECIFIED =
      SoilType._(0, _omitEnumNames ? '' : 'SOIL_TYPE_UNSPECIFIED');
  static const SoilType SOIL_TYPE_CLAY =
      SoilType._(1, _omitEnumNames ? '' : 'SOIL_TYPE_CLAY');
  static const SoilType SOIL_TYPE_SANDY =
      SoilType._(2, _omitEnumNames ? '' : 'SOIL_TYPE_SANDY');
  static const SoilType SOIL_TYPE_LOAMY =
      SoilType._(3, _omitEnumNames ? '' : 'SOIL_TYPE_LOAMY');
  static const SoilType SOIL_TYPE_SILT =
      SoilType._(4, _omitEnumNames ? '' : 'SOIL_TYPE_SILT');
  static const SoilType SOIL_TYPE_PEAT =
      SoilType._(5, _omitEnumNames ? '' : 'SOIL_TYPE_PEAT');
  static const SoilType SOIL_TYPE_CHALKY =
      SoilType._(6, _omitEnumNames ? '' : 'SOIL_TYPE_CHALKY');
  static const SoilType SOIL_TYPE_LATERITE =
      SoilType._(7, _omitEnumNames ? '' : 'SOIL_TYPE_LATERITE');
  static const SoilType SOIL_TYPE_BLACK =
      SoilType._(8, _omitEnumNames ? '' : 'SOIL_TYPE_BLACK');
  static const SoilType SOIL_TYPE_RED =
      SoilType._(9, _omitEnumNames ? '' : 'SOIL_TYPE_RED');
  static const SoilType SOIL_TYPE_ALLUVIAL =
      SoilType._(10, _omitEnumNames ? '' : 'SOIL_TYPE_ALLUVIAL');

  static const $core.List<SoilType> values = <SoilType>[
    SOIL_TYPE_UNSPECIFIED,
    SOIL_TYPE_CLAY,
    SOIL_TYPE_SANDY,
    SOIL_TYPE_LOAMY,
    SOIL_TYPE_SILT,
    SOIL_TYPE_PEAT,
    SOIL_TYPE_CHALKY,
    SOIL_TYPE_LATERITE,
    SOIL_TYPE_BLACK,
    SOIL_TYPE_RED,
    SOIL_TYPE_ALLUVIAL,
  ];

  static final $core.List<SoilType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 10);
  static SoilType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SoilType._(super.value, super.name);
}

/// ClimateZone represents the climate zone of a farm.
class ClimateZone extends $pb.ProtobufEnum {
  static const ClimateZone CLIMATE_ZONE_UNSPECIFIED =
      ClimateZone._(0, _omitEnumNames ? '' : 'CLIMATE_ZONE_UNSPECIFIED');
  static const ClimateZone CLIMATE_ZONE_TROPICAL =
      ClimateZone._(1, _omitEnumNames ? '' : 'CLIMATE_ZONE_TROPICAL');
  static const ClimateZone CLIMATE_ZONE_SUBTROPICAL =
      ClimateZone._(2, _omitEnumNames ? '' : 'CLIMATE_ZONE_SUBTROPICAL');
  static const ClimateZone CLIMATE_ZONE_ARID =
      ClimateZone._(3, _omitEnumNames ? '' : 'CLIMATE_ZONE_ARID');
  static const ClimateZone CLIMATE_ZONE_SEMIARID =
      ClimateZone._(4, _omitEnumNames ? '' : 'CLIMATE_ZONE_SEMIARID');
  static const ClimateZone CLIMATE_ZONE_TEMPERATE =
      ClimateZone._(5, _omitEnumNames ? '' : 'CLIMATE_ZONE_TEMPERATE');
  static const ClimateZone CLIMATE_ZONE_CONTINENTAL =
      ClimateZone._(6, _omitEnumNames ? '' : 'CLIMATE_ZONE_CONTINENTAL');
  static const ClimateZone CLIMATE_ZONE_POLAR =
      ClimateZone._(7, _omitEnumNames ? '' : 'CLIMATE_ZONE_POLAR');
  static const ClimateZone CLIMATE_ZONE_MEDITERRANEAN =
      ClimateZone._(8, _omitEnumNames ? '' : 'CLIMATE_ZONE_MEDITERRANEAN');
  static const ClimateZone CLIMATE_ZONE_MONSOON =
      ClimateZone._(9, _omitEnumNames ? '' : 'CLIMATE_ZONE_MONSOON');

  static const $core.List<ClimateZone> values = <ClimateZone>[
    CLIMATE_ZONE_UNSPECIFIED,
    CLIMATE_ZONE_TROPICAL,
    CLIMATE_ZONE_SUBTROPICAL,
    CLIMATE_ZONE_ARID,
    CLIMATE_ZONE_SEMIARID,
    CLIMATE_ZONE_TEMPERATE,
    CLIMATE_ZONE_CONTINENTAL,
    CLIMATE_ZONE_POLAR,
    CLIMATE_ZONE_MEDITERRANEAN,
    CLIMATE_ZONE_MONSOON,
  ];

  static final $core.List<ClimateZone?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 9);
  static ClimateZone? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ClimateZone._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
