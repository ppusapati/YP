// This is a generated file - do not edit.
//
// Generated from yield.proto.

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

@$core.Deprecated('Use harvestQualityGradeDescriptor instead')
const HarvestQualityGrade$json = {
  '1': 'HarvestQualityGrade',
  '2': [
    {'1': 'HARVEST_QUALITY_GRADE_UNSPECIFIED', '2': 0},
    {'1': 'HARVEST_QUALITY_GRADE_A', '2': 1},
    {'1': 'HARVEST_QUALITY_GRADE_B', '2': 2},
    {'1': 'HARVEST_QUALITY_GRADE_C', '2': 3},
    {'1': 'HARVEST_QUALITY_GRADE_D', '2': 4},
  ],
};

/// Descriptor for `HarvestQualityGrade`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List harvestQualityGradeDescriptor = $convert.base64Decode(
    'ChNIYXJ2ZXN0UXVhbGl0eUdyYWRlEiUKIUhBUlZFU1RfUVVBTElUWV9HUkFERV9VTlNQRUNJRk'
    'lFRBAAEhsKF0hBUlZFU1RfUVVBTElUWV9HUkFERV9BEAESGwoXSEFSVkVTVF9RVUFMSVRZX0dS'
    'QURFX0IQAhIbChdIQVJWRVNUX1FVQUxJVFlfR1JBREVfQxADEhsKF0hBUlZFU1RfUVVBTElUWV'
    '9HUkFERV9EEAQ=');

@$core.Deprecated('Use predictionStatusDescriptor instead')
const PredictionStatus$json = {
  '1': 'PredictionStatus',
  '2': [
    {'1': 'PREDICTION_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'PREDICTION_STATUS_PENDING', '2': 1},
    {'1': 'PREDICTION_STATUS_COMPLETED', '2': 2},
    {'1': 'PREDICTION_STATUS_FAILED', '2': 3},
    {'1': 'PREDICTION_STATUS_SUPERSEDED', '2': 4},
  ],
};

/// Descriptor for `PredictionStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List predictionStatusDescriptor = $convert.base64Decode(
    'ChBQcmVkaWN0aW9uU3RhdHVzEiEKHVBSRURJQ1RJT05fU1RBVFVTX1VOU1BFQ0lGSUVEEAASHQ'
    'oZUFJFRElDVElPTl9TVEFUVVNfUEVORElORxABEh8KG1BSRURJQ1RJT05fU1RBVFVTX0NPTVBM'
    'RVRFRBACEhwKGFBSRURJQ1RJT05fU1RBVFVTX0ZBSUxFRBADEiAKHFBSRURJQ1RJT05fU1RBVF'
    'VTX1NVUEVSU0VERUQQBA==');

@$core.Deprecated('Use harvestPlanStatusDescriptor instead')
const HarvestPlanStatus$json = {
  '1': 'HarvestPlanStatus',
  '2': [
    {'1': 'HARVEST_PLAN_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'HARVEST_PLAN_STATUS_DRAFT', '2': 1},
    {'1': 'HARVEST_PLAN_STATUS_SCHEDULED', '2': 2},
    {'1': 'HARVEST_PLAN_STATUS_IN_PROGRESS', '2': 3},
    {'1': 'HARVEST_PLAN_STATUS_COMPLETED', '2': 4},
    {'1': 'HARVEST_PLAN_STATUS_CANCELLED', '2': 5},
  ],
};

/// Descriptor for `HarvestPlanStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List harvestPlanStatusDescriptor = $convert.base64Decode(
    'ChFIYXJ2ZXN0UGxhblN0YXR1cxIjCh9IQVJWRVNUX1BMQU5fU1RBVFVTX1VOU1BFQ0lGSUVEEA'
    'ASHQoZSEFSVkVTVF9QTEFOX1NUQVRVU19EUkFGVBABEiEKHUhBUlZFU1RfUExBTl9TVEFUVVNf'
    'U0NIRURVTEVEEAISIwofSEFSVkVTVF9QTEFOX1NUQVRVU19JTl9QUk9HUkVTUxADEiEKHUhBUl'
    'ZFU1RfUExBTl9TVEFUVVNfQ09NUExFVEVEEAQSIQodSEFSVkVTVF9QTEFOX1NUQVRVU19DQU5D'
    'RUxMRUQQBQ==');

@$core.Deprecated('Use yieldFactorsDescriptor instead')
const YieldFactors$json = {
  '1': 'YieldFactors',
  '2': [
    {
      '1': 'soil_quality_score',
      '3': 1,
      '4': 1,
      '5': 1,
      '10': 'soilQualityScore'
    },
    {'1': 'weather_score', '3': 2, '4': 1, '5': 1, '10': 'weatherScore'},
    {'1': 'irrigation_score', '3': 3, '4': 1, '5': 1, '10': 'irrigationScore'},
    {
      '1': 'pest_pressure_score',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'pestPressureScore'
    },
    {'1': 'nutrient_score', '3': 5, '4': 1, '5': 1, '10': 'nutrientScore'},
    {'1': 'management_score', '3': 6, '4': 1, '5': 1, '10': 'managementScore'},
  ],
};

/// Descriptor for `YieldFactors`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List yieldFactorsDescriptor = $convert.base64Decode(
    'CgxZaWVsZEZhY3RvcnMSLAoSc29pbF9xdWFsaXR5X3Njb3JlGAEgASgBUhBzb2lsUXVhbGl0eV'
    'Njb3JlEiMKDXdlYXRoZXJfc2NvcmUYAiABKAFSDHdlYXRoZXJTY29yZRIpChBpcnJpZ2F0aW9u'
    'X3Njb3JlGAMgASgBUg9pcnJpZ2F0aW9uU2NvcmUSLgoTcGVzdF9wcmVzc3VyZV9zY29yZRgEIA'
    'EoAVIRcGVzdFByZXNzdXJlU2NvcmUSJQoObnV0cmllbnRfc2NvcmUYBSABKAFSDW51dHJpZW50'
    'U2NvcmUSKQoQbWFuYWdlbWVudF9zY29yZRgGIAEoAVIPbWFuYWdlbWVudFNjb3Jl');

@$core.Deprecated('Use yieldPredictionDescriptor instead')
const YieldPrediction$json = {
  '1': 'YieldPrediction',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 5, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'season', '3': 6, '4': 1, '5': 9, '10': 'season'},
    {'1': 'year', '3': 7, '4': 1, '5': 5, '10': 'year'},
    {
      '1': 'predicted_yield_kg_per_hectare',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'predictedYieldKgPerHectare'
    },
    {
      '1': 'prediction_confidence_pct',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'predictionConfidencePct'
    },
    {
      '1': 'prediction_model_version',
      '3': 10,
      '4': 1,
      '5': 9,
      '10': 'predictionModelVersion'
    },
    {
      '1': 'yield_factors',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.agriculture.yield.v1.YieldFactors',
      '10': 'yieldFactors'
    },
    {
      '1': 'status',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.agriculture.yield.v1.PredictionStatus',
      '10': 'status'
    },
    {'1': 'created_by', '3': 13, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'updated_by', '3': 14, '4': 1, '5': 9, '10': 'updatedBy'},
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

/// Descriptor for `YieldPrediction`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List yieldPredictionDescriptor = $convert.base64Decode(
    'Cg9ZaWVsZFByZWRpY3Rpb24SDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdG'
    'VuYW50SWQSFwoHZmFybV9pZBgDIAEoCVIGZmFybUlkEhkKCGZpZWxkX2lkGAQgASgJUgdmaWVs'
    'ZElkEhcKB2Nyb3BfaWQYBSABKAlSBmNyb3BJZBIWCgZzZWFzb24YBiABKAlSBnNlYXNvbhISCg'
    'R5ZWFyGAcgASgFUgR5ZWFyEkIKHnByZWRpY3RlZF95aWVsZF9rZ19wZXJfaGVjdGFyZRgIIAEo'
    'AVIacHJlZGljdGVkWWllbGRLZ1BlckhlY3RhcmUSOgoZcHJlZGljdGlvbl9jb25maWRlbmNlX3'
    'BjdBgJIAEoAVIXcHJlZGljdGlvbkNvbmZpZGVuY2VQY3QSOAoYcHJlZGljdGlvbl9tb2RlbF92'
    'ZXJzaW9uGAogASgJUhZwcmVkaWN0aW9uTW9kZWxWZXJzaW9uEkcKDXlpZWxkX2ZhY3RvcnMYCy'
    'ABKAsyIi5hZ3JpY3VsdHVyZS55aWVsZC52MS5ZaWVsZEZhY3RvcnNSDHlpZWxkRmFjdG9ycxI+'
    'CgZzdGF0dXMYDCABKA4yJi5hZ3JpY3VsdHVyZS55aWVsZC52MS5QcmVkaWN0aW9uU3RhdHVzUg'
    'ZzdGF0dXMSHQoKY3JlYXRlZF9ieRgNIAEoCVIJY3JlYXRlZEJ5Eh0KCnVwZGF0ZWRfYnkYDiAB'
    'KAlSCXVwZGF0ZWRCeRIYCgd2ZXJzaW9uGA8gASgDUgd2ZXJzaW9uEjkKCmNyZWF0ZWRfYXQYEC'
    'ABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRlZF9h'
    'dBgRIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdA==');

@$core.Deprecated('Use yieldRecordDescriptor instead')
const YieldRecord$json = {
  '1': 'YieldRecord',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 5, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'season', '3': 6, '4': 1, '5': 9, '10': 'season'},
    {'1': 'year', '3': 7, '4': 1, '5': 5, '10': 'year'},
    {
      '1': 'actual_yield_kg_per_hectare',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'actualYieldKgPerHectare'
    },
    {
      '1': 'total_area_harvested_hectares',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'totalAreaHarvestedHectares'
    },
    {'1': 'total_yield_kg', '3': 10, '4': 1, '5': 1, '10': 'totalYieldKg'},
    {
      '1': 'harvest_quality_grade',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.agriculture.yield.v1.HarvestQualityGrade',
      '10': 'harvestQualityGrade'
    },
    {
      '1': 'moisture_content_pct',
      '3': 12,
      '4': 1,
      '5': 1,
      '10': 'moistureContentPct'
    },
    {
      '1': 'harvest_date',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'harvestDate'
    },
    {
      '1': 'revenue_per_hectare',
      '3': 14,
      '4': 1,
      '5': 1,
      '10': 'revenuePerHectare'
    },
    {'1': 'cost_per_hectare', '3': 15, '4': 1, '5': 1, '10': 'costPerHectare'},
    {
      '1': 'profit_per_hectare',
      '3': 16,
      '4': 1,
      '5': 1,
      '10': 'profitPerHectare'
    },
    {'1': 'prediction_id', '3': 17, '4': 1, '5': 9, '10': 'predictionId'},
    {'1': 'created_by', '3': 18, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'updated_by', '3': 19, '4': 1, '5': 9, '10': 'updatedBy'},
    {'1': 'version', '3': 20, '4': 1, '5': 3, '10': 'version'},
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
};

/// Descriptor for `YieldRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List yieldRecordDescriptor = $convert.base64Decode(
    'CgtZaWVsZFJlY29yZBIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW5hbn'
    'RJZBIXCgdmYXJtX2lkGAMgASgJUgZmYXJtSWQSGQoIZmllbGRfaWQYBCABKAlSB2ZpZWxkSWQS'
    'FwoHY3JvcF9pZBgFIAEoCVIGY3JvcElkEhYKBnNlYXNvbhgGIAEoCVIGc2Vhc29uEhIKBHllYX'
    'IYByABKAVSBHllYXISPAobYWN0dWFsX3lpZWxkX2tnX3Blcl9oZWN0YXJlGAggASgBUhdhY3R1'
    'YWxZaWVsZEtnUGVySGVjdGFyZRJBCh10b3RhbF9hcmVhX2hhcnZlc3RlZF9oZWN0YXJlcxgJIA'
    'EoAVIadG90YWxBcmVhSGFydmVzdGVkSGVjdGFyZXMSJAoOdG90YWxfeWllbGRfa2cYCiABKAFS'
    'DHRvdGFsWWllbGRLZxJdChVoYXJ2ZXN0X3F1YWxpdHlfZ3JhZGUYCyABKA4yKS5hZ3JpY3VsdH'
    'VyZS55aWVsZC52MS5IYXJ2ZXN0UXVhbGl0eUdyYWRlUhNoYXJ2ZXN0UXVhbGl0eUdyYWRlEjAK'
    'FG1vaXN0dXJlX2NvbnRlbnRfcGN0GAwgASgBUhJtb2lzdHVyZUNvbnRlbnRQY3QSPQoMaGFydm'
    'VzdF9kYXRlGA0gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFILaGFydmVzdERhdGUS'
    'LgoTcmV2ZW51ZV9wZXJfaGVjdGFyZRgOIAEoAVIRcmV2ZW51ZVBlckhlY3RhcmUSKAoQY29zdF'
    '9wZXJfaGVjdGFyZRgPIAEoAVIOY29zdFBlckhlY3RhcmUSLAoScHJvZml0X3Blcl9oZWN0YXJl'
    'GBAgASgBUhBwcm9maXRQZXJIZWN0YXJlEiMKDXByZWRpY3Rpb25faWQYESABKAlSDHByZWRpY3'
    'Rpb25JZBIdCgpjcmVhdGVkX2J5GBIgASgJUgljcmVhdGVkQnkSHQoKdXBkYXRlZF9ieRgTIAEo'
    'CVIJdXBkYXRlZEJ5EhgKB3ZlcnNpb24YFCABKANSB3ZlcnNpb24SOQoKY3JlYXRlZF9hdBgVIA'
    'EoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0'
    'GBYgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZEF0');

@$core.Deprecated('Use harvestPlanDescriptor instead')
const HarvestPlan$json = {
  '1': 'HarvestPlan',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 5, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'season', '3': 6, '4': 1, '5': 9, '10': 'season'},
    {'1': 'year', '3': 7, '4': 1, '5': 5, '10': 'year'},
    {
      '1': 'planned_start_date',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'plannedStartDate'
    },
    {
      '1': 'planned_end_date',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'plannedEndDate'
    },
    {
      '1': 'estimated_yield_kg',
      '3': 10,
      '4': 1,
      '5': 1,
      '10': 'estimatedYieldKg'
    },
    {
      '1': 'total_area_hectares',
      '3': 11,
      '4': 1,
      '5': 1,
      '10': 'totalAreaHectares'
    },
    {
      '1': 'status',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.agriculture.yield.v1.HarvestPlanStatus',
      '10': 'status'
    },
    {'1': 'notes', '3': 13, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'created_by', '3': 14, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'updated_by', '3': 15, '4': 1, '5': 9, '10': 'updatedBy'},
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

/// Descriptor for `HarvestPlan`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List harvestPlanDescriptor = $convert.base64Decode(
    'CgtIYXJ2ZXN0UGxhbhIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW5hbn'
    'RJZBIXCgdmYXJtX2lkGAMgASgJUgZmYXJtSWQSGQoIZmllbGRfaWQYBCABKAlSB2ZpZWxkSWQS'
    'FwoHY3JvcF9pZBgFIAEoCVIGY3JvcElkEhYKBnNlYXNvbhgGIAEoCVIGc2Vhc29uEhIKBHllYX'
    'IYByABKAVSBHllYXISSAoScGxhbm5lZF9zdGFydF9kYXRlGAggASgLMhouZ29vZ2xlLnByb3Rv'
    'YnVmLlRpbWVzdGFtcFIQcGxhbm5lZFN0YXJ0RGF0ZRJEChBwbGFubmVkX2VuZF9kYXRlGAkgAS'
    'gLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIOcGxhbm5lZEVuZERhdGUSLAoSZXN0aW1h'
    'dGVkX3lpZWxkX2tnGAogASgBUhBlc3RpbWF0ZWRZaWVsZEtnEi4KE3RvdGFsX2FyZWFfaGVjdG'
    'FyZXMYCyABKAFSEXRvdGFsQXJlYUhlY3RhcmVzEj8KBnN0YXR1cxgMIAEoDjInLmFncmljdWx0'
    'dXJlLnlpZWxkLnYxLkhhcnZlc3RQbGFuU3RhdHVzUgZzdGF0dXMSFAoFbm90ZXMYDSABKAlSBW'
    '5vdGVzEh0KCmNyZWF0ZWRfYnkYDiABKAlSCWNyZWF0ZWRCeRIdCgp1cGRhdGVkX2J5GA8gASgJ'
    'Ugl1cGRhdGVkQnkSGAoHdmVyc2lvbhgQIAEoA1IHdmVyc2lvbhI5CgpjcmVhdGVkX2F0GBEgAS'
    'gLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQY'
    'EiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use cropPerformanceDescriptor instead')
const CropPerformance$json = {
  '1': 'CropPerformance',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 5, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'season', '3': 6, '4': 1, '5': 9, '10': 'season'},
    {'1': 'year', '3': 7, '4': 1, '5': 5, '10': 'year'},
    {
      '1': 'actual_yield_kg_per_hectare',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'actualYieldKgPerHectare'
    },
    {
      '1': 'predicted_yield_kg_per_hectare',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'predictedYieldKgPerHectare'
    },
    {
      '1': 'yield_variance_pct',
      '3': 10,
      '4': 1,
      '5': 1,
      '10': 'yieldVariancePct'
    },
    {
      '1': 'comparison_to_regional_avg_pct',
      '3': 11,
      '4': 1,
      '5': 1,
      '10': 'comparisonToRegionalAvgPct'
    },
    {
      '1': 'comparison_to_historical_avg_pct',
      '3': 12,
      '4': 1,
      '5': 1,
      '10': 'comparisonToHistoricalAvgPct'
    },
    {
      '1': 'revenue_per_hectare',
      '3': 13,
      '4': 1,
      '5': 1,
      '10': 'revenuePerHectare'
    },
    {'1': 'cost_per_hectare', '3': 14, '4': 1, '5': 1, '10': 'costPerHectare'},
    {
      '1': 'profit_per_hectare',
      '3': 15,
      '4': 1,
      '5': 1,
      '10': 'profitPerHectare'
    },
    {
      '1': 'yield_factors',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.agriculture.yield.v1.YieldFactors',
      '10': 'yieldFactors'
    },
    {'1': 'version', '3': 17, '4': 1, '5': 3, '10': 'version'},
    {
      '1': 'created_at',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 19,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `CropPerformance`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cropPerformanceDescriptor = $convert.base64Decode(
    'Cg9Dcm9wUGVyZm9ybWFuY2USDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdG'
    'VuYW50SWQSFwoHZmFybV9pZBgDIAEoCVIGZmFybUlkEhkKCGZpZWxkX2lkGAQgASgJUgdmaWVs'
    'ZElkEhcKB2Nyb3BfaWQYBSABKAlSBmNyb3BJZBIWCgZzZWFzb24YBiABKAlSBnNlYXNvbhISCg'
    'R5ZWFyGAcgASgFUgR5ZWFyEjwKG2FjdHVhbF95aWVsZF9rZ19wZXJfaGVjdGFyZRgIIAEoAVIX'
    'YWN0dWFsWWllbGRLZ1BlckhlY3RhcmUSQgoecHJlZGljdGVkX3lpZWxkX2tnX3Blcl9oZWN0YX'
    'JlGAkgASgBUhpwcmVkaWN0ZWRZaWVsZEtnUGVySGVjdGFyZRIsChJ5aWVsZF92YXJpYW5jZV9w'
    'Y3QYCiABKAFSEHlpZWxkVmFyaWFuY2VQY3QSQgoeY29tcGFyaXNvbl90b19yZWdpb25hbF9hdm'
    'dfcGN0GAsgASgBUhpjb21wYXJpc29uVG9SZWdpb25hbEF2Z1BjdBJGCiBjb21wYXJpc29uX3Rv'
    'X2hpc3RvcmljYWxfYXZnX3BjdBgMIAEoAVIcY29tcGFyaXNvblRvSGlzdG9yaWNhbEF2Z1BjdB'
    'IuChNyZXZlbnVlX3Blcl9oZWN0YXJlGA0gASgBUhFyZXZlbnVlUGVySGVjdGFyZRIoChBjb3N0'
    'X3Blcl9oZWN0YXJlGA4gASgBUg5jb3N0UGVySGVjdGFyZRIsChJwcm9maXRfcGVyX2hlY3Rhcm'
    'UYDyABKAFSEHByb2ZpdFBlckhlY3RhcmUSRwoNeWllbGRfZmFjdG9ycxgQIAEoCzIiLmFncmlj'
    'dWx0dXJlLnlpZWxkLnYxLllpZWxkRmFjdG9yc1IMeWllbGRGYWN0b3JzEhgKB3ZlcnNpb24YES'
    'ABKANSB3ZlcnNpb24SOQoKY3JlYXRlZF9hdBgSIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1l'
    'c3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GBMgASgLMhouZ29vZ2xlLnByb3RvYnVmLl'
    'RpbWVzdGFtcFIJdXBkYXRlZEF0');

@$core.Deprecated('Use predictYieldRequestDescriptor instead')
const PredictYieldRequest$json = {
  '1': 'PredictYieldRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 3, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'season', '3': 4, '4': 1, '5': 9, '10': 'season'},
    {'1': 'year', '3': 5, '4': 1, '5': 5, '10': 'year'},
    {
      '1': 'yield_factors',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.agriculture.yield.v1.YieldFactors',
      '10': 'yieldFactors'
    },
  ],
};

/// Descriptor for `PredictYieldRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List predictYieldRequestDescriptor = $convert.base64Decode(
    'ChNQcmVkaWN0WWllbGRSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZBIZCghmaWVsZF'
    '9pZBgCIAEoCVIHZmllbGRJZBIXCgdjcm9wX2lkGAMgASgJUgZjcm9wSWQSFgoGc2Vhc29uGAQg'
    'ASgJUgZzZWFzb24SEgoEeWVhchgFIAEoBVIEeWVhchJHCg15aWVsZF9mYWN0b3JzGAYgASgLMi'
    'IuYWdyaWN1bHR1cmUueWllbGQudjEuWWllbGRGYWN0b3JzUgx5aWVsZEZhY3RvcnM=');

@$core.Deprecated('Use predictYieldResponseDescriptor instead')
const PredictYieldResponse$json = {
  '1': 'PredictYieldResponse',
  '2': [
    {
      '1': 'prediction',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.yield.v1.YieldPrediction',
      '10': 'prediction'
    },
  ],
};

/// Descriptor for `PredictYieldResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List predictYieldResponseDescriptor = $convert.base64Decode(
    'ChRQcmVkaWN0WWllbGRSZXNwb25zZRJFCgpwcmVkaWN0aW9uGAEgASgLMiUuYWdyaWN1bHR1cm'
    'UueWllbGQudjEuWWllbGRQcmVkaWN0aW9uUgpwcmVkaWN0aW9u');

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
      '6': '.agriculture.yield.v1.YieldPrediction',
      '10': 'prediction'
    },
  ],
};

/// Descriptor for `GetPredictionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPredictionResponseDescriptor = $convert.base64Decode(
    'ChVHZXRQcmVkaWN0aW9uUmVzcG9uc2USRQoKcHJlZGljdGlvbhgBIAEoCzIlLmFncmljdWx0dX'
    'JlLnlpZWxkLnYxLllpZWxkUHJlZGljdGlvblIKcHJlZGljdGlvbg==');

@$core.Deprecated('Use listPredictionsRequestDescriptor instead')
const ListPredictionsRequest$json = {
  '1': 'ListPredictionsRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 5, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'season', '3': 6, '4': 1, '5': 9, '10': 'season'},
    {'1': 'year', '3': 7, '4': 1, '5': 5, '10': 'year'},
    {
      '1': 'status',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.agriculture.yield.v1.PredictionStatus',
      '10': 'status'
    },
    {'1': 'order_by', '3': 9, '4': 1, '5': 9, '10': 'orderBy'},
  ],
};

/// Descriptor for `ListPredictionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPredictionsRequestDescriptor = $convert.base64Decode(
    'ChZMaXN0UHJlZGljdGlvbnNSZXF1ZXN0EhsKCXBhZ2Vfc2l6ZRgBIAEoBVIIcGFnZVNpemUSHQ'
    'oKcGFnZV90b2tlbhgCIAEoCVIJcGFnZVRva2VuEhcKB2Zhcm1faWQYAyABKAlSBmZhcm1JZBIZ'
    'CghmaWVsZF9pZBgEIAEoCVIHZmllbGRJZBIXCgdjcm9wX2lkGAUgASgJUgZjcm9wSWQSFgoGc2'
    'Vhc29uGAYgASgJUgZzZWFzb24SEgoEeWVhchgHIAEoBVIEeWVhchI+CgZzdGF0dXMYCCABKA4y'
    'Ji5hZ3JpY3VsdHVyZS55aWVsZC52MS5QcmVkaWN0aW9uU3RhdHVzUgZzdGF0dXMSGQoIb3JkZX'
    'JfYnkYCSABKAlSB29yZGVyQnk=');

@$core.Deprecated('Use listPredictionsResponseDescriptor instead')
const ListPredictionsResponse$json = {
  '1': 'ListPredictionsResponse',
  '2': [
    {
      '1': 'predictions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.yield.v1.YieldPrediction',
      '10': 'predictions'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListPredictionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPredictionsResponseDescriptor = $convert.base64Decode(
    'ChdMaXN0UHJlZGljdGlvbnNSZXNwb25zZRJHCgtwcmVkaWN0aW9ucxgBIAMoCzIlLmFncmljdW'
    'x0dXJlLnlpZWxkLnYxLllpZWxkUHJlZGljdGlvblILcHJlZGljdGlvbnMSJgoPbmV4dF9wYWdl'
    'X3Rva2VuGAIgASgJUg1uZXh0UGFnZVRva2VuEh8KC3RvdGFsX2NvdW50GAMgASgFUgp0b3RhbE'
    'NvdW50');

@$core.Deprecated('Use recordYieldRequestDescriptor instead')
const RecordYieldRequest$json = {
  '1': 'RecordYieldRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 3, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'season', '3': 4, '4': 1, '5': 9, '10': 'season'},
    {'1': 'year', '3': 5, '4': 1, '5': 5, '10': 'year'},
    {
      '1': 'actual_yield_kg_per_hectare',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'actualYieldKgPerHectare'
    },
    {
      '1': 'total_area_harvested_hectares',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'totalAreaHarvestedHectares'
    },
    {'1': 'total_yield_kg', '3': 8, '4': 1, '5': 1, '10': 'totalYieldKg'},
    {
      '1': 'harvest_quality_grade',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.agriculture.yield.v1.HarvestQualityGrade',
      '10': 'harvestQualityGrade'
    },
    {
      '1': 'moisture_content_pct',
      '3': 10,
      '4': 1,
      '5': 1,
      '10': 'moistureContentPct'
    },
    {
      '1': 'harvest_date',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'harvestDate'
    },
    {
      '1': 'revenue_per_hectare',
      '3': 12,
      '4': 1,
      '5': 1,
      '10': 'revenuePerHectare'
    },
    {'1': 'cost_per_hectare', '3': 13, '4': 1, '5': 1, '10': 'costPerHectare'},
    {'1': 'prediction_id', '3': 14, '4': 1, '5': 9, '10': 'predictionId'},
  ],
};

/// Descriptor for `RecordYieldRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recordYieldRequestDescriptor = $convert.base64Decode(
    'ChJSZWNvcmRZaWVsZFJlcXVlc3QSFwoHZmFybV9pZBgBIAEoCVIGZmFybUlkEhkKCGZpZWxkX2'
    'lkGAIgASgJUgdmaWVsZElkEhcKB2Nyb3BfaWQYAyABKAlSBmNyb3BJZBIWCgZzZWFzb24YBCAB'
    'KAlSBnNlYXNvbhISCgR5ZWFyGAUgASgFUgR5ZWFyEjwKG2FjdHVhbF95aWVsZF9rZ19wZXJfaG'
    'VjdGFyZRgGIAEoAVIXYWN0dWFsWWllbGRLZ1BlckhlY3RhcmUSQQoddG90YWxfYXJlYV9oYXJ2'
    'ZXN0ZWRfaGVjdGFyZXMYByABKAFSGnRvdGFsQXJlYUhhcnZlc3RlZEhlY3RhcmVzEiQKDnRvdG'
    'FsX3lpZWxkX2tnGAggASgBUgx0b3RhbFlpZWxkS2cSXQoVaGFydmVzdF9xdWFsaXR5X2dyYWRl'
    'GAkgASgOMikuYWdyaWN1bHR1cmUueWllbGQudjEuSGFydmVzdFF1YWxpdHlHcmFkZVITaGFydm'
    'VzdFF1YWxpdHlHcmFkZRIwChRtb2lzdHVyZV9jb250ZW50X3BjdBgKIAEoAVISbW9pc3R1cmVD'
    'b250ZW50UGN0Ej0KDGhhcnZlc3RfZGF0ZRgLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3'
    'RhbXBSC2hhcnZlc3REYXRlEi4KE3JldmVudWVfcGVyX2hlY3RhcmUYDCABKAFSEXJldmVudWVQ'
    'ZXJIZWN0YXJlEigKEGNvc3RfcGVyX2hlY3RhcmUYDSABKAFSDmNvc3RQZXJIZWN0YXJlEiMKDX'
    'ByZWRpY3Rpb25faWQYDiABKAlSDHByZWRpY3Rpb25JZA==');

@$core.Deprecated('Use recordYieldResponseDescriptor instead')
const RecordYieldResponse$json = {
  '1': 'RecordYieldResponse',
  '2': [
    {
      '1': 'record',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.yield.v1.YieldRecord',
      '10': 'record'
    },
  ],
};

/// Descriptor for `RecordYieldResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recordYieldResponseDescriptor = $convert.base64Decode(
    'ChNSZWNvcmRZaWVsZFJlc3BvbnNlEjkKBnJlY29yZBgBIAEoCzIhLmFncmljdWx0dXJlLnlpZW'
    'xkLnYxLllpZWxkUmVjb3JkUgZyZWNvcmQ=');

@$core.Deprecated('Use getYieldHistoryRequestDescriptor instead')
const GetYieldHistoryRequest$json = {
  '1': 'GetYieldHistoryRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 3, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'from_year', '3': 4, '4': 1, '5': 5, '10': 'fromYear'},
    {'1': 'to_year', '3': 5, '4': 1, '5': 5, '10': 'toYear'},
    {'1': 'page_size', '3': 6, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 7, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `GetYieldHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getYieldHistoryRequestDescriptor = $convert.base64Decode(
    'ChZHZXRZaWVsZEhpc3RvcnlSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZBIZCghmaW'
    'VsZF9pZBgCIAEoCVIHZmllbGRJZBIXCgdjcm9wX2lkGAMgASgJUgZjcm9wSWQSGwoJZnJvbV95'
    'ZWFyGAQgASgFUghmcm9tWWVhchIXCgd0b195ZWFyGAUgASgFUgZ0b1llYXISGwoJcGFnZV9zaX'
    'plGAYgASgFUghwYWdlU2l6ZRIdCgpwYWdlX3Rva2VuGAcgASgJUglwYWdlVG9rZW4=');

@$core.Deprecated('Use getYieldHistoryResponseDescriptor instead')
const GetYieldHistoryResponse$json = {
  '1': 'GetYieldHistoryResponse',
  '2': [
    {
      '1': 'records',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.yield.v1.YieldRecord',
      '10': 'records'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `GetYieldHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getYieldHistoryResponseDescriptor = $convert.base64Decode(
    'ChdHZXRZaWVsZEhpc3RvcnlSZXNwb25zZRI7CgdyZWNvcmRzGAEgAygLMiEuYWdyaWN1bHR1cm'
    'UueWllbGQudjEuWWllbGRSZWNvcmRSB3JlY29yZHMSJgoPbmV4dF9wYWdlX3Rva2VuGAIgASgJ'
    'Ug1uZXh0UGFnZVRva2VuEh8KC3RvdGFsX2NvdW50GAMgASgFUgp0b3RhbENvdW50');

@$core.Deprecated('Use createHarvestPlanRequestDescriptor instead')
const CreateHarvestPlanRequest$json = {
  '1': 'CreateHarvestPlanRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 3, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'season', '3': 4, '4': 1, '5': 9, '10': 'season'},
    {'1': 'year', '3': 5, '4': 1, '5': 5, '10': 'year'},
    {
      '1': 'planned_start_date',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'plannedStartDate'
    },
    {
      '1': 'planned_end_date',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'plannedEndDate'
    },
    {
      '1': 'estimated_yield_kg',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'estimatedYieldKg'
    },
    {
      '1': 'total_area_hectares',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'totalAreaHectares'
    },
    {'1': 'notes', '3': 10, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `CreateHarvestPlanRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createHarvestPlanRequestDescriptor = $convert.base64Decode(
    'ChhDcmVhdGVIYXJ2ZXN0UGxhblJlcXVlc3QSFwoHZmFybV9pZBgBIAEoCVIGZmFybUlkEhkKCG'
    'ZpZWxkX2lkGAIgASgJUgdmaWVsZElkEhcKB2Nyb3BfaWQYAyABKAlSBmNyb3BJZBIWCgZzZWFz'
    'b24YBCABKAlSBnNlYXNvbhISCgR5ZWFyGAUgASgFUgR5ZWFyEkgKEnBsYW5uZWRfc3RhcnRfZG'
    'F0ZRgGIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSEHBsYW5uZWRTdGFydERhdGUS'
    'RAoQcGxhbm5lZF9lbmRfZGF0ZRgHIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSDn'
    'BsYW5uZWRFbmREYXRlEiwKEmVzdGltYXRlZF95aWVsZF9rZxgIIAEoAVIQZXN0aW1hdGVkWWll'
    'bGRLZxIuChN0b3RhbF9hcmVhX2hlY3RhcmVzGAkgASgBUhF0b3RhbEFyZWFIZWN0YXJlcxIUCg'
    'Vub3RlcxgKIAEoCVIFbm90ZXM=');

@$core.Deprecated('Use createHarvestPlanResponseDescriptor instead')
const CreateHarvestPlanResponse$json = {
  '1': 'CreateHarvestPlanResponse',
  '2': [
    {
      '1': 'plan',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.yield.v1.HarvestPlan',
      '10': 'plan'
    },
  ],
};

/// Descriptor for `CreateHarvestPlanResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createHarvestPlanResponseDescriptor =
    $convert.base64Decode(
        'ChlDcmVhdGVIYXJ2ZXN0UGxhblJlc3BvbnNlEjUKBHBsYW4YASABKAsyIS5hZ3JpY3VsdHVyZS'
        '55aWVsZC52MS5IYXJ2ZXN0UGxhblIEcGxhbg==');

@$core.Deprecated('Use getHarvestPlanRequestDescriptor instead')
const GetHarvestPlanRequest$json = {
  '1': 'GetHarvestPlanRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetHarvestPlanRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHarvestPlanRequestDescriptor = $convert
    .base64Decode('ChVHZXRIYXJ2ZXN0UGxhblJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use getHarvestPlanResponseDescriptor instead')
const GetHarvestPlanResponse$json = {
  '1': 'GetHarvestPlanResponse',
  '2': [
    {
      '1': 'plan',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.yield.v1.HarvestPlan',
      '10': 'plan'
    },
  ],
};

/// Descriptor for `GetHarvestPlanResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHarvestPlanResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRIYXJ2ZXN0UGxhblJlc3BvbnNlEjUKBHBsYW4YASABKAsyIS5hZ3JpY3VsdHVyZS55aW'
        'VsZC52MS5IYXJ2ZXN0UGxhblIEcGxhbg==');

@$core.Deprecated('Use listHarvestPlansRequestDescriptor instead')
const ListHarvestPlansRequest$json = {
  '1': 'ListHarvestPlansRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 5, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'season', '3': 6, '4': 1, '5': 9, '10': 'season'},
    {'1': 'year', '3': 7, '4': 1, '5': 5, '10': 'year'},
    {
      '1': 'status',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.agriculture.yield.v1.HarvestPlanStatus',
      '10': 'status'
    },
    {'1': 'order_by', '3': 9, '4': 1, '5': 9, '10': 'orderBy'},
  ],
};

/// Descriptor for `ListHarvestPlansRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listHarvestPlansRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0SGFydmVzdFBsYW5zUmVxdWVzdBIbCglwYWdlX3NpemUYASABKAVSCHBhZ2VTaXplEh'
    '0KCnBhZ2VfdG9rZW4YAiABKAlSCXBhZ2VUb2tlbhIXCgdmYXJtX2lkGAMgASgJUgZmYXJtSWQS'
    'GQoIZmllbGRfaWQYBCABKAlSB2ZpZWxkSWQSFwoHY3JvcF9pZBgFIAEoCVIGY3JvcElkEhYKBn'
    'NlYXNvbhgGIAEoCVIGc2Vhc29uEhIKBHllYXIYByABKAVSBHllYXISPwoGc3RhdHVzGAggASgO'
    'MicuYWdyaWN1bHR1cmUueWllbGQudjEuSGFydmVzdFBsYW5TdGF0dXNSBnN0YXR1cxIZCghvcm'
    'Rlcl9ieRgJIAEoCVIHb3JkZXJCeQ==');

@$core.Deprecated('Use listHarvestPlansResponseDescriptor instead')
const ListHarvestPlansResponse$json = {
  '1': 'ListHarvestPlansResponse',
  '2': [
    {
      '1': 'plans',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.yield.v1.HarvestPlan',
      '10': 'plans'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListHarvestPlansResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listHarvestPlansResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0SGFydmVzdFBsYW5zUmVzcG9uc2USNwoFcGxhbnMYASADKAsyIS5hZ3JpY3VsdHVyZS'
    '55aWVsZC52MS5IYXJ2ZXN0UGxhblIFcGxhbnMSJgoPbmV4dF9wYWdlX3Rva2VuGAIgASgJUg1u'
    'ZXh0UGFnZVRva2VuEh8KC3RvdGFsX2NvdW50GAMgASgFUgp0b3RhbENvdW50');

@$core.Deprecated('Use getCropPerformanceRequestDescriptor instead')
const GetCropPerformanceRequest$json = {
  '1': 'GetCropPerformanceRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 3, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'season', '3': 4, '4': 1, '5': 9, '10': 'season'},
    {'1': 'year', '3': 5, '4': 1, '5': 5, '10': 'year'},
  ],
};

/// Descriptor for `GetCropPerformanceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCropPerformanceRequestDescriptor = $convert.base64Decode(
    'ChlHZXRDcm9wUGVyZm9ybWFuY2VSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZBIZCg'
    'hmaWVsZF9pZBgCIAEoCVIHZmllbGRJZBIXCgdjcm9wX2lkGAMgASgJUgZjcm9wSWQSFgoGc2Vh'
    'c29uGAQgASgJUgZzZWFzb24SEgoEeWVhchgFIAEoBVIEeWVhcg==');

@$core.Deprecated('Use getCropPerformanceResponseDescriptor instead')
const GetCropPerformanceResponse$json = {
  '1': 'GetCropPerformanceResponse',
  '2': [
    {
      '1': 'performance',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.yield.v1.CropPerformance',
      '10': 'performance'
    },
  ],
};

/// Descriptor for `GetCropPerformanceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCropPerformanceResponseDescriptor =
    $convert.base64Decode(
        'ChpHZXRDcm9wUGVyZm9ybWFuY2VSZXNwb25zZRJHCgtwZXJmb3JtYW5jZRgBIAEoCzIlLmFncm'
        'ljdWx0dXJlLnlpZWxkLnYxLkNyb3BQZXJmb3JtYW5jZVILcGVyZm9ybWFuY2U=');

@$core.Deprecated('Use compareYieldsRequestDescriptor instead')
const CompareYieldsRequest$json = {
  '1': 'CompareYieldsRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 3, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'year_a', '3': 4, '4': 1, '5': 5, '10': 'yearA'},
    {'1': 'season_a', '3': 5, '4': 1, '5': 9, '10': 'seasonA'},
    {'1': 'year_b', '3': 6, '4': 1, '5': 5, '10': 'yearB'},
    {'1': 'season_b', '3': 7, '4': 1, '5': 9, '10': 'seasonB'},
  ],
};

/// Descriptor for `CompareYieldsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List compareYieldsRequestDescriptor = $convert.base64Decode(
    'ChRDb21wYXJlWWllbGRzUmVxdWVzdBIXCgdmYXJtX2lkGAEgASgJUgZmYXJtSWQSGQoIZmllbG'
    'RfaWQYAiABKAlSB2ZpZWxkSWQSFwoHY3JvcF9pZBgDIAEoCVIGY3JvcElkEhUKBnllYXJfYRgE'
    'IAEoBVIFeWVhckESGQoIc2Vhc29uX2EYBSABKAlSB3NlYXNvbkESFQoGeWVhcl9iGAYgASgFUg'
    'V5ZWFyQhIZCghzZWFzb25fYhgHIAEoCVIHc2Vhc29uQg==');

@$core.Deprecated('Use compareYieldsResponseDescriptor instead')
const CompareYieldsResponse$json = {
  '1': 'CompareYieldsResponse',
  '2': [
    {
      '1': 'performance_a',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.yield.v1.CropPerformance',
      '10': 'performanceA'
    },
    {
      '1': 'performance_b',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.agriculture.yield.v1.CropPerformance',
      '10': 'performanceB'
    },
    {
      '1': 'yield_difference_kg_per_hectare',
      '3': 3,
      '4': 1,
      '5': 1,
      '10': 'yieldDifferenceKgPerHectare'
    },
    {
      '1': 'yield_difference_pct',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'yieldDifferencePct'
    },
    {
      '1': 'profit_difference_per_hectare',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'profitDifferencePerHectare'
    },
  ],
};

/// Descriptor for `CompareYieldsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List compareYieldsResponseDescriptor = $convert.base64Decode(
    'ChVDb21wYXJlWWllbGRzUmVzcG9uc2USSgoNcGVyZm9ybWFuY2VfYRgBIAEoCzIlLmFncmljdW'
    'x0dXJlLnlpZWxkLnYxLkNyb3BQZXJmb3JtYW5jZVIMcGVyZm9ybWFuY2VBEkoKDXBlcmZvcm1h'
    'bmNlX2IYAiABKAsyJS5hZ3JpY3VsdHVyZS55aWVsZC52MS5Dcm9wUGVyZm9ybWFuY2VSDHBlcm'
    'Zvcm1hbmNlQhJECh95aWVsZF9kaWZmZXJlbmNlX2tnX3Blcl9oZWN0YXJlGAMgASgBUht5aWVs'
    'ZERpZmZlcmVuY2VLZ1BlckhlY3RhcmUSMAoUeWllbGRfZGlmZmVyZW5jZV9wY3QYBCABKAFSEn'
    'lpZWxkRGlmZmVyZW5jZVBjdBJBCh1wcm9maXRfZGlmZmVyZW5jZV9wZXJfaGVjdGFyZRgFIAEo'
    'AVIacHJvZml0RGlmZmVyZW5jZVBlckhlY3RhcmU=');

const $core.Map<$core.String, $core.dynamic> YieldServiceBase$json = {
  '1': 'YieldService',
  '2': [
    {
      '1': 'PredictYield',
      '2': '.agriculture.yield.v1.PredictYieldRequest',
      '3': '.agriculture.yield.v1.PredictYieldResponse'
    },
    {
      '1': 'GetPrediction',
      '2': '.agriculture.yield.v1.GetPredictionRequest',
      '3': '.agriculture.yield.v1.GetPredictionResponse'
    },
    {
      '1': 'ListPredictions',
      '2': '.agriculture.yield.v1.ListPredictionsRequest',
      '3': '.agriculture.yield.v1.ListPredictionsResponse'
    },
    {
      '1': 'RecordYield',
      '2': '.agriculture.yield.v1.RecordYieldRequest',
      '3': '.agriculture.yield.v1.RecordYieldResponse'
    },
    {
      '1': 'GetYieldHistory',
      '2': '.agriculture.yield.v1.GetYieldHistoryRequest',
      '3': '.agriculture.yield.v1.GetYieldHistoryResponse'
    },
    {
      '1': 'CreateHarvestPlan',
      '2': '.agriculture.yield.v1.CreateHarvestPlanRequest',
      '3': '.agriculture.yield.v1.CreateHarvestPlanResponse'
    },
    {
      '1': 'GetHarvestPlan',
      '2': '.agriculture.yield.v1.GetHarvestPlanRequest',
      '3': '.agriculture.yield.v1.GetHarvestPlanResponse'
    },
    {
      '1': 'ListHarvestPlans',
      '2': '.agriculture.yield.v1.ListHarvestPlansRequest',
      '3': '.agriculture.yield.v1.ListHarvestPlansResponse'
    },
    {
      '1': 'GetCropPerformance',
      '2': '.agriculture.yield.v1.GetCropPerformanceRequest',
      '3': '.agriculture.yield.v1.GetCropPerformanceResponse'
    },
    {
      '1': 'CompareYields',
      '2': '.agriculture.yield.v1.CompareYieldsRequest',
      '3': '.agriculture.yield.v1.CompareYieldsResponse'
    },
  ],
};

@$core.Deprecated('Use yieldServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    YieldServiceBase$messageJson = {
  '.agriculture.yield.v1.PredictYieldRequest': PredictYieldRequest$json,
  '.agriculture.yield.v1.YieldFactors': YieldFactors$json,
  '.agriculture.yield.v1.PredictYieldResponse': PredictYieldResponse$json,
  '.agriculture.yield.v1.YieldPrediction': YieldPrediction$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.yield.v1.GetPredictionRequest': GetPredictionRequest$json,
  '.agriculture.yield.v1.GetPredictionResponse': GetPredictionResponse$json,
  '.agriculture.yield.v1.ListPredictionsRequest': ListPredictionsRequest$json,
  '.agriculture.yield.v1.ListPredictionsResponse': ListPredictionsResponse$json,
  '.agriculture.yield.v1.RecordYieldRequest': RecordYieldRequest$json,
  '.agriculture.yield.v1.RecordYieldResponse': RecordYieldResponse$json,
  '.agriculture.yield.v1.YieldRecord': YieldRecord$json,
  '.agriculture.yield.v1.GetYieldHistoryRequest': GetYieldHistoryRequest$json,
  '.agriculture.yield.v1.GetYieldHistoryResponse': GetYieldHistoryResponse$json,
  '.agriculture.yield.v1.CreateHarvestPlanRequest':
      CreateHarvestPlanRequest$json,
  '.agriculture.yield.v1.CreateHarvestPlanResponse':
      CreateHarvestPlanResponse$json,
  '.agriculture.yield.v1.HarvestPlan': HarvestPlan$json,
  '.agriculture.yield.v1.GetHarvestPlanRequest': GetHarvestPlanRequest$json,
  '.agriculture.yield.v1.GetHarvestPlanResponse': GetHarvestPlanResponse$json,
  '.agriculture.yield.v1.ListHarvestPlansRequest': ListHarvestPlansRequest$json,
  '.agriculture.yield.v1.ListHarvestPlansResponse':
      ListHarvestPlansResponse$json,
  '.agriculture.yield.v1.GetCropPerformanceRequest':
      GetCropPerformanceRequest$json,
  '.agriculture.yield.v1.GetCropPerformanceResponse':
      GetCropPerformanceResponse$json,
  '.agriculture.yield.v1.CropPerformance': CropPerformance$json,
  '.agriculture.yield.v1.CompareYieldsRequest': CompareYieldsRequest$json,
  '.agriculture.yield.v1.CompareYieldsResponse': CompareYieldsResponse$json,
};

/// Descriptor for `YieldService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List yieldServiceDescriptor = $convert.base64Decode(
    'CgxZaWVsZFNlcnZpY2USZQoMUHJlZGljdFlpZWxkEikuYWdyaWN1bHR1cmUueWllbGQudjEuUH'
    'JlZGljdFlpZWxkUmVxdWVzdBoqLmFncmljdWx0dXJlLnlpZWxkLnYxLlByZWRpY3RZaWVsZFJl'
    'c3BvbnNlEmgKDUdldFByZWRpY3Rpb24SKi5hZ3JpY3VsdHVyZS55aWVsZC52MS5HZXRQcmVkaW'
    'N0aW9uUmVxdWVzdBorLmFncmljdWx0dXJlLnlpZWxkLnYxLkdldFByZWRpY3Rpb25SZXNwb25z'
    'ZRJuCg9MaXN0UHJlZGljdGlvbnMSLC5hZ3JpY3VsdHVyZS55aWVsZC52MS5MaXN0UHJlZGljdG'
    'lvbnNSZXF1ZXN0Gi0uYWdyaWN1bHR1cmUueWllbGQudjEuTGlzdFByZWRpY3Rpb25zUmVzcG9u'
    'c2USYgoLUmVjb3JkWWllbGQSKC5hZ3JpY3VsdHVyZS55aWVsZC52MS5SZWNvcmRZaWVsZFJlcX'
    'Vlc3QaKS5hZ3JpY3VsdHVyZS55aWVsZC52MS5SZWNvcmRZaWVsZFJlc3BvbnNlEm4KD0dldFlp'
    'ZWxkSGlzdG9yeRIsLmFncmljdWx0dXJlLnlpZWxkLnYxLkdldFlpZWxkSGlzdG9yeVJlcXVlc3'
    'QaLS5hZ3JpY3VsdHVyZS55aWVsZC52MS5HZXRZaWVsZEhpc3RvcnlSZXNwb25zZRJ0ChFDcmVh'
    'dGVIYXJ2ZXN0UGxhbhIuLmFncmljdWx0dXJlLnlpZWxkLnYxLkNyZWF0ZUhhcnZlc3RQbGFuUm'
    'VxdWVzdBovLmFncmljdWx0dXJlLnlpZWxkLnYxLkNyZWF0ZUhhcnZlc3RQbGFuUmVzcG9uc2US'
    'awoOR2V0SGFydmVzdFBsYW4SKy5hZ3JpY3VsdHVyZS55aWVsZC52MS5HZXRIYXJ2ZXN0UGxhbl'
    'JlcXVlc3QaLC5hZ3JpY3VsdHVyZS55aWVsZC52MS5HZXRIYXJ2ZXN0UGxhblJlc3BvbnNlEnEK'
    'EExpc3RIYXJ2ZXN0UGxhbnMSLS5hZ3JpY3VsdHVyZS55aWVsZC52MS5MaXN0SGFydmVzdFBsYW'
    '5zUmVxdWVzdBouLmFncmljdWx0dXJlLnlpZWxkLnYxLkxpc3RIYXJ2ZXN0UGxhbnNSZXNwb25z'
    'ZRJ3ChJHZXRDcm9wUGVyZm9ybWFuY2USLy5hZ3JpY3VsdHVyZS55aWVsZC52MS5HZXRDcm9wUG'
    'VyZm9ybWFuY2VSZXF1ZXN0GjAuYWdyaWN1bHR1cmUueWllbGQudjEuR2V0Q3JvcFBlcmZvcm1h'
    'bmNlUmVzcG9uc2USaAoNQ29tcGFyZVlpZWxkcxIqLmFncmljdWx0dXJlLnlpZWxkLnYxLkNvbX'
    'BhcmVZaWVsZHNSZXF1ZXN0GisuYWdyaWN1bHR1cmUueWllbGQudjEuQ29tcGFyZVlpZWxkc1Jl'
    'c3BvbnNl');
