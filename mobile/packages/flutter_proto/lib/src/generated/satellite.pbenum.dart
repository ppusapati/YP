// This is a generated file - do not edit.
//
// Generated from satellite.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class SatelliteProvider extends $pb.ProtobufEnum {
  static const SatelliteProvider SATELLITE_PROVIDER_UNSPECIFIED =
      SatelliteProvider._(
          0, _omitEnumNames ? '' : 'SATELLITE_PROVIDER_UNSPECIFIED');
  static const SatelliteProvider SATELLITE_PROVIDER_SENTINEL2 =
      SatelliteProvider._(
          1, _omitEnumNames ? '' : 'SATELLITE_PROVIDER_SENTINEL2');
  static const SatelliteProvider SATELLITE_PROVIDER_LANDSAT8 =
      SatelliteProvider._(
          2, _omitEnumNames ? '' : 'SATELLITE_PROVIDER_LANDSAT8');
  static const SatelliteProvider SATELLITE_PROVIDER_PLANET =
      SatelliteProvider._(3, _omitEnumNames ? '' : 'SATELLITE_PROVIDER_PLANET');
  static const SatelliteProvider SATELLITE_PROVIDER_CUSTOM =
      SatelliteProvider._(4, _omitEnumNames ? '' : 'SATELLITE_PROVIDER_CUSTOM');

  static const $core.List<SatelliteProvider> values = <SatelliteProvider>[
    SATELLITE_PROVIDER_UNSPECIFIED,
    SATELLITE_PROVIDER_SENTINEL2,
    SATELLITE_PROVIDER_LANDSAT8,
    SATELLITE_PROVIDER_PLANET,
    SATELLITE_PROVIDER_CUSTOM,
  ];

  static final $core.List<SatelliteProvider?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static SatelliteProvider? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SatelliteProvider._(super.value, super.name);
}

class SpectralBand extends $pb.ProtobufEnum {
  static const SpectralBand SPECTRAL_BAND_UNSPECIFIED =
      SpectralBand._(0, _omitEnumNames ? '' : 'SPECTRAL_BAND_UNSPECIFIED');
  static const SpectralBand SPECTRAL_BAND_RED =
      SpectralBand._(1, _omitEnumNames ? '' : 'SPECTRAL_BAND_RED');
  static const SpectralBand SPECTRAL_BAND_GREEN =
      SpectralBand._(2, _omitEnumNames ? '' : 'SPECTRAL_BAND_GREEN');
  static const SpectralBand SPECTRAL_BAND_BLUE =
      SpectralBand._(3, _omitEnumNames ? '' : 'SPECTRAL_BAND_BLUE');
  static const SpectralBand SPECTRAL_BAND_NIR =
      SpectralBand._(4, _omitEnumNames ? '' : 'SPECTRAL_BAND_NIR');
  static const SpectralBand SPECTRAL_BAND_SWIR =
      SpectralBand._(5, _omitEnumNames ? '' : 'SPECTRAL_BAND_SWIR');
  static const SpectralBand SPECTRAL_BAND_REDEDGE =
      SpectralBand._(6, _omitEnumNames ? '' : 'SPECTRAL_BAND_REDEDGE');

  static const $core.List<SpectralBand> values = <SpectralBand>[
    SPECTRAL_BAND_UNSPECIFIED,
    SPECTRAL_BAND_RED,
    SPECTRAL_BAND_GREEN,
    SPECTRAL_BAND_BLUE,
    SPECTRAL_BAND_NIR,
    SPECTRAL_BAND_SWIR,
    SPECTRAL_BAND_REDEDGE,
  ];

  static final $core.List<SpectralBand?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static SpectralBand? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SpectralBand._(super.value, super.name);
}

class ProcessingStatus extends $pb.ProtobufEnum {
  static const ProcessingStatus PROCESSING_STATUS_UNSPECIFIED =
      ProcessingStatus._(
          0, _omitEnumNames ? '' : 'PROCESSING_STATUS_UNSPECIFIED');
  static const ProcessingStatus PROCESSING_STATUS_PENDING =
      ProcessingStatus._(1, _omitEnumNames ? '' : 'PROCESSING_STATUS_PENDING');
  static const ProcessingStatus PROCESSING_STATUS_PROCESSING =
      ProcessingStatus._(
          2, _omitEnumNames ? '' : 'PROCESSING_STATUS_PROCESSING');
  static const ProcessingStatus PROCESSING_STATUS_COMPLETED =
      ProcessingStatus._(
          3, _omitEnumNames ? '' : 'PROCESSING_STATUS_COMPLETED');
  static const ProcessingStatus PROCESSING_STATUS_FAILED =
      ProcessingStatus._(4, _omitEnumNames ? '' : 'PROCESSING_STATUS_FAILED');

  static const $core.List<ProcessingStatus> values = <ProcessingStatus>[
    PROCESSING_STATUS_UNSPECIFIED,
    PROCESSING_STATUS_PENDING,
    PROCESSING_STATUS_PROCESSING,
    PROCESSING_STATUS_COMPLETED,
    PROCESSING_STATUS_FAILED,
  ];

  static final $core.List<ProcessingStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static ProcessingStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ProcessingStatus._(super.value, super.name);
}

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

  static const $core.List<StressType> values = <StressType>[
    STRESS_TYPE_UNSPECIFIED,
    STRESS_TYPE_WATER,
    STRESS_TYPE_NUTRIENT,
    STRESS_TYPE_DISEASE,
    STRESS_TYPE_PEST,
  ];

  static final $core.List<StressType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static StressType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const StressType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
