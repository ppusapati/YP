// This is a generated file - do not edit.
//
// Generated from ingestion.proto.

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
  static const SatelliteProvider SATELLITE_PROVIDER_LANDSAT =
      SatelliteProvider._(
          2, _omitEnumNames ? '' : 'SATELLITE_PROVIDER_LANDSAT');
  static const SatelliteProvider SATELLITE_PROVIDER_PLANETSCOPE =
      SatelliteProvider._(
          3, _omitEnumNames ? '' : 'SATELLITE_PROVIDER_PLANETSCOPE');

  static const $core.List<SatelliteProvider> values = <SatelliteProvider>[
    SATELLITE_PROVIDER_UNSPECIFIED,
    SATELLITE_PROVIDER_SENTINEL2,
    SATELLITE_PROVIDER_LANDSAT,
    SATELLITE_PROVIDER_PLANETSCOPE,
  ];

  static final $core.List<SatelliteProvider?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static SatelliteProvider? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SatelliteProvider._(super.value, super.name);
}

class IngestionStatus extends $pb.ProtobufEnum {
  static const IngestionStatus INGESTION_STATUS_UNSPECIFIED = IngestionStatus._(
      0, _omitEnumNames ? '' : 'INGESTION_STATUS_UNSPECIFIED');
  static const IngestionStatus INGESTION_STATUS_QUEUED =
      IngestionStatus._(1, _omitEnumNames ? '' : 'INGESTION_STATUS_QUEUED');
  static const IngestionStatus INGESTION_STATUS_DOWNLOADING = IngestionStatus._(
      2, _omitEnumNames ? '' : 'INGESTION_STATUS_DOWNLOADING');
  static const IngestionStatus INGESTION_STATUS_VALIDATING =
      IngestionStatus._(3, _omitEnumNames ? '' : 'INGESTION_STATUS_VALIDATING');
  static const IngestionStatus INGESTION_STATUS_STORED =
      IngestionStatus._(4, _omitEnumNames ? '' : 'INGESTION_STATUS_STORED');
  static const IngestionStatus INGESTION_STATUS_FAILED =
      IngestionStatus._(5, _omitEnumNames ? '' : 'INGESTION_STATUS_FAILED');

  static const $core.List<IngestionStatus> values = <IngestionStatus>[
    INGESTION_STATUS_UNSPECIFIED,
    INGESTION_STATUS_QUEUED,
    INGESTION_STATUS_DOWNLOADING,
    INGESTION_STATUS_VALIDATING,
    INGESTION_STATUS_STORED,
    INGESTION_STATUS_FAILED,
  ];

  static final $core.List<IngestionStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static IngestionStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const IngestionStatus._(super.value, super.name);
}

class SpectralBand extends $pb.ProtobufEnum {
  static const SpectralBand SPECTRAL_BAND_UNSPECIFIED =
      SpectralBand._(0, _omitEnumNames ? '' : 'SPECTRAL_BAND_UNSPECIFIED');
  static const SpectralBand SPECTRAL_BAND_BLUE =
      SpectralBand._(1, _omitEnumNames ? '' : 'SPECTRAL_BAND_BLUE');
  static const SpectralBand SPECTRAL_BAND_GREEN =
      SpectralBand._(2, _omitEnumNames ? '' : 'SPECTRAL_BAND_GREEN');
  static const SpectralBand SPECTRAL_BAND_RED =
      SpectralBand._(3, _omitEnumNames ? '' : 'SPECTRAL_BAND_RED');
  static const SpectralBand SPECTRAL_BAND_NIR =
      SpectralBand._(4, _omitEnumNames ? '' : 'SPECTRAL_BAND_NIR');
  static const SpectralBand SPECTRAL_BAND_SWIR1 =
      SpectralBand._(5, _omitEnumNames ? '' : 'SPECTRAL_BAND_SWIR1');
  static const SpectralBand SPECTRAL_BAND_SWIR2 =
      SpectralBand._(6, _omitEnumNames ? '' : 'SPECTRAL_BAND_SWIR2');
  static const SpectralBand SPECTRAL_BAND_RED_EDGE1 =
      SpectralBand._(7, _omitEnumNames ? '' : 'SPECTRAL_BAND_RED_EDGE1');
  static const SpectralBand SPECTRAL_BAND_RED_EDGE2 =
      SpectralBand._(8, _omitEnumNames ? '' : 'SPECTRAL_BAND_RED_EDGE2');
  static const SpectralBand SPECTRAL_BAND_RED_EDGE3 =
      SpectralBand._(9, _omitEnumNames ? '' : 'SPECTRAL_BAND_RED_EDGE3');

  static const $core.List<SpectralBand> values = <SpectralBand>[
    SPECTRAL_BAND_UNSPECIFIED,
    SPECTRAL_BAND_BLUE,
    SPECTRAL_BAND_GREEN,
    SPECTRAL_BAND_RED,
    SPECTRAL_BAND_NIR,
    SPECTRAL_BAND_SWIR1,
    SPECTRAL_BAND_SWIR2,
    SPECTRAL_BAND_RED_EDGE1,
    SPECTRAL_BAND_RED_EDGE2,
    SPECTRAL_BAND_RED_EDGE3,
  ];

  static final $core.List<SpectralBand?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 9);
  static SpectralBand? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SpectralBand._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
