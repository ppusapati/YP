// This is a generated file - do not edit.
//
// Generated from soillab.proto.

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

@$core.Deprecated('Use reportFormatDescriptor instead')
const ReportFormat$json = {
  '1': 'ReportFormat',
  '2': [
    {'1': 'REPORT_FORMAT_UNSPECIFIED', '2': 0},
    {'1': 'REPORT_FORMAT_CSV', '2': 1},
    {'1': 'REPORT_FORMAT_PDF', '2': 2},
  ],
};

/// Descriptor for `ReportFormat`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List reportFormatDescriptor = $convert.base64Decode(
    'CgxSZXBvcnRGb3JtYXQSHQoZUkVQT1JUX0ZPUk1BVF9VTlNQRUNJRklFRBAAEhUKEVJFUE9SVF'
    '9GT1JNQVRfQ1NWEAESFQoRUkVQT1JUX0ZPUk1BVF9QREYQAg==');

@$core.Deprecated('Use importStatusDescriptor instead')
const ImportStatus$json = {
  '1': 'ImportStatus',
  '2': [
    {'1': 'IMPORT_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'IMPORT_STATUS_RECEIVED', '2': 1},
    {'1': 'IMPORT_STATUS_PARSED', '2': 2},
    {'1': 'IMPORT_STATUS_NEEDS_REVIEW', '2': 3},
    {'1': 'IMPORT_STATUS_APPLIED', '2': 4},
    {'1': 'IMPORT_STATUS_REJECTED', '2': 5},
  ],
};

/// Descriptor for `ImportStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List importStatusDescriptor = $convert.base64Decode(
    'CgxJbXBvcnRTdGF0dXMSHQoZSU1QT1JUX1NUQVRVU19VTlNQRUNJRklFRBAAEhoKFklNUE9SVF'
    '9TVEFUVVNfUkVDRUlWRUQQARIYChRJTVBPUlRfU1RBVFVTX1BBUlNFRBACEh4KGklNUE9SVF9T'
    'VEFUVVNfTkVFRFNfUkVWSUVXEAMSGQoVSU1QT1JUX1NUQVRVU19BUFBMSUVEEAQSGgoWSU1QT1'
    'JUX1NUQVRVU19SRUpFQ1RFRBAF');

@$core.Deprecated('Use labDescriptor instead')
const Lab$json = {
  '1': 'Lab',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'accreditation', '3': 3, '4': 1, '5': 9, '10': 'accreditation'},
    {'1': 'contact_email', '3': 4, '4': 1, '5': 9, '10': 'contactEmail'},
    {
      '1': 'column_aliases',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.agriculture.soillab.v1.Lab.ColumnAliasesEntry',
      '10': 'columnAliases'
    },
  ],
  '3': [Lab_ColumnAliasesEntry$json],
};

@$core.Deprecated('Use labDescriptor instead')
const Lab_ColumnAliasesEntry$json = {
  '1': 'ColumnAliasesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Lab`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List labDescriptor = $convert.base64Decode(
    'CgNMYWISDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSJAoNYWNjcmVkaXRhdG'
    'lvbhgDIAEoCVINYWNjcmVkaXRhdGlvbhIjCg1jb250YWN0X2VtYWlsGAQgASgJUgxjb250YWN0'
    'RW1haWwSVQoOY29sdW1uX2FsaWFzZXMYBSADKAsyLi5hZ3JpY3VsdHVyZS5zb2lsbGFiLnYxLk'
    'xhYi5Db2x1bW5BbGlhc2VzRW50cnlSDWNvbHVtbkFsaWFzZXMaQAoSQ29sdW1uQWxpYXNlc0Vu'
    'dHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use labResultDescriptor instead')
const LabResult$json = {
  '1': 'LabResult',
  '2': [
    {'1': 'analyte', '3': 1, '4': 1, '5': 9, '10': 'analyte'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
    {'1': 'unit', '3': 3, '4': 1, '5': 9, '10': 'unit'},
    {'1': 'suspect', '3': 4, '4': 1, '5': 8, '10': 'suspect'},
    {'1': 'note', '3': 5, '4': 1, '5': 9, '10': 'note'},
  ],
};

/// Descriptor for `LabResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List labResultDescriptor = $convert.base64Decode(
    'CglMYWJSZXN1bHQSGAoHYW5hbHl0ZRgBIAEoCVIHYW5hbHl0ZRIUCgV2YWx1ZRgCIAEoAVIFdm'
    'FsdWUSEgoEdW5pdBgDIAEoCVIEdW5pdBIYCgdzdXNwZWN0GAQgASgIUgdzdXNwZWN0EhIKBG5v'
    'dGUYBSABKAlSBG5vdGU=');

@$core.Deprecated('Use reportRowDescriptor instead')
const ReportRow$json = {
  '1': 'ReportRow',
  '2': [
    {'1': 'line_number', '3': 1, '4': 1, '5': 5, '10': 'lineNumber'},
    {'1': 'sample_ref', '3': 2, '4': 1, '5': 9, '10': 'sampleRef'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'depth_cm', '3': 4, '4': 1, '5': 1, '10': 'depthCm'},
    {
      '1': 'collected_on',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'collectedOn'
    },
    {
      '1': 'results',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.agriculture.soillab.v1.LabResult',
      '10': 'results'
    },
    {'1': 'blocker', '3': 7, '4': 1, '5': 9, '10': 'blocker'},
  ],
};

/// Descriptor for `ReportRow`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reportRowDescriptor = $convert.base64Decode(
    'CglSZXBvcnRSb3cSHwoLbGluZV9udW1iZXIYASABKAVSCmxpbmVOdW1iZXISHQoKc2FtcGxlX3'
    'JlZhgCIAEoCVIJc2FtcGxlUmVmEhkKCGZpZWxkX2lkGAMgASgJUgdmaWVsZElkEhkKCGRlcHRo'
    'X2NtGAQgASgBUgdkZXB0aENtEj0KDGNvbGxlY3RlZF9vbhgFIAEoCzIaLmdvb2dsZS5wcm90b2'
    'J1Zi5UaW1lc3RhbXBSC2NvbGxlY3RlZE9uEjsKB3Jlc3VsdHMYBiADKAsyIS5hZ3JpY3VsdHVy'
    'ZS5zb2lsbGFiLnYxLkxhYlJlc3VsdFIHcmVzdWx0cxIYCgdibG9ja2VyGAcgASgJUgdibG9ja2'
    'Vy');

@$core.Deprecated('Use labReportDescriptor instead')
const LabReport$json = {
  '1': 'LabReport',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'lab_id', '3': 2, '4': 1, '5': 9, '10': 'labId'},
    {'1': 'lab_name', '3': 3, '4': 1, '5': 9, '10': 'labName'},
    {
      '1': 'format',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.soillab.v1.ReportFormat',
      '10': 'format'
    },
    {'1': 'filename', '3': 5, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'storage_url', '3': 6, '4': 1, '5': 9, '10': 'storageUrl'},
    {'1': 'content_sha256', '3': 7, '4': 1, '5': 9, '10': 'contentSha256'},
    {
      '1': 'status',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.agriculture.soillab.v1.ImportStatus',
      '10': 'status'
    },
    {'1': 'row_count', '3': 9, '4': 1, '5': 5, '10': 'rowCount'},
    {'1': 'applied_count', '3': 10, '4': 1, '5': 5, '10': 'appliedCount'},
    {'1': 'blocked_count', '3': 11, '4': 1, '5': 5, '10': 'blockedCount'},
    {
      '1': 'rows',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.agriculture.soillab.v1.ReportRow',
      '10': 'rows'
    },
    {
      '1': 'uploaded_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'uploadedAt'
    },
    {
      '1': 'applied_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'appliedAt'
    },
    {'1': 'uploaded_by', '3': 15, '4': 1, '5': 9, '10': 'uploadedBy'},
    {'1': 'rejection_reason', '3': 16, '4': 1, '5': 9, '10': 'rejectionReason'},
  ],
};

/// Descriptor for `LabReport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List labReportDescriptor = $convert.base64Decode(
    'CglMYWJSZXBvcnQSDgoCaWQYASABKAlSAmlkEhUKBmxhYl9pZBgCIAEoCVIFbGFiSWQSGQoIbG'
    'FiX25hbWUYAyABKAlSB2xhYk5hbWUSPAoGZm9ybWF0GAQgASgOMiQuYWdyaWN1bHR1cmUuc29p'
    'bGxhYi52MS5SZXBvcnRGb3JtYXRSBmZvcm1hdBIaCghmaWxlbmFtZRgFIAEoCVIIZmlsZW5hbW'
    'USHwoLc3RvcmFnZV91cmwYBiABKAlSCnN0b3JhZ2VVcmwSJQoOY29udGVudF9zaGEyNTYYByAB'
    'KAlSDWNvbnRlbnRTaGEyNTYSPAoGc3RhdHVzGAggASgOMiQuYWdyaWN1bHR1cmUuc29pbGxhYi'
    '52MS5JbXBvcnRTdGF0dXNSBnN0YXR1cxIbCglyb3dfY291bnQYCSABKAVSCHJvd0NvdW50EiMK'
    'DWFwcGxpZWRfY291bnQYCiABKAVSDGFwcGxpZWRDb3VudBIjCg1ibG9ja2VkX2NvdW50GAsgAS'
    'gFUgxibG9ja2VkQ291bnQSNQoEcm93cxgMIAMoCzIhLmFncmljdWx0dXJlLnNvaWxsYWIudjEu'
    'UmVwb3J0Um93UgRyb3dzEjsKC3VwbG9hZGVkX2F0GA0gASgLMhouZ29vZ2xlLnByb3RvYnVmLl'
    'RpbWVzdGFtcFIKdXBsb2FkZWRBdBI5CgphcHBsaWVkX2F0GA4gASgLMhouZ29vZ2xlLnByb3Rv'
    'YnVmLlRpbWVzdGFtcFIJYXBwbGllZEF0Eh8KC3VwbG9hZGVkX2J5GA8gASgJUgp1cGxvYWRlZE'
    'J5EikKEHJlamVjdGlvbl9yZWFzb24YECABKAlSD3JlamVjdGlvblJlYXNvbg==');

@$core.Deprecated('Use registerLabRequestDescriptor instead')
const RegisterLabRequest$json = {
  '1': 'RegisterLabRequest',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'accreditation', '3': 2, '4': 1, '5': 9, '10': 'accreditation'},
    {'1': 'contact_email', '3': 3, '4': 1, '5': 9, '10': 'contactEmail'},
    {
      '1': 'column_aliases',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.agriculture.soillab.v1.RegisterLabRequest.ColumnAliasesEntry',
      '10': 'columnAliases'
    },
  ],
  '3': [RegisterLabRequest_ColumnAliasesEntry$json],
};

@$core.Deprecated('Use registerLabRequestDescriptor instead')
const RegisterLabRequest_ColumnAliasesEntry$json = {
  '1': 'ColumnAliasesEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `RegisterLabRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerLabRequestDescriptor = $convert.base64Decode(
    'ChJSZWdpc3RlckxhYlJlcXVlc3QSEgoEbmFtZRgBIAEoCVIEbmFtZRIkCg1hY2NyZWRpdGF0aW'
    '9uGAIgASgJUg1hY2NyZWRpdGF0aW9uEiMKDWNvbnRhY3RfZW1haWwYAyABKAlSDGNvbnRhY3RF'
    'bWFpbBJkCg5jb2x1bW5fYWxpYXNlcxgEIAMoCzI9LmFncmljdWx0dXJlLnNvaWxsYWIudjEuUm'
    'VnaXN0ZXJMYWJSZXF1ZXN0LkNvbHVtbkFsaWFzZXNFbnRyeVINY29sdW1uQWxpYXNlcxpAChJD'
    'b2x1bW5BbGlhc2VzRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbH'
    'VlOgI4AQ==');

@$core.Deprecated('Use registerLabResponseDescriptor instead')
const RegisterLabResponse$json = {
  '1': 'RegisterLabResponse',
  '2': [
    {
      '1': 'lab',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soillab.v1.Lab',
      '10': 'lab'
    },
  ],
};

/// Descriptor for `RegisterLabResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerLabResponseDescriptor = $convert.base64Decode(
    'ChNSZWdpc3RlckxhYlJlc3BvbnNlEi0KA2xhYhgBIAEoCzIbLmFncmljdWx0dXJlLnNvaWxsYW'
    'IudjEuTGFiUgNsYWI=');

@$core.Deprecated('Use listLabsRequestDescriptor instead')
const ListLabsRequest$json = {
  '1': 'ListLabsRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListLabsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listLabsRequestDescriptor = $convert.base64Decode(
    'Cg9MaXN0TGFic1JlcXVlc3QSGwoJcGFnZV9zaXplGAEgASgFUghwYWdlU2l6ZRIdCgpwYWdlX3'
    'Rva2VuGAIgASgJUglwYWdlVG9rZW4=');

@$core.Deprecated('Use listLabsResponseDescriptor instead')
const ListLabsResponse$json = {
  '1': 'ListLabsResponse',
  '2': [
    {
      '1': 'labs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.soillab.v1.Lab',
      '10': 'labs'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListLabsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listLabsResponseDescriptor = $convert.base64Decode(
    'ChBMaXN0TGFic1Jlc3BvbnNlEi8KBGxhYnMYASADKAsyGy5hZ3JpY3VsdHVyZS5zb2lsbGFiLn'
    'YxLkxhYlIEbGFicxImCg9uZXh0X3BhZ2VfdG9rZW4YAiABKAlSDW5leHRQYWdlVG9rZW4SHwoL'
    'dG90YWxfY291bnQYAyABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use uploadReportRequestDescriptor instead')
const UploadReportRequest$json = {
  '1': 'UploadReportRequest',
  '2': [
    {'1': 'lab_id', '3': 1, '4': 1, '5': 9, '10': 'labId'},
    {
      '1': 'format',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.soillab.v1.ReportFormat',
      '10': 'format'
    },
    {'1': 'filename', '3': 3, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'content', '3': 4, '4': 1, '5': 12, '10': 'content'},
  ],
};

/// Descriptor for `UploadReportRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadReportRequestDescriptor = $convert.base64Decode(
    'ChNVcGxvYWRSZXBvcnRSZXF1ZXN0EhUKBmxhYl9pZBgBIAEoCVIFbGFiSWQSPAoGZm9ybWF0GA'
    'IgASgOMiQuYWdyaWN1bHR1cmUuc29pbGxhYi52MS5SZXBvcnRGb3JtYXRSBmZvcm1hdBIaCghm'
    'aWxlbmFtZRgDIAEoCVIIZmlsZW5hbWUSGAoHY29udGVudBgEIAEoDFIHY29udGVudA==');

@$core.Deprecated('Use uploadReportResponseDescriptor instead')
const UploadReportResponse$json = {
  '1': 'UploadReportResponse',
  '2': [
    {
      '1': 'report',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soillab.v1.LabReport',
      '10': 'report'
    },
    {'1': 'duplicate', '3': 2, '4': 1, '5': 8, '10': 'duplicate'},
  ],
};

/// Descriptor for `UploadReportResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uploadReportResponseDescriptor = $convert.base64Decode(
    'ChRVcGxvYWRSZXBvcnRSZXNwb25zZRI5CgZyZXBvcnQYASABKAsyIS5hZ3JpY3VsdHVyZS5zb2'
    'lsbGFiLnYxLkxhYlJlcG9ydFIGcmVwb3J0EhwKCWR1cGxpY2F0ZRgCIAEoCFIJZHVwbGljYXRl');

@$core.Deprecated('Use getReportRequestDescriptor instead')
const GetReportRequest$json = {
  '1': 'GetReportRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetReportRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReportRequestDescriptor =
    $convert.base64Decode('ChBHZXRSZXBvcnRSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use getReportResponseDescriptor instead')
const GetReportResponse$json = {
  '1': 'GetReportResponse',
  '2': [
    {
      '1': 'report',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soillab.v1.LabReport',
      '10': 'report'
    },
  ],
};

/// Descriptor for `GetReportResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReportResponseDescriptor = $convert.base64Decode(
    'ChFHZXRSZXBvcnRSZXNwb25zZRI5CgZyZXBvcnQYASABKAsyIS5hZ3JpY3VsdHVyZS5zb2lsbG'
    'FiLnYxLkxhYlJlcG9ydFIGcmVwb3J0');

@$core.Deprecated('Use listReportsRequestDescriptor instead')
const ListReportsRequest$json = {
  '1': 'ListReportsRequest',
  '2': [
    {'1': 'lab_id', '3': 1, '4': 1, '5': 9, '10': 'labId'},
    {
      '1': 'status',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.soillab.v1.ImportStatus',
      '10': 'status'
    },
    {'1': 'page_size', '3': 3, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 4, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListReportsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listReportsRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0UmVwb3J0c1JlcXVlc3QSFQoGbGFiX2lkGAEgASgJUgVsYWJJZBI8CgZzdGF0dXMYAi'
    'ABKA4yJC5hZ3JpY3VsdHVyZS5zb2lsbGFiLnYxLkltcG9ydFN0YXR1c1IGc3RhdHVzEhsKCXBh'
    'Z2Vfc2l6ZRgDIAEoBVIIcGFnZVNpemUSHQoKcGFnZV90b2tlbhgEIAEoCVIJcGFnZVRva2Vu');

@$core.Deprecated('Use listReportsResponseDescriptor instead')
const ListReportsResponse$json = {
  '1': 'ListReportsResponse',
  '2': [
    {
      '1': 'reports',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.soillab.v1.LabReport',
      '10': 'reports'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListReportsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listReportsResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0UmVwb3J0c1Jlc3BvbnNlEjsKB3JlcG9ydHMYASADKAsyIS5hZ3JpY3VsdHVyZS5zb2'
    'lsbGFiLnYxLkxhYlJlcG9ydFIHcmVwb3J0cxImCg9uZXh0X3BhZ2VfdG9rZW4YAiABKAlSDW5l'
    'eHRQYWdlVG9rZW4SHwoLdG90YWxfY291bnQYAyABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use applyReportRequestDescriptor instead')
const ApplyReportRequest$json = {
  '1': 'ApplyReportRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'skip_blocked', '3': 2, '4': 1, '5': 8, '10': 'skipBlocked'},
  ],
};

/// Descriptor for `ApplyReportRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applyReportRequestDescriptor = $convert.base64Decode(
    'ChJBcHBseVJlcG9ydFJlcXVlc3QSDgoCaWQYASABKAlSAmlkEiEKDHNraXBfYmxvY2tlZBgCIA'
    'EoCFILc2tpcEJsb2NrZWQ=');

@$core.Deprecated('Use applyReportResponseDescriptor instead')
const ApplyReportResponse$json = {
  '1': 'ApplyReportResponse',
  '2': [
    {
      '1': 'report',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soillab.v1.LabReport',
      '10': 'report'
    },
    {
      '1': 'created_sample_ids',
      '3': 2,
      '4': 3,
      '5': 9,
      '10': 'createdSampleIds'
    },
  ],
};

/// Descriptor for `ApplyReportResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List applyReportResponseDescriptor = $convert.base64Decode(
    'ChNBcHBseVJlcG9ydFJlc3BvbnNlEjkKBnJlcG9ydBgBIAEoCzIhLmFncmljdWx0dXJlLnNvaW'
    'xsYWIudjEuTGFiUmVwb3J0UgZyZXBvcnQSLAoSY3JlYXRlZF9zYW1wbGVfaWRzGAIgAygJUhBj'
    'cmVhdGVkU2FtcGxlSWRz');

@$core.Deprecated('Use rejectReportRequestDescriptor instead')
const RejectReportRequest$json = {
  '1': 'RejectReportRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `RejectReportRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rejectReportRequestDescriptor = $convert.base64Decode(
    'ChNSZWplY3RSZXBvcnRSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIWCgZyZWFzb24YAiABKAlSBn'
    'JlYXNvbg==');

@$core.Deprecated('Use rejectReportResponseDescriptor instead')
const RejectReportResponse$json = {
  '1': 'RejectReportResponse',
  '2': [
    {
      '1': 'report',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.soillab.v1.LabReport',
      '10': 'report'
    },
  ],
};

/// Descriptor for `RejectReportResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rejectReportResponseDescriptor = $convert.base64Decode(
    'ChRSZWplY3RSZXBvcnRSZXNwb25zZRI5CgZyZXBvcnQYASABKAsyIS5hZ3JpY3VsdHVyZS5zb2'
    'lsbGFiLnYxLkxhYlJlcG9ydFIGcmVwb3J0');

const $core.Map<$core.String, $core.dynamic> SoilLabServiceBase$json = {
  '1': 'SoilLabService',
  '2': [
    {
      '1': 'RegisterLab',
      '2': '.agriculture.soillab.v1.RegisterLabRequest',
      '3': '.agriculture.soillab.v1.RegisterLabResponse'
    },
    {
      '1': 'ListLabs',
      '2': '.agriculture.soillab.v1.ListLabsRequest',
      '3': '.agriculture.soillab.v1.ListLabsResponse'
    },
    {
      '1': 'UploadReport',
      '2': '.agriculture.soillab.v1.UploadReportRequest',
      '3': '.agriculture.soillab.v1.UploadReportResponse'
    },
    {
      '1': 'GetReport',
      '2': '.agriculture.soillab.v1.GetReportRequest',
      '3': '.agriculture.soillab.v1.GetReportResponse'
    },
    {
      '1': 'ListReports',
      '2': '.agriculture.soillab.v1.ListReportsRequest',
      '3': '.agriculture.soillab.v1.ListReportsResponse'
    },
    {
      '1': 'ApplyReport',
      '2': '.agriculture.soillab.v1.ApplyReportRequest',
      '3': '.agriculture.soillab.v1.ApplyReportResponse'
    },
    {
      '1': 'RejectReport',
      '2': '.agriculture.soillab.v1.RejectReportRequest',
      '3': '.agriculture.soillab.v1.RejectReportResponse'
    },
  ],
};

@$core.Deprecated('Use soilLabServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    SoilLabServiceBase$messageJson = {
  '.agriculture.soillab.v1.RegisterLabRequest': RegisterLabRequest$json,
  '.agriculture.soillab.v1.RegisterLabRequest.ColumnAliasesEntry':
      RegisterLabRequest_ColumnAliasesEntry$json,
  '.agriculture.soillab.v1.RegisterLabResponse': RegisterLabResponse$json,
  '.agriculture.soillab.v1.Lab': Lab$json,
  '.agriculture.soillab.v1.Lab.ColumnAliasesEntry': Lab_ColumnAliasesEntry$json,
  '.agriculture.soillab.v1.ListLabsRequest': ListLabsRequest$json,
  '.agriculture.soillab.v1.ListLabsResponse': ListLabsResponse$json,
  '.agriculture.soillab.v1.UploadReportRequest': UploadReportRequest$json,
  '.agriculture.soillab.v1.UploadReportResponse': UploadReportResponse$json,
  '.agriculture.soillab.v1.LabReport': LabReport$json,
  '.agriculture.soillab.v1.ReportRow': ReportRow$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.soillab.v1.LabResult': LabResult$json,
  '.agriculture.soillab.v1.GetReportRequest': GetReportRequest$json,
  '.agriculture.soillab.v1.GetReportResponse': GetReportResponse$json,
  '.agriculture.soillab.v1.ListReportsRequest': ListReportsRequest$json,
  '.agriculture.soillab.v1.ListReportsResponse': ListReportsResponse$json,
  '.agriculture.soillab.v1.ApplyReportRequest': ApplyReportRequest$json,
  '.agriculture.soillab.v1.ApplyReportResponse': ApplyReportResponse$json,
  '.agriculture.soillab.v1.RejectReportRequest': RejectReportRequest$json,
  '.agriculture.soillab.v1.RejectReportResponse': RejectReportResponse$json,
};

/// Descriptor for `SoilLabService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List soilLabServiceDescriptor = $convert.base64Decode(
    'Cg5Tb2lsTGFiU2VydmljZRJmCgtSZWdpc3RlckxhYhIqLmFncmljdWx0dXJlLnNvaWxsYWIudj'
    'EuUmVnaXN0ZXJMYWJSZXF1ZXN0GisuYWdyaWN1bHR1cmUuc29pbGxhYi52MS5SZWdpc3Rlckxh'
    'YlJlc3BvbnNlEl0KCExpc3RMYWJzEicuYWdyaWN1bHR1cmUuc29pbGxhYi52MS5MaXN0TGFic1'
    'JlcXVlc3QaKC5hZ3JpY3VsdHVyZS5zb2lsbGFiLnYxLkxpc3RMYWJzUmVzcG9uc2USaQoMVXBs'
    'b2FkUmVwb3J0EisuYWdyaWN1bHR1cmUuc29pbGxhYi52MS5VcGxvYWRSZXBvcnRSZXF1ZXN0Gi'
    'wuYWdyaWN1bHR1cmUuc29pbGxhYi52MS5VcGxvYWRSZXBvcnRSZXNwb25zZRJgCglHZXRSZXBv'
    'cnQSKC5hZ3JpY3VsdHVyZS5zb2lsbGFiLnYxLkdldFJlcG9ydFJlcXVlc3QaKS5hZ3JpY3VsdH'
    'VyZS5zb2lsbGFiLnYxLkdldFJlcG9ydFJlc3BvbnNlEmYKC0xpc3RSZXBvcnRzEiouYWdyaWN1'
    'bHR1cmUuc29pbGxhYi52MS5MaXN0UmVwb3J0c1JlcXVlc3QaKy5hZ3JpY3VsdHVyZS5zb2lsbG'
    'FiLnYxLkxpc3RSZXBvcnRzUmVzcG9uc2USZgoLQXBwbHlSZXBvcnQSKi5hZ3JpY3VsdHVyZS5z'
    'b2lsbGFiLnYxLkFwcGx5UmVwb3J0UmVxdWVzdBorLmFncmljdWx0dXJlLnNvaWxsYWIudjEuQX'
    'BwbHlSZXBvcnRSZXNwb25zZRJpCgxSZWplY3RSZXBvcnQSKy5hZ3JpY3VsdHVyZS5zb2lsbGFi'
    'LnYxLlJlamVjdFJlcG9ydFJlcXVlc3QaLC5hZ3JpY3VsdHVyZS5zb2lsbGFiLnYxLlJlamVjdF'
    'JlcG9ydFJlc3BvbnNl');
