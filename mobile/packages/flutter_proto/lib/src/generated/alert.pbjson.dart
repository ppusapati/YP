// This is a generated file - do not edit.
//
// Generated from alert.proto.

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

@$core.Deprecated('Use alertSeverityDescriptor instead')
const AlertSeverity$json = {
  '1': 'AlertSeverity',
  '2': [
    {'1': 'ALERT_SEVERITY_UNSPECIFIED', '2': 0},
    {'1': 'ALERT_SEVERITY_INFO', '2': 1},
    {'1': 'ALERT_SEVERITY_WARNING', '2': 2},
    {'1': 'ALERT_SEVERITY_CRITICAL', '2': 3},
    {'1': 'ALERT_SEVERITY_EMERGENCY', '2': 4},
  ],
};

/// Descriptor for `AlertSeverity`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List alertSeverityDescriptor = $convert.base64Decode(
    'Cg1BbGVydFNldmVyaXR5Eh4KGkFMRVJUX1NFVkVSSVRZX1VOU1BFQ0lGSUVEEAASFwoTQUxFUl'
    'RfU0VWRVJJVFlfSU5GTxABEhoKFkFMRVJUX1NFVkVSSVRZX1dBUk5JTkcQAhIbChdBTEVSVF9T'
    'RVZFUklUWV9DUklUSUNBTBADEhwKGEFMRVJUX1NFVkVSSVRZX0VNRVJHRU5DWRAE');

@$core.Deprecated('Use alertStatusDescriptor instead')
const AlertStatus$json = {
  '1': 'AlertStatus',
  '2': [
    {'1': 'ALERT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'ALERT_STATUS_ACTIVE', '2': 1},
    {'1': 'ALERT_STATUS_ACKNOWLEDGED', '2': 2},
    {'1': 'ALERT_STATUS_RESOLVED', '2': 3},
  ],
};

/// Descriptor for `AlertStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List alertStatusDescriptor = $convert.base64Decode(
    'CgtBbGVydFN0YXR1cxIcChhBTEVSVF9TVEFUVVNfVU5TUEVDSUZJRUQQABIXChNBTEVSVF9TVE'
    'FUVVNfQUNUSVZFEAESHQoZQUxFUlRfU1RBVFVTX0FDS05PV0xFREdFRBACEhkKFUFMRVJUX1NU'
    'QVRVU19SRVNPTFZFRBAD');

@$core.Deprecated('Use alertDescriptor instead')
const Alert$json = {
  '1': 'Alert',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'type', '3': 2, '4': 1, '5': 9, '10': 'type'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'message', '3': 4, '4': 1, '5': 9, '10': 'message'},
    {
      '1': 'severity',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.alert.v1.AlertSeverity',
      '10': 'severity'
    },
    {
      '1': 'status',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.alert.v1.AlertStatus',
      '10': 'status'
    },
    {'1': 'farm_id', '3': 7, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 8, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'field_name', '3': 9, '4': 1, '5': 9, '10': 'fieldName'},
    {
      '1': 'timestamp',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'read', '3': 11, '4': 1, '5': 8, '10': 'read'},
    {'1': 'action_url', '3': 12, '4': 1, '5': 9, '10': 'actionUrl'},
    {'1': 'recommendations', '3': 13, '4': 3, '5': 9, '10': 'recommendations'},
    {
      '1': 'acknowledged_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'acknowledgedAt'
    },
    {'1': 'acknowledged_by', '3': 15, '4': 1, '5': 9, '10': 'acknowledgedBy'},
    {
      '1': 'metrics',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.agriculture.alert.v1.Alert.MetricsEntry',
      '10': 'metrics'
    },
  ],
  '3': [Alert_MetricsEntry$json],
};

@$core.Deprecated('Use alertDescriptor instead')
const Alert_MetricsEntry$json = {
  '1': 'MetricsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Alert`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List alertDescriptor = $convert.base64Decode(
    'CgVBbGVydBIOCgJpZBgBIAEoCVICaWQSEgoEdHlwZRgCIAEoCVIEdHlwZRIUCgV0aXRsZRgDIA'
    'EoCVIFdGl0bGUSGAoHbWVzc2FnZRgEIAEoCVIHbWVzc2FnZRI/CghzZXZlcml0eRgFIAEoDjIj'
    'LmFncmljdWx0dXJlLmFsZXJ0LnYxLkFsZXJ0U2V2ZXJpdHlSCHNldmVyaXR5EjkKBnN0YXR1cx'
    'gGIAEoDjIhLmFncmljdWx0dXJlLmFsZXJ0LnYxLkFsZXJ0U3RhdHVzUgZzdGF0dXMSFwoHZmFy'
    'bV9pZBgHIAEoCVIGZmFybUlkEhkKCGZpZWxkX2lkGAggASgJUgdmaWVsZElkEh0KCmZpZWxkX2'
    '5hbWUYCSABKAlSCWZpZWxkTmFtZRI4Cgl0aW1lc3RhbXAYCiABKAsyGi5nb29nbGUucHJvdG9i'
    'dWYuVGltZXN0YW1wUgl0aW1lc3RhbXASEgoEcmVhZBgLIAEoCFIEcmVhZBIdCgphY3Rpb25fdX'
    'JsGAwgASgJUglhY3Rpb25VcmwSKAoPcmVjb21tZW5kYXRpb25zGA0gAygJUg9yZWNvbW1lbmRh'
    'dGlvbnMSQwoPYWNrbm93bGVkZ2VkX2F0GA4gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdG'
    'FtcFIOYWNrbm93bGVkZ2VkQXQSJwoPYWNrbm93bGVkZ2VkX2J5GA8gASgJUg5hY2tub3dsZWRn'
    'ZWRCeRJCCgdtZXRyaWNzGBAgAygLMiguYWdyaWN1bHR1cmUuYWxlcnQudjEuQWxlcnQuTWV0cm'
    'ljc0VudHJ5UgdtZXRyaWNzGjoKDE1ldHJpY3NFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2'
    'YWx1ZRgCIAEoAVIFdmFsdWU6AjgB');

@$core.Deprecated('Use alertRuleDescriptor instead')
const AlertRule$json = {
  '1': 'AlertRule',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'metric', '3': 3, '4': 1, '5': 9, '10': 'metric'},
    {'1': 'condition', '3': 4, '4': 1, '5': 9, '10': 'condition'},
    {'1': 'threshold', '3': 5, '4': 1, '5': 1, '10': 'threshold'},
    {
      '1': 'severity',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.alert.v1.AlertSeverity',
      '10': 'severity'
    },
    {'1': 'enabled', '3': 7, '4': 1, '5': 8, '10': 'enabled'},
    {'1': 'notify_channels', '3': 8, '4': 3, '5': 9, '10': 'notifyChannels'},
  ],
};

/// Descriptor for `AlertRule`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List alertRuleDescriptor = $convert.base64Decode(
    'CglBbGVydFJ1bGUSDgoCaWQYASABKAlSAmlkEhkKCGZpZWxkX2lkGAIgASgJUgdmaWVsZElkEh'
    'YKBm1ldHJpYxgDIAEoCVIGbWV0cmljEhwKCWNvbmRpdGlvbhgEIAEoCVIJY29uZGl0aW9uEhwK'
    'CXRocmVzaG9sZBgFIAEoAVIJdGhyZXNob2xkEj8KCHNldmVyaXR5GAYgASgOMiMuYWdyaWN1bH'
    'R1cmUuYWxlcnQudjEuQWxlcnRTZXZlcml0eVIIc2V2ZXJpdHkSGAoHZW5hYmxlZBgHIAEoCFIH'
    'ZW5hYmxlZBInCg9ub3RpZnlfY2hhbm5lbHMYCCADKAlSDm5vdGlmeUNoYW5uZWxz');

@$core.Deprecated('Use fieldRiskScoreDescriptor instead')
const FieldRiskScore$json = {
  '1': 'FieldRiskScore',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'field_name', '3': 2, '4': 1, '5': 9, '10': 'fieldName'},
    {'1': 'overall_score', '3': 3, '4': 1, '5': 1, '10': 'overallScore'},
    {
      '1': 'risk_factors',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.agriculture.alert.v1.FieldRiskScore.RiskFactorsEntry',
      '10': 'riskFactors'
    },
    {'1': 'calculated_at', '3': 5, '4': 1, '5': 9, '10': 'calculatedAt'},
    {'1': 'trend', '3': 6, '4': 1, '5': 9, '10': 'trend'},
  ],
  '3': [FieldRiskScore_RiskFactorsEntry$json],
};

@$core.Deprecated('Use fieldRiskScoreDescriptor instead')
const FieldRiskScore_RiskFactorsEntry$json = {
  '1': 'RiskFactorsEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `FieldRiskScore`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldRiskScoreDescriptor = $convert.base64Decode(
    'Cg5GaWVsZFJpc2tTY29yZRIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBIdCgpmaWVsZF9uYW'
    '1lGAIgASgJUglmaWVsZE5hbWUSIwoNb3ZlcmFsbF9zY29yZRgDIAEoAVIMb3ZlcmFsbFNjb3Jl'
    'ElgKDHJpc2tfZmFjdG9ycxgEIAMoCzI1LmFncmljdWx0dXJlLmFsZXJ0LnYxLkZpZWxkUmlza1'
    'Njb3JlLlJpc2tGYWN0b3JzRW50cnlSC3Jpc2tGYWN0b3JzEiMKDWNhbGN1bGF0ZWRfYXQYBSAB'
    'KAlSDGNhbGN1bGF0ZWRBdBIUCgV0cmVuZBgGIAEoCVIFdHJlbmQaPgoQUmlza0ZhY3RvcnNFbn'
    'RyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoAVIFdmFsdWU6AjgB');

@$core.Deprecated('Use listAlertsRequestDescriptor instead')
const ListAlertsRequest$json = {
  '1': 'ListAlertsRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'severity',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.alert.v1.AlertSeverity',
      '10': 'severity'
    },
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.alert.v1.AlertStatus',
      '10': 'status'
    },
    {'1': 'page_size', '3': 5, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 6, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListAlertsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAlertsRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0QWxlcnRzUmVxdWVzdBIXCgdmYXJtX2lkGAEgASgJUgZmYXJtSWQSGQoIZmllbGRfaW'
    'QYAiABKAlSB2ZpZWxkSWQSPwoIc2V2ZXJpdHkYAyABKA4yIy5hZ3JpY3VsdHVyZS5hbGVydC52'
    'MS5BbGVydFNldmVyaXR5UghzZXZlcml0eRI5CgZzdGF0dXMYBCABKA4yIS5hZ3JpY3VsdHVyZS'
    '5hbGVydC52MS5BbGVydFN0YXR1c1IGc3RhdHVzEhsKCXBhZ2Vfc2l6ZRgFIAEoBVIIcGFnZVNp'
    'emUSHQoKcGFnZV90b2tlbhgGIAEoCVIJcGFnZVRva2Vu');

@$core.Deprecated('Use listAlertsResponseDescriptor instead')
const ListAlertsResponse$json = {
  '1': 'ListAlertsResponse',
  '2': [
    {
      '1': 'alerts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.alert.v1.Alert',
      '10': 'alerts'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListAlertsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAlertsResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0QWxlcnRzUmVzcG9uc2USMwoGYWxlcnRzGAEgAygLMhsuYWdyaWN1bHR1cmUuYWxlcn'
    'QudjEuQWxlcnRSBmFsZXJ0cxImCg9uZXh0X3BhZ2VfdG9rZW4YAiABKAlSDW5leHRQYWdlVG9r'
    'ZW4SHwoLdG90YWxfY291bnQYAyABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use getAlertRequestDescriptor instead')
const GetAlertRequest$json = {
  '1': 'GetAlertRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetAlertRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAlertRequestDescriptor =
    $convert.base64Decode('Cg9HZXRBbGVydFJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use getAlertResponseDescriptor instead')
const GetAlertResponse$json = {
  '1': 'GetAlertResponse',
  '2': [
    {
      '1': 'alert',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.alert.v1.Alert',
      '10': 'alert'
    },
  ],
};

/// Descriptor for `GetAlertResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAlertResponseDescriptor = $convert.base64Decode(
    'ChBHZXRBbGVydFJlc3BvbnNlEjEKBWFsZXJ0GAEgASgLMhsuYWdyaWN1bHR1cmUuYWxlcnQudj'
    'EuQWxlcnRSBWFsZXJ0');

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
      '6': '.agriculture.alert.v1.Alert',
      '10': 'alert'
    },
  ],
};

/// Descriptor for `AcknowledgeAlertResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List acknowledgeAlertResponseDescriptor =
    $convert.base64Decode(
        'ChhBY2tub3dsZWRnZUFsZXJ0UmVzcG9uc2USMQoFYWxlcnQYASABKAsyGy5hZ3JpY3VsdHVyZS'
        '5hbGVydC52MS5BbGVydFIFYWxlcnQ=');

@$core.Deprecated('Use resolveAlertRequestDescriptor instead')
const ResolveAlertRequest$json = {
  '1': 'ResolveAlertRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `ResolveAlertRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveAlertRequestDescriptor = $convert
    .base64Decode('ChNSZXNvbHZlQWxlcnRSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use resolveAlertResponseDescriptor instead')
const ResolveAlertResponse$json = {
  '1': 'ResolveAlertResponse',
  '2': [
    {
      '1': 'alert',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.alert.v1.Alert',
      '10': 'alert'
    },
  ],
};

/// Descriptor for `ResolveAlertResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List resolveAlertResponseDescriptor = $convert.base64Decode(
    'ChRSZXNvbHZlQWxlcnRSZXNwb25zZRIxCgVhbGVydBgBIAEoCzIbLmFncmljdWx0dXJlLmFsZX'
    'J0LnYxLkFsZXJ0UgVhbGVydA==');

@$core.Deprecated('Use markAlertReadRequestDescriptor instead')
const MarkAlertReadRequest$json = {
  '1': 'MarkAlertReadRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `MarkAlertReadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markAlertReadRequestDescriptor = $convert
    .base64Decode('ChRNYXJrQWxlcnRSZWFkUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use markAlertReadResponseDescriptor instead')
const MarkAlertReadResponse$json = {
  '1': 'MarkAlertReadResponse',
  '2': [
    {
      '1': 'alert',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.alert.v1.Alert',
      '10': 'alert'
    },
  ],
};

/// Descriptor for `MarkAlertReadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markAlertReadResponseDescriptor = $convert.base64Decode(
    'ChVNYXJrQWxlcnRSZWFkUmVzcG9uc2USMQoFYWxlcnQYASABKAsyGy5hZ3JpY3VsdHVyZS5hbG'
    'VydC52MS5BbGVydFIFYWxlcnQ=');

@$core.Deprecated('Use markAllAlertsReadRequestDescriptor instead')
const MarkAllAlertsReadRequest$json = {
  '1': 'MarkAllAlertsReadRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
  ],
};

/// Descriptor for `MarkAllAlertsReadRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markAllAlertsReadRequestDescriptor =
    $convert.base64Decode(
        'ChhNYXJrQWxsQWxlcnRzUmVhZFJlcXVlc3QSFwoHZmFybV9pZBgBIAEoCVIGZmFybUlk');

@$core.Deprecated('Use markAllAlertsReadResponseDescriptor instead')
const MarkAllAlertsReadResponse$json = {
  '1': 'MarkAllAlertsReadResponse',
  '2': [
    {'1': 'updated_count', '3': 1, '4': 1, '5': 5, '10': 'updatedCount'},
  ],
};

/// Descriptor for `MarkAllAlertsReadResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List markAllAlertsReadResponseDescriptor =
    $convert.base64Decode(
        'ChlNYXJrQWxsQWxlcnRzUmVhZFJlc3BvbnNlEiMKDXVwZGF0ZWRfY291bnQYASABKAVSDHVwZG'
        'F0ZWRDb3VudA==');

@$core.Deprecated('Use getUnreadCountRequestDescriptor instead')
const GetUnreadCountRequest$json = {
  '1': 'GetUnreadCountRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
  ],
};

/// Descriptor for `GetUnreadCountRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUnreadCountRequestDescriptor =
    $convert.base64Decode(
        'ChVHZXRVbnJlYWRDb3VudFJlcXVlc3QSFwoHZmFybV9pZBgBIAEoCVIGZmFybUlk');

@$core.Deprecated('Use getUnreadCountResponseDescriptor instead')
const GetUnreadCountResponse$json = {
  '1': 'GetUnreadCountResponse',
  '2': [
    {'1': 'count', '3': 1, '4': 1, '5': 5, '10': 'count'},
  ],
};

/// Descriptor for `GetUnreadCountResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getUnreadCountResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRVbnJlYWRDb3VudFJlc3BvbnNlEhQKBWNvdW50GAEgASgFUgVjb3VudA==');

@$core.Deprecated('Use listAlertRulesRequestDescriptor instead')
const ListAlertRulesRequest$json = {
  '1': 'ListAlertRulesRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
  ],
};

/// Descriptor for `ListAlertRulesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAlertRulesRequestDescriptor =
    $convert.base64Decode(
        'ChVMaXN0QWxlcnRSdWxlc1JlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQ=');

@$core.Deprecated('Use listAlertRulesResponseDescriptor instead')
const ListAlertRulesResponse$json = {
  '1': 'ListAlertRulesResponse',
  '2': [
    {
      '1': 'rules',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.alert.v1.AlertRule',
      '10': 'rules'
    },
  ],
};

/// Descriptor for `ListAlertRulesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAlertRulesResponseDescriptor =
    $convert.base64Decode(
        'ChZMaXN0QWxlcnRSdWxlc1Jlc3BvbnNlEjUKBXJ1bGVzGAEgAygLMh8uYWdyaWN1bHR1cmUuYW'
        'xlcnQudjEuQWxlcnRSdWxlUgVydWxlcw==');

@$core.Deprecated('Use createAlertRuleRequestDescriptor instead')
const CreateAlertRuleRequest$json = {
  '1': 'CreateAlertRuleRequest',
  '2': [
    {
      '1': 'rule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.alert.v1.AlertRule',
      '10': 'rule'
    },
  ],
};

/// Descriptor for `CreateAlertRuleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createAlertRuleRequestDescriptor =
    $convert.base64Decode(
        'ChZDcmVhdGVBbGVydFJ1bGVSZXF1ZXN0EjMKBHJ1bGUYASABKAsyHy5hZ3JpY3VsdHVyZS5hbG'
        'VydC52MS5BbGVydFJ1bGVSBHJ1bGU=');

@$core.Deprecated('Use createAlertRuleResponseDescriptor instead')
const CreateAlertRuleResponse$json = {
  '1': 'CreateAlertRuleResponse',
  '2': [
    {
      '1': 'rule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.alert.v1.AlertRule',
      '10': 'rule'
    },
  ],
};

/// Descriptor for `CreateAlertRuleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createAlertRuleResponseDescriptor =
    $convert.base64Decode(
        'ChdDcmVhdGVBbGVydFJ1bGVSZXNwb25zZRIzCgRydWxlGAEgASgLMh8uYWdyaWN1bHR1cmUuYW'
        'xlcnQudjEuQWxlcnRSdWxlUgRydWxl');

@$core.Deprecated('Use updateAlertRuleRequestDescriptor instead')
const UpdateAlertRuleRequest$json = {
  '1': 'UpdateAlertRuleRequest',
  '2': [
    {
      '1': 'rule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.alert.v1.AlertRule',
      '10': 'rule'
    },
  ],
};

/// Descriptor for `UpdateAlertRuleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateAlertRuleRequestDescriptor =
    $convert.base64Decode(
        'ChZVcGRhdGVBbGVydFJ1bGVSZXF1ZXN0EjMKBHJ1bGUYASABKAsyHy5hZ3JpY3VsdHVyZS5hbG'
        'VydC52MS5BbGVydFJ1bGVSBHJ1bGU=');

@$core.Deprecated('Use updateAlertRuleResponseDescriptor instead')
const UpdateAlertRuleResponse$json = {
  '1': 'UpdateAlertRuleResponse',
  '2': [
    {
      '1': 'rule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.alert.v1.AlertRule',
      '10': 'rule'
    },
  ],
};

/// Descriptor for `UpdateAlertRuleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateAlertRuleResponseDescriptor =
    $convert.base64Decode(
        'ChdVcGRhdGVBbGVydFJ1bGVSZXNwb25zZRIzCgRydWxlGAEgASgLMh8uYWdyaWN1bHR1cmUuYW'
        'xlcnQudjEuQWxlcnRSdWxlUgRydWxl');

@$core.Deprecated('Use getFieldRiskRequestDescriptor instead')
const GetFieldRiskRequest$json = {
  '1': 'GetFieldRiskRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
  ],
};

/// Descriptor for `GetFieldRiskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFieldRiskRequestDescriptor =
    $convert.base64Decode(
        'ChNHZXRGaWVsZFJpc2tSZXF1ZXN0EhkKCGZpZWxkX2lkGAEgASgJUgdmaWVsZElk');

@$core.Deprecated('Use getFieldRiskResponseDescriptor instead')
const GetFieldRiskResponse$json = {
  '1': 'GetFieldRiskResponse',
  '2': [
    {
      '1': 'risk_score',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.alert.v1.FieldRiskScore',
      '10': 'riskScore'
    },
  ],
};

/// Descriptor for `GetFieldRiskResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFieldRiskResponseDescriptor = $convert.base64Decode(
    'ChRHZXRGaWVsZFJpc2tSZXNwb25zZRJDCgpyaXNrX3Njb3JlGAEgASgLMiQuYWdyaWN1bHR1cm'
    'UuYWxlcnQudjEuRmllbGRSaXNrU2NvcmVSCXJpc2tTY29yZQ==');

@$core.Deprecated('Use listFieldRisksRequestDescriptor instead')
const ListFieldRisksRequest$json = {
  '1': 'ListFieldRisksRequest',
};

/// Descriptor for `ListFieldRisksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFieldRisksRequestDescriptor =
    $convert.base64Decode('ChVMaXN0RmllbGRSaXNrc1JlcXVlc3Q=');

@$core.Deprecated('Use listFieldRisksResponseDescriptor instead')
const ListFieldRisksResponse$json = {
  '1': 'ListFieldRisksResponse',
  '2': [
    {
      '1': 'risk_scores',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.alert.v1.FieldRiskScore',
      '10': 'riskScores'
    },
  ],
};

/// Descriptor for `ListFieldRisksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFieldRisksResponseDescriptor =
    $convert.base64Decode(
        'ChZMaXN0RmllbGRSaXNrc1Jlc3BvbnNlEkUKC3Jpc2tfc2NvcmVzGAEgAygLMiQuYWdyaWN1bH'
        'R1cmUuYWxlcnQudjEuRmllbGRSaXNrU2NvcmVSCnJpc2tTY29yZXM=');

@$core.Deprecated('Use listAlertHistoryRequestDescriptor instead')
const ListAlertHistoryRequest$json = {
  '1': 'ListAlertHistoryRequest',
  '2': [
    {'1': 'start_date', '3': 1, '4': 1, '5': 9, '10': 'startDate'},
    {'1': 'end_date', '3': 2, '4': 1, '5': 9, '10': 'endDate'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'page_size', '3': 5, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 6, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListAlertHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAlertHistoryRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0QWxlcnRIaXN0b3J5UmVxdWVzdBIdCgpzdGFydF9kYXRlGAEgASgJUglzdGFydERhdG'
    'USGQoIZW5kX2RhdGUYAiABKAlSB2VuZERhdGUSFwoHZmFybV9pZBgDIAEoCVIGZmFybUlkEhkK'
    'CGZpZWxkX2lkGAQgASgJUgdmaWVsZElkEhsKCXBhZ2Vfc2l6ZRgFIAEoBVIIcGFnZVNpemUSHQ'
    'oKcGFnZV90b2tlbhgGIAEoCVIJcGFnZVRva2Vu');

@$core.Deprecated('Use listAlertHistoryResponseDescriptor instead')
const ListAlertHistoryResponse$json = {
  '1': 'ListAlertHistoryResponse',
  '2': [
    {
      '1': 'alerts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.alert.v1.Alert',
      '10': 'alerts'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListAlertHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAlertHistoryResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0QWxlcnRIaXN0b3J5UmVzcG9uc2USMwoGYWxlcnRzGAEgAygLMhsuYWdyaWN1bHR1cm'
    'UuYWxlcnQudjEuQWxlcnRSBmFsZXJ0cxImCg9uZXh0X3BhZ2VfdG9rZW4YAiABKAlSDW5leHRQ'
    'YWdlVG9rZW4SHwoLdG90YWxfY291bnQYAyABKAVSCnRvdGFsQ291bnQ=');

const $core.Map<$core.String, $core.dynamic> AlertServiceBase$json = {
  '1': 'AlertService',
  '2': [
    {
      '1': 'ListAlerts',
      '2': '.agriculture.alert.v1.ListAlertsRequest',
      '3': '.agriculture.alert.v1.ListAlertsResponse'
    },
    {
      '1': 'GetAlert',
      '2': '.agriculture.alert.v1.GetAlertRequest',
      '3': '.agriculture.alert.v1.GetAlertResponse'
    },
    {
      '1': 'AcknowledgeAlert',
      '2': '.agriculture.alert.v1.AcknowledgeAlertRequest',
      '3': '.agriculture.alert.v1.AcknowledgeAlertResponse'
    },
    {
      '1': 'ResolveAlert',
      '2': '.agriculture.alert.v1.ResolveAlertRequest',
      '3': '.agriculture.alert.v1.ResolveAlertResponse'
    },
    {
      '1': 'MarkAlertRead',
      '2': '.agriculture.alert.v1.MarkAlertReadRequest',
      '3': '.agriculture.alert.v1.MarkAlertReadResponse'
    },
    {
      '1': 'MarkAllAlertsRead',
      '2': '.agriculture.alert.v1.MarkAllAlertsReadRequest',
      '3': '.agriculture.alert.v1.MarkAllAlertsReadResponse'
    },
    {
      '1': 'GetUnreadCount',
      '2': '.agriculture.alert.v1.GetUnreadCountRequest',
      '3': '.agriculture.alert.v1.GetUnreadCountResponse'
    },
    {
      '1': 'ListAlertRules',
      '2': '.agriculture.alert.v1.ListAlertRulesRequest',
      '3': '.agriculture.alert.v1.ListAlertRulesResponse'
    },
    {
      '1': 'CreateAlertRule',
      '2': '.agriculture.alert.v1.CreateAlertRuleRequest',
      '3': '.agriculture.alert.v1.CreateAlertRuleResponse'
    },
    {
      '1': 'UpdateAlertRule',
      '2': '.agriculture.alert.v1.UpdateAlertRuleRequest',
      '3': '.agriculture.alert.v1.UpdateAlertRuleResponse'
    },
    {
      '1': 'GetFieldRisk',
      '2': '.agriculture.alert.v1.GetFieldRiskRequest',
      '3': '.agriculture.alert.v1.GetFieldRiskResponse'
    },
    {
      '1': 'ListFieldRisks',
      '2': '.agriculture.alert.v1.ListFieldRisksRequest',
      '3': '.agriculture.alert.v1.ListFieldRisksResponse'
    },
    {
      '1': 'ListAlertHistory',
      '2': '.agriculture.alert.v1.ListAlertHistoryRequest',
      '3': '.agriculture.alert.v1.ListAlertHistoryResponse'
    },
  ],
};

@$core.Deprecated('Use alertServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    AlertServiceBase$messageJson = {
  '.agriculture.alert.v1.ListAlertsRequest': ListAlertsRequest$json,
  '.agriculture.alert.v1.ListAlertsResponse': ListAlertsResponse$json,
  '.agriculture.alert.v1.Alert': Alert$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.alert.v1.Alert.MetricsEntry': Alert_MetricsEntry$json,
  '.agriculture.alert.v1.GetAlertRequest': GetAlertRequest$json,
  '.agriculture.alert.v1.GetAlertResponse': GetAlertResponse$json,
  '.agriculture.alert.v1.AcknowledgeAlertRequest': AcknowledgeAlertRequest$json,
  '.agriculture.alert.v1.AcknowledgeAlertResponse':
      AcknowledgeAlertResponse$json,
  '.agriculture.alert.v1.ResolveAlertRequest': ResolveAlertRequest$json,
  '.agriculture.alert.v1.ResolveAlertResponse': ResolveAlertResponse$json,
  '.agriculture.alert.v1.MarkAlertReadRequest': MarkAlertReadRequest$json,
  '.agriculture.alert.v1.MarkAlertReadResponse': MarkAlertReadResponse$json,
  '.agriculture.alert.v1.MarkAllAlertsReadRequest':
      MarkAllAlertsReadRequest$json,
  '.agriculture.alert.v1.MarkAllAlertsReadResponse':
      MarkAllAlertsReadResponse$json,
  '.agriculture.alert.v1.GetUnreadCountRequest': GetUnreadCountRequest$json,
  '.agriculture.alert.v1.GetUnreadCountResponse': GetUnreadCountResponse$json,
  '.agriculture.alert.v1.ListAlertRulesRequest': ListAlertRulesRequest$json,
  '.agriculture.alert.v1.ListAlertRulesResponse': ListAlertRulesResponse$json,
  '.agriculture.alert.v1.AlertRule': AlertRule$json,
  '.agriculture.alert.v1.CreateAlertRuleRequest': CreateAlertRuleRequest$json,
  '.agriculture.alert.v1.CreateAlertRuleResponse': CreateAlertRuleResponse$json,
  '.agriculture.alert.v1.UpdateAlertRuleRequest': UpdateAlertRuleRequest$json,
  '.agriculture.alert.v1.UpdateAlertRuleResponse': UpdateAlertRuleResponse$json,
  '.agriculture.alert.v1.GetFieldRiskRequest': GetFieldRiskRequest$json,
  '.agriculture.alert.v1.GetFieldRiskResponse': GetFieldRiskResponse$json,
  '.agriculture.alert.v1.FieldRiskScore': FieldRiskScore$json,
  '.agriculture.alert.v1.FieldRiskScore.RiskFactorsEntry':
      FieldRiskScore_RiskFactorsEntry$json,
  '.agriculture.alert.v1.ListFieldRisksRequest': ListFieldRisksRequest$json,
  '.agriculture.alert.v1.ListFieldRisksResponse': ListFieldRisksResponse$json,
  '.agriculture.alert.v1.ListAlertHistoryRequest': ListAlertHistoryRequest$json,
  '.agriculture.alert.v1.ListAlertHistoryResponse':
      ListAlertHistoryResponse$json,
};

/// Descriptor for `AlertService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List alertServiceDescriptor = $convert.base64Decode(
    'CgxBbGVydFNlcnZpY2USXwoKTGlzdEFsZXJ0cxInLmFncmljdWx0dXJlLmFsZXJ0LnYxLkxpc3'
    'RBbGVydHNSZXF1ZXN0GiguYWdyaWN1bHR1cmUuYWxlcnQudjEuTGlzdEFsZXJ0c1Jlc3BvbnNl'
    'ElkKCEdldEFsZXJ0EiUuYWdyaWN1bHR1cmUuYWxlcnQudjEuR2V0QWxlcnRSZXF1ZXN0GiYuYW'
    'dyaWN1bHR1cmUuYWxlcnQudjEuR2V0QWxlcnRSZXNwb25zZRJxChBBY2tub3dsZWRnZUFsZXJ0'
    'Ei0uYWdyaWN1bHR1cmUuYWxlcnQudjEuQWNrbm93bGVkZ2VBbGVydFJlcXVlc3QaLi5hZ3JpY3'
    'VsdHVyZS5hbGVydC52MS5BY2tub3dsZWRnZUFsZXJ0UmVzcG9uc2USZQoMUmVzb2x2ZUFsZXJ0'
    'EikuYWdyaWN1bHR1cmUuYWxlcnQudjEuUmVzb2x2ZUFsZXJ0UmVxdWVzdBoqLmFncmljdWx0dX'
    'JlLmFsZXJ0LnYxLlJlc29sdmVBbGVydFJlc3BvbnNlEmgKDU1hcmtBbGVydFJlYWQSKi5hZ3Jp'
    'Y3VsdHVyZS5hbGVydC52MS5NYXJrQWxlcnRSZWFkUmVxdWVzdBorLmFncmljdWx0dXJlLmFsZX'
    'J0LnYxLk1hcmtBbGVydFJlYWRSZXNwb25zZRJ0ChFNYXJrQWxsQWxlcnRzUmVhZBIuLmFncmlj'
    'dWx0dXJlLmFsZXJ0LnYxLk1hcmtBbGxBbGVydHNSZWFkUmVxdWVzdBovLmFncmljdWx0dXJlLm'
    'FsZXJ0LnYxLk1hcmtBbGxBbGVydHNSZWFkUmVzcG9uc2USawoOR2V0VW5yZWFkQ291bnQSKy5h'
    'Z3JpY3VsdHVyZS5hbGVydC52MS5HZXRVbnJlYWRDb3VudFJlcXVlc3QaLC5hZ3JpY3VsdHVyZS'
    '5hbGVydC52MS5HZXRVbnJlYWRDb3VudFJlc3BvbnNlEmsKDkxpc3RBbGVydFJ1bGVzEisuYWdy'
    'aWN1bHR1cmUuYWxlcnQudjEuTGlzdEFsZXJ0UnVsZXNSZXF1ZXN0GiwuYWdyaWN1bHR1cmUuYW'
    'xlcnQudjEuTGlzdEFsZXJ0UnVsZXNSZXNwb25zZRJuCg9DcmVhdGVBbGVydFJ1bGUSLC5hZ3Jp'
    'Y3VsdHVyZS5hbGVydC52MS5DcmVhdGVBbGVydFJ1bGVSZXF1ZXN0Gi0uYWdyaWN1bHR1cmUuYW'
    'xlcnQudjEuQ3JlYXRlQWxlcnRSdWxlUmVzcG9uc2USbgoPVXBkYXRlQWxlcnRSdWxlEiwuYWdy'
    'aWN1bHR1cmUuYWxlcnQudjEuVXBkYXRlQWxlcnRSdWxlUmVxdWVzdBotLmFncmljdWx0dXJlLm'
    'FsZXJ0LnYxLlVwZGF0ZUFsZXJ0UnVsZVJlc3BvbnNlEmUKDEdldEZpZWxkUmlzaxIpLmFncmlj'
    'dWx0dXJlLmFsZXJ0LnYxLkdldEZpZWxkUmlza1JlcXVlc3QaKi5hZ3JpY3VsdHVyZS5hbGVydC'
    '52MS5HZXRGaWVsZFJpc2tSZXNwb25zZRJrCg5MaXN0RmllbGRSaXNrcxIrLmFncmljdWx0dXJl'
    'LmFsZXJ0LnYxLkxpc3RGaWVsZFJpc2tzUmVxdWVzdBosLmFncmljdWx0dXJlLmFsZXJ0LnYxLk'
    'xpc3RGaWVsZFJpc2tzUmVzcG9uc2UScQoQTGlzdEFsZXJ0SGlzdG9yeRItLmFncmljdWx0dXJl'
    'LmFsZXJ0LnYxLkxpc3RBbGVydEhpc3RvcnlSZXF1ZXN0Gi4uYWdyaWN1bHR1cmUuYWxlcnQudj'
    'EuTGlzdEFsZXJ0SGlzdG9yeVJlc3BvbnNl');
