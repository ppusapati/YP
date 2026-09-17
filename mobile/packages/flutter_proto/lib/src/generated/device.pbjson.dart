// This is a generated file - do not edit.
//
// Generated from device.proto.

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

@$core.Deprecated('Use deviceStatusDescriptor instead')
const DeviceStatus$json = {
  '1': 'DeviceStatus',
  '2': [
    {'1': 'DEVICE_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'DEVICE_STATUS_PROVISIONED', '2': 1},
    {'1': 'DEVICE_STATUS_ONLINE', '2': 2},
    {'1': 'DEVICE_STATUS_OFFLINE', '2': 3},
    {'1': 'DEVICE_STATUS_DEGRADED', '2': 4},
    {'1': 'DEVICE_STATUS_RETIRED', '2': 5},
  ],
};

/// Descriptor for `DeviceStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List deviceStatusDescriptor = $convert.base64Decode(
    'CgxEZXZpY2VTdGF0dXMSHQoZREVWSUNFX1NUQVRVU19VTlNQRUNJRklFRBAAEh0KGURFVklDRV'
    '9TVEFUVVNfUFJPVklTSU9ORUQQARIYChRERVZJQ0VfU1RBVFVTX09OTElORRACEhkKFURFVklD'
    'RV9TVEFUVVNfT0ZGTElORRADEhoKFkRFVklDRV9TVEFUVVNfREVHUkFERUQQBBIZChVERVZJQ0'
    'VfU1RBVFVTX1JFVElSRUQQBQ==');

@$core.Deprecated('Use deviceKindDescriptor instead')
const DeviceKind$json = {
  '1': 'DeviceKind',
  '2': [
    {'1': 'DEVICE_KIND_UNSPECIFIED', '2': 0},
    {'1': 'DEVICE_KIND_SOIL_PROBE', '2': 1},
    {'1': 'DEVICE_KIND_WEATHER_STATION', '2': 2},
    {'1': 'DEVICE_KIND_IRRIGATION_VALVE', '2': 3},
    {'1': 'DEVICE_KIND_FLOW_METER', '2': 4},
    {'1': 'DEVICE_KIND_GATEWAY', '2': 5},
    {'1': 'DEVICE_KIND_TRACTOR_TELEMATICS', '2': 6},
  ],
};

/// Descriptor for `DeviceKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List deviceKindDescriptor = $convert.base64Decode(
    'CgpEZXZpY2VLaW5kEhsKF0RFVklDRV9LSU5EX1VOU1BFQ0lGSUVEEAASGgoWREVWSUNFX0tJTk'
    'RfU09JTF9QUk9CRRABEh8KG0RFVklDRV9LSU5EX1dFQVRIRVJfU1RBVElPThACEiAKHERFVklD'
    'RV9LSU5EX0lSUklHQVRJT05fVkFMVkUQAxIaChZERVZJQ0VfS0lORF9GTE9XX01FVEVSEAQSFw'
    'oTREVWSUNFX0tJTkRfR0FURVdBWRAFEiIKHkRFVklDRV9LSU5EX1RSQUNUT1JfVEVMRU1BVElD'
    'UxAG');

@$core.Deprecated('Use rolloutStateDescriptor instead')
const RolloutState$json = {
  '1': 'RolloutState',
  '2': [
    {'1': 'ROLLOUT_STATE_UNSPECIFIED', '2': 0},
    {'1': 'ROLLOUT_STATE_PENDING', '2': 1},
    {'1': 'ROLLOUT_STATE_IN_PROGRESS', '2': 2},
    {'1': 'ROLLOUT_STATE_PAUSED', '2': 3},
    {'1': 'ROLLOUT_STATE_COMPLETED', '2': 4},
    {'1': 'ROLLOUT_STATE_HALTED', '2': 5},
  ],
};

/// Descriptor for `RolloutState`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List rolloutStateDescriptor = $convert.base64Decode(
    'CgxSb2xsb3V0U3RhdGUSHQoZUk9MTE9VVF9TVEFURV9VTlNQRUNJRklFRBAAEhkKFVJPTExPVV'
    'RfU1RBVEVfUEVORElORxABEh0KGVJPTExPVVRfU1RBVEVfSU5fUFJPR1JFU1MQAhIYChRST0xM'
    'T1VUX1NUQVRFX1BBVVNFRBADEhsKF1JPTExPVVRfU1RBVEVfQ09NUExFVEVEEAQSGAoUUk9MTE'
    '9VVF9TVEFURV9IQUxURUQQBQ==');

@$core.Deprecated('Use updateStateDescriptor instead')
const UpdateState$json = {
  '1': 'UpdateState',
  '2': [
    {'1': 'UPDATE_STATE_UNSPECIFIED', '2': 0},
    {'1': 'UPDATE_STATE_OFFERED', '2': 1},
    {'1': 'UPDATE_STATE_DOWNLOADING', '2': 2},
    {'1': 'UPDATE_STATE_INSTALLING', '2': 3},
    {'1': 'UPDATE_STATE_SUCCEEDED', '2': 4},
    {'1': 'UPDATE_STATE_FAILED', '2': 5},
    {'1': 'UPDATE_STATE_ROLLED_BACK', '2': 6},
  ],
};

/// Descriptor for `UpdateState`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List updateStateDescriptor = $convert.base64Decode(
    'CgtVcGRhdGVTdGF0ZRIcChhVUERBVEVfU1RBVEVfVU5TUEVDSUZJRUQQABIYChRVUERBVEVfU1'
    'RBVEVfT0ZGRVJFRBABEhwKGFVQREFURV9TVEFURV9ET1dOTE9BRElORxACEhsKF1VQREFURV9T'
    'VEFURV9JTlNUQUxMSU5HEAMSGgoWVVBEQVRFX1NUQVRFX1NVQ0NFRURFRBAEEhcKE1VQREFURV'
    '9TVEFURV9GQUlMRUQQBRIcChhVUERBVEVfU1RBVEVfUk9MTEVEX0JBQ0sQBg==');

@$core.Deprecated('Use deviceDescriptor instead')
const Device$json = {
  '1': 'Device',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'serial', '3': 2, '4': 1, '5': 9, '10': 'serial'},
    {'1': 'name', '3': 3, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'kind',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.device.v1.DeviceKind',
      '10': 'kind'
    },
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.device.v1.DeviceStatus',
      '10': 'status'
    },
    {'1': 'farm_id', '3': 6, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 7, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'fleet', '3': 8, '4': 1, '5': 9, '10': 'fleet'},
    {'1': 'firmware_version', '3': 9, '4': 1, '5': 9, '10': 'firmwareVersion'},
    {
      '1': 'hardware_revision',
      '3': 10,
      '4': 1,
      '5': 9,
      '10': 'hardwareRevision'
    },
    {'1': 'latitude', '3': 11, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 12, '4': 1, '5': 1, '10': 'longitude'},
    {
      '1': 'provisioned_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'provisionedAt'
    },
    {
      '1': 'last_seen_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastSeenAt'
    },
    {'1': 'battery_percent', '3': 15, '4': 1, '5': 1, '10': 'batteryPercent'},
    {'1': 'signal_dbm', '3': 16, '4': 1, '5': 5, '10': 'signalDbm'},
    {'1': 'fault', '3': 17, '4': 1, '5': 9, '10': 'fault'},
  ],
};

/// Descriptor for `Device`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceDescriptor = $convert.base64Decode(
    'CgZEZXZpY2USDgoCaWQYASABKAlSAmlkEhYKBnNlcmlhbBgCIAEoCVIGc2VyaWFsEhIKBG5hbW'
    'UYAyABKAlSBG5hbWUSNQoEa2luZBgEIAEoDjIhLmFncmljdWx0dXJlLmRldmljZS52MS5EZXZp'
    'Y2VLaW5kUgRraW5kEjsKBnN0YXR1cxgFIAEoDjIjLmFncmljdWx0dXJlLmRldmljZS52MS5EZX'
    'ZpY2VTdGF0dXNSBnN0YXR1cxIXCgdmYXJtX2lkGAYgASgJUgZmYXJtSWQSGQoIZmllbGRfaWQY'
    'ByABKAlSB2ZpZWxkSWQSFAoFZmxlZXQYCCABKAlSBWZsZWV0EikKEGZpcm13YXJlX3ZlcnNpb2'
    '4YCSABKAlSD2Zpcm13YXJlVmVyc2lvbhIrChFoYXJkd2FyZV9yZXZpc2lvbhgKIAEoCVIQaGFy'
    'ZHdhcmVSZXZpc2lvbhIaCghsYXRpdHVkZRgLIAEoAVIIbGF0aXR1ZGUSHAoJbG9uZ2l0dWRlGA'
    'wgASgBUglsb25naXR1ZGUSQQoOcHJvdmlzaW9uZWRfYXQYDSABKAsyGi5nb29nbGUucHJvdG9i'
    'dWYuVGltZXN0YW1wUg1wcm92aXNpb25lZEF0EjwKDGxhc3Rfc2Vlbl9hdBgOIAEoCzIaLmdvb2'
    'dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCmxhc3RTZWVuQXQSJwoPYmF0dGVyeV9wZXJjZW50GA8g'
    'ASgBUg5iYXR0ZXJ5UGVyY2VudBIdCgpzaWduYWxfZGJtGBAgASgFUglzaWduYWxEYm0SFAoFZm'
    'F1bHQYESABKAlSBWZhdWx0');

@$core.Deprecated('Use heartbeatDescriptor instead')
const Heartbeat$json = {
  '1': 'Heartbeat',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'firmware_version', '3': 2, '4': 1, '5': 9, '10': 'firmwareVersion'},
    {'1': 'battery_percent', '3': 3, '4': 1, '5': 1, '10': 'batteryPercent'},
    {'1': 'signal_dbm', '3': 4, '4': 1, '5': 5, '10': 'signalDbm'},
    {'1': 'fault', '3': 5, '4': 1, '5': 9, '10': 'fault'},
    {
      '1': 'recorded_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'recordedAt'
    },
  ],
};

/// Descriptor for `Heartbeat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List heartbeatDescriptor = $convert.base64Decode(
    'CglIZWFydGJlYXQSGwoJZGV2aWNlX2lkGAEgASgJUghkZXZpY2VJZBIpChBmaXJtd2FyZV92ZX'
    'JzaW9uGAIgASgJUg9maXJtd2FyZVZlcnNpb24SJwoPYmF0dGVyeV9wZXJjZW50GAMgASgBUg5i'
    'YXR0ZXJ5UGVyY2VudBIdCgpzaWduYWxfZGJtGAQgASgFUglzaWduYWxEYm0SFAoFZmF1bHQYBS'
    'ABKAlSBWZhdWx0EjsKC3JlY29yZGVkX2F0GAYgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVz'
    'dGFtcFIKcmVjb3JkZWRBdA==');

@$core.Deprecated('Use fleetHealthDescriptor instead')
const FleetHealth$json = {
  '1': 'FleetHealth',
  '2': [
    {'1': 'fleet', '3': 1, '4': 1, '5': 9, '10': 'fleet'},
    {'1': 'total', '3': 2, '4': 1, '5': 5, '10': 'total'},
    {'1': 'online', '3': 3, '4': 1, '5': 5, '10': 'online'},
    {'1': 'offline', '3': 4, '4': 1, '5': 5, '10': 'offline'},
    {'1': 'degraded', '3': 5, '4': 1, '5': 5, '10': 'degraded'},
    {'1': 'provisioned', '3': 6, '4': 1, '5': 5, '10': 'provisioned'},
    {'1': 'low_battery', '3': 7, '4': 1, '5': 5, '10': 'lowBattery'},
    {
      '1': 'computed_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'computedAt'
    },
  ],
};

/// Descriptor for `FleetHealth`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fleetHealthDescriptor = $convert.base64Decode(
    'CgtGbGVldEhlYWx0aBIUCgVmbGVldBgBIAEoCVIFZmxlZXQSFAoFdG90YWwYAiABKAVSBXRvdG'
    'FsEhYKBm9ubGluZRgDIAEoBVIGb25saW5lEhgKB29mZmxpbmUYBCABKAVSB29mZmxpbmUSGgoI'
    'ZGVncmFkZWQYBSABKAVSCGRlZ3JhZGVkEiAKC3Byb3Zpc2lvbmVkGAYgASgFUgtwcm92aXNpb2'
    '5lZBIfCgtsb3dfYmF0dGVyeRgHIAEoBVIKbG93QmF0dGVyeRI7Cgtjb21wdXRlZF9hdBgIIAEo'
    'CzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCmNvbXB1dGVkQXQ=');

@$core.Deprecated('Use firmwareRolloutDescriptor instead')
const FirmwareRollout$json = {
  '1': 'FirmwareRollout',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'fleet', '3': 2, '4': 1, '5': 9, '10': 'fleet'},
    {
      '1': 'kind',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.device.v1.DeviceKind',
      '10': 'kind'
    },
    {'1': 'version', '3': 4, '4': 1, '5': 9, '10': 'version'},
    {'1': 'artifact_url', '3': 5, '4': 1, '5': 9, '10': 'artifactUrl'},
    {'1': 'artifact_sha256', '3': 6, '4': 1, '5': 9, '10': 'artifactSha256'},
    {
      '1': 'state',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.device.v1.RolloutState',
      '10': 'state'
    },
    {'1': 'stage_percent', '3': 8, '4': 1, '5': 5, '10': 'stagePercent'},
    {
      '1': 'failure_threshold',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'failureThreshold'
    },
    {'1': 'offered', '3': 10, '4': 1, '5': 5, '10': 'offered'},
    {'1': 'succeeded', '3': 11, '4': 1, '5': 5, '10': 'succeeded'},
    {'1': 'failed', '3': 12, '4': 1, '5': 5, '10': 'failed'},
    {
      '1': 'created_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {'1': 'halted_reason', '3': 14, '4': 1, '5': 9, '10': 'haltedReason'},
  ],
};

/// Descriptor for `FirmwareRollout`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List firmwareRolloutDescriptor = $convert.base64Decode(
    'Cg9GaXJtd2FyZVJvbGxvdXQSDgoCaWQYASABKAlSAmlkEhQKBWZsZWV0GAIgASgJUgVmbGVldB'
    'I1CgRraW5kGAMgASgOMiEuYWdyaWN1bHR1cmUuZGV2aWNlLnYxLkRldmljZUtpbmRSBGtpbmQS'
    'GAoHdmVyc2lvbhgEIAEoCVIHdmVyc2lvbhIhCgxhcnRpZmFjdF91cmwYBSABKAlSC2FydGlmYW'
    'N0VXJsEicKD2FydGlmYWN0X3NoYTI1NhgGIAEoCVIOYXJ0aWZhY3RTaGEyNTYSOQoFc3RhdGUY'
    'ByABKA4yIy5hZ3JpY3VsdHVyZS5kZXZpY2UudjEuUm9sbG91dFN0YXRlUgVzdGF0ZRIjCg1zdG'
    'FnZV9wZXJjZW50GAggASgFUgxzdGFnZVBlcmNlbnQSKwoRZmFpbHVyZV90aHJlc2hvbGQYCSAB'
    'KAFSEGZhaWx1cmVUaHJlc2hvbGQSGAoHb2ZmZXJlZBgKIAEoBVIHb2ZmZXJlZBIcCglzdWNjZW'
    'VkZWQYCyABKAVSCXN1Y2NlZWRlZBIWCgZmYWlsZWQYDCABKAVSBmZhaWxlZBI5CgpjcmVhdGVk'
    'X2F0GA0gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EiMKDWhhbH'
    'RlZF9yZWFzb24YDiABKAlSDGhhbHRlZFJlYXNvbg==');

@$core.Deprecated('Use deviceUpdateDescriptor instead')
const DeviceUpdate$json = {
  '1': 'DeviceUpdate',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'rollout_id', '3': 2, '4': 1, '5': 9, '10': 'rolloutId'},
    {
      '1': 'state',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.device.v1.UpdateState',
      '10': 'state'
    },
    {'1': 'detail', '3': 4, '4': 1, '5': 9, '10': 'detail'},
    {
      '1': 'updated_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `DeviceUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceUpdateDescriptor = $convert.base64Decode(
    'CgxEZXZpY2VVcGRhdGUSGwoJZGV2aWNlX2lkGAEgASgJUghkZXZpY2VJZBIdCgpyb2xsb3V0X2'
    'lkGAIgASgJUglyb2xsb3V0SWQSOAoFc3RhdGUYAyABKA4yIi5hZ3JpY3VsdHVyZS5kZXZpY2Uu'
    'djEuVXBkYXRlU3RhdGVSBXN0YXRlEhYKBmRldGFpbBgEIAEoCVIGZGV0YWlsEjkKCnVwZGF0ZW'
    'RfYXQYBSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQ=');

@$core.Deprecated('Use provisionDeviceRequestDescriptor instead')
const ProvisionDeviceRequest$json = {
  '1': 'ProvisionDeviceRequest',
  '2': [
    {'1': 'serial', '3': 1, '4': 1, '5': 9, '10': 'serial'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'kind',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.device.v1.DeviceKind',
      '10': 'kind'
    },
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 5, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'fleet', '3': 6, '4': 1, '5': 9, '10': 'fleet'},
    {
      '1': 'hardware_revision',
      '3': 7,
      '4': 1,
      '5': 9,
      '10': 'hardwareRevision'
    },
    {'1': 'latitude', '3': 8, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 9, '4': 1, '5': 1, '10': 'longitude'},
  ],
};

/// Descriptor for `ProvisionDeviceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List provisionDeviceRequestDescriptor = $convert.base64Decode(
    'ChZQcm92aXNpb25EZXZpY2VSZXF1ZXN0EhYKBnNlcmlhbBgBIAEoCVIGc2VyaWFsEhIKBG5hbW'
    'UYAiABKAlSBG5hbWUSNQoEa2luZBgDIAEoDjIhLmFncmljdWx0dXJlLmRldmljZS52MS5EZXZp'
    'Y2VLaW5kUgRraW5kEhcKB2Zhcm1faWQYBCABKAlSBmZhcm1JZBIZCghmaWVsZF9pZBgFIAEoCV'
    'IHZmllbGRJZBIUCgVmbGVldBgGIAEoCVIFZmxlZXQSKwoRaGFyZHdhcmVfcmV2aXNpb24YByAB'
    'KAlSEGhhcmR3YXJlUmV2aXNpb24SGgoIbGF0aXR1ZGUYCCABKAFSCGxhdGl0dWRlEhwKCWxvbm'
    'dpdHVkZRgJIAEoAVIJbG9uZ2l0dWRl');

@$core.Deprecated('Use provisionDeviceResponseDescriptor instead')
const ProvisionDeviceResponse$json = {
  '1': 'ProvisionDeviceResponse',
  '2': [
    {
      '1': 'device',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.device.v1.Device',
      '10': 'device'
    },
    {'1': 'enrolment_token', '3': 2, '4': 1, '5': 9, '10': 'enrolmentToken'},
  ],
};

/// Descriptor for `ProvisionDeviceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List provisionDeviceResponseDescriptor = $convert.base64Decode(
    'ChdQcm92aXNpb25EZXZpY2VSZXNwb25zZRI1CgZkZXZpY2UYASABKAsyHS5hZ3JpY3VsdHVyZS'
    '5kZXZpY2UudjEuRGV2aWNlUgZkZXZpY2USJwoPZW5yb2xtZW50X3Rva2VuGAIgASgJUg5lbnJv'
    'bG1lbnRUb2tlbg==');

@$core.Deprecated('Use getDeviceRequestDescriptor instead')
const GetDeviceRequest$json = {
  '1': 'GetDeviceRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetDeviceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDeviceRequestDescriptor =
    $convert.base64Decode('ChBHZXREZXZpY2VSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use getDeviceResponseDescriptor instead')
const GetDeviceResponse$json = {
  '1': 'GetDeviceResponse',
  '2': [
    {
      '1': 'device',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.device.v1.Device',
      '10': 'device'
    },
  ],
};

/// Descriptor for `GetDeviceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDeviceResponseDescriptor = $convert.base64Decode(
    'ChFHZXREZXZpY2VSZXNwb25zZRI1CgZkZXZpY2UYASABKAsyHS5hZ3JpY3VsdHVyZS5kZXZpY2'
    'UudjEuRGV2aWNlUgZkZXZpY2U=');

@$core.Deprecated('Use listDevicesRequestDescriptor instead')
const ListDevicesRequest$json = {
  '1': 'ListDevicesRequest',
  '2': [
    {'1': 'fleet', '3': 1, '4': 1, '5': 9, '10': 'fleet'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'kind',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.device.v1.DeviceKind',
      '10': 'kind'
    },
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.device.v1.DeviceStatus',
      '10': 'status'
    },
    {'1': 'page_size', '3': 6, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 7, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListDevicesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDevicesRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0RGV2aWNlc1JlcXVlc3QSFAoFZmxlZXQYASABKAlSBWZsZWV0EhcKB2Zhcm1faWQYAi'
    'ABKAlSBmZhcm1JZBIZCghmaWVsZF9pZBgDIAEoCVIHZmllbGRJZBI1CgRraW5kGAQgASgOMiEu'
    'YWdyaWN1bHR1cmUuZGV2aWNlLnYxLkRldmljZUtpbmRSBGtpbmQSOwoGc3RhdHVzGAUgASgOMi'
    'MuYWdyaWN1bHR1cmUuZGV2aWNlLnYxLkRldmljZVN0YXR1c1IGc3RhdHVzEhsKCXBhZ2Vfc2l6'
    'ZRgGIAEoBVIIcGFnZVNpemUSHQoKcGFnZV90b2tlbhgHIAEoCVIJcGFnZVRva2Vu');

@$core.Deprecated('Use listDevicesResponseDescriptor instead')
const ListDevicesResponse$json = {
  '1': 'ListDevicesResponse',
  '2': [
    {
      '1': 'devices',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.device.v1.Device',
      '10': 'devices'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListDevicesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDevicesResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0RGV2aWNlc1Jlc3BvbnNlEjcKB2RldmljZXMYASADKAsyHS5hZ3JpY3VsdHVyZS5kZX'
    'ZpY2UudjEuRGV2aWNlUgdkZXZpY2VzEiYKD25leHRfcGFnZV90b2tlbhgCIAEoCVINbmV4dFBh'
    'Z2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use recordHeartbeatsRequestDescriptor instead')
const RecordHeartbeatsRequest$json = {
  '1': 'RecordHeartbeatsRequest',
  '2': [
    {
      '1': 'heartbeats',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.device.v1.Heartbeat',
      '10': 'heartbeats'
    },
  ],
};

/// Descriptor for `RecordHeartbeatsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recordHeartbeatsRequestDescriptor =
    $convert.base64Decode(
        'ChdSZWNvcmRIZWFydGJlYXRzUmVxdWVzdBJACgpoZWFydGJlYXRzGAEgAygLMiAuYWdyaWN1bH'
        'R1cmUuZGV2aWNlLnYxLkhlYXJ0YmVhdFIKaGVhcnRiZWF0cw==');

@$core.Deprecated('Use recordHeartbeatsResponseDescriptor instead')
const RecordHeartbeatsResponse$json = {
  '1': 'RecordHeartbeatsResponse',
  '2': [
    {'1': 'recorded', '3': 1, '4': 1, '5': 5, '10': 'recorded'},
    {'1': 'rejected', '3': 2, '4': 3, '5': 9, '10': 'rejected'},
  ],
};

/// Descriptor for `RecordHeartbeatsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recordHeartbeatsResponseDescriptor =
    $convert.base64Decode(
        'ChhSZWNvcmRIZWFydGJlYXRzUmVzcG9uc2USGgoIcmVjb3JkZWQYASABKAVSCHJlY29yZGVkEh'
        'oKCHJlamVjdGVkGAIgAygJUghyZWplY3RlZA==');

@$core.Deprecated('Use retireDeviceRequestDescriptor instead')
const RetireDeviceRequest$json = {
  '1': 'RetireDeviceRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `RetireDeviceRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List retireDeviceRequestDescriptor = $convert.base64Decode(
    'ChNSZXRpcmVEZXZpY2VSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIWCgZyZWFzb24YAiABKAlSBn'
    'JlYXNvbg==');

@$core.Deprecated('Use retireDeviceResponseDescriptor instead')
const RetireDeviceResponse$json = {
  '1': 'RetireDeviceResponse',
  '2': [
    {
      '1': 'device',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.device.v1.Device',
      '10': 'device'
    },
  ],
};

/// Descriptor for `RetireDeviceResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List retireDeviceResponseDescriptor = $convert.base64Decode(
    'ChRSZXRpcmVEZXZpY2VSZXNwb25zZRI1CgZkZXZpY2UYASABKAsyHS5hZ3JpY3VsdHVyZS5kZX'
    'ZpY2UudjEuRGV2aWNlUgZkZXZpY2U=');

@$core.Deprecated('Use getFleetHealthRequestDescriptor instead')
const GetFleetHealthRequest$json = {
  '1': 'GetFleetHealthRequest',
  '2': [
    {'1': 'fleet', '3': 1, '4': 1, '5': 9, '10': 'fleet'},
  ],
};

/// Descriptor for `GetFleetHealthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFleetHealthRequestDescriptor =
    $convert.base64Decode(
        'ChVHZXRGbGVldEhlYWx0aFJlcXVlc3QSFAoFZmxlZXQYASABKAlSBWZsZWV0');

@$core.Deprecated('Use getFleetHealthResponseDescriptor instead')
const GetFleetHealthResponse$json = {
  '1': 'GetFleetHealthResponse',
  '2': [
    {
      '1': 'health',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.device.v1.FleetHealth',
      '10': 'health'
    },
  ],
};

/// Descriptor for `GetFleetHealthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFleetHealthResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRGbGVldEhlYWx0aFJlc3BvbnNlEjoKBmhlYWx0aBgBIAEoCzIiLmFncmljdWx0dXJlLm'
        'RldmljZS52MS5GbGVldEhlYWx0aFIGaGVhbHRo');

@$core.Deprecated('Use createRolloutRequestDescriptor instead')
const CreateRolloutRequest$json = {
  '1': 'CreateRolloutRequest',
  '2': [
    {'1': 'fleet', '3': 1, '4': 1, '5': 9, '10': 'fleet'},
    {
      '1': 'kind',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.device.v1.DeviceKind',
      '10': 'kind'
    },
    {'1': 'version', '3': 3, '4': 1, '5': 9, '10': 'version'},
    {'1': 'artifact_url', '3': 4, '4': 1, '5': 9, '10': 'artifactUrl'},
    {'1': 'artifact_sha256', '3': 5, '4': 1, '5': 9, '10': 'artifactSha256'},
    {'1': 'stage_percent', '3': 6, '4': 1, '5': 5, '10': 'stagePercent'},
    {
      '1': 'failure_threshold',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'failureThreshold'
    },
  ],
};

/// Descriptor for `CreateRolloutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createRolloutRequestDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVSb2xsb3V0UmVxdWVzdBIUCgVmbGVldBgBIAEoCVIFZmxlZXQSNQoEa2luZBgCIA'
    'EoDjIhLmFncmljdWx0dXJlLmRldmljZS52MS5EZXZpY2VLaW5kUgRraW5kEhgKB3ZlcnNpb24Y'
    'AyABKAlSB3ZlcnNpb24SIQoMYXJ0aWZhY3RfdXJsGAQgASgJUgthcnRpZmFjdFVybBInCg9hcn'
    'RpZmFjdF9zaGEyNTYYBSABKAlSDmFydGlmYWN0U2hhMjU2EiMKDXN0YWdlX3BlcmNlbnQYBiAB'
    'KAVSDHN0YWdlUGVyY2VudBIrChFmYWlsdXJlX3RocmVzaG9sZBgHIAEoAVIQZmFpbHVyZVRocm'
    'VzaG9sZA==');

@$core.Deprecated('Use createRolloutResponseDescriptor instead')
const CreateRolloutResponse$json = {
  '1': 'CreateRolloutResponse',
  '2': [
    {
      '1': 'rollout',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.device.v1.FirmwareRollout',
      '10': 'rollout'
    },
  ],
};

/// Descriptor for `CreateRolloutResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createRolloutResponseDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVSb2xsb3V0UmVzcG9uc2USQAoHcm9sbG91dBgBIAEoCzImLmFncmljdWx0dXJlLm'
    'RldmljZS52MS5GaXJtd2FyZVJvbGxvdXRSB3JvbGxvdXQ=');

@$core.Deprecated('Use advanceRolloutRequestDescriptor instead')
const AdvanceRolloutRequest$json = {
  '1': 'AdvanceRolloutRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'stage_percent', '3': 2, '4': 1, '5': 5, '10': 'stagePercent'},
  ],
};

/// Descriptor for `AdvanceRolloutRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List advanceRolloutRequestDescriptor = $convert.base64Decode(
    'ChVBZHZhbmNlUm9sbG91dFJlcXVlc3QSDgoCaWQYASABKAlSAmlkEiMKDXN0YWdlX3BlcmNlbn'
    'QYAiABKAVSDHN0YWdlUGVyY2VudA==');

@$core.Deprecated('Use advanceRolloutResponseDescriptor instead')
const AdvanceRolloutResponse$json = {
  '1': 'AdvanceRolloutResponse',
  '2': [
    {
      '1': 'rollout',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.device.v1.FirmwareRollout',
      '10': 'rollout'
    },
  ],
};

/// Descriptor for `AdvanceRolloutResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List advanceRolloutResponseDescriptor =
    $convert.base64Decode(
        'ChZBZHZhbmNlUm9sbG91dFJlc3BvbnNlEkAKB3JvbGxvdXQYASABKAsyJi5hZ3JpY3VsdHVyZS'
        '5kZXZpY2UudjEuRmlybXdhcmVSb2xsb3V0Ugdyb2xsb3V0');

@$core.Deprecated('Use reportUpdateRequestDescriptor instead')
const ReportUpdateRequest$json = {
  '1': 'ReportUpdateRequest',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'rollout_id', '3': 2, '4': 1, '5': 9, '10': 'rolloutId'},
    {
      '1': 'state',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.device.v1.UpdateState',
      '10': 'state'
    },
    {'1': 'detail', '3': 4, '4': 1, '5': 9, '10': 'detail'},
  ],
};

/// Descriptor for `ReportUpdateRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reportUpdateRequestDescriptor = $convert.base64Decode(
    'ChNSZXBvcnRVcGRhdGVSZXF1ZXN0EhsKCWRldmljZV9pZBgBIAEoCVIIZGV2aWNlSWQSHQoKcm'
    '9sbG91dF9pZBgCIAEoCVIJcm9sbG91dElkEjgKBXN0YXRlGAMgASgOMiIuYWdyaWN1bHR1cmUu'
    'ZGV2aWNlLnYxLlVwZGF0ZVN0YXRlUgVzdGF0ZRIWCgZkZXRhaWwYBCABKAlSBmRldGFpbA==');

@$core.Deprecated('Use reportUpdateResponseDescriptor instead')
const ReportUpdateResponse$json = {
  '1': 'ReportUpdateResponse',
  '2': [
    {
      '1': 'update',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.device.v1.DeviceUpdate',
      '10': 'update'
    },
    {
      '1': 'rollout',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.agriculture.device.v1.FirmwareRollout',
      '10': 'rollout'
    },
  ],
};

/// Descriptor for `ReportUpdateResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reportUpdateResponseDescriptor = $convert.base64Decode(
    'ChRSZXBvcnRVcGRhdGVSZXNwb25zZRI7CgZ1cGRhdGUYASABKAsyIy5hZ3JpY3VsdHVyZS5kZX'
    'ZpY2UudjEuRGV2aWNlVXBkYXRlUgZ1cGRhdGUSQAoHcm9sbG91dBgCIAEoCzImLmFncmljdWx0'
    'dXJlLmRldmljZS52MS5GaXJtd2FyZVJvbGxvdXRSB3JvbGxvdXQ=');

@$core.Deprecated('Use listRolloutsRequestDescriptor instead')
const ListRolloutsRequest$json = {
  '1': 'ListRolloutsRequest',
  '2': [
    {'1': 'fleet', '3': 1, '4': 1, '5': 9, '10': 'fleet'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 3, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListRolloutsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRolloutsRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0Um9sbG91dHNSZXF1ZXN0EhQKBWZsZWV0GAEgASgJUgVmbGVldBIbCglwYWdlX3Npem'
    'UYAiABKAVSCHBhZ2VTaXplEh0KCnBhZ2VfdG9rZW4YAyABKAlSCXBhZ2VUb2tlbg==');

@$core.Deprecated('Use listRolloutsResponseDescriptor instead')
const ListRolloutsResponse$json = {
  '1': 'ListRolloutsResponse',
  '2': [
    {
      '1': 'rollouts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.device.v1.FirmwareRollout',
      '10': 'rollouts'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListRolloutsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRolloutsResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0Um9sbG91dHNSZXNwb25zZRJCCghyb2xsb3V0cxgBIAMoCzImLmFncmljdWx0dXJlLm'
    'RldmljZS52MS5GaXJtd2FyZVJvbGxvdXRSCHJvbGxvdXRzEiYKD25leHRfcGFnZV90b2tlbhgC'
    'IAEoCVINbmV4dFBhZ2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3VudA==');

const $core.Map<$core.String, $core.dynamic> DeviceServiceBase$json = {
  '1': 'DeviceService',
  '2': [
    {
      '1': 'ProvisionDevice',
      '2': '.agriculture.device.v1.ProvisionDeviceRequest',
      '3': '.agriculture.device.v1.ProvisionDeviceResponse'
    },
    {
      '1': 'GetDevice',
      '2': '.agriculture.device.v1.GetDeviceRequest',
      '3': '.agriculture.device.v1.GetDeviceResponse'
    },
    {
      '1': 'ListDevices',
      '2': '.agriculture.device.v1.ListDevicesRequest',
      '3': '.agriculture.device.v1.ListDevicesResponse'
    },
    {
      '1': 'RecordHeartbeats',
      '2': '.agriculture.device.v1.RecordHeartbeatsRequest',
      '3': '.agriculture.device.v1.RecordHeartbeatsResponse'
    },
    {
      '1': 'RetireDevice',
      '2': '.agriculture.device.v1.RetireDeviceRequest',
      '3': '.agriculture.device.v1.RetireDeviceResponse'
    },
    {
      '1': 'GetFleetHealth',
      '2': '.agriculture.device.v1.GetFleetHealthRequest',
      '3': '.agriculture.device.v1.GetFleetHealthResponse'
    },
    {
      '1': 'CreateRollout',
      '2': '.agriculture.device.v1.CreateRolloutRequest',
      '3': '.agriculture.device.v1.CreateRolloutResponse'
    },
    {
      '1': 'AdvanceRollout',
      '2': '.agriculture.device.v1.AdvanceRolloutRequest',
      '3': '.agriculture.device.v1.AdvanceRolloutResponse'
    },
    {
      '1': 'ReportUpdate',
      '2': '.agriculture.device.v1.ReportUpdateRequest',
      '3': '.agriculture.device.v1.ReportUpdateResponse'
    },
    {
      '1': 'ListRollouts',
      '2': '.agriculture.device.v1.ListRolloutsRequest',
      '3': '.agriculture.device.v1.ListRolloutsResponse'
    },
  ],
};

@$core.Deprecated('Use deviceServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    DeviceServiceBase$messageJson = {
  '.agriculture.device.v1.ProvisionDeviceRequest': ProvisionDeviceRequest$json,
  '.agriculture.device.v1.ProvisionDeviceResponse':
      ProvisionDeviceResponse$json,
  '.agriculture.device.v1.Device': Device$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.device.v1.GetDeviceRequest': GetDeviceRequest$json,
  '.agriculture.device.v1.GetDeviceResponse': GetDeviceResponse$json,
  '.agriculture.device.v1.ListDevicesRequest': ListDevicesRequest$json,
  '.agriculture.device.v1.ListDevicesResponse': ListDevicesResponse$json,
  '.agriculture.device.v1.RecordHeartbeatsRequest':
      RecordHeartbeatsRequest$json,
  '.agriculture.device.v1.Heartbeat': Heartbeat$json,
  '.agriculture.device.v1.RecordHeartbeatsResponse':
      RecordHeartbeatsResponse$json,
  '.agriculture.device.v1.RetireDeviceRequest': RetireDeviceRequest$json,
  '.agriculture.device.v1.RetireDeviceResponse': RetireDeviceResponse$json,
  '.agriculture.device.v1.GetFleetHealthRequest': GetFleetHealthRequest$json,
  '.agriculture.device.v1.GetFleetHealthResponse': GetFleetHealthResponse$json,
  '.agriculture.device.v1.FleetHealth': FleetHealth$json,
  '.agriculture.device.v1.CreateRolloutRequest': CreateRolloutRequest$json,
  '.agriculture.device.v1.CreateRolloutResponse': CreateRolloutResponse$json,
  '.agriculture.device.v1.FirmwareRollout': FirmwareRollout$json,
  '.agriculture.device.v1.AdvanceRolloutRequest': AdvanceRolloutRequest$json,
  '.agriculture.device.v1.AdvanceRolloutResponse': AdvanceRolloutResponse$json,
  '.agriculture.device.v1.ReportUpdateRequest': ReportUpdateRequest$json,
  '.agriculture.device.v1.ReportUpdateResponse': ReportUpdateResponse$json,
  '.agriculture.device.v1.DeviceUpdate': DeviceUpdate$json,
  '.agriculture.device.v1.ListRolloutsRequest': ListRolloutsRequest$json,
  '.agriculture.device.v1.ListRolloutsResponse': ListRolloutsResponse$json,
};

/// Descriptor for `DeviceService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List deviceServiceDescriptor = $convert.base64Decode(
    'Cg1EZXZpY2VTZXJ2aWNlEnAKD1Byb3Zpc2lvbkRldmljZRItLmFncmljdWx0dXJlLmRldmljZS'
    '52MS5Qcm92aXNpb25EZXZpY2VSZXF1ZXN0Gi4uYWdyaWN1bHR1cmUuZGV2aWNlLnYxLlByb3Zp'
    'c2lvbkRldmljZVJlc3BvbnNlEl4KCUdldERldmljZRInLmFncmljdWx0dXJlLmRldmljZS52MS'
    '5HZXREZXZpY2VSZXF1ZXN0GiguYWdyaWN1bHR1cmUuZGV2aWNlLnYxLkdldERldmljZVJlc3Bv'
    'bnNlEmQKC0xpc3REZXZpY2VzEikuYWdyaWN1bHR1cmUuZGV2aWNlLnYxLkxpc3REZXZpY2VzUm'
    'VxdWVzdBoqLmFncmljdWx0dXJlLmRldmljZS52MS5MaXN0RGV2aWNlc1Jlc3BvbnNlEnMKEFJl'
    'Y29yZEhlYXJ0YmVhdHMSLi5hZ3JpY3VsdHVyZS5kZXZpY2UudjEuUmVjb3JkSGVhcnRiZWF0c1'
    'JlcXVlc3QaLy5hZ3JpY3VsdHVyZS5kZXZpY2UudjEuUmVjb3JkSGVhcnRiZWF0c1Jlc3BvbnNl'
    'EmcKDFJldGlyZURldmljZRIqLmFncmljdWx0dXJlLmRldmljZS52MS5SZXRpcmVEZXZpY2VSZX'
    'F1ZXN0GisuYWdyaWN1bHR1cmUuZGV2aWNlLnYxLlJldGlyZURldmljZVJlc3BvbnNlEm0KDkdl'
    'dEZsZWV0SGVhbHRoEiwuYWdyaWN1bHR1cmUuZGV2aWNlLnYxLkdldEZsZWV0SGVhbHRoUmVxdW'
    'VzdBotLmFncmljdWx0dXJlLmRldmljZS52MS5HZXRGbGVldEhlYWx0aFJlc3BvbnNlEmoKDUNy'
    'ZWF0ZVJvbGxvdXQSKy5hZ3JpY3VsdHVyZS5kZXZpY2UudjEuQ3JlYXRlUm9sbG91dFJlcXVlc3'
    'QaLC5hZ3JpY3VsdHVyZS5kZXZpY2UudjEuQ3JlYXRlUm9sbG91dFJlc3BvbnNlEm0KDkFkdmFu'
    'Y2VSb2xsb3V0EiwuYWdyaWN1bHR1cmUuZGV2aWNlLnYxLkFkdmFuY2VSb2xsb3V0UmVxdWVzdB'
    'otLmFncmljdWx0dXJlLmRldmljZS52MS5BZHZhbmNlUm9sbG91dFJlc3BvbnNlEmcKDFJlcG9y'
    'dFVwZGF0ZRIqLmFncmljdWx0dXJlLmRldmljZS52MS5SZXBvcnRVcGRhdGVSZXF1ZXN0GisuYW'
    'dyaWN1bHR1cmUuZGV2aWNlLnYxLlJlcG9ydFVwZGF0ZVJlc3BvbnNlEmcKDExpc3RSb2xsb3V0'
    'cxIqLmFncmljdWx0dXJlLmRldmljZS52MS5MaXN0Um9sbG91dHNSZXF1ZXN0GisuYWdyaWN1bH'
    'R1cmUuZGV2aWNlLnYxLkxpc3RSb2xsb3V0c1Jlc3BvbnNl');
