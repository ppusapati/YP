// This is a generated file - do not edit.
//
// Generated from vegetation_index.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class VegetationIndexType extends $pb.ProtobufEnum {
  static const VegetationIndexType VEGETATION_INDEX_TYPE_UNSPECIFIED =
      VegetationIndexType._(
          0, _omitEnumNames ? '' : 'VEGETATION_INDEX_TYPE_UNSPECIFIED');
  static const VegetationIndexType VEGETATION_INDEX_TYPE_NDVI =
      VegetationIndexType._(
          1, _omitEnumNames ? '' : 'VEGETATION_INDEX_TYPE_NDVI');
  static const VegetationIndexType VEGETATION_INDEX_TYPE_NDWI =
      VegetationIndexType._(
          2, _omitEnumNames ? '' : 'VEGETATION_INDEX_TYPE_NDWI');
  static const VegetationIndexType VEGETATION_INDEX_TYPE_EVI =
      VegetationIndexType._(
          3, _omitEnumNames ? '' : 'VEGETATION_INDEX_TYPE_EVI');
  static const VegetationIndexType VEGETATION_INDEX_TYPE_SAVI =
      VegetationIndexType._(
          4, _omitEnumNames ? '' : 'VEGETATION_INDEX_TYPE_SAVI');
  static const VegetationIndexType VEGETATION_INDEX_TYPE_MSAVI =
      VegetationIndexType._(
          5, _omitEnumNames ? '' : 'VEGETATION_INDEX_TYPE_MSAVI');
  static const VegetationIndexType VEGETATION_INDEX_TYPE_NDRE =
      VegetationIndexType._(
          6, _omitEnumNames ? '' : 'VEGETATION_INDEX_TYPE_NDRE');
  static const VegetationIndexType VEGETATION_INDEX_TYPE_GNDVI =
      VegetationIndexType._(
          7, _omitEnumNames ? '' : 'VEGETATION_INDEX_TYPE_GNDVI');
  static const VegetationIndexType VEGETATION_INDEX_TYPE_LAI =
      VegetationIndexType._(
          8, _omitEnumNames ? '' : 'VEGETATION_INDEX_TYPE_LAI');

  static const $core.List<VegetationIndexType> values = <VegetationIndexType>[
    VEGETATION_INDEX_TYPE_UNSPECIFIED,
    VEGETATION_INDEX_TYPE_NDVI,
    VEGETATION_INDEX_TYPE_NDWI,
    VEGETATION_INDEX_TYPE_EVI,
    VEGETATION_INDEX_TYPE_SAVI,
    VEGETATION_INDEX_TYPE_MSAVI,
    VEGETATION_INDEX_TYPE_NDRE,
    VEGETATION_INDEX_TYPE_GNDVI,
    VEGETATION_INDEX_TYPE_LAI,
  ];

  static final $core.List<VegetationIndexType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static VegetationIndexType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const VegetationIndexType._(super.value, super.name);
}

class ComputeStatus extends $pb.ProtobufEnum {
  static const ComputeStatus COMPUTE_STATUS_UNSPECIFIED =
      ComputeStatus._(0, _omitEnumNames ? '' : 'COMPUTE_STATUS_UNSPECIFIED');
  static const ComputeStatus COMPUTE_STATUS_QUEUED =
      ComputeStatus._(1, _omitEnumNames ? '' : 'COMPUTE_STATUS_QUEUED');
  static const ComputeStatus COMPUTE_STATUS_COMPUTING =
      ComputeStatus._(2, _omitEnumNames ? '' : 'COMPUTE_STATUS_COMPUTING');
  static const ComputeStatus COMPUTE_STATUS_INTERSECTING =
      ComputeStatus._(3, _omitEnumNames ? '' : 'COMPUTE_STATUS_INTERSECTING');
  static const ComputeStatus COMPUTE_STATUS_COMPLETED =
      ComputeStatus._(4, _omitEnumNames ? '' : 'COMPUTE_STATUS_COMPLETED');
  static const ComputeStatus COMPUTE_STATUS_FAILED =
      ComputeStatus._(5, _omitEnumNames ? '' : 'COMPUTE_STATUS_FAILED');

  static const $core.List<ComputeStatus> values = <ComputeStatus>[
    COMPUTE_STATUS_UNSPECIFIED,
    COMPUTE_STATUS_QUEUED,
    COMPUTE_STATUS_COMPUTING,
    COMPUTE_STATUS_INTERSECTING,
    COMPUTE_STATUS_COMPLETED,
    COMPUTE_STATUS_FAILED,
  ];

  static final $core.List<ComputeStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static ComputeStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ComputeStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
