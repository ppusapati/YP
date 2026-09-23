// This is a generated file - do not edit.
//
// Generated from field.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class FieldStatus extends $pb.ProtobufEnum {
  static const FieldStatus FIELD_STATUS_UNSPECIFIED =
      FieldStatus._(0, _omitEnumNames ? '' : 'FIELD_STATUS_UNSPECIFIED');
  static const FieldStatus FIELD_STATUS_ACTIVE =
      FieldStatus._(1, _omitEnumNames ? '' : 'FIELD_STATUS_ACTIVE');
  static const FieldStatus FIELD_STATUS_FALLOW =
      FieldStatus._(2, _omitEnumNames ? '' : 'FIELD_STATUS_FALLOW');
  static const FieldStatus FIELD_STATUS_PREPARATION =
      FieldStatus._(3, _omitEnumNames ? '' : 'FIELD_STATUS_PREPARATION');
  static const FieldStatus FIELD_STATUS_PLANTED =
      FieldStatus._(4, _omitEnumNames ? '' : 'FIELD_STATUS_PLANTED');
  static const FieldStatus FIELD_STATUS_HARVESTING =
      FieldStatus._(5, _omitEnumNames ? '' : 'FIELD_STATUS_HARVESTING');
  static const FieldStatus FIELD_STATUS_RETIRED =
      FieldStatus._(6, _omitEnumNames ? '' : 'FIELD_STATUS_RETIRED');

  static const $core.List<FieldStatus> values = <FieldStatus>[
    FIELD_STATUS_UNSPECIFIED,
    FIELD_STATUS_ACTIVE,
    FIELD_STATUS_FALLOW,
    FIELD_STATUS_PREPARATION,
    FIELD_STATUS_PLANTED,
    FIELD_STATUS_HARVESTING,
    FIELD_STATUS_RETIRED,
  ];

  static final $core.List<FieldStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static FieldStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FieldStatus._(super.value, super.name);
}

class FieldType extends $pb.ProtobufEnum {
  static const FieldType FIELD_TYPE_UNSPECIFIED =
      FieldType._(0, _omitEnumNames ? '' : 'FIELD_TYPE_UNSPECIFIED');
  static const FieldType FIELD_TYPE_CROPLAND =
      FieldType._(1, _omitEnumNames ? '' : 'FIELD_TYPE_CROPLAND');
  static const FieldType FIELD_TYPE_PASTURE =
      FieldType._(2, _omitEnumNames ? '' : 'FIELD_TYPE_PASTURE');
  static const FieldType FIELD_TYPE_ORCHARD =
      FieldType._(3, _omitEnumNames ? '' : 'FIELD_TYPE_ORCHARD');
  static const FieldType FIELD_TYPE_VINEYARD =
      FieldType._(4, _omitEnumNames ? '' : 'FIELD_TYPE_VINEYARD');
  static const FieldType FIELD_TYPE_GREENHOUSE =
      FieldType._(5, _omitEnumNames ? '' : 'FIELD_TYPE_GREENHOUSE');
  static const FieldType FIELD_TYPE_NURSERY =
      FieldType._(6, _omitEnumNames ? '' : 'FIELD_TYPE_NURSERY');
  static const FieldType FIELD_TYPE_AGROFOREST =
      FieldType._(7, _omitEnumNames ? '' : 'FIELD_TYPE_AGROFOREST');

  static const $core.List<FieldType> values = <FieldType>[
    FIELD_TYPE_UNSPECIFIED,
    FIELD_TYPE_CROPLAND,
    FIELD_TYPE_PASTURE,
    FIELD_TYPE_ORCHARD,
    FIELD_TYPE_VINEYARD,
    FIELD_TYPE_GREENHOUSE,
    FIELD_TYPE_NURSERY,
    FIELD_TYPE_AGROFOREST,
  ];

  static final $core.List<FieldType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static FieldType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FieldType._(super.value, super.name);
}

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
  static const SoilType SOIL_TYPE_CHALK =
      SoilType._(6, _omitEnumNames ? '' : 'SOIL_TYPE_CHALK');
  static const SoilType SOIL_TYPE_CLAY_LOAM =
      SoilType._(7, _omitEnumNames ? '' : 'SOIL_TYPE_CLAY_LOAM');
  static const SoilType SOIL_TYPE_SANDY_LOAM =
      SoilType._(8, _omitEnumNames ? '' : 'SOIL_TYPE_SANDY_LOAM');

  static const $core.List<SoilType> values = <SoilType>[
    SOIL_TYPE_UNSPECIFIED,
    SOIL_TYPE_CLAY,
    SOIL_TYPE_SANDY,
    SOIL_TYPE_LOAMY,
    SOIL_TYPE_SILT,
    SOIL_TYPE_PEAT,
    SOIL_TYPE_CHALK,
    SOIL_TYPE_CLAY_LOAM,
    SOIL_TYPE_SANDY_LOAM,
  ];

  static final $core.List<SoilType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static SoilType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SoilType._(super.value, super.name);
}

class IrrigationType extends $pb.ProtobufEnum {
  static const IrrigationType IRRIGATION_TYPE_UNSPECIFIED =
      IrrigationType._(0, _omitEnumNames ? '' : 'IRRIGATION_TYPE_UNSPECIFIED');
  static const IrrigationType IRRIGATION_TYPE_RAINFED =
      IrrigationType._(1, _omitEnumNames ? '' : 'IRRIGATION_TYPE_RAINFED');
  static const IrrigationType IRRIGATION_TYPE_DRIP =
      IrrigationType._(2, _omitEnumNames ? '' : 'IRRIGATION_TYPE_DRIP');
  static const IrrigationType IRRIGATION_TYPE_SPRINKLER =
      IrrigationType._(3, _omitEnumNames ? '' : 'IRRIGATION_TYPE_SPRINKLER');
  static const IrrigationType IRRIGATION_TYPE_FLOOD =
      IrrigationType._(4, _omitEnumNames ? '' : 'IRRIGATION_TYPE_FLOOD');
  static const IrrigationType IRRIGATION_TYPE_CENTER_PIVOT =
      IrrigationType._(5, _omitEnumNames ? '' : 'IRRIGATION_TYPE_CENTER_PIVOT');
  static const IrrigationType IRRIGATION_TYPE_FURROW =
      IrrigationType._(6, _omitEnumNames ? '' : 'IRRIGATION_TYPE_FURROW');
  static const IrrigationType IRRIGATION_TYPE_SUBSURFACE =
      IrrigationType._(7, _omitEnumNames ? '' : 'IRRIGATION_TYPE_SUBSURFACE');

  static const $core.List<IrrigationType> values = <IrrigationType>[
    IRRIGATION_TYPE_UNSPECIFIED,
    IRRIGATION_TYPE_RAINFED,
    IRRIGATION_TYPE_DRIP,
    IRRIGATION_TYPE_SPRINKLER,
    IRRIGATION_TYPE_FLOOD,
    IRRIGATION_TYPE_CENTER_PIVOT,
    IRRIGATION_TYPE_FURROW,
    IRRIGATION_TYPE_SUBSURFACE,
  ];

  static final $core.List<IrrigationType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static IrrigationType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const IrrigationType._(super.value, super.name);
}

/// GrowthStage is the phenological sequence a crop moves through, and this is
/// where a farmer records it. agriculture.pest.v1.GrowthStage is a copy of it —
/// names and numbers — because pest risk is scored partly on the stage.
///
/// If you add a stage here, add it to pest.proto in the same commit.
class GrowthStage extends $pb.ProtobufEnum {
  static const GrowthStage GROWTH_STAGE_UNSPECIFIED =
      GrowthStage._(0, _omitEnumNames ? '' : 'GROWTH_STAGE_UNSPECIFIED');
  static const GrowthStage GROWTH_STAGE_GERMINATION =
      GrowthStage._(1, _omitEnumNames ? '' : 'GROWTH_STAGE_GERMINATION');
  static const GrowthStage GROWTH_STAGE_SEEDLING =
      GrowthStage._(2, _omitEnumNames ? '' : 'GROWTH_STAGE_SEEDLING');
  static const GrowthStage GROWTH_STAGE_VEGETATIVE =
      GrowthStage._(3, _omitEnumNames ? '' : 'GROWTH_STAGE_VEGETATIVE');
  static const GrowthStage GROWTH_STAGE_BUDDING =
      GrowthStage._(4, _omitEnumNames ? '' : 'GROWTH_STAGE_BUDDING');
  static const GrowthStage GROWTH_STAGE_FLOWERING =
      GrowthStage._(5, _omitEnumNames ? '' : 'GROWTH_STAGE_FLOWERING');
  static const GrowthStage GROWTH_STAGE_FRUIT_SET =
      GrowthStage._(6, _omitEnumNames ? '' : 'GROWTH_STAGE_FRUIT_SET');
  static const GrowthStage GROWTH_STAGE_RIPENING =
      GrowthStage._(7, _omitEnumNames ? '' : 'GROWTH_STAGE_RIPENING');
  static const GrowthStage GROWTH_STAGE_MATURITY =
      GrowthStage._(8, _omitEnumNames ? '' : 'GROWTH_STAGE_MATURITY');
  static const GrowthStage GROWTH_STAGE_SENESCENCE =
      GrowthStage._(9, _omitEnumNames ? '' : 'GROWTH_STAGE_SENESCENCE');

  static const $core.List<GrowthStage> values = <GrowthStage>[
    GROWTH_STAGE_UNSPECIFIED,
    GROWTH_STAGE_GERMINATION,
    GROWTH_STAGE_SEEDLING,
    GROWTH_STAGE_VEGETATIVE,
    GROWTH_STAGE_BUDDING,
    GROWTH_STAGE_FLOWERING,
    GROWTH_STAGE_FRUIT_SET,
    GROWTH_STAGE_RIPENING,
    GROWTH_STAGE_MATURITY,
    GROWTH_STAGE_SENESCENCE,
  ];

  static final $core.List<GrowthStage?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 9);
  static GrowthStage? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GrowthStage._(super.value, super.name);
}

class AspectDirection extends $pb.ProtobufEnum {
  static const AspectDirection ASPECT_DIRECTION_UNSPECIFIED = AspectDirection._(
      0, _omitEnumNames ? '' : 'ASPECT_DIRECTION_UNSPECIFIED');
  static const AspectDirection ASPECT_DIRECTION_NORTH =
      AspectDirection._(1, _omitEnumNames ? '' : 'ASPECT_DIRECTION_NORTH');
  static const AspectDirection ASPECT_DIRECTION_NORTHEAST =
      AspectDirection._(2, _omitEnumNames ? '' : 'ASPECT_DIRECTION_NORTHEAST');
  static const AspectDirection ASPECT_DIRECTION_EAST =
      AspectDirection._(3, _omitEnumNames ? '' : 'ASPECT_DIRECTION_EAST');
  static const AspectDirection ASPECT_DIRECTION_SOUTHEAST =
      AspectDirection._(4, _omitEnumNames ? '' : 'ASPECT_DIRECTION_SOUTHEAST');
  static const AspectDirection ASPECT_DIRECTION_SOUTH =
      AspectDirection._(5, _omitEnumNames ? '' : 'ASPECT_DIRECTION_SOUTH');
  static const AspectDirection ASPECT_DIRECTION_SOUTHWEST =
      AspectDirection._(6, _omitEnumNames ? '' : 'ASPECT_DIRECTION_SOUTHWEST');
  static const AspectDirection ASPECT_DIRECTION_WEST =
      AspectDirection._(7, _omitEnumNames ? '' : 'ASPECT_DIRECTION_WEST');
  static const AspectDirection ASPECT_DIRECTION_NORTHWEST =
      AspectDirection._(8, _omitEnumNames ? '' : 'ASPECT_DIRECTION_NORTHWEST');
  static const AspectDirection ASPECT_DIRECTION_FLAT =
      AspectDirection._(9, _omitEnumNames ? '' : 'ASPECT_DIRECTION_FLAT');

  static const $core.List<AspectDirection> values = <AspectDirection>[
    ASPECT_DIRECTION_UNSPECIFIED,
    ASPECT_DIRECTION_NORTH,
    ASPECT_DIRECTION_NORTHEAST,
    ASPECT_DIRECTION_EAST,
    ASPECT_DIRECTION_SOUTHEAST,
    ASPECT_DIRECTION_SOUTH,
    ASPECT_DIRECTION_SOUTHWEST,
    ASPECT_DIRECTION_WEST,
    ASPECT_DIRECTION_NORTHWEST,
    ASPECT_DIRECTION_FLAT,
  ];

  static final $core.List<AspectDirection?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 9);
  static AspectDirection? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AspectDirection._(super.value, super.name);
}

class CropCycleStatus extends $pb.ProtobufEnum {
  static const CropCycleStatus CYCLE_STATUS_UNSPECIFIED =
      CropCycleStatus._(0, _omitEnumNames ? '' : 'CYCLE_STATUS_UNSPECIFIED');
  static const CropCycleStatus CYCLE_STATUS_PLANNED =
      CropCycleStatus._(1, _omitEnumNames ? '' : 'CYCLE_STATUS_PLANNED');
  static const CropCycleStatus CYCLE_STATUS_ACTIVE =
      CropCycleStatus._(2, _omitEnumNames ? '' : 'CYCLE_STATUS_ACTIVE');
  static const CropCycleStatus CYCLE_STATUS_HARVESTING =
      CropCycleStatus._(3, _omitEnumNames ? '' : 'CYCLE_STATUS_HARVESTING');
  static const CropCycleStatus CYCLE_STATUS_COMPLETED =
      CropCycleStatus._(4, _omitEnumNames ? '' : 'CYCLE_STATUS_COMPLETED');
  static const CropCycleStatus CYCLE_STATUS_ABANDONED =
      CropCycleStatus._(5, _omitEnumNames ? '' : 'CYCLE_STATUS_ABANDONED');

  static const $core.List<CropCycleStatus> values = <CropCycleStatus>[
    CYCLE_STATUS_UNSPECIFIED,
    CYCLE_STATUS_PLANNED,
    CYCLE_STATUS_ACTIVE,
    CYCLE_STATUS_HARVESTING,
    CYCLE_STATUS_COMPLETED,
    CYCLE_STATUS_ABANDONED,
  ];

  static final $core.List<CropCycleStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static CropCycleStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CropCycleStatus._(super.value, super.name);
}

class ActivityCategory extends $pb.ProtobufEnum {
  static const ActivityCategory CATEGORY_UNSPECIFIED =
      ActivityCategory._(0, _omitEnumNames ? '' : 'CATEGORY_UNSPECIFIED');
  static const ActivityCategory CATEGORY_LAND_PREP =
      ActivityCategory._(1, _omitEnumNames ? '' : 'CATEGORY_LAND_PREP');
  static const ActivityCategory CATEGORY_PLANTING =
      ActivityCategory._(2, _omitEnumNames ? '' : 'CATEGORY_PLANTING');
  static const ActivityCategory CATEGORY_IRRIGATION =
      ActivityCategory._(3, _omitEnumNames ? '' : 'CATEGORY_IRRIGATION');
  static const ActivityCategory CATEGORY_FERTILIZATION =
      ActivityCategory._(4, _omitEnumNames ? '' : 'CATEGORY_FERTILIZATION');
  static const ActivityCategory CATEGORY_PEST_CONTROL =
      ActivityCategory._(5, _omitEnumNames ? '' : 'CATEGORY_PEST_CONTROL');
  static const ActivityCategory CATEGORY_SCOUTING =
      ActivityCategory._(6, _omitEnumNames ? '' : 'CATEGORY_SCOUTING');
  static const ActivityCategory CATEGORY_HARVESTING =
      ActivityCategory._(7, _omitEnumNames ? '' : 'CATEGORY_HARVESTING');
  static const ActivityCategory CATEGORY_POST_HARVEST =
      ActivityCategory._(8, _omitEnumNames ? '' : 'CATEGORY_POST_HARVEST');
  static const ActivityCategory CATEGORY_SOIL_SAMPLING =
      ActivityCategory._(9, _omitEnumNames ? '' : 'CATEGORY_SOIL_SAMPLING');
  static const ActivityCategory CATEGORY_MAINTENANCE =
      ActivityCategory._(10, _omitEnumNames ? '' : 'CATEGORY_MAINTENANCE');

  static const $core.List<ActivityCategory> values = <ActivityCategory>[
    CATEGORY_UNSPECIFIED,
    CATEGORY_LAND_PREP,
    CATEGORY_PLANTING,
    CATEGORY_IRRIGATION,
    CATEGORY_FERTILIZATION,
    CATEGORY_PEST_CONTROL,
    CATEGORY_SCOUTING,
    CATEGORY_HARVESTING,
    CATEGORY_POST_HARVEST,
    CATEGORY_SOIL_SAMPLING,
    CATEGORY_MAINTENANCE,
  ];

  static final $core.List<ActivityCategory?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 10);
  static ActivityCategory? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ActivityCategory._(super.value, super.name);
}

class EvidenceType extends $pb.ProtobufEnum {
  static const EvidenceType EVIDENCE_TYPE_UNSPECIFIED =
      EvidenceType._(0, _omitEnumNames ? '' : 'EVIDENCE_TYPE_UNSPECIFIED');
  static const EvidenceType EVIDENCE_TYPE_PHOTO =
      EvidenceType._(1, _omitEnumNames ? '' : 'EVIDENCE_TYPE_PHOTO');
  static const EvidenceType EVIDENCE_TYPE_DOCUMENT =
      EvidenceType._(2, _omitEnumNames ? '' : 'EVIDENCE_TYPE_DOCUMENT');
  static const EvidenceType EVIDENCE_TYPE_VIDEO =
      EvidenceType._(3, _omitEnumNames ? '' : 'EVIDENCE_TYPE_VIDEO');
  static const EvidenceType EVIDENCE_TYPE_AUDIO =
      EvidenceType._(4, _omitEnumNames ? '' : 'EVIDENCE_TYPE_AUDIO');
  static const EvidenceType EVIDENCE_TYPE_OTHER =
      EvidenceType._(5, _omitEnumNames ? '' : 'EVIDENCE_TYPE_OTHER');

  static const $core.List<EvidenceType> values = <EvidenceType>[
    EVIDENCE_TYPE_UNSPECIFIED,
    EVIDENCE_TYPE_PHOTO,
    EVIDENCE_TYPE_DOCUMENT,
    EVIDENCE_TYPE_VIDEO,
    EVIDENCE_TYPE_AUDIO,
    EVIDENCE_TYPE_OTHER,
  ];

  static final $core.List<EvidenceType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static EvidenceType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EvidenceType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
