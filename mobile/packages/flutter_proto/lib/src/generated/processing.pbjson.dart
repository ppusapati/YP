// This is a generated file - do not edit.
//
// Generated from processing.proto.

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

@$core.Deprecated('Use processingStatusDescriptor instead')
const ProcessingStatus$json = {
  '1': 'ProcessingStatus',
  '2': [
    {'1': 'PROCESSING_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'PROCESSING_STATUS_QUEUED', '2': 1},
    {'1': 'PROCESSING_STATUS_PREPROCESSING', '2': 2},
    {'1': 'PROCESSING_STATUS_ATMOSPHERIC_CORRECTION', '2': 3},
    {'1': 'PROCESSING_STATUS_CLOUD_MASKING', '2': 4},
    {'1': 'PROCESSING_STATUS_ORTHORECTIFICATION', '2': 5},
    {'1': 'PROCESSING_STATUS_BAND_MATH', '2': 6},
    {'1': 'PROCESSING_STATUS_COMPLETED', '2': 7},
    {'1': 'PROCESSING_STATUS_FAILED', '2': 8},
  ],
};

/// Descriptor for `ProcessingStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List processingStatusDescriptor = $convert.base64Decode(
    'ChBQcm9jZXNzaW5nU3RhdHVzEiEKHVBST0NFU1NJTkdfU1RBVFVTX1VOU1BFQ0lGSUVEEAASHA'
    'oYUFJPQ0VTU0lOR19TVEFUVVNfUVVFVUVEEAESIwofUFJPQ0VTU0lOR19TVEFUVVNfUFJFUFJP'
    'Q0VTU0lORxACEiwKKFBST0NFU1NJTkdfU1RBVFVTX0FUTU9TUEhFUklDX0NPUlJFQ1RJT04QAx'
    'IjCh9QUk9DRVNTSU5HX1NUQVRVU19DTE9VRF9NQVNLSU5HEAQSKAokUFJPQ0VTU0lOR19TVEFU'
    'VVNfT1JUSE9SRUNUSUZJQ0FUSU9OEAUSHwobUFJPQ0VTU0lOR19TVEFUVVNfQkFORF9NQVRIEA'
    'YSHwobUFJPQ0VTU0lOR19TVEFUVVNfQ09NUExFVEVEEAcSHAoYUFJPQ0VTU0lOR19TVEFUVVNf'
    'RkFJTEVEEAg=');

@$core.Deprecated('Use processingLevelDescriptor instead')
const ProcessingLevel$json = {
  '1': 'ProcessingLevel',
  '2': [
    {'1': 'PROCESSING_LEVEL_UNSPECIFIED', '2': 0},
    {'1': 'PROCESSING_LEVEL_L1C', '2': 1},
    {'1': 'PROCESSING_LEVEL_L2A', '2': 2},
    {'1': 'PROCESSING_LEVEL_L3', '2': 3},
  ],
};

/// Descriptor for `ProcessingLevel`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List processingLevelDescriptor = $convert.base64Decode(
    'Cg9Qcm9jZXNzaW5nTGV2ZWwSIAocUFJPQ0VTU0lOR19MRVZFTF9VTlNQRUNJRklFRBAAEhgKFF'
    'BST0NFU1NJTkdfTEVWRUxfTDFDEAESGAoUUFJPQ0VTU0lOR19MRVZFTF9MMkEQAhIXChNQUk9D'
    'RVNTSU5HX0xFVkVMX0wzEAM=');

@$core.Deprecated('Use correctionAlgorithmDescriptor instead')
const CorrectionAlgorithm$json = {
  '1': 'CorrectionAlgorithm',
  '2': [
    {'1': 'CORRECTION_ALGORITHM_UNSPECIFIED', '2': 0},
    {'1': 'CORRECTION_ALGORITHM_SEN2COR', '2': 1},
    {'1': 'CORRECTION_ALGORITHM_LASRC', '2': 2},
    {'1': 'CORRECTION_ALGORITHM_FLAASH', '2': 3},
    {'1': 'CORRECTION_ALGORITHM_DOS', '2': 4},
  ],
};

/// Descriptor for `CorrectionAlgorithm`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List correctionAlgorithmDescriptor = $convert.base64Decode(
    'ChNDb3JyZWN0aW9uQWxnb3JpdGhtEiQKIENPUlJFQ1RJT05fQUxHT1JJVEhNX1VOU1BFQ0lGSU'
    'VEEAASIAocQ09SUkVDVElPTl9BTEdPUklUSE1fU0VOMkNPUhABEh4KGkNPUlJFQ1RJT05fQUxH'
    'T1JJVEhNX0xBU1JDEAISHwobQ09SUkVDVElPTl9BTEdPUklUSE1fRkxBQVNIEAMSHAoYQ09SUk'
    'VDVElPTl9BTEdPUklUSE1fRE9TEAQ=');

@$core.Deprecated('Use processingJobDescriptor instead')
const ProcessingJob$json = {
  '1': 'ProcessingJob',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'ingestion_task_id', '3': 3, '4': 1, '5': 9, '10': 'ingestionTaskId'},
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.processing.v1.ProcessingStatus',
      '10': 'status'
    },
    {
      '1': 'input_level',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.processing.v1.ProcessingLevel',
      '10': 'inputLevel'
    },
    {
      '1': 'output_level',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.processing.v1.ProcessingLevel',
      '10': 'outputLevel'
    },
    {
      '1': 'algorithm',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.processing.v1.CorrectionAlgorithm',
      '10': 'algorithm'
    },
    {'1': 'input_s3_key', '3': 9, '4': 1, '5': 9, '10': 'inputS3Key'},
    {'1': 'output_s3_key', '3': 10, '4': 1, '5': 9, '10': 'outputS3Key'},
    {
      '1': 'cloud_mask_threshold',
      '3': 11,
      '4': 1,
      '5': 1,
      '10': 'cloudMaskThreshold'
    },
    {
      '1': 'apply_atmospheric_correction',
      '3': 12,
      '4': 1,
      '5': 8,
      '10': 'applyAtmosphericCorrection'
    },
    {
      '1': 'apply_cloud_masking',
      '3': 13,
      '4': 1,
      '5': 8,
      '10': 'applyCloudMasking'
    },
    {
      '1': 'apply_orthorectification',
      '3': 14,
      '4': 1,
      '5': 8,
      '10': 'applyOrthorectification'
    },
    {
      '1': 'output_resolution_meters',
      '3': 15,
      '4': 1,
      '5': 5,
      '10': 'outputResolutionMeters'
    },
    {'1': 'output_crs', '3': 16, '4': 1, '5': 9, '10': 'outputCrs'},
    {'1': 'error_message', '3': 17, '4': 1, '5': 9, '10': 'errorMessage'},
    {
      '1': 'processing_time_seconds',
      '3': 18,
      '4': 1,
      '5': 1,
      '10': 'processingTimeSeconds'
    },
    {
      '1': 'created_at',
      '3': 19,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
    {
      '1': 'completed_at',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'completedAt'
    },
  ],
};

/// Descriptor for `ProcessingJob`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processingJobDescriptor = $convert.base64Decode(
    'Cg1Qcm9jZXNzaW5nSm9iEg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbm'
    'FudElkEioKEWluZ2VzdGlvbl90YXNrX2lkGAMgASgJUg9pbmdlc3Rpb25UYXNrSWQSFwoHZmFy'
    'bV9pZBgEIAEoCVIGZmFybUlkEk0KBnN0YXR1cxgFIAEoDjI1LmFncmljdWx0dXJlLnNhdGVsbG'
    'l0ZS5wcm9jZXNzaW5nLnYxLlByb2Nlc3NpbmdTdGF0dXNSBnN0YXR1cxJVCgtpbnB1dF9sZXZl'
    'bBgGIAEoDjI0LmFncmljdWx0dXJlLnNhdGVsbGl0ZS5wcm9jZXNzaW5nLnYxLlByb2Nlc3Npbm'
    'dMZXZlbFIKaW5wdXRMZXZlbBJXCgxvdXRwdXRfbGV2ZWwYByABKA4yNC5hZ3JpY3VsdHVyZS5z'
    'YXRlbGxpdGUucHJvY2Vzc2luZy52MS5Qcm9jZXNzaW5nTGV2ZWxSC291dHB1dExldmVsElYKCW'
    'FsZ29yaXRobRgIIAEoDjI4LmFncmljdWx0dXJlLnNhdGVsbGl0ZS5wcm9jZXNzaW5nLnYxLkNv'
    'cnJlY3Rpb25BbGdvcml0aG1SCWFsZ29yaXRobRIgCgxpbnB1dF9zM19rZXkYCSABKAlSCmlucH'
    'V0UzNLZXkSIgoNb3V0cHV0X3MzX2tleRgKIAEoCVILb3V0cHV0UzNLZXkSMAoUY2xvdWRfbWFz'
    'a190aHJlc2hvbGQYCyABKAFSEmNsb3VkTWFza1RocmVzaG9sZBJAChxhcHBseV9hdG1vc3BoZX'
    'JpY19jb3JyZWN0aW9uGAwgASgIUhphcHBseUF0bW9zcGhlcmljQ29ycmVjdGlvbhIuChNhcHBs'
    'eV9jbG91ZF9tYXNraW5nGA0gASgIUhFhcHBseUNsb3VkTWFza2luZxI5ChhhcHBseV9vcnRob3'
    'JlY3RpZmljYXRpb24YDiABKAhSF2FwcGx5T3J0aG9yZWN0aWZpY2F0aW9uEjgKGG91dHB1dF9y'
    'ZXNvbHV0aW9uX21ldGVycxgPIAEoBVIWb3V0cHV0UmVzb2x1dGlvbk1ldGVycxIdCgpvdXRwdX'
    'RfY3JzGBAgASgJUglvdXRwdXRDcnMSIwoNZXJyb3JfbWVzc2FnZRgRIAEoCVIMZXJyb3JNZXNz'
    'YWdlEjYKF3Byb2Nlc3NpbmdfdGltZV9zZWNvbmRzGBIgASgBUhVwcm9jZXNzaW5nVGltZVNlY2'
    '9uZHMSOQoKY3JlYXRlZF9hdBgTIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNy'
    'ZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GBQgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcF'
    'IJdXBkYXRlZEF0Ej0KDGNvbXBsZXRlZF9hdBgVIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1l'
    'c3RhbXBSC2NvbXBsZXRlZEF0');

@$core.Deprecated('Use submitProcessingJobRequestDescriptor instead')
const SubmitProcessingJobRequest$json = {
  '1': 'SubmitProcessingJobRequest',
  '2': [
    {'1': 'ingestion_task_id', '3': 1, '4': 1, '5': 9, '10': 'ingestionTaskId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'output_level',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.processing.v1.ProcessingLevel',
      '10': 'outputLevel'
    },
    {
      '1': 'algorithm',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.processing.v1.CorrectionAlgorithm',
      '10': 'algorithm'
    },
    {
      '1': 'cloud_mask_threshold',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'cloudMaskThreshold'
    },
    {
      '1': 'apply_atmospheric_correction',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'applyAtmosphericCorrection'
    },
    {
      '1': 'apply_cloud_masking',
      '3': 7,
      '4': 1,
      '5': 8,
      '10': 'applyCloudMasking'
    },
    {
      '1': 'apply_orthorectification',
      '3': 8,
      '4': 1,
      '5': 8,
      '10': 'applyOrthorectification'
    },
    {
      '1': 'output_resolution_meters',
      '3': 9,
      '4': 1,
      '5': 5,
      '10': 'outputResolutionMeters'
    },
    {'1': 'output_crs', '3': 10, '4': 1, '5': 9, '10': 'outputCrs'},
  ],
};

/// Descriptor for `SubmitProcessingJobRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitProcessingJobRequestDescriptor = $convert.base64Decode(
    'ChpTdWJtaXRQcm9jZXNzaW5nSm9iUmVxdWVzdBIqChFpbmdlc3Rpb25fdGFza19pZBgBIAEoCV'
    'IPaW5nZXN0aW9uVGFza0lkEhcKB2Zhcm1faWQYAiABKAlSBmZhcm1JZBJXCgxvdXRwdXRfbGV2'
    'ZWwYAyABKA4yNC5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUucHJvY2Vzc2luZy52MS5Qcm9jZXNzaW'
    '5nTGV2ZWxSC291dHB1dExldmVsElYKCWFsZ29yaXRobRgEIAEoDjI4LmFncmljdWx0dXJlLnNh'
    'dGVsbGl0ZS5wcm9jZXNzaW5nLnYxLkNvcnJlY3Rpb25BbGdvcml0aG1SCWFsZ29yaXRobRIwCh'
    'RjbG91ZF9tYXNrX3RocmVzaG9sZBgFIAEoAVISY2xvdWRNYXNrVGhyZXNob2xkEkAKHGFwcGx5'
    'X2F0bW9zcGhlcmljX2NvcnJlY3Rpb24YBiABKAhSGmFwcGx5QXRtb3NwaGVyaWNDb3JyZWN0aW'
    '9uEi4KE2FwcGx5X2Nsb3VkX21hc2tpbmcYByABKAhSEWFwcGx5Q2xvdWRNYXNraW5nEjkKGGFw'
    'cGx5X29ydGhvcmVjdGlmaWNhdGlvbhgIIAEoCFIXYXBwbHlPcnRob3JlY3RpZmljYXRpb24SOA'
    'oYb3V0cHV0X3Jlc29sdXRpb25fbWV0ZXJzGAkgASgFUhZvdXRwdXRSZXNvbHV0aW9uTWV0ZXJz'
    'Eh0KCm91dHB1dF9jcnMYCiABKAlSCW91dHB1dENycw==');

@$core.Deprecated('Use submitProcessingJobResponseDescriptor instead')
const SubmitProcessingJobResponse$json = {
  '1': 'SubmitProcessingJobResponse',
  '2': [
    {
      '1': 'job',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.processing.v1.ProcessingJob',
      '10': 'job'
    },
  ],
};

/// Descriptor for `SubmitProcessingJobResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitProcessingJobResponseDescriptor =
    $convert.base64Decode(
        'ChtTdWJtaXRQcm9jZXNzaW5nSm9iUmVzcG9uc2USRAoDam9iGAEgASgLMjIuYWdyaWN1bHR1cm'
        'Uuc2F0ZWxsaXRlLnByb2Nlc3NpbmcudjEuUHJvY2Vzc2luZ0pvYlIDam9i');

@$core.Deprecated('Use getProcessingJobRequestDescriptor instead')
const GetProcessingJobRequest$json = {
  '1': 'GetProcessingJobRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetProcessingJobRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProcessingJobRequestDescriptor = $convert
    .base64Decode('ChdHZXRQcm9jZXNzaW5nSm9iUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use getProcessingJobResponseDescriptor instead')
const GetProcessingJobResponse$json = {
  '1': 'GetProcessingJobResponse',
  '2': [
    {
      '1': 'job',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.processing.v1.ProcessingJob',
      '10': 'job'
    },
  ],
};

/// Descriptor for `GetProcessingJobResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProcessingJobResponseDescriptor =
    $convert.base64Decode(
        'ChhHZXRQcm9jZXNzaW5nSm9iUmVzcG9uc2USRAoDam9iGAEgASgLMjIuYWdyaWN1bHR1cmUuc2'
        'F0ZWxsaXRlLnByb2Nlc3NpbmcudjEuUHJvY2Vzc2luZ0pvYlIDam9i');

@$core.Deprecated('Use listProcessingJobsRequestDescriptor instead')
const ListProcessingJobsRequest$json = {
  '1': 'ListProcessingJobsRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.processing.v1.ProcessingStatus',
      '10': 'status'
    },
  ],
};

/// Descriptor for `ListProcessingJobsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProcessingJobsRequestDescriptor = $convert.base64Decode(
    'ChlMaXN0UHJvY2Vzc2luZ0pvYnNSZXF1ZXN0EhsKCXBhZ2Vfc2l6ZRgBIAEoBVIIcGFnZVNpem'
    'USHQoKcGFnZV90b2tlbhgCIAEoCVIJcGFnZVRva2VuEhcKB2Zhcm1faWQYAyABKAlSBmZhcm1J'
    'ZBJNCgZzdGF0dXMYBCABKA4yNS5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUucHJvY2Vzc2luZy52MS'
    '5Qcm9jZXNzaW5nU3RhdHVzUgZzdGF0dXM=');

@$core.Deprecated('Use listProcessingJobsResponseDescriptor instead')
const ListProcessingJobsResponse$json = {
  '1': 'ListProcessingJobsResponse',
  '2': [
    {
      '1': 'jobs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.satellite.processing.v1.ProcessingJob',
      '10': 'jobs'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListProcessingJobsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listProcessingJobsResponseDescriptor = $convert.base64Decode(
    'ChpMaXN0UHJvY2Vzc2luZ0pvYnNSZXNwb25zZRJGCgRqb2JzGAEgAygLMjIuYWdyaWN1bHR1cm'
    'Uuc2F0ZWxsaXRlLnByb2Nlc3NpbmcudjEuUHJvY2Vzc2luZ0pvYlIEam9icxImCg9uZXh0X3Bh'
    'Z2VfdG9rZW4YAiABKAlSDW5leHRQYWdlVG9rZW4SHwoLdG90YWxfY291bnQYAyABKAVSCnRvdG'
    'FsQ291bnQ=');

@$core.Deprecated('Use cancelProcessingJobRequestDescriptor instead')
const CancelProcessingJobRequest$json = {
  '1': 'CancelProcessingJobRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `CancelProcessingJobRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelProcessingJobRequestDescriptor =
    $convert.base64Decode(
        'ChpDYW5jZWxQcm9jZXNzaW5nSm9iUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use cancelProcessingJobResponseDescriptor instead')
const CancelProcessingJobResponse$json = {
  '1': 'CancelProcessingJobResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `CancelProcessingJobResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cancelProcessingJobResponseDescriptor =
    $convert.base64Decode(
        'ChtDYW5jZWxQcm9jZXNzaW5nSm9iUmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcw'
        '==');

@$core.Deprecated('Use getProcessingStatsRequestDescriptor instead')
const GetProcessingStatsRequest$json = {
  '1': 'GetProcessingStatsRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
  ],
};

/// Descriptor for `GetProcessingStatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProcessingStatsRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRQcm9jZXNzaW5nU3RhdHNSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZA==');

@$core.Deprecated('Use getProcessingStatsResponseDescriptor instead')
const GetProcessingStatsResponse$json = {
  '1': 'GetProcessingStatsResponse',
  '2': [
    {'1': 'total_jobs', '3': 1, '4': 1, '5': 3, '10': 'totalJobs'},
    {'1': 'completed_jobs', '3': 2, '4': 1, '5': 3, '10': 'completedJobs'},
    {'1': 'failed_jobs', '3': 3, '4': 1, '5': 3, '10': 'failedJobs'},
    {'1': 'pending_jobs', '3': 4, '4': 1, '5': 3, '10': 'pendingJobs'},
    {
      '1': 'avg_processing_time_seconds',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'avgProcessingTimeSeconds'
    },
  ],
};

/// Descriptor for `GetProcessingStatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getProcessingStatsResponseDescriptor = $convert.base64Decode(
    'ChpHZXRQcm9jZXNzaW5nU3RhdHNSZXNwb25zZRIdCgp0b3RhbF9qb2JzGAEgASgDUgl0b3RhbE'
    'pvYnMSJQoOY29tcGxldGVkX2pvYnMYAiABKANSDWNvbXBsZXRlZEpvYnMSHwoLZmFpbGVkX2pv'
    'YnMYAyABKANSCmZhaWxlZEpvYnMSIQoMcGVuZGluZ19qb2JzGAQgASgDUgtwZW5kaW5nSm9icx'
    'I9ChthdmdfcHJvY2Vzc2luZ190aW1lX3NlY29uZHMYBSABKAFSGGF2Z1Byb2Nlc3NpbmdUaW1l'
    'U2Vjb25kcw==');

const $core.Map<$core.String, $core.dynamic>
    SatelliteProcessingServiceBase$json = {
  '1': 'SatelliteProcessingService',
  '2': [
    {
      '1': 'SubmitProcessingJob',
      '2': '.agriculture.satellite.processing.v1.SubmitProcessingJobRequest',
      '3': '.agriculture.satellite.processing.v1.SubmitProcessingJobResponse'
    },
    {
      '1': 'GetProcessingJob',
      '2': '.agriculture.satellite.processing.v1.GetProcessingJobRequest',
      '3': '.agriculture.satellite.processing.v1.GetProcessingJobResponse'
    },
    {
      '1': 'ListProcessingJobs',
      '2': '.agriculture.satellite.processing.v1.ListProcessingJobsRequest',
      '3': '.agriculture.satellite.processing.v1.ListProcessingJobsResponse'
    },
    {
      '1': 'CancelProcessingJob',
      '2': '.agriculture.satellite.processing.v1.CancelProcessingJobRequest',
      '3': '.agriculture.satellite.processing.v1.CancelProcessingJobResponse'
    },
    {
      '1': 'GetProcessingStats',
      '2': '.agriculture.satellite.processing.v1.GetProcessingStatsRequest',
      '3': '.agriculture.satellite.processing.v1.GetProcessingStatsResponse'
    },
  ],
};

@$core.Deprecated('Use satelliteProcessingServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    SatelliteProcessingServiceBase$messageJson = {
  '.agriculture.satellite.processing.v1.SubmitProcessingJobRequest':
      SubmitProcessingJobRequest$json,
  '.agriculture.satellite.processing.v1.SubmitProcessingJobResponse':
      SubmitProcessingJobResponse$json,
  '.agriculture.satellite.processing.v1.ProcessingJob': ProcessingJob$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.satellite.processing.v1.GetProcessingJobRequest':
      GetProcessingJobRequest$json,
  '.agriculture.satellite.processing.v1.GetProcessingJobResponse':
      GetProcessingJobResponse$json,
  '.agriculture.satellite.processing.v1.ListProcessingJobsRequest':
      ListProcessingJobsRequest$json,
  '.agriculture.satellite.processing.v1.ListProcessingJobsResponse':
      ListProcessingJobsResponse$json,
  '.agriculture.satellite.processing.v1.CancelProcessingJobRequest':
      CancelProcessingJobRequest$json,
  '.agriculture.satellite.processing.v1.CancelProcessingJobResponse':
      CancelProcessingJobResponse$json,
  '.agriculture.satellite.processing.v1.GetProcessingStatsRequest':
      GetProcessingStatsRequest$json,
  '.agriculture.satellite.processing.v1.GetProcessingStatsResponse':
      GetProcessingStatsResponse$json,
};

/// Descriptor for `SatelliteProcessingService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List satelliteProcessingServiceDescriptor = $convert.base64Decode(
    'ChpTYXRlbGxpdGVQcm9jZXNzaW5nU2VydmljZRKYAQoTU3VibWl0UHJvY2Vzc2luZ0pvYhI/Lm'
    'FncmljdWx0dXJlLnNhdGVsbGl0ZS5wcm9jZXNzaW5nLnYxLlN1Ym1pdFByb2Nlc3NpbmdKb2JS'
    'ZXF1ZXN0GkAuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnByb2Nlc3NpbmcudjEuU3VibWl0UHJvY2'
    'Vzc2luZ0pvYlJlc3BvbnNlEo8BChBHZXRQcm9jZXNzaW5nSm9iEjwuYWdyaWN1bHR1cmUuc2F0'
    'ZWxsaXRlLnByb2Nlc3NpbmcudjEuR2V0UHJvY2Vzc2luZ0pvYlJlcXVlc3QaPS5hZ3JpY3VsdH'
    'VyZS5zYXRlbGxpdGUucHJvY2Vzc2luZy52MS5HZXRQcm9jZXNzaW5nSm9iUmVzcG9uc2USlQEK'
    'Ekxpc3RQcm9jZXNzaW5nSm9icxI+LmFncmljdWx0dXJlLnNhdGVsbGl0ZS5wcm9jZXNzaW5nLn'
    'YxLkxpc3RQcm9jZXNzaW5nSm9ic1JlcXVlc3QaPy5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUucHJv'
    'Y2Vzc2luZy52MS5MaXN0UHJvY2Vzc2luZ0pvYnNSZXNwb25zZRKYAQoTQ2FuY2VsUHJvY2Vzc2'
    'luZ0pvYhI/LmFncmljdWx0dXJlLnNhdGVsbGl0ZS5wcm9jZXNzaW5nLnYxLkNhbmNlbFByb2Nl'
    'c3NpbmdKb2JSZXF1ZXN0GkAuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnByb2Nlc3NpbmcudjEuQ2'
    'FuY2VsUHJvY2Vzc2luZ0pvYlJlc3BvbnNlEpUBChJHZXRQcm9jZXNzaW5nU3RhdHMSPi5hZ3Jp'
    'Y3VsdHVyZS5zYXRlbGxpdGUucHJvY2Vzc2luZy52MS5HZXRQcm9jZXNzaW5nU3RhdHNSZXF1ZX'
    'N0Gj8uYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnByb2Nlc3NpbmcudjEuR2V0UHJvY2Vzc2luZ1N0'
    'YXRzUmVzcG9uc2U=');
