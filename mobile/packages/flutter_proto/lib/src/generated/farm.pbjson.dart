// This is a generated file - do not edit.
//
// Generated from farm.proto.

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

@$core.Deprecated('Use farmTypeDescriptor instead')
const FarmType$json = {
  '1': 'FarmType',
  '2': [
    {'1': 'FARM_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'FARM_TYPE_CROP', '2': 1},
    {'1': 'FARM_TYPE_LIVESTOCK', '2': 2},
    {'1': 'FARM_TYPE_MIXED', '2': 3},
    {'1': 'FARM_TYPE_AQUACULTURE', '2': 4},
  ],
};

/// Descriptor for `FarmType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List farmTypeDescriptor = $convert.base64Decode(
    'CghGYXJtVHlwZRIZChVGQVJNX1RZUEVfVU5TUEVDSUZJRUQQABISCg5GQVJNX1RZUEVfQ1JPUB'
    'ABEhcKE0ZBUk1fVFlQRV9MSVZFU1RPQ0sQAhITCg9GQVJNX1RZUEVfTUlYRUQQAxIZChVGQVJN'
    'X1RZUEVfQVFVQUNVTFRVUkUQBA==');

@$core.Deprecated('Use farmStatusDescriptor instead')
const FarmStatus$json = {
  '1': 'FarmStatus',
  '2': [
    {'1': 'FARM_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'FARM_STATUS_ACTIVE', '2': 1},
    {'1': 'FARM_STATUS_INACTIVE', '2': 2},
    {'1': 'FARM_STATUS_PENDING', '2': 3},
    {'1': 'FARM_STATUS_SUSPENDED', '2': 4},
    {'1': 'FARM_STATUS_ARCHIVED', '2': 5},
  ],
};

/// Descriptor for `FarmStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List farmStatusDescriptor = $convert.base64Decode(
    'CgpGYXJtU3RhdHVzEhsKF0ZBUk1fU1RBVFVTX1VOU1BFQ0lGSUVEEAASFgoSRkFSTV9TVEFUVV'
    'NfQUNUSVZFEAESGAoURkFSTV9TVEFUVVNfSU5BQ1RJVkUQAhIXChNGQVJNX1NUQVRVU19QRU5E'
    'SU5HEAMSGQoVRkFSTV9TVEFUVVNfU1VTUEVOREVEEAQSGAoURkFSTV9TVEFUVVNfQVJDSElWRU'
    'QQBQ==');

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
    {'1': 'SOIL_TYPE_CHALKY', '2': 6},
    {'1': 'SOIL_TYPE_LATERITE', '2': 7},
    {'1': 'SOIL_TYPE_BLACK', '2': 8},
    {'1': 'SOIL_TYPE_RED', '2': 9},
    {'1': 'SOIL_TYPE_ALLUVIAL', '2': 10},
  ],
};

/// Descriptor for `SoilType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List soilTypeDescriptor = $convert.base64Decode(
    'CghTb2lsVHlwZRIZChVTT0lMX1RZUEVfVU5TUEVDSUZJRUQQABISCg5TT0lMX1RZUEVfQ0xBWR'
    'ABEhMKD1NPSUxfVFlQRV9TQU5EWRACEhMKD1NPSUxfVFlQRV9MT0FNWRADEhIKDlNPSUxfVFlQ'
    'RV9TSUxUEAQSEgoOU09JTF9UWVBFX1BFQVQQBRIUChBTT0lMX1RZUEVfQ0hBTEtZEAYSFgoSU0'
    '9JTF9UWVBFX0xBVEVSSVRFEAcSEwoPU09JTF9UWVBFX0JMQUNLEAgSEQoNU09JTF9UWVBFX1JF'
    'RBAJEhYKElNPSUxfVFlQRV9BTExVVklBTBAK');

@$core.Deprecated('Use climateZoneDescriptor instead')
const ClimateZone$json = {
  '1': 'ClimateZone',
  '2': [
    {'1': 'CLIMATE_ZONE_UNSPECIFIED', '2': 0},
    {'1': 'CLIMATE_ZONE_TROPICAL', '2': 1},
    {'1': 'CLIMATE_ZONE_SUBTROPICAL', '2': 2},
    {'1': 'CLIMATE_ZONE_ARID', '2': 3},
    {'1': 'CLIMATE_ZONE_SEMIARID', '2': 4},
    {'1': 'CLIMATE_ZONE_TEMPERATE', '2': 5},
    {'1': 'CLIMATE_ZONE_CONTINENTAL', '2': 6},
    {'1': 'CLIMATE_ZONE_POLAR', '2': 7},
    {'1': 'CLIMATE_ZONE_MEDITERRANEAN', '2': 8},
    {'1': 'CLIMATE_ZONE_MONSOON', '2': 9},
  ],
};

/// Descriptor for `ClimateZone`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List climateZoneDescriptor = $convert.base64Decode(
    'CgtDbGltYXRlWm9uZRIcChhDTElNQVRFX1pPTkVfVU5TUEVDSUZJRUQQABIZChVDTElNQVRFX1'
    'pPTkVfVFJPUElDQUwQARIcChhDTElNQVRFX1pPTkVfU1VCVFJPUElDQUwQAhIVChFDTElNQVRF'
    'X1pPTkVfQVJJRBADEhkKFUNMSU1BVEVfWk9ORV9TRU1JQVJJRBAEEhoKFkNMSU1BVEVfWk9ORV'
    '9URU1QRVJBVEUQBRIcChhDTElNQVRFX1pPTkVfQ09OVElORU5UQUwQBhIWChJDTElNQVRFX1pP'
    'TkVfUE9MQVIQBxIeChpDTElNQVRFX1pPTkVfTUVESVRFUlJBTkVBThAIEhgKFENMSU1BVEVfWk'
    '9ORV9NT05TT09OEAk=');

@$core.Deprecated('Use farmLocationDescriptor instead')
const FarmLocation$json = {
  '1': 'FarmLocation',
  '2': [
    {'1': 'latitude', '3': 1, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 2, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'elevation_meters', '3': 3, '4': 1, '5': 1, '10': 'elevationMeters'},
  ],
};

/// Descriptor for `FarmLocation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List farmLocationDescriptor = $convert.base64Decode(
    'CgxGYXJtTG9jYXRpb24SGgoIbGF0aXR1ZGUYASABKAFSCGxhdGl0dWRlEhwKCWxvbmdpdHVkZR'
    'gCIAEoAVIJbG9uZ2l0dWRlEikKEGVsZXZhdGlvbl9tZXRlcnMYAyABKAFSD2VsZXZhdGlvbk1l'
    'dGVycw==');

@$core.Deprecated('Use farmBoundaryDescriptor instead')
const FarmBoundary$json = {
  '1': 'FarmBoundary',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'geojson', '3': 3, '4': 1, '5': 9, '10': 'geojson'},
    {'1': 'area_hectares', '3': 4, '4': 1, '5': 1, '10': 'areaHectares'},
    {'1': 'perimeter_meters', '3': 5, '4': 1, '5': 1, '10': 'perimeterMeters'},
    {
      '1': 'created_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `FarmBoundary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List farmBoundaryDescriptor = $convert.base64Decode(
    'CgxGYXJtQm91bmRhcnkSDgoCaWQYASABKAlSAmlkEhcKB2Zhcm1faWQYAiABKAlSBmZhcm1JZB'
    'IYCgdnZW9qc29uGAMgASgJUgdnZW9qc29uEiMKDWFyZWFfaGVjdGFyZXMYBCABKAFSDGFyZWFI'
    'ZWN0YXJlcxIpChBwZXJpbWV0ZXJfbWV0ZXJzGAUgASgBUg9wZXJpbWV0ZXJNZXRlcnMSOQoKY3'
    'JlYXRlZF9hdBgGIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5'
    'Cgp1cGRhdGVkX2F0GAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZE'
    'F0');

@$core.Deprecated('Use farmOwnerDescriptor instead')
const FarmOwner$json = {
  '1': 'FarmOwner',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'user_id', '3': 3, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'owner_name', '3': 4, '4': 1, '5': 9, '10': 'ownerName'},
    {'1': 'email', '3': 5, '4': 1, '5': 9, '10': 'email'},
    {'1': 'phone', '3': 6, '4': 1, '5': 9, '10': 'phone'},
    {'1': 'is_primary', '3': 7, '4': 1, '5': 8, '10': 'isPrimary'},
    {
      '1': 'ownership_percentage',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'ownershipPercentage'
    },
    {
      '1': 'acquired_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'acquiredAt'
    },
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

/// Descriptor for `FarmOwner`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List farmOwnerDescriptor = $convert.base64Decode(
    'CglGYXJtT3duZXISDgoCaWQYASABKAlSAmlkEhcKB2Zhcm1faWQYAiABKAlSBmZhcm1JZBIXCg'
    'd1c2VyX2lkGAMgASgJUgZ1c2VySWQSHQoKb3duZXJfbmFtZRgEIAEoCVIJb3duZXJOYW1lEhQK'
    'BWVtYWlsGAUgASgJUgVlbWFpbBIUCgVwaG9uZRgGIAEoCVIFcGhvbmUSHQoKaXNfcHJpbWFyeR'
    'gHIAEoCFIJaXNQcmltYXJ5EjEKFG93bmVyc2hpcF9wZXJjZW50YWdlGAggASgBUhNvd25lcnNo'
    'aXBQZXJjZW50YWdlEjsKC2FjcXVpcmVkX2F0GAkgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbW'
    'VzdGFtcFIKYWNxdWlyZWRBdBI5CgpjcmVhdGVkX2F0GAogASgLMhouZ29vZ2xlLnByb3RvYnVm'
    'LlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYCyABKAsyGi5nb29nbGUucHJvdG'
    '9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use farmDescriptor instead')
const Farm$json = {
  '1': 'Farm',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'total_area_hectares',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'totalAreaHectares'
    },
    {
      '1': 'location',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.agriculture.farm.v1.FarmLocation',
      '10': 'location'
    },
    {
      '1': 'farm_type',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.farm.v1.FarmType',
      '10': 'farmType'
    },
    {
      '1': 'status',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.agriculture.farm.v1.FarmStatus',
      '10': 'status'
    },
    {
      '1': 'soil_type',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.agriculture.farm.v1.SoilType',
      '10': 'soilType'
    },
    {
      '1': 'climate_zone',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.agriculture.farm.v1.ClimateZone',
      '10': 'climateZone'
    },
    {'1': 'elevation_meters', '3': 11, '4': 1, '5': 1, '10': 'elevationMeters'},
    {'1': 'address', '3': 12, '4': 1, '5': 9, '10': 'address'},
    {'1': 'region', '3': 13, '4': 1, '5': 9, '10': 'region'},
    {'1': 'country', '3': 14, '4': 1, '5': 9, '10': 'country'},
    {
      '1': 'boundary',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.agriculture.farm.v1.FarmBoundary',
      '10': 'boundary'
    },
    {
      '1': 'owners',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.agriculture.farm.v1.FarmOwner',
      '10': 'owners'
    },
    {
      '1': 'metadata',
      '3': 17,
      '4': 3,
      '5': 11,
      '6': '.agriculture.farm.v1.Farm.MetadataEntry',
      '10': 'metadata'
    },
    {'1': 'version', '3': 18, '4': 1, '5': 3, '10': 'version'},
    {'1': 'created_by', '3': 19, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'updated_by', '3': 20, '4': 1, '5': 9, '10': 'updatedBy'},
    {
      '1': 'created_at',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
  '3': [Farm_MetadataEntry$json],
};

@$core.Deprecated('Use farmDescriptor instead')
const Farm_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Farm`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List farmDescriptor = $convert.base64Decode(
    'CgRGYXJtEg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbmFudElkEhIKBG'
    '5hbWUYAyABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb24YBCABKAlSC2Rlc2NyaXB0aW9uEi4KE3Rv'
    'dGFsX2FyZWFfaGVjdGFyZXMYBSABKAFSEXRvdGFsQXJlYUhlY3RhcmVzEj0KCGxvY2F0aW9uGA'
    'YgASgLMiEuYWdyaWN1bHR1cmUuZmFybS52MS5GYXJtTG9jYXRpb25SCGxvY2F0aW9uEjoKCWZh'
    'cm1fdHlwZRgHIAEoDjIdLmFncmljdWx0dXJlLmZhcm0udjEuRmFybVR5cGVSCGZhcm1UeXBlEj'
    'cKBnN0YXR1cxgIIAEoDjIfLmFncmljdWx0dXJlLmZhcm0udjEuRmFybVN0YXR1c1IGc3RhdHVz'
    'EjoKCXNvaWxfdHlwZRgJIAEoDjIdLmFncmljdWx0dXJlLmZhcm0udjEuU29pbFR5cGVSCHNvaW'
    'xUeXBlEkMKDGNsaW1hdGVfem9uZRgKIAEoDjIgLmFncmljdWx0dXJlLmZhcm0udjEuQ2xpbWF0'
    'ZVpvbmVSC2NsaW1hdGVab25lEikKEGVsZXZhdGlvbl9tZXRlcnMYCyABKAFSD2VsZXZhdGlvbk'
    '1ldGVycxIYCgdhZGRyZXNzGAwgASgJUgdhZGRyZXNzEhYKBnJlZ2lvbhgNIAEoCVIGcmVnaW9u'
    'EhgKB2NvdW50cnkYDiABKAlSB2NvdW50cnkSPQoIYm91bmRhcnkYDyABKAsyIS5hZ3JpY3VsdH'
    'VyZS5mYXJtLnYxLkZhcm1Cb3VuZGFyeVIIYm91bmRhcnkSNgoGb3duZXJzGBAgAygLMh4uYWdy'
    'aWN1bHR1cmUuZmFybS52MS5GYXJtT3duZXJSBm93bmVycxJDCghtZXRhZGF0YRgRIAMoCzInLm'
    'FncmljdWx0dXJlLmZhcm0udjEuRmFybS5NZXRhZGF0YUVudHJ5UghtZXRhZGF0YRIYCgd2ZXJz'
    'aW9uGBIgASgDUgd2ZXJzaW9uEh0KCmNyZWF0ZWRfYnkYEyABKAlSCWNyZWF0ZWRCeRIdCgp1cG'
    'RhdGVkX2J5GBQgASgJUgl1cGRhdGVkQnkSOQoKY3JlYXRlZF9hdBgVIAEoCzIaLmdvb2dsZS5w'
    'cm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GBYgASgLMhouZ29vZ2'
    'xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZEF0GjsKDU1ldGFkYXRhRW50cnkSEAoDa2V5'
    'GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use createFarmRequestDescriptor instead')
const CreateFarmRequest$json = {
  '1': 'CreateFarmRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'total_area_hectares',
      '3': 3,
      '4': 1,
      '5': 1,
      '10': 'totalAreaHectares'
    },
    {
      '1': 'location',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.farm.v1.FarmLocation',
      '10': 'location'
    },
    {
      '1': 'farm_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.farm.v1.FarmType',
      '10': 'farmType'
    },
    {
      '1': 'soil_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.farm.v1.SoilType',
      '10': 'soilType'
    },
    {
      '1': 'climate_zone',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.farm.v1.ClimateZone',
      '10': 'climateZone'
    },
    {'1': 'elevation_meters', '3': 8, '4': 1, '5': 1, '10': 'elevationMeters'},
    {'1': 'address', '3': 9, '4': 1, '5': 9, '10': 'address'},
    {'1': 'region', '3': 10, '4': 1, '5': 9, '10': 'region'},
    {'1': 'country', '3': 11, '4': 1, '5': 9, '10': 'country'},
    {
      '1': 'metadata',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.agriculture.farm.v1.CreateFarmRequest.MetadataEntry',
      '10': 'metadata'
    },
    {
      '1': 'owner',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.agriculture.farm.v1.FarmOwner',
      '10': 'owner'
    },
  ],
  '3': [CreateFarmRequest_MetadataEntry$json],
};

@$core.Deprecated('Use createFarmRequestDescriptor instead')
const CreateFarmRequest_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CreateFarmRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createFarmRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVGYXJtUmVxdWVzdBISCgRuYW1lGAEgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW9uGA'
    'IgASgJUgtkZXNjcmlwdGlvbhIuChN0b3RhbF9hcmVhX2hlY3RhcmVzGAMgASgBUhF0b3RhbEFy'
    'ZWFIZWN0YXJlcxI9Cghsb2NhdGlvbhgEIAEoCzIhLmFncmljdWx0dXJlLmZhcm0udjEuRmFybU'
    'xvY2F0aW9uUghsb2NhdGlvbhI6CglmYXJtX3R5cGUYBSABKA4yHS5hZ3JpY3VsdHVyZS5mYXJt'
    'LnYxLkZhcm1UeXBlUghmYXJtVHlwZRI6Cglzb2lsX3R5cGUYBiABKA4yHS5hZ3JpY3VsdHVyZS'
    '5mYXJtLnYxLlNvaWxUeXBlUghzb2lsVHlwZRJDCgxjbGltYXRlX3pvbmUYByABKA4yIC5hZ3Jp'
    'Y3VsdHVyZS5mYXJtLnYxLkNsaW1hdGVab25lUgtjbGltYXRlWm9uZRIpChBlbGV2YXRpb25fbW'
    'V0ZXJzGAggASgBUg9lbGV2YXRpb25NZXRlcnMSGAoHYWRkcmVzcxgJIAEoCVIHYWRkcmVzcxIW'
    'CgZyZWdpb24YCiABKAlSBnJlZ2lvbhIYCgdjb3VudHJ5GAsgASgJUgdjb3VudHJ5ElAKCG1ldG'
    'FkYXRhGAwgAygLMjQuYWdyaWN1bHR1cmUuZmFybS52MS5DcmVhdGVGYXJtUmVxdWVzdC5NZXRh'
    'ZGF0YUVudHJ5UghtZXRhZGF0YRI0CgVvd25lchgNIAEoCzIeLmFncmljdWx0dXJlLmZhcm0udj'
    'EuRmFybU93bmVyUgVvd25lcho7Cg1NZXRhZGF0YUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQK'
    'BXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use createFarmResponseDescriptor instead')
const CreateFarmResponse$json = {
  '1': 'CreateFarmResponse',
  '2': [
    {
      '1': 'farm',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.farm.v1.Farm',
      '10': 'farm'
    },
  ],
};

/// Descriptor for `CreateFarmResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createFarmResponseDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVGYXJtUmVzcG9uc2USLQoEZmFybRgBIAEoCzIZLmFncmljdWx0dXJlLmZhcm0udj'
    'EuRmFybVIEZmFybQ==');

@$core.Deprecated('Use getFarmRequestDescriptor instead')
const GetFarmRequest$json = {
  '1': 'GetFarmRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetFarmRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFarmRequestDescriptor =
    $convert.base64Decode('Cg5HZXRGYXJtUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use getFarmResponseDescriptor instead')
const GetFarmResponse$json = {
  '1': 'GetFarmResponse',
  '2': [
    {
      '1': 'farm',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.farm.v1.Farm',
      '10': 'farm'
    },
  ],
};

/// Descriptor for `GetFarmResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFarmResponseDescriptor = $convert.base64Decode(
    'Cg9HZXRGYXJtUmVzcG9uc2USLQoEZmFybRgBIAEoCzIZLmFncmljdWx0dXJlLmZhcm0udjEuRm'
    'FybVIEZmFybQ==');

@$core.Deprecated('Use listFarmsRequestDescriptor instead')
const ListFarmsRequest$json = {
  '1': 'ListFarmsRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {
      '1': 'farm_type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.farm.v1.FarmType',
      '10': 'farmType'
    },
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.farm.v1.FarmStatus',
      '10': 'status'
    },
    {'1': 'region', '3': 5, '4': 1, '5': 9, '10': 'region'},
    {'1': 'country', '3': 6, '4': 1, '5': 9, '10': 'country'},
    {
      '1': 'climate_zone',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.farm.v1.ClimateZone',
      '10': 'climateZone'
    },
    {'1': 'search', '3': 8, '4': 1, '5': 9, '10': 'search'},
    {'1': 'order_by', '3': 9, '4': 1, '5': 9, '10': 'orderBy'},
  ],
};

/// Descriptor for `ListFarmsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFarmsRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0RmFybXNSZXF1ZXN0EhsKCXBhZ2Vfc2l6ZRgBIAEoBVIIcGFnZVNpemUSHQoKcGFnZV'
    '90b2tlbhgCIAEoCVIJcGFnZVRva2VuEjoKCWZhcm1fdHlwZRgDIAEoDjIdLmFncmljdWx0dXJl'
    'LmZhcm0udjEuRmFybVR5cGVSCGZhcm1UeXBlEjcKBnN0YXR1cxgEIAEoDjIfLmFncmljdWx0dX'
    'JlLmZhcm0udjEuRmFybVN0YXR1c1IGc3RhdHVzEhYKBnJlZ2lvbhgFIAEoCVIGcmVnaW9uEhgK'
    'B2NvdW50cnkYBiABKAlSB2NvdW50cnkSQwoMY2xpbWF0ZV96b25lGAcgASgOMiAuYWdyaWN1bH'
    'R1cmUuZmFybS52MS5DbGltYXRlWm9uZVILY2xpbWF0ZVpvbmUSFgoGc2VhcmNoGAggASgJUgZz'
    'ZWFyY2gSGQoIb3JkZXJfYnkYCSABKAlSB29yZGVyQnk=');

@$core.Deprecated('Use listFarmsResponseDescriptor instead')
const ListFarmsResponse$json = {
  '1': 'ListFarmsResponse',
  '2': [
    {
      '1': 'farms',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.farm.v1.Farm',
      '10': 'farms'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListFarmsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFarmsResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0RmFybXNSZXNwb25zZRIvCgVmYXJtcxgBIAMoCzIZLmFncmljdWx0dXJlLmZhcm0udj'
    'EuRmFybVIFZmFybXMSJgoPbmV4dF9wYWdlX3Rva2VuGAIgASgJUg1uZXh0UGFnZVRva2VuEh8K'
    'C3RvdGFsX2NvdW50GAMgASgFUgp0b3RhbENvdW50');

@$core.Deprecated('Use updateFarmRequestDescriptor instead')
const UpdateFarmRequest$json = {
  '1': 'UpdateFarmRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'total_area_hectares',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'totalAreaHectares'
    },
    {
      '1': 'location',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.agriculture.farm.v1.FarmLocation',
      '10': 'location'
    },
    {
      '1': 'farm_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.farm.v1.FarmType',
      '10': 'farmType'
    },
    {
      '1': 'status',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.farm.v1.FarmStatus',
      '10': 'status'
    },
    {
      '1': 'soil_type',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.agriculture.farm.v1.SoilType',
      '10': 'soilType'
    },
    {
      '1': 'climate_zone',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.agriculture.farm.v1.ClimateZone',
      '10': 'climateZone'
    },
    {'1': 'elevation_meters', '3': 10, '4': 1, '5': 1, '10': 'elevationMeters'},
    {'1': 'address', '3': 11, '4': 1, '5': 9, '10': 'address'},
    {'1': 'region', '3': 12, '4': 1, '5': 9, '10': 'region'},
    {'1': 'country', '3': 13, '4': 1, '5': 9, '10': 'country'},
    {
      '1': 'metadata',
      '3': 14,
      '4': 3,
      '5': 11,
      '6': '.agriculture.farm.v1.UpdateFarmRequest.MetadataEntry',
      '10': 'metadata'
    },
    {
      '1': 'update_mask',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
  ],
  '3': [UpdateFarmRequest_MetadataEntry$json],
};

@$core.Deprecated('Use updateFarmRequestDescriptor instead')
const UpdateFarmRequest_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `UpdateFarmRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateFarmRequestDescriptor = $convert.base64Decode(
    'ChFVcGRhdGVGYXJtUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZR'
    'IgCgtkZXNjcmlwdGlvbhgDIAEoCVILZGVzY3JpcHRpb24SLgoTdG90YWxfYXJlYV9oZWN0YXJl'
    'cxgEIAEoAVIRdG90YWxBcmVhSGVjdGFyZXMSPQoIbG9jYXRpb24YBSABKAsyIS5hZ3JpY3VsdH'
    'VyZS5mYXJtLnYxLkZhcm1Mb2NhdGlvblIIbG9jYXRpb24SOgoJZmFybV90eXBlGAYgASgOMh0u'
    'YWdyaWN1bHR1cmUuZmFybS52MS5GYXJtVHlwZVIIZmFybVR5cGUSNwoGc3RhdHVzGAcgASgOMh'
    '8uYWdyaWN1bHR1cmUuZmFybS52MS5GYXJtU3RhdHVzUgZzdGF0dXMSOgoJc29pbF90eXBlGAgg'
    'ASgOMh0uYWdyaWN1bHR1cmUuZmFybS52MS5Tb2lsVHlwZVIIc29pbFR5cGUSQwoMY2xpbWF0ZV'
    '96b25lGAkgASgOMiAuYWdyaWN1bHR1cmUuZmFybS52MS5DbGltYXRlWm9uZVILY2xpbWF0ZVpv'
    'bmUSKQoQZWxldmF0aW9uX21ldGVycxgKIAEoAVIPZWxldmF0aW9uTWV0ZXJzEhgKB2FkZHJlc3'
    'MYCyABKAlSB2FkZHJlc3MSFgoGcmVnaW9uGAwgASgJUgZyZWdpb24SGAoHY291bnRyeRgNIAEo'
    'CVIHY291bnRyeRJQCghtZXRhZGF0YRgOIAMoCzI0LmFncmljdWx0dXJlLmZhcm0udjEuVXBkYX'
    'RlRmFybVJlcXVlc3QuTWV0YWRhdGFFbnRyeVIIbWV0YWRhdGESOwoLdXBkYXRlX21hc2sYDyAB'
    'KAsyGi5nb29nbGUucHJvdG9idWYuRmllbGRNYXNrUgp1cGRhdGVNYXNrGjsKDU1ldGFkYXRhRW'
    '50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use updateFarmResponseDescriptor instead')
const UpdateFarmResponse$json = {
  '1': 'UpdateFarmResponse',
  '2': [
    {
      '1': 'farm',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.farm.v1.Farm',
      '10': 'farm'
    },
  ],
};

/// Descriptor for `UpdateFarmResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateFarmResponseDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVGYXJtUmVzcG9uc2USLQoEZmFybRgBIAEoCzIZLmFncmljdWx0dXJlLmZhcm0udj'
    'EuRmFybVIEZmFybQ==');

@$core.Deprecated('Use deleteFarmRequestDescriptor instead')
const DeleteFarmRequest$json = {
  '1': 'DeleteFarmRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteFarmRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFarmRequestDescriptor =
    $convert.base64Decode('ChFEZWxldGVGYXJtUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use deleteFarmResponseDescriptor instead')
const DeleteFarmResponse$json = {
  '1': 'DeleteFarmResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `DeleteFarmResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFarmResponseDescriptor =
    $convert.base64Decode(
        'ChJEZWxldGVGYXJtUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcw==');

@$core.Deprecated('Use setFarmBoundaryRequestDescriptor instead')
const SetFarmBoundaryRequest$json = {
  '1': 'SetFarmBoundaryRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'geojson', '3': 2, '4': 1, '5': 9, '10': 'geojson'},
  ],
};

/// Descriptor for `SetFarmBoundaryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFarmBoundaryRequestDescriptor =
    $convert.base64Decode(
        'ChZTZXRGYXJtQm91bmRhcnlSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZBIYCgdnZW'
        '9qc29uGAIgASgJUgdnZW9qc29u');

@$core.Deprecated('Use setFarmBoundaryResponseDescriptor instead')
const SetFarmBoundaryResponse$json = {
  '1': 'SetFarmBoundaryResponse',
  '2': [
    {
      '1': 'boundary',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.farm.v1.FarmBoundary',
      '10': 'boundary'
    },
  ],
};

/// Descriptor for `SetFarmBoundaryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setFarmBoundaryResponseDescriptor =
    $convert.base64Decode(
        'ChdTZXRGYXJtQm91bmRhcnlSZXNwb25zZRI9Cghib3VuZGFyeRgBIAEoCzIhLmFncmljdWx0dX'
        'JlLmZhcm0udjEuRmFybUJvdW5kYXJ5Ughib3VuZGFyeQ==');

@$core.Deprecated('Use getFarmBoundaryRequestDescriptor instead')
const GetFarmBoundaryRequest$json = {
  '1': 'GetFarmBoundaryRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
  ],
};

/// Descriptor for `GetFarmBoundaryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFarmBoundaryRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRGYXJtQm91bmRhcnlSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZA==');

@$core.Deprecated('Use getFarmBoundaryResponseDescriptor instead')
const GetFarmBoundaryResponse$json = {
  '1': 'GetFarmBoundaryResponse',
  '2': [
    {
      '1': 'boundary',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.farm.v1.FarmBoundary',
      '10': 'boundary'
    },
  ],
};

/// Descriptor for `GetFarmBoundaryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFarmBoundaryResponseDescriptor =
    $convert.base64Decode(
        'ChdHZXRGYXJtQm91bmRhcnlSZXNwb25zZRI9Cghib3VuZGFyeRgBIAEoCzIhLmFncmljdWx0dX'
        'JlLmZhcm0udjEuRmFybUJvdW5kYXJ5Ughib3VuZGFyeQ==');

@$core.Deprecated('Use transferOwnershipRequestDescriptor instead')
const TransferOwnershipRequest$json = {
  '1': 'TransferOwnershipRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'from_user_id', '3': 2, '4': 1, '5': 9, '10': 'fromUserId'},
    {'1': 'to_user_id', '3': 3, '4': 1, '5': 9, '10': 'toUserId'},
    {'1': 'to_owner_name', '3': 4, '4': 1, '5': 9, '10': 'toOwnerName'},
    {'1': 'to_email', '3': 5, '4': 1, '5': 9, '10': 'toEmail'},
    {'1': 'to_phone', '3': 6, '4': 1, '5': 9, '10': 'toPhone'},
    {
      '1': 'ownership_percentage',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'ownershipPercentage'
    },
  ],
};

/// Descriptor for `TransferOwnershipRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferOwnershipRequestDescriptor = $convert.base64Decode(
    'ChhUcmFuc2Zlck93bmVyc2hpcFJlcXVlc3QSFwoHZmFybV9pZBgBIAEoCVIGZmFybUlkEiAKDG'
    'Zyb21fdXNlcl9pZBgCIAEoCVIKZnJvbVVzZXJJZBIcCgp0b191c2VyX2lkGAMgASgJUgh0b1Vz'
    'ZXJJZBIiCg10b19vd25lcl9uYW1lGAQgASgJUgt0b093bmVyTmFtZRIZCgh0b19lbWFpbBgFIA'
    'EoCVIHdG9FbWFpbBIZCgh0b19waG9uZRgGIAEoCVIHdG9QaG9uZRIxChRvd25lcnNoaXBfcGVy'
    'Y2VudGFnZRgHIAEoAVITb3duZXJzaGlwUGVyY2VudGFnZQ==');

@$core.Deprecated('Use transferOwnershipResponseDescriptor instead')
const TransferOwnershipResponse$json = {
  '1': 'TransferOwnershipResponse',
  '2': [
    {
      '1': 'farm',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.farm.v1.Farm',
      '10': 'farm'
    },
  ],
};

/// Descriptor for `TransferOwnershipResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferOwnershipResponseDescriptor =
    $convert.base64Decode(
        'ChlUcmFuc2Zlck93bmVyc2hpcFJlc3BvbnNlEi0KBGZhcm0YASABKAsyGS5hZ3JpY3VsdHVyZS'
        '5mYXJtLnYxLkZhcm1SBGZhcm0=');

const $core.Map<$core.String, $core.dynamic> FarmServiceBase$json = {
  '1': 'FarmService',
  '2': [
    {
      '1': 'CreateFarm',
      '2': '.agriculture.farm.v1.CreateFarmRequest',
      '3': '.agriculture.farm.v1.CreateFarmResponse'
    },
    {
      '1': 'GetFarm',
      '2': '.agriculture.farm.v1.GetFarmRequest',
      '3': '.agriculture.farm.v1.GetFarmResponse'
    },
    {
      '1': 'ListFarms',
      '2': '.agriculture.farm.v1.ListFarmsRequest',
      '3': '.agriculture.farm.v1.ListFarmsResponse'
    },
    {
      '1': 'UpdateFarm',
      '2': '.agriculture.farm.v1.UpdateFarmRequest',
      '3': '.agriculture.farm.v1.UpdateFarmResponse'
    },
    {
      '1': 'DeleteFarm',
      '2': '.agriculture.farm.v1.DeleteFarmRequest',
      '3': '.agriculture.farm.v1.DeleteFarmResponse'
    },
    {
      '1': 'SetFarmBoundary',
      '2': '.agriculture.farm.v1.SetFarmBoundaryRequest',
      '3': '.agriculture.farm.v1.SetFarmBoundaryResponse'
    },
    {
      '1': 'GetFarmBoundary',
      '2': '.agriculture.farm.v1.GetFarmBoundaryRequest',
      '3': '.agriculture.farm.v1.GetFarmBoundaryResponse'
    },
    {
      '1': 'TransferOwnership',
      '2': '.agriculture.farm.v1.TransferOwnershipRequest',
      '3': '.agriculture.farm.v1.TransferOwnershipResponse'
    },
  ],
};

@$core.Deprecated('Use farmServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    FarmServiceBase$messageJson = {
  '.agriculture.farm.v1.CreateFarmRequest': CreateFarmRequest$json,
  '.agriculture.farm.v1.FarmLocation': FarmLocation$json,
  '.agriculture.farm.v1.CreateFarmRequest.MetadataEntry':
      CreateFarmRequest_MetadataEntry$json,
  '.agriculture.farm.v1.FarmOwner': FarmOwner$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.farm.v1.CreateFarmResponse': CreateFarmResponse$json,
  '.agriculture.farm.v1.Farm': Farm$json,
  '.agriculture.farm.v1.FarmBoundary': FarmBoundary$json,
  '.agriculture.farm.v1.Farm.MetadataEntry': Farm_MetadataEntry$json,
  '.agriculture.farm.v1.GetFarmRequest': GetFarmRequest$json,
  '.agriculture.farm.v1.GetFarmResponse': GetFarmResponse$json,
  '.agriculture.farm.v1.ListFarmsRequest': ListFarmsRequest$json,
  '.agriculture.farm.v1.ListFarmsResponse': ListFarmsResponse$json,
  '.agriculture.farm.v1.UpdateFarmRequest': UpdateFarmRequest$json,
  '.agriculture.farm.v1.UpdateFarmRequest.MetadataEntry':
      UpdateFarmRequest_MetadataEntry$json,
  '.google.protobuf.FieldMask': $1.FieldMask$json,
  '.agriculture.farm.v1.UpdateFarmResponse': UpdateFarmResponse$json,
  '.agriculture.farm.v1.DeleteFarmRequest': DeleteFarmRequest$json,
  '.agriculture.farm.v1.DeleteFarmResponse': DeleteFarmResponse$json,
  '.agriculture.farm.v1.SetFarmBoundaryRequest': SetFarmBoundaryRequest$json,
  '.agriculture.farm.v1.SetFarmBoundaryResponse': SetFarmBoundaryResponse$json,
  '.agriculture.farm.v1.GetFarmBoundaryRequest': GetFarmBoundaryRequest$json,
  '.agriculture.farm.v1.GetFarmBoundaryResponse': GetFarmBoundaryResponse$json,
  '.agriculture.farm.v1.TransferOwnershipRequest':
      TransferOwnershipRequest$json,
  '.agriculture.farm.v1.TransferOwnershipResponse':
      TransferOwnershipResponse$json,
};

/// Descriptor for `FarmService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List farmServiceDescriptor = $convert.base64Decode(
    'CgtGYXJtU2VydmljZRJdCgpDcmVhdGVGYXJtEiYuYWdyaWN1bHR1cmUuZmFybS52MS5DcmVhdG'
    'VGYXJtUmVxdWVzdBonLmFncmljdWx0dXJlLmZhcm0udjEuQ3JlYXRlRmFybVJlc3BvbnNlElQK'
    'B0dldEZhcm0SIy5hZ3JpY3VsdHVyZS5mYXJtLnYxLkdldEZhcm1SZXF1ZXN0GiQuYWdyaWN1bH'
    'R1cmUuZmFybS52MS5HZXRGYXJtUmVzcG9uc2USWgoJTGlzdEZhcm1zEiUuYWdyaWN1bHR1cmUu'
    'ZmFybS52MS5MaXN0RmFybXNSZXF1ZXN0GiYuYWdyaWN1bHR1cmUuZmFybS52MS5MaXN0RmFybX'
    'NSZXNwb25zZRJdCgpVcGRhdGVGYXJtEiYuYWdyaWN1bHR1cmUuZmFybS52MS5VcGRhdGVGYXJt'
    'UmVxdWVzdBonLmFncmljdWx0dXJlLmZhcm0udjEuVXBkYXRlRmFybVJlc3BvbnNlEl0KCkRlbG'
    'V0ZUZhcm0SJi5hZ3JpY3VsdHVyZS5mYXJtLnYxLkRlbGV0ZUZhcm1SZXF1ZXN0GicuYWdyaWN1'
    'bHR1cmUuZmFybS52MS5EZWxldGVGYXJtUmVzcG9uc2USbAoPU2V0RmFybUJvdW5kYXJ5EisuYW'
    'dyaWN1bHR1cmUuZmFybS52MS5TZXRGYXJtQm91bmRhcnlSZXF1ZXN0GiwuYWdyaWN1bHR1cmUu'
    'ZmFybS52MS5TZXRGYXJtQm91bmRhcnlSZXNwb25zZRJsCg9HZXRGYXJtQm91bmRhcnkSKy5hZ3'
    'JpY3VsdHVyZS5mYXJtLnYxLkdldEZhcm1Cb3VuZGFyeVJlcXVlc3QaLC5hZ3JpY3VsdHVyZS5m'
    'YXJtLnYxLkdldEZhcm1Cb3VuZGFyeVJlc3BvbnNlEnIKEVRyYW5zZmVyT3duZXJzaGlwEi0uYW'
    'dyaWN1bHR1cmUuZmFybS52MS5UcmFuc2Zlck93bmVyc2hpcFJlcXVlc3QaLi5hZ3JpY3VsdHVy'
    'ZS5mYXJtLnYxLlRyYW5zZmVyT3duZXJzaGlwUmVzcG9uc2U=');
