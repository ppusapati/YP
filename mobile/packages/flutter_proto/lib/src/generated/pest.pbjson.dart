// This is a generated file - do not edit.
//
// Generated from pest.proto.

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

import 'package:protobuf/well_known_types/google/protobuf/timestamp.pbjson.dart'
    as $0;

@$core.Deprecated('Use riskLevelDescriptor instead')
const RiskLevel$json = {
  '1': 'RiskLevel',
  '2': [
    {'1': 'RISK_LEVEL_UNSPECIFIED', '2': 0},
    {'1': 'RISK_LEVEL_NONE', '2': 1},
    {'1': 'RISK_LEVEL_LOW', '2': 2},
    {'1': 'RISK_LEVEL_MODERATE', '2': 3},
    {'1': 'RISK_LEVEL_HIGH', '2': 4},
    {'1': 'RISK_LEVEL_CRITICAL', '2': 5},
  ],
};

/// Descriptor for `RiskLevel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List riskLevelDescriptor = $convert.base64Decode(
    'CglSaXNrTGV2ZWwSGgoWUklTS19MRVZFTF9VTlNQRUNJRklFRBAAEhMKD1JJU0tfTEVWRUxfTk'
    '9ORRABEhIKDlJJU0tfTEVWRUxfTE9XEAISFwoTUklTS19MRVZFTF9NT0RFUkFURRADEhMKD1JJ'
    'U0tfTEVWRUxfSElHSBAEEhcKE1JJU0tfTEVWRUxfQ1JJVElDQUwQBQ==');

@$core.Deprecated('Use treatmentTypeDescriptor instead')
const TreatmentType$json = {
  '1': 'TreatmentType',
  '2': [
    {'1': 'TREATMENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'TREATMENT_TYPE_CHEMICAL', '2': 1},
    {'1': 'TREATMENT_TYPE_BIOLOGICAL', '2': 2},
    {'1': 'TREATMENT_TYPE_CULTURAL', '2': 3},
    {'1': 'TREATMENT_TYPE_MECHANICAL', '2': 4},
  ],
};

/// Descriptor for `TreatmentType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List treatmentTypeDescriptor = $convert.base64Decode(
    'Cg1UcmVhdG1lbnRUeXBlEh4KGlRSRUFUTUVOVF9UWVBFX1VOU1BFQ0lGSUVEEAASGwoXVFJFQV'
    'RNRU5UX1RZUEVfQ0hFTUlDQUwQARIdChlUUkVBVE1FTlRfVFlQRV9CSU9MT0dJQ0FMEAISGwoX'
    'VFJFQVRNRU5UX1RZUEVfQ1VMVFVSQUwQAxIdChlUUkVBVE1FTlRfVFlQRV9NRUNIQU5JQ0FMEA'
    'Q=');

@$core.Deprecated('Use alertStatusDescriptor instead')
const AlertStatus$json = {
  '1': 'AlertStatus',
  '2': [
    {'1': 'ALERT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'ALERT_STATUS_ACTIVE', '2': 1},
    {'1': 'ALERT_STATUS_ACKNOWLEDGED', '2': 2},
    {'1': 'ALERT_STATUS_RESOLVED', '2': 3},
    {'1': 'ALERT_STATUS_EXPIRED', '2': 4},
  ],
};

/// Descriptor for `AlertStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List alertStatusDescriptor = $convert.base64Decode(
    'CgtBbGVydFN0YXR1cxIcChhBTEVSVF9TVEFUVVNfVU5TUEVDSUZJRUQQABIXChNBTEVSVF9TVE'
    'FUVVNfQUNUSVZFEAESHQoZQUxFUlRfU1RBVFVTX0FDS05PV0xFREdFRBACEhkKFUFMRVJUX1NU'
    'QVRVU19SRVNPTFZFRBADEhgKFEFMRVJUX1NUQVRVU19FWFBJUkVEEAQ=');

@$core.Deprecated('Use damageLevelDescriptor instead')
const DamageLevel$json = {
  '1': 'DamageLevel',
  '2': [
    {'1': 'DAMAGE_LEVEL_UNSPECIFIED', '2': 0},
    {'1': 'DAMAGE_LEVEL_NONE', '2': 1},
    {'1': 'DAMAGE_LEVEL_LIGHT', '2': 2},
    {'1': 'DAMAGE_LEVEL_MODERATE', '2': 3},
    {'1': 'DAMAGE_LEVEL_SEVERE', '2': 4},
    {'1': 'DAMAGE_LEVEL_DEVASTATING', '2': 5},
  ],
};

/// Descriptor for `DamageLevel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List damageLevelDescriptor = $convert.base64Decode(
    'CgtEYW1hZ2VMZXZlbBIcChhEQU1BR0VfTEVWRUxfVU5TUEVDSUZJRUQQABIVChFEQU1BR0VfTE'
    'VWRUxfTk9ORRABEhYKEkRBTUFHRV9MRVZFTF9MSUdIVBACEhkKFURBTUFHRV9MRVZFTF9NT0RF'
    'UkFURRADEhcKE0RBTUFHRV9MRVZFTF9TRVZFUkUQBBIcChhEQU1BR0VfTEVWRUxfREVWQVNUQV'
    'RJTkcQBQ==');

@$core.Deprecated('Use growthStageDescriptor instead')
const GrowthStage$json = {
  '1': 'GrowthStage',
  '2': [
    {'1': 'GROWTH_STAGE_UNSPECIFIED', '2': 0},
    {'1': 'GROWTH_STAGE_GERMINATION', '2': 1},
    {'1': 'GROWTH_STAGE_SEEDLING', '2': 2},
    {'1': 'GROWTH_STAGE_VEGETATIVE', '2': 3},
    {'1': 'GROWTH_STAGE_FLOWERING', '2': 4},
    {'1': 'GROWTH_STAGE_FRUITING', '2': 5},
    {'1': 'GROWTH_STAGE_MATURATION', '2': 6},
    {'1': 'GROWTH_STAGE_HARVEST', '2': 7},
  ],
};

/// Descriptor for `GrowthStage`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List growthStageDescriptor = $convert.base64Decode(
    'CgtHcm93dGhTdGFnZRIcChhHUk9XVEhfU1RBR0VfVU5TUEVDSUZJRUQQABIcChhHUk9XVEhfU1'
    'RBR0VfR0VSTUlOQVRJT04QARIZChVHUk9XVEhfU1RBR0VfU0VFRExJTkcQAhIbChdHUk9XVEhf'
    'U1RBR0VfVkVHRVRBVElWRRADEhoKFkdST1dUSF9TVEFHRV9GTE9XRVJJTkcQBBIZChVHUk9XVE'
    'hfU1RBR0VfRlJVSVRJTkcQBRIbChdHUk9XVEhfU1RBR0VfTUFUVVJBVElPThAGEhgKFEdST1dU'
    'SF9TVEFHRV9IQVJWRVNUEAc=');

@$core.Deprecated('Use weatherFactorsDescriptor instead')
const WeatherFactors$json = {
  '1': 'WeatherFactors',
  '2': [
    {
      '1': 'temperature_celsius',
      '3': 1,
      '4': 1,
      '5': 1,
      '10': 'temperatureCelsius'
    },
    {'1': 'humidity_pct', '3': 2, '4': 1, '5': 1, '10': 'humidityPct'},
    {'1': 'rainfall_mm', '3': 3, '4': 1, '5': 1, '10': 'rainfallMm'},
    {'1': 'wind_speed_kmh', '3': 4, '4': 1, '5': 1, '10': 'windSpeedKmh'},
  ],
};

/// Descriptor for `WeatherFactors`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List weatherFactorsDescriptor = $convert.base64Decode(
    'Cg5XZWF0aGVyRmFjdG9ycxIvChN0ZW1wZXJhdHVyZV9jZWxzaXVzGAEgASgBUhJ0ZW1wZXJhdH'
    'VyZUNlbHNpdXMSIQoMaHVtaWRpdHlfcGN0GAIgASgBUgtodW1pZGl0eVBjdBIfCgtyYWluZmFs'
    'bF9tbRgDIAEoAVIKcmFpbmZhbGxNbRIkCg53aW5kX3NwZWVkX2ttaBgEIAEoAVIMd2luZFNwZW'
    'VkS21o');

@$core.Deprecated('Use recommendedTreatmentDescriptor instead')
const RecommendedTreatment$json = {
  '1': 'RecommendedTreatment',
  '2': [
    {
      '1': 'treatment_type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.agriculture.pest.v1.TreatmentType',
      '10': 'treatmentType'
    },
    {'1': 'product_name', '3': 2, '4': 1, '5': 9, '10': 'productName'},
    {'1': 'application_rate', '3': 3, '4': 1, '5': 9, '10': 'applicationRate'},
    {
      '1': 'application_method',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'applicationMethod'
    },
    {'1': 'timing', '3': 5, '4': 1, '5': 9, '10': 'timing'},
    {'1': 'safety_interval', '3': 6, '4': 1, '5': 9, '10': 'safetyInterval'},
  ],
};

/// Descriptor for `RecommendedTreatment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recommendedTreatmentDescriptor = $convert.base64Decode(
    'ChRSZWNvbW1lbmRlZFRyZWF0bWVudBJJCg50cmVhdG1lbnRfdHlwZRgBIAEoDjIiLmFncmljdW'
    'x0dXJlLnBlc3QudjEuVHJlYXRtZW50VHlwZVINdHJlYXRtZW50VHlwZRIhCgxwcm9kdWN0X25h'
    'bWUYAiABKAlSC3Byb2R1Y3ROYW1lEikKEGFwcGxpY2F0aW9uX3JhdGUYAyABKAlSD2FwcGxpY2'
    'F0aW9uUmF0ZRItChJhcHBsaWNhdGlvbl9tZXRob2QYBCABKAlSEWFwcGxpY2F0aW9uTWV0aG9k'
    'EhYKBnRpbWluZxgFIAEoCVIGdGltaW5nEicKD3NhZmV0eV9pbnRlcnZhbBgGIAEoCVIOc2FmZX'
    'R5SW50ZXJ2YWw=');

@$core.Deprecated('Use pestSpeciesDescriptor instead')
const PestSpecies$json = {
  '1': 'PestSpecies',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'common_name', '3': 3, '4': 1, '5': 9, '10': 'commonName'},
    {'1': 'scientific_name', '3': 4, '4': 1, '5': 9, '10': 'scientificName'},
    {'1': 'family', '3': 5, '4': 1, '5': 9, '10': 'family'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {'1': 'affected_crops', '3': 7, '4': 3, '5': 9, '10': 'affectedCrops'},
    {
      '1': 'favorable_conditions',
      '3': 8,
      '4': 3,
      '5': 9,
      '10': 'favorableConditions'
    },
    {'1': 'image_url', '3': 9, '4': 1, '5': 9, '10': 'imageUrl'},
    {'1': 'version', '3': 10, '4': 1, '5': 3, '10': 'version'},
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

/// Descriptor for `PestSpecies`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pestSpeciesDescriptor = $convert.base64Decode(
    'CgtQZXN0U3BlY2llcxIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW5hbn'
    'RJZBIfCgtjb21tb25fbmFtZRgDIAEoCVIKY29tbW9uTmFtZRInCg9zY2llbnRpZmljX25hbWUY'
    'BCABKAlSDnNjaWVudGlmaWNOYW1lEhYKBmZhbWlseRgFIAEoCVIGZmFtaWx5EiAKC2Rlc2NyaX'
    'B0aW9uGAYgASgJUgtkZXNjcmlwdGlvbhIlCg5hZmZlY3RlZF9jcm9wcxgHIAMoCVINYWZmZWN0'
    'ZWRDcm9wcxIxChRmYXZvcmFibGVfY29uZGl0aW9ucxgIIAMoCVITZmF2b3JhYmxlQ29uZGl0aW'
    '9ucxIbCglpbWFnZV91cmwYCSABKAlSCGltYWdlVXJsEhgKB3ZlcnNpb24YCiABKANSB3ZlcnNp'
    'b24SOQoKY3JlYXRlZF9hdBgLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZW'
    'F0ZWRBdBI5Cgp1cGRhdGVkX2F0GAwgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJ'
    'dXBkYXRlZEF0');

@$core.Deprecated('Use pestPredictionDescriptor instead')
const PestPrediction$json = {
  '1': 'PestPrediction',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'pest_species_id', '3': 5, '4': 1, '5': 9, '10': 'pestSpeciesId'},
    {
      '1': 'prediction_date',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'predictionDate'
    },
    {
      '1': 'risk_level',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.pest.v1.RiskLevel',
      '10': 'riskLevel'
    },
    {'1': 'risk_score', '3': 8, '4': 1, '5': 5, '10': 'riskScore'},
    {'1': 'confidence_pct', '3': 9, '4': 1, '5': 1, '10': 'confidencePct'},
    {
      '1': 'weather_factors',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.agriculture.pest.v1.WeatherFactors',
      '10': 'weatherFactors'
    },
    {'1': 'crop_type', '3': 11, '4': 1, '5': 9, '10': 'cropType'},
    {
      '1': 'growth_stage',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.agriculture.pest.v1.GrowthStage',
      '10': 'growthStage'
    },
    {
      '1': 'geographic_risk_factor',
      '3': 13,
      '4': 1,
      '5': 1,
      '10': 'geographicRiskFactor'
    },
    {
      '1': 'historical_occurrence_count',
      '3': 14,
      '4': 1,
      '5': 5,
      '10': 'historicalOccurrenceCount'
    },
    {
      '1': 'predicted_onset_date',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'predictedOnsetDate'
    },
    {
      '1': 'predicted_peak_date',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'predictedPeakDate'
    },
    {
      '1': 'treatment_window_start',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'treatmentWindowStart'
    },
    {
      '1': 'treatment_window_end',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'treatmentWindowEnd'
    },
    {
      '1': 'recommended_treatments',
      '3': 19,
      '4': 3,
      '5': 11,
      '6': '.agriculture.pest.v1.RecommendedTreatment',
      '10': 'recommendedTreatments'
    },
    {'1': 'version', '3': 20, '4': 1, '5': 3, '10': 'version'},
    {'1': 'created_by', '3': 21, '4': 1, '5': 9, '10': 'createdBy'},
    {
      '1': 'created_at',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 23,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `PestPrediction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pestPredictionDescriptor = $convert.base64Decode(
    'Cg5QZXN0UHJlZGljdGlvbhIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW'
    '5hbnRJZBIXCgdmYXJtX2lkGAMgASgJUgZmYXJtSWQSGQoIZmllbGRfaWQYBCABKAlSB2ZpZWxk'
    'SWQSJgoPcGVzdF9zcGVjaWVzX2lkGAUgASgJUg1wZXN0U3BlY2llc0lkEkMKD3ByZWRpY3Rpb2'
    '5fZGF0ZRgGIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSDnByZWRpY3Rpb25EYXRl'
    'Ej0KCnJpc2tfbGV2ZWwYByABKA4yHi5hZ3JpY3VsdHVyZS5wZXN0LnYxLlJpc2tMZXZlbFIJcm'
    'lza0xldmVsEh0KCnJpc2tfc2NvcmUYCCABKAVSCXJpc2tTY29yZRIlCg5jb25maWRlbmNlX3Bj'
    'dBgJIAEoAVINY29uZmlkZW5jZVBjdBJMCg93ZWF0aGVyX2ZhY3RvcnMYCiABKAsyIy5hZ3JpY3'
    'VsdHVyZS5wZXN0LnYxLldlYXRoZXJGYWN0b3JzUg53ZWF0aGVyRmFjdG9ycxIbCgljcm9wX3R5'
    'cGUYCyABKAlSCGNyb3BUeXBlEkMKDGdyb3d0aF9zdGFnZRgMIAEoDjIgLmFncmljdWx0dXJlLn'
    'Blc3QudjEuR3Jvd3RoU3RhZ2VSC2dyb3d0aFN0YWdlEjQKFmdlb2dyYXBoaWNfcmlza19mYWN0'
    'b3IYDSABKAFSFGdlb2dyYXBoaWNSaXNrRmFjdG9yEj4KG2hpc3RvcmljYWxfb2NjdXJyZW5jZV'
    '9jb3VudBgOIAEoBVIZaGlzdG9yaWNhbE9jY3VycmVuY2VDb3VudBJMChRwcmVkaWN0ZWRfb25z'
    'ZXRfZGF0ZRgPIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSEnByZWRpY3RlZE9uc2'
    'V0RGF0ZRJKChNwcmVkaWN0ZWRfcGVha19kYXRlGBAgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRp'
    'bWVzdGFtcFIRcHJlZGljdGVkUGVha0RhdGUSUAoWdHJlYXRtZW50X3dpbmRvd19zdGFydBgRIA'
    'EoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSFHRyZWF0bWVudFdpbmRvd1N0YXJ0EkwK'
    'FHRyZWF0bWVudF93aW5kb3dfZW5kGBIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcF'
    'ISdHJlYXRtZW50V2luZG93RW5kEmAKFnJlY29tbWVuZGVkX3RyZWF0bWVudHMYEyADKAsyKS5h'
    'Z3JpY3VsdHVyZS5wZXN0LnYxLlJlY29tbWVuZGVkVHJlYXRtZW50UhVyZWNvbW1lbmRlZFRyZW'
    'F0bWVudHMSGAoHdmVyc2lvbhgUIAEoA1IHdmVyc2lvbhIdCgpjcmVhdGVkX2J5GBUgASgJUglj'
    'cmVhdGVkQnkSOQoKY3JlYXRlZF9hdBgWIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbX'
    'BSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GBcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVz'
    'dGFtcFIJdXBkYXRlZEF0');

@$core.Deprecated('Use pestAlertDescriptor instead')
const PestAlert$json = {
  '1': 'PestAlert',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'prediction_id', '3': 3, '4': 1, '5': 9, '10': 'predictionId'},
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 5, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'pest_species_id', '3': 6, '4': 1, '5': 9, '10': 'pestSpeciesId'},
    {
      '1': 'risk_level',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.pest.v1.RiskLevel',
      '10': 'riskLevel'
    },
    {
      '1': 'status',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.agriculture.pest.v1.AlertStatus',
      '10': 'status'
    },
    {'1': 'title', '3': 9, '4': 1, '5': 9, '10': 'title'},
    {'1': 'message', '3': 10, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'acknowledged_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'acknowledgedAt'
    },
    {'1': 'acknowledged_by', '3': 12, '4': 1, '5': 9, '10': 'acknowledgedBy'},
    {'1': 'version', '3': 13, '4': 1, '5': 3, '10': 'version'},
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
  ],
};

/// Descriptor for `PestAlert`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pestAlertDescriptor = $convert.base64Decode(
    'CglQZXN0QWxlcnQSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdGVuYW50SW'
    'QSIwoNcHJlZGljdGlvbl9pZBgDIAEoCVIMcHJlZGljdGlvbklkEhcKB2Zhcm1faWQYBCABKAlS'
    'BmZhcm1JZBIZCghmaWVsZF9pZBgFIAEoCVIHZmllbGRJZBImCg9wZXN0X3NwZWNpZXNfaWQYBi'
    'ABKAlSDXBlc3RTcGVjaWVzSWQSPQoKcmlza19sZXZlbBgHIAEoDjIeLmFncmljdWx0dXJlLnBl'
    'c3QudjEuUmlza0xldmVsUglyaXNrTGV2ZWwSOAoGc3RhdHVzGAggASgOMiAuYWdyaWN1bHR1cm'
    'UucGVzdC52MS5BbGVydFN0YXR1c1IGc3RhdHVzEhQKBXRpdGxlGAkgASgJUgV0aXRsZRIYCgdt'
    'ZXNzYWdlGAogASgJUgdtZXNzYWdlEkMKD2Fja25vd2xlZGdlZF9hdBgLIAEoCzIaLmdvb2dsZS'
    '5wcm90b2J1Zi5UaW1lc3RhbXBSDmFja25vd2xlZGdlZEF0EicKD2Fja25vd2xlZGdlZF9ieRgM'
    'IAEoCVIOYWNrbm93bGVkZ2VkQnkSGAoHdmVyc2lvbhgNIAEoA1IHdmVyc2lvbhI5CgpjcmVhdG'
    'VkX2F0GA4gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVw'
    'ZGF0ZWRfYXQYDyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use pestObservationDescriptor instead')
const PestObservation$json = {
  '1': 'PestObservation',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'pest_species_id', '3': 5, '4': 1, '5': 9, '10': 'pestSpeciesId'},
    {'1': 'pest_count', '3': 6, '4': 1, '5': 5, '10': 'pestCount'},
    {
      '1': 'damage_level',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.pest.v1.DamageLevel',
      '10': 'damageLevel'
    },
    {'1': 'trap_type', '3': 8, '4': 1, '5': 9, '10': 'trapType'},
    {'1': 'image_url', '3': 9, '4': 1, '5': 9, '10': 'imageUrl'},
    {'1': 'latitude', '3': 10, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 11, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'notes', '3': 12, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'observed_by', '3': 13, '4': 1, '5': 9, '10': 'observedBy'},
    {
      '1': 'observed_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'observedAt'
    },
    {'1': 'version', '3': 15, '4': 1, '5': 3, '10': 'version'},
    {
      '1': 'created_at',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `PestObservation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pestObservationDescriptor = $convert.base64Decode(
    'Cg9QZXN0T2JzZXJ2YXRpb24SDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdG'
    'VuYW50SWQSFwoHZmFybV9pZBgDIAEoCVIGZmFybUlkEhkKCGZpZWxkX2lkGAQgASgJUgdmaWVs'
    'ZElkEiYKD3Blc3Rfc3BlY2llc19pZBgFIAEoCVINcGVzdFNwZWNpZXNJZBIdCgpwZXN0X2NvdW'
    '50GAYgASgFUglwZXN0Q291bnQSQwoMZGFtYWdlX2xldmVsGAcgASgOMiAuYWdyaWN1bHR1cmUu'
    'cGVzdC52MS5EYW1hZ2VMZXZlbFILZGFtYWdlTGV2ZWwSGwoJdHJhcF90eXBlGAggASgJUgh0cm'
    'FwVHlwZRIbCglpbWFnZV91cmwYCSABKAlSCGltYWdlVXJsEhoKCGxhdGl0dWRlGAogASgBUghs'
    'YXRpdHVkZRIcCglsb25naXR1ZGUYCyABKAFSCWxvbmdpdHVkZRIUCgVub3RlcxgMIAEoCVIFbm'
    '90ZXMSHwoLb2JzZXJ2ZWRfYnkYDSABKAlSCm9ic2VydmVkQnkSOwoLb2JzZXJ2ZWRfYXQYDiAB'
    'KAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgpvYnNlcnZlZEF0EhgKB3ZlcnNpb24YDy'
    'ABKANSB3ZlcnNpb24SOQoKY3JlYXRlZF9hdBgQIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1l'
    'c3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GBEgASgLMhouZ29vZ2xlLnByb3RvYnVmLl'
    'RpbWVzdGFtcFIJdXBkYXRlZEF0');

@$core.Deprecated('Use pestTreatmentDescriptor instead')
const PestTreatment$json = {
  '1': 'PestTreatment',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'pest_species_id', '3': 5, '4': 1, '5': 9, '10': 'pestSpeciesId'},
    {'1': 'prediction_id', '3': 6, '4': 1, '5': 9, '10': 'predictionId'},
    {
      '1': 'treatment_type',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.pest.v1.TreatmentType',
      '10': 'treatmentType'
    },
    {'1': 'product_name', '3': 8, '4': 1, '5': 9, '10': 'productName'},
    {'1': 'application_rate', '3': 9, '4': 1, '5': 9, '10': 'applicationRate'},
    {
      '1': 'application_method',
      '3': 10,
      '4': 1,
      '5': 9,
      '10': 'applicationMethod'
    },
    {'1': 'cost', '3': 11, '4': 1, '5': 1, '10': 'cost'},
    {
      '1': 'effectiveness_rating',
      '3': 12,
      '4': 1,
      '5': 9,
      '10': 'effectivenessRating'
    },
    {'1': 'applied_by', '3': 13, '4': 1, '5': 9, '10': 'appliedBy'},
    {
      '1': 'applied_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'appliedAt'
    },
    {'1': 'notes', '3': 15, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'version', '3': 16, '4': 1, '5': 3, '10': 'version'},
    {
      '1': 'created_at',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `PestTreatment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pestTreatmentDescriptor = $convert.base64Decode(
    'Cg1QZXN0VHJlYXRtZW50Eg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbm'
    'FudElkEhcKB2Zhcm1faWQYAyABKAlSBmZhcm1JZBIZCghmaWVsZF9pZBgEIAEoCVIHZmllbGRJ'
    'ZBImCg9wZXN0X3NwZWNpZXNfaWQYBSABKAlSDXBlc3RTcGVjaWVzSWQSIwoNcHJlZGljdGlvbl'
    '9pZBgGIAEoCVIMcHJlZGljdGlvbklkEkkKDnRyZWF0bWVudF90eXBlGAcgASgOMiIuYWdyaWN1'
    'bHR1cmUucGVzdC52MS5UcmVhdG1lbnRUeXBlUg10cmVhdG1lbnRUeXBlEiEKDHByb2R1Y3Rfbm'
    'FtZRgIIAEoCVILcHJvZHVjdE5hbWUSKQoQYXBwbGljYXRpb25fcmF0ZRgJIAEoCVIPYXBwbGlj'
    'YXRpb25SYXRlEi0KEmFwcGxpY2F0aW9uX21ldGhvZBgKIAEoCVIRYXBwbGljYXRpb25NZXRob2'
    'QSEgoEY29zdBgLIAEoAVIEY29zdBIxChRlZmZlY3RpdmVuZXNzX3JhdGluZxgMIAEoCVITZWZm'
    'ZWN0aXZlbmVzc1JhdGluZxIdCgphcHBsaWVkX2J5GA0gASgJUglhcHBsaWVkQnkSOQoKYXBwbG'
    'llZF9hdBgOIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWFwcGxpZWRBdBIUCgVu'
    'b3RlcxgPIAEoCVIFbm90ZXMSGAoHdmVyc2lvbhgQIAEoA1IHdmVyc2lvbhI5CgpjcmVhdGVkX2'
    'F0GBEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0'
    'ZWRfYXQYEiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use pestRiskMapDescriptor instead')
const PestRiskMap$json = {
  '1': 'PestRiskMap',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'pest_species_id', '3': 3, '4': 1, '5': 9, '10': 'pestSpeciesId'},
    {'1': 'region', '3': 4, '4': 1, '5': 9, '10': 'region'},
    {
      '1': 'overall_risk_level',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.pest.v1.RiskLevel',
      '10': 'overallRiskLevel'
    },
    {'1': 'geojson', '3': 6, '4': 1, '5': 9, '10': 'geojson'},
    {
      '1': 'valid_from',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validFrom'
    },
    {
      '1': 'valid_until',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validUntil'
    },
    {'1': 'version', '3': 9, '4': 1, '5': 3, '10': 'version'},
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

/// Descriptor for `PestRiskMap`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pestRiskMapDescriptor = $convert.base64Decode(
    'CgtQZXN0Umlza01hcBIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW5hbn'
    'RJZBImCg9wZXN0X3NwZWNpZXNfaWQYAyABKAlSDXBlc3RTcGVjaWVzSWQSFgoGcmVnaW9uGAQg'
    'ASgJUgZyZWdpb24STAoSb3ZlcmFsbF9yaXNrX2xldmVsGAUgASgOMh4uYWdyaWN1bHR1cmUucG'
    'VzdC52MS5SaXNrTGV2ZWxSEG92ZXJhbGxSaXNrTGV2ZWwSGAoHZ2VvanNvbhgGIAEoCVIHZ2Vv'
    'anNvbhI5Cgp2YWxpZF9mcm9tGAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdm'
    'FsaWRGcm9tEjsKC3ZhbGlkX3VudGlsGAggASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFt'
    'cFIKdmFsaWRVbnRpbBIYCgd2ZXJzaW9uGAkgASgDUgd2ZXJzaW9uEjkKCmNyZWF0ZWRfYXQYCi'
    'ABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRlZF9h'
    'dBgLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdA==');

@$core.Deprecated('Use predictPestRiskRequestDescriptor instead')
const PredictPestRiskRequest$json = {
  '1': 'PredictPestRiskRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'pest_species_id', '3': 3, '4': 1, '5': 9, '10': 'pestSpeciesId'},
    {'1': 'crop_type', '3': 4, '4': 1, '5': 9, '10': 'cropType'},
    {
      '1': 'growth_stage',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.pest.v1.GrowthStage',
      '10': 'growthStage'
    },
    {
      '1': 'weather',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.agriculture.pest.v1.WeatherFactors',
      '10': 'weather'
    },
    {'1': 'latitude', '3': 7, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 8, '4': 1, '5': 1, '10': 'longitude'},
  ],
};

/// Descriptor for `PredictPestRiskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List predictPestRiskRequestDescriptor = $convert.base64Decode(
    'ChZQcmVkaWN0UGVzdFJpc2tSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZBIZCghmaW'
    'VsZF9pZBgCIAEoCVIHZmllbGRJZBImCg9wZXN0X3NwZWNpZXNfaWQYAyABKAlSDXBlc3RTcGVj'
    'aWVzSWQSGwoJY3JvcF90eXBlGAQgASgJUghjcm9wVHlwZRJDCgxncm93dGhfc3RhZ2UYBSABKA'
    '4yIC5hZ3JpY3VsdHVyZS5wZXN0LnYxLkdyb3d0aFN0YWdlUgtncm93dGhTdGFnZRI9Cgd3ZWF0'
    'aGVyGAYgASgLMiMuYWdyaWN1bHR1cmUucGVzdC52MS5XZWF0aGVyRmFjdG9yc1IHd2VhdGhlch'
    'IaCghsYXRpdHVkZRgHIAEoAVIIbGF0aXR1ZGUSHAoJbG9uZ2l0dWRlGAggASgBUglsb25naXR1'
    'ZGU=');

@$core.Deprecated('Use predictPestRiskResponseDescriptor instead')
const PredictPestRiskResponse$json = {
  '1': 'PredictPestRiskResponse',
  '2': [
    {
      '1': 'prediction',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.pest.v1.PestPrediction',
      '10': 'prediction'
    },
  ],
};

/// Descriptor for `PredictPestRiskResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List predictPestRiskResponseDescriptor =
    $convert.base64Decode(
        'ChdQcmVkaWN0UGVzdFJpc2tSZXNwb25zZRJDCgpwcmVkaWN0aW9uGAEgASgLMiMuYWdyaWN1bH'
        'R1cmUucGVzdC52MS5QZXN0UHJlZGljdGlvblIKcHJlZGljdGlvbg==');

@$core.Deprecated('Use getPredictionRequestDescriptor instead')
const GetPredictionRequest$json = {
  '1': 'GetPredictionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetPredictionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPredictionRequestDescriptor = $convert
    .base64Decode('ChRHZXRQcmVkaWN0aW9uUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use getPredictionResponseDescriptor instead')
const GetPredictionResponse$json = {
  '1': 'GetPredictionResponse',
  '2': [
    {
      '1': 'prediction',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.pest.v1.PestPrediction',
      '10': 'prediction'
    },
  ],
};

/// Descriptor for `GetPredictionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPredictionResponseDescriptor = $convert.base64Decode(
    'ChVHZXRQcmVkaWN0aW9uUmVzcG9uc2USQwoKcHJlZGljdGlvbhgBIAEoCzIjLmFncmljdWx0dX'
    'JlLnBlc3QudjEuUGVzdFByZWRpY3Rpb25SCnByZWRpY3Rpb24=');

@$core.Deprecated('Use listPredictionsRequestDescriptor instead')
const ListPredictionsRequest$json = {
  '1': 'ListPredictionsRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'pest_species_id', '3': 3, '4': 1, '5': 9, '10': 'pestSpeciesId'},
    {
      '1': 'min_risk_level',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.pest.v1.RiskLevel',
      '10': 'minRiskLevel'
    },
    {'1': 'page_size', '3': 5, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 6, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'order_by', '3': 7, '4': 1, '5': 9, '10': 'orderBy'},
  ],
};

/// Descriptor for `ListPredictionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPredictionsRequestDescriptor = $convert.base64Decode(
    'ChZMaXN0UHJlZGljdGlvbnNSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZBIZCghmaW'
    'VsZF9pZBgCIAEoCVIHZmllbGRJZBImCg9wZXN0X3NwZWNpZXNfaWQYAyABKAlSDXBlc3RTcGVj'
    'aWVzSWQSRAoObWluX3Jpc2tfbGV2ZWwYBCABKA4yHi5hZ3JpY3VsdHVyZS5wZXN0LnYxLlJpc2'
    'tMZXZlbFIMbWluUmlza0xldmVsEhsKCXBhZ2Vfc2l6ZRgFIAEoBVIIcGFnZVNpemUSHQoKcGFn'
    'ZV90b2tlbhgGIAEoCVIJcGFnZVRva2VuEhkKCG9yZGVyX2J5GAcgASgJUgdvcmRlckJ5');

@$core.Deprecated('Use listPredictionsResponseDescriptor instead')
const ListPredictionsResponse$json = {
  '1': 'ListPredictionsResponse',
  '2': [
    {
      '1': 'predictions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.pest.v1.PestPrediction',
      '10': 'predictions'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListPredictionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPredictionsResponseDescriptor = $convert.base64Decode(
    'ChdMaXN0UHJlZGljdGlvbnNSZXNwb25zZRJFCgtwcmVkaWN0aW9ucxgBIAMoCzIjLmFncmljdW'
    'x0dXJlLnBlc3QudjEuUGVzdFByZWRpY3Rpb25SC3ByZWRpY3Rpb25zEiYKD25leHRfcGFnZV90'
    'b2tlbhgCIAEoCVINbmV4dFBhZ2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3'
    'VudA==');

@$core.Deprecated('Use reportObservationRequestDescriptor instead')
const ReportObservationRequest$json = {
  '1': 'ReportObservationRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'pest_species_id', '3': 3, '4': 1, '5': 9, '10': 'pestSpeciesId'},
    {'1': 'pest_count', '3': 4, '4': 1, '5': 5, '10': 'pestCount'},
    {
      '1': 'damage_level',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.pest.v1.DamageLevel',
      '10': 'damageLevel'
    },
    {'1': 'trap_type', '3': 6, '4': 1, '5': 9, '10': 'trapType'},
    {'1': 'image_url', '3': 7, '4': 1, '5': 9, '10': 'imageUrl'},
    {'1': 'latitude', '3': 8, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 9, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'notes', '3': 10, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `ReportObservationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reportObservationRequestDescriptor = $convert.base64Decode(
    'ChhSZXBvcnRPYnNlcnZhdGlvblJlcXVlc3QSFwoHZmFybV9pZBgBIAEoCVIGZmFybUlkEhkKCG'
    'ZpZWxkX2lkGAIgASgJUgdmaWVsZElkEiYKD3Blc3Rfc3BlY2llc19pZBgDIAEoCVINcGVzdFNw'
    'ZWNpZXNJZBIdCgpwZXN0X2NvdW50GAQgASgFUglwZXN0Q291bnQSQwoMZGFtYWdlX2xldmVsGA'
    'UgASgOMiAuYWdyaWN1bHR1cmUucGVzdC52MS5EYW1hZ2VMZXZlbFILZGFtYWdlTGV2ZWwSGwoJ'
    'dHJhcF90eXBlGAYgASgJUgh0cmFwVHlwZRIbCglpbWFnZV91cmwYByABKAlSCGltYWdlVXJsEh'
    'oKCGxhdGl0dWRlGAggASgBUghsYXRpdHVkZRIcCglsb25naXR1ZGUYCSABKAFSCWxvbmdpdHVk'
    'ZRIUCgVub3RlcxgKIAEoCVIFbm90ZXM=');

@$core.Deprecated('Use reportObservationResponseDescriptor instead')
const ReportObservationResponse$json = {
  '1': 'ReportObservationResponse',
  '2': [
    {
      '1': 'observation',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.pest.v1.PestObservation',
      '10': 'observation'
    },
  ],
};

/// Descriptor for `ReportObservationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reportObservationResponseDescriptor =
    $convert.base64Decode(
        'ChlSZXBvcnRPYnNlcnZhdGlvblJlc3BvbnNlEkYKC29ic2VydmF0aW9uGAEgASgLMiQuYWdyaW'
        'N1bHR1cmUucGVzdC52MS5QZXN0T2JzZXJ2YXRpb25SC29ic2VydmF0aW9u');

@$core.Deprecated('Use listObservationsRequestDescriptor instead')
const ListObservationsRequest$json = {
  '1': 'ListObservationsRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'pest_species_id', '3': 3, '4': 1, '5': 9, '10': 'pestSpeciesId'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 5, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListObservationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listObservationsRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0T2JzZXJ2YXRpb25zUmVxdWVzdBIXCgdmYXJtX2lkGAEgASgJUgZmYXJtSWQSGQoIZm'
    'llbGRfaWQYAiABKAlSB2ZpZWxkSWQSJgoPcGVzdF9zcGVjaWVzX2lkGAMgASgJUg1wZXN0U3Bl'
    'Y2llc0lkEhsKCXBhZ2Vfc2l6ZRgEIAEoBVIIcGFnZVNpemUSHQoKcGFnZV90b2tlbhgFIAEoCV'
    'IJcGFnZVRva2Vu');

@$core.Deprecated('Use listObservationsResponseDescriptor instead')
const ListObservationsResponse$json = {
  '1': 'ListObservationsResponse',
  '2': [
    {
      '1': 'observations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.pest.v1.PestObservation',
      '10': 'observations'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListObservationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listObservationsResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0T2JzZXJ2YXRpb25zUmVzcG9uc2USSAoMb2JzZXJ2YXRpb25zGAEgAygLMiQuYWdyaW'
    'N1bHR1cmUucGVzdC52MS5QZXN0T2JzZXJ2YXRpb25SDG9ic2VydmF0aW9ucxImCg9uZXh0X3Bh'
    'Z2VfdG9rZW4YAiABKAlSDW5leHRQYWdlVG9rZW4SHwoLdG90YWxfY291bnQYAyABKAVSCnRvdG'
    'FsQ291bnQ=');

@$core.Deprecated('Use getPestSpeciesRequestDescriptor instead')
const GetPestSpeciesRequest$json = {
  '1': 'GetPestSpeciesRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetPestSpeciesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPestSpeciesRequestDescriptor = $convert
    .base64Decode('ChVHZXRQZXN0U3BlY2llc1JlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use getPestSpeciesResponseDescriptor instead')
const GetPestSpeciesResponse$json = {
  '1': 'GetPestSpeciesResponse',
  '2': [
    {
      '1': 'species',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.pest.v1.PestSpecies',
      '10': 'species'
    },
  ],
};

/// Descriptor for `GetPestSpeciesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPestSpeciesResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRQZXN0U3BlY2llc1Jlc3BvbnNlEjoKB3NwZWNpZXMYASABKAsyIC5hZ3JpY3VsdHVyZS'
        '5wZXN0LnYxLlBlc3RTcGVjaWVzUgdzcGVjaWVz');

@$core.Deprecated('Use listPestSpeciesRequestDescriptor instead')
const ListPestSpeciesRequest$json = {
  '1': 'ListPestSpeciesRequest',
  '2': [
    {'1': 'search', '3': 1, '4': 1, '5': 9, '10': 'search'},
    {'1': 'crop_type', '3': 2, '4': 1, '5': 9, '10': 'cropType'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 4, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListPestSpeciesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPestSpeciesRequestDescriptor = $convert.base64Decode(
    'ChZMaXN0UGVzdFNwZWNpZXNSZXF1ZXN0EhYKBnNlYXJjaBgBIAEoCVIGc2VhcmNoEhsKCWNyb3'
    'BfdHlwZRgCIAEoCVIIY3JvcFR5cGUSGwoJcGFnZV9zaXplGAMgASgFUghwYWdlU2l6ZRIdCgpw'
    'YWdlX3Rva2VuGAQgASgJUglwYWdlVG9rZW4=');

@$core.Deprecated('Use listPestSpeciesResponseDescriptor instead')
const ListPestSpeciesResponse$json = {
  '1': 'ListPestSpeciesResponse',
  '2': [
    {
      '1': 'species',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.pest.v1.PestSpecies',
      '10': 'species'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListPestSpeciesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPestSpeciesResponseDescriptor = $convert.base64Decode(
    'ChdMaXN0UGVzdFNwZWNpZXNSZXNwb25zZRI6CgdzcGVjaWVzGAEgAygLMiAuYWdyaWN1bHR1cm'
    'UucGVzdC52MS5QZXN0U3BlY2llc1IHc3BlY2llcxImCg9uZXh0X3BhZ2VfdG9rZW4YAiABKAlS'
    'DW5leHRQYWdlVG9rZW4SHwoLdG90YWxfY291bnQYAyABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use getTreatmentPlanRequestDescriptor instead')
const GetTreatmentPlanRequest$json = {
  '1': 'GetTreatmentPlanRequest',
  '2': [
    {'1': 'prediction_id', '3': 1, '4': 1, '5': 9, '10': 'predictionId'},
  ],
};

/// Descriptor for `GetTreatmentPlanRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTreatmentPlanRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRUcmVhdG1lbnRQbGFuUmVxdWVzdBIjCg1wcmVkaWN0aW9uX2lkGAEgASgJUgxwcmVkaW'
        'N0aW9uSWQ=');

@$core.Deprecated('Use getTreatmentPlanResponseDescriptor instead')
const GetTreatmentPlanResponse$json = {
  '1': 'GetTreatmentPlanResponse',
  '2': [
    {
      '1': 'prediction',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.pest.v1.PestPrediction',
      '10': 'prediction'
    },
    {
      '1': 'treatments',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.pest.v1.RecommendedTreatment',
      '10': 'treatments'
    },
  ],
};

/// Descriptor for `GetTreatmentPlanResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTreatmentPlanResponseDescriptor = $convert.base64Decode(
    'ChhHZXRUcmVhdG1lbnRQbGFuUmVzcG9uc2USQwoKcHJlZGljdGlvbhgBIAEoCzIjLmFncmljdW'
    'x0dXJlLnBlc3QudjEuUGVzdFByZWRpY3Rpb25SCnByZWRpY3Rpb24SSQoKdHJlYXRtZW50cxgC'
    'IAMoCzIpLmFncmljdWx0dXJlLnBlc3QudjEuUmVjb21tZW5kZWRUcmVhdG1lbnRSCnRyZWF0bW'
    'VudHM=');

@$core.Deprecated('Use getRiskMapRequestDescriptor instead')
const GetRiskMapRequest$json = {
  '1': 'GetRiskMapRequest',
  '2': [
    {'1': 'pest_species_id', '3': 1, '4': 1, '5': 9, '10': 'pestSpeciesId'},
    {'1': 'region', '3': 2, '4': 1, '5': 9, '10': 'region'},
  ],
};

/// Descriptor for `GetRiskMapRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRiskMapRequestDescriptor = $convert.base64Decode(
    'ChFHZXRSaXNrTWFwUmVxdWVzdBImCg9wZXN0X3NwZWNpZXNfaWQYASABKAlSDXBlc3RTcGVjaW'
    'VzSWQSFgoGcmVnaW9uGAIgASgJUgZyZWdpb24=');

@$core.Deprecated('Use getRiskMapResponseDescriptor instead')
const GetRiskMapResponse$json = {
  '1': 'GetRiskMapResponse',
  '2': [
    {
      '1': 'risk_map',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.pest.v1.PestRiskMap',
      '10': 'riskMap'
    },
  ],
};

/// Descriptor for `GetRiskMapResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRiskMapResponseDescriptor = $convert.base64Decode(
    'ChJHZXRSaXNrTWFwUmVzcG9uc2USOwoIcmlza19tYXAYASABKAsyIC5hZ3JpY3VsdHVyZS5wZX'
    'N0LnYxLlBlc3RSaXNrTWFwUgdyaXNrTWFw');

@$core.Deprecated('Use listAlertsRequestDescriptor instead')
const ListAlertsRequest$json = {
  '1': 'ListAlertsRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.pest.v1.AlertStatus',
      '10': 'status'
    },
    {
      '1': 'min_risk_level',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.pest.v1.RiskLevel',
      '10': 'minRiskLevel'
    },
    {'1': 'page_size', '3': 5, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 6, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListAlertsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAlertsRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0QWxlcnRzUmVxdWVzdBIXCgdmYXJtX2lkGAEgASgJUgZmYXJtSWQSGQoIZmllbGRfaW'
    'QYAiABKAlSB2ZpZWxkSWQSOAoGc3RhdHVzGAMgASgOMiAuYWdyaWN1bHR1cmUucGVzdC52MS5B'
    'bGVydFN0YXR1c1IGc3RhdHVzEkQKDm1pbl9yaXNrX2xldmVsGAQgASgOMh4uYWdyaWN1bHR1cm'
    'UucGVzdC52MS5SaXNrTGV2ZWxSDG1pblJpc2tMZXZlbBIbCglwYWdlX3NpemUYBSABKAVSCHBh'
    'Z2VTaXplEh0KCnBhZ2VfdG9rZW4YBiABKAlSCXBhZ2VUb2tlbg==');

@$core.Deprecated('Use listAlertsResponseDescriptor instead')
const ListAlertsResponse$json = {
  '1': 'ListAlertsResponse',
  '2': [
    {
      '1': 'alerts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.pest.v1.PestAlert',
      '10': 'alerts'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListAlertsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAlertsResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0QWxlcnRzUmVzcG9uc2USNgoGYWxlcnRzGAEgAygLMh4uYWdyaWN1bHR1cmUucGVzdC'
    '52MS5QZXN0QWxlcnRSBmFsZXJ0cxImCg9uZXh0X3BhZ2VfdG9rZW4YAiABKAlSDW5leHRQYWdl'
    'VG9rZW4SHwoLdG90YWxfY291bnQYAyABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use acknowledgeAlertRequestDescriptor instead')
const AcknowledgeAlertRequest$json = {
  '1': 'AcknowledgeAlertRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `AcknowledgeAlertRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List acknowledgeAlertRequestDescriptor = $convert
    .base64Decode('ChdBY2tub3dsZWRnZUFsZXJ0UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use acknowledgeAlertResponseDescriptor instead')
const AcknowledgeAlertResponse$json = {
  '1': 'AcknowledgeAlertResponse',
  '2': [
    {
      '1': 'alert',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.pest.v1.PestAlert',
      '10': 'alert'
    },
  ],
};

/// Descriptor for `AcknowledgeAlertResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List acknowledgeAlertResponseDescriptor =
    $convert.base64Decode(
        'ChhBY2tub3dsZWRnZUFsZXJ0UmVzcG9uc2USNAoFYWxlcnQYASABKAsyHi5hZ3JpY3VsdHVyZS'
        '5wZXN0LnYxLlBlc3RBbGVydFIFYWxlcnQ=');

const $core.Map<$core.String, $core.dynamic> PestPredictionServiceBase$json = {
  '1': 'PestPredictionService',
  '2': [
    {
      '1': 'PredictPestRisk',
      '2': '.agriculture.pest.v1.PredictPestRiskRequest',
      '3': '.agriculture.pest.v1.PredictPestRiskResponse'
    },
    {
      '1': 'GetPrediction',
      '2': '.agriculture.pest.v1.GetPredictionRequest',
      '3': '.agriculture.pest.v1.GetPredictionResponse'
    },
    {
      '1': 'ListPredictions',
      '2': '.agriculture.pest.v1.ListPredictionsRequest',
      '3': '.agriculture.pest.v1.ListPredictionsResponse'
    },
    {
      '1': 'ReportObservation',
      '2': '.agriculture.pest.v1.ReportObservationRequest',
      '3': '.agriculture.pest.v1.ReportObservationResponse'
    },
    {
      '1': 'ListObservations',
      '2': '.agriculture.pest.v1.ListObservationsRequest',
      '3': '.agriculture.pest.v1.ListObservationsResponse'
    },
    {
      '1': 'GetPestSpecies',
      '2': '.agriculture.pest.v1.GetPestSpeciesRequest',
      '3': '.agriculture.pest.v1.GetPestSpeciesResponse'
    },
    {
      '1': 'ListPestSpecies',
      '2': '.agriculture.pest.v1.ListPestSpeciesRequest',
      '3': '.agriculture.pest.v1.ListPestSpeciesResponse'
    },
    {
      '1': 'GetTreatmentPlan',
      '2': '.agriculture.pest.v1.GetTreatmentPlanRequest',
      '3': '.agriculture.pest.v1.GetTreatmentPlanResponse'
    },
    {
      '1': 'GetRiskMap',
      '2': '.agriculture.pest.v1.GetRiskMapRequest',
      '3': '.agriculture.pest.v1.GetRiskMapResponse'
    },
    {
      '1': 'ListAlerts',
      '2': '.agriculture.pest.v1.ListAlertsRequest',
      '3': '.agriculture.pest.v1.ListAlertsResponse'
    },
    {
      '1': 'AcknowledgeAlert',
      '2': '.agriculture.pest.v1.AcknowledgeAlertRequest',
      '3': '.agriculture.pest.v1.AcknowledgeAlertResponse'
    },
  ],
};

@$core.Deprecated('Use pestPredictionServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    PestPredictionServiceBase$messageJson = {
  '.agriculture.pest.v1.PredictPestRiskRequest': PredictPestRiskRequest$json,
  '.agriculture.pest.v1.WeatherFactors': WeatherFactors$json,
  '.agriculture.pest.v1.PredictPestRiskResponse': PredictPestRiskResponse$json,
  '.agriculture.pest.v1.PestPrediction': PestPrediction$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.pest.v1.RecommendedTreatment': RecommendedTreatment$json,
  '.agriculture.pest.v1.GetPredictionRequest': GetPredictionRequest$json,
  '.agriculture.pest.v1.GetPredictionResponse': GetPredictionResponse$json,
  '.agriculture.pest.v1.ListPredictionsRequest': ListPredictionsRequest$json,
  '.agriculture.pest.v1.ListPredictionsResponse': ListPredictionsResponse$json,
  '.agriculture.pest.v1.ReportObservationRequest':
      ReportObservationRequest$json,
  '.agriculture.pest.v1.ReportObservationResponse':
      ReportObservationResponse$json,
  '.agriculture.pest.v1.PestObservation': PestObservation$json,
  '.agriculture.pest.v1.ListObservationsRequest': ListObservationsRequest$json,
  '.agriculture.pest.v1.ListObservationsResponse':
      ListObservationsResponse$json,
  '.agriculture.pest.v1.GetPestSpeciesRequest': GetPestSpeciesRequest$json,
  '.agriculture.pest.v1.GetPestSpeciesResponse': GetPestSpeciesResponse$json,
  '.agriculture.pest.v1.PestSpecies': PestSpecies$json,
  '.agriculture.pest.v1.ListPestSpeciesRequest': ListPestSpeciesRequest$json,
  '.agriculture.pest.v1.ListPestSpeciesResponse': ListPestSpeciesResponse$json,
  '.agriculture.pest.v1.GetTreatmentPlanRequest': GetTreatmentPlanRequest$json,
  '.agriculture.pest.v1.GetTreatmentPlanResponse':
      GetTreatmentPlanResponse$json,
  '.agriculture.pest.v1.GetRiskMapRequest': GetRiskMapRequest$json,
  '.agriculture.pest.v1.GetRiskMapResponse': GetRiskMapResponse$json,
  '.agriculture.pest.v1.PestRiskMap': PestRiskMap$json,
  '.agriculture.pest.v1.ListAlertsRequest': ListAlertsRequest$json,
  '.agriculture.pest.v1.ListAlertsResponse': ListAlertsResponse$json,
  '.agriculture.pest.v1.PestAlert': PestAlert$json,
  '.agriculture.pest.v1.AcknowledgeAlertRequest': AcknowledgeAlertRequest$json,
  '.agriculture.pest.v1.AcknowledgeAlertResponse':
      AcknowledgeAlertResponse$json,
};

/// Descriptor for `PestPredictionService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List pestPredictionServiceDescriptor = $convert.base64Decode(
    'ChVQZXN0UHJlZGljdGlvblNlcnZpY2USbAoPUHJlZGljdFBlc3RSaXNrEisuYWdyaWN1bHR1cm'
    'UucGVzdC52MS5QcmVkaWN0UGVzdFJpc2tSZXF1ZXN0GiwuYWdyaWN1bHR1cmUucGVzdC52MS5Q'
    'cmVkaWN0UGVzdFJpc2tSZXNwb25zZRJmCg1HZXRQcmVkaWN0aW9uEikuYWdyaWN1bHR1cmUucG'
    'VzdC52MS5HZXRQcmVkaWN0aW9uUmVxdWVzdBoqLmFncmljdWx0dXJlLnBlc3QudjEuR2V0UHJl'
    'ZGljdGlvblJlc3BvbnNlEmwKD0xpc3RQcmVkaWN0aW9ucxIrLmFncmljdWx0dXJlLnBlc3Qudj'
    'EuTGlzdFByZWRpY3Rpb25zUmVxdWVzdBosLmFncmljdWx0dXJlLnBlc3QudjEuTGlzdFByZWRp'
    'Y3Rpb25zUmVzcG9uc2UScgoRUmVwb3J0T2JzZXJ2YXRpb24SLS5hZ3JpY3VsdHVyZS5wZXN0Ln'
    'YxLlJlcG9ydE9ic2VydmF0aW9uUmVxdWVzdBouLmFncmljdWx0dXJlLnBlc3QudjEuUmVwb3J0'
    'T2JzZXJ2YXRpb25SZXNwb25zZRJvChBMaXN0T2JzZXJ2YXRpb25zEiwuYWdyaWN1bHR1cmUucG'
    'VzdC52MS5MaXN0T2JzZXJ2YXRpb25zUmVxdWVzdBotLmFncmljdWx0dXJlLnBlc3QudjEuTGlz'
    'dE9ic2VydmF0aW9uc1Jlc3BvbnNlEmkKDkdldFBlc3RTcGVjaWVzEiouYWdyaWN1bHR1cmUucG'
    'VzdC52MS5HZXRQZXN0U3BlY2llc1JlcXVlc3QaKy5hZ3JpY3VsdHVyZS5wZXN0LnYxLkdldFBl'
    'c3RTcGVjaWVzUmVzcG9uc2USbAoPTGlzdFBlc3RTcGVjaWVzEisuYWdyaWN1bHR1cmUucGVzdC'
    '52MS5MaXN0UGVzdFNwZWNpZXNSZXF1ZXN0GiwuYWdyaWN1bHR1cmUucGVzdC52MS5MaXN0UGVz'
    'dFNwZWNpZXNSZXNwb25zZRJvChBHZXRUcmVhdG1lbnRQbGFuEiwuYWdyaWN1bHR1cmUucGVzdC'
    '52MS5HZXRUcmVhdG1lbnRQbGFuUmVxdWVzdBotLmFncmljdWx0dXJlLnBlc3QudjEuR2V0VHJl'
    'YXRtZW50UGxhblJlc3BvbnNlEl0KCkdldFJpc2tNYXASJi5hZ3JpY3VsdHVyZS5wZXN0LnYxLk'
    'dldFJpc2tNYXBSZXF1ZXN0GicuYWdyaWN1bHR1cmUucGVzdC52MS5HZXRSaXNrTWFwUmVzcG9u'
    'c2USXQoKTGlzdEFsZXJ0cxImLmFncmljdWx0dXJlLnBlc3QudjEuTGlzdEFsZXJ0c1JlcXVlc3'
    'QaJy5hZ3JpY3VsdHVyZS5wZXN0LnYxLkxpc3RBbGVydHNSZXNwb25zZRJvChBBY2tub3dsZWRn'
    'ZUFsZXJ0EiwuYWdyaWN1bHR1cmUucGVzdC52MS5BY2tub3dsZWRnZUFsZXJ0UmVxdWVzdBotLm'
    'FncmljdWx0dXJlLnBlc3QudjEuQWNrbm93bGVkZ2VBbGVydFJlc3BvbnNl');
