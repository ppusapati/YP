// This is a generated file - do not edit.
//
// Generated from assistant.proto.

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

@$core.Deprecated('Use localeDescriptor instead')
const Locale$json = {
  '1': 'Locale',
  '2': [
    {'1': 'LOCALE_UNSPECIFIED', '2': 0},
    {'1': 'LOCALE_EN', '2': 1},
    {'1': 'LOCALE_HI', '2': 2},
    {'1': 'LOCALE_MR', '2': 3},
    {'1': 'LOCALE_TE', '2': 4},
    {'1': 'LOCALE_TA', '2': 5},
    {'1': 'LOCALE_KN', '2': 6},
    {'1': 'LOCALE_PA', '2': 7},
    {'1': 'LOCALE_BN', '2': 8},
  ],
};

/// Descriptor for `Locale`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List localeDescriptor = $convert.base64Decode(
    'CgZMb2NhbGUSFgoSTE9DQUxFX1VOU1BFQ0lGSUVEEAASDQoJTE9DQUxFX0VOEAESDQoJTE9DQU'
    'xFX0hJEAISDQoJTE9DQUxFX01SEAMSDQoJTE9DQUxFX1RFEAQSDQoJTE9DQUxFX1RBEAUSDQoJ'
    'TE9DQUxFX0tOEAYSDQoJTE9DQUxFX1BBEAcSDQoJTE9DQUxFX0JOEAg=');

@$core.Deprecated('Use citationKindDescriptor instead')
const CitationKind$json = {
  '1': 'CitationKind',
  '2': [
    {'1': 'CITATION_KIND_UNSPECIFIED', '2': 0},
    {'1': 'CITATION_KIND_DOCUMENT', '2': 1},
    {'1': 'CITATION_KIND_FIELD', '2': 2},
    {'1': 'CITATION_KIND_PRESCRIPTION', '2': 3},
    {'1': 'CITATION_KIND_ALERT', '2': 4},
    {'1': 'CITATION_KIND_WEATHER', '2': 5},
    {'1': 'CITATION_KIND_DIAGNOSIS', '2': 6},
    {'1': 'CITATION_KIND_YIELD_FORECAST', '2': 7},
    {'1': 'CITATION_KIND_IRRIGATION', '2': 8},
    {'1': 'CITATION_KIND_PEST_RISK', '2': 9},
    {'1': 'CITATION_KIND_SOIL', '2': 10},
  ],
};

/// Descriptor for `CitationKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List citationKindDescriptor = $convert.base64Decode(
    'CgxDaXRhdGlvbktpbmQSHQoZQ0lUQVRJT05fS0lORF9VTlNQRUNJRklFRBAAEhoKFkNJVEFUSU'
    '9OX0tJTkRfRE9DVU1FTlQQARIXChNDSVRBVElPTl9LSU5EX0ZJRUxEEAISHgoaQ0lUQVRJT05f'
    'S0lORF9QUkVTQ1JJUFRJT04QAxIXChNDSVRBVElPTl9LSU5EX0FMRVJUEAQSGQoVQ0lUQVRJT0'
    '5fS0lORF9XRUFUSEVSEAUSGwoXQ0lUQVRJT05fS0lORF9ESUFHTk9TSVMQBhIgChxDSVRBVElP'
    'Tl9LSU5EX1lJRUxEX0ZPUkVDQVNUEAcSHAoYQ0lUQVRJT05fS0lORF9JUlJJR0FUSU9OEAgSGw'
    'oXQ0lUQVRJT05fS0lORF9QRVNUX1JJU0sQCRIWChJDSVRBVElPTl9LSU5EX1NPSUwQCg==');

@$core.Deprecated('Use answerKindDescriptor instead')
const AnswerKind$json = {
  '1': 'AnswerKind',
  '2': [
    {'1': 'ANSWER_KIND_UNSPECIFIED', '2': 0},
    {'1': 'ANSWER_KIND_GENERATED', '2': 1},
    {'1': 'ANSWER_KIND_EXTRACTIVE', '2': 2},
    {'1': 'ANSWER_KIND_REFUSED', '2': 3},
  ],
};

/// Descriptor for `AnswerKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List answerKindDescriptor = $convert.base64Decode(
    'CgpBbnN3ZXJLaW5kEhsKF0FOU1dFUl9LSU5EX1VOU1BFQ0lGSUVEEAASGQoVQU5TV0VSX0tJTk'
    'RfR0VORVJBVEVEEAESGgoWQU5TV0VSX0tJTkRfRVhUUkFDVElWRRACEhcKE0FOU1dFUl9LSU5E'
    'X1JFRlVTRUQQAw==');

@$core.Deprecated('Use groundednessVerdictDescriptor instead')
const GroundednessVerdict$json = {
  '1': 'GroundednessVerdict',
  '2': [
    {'1': 'GROUNDEDNESS_VERDICT_UNSPECIFIED', '2': 0},
    {'1': 'GROUNDEDNESS_VERDICT_GROUNDED', '2': 1},
    {'1': 'GROUNDEDNESS_VERDICT_PARTIAL', '2': 2},
    {'1': 'GROUNDEDNESS_VERDICT_UNGROUNDED', '2': 3},
  ],
};

/// Descriptor for `GroundednessVerdict`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List groundednessVerdictDescriptor = $convert.base64Decode(
    'ChNHcm91bmRlZG5lc3NWZXJkaWN0EiQKIEdST1VOREVETkVTU19WRVJESUNUX1VOU1BFQ0lGSU'
    'VEEAASIQodR1JPVU5ERURORVNTX1ZFUkRJQ1RfR1JPVU5ERUQQARIgChxHUk9VTkRFRE5FU1Nf'
    'VkVSRElDVF9QQVJUSUFMEAISIwofR1JPVU5ERURORVNTX1ZFUkRJQ1RfVU5HUk9VTkRFRBAD');

@$core.Deprecated('Use documentKindDescriptor instead')
const DocumentKind$json = {
  '1': 'DocumentKind',
  '2': [
    {'1': 'DOCUMENT_KIND_UNSPECIFIED', '2': 0},
    {'1': 'DOCUMENT_KIND_AGRONOMY_REFERENCE', '2': 1},
    {'1': 'DOCUMENT_KIND_CROP_GUIDE', '2': 2},
    {'1': 'DOCUMENT_KIND_REGIONAL_ADVISORY', '2': 3},
    {'1': 'DOCUMENT_KIND_PACKAGE_OF_PRACTICES', '2': 4},
  ],
};

/// Descriptor for `DocumentKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List documentKindDescriptor = $convert.base64Decode(
    'CgxEb2N1bWVudEtpbmQSHQoZRE9DVU1FTlRfS0lORF9VTlNQRUNJRklFRBAAEiQKIERPQ1VNRU'
    '5UX0tJTkRfQUdST05PTVlfUkVGRVJFTkNFEAESHAoYRE9DVU1FTlRfS0lORF9DUk9QX0dVSURF'
    'EAISIwofRE9DVU1FTlRfS0lORF9SRUdJT05BTF9BRFZJU09SWRADEiYKIkRPQ1VNRU5UX0tJTk'
    'RfUEFDS0FHRV9PRl9QUkFDVElDRVMQBA==');

@$core.Deprecated('Use citationDescriptor instead')
const Citation$json = {
  '1': 'Citation',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'kind',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.advisory.v1.CitationKind',
      '10': 'kind'
    },
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'snippet', '3': 4, '4': 1, '5': 9, '10': 'snippet'},
    {'1': 'uri', '3': 5, '4': 1, '5': 9, '10': 'uri'},
    {'1': 'source_id', '3': 6, '4': 1, '5': 9, '10': 'sourceId'},
    {'1': 'score', '3': 7, '4': 1, '5': 1, '10': 'score'},
    {'1': 'marker', '3': 8, '4': 1, '5': 5, '10': 'marker'},
    {
      '1': 'locale',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.agriculture.advisory.v1.Locale',
      '10': 'locale'
    },
  ],
};

/// Descriptor for `Citation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List citationDescriptor = $convert.base64Decode(
    'CghDaXRhdGlvbhIOCgJpZBgBIAEoCVICaWQSOQoEa2luZBgCIAEoDjIlLmFncmljdWx0dXJlLm'
    'Fkdmlzb3J5LnYxLkNpdGF0aW9uS2luZFIEa2luZBIUCgV0aXRsZRgDIAEoCVIFdGl0bGUSGAoH'
    'c25pcHBldBgEIAEoCVIHc25pcHBldBIQCgN1cmkYBSABKAlSA3VyaRIbCglzb3VyY2VfaWQYBi'
    'ABKAlSCHNvdXJjZUlkEhQKBXNjb3JlGAcgASgBUgVzY29yZRIWCgZtYXJrZXIYCCABKAVSBm1h'
    'cmtlchI3CgZsb2NhbGUYCSABKA4yHy5hZ3JpY3VsdHVyZS5hZHZpc29yeS52MS5Mb2NhbGVSBm'
    'xvY2FsZQ==');

@$core.Deprecated('Use toolCallDescriptor instead')
const ToolCall$json = {
  '1': 'ToolCall',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'arguments_json', '3': 2, '4': 1, '5': 9, '10': 'argumentsJson'},
    {'1': 'result_json', '3': 3, '4': 1, '5': 9, '10': 'resultJson'},
    {'1': 'ok', '3': 4, '4': 1, '5': 8, '10': 'ok'},
    {'1': 'error', '3': 5, '4': 1, '5': 9, '10': 'error'},
    {'1': 'latency_ms', '3': 6, '4': 1, '5': 3, '10': 'latencyMs'},
  ],
};

/// Descriptor for `ToolCall`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List toolCallDescriptor = $convert.base64Decode(
    'CghUb29sQ2FsbBISCgRuYW1lGAEgASgJUgRuYW1lEiUKDmFyZ3VtZW50c19qc29uGAIgASgJUg'
    '1hcmd1bWVudHNKc29uEh8KC3Jlc3VsdF9qc29uGAMgASgJUgpyZXN1bHRKc29uEg4KAm9rGAQg'
    'ASgIUgJvaxIUCgVlcnJvchgFIAEoCVIFZXJyb3ISHQoKbGF0ZW5jeV9tcxgGIAEoA1IJbGF0ZW'
    '5jeU1z');

@$core.Deprecated('Use unsupportedClaimDescriptor instead')
const UnsupportedClaim$json = {
  '1': 'UnsupportedClaim',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `UnsupportedClaim`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unsupportedClaimDescriptor = $convert.base64Decode(
    'ChBVbnN1cHBvcnRlZENsYWltEhIKBHRleHQYASABKAlSBHRleHQSFgoGcmVhc29uGAIgASgJUg'
    'ZyZWFzb24=');

@$core.Deprecated('Use evaluationDescriptor instead')
const Evaluation$json = {
  '1': 'Evaluation',
  '2': [
    {
      '1': 'verdict',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.agriculture.advisory.v1.GroundednessVerdict',
      '10': 'verdict'
    },
    {'1': 'groundedness', '3': 2, '4': 1, '5': 1, '10': 'groundedness'},
    {
      '1': 'unsupported',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.agriculture.advisory.v1.UnsupportedClaim',
      '10': 'unsupported'
    },
    {
      '1': 'unsupported_numbers',
      '3': 4,
      '4': 3,
      '5': 9,
      '10': 'unsupportedNumbers'
    },
    {'1': 'needs_review', '3': 5, '4': 1, '5': 8, '10': 'needsReview'},
    {'1': 'notes', '3': 6, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `Evaluation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List evaluationDescriptor = $convert.base64Decode(
    'CgpFdmFsdWF0aW9uEkYKB3ZlcmRpY3QYASABKA4yLC5hZ3JpY3VsdHVyZS5hZHZpc29yeS52MS'
    '5Hcm91bmRlZG5lc3NWZXJkaWN0Ugd2ZXJkaWN0EiIKDGdyb3VuZGVkbmVzcxgCIAEoAVIMZ3Jv'
    'dW5kZWRuZXNzEksKC3Vuc3VwcG9ydGVkGAMgAygLMikuYWdyaWN1bHR1cmUuYWR2aXNvcnkudj'
    'EuVW5zdXBwb3J0ZWRDbGFpbVILdW5zdXBwb3J0ZWQSLwoTdW5zdXBwb3J0ZWRfbnVtYmVycxgE'
    'IAMoCVISdW5zdXBwb3J0ZWROdW1iZXJzEiEKDG5lZWRzX3JldmlldxgFIAEoCFILbmVlZHNSZX'
    'ZpZXcSFAoFbm90ZXMYBiABKAlSBW5vdGVz');

@$core.Deprecated('Use usageDescriptor instead')
const Usage$json = {
  '1': 'Usage',
  '2': [
    {'1': 'prompt_tokens', '3': 1, '4': 1, '5': 5, '10': 'promptTokens'},
    {
      '1': 'completion_tokens',
      '3': 2,
      '4': 1,
      '5': 5,
      '10': 'completionTokens'
    },
    {'1': 'latency_ms', '3': 3, '4': 1, '5': 3, '10': 'latencyMs'},
    {'1': 'cost_micros', '3': 4, '4': 1, '5': 3, '10': 'costMicros'},
    {'1': 'model', '3': 5, '4': 1, '5': 9, '10': 'model'},
  ],
};

/// Descriptor for `Usage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List usageDescriptor = $convert.base64Decode(
    'CgVVc2FnZRIjCg1wcm9tcHRfdG9rZW5zGAEgASgFUgxwcm9tcHRUb2tlbnMSKwoRY29tcGxldG'
    'lvbl90b2tlbnMYAiABKAVSEGNvbXBsZXRpb25Ub2tlbnMSHQoKbGF0ZW5jeV9tcxgDIAEoA1IJ'
    'bGF0ZW5jeU1zEh8KC2Nvc3RfbWljcm9zGAQgASgDUgpjb3N0TWljcm9zEhQKBW1vZGVsGAUgAS'
    'gJUgVtb2RlbA==');

@$core.Deprecated('Use exchangeDescriptor instead')
const Exchange$json = {
  '1': 'Exchange',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'conversation_id', '3': 2, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'question', '3': 3, '4': 1, '5': 9, '10': 'question'},
    {'1': 'answer', '3': 4, '4': 1, '5': 9, '10': 'answer'},
    {
      '1': 'locale',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.advisory.v1.Locale',
      '10': 'locale'
    },
    {
      '1': 'answer_kind',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.advisory.v1.AnswerKind',
      '10': 'answerKind'
    },
    {
      '1': 'citations',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.agriculture.advisory.v1.Citation',
      '10': 'citations'
    },
    {
      '1': 'tool_calls',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.agriculture.advisory.v1.ToolCall',
      '10': 'toolCalls'
    },
    {
      '1': 'evaluation',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.agriculture.advisory.v1.Evaluation',
      '10': 'evaluation'
    },
    {
      '1': 'usage',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.agriculture.advisory.v1.Usage',
      '10': 'usage'
    },
    {'1': 'asked_by', '3': 11, '4': 1, '5': 9, '10': 'askedBy'},
    {
      '1': 'created_at',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {'1': 'reviewed', '3': 13, '4': 1, '5': 8, '10': 'reviewed'},
    {'1': 'reviewer_note', '3': 14, '4': 1, '5': 9, '10': 'reviewerNote'},
    {'1': 'rating', '3': 15, '4': 1, '5': 5, '10': 'rating'},
    {'1': 'reviewed_by', '3': 16, '4': 1, '5': 9, '10': 'reviewedBy'},
    {
      '1': 'reviewed_at',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'reviewedAt'
    },
  ],
};

/// Descriptor for `Exchange`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exchangeDescriptor = $convert.base64Decode(
    'CghFeGNoYW5nZRIOCgJpZBgBIAEoCVICaWQSJwoPY29udmVyc2F0aW9uX2lkGAIgASgJUg5jb2'
    '52ZXJzYXRpb25JZBIaCghxdWVzdGlvbhgDIAEoCVIIcXVlc3Rpb24SFgoGYW5zd2VyGAQgASgJ'
    'UgZhbnN3ZXISNwoGbG9jYWxlGAUgASgOMh8uYWdyaWN1bHR1cmUuYWR2aXNvcnkudjEuTG9jYW'
    'xlUgZsb2NhbGUSRAoLYW5zd2VyX2tpbmQYBiABKA4yIy5hZ3JpY3VsdHVyZS5hZHZpc29yeS52'
    'MS5BbnN3ZXJLaW5kUgphbnN3ZXJLaW5kEj8KCWNpdGF0aW9ucxgHIAMoCzIhLmFncmljdWx0dX'
    'JlLmFkdmlzb3J5LnYxLkNpdGF0aW9uUgljaXRhdGlvbnMSQAoKdG9vbF9jYWxscxgIIAMoCzIh'
    'LmFncmljdWx0dXJlLmFkdmlzb3J5LnYxLlRvb2xDYWxsUgl0b29sQ2FsbHMSQwoKZXZhbHVhdG'
    'lvbhgJIAEoCzIjLmFncmljdWx0dXJlLmFkdmlzb3J5LnYxLkV2YWx1YXRpb25SCmV2YWx1YXRp'
    'b24SNAoFdXNhZ2UYCiABKAsyHi5hZ3JpY3VsdHVyZS5hZHZpc29yeS52MS5Vc2FnZVIFdXNhZ2'
    'USGQoIYXNrZWRfYnkYCyABKAlSB2Fza2VkQnkSOQoKY3JlYXRlZF9hdBgMIAEoCzIaLmdvb2ds'
    'ZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBIaCghyZXZpZXdlZBgNIAEoCFIIcmV2aW'
    'V3ZWQSIwoNcmV2aWV3ZXJfbm90ZRgOIAEoCVIMcmV2aWV3ZXJOb3RlEhYKBnJhdGluZxgPIAEo'
    'BVIGcmF0aW5nEh8KC3Jldmlld2VkX2J5GBAgASgJUgpyZXZpZXdlZEJ5EjsKC3Jldmlld2VkX2'
    'F0GBEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIKcmV2aWV3ZWRBdA==');

@$core.Deprecated('Use conversationDescriptor instead')
const Conversation$json = {
  '1': 'Conversation',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'locale',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.advisory.v1.Locale',
      '10': 'locale'
    },
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
    {'1': 'exchange_count', '3': 8, '4': 1, '5': 5, '10': 'exchangeCount'},
  ],
};

/// Descriptor for `Conversation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationDescriptor = $convert.base64Decode(
    'CgxDb252ZXJzYXRpb24SDgoCaWQYASABKAlSAmlkEhQKBXRpdGxlGAIgASgJUgV0aXRsZRIZCg'
    'hmaWVsZF9pZBgDIAEoCVIHZmllbGRJZBIXCgdmYXJtX2lkGAQgASgJUgZmYXJtSWQSNwoGbG9j'
    'YWxlGAUgASgOMh8uYWdyaWN1bHR1cmUuYWR2aXNvcnkudjEuTG9jYWxlUgZsb2NhbGUSOQoKY3'
    'JlYXRlZF9hdBgGIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5'
    'Cgp1cGRhdGVkX2F0GAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZE'
    'F0EiUKDmV4Y2hhbmdlX2NvdW50GAggASgFUg1leGNoYW5nZUNvdW50');

@$core.Deprecated('Use referenceDocumentDescriptor instead')
const ReferenceDocument$json = {
  '1': 'ReferenceDocument',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {
      '1': 'kind',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.advisory.v1.DocumentKind',
      '10': 'kind'
    },
    {
      '1': 'locale',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.advisory.v1.Locale',
      '10': 'locale'
    },
    {'1': 'source', '3': 5, '4': 1, '5': 9, '10': 'source'},
    {'1': 'uri', '3': 6, '4': 1, '5': 9, '10': 'uri'},
    {'1': 'crops', '3': 7, '4': 3, '5': 9, '10': 'crops'},
    {'1': 'region', '3': 8, '4': 1, '5': 9, '10': 'region'},
    {'1': 'chunk_count', '3': 9, '4': 1, '5': 5, '10': 'chunkCount'},
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

/// Descriptor for `ReferenceDocument`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List referenceDocumentDescriptor = $convert.base64Decode(
    'ChFSZWZlcmVuY2VEb2N1bWVudBIOCgJpZBgBIAEoCVICaWQSFAoFdGl0bGUYAiABKAlSBXRpdG'
    'xlEjkKBGtpbmQYAyABKA4yJS5hZ3JpY3VsdHVyZS5hZHZpc29yeS52MS5Eb2N1bWVudEtpbmRS'
    'BGtpbmQSNwoGbG9jYWxlGAQgASgOMh8uYWdyaWN1bHR1cmUuYWR2aXNvcnkudjEuTG9jYWxlUg'
    'Zsb2NhbGUSFgoGc291cmNlGAUgASgJUgZzb3VyY2USEAoDdXJpGAYgASgJUgN1cmkSFAoFY3Jv'
    'cHMYByADKAlSBWNyb3BzEhYKBnJlZ2lvbhgIIAEoCVIGcmVnaW9uEh8KC2NodW5rX2NvdW50GA'
    'kgASgFUgpjaHVua0NvdW50EjkKCmNyZWF0ZWRfYXQYCiABKAsyGi5nb29nbGUucHJvdG9idWYu'
    'VGltZXN0YW1wUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use tenantBudgetDescriptor instead')
const TenantBudget$json = {
  '1': 'TenantBudget',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'daily_cost_micros', '3': 2, '4': 1, '5': 3, '10': 'dailyCostMicros'},
    {
      '1': 'daily_question_limit',
      '3': 3,
      '4': 1,
      '5': 5,
      '10': 'dailyQuestionLimit'
    },
    {
      '1': 'request_latency_budget_ms',
      '3': 4,
      '4': 1,
      '5': 3,
      '10': 'requestLatencyBudgetMs'
    },
    {'1': 'spent_cost_micros', '3': 5, '4': 1, '5': 3, '10': 'spentCostMicros'},
    {'1': 'spent_questions', '3': 6, '4': 1, '5': 5, '10': 'spentQuestions'},
    {'1': 'exhausted', '3': 7, '4': 1, '5': 8, '10': 'exhausted'},
    {
      '1': 'window_resets_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'windowResetsAt'
    },
  ],
};

/// Descriptor for `TenantBudget`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tenantBudgetDescriptor = $convert.base64Decode(
    'CgxUZW5hbnRCdWRnZXQSGwoJdGVuYW50X2lkGAEgASgJUgh0ZW5hbnRJZBIqChFkYWlseV9jb3'
    'N0X21pY3JvcxgCIAEoA1IPZGFpbHlDb3N0TWljcm9zEjAKFGRhaWx5X3F1ZXN0aW9uX2xpbWl0'
    'GAMgASgFUhJkYWlseVF1ZXN0aW9uTGltaXQSOQoZcmVxdWVzdF9sYXRlbmN5X2J1ZGdldF9tcx'
    'gEIAEoA1IWcmVxdWVzdExhdGVuY3lCdWRnZXRNcxIqChFzcGVudF9jb3N0X21pY3JvcxgFIAEo'
    'A1IPc3BlbnRDb3N0TWljcm9zEicKD3NwZW50X3F1ZXN0aW9ucxgGIAEoBVIOc3BlbnRRdWVzdG'
    'lvbnMSHAoJZXhoYXVzdGVkGAcgASgIUglleGhhdXN0ZWQSRAoQd2luZG93X3Jlc2V0c19hdBgI'
    'IAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSDndpbmRvd1Jlc2V0c0F0');

@$core.Deprecated('Use askRequestDescriptor instead')
const AskRequest$json = {
  '1': 'AskRequest',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'question', '3': 2, '4': 1, '5': 9, '10': 'question'},
    {
      '1': 'locale',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.advisory.v1.Locale',
      '10': 'locale'
    },
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 5, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'disable_tools', '3': 6, '4': 1, '5': 8, '10': 'disableTools'},
  ],
};

/// Descriptor for `AskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List askRequestDescriptor = $convert.base64Decode(
    'CgpBc2tSZXF1ZXN0EicKD2NvbnZlcnNhdGlvbl9pZBgBIAEoCVIOY29udmVyc2F0aW9uSWQSGg'
    'oIcXVlc3Rpb24YAiABKAlSCHF1ZXN0aW9uEjcKBmxvY2FsZRgDIAEoDjIfLmFncmljdWx0dXJl'
    'LmFkdmlzb3J5LnYxLkxvY2FsZVIGbG9jYWxlEhkKCGZpZWxkX2lkGAQgASgJUgdmaWVsZElkEh'
    'cKB2Zhcm1faWQYBSABKAlSBmZhcm1JZBIjCg1kaXNhYmxlX3Rvb2xzGAYgASgIUgxkaXNhYmxl'
    'VG9vbHM=');

@$core.Deprecated('Use askResponseDescriptor instead')
const AskResponse$json = {
  '1': 'AskResponse',
  '2': [
    {'1': 'conversation_id', '3': 1, '4': 1, '5': 9, '10': 'conversationId'},
    {
      '1': 'exchange',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.agriculture.advisory.v1.Exchange',
      '10': 'exchange'
    },
    {
      '1': 'budget',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.agriculture.advisory.v1.TenantBudget',
      '10': 'budget'
    },
  ],
};

/// Descriptor for `AskResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List askResponseDescriptor = $convert.base64Decode(
    'CgtBc2tSZXNwb25zZRInCg9jb252ZXJzYXRpb25faWQYASABKAlSDmNvbnZlcnNhdGlvbklkEj'
    '0KCGV4Y2hhbmdlGAIgASgLMiEuYWdyaWN1bHR1cmUuYWR2aXNvcnkudjEuRXhjaGFuZ2VSCGV4'
    'Y2hhbmdlEj0KBmJ1ZGdldBgDIAEoCzIlLmFncmljdWx0dXJlLmFkdmlzb3J5LnYxLlRlbmFudE'
    'J1ZGdldFIGYnVkZ2V0');

@$core.Deprecated('Use getConversationRequestDescriptor instead')
const GetConversationRequest$json = {
  '1': 'GetConversationRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetConversationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getConversationRequestDescriptor = $convert
    .base64Decode('ChZHZXRDb252ZXJzYXRpb25SZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use getConversationResponseDescriptor instead')
const GetConversationResponse$json = {
  '1': 'GetConversationResponse',
  '2': [
    {
      '1': 'conversation',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.advisory.v1.Conversation',
      '10': 'conversation'
    },
    {
      '1': 'exchanges',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.advisory.v1.Exchange',
      '10': 'exchanges'
    },
  ],
};

/// Descriptor for `GetConversationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getConversationResponseDescriptor = $convert.base64Decode(
    'ChdHZXRDb252ZXJzYXRpb25SZXNwb25zZRJJCgxjb252ZXJzYXRpb24YASABKAsyJS5hZ3JpY3'
    'VsdHVyZS5hZHZpc29yeS52MS5Db252ZXJzYXRpb25SDGNvbnZlcnNhdGlvbhI/CglleGNoYW5n'
    'ZXMYAiADKAsyIS5hZ3JpY3VsdHVyZS5hZHZpc29yeS52MS5FeGNoYW5nZVIJZXhjaGFuZ2Vz');

@$core.Deprecated('Use listConversationsRequestDescriptor instead')
const ListConversationsRequest$json = {
  '1': 'ListConversationsRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 4, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListConversationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listConversationsRequestDescriptor = $convert.base64Decode(
    'ChhMaXN0Q29udmVyc2F0aW9uc1JlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQSFw'
    'oHZmFybV9pZBgCIAEoCVIGZmFybUlkEhsKCXBhZ2Vfc2l6ZRgDIAEoBVIIcGFnZVNpemUSHwoL'
    'cGFnZV9vZmZzZXQYBCABKAVSCnBhZ2VPZmZzZXQ=');

@$core.Deprecated('Use listConversationsResponseDescriptor instead')
const ListConversationsResponse$json = {
  '1': 'ListConversationsResponse',
  '2': [
    {
      '1': 'conversations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.advisory.v1.Conversation',
      '10': 'conversations'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListConversationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listConversationsResponseDescriptor = $convert.base64Decode(
    'ChlMaXN0Q29udmVyc2F0aW9uc1Jlc3BvbnNlEksKDWNvbnZlcnNhdGlvbnMYASADKAsyJS5hZ3'
    'JpY3VsdHVyZS5hZHZpc29yeS52MS5Db252ZXJzYXRpb25SDWNvbnZlcnNhdGlvbnMSHwoLdG90'
    'YWxfY291bnQYAiABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use listExchangesRequestDescriptor instead')
const ListExchangesRequest$json = {
  '1': 'ListExchangesRequest',
  '2': [
    {'1': 'needs_review_only', '3': 1, '4': 1, '5': 8, '10': 'needsReviewOnly'},
    {'1': 'unreviewed_only', '3': 2, '4': 1, '5': 8, '10': 'unreviewedOnly'},
    {'1': 'conversation_id', '3': 3, '4': 1, '5': 9, '10': 'conversationId'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 5, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListExchangesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listExchangesRequestDescriptor = $convert.base64Decode(
    'ChRMaXN0RXhjaGFuZ2VzUmVxdWVzdBIqChFuZWVkc19yZXZpZXdfb25seRgBIAEoCFIPbmVlZH'
    'NSZXZpZXdPbmx5EicKD3VucmV2aWV3ZWRfb25seRgCIAEoCFIOdW5yZXZpZXdlZE9ubHkSJwoP'
    'Y29udmVyc2F0aW9uX2lkGAMgASgJUg5jb252ZXJzYXRpb25JZBIbCglwYWdlX3NpemUYBCABKA'
    'VSCHBhZ2VTaXplEh8KC3BhZ2Vfb2Zmc2V0GAUgASgFUgpwYWdlT2Zmc2V0');

@$core.Deprecated('Use listExchangesResponseDescriptor instead')
const ListExchangesResponse$json = {
  '1': 'ListExchangesResponse',
  '2': [
    {
      '1': 'exchanges',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.advisory.v1.Exchange',
      '10': 'exchanges'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListExchangesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listExchangesResponseDescriptor = $convert.base64Decode(
    'ChVMaXN0RXhjaGFuZ2VzUmVzcG9uc2USPwoJZXhjaGFuZ2VzGAEgAygLMiEuYWdyaWN1bHR1cm'
    'UuYWR2aXNvcnkudjEuRXhjaGFuZ2VSCWV4Y2hhbmdlcxIfCgt0b3RhbF9jb3VudBgCIAEoBVIK'
    'dG90YWxDb3VudA==');

@$core.Deprecated('Use reviewExchangeRequestDescriptor instead')
const ReviewExchangeRequest$json = {
  '1': 'ReviewExchangeRequest',
  '2': [
    {'1': 'exchange_id', '3': 1, '4': 1, '5': 9, '10': 'exchangeId'},
    {'1': 'note', '3': 2, '4': 1, '5': 9, '10': 'note'},
    {'1': 'rating', '3': 3, '4': 1, '5': 5, '10': 'rating'},
  ],
};

/// Descriptor for `ReviewExchangeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reviewExchangeRequestDescriptor = $convert.base64Decode(
    'ChVSZXZpZXdFeGNoYW5nZVJlcXVlc3QSHwoLZXhjaGFuZ2VfaWQYASABKAlSCmV4Y2hhbmdlSW'
    'QSEgoEbm90ZRgCIAEoCVIEbm90ZRIWCgZyYXRpbmcYAyABKAVSBnJhdGluZw==');

@$core.Deprecated('Use reviewExchangeResponseDescriptor instead')
const ReviewExchangeResponse$json = {
  '1': 'ReviewExchangeResponse',
  '2': [
    {
      '1': 'exchange',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.advisory.v1.Exchange',
      '10': 'exchange'
    },
  ],
};

/// Descriptor for `ReviewExchangeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reviewExchangeResponseDescriptor =
    $convert.base64Decode(
        'ChZSZXZpZXdFeGNoYW5nZVJlc3BvbnNlEj0KCGV4Y2hhbmdlGAEgASgLMiEuYWdyaWN1bHR1cm'
        'UuYWR2aXNvcnkudjEuRXhjaGFuZ2VSCGV4Y2hhbmdl');

@$core.Deprecated('Use getTenantBudgetRequestDescriptor instead')
const GetTenantBudgetRequest$json = {
  '1': 'GetTenantBudgetRequest',
};

/// Descriptor for `GetTenantBudgetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTenantBudgetRequestDescriptor =
    $convert.base64Decode('ChZHZXRUZW5hbnRCdWRnZXRSZXF1ZXN0');

@$core.Deprecated('Use getTenantBudgetResponseDescriptor instead')
const GetTenantBudgetResponse$json = {
  '1': 'GetTenantBudgetResponse',
  '2': [
    {
      '1': 'budget',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.advisory.v1.TenantBudget',
      '10': 'budget'
    },
  ],
};

/// Descriptor for `GetTenantBudgetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTenantBudgetResponseDescriptor =
    $convert.base64Decode(
        'ChdHZXRUZW5hbnRCdWRnZXRSZXNwb25zZRI9CgZidWRnZXQYASABKAsyJS5hZ3JpY3VsdHVyZS'
        '5hZHZpc29yeS52MS5UZW5hbnRCdWRnZXRSBmJ1ZGdldA==');

@$core.Deprecated('Use setTenantBudgetRequestDescriptor instead')
const SetTenantBudgetRequest$json = {
  '1': 'SetTenantBudgetRequest',
  '2': [
    {'1': 'daily_cost_micros', '3': 1, '4': 1, '5': 3, '10': 'dailyCostMicros'},
    {
      '1': 'daily_question_limit',
      '3': 2,
      '4': 1,
      '5': 5,
      '10': 'dailyQuestionLimit'
    },
    {
      '1': 'request_latency_budget_ms',
      '3': 3,
      '4': 1,
      '5': 3,
      '10': 'requestLatencyBudgetMs'
    },
  ],
};

/// Descriptor for `SetTenantBudgetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setTenantBudgetRequestDescriptor = $convert.base64Decode(
    'ChZTZXRUZW5hbnRCdWRnZXRSZXF1ZXN0EioKEWRhaWx5X2Nvc3RfbWljcm9zGAEgASgDUg9kYW'
    'lseUNvc3RNaWNyb3MSMAoUZGFpbHlfcXVlc3Rpb25fbGltaXQYAiABKAVSEmRhaWx5UXVlc3Rp'
    'b25MaW1pdBI5ChlyZXF1ZXN0X2xhdGVuY3lfYnVkZ2V0X21zGAMgASgDUhZyZXF1ZXN0TGF0ZW'
    '5jeUJ1ZGdldE1z');

@$core.Deprecated('Use setTenantBudgetResponseDescriptor instead')
const SetTenantBudgetResponse$json = {
  '1': 'SetTenantBudgetResponse',
  '2': [
    {
      '1': 'budget',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.advisory.v1.TenantBudget',
      '10': 'budget'
    },
  ],
};

/// Descriptor for `SetTenantBudgetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List setTenantBudgetResponseDescriptor =
    $convert.base64Decode(
        'ChdTZXRUZW5hbnRCdWRnZXRSZXNwb25zZRI9CgZidWRnZXQYASABKAsyJS5hZ3JpY3VsdHVyZS'
        '5hZHZpc29yeS52MS5UZW5hbnRCdWRnZXRSBmJ1ZGdldA==');

@$core.Deprecated('Use ingestDocumentRequestDescriptor instead')
const IngestDocumentRequest$json = {
  '1': 'IngestDocumentRequest',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {
      '1': 'kind',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.advisory.v1.DocumentKind',
      '10': 'kind'
    },
    {
      '1': 'locale',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.advisory.v1.Locale',
      '10': 'locale'
    },
    {'1': 'source', '3': 4, '4': 1, '5': 9, '10': 'source'},
    {'1': 'uri', '3': 5, '4': 1, '5': 9, '10': 'uri'},
    {'1': 'crops', '3': 6, '4': 3, '5': 9, '10': 'crops'},
    {'1': 'region', '3': 7, '4': 1, '5': 9, '10': 'region'},
    {'1': 'text', '3': 8, '4': 1, '5': 9, '10': 'text'},
  ],
};

/// Descriptor for `IngestDocumentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ingestDocumentRequestDescriptor = $convert.base64Decode(
    'ChVJbmdlc3REb2N1bWVudFJlcXVlc3QSFAoFdGl0bGUYASABKAlSBXRpdGxlEjkKBGtpbmQYAi'
    'ABKA4yJS5hZ3JpY3VsdHVyZS5hZHZpc29yeS52MS5Eb2N1bWVudEtpbmRSBGtpbmQSNwoGbG9j'
    'YWxlGAMgASgOMh8uYWdyaWN1bHR1cmUuYWR2aXNvcnkudjEuTG9jYWxlUgZsb2NhbGUSFgoGc2'
    '91cmNlGAQgASgJUgZzb3VyY2USEAoDdXJpGAUgASgJUgN1cmkSFAoFY3JvcHMYBiADKAlSBWNy'
    'b3BzEhYKBnJlZ2lvbhgHIAEoCVIGcmVnaW9uEhIKBHRleHQYCCABKAlSBHRleHQ=');

@$core.Deprecated('Use ingestDocumentResponseDescriptor instead')
const IngestDocumentResponse$json = {
  '1': 'IngestDocumentResponse',
  '2': [
    {
      '1': 'document',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.advisory.v1.ReferenceDocument',
      '10': 'document'
    },
  ],
};

/// Descriptor for `IngestDocumentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ingestDocumentResponseDescriptor =
    $convert.base64Decode(
        'ChZJbmdlc3REb2N1bWVudFJlc3BvbnNlEkYKCGRvY3VtZW50GAEgASgLMiouYWdyaWN1bHR1cm'
        'UuYWR2aXNvcnkudjEuUmVmZXJlbmNlRG9jdW1lbnRSCGRvY3VtZW50');

@$core.Deprecated('Use listDocumentsRequestDescriptor instead')
const ListDocumentsRequest$json = {
  '1': 'ListDocumentsRequest',
  '2': [
    {
      '1': 'locale',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.agriculture.advisory.v1.Locale',
      '10': 'locale'
    },
    {'1': 'crop', '3': 2, '4': 1, '5': 9, '10': 'crop'},
    {'1': 'region', '3': 3, '4': 1, '5': 9, '10': 'region'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 5, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListDocumentsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDocumentsRequestDescriptor = $convert.base64Decode(
    'ChRMaXN0RG9jdW1lbnRzUmVxdWVzdBI3CgZsb2NhbGUYASABKA4yHy5hZ3JpY3VsdHVyZS5hZH'
    'Zpc29yeS52MS5Mb2NhbGVSBmxvY2FsZRISCgRjcm9wGAIgASgJUgRjcm9wEhYKBnJlZ2lvbhgD'
    'IAEoCVIGcmVnaW9uEhsKCXBhZ2Vfc2l6ZRgEIAEoBVIIcGFnZVNpemUSHwoLcGFnZV9vZmZzZX'
    'QYBSABKAVSCnBhZ2VPZmZzZXQ=');

@$core.Deprecated('Use listDocumentsResponseDescriptor instead')
const ListDocumentsResponse$json = {
  '1': 'ListDocumentsResponse',
  '2': [
    {
      '1': 'documents',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.advisory.v1.ReferenceDocument',
      '10': 'documents'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListDocumentsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDocumentsResponseDescriptor = $convert.base64Decode(
    'ChVMaXN0RG9jdW1lbnRzUmVzcG9uc2USSAoJZG9jdW1lbnRzGAEgAygLMiouYWdyaWN1bHR1cm'
    'UuYWR2aXNvcnkudjEuUmVmZXJlbmNlRG9jdW1lbnRSCWRvY3VtZW50cxIfCgt0b3RhbF9jb3Vu'
    'dBgCIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use deleteDocumentRequestDescriptor instead')
const DeleteDocumentRequest$json = {
  '1': 'DeleteDocumentRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteDocumentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteDocumentRequestDescriptor = $convert
    .base64Decode('ChVEZWxldGVEb2N1bWVudFJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use deleteDocumentResponseDescriptor instead')
const DeleteDocumentResponse$json = {
  '1': 'DeleteDocumentResponse',
  '2': [
    {'1': 'deleted', '3': 1, '4': 1, '5': 8, '10': 'deleted'},
  ],
};

/// Descriptor for `DeleteDocumentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteDocumentResponseDescriptor =
    $convert.base64Decode(
        'ChZEZWxldGVEb2N1bWVudFJlc3BvbnNlEhgKB2RlbGV0ZWQYASABKAhSB2RlbGV0ZWQ=');

@$core.Deprecated('Use searchReferenceRequestDescriptor instead')
const SearchReferenceRequest$json = {
  '1': 'SearchReferenceRequest',
  '2': [
    {'1': 'query', '3': 1, '4': 1, '5': 9, '10': 'query'},
    {
      '1': 'locale',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.advisory.v1.Locale',
      '10': 'locale'
    },
    {'1': 'crop', '3': 3, '4': 1, '5': 9, '10': 'crop'},
    {'1': 'limit', '3': 4, '4': 1, '5': 5, '10': 'limit'},
  ],
};

/// Descriptor for `SearchReferenceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchReferenceRequestDescriptor = $convert.base64Decode(
    'ChZTZWFyY2hSZWZlcmVuY2VSZXF1ZXN0EhQKBXF1ZXJ5GAEgASgJUgVxdWVyeRI3CgZsb2NhbG'
    'UYAiABKA4yHy5hZ3JpY3VsdHVyZS5hZHZpc29yeS52MS5Mb2NhbGVSBmxvY2FsZRISCgRjcm9w'
    'GAMgASgJUgRjcm9wEhQKBWxpbWl0GAQgASgFUgVsaW1pdA==');

@$core.Deprecated('Use searchReferenceResponseDescriptor instead')
const SearchReferenceResponse$json = {
  '1': 'SearchReferenceResponse',
  '2': [
    {
      '1': 'results',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.advisory.v1.Citation',
      '10': 'results'
    },
  ],
};

/// Descriptor for `SearchReferenceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List searchReferenceResponseDescriptor =
    $convert.base64Decode(
        'ChdTZWFyY2hSZWZlcmVuY2VSZXNwb25zZRI7CgdyZXN1bHRzGAEgAygLMiEuYWdyaWN1bHR1cm'
        'UuYWR2aXNvcnkudjEuQ2l0YXRpb25SB3Jlc3VsdHM=');

const $core.Map<$core.String, $core.dynamic> AdvisoryServiceBase$json = {
  '1': 'AdvisoryService',
  '2': [
    {
      '1': 'Ask',
      '2': '.agriculture.advisory.v1.AskRequest',
      '3': '.agriculture.advisory.v1.AskResponse'
    },
    {
      '1': 'GetConversation',
      '2': '.agriculture.advisory.v1.GetConversationRequest',
      '3': '.agriculture.advisory.v1.GetConversationResponse'
    },
    {
      '1': 'ListConversations',
      '2': '.agriculture.advisory.v1.ListConversationsRequest',
      '3': '.agriculture.advisory.v1.ListConversationsResponse'
    },
    {
      '1': 'ListExchanges',
      '2': '.agriculture.advisory.v1.ListExchangesRequest',
      '3': '.agriculture.advisory.v1.ListExchangesResponse'
    },
    {
      '1': 'ReviewExchange',
      '2': '.agriculture.advisory.v1.ReviewExchangeRequest',
      '3': '.agriculture.advisory.v1.ReviewExchangeResponse'
    },
    {
      '1': 'GetTenantBudget',
      '2': '.agriculture.advisory.v1.GetTenantBudgetRequest',
      '3': '.agriculture.advisory.v1.GetTenantBudgetResponse'
    },
    {
      '1': 'SetTenantBudget',
      '2': '.agriculture.advisory.v1.SetTenantBudgetRequest',
      '3': '.agriculture.advisory.v1.SetTenantBudgetResponse'
    },
    {
      '1': 'IngestDocument',
      '2': '.agriculture.advisory.v1.IngestDocumentRequest',
      '3': '.agriculture.advisory.v1.IngestDocumentResponse'
    },
    {
      '1': 'ListDocuments',
      '2': '.agriculture.advisory.v1.ListDocumentsRequest',
      '3': '.agriculture.advisory.v1.ListDocumentsResponse'
    },
    {
      '1': 'DeleteDocument',
      '2': '.agriculture.advisory.v1.DeleteDocumentRequest',
      '3': '.agriculture.advisory.v1.DeleteDocumentResponse'
    },
    {
      '1': 'SearchReference',
      '2': '.agriculture.advisory.v1.SearchReferenceRequest',
      '3': '.agriculture.advisory.v1.SearchReferenceResponse'
    },
  ],
};

@$core.Deprecated('Use advisoryServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    AdvisoryServiceBase$messageJson = {
  '.agriculture.advisory.v1.AskRequest': AskRequest$json,
  '.agriculture.advisory.v1.AskResponse': AskResponse$json,
  '.agriculture.advisory.v1.Exchange': Exchange$json,
  '.agriculture.advisory.v1.Citation': Citation$json,
  '.agriculture.advisory.v1.ToolCall': ToolCall$json,
  '.agriculture.advisory.v1.Evaluation': Evaluation$json,
  '.agriculture.advisory.v1.UnsupportedClaim': UnsupportedClaim$json,
  '.agriculture.advisory.v1.Usage': Usage$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.advisory.v1.TenantBudget': TenantBudget$json,
  '.agriculture.advisory.v1.GetConversationRequest':
      GetConversationRequest$json,
  '.agriculture.advisory.v1.GetConversationResponse':
      GetConversationResponse$json,
  '.agriculture.advisory.v1.Conversation': Conversation$json,
  '.agriculture.advisory.v1.ListConversationsRequest':
      ListConversationsRequest$json,
  '.agriculture.advisory.v1.ListConversationsResponse':
      ListConversationsResponse$json,
  '.agriculture.advisory.v1.ListExchangesRequest': ListExchangesRequest$json,
  '.agriculture.advisory.v1.ListExchangesResponse': ListExchangesResponse$json,
  '.agriculture.advisory.v1.ReviewExchangeRequest': ReviewExchangeRequest$json,
  '.agriculture.advisory.v1.ReviewExchangeResponse':
      ReviewExchangeResponse$json,
  '.agriculture.advisory.v1.GetTenantBudgetRequest':
      GetTenantBudgetRequest$json,
  '.agriculture.advisory.v1.GetTenantBudgetResponse':
      GetTenantBudgetResponse$json,
  '.agriculture.advisory.v1.SetTenantBudgetRequest':
      SetTenantBudgetRequest$json,
  '.agriculture.advisory.v1.SetTenantBudgetResponse':
      SetTenantBudgetResponse$json,
  '.agriculture.advisory.v1.IngestDocumentRequest': IngestDocumentRequest$json,
  '.agriculture.advisory.v1.IngestDocumentResponse':
      IngestDocumentResponse$json,
  '.agriculture.advisory.v1.ReferenceDocument': ReferenceDocument$json,
  '.agriculture.advisory.v1.ListDocumentsRequest': ListDocumentsRequest$json,
  '.agriculture.advisory.v1.ListDocumentsResponse': ListDocumentsResponse$json,
  '.agriculture.advisory.v1.DeleteDocumentRequest': DeleteDocumentRequest$json,
  '.agriculture.advisory.v1.DeleteDocumentResponse':
      DeleteDocumentResponse$json,
  '.agriculture.advisory.v1.SearchReferenceRequest':
      SearchReferenceRequest$json,
  '.agriculture.advisory.v1.SearchReferenceResponse':
      SearchReferenceResponse$json,
};

/// Descriptor for `AdvisoryService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List advisoryServiceDescriptor = $convert.base64Decode(
    'Cg9BZHZpc29yeVNlcnZpY2USUAoDQXNrEiMuYWdyaWN1bHR1cmUuYWR2aXNvcnkudjEuQXNrUm'
    'VxdWVzdBokLmFncmljdWx0dXJlLmFkdmlzb3J5LnYxLkFza1Jlc3BvbnNlEnQKD0dldENvbnZl'
    'cnNhdGlvbhIvLmFncmljdWx0dXJlLmFkdmlzb3J5LnYxLkdldENvbnZlcnNhdGlvblJlcXVlc3'
    'QaMC5hZ3JpY3VsdHVyZS5hZHZpc29yeS52MS5HZXRDb252ZXJzYXRpb25SZXNwb25zZRJ6ChFM'
    'aXN0Q29udmVyc2F0aW9ucxIxLmFncmljdWx0dXJlLmFkdmlzb3J5LnYxLkxpc3RDb252ZXJzYX'
    'Rpb25zUmVxdWVzdBoyLmFncmljdWx0dXJlLmFkdmlzb3J5LnYxLkxpc3RDb252ZXJzYXRpb25z'
    'UmVzcG9uc2USbgoNTGlzdEV4Y2hhbmdlcxItLmFncmljdWx0dXJlLmFkdmlzb3J5LnYxLkxpc3'
    'RFeGNoYW5nZXNSZXF1ZXN0Gi4uYWdyaWN1bHR1cmUuYWR2aXNvcnkudjEuTGlzdEV4Y2hhbmdl'
    'c1Jlc3BvbnNlEnEKDlJldmlld0V4Y2hhbmdlEi4uYWdyaWN1bHR1cmUuYWR2aXNvcnkudjEuUm'
    'V2aWV3RXhjaGFuZ2VSZXF1ZXN0Gi8uYWdyaWN1bHR1cmUuYWR2aXNvcnkudjEuUmV2aWV3RXhj'
    'aGFuZ2VSZXNwb25zZRJ0Cg9HZXRUZW5hbnRCdWRnZXQSLy5hZ3JpY3VsdHVyZS5hZHZpc29yeS'
    '52MS5HZXRUZW5hbnRCdWRnZXRSZXF1ZXN0GjAuYWdyaWN1bHR1cmUuYWR2aXNvcnkudjEuR2V0'
    'VGVuYW50QnVkZ2V0UmVzcG9uc2USdAoPU2V0VGVuYW50QnVkZ2V0Ei8uYWdyaWN1bHR1cmUuYW'
    'R2aXNvcnkudjEuU2V0VGVuYW50QnVkZ2V0UmVxdWVzdBowLmFncmljdWx0dXJlLmFkdmlzb3J5'
    'LnYxLlNldFRlbmFudEJ1ZGdldFJlc3BvbnNlEnEKDkluZ2VzdERvY3VtZW50Ei4uYWdyaWN1bH'
    'R1cmUuYWR2aXNvcnkudjEuSW5nZXN0RG9jdW1lbnRSZXF1ZXN0Gi8uYWdyaWN1bHR1cmUuYWR2'
    'aXNvcnkudjEuSW5nZXN0RG9jdW1lbnRSZXNwb25zZRJuCg1MaXN0RG9jdW1lbnRzEi0uYWdyaW'
    'N1bHR1cmUuYWR2aXNvcnkudjEuTGlzdERvY3VtZW50c1JlcXVlc3QaLi5hZ3JpY3VsdHVyZS5h'
    'ZHZpc29yeS52MS5MaXN0RG9jdW1lbnRzUmVzcG9uc2UScQoORGVsZXRlRG9jdW1lbnQSLi5hZ3'
    'JpY3VsdHVyZS5hZHZpc29yeS52MS5EZWxldGVEb2N1bWVudFJlcXVlc3QaLy5hZ3JpY3VsdHVy'
    'ZS5hZHZpc29yeS52MS5EZWxldGVEb2N1bWVudFJlc3BvbnNlEnQKD1NlYXJjaFJlZmVyZW5jZR'
    'IvLmFncmljdWx0dXJlLmFkdmlzb3J5LnYxLlNlYXJjaFJlZmVyZW5jZVJlcXVlc3QaMC5hZ3Jp'
    'Y3VsdHVyZS5hZHZpc29yeS52MS5TZWFyY2hSZWZlcmVuY2VSZXNwb25zZQ==');
