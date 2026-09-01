// This is a generated file - do not edit.
//
// Generated from soil.proto.

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

@$core.Deprecated('Use soilTextureDescriptor instead')
const SoilTexture$json = {
  '1': 'SoilTexture',
  '2': [
    {'1': 'SOIL_TEXTURE_UNSPECIFIED', '2': 0},
    {'1': 'SOIL_TEXTURE_SANDY', '2': 1},
    {'1': 'SOIL_TEXTURE_LOAMY', '2': 2},
    {'1': 'SOIL_TEXTURE_CLAY', '2': 3},
    {'1': 'SOIL_TEXTURE_SILT', '2': 4},
    {'1': 'SOIL_TEXTURE_PEAT', '2': 5},
    {'1': 'SOIL_TEXTURE_CHALK', '2': 6},
  ],
};

/// Descriptor for `SoilTexture`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List soilTextureDescriptor = $convert.base64Decode(
    'CgtTb2lsVGV4dHVyZRIcChhTT0lMX1RFWFRVUkVfVU5TUEVDSUZJRUQQABIWChJTT0lMX1RFWF'
    'RVUkVfU0FORFkQARIWChJTT0lMX1RFWFRVUkVfTE9BTVkQAhIVChFTT0lMX1RFWFRVUkVfQ0xB'
    'WRADEhUKEVNPSUxfVEVYVFVSRV9TSUxUEAQSFQoRU09JTF9URVhUVVJFX1BFQVQQBRIWChJTT0'
    'lMX1RFWFRVUkVfQ0hBTEsQBg==');

@$core.Deprecated('Use analysisStatusDescriptor instead')
const AnalysisStatus$json = {
  '1': 'AnalysisStatus',
  '2': [
    {'1': 'ANALYSIS_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'ANALYSIS_STATUS_PENDING', '2': 1},
    {'1': 'ANALYSIS_STATUS_IN_PROGRESS', '2': 2},
    {'1': 'ANALYSIS_STATUS_COMPLETED', '2': 3},
    {'1': 'ANALYSIS_STATUS_FAILED', '2': 4},
  ],
};

/// Descriptor for `AnalysisStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List analysisStatusDescriptor = $convert.base64Decode(
    'Cg5BbmFseXNpc1N0YXR1cxIfChtBTkFMWVNJU19TVEFUVVNfVU5TUEVDSUZJRUQQABIbChdBTk'
    'FMWVNJU19TVEFUVVNfUEVORElORxABEh8KG0FOQUxZU0lTX1NUQVRVU19JTl9QUk9HUkVTUxAC'
    'Eh0KGUFOQUxZU0lTX1NUQVRVU19DT01QTEVURUQQAxIaChZBTkFMWVNJU19TVEFUVVNfRkFJTE'
    'VEEAQ=');

@$core.Deprecated('Use nutrientLevelDescriptor instead')
const NutrientLevel$json = {
  '1': 'NutrientLevel',
  '2': [
    {'1': 'NUTRIENT_LEVEL_UNSPECIFIED', '2': 0},
    {'1': 'NUTRIENT_LEVEL_DEFICIENT', '2': 1},
    {'1': 'NUTRIENT_LEVEL_LOW', '2': 2},
    {'1': 'NUTRIENT_LEVEL_ADEQUATE', '2': 3},
    {'1': 'NUTRIENT_LEVEL_HIGH', '2': 4},
    {'1': 'NUTRIENT_LEVEL_EXCESSIVE', '2': 5},
  ],
};

/// Descriptor for `NutrientLevel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List nutrientLevelDescriptor = $convert.base64Decode(
    'Cg1OdXRyaWVudExldmVsEh4KGk5VVFJJRU5UX0xFVkVMX1VOU1BFQ0lGSUVEEAASHAoYTlVUUk'
    'lFTlRfTEVWRUxfREVGSUNJRU5UEAESFgoSTlVUUklFTlRfTEVWRUxfTE9XEAISGwoXTlVUUklF'
    'TlRfTEVWRUxfQURFUVVBVEUQAxIXChNOVVRSSUVOVF9MRVZFTF9ISUdIEAQSHAoYTlVUUklFTl'
    'RfTEVWRUxfRVhDRVNTSVZFEAU=');

@$core.Deprecated('Use healthCategoryDescriptor instead')
const HealthCategory$json = {
  '1': 'HealthCategory',
  '2': [
    {'1': 'HEALTH_CATEGORY_UNSPECIFIED', '2': 0},
    {'1': 'HEALTH_CATEGORY_CRITICAL', '2': 1},
    {'1': 'HEALTH_CATEGORY_POOR', '2': 2},
    {'1': 'HEALTH_CATEGORY_FAIR', '2': 3},
    {'1': 'HEALTH_CATEGORY_GOOD', '2': 4},
    {'1': 'HEALTH_CATEGORY_EXCELLENT', '2': 5},
  ],
};

/// Descriptor for `HealthCategory`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List healthCategoryDescriptor = $convert.base64Decode(
    'Cg5IZWFsdGhDYXRlZ29yeRIfChtIRUFMVEhfQ0FURUdPUllfVU5TUEVDSUZJRUQQABIcChhIRU'
    'FMVEhfQ0FURUdPUllfQ1JJVElDQUwQARIYChRIRUFMVEhfQ0FURUdPUllfUE9PUhACEhgKFEhF'
    'QUxUSF9DQVRFR09SWV9GQUlSEAMSGAoUSEVBTFRIX0NBVEVHT1JZX0dPT0QQBBIdChlIRUFMVE'
    'hfQ0FURUdPUllfRVhDRUxMRU5UEAU=');

@$core.Deprecated('Use locationDescriptor instead')
const Location$json = {
  '1': 'Location',
  '2': [
    {'1': 'latitude', '3': 1, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 2, '4': 1, '5': 1, '10': 'longitude'},
  ],
};

/// Descriptor for `Location`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List locationDescriptor = $convert.base64Decode(
    'CghMb2NhdGlvbhIaCghsYXRpdHVkZRgBIAEoAVIIbGF0aXR1ZGUSHAoJbG9uZ2l0dWRlGAIgAS'
    'gBUglsb25naXR1ZGU=');

@$core.Deprecated('Use soilSampleDescriptor instead')
const SoilSample$json = {
  '1': 'SoilSample',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'sample_location',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soil.v1.Location',
      '10': 'sampleLocation'
    },
    {'1': 'sample_depth_cm', '3': 6, '4': 1, '5': 1, '10': 'sampleDepthCm'},
    {
      '1': 'collection_date',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'collectionDate'
    },
    {'1': 'pH', '3': 8, '4': 1, '5': 1, '10': 'pH'},
    {
      '1': 'organic_matter_pct',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'organicMatterPct'
    },
    {'1': 'nitrogen_ppm', '3': 10, '4': 1, '5': 1, '10': 'nitrogenPpm'},
    {'1': 'phosphorus_ppm', '3': 11, '4': 1, '5': 1, '10': 'phosphorusPpm'},
    {'1': 'potassium_ppm', '3': 12, '4': 1, '5': 1, '10': 'potassiumPpm'},
    {'1': 'calcium_ppm', '3': 13, '4': 1, '5': 1, '10': 'calciumPpm'},
    {'1': 'magnesium_ppm', '3': 14, '4': 1, '5': 1, '10': 'magnesiumPpm'},
    {'1': 'sulfur_ppm', '3': 15, '4': 1, '5': 1, '10': 'sulfurPpm'},
    {'1': 'iron_ppm', '3': 16, '4': 1, '5': 1, '10': 'ironPpm'},
    {'1': 'manganese_ppm', '3': 17, '4': 1, '5': 1, '10': 'manganesePpm'},
    {'1': 'zinc_ppm', '3': 18, '4': 1, '5': 1, '10': 'zincPpm'},
    {'1': 'copper_ppm', '3': 19, '4': 1, '5': 1, '10': 'copperPpm'},
    {'1': 'boron_ppm', '3': 20, '4': 1, '5': 1, '10': 'boronPpm'},
    {'1': 'moisture_pct', '3': 21, '4': 1, '5': 1, '10': 'moisturePct'},
    {
      '1': 'texture',
      '3': 22,
      '4': 1,
      '5': 14,
      '6': '.agriculture.soil.v1.SoilTexture',
      '10': 'texture'
    },
    {'1': 'bulk_density', '3': 23, '4': 1, '5': 1, '10': 'bulkDensity'},
    {
      '1': 'cation_exchange_capacity',
      '3': 24,
      '4': 1,
      '5': 1,
      '10': 'cationExchangeCapacity'
    },
    {
      '1': 'electrical_conductivity',
      '3': 25,
      '4': 1,
      '5': 1,
      '10': 'electricalConductivity'
    },
    {'1': 'collected_by', '3': 26, '4': 1, '5': 9, '10': 'collectedBy'},
    {'1': 'notes', '3': 27, '4': 1, '5': 9, '10': 'notes'},
    {
      '1': 'created_at',
      '3': 28,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 29,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {'1': 'version', '3': 30, '4': 1, '5': 3, '10': 'version'},
  ],
};

/// Descriptor for `SoilSample`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List soilSampleDescriptor = $convert.base64Decode(
    'CgpTb2lsU2FtcGxlEg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbmFudE'
    'lkEhkKCGZpZWxkX2lkGAMgASgJUgdmaWVsZElkEhcKB2Zhcm1faWQYBCABKAlSBmZhcm1JZBJG'
    'Cg9zYW1wbGVfbG9jYXRpb24YBSABKAsyHS5hZ3JpY3VsdHVyZS5zb2lsLnYxLkxvY2F0aW9uUg'
    '5zYW1wbGVMb2NhdGlvbhImCg9zYW1wbGVfZGVwdGhfY20YBiABKAFSDXNhbXBsZURlcHRoQ20S'
    'QwoPY29sbGVjdGlvbl9kYXRlGAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIOY2'
    '9sbGVjdGlvbkRhdGUSDgoCcEgYCCABKAFSAnBIEiwKEm9yZ2FuaWNfbWF0dGVyX3BjdBgJIAEo'
    'AVIQb3JnYW5pY01hdHRlclBjdBIhCgxuaXRyb2dlbl9wcG0YCiABKAFSC25pdHJvZ2VuUHBtEi'
    'UKDnBob3NwaG9ydXNfcHBtGAsgASgBUg1waG9zcGhvcnVzUHBtEiMKDXBvdGFzc2l1bV9wcG0Y'
    'DCABKAFSDHBvdGFzc2l1bVBwbRIfCgtjYWxjaXVtX3BwbRgNIAEoAVIKY2FsY2l1bVBwbRIjCg'
    '1tYWduZXNpdW1fcHBtGA4gASgBUgxtYWduZXNpdW1QcG0SHQoKc3VsZnVyX3BwbRgPIAEoAVIJ'
    'c3VsZnVyUHBtEhkKCGlyb25fcHBtGBAgASgBUgdpcm9uUHBtEiMKDW1hbmdhbmVzZV9wcG0YES'
    'ABKAFSDG1hbmdhbmVzZVBwbRIZCgh6aW5jX3BwbRgSIAEoAVIHemluY1BwbRIdCgpjb3BwZXJf'
    'cHBtGBMgASgBUgljb3BwZXJQcG0SGwoJYm9yb25fcHBtGBQgASgBUghib3JvblBwbRIhCgxtb2'
    'lzdHVyZV9wY3QYFSABKAFSC21vaXN0dXJlUGN0EjoKB3RleHR1cmUYFiABKA4yIC5hZ3JpY3Vs'
    'dHVyZS5zb2lsLnYxLlNvaWxUZXh0dXJlUgd0ZXh0dXJlEiEKDGJ1bGtfZGVuc2l0eRgXIAEoAV'
    'ILYnVsa0RlbnNpdHkSOAoYY2F0aW9uX2V4Y2hhbmdlX2NhcGFjaXR5GBggASgBUhZjYXRpb25F'
    'eGNoYW5nZUNhcGFjaXR5EjcKF2VsZWN0cmljYWxfY29uZHVjdGl2aXR5GBkgASgBUhZlbGVjdH'
    'JpY2FsQ29uZHVjdGl2aXR5EiEKDGNvbGxlY3RlZF9ieRgaIAEoCVILY29sbGVjdGVkQnkSFAoF'
    'bm90ZXMYGyABKAlSBW5vdGVzEjkKCmNyZWF0ZWRfYXQYHCABKAsyGi5nb29nbGUucHJvdG9idW'
    'YuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRlZF9hdBgdIAEoCzIaLmdvb2dsZS5wcm90'
    'b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdBIYCgd2ZXJzaW9uGB4gASgDUgd2ZXJzaW9u');

@$core.Deprecated('Use soilAnalysisDescriptor instead')
const SoilAnalysis$json = {
  '1': 'SoilAnalysis',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'sample_id', '3': 3, '4': 1, '5': 9, '10': 'sampleId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 5, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'status',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.soil.v1.AnalysisStatus',
      '10': 'status'
    },
    {'1': 'analysis_type', '3': 7, '4': 1, '5': 9, '10': 'analysisType'},
    {'1': 'soil_health_score', '3': 8, '4': 1, '5': 1, '10': 'soilHealthScore'},
    {
      '1': 'health_category',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.agriculture.soil.v1.HealthCategory',
      '10': 'healthCategory'
    },
    {'1': 'recommendations', '3': 10, '4': 3, '5': 9, '10': 'recommendations'},
    {'1': 'analyzed_by', '3': 11, '4': 1, '5': 9, '10': 'analyzedBy'},
    {
      '1': 'analyzed_at',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'analyzedAt'
    },
    {'1': 'summary', '3': 13, '4': 1, '5': 9, '10': 'summary'},
    {
      '1': 'created_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {'1': 'version', '3': 16, '4': 1, '5': 3, '10': 'version'},
  ],
};

/// Descriptor for `SoilAnalysis`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List soilAnalysisDescriptor = $convert.base64Decode(
    'CgxTb2lsQW5hbHlzaXMSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdGVuYW'
    '50SWQSGwoJc2FtcGxlX2lkGAMgASgJUghzYW1wbGVJZBIZCghmaWVsZF9pZBgEIAEoCVIHZmll'
    'bGRJZBIXCgdmYXJtX2lkGAUgASgJUgZmYXJtSWQSOwoGc3RhdHVzGAYgASgOMiMuYWdyaWN1bH'
    'R1cmUuc29pbC52MS5BbmFseXNpc1N0YXR1c1IGc3RhdHVzEiMKDWFuYWx5c2lzX3R5cGUYByAB'
    'KAlSDGFuYWx5c2lzVHlwZRIqChFzb2lsX2hlYWx0aF9zY29yZRgIIAEoAVIPc29pbEhlYWx0aF'
    'Njb3JlEkwKD2hlYWx0aF9jYXRlZ29yeRgJIAEoDjIjLmFncmljdWx0dXJlLnNvaWwudjEuSGVh'
    'bHRoQ2F0ZWdvcnlSDmhlYWx0aENhdGVnb3J5EigKD3JlY29tbWVuZGF0aW9ucxgKIAMoCVIPcm'
    'Vjb21tZW5kYXRpb25zEh8KC2FuYWx5emVkX2J5GAsgASgJUgphbmFseXplZEJ5EjsKC2FuYWx5'
    'emVkX2F0GAwgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIKYW5hbHl6ZWRBdBIYCg'
    'dzdW1tYXJ5GA0gASgJUgdzdW1tYXJ5EjkKCmNyZWF0ZWRfYXQYDiABKAsyGi5nb29nbGUucHJv'
    'dG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRlZF9hdBgPIAEoCzIaLmdvb2dsZS'
    '5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdBIYCgd2ZXJzaW9uGBAgASgDUgd2ZXJzaW9u');

@$core.Deprecated('Use soilMapDescriptor instead')
const SoilMap$json = {
  '1': 'SoilMap',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'map_type', '3': 5, '4': 1, '5': 9, '10': 'mapType'},
    {'1': 'raster_data', '3': 6, '4': 1, '5': 12, '10': 'rasterData'},
    {'1': 'crs', '3': 7, '4': 1, '5': 9, '10': 'crs'},
    {'1': 'resolution', '3': 8, '4': 1, '5': 1, '10': 'resolution'},
    {
      '1': 'bbox_min',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soil.v1.Location',
      '10': 'bboxMin'
    },
    {
      '1': 'bbox_max',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soil.v1.Location',
      '10': 'bboxMax'
    },
    {'1': 'generated_by', '3': 11, '4': 1, '5': 9, '10': 'generatedBy'},
    {
      '1': 'generated_at',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'generatedAt'
    },
    {
      '1': 'created_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {'1': 'version', '3': 15, '4': 1, '5': 3, '10': 'version'},
  ],
};

/// Descriptor for `SoilMap`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List soilMapDescriptor = $convert.base64Decode(
    'CgdTb2lsTWFwEg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbmFudElkEh'
    'kKCGZpZWxkX2lkGAMgASgJUgdmaWVsZElkEhcKB2Zhcm1faWQYBCABKAlSBmZhcm1JZBIZCght'
    'YXBfdHlwZRgFIAEoCVIHbWFwVHlwZRIfCgtyYXN0ZXJfZGF0YRgGIAEoDFIKcmFzdGVyRGF0YR'
    'IQCgNjcnMYByABKAlSA2NycxIeCgpyZXNvbHV0aW9uGAggASgBUgpyZXNvbHV0aW9uEjgKCGJi'
    'b3hfbWluGAkgASgLMh0uYWdyaWN1bHR1cmUuc29pbC52MS5Mb2NhdGlvblIHYmJveE1pbhI4Cg'
    'hiYm94X21heBgKIAEoCzIdLmFncmljdWx0dXJlLnNvaWwudjEuTG9jYXRpb25SB2Jib3hNYXgS'
    'IQoMZ2VuZXJhdGVkX2J5GAsgASgJUgtnZW5lcmF0ZWRCeRI9CgxnZW5lcmF0ZWRfYXQYDCABKA'
    'syGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgtnZW5lcmF0ZWRBdBI5CgpjcmVhdGVkX2F0'
    'GA0gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZW'
    'RfYXQYDiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQSGAoHdmVy'
    'c2lvbhgPIAEoA1IHdmVyc2lvbg==');

@$core.Deprecated('Use soilNutrientDescriptor instead')
const SoilNutrient$json = {
  '1': 'SoilNutrient',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'sample_id', '3': 3, '4': 1, '5': 9, '10': 'sampleId'},
    {'1': 'nutrient_name', '3': 4, '4': 1, '5': 9, '10': 'nutrientName'},
    {'1': 'value_ppm', '3': 5, '4': 1, '5': 1, '10': 'valuePpm'},
    {
      '1': 'level',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.soil.v1.NutrientLevel',
      '10': 'level'
    },
    {'1': 'optimal_min', '3': 7, '4': 1, '5': 1, '10': 'optimalMin'},
    {'1': 'optimal_max', '3': 8, '4': 1, '5': 1, '10': 'optimalMax'},
    {'1': 'unit', '3': 9, '4': 1, '5': 9, '10': 'unit'},
    {
      '1': 'created_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `SoilNutrient`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List soilNutrientDescriptor = $convert.base64Decode(
    'CgxTb2lsTnV0cmllbnQSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdGVuYW'
    '50SWQSGwoJc2FtcGxlX2lkGAMgASgJUghzYW1wbGVJZBIjCg1udXRyaWVudF9uYW1lGAQgASgJ'
    'UgxudXRyaWVudE5hbWUSGwoJdmFsdWVfcHBtGAUgASgBUgh2YWx1ZVBwbRI4CgVsZXZlbBgGIA'
    'EoDjIiLmFncmljdWx0dXJlLnNvaWwudjEuTnV0cmllbnRMZXZlbFIFbGV2ZWwSHwoLb3B0aW1h'
    'bF9taW4YByABKAFSCm9wdGltYWxNaW4SHwoLb3B0aW1hbF9tYXgYCCABKAFSCm9wdGltYWxNYX'
    'gSEgoEdW5pdBgJIAEoCVIEdW5pdBI5CgpjcmVhdGVkX2F0GAogASgLMhouZ29vZ2xlLnByb3Rv'
    'YnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use soilHealthScoreDescriptor instead')
const SoilHealthScore$json = {
  '1': 'SoilHealthScore',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'overall_score', '3': 5, '4': 1, '5': 1, '10': 'overallScore'},
    {
      '1': 'category',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.soil.v1.HealthCategory',
      '10': 'category'
    },
    {'1': 'physical_score', '3': 7, '4': 1, '5': 1, '10': 'physicalScore'},
    {'1': 'chemical_score', '3': 8, '4': 1, '5': 1, '10': 'chemicalScore'},
    {'1': 'biological_score', '3': 9, '4': 1, '5': 1, '10': 'biologicalScore'},
    {'1': 'recommendations', '3': 10, '4': 3, '5': 9, '10': 'recommendations'},
    {
      '1': 'deficiencies',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.agriculture.soil.v1.NutrientDeficiency',
      '10': 'deficiencies'
    },
    {
      '1': 'assessed_at',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'assessedAt'
    },
    {
      '1': 'created_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {'1': 'version', '3': 15, '4': 1, '5': 3, '10': 'version'},
  ],
};

/// Descriptor for `SoilHealthScore`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List soilHealthScoreDescriptor = $convert.base64Decode(
    'Cg9Tb2lsSGVhbHRoU2NvcmUSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdG'
    'VuYW50SWQSGQoIZmllbGRfaWQYAyABKAlSB2ZpZWxkSWQSFwoHZmFybV9pZBgEIAEoCVIGZmFy'
    'bUlkEiMKDW92ZXJhbGxfc2NvcmUYBSABKAFSDG92ZXJhbGxTY29yZRI/CghjYXRlZ29yeRgGIA'
    'EoDjIjLmFncmljdWx0dXJlLnNvaWwudjEuSGVhbHRoQ2F0ZWdvcnlSCGNhdGVnb3J5EiUKDnBo'
    'eXNpY2FsX3Njb3JlGAcgASgBUg1waHlzaWNhbFNjb3JlEiUKDmNoZW1pY2FsX3Njb3JlGAggAS'
    'gBUg1jaGVtaWNhbFNjb3JlEikKEGJpb2xvZ2ljYWxfc2NvcmUYCSABKAFSD2Jpb2xvZ2ljYWxT'
    'Y29yZRIoCg9yZWNvbW1lbmRhdGlvbnMYCiADKAlSD3JlY29tbWVuZGF0aW9ucxJLCgxkZWZpY2'
    'llbmNpZXMYCyADKAsyJy5hZ3JpY3VsdHVyZS5zb2lsLnYxLk51dHJpZW50RGVmaWNpZW5jeVIM'
    'ZGVmaWNpZW5jaWVzEjsKC2Fzc2Vzc2VkX2F0GAwgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbW'
    'VzdGFtcFIKYXNzZXNzZWRBdBI5CgpjcmVhdGVkX2F0GA0gASgLMhouZ29vZ2xlLnByb3RvYnVm'
    'LlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYDiABKAsyGi5nb29nbGUucHJvdG'
    '9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQSGAoHdmVyc2lvbhgPIAEoA1IHdmVyc2lvbg==');

@$core.Deprecated('Use nutrientDeficiencyDescriptor instead')
const NutrientDeficiency$json = {
  '1': 'NutrientDeficiency',
  '2': [
    {'1': 'nutrient_name', '3': 1, '4': 1, '5': 9, '10': 'nutrientName'},
    {'1': 'current_value', '3': 2, '4': 1, '5': 1, '10': 'currentValue'},
    {'1': 'optimal_value', '3': 3, '4': 1, '5': 1, '10': 'optimalValue'},
    {
      '1': 'level',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.soil.v1.NutrientLevel',
      '10': 'level'
    },
    {'1': 'recommendation', '3': 5, '4': 1, '5': 9, '10': 'recommendation'},
  ],
};

/// Descriptor for `NutrientDeficiency`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nutrientDeficiencyDescriptor = $convert.base64Decode(
    'ChJOdXRyaWVudERlZmljaWVuY3kSIwoNbnV0cmllbnRfbmFtZRgBIAEoCVIMbnV0cmllbnROYW'
    '1lEiMKDWN1cnJlbnRfdmFsdWUYAiABKAFSDGN1cnJlbnRWYWx1ZRIjCg1vcHRpbWFsX3ZhbHVl'
    'GAMgASgBUgxvcHRpbWFsVmFsdWUSOAoFbGV2ZWwYBCABKA4yIi5hZ3JpY3VsdHVyZS5zb2lsLn'
    'YxLk51dHJpZW50TGV2ZWxSBWxldmVsEiYKDnJlY29tbWVuZGF0aW9uGAUgASgJUg5yZWNvbW1l'
    'bmRhdGlvbg==');

@$core.Deprecated('Use soilReportDescriptor instead')
const SoilReport$json = {
  '1': 'SoilReport',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'sample',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soil.v1.SoilSample',
      '10': 'sample'
    },
    {
      '1': 'analysis',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soil.v1.SoilAnalysis',
      '10': 'analysis'
    },
    {
      '1': 'health_score',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soil.v1.SoilHealthScore',
      '10': 'healthScore'
    },
    {
      '1': 'nutrients',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.agriculture.soil.v1.SoilNutrient',
      '10': 'nutrients'
    },
    {'1': 'recommendations', '3': 9, '4': 3, '5': 9, '10': 'recommendations'},
    {
      '1': 'generated_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'generatedAt'
    },
  ],
};

/// Descriptor for `SoilReport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List soilReportDescriptor = $convert.base64Decode(
    'CgpTb2lsUmVwb3J0Eg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbmFudE'
    'lkEhkKCGZpZWxkX2lkGAMgASgJUgdmaWVsZElkEhcKB2Zhcm1faWQYBCABKAlSBmZhcm1JZBI3'
    'CgZzYW1wbGUYBSABKAsyHy5hZ3JpY3VsdHVyZS5zb2lsLnYxLlNvaWxTYW1wbGVSBnNhbXBsZR'
    'I9CghhbmFseXNpcxgGIAEoCzIhLmFncmljdWx0dXJlLnNvaWwudjEuU29pbEFuYWx5c2lzUghh'
    'bmFseXNpcxJHCgxoZWFsdGhfc2NvcmUYByABKAsyJC5hZ3JpY3VsdHVyZS5zb2lsLnYxLlNvaW'
    'xIZWFsdGhTY29yZVILaGVhbHRoU2NvcmUSPwoJbnV0cmllbnRzGAggAygLMiEuYWdyaWN1bHR1'
    'cmUuc29pbC52MS5Tb2lsTnV0cmllbnRSCW51dHJpZW50cxIoCg9yZWNvbW1lbmRhdGlvbnMYCS'
    'ADKAlSD3JlY29tbWVuZGF0aW9ucxI9CgxnZW5lcmF0ZWRfYXQYCiABKAsyGi5nb29nbGUucHJv'
    'dG9idWYuVGltZXN0YW1wUgtnZW5lcmF0ZWRBdA==');

@$core.Deprecated('Use createSoilSampleRequestDescriptor instead')
const CreateSoilSampleRequest$json = {
  '1': 'CreateSoilSampleRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'sample_location',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soil.v1.Location',
      '10': 'sampleLocation'
    },
    {'1': 'sample_depth_cm', '3': 5, '4': 1, '5': 1, '10': 'sampleDepthCm'},
    {
      '1': 'collection_date',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'collectionDate'
    },
    {'1': 'pH', '3': 7, '4': 1, '5': 1, '10': 'pH'},
    {
      '1': 'organic_matter_pct',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'organicMatterPct'
    },
    {'1': 'nitrogen_ppm', '3': 9, '4': 1, '5': 1, '10': 'nitrogenPpm'},
    {'1': 'phosphorus_ppm', '3': 10, '4': 1, '5': 1, '10': 'phosphorusPpm'},
    {'1': 'potassium_ppm', '3': 11, '4': 1, '5': 1, '10': 'potassiumPpm'},
    {'1': 'calcium_ppm', '3': 12, '4': 1, '5': 1, '10': 'calciumPpm'},
    {'1': 'magnesium_ppm', '3': 13, '4': 1, '5': 1, '10': 'magnesiumPpm'},
    {'1': 'sulfur_ppm', '3': 14, '4': 1, '5': 1, '10': 'sulfurPpm'},
    {'1': 'iron_ppm', '3': 15, '4': 1, '5': 1, '10': 'ironPpm'},
    {'1': 'manganese_ppm', '3': 16, '4': 1, '5': 1, '10': 'manganesePpm'},
    {'1': 'zinc_ppm', '3': 17, '4': 1, '5': 1, '10': 'zincPpm'},
    {'1': 'copper_ppm', '3': 18, '4': 1, '5': 1, '10': 'copperPpm'},
    {'1': 'boron_ppm', '3': 19, '4': 1, '5': 1, '10': 'boronPpm'},
    {'1': 'moisture_pct', '3': 20, '4': 1, '5': 1, '10': 'moisturePct'},
    {
      '1': 'texture',
      '3': 21,
      '4': 1,
      '5': 14,
      '6': '.agriculture.soil.v1.SoilTexture',
      '10': 'texture'
    },
    {'1': 'bulk_density', '3': 22, '4': 1, '5': 1, '10': 'bulkDensity'},
    {
      '1': 'cation_exchange_capacity',
      '3': 23,
      '4': 1,
      '5': 1,
      '10': 'cationExchangeCapacity'
    },
    {
      '1': 'electrical_conductivity',
      '3': 24,
      '4': 1,
      '5': 1,
      '10': 'electricalConductivity'
    },
    {'1': 'notes', '3': 25, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `CreateSoilSampleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSoilSampleRequestDescriptor = $convert.base64Decode(
    'ChdDcmVhdGVTb2lsU2FtcGxlUmVxdWVzdBIbCgl0ZW5hbnRfaWQYASABKAlSCHRlbmFudElkEh'
    'kKCGZpZWxkX2lkGAIgASgJUgdmaWVsZElkEhcKB2Zhcm1faWQYAyABKAlSBmZhcm1JZBJGCg9z'
    'YW1wbGVfbG9jYXRpb24YBCABKAsyHS5hZ3JpY3VsdHVyZS5zb2lsLnYxLkxvY2F0aW9uUg5zYW'
    '1wbGVMb2NhdGlvbhImCg9zYW1wbGVfZGVwdGhfY20YBSABKAFSDXNhbXBsZURlcHRoQ20SQwoP'
    'Y29sbGVjdGlvbl9kYXRlGAYgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIOY29sbG'
    'VjdGlvbkRhdGUSDgoCcEgYByABKAFSAnBIEiwKEm9yZ2FuaWNfbWF0dGVyX3BjdBgIIAEoAVIQ'
    'b3JnYW5pY01hdHRlclBjdBIhCgxuaXRyb2dlbl9wcG0YCSABKAFSC25pdHJvZ2VuUHBtEiUKDn'
    'Bob3NwaG9ydXNfcHBtGAogASgBUg1waG9zcGhvcnVzUHBtEiMKDXBvdGFzc2l1bV9wcG0YCyAB'
    'KAFSDHBvdGFzc2l1bVBwbRIfCgtjYWxjaXVtX3BwbRgMIAEoAVIKY2FsY2l1bVBwbRIjCg1tYW'
    'duZXNpdW1fcHBtGA0gASgBUgxtYWduZXNpdW1QcG0SHQoKc3VsZnVyX3BwbRgOIAEoAVIJc3Vs'
    'ZnVyUHBtEhkKCGlyb25fcHBtGA8gASgBUgdpcm9uUHBtEiMKDW1hbmdhbmVzZV9wcG0YECABKA'
    'FSDG1hbmdhbmVzZVBwbRIZCgh6aW5jX3BwbRgRIAEoAVIHemluY1BwbRIdCgpjb3BwZXJfcHBt'
    'GBIgASgBUgljb3BwZXJQcG0SGwoJYm9yb25fcHBtGBMgASgBUghib3JvblBwbRIhCgxtb2lzdH'
    'VyZV9wY3QYFCABKAFSC21vaXN0dXJlUGN0EjoKB3RleHR1cmUYFSABKA4yIC5hZ3JpY3VsdHVy'
    'ZS5zb2lsLnYxLlNvaWxUZXh0dXJlUgd0ZXh0dXJlEiEKDGJ1bGtfZGVuc2l0eRgWIAEoAVILYn'
    'Vsa0RlbnNpdHkSOAoYY2F0aW9uX2V4Y2hhbmdlX2NhcGFjaXR5GBcgASgBUhZjYXRpb25FeGNo'
    'YW5nZUNhcGFjaXR5EjcKF2VsZWN0cmljYWxfY29uZHVjdGl2aXR5GBggASgBUhZlbGVjdHJpY2'
    'FsQ29uZHVjdGl2aXR5EhQKBW5vdGVzGBkgASgJUgVub3Rlcw==');

@$core.Deprecated('Use createSoilSampleResponseDescriptor instead')
const CreateSoilSampleResponse$json = {
  '1': 'CreateSoilSampleResponse',
  '2': [
    {
      '1': 'sample',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soil.v1.SoilSample',
      '10': 'sample'
    },
  ],
};

/// Descriptor for `CreateSoilSampleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSoilSampleResponseDescriptor =
    $convert.base64Decode(
        'ChhDcmVhdGVTb2lsU2FtcGxlUmVzcG9uc2USNwoGc2FtcGxlGAEgASgLMh8uYWdyaWN1bHR1cm'
        'Uuc29pbC52MS5Tb2lsU2FtcGxlUgZzYW1wbGU=');

@$core.Deprecated('Use getSoilSampleRequestDescriptor instead')
const GetSoilSampleRequest$json = {
  '1': 'GetSoilSampleRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
  ],
};

/// Descriptor for `GetSoilSampleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSoilSampleRequestDescriptor = $convert.base64Decode(
    'ChRHZXRTb2lsU2FtcGxlUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgAS'
    'gJUgh0ZW5hbnRJZA==');

@$core.Deprecated('Use getSoilSampleResponseDescriptor instead')
const GetSoilSampleResponse$json = {
  '1': 'GetSoilSampleResponse',
  '2': [
    {
      '1': 'sample',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soil.v1.SoilSample',
      '10': 'sample'
    },
  ],
};

/// Descriptor for `GetSoilSampleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSoilSampleResponseDescriptor = $convert.base64Decode(
    'ChVHZXRTb2lsU2FtcGxlUmVzcG9uc2USNwoGc2FtcGxlGAEgASgLMh8uYWdyaWN1bHR1cmUuc2'
    '9pbC52MS5Tb2lsU2FtcGxlUgZzYW1wbGU=');

@$core.Deprecated('Use listSoilSamplesRequestDescriptor instead')
const ListSoilSamplesRequest$json = {
  '1': 'ListSoilSamplesRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 5, '4': 1, '5': 5, '10': 'pageOffset'},
    {'1': 'sort', '3': 6, '4': 3, '5': 9, '10': 'sort'},
    {
      '1': 'fields',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'fields'
    },
  ],
};

/// Descriptor for `ListSoilSamplesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSoilSamplesRequestDescriptor = $convert.base64Decode(
    'ChZMaXN0U29pbFNhbXBsZXNSZXF1ZXN0EhsKCXRlbmFudF9pZBgBIAEoCVIIdGVuYW50SWQSGQ'
    'oIZmllbGRfaWQYAiABKAlSB2ZpZWxkSWQSFwoHZmFybV9pZBgDIAEoCVIGZmFybUlkEhsKCXBh'
    'Z2Vfc2l6ZRgEIAEoBVIIcGFnZVNpemUSHwoLcGFnZV9vZmZzZXQYBSABKAVSCnBhZ2VPZmZzZX'
    'QSEgoEc29ydBgGIAMoCVIEc29ydBIyCgZmaWVsZHMYByABKAsyGi5nb29nbGUucHJvdG9idWYu'
    'RmllbGRNYXNrUgZmaWVsZHM=');

@$core.Deprecated('Use listSoilSamplesResponseDescriptor instead')
const ListSoilSamplesResponse$json = {
  '1': 'ListSoilSamplesResponse',
  '2': [
    {
      '1': 'samples',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.soil.v1.SoilSample',
      '10': 'samples'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
    {'1': 'has_next', '3': 3, '4': 1, '5': 8, '10': 'hasNext'},
  ],
};

/// Descriptor for `ListSoilSamplesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSoilSamplesResponseDescriptor = $convert.base64Decode(
    'ChdMaXN0U29pbFNhbXBsZXNSZXNwb25zZRI5CgdzYW1wbGVzGAEgAygLMh8uYWdyaWN1bHR1cm'
    'Uuc29pbC52MS5Tb2lsU2FtcGxlUgdzYW1wbGVzEh8KC3RvdGFsX2NvdW50GAIgASgFUgp0b3Rh'
    'bENvdW50EhkKCGhhc19uZXh0GAMgASgIUgdoYXNOZXh0');

@$core.Deprecated('Use analyzeSoilRequestDescriptor instead')
const AnalyzeSoilRequest$json = {
  '1': 'AnalyzeSoilRequest',
  '2': [
    {'1': 'sample_id', '3': 1, '4': 1, '5': 9, '10': 'sampleId'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'analysis_type', '3': 3, '4': 1, '5': 9, '10': 'analysisType'},
  ],
};

/// Descriptor for `AnalyzeSoilRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List analyzeSoilRequestDescriptor = $convert.base64Decode(
    'ChJBbmFseXplU29pbFJlcXVlc3QSGwoJc2FtcGxlX2lkGAEgASgJUghzYW1wbGVJZBIbCgl0ZW'
    '5hbnRfaWQYAiABKAlSCHRlbmFudElkEiMKDWFuYWx5c2lzX3R5cGUYAyABKAlSDGFuYWx5c2lz'
    'VHlwZQ==');

@$core.Deprecated('Use analyzeSoilResponseDescriptor instead')
const AnalyzeSoilResponse$json = {
  '1': 'AnalyzeSoilResponse',
  '2': [
    {
      '1': 'analysis',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soil.v1.SoilAnalysis',
      '10': 'analysis'
    },
  ],
};

/// Descriptor for `AnalyzeSoilResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List analyzeSoilResponseDescriptor = $convert.base64Decode(
    'ChNBbmFseXplU29pbFJlc3BvbnNlEj0KCGFuYWx5c2lzGAEgASgLMiEuYWdyaWN1bHR1cmUuc2'
    '9pbC52MS5Tb2lsQW5hbHlzaXNSCGFuYWx5c2lz');

@$core.Deprecated('Use listSoilAnalysesRequestDescriptor instead')
const ListSoilAnalysesRequest$json = {
  '1': 'ListSoilAnalysesRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'sample_id', '3': 4, '4': 1, '5': 9, '10': 'sampleId'},
    {'1': 'page_size', '3': 5, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 6, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListSoilAnalysesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSoilAnalysesRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0U29pbEFuYWx5c2VzUmVxdWVzdBIbCgl0ZW5hbnRfaWQYASABKAlSCHRlbmFudElkEh'
    'kKCGZpZWxkX2lkGAIgASgJUgdmaWVsZElkEhcKB2Zhcm1faWQYAyABKAlSBmZhcm1JZBIbCglz'
    'YW1wbGVfaWQYBCABKAlSCHNhbXBsZUlkEhsKCXBhZ2Vfc2l6ZRgFIAEoBVIIcGFnZVNpemUSHw'
    'oLcGFnZV9vZmZzZXQYBiABKAVSCnBhZ2VPZmZzZXQ=');

@$core.Deprecated('Use listSoilAnalysesResponseDescriptor instead')
const ListSoilAnalysesResponse$json = {
  '1': 'ListSoilAnalysesResponse',
  '2': [
    {
      '1': 'analyses',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.soil.v1.SoilAnalysis',
      '10': 'analyses'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
    {'1': 'has_next', '3': 3, '4': 1, '5': 8, '10': 'hasNext'},
  ],
};

/// Descriptor for `ListSoilAnalysesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSoilAnalysesResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0U29pbEFuYWx5c2VzUmVzcG9uc2USPQoIYW5hbHlzZXMYASADKAsyIS5hZ3JpY3VsdH'
    'VyZS5zb2lsLnYxLlNvaWxBbmFseXNpc1IIYW5hbHlzZXMSHwoLdG90YWxfY291bnQYAiABKAVS'
    'CnRvdGFsQ291bnQSGQoIaGFzX25leHQYAyABKAhSB2hhc05leHQ=');

@$core.Deprecated('Use getSoilMapRequestDescriptor instead')
const GetSoilMapRequest$json = {
  '1': 'GetSoilMapRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'map_type', '3': 3, '4': 1, '5': 9, '10': 'mapType'},
  ],
};

/// Descriptor for `GetSoilMapRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSoilMapRequestDescriptor = $convert.base64Decode(
    'ChFHZXRTb2lsTWFwUmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBIbCgl0ZW5hbn'
    'RfaWQYAiABKAlSCHRlbmFudElkEhkKCG1hcF90eXBlGAMgASgJUgdtYXBUeXBl');

@$core.Deprecated('Use getSoilMapResponseDescriptor instead')
const GetSoilMapResponse$json = {
  '1': 'GetSoilMapResponse',
  '2': [
    {
      '1': 'soil_map',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soil.v1.SoilMap',
      '10': 'soilMap'
    },
  ],
};

/// Descriptor for `GetSoilMapResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSoilMapResponseDescriptor = $convert.base64Decode(
    'ChJHZXRTb2lsTWFwUmVzcG9uc2USNwoIc29pbF9tYXAYASABKAsyHC5hZ3JpY3VsdHVyZS5zb2'
    'lsLnYxLlNvaWxNYXBSB3NvaWxNYXA=');

@$core.Deprecated('Use getSoilHealthRequestDescriptor instead')
const GetSoilHealthRequest$json = {
  '1': 'GetSoilHealthRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
  ],
};

/// Descriptor for `GetSoilHealthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSoilHealthRequestDescriptor = $convert.base64Decode(
    'ChRHZXRTb2lsSGVhbHRoUmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBIbCgl0ZW'
    '5hbnRfaWQYAiABKAlSCHRlbmFudElk');

@$core.Deprecated('Use getSoilHealthResponseDescriptor instead')
const GetSoilHealthResponse$json = {
  '1': 'GetSoilHealthResponse',
  '2': [
    {
      '1': 'health_score',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soil.v1.SoilHealthScore',
      '10': 'healthScore'
    },
  ],
};

/// Descriptor for `GetSoilHealthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSoilHealthResponseDescriptor = $convert.base64Decode(
    'ChVHZXRTb2lsSGVhbHRoUmVzcG9uc2USRwoMaGVhbHRoX3Njb3JlGAEgASgLMiQuYWdyaWN1bH'
    'R1cmUuc29pbC52MS5Tb2lsSGVhbHRoU2NvcmVSC2hlYWx0aFNjb3Jl');

@$core.Deprecated('Use getNutrientLevelsRequestDescriptor instead')
const GetNutrientLevelsRequest$json = {
  '1': 'GetNutrientLevelsRequest',
  '2': [
    {'1': 'sample_id', '3': 1, '4': 1, '5': 9, '10': 'sampleId'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
  ],
};

/// Descriptor for `GetNutrientLevelsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNutrientLevelsRequestDescriptor =
    $convert.base64Decode(
        'ChhHZXROdXRyaWVudExldmVsc1JlcXVlc3QSGwoJc2FtcGxlX2lkGAEgASgJUghzYW1wbGVJZB'
        'IbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbmFudElk');

@$core.Deprecated('Use getNutrientLevelsResponseDescriptor instead')
const GetNutrientLevelsResponse$json = {
  '1': 'GetNutrientLevelsResponse',
  '2': [
    {
      '1': 'nutrients',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.soil.v1.SoilNutrient',
      '10': 'nutrients'
    },
  ],
};

/// Descriptor for `GetNutrientLevelsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNutrientLevelsResponseDescriptor =
    $convert.base64Decode(
        'ChlHZXROdXRyaWVudExldmVsc1Jlc3BvbnNlEj8KCW51dHJpZW50cxgBIAMoCzIhLmFncmljdW'
        'x0dXJlLnNvaWwudjEuU29pbE51dHJpZW50UgludXRyaWVudHM=');

@$core.Deprecated('Use generateSoilReportRequestDescriptor instead')
const GenerateSoilReportRequest$json = {
  '1': 'GenerateSoilReportRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
  ],
};

/// Descriptor for `GenerateSoilReportRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateSoilReportRequestDescriptor =
    $convert.base64Decode(
        'ChlHZW5lcmF0ZVNvaWxSZXBvcnRSZXF1ZXN0EhkKCGZpZWxkX2lkGAEgASgJUgdmaWVsZElkEh'
        'sKCXRlbmFudF9pZBgCIAEoCVIIdGVuYW50SWQSFwoHZmFybV9pZBgDIAEoCVIGZmFybUlk');

@$core.Deprecated('Use generateSoilReportResponseDescriptor instead')
const GenerateSoilReportResponse$json = {
  '1': 'GenerateSoilReportResponse',
  '2': [
    {
      '1': 'report',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soil.v1.SoilReport',
      '10': 'report'
    },
  ],
};

/// Descriptor for `GenerateSoilReportResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateSoilReportResponseDescriptor =
    $convert.base64Decode(
        'ChpHZW5lcmF0ZVNvaWxSZXBvcnRSZXNwb25zZRI3CgZyZXBvcnQYASABKAsyHy5hZ3JpY3VsdH'
        'VyZS5zb2lsLnYxLlNvaWxSZXBvcnRSBnJlcG9ydA==');

const $core.Map<$core.String, $core.dynamic> SoilServiceBase$json = {
  '1': 'SoilService',
  '2': [
    {
      '1': 'CreateSoilSample',
      '2': '.agriculture.soil.v1.CreateSoilSampleRequest',
      '3': '.agriculture.soil.v1.CreateSoilSampleResponse'
    },
    {
      '1': 'GetSoilSample',
      '2': '.agriculture.soil.v1.GetSoilSampleRequest',
      '3': '.agriculture.soil.v1.GetSoilSampleResponse'
    },
    {
      '1': 'ListSoilSamples',
      '2': '.agriculture.soil.v1.ListSoilSamplesRequest',
      '3': '.agriculture.soil.v1.ListSoilSamplesResponse'
    },
    {
      '1': 'AnalyzeSoil',
      '2': '.agriculture.soil.v1.AnalyzeSoilRequest',
      '3': '.agriculture.soil.v1.AnalyzeSoilResponse'
    },
    {
      '1': 'ListSoilAnalyses',
      '2': '.agriculture.soil.v1.ListSoilAnalysesRequest',
      '3': '.agriculture.soil.v1.ListSoilAnalysesResponse'
    },
    {
      '1': 'GetSoilMap',
      '2': '.agriculture.soil.v1.GetSoilMapRequest',
      '3': '.agriculture.soil.v1.GetSoilMapResponse'
    },
    {
      '1': 'GetSoilHealth',
      '2': '.agriculture.soil.v1.GetSoilHealthRequest',
      '3': '.agriculture.soil.v1.GetSoilHealthResponse'
    },
    {
      '1': 'GetNutrientLevels',
      '2': '.agriculture.soil.v1.GetNutrientLevelsRequest',
      '3': '.agriculture.soil.v1.GetNutrientLevelsResponse'
    },
    {
      '1': 'GenerateSoilReport',
      '2': '.agriculture.soil.v1.GenerateSoilReportRequest',
      '3': '.agriculture.soil.v1.GenerateSoilReportResponse'
    },
  ],
};

@$core.Deprecated('Use soilServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    SoilServiceBase$messageJson = {
  '.agriculture.soil.v1.CreateSoilSampleRequest': CreateSoilSampleRequest$json,
  '.agriculture.soil.v1.Location': Location$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.soil.v1.CreateSoilSampleResponse':
      CreateSoilSampleResponse$json,
  '.agriculture.soil.v1.SoilSample': SoilSample$json,
  '.agriculture.soil.v1.GetSoilSampleRequest': GetSoilSampleRequest$json,
  '.agriculture.soil.v1.GetSoilSampleResponse': GetSoilSampleResponse$json,
  '.agriculture.soil.v1.ListSoilSamplesRequest': ListSoilSamplesRequest$json,
  '.google.protobuf.FieldMask': $1.FieldMask$json,
  '.agriculture.soil.v1.ListSoilSamplesResponse': ListSoilSamplesResponse$json,
  '.agriculture.soil.v1.AnalyzeSoilRequest': AnalyzeSoilRequest$json,
  '.agriculture.soil.v1.AnalyzeSoilResponse': AnalyzeSoilResponse$json,
  '.agriculture.soil.v1.SoilAnalysis': SoilAnalysis$json,
  '.agriculture.soil.v1.ListSoilAnalysesRequest': ListSoilAnalysesRequest$json,
  '.agriculture.soil.v1.ListSoilAnalysesResponse':
      ListSoilAnalysesResponse$json,
  '.agriculture.soil.v1.GetSoilMapRequest': GetSoilMapRequest$json,
  '.agriculture.soil.v1.GetSoilMapResponse': GetSoilMapResponse$json,
  '.agriculture.soil.v1.SoilMap': SoilMap$json,
  '.agriculture.soil.v1.GetSoilHealthRequest': GetSoilHealthRequest$json,
  '.agriculture.soil.v1.GetSoilHealthResponse': GetSoilHealthResponse$json,
  '.agriculture.soil.v1.SoilHealthScore': SoilHealthScore$json,
  '.agriculture.soil.v1.NutrientDeficiency': NutrientDeficiency$json,
  '.agriculture.soil.v1.GetNutrientLevelsRequest':
      GetNutrientLevelsRequest$json,
  '.agriculture.soil.v1.GetNutrientLevelsResponse':
      GetNutrientLevelsResponse$json,
  '.agriculture.soil.v1.SoilNutrient': SoilNutrient$json,
  '.agriculture.soil.v1.GenerateSoilReportRequest':
      GenerateSoilReportRequest$json,
  '.agriculture.soil.v1.GenerateSoilReportResponse':
      GenerateSoilReportResponse$json,
  '.agriculture.soil.v1.SoilReport': SoilReport$json,
};

/// Descriptor for `SoilService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List soilServiceDescriptor = $convert.base64Decode(
    'CgtTb2lsU2VydmljZRJvChBDcmVhdGVTb2lsU2FtcGxlEiwuYWdyaWN1bHR1cmUuc29pbC52MS'
    '5DcmVhdGVTb2lsU2FtcGxlUmVxdWVzdBotLmFncmljdWx0dXJlLnNvaWwudjEuQ3JlYXRlU29p'
    'bFNhbXBsZVJlc3BvbnNlEmYKDUdldFNvaWxTYW1wbGUSKS5hZ3JpY3VsdHVyZS5zb2lsLnYxLk'
    'dldFNvaWxTYW1wbGVSZXF1ZXN0GiouYWdyaWN1bHR1cmUuc29pbC52MS5HZXRTb2lsU2FtcGxl'
    'UmVzcG9uc2USbAoPTGlzdFNvaWxTYW1wbGVzEisuYWdyaWN1bHR1cmUuc29pbC52MS5MaXN0U2'
    '9pbFNhbXBsZXNSZXF1ZXN0GiwuYWdyaWN1bHR1cmUuc29pbC52MS5MaXN0U29pbFNhbXBsZXNS'
    'ZXNwb25zZRJgCgtBbmFseXplU29pbBInLmFncmljdWx0dXJlLnNvaWwudjEuQW5hbHl6ZVNvaW'
    'xSZXF1ZXN0GiguYWdyaWN1bHR1cmUuc29pbC52MS5BbmFseXplU29pbFJlc3BvbnNlEm8KEExp'
    'c3RTb2lsQW5hbHlzZXMSLC5hZ3JpY3VsdHVyZS5zb2lsLnYxLkxpc3RTb2lsQW5hbHlzZXNSZX'
    'F1ZXN0Gi0uYWdyaWN1bHR1cmUuc29pbC52MS5MaXN0U29pbEFuYWx5c2VzUmVzcG9uc2USXQoK'
    'R2V0U29pbE1hcBImLmFncmljdWx0dXJlLnNvaWwudjEuR2V0U29pbE1hcFJlcXVlc3QaJy5hZ3'
    'JpY3VsdHVyZS5zb2lsLnYxLkdldFNvaWxNYXBSZXNwb25zZRJmCg1HZXRTb2lsSGVhbHRoEiku'
    'YWdyaWN1bHR1cmUuc29pbC52MS5HZXRTb2lsSGVhbHRoUmVxdWVzdBoqLmFncmljdWx0dXJlLn'
    'NvaWwudjEuR2V0U29pbEhlYWx0aFJlc3BvbnNlEnIKEUdldE51dHJpZW50TGV2ZWxzEi0uYWdy'
    'aWN1bHR1cmUuc29pbC52MS5HZXROdXRyaWVudExldmVsc1JlcXVlc3QaLi5hZ3JpY3VsdHVyZS'
    '5zb2lsLnYxLkdldE51dHJpZW50TGV2ZWxzUmVzcG9uc2USdQoSR2VuZXJhdGVTb2lsUmVwb3J0'
    'Ei4uYWdyaWN1bHR1cmUuc29pbC52MS5HZW5lcmF0ZVNvaWxSZXBvcnRSZXF1ZXN0Gi8uYWdyaW'
    'N1bHR1cmUuc29pbC52MS5HZW5lcmF0ZVNvaWxSZXBvcnRSZXNwb25zZQ==');
