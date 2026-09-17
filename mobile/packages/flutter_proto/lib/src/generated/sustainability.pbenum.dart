// This is a generated file - do not edit.
//
// Generated from sustainability.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// InputCategory is what was applied to the field, grouped by how it emits.
///
/// The grouping is by emission pathway rather than by what a shop sells, because
/// that is what decides the arithmetic: urea emits CO2 as it hydrolyses *and*
/// N2O as nitrogen, while ammonium sulphate only does the second.
class InputCategory extends $pb.ProtobufEnum {
  static const InputCategory INPUT_CATEGORY_UNSPECIFIED =
      InputCategory._(0, _omitEnumNames ? '' : 'INPUT_CATEGORY_UNSPECIFIED');

  /// Synthetic nitrogen other than urea.
  static const InputCategory INPUT_CATEGORY_SYNTHETIC_N =
      InputCategory._(1, _omitEnumNames ? '' : 'INPUT_CATEGORY_SYNTHETIC_N');

  /// Urea specifically: it releases the CO2 that was fixed into it during
  /// manufacture, on top of the N2O every nitrogen source causes.
  static const InputCategory INPUT_CATEGORY_UREA =
      InputCategory._(2, _omitEnumNames ? '' : 'INPUT_CATEGORY_UREA');

  /// Phosphate and potash, which carry manufacturing emissions but no field
  /// emissions worth counting.
  static const InputCategory INPUT_CATEGORY_PHOSPHATE =
      InputCategory._(3, _omitEnumNames ? '' : 'INPUT_CATEGORY_PHOSPHATE');
  static const InputCategory INPUT_CATEGORY_POTASH =
      InputCategory._(4, _omitEnumNames ? '' : 'INPUT_CATEGORY_POTASH');

  /// Manure and compost: nitrogen, and a soil carbon input.
  static const InputCategory INPUT_CATEGORY_ORGANIC_N =
      InputCategory._(5, _omitEnumNames ? '' : 'INPUT_CATEGORY_ORGANIC_N');

  /// Agricultural lime, which releases CO2 as it reacts with soil acid.
  static const InputCategory INPUT_CATEGORY_LIME =
      InputCategory._(6, _omitEnumNames ? '' : 'INPUT_CATEGORY_LIME');
  static const InputCategory INPUT_CATEGORY_PESTICIDE =
      InputCategory._(7, _omitEnumNames ? '' : 'INPUT_CATEGORY_PESTICIDE');
  static const InputCategory INPUT_CATEGORY_SEED =
      InputCategory._(8, _omitEnumNames ? '' : 'INPUT_CATEGORY_SEED');

  /// Diesel burned by tractors, harvesters and pump sets.
  static const InputCategory INPUT_CATEGORY_DIESEL =
      InputCategory._(9, _omitEnumNames ? '' : 'INPUT_CATEGORY_DIESEL');

  /// Grid electricity, almost always for irrigation pumping.
  static const InputCategory INPUT_CATEGORY_ELECTRICITY =
      InputCategory._(10, _omitEnumNames ? '' : 'INPUT_CATEGORY_ELECTRICITY');

  /// Crop residue burned in the field.
  static const InputCategory INPUT_CATEGORY_RESIDUE_BURN =
      InputCategory._(11, _omitEnumNames ? '' : 'INPUT_CATEGORY_RESIDUE_BURN');

  static const $core.List<InputCategory> values = <InputCategory>[
    INPUT_CATEGORY_UNSPECIFIED,
    INPUT_CATEGORY_SYNTHETIC_N,
    INPUT_CATEGORY_UREA,
    INPUT_CATEGORY_PHOSPHATE,
    INPUT_CATEGORY_POTASH,
    INPUT_CATEGORY_ORGANIC_N,
    INPUT_CATEGORY_LIME,
    INPUT_CATEGORY_PESTICIDE,
    INPUT_CATEGORY_SEED,
    INPUT_CATEGORY_DIESEL,
    INPUT_CATEGORY_ELECTRICITY,
    INPUT_CATEGORY_RESIDUE_BURN,
  ];

  static final $core.List<InputCategory?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 11);
  static InputCategory? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const InputCategory._(super.value, super.name);
}

/// WaterRegime is how a paddy was watered, which is what decides its methane.
///
/// A continuously flooded paddy emits roughly twice the methane of one that is
/// drained mid-season, and that difference is usually the single largest number
/// in a rice field's footprint. Reporting rice without it is not an estimate,
/// it is a guess with a decimal point.
class WaterRegime extends $pb.ProtobufEnum {
  static const WaterRegime WATER_REGIME_UNSPECIFIED =
      WaterRegime._(0, _omitEnumNames ? '' : 'WATER_REGIME_UNSPECIFIED');
  static const WaterRegime WATER_REGIME_CONTINUOUS_FLOOD =
      WaterRegime._(1, _omitEnumNames ? '' : 'WATER_REGIME_CONTINUOUS_FLOOD');
  static const WaterRegime WATER_REGIME_SINGLE_DRAINAGE =
      WaterRegime._(2, _omitEnumNames ? '' : 'WATER_REGIME_SINGLE_DRAINAGE');
  static const WaterRegime WATER_REGIME_MULTIPLE_DRAINAGE =
      WaterRegime._(3, _omitEnumNames ? '' : 'WATER_REGIME_MULTIPLE_DRAINAGE');

  /// Alternate wetting and drying, the deliberate water-saving practice.
  static const WaterRegime WATER_REGIME_AWD =
      WaterRegime._(4, _omitEnumNames ? '' : 'WATER_REGIME_AWD');
  static const WaterRegime WATER_REGIME_RAINFED =
      WaterRegime._(5, _omitEnumNames ? '' : 'WATER_REGIME_RAINFED');

  /// Not a paddy at all.
  static const WaterRegime WATER_REGIME_UPLAND =
      WaterRegime._(6, _omitEnumNames ? '' : 'WATER_REGIME_UPLAND');

  static const $core.List<WaterRegime> values = <WaterRegime>[
    WATER_REGIME_UNSPECIFIED,
    WATER_REGIME_CONTINUOUS_FLOOD,
    WATER_REGIME_SINGLE_DRAINAGE,
    WATER_REGIME_MULTIPLE_DRAINAGE,
    WATER_REGIME_AWD,
    WATER_REGIME_RAINFED,
    WATER_REGIME_UPLAND,
  ];

  static final $core.List<WaterRegime?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static WaterRegime? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const WaterRegime._(super.value, super.name);
}

/// EmissionSource is one line of a footprint.
class EmissionSource extends $pb.ProtobufEnum {
  static const EmissionSource EMISSION_SOURCE_UNSPECIFIED =
      EmissionSource._(0, _omitEnumNames ? '' : 'EMISSION_SOURCE_UNSPECIFIED');

  /// N2O released in the field from applied nitrogen.
  static const EmissionSource EMISSION_SOURCE_DIRECT_N2O =
      EmissionSource._(1, _omitEnumNames ? '' : 'EMISSION_SOURCE_DIRECT_N2O');

  /// N2O from that nitrogen after it volatilises or leaches away.
  static const EmissionSource EMISSION_SOURCE_INDIRECT_N2O =
      EmissionSource._(2, _omitEnumNames ? '' : 'EMISSION_SOURCE_INDIRECT_N2O');

  /// CO2 from urea hydrolysis and from lime.
  static const EmissionSource EMISSION_SOURCE_UREA_CO2 =
      EmissionSource._(3, _omitEnumNames ? '' : 'EMISSION_SOURCE_UREA_CO2');
  static const EmissionSource EMISSION_SOURCE_LIME_CO2 =
      EmissionSource._(4, _omitEnumNames ? '' : 'EMISSION_SOURCE_LIME_CO2');

  /// CH4 from flooded rice.
  static const EmissionSource EMISSION_SOURCE_RICE_CH4 =
      EmissionSource._(5, _omitEnumNames ? '' : 'EMISSION_SOURCE_RICE_CH4');

  /// Fuel and electricity burned on the farm.
  static const EmissionSource EMISSION_SOURCE_ENERGY =
      EmissionSource._(6, _omitEnumNames ? '' : 'EMISSION_SOURCE_ENERGY');

  /// CH4 and N2O from burning crop residue in the field.
  static const EmissionSource EMISSION_SOURCE_RESIDUE_BURN =
      EmissionSource._(7, _omitEnumNames ? '' : 'EMISSION_SOURCE_RESIDUE_BURN');

  /// Manufacturing and transport of the inputs, which happen off the farm but
  /// happen because of it.
  static const EmissionSource EMISSION_SOURCE_UPSTREAM =
      EmissionSource._(8, _omitEnumNames ? '' : 'EMISSION_SOURCE_UPSTREAM');

  static const $core.List<EmissionSource> values = <EmissionSource>[
    EMISSION_SOURCE_UNSPECIFIED,
    EMISSION_SOURCE_DIRECT_N2O,
    EMISSION_SOURCE_INDIRECT_N2O,
    EMISSION_SOURCE_UREA_CO2,
    EMISSION_SOURCE_LIME_CO2,
    EMISSION_SOURCE_RICE_CH4,
    EMISSION_SOURCE_ENERGY,
    EMISSION_SOURCE_RESIDUE_BURN,
    EMISSION_SOURCE_UPSTREAM,
  ];

  static final $core.List<EmissionSource?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static EmissionSource? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EmissionSource._(super.value, super.name);
}

/// Completeness is how much of a category's activity data was actually recorded.
///
/// The distinction this enum exists for: a field with no diesel record has an
/// unknown fuel footprint, not a zero one. A carbon report that silently treats
/// an absent record as nothing produces a flattering number that nobody can
/// defend to an auditor.
class Completeness extends $pb.ProtobufEnum {
  static const Completeness COMPLETENESS_UNSPECIFIED =
      Completeness._(0, _omitEnumNames ? '' : 'COMPLETENESS_UNSPECIFIED');

  /// Activity data was recorded for this source.
  static const Completeness COMPLETENESS_RECORDED =
      Completeness._(1, _omitEnumNames ? '' : 'COMPLETENESS_RECORDED');

  /// Nothing was recorded, and the source is reported as unknown rather than
  /// as zero.
  static const Completeness COMPLETENESS_MISSING =
      Completeness._(2, _omitEnumNames ? '' : 'COMPLETENESS_MISSING');

  /// Nothing was recorded and nothing is expected — an upland field has no
  /// paddy methane.
  static const Completeness COMPLETENESS_NOT_APPLICABLE =
      Completeness._(3, _omitEnumNames ? '' : 'COMPLETENESS_NOT_APPLICABLE');

  static const $core.List<Completeness> values = <Completeness>[
    COMPLETENESS_UNSPECIFIED,
    COMPLETENESS_RECORDED,
    COMPLETENESS_MISSING,
    COMPLETENESS_NOT_APPLICABLE,
  ];

  static final $core.List<Completeness?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Completeness? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Completeness._(super.value, super.name);
}

/// CertificationStandard is the scheme a claim is made against.
class CertificationStandard extends $pb.ProtobufEnum {
  static const CertificationStandard CERTIFICATION_STANDARD_UNSPECIFIED =
      CertificationStandard._(
          0, _omitEnumNames ? '' : 'CERTIFICATION_STANDARD_UNSPECIFIED');

  /// India's National Programme for Organic Production.
  static const CertificationStandard CERTIFICATION_STANDARD_NPOP =
      CertificationStandard._(
          1, _omitEnumNames ? '' : 'CERTIFICATION_STANDARD_NPOP');
  static const CertificationStandard CERTIFICATION_STANDARD_GLOBALGAP =
      CertificationStandard._(
          2, _omitEnumNames ? '' : 'CERTIFICATION_STANDARD_GLOBALGAP');
  static const CertificationStandard CERTIFICATION_STANDARD_FAIRTRADE =
      CertificationStandard._(
          3, _omitEnumNames ? '' : 'CERTIFICATION_STANDARD_FAIRTRADE');
  static const CertificationStandard CERTIFICATION_STANDARD_RAINFOREST =
      CertificationStandard._(
          4, _omitEnumNames ? '' : 'CERTIFICATION_STANDARD_RAINFOREST');

  static const $core.List<CertificationStandard> values =
      <CertificationStandard>[
    CERTIFICATION_STANDARD_UNSPECIFIED,
    CERTIFICATION_STANDARD_NPOP,
    CERTIFICATION_STANDARD_GLOBALGAP,
    CERTIFICATION_STANDARD_FAIRTRADE,
    CERTIFICATION_STANDARD_RAINFOREST,
  ];

  static final $core.List<CertificationStandard?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static CertificationStandard? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CertificationStandard._(super.value, super.name);
}

/// FindingSeverity is how much a certification finding matters.
class FindingSeverity extends $pb.ProtobufEnum {
  static const FindingSeverity FINDING_SEVERITY_UNSPECIFIED = FindingSeverity._(
      0, _omitEnumNames ? '' : 'FINDING_SEVERITY_UNSPECIFIED');

  /// Disqualifying on its own.
  static const FindingSeverity FINDING_SEVERITY_BLOCKER =
      FindingSeverity._(1, _omitEnumNames ? '' : 'FINDING_SEVERITY_BLOCKER');

  /// Has to be resolved with the certifier, but is not automatically fatal.
  static const FindingSeverity FINDING_SEVERITY_MAJOR =
      FindingSeverity._(2, _omitEnumNames ? '' : 'FINDING_SEVERITY_MAJOR');
  static const FindingSeverity FINDING_SEVERITY_MINOR =
      FindingSeverity._(3, _omitEnumNames ? '' : 'FINDING_SEVERITY_MINOR');

  static const $core.List<FindingSeverity> values = <FindingSeverity>[
    FINDING_SEVERITY_UNSPECIFIED,
    FINDING_SEVERITY_BLOCKER,
    FINDING_SEVERITY_MAJOR,
    FINDING_SEVERITY_MINOR,
  ];

  static final $core.List<FindingSeverity?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static FindingSeverity? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const FindingSeverity._(super.value, super.name);
}

/// CertificationStatus is where a claim has got to.
class CertificationStatus extends $pb.ProtobufEnum {
  static const CertificationStatus CERTIFICATION_STATUS_UNSPECIFIED =
      CertificationStatus._(
          0, _omitEnumNames ? '' : 'CERTIFICATION_STATUS_UNSPECIFIED');

  /// Inside the conversion period; not yet certifiable.
  static const CertificationStatus CERTIFICATION_STATUS_IN_CONVERSION =
      CertificationStatus._(
          1, _omitEnumNames ? '' : 'CERTIFICATION_STATUS_IN_CONVERSION');

  /// Would pass on the records held.
  static const CertificationStatus CERTIFICATION_STATUS_ELIGIBLE =
      CertificationStatus._(
          2, _omitEnumNames ? '' : 'CERTIFICATION_STATUS_ELIGIBLE');

  /// Would not pass; see the findings.
  static const CertificationStatus CERTIFICATION_STATUS_BLOCKED =
      CertificationStatus._(
          3, _omitEnumNames ? '' : 'CERTIFICATION_STATUS_BLOCKED');

  /// Cannot be judged because the record is incomplete.
  static const CertificationStatus CERTIFICATION_STATUS_INSUFFICIENT_RECORDS =
      CertificationStatus._(
          4, _omitEnumNames ? '' : 'CERTIFICATION_STATUS_INSUFFICIENT_RECORDS');

  static const $core.List<CertificationStatus> values = <CertificationStatus>[
    CERTIFICATION_STATUS_UNSPECIFIED,
    CERTIFICATION_STATUS_IN_CONVERSION,
    CERTIFICATION_STATUS_ELIGIBLE,
    CERTIFICATION_STATUS_BLOCKED,
    CERTIFICATION_STATUS_INSUFFICIENT_RECORDS,
  ];

  static final $core.List<CertificationStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static CertificationStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CertificationStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
