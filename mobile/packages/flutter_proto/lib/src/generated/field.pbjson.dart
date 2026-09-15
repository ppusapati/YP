// This is a generated file - do not edit.
//
// Generated from field.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import 'package:protobuf/well_known_types/google/protobuf/field_mask.pbjson.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pbjson.dart'
    as $0;

@$core.Deprecated('Use fieldStatusDescriptor instead')
const FieldStatus$json = {
  '1': 'FieldStatus',
  '2': [
    {'1': 'FIELD_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'FIELD_STATUS_ACTIVE', '2': 1},
    {'1': 'FIELD_STATUS_FALLOW', '2': 2},
    {'1': 'FIELD_STATUS_PREPARATION', '2': 3},
    {'1': 'FIELD_STATUS_PLANTED', '2': 4},
    {'1': 'FIELD_STATUS_HARVESTING', '2': 5},
    {'1': 'FIELD_STATUS_RETIRED', '2': 6},
  ],
};

/// Descriptor for `FieldStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List fieldStatusDescriptor = $convert.base64Decode(
    'CgtGaWVsZFN0YXR1cxIcChhGSUVMRF9TVEFUVVNfVU5TUEVDSUZJRUQQABIXChNGSUVMRF9TVE'
    'FUVVNfQUNUSVZFEAESFwoTRklFTERfU1RBVFVTX0ZBTExPVxACEhwKGEZJRUxEX1NUQVRVU19Q'
    'UkVQQVJBVElPThADEhgKFEZJRUxEX1NUQVRVU19QTEFOVEVEEAQSGwoXRklFTERfU1RBVFVTX0'
    'hBUlZFU1RJTkcQBRIYChRGSUVMRF9TVEFUVVNfUkVUSVJFRBAG');

@$core.Deprecated('Use fieldTypeDescriptor instead')
const FieldType$json = {
  '1': 'FieldType',
  '2': [
    {'1': 'FIELD_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'FIELD_TYPE_CROPLAND', '2': 1},
    {'1': 'FIELD_TYPE_PASTURE', '2': 2},
    {'1': 'FIELD_TYPE_ORCHARD', '2': 3},
    {'1': 'FIELD_TYPE_VINEYARD', '2': 4},
    {'1': 'FIELD_TYPE_GREENHOUSE', '2': 5},
    {'1': 'FIELD_TYPE_NURSERY', '2': 6},
    {'1': 'FIELD_TYPE_AGROFOREST', '2': 7},
  ],
};

/// Descriptor for `FieldType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List fieldTypeDescriptor = $convert.base64Decode(
    'CglGaWVsZFR5cGUSGgoWRklFTERfVFlQRV9VTlNQRUNJRklFRBAAEhcKE0ZJRUxEX1RZUEVfQ1'
    'JPUExBTkQQARIWChJGSUVMRF9UWVBFX1BBU1RVUkUQAhIWChJGSUVMRF9UWVBFX09SQ0hBUkQQ'
    'AxIXChNGSUVMRF9UWVBFX1ZJTkVZQVJEEAQSGQoVRklFTERfVFlQRV9HUkVFTkhPVVNFEAUSFg'
    'oSRklFTERfVFlQRV9OVVJTRVJZEAYSGQoVRklFTERfVFlQRV9BR1JPRk9SRVNUEAc=');

@$core.Deprecated('Use soilTypeDescriptor instead')
const SoilType$json = {
  '1': 'SoilType',
  '2': [
    {'1': 'SOIL_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SOIL_TYPE_CLAY', '2': 1},
    {'1': 'SOIL_TYPE_SANDY', '2': 2},
    {'1': 'SOIL_TYPE_LOAMY', '2': 3},
    {'1': 'SOIL_TYPE_SILT', '2': 4},
    {'1': 'SOIL_TYPE_PEAT', '2': 5},
    {'1': 'SOIL_TYPE_CHALK', '2': 6},
    {'1': 'SOIL_TYPE_CLAY_LOAM', '2': 7},
    {'1': 'SOIL_TYPE_SANDY_LOAM', '2': 8},
  ],
};

/// Descriptor for `SoilType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List soilTypeDescriptor = $convert.base64Decode(
    'CghTb2lsVHlwZRIZChVTT0lMX1RZUEVfVU5TUEVDSUZJRUQQABISCg5TT0lMX1RZUEVfQ0xBWR'
    'ABEhMKD1NPSUxfVFlQRV9TQU5EWRACEhMKD1NPSUxfVFlQRV9MT0FNWRADEhIKDlNPSUxfVFlQ'
    'RV9TSUxUEAQSEgoOU09JTF9UWVBFX1BFQVQQBRITCg9TT0lMX1RZUEVfQ0hBTEsQBhIXChNTT0'
    'lMX1RZUEVfQ0xBWV9MT0FNEAcSGAoUU09JTF9UWVBFX1NBTkRZX0xPQU0QCA==');

@$core.Deprecated('Use irrigationTypeDescriptor instead')
const IrrigationType$json = {
  '1': 'IrrigationType',
  '2': [
    {'1': 'IRRIGATION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'IRRIGATION_TYPE_RAINFED', '2': 1},
    {'1': 'IRRIGATION_TYPE_DRIP', '2': 2},
    {'1': 'IRRIGATION_TYPE_SPRINKLER', '2': 3},
    {'1': 'IRRIGATION_TYPE_FLOOD', '2': 4},
    {'1': 'IRRIGATION_TYPE_CENTER_PIVOT', '2': 5},
    {'1': 'IRRIGATION_TYPE_FURROW', '2': 6},
    {'1': 'IRRIGATION_TYPE_SUBSURFACE', '2': 7},
  ],
};

/// Descriptor for `IrrigationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List irrigationTypeDescriptor = $convert.base64Decode(
    'Cg5JcnJpZ2F0aW9uVHlwZRIfChtJUlJJR0FUSU9OX1RZUEVfVU5TUEVDSUZJRUQQABIbChdJUl'
    'JJR0FUSU9OX1RZUEVfUkFJTkZFRBABEhgKFElSUklHQVRJT05fVFlQRV9EUklQEAISHQoZSVJS'
    'SUdBVElPTl9UWVBFX1NQUklOS0xFUhADEhkKFUlSUklHQVRJT05fVFlQRV9GTE9PRBAEEiAKHE'
    'lSUklHQVRJT05fVFlQRV9DRU5URVJfUElWT1QQBRIaChZJUlJJR0FUSU9OX1RZUEVfRlVSUk9X'
    'EAYSHgoaSVJSSUdBVElPTl9UWVBFX1NVQlNVUkZBQ0UQBw==');

@$core.Deprecated('Use growthStageDescriptor instead')
const GrowthStage$json = {
  '1': 'GrowthStage',
  '2': [
    {'1': 'GROWTH_STAGE_UNSPECIFIED', '2': 0},
    {'1': 'GROWTH_STAGE_GERMINATION', '2': 1},
    {'1': 'GROWTH_STAGE_SEEDLING', '2': 2},
    {'1': 'GROWTH_STAGE_VEGETATIVE', '2': 3},
    {'1': 'GROWTH_STAGE_BUDDING', '2': 4},
    {'1': 'GROWTH_STAGE_FLOWERING', '2': 5},
    {'1': 'GROWTH_STAGE_FRUIT_SET', '2': 6},
    {'1': 'GROWTH_STAGE_RIPENING', '2': 7},
    {'1': 'GROWTH_STAGE_MATURITY', '2': 8},
    {'1': 'GROWTH_STAGE_SENESCENCE', '2': 9},
  ],
};

/// Descriptor for `GrowthStage`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List growthStageDescriptor = $convert.base64Decode(
    'CgtHcm93dGhTdGFnZRIcChhHUk9XVEhfU1RBR0VfVU5TUEVDSUZJRUQQABIcChhHUk9XVEhfU1'
    'RBR0VfR0VSTUlOQVRJT04QARIZChVHUk9XVEhfU1RBR0VfU0VFRExJTkcQAhIbChdHUk9XVEhf'
    'U1RBR0VfVkVHRVRBVElWRRADEhgKFEdST1dUSF9TVEFHRV9CVURESU5HEAQSGgoWR1JPV1RIX1'
    'NUQUdFX0ZMT1dFUklORxAFEhoKFkdST1dUSF9TVEFHRV9GUlVJVF9TRVQQBhIZChVHUk9XVEhf'
    'U1RBR0VfUklQRU5JTkcQBxIZChVHUk9XVEhfU1RBR0VfTUFUVVJJVFkQCBIbChdHUk9XVEhfU1'
    'RBR0VfU0VORVNDRU5DRRAJ');

@$core.Deprecated('Use aspectDirectionDescriptor instead')
const AspectDirection$json = {
  '1': 'AspectDirection',
  '2': [
    {'1': 'ASPECT_DIRECTION_UNSPECIFIED', '2': 0},
    {'1': 'ASPECT_DIRECTION_NORTH', '2': 1},
    {'1': 'ASPECT_DIRECTION_NORTHEAST', '2': 2},
    {'1': 'ASPECT_DIRECTION_EAST', '2': 3},
    {'1': 'ASPECT_DIRECTION_SOUTHEAST', '2': 4},
    {'1': 'ASPECT_DIRECTION_SOUTH', '2': 5},
    {'1': 'ASPECT_DIRECTION_SOUTHWEST', '2': 6},
    {'1': 'ASPECT_DIRECTION_WEST', '2': 7},
    {'1': 'ASPECT_DIRECTION_NORTHWEST', '2': 8},
    {'1': 'ASPECT_DIRECTION_FLAT', '2': 9},
  ],
};

/// Descriptor for `AspectDirection`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List aspectDirectionDescriptor = $convert.base64Decode(
    'Cg9Bc3BlY3REaXJlY3Rpb24SIAocQVNQRUNUX0RJUkVDVElPTl9VTlNQRUNJRklFRBAAEhoKFk'
    'FTUEVDVF9ESVJFQ1RJT05fTk9SVEgQARIeChpBU1BFQ1RfRElSRUNUSU9OX05PUlRIRUFTVBAC'
    'EhkKFUFTUEVDVF9ESVJFQ1RJT05fRUFTVBADEh4KGkFTUEVDVF9ESVJFQ1RJT05fU09VVEhFQV'
    'NUEAQSGgoWQVNQRUNUX0RJUkVDVElPTl9TT1VUSBAFEh4KGkFTUEVDVF9ESVJFQ1RJT05fU09V'
    'VEhXRVNUEAYSGQoVQVNQRUNUX0RJUkVDVElPTl9XRVNUEAcSHgoaQVNQRUNUX0RJUkVDVElPTl'
    '9OT1JUSFdFU1QQCBIZChVBU1BFQ1RfRElSRUNUSU9OX0ZMQVQQCQ==');

@$core.Deprecated('Use cropCycleStatusDescriptor instead')
const CropCycleStatus$json = {
  '1': 'CropCycleStatus',
  '2': [
    {'1': 'CYCLE_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'CYCLE_STATUS_PLANNED', '2': 1},
    {'1': 'CYCLE_STATUS_ACTIVE', '2': 2},
    {'1': 'CYCLE_STATUS_HARVESTING', '2': 3},
    {'1': 'CYCLE_STATUS_COMPLETED', '2': 4},
    {'1': 'CYCLE_STATUS_ABANDONED', '2': 5},
  ],
};

/// Descriptor for `CropCycleStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List cropCycleStatusDescriptor = $convert.base64Decode(
    'Cg9Dcm9wQ3ljbGVTdGF0dXMSHAoYQ1lDTEVfU1RBVFVTX1VOU1BFQ0lGSUVEEAASGAoUQ1lDTE'
    'VfU1RBVFVTX1BMQU5ORUQQARIXChNDWUNMRV9TVEFUVVNfQUNUSVZFEAISGwoXQ1lDTEVfU1RB'
    'VFVTX0hBUlZFU1RJTkcQAxIaChZDWUNMRV9TVEFUVVNfQ09NUExFVEVEEAQSGgoWQ1lDTEVfU1'
    'RBVFVTX0FCQU5ET05FRBAF');

@$core.Deprecated('Use activityCategoryDescriptor instead')
const ActivityCategory$json = {
  '1': 'ActivityCategory',
  '2': [
    {'1': 'CATEGORY_UNSPECIFIED', '2': 0},
    {'1': 'CATEGORY_LAND_PREP', '2': 1},
    {'1': 'CATEGORY_PLANTING', '2': 2},
    {'1': 'CATEGORY_IRRIGATION', '2': 3},
    {'1': 'CATEGORY_FERTILIZATION', '2': 4},
    {'1': 'CATEGORY_PEST_CONTROL', '2': 5},
    {'1': 'CATEGORY_SCOUTING', '2': 6},
    {'1': 'CATEGORY_HARVESTING', '2': 7},
    {'1': 'CATEGORY_POST_HARVEST', '2': 8},
    {'1': 'CATEGORY_SOIL_SAMPLING', '2': 9},
    {'1': 'CATEGORY_MAINTENANCE', '2': 10},
  ],
};

/// Descriptor for `ActivityCategory`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List activityCategoryDescriptor = $convert.base64Decode(
    'ChBBY3Rpdml0eUNhdGVnb3J5EhgKFENBVEVHT1JZX1VOU1BFQ0lGSUVEEAASFgoSQ0FURUdPUl'
    'lfTEFORF9QUkVQEAESFQoRQ0FURUdPUllfUExBTlRJTkcQAhIXChNDQVRFR09SWV9JUlJJR0FU'
    'SU9OEAMSGgoWQ0FURUdPUllfRkVSVElMSVpBVElPThAEEhkKFUNBVEVHT1JZX1BFU1RfQ09OVF'
    'JPTBAFEhUKEUNBVEVHT1JZX1NDT1VUSU5HEAYSFwoTQ0FURUdPUllfSEFSVkVTVElORxAHEhkK'
    'FUNBVEVHT1JZX1BPU1RfSEFSVkVTVBAIEhoKFkNBVEVHT1JZX1NPSUxfU0FNUExJTkcQCRIYCh'
    'RDQVRFR09SWV9NQUlOVEVOQU5DRRAK');

@$core.Deprecated('Use evidenceTypeDescriptor instead')
const EvidenceType$json = {
  '1': 'EvidenceType',
  '2': [
    {'1': 'EVIDENCE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'EVIDENCE_TYPE_PHOTO', '2': 1},
    {'1': 'EVIDENCE_TYPE_DOCUMENT', '2': 2},
    {'1': 'EVIDENCE_TYPE_VIDEO', '2': 3},
    {'1': 'EVIDENCE_TYPE_AUDIO', '2': 4},
    {'1': 'EVIDENCE_TYPE_OTHER', '2': 5},
  ],
};

/// Descriptor for `EvidenceType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List evidenceTypeDescriptor = $convert.base64Decode(
    'CgxFdmlkZW5jZVR5cGUSHQoZRVZJREVOQ0VfVFlQRV9VTlNQRUNJRklFRBAAEhcKE0VWSURFTk'
    'NFX1RZUEVfUEhPVE8QARIaChZFVklERU5DRV9UWVBFX0RPQ1VNRU5UEAISFwoTRVZJREVOQ0Vf'
    'VFlQRV9WSURFTxADEhcKE0VWSURFTkNFX1RZUEVfQVVESU8QBBIXChNFVklERU5DRV9UWVBFX0'
    '9USEVSEAU=');

@$core.Deprecated('Use geoPointDescriptor instead')
const GeoPoint$json = {
  '1': 'GeoPoint',
  '2': [
    {'1': 'longitude', '3': 1, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'latitude', '3': 2, '4': 1, '5': 1, '10': 'latitude'},
  ],
};

/// Descriptor for `GeoPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List geoPointDescriptor = $convert.base64Decode(
    'CghHZW9Qb2ludBIcCglsb25naXR1ZGUYASABKAFSCWxvbmdpdHVkZRIaCghsYXRpdHVkZRgCIA'
    'EoAVIIbGF0aXR1ZGU=');

@$core.Deprecated('Use geoPolygonDescriptor instead')
const GeoPolygon$json = {
  '1': 'GeoPolygon',
  '2': [
    {
      '1': 'points',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.v1.GeoPoint',
      '10': 'points'
    },
  ],
};

/// Descriptor for `GeoPolygon`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List geoPolygonDescriptor = $convert.base64Decode(
    'CgpHZW9Qb2x5Z29uEjYKBnBvaW50cxgBIAMoCzIeLmFncmljdWx0dXJlLmZpZWxkLnYxLkdlb1'
    'BvaW50UgZwb2ludHM=');

@$core.Deprecated('Use fieldDescriptor instead')
const Field$json = {
  '1': 'Field',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'area_hectares', '3': 5, '4': 1, '5': 1, '10': 'areaHectares'},
    {
      '1': 'boundary',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.GeoPolygon',
      '10': 'boundary'
    },
    {'1': 'current_crop_id', '3': 7, '4': 1, '5': 9, '10': 'currentCropId'},
    {
      '1': 'planting_date',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'plantingDate'
    },
    {
      '1': 'expected_harvest_date',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expectedHarvestDate'
    },
    {
      '1': 'growth_stage',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.GrowthStage',
      '10': 'growthStage'
    },
    {
      '1': 'soil_type',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.SoilType',
      '10': 'soilType'
    },
    {
      '1': 'irrigation_type',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.IrrigationType',
      '10': 'irrigationType'
    },
    {
      '1': 'field_type',
      '3': 13,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.FieldType',
      '10': 'fieldType'
    },
    {
      '1': 'status',
      '3': 14,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.FieldStatus',
      '10': 'status'
    },
    {'1': 'elevation_meters', '3': 15, '4': 1, '5': 1, '10': 'elevationMeters'},
    {'1': 'slope_degrees', '3': 16, '4': 1, '5': 1, '10': 'slopeDegrees'},
    {
      '1': 'aspect_direction',
      '3': 17,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.AspectDirection',
      '10': 'aspectDirection'
    },
    {'1': 'created_by', '3': 18, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'updated_by', '3': 19, '4': 1, '5': 9, '10': 'updatedBy'},
    {
      '1': 'created_at',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {'1': 'version', '3': 22, '4': 1, '5': 3, '10': 'version'},
  ],
};

/// Descriptor for `Field`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldDescriptor = $convert.base64Decode(
    'CgVGaWVsZBIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW5hbnRJZBIXCg'
    'dmYXJtX2lkGAMgASgJUgZmYXJtSWQSEgoEbmFtZRgEIAEoCVIEbmFtZRIjCg1hcmVhX2hlY3Rh'
    'cmVzGAUgASgBUgxhcmVhSGVjdGFyZXMSPAoIYm91bmRhcnkYBiABKAsyIC5hZ3JpY3VsdHVyZS'
    '5maWVsZC52MS5HZW9Qb2x5Z29uUghib3VuZGFyeRImCg9jdXJyZW50X2Nyb3BfaWQYByABKAlS'
    'DWN1cnJlbnRDcm9wSWQSPwoNcGxhbnRpbmdfZGF0ZRgIIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi'
    '5UaW1lc3RhbXBSDHBsYW50aW5nRGF0ZRJOChVleHBlY3RlZF9oYXJ2ZXN0X2RhdGUYCSABKAsy'
    'Gi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUhNleHBlY3RlZEhhcnZlc3REYXRlEkQKDGdyb3'
    'd0aF9zdGFnZRgKIAEoDjIhLmFncmljdWx0dXJlLmZpZWxkLnYxLkdyb3d0aFN0YWdlUgtncm93'
    'dGhTdGFnZRI7Cglzb2lsX3R5cGUYCyABKA4yHi5hZ3JpY3VsdHVyZS5maWVsZC52MS5Tb2lsVH'
    'lwZVIIc29pbFR5cGUSTQoPaXJyaWdhdGlvbl90eXBlGAwgASgOMiQuYWdyaWN1bHR1cmUuZmll'
    'bGQudjEuSXJyaWdhdGlvblR5cGVSDmlycmlnYXRpb25UeXBlEj4KCmZpZWxkX3R5cGUYDSABKA'
    '4yHy5hZ3JpY3VsdHVyZS5maWVsZC52MS5GaWVsZFR5cGVSCWZpZWxkVHlwZRI5CgZzdGF0dXMY'
    'DiABKA4yIS5hZ3JpY3VsdHVyZS5maWVsZC52MS5GaWVsZFN0YXR1c1IGc3RhdHVzEikKEGVsZX'
    'ZhdGlvbl9tZXRlcnMYDyABKAFSD2VsZXZhdGlvbk1ldGVycxIjCg1zbG9wZV9kZWdyZWVzGBAg'
    'ASgBUgxzbG9wZURlZ3JlZXMSUAoQYXNwZWN0X2RpcmVjdGlvbhgRIAEoDjIlLmFncmljdWx0dX'
    'JlLmZpZWxkLnYxLkFzcGVjdERpcmVjdGlvblIPYXNwZWN0RGlyZWN0aW9uEh0KCmNyZWF0ZWRf'
    'YnkYEiABKAlSCWNyZWF0ZWRCeRIdCgp1cGRhdGVkX2J5GBMgASgJUgl1cGRhdGVkQnkSOQoKY3'
    'JlYXRlZF9hdBgUIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5'
    'Cgp1cGRhdGVkX2F0GBUgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZE'
    'F0EhgKB3ZlcnNpb24YFiABKANSB3ZlcnNpb24=');

@$core.Deprecated('Use fieldBoundaryDescriptor instead')
const FieldBoundary$json = {
  '1': 'FieldBoundary',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'polygon',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.GeoPolygon',
      '10': 'polygon'
    },
    {'1': 'area_hectares', '3': 4, '4': 1, '5': 1, '10': 'areaHectares'},
    {'1': 'perimeter_meters', '3': 5, '4': 1, '5': 1, '10': 'perimeterMeters'},
    {'1': 'source', '3': 6, '4': 1, '5': 9, '10': 'source'},
    {
      '1': 'recorded_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'recordedAt'
    },
    {
      '1': 'created_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `FieldBoundary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldBoundaryDescriptor = $convert.base64Decode(
    'Cg1GaWVsZEJvdW5kYXJ5Eg4KAmlkGAEgASgJUgJpZBIZCghmaWVsZF9pZBgCIAEoCVIHZmllbG'
    'RJZBI6Cgdwb2x5Z29uGAMgASgLMiAuYWdyaWN1bHR1cmUuZmllbGQudjEuR2VvUG9seWdvblIH'
    'cG9seWdvbhIjCg1hcmVhX2hlY3RhcmVzGAQgASgBUgxhcmVhSGVjdGFyZXMSKQoQcGVyaW1ldG'
    'VyX21ldGVycxgFIAEoAVIPcGVyaW1ldGVyTWV0ZXJzEhYKBnNvdXJjZRgGIAEoCVIGc291cmNl'
    'EjsKC3JlY29yZGVkX2F0GAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIKcmVjb3'
    'JkZWRBdBI5CgpjcmVhdGVkX2F0GAggASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJ'
    'Y3JlYXRlZEF0');

@$core.Deprecated('Use fieldCropAssignmentDescriptor instead')
const FieldCropAssignment$json = {
  '1': 'FieldCropAssignment',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 3, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'crop_variety', '3': 4, '4': 1, '5': 9, '10': 'cropVariety'},
    {
      '1': 'planting_date',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'plantingDate'
    },
    {
      '1': 'expected_harvest_date',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expectedHarvestDate'
    },
    {
      '1': 'actual_harvest_date',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'actualHarvestDate'
    },
    {
      '1': 'growth_stage',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.GrowthStage',
      '10': 'growthStage'
    },
    {'1': 'yield_per_hectare', '3': 9, '4': 1, '5': 1, '10': 'yieldPerHectare'},
    {'1': 'notes', '3': 10, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'season', '3': 11, '4': 1, '5': 9, '10': 'season'},
    {
      '1': 'created_at',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `FieldCropAssignment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldCropAssignmentDescriptor = $convert.base64Decode(
    'ChNGaWVsZENyb3BBc3NpZ25tZW50Eg4KAmlkGAEgASgJUgJpZBIZCghmaWVsZF9pZBgCIAEoCV'
    'IHZmllbGRJZBIXCgdjcm9wX2lkGAMgASgJUgZjcm9wSWQSIQoMY3JvcF92YXJpZXR5GAQgASgJ'
    'Ugtjcm9wVmFyaWV0eRI/Cg1wbGFudGluZ19kYXRlGAUgASgLMhouZ29vZ2xlLnByb3RvYnVmLl'
    'RpbWVzdGFtcFIMcGxhbnRpbmdEYXRlEk4KFWV4cGVjdGVkX2hhcnZlc3RfZGF0ZRgGIAEoCzIa'
    'Lmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSE2V4cGVjdGVkSGFydmVzdERhdGUSSgoTYWN0dW'
    'FsX2hhcnZlc3RfZGF0ZRgHIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSEWFjdHVh'
    'bEhhcnZlc3REYXRlEkQKDGdyb3d0aF9zdGFnZRgIIAEoDjIhLmFncmljdWx0dXJlLmZpZWxkLn'
    'YxLkdyb3d0aFN0YWdlUgtncm93dGhTdGFnZRIqChF5aWVsZF9wZXJfaGVjdGFyZRgJIAEoAVIP'
    'eWllbGRQZXJIZWN0YXJlEhQKBW5vdGVzGAogASgJUgVub3RlcxIWCgZzZWFzb24YCyABKAlSBn'
    'NlYXNvbhI5CgpjcmVhdGVkX2F0GAwgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJ'
    'Y3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYDSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW'
    '1wUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use fieldSegmentDescriptor instead')
const FieldSegment$json = {
  '1': 'FieldSegment',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'boundary',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.GeoPolygon',
      '10': 'boundary'
    },
    {'1': 'area_hectares', '3': 5, '4': 1, '5': 1, '10': 'areaHectares'},
    {
      '1': 'soil_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.SoilType',
      '10': 'soilType'
    },
    {'1': 'current_crop_id', '3': 7, '4': 1, '5': 9, '10': 'currentCropId'},
    {'1': 'notes', '3': 8, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'segment_index', '3': 9, '4': 1, '5': 5, '10': 'segmentIndex'},
    {
      '1': 'created_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `FieldSegment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldSegmentDescriptor = $convert.base64Decode(
    'CgxGaWVsZFNlZ21lbnQSDgoCaWQYASABKAlSAmlkEhkKCGZpZWxkX2lkGAIgASgJUgdmaWVsZE'
    'lkEhIKBG5hbWUYAyABKAlSBG5hbWUSPAoIYm91bmRhcnkYBCABKAsyIC5hZ3JpY3VsdHVyZS5m'
    'aWVsZC52MS5HZW9Qb2x5Z29uUghib3VuZGFyeRIjCg1hcmVhX2hlY3RhcmVzGAUgASgBUgxhcm'
    'VhSGVjdGFyZXMSOwoJc29pbF90eXBlGAYgASgOMh4uYWdyaWN1bHR1cmUuZmllbGQudjEuU29p'
    'bFR5cGVSCHNvaWxUeXBlEiYKD2N1cnJlbnRfY3JvcF9pZBgHIAEoCVINY3VycmVudENyb3BJZB'
    'IUCgVub3RlcxgIIAEoCVIFbm90ZXMSIwoNc2VnbWVudF9pbmRleBgJIAEoBVIMc2VnbWVudElu'
    'ZGV4EjkKCmNyZWF0ZWRfYXQYCiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcm'
    'VhdGVkQXQSOQoKdXBkYXRlZF9hdBgLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBS'
    'CXVwZGF0ZWRBdA==');

@$core.Deprecated('Use createFieldRequestDescriptor instead')
const CreateFieldRequest$json = {
  '1': 'CreateFieldRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'area_hectares', '3': 3, '4': 1, '5': 1, '10': 'areaHectares'},
    {
      '1': 'boundary',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.GeoPolygon',
      '10': 'boundary'
    },
    {
      '1': 'field_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.FieldType',
      '10': 'fieldType'
    },
    {
      '1': 'soil_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.SoilType',
      '10': 'soilType'
    },
    {
      '1': 'irrigation_type',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.IrrigationType',
      '10': 'irrigationType'
    },
    {'1': 'elevation_meters', '3': 8, '4': 1, '5': 1, '10': 'elevationMeters'},
    {'1': 'slope_degrees', '3': 9, '4': 1, '5': 1, '10': 'slopeDegrees'},
    {
      '1': 'aspect_direction',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.AspectDirection',
      '10': 'aspectDirection'
    },
  ],
};

/// Descriptor for `CreateFieldRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createFieldRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVGaWVsZFJlcXVlc3QSFwoHZmFybV9pZBgBIAEoCVIGZmFybUlkEhIKBG5hbWUYAi'
    'ABKAlSBG5hbWUSIwoNYXJlYV9oZWN0YXJlcxgDIAEoAVIMYXJlYUhlY3RhcmVzEjwKCGJvdW5k'
    'YXJ5GAQgASgLMiAuYWdyaWN1bHR1cmUuZmllbGQudjEuR2VvUG9seWdvblIIYm91bmRhcnkSPg'
    'oKZmllbGRfdHlwZRgFIAEoDjIfLmFncmljdWx0dXJlLmZpZWxkLnYxLkZpZWxkVHlwZVIJZmll'
    'bGRUeXBlEjsKCXNvaWxfdHlwZRgGIAEoDjIeLmFncmljdWx0dXJlLmZpZWxkLnYxLlNvaWxUeX'
    'BlUghzb2lsVHlwZRJNCg9pcnJpZ2F0aW9uX3R5cGUYByABKA4yJC5hZ3JpY3VsdHVyZS5maWVs'
    'ZC52MS5JcnJpZ2F0aW9uVHlwZVIOaXJyaWdhdGlvblR5cGUSKQoQZWxldmF0aW9uX21ldGVycx'
    'gIIAEoAVIPZWxldmF0aW9uTWV0ZXJzEiMKDXNsb3BlX2RlZ3JlZXMYCSABKAFSDHNsb3BlRGVn'
    'cmVlcxJQChBhc3BlY3RfZGlyZWN0aW9uGAogASgOMiUuYWdyaWN1bHR1cmUuZmllbGQudjEuQX'
    'NwZWN0RGlyZWN0aW9uUg9hc3BlY3REaXJlY3Rpb24=');

@$core.Deprecated('Use createFieldResponseDescriptor instead')
const CreateFieldResponse$json = {
  '1': 'CreateFieldResponse',
  '2': [
    {
      '1': 'field',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.Field',
      '10': 'field'
    },
  ],
};

/// Descriptor for `CreateFieldResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createFieldResponseDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVGaWVsZFJlc3BvbnNlEjEKBWZpZWxkGAEgASgLMhsuYWdyaWN1bHR1cmUuZmllbG'
    'QudjEuRmllbGRSBWZpZWxk');

@$core.Deprecated('Use getFieldRequestDescriptor instead')
const GetFieldRequest$json = {
  '1': 'GetFieldRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetFieldRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFieldRequestDescriptor =
    $convert.base64Decode('Cg9HZXRGaWVsZFJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use getFieldResponseDescriptor instead')
const GetFieldResponse$json = {
  '1': 'GetFieldResponse',
  '2': [
    {
      '1': 'field',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.Field',
      '10': 'field'
    },
  ],
};

/// Descriptor for `GetFieldResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFieldResponseDescriptor = $convert.base64Decode(
    'ChBHZXRGaWVsZFJlc3BvbnNlEjEKBWZpZWxkGAEgASgLMhsuYWdyaWN1bHR1cmUuZmllbGQudj'
    'EuRmllbGRSBWZpZWxk');

@$core.Deprecated('Use listFieldsRequestDescriptor instead')
const ListFieldsRequest$json = {
  '1': 'ListFieldsRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 2, '4': 1, '5': 5, '10': 'pageOffset'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.FieldStatus',
      '10': 'status'
    },
    {
      '1': 'field_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.FieldType',
      '10': 'fieldType'
    },
    {'1': 'search', '3': 6, '4': 1, '5': 9, '10': 'search'},
  ],
};

/// Descriptor for `ListFieldsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFieldsRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0RmllbGRzUmVxdWVzdBIbCglwYWdlX3NpemUYASABKAVSCHBhZ2VTaXplEh8KC3BhZ2'
    'Vfb2Zmc2V0GAIgASgFUgpwYWdlT2Zmc2V0EhcKB2Zhcm1faWQYAyABKAlSBmZhcm1JZBI5CgZz'
    'dGF0dXMYBCABKA4yIS5hZ3JpY3VsdHVyZS5maWVsZC52MS5GaWVsZFN0YXR1c1IGc3RhdHVzEj'
    '4KCmZpZWxkX3R5cGUYBSABKA4yHy5hZ3JpY3VsdHVyZS5maWVsZC52MS5GaWVsZFR5cGVSCWZp'
    'ZWxkVHlwZRIWCgZzZWFyY2gYBiABKAlSBnNlYXJjaA==');

@$core.Deprecated('Use listFieldsResponseDescriptor instead')
const ListFieldsResponse$json = {
  '1': 'ListFieldsResponse',
  '2': [
    {
      '1': 'fields',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.v1.Field',
      '10': 'fields'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListFieldsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFieldsResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0RmllbGRzUmVzcG9uc2USMwoGZmllbGRzGAEgAygLMhsuYWdyaWN1bHR1cmUuZmllbG'
    'QudjEuRmllbGRSBmZpZWxkcxIfCgt0b3RhbF9jb3VudBgCIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use updateFieldRequestDescriptor instead')
const UpdateFieldRequest$json = {
  '1': 'UpdateFieldRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'area_hectares', '3': 3, '4': 1, '5': 1, '10': 'areaHectares'},
    {
      '1': 'field_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.FieldType',
      '10': 'fieldType'
    },
    {
      '1': 'soil_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.SoilType',
      '10': 'soilType'
    },
    {
      '1': 'irrigation_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.IrrigationType',
      '10': 'irrigationType'
    },
    {
      '1': 'status',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.FieldStatus',
      '10': 'status'
    },
    {'1': 'elevation_meters', '3': 8, '4': 1, '5': 1, '10': 'elevationMeters'},
    {'1': 'slope_degrees', '3': 9, '4': 1, '5': 1, '10': 'slopeDegrees'},
    {
      '1': 'aspect_direction',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.AspectDirection',
      '10': 'aspectDirection'
    },
    {
      '1': 'growth_stage',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.GrowthStage',
      '10': 'growthStage'
    },
    {
      '1': 'update_mask',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
  ],
};

/// Descriptor for `UpdateFieldRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateFieldRequestDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVGaWVsZFJlcXVlc3QSDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbW'
    'USIwoNYXJlYV9oZWN0YXJlcxgDIAEoAVIMYXJlYUhlY3RhcmVzEj4KCmZpZWxkX3R5cGUYBCAB'
    'KA4yHy5hZ3JpY3VsdHVyZS5maWVsZC52MS5GaWVsZFR5cGVSCWZpZWxkVHlwZRI7Cglzb2lsX3'
    'R5cGUYBSABKA4yHi5hZ3JpY3VsdHVyZS5maWVsZC52MS5Tb2lsVHlwZVIIc29pbFR5cGUSTQoP'
    'aXJyaWdhdGlvbl90eXBlGAYgASgOMiQuYWdyaWN1bHR1cmUuZmllbGQudjEuSXJyaWdhdGlvbl'
    'R5cGVSDmlycmlnYXRpb25UeXBlEjkKBnN0YXR1cxgHIAEoDjIhLmFncmljdWx0dXJlLmZpZWxk'
    'LnYxLkZpZWxkU3RhdHVzUgZzdGF0dXMSKQoQZWxldmF0aW9uX21ldGVycxgIIAEoAVIPZWxldm'
    'F0aW9uTWV0ZXJzEiMKDXNsb3BlX2RlZ3JlZXMYCSABKAFSDHNsb3BlRGVncmVlcxJQChBhc3Bl'
    'Y3RfZGlyZWN0aW9uGAogASgOMiUuYWdyaWN1bHR1cmUuZmllbGQudjEuQXNwZWN0RGlyZWN0aW'
    '9uUg9hc3BlY3REaXJlY3Rpb24SRAoMZ3Jvd3RoX3N0YWdlGAsgASgOMiEuYWdyaWN1bHR1cmUu'
    'ZmllbGQudjEuR3Jvd3RoU3RhZ2VSC2dyb3d0aFN0YWdlEjsKC3VwZGF0ZV9tYXNrGAwgASgLMh'
    'ouZ29vZ2xlLnByb3RvYnVmLkZpZWxkTWFza1IKdXBkYXRlTWFzaw==');

@$core.Deprecated('Use updateFieldResponseDescriptor instead')
const UpdateFieldResponse$json = {
  '1': 'UpdateFieldResponse',
  '2': [
    {
      '1': 'field',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.Field',
      '10': 'field'
    },
  ],
};

/// Descriptor for `UpdateFieldResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateFieldResponseDescriptor = $convert.base64Decode(
    'ChNVcGRhdGVGaWVsZFJlc3BvbnNlEjEKBWZpZWxkGAEgASgLMhsuYWdyaWN1bHR1cmUuZmllbG'
    'QudjEuRmllbGRSBWZpZWxk');

@$core.Deprecated('Use deleteFieldRequestDescriptor instead')
const DeleteFieldRequest$json = {
  '1': 'DeleteFieldRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteFieldRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFieldRequestDescriptor =
    $convert.base64Decode('ChJEZWxldGVGaWVsZFJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use deleteFieldResponseDescriptor instead')
const DeleteFieldResponse$json = {
  '1': 'DeleteFieldResponse',
};

/// Descriptor for `DeleteFieldResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFieldResponseDescriptor =
    $convert.base64Decode('ChNEZWxldGVGaWVsZFJlc3BvbnNl');

@$core.Deprecated('Use setFieldBoundaryRequestDescriptor instead')
const SetFieldBoundaryRequest$json = {
  '1': 'SetFieldBoundaryRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'polygon',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.GeoPolygon',
      '10': 'polygon'
    },
    {'1': 'source', '3': 3, '4': 1, '5': 9, '10': 'source'},
  ],
};

/// Descriptor for `SetFieldBoundaryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFieldBoundaryRequestDescriptor = $convert.base64Decode(
    'ChdTZXRGaWVsZEJvdW5kYXJ5UmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBI6Cg'
    'dwb2x5Z29uGAIgASgLMiAuYWdyaWN1bHR1cmUuZmllbGQudjEuR2VvUG9seWdvblIHcG9seWdv'
    'bhIWCgZzb3VyY2UYAyABKAlSBnNvdXJjZQ==');

@$core.Deprecated('Use setFieldBoundaryResponseDescriptor instead')
const SetFieldBoundaryResponse$json = {
  '1': 'SetFieldBoundaryResponse',
  '2': [
    {
      '1': 'boundary',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.FieldBoundary',
      '10': 'boundary'
    },
  ],
};

/// Descriptor for `SetFieldBoundaryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFieldBoundaryResponseDescriptor =
    $convert.base64Decode(
        'ChhTZXRGaWVsZEJvdW5kYXJ5UmVzcG9uc2USPwoIYm91bmRhcnkYASABKAsyIy5hZ3JpY3VsdH'
        'VyZS5maWVsZC52MS5GaWVsZEJvdW5kYXJ5Ughib3VuZGFyeQ==');

@$core.Deprecated('Use assignCropRequestDescriptor instead')
const AssignCropRequest$json = {
  '1': 'AssignCropRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 2, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'crop_variety', '3': 3, '4': 1, '5': 9, '10': 'cropVariety'},
    {
      '1': 'planting_date',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'plantingDate'
    },
    {
      '1': 'expected_harvest_date',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expectedHarvestDate'
    },
    {'1': 'season', '3': 6, '4': 1, '5': 9, '10': 'season'},
    {'1': 'notes', '3': 7, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `AssignCropRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List assignCropRequestDescriptor = $convert.base64Decode(
    'ChFBc3NpZ25Dcm9wUmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBIXCgdjcm9wX2'
    'lkGAIgASgJUgZjcm9wSWQSIQoMY3JvcF92YXJpZXR5GAMgASgJUgtjcm9wVmFyaWV0eRI/Cg1w'
    'bGFudGluZ19kYXRlGAQgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIMcGxhbnRpbm'
    'dEYXRlEk4KFWV4cGVjdGVkX2hhcnZlc3RfZGF0ZRgFIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5U'
    'aW1lc3RhbXBSE2V4cGVjdGVkSGFydmVzdERhdGUSFgoGc2Vhc29uGAYgASgJUgZzZWFzb24SFA'
    'oFbm90ZXMYByABKAlSBW5vdGVz');

@$core.Deprecated('Use assignCropResponseDescriptor instead')
const AssignCropResponse$json = {
  '1': 'AssignCropResponse',
  '2': [
    {
      '1': 'assignment',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.FieldCropAssignment',
      '10': 'assignment'
    },
  ],
};

/// Descriptor for `AssignCropResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List assignCropResponseDescriptor = $convert.base64Decode(
    'ChJBc3NpZ25Dcm9wUmVzcG9uc2USSQoKYXNzaWdubWVudBgBIAEoCzIpLmFncmljdWx0dXJlLm'
    'ZpZWxkLnYxLkZpZWxkQ3JvcEFzc2lnbm1lbnRSCmFzc2lnbm1lbnQ=');

@$core.Deprecated('Use listFieldsByFarmRequestDescriptor instead')
const ListFieldsByFarmRequest$json = {
  '1': 'ListFieldsByFarmRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 3, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListFieldsByFarmRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFieldsByFarmRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0RmllbGRzQnlGYXJtUmVxdWVzdBIXCgdmYXJtX2lkGAEgASgJUgZmYXJtSWQSGwoJcG'
    'FnZV9zaXplGAIgASgFUghwYWdlU2l6ZRIfCgtwYWdlX29mZnNldBgDIAEoBVIKcGFnZU9mZnNl'
    'dA==');

@$core.Deprecated('Use listFieldsByFarmResponseDescriptor instead')
const ListFieldsByFarmResponse$json = {
  '1': 'ListFieldsByFarmResponse',
  '2': [
    {
      '1': 'fields',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.v1.Field',
      '10': 'fields'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListFieldsByFarmResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFieldsByFarmResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0RmllbGRzQnlGYXJtUmVzcG9uc2USMwoGZmllbGRzGAEgAygLMhsuYWdyaWN1bHR1cm'
    'UuZmllbGQudjEuRmllbGRSBmZpZWxkcxIfCgt0b3RhbF9jb3VudBgCIAEoBVIKdG90YWxDb3Vu'
    'dA==');

@$core.Deprecated('Use segmentFieldRequestDescriptor instead')
const SegmentFieldRequest$json = {
  '1': 'SegmentFieldRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'segments',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.v1.FieldSegmentInput',
      '10': 'segments'
    },
  ],
};

/// Descriptor for `SegmentFieldRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List segmentFieldRequestDescriptor = $convert.base64Decode(
    'ChNTZWdtZW50RmllbGRSZXF1ZXN0EhkKCGZpZWxkX2lkGAEgASgJUgdmaWVsZElkEkMKCHNlZ2'
    '1lbnRzGAIgAygLMicuYWdyaWN1bHR1cmUuZmllbGQudjEuRmllbGRTZWdtZW50SW5wdXRSCHNl'
    'Z21lbnRz');

@$core.Deprecated('Use fieldSegmentInputDescriptor instead')
const FieldSegmentInput$json = {
  '1': 'FieldSegmentInput',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'boundary',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.GeoPolygon',
      '10': 'boundary'
    },
    {'1': 'area_hectares', '3': 3, '4': 1, '5': 1, '10': 'areaHectares'},
    {
      '1': 'soil_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.SoilType',
      '10': 'soilType'
    },
    {'1': 'notes', '3': 5, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `FieldSegmentInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldSegmentInputDescriptor = $convert.base64Decode(
    'ChFGaWVsZFNlZ21lbnRJbnB1dBISCgRuYW1lGAEgASgJUgRuYW1lEjwKCGJvdW5kYXJ5GAIgAS'
    'gLMiAuYWdyaWN1bHR1cmUuZmllbGQudjEuR2VvUG9seWdvblIIYm91bmRhcnkSIwoNYXJlYV9o'
    'ZWN0YXJlcxgDIAEoAVIMYXJlYUhlY3RhcmVzEjsKCXNvaWxfdHlwZRgEIAEoDjIeLmFncmljdW'
    'x0dXJlLmZpZWxkLnYxLlNvaWxUeXBlUghzb2lsVHlwZRIUCgVub3RlcxgFIAEoCVIFbm90ZXM=');

@$core.Deprecated('Use segmentFieldResponseDescriptor instead')
const SegmentFieldResponse$json = {
  '1': 'SegmentFieldResponse',
  '2': [
    {
      '1': 'segments',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.v1.FieldSegment',
      '10': 'segments'
    },
  ],
};

/// Descriptor for `SegmentFieldResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List segmentFieldResponseDescriptor = $convert.base64Decode(
    'ChRTZWdtZW50RmllbGRSZXNwb25zZRI+CghzZWdtZW50cxgBIAMoCzIiLmFncmljdWx0dXJlLm'
    'ZpZWxkLnYxLkZpZWxkU2VnbWVudFIIc2VnbWVudHM=');

@$core.Deprecated('Use getFieldSegmentsRequestDescriptor instead')
const GetFieldSegmentsRequest$json = {
  '1': 'GetFieldSegmentsRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
  ],
};

/// Descriptor for `GetFieldSegmentsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFieldSegmentsRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRGaWVsZFNlZ21lbnRzUmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZA==');

@$core.Deprecated('Use getFieldSegmentsResponseDescriptor instead')
const GetFieldSegmentsResponse$json = {
  '1': 'GetFieldSegmentsResponse',
  '2': [
    {
      '1': 'segments',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.v1.FieldSegment',
      '10': 'segments'
    },
  ],
};

/// Descriptor for `GetFieldSegmentsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFieldSegmentsResponseDescriptor =
    $convert.base64Decode(
        'ChhHZXRGaWVsZFNlZ21lbnRzUmVzcG9uc2USPgoIc2VnbWVudHMYASADKAsyIi5hZ3JpY3VsdH'
        'VyZS5maWVsZC52MS5GaWVsZFNlZ21lbnRSCHNlZ21lbnRz');

@$core.Deprecated('Use getCropHistoryRequestDescriptor instead')
const GetCropHistoryRequest$json = {
  '1': 'GetCropHistoryRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 3, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `GetCropHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCropHistoryRequestDescriptor = $convert.base64Decode(
    'ChVHZXRDcm9wSGlzdG9yeVJlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQSGwoJcG'
    'FnZV9zaXplGAIgASgFUghwYWdlU2l6ZRIfCgtwYWdlX29mZnNldBgDIAEoBVIKcGFnZU9mZnNl'
    'dA==');

@$core.Deprecated('Use getCropHistoryResponseDescriptor instead')
const GetCropHistoryResponse$json = {
  '1': 'GetCropHistoryResponse',
  '2': [
    {
      '1': 'assignments',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.v1.FieldCropAssignment',
      '10': 'assignments'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `GetCropHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCropHistoryResponseDescriptor = $convert.base64Decode(
    'ChZHZXRDcm9wSGlzdG9yeVJlc3BvbnNlEksKC2Fzc2lnbm1lbnRzGAEgAygLMikuYWdyaWN1bH'
    'R1cmUuZmllbGQudjEuRmllbGRDcm9wQXNzaWdubWVudFILYXNzaWdubWVudHMSHwoLdG90YWxf'
    'Y291bnQYAiABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use cropCycleDescriptor instead')
const CropCycle$json = {
  '1': 'CropCycle',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 4, '4': 1, '5': 9, '10': 'cropId'},
    {
      '1': 'crop_assignment_id',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'cropAssignmentId'
    },
    {'1': 'season', '3': 6, '4': 1, '5': 9, '10': 'season'},
    {'1': 'cycle_year', '3': 7, '4': 1, '5': 5, '10': 'cycleYear'},
    {'1': 'name', '3': 8, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'planned_planting_date',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'plannedPlantingDate'
    },
    {
      '1': 'actual_planting_date',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'actualPlantingDate'
    },
    {
      '1': 'planned_harvest_date',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'plannedHarvestDate'
    },
    {
      '1': 'actual_harvest_date',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'actualHarvestDate'
    },
    {
      '1': 'status',
      '3': 13,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.CropCycleStatus',
      '10': 'status'
    },
    {
      '1': 'target_yield_per_hectare',
      '3': 14,
      '4': 1,
      '5': 1,
      '10': 'targetYieldPerHectare'
    },
    {
      '1': 'actual_yield_per_hectare',
      '3': 15,
      '4': 1,
      '5': 1,
      '10': 'actualYieldPerHectare'
    },
    {'1': 'yield_unit', '3': 16, '4': 1, '5': 9, '10': 'yieldUnit'},
    {'1': 'total_input_cost', '3': 17, '4': 1, '5': 3, '10': 'totalInputCost'},
    {'1': 'total_revenue', '3': 18, '4': 1, '5': 3, '10': 'totalRevenue'},
    {'1': 'currency', '3': 19, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'notes', '3': 20, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'version', '3': 21, '4': 1, '5': 3, '10': 'version'},
    {'1': 'created_by', '3': 22, '4': 1, '5': 9, '10': 'createdBy'},
    {
      '1': 'created_at',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 24,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {
      '1': 'management_unit_id',
      '3': 25,
      '4': 1,
      '5': 9,
      '10': 'managementUnitId'
    },
    {'1': 'crop_variety', '3': 26, '4': 1, '5': 9, '10': 'cropVariety'},
    {'1': 'seed_source', '3': 27, '4': 1, '5': 9, '10': 'seedSource'},
  ],
};

/// Descriptor for `CropCycle`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cropCycleDescriptor = $convert.base64Decode(
    'CglDcm9wQ3ljbGUSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdGVuYW50SW'
    'QSGQoIZmllbGRfaWQYAyABKAlSB2ZpZWxkSWQSFwoHY3JvcF9pZBgEIAEoCVIGY3JvcElkEiwK'
    'EmNyb3BfYXNzaWdubWVudF9pZBgFIAEoCVIQY3JvcEFzc2lnbm1lbnRJZBIWCgZzZWFzb24YBi'
    'ABKAlSBnNlYXNvbhIdCgpjeWNsZV95ZWFyGAcgASgFUgljeWNsZVllYXISEgoEbmFtZRgIIAEo'
    'CVIEbmFtZRJOChVwbGFubmVkX3BsYW50aW5nX2RhdGUYCSABKAsyGi5nb29nbGUucHJvdG9idW'
    'YuVGltZXN0YW1wUhNwbGFubmVkUGxhbnRpbmdEYXRlEkwKFGFjdHVhbF9wbGFudGluZ19kYXRl'
    'GAogASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFISYWN0dWFsUGxhbnRpbmdEYXRlEk'
    'wKFHBsYW5uZWRfaGFydmVzdF9kYXRlGAsgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFt'
    'cFIScGxhbm5lZEhhcnZlc3REYXRlEkoKE2FjdHVhbF9oYXJ2ZXN0X2RhdGUYDCABKAsyGi5nb2'
    '9nbGUucHJvdG9idWYuVGltZXN0YW1wUhFhY3R1YWxIYXJ2ZXN0RGF0ZRI9CgZzdGF0dXMYDSAB'
    'KA4yJS5hZ3JpY3VsdHVyZS5maWVsZC52MS5Dcm9wQ3ljbGVTdGF0dXNSBnN0YXR1cxI3Chh0YX'
    'JnZXRfeWllbGRfcGVyX2hlY3RhcmUYDiABKAFSFXRhcmdldFlpZWxkUGVySGVjdGFyZRI3Chhh'
    'Y3R1YWxfeWllbGRfcGVyX2hlY3RhcmUYDyABKAFSFWFjdHVhbFlpZWxkUGVySGVjdGFyZRIdCg'
    'p5aWVsZF91bml0GBAgASgJUgl5aWVsZFVuaXQSKAoQdG90YWxfaW5wdXRfY29zdBgRIAEoA1IO'
    'dG90YWxJbnB1dENvc3QSIwoNdG90YWxfcmV2ZW51ZRgSIAEoA1IMdG90YWxSZXZlbnVlEhoKCG'
    'N1cnJlbmN5GBMgASgJUghjdXJyZW5jeRIUCgVub3RlcxgUIAEoCVIFbm90ZXMSGAoHdmVyc2lv'
    'bhgVIAEoA1IHdmVyc2lvbhIdCgpjcmVhdGVkX2J5GBYgASgJUgljcmVhdGVkQnkSOQoKY3JlYX'
    'RlZF9hdBgXIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1'
    'cGRhdGVkX2F0GBggASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZEF0Ei'
    'wKEm1hbmFnZW1lbnRfdW5pdF9pZBgZIAEoCVIQbWFuYWdlbWVudFVuaXRJZBIhCgxjcm9wX3Zh'
    'cmlldHkYGiABKAlSC2Nyb3BWYXJpZXR5Eh8KC3NlZWRfc291cmNlGBsgASgJUgpzZWVkU291cm'
    'Nl');

@$core.Deprecated('Use createCropCycleRequestDescriptor instead')
const CreateCropCycleRequest$json = {
  '1': 'CreateCropCycleRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 2, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'season', '3': 3, '4': 1, '5': 9, '10': 'season'},
    {'1': 'cycle_year', '3': 4, '4': 1, '5': 5, '10': 'cycleYear'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'planned_planting_date',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'plannedPlantingDate'
    },
    {
      '1': 'planned_harvest_date',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'plannedHarvestDate'
    },
    {
      '1': 'target_yield_per_hectare',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'targetYieldPerHectare'
    },
    {'1': 'yield_unit', '3': 9, '4': 1, '5': 9, '10': 'yieldUnit'},
    {'1': 'notes', '3': 10, '4': 1, '5': 9, '10': 'notes'},
    {
      '1': 'management_unit_id',
      '3': 11,
      '4': 1,
      '5': 9,
      '10': 'managementUnitId'
    },
    {'1': 'crop_variety', '3': 12, '4': 1, '5': 9, '10': 'cropVariety'},
    {'1': 'seed_source', '3': 13, '4': 1, '5': 9, '10': 'seedSource'},
  ],
};

/// Descriptor for `CreateCropCycleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCropCycleRequestDescriptor = $convert.base64Decode(
    'ChZDcmVhdGVDcm9wQ3ljbGVSZXF1ZXN0EhkKCGZpZWxkX2lkGAEgASgJUgdmaWVsZElkEhcKB2'
    'Nyb3BfaWQYAiABKAlSBmNyb3BJZBIWCgZzZWFzb24YAyABKAlSBnNlYXNvbhIdCgpjeWNsZV95'
    'ZWFyGAQgASgFUgljeWNsZVllYXISEgoEbmFtZRgFIAEoCVIEbmFtZRJOChVwbGFubmVkX3BsYW'
    '50aW5nX2RhdGUYBiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUhNwbGFubmVkUGxh'
    'bnRpbmdEYXRlEkwKFHBsYW5uZWRfaGFydmVzdF9kYXRlGAcgASgLMhouZ29vZ2xlLnByb3RvYn'
    'VmLlRpbWVzdGFtcFIScGxhbm5lZEhhcnZlc3REYXRlEjcKGHRhcmdldF95aWVsZF9wZXJfaGVj'
    'dGFyZRgIIAEoAVIVdGFyZ2V0WWllbGRQZXJIZWN0YXJlEh0KCnlpZWxkX3VuaXQYCSABKAlSCX'
    'lpZWxkVW5pdBIUCgVub3RlcxgKIAEoCVIFbm90ZXMSLAoSbWFuYWdlbWVudF91bml0X2lkGAsg'
    'ASgJUhBtYW5hZ2VtZW50VW5pdElkEiEKDGNyb3BfdmFyaWV0eRgMIAEoCVILY3JvcFZhcmlldH'
    'kSHwoLc2VlZF9zb3VyY2UYDSABKAlSCnNlZWRTb3VyY2U=');

@$core.Deprecated('Use createCropCycleResponseDescriptor instead')
const CreateCropCycleResponse$json = {
  '1': 'CreateCropCycleResponse',
  '2': [
    {
      '1': 'cycle',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.CropCycle',
      '10': 'cycle'
    },
  ],
};

/// Descriptor for `CreateCropCycleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCropCycleResponseDescriptor =
    $convert.base64Decode(
        'ChdDcmVhdGVDcm9wQ3ljbGVSZXNwb25zZRI1CgVjeWNsZRgBIAEoCzIfLmFncmljdWx0dXJlLm'
        'ZpZWxkLnYxLkNyb3BDeWNsZVIFY3ljbGU=');

@$core.Deprecated('Use getCropCycleRequestDescriptor instead')
const GetCropCycleRequest$json = {
  '1': 'GetCropCycleRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetCropCycleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCropCycleRequestDescriptor = $convert
    .base64Decode('ChNHZXRDcm9wQ3ljbGVSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use getCropCycleResponseDescriptor instead')
const GetCropCycleResponse$json = {
  '1': 'GetCropCycleResponse',
  '2': [
    {
      '1': 'cycle',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.CropCycle',
      '10': 'cycle'
    },
  ],
};

/// Descriptor for `GetCropCycleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCropCycleResponseDescriptor = $convert.base64Decode(
    'ChRHZXRDcm9wQ3ljbGVSZXNwb25zZRI1CgVjeWNsZRgBIAEoCzIfLmFncmljdWx0dXJlLmZpZW'
    'xkLnYxLkNyb3BDeWNsZVIFY3ljbGU=');

@$core.Deprecated('Use listCropCyclesRequestDescriptor instead')
const ListCropCyclesRequest$json = {
  '1': 'ListCropCyclesRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.CropCycleStatus',
      '10': 'status'
    },
    {'1': 'page_size', '3': 3, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 4, '4': 1, '5': 5, '10': 'pageOffset'},
    {
      '1': 'management_unit_id',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'managementUnitId'
    },
  ],
};

/// Descriptor for `ListCropCyclesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCropCyclesRequestDescriptor = $convert.base64Decode(
    'ChVMaXN0Q3JvcEN5Y2xlc1JlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQSPQoGc3'
    'RhdHVzGAIgASgOMiUuYWdyaWN1bHR1cmUuZmllbGQudjEuQ3JvcEN5Y2xlU3RhdHVzUgZzdGF0'
    'dXMSGwoJcGFnZV9zaXplGAMgASgFUghwYWdlU2l6ZRIfCgtwYWdlX29mZnNldBgEIAEoBVIKcG'
    'FnZU9mZnNldBIsChJtYW5hZ2VtZW50X3VuaXRfaWQYBSABKAlSEG1hbmFnZW1lbnRVbml0SWQ=');

@$core.Deprecated('Use listCropCyclesResponseDescriptor instead')
const ListCropCyclesResponse$json = {
  '1': 'ListCropCyclesResponse',
  '2': [
    {
      '1': 'cycles',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.v1.CropCycle',
      '10': 'cycles'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListCropCyclesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCropCyclesResponseDescriptor = $convert.base64Decode(
    'ChZMaXN0Q3JvcEN5Y2xlc1Jlc3BvbnNlEjcKBmN5Y2xlcxgBIAMoCzIfLmFncmljdWx0dXJlLm'
    'ZpZWxkLnYxLkNyb3BDeWNsZVIGY3ljbGVzEh8KC3RvdGFsX2NvdW50GAIgASgFUgp0b3RhbENv'
    'dW50');

@$core.Deprecated('Use updateCropCycleRequestDescriptor instead')
const UpdateCropCycleRequest$json = {
  '1': 'UpdateCropCycleRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.CropCycleStatus',
      '10': 'status'
    },
    {
      '1': 'actual_planting_date',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'actualPlantingDate'
    },
    {
      '1': 'actual_harvest_date',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'actualHarvestDate'
    },
    {
      '1': 'actual_yield_per_hectare',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'actualYieldPerHectare'
    },
    {'1': 'total_input_cost', '3': 6, '4': 1, '5': 3, '10': 'totalInputCost'},
    {'1': 'total_revenue', '3': 7, '4': 1, '5': 3, '10': 'totalRevenue'},
    {'1': 'notes', '3': 8, '4': 1, '5': 9, '10': 'notes'},
    {
      '1': 'update_mask',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
  ],
};

/// Descriptor for `UpdateCropCycleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateCropCycleRequestDescriptor = $convert.base64Decode(
    'ChZVcGRhdGVDcm9wQ3ljbGVSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBI9CgZzdGF0dXMYAiABKA'
    '4yJS5hZ3JpY3VsdHVyZS5maWVsZC52MS5Dcm9wQ3ljbGVTdGF0dXNSBnN0YXR1cxJMChRhY3R1'
    'YWxfcGxhbnRpbmdfZGF0ZRgDIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSEmFjdH'
    'VhbFBsYW50aW5nRGF0ZRJKChNhY3R1YWxfaGFydmVzdF9kYXRlGAQgASgLMhouZ29vZ2xlLnBy'
    'b3RvYnVmLlRpbWVzdGFtcFIRYWN0dWFsSGFydmVzdERhdGUSNwoYYWN0dWFsX3lpZWxkX3Blcl'
    '9oZWN0YXJlGAUgASgBUhVhY3R1YWxZaWVsZFBlckhlY3RhcmUSKAoQdG90YWxfaW5wdXRfY29z'
    'dBgGIAEoA1IOdG90YWxJbnB1dENvc3QSIwoNdG90YWxfcmV2ZW51ZRgHIAEoA1IMdG90YWxSZX'
    'ZlbnVlEhQKBW5vdGVzGAggASgJUgVub3RlcxI7Cgt1cGRhdGVfbWFzaxgJIAEoCzIaLmdvb2ds'
    'ZS5wcm90b2J1Zi5GaWVsZE1hc2tSCnVwZGF0ZU1hc2s=');

@$core.Deprecated('Use updateCropCycleResponseDescriptor instead')
const UpdateCropCycleResponse$json = {
  '1': 'UpdateCropCycleResponse',
  '2': [
    {
      '1': 'cycle',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.CropCycle',
      '10': 'cycle'
    },
  ],
};

/// Descriptor for `UpdateCropCycleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateCropCycleResponseDescriptor =
    $convert.base64Decode(
        'ChdVcGRhdGVDcm9wQ3ljbGVSZXNwb25zZRI1CgVjeWNsZRgBIAEoCzIfLmFncmljdWx0dXJlLm'
        'ZpZWxkLnYxLkNyb3BDeWNsZVIFY3ljbGU=');

@$core.Deprecated('Use activityEventDescriptor instead')
const ActivityEvent$json = {
  '1': 'ActivityEvent',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_cycle_id', '3': 4, '4': 1, '5': 9, '10': 'cropCycleId'},
    {'1': 'performed_by', '3': 5, '4': 1, '5': 9, '10': 'performedBy'},
    {'1': 'activity_type', '3': 6, '4': 1, '5': 9, '10': 'activityType'},
    {
      '1': 'category',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.ActivityCategory',
      '10': 'category'
    },
    {
      '1': 'started_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startedAt'
    },
    {
      '1': 'completed_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'completedAt'
    },
    {'1': 'duration_minutes', '3': 10, '4': 1, '5': 5, '10': 'durationMinutes'},
    {'1': 'description', '3': 11, '4': 1, '5': 9, '10': 'description'},
    {'1': 'notes', '3': 12, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'input_product_id', '3': 13, '4': 1, '5': 9, '10': 'inputProductId'},
    {'1': 'input_quantity', '3': 14, '4': 1, '5': 1, '10': 'inputQuantity'},
    {'1': 'input_unit', '3': 15, '4': 1, '5': 9, '10': 'inputUnit'},
    {'1': 'input_cost', '3': 16, '4': 1, '5': 3, '10': 'inputCost'},
    {'1': 'currency', '3': 17, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'area_hectares', '3': 18, '4': 1, '5': 1, '10': 'areaHectares'},
    {
      '1': 'weather_temp_celsius',
      '3': 19,
      '4': 1,
      '5': 1,
      '10': 'weatherTempCelsius'
    },
    {
      '1': 'weather_humidity_pct',
      '3': 20,
      '4': 1,
      '5': 1,
      '10': 'weatherHumidityPct'
    },
    {
      '1': 'weather_wind_speed_kmh',
      '3': 21,
      '4': 1,
      '5': 1,
      '10': 'weatherWindSpeedKmh'
    },
    {
      '1': 'weather_conditions',
      '3': 22,
      '4': 1,
      '5': 9,
      '10': 'weatherConditions'
    },
    {
      '1': 'created_at',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `ActivityEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activityEventDescriptor = $convert.base64Decode(
    'Cg1BY3Rpdml0eUV2ZW50Eg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbm'
    'FudElkEhkKCGZpZWxkX2lkGAMgASgJUgdmaWVsZElkEiIKDWNyb3BfY3ljbGVfaWQYBCABKAlS'
    'C2Nyb3BDeWNsZUlkEiEKDHBlcmZvcm1lZF9ieRgFIAEoCVILcGVyZm9ybWVkQnkSIwoNYWN0aX'
    'ZpdHlfdHlwZRgGIAEoCVIMYWN0aXZpdHlUeXBlEkIKCGNhdGVnb3J5GAcgASgOMiYuYWdyaWN1'
    'bHR1cmUuZmllbGQudjEuQWN0aXZpdHlDYXRlZ29yeVIIY2F0ZWdvcnkSOQoKc3RhcnRlZF9hdB'
    'gIIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXN0YXJ0ZWRBdBI9Cgxjb21wbGV0'
    'ZWRfYXQYCSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgtjb21wbGV0ZWRBdBIpCh'
    'BkdXJhdGlvbl9taW51dGVzGAogASgFUg9kdXJhdGlvbk1pbnV0ZXMSIAoLZGVzY3JpcHRpb24Y'
    'CyABKAlSC2Rlc2NyaXB0aW9uEhQKBW5vdGVzGAwgASgJUgVub3RlcxIoChBpbnB1dF9wcm9kdW'
    'N0X2lkGA0gASgJUg5pbnB1dFByb2R1Y3RJZBIlCg5pbnB1dF9xdWFudGl0eRgOIAEoAVINaW5w'
    'dXRRdWFudGl0eRIdCgppbnB1dF91bml0GA8gASgJUglpbnB1dFVuaXQSHQoKaW5wdXRfY29zdB'
    'gQIAEoA1IJaW5wdXRDb3N0EhoKCGN1cnJlbmN5GBEgASgJUghjdXJyZW5jeRIjCg1hcmVhX2hl'
    'Y3RhcmVzGBIgASgBUgxhcmVhSGVjdGFyZXMSMAoUd2VhdGhlcl90ZW1wX2NlbHNpdXMYEyABKA'
    'FSEndlYXRoZXJUZW1wQ2Vsc2l1cxIwChR3ZWF0aGVyX2h1bWlkaXR5X3BjdBgUIAEoAVISd2Vh'
    'dGhlckh1bWlkaXR5UGN0EjMKFndlYXRoZXJfd2luZF9zcGVlZF9rbWgYFSABKAFSE3dlYXRoZX'
    'JXaW5kU3BlZWRLbWgSLQoSd2VhdGhlcl9jb25kaXRpb25zGBYgASgJUhF3ZWF0aGVyQ29uZGl0'
    'aW9ucxI5CgpjcmVhdGVkX2F0GBcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3'
    'JlYXRlZEF0');

@$core.Deprecated('Use logActivityEventRequestDescriptor instead')
const LogActivityEventRequest$json = {
  '1': 'LogActivityEventRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_cycle_id', '3': 2, '4': 1, '5': 9, '10': 'cropCycleId'},
    {'1': 'activity_type', '3': 3, '4': 1, '5': 9, '10': 'activityType'},
    {
      '1': 'category',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.ActivityCategory',
      '10': 'category'
    },
    {
      '1': 'started_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startedAt'
    },
    {
      '1': 'completed_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'completedAt'
    },
    {'1': 'duration_minutes', '3': 7, '4': 1, '5': 5, '10': 'durationMinutes'},
    {'1': 'description', '3': 8, '4': 1, '5': 9, '10': 'description'},
    {'1': 'notes', '3': 9, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'input_product_id', '3': 10, '4': 1, '5': 9, '10': 'inputProductId'},
    {'1': 'input_quantity', '3': 11, '4': 1, '5': 1, '10': 'inputQuantity'},
    {'1': 'input_unit', '3': 12, '4': 1, '5': 9, '10': 'inputUnit'},
    {'1': 'input_cost', '3': 13, '4': 1, '5': 3, '10': 'inputCost'},
    {'1': 'currency', '3': 14, '4': 1, '5': 9, '10': 'currency'},
    {'1': 'area_hectares', '3': 15, '4': 1, '5': 1, '10': 'areaHectares'},
    {
      '1': 'weather_temp_celsius',
      '3': 16,
      '4': 1,
      '5': 1,
      '10': 'weatherTempCelsius'
    },
    {
      '1': 'weather_humidity_pct',
      '3': 17,
      '4': 1,
      '5': 1,
      '10': 'weatherHumidityPct'
    },
    {
      '1': 'weather_wind_speed_kmh',
      '3': 18,
      '4': 1,
      '5': 1,
      '10': 'weatherWindSpeedKmh'
    },
    {
      '1': 'weather_conditions',
      '3': 19,
      '4': 1,
      '5': 9,
      '10': 'weatherConditions'
    },
  ],
};

/// Descriptor for `LogActivityEventRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logActivityEventRequestDescriptor = $convert.base64Decode(
    'ChdMb2dBY3Rpdml0eUV2ZW50UmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBIiCg'
    '1jcm9wX2N5Y2xlX2lkGAIgASgJUgtjcm9wQ3ljbGVJZBIjCg1hY3Rpdml0eV90eXBlGAMgASgJ'
    'UgxhY3Rpdml0eVR5cGUSQgoIY2F0ZWdvcnkYBCABKA4yJi5hZ3JpY3VsdHVyZS5maWVsZC52MS'
    '5BY3Rpdml0eUNhdGVnb3J5UghjYXRlZ29yeRI5CgpzdGFydGVkX2F0GAUgASgLMhouZ29vZ2xl'
    'LnByb3RvYnVmLlRpbWVzdGFtcFIJc3RhcnRlZEF0Ej0KDGNvbXBsZXRlZF9hdBgGIAEoCzIaLm'
    'dvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSC2NvbXBsZXRlZEF0EikKEGR1cmF0aW9uX21pbnV0'
    'ZXMYByABKAVSD2R1cmF0aW9uTWludXRlcxIgCgtkZXNjcmlwdGlvbhgIIAEoCVILZGVzY3JpcH'
    'Rpb24SFAoFbm90ZXMYCSABKAlSBW5vdGVzEigKEGlucHV0X3Byb2R1Y3RfaWQYCiABKAlSDmlu'
    'cHV0UHJvZHVjdElkEiUKDmlucHV0X3F1YW50aXR5GAsgASgBUg1pbnB1dFF1YW50aXR5Eh0KCm'
    'lucHV0X3VuaXQYDCABKAlSCWlucHV0VW5pdBIdCgppbnB1dF9jb3N0GA0gASgDUglpbnB1dENv'
    'c3QSGgoIY3VycmVuY3kYDiABKAlSCGN1cnJlbmN5EiMKDWFyZWFfaGVjdGFyZXMYDyABKAFSDG'
    'FyZWFIZWN0YXJlcxIwChR3ZWF0aGVyX3RlbXBfY2Vsc2l1cxgQIAEoAVISd2VhdGhlclRlbXBD'
    'ZWxzaXVzEjAKFHdlYXRoZXJfaHVtaWRpdHlfcGN0GBEgASgBUhJ3ZWF0aGVySHVtaWRpdHlQY3'
    'QSMwoWd2VhdGhlcl93aW5kX3NwZWVkX2ttaBgSIAEoAVITd2VhdGhlcldpbmRTcGVlZEttaBIt'
    'ChJ3ZWF0aGVyX2NvbmRpdGlvbnMYEyABKAlSEXdlYXRoZXJDb25kaXRpb25z');

@$core.Deprecated('Use logActivityEventResponseDescriptor instead')
const LogActivityEventResponse$json = {
  '1': 'LogActivityEventResponse',
  '2': [
    {
      '1': 'event',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.ActivityEvent',
      '10': 'event'
    },
  ],
};

/// Descriptor for `LogActivityEventResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List logActivityEventResponseDescriptor =
    $convert.base64Decode(
        'ChhMb2dBY3Rpdml0eUV2ZW50UmVzcG9uc2USOQoFZXZlbnQYASABKAsyIy5hZ3JpY3VsdHVyZS'
        '5maWVsZC52MS5BY3Rpdml0eUV2ZW50UgVldmVudA==');

@$core.Deprecated('Use listActivityEventsRequestDescriptor instead')
const ListActivityEventsRequest$json = {
  '1': 'ListActivityEventsRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_cycle_id', '3': 2, '4': 1, '5': 9, '10': 'cropCycleId'},
    {
      '1': 'category',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.ActivityCategory',
      '10': 'category'
    },
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 5, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListActivityEventsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listActivityEventsRequestDescriptor = $convert.base64Decode(
    'ChlMaXN0QWN0aXZpdHlFdmVudHNSZXF1ZXN0EhkKCGZpZWxkX2lkGAEgASgJUgdmaWVsZElkEi'
    'IKDWNyb3BfY3ljbGVfaWQYAiABKAlSC2Nyb3BDeWNsZUlkEkIKCGNhdGVnb3J5GAMgASgOMiYu'
    'YWdyaWN1bHR1cmUuZmllbGQudjEuQWN0aXZpdHlDYXRlZ29yeVIIY2F0ZWdvcnkSGwoJcGFnZV'
    '9zaXplGAQgASgFUghwYWdlU2l6ZRIfCgtwYWdlX29mZnNldBgFIAEoBVIKcGFnZU9mZnNldA==');

@$core.Deprecated('Use listActivityEventsResponseDescriptor instead')
const ListActivityEventsResponse$json = {
  '1': 'ListActivityEventsResponse',
  '2': [
    {
      '1': 'events',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.v1.ActivityEvent',
      '10': 'events'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListActivityEventsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listActivityEventsResponseDescriptor =
    $convert.base64Decode(
        'ChpMaXN0QWN0aXZpdHlFdmVudHNSZXNwb25zZRI7CgZldmVudHMYASADKAsyIy5hZ3JpY3VsdH'
        'VyZS5maWVsZC52MS5BY3Rpdml0eUV2ZW50UgZldmVudHMSHwoLdG90YWxfY291bnQYAiABKAVS'
        'CnRvdGFsQ291bnQ=');

@$core.Deprecated('Use activityEvidenceDescriptor instead')
const ActivityEvidence$json = {
  '1': 'ActivityEvidence',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'activity_event_id', '3': 3, '4': 1, '5': 9, '10': 'activityEventId'},
    {
      '1': 'evidence_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.EvidenceType',
      '10': 'evidenceType'
    },
    {'1': 'file_url', '3': 5, '4': 1, '5': 9, '10': 'fileUrl'},
    {'1': 'file_name', '3': 6, '4': 1, '5': 9, '10': 'fileName'},
    {'1': 'file_size_bytes', '3': 7, '4': 1, '5': 3, '10': 'fileSizeBytes'},
    {'1': 'mime_type', '3': 8, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'thumbnail_url', '3': 9, '4': 1, '5': 9, '10': 'thumbnailUrl'},
    {'1': 'caption', '3': 10, '4': 1, '5': 9, '10': 'caption'},
    {'1': 'latitude', '3': 11, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 12, '4': 1, '5': 1, '10': 'longitude'},
    {
      '1': 'captured_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'capturedAt'
    },
    {'1': 'captured_by', '3': 14, '4': 1, '5': 9, '10': 'capturedBy'},
    {
      '1': 'created_at',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `ActivityEvidence`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activityEvidenceDescriptor = $convert.base64Decode(
    'ChBBY3Rpdml0eUV2aWRlbmNlEg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCH'
    'RlbmFudElkEioKEWFjdGl2aXR5X2V2ZW50X2lkGAMgASgJUg9hY3Rpdml0eUV2ZW50SWQSRwoN'
    'ZXZpZGVuY2VfdHlwZRgEIAEoDjIiLmFncmljdWx0dXJlLmZpZWxkLnYxLkV2aWRlbmNlVHlwZV'
    'IMZXZpZGVuY2VUeXBlEhkKCGZpbGVfdXJsGAUgASgJUgdmaWxlVXJsEhsKCWZpbGVfbmFtZRgG'
    'IAEoCVIIZmlsZU5hbWUSJgoPZmlsZV9zaXplX2J5dGVzGAcgASgDUg1maWxlU2l6ZUJ5dGVzEh'
    'sKCW1pbWVfdHlwZRgIIAEoCVIIbWltZVR5cGUSIwoNdGh1bWJuYWlsX3VybBgJIAEoCVIMdGh1'
    'bWJuYWlsVXJsEhgKB2NhcHRpb24YCiABKAlSB2NhcHRpb24SGgoIbGF0aXR1ZGUYCyABKAFSCG'
    'xhdGl0dWRlEhwKCWxvbmdpdHVkZRgMIAEoAVIJbG9uZ2l0dWRlEjsKC2NhcHR1cmVkX2F0GA0g'
    'ASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIKY2FwdHVyZWRBdBIfCgtjYXB0dXJlZF'
    '9ieRgOIAEoCVIKY2FwdHVyZWRCeRI5CgpjcmVhdGVkX2F0GA8gASgLMhouZ29vZ2xlLnByb3Rv'
    'YnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use addActivityEvidenceRequestDescriptor instead')
const AddActivityEvidenceRequest$json = {
  '1': 'AddActivityEvidenceRequest',
  '2': [
    {'1': 'activity_event_id', '3': 1, '4': 1, '5': 9, '10': 'activityEventId'},
    {
      '1': 'evidence_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.field.v1.EvidenceType',
      '10': 'evidenceType'
    },
    {'1': 'file_url', '3': 3, '4': 1, '5': 9, '10': 'fileUrl'},
    {'1': 'file_name', '3': 4, '4': 1, '5': 9, '10': 'fileName'},
    {'1': 'file_size_bytes', '3': 5, '4': 1, '5': 3, '10': 'fileSizeBytes'},
    {'1': 'mime_type', '3': 6, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'thumbnail_url', '3': 7, '4': 1, '5': 9, '10': 'thumbnailUrl'},
    {'1': 'caption', '3': 8, '4': 1, '5': 9, '10': 'caption'},
    {'1': 'latitude', '3': 9, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 10, '4': 1, '5': 1, '10': 'longitude'},
    {
      '1': 'captured_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'capturedAt'
    },
  ],
};

/// Descriptor for `AddActivityEvidenceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addActivityEvidenceRequestDescriptor = $convert.base64Decode(
    'ChpBZGRBY3Rpdml0eUV2aWRlbmNlUmVxdWVzdBIqChFhY3Rpdml0eV9ldmVudF9pZBgBIAEoCV'
    'IPYWN0aXZpdHlFdmVudElkEkcKDWV2aWRlbmNlX3R5cGUYAiABKA4yIi5hZ3JpY3VsdHVyZS5m'
    'aWVsZC52MS5FdmlkZW5jZVR5cGVSDGV2aWRlbmNlVHlwZRIZCghmaWxlX3VybBgDIAEoCVIHZm'
    'lsZVVybBIbCglmaWxlX25hbWUYBCABKAlSCGZpbGVOYW1lEiYKD2ZpbGVfc2l6ZV9ieXRlcxgF'
    'IAEoA1INZmlsZVNpemVCeXRlcxIbCgltaW1lX3R5cGUYBiABKAlSCG1pbWVUeXBlEiMKDXRodW'
    '1ibmFpbF91cmwYByABKAlSDHRodW1ibmFpbFVybBIYCgdjYXB0aW9uGAggASgJUgdjYXB0aW9u'
    'EhoKCGxhdGl0dWRlGAkgASgBUghsYXRpdHVkZRIcCglsb25naXR1ZGUYCiABKAFSCWxvbmdpdH'
    'VkZRI7CgtjYXB0dXJlZF9hdBgLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCmNh'
    'cHR1cmVkQXQ=');

@$core.Deprecated('Use addActivityEvidenceResponseDescriptor instead')
const AddActivityEvidenceResponse$json = {
  '1': 'AddActivityEvidenceResponse',
  '2': [
    {
      '1': 'evidence',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.v1.ActivityEvidence',
      '10': 'evidence'
    },
  ],
};

/// Descriptor for `AddActivityEvidenceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addActivityEvidenceResponseDescriptor =
    $convert.base64Decode(
        'ChtBZGRBY3Rpdml0eUV2aWRlbmNlUmVzcG9uc2USQgoIZXZpZGVuY2UYASABKAsyJi5hZ3JpY3'
        'VsdHVyZS5maWVsZC52MS5BY3Rpdml0eUV2aWRlbmNlUghldmlkZW5jZQ==');

@$core.Deprecated('Use listActivityEvidenceRequestDescriptor instead')
const ListActivityEvidenceRequest$json = {
  '1': 'ListActivityEvidenceRequest',
  '2': [
    {'1': 'activity_event_id', '3': 1, '4': 1, '5': 9, '10': 'activityEventId'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 3, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListActivityEvidenceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listActivityEvidenceRequestDescriptor =
    $convert.base64Decode(
        'ChtMaXN0QWN0aXZpdHlFdmlkZW5jZVJlcXVlc3QSKgoRYWN0aXZpdHlfZXZlbnRfaWQYASABKA'
        'lSD2FjdGl2aXR5RXZlbnRJZBIbCglwYWdlX3NpemUYAiABKAVSCHBhZ2VTaXplEh8KC3BhZ2Vf'
        'b2Zmc2V0GAMgASgFUgpwYWdlT2Zmc2V0');

@$core.Deprecated('Use listActivityEvidenceResponseDescriptor instead')
const ListActivityEvidenceResponse$json = {
  '1': 'ListActivityEvidenceResponse',
  '2': [
    {
      '1': 'evidence',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.v1.ActivityEvidence',
      '10': 'evidence'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListActivityEvidenceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listActivityEvidenceResponseDescriptor =
    $convert.base64Decode(
        'ChxMaXN0QWN0aXZpdHlFdmlkZW5jZVJlc3BvbnNlEkIKCGV2aWRlbmNlGAEgAygLMiYuYWdyaW'
        'N1bHR1cmUuZmllbGQudjEuQWN0aXZpdHlFdmlkZW5jZVIIZXZpZGVuY2USHwoLdG90YWxfY291'
        'bnQYAiABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use deleteActivityEvidenceRequestDescriptor instead')
const DeleteActivityEvidenceRequest$json = {
  '1': 'DeleteActivityEvidenceRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteActivityEvidenceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteActivityEvidenceRequestDescriptor =
    $convert.base64Decode(
        'Ch1EZWxldGVBY3Rpdml0eUV2aWRlbmNlUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use deleteActivityEvidenceResponseDescriptor instead')
const DeleteActivityEvidenceResponse$json = {
  '1': 'DeleteActivityEvidenceResponse',
};

/// Descriptor for `DeleteActivityEvidenceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteActivityEvidenceResponseDescriptor =
    $convert.base64Decode('Ch5EZWxldGVBY3Rpdml0eUV2aWRlbmNlUmVzcG9uc2U=');

const $core.Map<$core.String, $core.dynamic> FieldServiceBase$json = {
  '1': 'FieldService',
  '2': [
    {
      '1': 'CreateField',
      '2': '.agriculture.field.v1.CreateFieldRequest',
      '3': '.agriculture.field.v1.CreateFieldResponse'
    },
    {
      '1': 'GetField',
      '2': '.agriculture.field.v1.GetFieldRequest',
      '3': '.agriculture.field.v1.GetFieldResponse'
    },
    {
      '1': 'ListFields',
      '2': '.agriculture.field.v1.ListFieldsRequest',
      '3': '.agriculture.field.v1.ListFieldsResponse'
    },
    {
      '1': 'UpdateField',
      '2': '.agriculture.field.v1.UpdateFieldRequest',
      '3': '.agriculture.field.v1.UpdateFieldResponse'
    },
    {
      '1': 'DeleteField',
      '2': '.agriculture.field.v1.DeleteFieldRequest',
      '3': '.agriculture.field.v1.DeleteFieldResponse'
    },
    {
      '1': 'SetFieldBoundary',
      '2': '.agriculture.field.v1.SetFieldBoundaryRequest',
      '3': '.agriculture.field.v1.SetFieldBoundaryResponse'
    },
    {
      '1': 'AssignCrop',
      '2': '.agriculture.field.v1.AssignCropRequest',
      '3': '.agriculture.field.v1.AssignCropResponse'
    },
    {
      '1': 'ListFieldsByFarm',
      '2': '.agriculture.field.v1.ListFieldsByFarmRequest',
      '3': '.agriculture.field.v1.ListFieldsByFarmResponse'
    },
    {
      '1': 'SegmentField',
      '2': '.agriculture.field.v1.SegmentFieldRequest',
      '3': '.agriculture.field.v1.SegmentFieldResponse'
    },
    {
      '1': 'GetFieldSegments',
      '2': '.agriculture.field.v1.GetFieldSegmentsRequest',
      '3': '.agriculture.field.v1.GetFieldSegmentsResponse'
    },
    {
      '1': 'GetCropHistory',
      '2': '.agriculture.field.v1.GetCropHistoryRequest',
      '3': '.agriculture.field.v1.GetCropHistoryResponse'
    },
    {
      '1': 'CreateCropCycle',
      '2': '.agriculture.field.v1.CreateCropCycleRequest',
      '3': '.agriculture.field.v1.CreateCropCycleResponse'
    },
    {
      '1': 'GetCropCycle',
      '2': '.agriculture.field.v1.GetCropCycleRequest',
      '3': '.agriculture.field.v1.GetCropCycleResponse'
    },
    {
      '1': 'ListCropCycles',
      '2': '.agriculture.field.v1.ListCropCyclesRequest',
      '3': '.agriculture.field.v1.ListCropCyclesResponse'
    },
    {
      '1': 'UpdateCropCycle',
      '2': '.agriculture.field.v1.UpdateCropCycleRequest',
      '3': '.agriculture.field.v1.UpdateCropCycleResponse'
    },
    {
      '1': 'LogActivityEvent',
      '2': '.agriculture.field.v1.LogActivityEventRequest',
      '3': '.agriculture.field.v1.LogActivityEventResponse'
    },
    {
      '1': 'ListActivityEvents',
      '2': '.agriculture.field.v1.ListActivityEventsRequest',
      '3': '.agriculture.field.v1.ListActivityEventsResponse'
    },
    {
      '1': 'AddActivityEvidence',
      '2': '.agriculture.field.v1.AddActivityEvidenceRequest',
      '3': '.agriculture.field.v1.AddActivityEvidenceResponse'
    },
    {
      '1': 'ListActivityEvidence',
      '2': '.agriculture.field.v1.ListActivityEvidenceRequest',
      '3': '.agriculture.field.v1.ListActivityEvidenceResponse'
    },
    {
      '1': 'DeleteActivityEvidence',
      '2': '.agriculture.field.v1.DeleteActivityEvidenceRequest',
      '3': '.agriculture.field.v1.DeleteActivityEvidenceResponse'
    },
  ],
};

@$core.Deprecated('Use fieldServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    FieldServiceBase$messageJson = {
  '.agriculture.field.v1.CreateFieldRequest': CreateFieldRequest$json,
  '.agriculture.field.v1.GeoPolygon': GeoPolygon$json,
  '.agriculture.field.v1.GeoPoint': GeoPoint$json,
  '.agriculture.field.v1.CreateFieldResponse': CreateFieldResponse$json,
  '.agriculture.field.v1.Field': Field$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.field.v1.GetFieldRequest': GetFieldRequest$json,
  '.agriculture.field.v1.GetFieldResponse': GetFieldResponse$json,
  '.agriculture.field.v1.ListFieldsRequest': ListFieldsRequest$json,
  '.agriculture.field.v1.ListFieldsResponse': ListFieldsResponse$json,
  '.agriculture.field.v1.UpdateFieldRequest': UpdateFieldRequest$json,
  '.google.protobuf.FieldMask': $1.FieldMask$json,
  '.agriculture.field.v1.UpdateFieldResponse': UpdateFieldResponse$json,
  '.agriculture.field.v1.DeleteFieldRequest': DeleteFieldRequest$json,
  '.agriculture.field.v1.DeleteFieldResponse': DeleteFieldResponse$json,
  '.agriculture.field.v1.SetFieldBoundaryRequest': SetFieldBoundaryRequest$json,
  '.agriculture.field.v1.SetFieldBoundaryResponse':
      SetFieldBoundaryResponse$json,
  '.agriculture.field.v1.FieldBoundary': FieldBoundary$json,
  '.agriculture.field.v1.AssignCropRequest': AssignCropRequest$json,
  '.agriculture.field.v1.AssignCropResponse': AssignCropResponse$json,
  '.agriculture.field.v1.FieldCropAssignment': FieldCropAssignment$json,
  '.agriculture.field.v1.ListFieldsByFarmRequest': ListFieldsByFarmRequest$json,
  '.agriculture.field.v1.ListFieldsByFarmResponse':
      ListFieldsByFarmResponse$json,
  '.agriculture.field.v1.SegmentFieldRequest': SegmentFieldRequest$json,
  '.agriculture.field.v1.FieldSegmentInput': FieldSegmentInput$json,
  '.agriculture.field.v1.SegmentFieldResponse': SegmentFieldResponse$json,
  '.agriculture.field.v1.FieldSegment': FieldSegment$json,
  '.agriculture.field.v1.GetFieldSegmentsRequest': GetFieldSegmentsRequest$json,
  '.agriculture.field.v1.GetFieldSegmentsResponse':
      GetFieldSegmentsResponse$json,
  '.agriculture.field.v1.GetCropHistoryRequest': GetCropHistoryRequest$json,
  '.agriculture.field.v1.GetCropHistoryResponse': GetCropHistoryResponse$json,
  '.agriculture.field.v1.CreateCropCycleRequest': CreateCropCycleRequest$json,
  '.agriculture.field.v1.CreateCropCycleResponse': CreateCropCycleResponse$json,
  '.agriculture.field.v1.CropCycle': CropCycle$json,
  '.agriculture.field.v1.GetCropCycleRequest': GetCropCycleRequest$json,
  '.agriculture.field.v1.GetCropCycleResponse': GetCropCycleResponse$json,
  '.agriculture.field.v1.ListCropCyclesRequest': ListCropCyclesRequest$json,
  '.agriculture.field.v1.ListCropCyclesResponse': ListCropCyclesResponse$json,
  '.agriculture.field.v1.UpdateCropCycleRequest': UpdateCropCycleRequest$json,
  '.agriculture.field.v1.UpdateCropCycleResponse': UpdateCropCycleResponse$json,
  '.agriculture.field.v1.LogActivityEventRequest': LogActivityEventRequest$json,
  '.agriculture.field.v1.LogActivityEventResponse':
      LogActivityEventResponse$json,
  '.agriculture.field.v1.ActivityEvent': ActivityEvent$json,
  '.agriculture.field.v1.ListActivityEventsRequest':
      ListActivityEventsRequest$json,
  '.agriculture.field.v1.ListActivityEventsResponse':
      ListActivityEventsResponse$json,
  '.agriculture.field.v1.AddActivityEvidenceRequest':
      AddActivityEvidenceRequest$json,
  '.agriculture.field.v1.AddActivityEvidenceResponse':
      AddActivityEvidenceResponse$json,
  '.agriculture.field.v1.ActivityEvidence': ActivityEvidence$json,
  '.agriculture.field.v1.ListActivityEvidenceRequest':
      ListActivityEvidenceRequest$json,
  '.agriculture.field.v1.ListActivityEvidenceResponse':
      ListActivityEvidenceResponse$json,
  '.agriculture.field.v1.DeleteActivityEvidenceRequest':
      DeleteActivityEvidenceRequest$json,
  '.agriculture.field.v1.DeleteActivityEvidenceResponse':
      DeleteActivityEvidenceResponse$json,
};

/// Descriptor for `FieldService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List fieldServiceDescriptor = $convert.base64Decode(
    'CgxGaWVsZFNlcnZpY2USYgoLQ3JlYXRlRmllbGQSKC5hZ3JpY3VsdHVyZS5maWVsZC52MS5Dcm'
    'VhdGVGaWVsZFJlcXVlc3QaKS5hZ3JpY3VsdHVyZS5maWVsZC52MS5DcmVhdGVGaWVsZFJlc3Bv'
    'bnNlElkKCEdldEZpZWxkEiUuYWdyaWN1bHR1cmUuZmllbGQudjEuR2V0RmllbGRSZXF1ZXN0Gi'
    'YuYWdyaWN1bHR1cmUuZmllbGQudjEuR2V0RmllbGRSZXNwb25zZRJfCgpMaXN0RmllbGRzEicu'
    'YWdyaWN1bHR1cmUuZmllbGQudjEuTGlzdEZpZWxkc1JlcXVlc3QaKC5hZ3JpY3VsdHVyZS5maW'
    'VsZC52MS5MaXN0RmllbGRzUmVzcG9uc2USYgoLVXBkYXRlRmllbGQSKC5hZ3JpY3VsdHVyZS5m'
    'aWVsZC52MS5VcGRhdGVGaWVsZFJlcXVlc3QaKS5hZ3JpY3VsdHVyZS5maWVsZC52MS5VcGRhdG'
    'VGaWVsZFJlc3BvbnNlEmIKC0RlbGV0ZUZpZWxkEiguYWdyaWN1bHR1cmUuZmllbGQudjEuRGVs'
    'ZXRlRmllbGRSZXF1ZXN0GikuYWdyaWN1bHR1cmUuZmllbGQudjEuRGVsZXRlRmllbGRSZXNwb2'
    '5zZRJxChBTZXRGaWVsZEJvdW5kYXJ5Ei0uYWdyaWN1bHR1cmUuZmllbGQudjEuU2V0RmllbGRC'
    'b3VuZGFyeVJlcXVlc3QaLi5hZ3JpY3VsdHVyZS5maWVsZC52MS5TZXRGaWVsZEJvdW5kYXJ5Um'
    'VzcG9uc2USXwoKQXNzaWduQ3JvcBInLmFncmljdWx0dXJlLmZpZWxkLnYxLkFzc2lnbkNyb3BS'
    'ZXF1ZXN0GiguYWdyaWN1bHR1cmUuZmllbGQudjEuQXNzaWduQ3JvcFJlc3BvbnNlEnEKEExpc3'
    'RGaWVsZHNCeUZhcm0SLS5hZ3JpY3VsdHVyZS5maWVsZC52MS5MaXN0RmllbGRzQnlGYXJtUmVx'
    'dWVzdBouLmFncmljdWx0dXJlLmZpZWxkLnYxLkxpc3RGaWVsZHNCeUZhcm1SZXNwb25zZRJlCg'
    'xTZWdtZW50RmllbGQSKS5hZ3JpY3VsdHVyZS5maWVsZC52MS5TZWdtZW50RmllbGRSZXF1ZXN0'
    'GiouYWdyaWN1bHR1cmUuZmllbGQudjEuU2VnbWVudEZpZWxkUmVzcG9uc2UScQoQR2V0RmllbG'
    'RTZWdtZW50cxItLmFncmljdWx0dXJlLmZpZWxkLnYxLkdldEZpZWxkU2VnbWVudHNSZXF1ZXN0'
    'Gi4uYWdyaWN1bHR1cmUuZmllbGQudjEuR2V0RmllbGRTZWdtZW50c1Jlc3BvbnNlEmsKDkdldE'
    'Nyb3BIaXN0b3J5EisuYWdyaWN1bHR1cmUuZmllbGQudjEuR2V0Q3JvcEhpc3RvcnlSZXF1ZXN0'
    'GiwuYWdyaWN1bHR1cmUuZmllbGQudjEuR2V0Q3JvcEhpc3RvcnlSZXNwb25zZRJuCg9DcmVhdG'
    'VDcm9wQ3ljbGUSLC5hZ3JpY3VsdHVyZS5maWVsZC52MS5DcmVhdGVDcm9wQ3ljbGVSZXF1ZXN0'
    'Gi0uYWdyaWN1bHR1cmUuZmllbGQudjEuQ3JlYXRlQ3JvcEN5Y2xlUmVzcG9uc2USZQoMR2V0Q3'
    'JvcEN5Y2xlEikuYWdyaWN1bHR1cmUuZmllbGQudjEuR2V0Q3JvcEN5Y2xlUmVxdWVzdBoqLmFn'
    'cmljdWx0dXJlLmZpZWxkLnYxLkdldENyb3BDeWNsZVJlc3BvbnNlEmsKDkxpc3RDcm9wQ3ljbG'
    'VzEisuYWdyaWN1bHR1cmUuZmllbGQudjEuTGlzdENyb3BDeWNsZXNSZXF1ZXN0GiwuYWdyaWN1'
    'bHR1cmUuZmllbGQudjEuTGlzdENyb3BDeWNsZXNSZXNwb25zZRJuCg9VcGRhdGVDcm9wQ3ljbG'
    'USLC5hZ3JpY3VsdHVyZS5maWVsZC52MS5VcGRhdGVDcm9wQ3ljbGVSZXF1ZXN0Gi0uYWdyaWN1'
    'bHR1cmUuZmllbGQudjEuVXBkYXRlQ3JvcEN5Y2xlUmVzcG9uc2UScQoQTG9nQWN0aXZpdHlFdm'
    'VudBItLmFncmljdWx0dXJlLmZpZWxkLnYxLkxvZ0FjdGl2aXR5RXZlbnRSZXF1ZXN0Gi4uYWdy'
    'aWN1bHR1cmUuZmllbGQudjEuTG9nQWN0aXZpdHlFdmVudFJlc3BvbnNlEncKEkxpc3RBY3Rpdm'
    'l0eUV2ZW50cxIvLmFncmljdWx0dXJlLmZpZWxkLnYxLkxpc3RBY3Rpdml0eUV2ZW50c1JlcXVl'
    'c3QaMC5hZ3JpY3VsdHVyZS5maWVsZC52MS5MaXN0QWN0aXZpdHlFdmVudHNSZXNwb25zZRJ6Ch'
    'NBZGRBY3Rpdml0eUV2aWRlbmNlEjAuYWdyaWN1bHR1cmUuZmllbGQudjEuQWRkQWN0aXZpdHlF'
    'dmlkZW5jZVJlcXVlc3QaMS5hZ3JpY3VsdHVyZS5maWVsZC52MS5BZGRBY3Rpdml0eUV2aWRlbm'
    'NlUmVzcG9uc2USfQoUTGlzdEFjdGl2aXR5RXZpZGVuY2USMS5hZ3JpY3VsdHVyZS5maWVsZC52'
    'MS5MaXN0QWN0aXZpdHlFdmlkZW5jZVJlcXVlc3QaMi5hZ3JpY3VsdHVyZS5maWVsZC52MS5MaX'
    'N0QWN0aXZpdHlFdmlkZW5jZVJlc3BvbnNlEoMBChZEZWxldGVBY3Rpdml0eUV2aWRlbmNlEjMu'
    'YWdyaWN1bHR1cmUuZmllbGQudjEuRGVsZXRlQWN0aXZpdHlFdmlkZW5jZVJlcXVlc3QaNC5hZ3'
    'JpY3VsdHVyZS5maWVsZC52MS5EZWxldGVBY3Rpdml0eUV2aWRlbmNlUmVzcG9uc2U=');
