// This is a generated file - do not edit.
//
// Generated from vegetation_index.proto.

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

@$core.Deprecated('Use vegetationIndexTypeDescriptor instead')
const VegetationIndexType$json = {
  '1': 'VegetationIndexType',
  '2': [
    {'1': 'VEGETATION_INDEX_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'VEGETATION_INDEX_TYPE_NDVI', '2': 1},
    {'1': 'VEGETATION_INDEX_TYPE_NDWI', '2': 2},
    {'1': 'VEGETATION_INDEX_TYPE_EVI', '2': 3},
    {'1': 'VEGETATION_INDEX_TYPE_SAVI', '2': 4},
    {'1': 'VEGETATION_INDEX_TYPE_MSAVI', '2': 5},
    {'1': 'VEGETATION_INDEX_TYPE_NDRE', '2': 6},
    {'1': 'VEGETATION_INDEX_TYPE_GNDVI', '2': 7},
    {'1': 'VEGETATION_INDEX_TYPE_LAI', '2': 8},
  ],
};

/// Descriptor for `VegetationIndexType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List vegetationIndexTypeDescriptor = $convert.base64Decode(
    'ChNWZWdldGF0aW9uSW5kZXhUeXBlEiUKIVZFR0VUQVRJT05fSU5ERVhfVFlQRV9VTlNQRUNJRk'
    'lFRBAAEh4KGlZFR0VUQVRJT05fSU5ERVhfVFlQRV9ORFZJEAESHgoaVkVHRVRBVElPTl9JTkRF'
    'WF9UWVBFX05EV0kQAhIdChlWRUdFVEFUSU9OX0lOREVYX1RZUEVfRVZJEAMSHgoaVkVHRVRBVE'
    'lPTl9JTkRFWF9UWVBFX1NBVkkQBBIfChtWRUdFVEFUSU9OX0lOREVYX1RZUEVfTVNBVkkQBRIe'
    'ChpWRUdFVEFUSU9OX0lOREVYX1RZUEVfTkRSRRAGEh8KG1ZFR0VUQVRJT05fSU5ERVhfVFlQRV'
    '9HTkRWSRAHEh0KGVZFR0VUQVRJT05fSU5ERVhfVFlQRV9MQUkQCA==');

@$core.Deprecated('Use computeStatusDescriptor instead')
const ComputeStatus$json = {
  '1': 'ComputeStatus',
  '2': [
    {'1': 'COMPUTE_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'COMPUTE_STATUS_QUEUED', '2': 1},
    {'1': 'COMPUTE_STATUS_COMPUTING', '2': 2},
    {'1': 'COMPUTE_STATUS_INTERSECTING', '2': 3},
    {'1': 'COMPUTE_STATUS_COMPLETED', '2': 4},
    {'1': 'COMPUTE_STATUS_FAILED', '2': 5},
  ],
};

/// Descriptor for `ComputeStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List computeStatusDescriptor = $convert.base64Decode(
    'Cg1Db21wdXRlU3RhdHVzEh4KGkNPTVBVVEVfU1RBVFVTX1VOU1BFQ0lGSUVEEAASGQoVQ09NUF'
    'VURV9TVEFUVVNfUVVFVUVEEAESHAoYQ09NUFVURV9TVEFUVVNfQ09NUFVUSU5HEAISHwobQ09N'
    'UFVURV9TVEFUVVNfSU5URVJTRUNUSU5HEAMSHAoYQ09NUFVURV9TVEFUVVNfQ09NUExFVEVEEA'
    'QSGQoVQ09NUFVURV9TVEFUVVNfRkFJTEVEEAU=');

@$core.Deprecated('Use vegetationIndexDescriptor instead')
const VegetationIndex$json = {
  '1': 'VegetationIndex',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'processing_job_id', '3': 5, '4': 1, '5': 9, '10': 'processingJobId'},
    {
      '1': 'index_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.vegetation.v1.VegetationIndexType',
      '10': 'indexType'
    },
    {'1': 'mean_value', '3': 7, '4': 1, '5': 1, '10': 'meanValue'},
    {'1': 'min_value', '3': 8, '4': 1, '5': 1, '10': 'minValue'},
    {'1': 'max_value', '3': 9, '4': 1, '5': 1, '10': 'maxValue'},
    {'1': 'std_deviation', '3': 10, '4': 1, '5': 1, '10': 'stdDeviation'},
    {'1': 'median_value', '3': 11, '4': 1, '5': 1, '10': 'medianValue'},
    {'1': 'pixel_count', '3': 12, '4': 1, '5': 3, '10': 'pixelCount'},
    {'1': 'coverage_percent', '3': 13, '4': 1, '5': 1, '10': 'coveragePercent'},
    {'1': 'raster_s3_key', '3': 14, '4': 1, '5': 9, '10': 'rasterS3Key'},
    {
      '1': 'acquisition_date',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'acquisitionDate'
    },
    {
      '1': 'computed_at',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'computedAt'
    },
    {
      '1': 'created_at',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `VegetationIndex`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List vegetationIndexDescriptor = $convert.base64Decode(
    'Cg9WZWdldGF0aW9uSW5kZXgSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdG'
    'VuYW50SWQSFwoHZmFybV9pZBgDIAEoCVIGZmFybUlkEhkKCGZpZWxkX2lkGAQgASgJUgdmaWVs'
    'ZElkEioKEXByb2Nlc3Npbmdfam9iX2lkGAUgASgJUg9wcm9jZXNzaW5nSm9iSWQSVwoKaW5kZX'
    'hfdHlwZRgGIAEoDjI4LmFncmljdWx0dXJlLnNhdGVsbGl0ZS52ZWdldGF0aW9uLnYxLlZlZ2V0'
    'YXRpb25JbmRleFR5cGVSCWluZGV4VHlwZRIdCgptZWFuX3ZhbHVlGAcgASgBUgltZWFuVmFsdW'
    'USGwoJbWluX3ZhbHVlGAggASgBUghtaW5WYWx1ZRIbCgltYXhfdmFsdWUYCSABKAFSCG1heFZh'
    'bHVlEiMKDXN0ZF9kZXZpYXRpb24YCiABKAFSDHN0ZERldmlhdGlvbhIhCgxtZWRpYW5fdmFsdW'
    'UYCyABKAFSC21lZGlhblZhbHVlEh8KC3BpeGVsX2NvdW50GAwgASgDUgpwaXhlbENvdW50EikK'
    'EGNvdmVyYWdlX3BlcmNlbnQYDSABKAFSD2NvdmVyYWdlUGVyY2VudBIiCg1yYXN0ZXJfczNfa2'
    'V5GA4gASgJUgtyYXN0ZXJTM0tleRJFChBhY3F1aXNpdGlvbl9kYXRlGA8gASgLMhouZ29vZ2xl'
    'LnByb3RvYnVmLlRpbWVzdGFtcFIPYWNxdWlzaXRpb25EYXRlEjsKC2NvbXB1dGVkX2F0GBAgAS'
    'gLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIKY29tcHV0ZWRBdBI5CgpjcmVhdGVkX2F0'
    'GBEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use computeTaskDescriptor instead')
const ComputeTask$json = {
  '1': 'ComputeTask',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'processing_job_id', '3': 3, '4': 1, '5': 9, '10': 'processingJobId'},
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'index_types',
      '3': 5,
      '4': 3,
      '5': 14,
      '6': '.agriculture.satellite.vegetation.v1.VegetationIndexType',
      '10': 'indexTypes'
    },
    {
      '1': 'status',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.vegetation.v1.ComputeStatus',
      '10': 'status'
    },
    {'1': 'error_message', '3': 7, '4': 1, '5': 9, '10': 'errorMessage'},
    {
      '1': 'compute_time_seconds',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'computeTimeSeconds'
    },
    {
      '1': 'created_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'completed_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'completedAt'
    },
  ],
};

/// Descriptor for `ComputeTask`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List computeTaskDescriptor = $convert.base64Decode(
    'CgtDb21wdXRlVGFzaxIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW5hbn'
    'RJZBIqChFwcm9jZXNzaW5nX2pvYl9pZBgDIAEoCVIPcHJvY2Vzc2luZ0pvYklkEhcKB2Zhcm1f'
    'aWQYBCABKAlSBmZhcm1JZBJZCgtpbmRleF90eXBlcxgFIAMoDjI4LmFncmljdWx0dXJlLnNhdG'
    'VsbGl0ZS52ZWdldGF0aW9uLnYxLlZlZ2V0YXRpb25JbmRleFR5cGVSCmluZGV4VHlwZXMSSgoG'
    'c3RhdHVzGAYgASgOMjIuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnZlZ2V0YXRpb24udjEuQ29tcH'
    'V0ZVN0YXR1c1IGc3RhdHVzEiMKDWVycm9yX21lc3NhZ2UYByABKAlSDGVycm9yTWVzc2FnZRIw'
    'ChRjb21wdXRlX3RpbWVfc2Vjb25kcxgIIAEoAVISY29tcHV0ZVRpbWVTZWNvbmRzEjkKCmNyZW'
    'F0ZWRfYXQYCSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSPQoM'
    'Y29tcGxldGVkX2F0GAogASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFILY29tcGxldG'
    'VkQXQ=');

@$core.Deprecated('Use nDVITimeSeriesDescriptor instead')
const NDVITimeSeries$json = {
  '1': 'NDVITimeSeries',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'points',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.agriculture.satellite.vegetation.v1.TimeSeriesPoint',
      '10': 'points'
    },
  ],
};

/// Descriptor for `NDVITimeSeries`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nDVITimeSeriesDescriptor = $convert.base64Decode(
    'Cg5ORFZJVGltZVNlcmllcxIXCgdmYXJtX2lkGAEgASgJUgZmYXJtSWQSGQoIZmllbGRfaWQYAi'
    'ABKAlSB2ZpZWxkSWQSTAoGcG9pbnRzGAMgAygLMjQuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnZl'
    'Z2V0YXRpb24udjEuVGltZVNlcmllc1BvaW50UgZwb2ludHM=');

@$core.Deprecated('Use timeSeriesPointDescriptor instead')
const TimeSeriesPoint$json = {
  '1': 'TimeSeriesPoint',
  '2': [
    {
      '1': 'date',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'date'
    },
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
    {'1': 'std_deviation', '3': 3, '4': 1, '5': 1, '10': 'stdDeviation'},
  ],
};

/// Descriptor for `TimeSeriesPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeSeriesPointDescriptor = $convert.base64Decode(
    'Cg9UaW1lU2VyaWVzUG9pbnQSLgoEZGF0ZRgBIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3'
    'RhbXBSBGRhdGUSFAoFdmFsdWUYAiABKAFSBXZhbHVlEiMKDXN0ZF9kZXZpYXRpb24YAyABKAFS'
    'DHN0ZERldmlhdGlvbg==');

@$core.Deprecated('Use computeIndicesRequestDescriptor instead')
const ComputeIndicesRequest$json = {
  '1': 'ComputeIndicesRequest',
  '2': [
    {'1': 'processing_job_id', '3': 1, '4': 1, '5': 9, '10': 'processingJobId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'index_types',
      '3': 3,
      '4': 3,
      '5': 14,
      '6': '.agriculture.satellite.vegetation.v1.VegetationIndexType',
      '10': 'indexTypes'
    },
  ],
};

/// Descriptor for `ComputeIndicesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List computeIndicesRequestDescriptor = $convert.base64Decode(
    'ChVDb21wdXRlSW5kaWNlc1JlcXVlc3QSKgoRcHJvY2Vzc2luZ19qb2JfaWQYASABKAlSD3Byb2'
    'Nlc3NpbmdKb2JJZBIXCgdmYXJtX2lkGAIgASgJUgZmYXJtSWQSWQoLaW5kZXhfdHlwZXMYAyAD'
    'KA4yOC5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUudmVnZXRhdGlvbi52MS5WZWdldGF0aW9uSW5kZX'
    'hUeXBlUgppbmRleFR5cGVz');

@$core.Deprecated('Use computeIndicesResponseDescriptor instead')
const ComputeIndicesResponse$json = {
  '1': 'ComputeIndicesResponse',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.vegetation.v1.ComputeTask',
      '10': 'task'
    },
  ],
};

/// Descriptor for `ComputeIndicesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List computeIndicesResponseDescriptor =
    $convert.base64Decode(
        'ChZDb21wdXRlSW5kaWNlc1Jlc3BvbnNlEkQKBHRhc2sYASABKAsyMC5hZ3JpY3VsdHVyZS5zYX'
        'RlbGxpdGUudmVnZXRhdGlvbi52MS5Db21wdXRlVGFza1IEdGFzaw==');

@$core.Deprecated('Use getVegetationIndexRequestDescriptor instead')
const GetVegetationIndexRequest$json = {
  '1': 'GetVegetationIndexRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetVegetationIndexRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getVegetationIndexRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRWZWdldGF0aW9uSW5kZXhSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use getVegetationIndexResponseDescriptor instead')
const GetVegetationIndexResponse$json = {
  '1': 'GetVegetationIndexResponse',
  '2': [
    {
      '1': 'index',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.vegetation.v1.VegetationIndex',
      '10': 'index'
    },
  ],
};

/// Descriptor for `GetVegetationIndexResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getVegetationIndexResponseDescriptor =
    $convert.base64Decode(
        'ChpHZXRWZWdldGF0aW9uSW5kZXhSZXNwb25zZRJKCgVpbmRleBgBIAEoCzI0LmFncmljdWx0dX'
        'JlLnNhdGVsbGl0ZS52ZWdldGF0aW9uLnYxLlZlZ2V0YXRpb25JbmRleFIFaW5kZXg=');

@$core.Deprecated('Use listVegetationIndicesRequestDescriptor instead')
const ListVegetationIndicesRequest$json = {
  '1': 'ListVegetationIndicesRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'index_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.vegetation.v1.VegetationIndexType',
      '10': 'indexType'
    },
    {
      '1': 'date_from',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'dateFrom'
    },
    {
      '1': 'date_to',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'dateTo'
    },
  ],
};

/// Descriptor for `ListVegetationIndicesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listVegetationIndicesRequestDescriptor = $convert.base64Decode(
    'ChxMaXN0VmVnZXRhdGlvbkluZGljZXNSZXF1ZXN0EhsKCXBhZ2Vfc2l6ZRgBIAEoBVIIcGFnZV'
    'NpemUSHQoKcGFnZV90b2tlbhgCIAEoCVIJcGFnZVRva2VuEhcKB2Zhcm1faWQYAyABKAlSBmZh'
    'cm1JZBIZCghmaWVsZF9pZBgEIAEoCVIHZmllbGRJZBJXCgppbmRleF90eXBlGAUgASgOMjguYW'
    'dyaWN1bHR1cmUuc2F0ZWxsaXRlLnZlZ2V0YXRpb24udjEuVmVnZXRhdGlvbkluZGV4VHlwZVIJ'
    'aW5kZXhUeXBlEjcKCWRhdGVfZnJvbRgGIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbX'
    'BSCGRhdGVGcm9tEjMKB2RhdGVfdG8YByABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1w'
    'UgZkYXRlVG8=');

@$core.Deprecated('Use listVegetationIndicesResponseDescriptor instead')
const ListVegetationIndicesResponse$json = {
  '1': 'ListVegetationIndicesResponse',
  '2': [
    {
      '1': 'indices',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.satellite.vegetation.v1.VegetationIndex',
      '10': 'indices'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListVegetationIndicesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listVegetationIndicesResponseDescriptor = $convert.base64Decode(
    'Ch1MaXN0VmVnZXRhdGlvbkluZGljZXNSZXNwb25zZRJOCgdpbmRpY2VzGAEgAygLMjQuYWdyaW'
    'N1bHR1cmUuc2F0ZWxsaXRlLnZlZ2V0YXRpb24udjEuVmVnZXRhdGlvbkluZGV4UgdpbmRpY2Vz'
    'EiYKD25leHRfcGFnZV90b2tlbhgCIAEoCVINbmV4dFBhZ2VUb2tlbhIfCgt0b3RhbF9jb3VudB'
    'gDIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use getNDVITimeSeriesRequestDescriptor instead')
const GetNDVITimeSeriesRequest$json = {
  '1': 'GetNDVITimeSeriesRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
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
  ],
};

/// Descriptor for `GetNDVITimeSeriesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNDVITimeSeriesRequestDescriptor = $convert.base64Decode(
    'ChhHZXRORFZJVGltZVNlcmllc1JlcXVlc3QSFwoHZmFybV9pZBgBIAEoCVIGZmFybUlkEhkKCG'
    'ZpZWxkX2lkGAIgASgJUgdmaWVsZElkEjcKCWRhdGVfZnJvbRgDIAEoCzIaLmdvb2dsZS5wcm90'
    'b2J1Zi5UaW1lc3RhbXBSCGRhdGVGcm9tEjMKB2RhdGVfdG8YBCABKAsyGi5nb29nbGUucHJvdG'
    '9idWYuVGltZXN0YW1wUgZkYXRlVG8=');

@$core.Deprecated('Use getNDVITimeSeriesResponseDescriptor instead')
const GetNDVITimeSeriesResponse$json = {
  '1': 'GetNDVITimeSeriesResponse',
  '2': [
    {
      '1': 'time_series',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.vegetation.v1.NDVITimeSeries',
      '10': 'timeSeries'
    },
  ],
};

/// Descriptor for `GetNDVITimeSeriesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getNDVITimeSeriesResponseDescriptor = $convert.base64Decode(
    'ChlHZXRORFZJVGltZVNlcmllc1Jlc3BvbnNlElQKC3RpbWVfc2VyaWVzGAEgASgLMjMuYWdyaW'
    'N1bHR1cmUuc2F0ZWxsaXRlLnZlZ2V0YXRpb24udjEuTkRWSVRpbWVTZXJpZXNSCnRpbWVTZXJp'
    'ZXM=');

@$core.Deprecated('Use getFieldHealthRequestDescriptor instead')
const GetFieldHealthRequest$json = {
  '1': 'GetFieldHealthRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
  ],
};

/// Descriptor for `GetFieldHealthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFieldHealthRequestDescriptor = $convert.base64Decode(
    'ChVHZXRGaWVsZEhlYWx0aFJlcXVlc3QSFwoHZmFybV9pZBgBIAEoCVIGZmFybUlkEhkKCGZpZW'
    'xkX2lkGAIgASgJUgdmaWVsZElk');

@$core.Deprecated('Use getFieldHealthResponseDescriptor instead')
const GetFieldHealthResponse$json = {
  '1': 'GetFieldHealthResponse',
  '2': [
    {'1': 'current_ndvi', '3': 1, '4': 1, '5': 1, '10': 'currentNdvi'},
    {'1': 'ndvi_trend', '3': 2, '4': 1, '5': 1, '10': 'ndviTrend'},
    {'1': 'health_score', '3': 3, '4': 1, '5': 1, '10': 'healthScore'},
    {'1': 'health_category', '3': 4, '4': 1, '5': 9, '10': 'healthCategory'},
    {
      '1': 'last_computed',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastComputed'
    },
  ],
};

/// Descriptor for `GetFieldHealthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFieldHealthResponseDescriptor = $convert.base64Decode(
    'ChZHZXRGaWVsZEhlYWx0aFJlc3BvbnNlEiEKDGN1cnJlbnRfbmR2aRgBIAEoAVILY3VycmVudE'
    '5kdmkSHQoKbmR2aV90cmVuZBgCIAEoAVIJbmR2aVRyZW5kEiEKDGhlYWx0aF9zY29yZRgDIAEo'
    'AVILaGVhbHRoU2NvcmUSJwoPaGVhbHRoX2NhdGVnb3J5GAQgASgJUg5oZWFsdGhDYXRlZ29yeR'
    'I/Cg1sYXN0X2NvbXB1dGVkGAUgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIMbGFz'
    'dENvbXB1dGVk');

const $core.Map<$core.String, $core.dynamic> VegetationIndexServiceBase$json = {
  '1': 'VegetationIndexService',
  '2': [
    {
      '1': 'ComputeIndices',
      '2': '.agriculture.satellite.vegetation.v1.ComputeIndicesRequest',
      '3': '.agriculture.satellite.vegetation.v1.ComputeIndicesResponse'
    },
    {
      '1': 'GetVegetationIndex',
      '2': '.agriculture.satellite.vegetation.v1.GetVegetationIndexRequest',
      '3': '.agriculture.satellite.vegetation.v1.GetVegetationIndexResponse'
    },
    {
      '1': 'ListVegetationIndices',
      '2': '.agriculture.satellite.vegetation.v1.ListVegetationIndicesRequest',
      '3': '.agriculture.satellite.vegetation.v1.ListVegetationIndicesResponse'
    },
    {
      '1': 'GetNDVITimeSeries',
      '2': '.agriculture.satellite.vegetation.v1.GetNDVITimeSeriesRequest',
      '3': '.agriculture.satellite.vegetation.v1.GetNDVITimeSeriesResponse'
    },
    {
      '1': 'GetFieldHealth',
      '2': '.agriculture.satellite.vegetation.v1.GetFieldHealthRequest',
      '3': '.agriculture.satellite.vegetation.v1.GetFieldHealthResponse'
    },
  ],
};

@$core.Deprecated('Use vegetationIndexServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    VegetationIndexServiceBase$messageJson = {
  '.agriculture.satellite.vegetation.v1.ComputeIndicesRequest':
      ComputeIndicesRequest$json,
  '.agriculture.satellite.vegetation.v1.ComputeIndicesResponse':
      ComputeIndicesResponse$json,
  '.agriculture.satellite.vegetation.v1.ComputeTask': ComputeTask$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.satellite.vegetation.v1.GetVegetationIndexRequest':
      GetVegetationIndexRequest$json,
  '.agriculture.satellite.vegetation.v1.GetVegetationIndexResponse':
      GetVegetationIndexResponse$json,
  '.agriculture.satellite.vegetation.v1.VegetationIndex': VegetationIndex$json,
  '.agriculture.satellite.vegetation.v1.ListVegetationIndicesRequest':
      ListVegetationIndicesRequest$json,
  '.agriculture.satellite.vegetation.v1.ListVegetationIndicesResponse':
      ListVegetationIndicesResponse$json,
  '.agriculture.satellite.vegetation.v1.GetNDVITimeSeriesRequest':
      GetNDVITimeSeriesRequest$json,
  '.agriculture.satellite.vegetation.v1.GetNDVITimeSeriesResponse':
      GetNDVITimeSeriesResponse$json,
  '.agriculture.satellite.vegetation.v1.NDVITimeSeries': NDVITimeSeries$json,
  '.agriculture.satellite.vegetation.v1.TimeSeriesPoint': TimeSeriesPoint$json,
  '.agriculture.satellite.vegetation.v1.GetFieldHealthRequest':
      GetFieldHealthRequest$json,
  '.agriculture.satellite.vegetation.v1.GetFieldHealthResponse':
      GetFieldHealthResponse$json,
};

/// Descriptor for `VegetationIndexService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List vegetationIndexServiceDescriptor = $convert.base64Decode(
    'ChZWZWdldGF0aW9uSW5kZXhTZXJ2aWNlEokBCg5Db21wdXRlSW5kaWNlcxI6LmFncmljdWx0dX'
    'JlLnNhdGVsbGl0ZS52ZWdldGF0aW9uLnYxLkNvbXB1dGVJbmRpY2VzUmVxdWVzdBo7LmFncmlj'
    'dWx0dXJlLnNhdGVsbGl0ZS52ZWdldGF0aW9uLnYxLkNvbXB1dGVJbmRpY2VzUmVzcG9uc2USlQ'
    'EKEkdldFZlZ2V0YXRpb25JbmRleBI+LmFncmljdWx0dXJlLnNhdGVsbGl0ZS52ZWdldGF0aW9u'
    'LnYxLkdldFZlZ2V0YXRpb25JbmRleFJlcXVlc3QaPy5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUudm'
    'VnZXRhdGlvbi52MS5HZXRWZWdldGF0aW9uSW5kZXhSZXNwb25zZRKeAQoVTGlzdFZlZ2V0YXRp'
    'b25JbmRpY2VzEkEuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnZlZ2V0YXRpb24udjEuTGlzdFZlZ2'
    'V0YXRpb25JbmRpY2VzUmVxdWVzdBpCLmFncmljdWx0dXJlLnNhdGVsbGl0ZS52ZWdldGF0aW9u'
    'LnYxLkxpc3RWZWdldGF0aW9uSW5kaWNlc1Jlc3BvbnNlEpIBChFHZXRORFZJVGltZVNlcmllcx'
    'I9LmFncmljdWx0dXJlLnNhdGVsbGl0ZS52ZWdldGF0aW9uLnYxLkdldE5EVklUaW1lU2VyaWVz'
    'UmVxdWVzdBo+LmFncmljdWx0dXJlLnNhdGVsbGl0ZS52ZWdldGF0aW9uLnYxLkdldE5EVklUaW'
    '1lU2VyaWVzUmVzcG9uc2USiQEKDkdldEZpZWxkSGVhbHRoEjouYWdyaWN1bHR1cmUuc2F0ZWxs'
    'aXRlLnZlZ2V0YXRpb24udjEuR2V0RmllbGRIZWFsdGhSZXF1ZXN0GjsuYWdyaWN1bHR1cmUuc2'
    'F0ZWxsaXRlLnZlZ2V0YXRpb24udjEuR2V0RmllbGRIZWFsdGhSZXNwb25zZQ==');
