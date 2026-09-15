// This is a generated file - do not edit.
//
// Generated from advisory.proto.

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

@$core.Deprecated('Use advisorySeverityDescriptor instead')
const AdvisorySeverity$json = {
  '1': 'AdvisorySeverity',
  '2': [
    {'1': 'ADVISORY_SEVERITY_UNSPECIFIED', '2': 0},
    {'1': 'ADVISORY_SEVERITY_LOW', '2': 1},
    {'1': 'ADVISORY_SEVERITY_MEDIUM', '2': 2},
    {'1': 'ADVISORY_SEVERITY_HIGH', '2': 3},
    {'1': 'ADVISORY_SEVERITY_CRITICAL', '2': 4},
  ],
};

/// Descriptor for `AdvisorySeverity`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List advisorySeverityDescriptor = $convert.base64Decode(
    'ChBBZHZpc29yeVNldmVyaXR5EiEKHUFEVklTT1JZX1NFVkVSSVRZX1VOU1BFQ0lGSUVEEAASGQ'
    'oVQURWSVNPUllfU0VWRVJJVFlfTE9XEAESHAoYQURWSVNPUllfU0VWRVJJVFlfTUVESVVNEAIS'
    'GgoWQURWSVNPUllfU0VWRVJJVFlfSElHSBADEh4KGkFEVklTT1JZX1NFVkVSSVRZX0NSSVRJQ0'
    'FMEAQ=');

@$core.Deprecated('Use advisoryDescriptor instead')
const Advisory$json = {
  '1': 'Advisory',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'title', '3': 2, '4': 1, '5': 9, '10': 'title'},
    {'1': 'content', '3': 3, '4': 1, '5': 9, '10': 'content'},
    {'1': 'crop_type', '3': 4, '4': 1, '5': 9, '10': 'cropType'},
    {
      '1': 'severity',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.agronomy.v1.AdvisorySeverity',
      '10': 'severity'
    },
    {'1': 'region', '3': 6, '4': 1, '5': 9, '10': 'region'},
    {'1': 'farm_id', '3': 7, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 8, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'created_by', '3': 9, '4': 1, '5': 9, '10': 'createdBy'},
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

/// Descriptor for `Advisory`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List advisoryDescriptor = $convert.base64Decode(
    'CghBZHZpc29yeRIOCgJpZBgBIAEoCVICaWQSFAoFdGl0bGUYAiABKAlSBXRpdGxlEhgKB2Nvbn'
    'RlbnQYAyABKAlSB2NvbnRlbnQSGwoJY3JvcF90eXBlGAQgASgJUghjcm9wVHlwZRJFCghzZXZl'
    'cml0eRgFIAEoDjIpLmFncmljdWx0dXJlLmFncm9ub215LnYxLkFkdmlzb3J5U2V2ZXJpdHlSCH'
    'NldmVyaXR5EhYKBnJlZ2lvbhgGIAEoCVIGcmVnaW9uEhcKB2Zhcm1faWQYByABKAlSBmZhcm1J'
    'ZBIZCghmaWVsZF9pZBgIIAEoCVIHZmllbGRJZBIdCgpjcmVhdGVkX2J5GAkgASgJUgljcmVhdG'
    'VkQnkSOQoKY3JlYXRlZF9hdBgKIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNy'
    'ZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GAsgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcF'
    'IJdXBkYXRlZEF0');

@$core.Deprecated('Use getAdvisoryRequestDescriptor instead')
const GetAdvisoryRequest$json = {
  '1': 'GetAdvisoryRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetAdvisoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAdvisoryRequestDescriptor =
    $convert.base64Decode('ChJHZXRBZHZpc29yeVJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use getAdvisoryResponseDescriptor instead')
const GetAdvisoryResponse$json = {
  '1': 'GetAdvisoryResponse',
  '2': [
    {
      '1': 'advisory',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.agronomy.v1.Advisory',
      '10': 'advisory'
    },
  ],
};

/// Descriptor for `GetAdvisoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAdvisoryResponseDescriptor = $convert.base64Decode(
    'ChNHZXRBZHZpc29yeVJlc3BvbnNlEj0KCGFkdmlzb3J5GAEgASgLMiEuYWdyaWN1bHR1cmUuYW'
    'dyb25vbXkudjEuQWR2aXNvcnlSCGFkdmlzb3J5');

@$core.Deprecated('Use listAdvisoriesRequestDescriptor instead')
const ListAdvisoriesRequest$json = {
  '1': 'ListAdvisoriesRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_type', '3': 3, '4': 1, '5': 9, '10': 'cropType'},
    {
      '1': 'severity',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.agronomy.v1.AdvisorySeverity',
      '10': 'severity'
    },
    {'1': 'region', '3': 5, '4': 1, '5': 9, '10': 'region'},
    {'1': 'page_size', '3': 6, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 7, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListAdvisoriesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAdvisoriesRequestDescriptor = $convert.base64Decode(
    'ChVMaXN0QWR2aXNvcmllc1JlcXVlc3QSFwoHZmFybV9pZBgBIAEoCVIGZmFybUlkEhkKCGZpZW'
    'xkX2lkGAIgASgJUgdmaWVsZElkEhsKCWNyb3BfdHlwZRgDIAEoCVIIY3JvcFR5cGUSRQoIc2V2'
    'ZXJpdHkYBCABKA4yKS5hZ3JpY3VsdHVyZS5hZ3Jvbm9teS52MS5BZHZpc29yeVNldmVyaXR5Ug'
    'hzZXZlcml0eRIWCgZyZWdpb24YBSABKAlSBnJlZ2lvbhIbCglwYWdlX3NpemUYBiABKAVSCHBh'
    'Z2VTaXplEh0KCnBhZ2VfdG9rZW4YByABKAlSCXBhZ2VUb2tlbg==');

@$core.Deprecated('Use listAdvisoriesResponseDescriptor instead')
const ListAdvisoriesResponse$json = {
  '1': 'ListAdvisoriesResponse',
  '2': [
    {
      '1': 'advisories',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.agronomy.v1.Advisory',
      '10': 'advisories'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListAdvisoriesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAdvisoriesResponseDescriptor = $convert.base64Decode(
    'ChZMaXN0QWR2aXNvcmllc1Jlc3BvbnNlEkEKCmFkdmlzb3JpZXMYASADKAsyIS5hZ3JpY3VsdH'
    'VyZS5hZ3Jvbm9teS52MS5BZHZpc29yeVIKYWR2aXNvcmllcxImCg9uZXh0X3BhZ2VfdG9rZW4Y'
    'AiABKAlSDW5leHRQYWdlVG9rZW4SHwoLdG90YWxfY291bnQYAyABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use createAdvisoryRequestDescriptor instead')
const CreateAdvisoryRequest$json = {
  '1': 'CreateAdvisoryRequest',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'content', '3': 2, '4': 1, '5': 9, '10': 'content'},
    {'1': 'crop_type', '3': 3, '4': 1, '5': 9, '10': 'cropType'},
    {
      '1': 'severity',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.agronomy.v1.AdvisorySeverity',
      '10': 'severity'
    },
    {'1': 'region', '3': 5, '4': 1, '5': 9, '10': 'region'},
    {'1': 'farm_id', '3': 6, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 7, '4': 1, '5': 9, '10': 'fieldId'},
  ],
};

/// Descriptor for `CreateAdvisoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createAdvisoryRequestDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVBZHZpc29yeVJlcXVlc3QSFAoFdGl0bGUYASABKAlSBXRpdGxlEhgKB2NvbnRlbn'
    'QYAiABKAlSB2NvbnRlbnQSGwoJY3JvcF90eXBlGAMgASgJUghjcm9wVHlwZRJFCghzZXZlcml0'
    'eRgEIAEoDjIpLmFncmljdWx0dXJlLmFncm9ub215LnYxLkFkdmlzb3J5U2V2ZXJpdHlSCHNldm'
    'VyaXR5EhYKBnJlZ2lvbhgFIAEoCVIGcmVnaW9uEhcKB2Zhcm1faWQYBiABKAlSBmZhcm1JZBIZ'
    'CghmaWVsZF9pZBgHIAEoCVIHZmllbGRJZA==');

@$core.Deprecated('Use createAdvisoryResponseDescriptor instead')
const CreateAdvisoryResponse$json = {
  '1': 'CreateAdvisoryResponse',
  '2': [
    {
      '1': 'advisory',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.agronomy.v1.Advisory',
      '10': 'advisory'
    },
  ],
};

/// Descriptor for `CreateAdvisoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createAdvisoryResponseDescriptor =
    $convert.base64Decode(
        'ChZDcmVhdGVBZHZpc29yeVJlc3BvbnNlEj0KCGFkdmlzb3J5GAEgASgLMiEuYWdyaWN1bHR1cm'
        'UuYWdyb25vbXkudjEuQWR2aXNvcnlSCGFkdmlzb3J5');

const $core.Map<$core.String, $core.dynamic> AdvisoryServiceBase$json = {
  '1': 'AdvisoryService',
  '2': [
    {
      '1': 'GetAdvisory',
      '2': '.agriculture.agronomy.v1.GetAdvisoryRequest',
      '3': '.agriculture.agronomy.v1.GetAdvisoryResponse'
    },
    {
      '1': 'ListAdvisories',
      '2': '.agriculture.agronomy.v1.ListAdvisoriesRequest',
      '3': '.agriculture.agronomy.v1.ListAdvisoriesResponse'
    },
    {
      '1': 'CreateAdvisory',
      '2': '.agriculture.agronomy.v1.CreateAdvisoryRequest',
      '3': '.agriculture.agronomy.v1.CreateAdvisoryResponse'
    },
  ],
};

@$core.Deprecated('Use advisoryServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    AdvisoryServiceBase$messageJson = {
  '.agriculture.agronomy.v1.GetAdvisoryRequest': GetAdvisoryRequest$json,
  '.agriculture.agronomy.v1.GetAdvisoryResponse': GetAdvisoryResponse$json,
  '.agriculture.agronomy.v1.Advisory': Advisory$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.agronomy.v1.ListAdvisoriesRequest': ListAdvisoriesRequest$json,
  '.agriculture.agronomy.v1.ListAdvisoriesResponse':
      ListAdvisoriesResponse$json,
  '.agriculture.agronomy.v1.CreateAdvisoryRequest': CreateAdvisoryRequest$json,
  '.agriculture.agronomy.v1.CreateAdvisoryResponse':
      CreateAdvisoryResponse$json,
};

/// Descriptor for `AdvisoryService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List advisoryServiceDescriptor = $convert.base64Decode(
    'Cg9BZHZpc29yeVNlcnZpY2USaAoLR2V0QWR2aXNvcnkSKy5hZ3JpY3VsdHVyZS5hZ3Jvbm9teS'
    '52MS5HZXRBZHZpc29yeVJlcXVlc3QaLC5hZ3JpY3VsdHVyZS5hZ3Jvbm9teS52MS5HZXRBZHZp'
    'c29yeVJlc3BvbnNlEnEKDkxpc3RBZHZpc29yaWVzEi4uYWdyaWN1bHR1cmUuYWdyb25vbXkudj'
    'EuTGlzdEFkdmlzb3JpZXNSZXF1ZXN0Gi8uYWdyaWN1bHR1cmUuYWdyb25vbXkudjEuTGlzdEFk'
    'dmlzb3JpZXNSZXNwb25zZRJxCg5DcmVhdGVBZHZpc29yeRIuLmFncmljdWx0dXJlLmFncm9ub2'
    '15LnYxLkNyZWF0ZUFkdmlzb3J5UmVxdWVzdBovLmFncmljdWx0dXJlLmFncm9ub215LnYxLkNy'
    'ZWF0ZUFkdmlzb3J5UmVzcG9uc2U=');
