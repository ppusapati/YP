// This is a generated file - do not edit.
//
// Generated from finance.proto.

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

@$core.Deprecated('Use cropCategoryDescriptor instead')
const CropCategory$json = {
  '1': 'CropCategory',
  '2': [
    {'1': 'CROP_CATEGORY_UNSPECIFIED', '2': 0},
    {'1': 'CROP_CATEGORY_FOOD_GRAIN', '2': 1},
    {'1': 'CROP_CATEGORY_OILSEED', '2': 2},
    {'1': 'CROP_CATEGORY_COMMERCIAL', '2': 3},
    {'1': 'CROP_CATEGORY_HORTICULTURE', '2': 4},
  ],
};

/// Descriptor for `CropCategory`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List cropCategoryDescriptor = $convert.base64Decode(
    'CgxDcm9wQ2F0ZWdvcnkSHQoZQ1JPUF9DQVRFR09SWV9VTlNQRUNJRklFRBAAEhwKGENST1BfQ0'
    'FURUdPUllfRk9PRF9HUkFJThABEhkKFUNST1BfQ0FURUdPUllfT0lMU0VFRBACEhwKGENST1Bf'
    'Q0FURUdPUllfQ09NTUVSQ0lBTBADEh4KGkNST1BfQ0FURUdPUllfSE9SVElDVUxUVVJFEAQ=');

@$core.Deprecated('Use quoteConfidenceDescriptor instead')
const QuoteConfidence$json = {
  '1': 'QuoteConfidence',
  '2': [
    {'1': 'QUOTE_CONFIDENCE_UNSPECIFIED', '2': 0},
    {'1': 'QUOTE_CONFIDENCE_FIELD_HISTORY', '2': 1},
    {'1': 'QUOTE_CONFIDENCE_SHORT_HISTORY', '2': 2},
    {'1': 'QUOTE_CONFIDENCE_BENCHMARK_ONLY', '2': 3},
  ],
};

/// Descriptor for `QuoteConfidence`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List quoteConfidenceDescriptor = $convert.base64Decode(
    'Cg9RdW90ZUNvbmZpZGVuY2USIAocUVVPVEVfQ09ORklERU5DRV9VTlNQRUNJRklFRBAAEiIKHl'
    'FVT1RFX0NPTkZJREVOQ0VfRklFTERfSElTVE9SWRABEiIKHlFVT1RFX0NPTkZJREVOQ0VfU0hP'
    'UlRfSElTVE9SWRACEiMKH1FVT1RFX0NPTkZJREVOQ0VfQkVOQ0hNQVJLX09OTFkQAw==');

@$core.Deprecated('Use creditBandDescriptor instead')
const CreditBand$json = {
  '1': 'CreditBand',
  '2': [
    {'1': 'CREDIT_BAND_UNSPECIFIED', '2': 0},
    {'1': 'CREDIT_BAND_POOR', '2': 1},
    {'1': 'CREDIT_BAND_FAIR', '2': 2},
    {'1': 'CREDIT_BAND_GOOD', '2': 3},
    {'1': 'CREDIT_BAND_EXCELLENT', '2': 4},
  ],
};

/// Descriptor for `CreditBand`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List creditBandDescriptor = $convert.base64Decode(
    'CgpDcmVkaXRCYW5kEhsKF0NSRURJVF9CQU5EX1VOU1BFQ0lGSUVEEAASFAoQQ1JFRElUX0JBTk'
    'RfUE9PUhABEhQKEENSRURJVF9CQU5EX0ZBSVIQAhIUChBDUkVESVRfQkFORF9HT09EEAMSGQoV'
    'Q1JFRElUX0JBTkRfRVhDRUxMRU5UEAQ=');

@$core.Deprecated('Use scoreStatusDescriptor instead')
const ScoreStatus$json = {
  '1': 'ScoreStatus',
  '2': [
    {'1': 'SCORE_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'SCORE_STATUS_SCORED', '2': 1},
    {'1': 'SCORE_STATUS_INSUFFICIENT_HISTORY', '2': 2},
  ],
};

/// Descriptor for `ScoreStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List scoreStatusDescriptor = $convert.base64Decode(
    'CgtTY29yZVN0YXR1cxIcChhTQ09SRV9TVEFUVVNfVU5TUEVDSUZJRUQQABIXChNTQ09SRV9TVE'
    'FUVVNfU0NPUkVEEAESJQohU0NPUkVfU1RBVFVTX0lOU1VGRklDSUVOVF9ISVNUT1JZEAI=');

@$core.Deprecated('Use lossCauseDescriptor instead')
const LossCause$json = {
  '1': 'LossCause',
  '2': [
    {'1': 'LOSS_CAUSE_UNSPECIFIED', '2': 0},
    {'1': 'LOSS_CAUSE_DROUGHT', '2': 1},
    {'1': 'LOSS_CAUSE_FLOOD', '2': 2},
    {'1': 'LOSS_CAUSE_UNSEASONAL_RAIN', '2': 3},
    {'1': 'LOSS_CAUSE_HAIL', '2': 4},
    {'1': 'LOSS_CAUSE_CYCLONE', '2': 5},
    {'1': 'LOSS_CAUSE_PEST', '2': 6},
    {'1': 'LOSS_CAUSE_DISEASE', '2': 7},
    {'1': 'LOSS_CAUSE_FIRE', '2': 8},
  ],
};

/// Descriptor for `LossCause`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List lossCauseDescriptor = $convert.base64Decode(
    'CglMb3NzQ2F1c2USGgoWTE9TU19DQVVTRV9VTlNQRUNJRklFRBAAEhYKEkxPU1NfQ0FVU0VfRF'
    'JPVUdIVBABEhQKEExPU1NfQ0FVU0VfRkxPT0QQAhIeChpMT1NTX0NBVVNFX1VOU0VBU09OQUxf'
    'UkFJThADEhMKD0xPU1NfQ0FVU0VfSEFJTBAEEhYKEkxPU1NfQ0FVU0VfQ1lDTE9ORRAFEhMKD0'
    'xPU1NfQ0FVU0VfUEVTVBAGEhYKEkxPU1NfQ0FVU0VfRElTRUFTRRAHEhMKD0xPU1NfQ0FVU0Vf'
    'RklSRRAI');

@$core.Deprecated('Use claimStatusDescriptor instead')
const ClaimStatus$json = {
  '1': 'ClaimStatus',
  '2': [
    {'1': 'CLAIM_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'CLAIM_STATUS_DRAFT', '2': 1},
    {'1': 'CLAIM_STATUS_SUBMITTED', '2': 2},
    {'1': 'CLAIM_STATUS_EVIDENCE_READY', '2': 3},
    {'1': 'CLAIM_STATUS_SETTLED', '2': 4},
    {'1': 'CLAIM_STATUS_REJECTED', '2': 5},
    {'1': 'CLAIM_STATUS_WITHDRAWN', '2': 6},
  ],
};

/// Descriptor for `ClaimStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List claimStatusDescriptor = $convert.base64Decode(
    'CgtDbGFpbVN0YXR1cxIcChhDTEFJTV9TVEFUVVNfVU5TUEVDSUZJRUQQABIWChJDTEFJTV9TVE'
    'FUVVNfRFJBRlQQARIaChZDTEFJTV9TVEFUVVNfU1VCTUlUVEVEEAISHwobQ0xBSU1fU1RBVFVT'
    'X0VWSURFTkNFX1JFQURZEAMSGAoUQ0xBSU1fU1RBVFVTX1NFVFRMRUQQBBIZChVDTEFJTV9TVE'
    'FUVVNfUkVKRUNURUQQBRIaChZDTEFJTV9TVEFUVVNfV0lUSERSQVdOEAY=');

@$core.Deprecated('Use evidenceSourceDescriptor instead')
const EvidenceSource$json = {
  '1': 'EvidenceSource',
  '2': [
    {'1': 'EVIDENCE_SOURCE_UNSPECIFIED', '2': 0},
    {'1': 'EVIDENCE_SOURCE_SATELLITE_NDVI', '2': 1},
    {'1': 'EVIDENCE_SOURCE_WEATHER', '2': 2},
    {'1': 'EVIDENCE_SOURCE_FIELD_INSPECTION', '2': 3},
    {'1': 'EVIDENCE_SOURCE_YIELD_RECORD', '2': 4},
    {'1': 'EVIDENCE_SOURCE_PHOTO', '2': 5},
  ],
};

/// Descriptor for `EvidenceSource`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List evidenceSourceDescriptor = $convert.base64Decode(
    'Cg5FdmlkZW5jZVNvdXJjZRIfChtFVklERU5DRV9TT1VSQ0VfVU5TUEVDSUZJRUQQABIiCh5FVk'
    'lERU5DRV9TT1VSQ0VfU0FURUxMSVRFX05EVkkQARIbChdFVklERU5DRV9TT1VSQ0VfV0VBVEhF'
    'UhACEiQKIEVWSURFTkNFX1NPVVJDRV9GSUVMRF9JTlNQRUNUSU9OEAMSIAocRVZJREVOQ0VfU0'
    '9VUkNFX1lJRUxEX1JFQ09SRBAEEhkKFUVWSURFTkNFX1NPVVJDRV9QSE9UTxAF');

@$core.Deprecated('Use evidenceVerdictDescriptor instead')
const EvidenceVerdict$json = {
  '1': 'EvidenceVerdict',
  '2': [
    {'1': 'EVIDENCE_VERDICT_UNSPECIFIED', '2': 0},
    {'1': 'EVIDENCE_VERDICT_SUPPORTS', '2': 1},
    {'1': 'EVIDENCE_VERDICT_CONTRADICTS', '2': 2},
    {'1': 'EVIDENCE_VERDICT_INCONCLUSIVE', '2': 3},
  ],
};

/// Descriptor for `EvidenceVerdict`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List evidenceVerdictDescriptor = $convert.base64Decode(
    'Cg9FdmlkZW5jZVZlcmRpY3QSIAocRVZJREVOQ0VfVkVSRElDVF9VTlNQRUNJRklFRBAAEh0KGU'
    'VWSURFTkNFX1ZFUkRJQ1RfU1VQUE9SVFMQARIgChxFVklERU5DRV9WRVJESUNUX0NPTlRSQURJ'
    'Q1RTEAISIQodRVZJREVOQ0VfVkVSRElDVF9JTkNPTkNMVVNJVkUQAw==');

@$core.Deprecated('Use premiumLineDescriptor instead')
const PremiumLine$json = {
  '1': 'PremiumLine',
  '2': [
    {'1': 'label', '3': 1, '4': 1, '5': 9, '10': 'label'},
    {'1': 'rate', '3': 2, '4': 1, '5': 1, '10': 'rate'},
    {'1': 'amount', '3': 3, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'basis', '3': 4, '4': 1, '5': 9, '10': 'basis'},
  ],
};

/// Descriptor for `PremiumLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List premiumLineDescriptor = $convert.base64Decode(
    'CgtQcmVtaXVtTGluZRIUCgVsYWJlbBgBIAEoCVIFbGFiZWwSEgoEcmF0ZRgCIAEoAVIEcmF0ZR'
    'IWCgZhbW91bnQYAyABKAFSBmFtb3VudBIUCgViYXNpcxgEIAEoCVIFYmFzaXM=');

@$core.Deprecated('Use insuranceQuoteDescriptor instead')
const InsuranceQuote$json = {
  '1': 'InsuranceQuote',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'crop', '3': 4, '4': 1, '5': 9, '10': 'crop'},
    {
      '1': 'category',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.CropCategory',
      '10': 'category'
    },
    {
      '1': 'season',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.Season',
      '10': 'season'
    },
    {'1': 'year', '3': 7, '4': 1, '5': 5, '10': 'year'},
    {'1': 'area_hectares', '3': 8, '4': 1, '5': 1, '10': 'areaHectares'},
    {
      '1': 'sum_insured_per_hectare',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'sumInsuredPerHectare'
    },
    {
      '1': 'total_sum_insured',
      '3': 10,
      '4': 1,
      '5': 1,
      '10': 'totalSumInsured'
    },
    {'1': 'indemnity_level', '3': 11, '4': 1, '5': 1, '10': 'indemnityLevel'},
    {
      '1': 'threshold_yield_kg_ha',
      '3': 12,
      '4': 1,
      '5': 1,
      '10': 'thresholdYieldKgHa'
    },
    {
      '1': 'lines',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.agriculture.finance.v1.PremiumLine',
      '10': 'lines'
    },
    {
      '1': 'actuarial_premium',
      '3': 14,
      '4': 1,
      '5': 1,
      '10': 'actuarialPremium'
    },
    {'1': 'actuarial_rate', '3': 15, '4': 1, '5': 1, '10': 'actuarialRate'},
    {'1': 'farmer_premium', '3': 16, '4': 1, '5': 1, '10': 'farmerPremium'},
    {'1': 'subsidy', '3': 17, '4': 1, '5': 1, '10': 'subsidy'},
    {
      '1': 'confidence',
      '3': 18,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.QuoteConfidence',
      '10': 'confidence'
    },
    {'1': 'history_seasons', '3': 19, '4': 1, '5': 5, '10': 'historySeasons'},
    {'1': 'basis', '3': 20, '4': 1, '5': 9, '10': 'basis'},
    {
      '1': 'quoted_at',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'quotedAt'
    },
    {
      '1': 'expires_at',
      '3': 22,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiresAt'
    },
  ],
};

/// Descriptor for `InsuranceQuote`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List insuranceQuoteDescriptor = $convert.base64Decode(
    'Cg5JbnN1cmFuY2VRdW90ZRIOCgJpZBgBIAEoCVICaWQSGQoIZmllbGRfaWQYAiABKAlSB2ZpZW'
    'xkSWQSFwoHZmFybV9pZBgDIAEoCVIGZmFybUlkEhIKBGNyb3AYBCABKAlSBGNyb3ASQAoIY2F0'
    'ZWdvcnkYBSABKA4yJC5hZ3JpY3VsdHVyZS5maW5hbmNlLnYxLkNyb3BDYXRlZ29yeVIIY2F0ZW'
    'dvcnkSNgoGc2Vhc29uGAYgASgOMh4uYWdyaWN1bHR1cmUuZmluYW5jZS52MS5TZWFzb25SBnNl'
    'YXNvbhISCgR5ZWFyGAcgASgFUgR5ZWFyEiMKDWFyZWFfaGVjdGFyZXMYCCABKAFSDGFyZWFIZW'
    'N0YXJlcxI1ChdzdW1faW5zdXJlZF9wZXJfaGVjdGFyZRgJIAEoAVIUc3VtSW5zdXJlZFBlckhl'
    'Y3RhcmUSKgoRdG90YWxfc3VtX2luc3VyZWQYCiABKAFSD3RvdGFsU3VtSW5zdXJlZBInCg9pbm'
    'RlbW5pdHlfbGV2ZWwYCyABKAFSDmluZGVtbml0eUxldmVsEjEKFXRocmVzaG9sZF95aWVsZF9r'
    'Z19oYRgMIAEoAVISdGhyZXNob2xkWWllbGRLZ0hhEjkKBWxpbmVzGA0gAygLMiMuYWdyaWN1bH'
    'R1cmUuZmluYW5jZS52MS5QcmVtaXVtTGluZVIFbGluZXMSKwoRYWN0dWFyaWFsX3ByZW1pdW0Y'
    'DiABKAFSEGFjdHVhcmlhbFByZW1pdW0SJQoOYWN0dWFyaWFsX3JhdGUYDyABKAFSDWFjdHVhcm'
    'lhbFJhdGUSJQoOZmFybWVyX3ByZW1pdW0YECABKAFSDWZhcm1lclByZW1pdW0SGAoHc3Vic2lk'
    'eRgRIAEoAVIHc3Vic2lkeRJHCgpjb25maWRlbmNlGBIgASgOMicuYWdyaWN1bHR1cmUuZmluYW'
    '5jZS52MS5RdW90ZUNvbmZpZGVuY2VSCmNvbmZpZGVuY2USJwoPaGlzdG9yeV9zZWFzb25zGBMg'
    'ASgFUg5oaXN0b3J5U2Vhc29ucxIUCgViYXNpcxgUIAEoCVIFYmFzaXMSNwoJcXVvdGVkX2F0GB'
    'UgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIIcXVvdGVkQXQSOQoKZXhwaXJlc19h'
    'dBgWIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWV4cGlyZXNBdA==');

@$core.Deprecated('Use scoreFactorDescriptor instead')
const ScoreFactor$json = {
  '1': 'ScoreFactor',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 9, '10': 'code'},
    {'1': 'label', '3': 2, '4': 1, '5': 9, '10': 'label'},
    {'1': 'points', '3': 3, '4': 1, '5': 1, '10': 'points'},
    {'1': 'value', '3': 4, '4': 1, '5': 1, '10': 'value'},
    {'1': 'explanation', '3': 5, '4': 1, '5': 9, '10': 'explanation'},
  ],
};

/// Descriptor for `ScoreFactor`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scoreFactorDescriptor = $convert.base64Decode(
    'CgtTY29yZUZhY3RvchISCgRjb2RlGAEgASgJUgRjb2RlEhQKBWxhYmVsGAIgASgJUgVsYWJlbB'
    'IWCgZwb2ludHMYAyABKAFSBnBvaW50cxIUCgV2YWx1ZRgEIAEoAVIFdmFsdWUSIAoLZXhwbGFu'
    'YXRpb24YBSABKAlSC2V4cGxhbmF0aW9u');

@$core.Deprecated('Use creditAssessmentDescriptor instead')
const CreditAssessment$json = {
  '1': 'CreditAssessment',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.ScoreStatus',
      '10': 'status'
    },
    {'1': 'score', '3': 4, '4': 1, '5': 5, '10': 'score'},
    {
      '1': 'band',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.CreditBand',
      '10': 'band'
    },
    {
      '1': 'factors',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.agriculture.finance.v1.ScoreFactor',
      '10': 'factors'
    },
    {
      '1': 'seasons_considered',
      '3': 7,
      '4': 1,
      '5': 5,
      '10': 'seasonsConsidered'
    },
    {'1': 'mean_yield_kg_ha', '3': 8, '4': 1, '5': 1, '10': 'meanYieldKgHa'},
    {
      '1': 'yield_variability',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'yieldVariability'
    },
    {
      '1': 'mean_profit_per_hectare',
      '3': 10,
      '4': 1,
      '5': 1,
      '10': 'meanProfitPerHectare'
    },
    {'1': 'indicative_limit', '3': 11, '4': 1, '5': 1, '10': 'indicativeLimit'},
    {'1': 'caveat', '3': 12, '4': 1, '5': 9, '10': 'caveat'},
    {
      '1': 'assessed_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'assessedAt'
    },
  ],
};

/// Descriptor for `CreditAssessment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List creditAssessmentDescriptor = $convert.base64Decode(
    'ChBDcmVkaXRBc3Nlc3NtZW50Eg4KAmlkGAEgASgJUgJpZBIXCgdmYXJtX2lkGAIgASgJUgZmYX'
    'JtSWQSOwoGc3RhdHVzGAMgASgOMiMuYWdyaWN1bHR1cmUuZmluYW5jZS52MS5TY29yZVN0YXR1'
    'c1IGc3RhdHVzEhQKBXNjb3JlGAQgASgFUgVzY29yZRI2CgRiYW5kGAUgASgOMiIuYWdyaWN1bH'
    'R1cmUuZmluYW5jZS52MS5DcmVkaXRCYW5kUgRiYW5kEj0KB2ZhY3RvcnMYBiADKAsyIy5hZ3Jp'
    'Y3VsdHVyZS5maW5hbmNlLnYxLlNjb3JlRmFjdG9yUgdmYWN0b3JzEi0KEnNlYXNvbnNfY29uc2'
    'lkZXJlZBgHIAEoBVIRc2Vhc29uc0NvbnNpZGVyZWQSJwoQbWVhbl95aWVsZF9rZ19oYRgIIAEo'
    'AVINbWVhbllpZWxkS2dIYRIrChF5aWVsZF92YXJpYWJpbGl0eRgJIAEoAVIQeWllbGRWYXJpYW'
    'JpbGl0eRI1ChdtZWFuX3Byb2ZpdF9wZXJfaGVjdGFyZRgKIAEoAVIUbWVhblByb2ZpdFBlckhl'
    'Y3RhcmUSKQoQaW5kaWNhdGl2ZV9saW1pdBgLIAEoAVIPaW5kaWNhdGl2ZUxpbWl0EhYKBmNhdm'
    'VhdBgMIAEoCVIGY2F2ZWF0EjsKC2Fzc2Vzc2VkX2F0GA0gASgLMhouZ29vZ2xlLnByb3RvYnVm'
    'LlRpbWVzdGFtcFIKYXNzZXNzZWRBdA==');

@$core.Deprecated('Use evidenceDescriptor instead')
const Evidence$json = {
  '1': 'Evidence',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'source',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.EvidenceSource',
      '10': 'source'
    },
    {
      '1': 'verdict',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.EvidenceVerdict',
      '10': 'verdict'
    },
    {'1': 'summary', '3': 4, '4': 1, '5': 9, '10': 'summary'},
    {'1': 'observed', '3': 5, '4': 1, '5': 1, '10': 'observed'},
    {'1': 'baseline', '3': 6, '4': 1, '5': 1, '10': 'baseline'},
    {'1': 'unit', '3': 7, '4': 1, '5': 9, '10': 'unit'},
    {
      '1': 'observed_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'observedAt'
    },
    {'1': 'reference', '3': 9, '4': 1, '5': 9, '10': 'reference'},
  ],
};

/// Descriptor for `Evidence`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List evidenceDescriptor = $convert.base64Decode(
    'CghFdmlkZW5jZRIOCgJpZBgBIAEoCVICaWQSPgoGc291cmNlGAIgASgOMiYuYWdyaWN1bHR1cm'
    'UuZmluYW5jZS52MS5FdmlkZW5jZVNvdXJjZVIGc291cmNlEkEKB3ZlcmRpY3QYAyABKA4yJy5h'
    'Z3JpY3VsdHVyZS5maW5hbmNlLnYxLkV2aWRlbmNlVmVyZGljdFIHdmVyZGljdBIYCgdzdW1tYX'
    'J5GAQgASgJUgdzdW1tYXJ5EhoKCG9ic2VydmVkGAUgASgBUghvYnNlcnZlZBIaCghiYXNlbGlu'
    'ZRgGIAEoAVIIYmFzZWxpbmUSEgoEdW5pdBgHIAEoCVIEdW5pdBI7CgtvYnNlcnZlZF9hdBgIIA'
    'EoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCm9ic2VydmVkQXQSHAoJcmVmZXJlbmNl'
    'GAkgASgJUglyZWZlcmVuY2U=');

@$core.Deprecated('Use claimDescriptor instead')
const Claim$json = {
  '1': 'Claim',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'quote_id', '3': 2, '4': 1, '5': 9, '10': 'quoteId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'crop', '3': 5, '4': 1, '5': 9, '10': 'crop'},
    {
      '1': 'season',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.Season',
      '10': 'season'
    },
    {'1': 'year', '3': 7, '4': 1, '5': 5, '10': 'year'},
    {
      '1': 'cause',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.LossCause',
      '10': 'cause'
    },
    {
      '1': 'loss_started_on',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lossStartedOn'
    },
    {
      '1': 'loss_ended_on',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lossEndedOn'
    },
    {'1': 'description', '3': 11, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'status',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.ClaimStatus',
      '10': 'status'
    },
    {
      '1': 'claimed_area_hectares',
      '3': 13,
      '4': 1,
      '5': 1,
      '10': 'claimedAreaHectares'
    },
    {
      '1': 'reported_yield_kg_ha',
      '3': 14,
      '4': 1,
      '5': 1,
      '10': 'reportedYieldKgHa'
    },
    {
      '1': 'threshold_yield_kg_ha',
      '3': 15,
      '4': 1,
      '5': 1,
      '10': 'thresholdYieldKgHa'
    },
    {'1': 'indicated_payout', '3': 16, '4': 1, '5': 1, '10': 'indicatedPayout'},
    {
      '1': 'evidence',
      '3': 17,
      '4': 3,
      '5': 11,
      '6': '.agriculture.finance.v1.Evidence',
      '10': 'evidence'
    },
    {'1': 'evidence_summary', '3': 18, '4': 1, '5': 9, '10': 'evidenceSummary'},
    {'1': 'submitted_by', '3': 19, '4': 1, '5': 9, '10': 'submittedBy'},
    {
      '1': 'submitted_at',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'submittedAt'
    },
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
    {'1': 'version', '3': 23, '4': 1, '5': 3, '10': 'version'},
  ],
};

/// Descriptor for `Claim`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List claimDescriptor = $convert.base64Decode(
    'CgVDbGFpbRIOCgJpZBgBIAEoCVICaWQSGQoIcXVvdGVfaWQYAiABKAlSB3F1b3RlSWQSGQoIZm'
    'llbGRfaWQYAyABKAlSB2ZpZWxkSWQSFwoHZmFybV9pZBgEIAEoCVIGZmFybUlkEhIKBGNyb3AY'
    'BSABKAlSBGNyb3ASNgoGc2Vhc29uGAYgASgOMh4uYWdyaWN1bHR1cmUuZmluYW5jZS52MS5TZW'
    'Fzb25SBnNlYXNvbhISCgR5ZWFyGAcgASgFUgR5ZWFyEjcKBWNhdXNlGAggASgOMiEuYWdyaWN1'
    'bHR1cmUuZmluYW5jZS52MS5Mb3NzQ2F1c2VSBWNhdXNlEkIKD2xvc3Nfc3RhcnRlZF9vbhgJIA'
    'EoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSDWxvc3NTdGFydGVkT24SPgoNbG9zc19l'
    'bmRlZF9vbhgKIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSC2xvc3NFbmRlZE9uEi'
    'AKC2Rlc2NyaXB0aW9uGAsgASgJUgtkZXNjcmlwdGlvbhI7CgZzdGF0dXMYDCABKA4yIy5hZ3Jp'
    'Y3VsdHVyZS5maW5hbmNlLnYxLkNsYWltU3RhdHVzUgZzdGF0dXMSMgoVY2xhaW1lZF9hcmVhX2'
    'hlY3RhcmVzGA0gASgBUhNjbGFpbWVkQXJlYUhlY3RhcmVzEi8KFHJlcG9ydGVkX3lpZWxkX2tn'
    'X2hhGA4gASgBUhFyZXBvcnRlZFlpZWxkS2dIYRIxChV0aHJlc2hvbGRfeWllbGRfa2dfaGEYDy'
    'ABKAFSEnRocmVzaG9sZFlpZWxkS2dIYRIpChBpbmRpY2F0ZWRfcGF5b3V0GBAgASgBUg9pbmRp'
    'Y2F0ZWRQYXlvdXQSPAoIZXZpZGVuY2UYESADKAsyIC5hZ3JpY3VsdHVyZS5maW5hbmNlLnYxLk'
    'V2aWRlbmNlUghldmlkZW5jZRIpChBldmlkZW5jZV9zdW1tYXJ5GBIgASgJUg9ldmlkZW5jZVN1'
    'bW1hcnkSIQoMc3VibWl0dGVkX2J5GBMgASgJUgtzdWJtaXR0ZWRCeRI9CgxzdWJtaXR0ZWRfYX'
    'QYFCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgtzdWJtaXR0ZWRBdBI5CgpjcmVh'
    'dGVkX2F0GBUgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCn'
    'VwZGF0ZWRfYXQYFiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQS'
    'GAoHdmVyc2lvbhgXIAEoA1IHdmVyc2lvbg==');

@$core.Deprecated('Use quoteInsuranceRequestDescriptor instead')
const QuoteInsuranceRequest$json = {
  '1': 'QuoteInsuranceRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'crop', '3': 3, '4': 1, '5': 9, '10': 'crop'},
    {
      '1': 'category',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.CropCategory',
      '10': 'category'
    },
    {
      '1': 'season',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.Season',
      '10': 'season'
    },
    {'1': 'year', '3': 6, '4': 1, '5': 5, '10': 'year'},
    {'1': 'area_hectares', '3': 7, '4': 1, '5': 1, '10': 'areaHectares'},
    {
      '1': 'sum_insured_per_hectare',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'sumInsuredPerHectare'
    },
    {'1': 'indemnity_level', '3': 9, '4': 1, '5': 1, '10': 'indemnityLevel'},
  ],
};

/// Descriptor for `QuoteInsuranceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quoteInsuranceRequestDescriptor = $convert.base64Decode(
    'ChVRdW90ZUluc3VyYW5jZVJlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQSFwoHZm'
    'FybV9pZBgCIAEoCVIGZmFybUlkEhIKBGNyb3AYAyABKAlSBGNyb3ASQAoIY2F0ZWdvcnkYBCAB'
    'KA4yJC5hZ3JpY3VsdHVyZS5maW5hbmNlLnYxLkNyb3BDYXRlZ29yeVIIY2F0ZWdvcnkSNgoGc2'
    'Vhc29uGAUgASgOMh4uYWdyaWN1bHR1cmUuZmluYW5jZS52MS5TZWFzb25SBnNlYXNvbhISCgR5'
    'ZWFyGAYgASgFUgR5ZWFyEiMKDWFyZWFfaGVjdGFyZXMYByABKAFSDGFyZWFIZWN0YXJlcxI1Ch'
    'dzdW1faW5zdXJlZF9wZXJfaGVjdGFyZRgIIAEoAVIUc3VtSW5zdXJlZFBlckhlY3RhcmUSJwoP'
    'aW5kZW1uaXR5X2xldmVsGAkgASgBUg5pbmRlbW5pdHlMZXZlbA==');

@$core.Deprecated('Use quoteInsuranceResponseDescriptor instead')
const QuoteInsuranceResponse$json = {
  '1': 'QuoteInsuranceResponse',
  '2': [
    {
      '1': 'quote',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.finance.v1.InsuranceQuote',
      '10': 'quote'
    },
  ],
};

/// Descriptor for `QuoteInsuranceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List quoteInsuranceResponseDescriptor =
    $convert.base64Decode(
        'ChZRdW90ZUluc3VyYW5jZVJlc3BvbnNlEjwKBXF1b3RlGAEgASgLMiYuYWdyaWN1bHR1cmUuZm'
        'luYW5jZS52MS5JbnN1cmFuY2VRdW90ZVIFcXVvdGU=');

@$core.Deprecated('Use getQuoteRequestDescriptor instead')
const GetQuoteRequest$json = {
  '1': 'GetQuoteRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetQuoteRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getQuoteRequestDescriptor =
    $convert.base64Decode('Cg9HZXRRdW90ZVJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use getQuoteResponseDescriptor instead')
const GetQuoteResponse$json = {
  '1': 'GetQuoteResponse',
  '2': [
    {
      '1': 'quote',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.finance.v1.InsuranceQuote',
      '10': 'quote'
    },
  ],
};

/// Descriptor for `GetQuoteResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getQuoteResponseDescriptor = $convert.base64Decode(
    'ChBHZXRRdW90ZVJlc3BvbnNlEjwKBXF1b3RlGAEgASgLMiYuYWdyaWN1bHR1cmUuZmluYW5jZS'
    '52MS5JbnN1cmFuY2VRdW90ZVIFcXVvdGU=');

@$core.Deprecated('Use listQuotesRequestDescriptor instead')
const ListQuotesRequest$json = {
  '1': 'ListQuotesRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'year', '3': 3, '4': 1, '5': 5, '10': 'year'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 5, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListQuotesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listQuotesRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0UXVvdGVzUmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBIXCgdmYXJtX2'
    'lkGAIgASgJUgZmYXJtSWQSEgoEeWVhchgDIAEoBVIEeWVhchIbCglwYWdlX3NpemUYBCABKAVS'
    'CHBhZ2VTaXplEh0KCnBhZ2VfdG9rZW4YBSABKAlSCXBhZ2VUb2tlbg==');

@$core.Deprecated('Use listQuotesResponseDescriptor instead')
const ListQuotesResponse$json = {
  '1': 'ListQuotesResponse',
  '2': [
    {
      '1': 'quotes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.finance.v1.InsuranceQuote',
      '10': 'quotes'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListQuotesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listQuotesResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0UXVvdGVzUmVzcG9uc2USPgoGcXVvdGVzGAEgAygLMiYuYWdyaWN1bHR1cmUuZmluYW'
    '5jZS52MS5JbnN1cmFuY2VRdW90ZVIGcXVvdGVzEiYKD25leHRfcGFnZV90b2tlbhgCIAEoCVIN'
    'bmV4dFBhZ2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use assessCreditRequestDescriptor instead')
const AssessCreditRequest$json = {
  '1': 'AssessCreditRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'from_year', '3': 2, '4': 1, '5': 5, '10': 'fromYear'},
    {'1': 'to_year', '3': 3, '4': 1, '5': 5, '10': 'toYear'},
  ],
};

/// Descriptor for `AssessCreditRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List assessCreditRequestDescriptor = $convert.base64Decode(
    'ChNBc3Nlc3NDcmVkaXRSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZBIbCglmcm9tX3'
    'llYXIYAiABKAVSCGZyb21ZZWFyEhcKB3RvX3llYXIYAyABKAVSBnRvWWVhcg==');

@$core.Deprecated('Use assessCreditResponseDescriptor instead')
const AssessCreditResponse$json = {
  '1': 'AssessCreditResponse',
  '2': [
    {
      '1': 'assessment',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.finance.v1.CreditAssessment',
      '10': 'assessment'
    },
  ],
};

/// Descriptor for `AssessCreditResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List assessCreditResponseDescriptor = $convert.base64Decode(
    'ChRBc3Nlc3NDcmVkaXRSZXNwb25zZRJICgphc3Nlc3NtZW50GAEgASgLMiguYWdyaWN1bHR1cm'
    'UuZmluYW5jZS52MS5DcmVkaXRBc3Nlc3NtZW50Ugphc3Nlc3NtZW50');

@$core.Deprecated('Use getCreditAssessmentRequestDescriptor instead')
const GetCreditAssessmentRequest$json = {
  '1': 'GetCreditAssessmentRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetCreditAssessmentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCreditAssessmentRequestDescriptor =
    $convert.base64Decode(
        'ChpHZXRDcmVkaXRBc3Nlc3NtZW50UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use getCreditAssessmentResponseDescriptor instead')
const GetCreditAssessmentResponse$json = {
  '1': 'GetCreditAssessmentResponse',
  '2': [
    {
      '1': 'assessment',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.finance.v1.CreditAssessment',
      '10': 'assessment'
    },
  ],
};

/// Descriptor for `GetCreditAssessmentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCreditAssessmentResponseDescriptor =
    $convert.base64Decode(
        'ChtHZXRDcmVkaXRBc3Nlc3NtZW50UmVzcG9uc2USSAoKYXNzZXNzbWVudBgBIAEoCzIoLmFncm'
        'ljdWx0dXJlLmZpbmFuY2UudjEuQ3JlZGl0QXNzZXNzbWVudFIKYXNzZXNzbWVudA==');

@$core.Deprecated('Use fileClaimRequestDescriptor instead')
const FileClaimRequest$json = {
  '1': 'FileClaimRequest',
  '2': [
    {'1': 'quote_id', '3': 1, '4': 1, '5': 9, '10': 'quoteId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'cause',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.LossCause',
      '10': 'cause'
    },
    {
      '1': 'loss_started_on',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lossStartedOn'
    },
    {
      '1': 'loss_ended_on',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lossEndedOn'
    },
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'claimed_area_hectares',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'claimedAreaHectares'
    },
    {
      '1': 'reported_yield_kg_ha',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'reportedYieldKgHa'
    },
  ],
};

/// Descriptor for `FileClaimRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileClaimRequestDescriptor = $convert.base64Decode(
    'ChBGaWxlQ2xhaW1SZXF1ZXN0EhkKCHF1b3RlX2lkGAEgASgJUgdxdW90ZUlkEhkKCGZpZWxkX2'
    'lkGAIgASgJUgdmaWVsZElkEjcKBWNhdXNlGAMgASgOMiEuYWdyaWN1bHR1cmUuZmluYW5jZS52'
    'MS5Mb3NzQ2F1c2VSBWNhdXNlEkIKD2xvc3Nfc3RhcnRlZF9vbhgEIAEoCzIaLmdvb2dsZS5wcm'
    '90b2J1Zi5UaW1lc3RhbXBSDWxvc3NTdGFydGVkT24SPgoNbG9zc19lbmRlZF9vbhgFIAEoCzIa'
    'Lmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSC2xvc3NFbmRlZE9uEiAKC2Rlc2NyaXB0aW9uGA'
    'YgASgJUgtkZXNjcmlwdGlvbhIyChVjbGFpbWVkX2FyZWFfaGVjdGFyZXMYByABKAFSE2NsYWlt'
    'ZWRBcmVhSGVjdGFyZXMSLwoUcmVwb3J0ZWRfeWllbGRfa2dfaGEYCCABKAFSEXJlcG9ydGVkWW'
    'llbGRLZ0hh');

@$core.Deprecated('Use fileClaimResponseDescriptor instead')
const FileClaimResponse$json = {
  '1': 'FileClaimResponse',
  '2': [
    {
      '1': 'claim',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.finance.v1.Claim',
      '10': 'claim'
    },
  ],
};

/// Descriptor for `FileClaimResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fileClaimResponseDescriptor = $convert.base64Decode(
    'ChFGaWxlQ2xhaW1SZXNwb25zZRIzCgVjbGFpbRgBIAEoCzIdLmFncmljdWx0dXJlLmZpbmFuY2'
    'UudjEuQ2xhaW1SBWNsYWlt');

@$core.Deprecated('Use gatherEvidenceRequestDescriptor instead')
const GatherEvidenceRequest$json = {
  '1': 'GatherEvidenceRequest',
  '2': [
    {'1': 'claim_id', '3': 1, '4': 1, '5': 9, '10': 'claimId'},
  ],
};

/// Descriptor for `GatherEvidenceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gatherEvidenceRequestDescriptor =
    $convert.base64Decode(
        'ChVHYXRoZXJFdmlkZW5jZVJlcXVlc3QSGQoIY2xhaW1faWQYASABKAlSB2NsYWltSWQ=');

@$core.Deprecated('Use gatherEvidenceResponseDescriptor instead')
const GatherEvidenceResponse$json = {
  '1': 'GatherEvidenceResponse',
  '2': [
    {
      '1': 'claim',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.finance.v1.Claim',
      '10': 'claim'
    },
  ],
};

/// Descriptor for `GatherEvidenceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gatherEvidenceResponseDescriptor =
    $convert.base64Decode(
        'ChZHYXRoZXJFdmlkZW5jZVJlc3BvbnNlEjMKBWNsYWltGAEgASgLMh0uYWdyaWN1bHR1cmUuZm'
        'luYW5jZS52MS5DbGFpbVIFY2xhaW0=');

@$core.Deprecated('Use getClaimRequestDescriptor instead')
const GetClaimRequest$json = {
  '1': 'GetClaimRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetClaimRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getClaimRequestDescriptor =
    $convert.base64Decode('Cg9HZXRDbGFpbVJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use getClaimResponseDescriptor instead')
const GetClaimResponse$json = {
  '1': 'GetClaimResponse',
  '2': [
    {
      '1': 'claim',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.finance.v1.Claim',
      '10': 'claim'
    },
  ],
};

/// Descriptor for `GetClaimResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getClaimResponseDescriptor = $convert.base64Decode(
    'ChBHZXRDbGFpbVJlc3BvbnNlEjMKBWNsYWltGAEgASgLMh0uYWdyaWN1bHR1cmUuZmluYW5jZS'
    '52MS5DbGFpbVIFY2xhaW0=');

@$core.Deprecated('Use listClaimsRequestDescriptor instead')
const ListClaimsRequest$json = {
  '1': 'ListClaimsRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.ClaimStatus',
      '10': 'status'
    },
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 5, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListClaimsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listClaimsRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0Q2xhaW1zUmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBIXCgdmYXJtX2'
    'lkGAIgASgJUgZmYXJtSWQSOwoGc3RhdHVzGAMgASgOMiMuYWdyaWN1bHR1cmUuZmluYW5jZS52'
    'MS5DbGFpbVN0YXR1c1IGc3RhdHVzEhsKCXBhZ2Vfc2l6ZRgEIAEoBVIIcGFnZVNpemUSHQoKcG'
    'FnZV90b2tlbhgFIAEoCVIJcGFnZVRva2Vu');

@$core.Deprecated('Use listClaimsResponseDescriptor instead')
const ListClaimsResponse$json = {
  '1': 'ListClaimsResponse',
  '2': [
    {
      '1': 'claims',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.finance.v1.Claim',
      '10': 'claims'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListClaimsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listClaimsResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0Q2xhaW1zUmVzcG9uc2USNQoGY2xhaW1zGAEgAygLMh0uYWdyaWN1bHR1cmUuZmluYW'
    '5jZS52MS5DbGFpbVIGY2xhaW1zEiYKD25leHRfcGFnZV90b2tlbhgCIAEoCVINbmV4dFBhZ2VU'
    'b2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use updateClaimStatusRequestDescriptor instead')
const UpdateClaimStatusRequest$json = {
  '1': 'UpdateClaimStatusRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.finance.v1.ClaimStatus',
      '10': 'status'
    },
    {'1': 'note', '3': 3, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `UpdateClaimStatusRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateClaimStatusRequestDescriptor = $convert.base64Decode(
    'ChhVcGRhdGVDbGFpbVN0YXR1c1JlcXVlc3QSDgoCaWQYASABKAlSAmlkEjsKBnN0YXR1cxgCIA'
    'EoDjIjLmFncmljdWx0dXJlLmZpbmFuY2UudjEuQ2xhaW1TdGF0dXNSBnN0YXR1cxISCgRub3Rl'
    'GAMgASgJUgRub3Rl');

@$core.Deprecated('Use updateClaimStatusResponseDescriptor instead')
const UpdateClaimStatusResponse$json = {
  '1': 'UpdateClaimStatusResponse',
  '2': [
    {
      '1': 'claim',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.finance.v1.Claim',
      '10': 'claim'
    },
  ],
};

/// Descriptor for `UpdateClaimStatusResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateClaimStatusResponseDescriptor =
    $convert.base64Decode(
        'ChlVcGRhdGVDbGFpbVN0YXR1c1Jlc3BvbnNlEjMKBWNsYWltGAEgASgLMh0uYWdyaWN1bHR1cm'
        'UuZmluYW5jZS52MS5DbGFpbVIFY2xhaW0=');

const $core.Map<$core.String, $core.dynamic> FinanceServiceBase$json = {
  '1': 'FinanceService',
  '2': [
    {
      '1': 'QuoteInsurance',
      '2': '.agriculture.finance.v1.QuoteInsuranceRequest',
      '3': '.agriculture.finance.v1.QuoteInsuranceResponse'
    },
    {
      '1': 'GetQuote',
      '2': '.agriculture.finance.v1.GetQuoteRequest',
      '3': '.agriculture.finance.v1.GetQuoteResponse'
    },
    {
      '1': 'ListQuotes',
      '2': '.agriculture.finance.v1.ListQuotesRequest',
      '3': '.agriculture.finance.v1.ListQuotesResponse'
    },
    {
      '1': 'AssessCredit',
      '2': '.agriculture.finance.v1.AssessCreditRequest',
      '3': '.agriculture.finance.v1.AssessCreditResponse'
    },
    {
      '1': 'GetCreditAssessment',
      '2': '.agriculture.finance.v1.GetCreditAssessmentRequest',
      '3': '.agriculture.finance.v1.GetCreditAssessmentResponse'
    },
    {
      '1': 'FileClaim',
      '2': '.agriculture.finance.v1.FileClaimRequest',
      '3': '.agriculture.finance.v1.FileClaimResponse'
    },
    {
      '1': 'GatherEvidence',
      '2': '.agriculture.finance.v1.GatherEvidenceRequest',
      '3': '.agriculture.finance.v1.GatherEvidenceResponse'
    },
    {
      '1': 'GetClaim',
      '2': '.agriculture.finance.v1.GetClaimRequest',
      '3': '.agriculture.finance.v1.GetClaimResponse'
    },
    {
      '1': 'ListClaims',
      '2': '.agriculture.finance.v1.ListClaimsRequest',
      '3': '.agriculture.finance.v1.ListClaimsResponse'
    },
    {
      '1': 'UpdateClaimStatus',
      '2': '.agriculture.finance.v1.UpdateClaimStatusRequest',
      '3': '.agriculture.finance.v1.UpdateClaimStatusResponse'
    },
  ],
};

@$core.Deprecated('Use financeServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    FinanceServiceBase$messageJson = {
  '.agriculture.finance.v1.QuoteInsuranceRequest': QuoteInsuranceRequest$json,
  '.agriculture.finance.v1.QuoteInsuranceResponse': QuoteInsuranceResponse$json,
  '.agriculture.finance.v1.InsuranceQuote': InsuranceQuote$json,
  '.agriculture.finance.v1.PremiumLine': PremiumLine$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.finance.v1.GetQuoteRequest': GetQuoteRequest$json,
  '.agriculture.finance.v1.GetQuoteResponse': GetQuoteResponse$json,
  '.agriculture.finance.v1.ListQuotesRequest': ListQuotesRequest$json,
  '.agriculture.finance.v1.ListQuotesResponse': ListQuotesResponse$json,
  '.agriculture.finance.v1.AssessCreditRequest': AssessCreditRequest$json,
  '.agriculture.finance.v1.AssessCreditResponse': AssessCreditResponse$json,
  '.agriculture.finance.v1.CreditAssessment': CreditAssessment$json,
  '.agriculture.finance.v1.ScoreFactor': ScoreFactor$json,
  '.agriculture.finance.v1.GetCreditAssessmentRequest':
      GetCreditAssessmentRequest$json,
  '.agriculture.finance.v1.GetCreditAssessmentResponse':
      GetCreditAssessmentResponse$json,
  '.agriculture.finance.v1.FileClaimRequest': FileClaimRequest$json,
  '.agriculture.finance.v1.FileClaimResponse': FileClaimResponse$json,
  '.agriculture.finance.v1.Claim': Claim$json,
  '.agriculture.finance.v1.Evidence': Evidence$json,
  '.agriculture.finance.v1.GatherEvidenceRequest': GatherEvidenceRequest$json,
  '.agriculture.finance.v1.GatherEvidenceResponse': GatherEvidenceResponse$json,
  '.agriculture.finance.v1.GetClaimRequest': GetClaimRequest$json,
  '.agriculture.finance.v1.GetClaimResponse': GetClaimResponse$json,
  '.agriculture.finance.v1.ListClaimsRequest': ListClaimsRequest$json,
  '.agriculture.finance.v1.ListClaimsResponse': ListClaimsResponse$json,
  '.agriculture.finance.v1.UpdateClaimStatusRequest':
      UpdateClaimStatusRequest$json,
  '.agriculture.finance.v1.UpdateClaimStatusResponse':
      UpdateClaimStatusResponse$json,
};

/// Descriptor for `FinanceService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List financeServiceDescriptor = $convert.base64Decode(
    'Cg5GaW5hbmNlU2VydmljZRJvCg5RdW90ZUluc3VyYW5jZRItLmFncmljdWx0dXJlLmZpbmFuY2'
    'UudjEuUXVvdGVJbnN1cmFuY2VSZXF1ZXN0Gi4uYWdyaWN1bHR1cmUuZmluYW5jZS52MS5RdW90'
    'ZUluc3VyYW5jZVJlc3BvbnNlEl0KCEdldFF1b3RlEicuYWdyaWN1bHR1cmUuZmluYW5jZS52MS'
    '5HZXRRdW90ZVJlcXVlc3QaKC5hZ3JpY3VsdHVyZS5maW5hbmNlLnYxLkdldFF1b3RlUmVzcG9u'
    'c2USYwoKTGlzdFF1b3RlcxIpLmFncmljdWx0dXJlLmZpbmFuY2UudjEuTGlzdFF1b3Rlc1JlcX'
    'Vlc3QaKi5hZ3JpY3VsdHVyZS5maW5hbmNlLnYxLkxpc3RRdW90ZXNSZXNwb25zZRJpCgxBc3Nl'
    'c3NDcmVkaXQSKy5hZ3JpY3VsdHVyZS5maW5hbmNlLnYxLkFzc2Vzc0NyZWRpdFJlcXVlc3QaLC'
    '5hZ3JpY3VsdHVyZS5maW5hbmNlLnYxLkFzc2Vzc0NyZWRpdFJlc3BvbnNlEn4KE0dldENyZWRp'
    'dEFzc2Vzc21lbnQSMi5hZ3JpY3VsdHVyZS5maW5hbmNlLnYxLkdldENyZWRpdEFzc2Vzc21lbn'
    'RSZXF1ZXN0GjMuYWdyaWN1bHR1cmUuZmluYW5jZS52MS5HZXRDcmVkaXRBc3Nlc3NtZW50UmVz'
    'cG9uc2USYAoJRmlsZUNsYWltEiguYWdyaWN1bHR1cmUuZmluYW5jZS52MS5GaWxlQ2xhaW1SZX'
    'F1ZXN0GikuYWdyaWN1bHR1cmUuZmluYW5jZS52MS5GaWxlQ2xhaW1SZXNwb25zZRJvCg5HYXRo'
    'ZXJFdmlkZW5jZRItLmFncmljdWx0dXJlLmZpbmFuY2UudjEuR2F0aGVyRXZpZGVuY2VSZXF1ZX'
    'N0Gi4uYWdyaWN1bHR1cmUuZmluYW5jZS52MS5HYXRoZXJFdmlkZW5jZVJlc3BvbnNlEl0KCEdl'
    'dENsYWltEicuYWdyaWN1bHR1cmUuZmluYW5jZS52MS5HZXRDbGFpbVJlcXVlc3QaKC5hZ3JpY3'
    'VsdHVyZS5maW5hbmNlLnYxLkdldENsYWltUmVzcG9uc2USYwoKTGlzdENsYWltcxIpLmFncmlj'
    'dWx0dXJlLmZpbmFuY2UudjEuTGlzdENsYWltc1JlcXVlc3QaKi5hZ3JpY3VsdHVyZS5maW5hbm'
    'NlLnYxLkxpc3RDbGFpbXNSZXNwb25zZRJ4ChFVcGRhdGVDbGFpbVN0YXR1cxIwLmFncmljdWx0'
    'dXJlLmZpbmFuY2UudjEuVXBkYXRlQ2xhaW1TdGF0dXNSZXF1ZXN0GjEuYWdyaWN1bHR1cmUuZm'
    'luYW5jZS52MS5VcGRhdGVDbGFpbVN0YXR1c1Jlc3BvbnNl');
