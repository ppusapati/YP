// This is a generated file - do not edit.
//
// Generated from sustainability.proto.

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

@$core.Deprecated('Use inputCategoryDescriptor instead')
const InputCategory$json = {
  '1': 'InputCategory',
  '2': [
    {'1': 'INPUT_CATEGORY_UNSPECIFIED', '2': 0},
    {'1': 'INPUT_CATEGORY_SYNTHETIC_N', '2': 1},
    {'1': 'INPUT_CATEGORY_UREA', '2': 2},
    {'1': 'INPUT_CATEGORY_PHOSPHATE', '2': 3},
    {'1': 'INPUT_CATEGORY_POTASH', '2': 4},
    {'1': 'INPUT_CATEGORY_ORGANIC_N', '2': 5},
    {'1': 'INPUT_CATEGORY_LIME', '2': 6},
    {'1': 'INPUT_CATEGORY_PESTICIDE', '2': 7},
    {'1': 'INPUT_CATEGORY_SEED', '2': 8},
    {'1': 'INPUT_CATEGORY_DIESEL', '2': 9},
    {'1': 'INPUT_CATEGORY_ELECTRICITY', '2': 10},
    {'1': 'INPUT_CATEGORY_RESIDUE_BURN', '2': 11},
  ],
};

/// Descriptor for `InputCategory`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List inputCategoryDescriptor = $convert.base64Decode(
    'Cg1JbnB1dENhdGVnb3J5Eh4KGklOUFVUX0NBVEVHT1JZX1VOU1BFQ0lGSUVEEAASHgoaSU5QVV'
    'RfQ0FURUdPUllfU1lOVEhFVElDX04QARIXChNJTlBVVF9DQVRFR09SWV9VUkVBEAISHAoYSU5Q'
    'VVRfQ0FURUdPUllfUEhPU1BIQVRFEAMSGQoVSU5QVVRfQ0FURUdPUllfUE9UQVNIEAQSHAoYSU'
    '5QVVRfQ0FURUdPUllfT1JHQU5JQ19OEAUSFwoTSU5QVVRfQ0FURUdPUllfTElNRRAGEhwKGElO'
    'UFVUX0NBVEVHT1JZX1BFU1RJQ0lERRAHEhcKE0lOUFVUX0NBVEVHT1JZX1NFRUQQCBIZChVJTl'
    'BVVF9DQVRFR09SWV9ESUVTRUwQCRIeChpJTlBVVF9DQVRFR09SWV9FTEVDVFJJQ0lUWRAKEh8K'
    'G0lOUFVUX0NBVEVHT1JZX1JFU0lEVUVfQlVSThAL');

@$core.Deprecated('Use waterRegimeDescriptor instead')
const WaterRegime$json = {
  '1': 'WaterRegime',
  '2': [
    {'1': 'WATER_REGIME_UNSPECIFIED', '2': 0},
    {'1': 'WATER_REGIME_CONTINUOUS_FLOOD', '2': 1},
    {'1': 'WATER_REGIME_SINGLE_DRAINAGE', '2': 2},
    {'1': 'WATER_REGIME_MULTIPLE_DRAINAGE', '2': 3},
    {'1': 'WATER_REGIME_AWD', '2': 4},
    {'1': 'WATER_REGIME_RAINFED', '2': 5},
    {'1': 'WATER_REGIME_UPLAND', '2': 6},
  ],
};

/// Descriptor for `WaterRegime`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List waterRegimeDescriptor = $convert.base64Decode(
    'CgtXYXRlclJlZ2ltZRIcChhXQVRFUl9SRUdJTUVfVU5TUEVDSUZJRUQQABIhCh1XQVRFUl9SRU'
    'dJTUVfQ09OVElOVU9VU19GTE9PRBABEiAKHFdBVEVSX1JFR0lNRV9TSU5HTEVfRFJBSU5BR0UQ'
    'AhIiCh5XQVRFUl9SRUdJTUVfTVVMVElQTEVfRFJBSU5BR0UQAxIUChBXQVRFUl9SRUdJTUVfQV'
    'dEEAQSGAoUV0FURVJfUkVHSU1FX1JBSU5GRUQQBRIXChNXQVRFUl9SRUdJTUVfVVBMQU5EEAY=');

@$core.Deprecated('Use emissionSourceDescriptor instead')
const EmissionSource$json = {
  '1': 'EmissionSource',
  '2': [
    {'1': 'EMISSION_SOURCE_UNSPECIFIED', '2': 0},
    {'1': 'EMISSION_SOURCE_DIRECT_N2O', '2': 1},
    {'1': 'EMISSION_SOURCE_INDIRECT_N2O', '2': 2},
    {'1': 'EMISSION_SOURCE_UREA_CO2', '2': 3},
    {'1': 'EMISSION_SOURCE_LIME_CO2', '2': 4},
    {'1': 'EMISSION_SOURCE_RICE_CH4', '2': 5},
    {'1': 'EMISSION_SOURCE_ENERGY', '2': 6},
    {'1': 'EMISSION_SOURCE_RESIDUE_BURN', '2': 7},
    {'1': 'EMISSION_SOURCE_UPSTREAM', '2': 8},
  ],
};

/// Descriptor for `EmissionSource`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List emissionSourceDescriptor = $convert.base64Decode(
    'Cg5FbWlzc2lvblNvdXJjZRIfChtFTUlTU0lPTl9TT1VSQ0VfVU5TUEVDSUZJRUQQABIeChpFTU'
    'lTU0lPTl9TT1VSQ0VfRElSRUNUX04yTxABEiAKHEVNSVNTSU9OX1NPVVJDRV9JTkRJUkVDVF9O'
    'Mk8QAhIcChhFTUlTU0lPTl9TT1VSQ0VfVVJFQV9DTzIQAxIcChhFTUlTU0lPTl9TT1VSQ0VfTE'
    'lNRV9DTzIQBBIcChhFTUlTU0lPTl9TT1VSQ0VfUklDRV9DSDQQBRIaChZFTUlTU0lPTl9TT1VS'
    'Q0VfRU5FUkdZEAYSIAocRU1JU1NJT05fU09VUkNFX1JFU0lEVUVfQlVSThAHEhwKGEVNSVNTSU'
    '9OX1NPVVJDRV9VUFNUUkVBTRAI');

@$core.Deprecated('Use completenessDescriptor instead')
const Completeness$json = {
  '1': 'Completeness',
  '2': [
    {'1': 'COMPLETENESS_UNSPECIFIED', '2': 0},
    {'1': 'COMPLETENESS_RECORDED', '2': 1},
    {'1': 'COMPLETENESS_MISSING', '2': 2},
    {'1': 'COMPLETENESS_NOT_APPLICABLE', '2': 3},
  ],
};

/// Descriptor for `Completeness`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List completenessDescriptor = $convert.base64Decode(
    'CgxDb21wbGV0ZW5lc3MSHAoYQ09NUExFVEVORVNTX1VOU1BFQ0lGSUVEEAASGQoVQ09NUExFVE'
    'VORVNTX1JFQ09SREVEEAESGAoUQ09NUExFVEVORVNTX01JU1NJTkcQAhIfChtDT01QTEVURU5F'
    'U1NfTk9UX0FQUExJQ0FCTEUQAw==');

@$core.Deprecated('Use certificationStandardDescriptor instead')
const CertificationStandard$json = {
  '1': 'CertificationStandard',
  '2': [
    {'1': 'CERTIFICATION_STANDARD_UNSPECIFIED', '2': 0},
    {'1': 'CERTIFICATION_STANDARD_NPOP', '2': 1},
    {'1': 'CERTIFICATION_STANDARD_GLOBALGAP', '2': 2},
    {'1': 'CERTIFICATION_STANDARD_FAIRTRADE', '2': 3},
    {'1': 'CERTIFICATION_STANDARD_RAINFOREST', '2': 4},
  ],
};

/// Descriptor for `CertificationStandard`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List certificationStandardDescriptor = $convert.base64Decode(
    'ChVDZXJ0aWZpY2F0aW9uU3RhbmRhcmQSJgoiQ0VSVElGSUNBVElPTl9TVEFOREFSRF9VTlNQRU'
    'NJRklFRBAAEh8KG0NFUlRJRklDQVRJT05fU1RBTkRBUkRfTlBPUBABEiQKIENFUlRJRklDQVRJ'
    'T05fU1RBTkRBUkRfR0xPQkFMR0FQEAISJAogQ0VSVElGSUNBVElPTl9TVEFOREFSRF9GQUlSVF'
    'JBREUQAxIlCiFDRVJUSUZJQ0FUSU9OX1NUQU5EQVJEX1JBSU5GT1JFU1QQBA==');

@$core.Deprecated('Use findingSeverityDescriptor instead')
const FindingSeverity$json = {
  '1': 'FindingSeverity',
  '2': [
    {'1': 'FINDING_SEVERITY_UNSPECIFIED', '2': 0},
    {'1': 'FINDING_SEVERITY_BLOCKER', '2': 1},
    {'1': 'FINDING_SEVERITY_MAJOR', '2': 2},
    {'1': 'FINDING_SEVERITY_MINOR', '2': 3},
  ],
};

/// Descriptor for `FindingSeverity`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List findingSeverityDescriptor = $convert.base64Decode(
    'Cg9GaW5kaW5nU2V2ZXJpdHkSIAocRklORElOR19TRVZFUklUWV9VTlNQRUNJRklFRBAAEhwKGE'
    'ZJTkRJTkdfU0VWRVJJVFlfQkxPQ0tFUhABEhoKFkZJTkRJTkdfU0VWRVJJVFlfTUFKT1IQAhIa'
    'ChZGSU5ESU5HX1NFVkVSSVRZX01JTk9SEAM=');

@$core.Deprecated('Use certificationStatusDescriptor instead')
const CertificationStatus$json = {
  '1': 'CertificationStatus',
  '2': [
    {'1': 'CERTIFICATION_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'CERTIFICATION_STATUS_IN_CONVERSION', '2': 1},
    {'1': 'CERTIFICATION_STATUS_ELIGIBLE', '2': 2},
    {'1': 'CERTIFICATION_STATUS_BLOCKED', '2': 3},
    {'1': 'CERTIFICATION_STATUS_INSUFFICIENT_RECORDS', '2': 4},
  ],
};

/// Descriptor for `CertificationStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List certificationStatusDescriptor = $convert.base64Decode(
    'ChNDZXJ0aWZpY2F0aW9uU3RhdHVzEiQKIENFUlRJRklDQVRJT05fU1RBVFVTX1VOU1BFQ0lGSU'
    'VEEAASJgoiQ0VSVElGSUNBVElPTl9TVEFUVVNfSU5fQ09OVkVSU0lPThABEiEKHUNFUlRJRklD'
    'QVRJT05fU1RBVFVTX0VMSUdJQkxFEAISIAocQ0VSVElGSUNBVElPTl9TVEFUVVNfQkxPQ0tFRB'
    'ADEi0KKUNFUlRJRklDQVRJT05fU1RBVFVTX0lOU1VGRklDSUVOVF9SRUNPUkRTEAQ=');

@$core.Deprecated('Use inputUseDescriptor instead')
const InputUse$json = {
  '1': 'InputUse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop', '3': 3, '4': 1, '5': 9, '10': 'crop'},
    {'1': 'year', '3': 4, '4': 1, '5': 5, '10': 'year'},
    {
      '1': 'category',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sustainability.v1.InputCategory',
      '10': 'category'
    },
    {'1': 'product', '3': 6, '4': 1, '5': 9, '10': 'product'},
    {'1': 'quantity', '3': 7, '4': 1, '5': 1, '10': 'quantity'},
    {'1': 'unit', '3': 8, '4': 1, '5': 9, '10': 'unit'},
    {'1': 'nitrogen_kg', '3': 9, '4': 1, '5': 1, '10': 'nitrogenKg'},
    {
      '1': 'applied_on',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'appliedOn'
    },
    {'1': 'applied_by', '3': 11, '4': 1, '5': 9, '10': 'appliedBy'},
    {'1': 'notes', '3': 12, '4': 1, '5': 9, '10': 'notes'},
    {
      '1': 'organic_permitted',
      '3': 13,
      '4': 1,
      '5': 8,
      '10': 'organicPermitted'
    },
    {
      '1': 'created_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `InputUse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inputUseDescriptor = $convert.base64Decode(
    'CghJbnB1dFVzZRIOCgJpZBgBIAEoCVICaWQSGQoIZmllbGRfaWQYAiABKAlSB2ZpZWxkSWQSEg'
    'oEY3JvcBgDIAEoCVIEY3JvcBISCgR5ZWFyGAQgASgFUgR5ZWFyEkgKCGNhdGVnb3J5GAUgASgO'
    'MiwuYWdyaWN1bHR1cmUuc3VzdGFpbmFiaWxpdHkudjEuSW5wdXRDYXRlZ29yeVIIY2F0ZWdvcn'
    'kSGAoHcHJvZHVjdBgGIAEoCVIHcHJvZHVjdBIaCghxdWFudGl0eRgHIAEoAVIIcXVhbnRpdHkS'
    'EgoEdW5pdBgIIAEoCVIEdW5pdBIfCgtuaXRyb2dlbl9rZxgJIAEoAVIKbml0cm9nZW5LZxI5Cg'
    'phcHBsaWVkX29uGAogASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJYXBwbGllZE9u'
    'Eh0KCmFwcGxpZWRfYnkYCyABKAlSCWFwcGxpZWRCeRIUCgVub3RlcxgMIAEoCVIFbm90ZXMSKw'
    'oRb3JnYW5pY19wZXJtaXR0ZWQYDSABKAhSEG9yZ2FuaWNQZXJtaXR0ZWQSOQoKY3JlYXRlZF9h'
    'dBgOIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdA==');

@$core.Deprecated('Use emissionLineDescriptor instead')
const EmissionLine$json = {
  '1': 'EmissionLine',
  '2': [
    {
      '1': 'source',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sustainability.v1.EmissionSource',
      '10': 'source'
    },
    {'1': 'kg_co2e', '3': 2, '4': 1, '5': 1, '10': 'kgCo2e'},
    {'1': 'basis', '3': 3, '4': 1, '5': 9, '10': 'basis'},
    {
      '1': 'completeness',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sustainability.v1.Completeness',
      '10': 'completeness'
    },
  ],
};

/// Descriptor for `EmissionLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emissionLineDescriptor = $convert.base64Decode(
    'CgxFbWlzc2lvbkxpbmUSRQoGc291cmNlGAEgASgOMi0uYWdyaWN1bHR1cmUuc3VzdGFpbmFiaW'
    'xpdHkudjEuRW1pc3Npb25Tb3VyY2VSBnNvdXJjZRIXCgdrZ19jbzJlGAIgASgBUgZrZ0NvMmUS'
    'FAoFYmFzaXMYAyABKAlSBWJhc2lzEk8KDGNvbXBsZXRlbmVzcxgEIAEoDjIrLmFncmljdWx0dX'
    'JlLnN1c3RhaW5hYmlsaXR5LnYxLkNvbXBsZXRlbmVzc1IMY29tcGxldGVuZXNz');

@$core.Deprecated('Use footprintDescriptor instead')
const Footprint$json = {
  '1': 'Footprint',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'crop', '3': 4, '4': 1, '5': 9, '10': 'crop'},
    {'1': 'year', '3': 5, '4': 1, '5': 5, '10': 'year'},
    {'1': 'area_hectares', '3': 6, '4': 1, '5': 1, '10': 'areaHectares'},
    {
      '1': 'water_regime',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sustainability.v1.WaterRegime',
      '10': 'waterRegime'
    },
    {
      '1': 'lines',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.agriculture.sustainability.v1.EmissionLine',
      '10': 'lines'
    },
    {'1': 'total_kg_co2e', '3': 9, '4': 1, '5': 1, '10': 'totalKgCo2e'},
    {
      '1': 'kg_co2e_per_hectare',
      '3': 10,
      '4': 1,
      '5': 1,
      '10': 'kgCo2ePerHectare'
    },
    {'1': 'kg_co2e_per_tonne', '3': 11, '4': 1, '5': 1, '10': 'kgCo2ePerTonne'},
    {'1': 'yield_tonnes', '3': 12, '4': 1, '5': 1, '10': 'yieldTonnes'},
    {
      '1': 'missing_sources',
      '3': 13,
      '4': 3,
      '5': 14,
      '6': '.agriculture.sustainability.v1.EmissionSource',
      '10': 'missingSources'
    },
    {'1': 'complete', '3': 14, '4': 1, '5': 8, '10': 'complete'},
    {
      '1': 'computed_at',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'computedAt'
    },
    {'1': 'method', '3': 16, '4': 1, '5': 9, '10': 'method'},
  ],
};

/// Descriptor for `Footprint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List footprintDescriptor = $convert.base64Decode(
    'CglGb290cHJpbnQSDgoCaWQYASABKAlSAmlkEhkKCGZpZWxkX2lkGAIgASgJUgdmaWVsZElkEh'
    'cKB2Zhcm1faWQYAyABKAlSBmZhcm1JZBISCgRjcm9wGAQgASgJUgRjcm9wEhIKBHllYXIYBSAB'
    'KAVSBHllYXISIwoNYXJlYV9oZWN0YXJlcxgGIAEoAVIMYXJlYUhlY3RhcmVzEk0KDHdhdGVyX3'
    'JlZ2ltZRgHIAEoDjIqLmFncmljdWx0dXJlLnN1c3RhaW5hYmlsaXR5LnYxLldhdGVyUmVnaW1l'
    'Ugt3YXRlclJlZ2ltZRJBCgVsaW5lcxgIIAMoCzIrLmFncmljdWx0dXJlLnN1c3RhaW5hYmlsaX'
    'R5LnYxLkVtaXNzaW9uTGluZVIFbGluZXMSIgoNdG90YWxfa2dfY28yZRgJIAEoAVILdG90YWxL'
    'Z0NvMmUSLQoTa2dfY28yZV9wZXJfaGVjdGFyZRgKIAEoAVIQa2dDbzJlUGVySGVjdGFyZRIpCh'
    'FrZ19jbzJlX3Blcl90b25uZRgLIAEoAVIOa2dDbzJlUGVyVG9ubmUSIQoMeWllbGRfdG9ubmVz'
    'GAwgASgBUgt5aWVsZFRvbm5lcxJWCg9taXNzaW5nX3NvdXJjZXMYDSADKA4yLS5hZ3JpY3VsdH'
    'VyZS5zdXN0YWluYWJpbGl0eS52MS5FbWlzc2lvblNvdXJjZVIObWlzc2luZ1NvdXJjZXMSGgoI'
    'Y29tcGxldGUYDiABKAhSCGNvbXBsZXRlEjsKC2NvbXB1dGVkX2F0GA8gASgLMhouZ29vZ2xlLn'
    'Byb3RvYnVmLlRpbWVzdGFtcFIKY29tcHV0ZWRBdBIWCgZtZXRob2QYECABKAlSBm1ldGhvZA==');

@$core.Deprecated('Use findingDescriptor instead')
const Finding$json = {
  '1': 'Finding',
  '2': [
    {
      '1': 'severity',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sustainability.v1.FindingSeverity',
      '10': 'severity'
    },
    {'1': 'code', '3': 2, '4': 1, '5': 9, '10': 'code'},
    {'1': 'message', '3': 3, '4': 1, '5': 9, '10': 'message'},
    {'1': 'evidence_id', '3': 4, '4': 1, '5': 9, '10': 'evidenceId'},
    {
      '1': 'occurred_on',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'occurredOn'
    },
  ],
};

/// Descriptor for `Finding`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List findingDescriptor = $convert.base64Decode(
    'CgdGaW5kaW5nEkoKCHNldmVyaXR5GAEgASgOMi4uYWdyaWN1bHR1cmUuc3VzdGFpbmFiaWxpdH'
    'kudjEuRmluZGluZ1NldmVyaXR5UghzZXZlcml0eRISCgRjb2RlGAIgASgJUgRjb2RlEhgKB21l'
    'c3NhZ2UYAyABKAlSB21lc3NhZ2USHwoLZXZpZGVuY2VfaWQYBCABKAlSCmV2aWRlbmNlSWQSOw'
    'oLb2NjdXJyZWRfb24YBSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgpvY2N1cnJl'
    'ZE9u');

@$core.Deprecated('Use certificationCheckDescriptor instead')
const CertificationCheck$json = {
  '1': 'CertificationCheck',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'standard',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sustainability.v1.CertificationStandard',
      '10': 'standard'
    },
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sustainability.v1.CertificationStatus',
      '10': 'status'
    },
    {
      '1': 'conversion_started_on',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'conversionStartedOn'
    },
    {
      '1': 'eligible_from',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'eligibleFrom'
    },
    {
      '1': 'findings',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.agriculture.sustainability.v1.Finding',
      '10': 'findings'
    },
    {'1': 'record_years', '3': 7, '4': 1, '5': 5, '10': 'recordYears'},
    {'1': 'summary', '3': 8, '4': 1, '5': 9, '10': 'summary'},
  ],
};

/// Descriptor for `CertificationCheck`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List certificationCheckDescriptor = $convert.base64Decode(
    'ChJDZXJ0aWZpY2F0aW9uQ2hlY2sSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQSUAoIc3Rhbm'
    'RhcmQYAiABKA4yNC5hZ3JpY3VsdHVyZS5zdXN0YWluYWJpbGl0eS52MS5DZXJ0aWZpY2F0aW9u'
    'U3RhbmRhcmRSCHN0YW5kYXJkEkoKBnN0YXR1cxgDIAEoDjIyLmFncmljdWx0dXJlLnN1c3RhaW'
    '5hYmlsaXR5LnYxLkNlcnRpZmljYXRpb25TdGF0dXNSBnN0YXR1cxJOChVjb252ZXJzaW9uX3N0'
    'YXJ0ZWRfb24YBCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUhNjb252ZXJzaW9uU3'
    'RhcnRlZE9uEj8KDWVsaWdpYmxlX2Zyb20YBSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0'
    'YW1wUgxlbGlnaWJsZUZyb20SQgoIZmluZGluZ3MYBiADKAsyJi5hZ3JpY3VsdHVyZS5zdXN0YW'
    'luYWJpbGl0eS52MS5GaW5kaW5nUghmaW5kaW5ncxIhCgxyZWNvcmRfeWVhcnMYByABKAVSC3Jl'
    'Y29yZFllYXJzEhgKB3N1bW1hcnkYCCABKAlSB3N1bW1hcnk=');

@$core.Deprecated('Use recordInputUseRequestDescriptor instead')
const RecordInputUseRequest$json = {
  '1': 'RecordInputUseRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop', '3': 2, '4': 1, '5': 9, '10': 'crop'},
    {'1': 'year', '3': 3, '4': 1, '5': 5, '10': 'year'},
    {
      '1': 'category',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sustainability.v1.InputCategory',
      '10': 'category'
    },
    {'1': 'product', '3': 5, '4': 1, '5': 9, '10': 'product'},
    {'1': 'quantity', '3': 6, '4': 1, '5': 1, '10': 'quantity'},
    {'1': 'unit', '3': 7, '4': 1, '5': 9, '10': 'unit'},
    {'1': 'nitrogen_kg', '3': 8, '4': 1, '5': 1, '10': 'nitrogenKg'},
    {
      '1': 'applied_on',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'appliedOn'
    },
    {'1': 'notes', '3': 10, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `RecordInputUseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recordInputUseRequestDescriptor = $convert.base64Decode(
    'ChVSZWNvcmRJbnB1dFVzZVJlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQSEgoEY3'
    'JvcBgCIAEoCVIEY3JvcBISCgR5ZWFyGAMgASgFUgR5ZWFyEkgKCGNhdGVnb3J5GAQgASgOMiwu'
    'YWdyaWN1bHR1cmUuc3VzdGFpbmFiaWxpdHkudjEuSW5wdXRDYXRlZ29yeVIIY2F0ZWdvcnkSGA'
    'oHcHJvZHVjdBgFIAEoCVIHcHJvZHVjdBIaCghxdWFudGl0eRgGIAEoAVIIcXVhbnRpdHkSEgoE'
    'dW5pdBgHIAEoCVIEdW5pdBIfCgtuaXRyb2dlbl9rZxgIIAEoAVIKbml0cm9nZW5LZxI5CgphcH'
    'BsaWVkX29uGAkgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJYXBwbGllZE9uEhQK'
    'BW5vdGVzGAogASgJUgVub3Rlcw==');

@$core.Deprecated('Use recordInputUseResponseDescriptor instead')
const RecordInputUseResponse$json = {
  '1': 'RecordInputUseResponse',
  '2': [
    {
      '1': 'input',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sustainability.v1.InputUse',
      '10': 'input'
    },
  ],
};

/// Descriptor for `RecordInputUseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recordInputUseResponseDescriptor =
    $convert.base64Decode(
        'ChZSZWNvcmRJbnB1dFVzZVJlc3BvbnNlEj0KBWlucHV0GAEgASgLMicuYWdyaWN1bHR1cmUuc3'
        'VzdGFpbmFiaWxpdHkudjEuSW5wdXRVc2VSBWlucHV0');

@$core.Deprecated('Use listInputUseRequestDescriptor instead')
const ListInputUseRequest$json = {
  '1': 'ListInputUseRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'year', '3': 2, '4': 1, '5': 5, '10': 'year'},
    {
      '1': 'category',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sustainability.v1.InputCategory',
      '10': 'category'
    },
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 5, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListInputUseRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listInputUseRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0SW5wdXRVc2VSZXF1ZXN0EhkKCGZpZWxkX2lkGAEgASgJUgdmaWVsZElkEhIKBHllYX'
    'IYAiABKAVSBHllYXISSAoIY2F0ZWdvcnkYAyABKA4yLC5hZ3JpY3VsdHVyZS5zdXN0YWluYWJp'
    'bGl0eS52MS5JbnB1dENhdGVnb3J5UghjYXRlZ29yeRIbCglwYWdlX3NpemUYBCABKAVSCHBhZ2'
    'VTaXplEh0KCnBhZ2VfdG9rZW4YBSABKAlSCXBhZ2VUb2tlbg==');

@$core.Deprecated('Use listInputUseResponseDescriptor instead')
const ListInputUseResponse$json = {
  '1': 'ListInputUseResponse',
  '2': [
    {
      '1': 'inputs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.sustainability.v1.InputUse',
      '10': 'inputs'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListInputUseResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listInputUseResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0SW5wdXRVc2VSZXNwb25zZRI/CgZpbnB1dHMYASADKAsyJy5hZ3JpY3VsdHVyZS5zdX'
    'N0YWluYWJpbGl0eS52MS5JbnB1dFVzZVIGaW5wdXRzEiYKD25leHRfcGFnZV90b2tlbhgCIAEo'
    'CVINbmV4dFBhZ2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use computeFootprintRequestDescriptor instead')
const ComputeFootprintRequest$json = {
  '1': 'ComputeFootprintRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'year', '3': 2, '4': 1, '5': 5, '10': 'year'},
    {'1': 'crop', '3': 3, '4': 1, '5': 9, '10': 'crop'},
    {'1': 'area_hectares', '3': 4, '4': 1, '5': 1, '10': 'areaHectares'},
    {
      '1': 'water_regime',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sustainability.v1.WaterRegime',
      '10': 'waterRegime'
    },
    {'1': 'flooded_days', '3': 6, '4': 1, '5': 5, '10': 'floodedDays'},
    {'1': 'yield_tonnes', '3': 7, '4': 1, '5': 1, '10': 'yieldTonnes'},
  ],
};

/// Descriptor for `ComputeFootprintRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List computeFootprintRequestDescriptor = $convert.base64Decode(
    'ChdDb21wdXRlRm9vdHByaW50UmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBISCg'
    'R5ZWFyGAIgASgFUgR5ZWFyEhIKBGNyb3AYAyABKAlSBGNyb3ASIwoNYXJlYV9oZWN0YXJlcxgE'
    'IAEoAVIMYXJlYUhlY3RhcmVzEk0KDHdhdGVyX3JlZ2ltZRgFIAEoDjIqLmFncmljdWx0dXJlLn'
    'N1c3RhaW5hYmlsaXR5LnYxLldhdGVyUmVnaW1lUgt3YXRlclJlZ2ltZRIhCgxmbG9vZGVkX2Rh'
    'eXMYBiABKAVSC2Zsb29kZWREYXlzEiEKDHlpZWxkX3Rvbm5lcxgHIAEoAVILeWllbGRUb25uZX'
    'M=');

@$core.Deprecated('Use computeFootprintResponseDescriptor instead')
const ComputeFootprintResponse$json = {
  '1': 'ComputeFootprintResponse',
  '2': [
    {
      '1': 'footprint',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sustainability.v1.Footprint',
      '10': 'footprint'
    },
  ],
};

/// Descriptor for `ComputeFootprintResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List computeFootprintResponseDescriptor =
    $convert.base64Decode(
        'ChhDb21wdXRlRm9vdHByaW50UmVzcG9uc2USRgoJZm9vdHByaW50GAEgASgLMiguYWdyaWN1bH'
        'R1cmUuc3VzdGFpbmFiaWxpdHkudjEuRm9vdHByaW50Uglmb290cHJpbnQ=');

@$core.Deprecated('Use getFootprintRequestDescriptor instead')
const GetFootprintRequest$json = {
  '1': 'GetFootprintRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetFootprintRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFootprintRequestDescriptor = $convert
    .base64Decode('ChNHZXRGb290cHJpbnRSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use getFootprintResponseDescriptor instead')
const GetFootprintResponse$json = {
  '1': 'GetFootprintResponse',
  '2': [
    {
      '1': 'footprint',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sustainability.v1.Footprint',
      '10': 'footprint'
    },
  ],
};

/// Descriptor for `GetFootprintResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFootprintResponseDescriptor = $convert.base64Decode(
    'ChRHZXRGb290cHJpbnRSZXNwb25zZRJGCglmb290cHJpbnQYASABKAsyKC5hZ3JpY3VsdHVyZS'
    '5zdXN0YWluYWJpbGl0eS52MS5Gb290cHJpbnRSCWZvb3RwcmludA==');

@$core.Deprecated('Use listFootprintsRequestDescriptor instead')
const ListFootprintsRequest$json = {
  '1': 'ListFootprintsRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'year', '3': 3, '4': 1, '5': 5, '10': 'year'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 5, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListFootprintsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFootprintsRequestDescriptor = $convert.base64Decode(
    'ChVMaXN0Rm9vdHByaW50c1JlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQSFwoHZm'
    'FybV9pZBgCIAEoCVIGZmFybUlkEhIKBHllYXIYAyABKAVSBHllYXISGwoJcGFnZV9zaXplGAQg'
    'ASgFUghwYWdlU2l6ZRIdCgpwYWdlX3Rva2VuGAUgASgJUglwYWdlVG9rZW4=');

@$core.Deprecated('Use listFootprintsResponseDescriptor instead')
const ListFootprintsResponse$json = {
  '1': 'ListFootprintsResponse',
  '2': [
    {
      '1': 'footprints',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.sustainability.v1.Footprint',
      '10': 'footprints'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListFootprintsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFootprintsResponseDescriptor = $convert.base64Decode(
    'ChZMaXN0Rm9vdHByaW50c1Jlc3BvbnNlEkgKCmZvb3RwcmludHMYASADKAsyKC5hZ3JpY3VsdH'
    'VyZS5zdXN0YWluYWJpbGl0eS52MS5Gb290cHJpbnRSCmZvb3RwcmludHMSJgoPbmV4dF9wYWdl'
    'X3Rva2VuGAIgASgJUg1uZXh0UGFnZVRva2VuEh8KC3RvdGFsX2NvdW50GAMgASgFUgp0b3RhbE'
    'NvdW50');

@$core.Deprecated('Use checkCertificationRequestDescriptor instead')
const CheckCertificationRequest$json = {
  '1': 'CheckCertificationRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'standard',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sustainability.v1.CertificationStandard',
      '10': 'standard'
    },
    {
      '1': 'conversion_started_on',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'conversionStartedOn'
    },
  ],
};

/// Descriptor for `CheckCertificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkCertificationRequestDescriptor = $convert.base64Decode(
    'ChlDaGVja0NlcnRpZmljYXRpb25SZXF1ZXN0EhkKCGZpZWxkX2lkGAEgASgJUgdmaWVsZElkEl'
    'AKCHN0YW5kYXJkGAIgASgOMjQuYWdyaWN1bHR1cmUuc3VzdGFpbmFiaWxpdHkudjEuQ2VydGlm'
    'aWNhdGlvblN0YW5kYXJkUghzdGFuZGFyZBJOChVjb252ZXJzaW9uX3N0YXJ0ZWRfb24YAyABKA'
    'syGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUhNjb252ZXJzaW9uU3RhcnRlZE9u');

@$core.Deprecated('Use checkCertificationResponseDescriptor instead')
const CheckCertificationResponse$json = {
  '1': 'CheckCertificationResponse',
  '2': [
    {
      '1': 'check',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sustainability.v1.CertificationCheck',
      '10': 'check'
    },
  ],
};

/// Descriptor for `CheckCertificationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkCertificationResponseDescriptor =
    $convert.base64Decode(
        'ChpDaGVja0NlcnRpZmljYXRpb25SZXNwb25zZRJHCgVjaGVjaxgBIAEoCzIxLmFncmljdWx0dX'
        'JlLnN1c3RhaW5hYmlsaXR5LnYxLkNlcnRpZmljYXRpb25DaGVja1IFY2hlY2s=');

@$core.Deprecated('Use exportCertificationPackRequestDescriptor instead')
const ExportCertificationPackRequest$json = {
  '1': 'ExportCertificationPackRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'standard',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sustainability.v1.CertificationStandard',
      '10': 'standard'
    },
    {
      '1': 'conversion_started_on',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'conversionStartedOn'
    },
    {'1': 'allow_incomplete', '3': 4, '4': 1, '5': 8, '10': 'allowIncomplete'},
  ],
};

/// Descriptor for `ExportCertificationPackRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportCertificationPackRequestDescriptor = $convert.base64Decode(
    'Ch5FeHBvcnRDZXJ0aWZpY2F0aW9uUGFja1JlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZW'
    'xkSWQSUAoIc3RhbmRhcmQYAiABKA4yNC5hZ3JpY3VsdHVyZS5zdXN0YWluYWJpbGl0eS52MS5D'
    'ZXJ0aWZpY2F0aW9uU3RhbmRhcmRSCHN0YW5kYXJkEk4KFWNvbnZlcnNpb25fc3RhcnRlZF9vbh'
    'gDIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSE2NvbnZlcnNpb25TdGFydGVkT24S'
    'KQoQYWxsb3dfaW5jb21wbGV0ZRgEIAEoCFIPYWxsb3dJbmNvbXBsZXRl');

@$core.Deprecated('Use exportCertificationPackResponseDescriptor instead')
const ExportCertificationPackResponse$json = {
  '1': 'ExportCertificationPackResponse',
  '2': [
    {'1': 'filename', '3': 1, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'content', '3': 2, '4': 1, '5': 12, '10': 'content'},
    {'1': 'content_type', '3': 3, '4': 1, '5': 9, '10': 'contentType'},
    {
      '1': 'check',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sustainability.v1.CertificationCheck',
      '10': 'check'
    },
  ],
};

/// Descriptor for `ExportCertificationPackResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportCertificationPackResponseDescriptor =
    $convert.base64Decode(
        'Ch9FeHBvcnRDZXJ0aWZpY2F0aW9uUGFja1Jlc3BvbnNlEhoKCGZpbGVuYW1lGAEgASgJUghmaW'
        'xlbmFtZRIYCgdjb250ZW50GAIgASgMUgdjb250ZW50EiEKDGNvbnRlbnRfdHlwZRgDIAEoCVIL'
        'Y29udGVudFR5cGUSRwoFY2hlY2sYBCABKAsyMS5hZ3JpY3VsdHVyZS5zdXN0YWluYWJpbGl0eS'
        '52MS5DZXJ0aWZpY2F0aW9uQ2hlY2tSBWNoZWNr');

const $core.Map<$core.String, $core.dynamic> SustainabilityServiceBase$json = {
  '1': 'SustainabilityService',
  '2': [
    {
      '1': 'RecordInputUse',
      '2': '.agriculture.sustainability.v1.RecordInputUseRequest',
      '3': '.agriculture.sustainability.v1.RecordInputUseResponse'
    },
    {
      '1': 'ListInputUse',
      '2': '.agriculture.sustainability.v1.ListInputUseRequest',
      '3': '.agriculture.sustainability.v1.ListInputUseResponse'
    },
    {
      '1': 'ComputeFootprint',
      '2': '.agriculture.sustainability.v1.ComputeFootprintRequest',
      '3': '.agriculture.sustainability.v1.ComputeFootprintResponse'
    },
    {
      '1': 'GetFootprint',
      '2': '.agriculture.sustainability.v1.GetFootprintRequest',
      '3': '.agriculture.sustainability.v1.GetFootprintResponse'
    },
    {
      '1': 'ListFootprints',
      '2': '.agriculture.sustainability.v1.ListFootprintsRequest',
      '3': '.agriculture.sustainability.v1.ListFootprintsResponse'
    },
    {
      '1': 'CheckCertification',
      '2': '.agriculture.sustainability.v1.CheckCertificationRequest',
      '3': '.agriculture.sustainability.v1.CheckCertificationResponse'
    },
    {
      '1': 'ExportCertificationPack',
      '2': '.agriculture.sustainability.v1.ExportCertificationPackRequest',
      '3': '.agriculture.sustainability.v1.ExportCertificationPackResponse'
    },
  ],
};

@$core.Deprecated('Use sustainabilityServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    SustainabilityServiceBase$messageJson = {
  '.agriculture.sustainability.v1.RecordInputUseRequest':
      RecordInputUseRequest$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.sustainability.v1.RecordInputUseResponse':
      RecordInputUseResponse$json,
  '.agriculture.sustainability.v1.InputUse': InputUse$json,
  '.agriculture.sustainability.v1.ListInputUseRequest':
      ListInputUseRequest$json,
  '.agriculture.sustainability.v1.ListInputUseResponse':
      ListInputUseResponse$json,
  '.agriculture.sustainability.v1.ComputeFootprintRequest':
      ComputeFootprintRequest$json,
  '.agriculture.sustainability.v1.ComputeFootprintResponse':
      ComputeFootprintResponse$json,
  '.agriculture.sustainability.v1.Footprint': Footprint$json,
  '.agriculture.sustainability.v1.EmissionLine': EmissionLine$json,
  '.agriculture.sustainability.v1.GetFootprintRequest':
      GetFootprintRequest$json,
  '.agriculture.sustainability.v1.GetFootprintResponse':
      GetFootprintResponse$json,
  '.agriculture.sustainability.v1.ListFootprintsRequest':
      ListFootprintsRequest$json,
  '.agriculture.sustainability.v1.ListFootprintsResponse':
      ListFootprintsResponse$json,
  '.agriculture.sustainability.v1.CheckCertificationRequest':
      CheckCertificationRequest$json,
  '.agriculture.sustainability.v1.CheckCertificationResponse':
      CheckCertificationResponse$json,
  '.agriculture.sustainability.v1.CertificationCheck': CertificationCheck$json,
  '.agriculture.sustainability.v1.Finding': Finding$json,
  '.agriculture.sustainability.v1.ExportCertificationPackRequest':
      ExportCertificationPackRequest$json,
  '.agriculture.sustainability.v1.ExportCertificationPackResponse':
      ExportCertificationPackResponse$json,
};

/// Descriptor for `SustainabilityService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List sustainabilityServiceDescriptor = $convert.base64Decode(
    'ChVTdXN0YWluYWJpbGl0eVNlcnZpY2USfQoOUmVjb3JkSW5wdXRVc2USNC5hZ3JpY3VsdHVyZS'
    '5zdXN0YWluYWJpbGl0eS52MS5SZWNvcmRJbnB1dFVzZVJlcXVlc3QaNS5hZ3JpY3VsdHVyZS5z'
    'dXN0YWluYWJpbGl0eS52MS5SZWNvcmRJbnB1dFVzZVJlc3BvbnNlEncKDExpc3RJbnB1dFVzZR'
    'IyLmFncmljdWx0dXJlLnN1c3RhaW5hYmlsaXR5LnYxLkxpc3RJbnB1dFVzZVJlcXVlc3QaMy5h'
    'Z3JpY3VsdHVyZS5zdXN0YWluYWJpbGl0eS52MS5MaXN0SW5wdXRVc2VSZXNwb25zZRKDAQoQQ2'
    '9tcHV0ZUZvb3RwcmludBI2LmFncmljdWx0dXJlLnN1c3RhaW5hYmlsaXR5LnYxLkNvbXB1dGVG'
    'b290cHJpbnRSZXF1ZXN0GjcuYWdyaWN1bHR1cmUuc3VzdGFpbmFiaWxpdHkudjEuQ29tcHV0ZU'
    'Zvb3RwcmludFJlc3BvbnNlEncKDEdldEZvb3RwcmludBIyLmFncmljdWx0dXJlLnN1c3RhaW5h'
    'YmlsaXR5LnYxLkdldEZvb3RwcmludFJlcXVlc3QaMy5hZ3JpY3VsdHVyZS5zdXN0YWluYWJpbG'
    'l0eS52MS5HZXRGb290cHJpbnRSZXNwb25zZRJ9Cg5MaXN0Rm9vdHByaW50cxI0LmFncmljdWx0'
    'dXJlLnN1c3RhaW5hYmlsaXR5LnYxLkxpc3RGb290cHJpbnRzUmVxdWVzdBo1LmFncmljdWx0dX'
    'JlLnN1c3RhaW5hYmlsaXR5LnYxLkxpc3RGb290cHJpbnRzUmVzcG9uc2USiQEKEkNoZWNrQ2Vy'
    'dGlmaWNhdGlvbhI4LmFncmljdWx0dXJlLnN1c3RhaW5hYmlsaXR5LnYxLkNoZWNrQ2VydGlmaW'
    'NhdGlvblJlcXVlc3QaOS5hZ3JpY3VsdHVyZS5zdXN0YWluYWJpbGl0eS52MS5DaGVja0NlcnRp'
    'ZmljYXRpb25SZXNwb25zZRKYAQoXRXhwb3J0Q2VydGlmaWNhdGlvblBhY2sSPS5hZ3JpY3VsdH'
    'VyZS5zdXN0YWluYWJpbGl0eS52MS5FeHBvcnRDZXJ0aWZpY2F0aW9uUGFja1JlcXVlc3QaPi5h'
    'Z3JpY3VsdHVyZS5zdXN0YWluYWJpbGl0eS52MS5FeHBvcnRDZXJ0aWZpY2F0aW9uUGFja1Jlc3'
    'BvbnNl');
