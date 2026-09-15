// This is a generated file - do not edit.
//
// Generated from inspection.proto.

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

@$core.Deprecated('Use inspectionStatusDescriptor instead')
const InspectionStatus$json = {
  '1': 'InspectionStatus',
  '2': [
    {'1': 'INSPECTION_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'INSPECTION_STATUS_DRAFT', '2': 1},
    {'1': 'INSPECTION_STATUS_SUBMITTED', '2': 2},
    {'1': 'INSPECTION_STATUS_REVIEWED', '2': 3},
  ],
};

/// Descriptor for `InspectionStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List inspectionStatusDescriptor = $convert.base64Decode(
    'ChBJbnNwZWN0aW9uU3RhdHVzEiEKHUlOU1BFQ1RJT05fU1RBVFVTX1VOU1BFQ0lGSUVEEAASGw'
    'oXSU5TUEVDVElPTl9TVEFUVVNfRFJBRlQQARIfChtJTlNQRUNUSU9OX1NUQVRVU19TVUJNSVRU'
    'RUQQAhIeChpJTlNQRUNUSU9OX1NUQVRVU19SRVZJRVdFRBAD');

@$core.Deprecated('Use issueSeverityDescriptor instead')
const IssueSeverity$json = {
  '1': 'IssueSeverity',
  '2': [
    {'1': 'ISSUE_SEVERITY_UNSPECIFIED', '2': 0},
    {'1': 'ISSUE_SEVERITY_LOW', '2': 1},
    {'1': 'ISSUE_SEVERITY_MEDIUM', '2': 2},
    {'1': 'ISSUE_SEVERITY_HIGH', '2': 3},
    {'1': 'ISSUE_SEVERITY_CRITICAL', '2': 4},
  ],
};

/// Descriptor for `IssueSeverity`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List issueSeverityDescriptor = $convert.base64Decode(
    'Cg1Jc3N1ZVNldmVyaXR5Eh4KGklTU1VFX1NFVkVSSVRZX1VOU1BFQ0lGSUVEEAASFgoSSVNTVU'
    'VfU0VWRVJJVFlfTE9XEAESGQoVSVNTVUVfU0VWRVJJVFlfTUVESVVNEAISFwoTSVNTVUVfU0VW'
    'RVJJVFlfSElHSBADEhsKF0lTU1VFX1NFVkVSSVRZX0NSSVRJQ0FMEAQ=');

@$core.Deprecated('Use inspectionIssueDescriptor instead')
const InspectionIssue$json = {
  '1': 'InspectionIssue',
  '2': [
    {'1': 'description', '3': 1, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'severity',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.agronomy.v1.IssueSeverity',
      '10': 'severity'
    },
    {'1': 'photo_url', '3': 3, '4': 1, '5': 9, '10': 'photoUrl'},
  ],
};

/// Descriptor for `InspectionIssue`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inspectionIssueDescriptor = $convert.base64Decode(
    'Cg9JbnNwZWN0aW9uSXNzdWUSIAoLZGVzY3JpcHRpb24YASABKAlSC2Rlc2NyaXB0aW9uEkIKCH'
    'NldmVyaXR5GAIgASgOMiYuYWdyaWN1bHR1cmUuYWdyb25vbXkudjEuSXNzdWVTZXZlcml0eVII'
    'c2V2ZXJpdHkSGwoJcGhvdG9fdXJsGAMgASgJUghwaG90b1VybA==');

@$core.Deprecated('Use inspectionDescriptor instead')
const Inspection$json = {
  '1': 'Inspection',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'inspector_id', '3': 4, '4': 1, '5': 9, '10': 'inspectorId'},
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.agronomy.v1.InspectionStatus',
      '10': 'status'
    },
    {'1': 'findings', '3': 6, '4': 1, '5': 9, '10': 'findings'},
    {'1': 'photos', '3': 7, '4': 3, '5': 9, '10': 'photos'},
    {'1': 'recommendations', '3': 8, '4': 3, '5': 9, '10': 'recommendations'},
    {
      '1': 'issues',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.agriculture.agronomy.v1.InspectionIssue',
      '10': 'issues'
    },
    {'1': 'health_score', '3': 10, '4': 1, '5': 1, '10': 'healthScore'},
    {'1': 'notes', '3': 11, '4': 1, '5': 9, '10': 'notes'},
    {
      '1': 'inspection_date',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'inspectionDate'
    },
    {
      '1': 'created_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `Inspection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List inspectionDescriptor = $convert.base64Decode(
    'CgpJbnNwZWN0aW9uEg4KAmlkGAEgASgJUgJpZBIZCghmaWVsZF9pZBgCIAEoCVIHZmllbGRJZB'
    'IXCgdmYXJtX2lkGAMgASgJUgZmYXJtSWQSIQoMaW5zcGVjdG9yX2lkGAQgASgJUgtpbnNwZWN0'
    'b3JJZBJBCgZzdGF0dXMYBSABKA4yKS5hZ3JpY3VsdHVyZS5hZ3Jvbm9teS52MS5JbnNwZWN0aW'
    '9uU3RhdHVzUgZzdGF0dXMSGgoIZmluZGluZ3MYBiABKAlSCGZpbmRpbmdzEhYKBnBob3RvcxgH'
    'IAMoCVIGcGhvdG9zEigKD3JlY29tbWVuZGF0aW9ucxgIIAMoCVIPcmVjb21tZW5kYXRpb25zEk'
    'AKBmlzc3VlcxgJIAMoCzIoLmFncmljdWx0dXJlLmFncm9ub215LnYxLkluc3BlY3Rpb25Jc3N1'
    'ZVIGaXNzdWVzEiEKDGhlYWx0aF9zY29yZRgKIAEoAVILaGVhbHRoU2NvcmUSFAoFbm90ZXMYCy'
    'ABKAlSBW5vdGVzEkMKD2luc3BlY3Rpb25fZGF0ZRgMIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5U'
    'aW1lc3RhbXBSDmluc3BlY3Rpb25EYXRlEjkKCmNyZWF0ZWRfYXQYDSABKAsyGi5nb29nbGUucH'
    'JvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRlZF9hdBgOIAEoCzIaLmdvb2ds'
    'ZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdA==');

@$core.Deprecated('Use getInspectionRequestDescriptor instead')
const GetInspectionRequest$json = {
  '1': 'GetInspectionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetInspectionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getInspectionRequestDescriptor = $convert
    .base64Decode('ChRHZXRJbnNwZWN0aW9uUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use getInspectionResponseDescriptor instead')
const GetInspectionResponse$json = {
  '1': 'GetInspectionResponse',
  '2': [
    {
      '1': 'inspection',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.agronomy.v1.Inspection',
      '10': 'inspection'
    },
  ],
};

/// Descriptor for `GetInspectionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getInspectionResponseDescriptor = $convert.base64Decode(
    'ChVHZXRJbnNwZWN0aW9uUmVzcG9uc2USQwoKaW5zcGVjdGlvbhgBIAEoCzIjLmFncmljdWx0dX'
    'JlLmFncm9ub215LnYxLkluc3BlY3Rpb25SCmluc3BlY3Rpb24=');

@$core.Deprecated('Use listInspectionsRequestDescriptor instead')
const ListInspectionsRequest$json = {
  '1': 'ListInspectionsRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'inspector_id', '3': 3, '4': 1, '5': 9, '10': 'inspectorId'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.agronomy.v1.InspectionStatus',
      '10': 'status'
    },
    {'1': 'page_size', '3': 5, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 6, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListInspectionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listInspectionsRequestDescriptor = $convert.base64Decode(
    'ChZMaXN0SW5zcGVjdGlvbnNSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZBIZCghmaW'
    'VsZF9pZBgCIAEoCVIHZmllbGRJZBIhCgxpbnNwZWN0b3JfaWQYAyABKAlSC2luc3BlY3Rvcklk'
    'EkEKBnN0YXR1cxgEIAEoDjIpLmFncmljdWx0dXJlLmFncm9ub215LnYxLkluc3BlY3Rpb25TdG'
    'F0dXNSBnN0YXR1cxIbCglwYWdlX3NpemUYBSABKAVSCHBhZ2VTaXplEh0KCnBhZ2VfdG9rZW4Y'
    'BiABKAlSCXBhZ2VUb2tlbg==');

@$core.Deprecated('Use listInspectionsResponseDescriptor instead')
const ListInspectionsResponse$json = {
  '1': 'ListInspectionsResponse',
  '2': [
    {
      '1': 'inspections',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.agronomy.v1.Inspection',
      '10': 'inspections'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListInspectionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listInspectionsResponseDescriptor = $convert.base64Decode(
    'ChdMaXN0SW5zcGVjdGlvbnNSZXNwb25zZRJFCgtpbnNwZWN0aW9ucxgBIAMoCzIjLmFncmljdW'
    'x0dXJlLmFncm9ub215LnYxLkluc3BlY3Rpb25SC2luc3BlY3Rpb25zEiYKD25leHRfcGFnZV90'
    'b2tlbhgCIAEoCVINbmV4dFBhZ2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3'
    'VudA==');

@$core.Deprecated('Use createInspectionRequestDescriptor instead')
const CreateInspectionRequest$json = {
  '1': 'CreateInspectionRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'findings', '3': 3, '4': 1, '5': 9, '10': 'findings'},
    {'1': 'photos', '3': 4, '4': 3, '5': 9, '10': 'photos'},
    {'1': 'recommendations', '3': 5, '4': 3, '5': 9, '10': 'recommendations'},
    {
      '1': 'issues',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.agriculture.agronomy.v1.InspectionIssue',
      '10': 'issues'
    },
    {'1': 'health_score', '3': 7, '4': 1, '5': 1, '10': 'healthScore'},
    {'1': 'notes', '3': 8, '4': 1, '5': 9, '10': 'notes'},
    {
      '1': 'inspection_date',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'inspectionDate'
    },
  ],
};

/// Descriptor for `CreateInspectionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createInspectionRequestDescriptor = $convert.base64Decode(
    'ChdDcmVhdGVJbnNwZWN0aW9uUmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBIXCg'
    'dmYXJtX2lkGAIgASgJUgZmYXJtSWQSGgoIZmluZGluZ3MYAyABKAlSCGZpbmRpbmdzEhYKBnBo'
    'b3RvcxgEIAMoCVIGcGhvdG9zEigKD3JlY29tbWVuZGF0aW9ucxgFIAMoCVIPcmVjb21tZW5kYX'
    'Rpb25zEkAKBmlzc3VlcxgGIAMoCzIoLmFncmljdWx0dXJlLmFncm9ub215LnYxLkluc3BlY3Rp'
    'b25Jc3N1ZVIGaXNzdWVzEiEKDGhlYWx0aF9zY29yZRgHIAEoAVILaGVhbHRoU2NvcmUSFAoFbm'
    '90ZXMYCCABKAlSBW5vdGVzEkMKD2luc3BlY3Rpb25fZGF0ZRgJIAEoCzIaLmdvb2dsZS5wcm90'
    'b2J1Zi5UaW1lc3RhbXBSDmluc3BlY3Rpb25EYXRl');

@$core.Deprecated('Use createInspectionResponseDescriptor instead')
const CreateInspectionResponse$json = {
  '1': 'CreateInspectionResponse',
  '2': [
    {
      '1': 'inspection',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.agronomy.v1.Inspection',
      '10': 'inspection'
    },
  ],
};

/// Descriptor for `CreateInspectionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createInspectionResponseDescriptor =
    $convert.base64Decode(
        'ChhDcmVhdGVJbnNwZWN0aW9uUmVzcG9uc2USQwoKaW5zcGVjdGlvbhgBIAEoCzIjLmFncmljdW'
        'x0dXJlLmFncm9ub215LnYxLkluc3BlY3Rpb25SCmluc3BlY3Rpb24=');

@$core.Deprecated('Use submitInspectionRequestDescriptor instead')
const SubmitInspectionRequest$json = {
  '1': 'SubmitInspectionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `SubmitInspectionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitInspectionRequestDescriptor = $convert
    .base64Decode('ChdTdWJtaXRJbnNwZWN0aW9uUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use submitInspectionResponseDescriptor instead')
const SubmitInspectionResponse$json = {
  '1': 'SubmitInspectionResponse',
  '2': [
    {
      '1': 'inspection',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.agronomy.v1.Inspection',
      '10': 'inspection'
    },
  ],
};

/// Descriptor for `SubmitInspectionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitInspectionResponseDescriptor =
    $convert.base64Decode(
        'ChhTdWJtaXRJbnNwZWN0aW9uUmVzcG9uc2USQwoKaW5zcGVjdGlvbhgBIAEoCzIjLmFncmljdW'
        'x0dXJlLmFncm9ub215LnYxLkluc3BlY3Rpb25SCmluc3BlY3Rpb24=');

const $core.Map<$core.String, $core.dynamic> InspectionServiceBase$json = {
  '1': 'InspectionService',
  '2': [
    {
      '1': 'GetInspection',
      '2': '.agriculture.agronomy.v1.GetInspectionRequest',
      '3': '.agriculture.agronomy.v1.GetInspectionResponse'
    },
    {
      '1': 'ListInspections',
      '2': '.agriculture.agronomy.v1.ListInspectionsRequest',
      '3': '.agriculture.agronomy.v1.ListInspectionsResponse'
    },
    {
      '1': 'CreateInspection',
      '2': '.agriculture.agronomy.v1.CreateInspectionRequest',
      '3': '.agriculture.agronomy.v1.CreateInspectionResponse'
    },
    {
      '1': 'SubmitInspection',
      '2': '.agriculture.agronomy.v1.SubmitInspectionRequest',
      '3': '.agriculture.agronomy.v1.SubmitInspectionResponse'
    },
  ],
};

@$core.Deprecated('Use inspectionServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    InspectionServiceBase$messageJson = {
  '.agriculture.agronomy.v1.GetInspectionRequest': GetInspectionRequest$json,
  '.agriculture.agronomy.v1.GetInspectionResponse': GetInspectionResponse$json,
  '.agriculture.agronomy.v1.Inspection': Inspection$json,
  '.agriculture.agronomy.v1.InspectionIssue': InspectionIssue$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.agronomy.v1.ListInspectionsRequest':
      ListInspectionsRequest$json,
  '.agriculture.agronomy.v1.ListInspectionsResponse':
      ListInspectionsResponse$json,
  '.agriculture.agronomy.v1.CreateInspectionRequest':
      CreateInspectionRequest$json,
  '.agriculture.agronomy.v1.CreateInspectionResponse':
      CreateInspectionResponse$json,
  '.agriculture.agronomy.v1.SubmitInspectionRequest':
      SubmitInspectionRequest$json,
  '.agriculture.agronomy.v1.SubmitInspectionResponse':
      SubmitInspectionResponse$json,
};

/// Descriptor for `InspectionService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List inspectionServiceDescriptor = $convert.base64Decode(
    'ChFJbnNwZWN0aW9uU2VydmljZRJuCg1HZXRJbnNwZWN0aW9uEi0uYWdyaWN1bHR1cmUuYWdyb2'
    '5vbXkudjEuR2V0SW5zcGVjdGlvblJlcXVlc3QaLi5hZ3JpY3VsdHVyZS5hZ3Jvbm9teS52MS5H'
    'ZXRJbnNwZWN0aW9uUmVzcG9uc2USdAoPTGlzdEluc3BlY3Rpb25zEi8uYWdyaWN1bHR1cmUuYW'
    'dyb25vbXkudjEuTGlzdEluc3BlY3Rpb25zUmVxdWVzdBowLmFncmljdWx0dXJlLmFncm9ub215'
    'LnYxLkxpc3RJbnNwZWN0aW9uc1Jlc3BvbnNlEncKEENyZWF0ZUluc3BlY3Rpb24SMC5hZ3JpY3'
    'VsdHVyZS5hZ3Jvbm9teS52MS5DcmVhdGVJbnNwZWN0aW9uUmVxdWVzdBoxLmFncmljdWx0dXJl'
    'LmFncm9ub215LnYxLkNyZWF0ZUluc3BlY3Rpb25SZXNwb25zZRJ3ChBTdWJtaXRJbnNwZWN0aW'
    '9uEjAuYWdyaWN1bHR1cmUuYWdyb25vbXkudjEuU3VibWl0SW5zcGVjdGlvblJlcXVlc3QaMS5h'
    'Z3JpY3VsdHVyZS5hZ3Jvbm9teS52MS5TdWJtaXRJbnNwZWN0aW9uUmVzcG9uc2U=');
