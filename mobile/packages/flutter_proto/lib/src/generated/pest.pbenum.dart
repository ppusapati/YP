// This is a generated file - do not edit.
//
// Generated from pest.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class RiskLevel extends $pb.ProtobufEnum {
  static const RiskLevel RISK_LEVEL_UNSPECIFIED =
      RiskLevel._(0, _omitEnumNames ? '' : 'RISK_LEVEL_UNSPECIFIED');
  static const RiskLevel RISK_LEVEL_NONE =
      RiskLevel._(1, _omitEnumNames ? '' : 'RISK_LEVEL_NONE');
  static const RiskLevel RISK_LEVEL_LOW =
      RiskLevel._(2, _omitEnumNames ? '' : 'RISK_LEVEL_LOW');
  static const RiskLevel RISK_LEVEL_MODERATE =
      RiskLevel._(3, _omitEnumNames ? '' : 'RISK_LEVEL_MODERATE');
  static const RiskLevel RISK_LEVEL_HIGH =
      RiskLevel._(4, _omitEnumNames ? '' : 'RISK_LEVEL_HIGH');
  static const RiskLevel RISK_LEVEL_CRITICAL =
      RiskLevel._(5, _omitEnumNames ? '' : 'RISK_LEVEL_CRITICAL');

  static const $core.List<RiskLevel> values = <RiskLevel>[
    RISK_LEVEL_UNSPECIFIED,
    RISK_LEVEL_NONE,
    RISK_LEVEL_LOW,
    RISK_LEVEL_MODERATE,
    RISK_LEVEL_HIGH,
    RISK_LEVEL_CRITICAL,
  ];

  static final $core.List<RiskLevel?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static RiskLevel? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const RiskLevel._(super.value, super.name);
}

class TreatmentType extends $pb.ProtobufEnum {
  static const TreatmentType TREATMENT_TYPE_UNSPECIFIED =
      TreatmentType._(0, _omitEnumNames ? '' : 'TREATMENT_TYPE_UNSPECIFIED');
  static const TreatmentType TREATMENT_TYPE_CHEMICAL =
      TreatmentType._(1, _omitEnumNames ? '' : 'TREATMENT_TYPE_CHEMICAL');
  static const TreatmentType TREATMENT_TYPE_BIOLOGICAL =
      TreatmentType._(2, _omitEnumNames ? '' : 'TREATMENT_TYPE_BIOLOGICAL');
  static const TreatmentType TREATMENT_TYPE_CULTURAL =
      TreatmentType._(3, _omitEnumNames ? '' : 'TREATMENT_TYPE_CULTURAL');
  static const TreatmentType TREATMENT_TYPE_MECHANICAL =
      TreatmentType._(4, _omitEnumNames ? '' : 'TREATMENT_TYPE_MECHANICAL');

  static const $core.List<TreatmentType> values = <TreatmentType>[
    TREATMENT_TYPE_UNSPECIFIED,
    TREATMENT_TYPE_CHEMICAL,
    TREATMENT_TYPE_BIOLOGICAL,
    TREATMENT_TYPE_CULTURAL,
    TREATMENT_TYPE_MECHANICAL,
  ];

  static final $core.List<TreatmentType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static TreatmentType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TreatmentType._(super.value, super.name);
}

class AlertStatus extends $pb.ProtobufEnum {
  static const AlertStatus ALERT_STATUS_UNSPECIFIED =
      AlertStatus._(0, _omitEnumNames ? '' : 'ALERT_STATUS_UNSPECIFIED');
  static const AlertStatus ALERT_STATUS_ACTIVE =
      AlertStatus._(1, _omitEnumNames ? '' : 'ALERT_STATUS_ACTIVE');
  static const AlertStatus ALERT_STATUS_ACKNOWLEDGED =
      AlertStatus._(2, _omitEnumNames ? '' : 'ALERT_STATUS_ACKNOWLEDGED');
  static const AlertStatus ALERT_STATUS_RESOLVED =
      AlertStatus._(3, _omitEnumNames ? '' : 'ALERT_STATUS_RESOLVED');
  static const AlertStatus ALERT_STATUS_EXPIRED =
      AlertStatus._(4, _omitEnumNames ? '' : 'ALERT_STATUS_EXPIRED');

  static const $core.List<AlertStatus> values = <AlertStatus>[
    ALERT_STATUS_UNSPECIFIED,
    ALERT_STATUS_ACTIVE,
    ALERT_STATUS_ACKNOWLEDGED,
    ALERT_STATUS_RESOLVED,
    ALERT_STATUS_EXPIRED,
  ];

  static final $core.List<AlertStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static AlertStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AlertStatus._(super.value, super.name);
}

class DamageLevel extends $pb.ProtobufEnum {
  static const DamageLevel DAMAGE_LEVEL_UNSPECIFIED =
      DamageLevel._(0, _omitEnumNames ? '' : 'DAMAGE_LEVEL_UNSPECIFIED');
  static const DamageLevel DAMAGE_LEVEL_NONE =
      DamageLevel._(1, _omitEnumNames ? '' : 'DAMAGE_LEVEL_NONE');
  static const DamageLevel DAMAGE_LEVEL_LIGHT =
      DamageLevel._(2, _omitEnumNames ? '' : 'DAMAGE_LEVEL_LIGHT');
  static const DamageLevel DAMAGE_LEVEL_MODERATE =
      DamageLevel._(3, _omitEnumNames ? '' : 'DAMAGE_LEVEL_MODERATE');
  static const DamageLevel DAMAGE_LEVEL_SEVERE =
      DamageLevel._(4, _omitEnumNames ? '' : 'DAMAGE_LEVEL_SEVERE');
  static const DamageLevel DAMAGE_LEVEL_DEVASTATING =
      DamageLevel._(5, _omitEnumNames ? '' : 'DAMAGE_LEVEL_DEVASTATING');

  static const $core.List<DamageLevel> values = <DamageLevel>[
    DAMAGE_LEVEL_UNSPECIFIED,
    DAMAGE_LEVEL_NONE,
    DAMAGE_LEVEL_LIGHT,
    DAMAGE_LEVEL_MODERATE,
    DAMAGE_LEVEL_SEVERE,
    DAMAGE_LEVEL_DEVASTATING,
  ];

  static final $core.List<DamageLevel?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static DamageLevel? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DamageLevel._(super.value, super.name);
}

/// GrowthStage must stay identical — names and numbers — to
/// agriculture.field.v1.GrowthStage.
///
/// It did not used to be. This service had FLOWERING = 4, FRUITING = 5,
/// MATURATION = 6, HARVEST = 7 against field-service's BUDDING = 4,
/// FLOWERING = 5, FRUIT_SET = 6, RIPENING = 7, MATURITY = 8, SENESCENCE = 9.
/// Two separate hazards: a stage named in one vocabulary and absent from the
/// other was silently dropped, and — worse, because nothing would have shown
/// it — the *numbers* collided, so field's FLOWERING(5) decoded here as
/// FRUITING(5) on any path that carried the enum rather than its name.
///
/// field-service's list won because it is the phenological sequence and it is
/// where a farmer actually records the stage; this service only reads it.
/// Growth stage is worth a quarter of the pest risk score, so a stage read as
/// the wrong one, or not read at all, moves a farmer-facing number.
///
/// If you add a stage here, add it to field.proto in the same commit.
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

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
