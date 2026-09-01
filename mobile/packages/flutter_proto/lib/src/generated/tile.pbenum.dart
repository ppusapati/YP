// This is a generated file - do not edit.
//
// Generated from tile.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class TileFormat extends $pb.ProtobufEnum {
  static const TileFormat TILE_FORMAT_UNSPECIFIED =
      TileFormat._(0, _omitEnumNames ? '' : 'TILE_FORMAT_UNSPECIFIED');
  static const TileFormat TILE_FORMAT_PNG =
      TileFormat._(1, _omitEnumNames ? '' : 'TILE_FORMAT_PNG');
  static const TileFormat TILE_FORMAT_JPEG =
      TileFormat._(2, _omitEnumNames ? '' : 'TILE_FORMAT_JPEG');
  static const TileFormat TILE_FORMAT_WEBP =
      TileFormat._(3, _omitEnumNames ? '' : 'TILE_FORMAT_WEBP');
  static const TileFormat TILE_FORMAT_MVT =
      TileFormat._(4, _omitEnumNames ? '' : 'TILE_FORMAT_MVT');

  static const $core.List<TileFormat> values = <TileFormat>[
    TILE_FORMAT_UNSPECIFIED,
    TILE_FORMAT_PNG,
    TILE_FORMAT_JPEG,
    TILE_FORMAT_WEBP,
    TILE_FORMAT_MVT,
  ];

  static final $core.List<TileFormat?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static TileFormat? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TileFormat._(super.value, super.name);
}

class TilesetStatus extends $pb.ProtobufEnum {
  static const TilesetStatus TILESET_STATUS_UNSPECIFIED =
      TilesetStatus._(0, _omitEnumNames ? '' : 'TILESET_STATUS_UNSPECIFIED');
  static const TilesetStatus TILESET_STATUS_QUEUED =
      TilesetStatus._(1, _omitEnumNames ? '' : 'TILESET_STATUS_QUEUED');
  static const TilesetStatus TILESET_STATUS_GENERATING =
      TilesetStatus._(2, _omitEnumNames ? '' : 'TILESET_STATUS_GENERATING');
  static const TilesetStatus TILESET_STATUS_COMPLETED =
      TilesetStatus._(3, _omitEnumNames ? '' : 'TILESET_STATUS_COMPLETED');
  static const TilesetStatus TILESET_STATUS_FAILED =
      TilesetStatus._(4, _omitEnumNames ? '' : 'TILESET_STATUS_FAILED');

  static const $core.List<TilesetStatus> values = <TilesetStatus>[
    TILESET_STATUS_UNSPECIFIED,
    TILESET_STATUS_QUEUED,
    TILESET_STATUS_GENERATING,
    TILESET_STATUS_COMPLETED,
    TILESET_STATUS_FAILED,
  ];

  static final $core.List<TilesetStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static TilesetStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TilesetStatus._(super.value, super.name);
}

class TileLayer extends $pb.ProtobufEnum {
  static const TileLayer TILE_LAYER_UNSPECIFIED =
      TileLayer._(0, _omitEnumNames ? '' : 'TILE_LAYER_UNSPECIFIED');
  static const TileLayer TILE_LAYER_RGB =
      TileLayer._(1, _omitEnumNames ? '' : 'TILE_LAYER_RGB');
  static const TileLayer TILE_LAYER_NDVI =
      TileLayer._(2, _omitEnumNames ? '' : 'TILE_LAYER_NDVI');
  static const TileLayer TILE_LAYER_NDWI =
      TileLayer._(3, _omitEnumNames ? '' : 'TILE_LAYER_NDWI');
  static const TileLayer TILE_LAYER_EVI =
      TileLayer._(4, _omitEnumNames ? '' : 'TILE_LAYER_EVI');
  static const TileLayer TILE_LAYER_STRESS =
      TileLayer._(5, _omitEnumNames ? '' : 'TILE_LAYER_STRESS');
  static const TileLayer TILE_LAYER_FALSE_COLOR =
      TileLayer._(6, _omitEnumNames ? '' : 'TILE_LAYER_FALSE_COLOR');
  static const TileLayer TILE_LAYER_THERMAL =
      TileLayer._(7, _omitEnumNames ? '' : 'TILE_LAYER_THERMAL');

  static const $core.List<TileLayer> values = <TileLayer>[
    TILE_LAYER_UNSPECIFIED,
    TILE_LAYER_RGB,
    TILE_LAYER_NDVI,
    TILE_LAYER_NDWI,
    TILE_LAYER_EVI,
    TILE_LAYER_STRESS,
    TILE_LAYER_FALSE_COLOR,
    TILE_LAYER_THERMAL,
  ];

  static final $core.List<TileLayer?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static TileLayer? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TileLayer._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
