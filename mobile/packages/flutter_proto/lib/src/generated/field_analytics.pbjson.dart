// This is a generated file - do not edit.
//
// Generated from field_analytics.proto.

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

@$core.Deprecated('Use fieldAnalyticsSummaryDescriptor instead')
const FieldAnalyticsSummary$json = {
  '1': 'FieldAnalyticsSummary',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'field_name', '3': 2, '4': 1, '5': 9, '10': 'fieldName'},
    {'1': 'mean_yield', '3': 3, '4': 1, '5': 1, '10': 'meanYield'},
    {'1': 'peak_yield', '3': 4, '4': 1, '5': 1, '10': 'peakYield'},
    {'1': 'yield_trend', '3': 5, '4': 1, '5': 9, '10': 'yieldTrend'},
    {'1': 'avg_stress_days', '3': 6, '4': 1, '5': 1, '10': 'avgStressDays'},
    {'1': 'avg_ndvi', '3': 7, '4': 1, '5': 1, '10': 'avgNdvi'},
    {'1': 'seasons_analyzed', '3': 8, '4': 1, '5': 5, '10': 'seasonsAnalyzed'},
  ],
};

/// Descriptor for `FieldAnalyticsSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldAnalyticsSummaryDescriptor = $convert.base64Decode(
    'ChVGaWVsZEFuYWx5dGljc1N1bW1hcnkSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQSHQoKZm'
    'llbGRfbmFtZRgCIAEoCVIJZmllbGROYW1lEh0KCm1lYW5feWllbGQYAyABKAFSCW1lYW5ZaWVs'
    'ZBIdCgpwZWFrX3lpZWxkGAQgASgBUglwZWFrWWllbGQSHwoLeWllbGRfdHJlbmQYBSABKAlSCn'
    'lpZWxkVHJlbmQSJgoPYXZnX3N0cmVzc19kYXlzGAYgASgBUg1hdmdTdHJlc3NEYXlzEhkKCGF2'
    'Z19uZHZpGAcgASgBUgdhdmdOZHZpEikKEHNlYXNvbnNfYW5hbHl6ZWQYCCABKAVSD3NlYXNvbn'
    'NBbmFseXplZA==');

@$core.Deprecated('Use yieldTrendPointDescriptor instead')
const YieldTrendPoint$json = {
  '1': 'YieldTrendPoint',
  '2': [
    {'1': 'season', '3': 1, '4': 1, '5': 9, '10': 'season'},
    {'1': 'crop', '3': 2, '4': 1, '5': 9, '10': 'crop'},
    {'1': 'yield_value', '3': 3, '4': 1, '5': 1, '10': 'yieldValue'},
    {'1': 'ndvi', '3': 4, '4': 1, '5': 1, '10': 'ndvi'},
  ],
};

/// Descriptor for `YieldTrendPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List yieldTrendPointDescriptor = $convert.base64Decode(
    'Cg9ZaWVsZFRyZW5kUG9pbnQSFgoGc2Vhc29uGAEgASgJUgZzZWFzb24SEgoEY3JvcBgCIAEoCV'
    'IEY3JvcBIfCgt5aWVsZF92YWx1ZRgDIAEoAVIKeWllbGRWYWx1ZRISCgRuZHZpGAQgASgBUgRu'
    'ZHZp');

@$core.Deprecated('Use seasonComparisonDescriptor instead')
const SeasonComparison$json = {
  '1': 'SeasonComparison',
  '2': [
    {'1': 'season', '3': 1, '4': 1, '5': 9, '10': 'season'},
    {'1': 'crop', '3': 2, '4': 1, '5': 9, '10': 'crop'},
    {'1': 'yield_value', '3': 3, '4': 1, '5': 1, '10': 'yieldValue'},
    {'1': 'yield_vs_mean_pct', '3': 4, '4': 1, '5': 1, '10': 'yieldVsMeanPct'},
    {'1': 'stress_days', '3': 5, '4': 1, '5': 5, '10': 'stressDays'},
    {
      '1': 'stress_vs_mean_pct',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'stressVsMeanPct'
    },
    {'1': 'ndvi_peak', '3': 7, '4': 1, '5': 1, '10': 'ndviPeak'},
    {'1': 'ndvi_vs_mean_pct', '3': 8, '4': 1, '5': 1, '10': 'ndviVsMeanPct'},
    {'1': 'notable_events', '3': 9, '4': 3, '5': 9, '10': 'notableEvents'},
  ],
};

/// Descriptor for `SeasonComparison`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List seasonComparisonDescriptor = $convert.base64Decode(
    'ChBTZWFzb25Db21wYXJpc29uEhYKBnNlYXNvbhgBIAEoCVIGc2Vhc29uEhIKBGNyb3AYAiABKA'
    'lSBGNyb3ASHwoLeWllbGRfdmFsdWUYAyABKAFSCnlpZWxkVmFsdWUSKQoReWllbGRfdnNfbWVh'
    'bl9wY3QYBCABKAFSDnlpZWxkVnNNZWFuUGN0Eh8KC3N0cmVzc19kYXlzGAUgASgFUgpzdHJlc3'
    'NEYXlzEisKEnN0cmVzc192c19tZWFuX3BjdBgGIAEoAVIPc3RyZXNzVnNNZWFuUGN0EhsKCW5k'
    'dmlfcGVhaxgHIAEoAVIIbmR2aVBlYWsSJwoQbmR2aV92c19tZWFuX3BjdBgIIAEoAVINbmR2aV'
    'ZzTWVhblBjdBIlCg5ub3RhYmxlX2V2ZW50cxgJIAMoCVINbm90YWJsZUV2ZW50cw==');

@$core.Deprecated('Use rotationAnalysisDescriptor instead')
const RotationAnalysis$json = {
  '1': 'RotationAnalysis',
  '2': [
    {
      '1': 'effectiveness_score',
      '3': 1,
      '4': 1,
      '5': 1,
      '10': 'effectivenessScore'
    },
    {'1': 'diversity_index', '3': 2, '4': 1, '5': 1, '10': 'diversityIndex'},
    {'1': 'rotation_length', '3': 3, '4': 1, '5': 5, '10': 'rotationLength'},
    {
      '1': 'soil_health_impact',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'soilHealthImpact'
    },
    {'1': 'rotation_pattern', '3': 5, '4': 3, '5': 9, '10': 'rotationPattern'},
    {'1': 'recommendations', '3': 6, '4': 3, '5': 9, '10': 'recommendations'},
  ],
};

/// Descriptor for `RotationAnalysis`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rotationAnalysisDescriptor = $convert.base64Decode(
    'ChBSb3RhdGlvbkFuYWx5c2lzEi8KE2VmZmVjdGl2ZW5lc3Nfc2NvcmUYASABKAFSEmVmZmVjdG'
    'l2ZW5lc3NTY29yZRInCg9kaXZlcnNpdHlfaW5kZXgYAiABKAFSDmRpdmVyc2l0eUluZGV4EicK'
    'D3JvdGF0aW9uX2xlbmd0aBgDIAEoBVIOcm90YXRpb25MZW5ndGgSLAoSc29pbF9oZWFsdGhfaW'
    '1wYWN0GAQgASgJUhBzb2lsSGVhbHRoSW1wYWN0EikKEHJvdGF0aW9uX3BhdHRlcm4YBSADKAlS'
    'D3JvdGF0aW9uUGF0dGVybhIoCg9yZWNvbW1lbmRhdGlvbnMYBiADKAlSD3JlY29tbWVuZGF0aW'
    '9ucw==');

@$core.Deprecated('Use historicalMetricsDescriptor instead')
const HistoricalMetrics$json = {
  '1': 'HistoricalMetrics',
  '2': [
    {'1': 'mean_yield', '3': 1, '4': 1, '5': 1, '10': 'meanYield'},
    {'1': 'peak_yield', '3': 2, '4': 1, '5': 1, '10': 'peakYield'},
    {'1': 'yield_trend', '3': 3, '4': 1, '5': 9, '10': 'yieldTrend'},
    {'1': 'avg_stress_days', '3': 4, '4': 1, '5': 1, '10': 'avgStressDays'},
    {'1': 'avg_ndvi', '3': 5, '4': 1, '5': 1, '10': 'avgNdvi'},
    {'1': 'seasons_analyzed', '3': 6, '4': 1, '5': 5, '10': 'seasonsAnalyzed'},
    {
      '1': 'fields',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.analytics.v1.FieldAnalyticsSummary',
      '10': 'fields'
    },
  ],
};

/// Descriptor for `HistoricalMetrics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List historicalMetricsDescriptor = $convert.base64Decode(
    'ChFIaXN0b3JpY2FsTWV0cmljcxIdCgptZWFuX3lpZWxkGAEgASgBUgltZWFuWWllbGQSHQoKcG'
    'Vha195aWVsZBgCIAEoAVIJcGVha1lpZWxkEh8KC3lpZWxkX3RyZW5kGAMgASgJUgp5aWVsZFRy'
    'ZW5kEiYKD2F2Z19zdHJlc3NfZGF5cxgEIAEoAVINYXZnU3RyZXNzRGF5cxIZCghhdmdfbmR2aR'
    'gFIAEoAVIHYXZnTmR2aRIpChBzZWFzb25zX2FuYWx5emVkGAYgASgFUg9zZWFzb25zQW5hbHl6'
    'ZWQSTQoGZmllbGRzGAcgAygLMjUuYWdyaWN1bHR1cmUuZmllbGQuYW5hbHl0aWNzLnYxLkZpZW'
    'xkQW5hbHl0aWNzU3VtbWFyeVIGZmllbGRz');

@$core.Deprecated('Use crossFieldTrendPointDescriptor instead')
const CrossFieldTrendPoint$json = {
  '1': 'CrossFieldTrendPoint',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'field_name', '3': 2, '4': 1, '5': 9, '10': 'fieldName'},
    {'1': 'values', '3': 3, '4': 3, '5': 1, '10': 'values'},
    {'1': 'labels', '3': 4, '4': 3, '5': 9, '10': 'labels'},
  ],
};

/// Descriptor for `CrossFieldTrendPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List crossFieldTrendPointDescriptor = $convert.base64Decode(
    'ChRDcm9zc0ZpZWxkVHJlbmRQb2ludBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBIdCgpmaW'
    'VsZF9uYW1lGAIgASgJUglmaWVsZE5hbWUSFgoGdmFsdWVzGAMgAygBUgZ2YWx1ZXMSFgoGbGFi'
    'ZWxzGAQgAygJUgZsYWJlbHM=');

@$core.Deprecated('Use getHistoricalMetricsRequestDescriptor instead')
const GetHistoricalMetricsRequest$json = {
  '1': 'GetHistoricalMetricsRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'time_period', '3': 3, '4': 1, '5': 9, '10': 'timePeriod'},
  ],
};

/// Descriptor for `GetHistoricalMetricsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHistoricalMetricsRequestDescriptor =
    $convert.base64Decode(
        'ChtHZXRIaXN0b3JpY2FsTWV0cmljc1JlcXVlc3QSFwoHZmFybV9pZBgBIAEoCVIGZmFybUlkEh'
        'kKCGZpZWxkX2lkGAIgASgJUgdmaWVsZElkEh8KC3RpbWVfcGVyaW9kGAMgASgJUgp0aW1lUGVy'
        'aW9k');

@$core.Deprecated('Use getHistoricalMetricsResponseDescriptor instead')
const GetHistoricalMetricsResponse$json = {
  '1': 'GetHistoricalMetricsResponse',
  '2': [
    {
      '1': 'metrics',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.analytics.v1.HistoricalMetrics',
      '10': 'metrics'
    },
  ],
};

/// Descriptor for `GetHistoricalMetricsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getHistoricalMetricsResponseDescriptor =
    $convert.base64Decode(
        'ChxHZXRIaXN0b3JpY2FsTWV0cmljc1Jlc3BvbnNlEksKB21ldHJpY3MYASABKAsyMS5hZ3JpY3'
        'VsdHVyZS5maWVsZC5hbmFseXRpY3MudjEuSGlzdG9yaWNhbE1ldHJpY3NSB21ldHJpY3M=');

@$core.Deprecated('Use listFieldAnalyticsRequestDescriptor instead')
const ListFieldAnalyticsRequest$json = {
  '1': 'ListFieldAnalyticsRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
  ],
};

/// Descriptor for `ListFieldAnalyticsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFieldAnalyticsRequestDescriptor =
    $convert.base64Decode(
        'ChlMaXN0RmllbGRBbmFseXRpY3NSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZA==');

@$core.Deprecated('Use listFieldAnalyticsResponseDescriptor instead')
const ListFieldAnalyticsResponse$json = {
  '1': 'ListFieldAnalyticsResponse',
  '2': [
    {
      '1': 'summaries',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.analytics.v1.FieldAnalyticsSummary',
      '10': 'summaries'
    },
  ],
};

/// Descriptor for `ListFieldAnalyticsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFieldAnalyticsResponseDescriptor =
    $convert.base64Decode(
        'ChpMaXN0RmllbGRBbmFseXRpY3NSZXNwb25zZRJTCglzdW1tYXJpZXMYASADKAsyNS5hZ3JpY3'
        'VsdHVyZS5maWVsZC5hbmFseXRpY3MudjEuRmllbGRBbmFseXRpY3NTdW1tYXJ5UglzdW1tYXJp'
        'ZXM=');

@$core.Deprecated('Use getFieldAnalyticsRequestDescriptor instead')
const GetFieldAnalyticsRequest$json = {
  '1': 'GetFieldAnalyticsRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
  ],
};

/// Descriptor for `GetFieldAnalyticsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFieldAnalyticsRequestDescriptor =
    $convert.base64Decode(
        'ChhHZXRGaWVsZEFuYWx5dGljc1JlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQ=');

@$core.Deprecated('Use getFieldAnalyticsResponseDescriptor instead')
const GetFieldAnalyticsResponse$json = {
  '1': 'GetFieldAnalyticsResponse',
  '2': [
    {
      '1': 'summary',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.analytics.v1.FieldAnalyticsSummary',
      '10': 'summary'
    },
    {
      '1': 'yield_trends',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.analytics.v1.YieldTrendPoint',
      '10': 'yieldTrends'
    },
  ],
};

/// Descriptor for `GetFieldAnalyticsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFieldAnalyticsResponseDescriptor = $convert.base64Decode(
    'ChlHZXRGaWVsZEFuYWx5dGljc1Jlc3BvbnNlEk8KB3N1bW1hcnkYASABKAsyNS5hZ3JpY3VsdH'
    'VyZS5maWVsZC5hbmFseXRpY3MudjEuRmllbGRBbmFseXRpY3NTdW1tYXJ5UgdzdW1tYXJ5ElIK'
    'DHlpZWxkX3RyZW5kcxgCIAMoCzIvLmFncmljdWx0dXJlLmZpZWxkLmFuYWx5dGljcy52MS5ZaW'
    'VsZFRyZW5kUG9pbnRSC3lpZWxkVHJlbmRz');

@$core.Deprecated('Use getSeasonComparisonsRequestDescriptor instead')
const GetSeasonComparisonsRequest$json = {
  '1': 'GetSeasonComparisonsRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
  ],
};

/// Descriptor for `GetSeasonComparisonsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSeasonComparisonsRequestDescriptor =
    $convert.base64Decode(
        'ChtHZXRTZWFzb25Db21wYXJpc29uc1JlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSW'
        'Q=');

@$core.Deprecated('Use getSeasonComparisonsResponseDescriptor instead')
const GetSeasonComparisonsResponse$json = {
  '1': 'GetSeasonComparisonsResponse',
  '2': [
    {
      '1': 'comparisons',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.analytics.v1.SeasonComparison',
      '10': 'comparisons'
    },
  ],
};

/// Descriptor for `GetSeasonComparisonsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSeasonComparisonsResponseDescriptor =
    $convert.base64Decode(
        'ChxHZXRTZWFzb25Db21wYXJpc29uc1Jlc3BvbnNlElIKC2NvbXBhcmlzb25zGAEgAygLMjAuYW'
        'dyaWN1bHR1cmUuZmllbGQuYW5hbHl0aWNzLnYxLlNlYXNvbkNvbXBhcmlzb25SC2NvbXBhcmlz'
        'b25z');

@$core.Deprecated('Use getRotationAnalysisRequestDescriptor instead')
const GetRotationAnalysisRequest$json = {
  '1': 'GetRotationAnalysisRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
  ],
};

/// Descriptor for `GetRotationAnalysisRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRotationAnalysisRequestDescriptor =
    $convert.base64Decode(
        'ChpHZXRSb3RhdGlvbkFuYWx5c2lzUmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZA'
        '==');

@$core.Deprecated('Use getRotationAnalysisResponseDescriptor instead')
const GetRotationAnalysisResponse$json = {
  '1': 'GetRotationAnalysisResponse',
  '2': [
    {
      '1': 'analysis',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.field.analytics.v1.RotationAnalysis',
      '10': 'analysis'
    },
  ],
};

/// Descriptor for `GetRotationAnalysisResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRotationAnalysisResponseDescriptor =
    $convert.base64Decode(
        'ChtHZXRSb3RhdGlvbkFuYWx5c2lzUmVzcG9uc2USTAoIYW5hbHlzaXMYASABKAsyMC5hZ3JpY3'
        'VsdHVyZS5maWVsZC5hbmFseXRpY3MudjEuUm90YXRpb25BbmFseXNpc1IIYW5hbHlzaXM=');

@$core.Deprecated('Use getCrossFieldTrendsRequestDescriptor instead')
const GetCrossFieldTrendsRequest$json = {
  '1': 'GetCrossFieldTrendsRequest',
  '2': [
    {'1': 'field_ids', '3': 1, '4': 3, '5': 9, '10': 'fieldIds'},
    {'1': 'metric', '3': 2, '4': 1, '5': 9, '10': 'metric'},
  ],
};

/// Descriptor for `GetCrossFieldTrendsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCrossFieldTrendsRequestDescriptor =
    $convert.base64Decode(
        'ChpHZXRDcm9zc0ZpZWxkVHJlbmRzUmVxdWVzdBIbCglmaWVsZF9pZHMYASADKAlSCGZpZWxkSW'
        'RzEhYKBm1ldHJpYxgCIAEoCVIGbWV0cmlj');

@$core.Deprecated('Use getCrossFieldTrendsResponseDescriptor instead')
const GetCrossFieldTrendsResponse$json = {
  '1': 'GetCrossFieldTrendsResponse',
  '2': [
    {
      '1': 'trends',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.field.analytics.v1.CrossFieldTrendPoint',
      '10': 'trends'
    },
  ],
};

/// Descriptor for `GetCrossFieldTrendsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCrossFieldTrendsResponseDescriptor =
    $convert.base64Decode(
        'ChtHZXRDcm9zc0ZpZWxkVHJlbmRzUmVzcG9uc2USTAoGdHJlbmRzGAEgAygLMjQuYWdyaWN1bH'
        'R1cmUuZmllbGQuYW5hbHl0aWNzLnYxLkNyb3NzRmllbGRUcmVuZFBvaW50UgZ0cmVuZHM=');

const $core.Map<$core.String, $core.dynamic> FieldAnalyticsServiceBase$json = {
  '1': 'FieldAnalyticsService',
  '2': [
    {
      '1': 'GetHistoricalMetrics',
      '2': '.agriculture.field.analytics.v1.GetHistoricalMetricsRequest',
      '3': '.agriculture.field.analytics.v1.GetHistoricalMetricsResponse'
    },
    {
      '1': 'ListFieldAnalytics',
      '2': '.agriculture.field.analytics.v1.ListFieldAnalyticsRequest',
      '3': '.agriculture.field.analytics.v1.ListFieldAnalyticsResponse'
    },
    {
      '1': 'GetFieldAnalytics',
      '2': '.agriculture.field.analytics.v1.GetFieldAnalyticsRequest',
      '3': '.agriculture.field.analytics.v1.GetFieldAnalyticsResponse'
    },
    {
      '1': 'GetSeasonComparisons',
      '2': '.agriculture.field.analytics.v1.GetSeasonComparisonsRequest',
      '3': '.agriculture.field.analytics.v1.GetSeasonComparisonsResponse'
    },
    {
      '1': 'GetRotationAnalysis',
      '2': '.agriculture.field.analytics.v1.GetRotationAnalysisRequest',
      '3': '.agriculture.field.analytics.v1.GetRotationAnalysisResponse'
    },
    {
      '1': 'GetCrossFieldTrends',
      '2': '.agriculture.field.analytics.v1.GetCrossFieldTrendsRequest',
      '3': '.agriculture.field.analytics.v1.GetCrossFieldTrendsResponse'
    },
  ],
};

@$core.Deprecated('Use fieldAnalyticsServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    FieldAnalyticsServiceBase$messageJson = {
  '.agriculture.field.analytics.v1.GetHistoricalMetricsRequest':
      GetHistoricalMetricsRequest$json,
  '.agriculture.field.analytics.v1.GetHistoricalMetricsResponse':
      GetHistoricalMetricsResponse$json,
  '.agriculture.field.analytics.v1.HistoricalMetrics': HistoricalMetrics$json,
  '.agriculture.field.analytics.v1.FieldAnalyticsSummary':
      FieldAnalyticsSummary$json,
  '.agriculture.field.analytics.v1.ListFieldAnalyticsRequest':
      ListFieldAnalyticsRequest$json,
  '.agriculture.field.analytics.v1.ListFieldAnalyticsResponse':
      ListFieldAnalyticsResponse$json,
  '.agriculture.field.analytics.v1.GetFieldAnalyticsRequest':
      GetFieldAnalyticsRequest$json,
  '.agriculture.field.analytics.v1.GetFieldAnalyticsResponse':
      GetFieldAnalyticsResponse$json,
  '.agriculture.field.analytics.v1.YieldTrendPoint': YieldTrendPoint$json,
  '.agriculture.field.analytics.v1.GetSeasonComparisonsRequest':
      GetSeasonComparisonsRequest$json,
  '.agriculture.field.analytics.v1.GetSeasonComparisonsResponse':
      GetSeasonComparisonsResponse$json,
  '.agriculture.field.analytics.v1.SeasonComparison': SeasonComparison$json,
  '.agriculture.field.analytics.v1.GetRotationAnalysisRequest':
      GetRotationAnalysisRequest$json,
  '.agriculture.field.analytics.v1.GetRotationAnalysisResponse':
      GetRotationAnalysisResponse$json,
  '.agriculture.field.analytics.v1.RotationAnalysis': RotationAnalysis$json,
  '.agriculture.field.analytics.v1.GetCrossFieldTrendsRequest':
      GetCrossFieldTrendsRequest$json,
  '.agriculture.field.analytics.v1.GetCrossFieldTrendsResponse':
      GetCrossFieldTrendsResponse$json,
  '.agriculture.field.analytics.v1.CrossFieldTrendPoint':
      CrossFieldTrendPoint$json,
};

/// Descriptor for `FieldAnalyticsService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List fieldAnalyticsServiceDescriptor = $convert.base64Decode(
    'ChVGaWVsZEFuYWx5dGljc1NlcnZpY2USkQEKFEdldEhpc3RvcmljYWxNZXRyaWNzEjsuYWdyaW'
    'N1bHR1cmUuZmllbGQuYW5hbHl0aWNzLnYxLkdldEhpc3RvcmljYWxNZXRyaWNzUmVxdWVzdBo8'
    'LmFncmljdWx0dXJlLmZpZWxkLmFuYWx5dGljcy52MS5HZXRIaXN0b3JpY2FsTWV0cmljc1Jlc3'
    'BvbnNlEosBChJMaXN0RmllbGRBbmFseXRpY3MSOS5hZ3JpY3VsdHVyZS5maWVsZC5hbmFseXRp'
    'Y3MudjEuTGlzdEZpZWxkQW5hbHl0aWNzUmVxdWVzdBo6LmFncmljdWx0dXJlLmZpZWxkLmFuYW'
    'x5dGljcy52MS5MaXN0RmllbGRBbmFseXRpY3NSZXNwb25zZRKIAQoRR2V0RmllbGRBbmFseXRp'
    'Y3MSOC5hZ3JpY3VsdHVyZS5maWVsZC5hbmFseXRpY3MudjEuR2V0RmllbGRBbmFseXRpY3NSZX'
    'F1ZXN0GjkuYWdyaWN1bHR1cmUuZmllbGQuYW5hbHl0aWNzLnYxLkdldEZpZWxkQW5hbHl0aWNz'
    'UmVzcG9uc2USkQEKFEdldFNlYXNvbkNvbXBhcmlzb25zEjsuYWdyaWN1bHR1cmUuZmllbGQuYW'
    '5hbHl0aWNzLnYxLkdldFNlYXNvbkNvbXBhcmlzb25zUmVxdWVzdBo8LmFncmljdWx0dXJlLmZp'
    'ZWxkLmFuYWx5dGljcy52MS5HZXRTZWFzb25Db21wYXJpc29uc1Jlc3BvbnNlEo4BChNHZXRSb3'
    'RhdGlvbkFuYWx5c2lzEjouYWdyaWN1bHR1cmUuZmllbGQuYW5hbHl0aWNzLnYxLkdldFJvdGF0'
    'aW9uQW5hbHlzaXNSZXF1ZXN0GjsuYWdyaWN1bHR1cmUuZmllbGQuYW5hbHl0aWNzLnYxLkdldF'
    'JvdGF0aW9uQW5hbHlzaXNSZXNwb25zZRKOAQoTR2V0Q3Jvc3NGaWVsZFRyZW5kcxI6LmFncmlj'
    'dWx0dXJlLmZpZWxkLmFuYWx5dGljcy52MS5HZXRDcm9zc0ZpZWxkVHJlbmRzUmVxdWVzdBo7Lm'
    'FncmljdWx0dXJlLmZpZWxkLmFuYWx5dGljcy52MS5HZXRDcm9zc0ZpZWxkVHJlbmRzUmVzcG9u'
    'c2U=');
