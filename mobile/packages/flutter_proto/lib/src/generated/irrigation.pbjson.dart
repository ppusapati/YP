// This is a generated file - do not edit.
//
// Generated from irrigation.proto.

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

@$core.Deprecated('Use scheduleTypeDescriptor instead')
const ScheduleType$json = {
  '1': 'ScheduleType',
  '2': [
    {'1': 'SCHEDULE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SCHEDULE_TYPE_FIXED', '2': 1},
    {'1': 'SCHEDULE_TYPE_ADAPTIVE', '2': 2},
    {'1': 'SCHEDULE_TYPE_AI_DRIVEN', '2': 3},
  ],
};

/// Descriptor for `ScheduleType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List scheduleTypeDescriptor = $convert.base64Decode(
    'CgxTY2hlZHVsZVR5cGUSHQoZU0NIRURVTEVfVFlQRV9VTlNQRUNJRklFRBAAEhcKE1NDSEVEVU'
    'xFX1RZUEVfRklYRUQQARIaChZTQ0hFRFVMRV9UWVBFX0FEQVBUSVZFEAISGwoXU0NIRURVTEVf'
    'VFlQRV9BSV9EUklWRU4QAw==');

@$core.Deprecated('Use frequencyDescriptor instead')
const Frequency$json = {
  '1': 'Frequency',
  '2': [
    {'1': 'FREQUENCY_UNSPECIFIED', '2': 0},
    {'1': 'FREQUENCY_DAILY', '2': 1},
    {'1': 'FREQUENCY_EVERY_OTHER_DAY', '2': 2},
    {'1': 'FREQUENCY_WEEKLY', '2': 3},
    {'1': 'FREQUENCY_CUSTOM', '2': 4},
  ],
};

/// Descriptor for `Frequency`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List frequencyDescriptor = $convert.base64Decode(
    'CglGcmVxdWVuY3kSGQoVRlJFUVVFTkNZX1VOU1BFQ0lGSUVEEAASEwoPRlJFUVVFTkNZX0RBSU'
    'xZEAESHQoZRlJFUVVFTkNZX0VWRVJZX09USEVSX0RBWRACEhQKEEZSRVFVRU5DWV9XRUVLTFkQ'
    'AxIUChBGUkVRVUVOQ1lfQ1VTVE9NEAQ=');

@$core.Deprecated('Use controllerTypeDescriptor instead')
const ControllerType$json = {
  '1': 'ControllerType',
  '2': [
    {'1': 'CONTROLLER_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'CONTROLLER_TYPE_DRIP', '2': 1},
    {'1': 'CONTROLLER_TYPE_VALVE', '2': 2},
    {'1': 'CONTROLLER_TYPE_PUMP', '2': 3},
    {'1': 'CONTROLLER_TYPE_SPRINKLER', '2': 4},
  ],
};

/// Descriptor for `ControllerType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List controllerTypeDescriptor = $convert.base64Decode(
    'Cg5Db250cm9sbGVyVHlwZRIfChtDT05UUk9MTEVSX1RZUEVfVU5TUEVDSUZJRUQQABIYChRDT0'
    '5UUk9MTEVSX1RZUEVfRFJJUBABEhkKFUNPTlRST0xMRVJfVFlQRV9WQUxWRRACEhgKFENPTlRS'
    'T0xMRVJfVFlQRV9QVU1QEAMSHQoZQ09OVFJPTExFUl9UWVBFX1NQUklOS0xFUhAE');

@$core.Deprecated('Use protocolDescriptor instead')
const Protocol$json = {
  '1': 'Protocol',
  '2': [
    {'1': 'PROTOCOL_UNSPECIFIED', '2': 0},
    {'1': 'PROTOCOL_MQTT', '2': 1},
    {'1': 'PROTOCOL_LORAWAN', '2': 2},
    {'1': 'PROTOCOL_MODBUS', '2': 3},
  ],
};

/// Descriptor for `Protocol`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List protocolDescriptor = $convert.base64Decode(
    'CghQcm90b2NvbBIYChRQUk9UT0NPTF9VTlNQRUNJRklFRBAAEhEKDVBST1RPQ09MX01RVFQQAR'
    'IUChBQUk9UT0NPTF9MT1JBV0FOEAISEwoPUFJPVE9DT0xfTU9EQlVTEAM=');

@$core.Deprecated('Use controllerStatusDescriptor instead')
const ControllerStatus$json = {
  '1': 'ControllerStatus',
  '2': [
    {'1': 'CONTROLLER_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'CONTROLLER_STATUS_ONLINE', '2': 1},
    {'1': 'CONTROLLER_STATUS_OFFLINE', '2': 2},
    {'1': 'CONTROLLER_STATUS_ERROR', '2': 3},
  ],
};

/// Descriptor for `ControllerStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List controllerStatusDescriptor = $convert.base64Decode(
    'ChBDb250cm9sbGVyU3RhdHVzEiEKHUNPTlRST0xMRVJfU1RBVFVTX1VOU1BFQ0lGSUVEEAASHA'
    'oYQ09OVFJPTExFUl9TVEFUVVNfT05MSU5FEAESHQoZQ09OVFJPTExFUl9TVEFUVVNfT0ZGTElO'
    'RRACEhsKF0NPTlRST0xMRVJfU1RBVFVTX0VSUk9SEAM=');

@$core.Deprecated('Use irrigationStatusDescriptor instead')
const IrrigationStatus$json = {
  '1': 'IrrigationStatus',
  '2': [
    {'1': 'IRRIGATION_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'IRRIGATION_STATUS_SCHEDULED', '2': 1},
    {'1': 'IRRIGATION_STATUS_ACTIVE', '2': 2},
    {'1': 'IRRIGATION_STATUS_COMPLETED', '2': 3},
    {'1': 'IRRIGATION_STATUS_CANCELLED', '2': 4},
    {'1': 'IRRIGATION_STATUS_FAILED', '2': 5},
  ],
};

/// Descriptor for `IrrigationStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List irrigationStatusDescriptor = $convert.base64Decode(
    'ChBJcnJpZ2F0aW9uU3RhdHVzEiEKHUlSUklHQVRJT05fU1RBVFVTX1VOU1BFQ0lGSUVEEAASHw'
    'obSVJSSUdBVElPTl9TVEFUVVNfU0NIRURVTEVEEAESHAoYSVJSSUdBVElPTl9TVEFUVVNfQUNU'
    'SVZFEAISHwobSVJSSUdBVElPTl9TVEFUVVNfQ09NUExFVEVEEAMSHwobSVJSSUdBVElPTl9TVE'
    'FUVVNfQ0FOQ0VMTEVEEAQSHAoYSVJSSUdBVElPTl9TVEFUVVNfRkFJTEVEEAU=');

@$core.Deprecated('Use irrigationScheduleDescriptor instead')
const IrrigationSchedule$json = {
  '1': 'IrrigationSchedule',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'zone_id', '3': 5, '4': 1, '5': 9, '10': 'zoneId'},
    {
      '1': 'schedule_type',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.irrigation.v1.ScheduleType',
      '10': 'scheduleType'
    },
    {
      '1': 'start_time',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startTime'
    },
    {
      '1': 'end_time',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'endTime'
    },
    {'1': 'duration_minutes', '3': 9, '4': 1, '5': 5, '10': 'durationMinutes'},
    {
      '1': 'water_quantity_liters',
      '3': 10,
      '4': 1,
      '5': 1,
      '10': 'waterQuantityLiters'
    },
    {
      '1': 'flow_rate_liters_per_hour',
      '3': 11,
      '4': 1,
      '5': 1,
      '10': 'flowRateLitersPerHour'
    },
    {
      '1': 'frequency',
      '3': 12,
      '4': 1,
      '5': 14,
      '6': '.agriculture.irrigation.v1.Frequency',
      '10': 'frequency'
    },
    {
      '1': 'soil_moisture_threshold_pct',
      '3': 13,
      '4': 1,
      '5': 1,
      '10': 'soilMoistureThresholdPct'
    },
    {'1': 'weather_adjusted', '3': 14, '4': 1, '5': 8, '10': 'weatherAdjusted'},
    {
      '1': 'crop_growth_stage',
      '3': 15,
      '4': 1,
      '5': 9,
      '10': 'cropGrowthStage'
    },
    {'1': 'controller_id', '3': 16, '4': 1, '5': 9, '10': 'controllerId'},
    {
      '1': 'status',
      '3': 17,
      '4': 1,
      '5': 14,
      '6': '.agriculture.irrigation.v1.IrrigationStatus',
      '10': 'status'
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
    {'1': 'version', '3': 20, '4': 1, '5': 3, '10': 'version'},
    {'1': 'created_by', '3': 21, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'name', '3': 22, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 23, '4': 1, '5': 9, '10': 'description'},
  ],
};

/// Descriptor for `IrrigationSchedule`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List irrigationScheduleDescriptor = $convert.base64Decode(
    'ChJJcnJpZ2F0aW9uU2NoZWR1bGUSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCV'
    'IIdGVuYW50SWQSGQoIZmllbGRfaWQYAyABKAlSB2ZpZWxkSWQSFwoHZmFybV9pZBgEIAEoCVIG'
    'ZmFybUlkEhcKB3pvbmVfaWQYBSABKAlSBnpvbmVJZBJMCg1zY2hlZHVsZV90eXBlGAYgASgOMi'
    'cuYWdyaWN1bHR1cmUuaXJyaWdhdGlvbi52MS5TY2hlZHVsZVR5cGVSDHNjaGVkdWxlVHlwZRI5'
    'CgpzdGFydF90aW1lGAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJc3RhcnRUaW'
    '1lEjUKCGVuZF90aW1lGAggASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIHZW5kVGlt'
    'ZRIpChBkdXJhdGlvbl9taW51dGVzGAkgASgFUg9kdXJhdGlvbk1pbnV0ZXMSMgoVd2F0ZXJfcX'
    'VhbnRpdHlfbGl0ZXJzGAogASgBUhN3YXRlclF1YW50aXR5TGl0ZXJzEjgKGWZsb3dfcmF0ZV9s'
    'aXRlcnNfcGVyX2hvdXIYCyABKAFSFWZsb3dSYXRlTGl0ZXJzUGVySG91chJCCglmcmVxdWVuY3'
    'kYDCABKA4yJC5hZ3JpY3VsdHVyZS5pcnJpZ2F0aW9uLnYxLkZyZXF1ZW5jeVIJZnJlcXVlbmN5'
    'Ej0KG3NvaWxfbW9pc3R1cmVfdGhyZXNob2xkX3BjdBgNIAEoAVIYc29pbE1vaXN0dXJlVGhyZX'
    'Nob2xkUGN0EikKEHdlYXRoZXJfYWRqdXN0ZWQYDiABKAhSD3dlYXRoZXJBZGp1c3RlZBIqChFj'
    'cm9wX2dyb3d0aF9zdGFnZRgPIAEoCVIPY3JvcEdyb3d0aFN0YWdlEiMKDWNvbnRyb2xsZXJfaW'
    'QYECABKAlSDGNvbnRyb2xsZXJJZBJDCgZzdGF0dXMYESABKA4yKy5hZ3JpY3VsdHVyZS5pcnJp'
    'Z2F0aW9uLnYxLklycmlnYXRpb25TdGF0dXNSBnN0YXR1cxI5CgpjcmVhdGVkX2F0GBIgASgLMh'
    'ouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYEyAB'
    'KAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQSGAoHdmVyc2lvbhgUIA'
    'EoA1IHdmVyc2lvbhIdCgpjcmVhdGVkX2J5GBUgASgJUgljcmVhdGVkQnkSEgoEbmFtZRgWIAEo'
    'CVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgXIAEoCVILZGVzY3JpcHRpb24=');

@$core.Deprecated('Use irrigationZoneDescriptor instead')
const IrrigationZone$json = {
  '1': 'IrrigationZone',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'name', '3': 5, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {'1': 'area_hectares', '3': 7, '4': 1, '5': 1, '10': 'areaHectares'},
    {'1': 'soil_type', '3': 8, '4': 1, '5': 9, '10': 'soilType'},
    {'1': 'crop_type', '3': 9, '4': 1, '5': 9, '10': 'cropType'},
    {
      '1': 'crop_growth_stage',
      '3': 10,
      '4': 1,
      '5': 9,
      '10': 'cropGrowthStage'
    },
    {'1': 'latitude', '3': 11, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 12, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'is_active', '3': 13, '4': 1, '5': 8, '10': 'isActive'},
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

/// Descriptor for `IrrigationZone`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List irrigationZoneDescriptor = $convert.base64Decode(
    'Cg5JcnJpZ2F0aW9uWm9uZRIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW'
    '5hbnRJZBIZCghmaWVsZF9pZBgDIAEoCVIHZmllbGRJZBIXCgdmYXJtX2lkGAQgASgJUgZmYXJt'
    'SWQSEgoEbmFtZRgFIAEoCVIEbmFtZRIgCgtkZXNjcmlwdGlvbhgGIAEoCVILZGVzY3JpcHRpb2'
    '4SIwoNYXJlYV9oZWN0YXJlcxgHIAEoAVIMYXJlYUhlY3RhcmVzEhsKCXNvaWxfdHlwZRgIIAEo'
    'CVIIc29pbFR5cGUSGwoJY3JvcF90eXBlGAkgASgJUghjcm9wVHlwZRIqChFjcm9wX2dyb3d0aF'
    '9zdGFnZRgKIAEoCVIPY3JvcEdyb3d0aFN0YWdlEhoKCGxhdGl0dWRlGAsgASgBUghsYXRpdHVk'
    'ZRIcCglsb25naXR1ZGUYDCABKAFSCWxvbmdpdHVkZRIbCglpc19hY3RpdmUYDSABKAhSCGlzQW'
    'N0aXZlEjkKCmNyZWF0ZWRfYXQYDiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUglj'
    'cmVhdGVkQXQSOQoKdXBkYXRlZF9hdBgPIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbX'
    'BSCXVwZGF0ZWRBdA==');

@$core.Deprecated('Use waterControllerDescriptor instead')
const WaterController$json = {
  '1': 'WaterController',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'zone_id', '3': 3, '4': 1, '5': 9, '10': 'zoneId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 5, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'name', '3': 6, '4': 1, '5': 9, '10': 'name'},
    {'1': 'model', '3': 7, '4': 1, '5': 9, '10': 'model'},
    {'1': 'firmware_version', '3': 8, '4': 1, '5': 9, '10': 'firmwareVersion'},
    {
      '1': 'controller_type',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.agriculture.irrigation.v1.ControllerType',
      '10': 'controllerType'
    },
    {
      '1': 'protocol',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.agriculture.irrigation.v1.Protocol',
      '10': 'protocol'
    },
    {
      '1': 'status',
      '3': 11,
      '4': 1,
      '5': 14,
      '6': '.agriculture.irrigation.v1.ControllerStatus',
      '10': 'status'
    },
    {'1': 'endpoint', '3': 12, '4': 1, '5': 9, '10': 'endpoint'},
    {
      '1': 'max_flow_rate_liters_per_hour',
      '3': 13,
      '4': 1,
      '5': 1,
      '10': 'maxFlowRateLitersPerHour'
    },
    {
      '1': 'last_heartbeat',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastHeartbeat'
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
      '1': 'updated_at',
      '3': 16,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
};

/// Descriptor for `WaterController`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List waterControllerDescriptor = $convert.base64Decode(
    'Cg9XYXRlckNvbnRyb2xsZXISDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdG'
    'VuYW50SWQSFwoHem9uZV9pZBgDIAEoCVIGem9uZUlkEhkKCGZpZWxkX2lkGAQgASgJUgdmaWVs'
    'ZElkEhcKB2Zhcm1faWQYBSABKAlSBmZhcm1JZBISCgRuYW1lGAYgASgJUgRuYW1lEhQKBW1vZG'
    'VsGAcgASgJUgVtb2RlbBIpChBmaXJtd2FyZV92ZXJzaW9uGAggASgJUg9maXJtd2FyZVZlcnNp'
    'b24SUgoPY29udHJvbGxlcl90eXBlGAkgASgOMikuYWdyaWN1bHR1cmUuaXJyaWdhdGlvbi52MS'
    '5Db250cm9sbGVyVHlwZVIOY29udHJvbGxlclR5cGUSPwoIcHJvdG9jb2wYCiABKA4yIy5hZ3Jp'
    'Y3VsdHVyZS5pcnJpZ2F0aW9uLnYxLlByb3RvY29sUghwcm90b2NvbBJDCgZzdGF0dXMYCyABKA'
    '4yKy5hZ3JpY3VsdHVyZS5pcnJpZ2F0aW9uLnYxLkNvbnRyb2xsZXJTdGF0dXNSBnN0YXR1cxIa'
    'CghlbmRwb2ludBgMIAEoCVIIZW5kcG9pbnQSPwodbWF4X2Zsb3dfcmF0ZV9saXRlcnNfcGVyX2'
    'hvdXIYDSABKAFSGG1heEZsb3dSYXRlTGl0ZXJzUGVySG91chJBCg5sYXN0X2hlYXJ0YmVhdBgO'
    'IAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSDWxhc3RIZWFydGJlYXQSOQoKY3JlYX'
    'RlZF9hdBgPIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1'
    'cGRhdGVkX2F0GBAgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZEF0');

@$core.Deprecated('Use irrigationEventDescriptor instead')
const IrrigationEvent$json = {
  '1': 'IrrigationEvent',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'schedule_id', '3': 3, '4': 1, '5': 9, '10': 'scheduleId'},
    {'1': 'zone_id', '3': 4, '4': 1, '5': 9, '10': 'zoneId'},
    {'1': 'controller_id', '3': 5, '4': 1, '5': 9, '10': 'controllerId'},
    {
      '1': 'status',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.irrigation.v1.IrrigationStatus',
      '10': 'status'
    },
    {
      '1': 'started_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startedAt'
    },
    {
      '1': 'ended_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'endedAt'
    },
    {
      '1': 'actual_duration_minutes',
      '3': 9,
      '4': 1,
      '5': 5,
      '10': 'actualDurationMinutes'
    },
    {
      '1': 'actual_water_liters',
      '3': 10,
      '4': 1,
      '5': 1,
      '10': 'actualWaterLiters'
    },
    {
      '1': 'soil_moisture_before_pct',
      '3': 11,
      '4': 1,
      '5': 1,
      '10': 'soilMoistureBeforePct'
    },
    {
      '1': 'soil_moisture_after_pct',
      '3': 12,
      '4': 1,
      '5': 1,
      '10': 'soilMoistureAfterPct'
    },
    {'1': 'failure_reason', '3': 13, '4': 1, '5': 9, '10': 'failureReason'},
    {
      '1': 'created_at',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `IrrigationEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List irrigationEventDescriptor = $convert.base64Decode(
    'Cg9JcnJpZ2F0aW9uRXZlbnQSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdG'
    'VuYW50SWQSHwoLc2NoZWR1bGVfaWQYAyABKAlSCnNjaGVkdWxlSWQSFwoHem9uZV9pZBgEIAEo'
    'CVIGem9uZUlkEiMKDWNvbnRyb2xsZXJfaWQYBSABKAlSDGNvbnRyb2xsZXJJZBJDCgZzdGF0dX'
    'MYBiABKA4yKy5hZ3JpY3VsdHVyZS5pcnJpZ2F0aW9uLnYxLklycmlnYXRpb25TdGF0dXNSBnN0'
    'YXR1cxI5CgpzdGFydGVkX2F0GAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJc3'
    'RhcnRlZEF0EjUKCGVuZGVkX2F0GAggASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIH'
    'ZW5kZWRBdBI2ChdhY3R1YWxfZHVyYXRpb25fbWludXRlcxgJIAEoBVIVYWN0dWFsRHVyYXRpb2'
    '5NaW51dGVzEi4KE2FjdHVhbF93YXRlcl9saXRlcnMYCiABKAFSEWFjdHVhbFdhdGVyTGl0ZXJz'
    'EjcKGHNvaWxfbW9pc3R1cmVfYmVmb3JlX3BjdBgLIAEoAVIVc29pbE1vaXN0dXJlQmVmb3JlUG'
    'N0EjUKF3NvaWxfbW9pc3R1cmVfYWZ0ZXJfcGN0GAwgASgBUhRzb2lsTW9pc3R1cmVBZnRlclBj'
    'dBIlCg5mYWlsdXJlX3JlYXNvbhgNIAEoCVINZmFpbHVyZVJlYXNvbhI5CgpjcmVhdGVkX2F0GA'
    '4gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use decisionInputsDescriptor instead')
const DecisionInputs$json = {
  '1': 'DecisionInputs',
  '2': [
    {'1': 'soil_moisture', '3': 1, '4': 1, '5': 1, '10': 'soilMoisture'},
    {'1': 'temperature', '3': 2, '4': 1, '5': 1, '10': 'temperature'},
    {'1': 'humidity', '3': 3, '4': 1, '5': 1, '10': 'humidity'},
    {
      '1': 'rainfall_forecast_mm',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'rainfallForecastMm'
    },
    {'1': 'wind_speed', '3': 5, '4': 1, '5': 1, '10': 'windSpeed'},
    {'1': 'crop_type', '3': 6, '4': 1, '5': 9, '10': 'cropType'},
    {'1': 'growth_stage', '3': 7, '4': 1, '5': 9, '10': 'growthStage'},
    {
      '1': 'evapotranspiration_mm',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'evapotranspirationMm'
    },
  ],
};

/// Descriptor for `DecisionInputs`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decisionInputsDescriptor = $convert.base64Decode(
    'Cg5EZWNpc2lvbklucHV0cxIjCg1zb2lsX21vaXN0dXJlGAEgASgBUgxzb2lsTW9pc3R1cmUSIA'
    'oLdGVtcGVyYXR1cmUYAiABKAFSC3RlbXBlcmF0dXJlEhoKCGh1bWlkaXR5GAMgASgBUghodW1p'
    'ZGl0eRIwChRyYWluZmFsbF9mb3JlY2FzdF9tbRgEIAEoAVIScmFpbmZhbGxGb3JlY2FzdE1tEh'
    '0KCndpbmRfc3BlZWQYBSABKAFSCXdpbmRTcGVlZBIbCgljcm9wX3R5cGUYBiABKAlSCGNyb3BU'
    'eXBlEiEKDGdyb3d0aF9zdGFnZRgHIAEoCVILZ3Jvd3RoU3RhZ2USMwoVZXZhcG90cmFuc3Bpcm'
    'F0aW9uX21tGAggASgBUhRldmFwb3RyYW5zcGlyYXRpb25NbQ==');

@$core.Deprecated('Use decisionOutputDescriptor instead')
const DecisionOutput$json = {
  '1': 'DecisionOutput',
  '2': [
    {'1': 'should_irrigate', '3': 1, '4': 1, '5': 8, '10': 'shouldIrrigate'},
    {
      '1': 'water_quantity_liters',
      '3': 2,
      '4': 1,
      '5': 1,
      '10': 'waterQuantityLiters'
    },
    {'1': 'duration_minutes', '3': 3, '4': 1, '5': 5, '10': 'durationMinutes'},
    {
      '1': 'optimal_time',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'optimalTime'
    },
    {'1': 'reasoning', '3': 5, '4': 1, '5': 9, '10': 'reasoning'},
    {'1': 'confidence_score', '3': 6, '4': 1, '5': 1, '10': 'confidenceScore'},
  ],
};

/// Descriptor for `DecisionOutput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decisionOutputDescriptor = $convert.base64Decode(
    'Cg5EZWNpc2lvbk91dHB1dBInCg9zaG91bGRfaXJyaWdhdGUYASABKAhSDnNob3VsZElycmlnYX'
    'RlEjIKFXdhdGVyX3F1YW50aXR5X2xpdGVycxgCIAEoAVITd2F0ZXJRdWFudGl0eUxpdGVycxIp'
    'ChBkdXJhdGlvbl9taW51dGVzGAMgASgFUg9kdXJhdGlvbk1pbnV0ZXMSPQoMb3B0aW1hbF90aW'
    '1lGAQgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFILb3B0aW1hbFRpbWUSHAoJcmVh'
    'c29uaW5nGAUgASgJUglyZWFzb25pbmcSKQoQY29uZmlkZW5jZV9zY29yZRgGIAEoAVIPY29uZm'
    'lkZW5jZVNjb3Jl');

@$core.Deprecated('Use irrigationDecisionDescriptor instead')
const IrrigationDecision$json = {
  '1': 'IrrigationDecision',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'zone_id', '3': 3, '4': 1, '5': 9, '10': 'zoneId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'schedule_id', '3': 5, '4': 1, '5': 9, '10': 'scheduleId'},
    {
      '1': 'inputs',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.DecisionInputs',
      '10': 'inputs'
    },
    {
      '1': 'output',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.DecisionOutput',
      '10': 'output'
    },
    {
      '1': 'decided_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'decidedAt'
    },
    {'1': 'applied', '3': 9, '4': 1, '5': 8, '10': 'applied'},
    {
      '1': 'created_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `IrrigationDecision`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List irrigationDecisionDescriptor = $convert.base64Decode(
    'ChJJcnJpZ2F0aW9uRGVjaXNpb24SDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCV'
    'IIdGVuYW50SWQSFwoHem9uZV9pZBgDIAEoCVIGem9uZUlkEhkKCGZpZWxkX2lkGAQgASgJUgdm'
    'aWVsZElkEh8KC3NjaGVkdWxlX2lkGAUgASgJUgpzY2hlZHVsZUlkEkEKBmlucHV0cxgGIAEoCz'
    'IpLmFncmljdWx0dXJlLmlycmlnYXRpb24udjEuRGVjaXNpb25JbnB1dHNSBmlucHV0cxJBCgZv'
    'dXRwdXQYByABKAsyKS5hZ3JpY3VsdHVyZS5pcnJpZ2F0aW9uLnYxLkRlY2lzaW9uT3V0cHV0Ug'
    'ZvdXRwdXQSOQoKZGVjaWRlZF9hdBgIIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBS'
    'CWRlY2lkZWRBdBIYCgdhcHBsaWVkGAkgASgIUgdhcHBsaWVkEjkKCmNyZWF0ZWRfYXQYCiABKA'
    'syGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use waterUsageLogDescriptor instead')
const WaterUsageLog$json = {
  '1': 'WaterUsageLog',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'zone_id', '3': 3, '4': 1, '5': 9, '10': 'zoneId'},
    {'1': 'controller_id', '3': 4, '4': 1, '5': 9, '10': 'controllerId'},
    {'1': 'water_liters', '3': 5, '4': 1, '5': 1, '10': 'waterLiters'},
    {
      '1': 'recorded_at',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'recordedAt'
    },
    {
      '1': 'period_start',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'periodStart'
    },
    {
      '1': 'period_end',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'periodEnd'
    },
  ],
};

/// Descriptor for `WaterUsageLog`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List waterUsageLogDescriptor = $convert.base64Decode(
    'Cg1XYXRlclVzYWdlTG9nEg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbm'
    'FudElkEhcKB3pvbmVfaWQYAyABKAlSBnpvbmVJZBIjCg1jb250cm9sbGVyX2lkGAQgASgJUgxj'
    'b250cm9sbGVySWQSIQoMd2F0ZXJfbGl0ZXJzGAUgASgBUgt3YXRlckxpdGVycxI7CgtyZWNvcm'
    'RlZF9hdBgGIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCnJlY29yZGVkQXQSPQoM'
    'cGVyaW9kX3N0YXJ0GAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFILcGVyaW9kU3'
    'RhcnQSOQoKcGVyaW9kX2VuZBgIIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXBl'
    'cmlvZEVuZA==');

@$core.Deprecated('Use createScheduleRequestDescriptor instead')
const CreateScheduleRequest$json = {
  '1': 'CreateScheduleRequest',
  '2': [
    {
      '1': 'schedule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.IrrigationSchedule',
      '10': 'schedule'
    },
  ],
};

/// Descriptor for `CreateScheduleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createScheduleRequestDescriptor = $convert.base64Decode(
    'ChVDcmVhdGVTY2hlZHVsZVJlcXVlc3QSSQoIc2NoZWR1bGUYASABKAsyLS5hZ3JpY3VsdHVyZS'
    '5pcnJpZ2F0aW9uLnYxLklycmlnYXRpb25TY2hlZHVsZVIIc2NoZWR1bGU=');

@$core.Deprecated('Use createScheduleResponseDescriptor instead')
const CreateScheduleResponse$json = {
  '1': 'CreateScheduleResponse',
  '2': [
    {
      '1': 'schedule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.IrrigationSchedule',
      '10': 'schedule'
    },
  ],
};

/// Descriptor for `CreateScheduleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createScheduleResponseDescriptor =
    $convert.base64Decode(
        'ChZDcmVhdGVTY2hlZHVsZVJlc3BvbnNlEkkKCHNjaGVkdWxlGAEgASgLMi0uYWdyaWN1bHR1cm'
        'UuaXJyaWdhdGlvbi52MS5JcnJpZ2F0aW9uU2NoZWR1bGVSCHNjaGVkdWxl');

@$core.Deprecated('Use getScheduleRequestDescriptor instead')
const GetScheduleRequest$json = {
  '1': 'GetScheduleRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetScheduleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getScheduleRequestDescriptor =
    $convert.base64Decode('ChJHZXRTY2hlZHVsZVJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use getScheduleResponseDescriptor instead')
const GetScheduleResponse$json = {
  '1': 'GetScheduleResponse',
  '2': [
    {
      '1': 'schedule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.IrrigationSchedule',
      '10': 'schedule'
    },
  ],
};

/// Descriptor for `GetScheduleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getScheduleResponseDescriptor = $convert.base64Decode(
    'ChNHZXRTY2hlZHVsZVJlc3BvbnNlEkkKCHNjaGVkdWxlGAEgASgLMi0uYWdyaWN1bHR1cmUuaX'
    'JyaWdhdGlvbi52MS5JcnJpZ2F0aW9uU2NoZWR1bGVSCHNjaGVkdWxl');

@$core.Deprecated('Use listSchedulesRequestDescriptor instead')
const ListSchedulesRequest$json = {
  '1': 'ListSchedulesRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'zone_id', '3': 3, '4': 1, '5': 9, '10': 'zoneId'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.irrigation.v1.IrrigationStatus',
      '10': 'status'
    },
    {'1': 'page_size', '3': 5, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 6, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListSchedulesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSchedulesRequestDescriptor = $convert.base64Decode(
    'ChRMaXN0U2NoZWR1bGVzUmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBIXCgdmYX'
    'JtX2lkGAIgASgJUgZmYXJtSWQSFwoHem9uZV9pZBgDIAEoCVIGem9uZUlkEkMKBnN0YXR1cxgE'
    'IAEoDjIrLmFncmljdWx0dXJlLmlycmlnYXRpb24udjEuSXJyaWdhdGlvblN0YXR1c1IGc3RhdH'
    'VzEhsKCXBhZ2Vfc2l6ZRgFIAEoBVIIcGFnZVNpemUSHwoLcGFnZV9vZmZzZXQYBiABKAVSCnBh'
    'Z2VPZmZzZXQ=');

@$core.Deprecated('Use listSchedulesResponseDescriptor instead')
const ListSchedulesResponse$json = {
  '1': 'ListSchedulesResponse',
  '2': [
    {
      '1': 'schedules',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.irrigation.v1.IrrigationSchedule',
      '10': 'schedules'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListSchedulesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSchedulesResponseDescriptor = $convert.base64Decode(
    'ChVMaXN0U2NoZWR1bGVzUmVzcG9uc2USSwoJc2NoZWR1bGVzGAEgAygLMi0uYWdyaWN1bHR1cm'
    'UuaXJyaWdhdGlvbi52MS5JcnJpZ2F0aW9uU2NoZWR1bGVSCXNjaGVkdWxlcxIfCgt0b3RhbF9j'
    'b3VudBgCIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use updateScheduleRequestDescriptor instead')
const UpdateScheduleRequest$json = {
  '1': 'UpdateScheduleRequest',
  '2': [
    {
      '1': 'schedule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.IrrigationSchedule',
      '10': 'schedule'
    },
  ],
};

/// Descriptor for `UpdateScheduleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateScheduleRequestDescriptor = $convert.base64Decode(
    'ChVVcGRhdGVTY2hlZHVsZVJlcXVlc3QSSQoIc2NoZWR1bGUYASABKAsyLS5hZ3JpY3VsdHVyZS'
    '5pcnJpZ2F0aW9uLnYxLklycmlnYXRpb25TY2hlZHVsZVIIc2NoZWR1bGU=');

@$core.Deprecated('Use updateScheduleResponseDescriptor instead')
const UpdateScheduleResponse$json = {
  '1': 'UpdateScheduleResponse',
  '2': [
    {
      '1': 'schedule',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.IrrigationSchedule',
      '10': 'schedule'
    },
  ],
};

/// Descriptor for `UpdateScheduleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateScheduleResponseDescriptor =
    $convert.base64Decode(
        'ChZVcGRhdGVTY2hlZHVsZVJlc3BvbnNlEkkKCHNjaGVkdWxlGAEgASgLMi0uYWdyaWN1bHR1cm'
        'UuaXJyaWdhdGlvbi52MS5JcnJpZ2F0aW9uU2NoZWR1bGVSCHNjaGVkdWxl');

@$core.Deprecated('Use deleteScheduleRequestDescriptor instead')
const DeleteScheduleRequest$json = {
  '1': 'DeleteScheduleRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteScheduleRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteScheduleRequestDescriptor = $convert
    .base64Decode('ChVEZWxldGVTY2hlZHVsZVJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use deleteScheduleResponseDescriptor instead')
const DeleteScheduleResponse$json = {
  '1': 'DeleteScheduleResponse',
  '2': [
    {'1': 'success', '3': 1, '4': 1, '5': 8, '10': 'success'},
  ],
};

/// Descriptor for `DeleteScheduleResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteScheduleResponseDescriptor =
    $convert.base64Decode(
        'ChZEZWxldGVTY2hlZHVsZVJlc3BvbnNlEhgKB3N1Y2Nlc3MYASABKAhSB3N1Y2Nlc3M=');

@$core.Deprecated('Use generateIrrigationDecisionRequestDescriptor instead')
const GenerateIrrigationDecisionRequest$json = {
  '1': 'GenerateIrrigationDecisionRequest',
  '2': [
    {'1': 'zone_id', '3': 1, '4': 1, '5': 9, '10': 'zoneId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'inputs',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.DecisionInputs',
      '10': 'inputs'
    },
  ],
};

/// Descriptor for `GenerateIrrigationDecisionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateIrrigationDecisionRequestDescriptor =
    $convert.base64Decode(
        'CiFHZW5lcmF0ZUlycmlnYXRpb25EZWNpc2lvblJlcXVlc3QSFwoHem9uZV9pZBgBIAEoCVIGem'
        '9uZUlkEhkKCGZpZWxkX2lkGAIgASgJUgdmaWVsZElkEkEKBmlucHV0cxgDIAEoCzIpLmFncmlj'
        'dWx0dXJlLmlycmlnYXRpb24udjEuRGVjaXNpb25JbnB1dHNSBmlucHV0cw==');

@$core.Deprecated('Use generateIrrigationDecisionResponseDescriptor instead')
const GenerateIrrigationDecisionResponse$json = {
  '1': 'GenerateIrrigationDecisionResponse',
  '2': [
    {
      '1': 'decision',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.IrrigationDecision',
      '10': 'decision'
    },
  ],
};

/// Descriptor for `GenerateIrrigationDecisionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateIrrigationDecisionResponseDescriptor =
    $convert.base64Decode(
        'CiJHZW5lcmF0ZUlycmlnYXRpb25EZWNpc2lvblJlc3BvbnNlEkkKCGRlY2lzaW9uGAEgASgLMi'
        '0uYWdyaWN1bHR1cmUuaXJyaWdhdGlvbi52MS5JcnJpZ2F0aW9uRGVjaXNpb25SCGRlY2lzaW9u');

@$core.Deprecated('Use createZoneRequestDescriptor instead')
const CreateZoneRequest$json = {
  '1': 'CreateZoneRequest',
  '2': [
    {
      '1': 'zone',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.IrrigationZone',
      '10': 'zone'
    },
  ],
};

/// Descriptor for `CreateZoneRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createZoneRequestDescriptor = $convert.base64Decode(
    'ChFDcmVhdGVab25lUmVxdWVzdBI9CgR6b25lGAEgASgLMikuYWdyaWN1bHR1cmUuaXJyaWdhdG'
    'lvbi52MS5JcnJpZ2F0aW9uWm9uZVIEem9uZQ==');

@$core.Deprecated('Use createZoneResponseDescriptor instead')
const CreateZoneResponse$json = {
  '1': 'CreateZoneResponse',
  '2': [
    {
      '1': 'zone',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.IrrigationZone',
      '10': 'zone'
    },
  ],
};

/// Descriptor for `CreateZoneResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createZoneResponseDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVab25lUmVzcG9uc2USPQoEem9uZRgBIAEoCzIpLmFncmljdWx0dXJlLmlycmlnYX'
    'Rpb24udjEuSXJyaWdhdGlvblpvbmVSBHpvbmU=');

@$core.Deprecated('Use listZonesRequestDescriptor instead')
const ListZonesRequest$json = {
  '1': 'ListZonesRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 4, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListZonesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listZonesRequestDescriptor = $convert.base64Decode(
    'ChBMaXN0Wm9uZXNSZXF1ZXN0EhkKCGZpZWxkX2lkGAEgASgJUgdmaWVsZElkEhcKB2Zhcm1faW'
    'QYAiABKAlSBmZhcm1JZBIbCglwYWdlX3NpemUYAyABKAVSCHBhZ2VTaXplEh8KC3BhZ2Vfb2Zm'
    'c2V0GAQgASgFUgpwYWdlT2Zmc2V0');

@$core.Deprecated('Use listZonesResponseDescriptor instead')
const ListZonesResponse$json = {
  '1': 'ListZonesResponse',
  '2': [
    {
      '1': 'zones',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.irrigation.v1.IrrigationZone',
      '10': 'zones'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListZonesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listZonesResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0Wm9uZXNSZXNwb25zZRI/CgV6b25lcxgBIAMoCzIpLmFncmljdWx0dXJlLmlycmlnYX'
    'Rpb24udjEuSXJyaWdhdGlvblpvbmVSBXpvbmVzEh8KC3RvdGFsX2NvdW50GAIgASgFUgp0b3Rh'
    'bENvdW50');

@$core.Deprecated('Use registerControllerRequestDescriptor instead')
const RegisterControllerRequest$json = {
  '1': 'RegisterControllerRequest',
  '2': [
    {
      '1': 'controller',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.WaterController',
      '10': 'controller'
    },
  ],
};

/// Descriptor for `RegisterControllerRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerControllerRequestDescriptor =
    $convert.base64Decode(
        'ChlSZWdpc3RlckNvbnRyb2xsZXJSZXF1ZXN0EkoKCmNvbnRyb2xsZXIYASABKAsyKi5hZ3JpY3'
        'VsdHVyZS5pcnJpZ2F0aW9uLnYxLldhdGVyQ29udHJvbGxlclIKY29udHJvbGxlcg==');

@$core.Deprecated('Use registerControllerResponseDescriptor instead')
const RegisterControllerResponse$json = {
  '1': 'RegisterControllerResponse',
  '2': [
    {
      '1': 'controller',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.WaterController',
      '10': 'controller'
    },
  ],
};

/// Descriptor for `RegisterControllerResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerControllerResponseDescriptor =
    $convert.base64Decode(
        'ChpSZWdpc3RlckNvbnRyb2xsZXJSZXNwb25zZRJKCgpjb250cm9sbGVyGAEgASgLMiouYWdyaW'
        'N1bHR1cmUuaXJyaWdhdGlvbi52MS5XYXRlckNvbnRyb2xsZXJSCmNvbnRyb2xsZXI=');

@$core.Deprecated('Use listControllersRequestDescriptor instead')
const ListControllersRequest$json = {
  '1': 'ListControllersRequest',
  '2': [
    {'1': 'zone_id', '3': 1, '4': 1, '5': 9, '10': 'zoneId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.irrigation.v1.ControllerStatus',
      '10': 'status'
    },
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 5, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListControllersRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listControllersRequestDescriptor = $convert.base64Decode(
    'ChZMaXN0Q29udHJvbGxlcnNSZXF1ZXN0EhcKB3pvbmVfaWQYASABKAlSBnpvbmVJZBIZCghmaW'
    'VsZF9pZBgCIAEoCVIHZmllbGRJZBJDCgZzdGF0dXMYAyABKA4yKy5hZ3JpY3VsdHVyZS5pcnJp'
    'Z2F0aW9uLnYxLkNvbnRyb2xsZXJTdGF0dXNSBnN0YXR1cxIbCglwYWdlX3NpemUYBCABKAVSCH'
    'BhZ2VTaXplEh8KC3BhZ2Vfb2Zmc2V0GAUgASgFUgpwYWdlT2Zmc2V0');

@$core.Deprecated('Use listControllersResponseDescriptor instead')
const ListControllersResponse$json = {
  '1': 'ListControllersResponse',
  '2': [
    {
      '1': 'controllers',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.irrigation.v1.WaterController',
      '10': 'controllers'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListControllersResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listControllersResponseDescriptor = $convert.base64Decode(
    'ChdMaXN0Q29udHJvbGxlcnNSZXNwb25zZRJMCgtjb250cm9sbGVycxgBIAMoCzIqLmFncmljdW'
    'x0dXJlLmlycmlnYXRpb24udjEuV2F0ZXJDb250cm9sbGVyUgtjb250cm9sbGVycxIfCgt0b3Rh'
    'bF9jb3VudBgCIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use triggerIrrigationRequestDescriptor instead')
const TriggerIrrigationRequest$json = {
  '1': 'TriggerIrrigationRequest',
  '2': [
    {'1': 'schedule_id', '3': 1, '4': 1, '5': 9, '10': 'scheduleId'},
    {'1': 'controller_id', '3': 2, '4': 1, '5': 9, '10': 'controllerId'},
    {'1': 'zone_id', '3': 3, '4': 1, '5': 9, '10': 'zoneId'},
    {'1': 'duration_minutes', '3': 4, '4': 1, '5': 5, '10': 'durationMinutes'},
    {
      '1': 'water_quantity_liters',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'waterQuantityLiters'
    },
  ],
};

/// Descriptor for `TriggerIrrigationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List triggerIrrigationRequestDescriptor = $convert.base64Decode(
    'ChhUcmlnZ2VySXJyaWdhdGlvblJlcXVlc3QSHwoLc2NoZWR1bGVfaWQYASABKAlSCnNjaGVkdW'
    'xlSWQSIwoNY29udHJvbGxlcl9pZBgCIAEoCVIMY29udHJvbGxlcklkEhcKB3pvbmVfaWQYAyAB'
    'KAlSBnpvbmVJZBIpChBkdXJhdGlvbl9taW51dGVzGAQgASgFUg9kdXJhdGlvbk1pbnV0ZXMSMg'
    'oVd2F0ZXJfcXVhbnRpdHlfbGl0ZXJzGAUgASgBUhN3YXRlclF1YW50aXR5TGl0ZXJz');

@$core.Deprecated('Use triggerIrrigationResponseDescriptor instead')
const TriggerIrrigationResponse$json = {
  '1': 'TriggerIrrigationResponse',
  '2': [
    {
      '1': 'event',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.IrrigationEvent',
      '10': 'event'
    },
  ],
};

/// Descriptor for `TriggerIrrigationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List triggerIrrigationResponseDescriptor =
    $convert.base64Decode(
        'ChlUcmlnZ2VySXJyaWdhdGlvblJlc3BvbnNlEkAKBWV2ZW50GAEgASgLMiouYWdyaWN1bHR1cm'
        'UuaXJyaWdhdGlvbi52MS5JcnJpZ2F0aW9uRXZlbnRSBWV2ZW50');

@$core.Deprecated('Use stopIrrigationRequestDescriptor instead')
const StopIrrigationRequest$json = {
  '1': 'StopIrrigationRequest',
  '2': [
    {'1': 'event_id', '3': 1, '4': 1, '5': 9, '10': 'eventId'},
    {'1': 'controller_id', '3': 2, '4': 1, '5': 9, '10': 'controllerId'},
  ],
};

/// Descriptor for `StopIrrigationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopIrrigationRequestDescriptor = $convert.base64Decode(
    'ChVTdG9wSXJyaWdhdGlvblJlcXVlc3QSGQoIZXZlbnRfaWQYASABKAlSB2V2ZW50SWQSIwoNY2'
    '9udHJvbGxlcl9pZBgCIAEoCVIMY29udHJvbGxlcklk');

@$core.Deprecated('Use stopIrrigationResponseDescriptor instead')
const StopIrrigationResponse$json = {
  '1': 'StopIrrigationResponse',
  '2': [
    {
      '1': 'event',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.irrigation.v1.IrrigationEvent',
      '10': 'event'
    },
  ],
};

/// Descriptor for `StopIrrigationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stopIrrigationResponseDescriptor =
    $convert.base64Decode(
        'ChZTdG9wSXJyaWdhdGlvblJlc3BvbnNlEkAKBWV2ZW50GAEgASgLMiouYWdyaWN1bHR1cmUuaX'
        'JyaWdhdGlvbi52MS5JcnJpZ2F0aW9uRXZlbnRSBWV2ZW50');

@$core.Deprecated('Use getWaterUsageRequestDescriptor instead')
const GetWaterUsageRequest$json = {
  '1': 'GetWaterUsageRequest',
  '2': [
    {'1': 'zone_id', '3': 1, '4': 1, '5': 9, '10': 'zoneId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'from',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'from'
    },
    {
      '1': 'to',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'to'
    },
  ],
};

/// Descriptor for `GetWaterUsageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWaterUsageRequestDescriptor = $convert.base64Decode(
    'ChRHZXRXYXRlclVzYWdlUmVxdWVzdBIXCgd6b25lX2lkGAEgASgJUgZ6b25lSWQSGQoIZmllbG'
    'RfaWQYAiABKAlSB2ZpZWxkSWQSLgoEZnJvbRgDIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1l'
    'c3RhbXBSBGZyb20SKgoCdG8YBCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgJ0bw'
    '==');

@$core.Deprecated('Use getWaterUsageResponseDescriptor instead')
const GetWaterUsageResponse$json = {
  '1': 'GetWaterUsageResponse',
  '2': [
    {
      '1': 'logs',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.irrigation.v1.WaterUsageLog',
      '10': 'logs'
    },
    {'1': 'total_liters', '3': 2, '4': 1, '5': 1, '10': 'totalLiters'},
  ],
};

/// Descriptor for `GetWaterUsageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getWaterUsageResponseDescriptor = $convert.base64Decode(
    'ChVHZXRXYXRlclVzYWdlUmVzcG9uc2USPAoEbG9ncxgBIAMoCzIoLmFncmljdWx0dXJlLmlycm'
    'lnYXRpb24udjEuV2F0ZXJVc2FnZUxvZ1IEbG9ncxIhCgx0b3RhbF9saXRlcnMYAiABKAFSC3Rv'
    'dGFsTGl0ZXJz');

@$core.Deprecated('Use getIrrigationHistoryRequestDescriptor instead')
const GetIrrigationHistoryRequest$json = {
  '1': 'GetIrrigationHistoryRequest',
  '2': [
    {'1': 'zone_id', '3': 1, '4': 1, '5': 9, '10': 'zoneId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'schedule_id', '3': 3, '4': 1, '5': 9, '10': 'scheduleId'},
    {
      '1': 'from',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'from'
    },
    {
      '1': 'to',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'to'
    },
    {'1': 'page_size', '3': 6, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 7, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `GetIrrigationHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getIrrigationHistoryRequestDescriptor = $convert.base64Decode(
    'ChtHZXRJcnJpZ2F0aW9uSGlzdG9yeVJlcXVlc3QSFwoHem9uZV9pZBgBIAEoCVIGem9uZUlkEh'
    'kKCGZpZWxkX2lkGAIgASgJUgdmaWVsZElkEh8KC3NjaGVkdWxlX2lkGAMgASgJUgpzY2hlZHVs'
    'ZUlkEi4KBGZyb20YBCABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgRmcm9tEioKAn'
    'RvGAUgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFICdG8SGwoJcGFnZV9zaXplGAYg'
    'ASgFUghwYWdlU2l6ZRIfCgtwYWdlX29mZnNldBgHIAEoBVIKcGFnZU9mZnNldA==');

@$core.Deprecated('Use getIrrigationHistoryResponseDescriptor instead')
const GetIrrigationHistoryResponse$json = {
  '1': 'GetIrrigationHistoryResponse',
  '2': [
    {
      '1': 'events',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.irrigation.v1.IrrigationEvent',
      '10': 'events'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `GetIrrigationHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getIrrigationHistoryResponseDescriptor =
    $convert.base64Decode(
        'ChxHZXRJcnJpZ2F0aW9uSGlzdG9yeVJlc3BvbnNlEkIKBmV2ZW50cxgBIAMoCzIqLmFncmljdW'
        'x0dXJlLmlycmlnYXRpb24udjEuSXJyaWdhdGlvbkV2ZW50UgZldmVudHMSHwoLdG90YWxfY291'
        'bnQYAiABKAVSCnRvdGFsQ291bnQ=');

const $core.Map<$core.String, $core.dynamic> IrrigationServiceBase$json = {
  '1': 'IrrigationService',
  '2': [
    {
      '1': 'CreateSchedule',
      '2': '.agriculture.irrigation.v1.CreateScheduleRequest',
      '3': '.agriculture.irrigation.v1.CreateScheduleResponse'
    },
    {
      '1': 'GetSchedule',
      '2': '.agriculture.irrigation.v1.GetScheduleRequest',
      '3': '.agriculture.irrigation.v1.GetScheduleResponse'
    },
    {
      '1': 'ListSchedules',
      '2': '.agriculture.irrigation.v1.ListSchedulesRequest',
      '3': '.agriculture.irrigation.v1.ListSchedulesResponse'
    },
    {
      '1': 'UpdateSchedule',
      '2': '.agriculture.irrigation.v1.UpdateScheduleRequest',
      '3': '.agriculture.irrigation.v1.UpdateScheduleResponse'
    },
    {
      '1': 'DeleteSchedule',
      '2': '.agriculture.irrigation.v1.DeleteScheduleRequest',
      '3': '.agriculture.irrigation.v1.DeleteScheduleResponse'
    },
    {
      '1': 'GenerateIrrigationDecision',
      '2': '.agriculture.irrigation.v1.GenerateIrrigationDecisionRequest',
      '3': '.agriculture.irrigation.v1.GenerateIrrigationDecisionResponse'
    },
    {
      '1': 'CreateZone',
      '2': '.agriculture.irrigation.v1.CreateZoneRequest',
      '3': '.agriculture.irrigation.v1.CreateZoneResponse'
    },
    {
      '1': 'ListZones',
      '2': '.agriculture.irrigation.v1.ListZonesRequest',
      '3': '.agriculture.irrigation.v1.ListZonesResponse'
    },
    {
      '1': 'RegisterController',
      '2': '.agriculture.irrigation.v1.RegisterControllerRequest',
      '3': '.agriculture.irrigation.v1.RegisterControllerResponse'
    },
    {
      '1': 'ListControllers',
      '2': '.agriculture.irrigation.v1.ListControllersRequest',
      '3': '.agriculture.irrigation.v1.ListControllersResponse'
    },
    {
      '1': 'TriggerIrrigation',
      '2': '.agriculture.irrigation.v1.TriggerIrrigationRequest',
      '3': '.agriculture.irrigation.v1.TriggerIrrigationResponse'
    },
    {
      '1': 'StopIrrigation',
      '2': '.agriculture.irrigation.v1.StopIrrigationRequest',
      '3': '.agriculture.irrigation.v1.StopIrrigationResponse'
    },
    {
      '1': 'GetWaterUsage',
      '2': '.agriculture.irrigation.v1.GetWaterUsageRequest',
      '3': '.agriculture.irrigation.v1.GetWaterUsageResponse'
    },
    {
      '1': 'GetIrrigationHistory',
      '2': '.agriculture.irrigation.v1.GetIrrigationHistoryRequest',
      '3': '.agriculture.irrigation.v1.GetIrrigationHistoryResponse'
    },
  ],
};

@$core.Deprecated('Use irrigationServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    IrrigationServiceBase$messageJson = {
  '.agriculture.irrigation.v1.CreateScheduleRequest':
      CreateScheduleRequest$json,
  '.agriculture.irrigation.v1.IrrigationSchedule': IrrigationSchedule$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.irrigation.v1.CreateScheduleResponse':
      CreateScheduleResponse$json,
  '.agriculture.irrigation.v1.GetScheduleRequest': GetScheduleRequest$json,
  '.agriculture.irrigation.v1.GetScheduleResponse': GetScheduleResponse$json,
  '.agriculture.irrigation.v1.ListSchedulesRequest': ListSchedulesRequest$json,
  '.agriculture.irrigation.v1.ListSchedulesResponse':
      ListSchedulesResponse$json,
  '.agriculture.irrigation.v1.UpdateScheduleRequest':
      UpdateScheduleRequest$json,
  '.agriculture.irrigation.v1.UpdateScheduleResponse':
      UpdateScheduleResponse$json,
  '.agriculture.irrigation.v1.DeleteScheduleRequest':
      DeleteScheduleRequest$json,
  '.agriculture.irrigation.v1.DeleteScheduleResponse':
      DeleteScheduleResponse$json,
  '.agriculture.irrigation.v1.GenerateIrrigationDecisionRequest':
      GenerateIrrigationDecisionRequest$json,
  '.agriculture.irrigation.v1.DecisionInputs': DecisionInputs$json,
  '.agriculture.irrigation.v1.GenerateIrrigationDecisionResponse':
      GenerateIrrigationDecisionResponse$json,
  '.agriculture.irrigation.v1.IrrigationDecision': IrrigationDecision$json,
  '.agriculture.irrigation.v1.DecisionOutput': DecisionOutput$json,
  '.agriculture.irrigation.v1.CreateZoneRequest': CreateZoneRequest$json,
  '.agriculture.irrigation.v1.IrrigationZone': IrrigationZone$json,
  '.agriculture.irrigation.v1.CreateZoneResponse': CreateZoneResponse$json,
  '.agriculture.irrigation.v1.ListZonesRequest': ListZonesRequest$json,
  '.agriculture.irrigation.v1.ListZonesResponse': ListZonesResponse$json,
  '.agriculture.irrigation.v1.RegisterControllerRequest':
      RegisterControllerRequest$json,
  '.agriculture.irrigation.v1.WaterController': WaterController$json,
  '.agriculture.irrigation.v1.RegisterControllerResponse':
      RegisterControllerResponse$json,
  '.agriculture.irrigation.v1.ListControllersRequest':
      ListControllersRequest$json,
  '.agriculture.irrigation.v1.ListControllersResponse':
      ListControllersResponse$json,
  '.agriculture.irrigation.v1.TriggerIrrigationRequest':
      TriggerIrrigationRequest$json,
  '.agriculture.irrigation.v1.TriggerIrrigationResponse':
      TriggerIrrigationResponse$json,
  '.agriculture.irrigation.v1.IrrigationEvent': IrrigationEvent$json,
  '.agriculture.irrigation.v1.StopIrrigationRequest':
      StopIrrigationRequest$json,
  '.agriculture.irrigation.v1.StopIrrigationResponse':
      StopIrrigationResponse$json,
  '.agriculture.irrigation.v1.GetWaterUsageRequest': GetWaterUsageRequest$json,
  '.agriculture.irrigation.v1.GetWaterUsageResponse':
      GetWaterUsageResponse$json,
  '.agriculture.irrigation.v1.WaterUsageLog': WaterUsageLog$json,
  '.agriculture.irrigation.v1.GetIrrigationHistoryRequest':
      GetIrrigationHistoryRequest$json,
  '.agriculture.irrigation.v1.GetIrrigationHistoryResponse':
      GetIrrigationHistoryResponse$json,
};

/// Descriptor for `IrrigationService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List irrigationServiceDescriptor = $convert.base64Decode(
    'ChFJcnJpZ2F0aW9uU2VydmljZRJ1Cg5DcmVhdGVTY2hlZHVsZRIwLmFncmljdWx0dXJlLmlycm'
    'lnYXRpb24udjEuQ3JlYXRlU2NoZWR1bGVSZXF1ZXN0GjEuYWdyaWN1bHR1cmUuaXJyaWdhdGlv'
    'bi52MS5DcmVhdGVTY2hlZHVsZVJlc3BvbnNlEmwKC0dldFNjaGVkdWxlEi0uYWdyaWN1bHR1cm'
    'UuaXJyaWdhdGlvbi52MS5HZXRTY2hlZHVsZVJlcXVlc3QaLi5hZ3JpY3VsdHVyZS5pcnJpZ2F0'
    'aW9uLnYxLkdldFNjaGVkdWxlUmVzcG9uc2UScgoNTGlzdFNjaGVkdWxlcxIvLmFncmljdWx0dX'
    'JlLmlycmlnYXRpb24udjEuTGlzdFNjaGVkdWxlc1JlcXVlc3QaMC5hZ3JpY3VsdHVyZS5pcnJp'
    'Z2F0aW9uLnYxLkxpc3RTY2hlZHVsZXNSZXNwb25zZRJ1Cg5VcGRhdGVTY2hlZHVsZRIwLmFncm'
    'ljdWx0dXJlLmlycmlnYXRpb24udjEuVXBkYXRlU2NoZWR1bGVSZXF1ZXN0GjEuYWdyaWN1bHR1'
    'cmUuaXJyaWdhdGlvbi52MS5VcGRhdGVTY2hlZHVsZVJlc3BvbnNlEnUKDkRlbGV0ZVNjaGVkdW'
    'xlEjAuYWdyaWN1bHR1cmUuaXJyaWdhdGlvbi52MS5EZWxldGVTY2hlZHVsZVJlcXVlc3QaMS5h'
    'Z3JpY3VsdHVyZS5pcnJpZ2F0aW9uLnYxLkRlbGV0ZVNjaGVkdWxlUmVzcG9uc2USmQEKGkdlbm'
    'VyYXRlSXJyaWdhdGlvbkRlY2lzaW9uEjwuYWdyaWN1bHR1cmUuaXJyaWdhdGlvbi52MS5HZW5l'
    'cmF0ZUlycmlnYXRpb25EZWNpc2lvblJlcXVlc3QaPS5hZ3JpY3VsdHVyZS5pcnJpZ2F0aW9uLn'
    'YxLkdlbmVyYXRlSXJyaWdhdGlvbkRlY2lzaW9uUmVzcG9uc2USaQoKQ3JlYXRlWm9uZRIsLmFn'
    'cmljdWx0dXJlLmlycmlnYXRpb24udjEuQ3JlYXRlWm9uZVJlcXVlc3QaLS5hZ3JpY3VsdHVyZS'
    '5pcnJpZ2F0aW9uLnYxLkNyZWF0ZVpvbmVSZXNwb25zZRJmCglMaXN0Wm9uZXMSKy5hZ3JpY3Vs'
    'dHVyZS5pcnJpZ2F0aW9uLnYxLkxpc3Rab25lc1JlcXVlc3QaLC5hZ3JpY3VsdHVyZS5pcnJpZ2'
    'F0aW9uLnYxLkxpc3Rab25lc1Jlc3BvbnNlEoEBChJSZWdpc3RlckNvbnRyb2xsZXISNC5hZ3Jp'
    'Y3VsdHVyZS5pcnJpZ2F0aW9uLnYxLlJlZ2lzdGVyQ29udHJvbGxlclJlcXVlc3QaNS5hZ3JpY3'
    'VsdHVyZS5pcnJpZ2F0aW9uLnYxLlJlZ2lzdGVyQ29udHJvbGxlclJlc3BvbnNlEngKD0xpc3RD'
    'b250cm9sbGVycxIxLmFncmljdWx0dXJlLmlycmlnYXRpb24udjEuTGlzdENvbnRyb2xsZXJzUm'
    'VxdWVzdBoyLmFncmljdWx0dXJlLmlycmlnYXRpb24udjEuTGlzdENvbnRyb2xsZXJzUmVzcG9u'
    'c2USfgoRVHJpZ2dlcklycmlnYXRpb24SMy5hZ3JpY3VsdHVyZS5pcnJpZ2F0aW9uLnYxLlRyaW'
    'dnZXJJcnJpZ2F0aW9uUmVxdWVzdBo0LmFncmljdWx0dXJlLmlycmlnYXRpb24udjEuVHJpZ2dl'
    'cklycmlnYXRpb25SZXNwb25zZRJ1Cg5TdG9wSXJyaWdhdGlvbhIwLmFncmljdWx0dXJlLmlycm'
    'lnYXRpb24udjEuU3RvcElycmlnYXRpb25SZXF1ZXN0GjEuYWdyaWN1bHR1cmUuaXJyaWdhdGlv'
    'bi52MS5TdG9wSXJyaWdhdGlvblJlc3BvbnNlEnIKDUdldFdhdGVyVXNhZ2USLy5hZ3JpY3VsdH'
    'VyZS5pcnJpZ2F0aW9uLnYxLkdldFdhdGVyVXNhZ2VSZXF1ZXN0GjAuYWdyaWN1bHR1cmUuaXJy'
    'aWdhdGlvbi52MS5HZXRXYXRlclVzYWdlUmVzcG9uc2UShwEKFEdldElycmlnYXRpb25IaXN0b3'
    'J5EjYuYWdyaWN1bHR1cmUuaXJyaWdhdGlvbi52MS5HZXRJcnJpZ2F0aW9uSGlzdG9yeVJlcXVl'
    'c3QaNy5hZ3JpY3VsdHVyZS5pcnJpZ2F0aW9uLnYxLkdldElycmlnYXRpb25IaXN0b3J5UmVzcG'
    '9uc2U=');
