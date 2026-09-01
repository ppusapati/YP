// This is a generated file - do not edit.
//
// Generated from crop.proto.

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

@$core.Deprecated('Use cropCategoryDescriptor instead')
const CropCategory$json = {
  '1': 'CropCategory',
  '2': [
    {'1': 'CROP_CATEGORY_UNSPECIFIED', '2': 0},
    {'1': 'CROP_CATEGORY_CEREAL', '2': 1},
    {'1': 'CROP_CATEGORY_LEGUME', '2': 2},
    {'1': 'CROP_CATEGORY_VEGETABLE', '2': 3},
    {'1': 'CROP_CATEGORY_FRUIT', '2': 4},
    {'1': 'CROP_CATEGORY_OILSEED', '2': 5},
    {'1': 'CROP_CATEGORY_FIBER', '2': 6},
    {'1': 'CROP_CATEGORY_SPICE', '2': 7},
  ],
};

/// Descriptor for `CropCategory`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List cropCategoryDescriptor = $convert.base64Decode(
    'CgxDcm9wQ2F0ZWdvcnkSHQoZQ1JPUF9DQVRFR09SWV9VTlNQRUNJRklFRBAAEhgKFENST1BfQ0'
    'FURUdPUllfQ0VSRUFMEAESGAoUQ1JPUF9DQVRFR09SWV9MRUdVTUUQAhIbChdDUk9QX0NBVEVH'
    'T1JZX1ZFR0VUQUJMRRADEhcKE0NST1BfQ0FURUdPUllfRlJVSVQQBBIZChVDUk9QX0NBVEVHT1'
    'JZX09JTFNFRUQQBRIXChNDUk9QX0NBVEVHT1JZX0ZJQkVSEAYSFwoTQ1JPUF9DQVRFR09SWV9T'
    'UElDRRAH');

@$core.Deprecated('Use growthStageDescriptor instead')
const GrowthStage$json = {
  '1': 'GrowthStage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'crop_id', '3': 2, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'stage_order', '3': 4, '4': 1, '5': 5, '10': 'stageOrder'},
    {'1': 'duration_days', '3': 5, '4': 1, '5': 5, '10': 'durationDays'},
    {
      '1': 'water_requirement_mm',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'waterRequirementMm'
    },
    {
      '1': 'nutrient_requirements',
      '3': 7,
      '4': 1,
      '5': 9,
      '10': 'nutrientRequirements'
    },
    {'1': 'description', '3': 8, '4': 1, '5': 9, '10': 'description'},
    {'1': 'optimal_temp_min', '3': 9, '4': 1, '5': 1, '10': 'optimalTempMin'},
    {'1': 'optimal_temp_max', '3': 10, '4': 1, '5': 1, '10': 'optimalTempMax'},
    {
      '1': 'created_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `GrowthStage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List growthStageDescriptor = $convert.base64Decode(
    'CgtHcm93dGhTdGFnZRIOCgJpZBgBIAEoCVICaWQSFwoHY3JvcF9pZBgCIAEoCVIGY3JvcElkEh'
    'IKBG5hbWUYAyABKAlSBG5hbWUSHwoLc3RhZ2Vfb3JkZXIYBCABKAVSCnN0YWdlT3JkZXISIwoN'
    'ZHVyYXRpb25fZGF5cxgFIAEoBVIMZHVyYXRpb25EYXlzEjAKFHdhdGVyX3JlcXVpcmVtZW50X2'
    '1tGAYgASgBUhJ3YXRlclJlcXVpcmVtZW50TW0SMwoVbnV0cmllbnRfcmVxdWlyZW1lbnRzGAcg'
    'ASgJUhRudXRyaWVudFJlcXVpcmVtZW50cxIgCgtkZXNjcmlwdGlvbhgIIAEoCVILZGVzY3JpcH'
    'Rpb24SKAoQb3B0aW1hbF90ZW1wX21pbhgJIAEoAVIOb3B0aW1hbFRlbXBNaW4SKAoQb3B0aW1h'
    'bF90ZW1wX21heBgKIAEoAVIOb3B0aW1hbFRlbXBNYXgSOQoKY3JlYXRlZF9hdBgLIAEoCzIaLm'
    'dvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GAwgASgL'
    'MhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZEF0');

@$core.Deprecated('Use cropVarietyDescriptor instead')
const CropVariety$json = {
  '1': 'CropVariety',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'crop_id', '3': 2, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'maturity_days', '3': 5, '4': 1, '5': 5, '10': 'maturityDays'},
    {
      '1': 'yield_potential_kg_per_hectare',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'yieldPotentialKgPerHectare'
    },
    {'1': 'is_hybrid', '3': 7, '4': 1, '5': 8, '10': 'isHybrid'},
    {
      '1': 'disease_resistance',
      '3': 8,
      '4': 1,
      '5': 9,
      '10': 'diseaseResistance'
    },
    {'1': 'suitable_regions', '3': 9, '4': 1, '5': 9, '10': 'suitableRegions'},
    {
      '1': 'seed_rate_kg_per_hectare',
      '3': 10,
      '4': 1,
      '5': 9,
      '10': 'seedRateKgPerHectare'
    },
    {
      '1': 'created_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `CropVariety`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cropVarietyDescriptor = $convert.base64Decode(
    'CgtDcm9wVmFyaWV0eRIOCgJpZBgBIAEoCVICaWQSFwoHY3JvcF9pZBgCIAEoCVIGY3JvcElkEh'
    'IKBG5hbWUYAyABKAlSBG5hbWUSIAoLZGVzY3JpcHRpb24YBCABKAlSC2Rlc2NyaXB0aW9uEiMK'
    'DW1hdHVyaXR5X2RheXMYBSABKAVSDG1hdHVyaXR5RGF5cxJCCh55aWVsZF9wb3RlbnRpYWxfa2'
    'dfcGVyX2hlY3RhcmUYBiABKAFSGnlpZWxkUG90ZW50aWFsS2dQZXJIZWN0YXJlEhsKCWlzX2h5'
    'YnJpZBgHIAEoCFIIaXNIeWJyaWQSLQoSZGlzZWFzZV9yZXNpc3RhbmNlGAggASgJUhFkaXNlYX'
    'NlUmVzaXN0YW5jZRIpChBzdWl0YWJsZV9yZWdpb25zGAkgASgJUg9zdWl0YWJsZVJlZ2lvbnMS'
    'NgoYc2VlZF9yYXRlX2tnX3Blcl9oZWN0YXJlGAogASgJUhRzZWVkUmF0ZUtnUGVySGVjdGFyZR'
    'I5CgpjcmVhdGVkX2F0GAsgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRl'
    'ZEF0EjkKCnVwZGF0ZWRfYXQYDCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cG'
    'RhdGVkQXQ=');

@$core.Deprecated('Use cropRequirementsDescriptor instead')
const CropRequirements$json = {
  '1': 'CropRequirements',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'crop_id', '3': 2, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'optimal_temp_min', '3': 3, '4': 1, '5': 1, '10': 'optimalTempMin'},
    {'1': 'optimal_temp_max', '3': 4, '4': 1, '5': 1, '10': 'optimalTempMax'},
    {
      '1': 'optimal_humidity_min',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'optimalHumidityMin'
    },
    {
      '1': 'optimal_humidity_max',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'optimalHumidityMax'
    },
    {
      '1': 'optimal_soil_ph_min',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'optimalSoilPhMin'
    },
    {
      '1': 'optimal_soil_ph_max',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'optimalSoilPhMax'
    },
    {
      '1': 'water_requirement_mm_per_day',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'waterRequirementMmPerDay'
    },
    {'1': 'sunlight_hours', '3': 10, '4': 1, '5': 1, '10': 'sunlightHours'},
    {'1': 'frost_tolerant', '3': 11, '4': 1, '5': 8, '10': 'frostTolerant'},
    {'1': 'drought_tolerant', '3': 12, '4': 1, '5': 8, '10': 'droughtTolerant'},
    {
      '1': 'soil_type_preference',
      '3': 13,
      '4': 1,
      '5': 9,
      '10': 'soilTypePreference'
    },
    {
      '1': 'nutrient_requirements',
      '3': 14,
      '4': 1,
      '5': 9,
      '10': 'nutrientRequirements'
    },
    {
      '1': 'created_at',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `CropRequirements`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cropRequirementsDescriptor = $convert.base64Decode(
    'ChBDcm9wUmVxdWlyZW1lbnRzEg4KAmlkGAEgASgJUgJpZBIXCgdjcm9wX2lkGAIgASgJUgZjcm'
    '9wSWQSKAoQb3B0aW1hbF90ZW1wX21pbhgDIAEoAVIOb3B0aW1hbFRlbXBNaW4SKAoQb3B0aW1h'
    'bF90ZW1wX21heBgEIAEoAVIOb3B0aW1hbFRlbXBNYXgSMAoUb3B0aW1hbF9odW1pZGl0eV9taW'
    '4YBSABKAFSEm9wdGltYWxIdW1pZGl0eU1pbhIwChRvcHRpbWFsX2h1bWlkaXR5X21heBgGIAEo'
    'AVISb3B0aW1hbEh1bWlkaXR5TWF4Ei0KE29wdGltYWxfc29pbF9waF9taW4YByABKAFSEG9wdG'
    'ltYWxTb2lsUGhNaW4SLQoTb3B0aW1hbF9zb2lsX3BoX21heBgIIAEoAVIQb3B0aW1hbFNvaWxQ'
    'aE1heBI+Chx3YXRlcl9yZXF1aXJlbWVudF9tbV9wZXJfZGF5GAkgASgBUhh3YXRlclJlcXVpcm'
    'VtZW50TW1QZXJEYXkSJQoOc3VubGlnaHRfaG91cnMYCiABKAFSDXN1bmxpZ2h0SG91cnMSJQoO'
    'ZnJvc3RfdG9sZXJhbnQYCyABKAhSDWZyb3N0VG9sZXJhbnQSKQoQZHJvdWdodF90b2xlcmFudB'
    'gMIAEoCFIPZHJvdWdodFRvbGVyYW50EjAKFHNvaWxfdHlwZV9wcmVmZXJlbmNlGA0gASgJUhJz'
    'b2lsVHlwZVByZWZlcmVuY2USMwoVbnV0cmllbnRfcmVxdWlyZW1lbnRzGA4gASgJUhRudXRyaW'
    'VudFJlcXVpcmVtZW50cxI5CgpjcmVhdGVkX2F0GA8gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRp'
    'bWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYECABKAsyGi5nb29nbGUucHJvdG9idW'
    'YuVGltZXN0YW1wUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use cropRecommendationDescriptor instead')
const CropRecommendation$json = {
  '1': 'CropRecommendation',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'crop_id', '3': 2, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'tenant_id', '3': 3, '4': 1, '5': 9, '10': 'tenantId'},
    {
      '1': 'recommendation_type',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'recommendationType'
    },
    {'1': 'title', '3': 5, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {'1': 'severity', '3': 7, '4': 1, '5': 9, '10': 'severity'},
    {'1': 'confidence_score', '3': 8, '4': 1, '5': 1, '10': 'confidenceScore'},
    {'1': 'parameters', '3': 9, '4': 1, '5': 9, '10': 'parameters'},
    {
      '1': 'applicable_growth_stage',
      '3': 10,
      '4': 1,
      '5': 9,
      '10': 'applicableGrowthStage'
    },
    {
      '1': 'valid_from',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validFrom'
    },
    {
      '1': 'valid_until',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validUntil'
    },
    {
      '1': 'created_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `CropRecommendation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cropRecommendationDescriptor = $convert.base64Decode(
    'ChJDcm9wUmVjb21tZW5kYXRpb24SDgoCaWQYASABKAlSAmlkEhcKB2Nyb3BfaWQYAiABKAlSBm'
    'Nyb3BJZBIbCgl0ZW5hbnRfaWQYAyABKAlSCHRlbmFudElkEi8KE3JlY29tbWVuZGF0aW9uX3R5'
    'cGUYBCABKAlSEnJlY29tbWVuZGF0aW9uVHlwZRIUCgV0aXRsZRgFIAEoCVIFdGl0bGUSIAoLZG'
    'VzY3JpcHRpb24YBiABKAlSC2Rlc2NyaXB0aW9uEhoKCHNldmVyaXR5GAcgASgJUghzZXZlcml0'
    'eRIpChBjb25maWRlbmNlX3Njb3JlGAggASgBUg9jb25maWRlbmNlU2NvcmUSHgoKcGFyYW1ldG'
    'VycxgJIAEoCVIKcGFyYW1ldGVycxI2ChdhcHBsaWNhYmxlX2dyb3d0aF9zdGFnZRgKIAEoCVIV'
    'YXBwbGljYWJsZUdyb3d0aFN0YWdlEjkKCnZhbGlkX2Zyb20YCyABKAsyGi5nb29nbGUucHJvdG'
    '9idWYuVGltZXN0YW1wUgl2YWxpZEZyb20SOwoLdmFsaWRfdW50aWwYDCABKAsyGi5nb29nbGUu'
    'cHJvdG9idWYuVGltZXN0YW1wUgp2YWxpZFVudGlsEjkKCmNyZWF0ZWRfYXQYDSABKAsyGi5nb2'
    '9nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use cropDescriptor instead')
const Crop$json = {
  '1': 'Crop',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'scientific_name', '3': 4, '4': 1, '5': 9, '10': 'scientificName'},
    {'1': 'family', '3': 5, '4': 1, '5': 9, '10': 'family'},
    {
      '1': 'category',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.crop.v1.CropCategory',
      '10': 'category'
    },
    {'1': 'description', '3': 7, '4': 1, '5': 9, '10': 'description'},
    {'1': 'image_url', '3': 8, '4': 1, '5': 9, '10': 'imageUrl'},
    {
      '1': 'disease_susceptibilities',
      '3': 9,
      '4': 3,
      '5': 9,
      '10': 'diseaseSusceptibilities'
    },
    {'1': 'companion_plants', '3': 10, '4': 3, '5': 9, '10': 'companionPlants'},
    {'1': 'rotation_group', '3': 11, '4': 1, '5': 9, '10': 'rotationGroup'},
    {'1': 'version', '3': 12, '4': 1, '5': 5, '10': 'version'},
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
    {
      '1': 'varieties',
      '3': 15,
      '4': 3,
      '5': 11,
      '6': '.agriculture.crop.v1.CropVariety',
      '10': 'varieties'
    },
    {
      '1': 'growth_stages',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.agriculture.crop.v1.GrowthStage',
      '10': 'growthStages'
    },
    {
      '1': 'requirements',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.agriculture.crop.v1.CropRequirements',
      '10': 'requirements'
    },
  ],
};

/// Descriptor for `Crop`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cropDescriptor = $convert.base64Decode(
    'CgRDcm9wEg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbmFudElkEhIKBG'
    '5hbWUYAyABKAlSBG5hbWUSJwoPc2NpZW50aWZpY19uYW1lGAQgASgJUg5zY2llbnRpZmljTmFt'
    'ZRIWCgZmYW1pbHkYBSABKAlSBmZhbWlseRI9CghjYXRlZ29yeRgGIAEoDjIhLmFncmljdWx0dX'
    'JlLmNyb3AudjEuQ3JvcENhdGVnb3J5UghjYXRlZ29yeRIgCgtkZXNjcmlwdGlvbhgHIAEoCVIL'
    'ZGVzY3JpcHRpb24SGwoJaW1hZ2VfdXJsGAggASgJUghpbWFnZVVybBI5ChhkaXNlYXNlX3N1c2'
    'NlcHRpYmlsaXRpZXMYCSADKAlSF2Rpc2Vhc2VTdXNjZXB0aWJpbGl0aWVzEikKEGNvbXBhbmlv'
    'bl9wbGFudHMYCiADKAlSD2NvbXBhbmlvblBsYW50cxIlCg5yb3RhdGlvbl9ncm91cBgLIAEoCV'
    'INcm90YXRpb25Hcm91cBIYCgd2ZXJzaW9uGAwgASgFUgd2ZXJzaW9uEjkKCmNyZWF0ZWRfYXQY'
    'DSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRlZF'
    '9hdBgOIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdBI+Cgl2YXJp'
    'ZXRpZXMYDyADKAsyIC5hZ3JpY3VsdHVyZS5jcm9wLnYxLkNyb3BWYXJpZXR5Ugl2YXJpZXRpZX'
    'MSRQoNZ3Jvd3RoX3N0YWdlcxgQIAMoCzIgLmFncmljdWx0dXJlLmNyb3AudjEuR3Jvd3RoU3Rh'
    'Z2VSDGdyb3d0aFN0YWdlcxJJCgxyZXF1aXJlbWVudHMYESABKAsyJS5hZ3JpY3VsdHVyZS5jcm'
    '9wLnYxLkNyb3BSZXF1aXJlbWVudHNSDHJlcXVpcmVtZW50cw==');

@$core.Deprecated('Use createCropRequestDescriptor instead')
const CreateCropRequest$json = {
  '1': 'CreateCropRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'scientific_name', '3': 3, '4': 1, '5': 9, '10': 'scientificName'},
    {'1': 'family', '3': 4, '4': 1, '5': 9, '10': 'family'},
    {
      '1': 'category',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.crop.v1.CropCategory',
      '10': 'category'
    },
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {'1': 'image_url', '3': 7, '4': 1, '5': 9, '10': 'imageUrl'},
    {
      '1': 'disease_susceptibilities',
      '3': 8,
      '4': 3,
      '5': 9,
      '10': 'diseaseSusceptibilities'
    },
    {'1': 'companion_plants', '3': 9, '4': 3, '5': 9, '10': 'companionPlants'},
    {'1': 'rotation_group', '3': 10, '4': 1, '5': 9, '10': 'rotationGroup'},
  ],
};

/// Descriptor for `CreateCropRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCropRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVDcm9wUmVxdWVzdBIbCgl0ZW5hbnRfaWQYASABKAlSCHRlbmFudElkEhIKBG5hbW'
    'UYAiABKAlSBG5hbWUSJwoPc2NpZW50aWZpY19uYW1lGAMgASgJUg5zY2llbnRpZmljTmFtZRIW'
    'CgZmYW1pbHkYBCABKAlSBmZhbWlseRI9CghjYXRlZ29yeRgFIAEoDjIhLmFncmljdWx0dXJlLm'
    'Nyb3AudjEuQ3JvcENhdGVnb3J5UghjYXRlZ29yeRIgCgtkZXNjcmlwdGlvbhgGIAEoCVILZGVz'
    'Y3JpcHRpb24SGwoJaW1hZ2VfdXJsGAcgASgJUghpbWFnZVVybBI5ChhkaXNlYXNlX3N1c2NlcH'
    'RpYmlsaXRpZXMYCCADKAlSF2Rpc2Vhc2VTdXNjZXB0aWJpbGl0aWVzEikKEGNvbXBhbmlvbl9w'
    'bGFudHMYCSADKAlSD2NvbXBhbmlvblBsYW50cxIlCg5yb3RhdGlvbl9ncm91cBgKIAEoCVINcm'
    '90YXRpb25Hcm91cA==');

@$core.Deprecated('Use createCropResponseDescriptor instead')
const CreateCropResponse$json = {
  '1': 'CreateCropResponse',
  '2': [
    {
      '1': 'crop',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.crop.v1.Crop',
      '10': 'crop'
    },
  ],
};

/// Descriptor for `CreateCropResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCropResponseDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVDcm9wUmVzcG9uc2USLQoEY3JvcBgBIAEoCzIZLmFncmljdWx0dXJlLmNyb3Audj'
    'EuQ3JvcFIEY3JvcA==');

@$core.Deprecated('Use getCropRequestDescriptor instead')
const GetCropRequest$json = {
  '1': 'GetCropRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
  ],
};

/// Descriptor for `GetCropRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCropRequestDescriptor = $convert.base64Decode(
    'Cg5HZXRDcm9wUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW'
    '5hbnRJZA==');

@$core.Deprecated('Use getCropResponseDescriptor instead')
const GetCropResponse$json = {
  '1': 'GetCropResponse',
  '2': [
    {
      '1': 'crop',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.crop.v1.Crop',
      '10': 'crop'
    },
  ],
};

/// Descriptor for `GetCropResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCropResponseDescriptor = $convert.base64Decode(
    'Cg9HZXRDcm9wUmVzcG9uc2USLQoEY3JvcBgBIAEoCzIZLmFncmljdWx0dXJlLmNyb3AudjEuQ3'
    'JvcFIEY3JvcA==');

@$core.Deprecated('Use listCropsRequestDescriptor instead')
const ListCropsRequest$json = {
  '1': 'ListCropsRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {
      '1': 'category',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.crop.v1.CropCategory',
      '10': 'category'
    },
    {'1': 'search_term', '3': 3, '4': 1, '5': 9, '10': 'searchTerm'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 5, '4': 1, '5': 5, '10': 'pageOffset'},
    {'1': 'sort', '3': 6, '4': 3, '5': 9, '10': 'sort'},
    {
      '1': 'field_mask',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'fieldMask'
    },
  ],
};

/// Descriptor for `ListCropsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCropsRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0Q3JvcHNSZXF1ZXN0EhsKCXRlbmFudF9pZBgBIAEoCVIIdGVuYW50SWQSPQoIY2F0ZW'
    'dvcnkYAiABKA4yIS5hZ3JpY3VsdHVyZS5jcm9wLnYxLkNyb3BDYXRlZ29yeVIIY2F0ZWdvcnkS'
    'HwoLc2VhcmNoX3Rlcm0YAyABKAlSCnNlYXJjaFRlcm0SGwoJcGFnZV9zaXplGAQgASgFUghwYW'
    'dlU2l6ZRIfCgtwYWdlX29mZnNldBgFIAEoBVIKcGFnZU9mZnNldBISCgRzb3J0GAYgAygJUgRz'
    'b3J0EjkKCmZpZWxkX21hc2sYByABKAsyGi5nb29nbGUucHJvdG9idWYuRmllbGRNYXNrUglmaW'
    'VsZE1hc2s=');

@$core.Deprecated('Use listCropsResponseDescriptor instead')
const ListCropsResponse$json = {
  '1': 'ListCropsResponse',
  '2': [
    {
      '1': 'crops',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.crop.v1.Crop',
      '10': 'crops'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListCropsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCropsResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0Q3JvcHNSZXNwb25zZRIvCgVjcm9wcxgBIAMoCzIZLmFncmljdWx0dXJlLmNyb3Audj'
    'EuQ3JvcFIFY3JvcHMSHwoLdG90YWxfY291bnQYAiABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use updateCropRequestDescriptor instead')
const UpdateCropRequest$json = {
  '1': 'UpdateCropRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'scientific_name', '3': 4, '4': 1, '5': 9, '10': 'scientificName'},
    {'1': 'family', '3': 5, '4': 1, '5': 9, '10': 'family'},
    {
      '1': 'category',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.crop.v1.CropCategory',
      '10': 'category'
    },
    {'1': 'description', '3': 7, '4': 1, '5': 9, '10': 'description'},
    {'1': 'image_url', '3': 8, '4': 1, '5': 9, '10': 'imageUrl'},
    {
      '1': 'disease_susceptibilities',
      '3': 9,
      '4': 3,
      '5': 9,
      '10': 'diseaseSusceptibilities'
    },
    {'1': 'companion_plants', '3': 10, '4': 3, '5': 9, '10': 'companionPlants'},
    {'1': 'rotation_group', '3': 11, '4': 1, '5': 9, '10': 'rotationGroup'},
    {'1': 'version', '3': 12, '4': 1, '5': 5, '10': 'version'},
    {
      '1': 'update_mask',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
  ],
};

/// Descriptor for `UpdateCropRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateCropRequestDescriptor = $convert.base64Decode(
    'ChFVcGRhdGVDcm9wUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUg'
    'h0ZW5hbnRJZBISCgRuYW1lGAMgASgJUgRuYW1lEicKD3NjaWVudGlmaWNfbmFtZRgEIAEoCVIO'
    'c2NpZW50aWZpY05hbWUSFgoGZmFtaWx5GAUgASgJUgZmYW1pbHkSPQoIY2F0ZWdvcnkYBiABKA'
    '4yIS5hZ3JpY3VsdHVyZS5jcm9wLnYxLkNyb3BDYXRlZ29yeVIIY2F0ZWdvcnkSIAoLZGVzY3Jp'
    'cHRpb24YByABKAlSC2Rlc2NyaXB0aW9uEhsKCWltYWdlX3VybBgIIAEoCVIIaW1hZ2VVcmwSOQ'
    'oYZGlzZWFzZV9zdXNjZXB0aWJpbGl0aWVzGAkgAygJUhdkaXNlYXNlU3VzY2VwdGliaWxpdGll'
    'cxIpChBjb21wYW5pb25fcGxhbnRzGAogAygJUg9jb21wYW5pb25QbGFudHMSJQoOcm90YXRpb2'
    '5fZ3JvdXAYCyABKAlSDXJvdGF0aW9uR3JvdXASGAoHdmVyc2lvbhgMIAEoBVIHdmVyc2lvbhI7'
    'Cgt1cGRhdGVfbWFzaxgNIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5GaWVsZE1hc2tSCnVwZGF0ZU'
    '1hc2s=');

@$core.Deprecated('Use updateCropResponseDescriptor instead')
const UpdateCropResponse$json = {
  '1': 'UpdateCropResponse',
  '2': [
    {
      '1': 'crop',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.crop.v1.Crop',
      '10': 'crop'
    },
  ],
};

/// Descriptor for `UpdateCropResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateCropResponseDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVDcm9wUmVzcG9uc2USLQoEY3JvcBgBIAEoCzIZLmFncmljdWx0dXJlLmNyb3Audj'
    'EuQ3JvcFIEY3JvcA==');

@$core.Deprecated('Use deleteCropRequestDescriptor instead')
const DeleteCropRequest$json = {
  '1': 'DeleteCropRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
  ],
};

/// Descriptor for `DeleteCropRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteCropRequestDescriptor = $convert.base64Decode(
    'ChFEZWxldGVDcm9wUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUg'
    'h0ZW5hbnRJZA==');

@$core.Deprecated('Use deleteCropResponseDescriptor instead')
const DeleteCropResponse$json = {
  '1': 'DeleteCropResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `DeleteCropResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteCropResponseDescriptor =
    $convert.base64Decode(
        'ChJEZWxldGVDcm9wUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcw==');

@$core.Deprecated('Use addVarietyRequestDescriptor instead')
const AddVarietyRequest$json = {
  '1': 'AddVarietyRequest',
  '2': [
    {'1': 'crop_id', '3': 1, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'maturity_days', '3': 5, '4': 1, '5': 5, '10': 'maturityDays'},
    {
      '1': 'yield_potential_kg_per_hectare',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'yieldPotentialKgPerHectare'
    },
    {'1': 'is_hybrid', '3': 7, '4': 1, '5': 8, '10': 'isHybrid'},
    {
      '1': 'disease_resistance',
      '3': 8,
      '4': 1,
      '5': 9,
      '10': 'diseaseResistance'
    },
    {'1': 'suitable_regions', '3': 9, '4': 1, '5': 9, '10': 'suitableRegions'},
    {
      '1': 'seed_rate_kg_per_hectare',
      '3': 10,
      '4': 1,
      '5': 9,
      '10': 'seedRateKgPerHectare'
    },
  ],
};

/// Descriptor for `AddVarietyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addVarietyRequestDescriptor = $convert.base64Decode(
    'ChFBZGRWYXJpZXR5UmVxdWVzdBIXCgdjcm9wX2lkGAEgASgJUgZjcm9wSWQSGwoJdGVuYW50X2'
    'lkGAIgASgJUgh0ZW5hbnRJZBISCgRuYW1lGAMgASgJUgRuYW1lEiAKC2Rlc2NyaXB0aW9uGAQg'
    'ASgJUgtkZXNjcmlwdGlvbhIjCg1tYXR1cml0eV9kYXlzGAUgASgFUgxtYXR1cml0eURheXMSQg'
    'oeeWllbGRfcG90ZW50aWFsX2tnX3Blcl9oZWN0YXJlGAYgASgBUhp5aWVsZFBvdGVudGlhbEtn'
    'UGVySGVjdGFyZRIbCglpc19oeWJyaWQYByABKAhSCGlzSHlicmlkEi0KEmRpc2Vhc2VfcmVzaX'
    'N0YW5jZRgIIAEoCVIRZGlzZWFzZVJlc2lzdGFuY2USKQoQc3VpdGFibGVfcmVnaW9ucxgJIAEo'
    'CVIPc3VpdGFibGVSZWdpb25zEjYKGHNlZWRfcmF0ZV9rZ19wZXJfaGVjdGFyZRgKIAEoCVIUc2'
    'VlZFJhdGVLZ1BlckhlY3RhcmU=');

@$core.Deprecated('Use addVarietyResponseDescriptor instead')
const AddVarietyResponse$json = {
  '1': 'AddVarietyResponse',
  '2': [
    {
      '1': 'variety',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.crop.v1.CropVariety',
      '10': 'variety'
    },
  ],
};

/// Descriptor for `AddVarietyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addVarietyResponseDescriptor = $convert.base64Decode(
    'ChJBZGRWYXJpZXR5UmVzcG9uc2USOgoHdmFyaWV0eRgBIAEoCzIgLmFncmljdWx0dXJlLmNyb3'
    'AudjEuQ3JvcFZhcmlldHlSB3ZhcmlldHk=');

@$core.Deprecated('Use listVarietiesRequestDescriptor instead')
const ListVarietiesRequest$json = {
  '1': 'ListVarietiesRequest',
  '2': [
    {'1': 'crop_id', '3': 1, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 4, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListVarietiesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listVarietiesRequestDescriptor = $convert.base64Decode(
    'ChRMaXN0VmFyaWV0aWVzUmVxdWVzdBIXCgdjcm9wX2lkGAEgASgJUgZjcm9wSWQSGwoJdGVuYW'
    '50X2lkGAIgASgJUgh0ZW5hbnRJZBIbCglwYWdlX3NpemUYAyABKAVSCHBhZ2VTaXplEh8KC3Bh'
    'Z2Vfb2Zmc2V0GAQgASgFUgpwYWdlT2Zmc2V0');

@$core.Deprecated('Use listVarietiesResponseDescriptor instead')
const ListVarietiesResponse$json = {
  '1': 'ListVarietiesResponse',
  '2': [
    {
      '1': 'varieties',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.crop.v1.CropVariety',
      '10': 'varieties'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListVarietiesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listVarietiesResponseDescriptor = $convert.base64Decode(
    'ChVMaXN0VmFyaWV0aWVzUmVzcG9uc2USPgoJdmFyaWV0aWVzGAEgAygLMiAuYWdyaWN1bHR1cm'
    'UuY3JvcC52MS5Dcm9wVmFyaWV0eVIJdmFyaWV0aWVzEh8KC3RvdGFsX2NvdW50GAIgASgFUgp0'
    'b3RhbENvdW50');

@$core.Deprecated('Use getGrowthStagesRequestDescriptor instead')
const GetGrowthStagesRequest$json = {
  '1': 'GetGrowthStagesRequest',
  '2': [
    {'1': 'crop_id', '3': 1, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
  ],
};

/// Descriptor for `GetGrowthStagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGrowthStagesRequestDescriptor =
    $convert.base64Decode(
        'ChZHZXRHcm93dGhTdGFnZXNSZXF1ZXN0EhcKB2Nyb3BfaWQYASABKAlSBmNyb3BJZBIbCgl0ZW'
        '5hbnRfaWQYAiABKAlSCHRlbmFudElk');

@$core.Deprecated('Use getGrowthStagesResponseDescriptor instead')
const GetGrowthStagesResponse$json = {
  '1': 'GetGrowthStagesResponse',
  '2': [
    {
      '1': 'growth_stages',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.crop.v1.GrowthStage',
      '10': 'growthStages'
    },
  ],
};

/// Descriptor for `GetGrowthStagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getGrowthStagesResponseDescriptor =
    $convert.base64Decode(
        'ChdHZXRHcm93dGhTdGFnZXNSZXNwb25zZRJFCg1ncm93dGhfc3RhZ2VzGAEgAygLMiAuYWdyaW'
        'N1bHR1cmUuY3JvcC52MS5Hcm93dGhTdGFnZVIMZ3Jvd3RoU3RhZ2Vz');

@$core.Deprecated('Use getCropRequirementsRequestDescriptor instead')
const GetCropRequirementsRequest$json = {
  '1': 'GetCropRequirementsRequest',
  '2': [
    {'1': 'crop_id', '3': 1, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
  ],
};

/// Descriptor for `GetCropRequirementsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCropRequirementsRequestDescriptor =
    $convert.base64Decode(
        'ChpHZXRDcm9wUmVxdWlyZW1lbnRzUmVxdWVzdBIXCgdjcm9wX2lkGAEgASgJUgZjcm9wSWQSGw'
        'oJdGVuYW50X2lkGAIgASgJUgh0ZW5hbnRJZA==');

@$core.Deprecated('Use getCropRequirementsResponseDescriptor instead')
const GetCropRequirementsResponse$json = {
  '1': 'GetCropRequirementsResponse',
  '2': [
    {
      '1': 'requirements',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.crop.v1.CropRequirements',
      '10': 'requirements'
    },
  ],
};

/// Descriptor for `GetCropRequirementsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCropRequirementsResponseDescriptor =
    $convert.base64Decode(
        'ChtHZXRDcm9wUmVxdWlyZW1lbnRzUmVzcG9uc2USSQoMcmVxdWlyZW1lbnRzGAEgASgLMiUuYW'
        'dyaWN1bHR1cmUuY3JvcC52MS5Dcm9wUmVxdWlyZW1lbnRzUgxyZXF1aXJlbWVudHM=');

@$core.Deprecated('Use generateRecommendationRequestDescriptor instead')
const GenerateRecommendationRequest$json = {
  '1': 'GenerateRecommendationRequest',
  '2': [
    {'1': 'crop_id', '3': 1, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {
      '1': 'recommendation_type',
      '3': 3,
      '4': 1,
      '5': 9,
      '10': 'recommendationType'
    },
    {
      '1': 'current_growth_stage',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'currentGrowthStage'
    },
    {
      '1': 'current_temperature',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'currentTemperature'
    },
    {'1': 'current_humidity', '3': 6, '4': 1, '5': 1, '10': 'currentHumidity'},
    {'1': 'current_soil_ph', '3': 7, '4': 1, '5': 1, '10': 'currentSoilPh'},
    {
      '1': 'current_soil_moisture',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'currentSoilMoisture'
    },
  ],
};

/// Descriptor for `GenerateRecommendationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateRecommendationRequestDescriptor = $convert.base64Decode(
    'Ch1HZW5lcmF0ZVJlY29tbWVuZGF0aW9uUmVxdWVzdBIXCgdjcm9wX2lkGAEgASgJUgZjcm9wSW'
    'QSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW5hbnRJZBIvChNyZWNvbW1lbmRhdGlvbl90eXBlGAMg'
    'ASgJUhJyZWNvbW1lbmRhdGlvblR5cGUSMAoUY3VycmVudF9ncm93dGhfc3RhZ2UYBCABKAlSEm'
    'N1cnJlbnRHcm93dGhTdGFnZRIvChNjdXJyZW50X3RlbXBlcmF0dXJlGAUgASgBUhJjdXJyZW50'
    'VGVtcGVyYXR1cmUSKQoQY3VycmVudF9odW1pZGl0eRgGIAEoAVIPY3VycmVudEh1bWlkaXR5Ei'
    'YKD2N1cnJlbnRfc29pbF9waBgHIAEoAVINY3VycmVudFNvaWxQaBIyChVjdXJyZW50X3NvaWxf'
    'bW9pc3R1cmUYCCABKAFSE2N1cnJlbnRTb2lsTW9pc3R1cmU=');

@$core.Deprecated('Use generateRecommendationResponseDescriptor instead')
const GenerateRecommendationResponse$json = {
  '1': 'GenerateRecommendationResponse',
  '2': [
    {
      '1': 'recommendation',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.crop.v1.CropRecommendation',
      '10': 'recommendation'
    },
  ],
};

/// Descriptor for `GenerateRecommendationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateRecommendationResponseDescriptor =
    $convert.base64Decode(
        'Ch5HZW5lcmF0ZVJlY29tbWVuZGF0aW9uUmVzcG9uc2USTwoOcmVjb21tZW5kYXRpb24YASABKA'
        'syJy5hZ3JpY3VsdHVyZS5jcm9wLnYxLkNyb3BSZWNvbW1lbmRhdGlvblIOcmVjb21tZW5kYXRp'
        'b24=');

const $core.Map<$core.String, $core.dynamic> CropServiceBase$json = {
  '1': 'CropService',
  '2': [
    {
      '1': 'CreateCrop',
      '2': '.agriculture.crop.v1.CreateCropRequest',
      '3': '.agriculture.crop.v1.CreateCropResponse'
    },
    {
      '1': 'GetCrop',
      '2': '.agriculture.crop.v1.GetCropRequest',
      '3': '.agriculture.crop.v1.GetCropResponse'
    },
    {
      '1': 'ListCrops',
      '2': '.agriculture.crop.v1.ListCropsRequest',
      '3': '.agriculture.crop.v1.ListCropsResponse'
    },
    {
      '1': 'UpdateCrop',
      '2': '.agriculture.crop.v1.UpdateCropRequest',
      '3': '.agriculture.crop.v1.UpdateCropResponse'
    },
    {
      '1': 'DeleteCrop',
      '2': '.agriculture.crop.v1.DeleteCropRequest',
      '3': '.agriculture.crop.v1.DeleteCropResponse'
    },
    {
      '1': 'AddVariety',
      '2': '.agriculture.crop.v1.AddVarietyRequest',
      '3': '.agriculture.crop.v1.AddVarietyResponse'
    },
    {
      '1': 'ListVarieties',
      '2': '.agriculture.crop.v1.ListVarietiesRequest',
      '3': '.agriculture.crop.v1.ListVarietiesResponse'
    },
    {
      '1': 'GetGrowthStages',
      '2': '.agriculture.crop.v1.GetGrowthStagesRequest',
      '3': '.agriculture.crop.v1.GetGrowthStagesResponse'
    },
    {
      '1': 'GetCropRequirements',
      '2': '.agriculture.crop.v1.GetCropRequirementsRequest',
      '3': '.agriculture.crop.v1.GetCropRequirementsResponse'
    },
    {
      '1': 'GenerateRecommendation',
      '2': '.agriculture.crop.v1.GenerateRecommendationRequest',
      '3': '.agriculture.crop.v1.GenerateRecommendationResponse'
    },
  ],
};

@$core.Deprecated('Use cropServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    CropServiceBase$messageJson = {
  '.agriculture.crop.v1.CreateCropRequest': CreateCropRequest$json,
  '.agriculture.crop.v1.CreateCropResponse': CreateCropResponse$json,
  '.agriculture.crop.v1.Crop': Crop$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.crop.v1.CropVariety': CropVariety$json,
  '.agriculture.crop.v1.GrowthStage': GrowthStage$json,
  '.agriculture.crop.v1.CropRequirements': CropRequirements$json,
  '.agriculture.crop.v1.GetCropRequest': GetCropRequest$json,
  '.agriculture.crop.v1.GetCropResponse': GetCropResponse$json,
  '.agriculture.crop.v1.ListCropsRequest': ListCropsRequest$json,
  '.google.protobuf.FieldMask': $1.FieldMask$json,
  '.agriculture.crop.v1.ListCropsResponse': ListCropsResponse$json,
  '.agriculture.crop.v1.UpdateCropRequest': UpdateCropRequest$json,
  '.agriculture.crop.v1.UpdateCropResponse': UpdateCropResponse$json,
  '.agriculture.crop.v1.DeleteCropRequest': DeleteCropRequest$json,
  '.agriculture.crop.v1.DeleteCropResponse': DeleteCropResponse$json,
  '.agriculture.crop.v1.AddVarietyRequest': AddVarietyRequest$json,
  '.agriculture.crop.v1.AddVarietyResponse': AddVarietyResponse$json,
  '.agriculture.crop.v1.ListVarietiesRequest': ListVarietiesRequest$json,
  '.agriculture.crop.v1.ListVarietiesResponse': ListVarietiesResponse$json,
  '.agriculture.crop.v1.GetGrowthStagesRequest': GetGrowthStagesRequest$json,
  '.agriculture.crop.v1.GetGrowthStagesResponse': GetGrowthStagesResponse$json,
  '.agriculture.crop.v1.GetCropRequirementsRequest':
      GetCropRequirementsRequest$json,
  '.agriculture.crop.v1.GetCropRequirementsResponse':
      GetCropRequirementsResponse$json,
  '.agriculture.crop.v1.GenerateRecommendationRequest':
      GenerateRecommendationRequest$json,
  '.agriculture.crop.v1.GenerateRecommendationResponse':
      GenerateRecommendationResponse$json,
  '.agriculture.crop.v1.CropRecommendation': CropRecommendation$json,
};

/// Descriptor for `CropService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List cropServiceDescriptor = $convert.base64Decode(
    'CgtDcm9wU2VydmljZRJdCgpDcmVhdGVDcm9wEiYuYWdyaWN1bHR1cmUuY3JvcC52MS5DcmVhdG'
    'VDcm9wUmVxdWVzdBonLmFncmljdWx0dXJlLmNyb3AudjEuQ3JlYXRlQ3JvcFJlc3BvbnNlElQK'
    'B0dldENyb3ASIy5hZ3JpY3VsdHVyZS5jcm9wLnYxLkdldENyb3BSZXF1ZXN0GiQuYWdyaWN1bH'
    'R1cmUuY3JvcC52MS5HZXRDcm9wUmVzcG9uc2USWgoJTGlzdENyb3BzEiUuYWdyaWN1bHR1cmUu'
    'Y3JvcC52MS5MaXN0Q3JvcHNSZXF1ZXN0GiYuYWdyaWN1bHR1cmUuY3JvcC52MS5MaXN0Q3JvcH'
    'NSZXNwb25zZRJdCgpVcGRhdGVDcm9wEiYuYWdyaWN1bHR1cmUuY3JvcC52MS5VcGRhdGVDcm9w'
    'UmVxdWVzdBonLmFncmljdWx0dXJlLmNyb3AudjEuVXBkYXRlQ3JvcFJlc3BvbnNlEl0KCkRlbG'
    'V0ZUNyb3ASJi5hZ3JpY3VsdHVyZS5jcm9wLnYxLkRlbGV0ZUNyb3BSZXF1ZXN0GicuYWdyaWN1'
    'bHR1cmUuY3JvcC52MS5EZWxldGVDcm9wUmVzcG9uc2USXQoKQWRkVmFyaWV0eRImLmFncmljdW'
    'x0dXJlLmNyb3AudjEuQWRkVmFyaWV0eVJlcXVlc3QaJy5hZ3JpY3VsdHVyZS5jcm9wLnYxLkFk'
    'ZFZhcmlldHlSZXNwb25zZRJmCg1MaXN0VmFyaWV0aWVzEikuYWdyaWN1bHR1cmUuY3JvcC52MS'
    '5MaXN0VmFyaWV0aWVzUmVxdWVzdBoqLmFncmljdWx0dXJlLmNyb3AudjEuTGlzdFZhcmlldGll'
    'c1Jlc3BvbnNlEmwKD0dldEdyb3d0aFN0YWdlcxIrLmFncmljdWx0dXJlLmNyb3AudjEuR2V0R3'
    'Jvd3RoU3RhZ2VzUmVxdWVzdBosLmFncmljdWx0dXJlLmNyb3AudjEuR2V0R3Jvd3RoU3RhZ2Vz'
    'UmVzcG9uc2USeAoTR2V0Q3JvcFJlcXVpcmVtZW50cxIvLmFncmljdWx0dXJlLmNyb3AudjEuR2'
    'V0Q3JvcFJlcXVpcmVtZW50c1JlcXVlc3QaMC5hZ3JpY3VsdHVyZS5jcm9wLnYxLkdldENyb3BS'
    'ZXF1aXJlbWVudHNSZXNwb25zZRKBAQoWR2VuZXJhdGVSZWNvbW1lbmRhdGlvbhIyLmFncmljdW'
    'x0dXJlLmNyb3AudjEuR2VuZXJhdGVSZWNvbW1lbmRhdGlvblJlcXVlc3QaMy5hZ3JpY3VsdHVy'
    'ZS5jcm9wLnYxLkdlbmVyYXRlUmVjb21tZW5kYXRpb25SZXNwb25zZQ==');
