// This is a generated file - do not edit.
//
// Generated from crop.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// CropCategory represents the classification of a crop.
class CropCategory extends $pb.ProtobufEnum {
  static const CropCategory CROP_CATEGORY_UNSPECIFIED =
      CropCategory._(0, _omitEnumNames ? '' : 'CROP_CATEGORY_UNSPECIFIED');
  static const CropCategory CROP_CATEGORY_CEREAL =
      CropCategory._(1, _omitEnumNames ? '' : 'CROP_CATEGORY_CEREAL');
  static const CropCategory CROP_CATEGORY_LEGUME =
      CropCategory._(2, _omitEnumNames ? '' : 'CROP_CATEGORY_LEGUME');
  static const CropCategory CROP_CATEGORY_VEGETABLE =
      CropCategory._(3, _omitEnumNames ? '' : 'CROP_CATEGORY_VEGETABLE');
  static const CropCategory CROP_CATEGORY_FRUIT =
      CropCategory._(4, _omitEnumNames ? '' : 'CROP_CATEGORY_FRUIT');
  static const CropCategory CROP_CATEGORY_OILSEED =
      CropCategory._(5, _omitEnumNames ? '' : 'CROP_CATEGORY_OILSEED');
  static const CropCategory CROP_CATEGORY_FIBER =
      CropCategory._(6, _omitEnumNames ? '' : 'CROP_CATEGORY_FIBER');
  static const CropCategory CROP_CATEGORY_SPICE =
      CropCategory._(7, _omitEnumNames ? '' : 'CROP_CATEGORY_SPICE');

  static const $core.List<CropCategory> values = <CropCategory>[
    CROP_CATEGORY_UNSPECIFIED,
    CROP_CATEGORY_CEREAL,
    CROP_CATEGORY_LEGUME,
    CROP_CATEGORY_VEGETABLE,
    CROP_CATEGORY_FRUIT,
    CROP_CATEGORY_OILSEED,
    CROP_CATEGORY_FIBER,
    CROP_CATEGORY_SPICE,
  ];

  static final $core.List<CropCategory?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 7);
  static CropCategory? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CropCategory._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
