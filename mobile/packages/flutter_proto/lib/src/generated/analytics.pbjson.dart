// This is a generated file - do not edit.
//
// Generated from analytics.proto.

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

@$core.Deprecated('Use stressTypeDescriptor instead')
const StressType$json = {
  '1': 'StressType',
  '2': [
    {'1': 'STRESS_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'STRESS_TYPE_WATER', '2': 1},
    {'1': 'STRESS_TYPE_NUTRIENT', '2': 2},
    {'1': 'STRESS_TYPE_DISEASE', '2': 3},
    {'1': 'STRESS_TYPE_PEST', '2': 4},
    {'1': 'STRESS_TYPE_HEAT', '2': 5},
    {'1': 'STRESS_TYPE_FROST', '2': 6},
  ],
};

/// Descriptor for `StressType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List stressTypeDescriptor = $convert.base64Decode(
    'CgpTdHJlc3NUeXBlEhsKF1NUUkVTU19UWVBFX1VOU1BFQ0lGSUVEEAASFQoRU1RSRVNTX1RZUE'
    'VfV0FURVIQARIYChRTVFJFU1NfVFlQRV9OVVRSSUVOVBACEhcKE1NUUkVTU19UWVBFX0RJU0VB'
    'U0UQAxIUChBTVFJFU1NfVFlQRV9QRVNUEAQSFAoQU1RSRVNTX1RZUEVfSEVBVBAFEhUKEVNUUk'
    'VTU19UWVBFX0ZST1NUEAY=');

@$core.Deprecated('Use severityLevelDescriptor instead')
const SeverityLevel$json = {
  '1': 'SeverityLevel',
  '2': [
    {'1': 'SEVERITY_LEVEL_UNSPECIFIED', '2': 0},
    {'1': 'SEVERITY_LEVEL_LOW', '2': 1},
    {'1': 'SEVERITY_LEVEL_MEDIUM', '2': 2},
    {'1': 'SEVERITY_LEVEL_HIGH', '2': 3},
    {'1': 'SEVERITY_LEVEL_CRITICAL', '2': 4},
  ],
};

/// Descriptor for `SeverityLevel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List severityLevelDescriptor = $convert.base64Decode(
    'Cg1TZXZlcml0eUxldmVsEh4KGlNFVkVSSVRZX0xFVkVMX1VOU1BFQ0lGSUVEEAASFgoSU0VWRV'
    'JJVFlfTEVWRUxfTE9XEAESGQoVU0VWRVJJVFlfTEVWRUxfTUVESVVNEAISFwoTU0VWRVJJVFlf'
    'TEVWRUxfSElHSBADEhsKF1NFVkVSSVRZX0xFVkVMX0NSSVRJQ0FMEAQ=');

@$core.Deprecated('Use analysisTypeDescriptor instead')
const AnalysisType$json = {
  '1': 'AnalysisType',
  '2': [
    {'1': 'ANALYSIS_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'ANALYSIS_TYPE_STRESS_DETECTION', '2': 1},
    {'1': 'ANALYSIS_TYPE_CHANGE_DETECTION', '2': 2},
    {'1': 'ANALYSIS_TYPE_TEMPORAL_TREND', '2': 3},
    {'1': 'ANALYSIS_TYPE_ANOMALY_DETECTION', '2': 4},
    {'1': 'ANALYSIS_TYPE_CROP_CLASSIFICATION', '2': 5},
  ],
};

/// Descriptor for `AnalysisType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List analysisTypeDescriptor = $convert.base64Decode(
    'CgxBbmFseXNpc1R5cGUSHQoZQU5BTFlTSVNfVFlQRV9VTlNQRUNJRklFRBAAEiIKHkFOQUxZU0'
    'lTX1RZUEVfU1RSRVNTX0RFVEVDVElPThABEiIKHkFOQUxZU0lTX1RZUEVfQ0hBTkdFX0RFVEVD'
    'VElPThACEiAKHEFOQUxZU0lTX1RZUEVfVEVNUE9SQUxfVFJFTkQQAxIjCh9BTkFMWVNJU19UWV'
    'BFX0FOT01BTFlfREVURUNUSU9OEAQSJQohQU5BTFlTSVNfVFlQRV9DUk9QX0NMQVNTSUZJQ0FU'
    'SU9OEAU=');

@$core.Deprecated('Use stressAlertDescriptor instead')
const StressAlert$json = {
  '1': 'StressAlert',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'stress_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.analytics.v1.StressType',
      '10': 'stressType'
    },
    {
      '1': 'severity',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.analytics.v1.SeverityLevel',
      '10': 'severity'
    },
    {'1': 'confidence', '3': 7, '4': 1, '5': 1, '10': 'confidence'},
    {
      '1': 'affected_area_hectares',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'affectedAreaHectares'
    },
    {
      '1': 'affected_percentage',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'affectedPercentage'
    },
    {'1': 'bbox_geojson', '3': 10, '4': 1, '5': 9, '10': 'bboxGeojson'},
    {'1': 'description', '3': 11, '4': 1, '5': 9, '10': 'description'},
    {'1': 'recommendation', '3': 12, '4': 1, '5': 9, '10': 'recommendation'},
    {'1': 'acknowledged', '3': 13, '4': 1, '5': 8, '10': 'acknowledged'},
    {
      '1': 'detected_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'detectedAt'
    },
    {
      '1': 'created_at',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `StressAlert`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stressAlertDescriptor = $convert.base64Decode(
    'CgtTdHJlc3NBbGVydBIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW5hbn'
    'RJZBIXCgdmYXJtX2lkGAMgASgJUgZmYXJtSWQSGQoIZmllbGRfaWQYBCABKAlSB2ZpZWxkSWQS'
    'TwoLc3RyZXNzX3R5cGUYBSABKA4yLi5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUuYW5hbHl0aWNzLn'
    'YxLlN0cmVzc1R5cGVSCnN0cmVzc1R5cGUSTQoIc2V2ZXJpdHkYBiABKA4yMS5hZ3JpY3VsdHVy'
    'ZS5zYXRlbGxpdGUuYW5hbHl0aWNzLnYxLlNldmVyaXR5TGV2ZWxSCHNldmVyaXR5Eh4KCmNvbm'
    'ZpZGVuY2UYByABKAFSCmNvbmZpZGVuY2USNAoWYWZmZWN0ZWRfYXJlYV9oZWN0YXJlcxgIIAEo'
    'AVIUYWZmZWN0ZWRBcmVhSGVjdGFyZXMSLwoTYWZmZWN0ZWRfcGVyY2VudGFnZRgJIAEoAVISYW'
    'ZmZWN0ZWRQZXJjZW50YWdlEiEKDGJib3hfZ2VvanNvbhgKIAEoCVILYmJveEdlb2pzb24SIAoL'
    'ZGVzY3JpcHRpb24YCyABKAlSC2Rlc2NyaXB0aW9uEiYKDnJlY29tbWVuZGF0aW9uGAwgASgJUg'
    '5yZWNvbW1lbmRhdGlvbhIiCgxhY2tub3dsZWRnZWQYDSABKAhSDGFja25vd2xlZGdlZBI7Cgtk'
    'ZXRlY3RlZF9hdBgOIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCmRldGVjdGVkQX'
    'QSOQoKY3JlYXRlZF9hdBgPIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0'
    'ZWRBdA==');

@$core.Deprecated('Use temporalAnalysisDescriptor instead')
const TemporalAnalysis$json = {
  '1': 'TemporalAnalysis',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'analysis_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.analytics.v1.AnalysisType',
      '10': 'analysisType'
    },
    {'1': 'metric_name', '3': 6, '4': 1, '5': 9, '10': 'metricName'},
    {'1': 'trend_slope', '3': 7, '4': 1, '5': 1, '10': 'trendSlope'},
    {'1': 'trend_r_squared', '3': 8, '4': 1, '5': 1, '10': 'trendRSquared'},
    {'1': 'current_value', '3': 9, '4': 1, '5': 1, '10': 'currentValue'},
    {'1': 'baseline_value', '3': 10, '4': 1, '5': 1, '10': 'baselineValue'},
    {
      '1': 'deviation_percent',
      '3': 11,
      '4': 1,
      '5': 1,
      '10': 'deviationPercent'
    },
    {
      '1': 'period_start',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'periodStart'
    },
    {
      '1': 'period_end',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'periodEnd'
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

/// Descriptor for `TemporalAnalysis`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List temporalAnalysisDescriptor = $convert.base64Decode(
    'ChBUZW1wb3JhbEFuYWx5c2lzEg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCH'
    'RlbmFudElkEhcKB2Zhcm1faWQYAyABKAlSBmZhcm1JZBIZCghmaWVsZF9pZBgEIAEoCVIHZmll'
    'bGRJZBJVCg1hbmFseXNpc190eXBlGAUgASgOMjAuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLmFuYW'
    'x5dGljcy52MS5BbmFseXNpc1R5cGVSDGFuYWx5c2lzVHlwZRIfCgttZXRyaWNfbmFtZRgGIAEo'
    'CVIKbWV0cmljTmFtZRIfCgt0cmVuZF9zbG9wZRgHIAEoAVIKdHJlbmRTbG9wZRImCg90cmVuZF'
    '9yX3NxdWFyZWQYCCABKAFSDXRyZW5kUlNxdWFyZWQSIwoNY3VycmVudF92YWx1ZRgJIAEoAVIM'
    'Y3VycmVudFZhbHVlEiUKDmJhc2VsaW5lX3ZhbHVlGAogASgBUg1iYXNlbGluZVZhbHVlEisKEW'
    'RldmlhdGlvbl9wZXJjZW50GAsgASgBUhBkZXZpYXRpb25QZXJjZW50Ej0KDHBlcmlvZF9zdGFy'
    'dBgMIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSC3BlcmlvZFN0YXJ0EjkKCnBlcm'
    'lvZF9lbmQYDSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUglwZXJpb2RFbmQSOQoK'
    'Y3JlYXRlZF9hdBgOIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdA'
    '==');

@$core.Deprecated('Use detectStressRequestDescriptor instead')
const DetectStressRequest$json = {
  '1': 'DetectStressRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'processing_job_id', '3': 3, '4': 1, '5': 9, '10': 'processingJobId'},
  ],
};

/// Descriptor for `DetectStressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectStressRequestDescriptor = $convert.base64Decode(
    'ChNEZXRlY3RTdHJlc3NSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZBIZCghmaWVsZF'
    '9pZBgCIAEoCVIHZmllbGRJZBIqChFwcm9jZXNzaW5nX2pvYl9pZBgDIAEoCVIPcHJvY2Vzc2lu'
    'Z0pvYklk');

@$core.Deprecated('Use detectStressResponseDescriptor instead')
const DetectStressResponse$json = {
  '1': 'DetectStressResponse',
  '2': [
    {
      '1': 'alerts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.satellite.analytics.v1.StressAlert',
      '10': 'alerts'
    },
  ],
};

/// Descriptor for `DetectStressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectStressResponseDescriptor = $convert.base64Decode(
    'ChREZXRlY3RTdHJlc3NSZXNwb25zZRJHCgZhbGVydHMYASADKAsyLy5hZ3JpY3VsdHVyZS5zYX'
    'RlbGxpdGUuYW5hbHl0aWNzLnYxLlN0cmVzc0FsZXJ0UgZhbGVydHM=');

@$core.Deprecated('Use listStressAlertsRequestDescriptor instead')
const ListStressAlertsRequest$json = {
  '1': 'ListStressAlertsRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'stress_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.analytics.v1.StressType',
      '10': 'stressType'
    },
    {
      '1': 'min_severity',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.analytics.v1.SeverityLevel',
      '10': 'minSeverity'
    },
    {
      '1': 'unacknowledged_only',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'unacknowledgedOnly'
    },
  ],
};

/// Descriptor for `ListStressAlertsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listStressAlertsRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0U3RyZXNzQWxlcnRzUmVxdWVzdBIbCglwYWdlX3NpemUYASABKAVSCHBhZ2VTaXplEh'
    '0KCnBhZ2VfdG9rZW4YAiABKAlSCXBhZ2VUb2tlbhIXCgdmYXJtX2lkGAMgASgJUgZmYXJtSWQS'
    'TwoLc3RyZXNzX3R5cGUYBCABKA4yLi5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUuYW5hbHl0aWNzLn'
    'YxLlN0cmVzc1R5cGVSCnN0cmVzc1R5cGUSVAoMbWluX3NldmVyaXR5GAUgASgOMjEuYWdyaWN1'
    'bHR1cmUuc2F0ZWxsaXRlLmFuYWx5dGljcy52MS5TZXZlcml0eUxldmVsUgttaW5TZXZlcml0eR'
    'IvChN1bmFja25vd2xlZGdlZF9vbmx5GAYgASgIUhJ1bmFja25vd2xlZGdlZE9ubHk=');

@$core.Deprecated('Use listStressAlertsResponseDescriptor instead')
const ListStressAlertsResponse$json = {
  '1': 'ListStressAlertsResponse',
  '2': [
    {
      '1': 'alerts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.satellite.analytics.v1.StressAlert',
      '10': 'alerts'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListStressAlertsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listStressAlertsResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0U3RyZXNzQWxlcnRzUmVzcG9uc2USRwoGYWxlcnRzGAEgAygLMi8uYWdyaWN1bHR1cm'
    'Uuc2F0ZWxsaXRlLmFuYWx5dGljcy52MS5TdHJlc3NBbGVydFIGYWxlcnRzEiYKD25leHRfcGFn'
    'ZV90b2tlbhgCIAEoCVINbmV4dFBhZ2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YW'
    'xDb3VudA==');

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
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `AcknowledgeAlertResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List acknowledgeAlertResponseDescriptor =
    $convert.base64Decode(
        'ChhBY2tub3dsZWRnZUFsZXJ0UmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcw==');

@$core.Deprecated('Use runTemporalAnalysisRequestDescriptor instead')
const RunTemporalAnalysisRequest$json = {
  '1': 'RunTemporalAnalysisRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'analysis_type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.analytics.v1.AnalysisType',
      '10': 'analysisType'
    },
    {
      '1': 'period_start',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'periodStart'
    },
    {
      '1': 'period_end',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'periodEnd'
    },
  ],
};

/// Descriptor for `RunTemporalAnalysisRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List runTemporalAnalysisRequestDescriptor = $convert.base64Decode(
    'ChpSdW5UZW1wb3JhbEFuYWx5c2lzUmVxdWVzdBIXCgdmYXJtX2lkGAEgASgJUgZmYXJtSWQSGQ'
    'oIZmllbGRfaWQYAiABKAlSB2ZpZWxkSWQSVQoNYW5hbHlzaXNfdHlwZRgDIAEoDjIwLmFncmlj'
    'dWx0dXJlLnNhdGVsbGl0ZS5hbmFseXRpY3MudjEuQW5hbHlzaXNUeXBlUgxhbmFseXNpc1R5cG'
    'USPQoMcGVyaW9kX3N0YXJ0GAQgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFILcGVy'
    'aW9kU3RhcnQSOQoKcGVyaW9kX2VuZBgFIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbX'
    'BSCXBlcmlvZEVuZA==');

@$core.Deprecated('Use runTemporalAnalysisResponseDescriptor instead')
const RunTemporalAnalysisResponse$json = {
  '1': 'RunTemporalAnalysisResponse',
  '2': [
    {
      '1': 'analysis',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.analytics.v1.TemporalAnalysis',
      '10': 'analysis'
    },
  ],
};

/// Descriptor for `RunTemporalAnalysisResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List runTemporalAnalysisResponseDescriptor =
    $convert.base64Decode(
        'ChtSdW5UZW1wb3JhbEFuYWx5c2lzUmVzcG9uc2USUAoIYW5hbHlzaXMYASABKAsyNC5hZ3JpY3'
        'VsdHVyZS5zYXRlbGxpdGUuYW5hbHl0aWNzLnYxLlRlbXBvcmFsQW5hbHlzaXNSCGFuYWx5c2lz');

@$core.Deprecated('Use getFieldAnalyticsSummaryRequestDescriptor instead')
const GetFieldAnalyticsSummaryRequest$json = {
  '1': 'GetFieldAnalyticsSummaryRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
  ],
};

/// Descriptor for `GetFieldAnalyticsSummaryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFieldAnalyticsSummaryRequestDescriptor =
    $convert.base64Decode(
        'Ch9HZXRGaWVsZEFuYWx5dGljc1N1bW1hcnlSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm'
        '1JZBIZCghmaWVsZF9pZBgCIAEoCVIHZmllbGRJZA==');

@$core.Deprecated('Use getFieldAnalyticsSummaryResponseDescriptor instead')
const GetFieldAnalyticsSummaryResponse$json = {
  '1': 'GetFieldAnalyticsSummaryResponse',
  '2': [
    {
      '1': 'active_stress_alerts',
      '3': 1,
      '4': 1,
      '5': 5,
      '10': 'activeStressAlerts'
    },
    {'1': 'health_score', '3': 2, '4': 1, '5': 1, '10': 'healthScore'},
    {'1': 'ndvi_trend', '3': 3, '4': 1, '5': 1, '10': 'ndviTrend'},
    {
      '1': 'dominant_stress_type',
      '3': 4,
      '4': 1,
      '5': 9,
      '10': 'dominantStressType'
    },
    {
      '1': 'last_analysis',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastAnalysis'
    },
  ],
};

/// Descriptor for `GetFieldAnalyticsSummaryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFieldAnalyticsSummaryResponseDescriptor = $convert.base64Decode(
    'CiBHZXRGaWVsZEFuYWx5dGljc1N1bW1hcnlSZXNwb25zZRIwChRhY3RpdmVfc3RyZXNzX2FsZX'
    'J0cxgBIAEoBVISYWN0aXZlU3RyZXNzQWxlcnRzEiEKDGhlYWx0aF9zY29yZRgCIAEoAVILaGVh'
    'bHRoU2NvcmUSHQoKbmR2aV90cmVuZBgDIAEoAVIJbmR2aVRyZW5kEjAKFGRvbWluYW50X3N0cm'
    'Vzc190eXBlGAQgASgJUhJkb21pbmFudFN0cmVzc1R5cGUSPwoNbGFzdF9hbmFseXNpcxgFIAEo'
    'CzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSDGxhc3RBbmFseXNpcw==');

const $core.Map<$core.String, $core.dynamic>
    SatelliteAnalyticsServiceBase$json = {
  '1': 'SatelliteAnalyticsService',
  '2': [
    {
      '1': 'DetectStress',
      '2': '.agriculture.satellite.analytics.v1.DetectStressRequest',
      '3': '.agriculture.satellite.analytics.v1.DetectStressResponse'
    },
    {
      '1': 'ListStressAlerts',
      '2': '.agriculture.satellite.analytics.v1.ListStressAlertsRequest',
      '3': '.agriculture.satellite.analytics.v1.ListStressAlertsResponse'
    },
    {
      '1': 'AcknowledgeAlert',
      '2': '.agriculture.satellite.analytics.v1.AcknowledgeAlertRequest',
      '3': '.agriculture.satellite.analytics.v1.AcknowledgeAlertResponse'
    },
    {
      '1': 'RunTemporalAnalysis',
      '2': '.agriculture.satellite.analytics.v1.RunTemporalAnalysisRequest',
      '3': '.agriculture.satellite.analytics.v1.RunTemporalAnalysisResponse'
    },
    {
      '1': 'GetFieldAnalyticsSummary',
      '2':
          '.agriculture.satellite.analytics.v1.GetFieldAnalyticsSummaryRequest',
      '3':
          '.agriculture.satellite.analytics.v1.GetFieldAnalyticsSummaryResponse'
    },
  ],
};

@$core.Deprecated('Use satelliteAnalyticsServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    SatelliteAnalyticsServiceBase$messageJson = {
  '.agriculture.satellite.analytics.v1.DetectStressRequest':
      DetectStressRequest$json,
  '.agriculture.satellite.analytics.v1.DetectStressResponse':
      DetectStressResponse$json,
  '.agriculture.satellite.analytics.v1.StressAlert': StressAlert$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.satellite.analytics.v1.ListStressAlertsRequest':
      ListStressAlertsRequest$json,
  '.agriculture.satellite.analytics.v1.ListStressAlertsResponse':
      ListStressAlertsResponse$json,
  '.agriculture.satellite.analytics.v1.AcknowledgeAlertRequest':
      AcknowledgeAlertRequest$json,
  '.agriculture.satellite.analytics.v1.AcknowledgeAlertResponse':
      AcknowledgeAlertResponse$json,
  '.agriculture.satellite.analytics.v1.RunTemporalAnalysisRequest':
      RunTemporalAnalysisRequest$json,
  '.agriculture.satellite.analytics.v1.RunTemporalAnalysisResponse':
      RunTemporalAnalysisResponse$json,
  '.agriculture.satellite.analytics.v1.TemporalAnalysis': TemporalAnalysis$json,
  '.agriculture.satellite.analytics.v1.GetFieldAnalyticsSummaryRequest':
      GetFieldAnalyticsSummaryRequest$json,
  '.agriculture.satellite.analytics.v1.GetFieldAnalyticsSummaryResponse':
      GetFieldAnalyticsSummaryResponse$json,
};

/// Descriptor for `SatelliteAnalyticsService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List satelliteAnalyticsServiceDescriptor = $convert.base64Decode(
    'ChlTYXRlbGxpdGVBbmFseXRpY3NTZXJ2aWNlEoEBCgxEZXRlY3RTdHJlc3MSNy5hZ3JpY3VsdH'
    'VyZS5zYXRlbGxpdGUuYW5hbHl0aWNzLnYxLkRldGVjdFN0cmVzc1JlcXVlc3QaOC5hZ3JpY3Vs'
    'dHVyZS5zYXRlbGxpdGUuYW5hbHl0aWNzLnYxLkRldGVjdFN0cmVzc1Jlc3BvbnNlEo0BChBMaX'
    'N0U3RyZXNzQWxlcnRzEjsuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLmFuYWx5dGljcy52MS5MaXN0'
    'U3RyZXNzQWxlcnRzUmVxdWVzdBo8LmFncmljdWx0dXJlLnNhdGVsbGl0ZS5hbmFseXRpY3Mudj'
    'EuTGlzdFN0cmVzc0FsZXJ0c1Jlc3BvbnNlEo0BChBBY2tub3dsZWRnZUFsZXJ0EjsuYWdyaWN1'
    'bHR1cmUuc2F0ZWxsaXRlLmFuYWx5dGljcy52MS5BY2tub3dsZWRnZUFsZXJ0UmVxdWVzdBo8Lm'
    'FncmljdWx0dXJlLnNhdGVsbGl0ZS5hbmFseXRpY3MudjEuQWNrbm93bGVkZ2VBbGVydFJlc3Bv'
    'bnNlEpYBChNSdW5UZW1wb3JhbEFuYWx5c2lzEj4uYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLmFuYW'
    'x5dGljcy52MS5SdW5UZW1wb3JhbEFuYWx5c2lzUmVxdWVzdBo/LmFncmljdWx0dXJlLnNhdGVs'
    'bGl0ZS5hbmFseXRpY3MudjEuUnVuVGVtcG9yYWxBbmFseXNpc1Jlc3BvbnNlEqUBChhHZXRGaW'
    'VsZEFuYWx5dGljc1N1bW1hcnkSQy5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUuYW5hbHl0aWNzLnYx'
    'LkdldEZpZWxkQW5hbHl0aWNzU3VtbWFyeVJlcXVlc3QaRC5hZ3JpY3VsdHVyZS5zYXRlbGxpdG'
    'UuYW5hbHl0aWNzLnYxLkdldEZpZWxkQW5hbHl0aWNzU3VtbWFyeVJlc3BvbnNl');
