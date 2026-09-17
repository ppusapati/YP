// This is a generated file - do not edit.
//
// Generated from planning.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Season is the Indian cropping calendar.
///
/// Not "spring/summer/autumn": the crop calendar here runs on the monsoon, and
/// a planner that assumed temperate seasons would put a sowing window in the
/// wrong three months.
class Season extends $pb.ProtobufEnum {
  static const Season SEASON_UNSPECIFIED =
      Season._(0, _omitEnumNames ? '' : 'SEASON_UNSPECIFIED');

  /// Monsoon-sown, June–October.
  static const Season SEASON_KHARIF =
      Season._(1, _omitEnumNames ? '' : 'SEASON_KHARIF');

  /// Winter, October–March, on residual moisture or irrigation.
  static const Season SEASON_RABI =
      Season._(2, _omitEnumNames ? '' : 'SEASON_RABI');

  /// Short summer crop between rabi and kharif, needs irrigation.
  static const Season SEASON_ZAID =
      Season._(3, _omitEnumNames ? '' : 'SEASON_ZAID');

  static const $core.List<Season> values = <Season>[
    SEASON_UNSPECIFIED,
    SEASON_KHARIF,
    SEASON_RABI,
    SEASON_ZAID,
  ];

  static final $core.List<Season?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Season? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Season._(super.value, super.name);
}

/// PlanStatus is where a season plan has got to.
class PlanStatus extends $pb.ProtobufEnum {
  static const PlanStatus PLAN_STATUS_UNSPECIFIED =
      PlanStatus._(0, _omitEnumNames ? '' : 'PLAN_STATUS_UNSPECIFIED');
  static const PlanStatus PLAN_STATUS_DRAFT =
      PlanStatus._(1, _omitEnumNames ? '' : 'PLAN_STATUS_DRAFT');
  static const PlanStatus PLAN_STATUS_COMMITTED =
      PlanStatus._(2, _omitEnumNames ? '' : 'PLAN_STATUS_COMMITTED');
  static const PlanStatus PLAN_STATUS_COMPLETED =
      PlanStatus._(3, _omitEnumNames ? '' : 'PLAN_STATUS_COMPLETED');
  static const PlanStatus PLAN_STATUS_ABANDONED =
      PlanStatus._(4, _omitEnumNames ? '' : 'PLAN_STATUS_ABANDONED');

  static const $core.List<PlanStatus> values = <PlanStatus>[
    PLAN_STATUS_UNSPECIFIED,
    PLAN_STATUS_DRAFT,
    PLAN_STATUS_COMMITTED,
    PLAN_STATUS_COMPLETED,
    PLAN_STATUS_ABANDONED,
  ];

  static final $core.List<PlanStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static PlanStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PlanStatus._(super.value, super.name);
}

/// RotationVerdict is what the rotation check makes of a proposed crop.
class RotationVerdict extends $pb.ProtobufEnum {
  static const RotationVerdict ROTATION_VERDICT_UNSPECIFIED = RotationVerdict._(
      0, _omitEnumNames ? '' : 'ROTATION_VERDICT_UNSPECIFIED');
  static const RotationVerdict ROTATION_VERDICT_GOOD =
      RotationVerdict._(1, _omitEnumNames ? '' : 'ROTATION_VERDICT_GOOD');

  /// Allowed, but it gives up something — usually the nitrogen a legume would
  /// have fixed.
  static const RotationVerdict ROTATION_VERDICT_ACCEPTABLE =
      RotationVerdict._(2, _omitEnumNames ? '' : 'ROTATION_VERDICT_ACCEPTABLE');

  /// A real agronomic problem: the same family back-to-back builds up the
  /// pathogens that live in the soil between seasons.
  static const RotationVerdict ROTATION_VERDICT_POOR =
      RotationVerdict._(3, _omitEnumNames ? '' : 'ROTATION_VERDICT_POOR');

  static const $core.List<RotationVerdict> values = <RotationVerdict>[
    ROTATION_VERDICT_UNSPECIFIED,
    ROTATION_VERDICT_GOOD,
    ROTATION_VERDICT_ACCEPTABLE,
    ROTATION_VERDICT_POOR,
  ];

  static final $core.List<RotationVerdict?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static RotationVerdict? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const RotationVerdict._(super.value, super.name);
}

/// InputKind is a purchased input a plan budgets for.
class InputKind extends $pb.ProtobufEnum {
  static const InputKind INPUT_KIND_UNSPECIFIED =
      InputKind._(0, _omitEnumNames ? '' : 'INPUT_KIND_UNSPECIFIED');
  static const InputKind INPUT_KIND_SEED =
      InputKind._(1, _omitEnumNames ? '' : 'INPUT_KIND_SEED');
  static const InputKind INPUT_KIND_FERTILISER =
      InputKind._(2, _omitEnumNames ? '' : 'INPUT_KIND_FERTILISER');
  static const InputKind INPUT_KIND_PESTICIDE =
      InputKind._(3, _omitEnumNames ? '' : 'INPUT_KIND_PESTICIDE');
  static const InputKind INPUT_KIND_LABOUR =
      InputKind._(4, _omitEnumNames ? '' : 'INPUT_KIND_LABOUR');
  static const InputKind INPUT_KIND_MACHINERY =
      InputKind._(5, _omitEnumNames ? '' : 'INPUT_KIND_MACHINERY');
  static const InputKind INPUT_KIND_IRRIGATION =
      InputKind._(6, _omitEnumNames ? '' : 'INPUT_KIND_IRRIGATION');

  static const $core.List<InputKind> values = <InputKind>[
    INPUT_KIND_UNSPECIFIED,
    INPUT_KIND_SEED,
    INPUT_KIND_FERTILISER,
    INPUT_KIND_PESTICIDE,
    INPUT_KIND_LABOUR,
    INPUT_KIND_MACHINERY,
    INPUT_KIND_IRRIGATION,
  ];

  static final $core.List<InputKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static InputKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const InputKind._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
