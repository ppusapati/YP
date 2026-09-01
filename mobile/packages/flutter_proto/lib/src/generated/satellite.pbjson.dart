// This is a generated file - do not edit.
//
// Generated from satellite.proto.

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
    {'1': 'SATELLITE_PROVIDER_LANDSAT8', '2': 2},
    {'1': 'SATELLITE_PROVIDER_PLANET', '2': 3},
    {'1': 'SATELLITE_PROVIDER_CUSTOM', '2': 4},
  ],
};

/// Descriptor for `SatelliteProvider`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List satelliteProviderDescriptor = $convert.base64Decode(
    'ChFTYXRlbGxpdGVQcm92aWRlchIiCh5TQVRFTExJVEVfUFJPVklERVJfVU5TUEVDSUZJRUQQAB'
    'IgChxTQVRFTExJVEVfUFJPVklERVJfU0VOVElORUwyEAESHwobU0FURUxMSVRFX1BST1ZJREVS'
    'X0xBTkRTQVQ4EAISHQoZU0FURUxMSVRFX1BST1ZJREVSX1BMQU5FVBADEh0KGVNBVEVMTElURV'
    '9QUk9WSURFUl9DVVNUT00QBA==');

@$core.Deprecated('Use spectralBandDescriptor instead')
const SpectralBand$json = {
  '1': 'SpectralBand',
  '2': [
    {'1': 'SPECTRAL_BAND_UNSPECIFIED', '2': 0},
    {'1': 'SPECTRAL_BAND_RED', '2': 1},
    {'1': 'SPECTRAL_BAND_GREEN', '2': 2},
    {'1': 'SPECTRAL_BAND_BLUE', '2': 3},
    {'1': 'SPECTRAL_BAND_NIR', '2': 4},
    {'1': 'SPECTRAL_BAND_SWIR', '2': 5},
    {'1': 'SPECTRAL_BAND_REDEDGE', '2': 6},
  ],
};

/// Descriptor for `SpectralBand`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List spectralBandDescriptor = $convert.base64Decode(
    'CgxTcGVjdHJhbEJhbmQSHQoZU1BFQ1RSQUxfQkFORF9VTlNQRUNJRklFRBAAEhUKEVNQRUNUUk'
    'FMX0JBTkRfUkVEEAESFwoTU1BFQ1RSQUxfQkFORF9HUkVFThACEhYKElNQRUNUUkFMX0JBTkRf'
    'QkxVRRADEhUKEVNQRUNUUkFMX0JBTkRfTklSEAQSFgoSU1BFQ1RSQUxfQkFORF9TV0lSEAUSGQ'
    'oVU1BFQ1RSQUxfQkFORF9SRURFREdFEAY=');

@$core.Deprecated('Use processingStatusDescriptor instead')
const ProcessingStatus$json = {
  '1': 'ProcessingStatus',
  '2': [
    {'1': 'PROCESSING_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'PROCESSING_STATUS_PENDING', '2': 1},
    {'1': 'PROCESSING_STATUS_PROCESSING', '2': 2},
    {'1': 'PROCESSING_STATUS_COMPLETED', '2': 3},
    {'1': 'PROCESSING_STATUS_FAILED', '2': 4},
  ],
};

/// Descriptor for `ProcessingStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List processingStatusDescriptor = $convert.base64Decode(
    'ChBQcm9jZXNzaW5nU3RhdHVzEiEKHVBST0NFU1NJTkdfU1RBVFVTX1VOU1BFQ0lGSUVEEAASHQ'
    'oZUFJPQ0VTU0lOR19TVEFUVVNfUEVORElORxABEiAKHFBST0NFU1NJTkdfU1RBVFVTX1BST0NF'
    'U1NJTkcQAhIfChtQUk9DRVNTSU5HX1NUQVRVU19DT01QTEVURUQQAxIcChhQUk9DRVNTSU5HX1'
    'NUQVRVU19GQUlMRUQQBA==');

@$core.Deprecated('Use stressTypeDescriptor instead')
const StressType$json = {
  '1': 'StressType',
  '2': [
    {'1': 'STRESS_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'STRESS_TYPE_WATER', '2': 1},
    {'1': 'STRESS_TYPE_NUTRIENT', '2': 2},
    {'1': 'STRESS_TYPE_DISEASE', '2': 3},
    {'1': 'STRESS_TYPE_PEST', '2': 4},
  ],
};

/// Descriptor for `StressType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List stressTypeDescriptor = $convert.base64Decode(
    'CgpTdHJlc3NUeXBlEhsKF1NUUkVTU19UWVBFX1VOU1BFQ0lGSUVEEAASFQoRU1RSRVNTX1RZUE'
    'VfV0FURVIQARIYChRTVFJFU1NfVFlQRV9OVVRSSUVOVBACEhcKE1NUUkVTU19UWVBFX0RJU0VB'
    'U0UQAxIUChBTVFJFU1NfVFlQRV9QRVNUEAQ=');

@$core.Deprecated('Use boundingBoxDescriptor instead')
const BoundingBox$json = {
  '1': 'BoundingBox',
  '2': [
    {'1': 'min_lat', '3': 1, '4': 1, '5': 1, '10': 'minLat'},
    {'1': 'min_lon', '3': 2, '4': 1, '5': 1, '10': 'minLon'},
    {'1': 'max_lat', '3': 3, '4': 1, '5': 1, '10': 'maxLat'},
    {'1': 'max_lon', '3': 4, '4': 1, '5': 1, '10': 'maxLon'},
  ],
};

/// Descriptor for `BoundingBox`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boundingBoxDescriptor = $convert.base64Decode(
    'CgtCb3VuZGluZ0JveBIXCgdtaW5fbGF0GAEgASgBUgZtaW5MYXQSFwoHbWluX2xvbhgCIAEoAV'
    'IGbWluTG9uEhcKB21heF9sYXQYAyABKAFSBm1heExhdBIXCgdtYXhfbG9uGAQgASgBUgZtYXhM'
    'b24=');

@$core.Deprecated('Use satelliteImageDescriptor instead')
const SatelliteImage$json = {
  '1': 'SatelliteImage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'satellite_provider',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.v1.SatelliteProvider',
      '10': 'satelliteProvider'
    },
    {
      '1': 'acquisition_date',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'acquisitionDate'
    },
    {'1': 'cloud_cover_pct', '3': 7, '4': 1, '5': 1, '10': 'cloudCoverPct'},
    {
      '1': 'resolution_meters',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'resolutionMeters'
    },
    {
      '1': 'bands',
      '3': 9,
      '4': 3,
      '5': 14,
      '6': '.agriculture.satellite.v1.SpectralBand',
      '10': 'bands'
    },
    {
      '1': 'bbox',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.v1.BoundingBox',
      '10': 'bbox'
    },
    {'1': 'image_url', '3': 11, '4': 1, '5': 9, '10': 'imageUrl'},
    {
      '1': 'processing_status',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.v1.ProcessingStatus',
      '10': 'processingStatus'
    },
    {'1': 'version', '3': 13, '4': 1, '5': 5, '10': 'version'},
    {
      '1': 'created_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `SatelliteImage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satelliteImageDescriptor = $convert.base64Decode(
    'Cg5TYXRlbGxpdGVJbWFnZRIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW'
    '5hbnRJZBIZCghmaWVsZF9pZBgDIAEoCVIHZmllbGRJZBIXCgdmYXJtX2lkGAQgASgJUgZmYXJt'
    'SWQSWgoSc2F0ZWxsaXRlX3Byb3ZpZGVyGAUgASgOMisuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLn'
    'YxLlNhdGVsbGl0ZVByb3ZpZGVyUhFzYXRlbGxpdGVQcm92aWRlchJFChBhY3F1aXNpdGlvbl9k'
    'YXRlGAYgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIPYWNxdWlzaXRpb25EYXRlEi'
    'YKD2Nsb3VkX2NvdmVyX3BjdBgHIAEoAVINY2xvdWRDb3ZlclBjdBIrChFyZXNvbHV0aW9uX21l'
    'dGVycxgIIAEoAVIQcmVzb2x1dGlvbk1ldGVycxI8CgViYW5kcxgJIAMoDjImLmFncmljdWx0dX'
    'JlLnNhdGVsbGl0ZS52MS5TcGVjdHJhbEJhbmRSBWJhbmRzEjkKBGJib3gYCiABKAsyJS5hZ3Jp'
    'Y3VsdHVyZS5zYXRlbGxpdGUudjEuQm91bmRpbmdCb3hSBGJib3gSGwoJaW1hZ2VfdXJsGAsgAS'
    'gJUghpbWFnZVVybBJXChFwcm9jZXNzaW5nX3N0YXR1cxgMIAEoDjIqLmFncmljdWx0dXJlLnNh'
    'dGVsbGl0ZS52MS5Qcm9jZXNzaW5nU3RhdHVzUhBwcm9jZXNzaW5nU3RhdHVzEhgKB3ZlcnNpb2'
    '4YDSABKAVSB3ZlcnNpb24SOQoKY3JlYXRlZF9hdBgOIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5U'
    'aW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GA8gASgLMhouZ29vZ2xlLnByb3RvYn'
    'VmLlRpbWVzdGFtcFIJdXBkYXRlZEF0');

@$core.Deprecated('Use vegetationIndexDescriptor instead')
const VegetationIndex$json = {
  '1': 'VegetationIndex',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'image_id', '3': 3, '4': 1, '5': 9, '10': 'imageId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'index_type', '3': 5, '4': 1, '5': 9, '10': 'indexType'},
    {'1': 'min_value', '3': 6, '4': 1, '5': 1, '10': 'minValue'},
    {'1': 'max_value', '3': 7, '4': 1, '5': 1, '10': 'maxValue'},
    {'1': 'mean_value', '3': 8, '4': 1, '5': 1, '10': 'meanValue'},
    {'1': 'std_dev', '3': 9, '4': 1, '5': 1, '10': 'stdDev'},
    {'1': 'raster_url', '3': 10, '4': 1, '5': 9, '10': 'rasterUrl'},
    {
      '1': 'computed_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'computedAt'
    },
    {'1': 'version', '3': 12, '4': 1, '5': 5, '10': 'version'},
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

/// Descriptor for `VegetationIndex`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List vegetationIndexDescriptor = $convert.base64Decode(
    'Cg9WZWdldGF0aW9uSW5kZXgSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdG'
    'VuYW50SWQSGQoIaW1hZ2VfaWQYAyABKAlSB2ltYWdlSWQSGQoIZmllbGRfaWQYBCABKAlSB2Zp'
    'ZWxkSWQSHQoKaW5kZXhfdHlwZRgFIAEoCVIJaW5kZXhUeXBlEhsKCW1pbl92YWx1ZRgGIAEoAV'
    'IIbWluVmFsdWUSGwoJbWF4X3ZhbHVlGAcgASgBUghtYXhWYWx1ZRIdCgptZWFuX3ZhbHVlGAgg'
    'ASgBUgltZWFuVmFsdWUSFwoHc3RkX2RldhgJIAEoAVIGc3RkRGV2Eh0KCnJhc3Rlcl91cmwYCi'
    'ABKAlSCXJhc3RlclVybBI7Cgtjb21wdXRlZF9hdBgLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5U'
    'aW1lc3RhbXBSCmNvbXB1dGVkQXQSGAoHdmVyc2lvbhgMIAEoBVIHdmVyc2lvbhI5CgpjcmVhdG'
    'VkX2F0GA0gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVw'
    'ZGF0ZWRfYXQYDiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use cropStressAlertDescriptor instead')
const CropStressAlert$json = {
  '1': 'CropStressAlert',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'image_id', '3': 4, '4': 1, '5': 9, '10': 'imageId'},
    {'1': 'stress_detected', '3': 5, '4': 1, '5': 8, '10': 'stressDetected'},
    {
      '1': 'stress_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.v1.StressType',
      '10': 'stressType'
    },
    {'1': 'stress_severity', '3': 7, '4': 1, '5': 1, '10': 'stressSeverity'},
    {'1': 'affected_area_pct', '3': 8, '4': 1, '5': 1, '10': 'affectedAreaPct'},
    {'1': 'description', '3': 9, '4': 1, '5': 9, '10': 'description'},
    {'1': 'recommendation', '3': 10, '4': 1, '5': 9, '10': 'recommendation'},
    {
      '1': 'affected_bbox',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.v1.BoundingBox',
      '10': 'affectedBbox'
    },
    {'1': 'version', '3': 12, '4': 1, '5': 5, '10': 'version'},
    {
      '1': 'detected_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'detectedAt'
    },
    {
      '1': 'created_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `CropStressAlert`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cropStressAlertDescriptor = $convert.base64Decode(
    'Cg9Dcm9wU3RyZXNzQWxlcnQSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdG'
    'VuYW50SWQSGQoIZmllbGRfaWQYAyABKAlSB2ZpZWxkSWQSGQoIaW1hZ2VfaWQYBCABKAlSB2lt'
    'YWdlSWQSJwoPc3RyZXNzX2RldGVjdGVkGAUgASgIUg5zdHJlc3NEZXRlY3RlZBJFCgtzdHJlc3'
    'NfdHlwZRgGIAEoDjIkLmFncmljdWx0dXJlLnNhdGVsbGl0ZS52MS5TdHJlc3NUeXBlUgpzdHJl'
    'c3NUeXBlEicKD3N0cmVzc19zZXZlcml0eRgHIAEoAVIOc3RyZXNzU2V2ZXJpdHkSKgoRYWZmZW'
    'N0ZWRfYXJlYV9wY3QYCCABKAFSD2FmZmVjdGVkQXJlYVBjdBIgCgtkZXNjcmlwdGlvbhgJIAEo'
    'CVILZGVzY3JpcHRpb24SJgoOcmVjb21tZW5kYXRpb24YCiABKAlSDnJlY29tbWVuZGF0aW9uEk'
    'oKDWFmZmVjdGVkX2Jib3gYCyABKAsyJS5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUudjEuQm91bmRp'
    'bmdCb3hSDGFmZmVjdGVkQmJveBIYCgd2ZXJzaW9uGAwgASgFUgd2ZXJzaW9uEjsKC2RldGVjdG'
    'VkX2F0GA0gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIKZGV0ZWN0ZWRBdBI5Cgpj'
    'cmVhdGVkX2F0GA4gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0Ej'
    'kKCnVwZGF0ZWRfYXQYDyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVk'
    'QXQ=');

@$core.Deprecated('Use temporalAnalysisDescriptor instead')
const TemporalAnalysis$json = {
  '1': 'TemporalAnalysis',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'index_type', '3': 4, '4': 1, '5': 9, '10': 'indexType'},
    {
      '1': 'start_date',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startDate'
    },
    {
      '1': 'end_date',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'endDate'
    },
    {
      '1': 'data_points',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.agriculture.satellite.v1.TemporalDataPoint',
      '10': 'dataPoints'
    },
    {'1': 'trend_slope', '3': 8, '4': 1, '5': 1, '10': 'trendSlope'},
    {'1': 'trend_direction', '3': 9, '4': 1, '5': 9, '10': 'trendDirection'},
    {'1': 'change_pct', '3': 10, '4': 1, '5': 1, '10': 'changePct'},
    {'1': 'version', '3': 11, '4': 1, '5': 5, '10': 'version'},
    {
      '1': 'created_at',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `TemporalAnalysis`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List temporalAnalysisDescriptor = $convert.base64Decode(
    'ChBUZW1wb3JhbEFuYWx5c2lzEg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCH'
    'RlbmFudElkEhkKCGZpZWxkX2lkGAMgASgJUgdmaWVsZElkEh0KCmluZGV4X3R5cGUYBCABKAlS'
    'CWluZGV4VHlwZRI5CgpzdGFydF9kYXRlGAUgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdG'
    'FtcFIJc3RhcnREYXRlEjUKCGVuZF9kYXRlGAYgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVz'
    'dGFtcFIHZW5kRGF0ZRJMCgtkYXRhX3BvaW50cxgHIAMoCzIrLmFncmljdWx0dXJlLnNhdGVsbG'
    'l0ZS52MS5UZW1wb3JhbERhdGFQb2ludFIKZGF0YVBvaW50cxIfCgt0cmVuZF9zbG9wZRgIIAEo'
    'AVIKdHJlbmRTbG9wZRInCg90cmVuZF9kaXJlY3Rpb24YCSABKAlSDnRyZW5kRGlyZWN0aW9uEh'
    '0KCmNoYW5nZV9wY3QYCiABKAFSCWNoYW5nZVBjdBIYCgd2ZXJzaW9uGAsgASgFUgd2ZXJzaW9u'
    'EjkKCmNyZWF0ZWRfYXQYDCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdG'
    'VkQXQSOQoKdXBkYXRlZF9hdBgNIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVw'
    'ZGF0ZWRBdA==');

@$core.Deprecated('Use temporalDataPointDescriptor instead')
const TemporalDataPoint$json = {
  '1': 'TemporalDataPoint',
  '2': [
    {
      '1': 'date',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'date'
    },
    {'1': 'mean_value', '3': 2, '4': 1, '5': 1, '10': 'meanValue'},
    {'1': 'min_value', '3': 3, '4': 1, '5': 1, '10': 'minValue'},
    {'1': 'max_value', '3': 4, '4': 1, '5': 1, '10': 'maxValue'},
  ],
};

/// Descriptor for `TemporalDataPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List temporalDataPointDescriptor = $convert.base64Decode(
    'ChFUZW1wb3JhbERhdGFQb2ludBIuCgRkYXRlGAEgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbW'
    'VzdGFtcFIEZGF0ZRIdCgptZWFuX3ZhbHVlGAIgASgBUgltZWFuVmFsdWUSGwoJbWluX3ZhbHVl'
    'GAMgASgBUghtaW5WYWx1ZRIbCgltYXhfdmFsdWUYBCABKAFSCG1heFZhbHVl');

@$core.Deprecated('Use satelliteTaskDescriptor instead')
const SatelliteTask$json = {
  '1': 'SatelliteTask',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'task_type', '3': 4, '4': 1, '5': 9, '10': 'taskType'},
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.v1.ProcessingStatus',
      '10': 'status'
    },
    {'1': 'input_image_id', '3': 6, '4': 1, '5': 9, '10': 'inputImageId'},
    {'1': 'result_id', '3': 7, '4': 1, '5': 9, '10': 'resultId'},
    {'1': 'error_message', '3': 8, '4': 1, '5': 9, '10': 'errorMessage'},
    {'1': 'retry_count', '3': 9, '4': 1, '5': 5, '10': 'retryCount'},
    {'1': 'version', '3': 10, '4': 1, '5': 5, '10': 'version'},
    {
      '1': 'created_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `SatelliteTask`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List satelliteTaskDescriptor = $convert.base64Decode(
    'Cg1TYXRlbGxpdGVUYXNrEg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbm'
    'FudElkEhkKCGZpZWxkX2lkGAMgASgJUgdmaWVsZElkEhsKCXRhc2tfdHlwZRgEIAEoCVIIdGFz'
    'a1R5cGUSQgoGc3RhdHVzGAUgASgOMiouYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnYxLlByb2Nlc3'
    'NpbmdTdGF0dXNSBnN0YXR1cxIkCg5pbnB1dF9pbWFnZV9pZBgGIAEoCVIMaW5wdXRJbWFnZUlk'
    'EhsKCXJlc3VsdF9pZBgHIAEoCVIIcmVzdWx0SWQSIwoNZXJyb3JfbWVzc2FnZRgIIAEoCVIMZX'
    'Jyb3JNZXNzYWdlEh8KC3JldHJ5X2NvdW50GAkgASgFUgpyZXRyeUNvdW50EhgKB3ZlcnNpb24Y'
    'CiABKAVSB3ZlcnNpb24SOQoKY3JlYXRlZF9hdBgLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW'
    '1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GAwgASgLMhouZ29vZ2xlLnByb3RvYnVm'
    'LlRpbWVzdGFtcFIJdXBkYXRlZEF0');

@$core.Deprecated('Use requestImageryRequestDescriptor instead')
const RequestImageryRequest$json = {
  '1': 'RequestImageryRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'satellite_provider',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.v1.SatelliteProvider',
      '10': 'satelliteProvider'
    },
    {
      '1': 'bbox',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.v1.BoundingBox',
      '10': 'bbox'
    },
    {
      '1': 'max_cloud_cover_pct',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'maxCloudCoverPct'
    },
    {
      '1': 'resolution_meters',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'resolutionMeters'
    },
    {
      '1': 'bands',
      '3': 8,
      '4': 3,
      '5': 14,
      '6': '.agriculture.satellite.v1.SpectralBand',
      '10': 'bands'
    },
  ],
};

/// Descriptor for `RequestImageryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestImageryRequestDescriptor = $convert.base64Decode(
    'ChVSZXF1ZXN0SW1hZ2VyeVJlcXVlc3QSGwoJdGVuYW50X2lkGAEgASgJUgh0ZW5hbnRJZBIZCg'
    'hmaWVsZF9pZBgCIAEoCVIHZmllbGRJZBIXCgdmYXJtX2lkGAMgASgJUgZmYXJtSWQSWgoSc2F0'
    'ZWxsaXRlX3Byb3ZpZGVyGAQgASgOMisuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnYxLlNhdGVsbG'
    'l0ZVByb3ZpZGVyUhFzYXRlbGxpdGVQcm92aWRlchI5CgRiYm94GAUgASgLMiUuYWdyaWN1bHR1'
    'cmUuc2F0ZWxsaXRlLnYxLkJvdW5kaW5nQm94UgRiYm94Ei0KE21heF9jbG91ZF9jb3Zlcl9wY3'
    'QYBiABKAFSEG1heENsb3VkQ292ZXJQY3QSKwoRcmVzb2x1dGlvbl9tZXRlcnMYByABKAFSEHJl'
    'c29sdXRpb25NZXRlcnMSPAoFYmFuZHMYCCADKA4yJi5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUudj'
    'EuU3BlY3RyYWxCYW5kUgViYW5kcw==');

@$core.Deprecated('Use requestImageryResponseDescriptor instead')
const RequestImageryResponse$json = {
  '1': 'RequestImageryResponse',
  '2': [
    {
      '1': 'task',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.v1.SatelliteTask',
      '10': 'task'
    },
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `RequestImageryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestImageryResponseDescriptor = $convert.base64Decode(
    'ChZSZXF1ZXN0SW1hZ2VyeVJlc3BvbnNlEjsKBHRhc2sYASABKAsyJy5hZ3JpY3VsdHVyZS5zYX'
    'RlbGxpdGUudjEuU2F0ZWxsaXRlVGFza1IEdGFzaxIYCgdtZXNzYWdlGAIgASgJUgdtZXNzYWdl');

@$core.Deprecated('Use getImageRequestDescriptor instead')
const GetImageRequest$json = {
  '1': 'GetImageRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
  ],
};

/// Descriptor for `GetImageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getImageRequestDescriptor = $convert.base64Decode(
    'Cg9HZXRJbWFnZVJlcXVlc3QSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdG'
    'VuYW50SWQ=');

@$core.Deprecated('Use getImageResponseDescriptor instead')
const GetImageResponse$json = {
  '1': 'GetImageResponse',
  '2': [
    {
      '1': 'image',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.v1.SatelliteImage',
      '10': 'image'
    },
  ],
};

/// Descriptor for `GetImageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getImageResponseDescriptor = $convert.base64Decode(
    'ChBHZXRJbWFnZVJlc3BvbnNlEj4KBWltYWdlGAEgASgLMiguYWdyaWN1bHR1cmUuc2F0ZWxsaX'
    'RlLnYxLlNhdGVsbGl0ZUltYWdlUgVpbWFnZQ==');

@$core.Deprecated('Use listImagesRequestDescriptor instead')
const ListImagesRequest$json = {
  '1': 'ListImagesRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 5, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListImagesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listImagesRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0SW1hZ2VzUmVxdWVzdBIbCgl0ZW5hbnRfaWQYASABKAlSCHRlbmFudElkEhkKCGZpZW'
    'xkX2lkGAIgASgJUgdmaWVsZElkEhcKB2Zhcm1faWQYAyABKAlSBmZhcm1JZBIbCglwYWdlX3Np'
    'emUYBCABKAVSCHBhZ2VTaXplEh8KC3BhZ2Vfb2Zmc2V0GAUgASgFUgpwYWdlT2Zmc2V0');

@$core.Deprecated('Use listImagesResponseDescriptor instead')
const ListImagesResponse$json = {
  '1': 'ListImagesResponse',
  '2': [
    {
      '1': 'images',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.satellite.v1.SatelliteImage',
      '10': 'images'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListImagesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listImagesResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0SW1hZ2VzUmVzcG9uc2USQAoGaW1hZ2VzGAEgAygLMiguYWdyaWN1bHR1cmUuc2F0ZW'
    'xsaXRlLnYxLlNhdGVsbGl0ZUltYWdlUgZpbWFnZXMSHwoLdG90YWxfY291bnQYAiABKAVSCnRv'
    'dGFsQ291bnQ=');

@$core.Deprecated('Use computeIndexRequestDescriptor instead')
const ComputeIndexRequest$json = {
  '1': 'ComputeIndexRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'image_id', '3': 2, '4': 1, '5': 9, '10': 'imageId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
  ],
};

/// Descriptor for `ComputeIndexRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List computeIndexRequestDescriptor = $convert.base64Decode(
    'ChNDb21wdXRlSW5kZXhSZXF1ZXN0EhsKCXRlbmFudF9pZBgBIAEoCVIIdGVuYW50SWQSGQoIaW'
    '1hZ2VfaWQYAiABKAlSB2ltYWdlSWQSGQoIZmllbGRfaWQYAyABKAlSB2ZpZWxkSWQ=');

@$core.Deprecated('Use computeIndexResponseDescriptor instead')
const ComputeIndexResponse$json = {
  '1': 'ComputeIndexResponse',
  '2': [
    {
      '1': 'index',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.v1.VegetationIndex',
      '10': 'index'
    },
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `ComputeIndexResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List computeIndexResponseDescriptor = $convert.base64Decode(
    'ChRDb21wdXRlSW5kZXhSZXNwb25zZRI/CgVpbmRleBgBIAEoCzIpLmFncmljdWx0dXJlLnNhdG'
    'VsbGl0ZS52MS5WZWdldGF0aW9uSW5kZXhSBWluZGV4EhgKB21lc3NhZ2UYAiABKAlSB21lc3Nh'
    'Z2U=');

@$core.Deprecated('Use getVegetationIndicesRequestDescriptor instead')
const GetVegetationIndicesRequest$json = {
  '1': 'GetVegetationIndicesRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'image_id', '3': 2, '4': 1, '5': 9, '10': 'imageId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'index_type', '3': 4, '4': 1, '5': 9, '10': 'indexType'},
  ],
};

/// Descriptor for `GetVegetationIndicesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getVegetationIndicesRequestDescriptor =
    $convert.base64Decode(
        'ChtHZXRWZWdldGF0aW9uSW5kaWNlc1JlcXVlc3QSGwoJdGVuYW50X2lkGAEgASgJUgh0ZW5hbn'
        'RJZBIZCghpbWFnZV9pZBgCIAEoCVIHaW1hZ2VJZBIZCghmaWVsZF9pZBgDIAEoCVIHZmllbGRJ'
        'ZBIdCgppbmRleF90eXBlGAQgASgJUglpbmRleFR5cGU=');

@$core.Deprecated('Use getVegetationIndicesResponseDescriptor instead')
const GetVegetationIndicesResponse$json = {
  '1': 'GetVegetationIndicesResponse',
  '2': [
    {
      '1': 'indices',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.satellite.v1.VegetationIndex',
      '10': 'indices'
    },
  ],
};

/// Descriptor for `GetVegetationIndicesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getVegetationIndicesResponseDescriptor =
    $convert.base64Decode(
        'ChxHZXRWZWdldGF0aW9uSW5kaWNlc1Jlc3BvbnNlEkMKB2luZGljZXMYASADKAsyKS5hZ3JpY3'
        'VsdHVyZS5zYXRlbGxpdGUudjEuVmVnZXRhdGlvbkluZGV4UgdpbmRpY2Vz');

@$core.Deprecated('Use detectCropStressRequestDescriptor instead')
const DetectCropStressRequest$json = {
  '1': 'DetectCropStressRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'image_id', '3': 2, '4': 1, '5': 9, '10': 'imageId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
  ],
};

/// Descriptor for `DetectCropStressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectCropStressRequestDescriptor = $convert.base64Decode(
    'ChdEZXRlY3RDcm9wU3RyZXNzUmVxdWVzdBIbCgl0ZW5hbnRfaWQYASABKAlSCHRlbmFudElkEh'
    'kKCGltYWdlX2lkGAIgASgJUgdpbWFnZUlkEhkKCGZpZWxkX2lkGAMgASgJUgdmaWVsZElk');

@$core.Deprecated('Use detectCropStressResponseDescriptor instead')
const DetectCropStressResponse$json = {
  '1': 'DetectCropStressResponse',
  '2': [
    {
      '1': 'alert',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.v1.CropStressAlert',
      '10': 'alert'
    },
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `DetectCropStressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectCropStressResponseDescriptor = $convert.base64Decode(
    'ChhEZXRlY3RDcm9wU3RyZXNzUmVzcG9uc2USPwoFYWxlcnQYASABKAsyKS5hZ3JpY3VsdHVyZS'
    '5zYXRlbGxpdGUudjEuQ3JvcFN0cmVzc0FsZXJ0UgVhbGVydBIYCgdtZXNzYWdlGAIgASgJUgdt'
    'ZXNzYWdl');

@$core.Deprecated('Use getTemporalAnalysisRequestDescriptor instead')
const GetTemporalAnalysisRequest$json = {
  '1': 'GetTemporalAnalysisRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'index_type', '3': 3, '4': 1, '5': 9, '10': 'indexType'},
    {
      '1': 'start_date',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startDate'
    },
    {
      '1': 'end_date',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'endDate'
    },
  ],
};

/// Descriptor for `GetTemporalAnalysisRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTemporalAnalysisRequestDescriptor = $convert.base64Decode(
    'ChpHZXRUZW1wb3JhbEFuYWx5c2lzUmVxdWVzdBIbCgl0ZW5hbnRfaWQYASABKAlSCHRlbmFudE'
    'lkEhkKCGZpZWxkX2lkGAIgASgJUgdmaWVsZElkEh0KCmluZGV4X3R5cGUYAyABKAlSCWluZGV4'
    'VHlwZRI5CgpzdGFydF9kYXRlGAQgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJc3'
    'RhcnREYXRlEjUKCGVuZF9kYXRlGAUgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIH'
    'ZW5kRGF0ZQ==');

@$core.Deprecated('Use getTemporalAnalysisResponseDescriptor instead')
const GetTemporalAnalysisResponse$json = {
  '1': 'GetTemporalAnalysisResponse',
  '2': [
    {
      '1': 'analysis',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.v1.TemporalAnalysis',
      '10': 'analysis'
    },
  ],
};

/// Descriptor for `GetTemporalAnalysisResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTemporalAnalysisResponseDescriptor =
    $convert.base64Decode(
        'ChtHZXRUZW1wb3JhbEFuYWx5c2lzUmVzcG9uc2USRgoIYW5hbHlzaXMYASABKAsyKi5hZ3JpY3'
        'VsdHVyZS5zYXRlbGxpdGUudjEuVGVtcG9yYWxBbmFseXNpc1IIYW5hbHlzaXM=');

@$core.Deprecated('Use listAlertsRequestDescriptor instead')
const ListAlertsRequest$json = {
  '1': 'ListAlertsRequest',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 4, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListAlertsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAlertsRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0QWxlcnRzUmVxdWVzdBIbCgl0ZW5hbnRfaWQYASABKAlSCHRlbmFudElkEhkKCGZpZW'
    'xkX2lkGAIgASgJUgdmaWVsZElkEhsKCXBhZ2Vfc2l6ZRgDIAEoBVIIcGFnZVNpemUSHwoLcGFn'
    'ZV9vZmZzZXQYBCABKAVSCnBhZ2VPZmZzZXQ=');

@$core.Deprecated('Use listAlertsResponseDescriptor instead')
const ListAlertsResponse$json = {
  '1': 'ListAlertsResponse',
  '2': [
    {
      '1': 'alerts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.satellite.v1.CropStressAlert',
      '10': 'alerts'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListAlertsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAlertsResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0QWxlcnRzUmVzcG9uc2USQQoGYWxlcnRzGAEgAygLMikuYWdyaWN1bHR1cmUuc2F0ZW'
    'xsaXRlLnYxLkNyb3BTdHJlc3NBbGVydFIGYWxlcnRzEh8KC3RvdGFsX2NvdW50GAIgASgFUgp0'
    'b3RhbENvdW50');

const $core.Map<$core.String, $core.dynamic> SatelliteServiceBase$json = {
  '1': 'SatelliteService',
  '2': [
    {
      '1': 'RequestImagery',
      '2': '.agriculture.satellite.v1.RequestImageryRequest',
      '3': '.agriculture.satellite.v1.RequestImageryResponse'
    },
    {
      '1': 'GetImage',
      '2': '.agriculture.satellite.v1.GetImageRequest',
      '3': '.agriculture.satellite.v1.GetImageResponse'
    },
    {
      '1': 'ListImages',
      '2': '.agriculture.satellite.v1.ListImagesRequest',
      '3': '.agriculture.satellite.v1.ListImagesResponse'
    },
    {
      '1': 'ComputeNDVI',
      '2': '.agriculture.satellite.v1.ComputeIndexRequest',
      '3': '.agriculture.satellite.v1.ComputeIndexResponse'
    },
    {
      '1': 'ComputeNDWI',
      '2': '.agriculture.satellite.v1.ComputeIndexRequest',
      '3': '.agriculture.satellite.v1.ComputeIndexResponse'
    },
    {
      '1': 'ComputeEVI',
      '2': '.agriculture.satellite.v1.ComputeIndexRequest',
      '3': '.agriculture.satellite.v1.ComputeIndexResponse'
    },
    {
      '1': 'GetVegetationIndices',
      '2': '.agriculture.satellite.v1.GetVegetationIndicesRequest',
      '3': '.agriculture.satellite.v1.GetVegetationIndicesResponse'
    },
    {
      '1': 'DetectCropStress',
      '2': '.agriculture.satellite.v1.DetectCropStressRequest',
      '3': '.agriculture.satellite.v1.DetectCropStressResponse'
    },
    {
      '1': 'GetTemporalAnalysis',
      '2': '.agriculture.satellite.v1.GetTemporalAnalysisRequest',
      '3': '.agriculture.satellite.v1.GetTemporalAnalysisResponse'
    },
    {
      '1': 'ListAlerts',
      '2': '.agriculture.satellite.v1.ListAlertsRequest',
      '3': '.agriculture.satellite.v1.ListAlertsResponse'
    },
  ],
};

@$core.Deprecated('Use satelliteServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    SatelliteServiceBase$messageJson = {
  '.agriculture.satellite.v1.RequestImageryRequest': RequestImageryRequest$json,
  '.agriculture.satellite.v1.BoundingBox': BoundingBox$json,
  '.agriculture.satellite.v1.RequestImageryResponse':
      RequestImageryResponse$json,
  '.agriculture.satellite.v1.SatelliteTask': SatelliteTask$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.satellite.v1.GetImageRequest': GetImageRequest$json,
  '.agriculture.satellite.v1.GetImageResponse': GetImageResponse$json,
  '.agriculture.satellite.v1.SatelliteImage': SatelliteImage$json,
  '.agriculture.satellite.v1.ListImagesRequest': ListImagesRequest$json,
  '.agriculture.satellite.v1.ListImagesResponse': ListImagesResponse$json,
  '.agriculture.satellite.v1.ComputeIndexRequest': ComputeIndexRequest$json,
  '.agriculture.satellite.v1.ComputeIndexResponse': ComputeIndexResponse$json,
  '.agriculture.satellite.v1.VegetationIndex': VegetationIndex$json,
  '.agriculture.satellite.v1.GetVegetationIndicesRequest':
      GetVegetationIndicesRequest$json,
  '.agriculture.satellite.v1.GetVegetationIndicesResponse':
      GetVegetationIndicesResponse$json,
  '.agriculture.satellite.v1.DetectCropStressRequest':
      DetectCropStressRequest$json,
  '.agriculture.satellite.v1.DetectCropStressResponse':
      DetectCropStressResponse$json,
  '.agriculture.satellite.v1.CropStressAlert': CropStressAlert$json,
  '.agriculture.satellite.v1.GetTemporalAnalysisRequest':
      GetTemporalAnalysisRequest$json,
  '.agriculture.satellite.v1.GetTemporalAnalysisResponse':
      GetTemporalAnalysisResponse$json,
  '.agriculture.satellite.v1.TemporalAnalysis': TemporalAnalysis$json,
  '.agriculture.satellite.v1.TemporalDataPoint': TemporalDataPoint$json,
  '.agriculture.satellite.v1.ListAlertsRequest': ListAlertsRequest$json,
  '.agriculture.satellite.v1.ListAlertsResponse': ListAlertsResponse$json,
};

/// Descriptor for `SatelliteService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List satelliteServiceDescriptor = $convert.base64Decode(
    'ChBTYXRlbGxpdGVTZXJ2aWNlEnMKDlJlcXVlc3RJbWFnZXJ5Ei8uYWdyaWN1bHR1cmUuc2F0ZW'
    'xsaXRlLnYxLlJlcXVlc3RJbWFnZXJ5UmVxdWVzdBowLmFncmljdWx0dXJlLnNhdGVsbGl0ZS52'
    'MS5SZXF1ZXN0SW1hZ2VyeVJlc3BvbnNlEmEKCEdldEltYWdlEikuYWdyaWN1bHR1cmUuc2F0ZW'
    'xsaXRlLnYxLkdldEltYWdlUmVxdWVzdBoqLmFncmljdWx0dXJlLnNhdGVsbGl0ZS52MS5HZXRJ'
    'bWFnZVJlc3BvbnNlEmcKCkxpc3RJbWFnZXMSKy5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUudjEuTG'
    'lzdEltYWdlc1JlcXVlc3QaLC5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUudjEuTGlzdEltYWdlc1Jl'
    'c3BvbnNlEmwKC0NvbXB1dGVORFZJEi0uYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnYxLkNvbXB1dG'
    'VJbmRleFJlcXVlc3QaLi5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUudjEuQ29tcHV0ZUluZGV4UmVz'
    'cG9uc2USbAoLQ29tcHV0ZU5EV0kSLS5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUudjEuQ29tcHV0ZU'
    'luZGV4UmVxdWVzdBouLmFncmljdWx0dXJlLnNhdGVsbGl0ZS52MS5Db21wdXRlSW5kZXhSZXNw'
    'b25zZRJrCgpDb21wdXRlRVZJEi0uYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnYxLkNvbXB1dGVJbm'
    'RleFJlcXVlc3QaLi5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUudjEuQ29tcHV0ZUluZGV4UmVzcG9u'
    'c2UShQEKFEdldFZlZ2V0YXRpb25JbmRpY2VzEjUuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnYxLk'
    'dldFZlZ2V0YXRpb25JbmRpY2VzUmVxdWVzdBo2LmFncmljdWx0dXJlLnNhdGVsbGl0ZS52MS5H'
    'ZXRWZWdldGF0aW9uSW5kaWNlc1Jlc3BvbnNlEnkKEERldGVjdENyb3BTdHJlc3MSMS5hZ3JpY3'
    'VsdHVyZS5zYXRlbGxpdGUudjEuRGV0ZWN0Q3JvcFN0cmVzc1JlcXVlc3QaMi5hZ3JpY3VsdHVy'
    'ZS5zYXRlbGxpdGUudjEuRGV0ZWN0Q3JvcFN0cmVzc1Jlc3BvbnNlEoIBChNHZXRUZW1wb3JhbE'
    'FuYWx5c2lzEjQuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnYxLkdldFRlbXBvcmFsQW5hbHlzaXNS'
    'ZXF1ZXN0GjUuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnYxLkdldFRlbXBvcmFsQW5hbHlzaXNSZX'
    'Nwb25zZRJnCgpMaXN0QWxlcnRzEisuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnYxLkxpc3RBbGVy'
    'dHNSZXF1ZXN0GiwuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnYxLkxpc3RBbGVydHNSZXNwb25zZQ'
    '==');
