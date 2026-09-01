// This is a generated file - do not edit.
//
// Generated from ingestion.proto.

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

@$core.Deprecated('Use satelliteProviderDescriptor instead')
const SatelliteProvider$json = {
  '1': 'SatelliteProvider',
  '2': [
    {'1': 'SATELLITE_PROVIDER_UNSPECIFIED', '2': 0},
    {'1': 'SATELLITE_PROVIDER_SENTINEL2', '2': 1},
    {'1': 'SATELLITE_PROVIDER_LANDSAT', '2': 2},
    {'1': 'SATELLITE_PROVIDER_PLANETSCOPE', '2': 3},
  ],
};

/// Descriptor for `SatelliteProvider`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List satelliteProviderDescriptor = $convert.base64Decode(
    'ChFTYXRlbGxpdGVQcm92aWRlchIiCh5TQVRFTExJVEVfUFJPVklERVJfVU5TUEVDSUZJRUQQAB'
    'IgChxTQVRFTExJVEVfUFJPVklERVJfU0VOVElORUwyEAESHgoaU0FURUxMSVRFX1BST1ZJREVS'
    'X0xBTkRTQVQQAhIiCh5TQVRFTExJVEVfUFJPVklERVJfUExBTkVUU0NPUEUQAw==');

@$core.Deprecated('Use ingestionStatusDescriptor instead')
const IngestionStatus$json = {
  '1': 'IngestionStatus',
  '2': [
    {'1': 'INGESTION_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'INGESTION_STATUS_QUEUED', '2': 1},
    {'1': 'INGESTION_STATUS_DOWNLOADING', '2': 2},
    {'1': 'INGESTION_STATUS_VALIDATING', '2': 3},
    {'1': 'INGESTION_STATUS_STORED', '2': 4},
    {'1': 'INGESTION_STATUS_FAILED', '2': 5},
  ],
};

/// Descriptor for `IngestionStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List ingestionStatusDescriptor = $convert.base64Decode(
    'Cg9Jbmdlc3Rpb25TdGF0dXMSIAocSU5HRVNUSU9OX1NUQVRVU19VTlNQRUNJRklFRBAAEhsKF0'
    'lOR0VTVElPTl9TVEFUVVNfUVVFVUVEEAESIAocSU5HRVNUSU9OX1NUQVRVU19ET1dOTE9BRElO'
    'RxACEh8KG0lOR0VTVElPTl9TVEFUVVNfVkFMSURBVElORxADEhsKF0lOR0VTVElPTl9TVEFUVV'
    'NfU1RPUkVEEAQSGwoXSU5HRVNUSU9OX1NUQVRVU19GQUlMRUQQBQ==');

@$core.Deprecated('Use spectralBandDescriptor instead')
const SpectralBand$json = {
  '1': 'SpectralBand',
  '2': [
    {'1': 'SPECTRAL_BAND_UNSPECIFIED', '2': 0},
    {'1': 'SPECTRAL_BAND_BLUE', '2': 1},
    {'1': 'SPECTRAL_BAND_GREEN', '2': 2},
    {'1': 'SPECTRAL_BAND_RED', '2': 3},
    {'1': 'SPECTRAL_BAND_NIR', '2': 4},
    {'1': 'SPECTRAL_BAND_SWIR1', '2': 5},
    {'1': 'SPECTRAL_BAND_SWIR2', '2': 6},
    {'1': 'SPECTRAL_BAND_RED_EDGE1', '2': 7},
    {'1': 'SPECTRAL_BAND_RED_EDGE2', '2': 8},
    {'1': 'SPECTRAL_BAND_RED_EDGE3', '2': 9},
  ],
};

/// Descriptor for `SpectralBand`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List spectralBandDescriptor = $convert.base64Decode(
    'CgxTcGVjdHJhbEJhbmQSHQoZU1BFQ1RSQUxfQkFORF9VTlNQRUNJRklFRBAAEhYKElNQRUNUUk'
    'FMX0JBTkRfQkxVRRABEhcKE1NQRUNUUkFMX0JBTkRfR1JFRU4QAhIVChFTUEVDVFJBTF9CQU5E'
    'X1JFRBADEhUKEVNQRUNUUkFMX0JBTkRfTklSEAQSFwoTU1BFQ1RSQUxfQkFORF9TV0lSMRAFEh'
    'cKE1NQRUNUUkFMX0JBTkRfU1dJUjIQBhIbChdTUEVDVFJBTF9CQU5EX1JFRF9FREdFMRAHEhsK'
    'F1NQRUNUUkFMX0JBTkRfUkVEX0VER0UyEAgSGwoXU1BFQ1RSQUxfQkFORF9SRURfRURHRTMQCQ'
    '==');

@$core.Deprecated('Use ingestionTaskDescriptor instead')
const IngestionTask$json = {
  '1': 'IngestionTask',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'provider',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.ingestion.v1.SatelliteProvider',
      '10': 'provider'
    },
    {'1': 'scene_id', '3': 5, '4': 1, '5': 9, '10': 'sceneId'},
    {
      '1': 'status',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.ingestion.v1.IngestionStatus',
      '10': 'status'
    },
    {'1': 's3_bucket', '3': 7, '4': 1, '5': 9, '10': 's3Bucket'},
    {'1': 's3_key', '3': 8, '4': 1, '5': 9, '10': 's3Key'},
    {
      '1': 'cloud_cover_percent',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'cloudCoverPercent'
    },
    {
      '1': 'resolution_meters',
      '3': 10,
      '4': 1,
      '5': 1,
      '10': 'resolutionMeters'
    },
    {
      '1': 'bands',
      '3': 11,
      '4': 3,
      '5': 14,
      '6': '.agriculture.satellite.ingestion.v1.SpectralBand',
      '10': 'bands'
    },
    {'1': 'bbox_geojson', '3': 12, '4': 1, '5': 9, '10': 'bboxGeojson'},
    {'1': 'file_size_bytes', '3': 13, '4': 1, '5': 3, '10': 'fileSizeBytes'},
    {'1': 'checksum_sha256', '3': 14, '4': 1, '5': 9, '10': 'checksumSha256'},
    {'1': 'error_message', '3': 15, '4': 1, '5': 9, '10': 'errorMessage'},
    {'1': 'retry_count', '3': 16, '4': 1, '5': 5, '10': 'retryCount'},
    {
      '1': 'acquisition_date',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'acquisitionDate'
    },
    {
      '1': 'created_at',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 19,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {
      '1': 'completed_at',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'completedAt'
    },
  ],
};

/// Descriptor for `IngestionTask`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ingestionTaskDescriptor = $convert.base64Decode(
    'Cg1Jbmdlc3Rpb25UYXNrEg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbm'
    'FudElkEhcKB2Zhcm1faWQYAyABKAlSBmZhcm1JZBJRCghwcm92aWRlchgEIAEoDjI1LmFncmlj'
    'dWx0dXJlLnNhdGVsbGl0ZS5pbmdlc3Rpb24udjEuU2F0ZWxsaXRlUHJvdmlkZXJSCHByb3ZpZG'
    'VyEhkKCHNjZW5lX2lkGAUgASgJUgdzY2VuZUlkEksKBnN0YXR1cxgGIAEoDjIzLmFncmljdWx0'
    'dXJlLnNhdGVsbGl0ZS5pbmdlc3Rpb24udjEuSW5nZXN0aW9uU3RhdHVzUgZzdGF0dXMSGwoJcz'
    'NfYnVja2V0GAcgASgJUghzM0J1Y2tldBIVCgZzM19rZXkYCCABKAlSBXMzS2V5Ei4KE2Nsb3Vk'
    'X2NvdmVyX3BlcmNlbnQYCSABKAFSEWNsb3VkQ292ZXJQZXJjZW50EisKEXJlc29sdXRpb25fbW'
    'V0ZXJzGAogASgBUhByZXNvbHV0aW9uTWV0ZXJzEkYKBWJhbmRzGAsgAygOMjAuYWdyaWN1bHR1'
    'cmUuc2F0ZWxsaXRlLmluZ2VzdGlvbi52MS5TcGVjdHJhbEJhbmRSBWJhbmRzEiEKDGJib3hfZ2'
    'VvanNvbhgMIAEoCVILYmJveEdlb2pzb24SJgoPZmlsZV9zaXplX2J5dGVzGA0gASgDUg1maWxl'
    'U2l6ZUJ5dGVzEicKD2NoZWNrc3VtX3NoYTI1NhgOIAEoCVIOY2hlY2tzdW1TaGEyNTYSIwoNZX'
    'Jyb3JfbWVzc2FnZRgPIAEoCVIMZXJyb3JNZXNzYWdlEh8KC3JldHJ5X2NvdW50GBAgASgFUgpy'
    'ZXRyeUNvdW50EkUKEGFjcXVpc2l0aW9uX2RhdGUYESABKAsyGi5nb29nbGUucHJvdG9idWYuVG'
    'ltZXN0YW1wUg9hY3F1aXNpdGlvbkRhdGUSOQoKY3JlYXRlZF9hdBgSIAEoCzIaLmdvb2dsZS5w'
    'cm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GBMgASgLMhouZ29vZ2'
    'xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZEF0Ej0KDGNvbXBsZXRlZF9hdBgUIAEoCzIa'
    'Lmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSC2NvbXBsZXRlZEF0');

@$core.Deprecated('Use requestIngestionRequestDescriptor instead')
const RequestIngestionRequest$json = {
  '1': 'RequestIngestionRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'provider',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.ingestion.v1.SatelliteProvider',
      '10': 'provider'
    },
    {
      '1': 'date_from',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'dateFrom'
    },
    {
      '1': 'date_to',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'dateTo'
    },
    {'1': 'max_cloud_cover', '3': 5, '4': 1, '5': 1, '10': 'maxCloudCover'},
    {
      '1': 'bands',
      '3': 6,
      '4': 3,
      '5': 14,
      '6': '.agriculture.satellite.ingestion.v1.SpectralBand',
      '10': 'bands'
    },
  ],
};

/// Descriptor for `RequestIngestionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestIngestionRequestDescriptor = $convert.base64Decode(
    'ChdSZXF1ZXN0SW5nZXN0aW9uUmVxdWVzdBIXCgdmYXJtX2lkGAEgASgJUgZmYXJtSWQSUQoIcH'
    'JvdmlkZXIYAiABKA4yNS5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUuaW5nZXN0aW9uLnYxLlNhdGVs'
    'bGl0ZVByb3ZpZGVyUghwcm92aWRlchI3CglkYXRlX2Zyb20YAyABKAsyGi5nb29nbGUucHJvdG'
    '9idWYuVGltZXN0YW1wUghkYXRlRnJvbRIzCgdkYXRlX3RvGAQgASgLMhouZ29vZ2xlLnByb3Rv'
    'YnVmLlRpbWVzdGFtcFIGZGF0ZVRvEiYKD21heF9jbG91ZF9jb3ZlchgFIAEoAVINbWF4Q2xvdW'
    'RDb3ZlchJGCgViYW5kcxgGIAMoDjIwLmFncmljdWx0dXJlLnNhdGVsbGl0ZS5pbmdlc3Rpb24u'
    'djEuU3BlY3RyYWxCYW5kUgViYW5kcw==');

@$core.Deprecated('Use requestIngestionResponseDescriptor instead')
const RequestIngestionResponse$json = {
  '1': 'RequestIngestionResponse',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.ingestion.v1.IngestionTask',
      '10': 'task'
    },
  ],
};

/// Descriptor for `RequestIngestionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestIngestionResponseDescriptor =
    $convert.base64Decode(
        'ChhSZXF1ZXN0SW5nZXN0aW9uUmVzcG9uc2USRQoEdGFzaxgBIAEoCzIxLmFncmljdWx0dXJlLn'
        'NhdGVsbGl0ZS5pbmdlc3Rpb24udjEuSW5nZXN0aW9uVGFza1IEdGFzaw==');

@$core.Deprecated('Use getIngestionTaskRequestDescriptor instead')
const GetIngestionTaskRequest$json = {
  '1': 'GetIngestionTaskRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetIngestionTaskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getIngestionTaskRequestDescriptor = $convert
    .base64Decode('ChdHZXRJbmdlc3Rpb25UYXNrUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use getIngestionTaskResponseDescriptor instead')
const GetIngestionTaskResponse$json = {
  '1': 'GetIngestionTaskResponse',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.ingestion.v1.IngestionTask',
      '10': 'task'
    },
  ],
};

/// Descriptor for `GetIngestionTaskResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getIngestionTaskResponseDescriptor =
    $convert.base64Decode(
        'ChhHZXRJbmdlc3Rpb25UYXNrUmVzcG9uc2USRQoEdGFzaxgBIAEoCzIxLmFncmljdWx0dXJlLn'
        'NhdGVsbGl0ZS5pbmdlc3Rpb24udjEuSW5nZXN0aW9uVGFza1IEdGFzaw==');

@$core.Deprecated('Use listIngestionTasksRequestDescriptor instead')
const ListIngestionTasksRequest$json = {
  '1': 'ListIngestionTasksRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'provider',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.ingestion.v1.SatelliteProvider',
      '10': 'provider'
    },
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.ingestion.v1.IngestionStatus',
      '10': 'status'
    },
  ],
};

/// Descriptor for `ListIngestionTasksRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listIngestionTasksRequestDescriptor = $convert.base64Decode(
    'ChlMaXN0SW5nZXN0aW9uVGFza3NSZXF1ZXN0EhsKCXBhZ2Vfc2l6ZRgBIAEoBVIIcGFnZVNpem'
    'USHQoKcGFnZV90b2tlbhgCIAEoCVIJcGFnZVRva2VuEhcKB2Zhcm1faWQYAyABKAlSBmZhcm1J'
    'ZBJRCghwcm92aWRlchgEIAEoDjI1LmFncmljdWx0dXJlLnNhdGVsbGl0ZS5pbmdlc3Rpb24udj'
    'EuU2F0ZWxsaXRlUHJvdmlkZXJSCHByb3ZpZGVyEksKBnN0YXR1cxgFIAEoDjIzLmFncmljdWx0'
    'dXJlLnNhdGVsbGl0ZS5pbmdlc3Rpb24udjEuSW5nZXN0aW9uU3RhdHVzUgZzdGF0dXM=');

@$core.Deprecated('Use listIngestionTasksResponseDescriptor instead')
const ListIngestionTasksResponse$json = {
  '1': 'ListIngestionTasksResponse',
  '2': [
    {
      '1': 'tasks',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.satellite.ingestion.v1.IngestionTask',
      '10': 'tasks'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListIngestionTasksResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listIngestionTasksResponseDescriptor = $convert.base64Decode(
    'ChpMaXN0SW5nZXN0aW9uVGFza3NSZXNwb25zZRJHCgV0YXNrcxgBIAMoCzIxLmFncmljdWx0dX'
    'JlLnNhdGVsbGl0ZS5pbmdlc3Rpb24udjEuSW5nZXN0aW9uVGFza1IFdGFza3MSJgoPbmV4dF9w'
    'YWdlX3Rva2VuGAIgASgJUg1uZXh0UGFnZVRva2VuEh8KC3RvdGFsX2NvdW50GAMgASgFUgp0b3'
    'RhbENvdW50');

@$core.Deprecated('Use cancelIngestionRequestDescriptor instead')
const CancelIngestionRequest$json = {
  '1': 'CancelIngestionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `CancelIngestionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelIngestionRequestDescriptor = $convert
    .base64Decode('ChZDYW5jZWxJbmdlc3Rpb25SZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use cancelIngestionResponseDescriptor instead')
const CancelIngestionResponse$json = {
  '1': 'CancelIngestionResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `CancelIngestionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelIngestionResponseDescriptor =
    $convert.base64Decode(
        'ChdDYW5jZWxJbmdlc3Rpb25SZXNwb25zZRIYCgdzdWNjZXNzGAEgASgIUgdzdWNjZXNz');

@$core.Deprecated('Use retryIngestionRequestDescriptor instead')
const RetryIngestionRequest$json = {
  '1': 'RetryIngestionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `RetryIngestionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List retryIngestionRequestDescriptor = $convert
    .base64Decode('ChVSZXRyeUluZ2VzdGlvblJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use retryIngestionResponseDescriptor instead')
const RetryIngestionResponse$json = {
  '1': 'RetryIngestionResponse',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.ingestion.v1.IngestionTask',
      '10': 'task'
    },
  ],
};

/// Descriptor for `RetryIngestionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List retryIngestionResponseDescriptor =
    $convert.base64Decode(
        'ChZSZXRyeUluZ2VzdGlvblJlc3BvbnNlEkUKBHRhc2sYASABKAsyMS5hZ3JpY3VsdHVyZS5zYX'
        'RlbGxpdGUuaW5nZXN0aW9uLnYxLkluZ2VzdGlvblRhc2tSBHRhc2s=');

@$core.Deprecated('Use getIngestionStatsRequestDescriptor instead')
const GetIngestionStatsRequest$json = {
  '1': 'GetIngestionStatsRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'provider',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.ingestion.v1.SatelliteProvider',
      '10': 'provider'
    },
  ],
};

/// Descriptor for `GetIngestionStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getIngestionStatsRequestDescriptor = $convert.base64Decode(
    'ChhHZXRJbmdlc3Rpb25TdGF0c1JlcXVlc3QSFwoHZmFybV9pZBgBIAEoCVIGZmFybUlkElEKCH'
    'Byb3ZpZGVyGAIgASgOMjUuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLmluZ2VzdGlvbi52MS5TYXRl'
    'bGxpdGVQcm92aWRlclIIcHJvdmlkZXI=');

@$core.Deprecated('Use getIngestionStatsResponseDescriptor instead')
const GetIngestionStatsResponse$json = {
  '1': 'GetIngestionStatsResponse',
  '2': [
    {'1': 'total_tasks', '3': 1, '4': 1, '5': 3, '10': 'totalTasks'},
    {'1': 'completed_tasks', '3': 2, '4': 1, '5': 3, '10': 'completedTasks'},
    {'1': 'failed_tasks', '3': 3, '4': 1, '5': 3, '10': 'failedTasks'},
    {'1': 'pending_tasks', '3': 4, '4': 1, '5': 3, '10': 'pendingTasks'},
    {
      '1': 'total_bytes_stored',
      '3': 5,
      '4': 1,
      '5': 3,
      '10': 'totalBytesStored'
    },
  ],
};

/// Descriptor for `GetIngestionStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getIngestionStatsResponseDescriptor = $convert.base64Decode(
    'ChlHZXRJbmdlc3Rpb25TdGF0c1Jlc3BvbnNlEh8KC3RvdGFsX3Rhc2tzGAEgASgDUgp0b3RhbF'
    'Rhc2tzEicKD2NvbXBsZXRlZF90YXNrcxgCIAEoA1IOY29tcGxldGVkVGFza3MSIQoMZmFpbGVk'
    'X3Rhc2tzGAMgASgDUgtmYWlsZWRUYXNrcxIjCg1wZW5kaW5nX3Rhc2tzGAQgASgDUgxwZW5kaW'
    '5nVGFza3MSLAoSdG90YWxfYnl0ZXNfc3RvcmVkGAUgASgDUhB0b3RhbEJ5dGVzU3RvcmVk');

const $core.Map<$core.String, $core.dynamic>
    SatelliteIngestionServiceBase$json = {
  '1': 'SatelliteIngestionService',
  '2': [
    {
      '1': 'RequestIngestion',
      '2': '.agriculture.satellite.ingestion.v1.RequestIngestionRequest',
      '3': '.agriculture.satellite.ingestion.v1.RequestIngestionResponse'
    },
    {
      '1': 'GetIngestionTask',
      '2': '.agriculture.satellite.ingestion.v1.GetIngestionTaskRequest',
      '3': '.agriculture.satellite.ingestion.v1.GetIngestionTaskResponse'
    },
    {
      '1': 'ListIngestionTasks',
      '2': '.agriculture.satellite.ingestion.v1.ListIngestionTasksRequest',
      '3': '.agriculture.satellite.ingestion.v1.ListIngestionTasksResponse'
    },
    {
      '1': 'CancelIngestion',
      '2': '.agriculture.satellite.ingestion.v1.CancelIngestionRequest',
      '3': '.agriculture.satellite.ingestion.v1.CancelIngestionResponse'
    },
    {
      '1': 'RetryIngestion',
      '2': '.agriculture.satellite.ingestion.v1.RetryIngestionRequest',
      '3': '.agriculture.satellite.ingestion.v1.RetryIngestionResponse'
    },
    {
      '1': 'GetIngestionStats',
      '2': '.agriculture.satellite.ingestion.v1.GetIngestionStatsRequest',
      '3': '.agriculture.satellite.ingestion.v1.GetIngestionStatsResponse'
    },
  ],
};

@$core.Deprecated('Use satelliteIngestionServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    SatelliteIngestionServiceBase$messageJson = {
  '.agriculture.satellite.ingestion.v1.RequestIngestionRequest':
      RequestIngestionRequest$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.satellite.ingestion.v1.RequestIngestionResponse':
      RequestIngestionResponse$json,
  '.agriculture.satellite.ingestion.v1.IngestionTask': IngestionTask$json,
  '.agriculture.satellite.ingestion.v1.GetIngestionTaskRequest':
      GetIngestionTaskRequest$json,
  '.agriculture.satellite.ingestion.v1.GetIngestionTaskResponse':
      GetIngestionTaskResponse$json,
  '.agriculture.satellite.ingestion.v1.ListIngestionTasksRequest':
      ListIngestionTasksRequest$json,
  '.agriculture.satellite.ingestion.v1.ListIngestionTasksResponse':
      ListIngestionTasksResponse$json,
  '.agriculture.satellite.ingestion.v1.CancelIngestionRequest':
      CancelIngestionRequest$json,
  '.agriculture.satellite.ingestion.v1.CancelIngestionResponse':
      CancelIngestionResponse$json,
  '.agriculture.satellite.ingestion.v1.RetryIngestionRequest':
      RetryIngestionRequest$json,
  '.agriculture.satellite.ingestion.v1.RetryIngestionResponse':
      RetryIngestionResponse$json,
  '.agriculture.satellite.ingestion.v1.GetIngestionStatsRequest':
      GetIngestionStatsRequest$json,
  '.agriculture.satellite.ingestion.v1.GetIngestionStatsResponse':
      GetIngestionStatsResponse$json,
};

/// Descriptor for `SatelliteIngestionService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List satelliteIngestionServiceDescriptor = $convert.base64Decode(
    'ChlTYXRlbGxpdGVJbmdlc3Rpb25TZXJ2aWNlEo0BChBSZXF1ZXN0SW5nZXN0aW9uEjsuYWdyaW'
    'N1bHR1cmUuc2F0ZWxsaXRlLmluZ2VzdGlvbi52MS5SZXF1ZXN0SW5nZXN0aW9uUmVxdWVzdBo8'
    'LmFncmljdWx0dXJlLnNhdGVsbGl0ZS5pbmdlc3Rpb24udjEuUmVxdWVzdEluZ2VzdGlvblJlc3'
    'BvbnNlEo0BChBHZXRJbmdlc3Rpb25UYXNrEjsuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLmluZ2Vz'
    'dGlvbi52MS5HZXRJbmdlc3Rpb25UYXNrUmVxdWVzdBo8LmFncmljdWx0dXJlLnNhdGVsbGl0ZS'
    '5pbmdlc3Rpb24udjEuR2V0SW5nZXN0aW9uVGFza1Jlc3BvbnNlEpMBChJMaXN0SW5nZXN0aW9u'
    'VGFza3MSPS5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUuaW5nZXN0aW9uLnYxLkxpc3RJbmdlc3Rpb2'
    '5UYXNrc1JlcXVlc3QaPi5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUuaW5nZXN0aW9uLnYxLkxpc3RJ'
    'bmdlc3Rpb25UYXNrc1Jlc3BvbnNlEooBCg9DYW5jZWxJbmdlc3Rpb24SOi5hZ3JpY3VsdHVyZS'
    '5zYXRlbGxpdGUuaW5nZXN0aW9uLnYxLkNhbmNlbEluZ2VzdGlvblJlcXVlc3QaOy5hZ3JpY3Vs'
    'dHVyZS5zYXRlbGxpdGUuaW5nZXN0aW9uLnYxLkNhbmNlbEluZ2VzdGlvblJlc3BvbnNlEocBCg'
    '5SZXRyeUluZ2VzdGlvbhI5LmFncmljdWx0dXJlLnNhdGVsbGl0ZS5pbmdlc3Rpb24udjEuUmV0'
    'cnlJbmdlc3Rpb25SZXF1ZXN0GjouYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLmluZ2VzdGlvbi52MS'
    '5SZXRyeUluZ2VzdGlvblJlc3BvbnNlEpABChFHZXRJbmdlc3Rpb25TdGF0cxI8LmFncmljdWx0'
    'dXJlLnNhdGVsbGl0ZS5pbmdlc3Rpb24udjEuR2V0SW5nZXN0aW9uU3RhdHNSZXF1ZXN0Gj0uYW'
    'dyaWN1bHR1cmUuc2F0ZWxsaXRlLmluZ2VzdGlvbi52MS5HZXRJbmdlc3Rpb25TdGF0c1Jlc3Bv'
    'bnNl');
