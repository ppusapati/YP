// This is a generated file - do not edit.
//
// Generated from planning.proto.

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

@$core.Deprecated('Use seasonDescriptor instead')
const Season$json = {
  '1': 'Season',
  '2': [
    {'1': 'SEASON_UNSPECIFIED', '2': 0},
    {'1': 'SEASON_KHARIF', '2': 1},
    {'1': 'SEASON_RABI', '2': 2},
    {'1': 'SEASON_ZAID', '2': 3},
  ],
};

/// Descriptor for `Season`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List seasonDescriptor = $convert.base64Decode(
    'CgZTZWFzb24SFgoSU0VBU09OX1VOU1BFQ0lGSUVEEAASEQoNU0VBU09OX0tIQVJJRhABEg8KC1'
    'NFQVNPTl9SQUJJEAISDwoLU0VBU09OX1pBSUQQAw==');

@$core.Deprecated('Use planStatusDescriptor instead')
const PlanStatus$json = {
  '1': 'PlanStatus',
  '2': [
    {'1': 'PLAN_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'PLAN_STATUS_DRAFT', '2': 1},
    {'1': 'PLAN_STATUS_COMMITTED', '2': 2},
    {'1': 'PLAN_STATUS_COMPLETED', '2': 3},
    {'1': 'PLAN_STATUS_ABANDONED', '2': 4},
  ],
};

/// Descriptor for `PlanStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List planStatusDescriptor = $convert.base64Decode(
    'CgpQbGFuU3RhdHVzEhsKF1BMQU5fU1RBVFVTX1VOU1BFQ0lGSUVEEAASFQoRUExBTl9TVEFUVV'
    'NfRFJBRlQQARIZChVQTEFOX1NUQVRVU19DT01NSVRURUQQAhIZChVQTEFOX1NUQVRVU19DT01Q'
    'TEVURUQQAxIZChVQTEFOX1NUQVRVU19BQkFORE9ORUQQBA==');

@$core.Deprecated('Use rotationVerdictDescriptor instead')
const RotationVerdict$json = {
  '1': 'RotationVerdict',
  '2': [
    {'1': 'ROTATION_VERDICT_UNSPECIFIED', '2': 0},
    {'1': 'ROTATION_VERDICT_GOOD', '2': 1},
    {'1': 'ROTATION_VERDICT_ACCEPTABLE', '2': 2},
    {'1': 'ROTATION_VERDICT_POOR', '2': 3},
  ],
};

/// Descriptor for `RotationVerdict`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List rotationVerdictDescriptor = $convert.base64Decode(
    'Cg9Sb3RhdGlvblZlcmRpY3QSIAocUk9UQVRJT05fVkVSRElDVF9VTlNQRUNJRklFRBAAEhkKFV'
    'JPVEFUSU9OX1ZFUkRJQ1RfR09PRBABEh8KG1JPVEFUSU9OX1ZFUkRJQ1RfQUNDRVBUQUJMRRAC'
    'EhkKFVJPVEFUSU9OX1ZFUkRJQ1RfUE9PUhAD');

@$core.Deprecated('Use inputKindDescriptor instead')
const InputKind$json = {
  '1': 'InputKind',
  '2': [
    {'1': 'INPUT_KIND_UNSPECIFIED', '2': 0},
    {'1': 'INPUT_KIND_SEED', '2': 1},
    {'1': 'INPUT_KIND_FERTILISER', '2': 2},
    {'1': 'INPUT_KIND_PESTICIDE', '2': 3},
    {'1': 'INPUT_KIND_LABOUR', '2': 4},
    {'1': 'INPUT_KIND_MACHINERY', '2': 5},
    {'1': 'INPUT_KIND_IRRIGATION', '2': 6},
  ],
};

/// Descriptor for `InputKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List inputKindDescriptor = $convert.base64Decode(
    'CglJbnB1dEtpbmQSGgoWSU5QVVRfS0lORF9VTlNQRUNJRklFRBAAEhMKD0lOUFVUX0tJTkRfU0'
    'VFRBABEhkKFUlOUFVUX0tJTkRfRkVSVElMSVNFUhACEhgKFElOUFVUX0tJTkRfUEVTVElDSURF'
    'EAMSFQoRSU5QVVRfS0lORF9MQUJPVVIQBBIYChRJTlBVVF9LSU5EX01BQ0hJTkVSWRAFEhkKFU'
    'lOUFVUX0tJTkRfSVJSSUdBVElPThAG');

@$core.Deprecated('Use sowingWindowDescriptor instead')
const SowingWindow$json = {
  '1': 'SowingWindow',
  '2': [
    {'1': 'crop', '3': 1, '4': 1, '5': 9, '10': 'crop'},
    {
      '1': 'season',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.planning.v1.Season',
      '10': 'season'
    },
    {
      '1': 'opens',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'opens'
    },
    {
      '1': 'closes',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'closes'
    },
    {
      '1': 'optimal',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'optimal'
    },
    {'1': 'basis', '3': 6, '4': 1, '5': 9, '10': 'basis'},
    {'1': 'weather_informed', '3': 7, '4': 1, '5': 8, '10': 'weatherInformed'},
  ],
};

/// Descriptor for `SowingWindow`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sowingWindowDescriptor = $convert.base64Decode(
    'CgxTb3dpbmdXaW5kb3cSEgoEY3JvcBgBIAEoCVIEY3JvcBI3CgZzZWFzb24YAiABKA4yHy5hZ3'
    'JpY3VsdHVyZS5wbGFubmluZy52MS5TZWFzb25SBnNlYXNvbhIwCgVvcGVucxgDIAEoCzIaLmdv'
    'b2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSBW9wZW5zEjIKBmNsb3NlcxgEIAEoCzIaLmdvb2dsZS'
    '5wcm90b2J1Zi5UaW1lc3RhbXBSBmNsb3NlcxI0CgdvcHRpbWFsGAUgASgLMhouZ29vZ2xlLnBy'
    'b3RvYnVmLlRpbWVzdGFtcFIHb3B0aW1hbBIUCgViYXNpcxgGIAEoCVIFYmFzaXMSKQoQd2VhdG'
    'hlcl9pbmZvcm1lZBgHIAEoCFIPd2VhdGhlckluZm9ybWVk');

@$core.Deprecated('Use inputLineDescriptor instead')
const InputLine$json = {
  '1': 'InputLine',
  '2': [
    {
      '1': 'kind',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.agriculture.planning.v1.InputKind',
      '10': 'kind'
    },
    {'1': 'item', '3': 2, '4': 1, '5': 9, '10': 'item'},
    {'1': 'quantity', '3': 3, '4': 1, '5': 1, '10': 'quantity'},
    {'1': 'unit', '3': 4, '4': 1, '5': 9, '10': 'unit'},
    {'1': 'unit_cost', '3': 5, '4': 1, '5': 1, '10': 'unitCost'},
    {'1': 'total_cost', '3': 6, '4': 1, '5': 1, '10': 'totalCost'},
    {'1': 'note', '3': 7, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `InputLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inputLineDescriptor = $convert.base64Decode(
    'CglJbnB1dExpbmUSNgoEa2luZBgBIAEoDjIiLmFncmljdWx0dXJlLnBsYW5uaW5nLnYxLklucH'
    'V0S2luZFIEa2luZBISCgRpdGVtGAIgASgJUgRpdGVtEhoKCHF1YW50aXR5GAMgASgBUghxdWFu'
    'dGl0eRISCgR1bml0GAQgASgJUgR1bml0EhsKCXVuaXRfY29zdBgFIAEoAVIIdW5pdENvc3QSHQ'
    'oKdG90YWxfY29zdBgGIAEoAVIJdG90YWxDb3N0EhIKBG5vdGUYByABKAlSBG5vdGU=');

@$core.Deprecated('Use inputBudgetDescriptor instead')
const InputBudget$json = {
  '1': 'InputBudget',
  '2': [
    {
      '1': 'lines',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.planning.v1.InputLine',
      '10': 'lines'
    },
    {'1': 'total_cost', '3': 2, '4': 1, '5': 1, '10': 'totalCost'},
    {'1': 'cost_per_hectare', '3': 3, '4': 1, '5': 1, '10': 'costPerHectare'},
    {'1': 'currency', '3': 4, '4': 1, '5': 9, '10': 'currency'},
  ],
};

/// Descriptor for `InputBudget`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inputBudgetDescriptor = $convert.base64Decode(
    'CgtJbnB1dEJ1ZGdldBI4CgVsaW5lcxgBIAMoCzIiLmFncmljdWx0dXJlLnBsYW5uaW5nLnYxLk'
    'lucHV0TGluZVIFbGluZXMSHQoKdG90YWxfY29zdBgCIAEoAVIJdG90YWxDb3N0EigKEGNvc3Rf'
    'cGVyX2hlY3RhcmUYAyABKAFSDmNvc3RQZXJIZWN0YXJlEhoKCGN1cnJlbmN5GAQgASgJUghjdX'
    'JyZW5jeQ==');

@$core.Deprecated('Use rotationCheckDescriptor instead')
const RotationCheck$json = {
  '1': 'RotationCheck',
  '2': [
    {'1': 'crop', '3': 1, '4': 1, '5': 9, '10': 'crop'},
    {'1': 'previous_crop', '3': 2, '4': 1, '5': 9, '10': 'previousCrop'},
    {
      '1': 'verdict',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.planning.v1.RotationVerdict',
      '10': 'verdict'
    },
    {'1': 'rationale', '3': 4, '4': 1, '5': 9, '10': 'rationale'},
    {
      '1': 'nitrogen_credit_kg_ha',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'nitrogenCreditKgHa'
    },
  ],
};

/// Descriptor for `RotationCheck`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rotationCheckDescriptor = $convert.base64Decode(
    'Cg1Sb3RhdGlvbkNoZWNrEhIKBGNyb3AYASABKAlSBGNyb3ASIwoNcHJldmlvdXNfY3JvcBgCIA'
    'EoCVIMcHJldmlvdXNDcm9wEkIKB3ZlcmRpY3QYAyABKA4yKC5hZ3JpY3VsdHVyZS5wbGFubmlu'
    'Zy52MS5Sb3RhdGlvblZlcmRpY3RSB3ZlcmRpY3QSHAoJcmF0aW9uYWxlGAQgASgJUglyYXRpb2'
    '5hbGUSMQoVbml0cm9nZW5fY3JlZGl0X2tnX2hhGAUgASgBUhJuaXRyb2dlbkNyZWRpdEtnSGE=');

@$core.Deprecated('Use seasonPlanDescriptor instead')
const SeasonPlan$json = {
  '1': 'SeasonPlan',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'season',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.planning.v1.Season',
      '10': 'season'
    },
    {'1': 'year', '3': 5, '4': 1, '5': 5, '10': 'year'},
    {'1': 'crop', '3': 6, '4': 1, '5': 9, '10': 'crop'},
    {'1': 'variety', '3': 7, '4': 1, '5': 9, '10': 'variety'},
    {'1': 'area_hectares', '3': 8, '4': 1, '5': 1, '10': 'areaHectares'},
    {
      '1': 'status',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.agriculture.planning.v1.PlanStatus',
      '10': 'status'
    },
    {
      '1': 'sowing_window',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.agriculture.planning.v1.SowingWindow',
      '10': 'sowingWindow'
    },
    {
      '1': 'rotation_check',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.agriculture.planning.v1.RotationCheck',
      '10': 'rotationCheck'
    },
    {
      '1': 'budget',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.agriculture.planning.v1.InputBudget',
      '10': 'budget'
    },
    {
      '1': 'target_yield_tonnes_ha',
      '3': 13,
      '4': 1,
      '5': 1,
      '10': 'targetYieldTonnesHa'
    },
    {'1': 'notes', '3': 14, '4': 1, '5': 9, '10': 'notes'},
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
    {'1': 'version', '3': 17, '4': 1, '5': 3, '10': 'version'},
  ],
};

/// Descriptor for `SeasonPlan`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List seasonPlanDescriptor = $convert.base64Decode(
    'CgpTZWFzb25QbGFuEg4KAmlkGAEgASgJUgJpZBIZCghmaWVsZF9pZBgCIAEoCVIHZmllbGRJZB'
    'IXCgdmYXJtX2lkGAMgASgJUgZmYXJtSWQSNwoGc2Vhc29uGAQgASgOMh8uYWdyaWN1bHR1cmUu'
    'cGxhbm5pbmcudjEuU2Vhc29uUgZzZWFzb24SEgoEeWVhchgFIAEoBVIEeWVhchISCgRjcm9wGA'
    'YgASgJUgRjcm9wEhgKB3ZhcmlldHkYByABKAlSB3ZhcmlldHkSIwoNYXJlYV9oZWN0YXJlcxgI'
    'IAEoAVIMYXJlYUhlY3RhcmVzEjsKBnN0YXR1cxgJIAEoDjIjLmFncmljdWx0dXJlLnBsYW5uaW'
    '5nLnYxLlBsYW5TdGF0dXNSBnN0YXR1cxJKCg1zb3dpbmdfd2luZG93GAogASgLMiUuYWdyaWN1'
    'bHR1cmUucGxhbm5pbmcudjEuU293aW5nV2luZG93Ugxzb3dpbmdXaW5kb3cSTQoOcm90YXRpb2'
    '5fY2hlY2sYCyABKAsyJi5hZ3JpY3VsdHVyZS5wbGFubmluZy52MS5Sb3RhdGlvbkNoZWNrUg1y'
    'b3RhdGlvbkNoZWNrEjwKBmJ1ZGdldBgMIAEoCzIkLmFncmljdWx0dXJlLnBsYW5uaW5nLnYxLk'
    'lucHV0QnVkZ2V0UgZidWRnZXQSMwoWdGFyZ2V0X3lpZWxkX3Rvbm5lc19oYRgNIAEoAVITdGFy'
    'Z2V0WWllbGRUb25uZXNIYRIUCgVub3RlcxgOIAEoCVIFbm90ZXMSOQoKY3JlYXRlZF9hdBgPIA'
    'EoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0'
    'GBAgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZEF0EhgKB3ZlcnNpb2'
    '4YESABKANSB3ZlcnNpb24=');

@$core.Deprecated('Use createPlanRequestDescriptor instead')
const CreatePlanRequest$json = {
  '1': 'CreatePlanRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'season',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.planning.v1.Season',
      '10': 'season'
    },
    {'1': 'year', '3': 4, '4': 1, '5': 5, '10': 'year'},
    {'1': 'crop', '3': 5, '4': 1, '5': 9, '10': 'crop'},
    {'1': 'variety', '3': 6, '4': 1, '5': 9, '10': 'variety'},
    {'1': 'area_hectares', '3': 7, '4': 1, '5': 1, '10': 'areaHectares'},
    {
      '1': 'target_yield_tonnes_ha',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'targetYieldTonnesHa'
    },
    {'1': 'notes', '3': 9, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `CreatePlanRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createPlanRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVQbGFuUmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBIXCgdmYXJtX2'
    'lkGAIgASgJUgZmYXJtSWQSNwoGc2Vhc29uGAMgASgOMh8uYWdyaWN1bHR1cmUucGxhbm5pbmcu'
    'djEuU2Vhc29uUgZzZWFzb24SEgoEeWVhchgEIAEoBVIEeWVhchISCgRjcm9wGAUgASgJUgRjcm'
    '9wEhgKB3ZhcmlldHkYBiABKAlSB3ZhcmlldHkSIwoNYXJlYV9oZWN0YXJlcxgHIAEoAVIMYXJl'
    'YUhlY3RhcmVzEjMKFnRhcmdldF95aWVsZF90b25uZXNfaGEYCCABKAFSE3RhcmdldFlpZWxkVG'
    '9ubmVzSGESFAoFbm90ZXMYCSABKAlSBW5vdGVz');

@$core.Deprecated('Use createPlanResponseDescriptor instead')
const CreatePlanResponse$json = {
  '1': 'CreatePlanResponse',
  '2': [
    {
      '1': 'plan',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.planning.v1.SeasonPlan',
      '10': 'plan'
    },
  ],
};

/// Descriptor for `CreatePlanResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createPlanResponseDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVQbGFuUmVzcG9uc2USNwoEcGxhbhgBIAEoCzIjLmFncmljdWx0dXJlLnBsYW5uaW'
    '5nLnYxLlNlYXNvblBsYW5SBHBsYW4=');

@$core.Deprecated('Use getPlanRequestDescriptor instead')
const GetPlanRequest$json = {
  '1': 'GetPlanRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetPlanRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPlanRequestDescriptor =
    $convert.base64Decode('Cg5HZXRQbGFuUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use getPlanResponseDescriptor instead')
const GetPlanResponse$json = {
  '1': 'GetPlanResponse',
  '2': [
    {
      '1': 'plan',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.planning.v1.SeasonPlan',
      '10': 'plan'
    },
  ],
};

/// Descriptor for `GetPlanResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPlanResponseDescriptor = $convert.base64Decode(
    'Cg9HZXRQbGFuUmVzcG9uc2USNwoEcGxhbhgBIAEoCzIjLmFncmljdWx0dXJlLnBsYW5uaW5nLn'
    'YxLlNlYXNvblBsYW5SBHBsYW4=');

@$core.Deprecated('Use listPlansRequestDescriptor instead')
const ListPlansRequest$json = {
  '1': 'ListPlansRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'season',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.planning.v1.Season',
      '10': 'season'
    },
    {'1': 'year', '3': 4, '4': 1, '5': 5, '10': 'year'},
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.planning.v1.PlanStatus',
      '10': 'status'
    },
    {'1': 'page_size', '3': 6, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 7, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListPlansRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPlansRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0UGxhbnNSZXF1ZXN0EhkKCGZpZWxkX2lkGAEgASgJUgdmaWVsZElkEhcKB2Zhcm1faW'
    'QYAiABKAlSBmZhcm1JZBI3CgZzZWFzb24YAyABKA4yHy5hZ3JpY3VsdHVyZS5wbGFubmluZy52'
    'MS5TZWFzb25SBnNlYXNvbhISCgR5ZWFyGAQgASgFUgR5ZWFyEjsKBnN0YXR1cxgFIAEoDjIjLm'
    'FncmljdWx0dXJlLnBsYW5uaW5nLnYxLlBsYW5TdGF0dXNSBnN0YXR1cxIbCglwYWdlX3NpemUY'
    'BiABKAVSCHBhZ2VTaXplEh0KCnBhZ2VfdG9rZW4YByABKAlSCXBhZ2VUb2tlbg==');

@$core.Deprecated('Use listPlansResponseDescriptor instead')
const ListPlansResponse$json = {
  '1': 'ListPlansResponse',
  '2': [
    {
      '1': 'plans',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.planning.v1.SeasonPlan',
      '10': 'plans'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListPlansResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPlansResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0UGxhbnNSZXNwb25zZRI5CgVwbGFucxgBIAMoCzIjLmFncmljdWx0dXJlLnBsYW5uaW'
    '5nLnYxLlNlYXNvblBsYW5SBXBsYW5zEiYKD25leHRfcGFnZV90b2tlbhgCIAEoCVINbmV4dFBh'
    'Z2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use updatePlanRequestDescriptor instead')
const UpdatePlanRequest$json = {
  '1': 'UpdatePlanRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'crop', '3': 2, '4': 1, '5': 9, '10': 'crop'},
    {'1': 'variety', '3': 3, '4': 1, '5': 9, '10': 'variety'},
    {'1': 'area_hectares', '3': 4, '4': 1, '5': 1, '10': 'areaHectares'},
    {
      '1': 'target_yield_tonnes_ha',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'targetYieldTonnesHa'
    },
    {'1': 'notes', '3': 6, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'base_version', '3': 7, '4': 1, '5': 3, '10': 'baseVersion'},
  ],
};

/// Descriptor for `UpdatePlanRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updatePlanRequestDescriptor = $convert.base64Decode(
    'ChFVcGRhdGVQbGFuUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSEgoEY3JvcBgCIAEoCVIEY3JvcB'
    'IYCgd2YXJpZXR5GAMgASgJUgd2YXJpZXR5EiMKDWFyZWFfaGVjdGFyZXMYBCABKAFSDGFyZWFI'
    'ZWN0YXJlcxIzChZ0YXJnZXRfeWllbGRfdG9ubmVzX2hhGAUgASgBUhN0YXJnZXRZaWVsZFRvbm'
    '5lc0hhEhQKBW5vdGVzGAYgASgJUgVub3RlcxIhCgxiYXNlX3ZlcnNpb24YByABKANSC2Jhc2VW'
    'ZXJzaW9u');

@$core.Deprecated('Use updatePlanResponseDescriptor instead')
const UpdatePlanResponse$json = {
  '1': 'UpdatePlanResponse',
  '2': [
    {
      '1': 'plan',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.planning.v1.SeasonPlan',
      '10': 'plan'
    },
  ],
};

/// Descriptor for `UpdatePlanResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updatePlanResponseDescriptor = $convert.base64Decode(
    'ChJVcGRhdGVQbGFuUmVzcG9uc2USNwoEcGxhbhgBIAEoCzIjLmFncmljdWx0dXJlLnBsYW5uaW'
    '5nLnYxLlNlYXNvblBsYW5SBHBsYW4=');

@$core.Deprecated('Use commitPlanRequestDescriptor instead')
const CommitPlanRequest$json = {
  '1': 'CommitPlanRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `CommitPlanRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commitPlanRequestDescriptor =
    $convert.base64Decode('ChFDb21taXRQbGFuUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use commitPlanResponseDescriptor instead')
const CommitPlanResponse$json = {
  '1': 'CommitPlanResponse',
  '2': [
    {
      '1': 'plan',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.planning.v1.SeasonPlan',
      '10': 'plan'
    },
  ],
};

/// Descriptor for `CommitPlanResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List commitPlanResponseDescriptor = $convert.base64Decode(
    'ChJDb21taXRQbGFuUmVzcG9uc2USNwoEcGxhbhgBIAEoCzIjLmFncmljdWx0dXJlLnBsYW5uaW'
    '5nLnYxLlNlYXNvblBsYW5SBHBsYW4=');

@$core.Deprecated('Use checkRotationRequestDescriptor instead')
const CheckRotationRequest$json = {
  '1': 'CheckRotationRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop', '3': 2, '4': 1, '5': 9, '10': 'crop'},
  ],
};

/// Descriptor for `CheckRotationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkRotationRequestDescriptor = $convert.base64Decode(
    'ChRDaGVja1JvdGF0aW9uUmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBISCgRjcm'
    '9wGAIgASgJUgRjcm9w');

@$core.Deprecated('Use checkRotationResponseDescriptor instead')
const CheckRotationResponse$json = {
  '1': 'CheckRotationResponse',
  '2': [
    {
      '1': 'check',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.planning.v1.RotationCheck',
      '10': 'check'
    },
  ],
};

/// Descriptor for `CheckRotationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkRotationResponseDescriptor = $convert.base64Decode(
    'ChVDaGVja1JvdGF0aW9uUmVzcG9uc2USPAoFY2hlY2sYASABKAsyJi5hZ3JpY3VsdHVyZS5wbG'
    'FubmluZy52MS5Sb3RhdGlvbkNoZWNrUgVjaGVjaw==');

@$core.Deprecated('Use getSowingWindowRequestDescriptor instead')
const GetSowingWindowRequest$json = {
  '1': 'GetSowingWindowRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop', '3': 2, '4': 1, '5': 9, '10': 'crop'},
    {
      '1': 'season',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.planning.v1.Season',
      '10': 'season'
    },
    {'1': 'year', '3': 4, '4': 1, '5': 5, '10': 'year'},
  ],
};

/// Descriptor for `GetSowingWindowRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSowingWindowRequestDescriptor = $convert.base64Decode(
    'ChZHZXRTb3dpbmdXaW5kb3dSZXF1ZXN0EhkKCGZpZWxkX2lkGAEgASgJUgdmaWVsZElkEhIKBG'
    'Nyb3AYAiABKAlSBGNyb3ASNwoGc2Vhc29uGAMgASgOMh8uYWdyaWN1bHR1cmUucGxhbm5pbmcu'
    'djEuU2Vhc29uUgZzZWFzb24SEgoEeWVhchgEIAEoBVIEeWVhcg==');

@$core.Deprecated('Use getSowingWindowResponseDescriptor instead')
const GetSowingWindowResponse$json = {
  '1': 'GetSowingWindowResponse',
  '2': [
    {
      '1': 'window',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.planning.v1.SowingWindow',
      '10': 'window'
    },
  ],
};

/// Descriptor for `GetSowingWindowResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSowingWindowResponseDescriptor =
    $convert.base64Decode(
        'ChdHZXRTb3dpbmdXaW5kb3dSZXNwb25zZRI9CgZ3aW5kb3cYASABKAsyJS5hZ3JpY3VsdHVyZS'
        '5wbGFubmluZy52MS5Tb3dpbmdXaW5kb3dSBndpbmRvdw==');

const $core.Map<$core.String, $core.dynamic> PlanningServiceBase$json = {
  '1': 'PlanningService',
  '2': [
    {
      '1': 'CreatePlan',
      '2': '.agriculture.planning.v1.CreatePlanRequest',
      '3': '.agriculture.planning.v1.CreatePlanResponse'
    },
    {
      '1': 'GetPlan',
      '2': '.agriculture.planning.v1.GetPlanRequest',
      '3': '.agriculture.planning.v1.GetPlanResponse'
    },
    {
      '1': 'ListPlans',
      '2': '.agriculture.planning.v1.ListPlansRequest',
      '3': '.agriculture.planning.v1.ListPlansResponse'
    },
    {
      '1': 'UpdatePlan',
      '2': '.agriculture.planning.v1.UpdatePlanRequest',
      '3': '.agriculture.planning.v1.UpdatePlanResponse'
    },
    {
      '1': 'CommitPlan',
      '2': '.agriculture.planning.v1.CommitPlanRequest',
      '3': '.agriculture.planning.v1.CommitPlanResponse'
    },
    {
      '1': 'CheckRotation',
      '2': '.agriculture.planning.v1.CheckRotationRequest',
      '3': '.agriculture.planning.v1.CheckRotationResponse'
    },
    {
      '1': 'GetSowingWindow',
      '2': '.agriculture.planning.v1.GetSowingWindowRequest',
      '3': '.agriculture.planning.v1.GetSowingWindowResponse'
    },
  ],
};

@$core.Deprecated('Use planningServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    PlanningServiceBase$messageJson = {
  '.agriculture.planning.v1.CreatePlanRequest': CreatePlanRequest$json,
  '.agriculture.planning.v1.CreatePlanResponse': CreatePlanResponse$json,
  '.agriculture.planning.v1.SeasonPlan': SeasonPlan$json,
  '.agriculture.planning.v1.SowingWindow': SowingWindow$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.planning.v1.RotationCheck': RotationCheck$json,
  '.agriculture.planning.v1.InputBudget': InputBudget$json,
  '.agriculture.planning.v1.InputLine': InputLine$json,
  '.agriculture.planning.v1.GetPlanRequest': GetPlanRequest$json,
  '.agriculture.planning.v1.GetPlanResponse': GetPlanResponse$json,
  '.agriculture.planning.v1.ListPlansRequest': ListPlansRequest$json,
  '.agriculture.planning.v1.ListPlansResponse': ListPlansResponse$json,
  '.agriculture.planning.v1.UpdatePlanRequest': UpdatePlanRequest$json,
  '.agriculture.planning.v1.UpdatePlanResponse': UpdatePlanResponse$json,
  '.agriculture.planning.v1.CommitPlanRequest': CommitPlanRequest$json,
  '.agriculture.planning.v1.CommitPlanResponse': CommitPlanResponse$json,
  '.agriculture.planning.v1.CheckRotationRequest': CheckRotationRequest$json,
  '.agriculture.planning.v1.CheckRotationResponse': CheckRotationResponse$json,
  '.agriculture.planning.v1.GetSowingWindowRequest':
      GetSowingWindowRequest$json,
  '.agriculture.planning.v1.GetSowingWindowResponse':
      GetSowingWindowResponse$json,
};

/// Descriptor for `PlanningService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List planningServiceDescriptor = $convert.base64Decode(
    'Cg9QbGFubmluZ1NlcnZpY2USZQoKQ3JlYXRlUGxhbhIqLmFncmljdWx0dXJlLnBsYW5uaW5nLn'
    'YxLkNyZWF0ZVBsYW5SZXF1ZXN0GisuYWdyaWN1bHR1cmUucGxhbm5pbmcudjEuQ3JlYXRlUGxh'
    'blJlc3BvbnNlElwKB0dldFBsYW4SJy5hZ3JpY3VsdHVyZS5wbGFubmluZy52MS5HZXRQbGFuUm'
    'VxdWVzdBooLmFncmljdWx0dXJlLnBsYW5uaW5nLnYxLkdldFBsYW5SZXNwb25zZRJiCglMaXN0'
    'UGxhbnMSKS5hZ3JpY3VsdHVyZS5wbGFubmluZy52MS5MaXN0UGxhbnNSZXF1ZXN0GiouYWdyaW'
    'N1bHR1cmUucGxhbm5pbmcudjEuTGlzdFBsYW5zUmVzcG9uc2USZQoKVXBkYXRlUGxhbhIqLmFn'
    'cmljdWx0dXJlLnBsYW5uaW5nLnYxLlVwZGF0ZVBsYW5SZXF1ZXN0GisuYWdyaWN1bHR1cmUucG'
    'xhbm5pbmcudjEuVXBkYXRlUGxhblJlc3BvbnNlEmUKCkNvbW1pdFBsYW4SKi5hZ3JpY3VsdHVy'
    'ZS5wbGFubmluZy52MS5Db21taXRQbGFuUmVxdWVzdBorLmFncmljdWx0dXJlLnBsYW5uaW5nLn'
    'YxLkNvbW1pdFBsYW5SZXNwb25zZRJuCg1DaGVja1JvdGF0aW9uEi0uYWdyaWN1bHR1cmUucGxh'
    'bm5pbmcudjEuQ2hlY2tSb3RhdGlvblJlcXVlc3QaLi5hZ3JpY3VsdHVyZS5wbGFubmluZy52MS'
    '5DaGVja1JvdGF0aW9uUmVzcG9uc2USdAoPR2V0U293aW5nV2luZG93Ei8uYWdyaWN1bHR1cmUu'
    'cGxhbm5pbmcudjEuR2V0U293aW5nV2luZG93UmVxdWVzdBowLmFncmljdWx0dXJlLnBsYW5uaW'
    '5nLnYxLkdldFNvd2luZ1dpbmRvd1Jlc3BvbnNl');
