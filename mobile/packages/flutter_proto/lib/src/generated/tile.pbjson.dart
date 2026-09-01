// This is a generated file - do not edit.
//
// Generated from tile.proto.

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

@$core.Deprecated('Use tileFormatDescriptor instead')
const TileFormat$json = {
  '1': 'TileFormat',
  '2': [
    {'1': 'TILE_FORMAT_UNSPECIFIED', '2': 0},
    {'1': 'TILE_FORMAT_PNG', '2': 1},
    {'1': 'TILE_FORMAT_JPEG', '2': 2},
    {'1': 'TILE_FORMAT_WEBP', '2': 3},
    {'1': 'TILE_FORMAT_MVT', '2': 4},
  ],
};

/// Descriptor for `TileFormat`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List tileFormatDescriptor = $convert.base64Decode(
    'CgpUaWxlRm9ybWF0EhsKF1RJTEVfRk9STUFUX1VOU1BFQ0lGSUVEEAASEwoPVElMRV9GT1JNQV'
    'RfUE5HEAESFAoQVElMRV9GT1JNQVRfSlBFRxACEhQKEFRJTEVfRk9STUFUX1dFQlAQAxITCg9U'
    'SUxFX0ZPUk1BVF9NVlQQBA==');

@$core.Deprecated('Use tilesetStatusDescriptor instead')
const TilesetStatus$json = {
  '1': 'TilesetStatus',
  '2': [
    {'1': 'TILESET_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'TILESET_STATUS_QUEUED', '2': 1},
    {'1': 'TILESET_STATUS_GENERATING', '2': 2},
    {'1': 'TILESET_STATUS_COMPLETED', '2': 3},
    {'1': 'TILESET_STATUS_FAILED', '2': 4},
  ],
};

/// Descriptor for `TilesetStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List tilesetStatusDescriptor = $convert.base64Decode(
    'Cg1UaWxlc2V0U3RhdHVzEh4KGlRJTEVTRVRfU1RBVFVTX1VOU1BFQ0lGSUVEEAASGQoVVElMRV'
    'NFVF9TVEFUVVNfUVVFVUVEEAESHQoZVElMRVNFVF9TVEFUVVNfR0VORVJBVElORxACEhwKGFRJ'
    'TEVTRVRfU1RBVFVTX0NPTVBMRVRFRBADEhkKFVRJTEVTRVRfU1RBVFVTX0ZBSUxFRBAE');

@$core.Deprecated('Use tileLayerDescriptor instead')
const TileLayer$json = {
  '1': 'TileLayer',
  '2': [
    {'1': 'TILE_LAYER_UNSPECIFIED', '2': 0},
    {'1': 'TILE_LAYER_RGB', '2': 1},
    {'1': 'TILE_LAYER_NDVI', '2': 2},
    {'1': 'TILE_LAYER_NDWI', '2': 3},
    {'1': 'TILE_LAYER_EVI', '2': 4},
    {'1': 'TILE_LAYER_STRESS', '2': 5},
    {'1': 'TILE_LAYER_FALSE_COLOR', '2': 6},
    {'1': 'TILE_LAYER_THERMAL', '2': 7},
  ],
};

/// Descriptor for `TileLayer`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List tileLayerDescriptor = $convert.base64Decode(
    'CglUaWxlTGF5ZXISGgoWVElMRV9MQVlFUl9VTlNQRUNJRklFRBAAEhIKDlRJTEVfTEFZRVJfUk'
    'dCEAESEwoPVElMRV9MQVlFUl9ORFZJEAISEwoPVElMRV9MQVlFUl9ORFdJEAMSEgoOVElMRV9M'
    'QVlFUl9FVkkQBBIVChFUSUxFX0xBWUVSX1NUUkVTUxAFEhoKFlRJTEVfTEFZRVJfRkFMU0VfQ0'
    '9MT1IQBhIWChJUSUxFX0xBWUVSX1RIRVJNQUwQBw==');

@$core.Deprecated('Use tilesetDescriptor instead')
const Tileset$json = {
  '1': 'Tileset',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'processing_job_id', '3': 4, '4': 1, '5': 9, '10': 'processingJobId'},
    {
      '1': 'layer',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.tile.v1.TileLayer',
      '10': 'layer'
    },
    {
      '1': 'format',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.tile.v1.TileFormat',
      '10': 'format'
    },
    {
      '1': 'status',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.tile.v1.TilesetStatus',
      '10': 'status'
    },
    {'1': 'min_zoom', '3': 8, '4': 1, '5': 5, '10': 'minZoom'},
    {'1': 'max_zoom', '3': 9, '4': 1, '5': 5, '10': 'maxZoom'},
    {'1': 's3_prefix', '3': 10, '4': 1, '5': 9, '10': 's3Prefix'},
    {'1': 'total_tiles', '3': 11, '4': 1, '5': 3, '10': 'totalTiles'},
    {'1': 'bbox_geojson', '3': 12, '4': 1, '5': 9, '10': 'bboxGeojson'},
    {'1': 'error_message', '3': 13, '4': 1, '5': 9, '10': 'errorMessage'},
    {
      '1': 'acquisition_date',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'acquisitionDate'
    },
    {
      '1': 'created_at',
      '3': 15,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'completed_at',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'completedAt'
    },
  ],
};

/// Descriptor for `Tileset`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tilesetDescriptor = $convert.base64Decode(
    'CgdUaWxlc2V0Eg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbmFudElkEh'
    'cKB2Zhcm1faWQYAyABKAlSBmZhcm1JZBIqChFwcm9jZXNzaW5nX2pvYl9pZBgEIAEoCVIPcHJv'
    'Y2Vzc2luZ0pvYklkEj4KBWxheWVyGAUgASgOMiguYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnRpbG'
    'UudjEuVGlsZUxheWVyUgVsYXllchJBCgZmb3JtYXQYBiABKA4yKS5hZ3JpY3VsdHVyZS5zYXRl'
    'bGxpdGUudGlsZS52MS5UaWxlRm9ybWF0UgZmb3JtYXQSRAoGc3RhdHVzGAcgASgOMiwuYWdyaW'
    'N1bHR1cmUuc2F0ZWxsaXRlLnRpbGUudjEuVGlsZXNldFN0YXR1c1IGc3RhdHVzEhkKCG1pbl96'
    'b29tGAggASgFUgdtaW5ab29tEhkKCG1heF96b29tGAkgASgFUgdtYXhab29tEhsKCXMzX3ByZW'
    'ZpeBgKIAEoCVIIczNQcmVmaXgSHwoLdG90YWxfdGlsZXMYCyABKANSCnRvdGFsVGlsZXMSIQoM'
    'YmJveF9nZW9qc29uGAwgASgJUgtiYm94R2VvanNvbhIjCg1lcnJvcl9tZXNzYWdlGA0gASgJUg'
    'xlcnJvck1lc3NhZ2USRQoQYWNxdWlzaXRpb25fZGF0ZRgOIAEoCzIaLmdvb2dsZS5wcm90b2J1'
    'Zi5UaW1lc3RhbXBSD2FjcXVpc2l0aW9uRGF0ZRI5CgpjcmVhdGVkX2F0GA8gASgLMhouZ29vZ2'
    'xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0Ej0KDGNvbXBsZXRlZF9hdBgQIAEoCzIa'
    'Lmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSC2NvbXBsZXRlZEF0');

@$core.Deprecated('Use generateTilesetRequestDescriptor instead')
const GenerateTilesetRequest$json = {
  '1': 'GenerateTilesetRequest',
  '2': [
    {'1': 'processing_job_id', '3': 1, '4': 1, '5': 9, '10': 'processingJobId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'layer',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.tile.v1.TileLayer',
      '10': 'layer'
    },
    {
      '1': 'format',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.tile.v1.TileFormat',
      '10': 'format'
    },
    {'1': 'min_zoom', '3': 5, '4': 1, '5': 5, '10': 'minZoom'},
    {'1': 'max_zoom', '3': 6, '4': 1, '5': 5, '10': 'maxZoom'},
  ],
};

/// Descriptor for `GenerateTilesetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateTilesetRequestDescriptor = $convert.base64Decode(
    'ChZHZW5lcmF0ZVRpbGVzZXRSZXF1ZXN0EioKEXByb2Nlc3Npbmdfam9iX2lkGAEgASgJUg9wcm'
    '9jZXNzaW5nSm9iSWQSFwoHZmFybV9pZBgCIAEoCVIGZmFybUlkEj4KBWxheWVyGAMgASgOMigu'
    'YWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnRpbGUudjEuVGlsZUxheWVyUgVsYXllchJBCgZmb3JtYX'
    'QYBCABKA4yKS5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUudGlsZS52MS5UaWxlRm9ybWF0UgZmb3Jt'
    'YXQSGQoIbWluX3pvb20YBSABKAVSB21pblpvb20SGQoIbWF4X3pvb20YBiABKAVSB21heFpvb2'
    '0=');

@$core.Deprecated('Use generateTilesetResponseDescriptor instead')
const GenerateTilesetResponse$json = {
  '1': 'GenerateTilesetResponse',
  '2': [
    {
      '1': 'tileset',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.tile.v1.Tileset',
      '10': 'tileset'
    },
  ],
};

/// Descriptor for `GenerateTilesetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateTilesetResponseDescriptor =
    $convert.base64Decode(
        'ChdHZW5lcmF0ZVRpbGVzZXRSZXNwb25zZRJACgd0aWxlc2V0GAEgASgLMiYuYWdyaWN1bHR1cm'
        'Uuc2F0ZWxsaXRlLnRpbGUudjEuVGlsZXNldFIHdGlsZXNldA==');

@$core.Deprecated('Use getTilesetRequestDescriptor instead')
const GetTilesetRequest$json = {
  '1': 'GetTilesetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetTilesetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTilesetRequestDescriptor =
    $convert.base64Decode('ChFHZXRUaWxlc2V0UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use getTilesetResponseDescriptor instead')
const GetTilesetResponse$json = {
  '1': 'GetTilesetResponse',
  '2': [
    {
      '1': 'tileset',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.satellite.tile.v1.Tileset',
      '10': 'tileset'
    },
  ],
};

/// Descriptor for `GetTilesetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTilesetResponseDescriptor = $convert.base64Decode(
    'ChJHZXRUaWxlc2V0UmVzcG9uc2USQAoHdGlsZXNldBgBIAEoCzImLmFncmljdWx0dXJlLnNhdG'
    'VsbGl0ZS50aWxlLnYxLlRpbGVzZXRSB3RpbGVzZXQ=');

@$core.Deprecated('Use listTilesetsRequestDescriptor instead')
const ListTilesetsRequest$json = {
  '1': 'ListTilesetsRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'layer',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.tile.v1.TileLayer',
      '10': 'layer'
    },
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.satellite.tile.v1.TilesetStatus',
      '10': 'status'
    },
  ],
};

/// Descriptor for `ListTilesetsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTilesetsRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0VGlsZXNldHNSZXF1ZXN0EhsKCXBhZ2Vfc2l6ZRgBIAEoBVIIcGFnZVNpemUSHQoKcG'
    'FnZV90b2tlbhgCIAEoCVIJcGFnZVRva2VuEhcKB2Zhcm1faWQYAyABKAlSBmZhcm1JZBI+CgVs'
    'YXllchgEIAEoDjIoLmFncmljdWx0dXJlLnNhdGVsbGl0ZS50aWxlLnYxLlRpbGVMYXllclIFbG'
    'F5ZXISRAoGc3RhdHVzGAUgASgOMiwuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnRpbGUudjEuVGls'
    'ZXNldFN0YXR1c1IGc3RhdHVz');

@$core.Deprecated('Use listTilesetsResponseDescriptor instead')
const ListTilesetsResponse$json = {
  '1': 'ListTilesetsResponse',
  '2': [
    {
      '1': 'tilesets',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.satellite.tile.v1.Tileset',
      '10': 'tilesets'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListTilesetsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTilesetsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0VGlsZXNldHNSZXNwb25zZRJCCgh0aWxlc2V0cxgBIAMoCzImLmFncmljdWx0dXJlLn'
    'NhdGVsbGl0ZS50aWxlLnYxLlRpbGVzZXRSCHRpbGVzZXRzEiYKD25leHRfcGFnZV90b2tlbhgC'
    'IAEoCVINbmV4dFBhZ2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use getTileRequestDescriptor instead')
const GetTileRequest$json = {
  '1': 'GetTileRequest',
  '2': [
    {'1': 'tileset_id', '3': 1, '4': 1, '5': 9, '10': 'tilesetId'},
    {'1': 'z', '3': 2, '4': 1, '5': 5, '10': 'z'},
    {'1': 'x', '3': 3, '4': 1, '5': 5, '10': 'x'},
    {'1': 'y', '3': 4, '4': 1, '5': 5, '10': 'y'},
  ],
};

/// Descriptor for `GetTileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTileRequestDescriptor = $convert.base64Decode(
    'Cg5HZXRUaWxlUmVxdWVzdBIdCgp0aWxlc2V0X2lkGAEgASgJUgl0aWxlc2V0SWQSDAoBehgCIA'
    'EoBVIBehIMCgF4GAMgASgFUgF4EgwKAXkYBCABKAVSAXk=');

@$core.Deprecated('Use getTileResponseDescriptor instead')
const GetTileResponse$json = {
  '1': 'GetTileResponse',
  '2': [
    {'1': 'tile_data', '3': 1, '4': 1, '5': 12, '10': 'tileData'},
    {'1': 'content_type', '3': 2, '4': 1, '5': 9, '10': 'contentType'},
  ],
};

/// Descriptor for `GetTileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTileResponseDescriptor = $convert.base64Decode(
    'Cg9HZXRUaWxlUmVzcG9uc2USGwoJdGlsZV9kYXRhGAEgASgMUgh0aWxlRGF0YRIhCgxjb250ZW'
    '50X3R5cGUYAiABKAlSC2NvbnRlbnRUeXBl');

@$core.Deprecated('Use deleteTilesetRequestDescriptor instead')
const DeleteTilesetRequest$json = {
  '1': 'DeleteTilesetRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteTilesetRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteTilesetRequestDescriptor = $convert
    .base64Decode('ChREZWxldGVUaWxlc2V0UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use deleteTilesetResponseDescriptor instead')
const DeleteTilesetResponse$json = {
  '1': 'DeleteTilesetResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `DeleteTilesetResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteTilesetResponseDescriptor =
    $convert.base64Decode(
        'ChVEZWxldGVUaWxlc2V0UmVzcG9uc2USGAoHc3VjY2VzcxgBIAEoCFIHc3VjY2Vzcw==');

const $core.Map<$core.String, $core.dynamic> SatelliteTileServiceBase$json = {
  '1': 'SatelliteTileService',
  '2': [
    {
      '1': 'GenerateTileset',
      '2': '.agriculture.satellite.tile.v1.GenerateTilesetRequest',
      '3': '.agriculture.satellite.tile.v1.GenerateTilesetResponse'
    },
    {
      '1': 'GetTileset',
      '2': '.agriculture.satellite.tile.v1.GetTilesetRequest',
      '3': '.agriculture.satellite.tile.v1.GetTilesetResponse'
    },
    {
      '1': 'ListTilesets',
      '2': '.agriculture.satellite.tile.v1.ListTilesetsRequest',
      '3': '.agriculture.satellite.tile.v1.ListTilesetsResponse'
    },
    {
      '1': 'GetTile',
      '2': '.agriculture.satellite.tile.v1.GetTileRequest',
      '3': '.agriculture.satellite.tile.v1.GetTileResponse'
    },
    {
      '1': 'DeleteTileset',
      '2': '.agriculture.satellite.tile.v1.DeleteTilesetRequest',
      '3': '.agriculture.satellite.tile.v1.DeleteTilesetResponse'
    },
  ],
};

@$core.Deprecated('Use satelliteTileServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    SatelliteTileServiceBase$messageJson = {
  '.agriculture.satellite.tile.v1.GenerateTilesetRequest':
      GenerateTilesetRequest$json,
  '.agriculture.satellite.tile.v1.GenerateTilesetResponse':
      GenerateTilesetResponse$json,
  '.agriculture.satellite.tile.v1.Tileset': Tileset$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.satellite.tile.v1.GetTilesetRequest': GetTilesetRequest$json,
  '.agriculture.satellite.tile.v1.GetTilesetResponse': GetTilesetResponse$json,
  '.agriculture.satellite.tile.v1.ListTilesetsRequest':
      ListTilesetsRequest$json,
  '.agriculture.satellite.tile.v1.ListTilesetsResponse':
      ListTilesetsResponse$json,
  '.agriculture.satellite.tile.v1.GetTileRequest': GetTileRequest$json,
  '.agriculture.satellite.tile.v1.GetTileResponse': GetTileResponse$json,
  '.agriculture.satellite.tile.v1.DeleteTilesetRequest':
      DeleteTilesetRequest$json,
  '.agriculture.satellite.tile.v1.DeleteTilesetResponse':
      DeleteTilesetResponse$json,
};

/// Descriptor for `SatelliteTileService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List satelliteTileServiceDescriptor = $convert.base64Decode(
    'ChRTYXRlbGxpdGVUaWxlU2VydmljZRKAAQoPR2VuZXJhdGVUaWxlc2V0EjUuYWdyaWN1bHR1cm'
    'Uuc2F0ZWxsaXRlLnRpbGUudjEuR2VuZXJhdGVUaWxlc2V0UmVxdWVzdBo2LmFncmljdWx0dXJl'
    'LnNhdGVsbGl0ZS50aWxlLnYxLkdlbmVyYXRlVGlsZXNldFJlc3BvbnNlEnEKCkdldFRpbGVzZX'
    'QSMC5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUudGlsZS52MS5HZXRUaWxlc2V0UmVxdWVzdBoxLmFn'
    'cmljdWx0dXJlLnNhdGVsbGl0ZS50aWxlLnYxLkdldFRpbGVzZXRSZXNwb25zZRJ3CgxMaXN0VG'
    'lsZXNldHMSMi5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUudGlsZS52MS5MaXN0VGlsZXNldHNSZXF1'
    'ZXN0GjMuYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnRpbGUudjEuTGlzdFRpbGVzZXRzUmVzcG9uc2'
    'USaAoHR2V0VGlsZRItLmFncmljdWx0dXJlLnNhdGVsbGl0ZS50aWxlLnYxLkdldFRpbGVSZXF1'
    'ZXN0Gi4uYWdyaWN1bHR1cmUuc2F0ZWxsaXRlLnRpbGUudjEuR2V0VGlsZVJlc3BvbnNlEnoKDU'
    'RlbGV0ZVRpbGVzZXQSMy5hZ3JpY3VsdHVyZS5zYXRlbGxpdGUudGlsZS52MS5EZWxldGVUaWxl'
    'c2V0UmVxdWVzdBo0LmFncmljdWx0dXJlLnNhdGVsbGl0ZS50aWxlLnYxLkRlbGV0ZVRpbGVzZX'
    'RSZXNwb25zZQ==');
