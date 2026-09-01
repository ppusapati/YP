// This is a generated file - do not edit.
//
// Generated from sensor.proto.

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

import 'package:protobuf/well_known_types/google/protobuf/field_mask.pbjson.dart'
    as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pbjson.dart'
    as $0;

@$core.Deprecated('Use sensorTypeDescriptor instead')
const SensorType$json = {
  '1': 'SensorType',
  '2': [
    {'1': 'SENSOR_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SENSOR_TYPE_SOIL_MOISTURE', '2': 1},
    {'1': 'SENSOR_TYPE_SOIL_PH', '2': 2},
    {'1': 'SENSOR_TYPE_TEMPERATURE', '2': 3},
    {'1': 'SENSOR_TYPE_HUMIDITY', '2': 4},
    {'1': 'SENSOR_TYPE_RAINFALL', '2': 5},
    {'1': 'SENSOR_TYPE_WIND_SPEED', '2': 6},
    {'1': 'SENSOR_TYPE_WIND_DIRECTION', '2': 7},
    {'1': 'SENSOR_TYPE_LIGHT_INTENSITY', '2': 8},
    {'1': 'SENSOR_TYPE_LEAF_WETNESS', '2': 9},
  ],
};

/// Descriptor for `SensorType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sensorTypeDescriptor = $convert.base64Decode(
    'CgpTZW5zb3JUeXBlEhsKF1NFTlNPUl9UWVBFX1VOU1BFQ0lGSUVEEAASHQoZU0VOU09SX1RZUE'
    'VfU09JTF9NT0lTVFVSRRABEhcKE1NFTlNPUl9UWVBFX1NPSUxfUEgQAhIbChdTRU5TT1JfVFlQ'
    'RV9URU1QRVJBVFVSRRADEhgKFFNFTlNPUl9UWVBFX0hVTUlESVRZEAQSGAoUU0VOU09SX1RZUE'
    'VfUkFJTkZBTEwQBRIaChZTRU5TT1JfVFlQRV9XSU5EX1NQRUVEEAYSHgoaU0VOU09SX1RZUEVf'
    'V0lORF9ESVJFQ1RJT04QBxIfChtTRU5TT1JfVFlQRV9MSUdIVF9JTlRFTlNJVFkQCBIcChhTRU'
    '5TT1JfVFlQRV9MRUFGX1dFVE5FU1MQCQ==');

@$core.Deprecated('Use sensorStatusDescriptor instead')
const SensorStatus$json = {
  '1': 'SensorStatus',
  '2': [
    {'1': 'SENSOR_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'SENSOR_STATUS_ACTIVE', '2': 1},
    {'1': 'SENSOR_STATUS_INACTIVE', '2': 2},
    {'1': 'SENSOR_STATUS_MAINTENANCE', '2': 3},
    {'1': 'SENSOR_STATUS_DECOMMISSIONED', '2': 4},
  ],
};

/// Descriptor for `SensorStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sensorStatusDescriptor = $convert.base64Decode(
    'CgxTZW5zb3JTdGF0dXMSHQoZU0VOU09SX1NUQVRVU19VTlNQRUNJRklFRBAAEhgKFFNFTlNPUl'
    '9TVEFUVVNfQUNUSVZFEAESGgoWU0VOU09SX1NUQVRVU19JTkFDVElWRRACEh0KGVNFTlNPUl9T'
    'VEFUVVNfTUFJTlRFTkFOQ0UQAxIgChxTRU5TT1JfU1RBVFVTX0RFQ09NTUlTU0lPTkVEEAQ=');

@$core.Deprecated('Use sensorProtocolDescriptor instead')
const SensorProtocol$json = {
  '1': 'SensorProtocol',
  '2': [
    {'1': 'SENSOR_PROTOCOL_UNSPECIFIED', '2': 0},
    {'1': 'SENSOR_PROTOCOL_MQTT', '2': 1},
    {'1': 'SENSOR_PROTOCOL_LORAWAN', '2': 2},
    {'1': 'SENSOR_PROTOCOL_ZIGBEE', '2': 3},
    {'1': 'SENSOR_PROTOCOL_WIFI', '2': 4},
    {'1': 'SENSOR_PROTOCOL_CELLULAR', '2': 5},
  ],
};

/// Descriptor for `SensorProtocol`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sensorProtocolDescriptor = $convert.base64Decode(
    'Cg5TZW5zb3JQcm90b2NvbBIfChtTRU5TT1JfUFJPVE9DT0xfVU5TUEVDSUZJRUQQABIYChRTRU'
    '5TT1JfUFJPVE9DT0xfTVFUVBABEhsKF1NFTlNPUl9QUk9UT0NPTF9MT1JBV0FOEAISGgoWU0VO'
    'U09SX1BST1RPQ09MX1pJR0JFRRADEhgKFFNFTlNPUl9QUk9UT0NPTF9XSUZJEAQSHAoYU0VOU0'
    '9SX1BST1RPQ09MX0NFTExVTEFSEAU=');

@$core.Deprecated('Use readingQualityDescriptor instead')
const ReadingQuality$json = {
  '1': 'ReadingQuality',
  '2': [
    {'1': 'READING_QUALITY_UNSPECIFIED', '2': 0},
    {'1': 'READING_QUALITY_GOOD', '2': 1},
    {'1': 'READING_QUALITY_SUSPECT', '2': 2},
    {'1': 'READING_QUALITY_BAD', '2': 3},
  ],
};

/// Descriptor for `ReadingQuality`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List readingQualityDescriptor = $convert.base64Decode(
    'Cg5SZWFkaW5nUXVhbGl0eRIfChtSRUFESU5HX1FVQUxJVFlfVU5TUEVDSUZJRUQQABIYChRSRU'
    'FESU5HX1FVQUxJVFlfR09PRBABEhsKF1JFQURJTkdfUVVBTElUWV9TVVNQRUNUEAISFwoTUkVB'
    'RElOR19RVUFMSVRZX0JBRBAD');

@$core.Deprecated('Use alertConditionDescriptor instead')
const AlertCondition$json = {
  '1': 'AlertCondition',
  '2': [
    {'1': 'ALERT_CONDITION_UNSPECIFIED', '2': 0},
    {'1': 'ALERT_CONDITION_GT', '2': 1},
    {'1': 'ALERT_CONDITION_LT', '2': 2},
    {'1': 'ALERT_CONDITION_EQ', '2': 3},
    {'1': 'ALERT_CONDITION_GTE', '2': 4},
    {'1': 'ALERT_CONDITION_LTE', '2': 5},
  ],
};

/// Descriptor for `AlertCondition`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List alertConditionDescriptor = $convert.base64Decode(
    'Cg5BbGVydENvbmRpdGlvbhIfChtBTEVSVF9DT05ESVRJT05fVU5TUEVDSUZJRUQQABIWChJBTE'
    'VSVF9DT05ESVRJT05fR1QQARIWChJBTEVSVF9DT05ESVRJT05fTFQQAhIWChJBTEVSVF9DT05E'
    'SVRJT05fRVEQAxIXChNBTEVSVF9DT05ESVRJT05fR1RFEAQSFwoTQUxFUlRfQ09ORElUSU9OX0'
    'xURRAF');

@$core.Deprecated('Use alertSeverityDescriptor instead')
const AlertSeverity$json = {
  '1': 'AlertSeverity',
  '2': [
    {'1': 'ALERT_SEVERITY_UNSPECIFIED', '2': 0},
    {'1': 'ALERT_SEVERITY_LOW', '2': 1},
    {'1': 'ALERT_SEVERITY_MEDIUM', '2': 2},
    {'1': 'ALERT_SEVERITY_HIGH', '2': 3},
    {'1': 'ALERT_SEVERITY_CRITICAL', '2': 4},
  ],
};

/// Descriptor for `AlertSeverity`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List alertSeverityDescriptor = $convert.base64Decode(
    'Cg1BbGVydFNldmVyaXR5Eh4KGkFMRVJUX1NFVkVSSVRZX1VOU1BFQ0lGSUVEEAASFgoSQUxFUl'
    'RfU0VWRVJJVFlfTE9XEAESGQoVQUxFUlRfU0VWRVJJVFlfTUVESVVNEAISFwoTQUxFUlRfU0VW'
    'RVJJVFlfSElHSBADEhsKF0FMRVJUX1NFVkVSSVRZX0NSSVRJQ0FMEAQ=');

@$core.Deprecated('Use geoLocationDescriptor instead')
const GeoLocation$json = {
  '1': 'GeoLocation',
  '2': [
    {'1': 'latitude', '3': 1, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 2, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'elevation_m', '3': 3, '4': 1, '5': 1, '10': 'elevationM'},
  ],
};

/// Descriptor for `GeoLocation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List geoLocationDescriptor = $convert.base64Decode(
    'CgtHZW9Mb2NhdGlvbhIaCghsYXRpdHVkZRgBIAEoAVIIbGF0aXR1ZGUSHAoJbG9uZ2l0dWRlGA'
    'IgASgBUglsb25naXR1ZGUSHwoLZWxldmF0aW9uX20YAyABKAFSCmVsZXZhdGlvbk0=');

@$core.Deprecated('Use sensorDescriptor instead')
const Sensor$json = {
  '1': 'Sensor',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'sensor_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.SensorType',
      '10': 'sensorType'
    },
    {'1': 'device_id', '3': 6, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'manufacturer', '3': 7, '4': 1, '5': 9, '10': 'manufacturer'},
    {'1': 'model', '3': 8, '4': 1, '5': 9, '10': 'model'},
    {'1': 'firmware_version', '3': 9, '4': 1, '5': 9, '10': 'firmwareVersion'},
    {
      '1': 'location',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sensor.v1.GeoLocation',
      '10': 'location'
    },
    {
      '1': 'installation_date',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'installationDate'
    },
    {
      '1': 'last_reading_at',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastReadingAt'
    },
    {
      '1': 'battery_level_pct',
      '3': 13,
      '4': 1,
      '5': 1,
      '10': 'batteryLevelPct'
    },
    {
      '1': 'signal_strength_dbm',
      '3': 14,
      '4': 1,
      '5': 1,
      '10': 'signalStrengthDbm'
    },
    {
      '1': 'status',
      '3': 15,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.SensorStatus',
      '10': 'status'
    },
    {
      '1': 'protocol',
      '3': 16,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.SensorProtocol',
      '10': 'protocol'
    },
    {
      '1': 'reading_interval_seconds',
      '3': 17,
      '4': 1,
      '5': 5,
      '10': 'readingIntervalSeconds'
    },
    {
      '1': 'metadata',
      '3': 18,
      '4': 3,
      '5': 11,
      '6': '.agriculture.sensor.v1.Sensor.MetadataEntry',
      '10': 'metadata'
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
    {'1': 'version', '3': 21, '4': 1, '5': 3, '10': 'version'},
  ],
  '3': [Sensor_MetadataEntry$json],
};

@$core.Deprecated('Use sensorDescriptor instead')
const Sensor_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Sensor`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sensorDescriptor = $convert.base64Decode(
    'CgZTZW5zb3ISDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdGVuYW50SWQSGQ'
    'oIZmllbGRfaWQYAyABKAlSB2ZpZWxkSWQSFwoHZmFybV9pZBgEIAEoCVIGZmFybUlkEkIKC3Nl'
    'bnNvcl90eXBlGAUgASgOMiEuYWdyaWN1bHR1cmUuc2Vuc29yLnYxLlNlbnNvclR5cGVSCnNlbn'
    'NvclR5cGUSGwoJZGV2aWNlX2lkGAYgASgJUghkZXZpY2VJZBIiCgxtYW51ZmFjdHVyZXIYByAB'
    'KAlSDG1hbnVmYWN0dXJlchIUCgVtb2RlbBgIIAEoCVIFbW9kZWwSKQoQZmlybXdhcmVfdmVyc2'
    'lvbhgJIAEoCVIPZmlybXdhcmVWZXJzaW9uEj4KCGxvY2F0aW9uGAogASgLMiIuYWdyaWN1bHR1'
    'cmUuc2Vuc29yLnYxLkdlb0xvY2F0aW9uUghsb2NhdGlvbhJHChFpbnN0YWxsYXRpb25fZGF0ZR'
    'gLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSEGluc3RhbGxhdGlvbkRhdGUSQgoP'
    'bGFzdF9yZWFkaW5nX2F0GAwgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFINbGFzdF'
    'JlYWRpbmdBdBIqChFiYXR0ZXJ5X2xldmVsX3BjdBgNIAEoAVIPYmF0dGVyeUxldmVsUGN0Ei4K'
    'E3NpZ25hbF9zdHJlbmd0aF9kYm0YDiABKAFSEXNpZ25hbFN0cmVuZ3RoRGJtEjsKBnN0YXR1cx'
    'gPIAEoDjIjLmFncmljdWx0dXJlLnNlbnNvci52MS5TZW5zb3JTdGF0dXNSBnN0YXR1cxJBCghw'
    'cm90b2NvbBgQIAEoDjIlLmFncmljdWx0dXJlLnNlbnNvci52MS5TZW5zb3JQcm90b2NvbFIIcH'
    'JvdG9jb2wSOAoYcmVhZGluZ19pbnRlcnZhbF9zZWNvbmRzGBEgASgFUhZyZWFkaW5nSW50ZXJ2'
    'YWxTZWNvbmRzEkcKCG1ldGFkYXRhGBIgAygLMisuYWdyaWN1bHR1cmUuc2Vuc29yLnYxLlNlbn'
    'Nvci5NZXRhZGF0YUVudHJ5UghtZXRhZGF0YRI5CgpjcmVhdGVkX2F0GBMgASgLMhouZ29vZ2xl'
    'LnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkKCnVwZGF0ZWRfYXQYFCABKAsyGi5nb2'
    '9nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQXQSGAoHdmVyc2lvbhgVIAEoA1IHdmVy'
    'c2lvbho7Cg1NZXRhZGF0YUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUg'
    'V2YWx1ZToCOAE=');

@$core.Deprecated('Use sensorReadingDescriptor instead')
const SensorReading$json = {
  '1': 'SensorReading',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'sensor_id', '3': 2, '4': 1, '5': 9, '10': 'sensorId'},
    {'1': 'tenant_id', '3': 3, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'value', '3': 4, '4': 1, '5': 1, '10': 'value'},
    {'1': 'unit', '3': 5, '4': 1, '5': 9, '10': 'unit'},
    {
      '1': 'timestamp',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'quality',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.ReadingQuality',
      '10': 'quality'
    },
    {'1': 'battery_level_pct', '3': 8, '4': 1, '5': 1, '10': 'batteryLevelPct'},
    {
      '1': 'signal_strength_dbm',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'signalStrengthDbm'
    },
    {
      '1': 'metadata',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.agriculture.sensor.v1.SensorReading.MetadataEntry',
      '10': 'metadata'
    },
    {
      '1': 'created_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
  '3': [SensorReading_MetadataEntry$json],
};

@$core.Deprecated('Use sensorReadingDescriptor instead')
const SensorReading_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `SensorReading`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sensorReadingDescriptor = $convert.base64Decode(
    'Cg1TZW5zb3JSZWFkaW5nEg4KAmlkGAEgASgJUgJpZBIbCglzZW5zb3JfaWQYAiABKAlSCHNlbn'
    'NvcklkEhsKCXRlbmFudF9pZBgDIAEoCVIIdGVuYW50SWQSFAoFdmFsdWUYBCABKAFSBXZhbHVl'
    'EhIKBHVuaXQYBSABKAlSBHVuaXQSOAoJdGltZXN0YW1wGAYgASgLMhouZ29vZ2xlLnByb3RvYn'
    'VmLlRpbWVzdGFtcFIJdGltZXN0YW1wEj8KB3F1YWxpdHkYByABKA4yJS5hZ3JpY3VsdHVyZS5z'
    'ZW5zb3IudjEuUmVhZGluZ1F1YWxpdHlSB3F1YWxpdHkSKgoRYmF0dGVyeV9sZXZlbF9wY3QYCC'
    'ABKAFSD2JhdHRlcnlMZXZlbFBjdBIuChNzaWduYWxfc3RyZW5ndGhfZGJtGAkgASgBUhFzaWdu'
    'YWxTdHJlbmd0aERibRJOCghtZXRhZGF0YRgKIAMoCzIyLmFncmljdWx0dXJlLnNlbnNvci52MS'
    '5TZW5zb3JSZWFkaW5nLk1ldGFkYXRhRW50cnlSCG1ldGFkYXRhEjkKCmNyZWF0ZWRfYXQYCyAB'
    'KAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQaOwoNTWV0YWRhdGFFbn'
    'RyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use sensorAlertDescriptor instead')
const SensorAlert$json = {
  '1': 'SensorAlert',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'sensor_id', '3': 2, '4': 1, '5': 9, '10': 'sensorId'},
    {'1': 'tenant_id', '3': 3, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'sensor_type',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.SensorType',
      '10': 'sensorType'
    },
    {'1': 'threshold', '3': 6, '4': 1, '5': 1, '10': 'threshold'},
    {'1': 'actual_value', '3': 7, '4': 1, '5': 1, '10': 'actualValue'},
    {
      '1': 'condition',
      '3': 8,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.AlertCondition',
      '10': 'condition'
    },
    {
      '1': 'severity',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.AlertSeverity',
      '10': 'severity'
    },
    {'1': 'message', '3': 10, '4': 1, '5': 9, '10': 'message'},
    {'1': 'acknowledged', '3': 11, '4': 1, '5': 8, '10': 'acknowledged'},
    {'1': 'acknowledged_by', '3': 12, '4': 1, '5': 9, '10': 'acknowledgedBy'},
    {
      '1': 'acknowledged_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'acknowledgedAt'
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

/// Descriptor for `SensorAlert`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sensorAlertDescriptor = $convert.base64Decode(
    'CgtTZW5zb3JBbGVydBIOCgJpZBgBIAEoCVICaWQSGwoJc2Vuc29yX2lkGAIgASgJUghzZW5zb3'
    'JJZBIbCgl0ZW5hbnRfaWQYAyABKAlSCHRlbmFudElkEhkKCGZpZWxkX2lkGAQgASgJUgdmaWVs'
    'ZElkEkIKC3NlbnNvcl90eXBlGAUgASgOMiEuYWdyaWN1bHR1cmUuc2Vuc29yLnYxLlNlbnNvcl'
    'R5cGVSCnNlbnNvclR5cGUSHAoJdGhyZXNob2xkGAYgASgBUgl0aHJlc2hvbGQSIQoMYWN0dWFs'
    'X3ZhbHVlGAcgASgBUgthY3R1YWxWYWx1ZRJDCgljb25kaXRpb24YCCABKA4yJS5hZ3JpY3VsdH'
    'VyZS5zZW5zb3IudjEuQWxlcnRDb25kaXRpb25SCWNvbmRpdGlvbhJACghzZXZlcml0eRgJIAEo'
    'DjIkLmFncmljdWx0dXJlLnNlbnNvci52MS5BbGVydFNldmVyaXR5UghzZXZlcml0eRIYCgdtZX'
    'NzYWdlGAogASgJUgdtZXNzYWdlEiIKDGFja25vd2xlZGdlZBgLIAEoCFIMYWNrbm93bGVkZ2Vk'
    'EicKD2Fja25vd2xlZGdlZF9ieRgMIAEoCVIOYWNrbm93bGVkZ2VkQnkSQwoPYWNrbm93bGVkZ2'
    'VkX2F0GA0gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIOYWNrbm93bGVkZ2VkQXQS'
    'OQoKY3JlYXRlZF9hdBgOIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZW'
    'RBdBI5Cgp1cGRhdGVkX2F0GA8gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJdXBk'
    'YXRlZEF0');

@$core.Deprecated('Use sensorNetworkDescriptor instead')
const SensorNetwork$json = {
  '1': 'SensorNetwork',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'name', '3': 4, '4': 1, '5': 9, '10': 'name'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'protocol',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.SensorProtocol',
      '10': 'protocol'
    },
    {'1': 'gateway_id', '3': 7, '4': 1, '5': 9, '10': 'gatewayId'},
    {'1': 'sensor_ids', '3': 8, '4': 3, '5': 9, '10': 'sensorIds'},
    {'1': 'total_sensors', '3': 9, '4': 1, '5': 5, '10': 'totalSensors'},
    {'1': 'active_sensors', '3': 10, '4': 1, '5': 5, '10': 'activeSensors'},
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

/// Descriptor for `SensorNetwork`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sensorNetworkDescriptor = $convert.base64Decode(
    'Cg1TZW5zb3JOZXR3b3JrEg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbm'
    'FudElkEhcKB2Zhcm1faWQYAyABKAlSBmZhcm1JZBISCgRuYW1lGAQgASgJUgRuYW1lEiAKC2Rl'
    'c2NyaXB0aW9uGAUgASgJUgtkZXNjcmlwdGlvbhJBCghwcm90b2NvbBgGIAEoDjIlLmFncmljdW'
    'x0dXJlLnNlbnNvci52MS5TZW5zb3JQcm90b2NvbFIIcHJvdG9jb2wSHQoKZ2F0ZXdheV9pZBgH'
    'IAEoCVIJZ2F0ZXdheUlkEh0KCnNlbnNvcl9pZHMYCCADKAlSCXNlbnNvcklkcxIjCg10b3RhbF'
    '9zZW5zb3JzGAkgASgFUgx0b3RhbFNlbnNvcnMSJQoOYWN0aXZlX3NlbnNvcnMYCiABKAVSDWFj'
    'dGl2ZVNlbnNvcnMSOQoKY3JlYXRlZF9hdBgLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3'
    'RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GAwgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRp'
    'bWVzdGFtcFIJdXBkYXRlZEF0');

@$core.Deprecated('Use sensorCalibrationDescriptor instead')
const SensorCalibration$json = {
  '1': 'SensorCalibration',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'sensor_id', '3': 2, '4': 1, '5': 9, '10': 'sensorId'},
    {'1': 'tenant_id', '3': 3, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'offset', '3': 4, '4': 1, '5': 1, '10': 'offset'},
    {'1': 'scale_factor', '3': 5, '4': 1, '5': 1, '10': 'scaleFactor'},
    {
      '1': 'calibration_date',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'calibrationDate'
    },
    {
      '1': 'next_calibration_date',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'nextCalibrationDate'
    },
    {'1': 'calibrated_by', '3': 8, '4': 1, '5': 9, '10': 'calibratedBy'},
    {'1': 'notes', '3': 9, '4': 1, '5': 9, '10': 'notes'},
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

/// Descriptor for `SensorCalibration`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sensorCalibrationDescriptor = $convert.base64Decode(
    'ChFTZW5zb3JDYWxpYnJhdGlvbhIOCgJpZBgBIAEoCVICaWQSGwoJc2Vuc29yX2lkGAIgASgJUg'
    'hzZW5zb3JJZBIbCgl0ZW5hbnRfaWQYAyABKAlSCHRlbmFudElkEhYKBm9mZnNldBgEIAEoAVIG'
    'b2Zmc2V0EiEKDHNjYWxlX2ZhY3RvchgFIAEoAVILc2NhbGVGYWN0b3ISRQoQY2FsaWJyYXRpb2'
    '5fZGF0ZRgGIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSD2NhbGlicmF0aW9uRGF0'
    'ZRJOChVuZXh0X2NhbGlicmF0aW9uX2RhdGUYByABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZX'
    'N0YW1wUhNuZXh0Q2FsaWJyYXRpb25EYXRlEiMKDWNhbGlicmF0ZWRfYnkYCCABKAlSDGNhbGli'
    'cmF0ZWRCeRIUCgVub3RlcxgJIAEoCVIFbm90ZXMSOQoKY3JlYXRlZF9hdBgKIAEoCzIaLmdvb2'
    'dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdA==');

@$core.Deprecated('Use registerSensorRequestDescriptor instead')
const RegisterSensorRequest$json = {
  '1': 'RegisterSensorRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'sensor_type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.SensorType',
      '10': 'sensorType'
    },
    {'1': 'device_id', '3': 4, '4': 1, '5': 9, '10': 'deviceId'},
    {'1': 'manufacturer', '3': 5, '4': 1, '5': 9, '10': 'manufacturer'},
    {'1': 'model', '3': 6, '4': 1, '5': 9, '10': 'model'},
    {'1': 'firmware_version', '3': 7, '4': 1, '5': 9, '10': 'firmwareVersion'},
    {
      '1': 'location',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sensor.v1.GeoLocation',
      '10': 'location'
    },
    {
      '1': 'installation_date',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'installationDate'
    },
    {
      '1': 'protocol',
      '3': 10,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.SensorProtocol',
      '10': 'protocol'
    },
    {
      '1': 'reading_interval_seconds',
      '3': 11,
      '4': 1,
      '5': 5,
      '10': 'readingIntervalSeconds'
    },
    {
      '1': 'metadata',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.agriculture.sensor.v1.RegisterSensorRequest.MetadataEntry',
      '10': 'metadata'
    },
  ],
  '3': [RegisterSensorRequest_MetadataEntry$json],
};

@$core.Deprecated('Use registerSensorRequestDescriptor instead')
const RegisterSensorRequest_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `RegisterSensorRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerSensorRequestDescriptor = $convert.base64Decode(
    'ChVSZWdpc3RlclNlbnNvclJlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQSFwoHZm'
    'FybV9pZBgCIAEoCVIGZmFybUlkEkIKC3NlbnNvcl90eXBlGAMgASgOMiEuYWdyaWN1bHR1cmUu'
    'c2Vuc29yLnYxLlNlbnNvclR5cGVSCnNlbnNvclR5cGUSGwoJZGV2aWNlX2lkGAQgASgJUghkZX'
    'ZpY2VJZBIiCgxtYW51ZmFjdHVyZXIYBSABKAlSDG1hbnVmYWN0dXJlchIUCgVtb2RlbBgGIAEo'
    'CVIFbW9kZWwSKQoQZmlybXdhcmVfdmVyc2lvbhgHIAEoCVIPZmlybXdhcmVWZXJzaW9uEj4KCG'
    'xvY2F0aW9uGAggASgLMiIuYWdyaWN1bHR1cmUuc2Vuc29yLnYxLkdlb0xvY2F0aW9uUghsb2Nh'
    'dGlvbhJHChFpbnN0YWxsYXRpb25fZGF0ZRgJIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3'
    'RhbXBSEGluc3RhbGxhdGlvbkRhdGUSQQoIcHJvdG9jb2wYCiABKA4yJS5hZ3JpY3VsdHVyZS5z'
    'ZW5zb3IudjEuU2Vuc29yUHJvdG9jb2xSCHByb3RvY29sEjgKGHJlYWRpbmdfaW50ZXJ2YWxfc2'
    'Vjb25kcxgLIAEoBVIWcmVhZGluZ0ludGVydmFsU2Vjb25kcxJWCghtZXRhZGF0YRgMIAMoCzI6'
    'LmFncmljdWx0dXJlLnNlbnNvci52MS5SZWdpc3RlclNlbnNvclJlcXVlc3QuTWV0YWRhdGFFbn'
    'RyeVIIbWV0YWRhdGEaOwoNTWV0YWRhdGFFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1'
    'ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use registerSensorResponseDescriptor instead')
const RegisterSensorResponse$json = {
  '1': 'RegisterSensorResponse',
  '2': [
    {
      '1': 'sensor',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sensor.v1.Sensor',
      '10': 'sensor'
    },
  ],
};

/// Descriptor for `RegisterSensorResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerSensorResponseDescriptor =
    $convert.base64Decode(
        'ChZSZWdpc3RlclNlbnNvclJlc3BvbnNlEjUKBnNlbnNvchgBIAEoCzIdLmFncmljdWx0dXJlLn'
        'NlbnNvci52MS5TZW5zb3JSBnNlbnNvcg==');

@$core.Deprecated('Use getSensorRequestDescriptor instead')
const GetSensorRequest$json = {
  '1': 'GetSensorRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetSensorRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSensorRequestDescriptor =
    $convert.base64Decode('ChBHZXRTZW5zb3JSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use getSensorResponseDescriptor instead')
const GetSensorResponse$json = {
  '1': 'GetSensorResponse',
  '2': [
    {
      '1': 'sensor',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sensor.v1.Sensor',
      '10': 'sensor'
    },
  ],
};

/// Descriptor for `GetSensorResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSensorResponseDescriptor = $convert.base64Decode(
    'ChFHZXRTZW5zb3JSZXNwb25zZRI1CgZzZW5zb3IYASABKAsyHS5hZ3JpY3VsdHVyZS5zZW5zb3'
    'IudjEuU2Vuc29yUgZzZW5zb3I=');

@$core.Deprecated('Use listSensorsRequestDescriptor instead')
const ListSensorsRequest$json = {
  '1': 'ListSensorsRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'sensor_type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.SensorType',
      '10': 'sensorType'
    },
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.SensorStatus',
      '10': 'status'
    },
    {
      '1': 'protocol',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.SensorProtocol',
      '10': 'protocol'
    },
    {'1': 'page_size', '3': 6, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 7, '4': 1, '5': 5, '10': 'pageOffset'},
    {'1': 'sort', '3': 8, '4': 3, '5': 9, '10': 'sort'},
  ],
};

/// Descriptor for `ListSensorsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSensorsRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0U2Vuc29yc1JlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQSFwoHZmFybV'
    '9pZBgCIAEoCVIGZmFybUlkEkIKC3NlbnNvcl90eXBlGAMgASgOMiEuYWdyaWN1bHR1cmUuc2Vu'
    'c29yLnYxLlNlbnNvclR5cGVSCnNlbnNvclR5cGUSOwoGc3RhdHVzGAQgASgOMiMuYWdyaWN1bH'
    'R1cmUuc2Vuc29yLnYxLlNlbnNvclN0YXR1c1IGc3RhdHVzEkEKCHByb3RvY29sGAUgASgOMiUu'
    'YWdyaWN1bHR1cmUuc2Vuc29yLnYxLlNlbnNvclByb3RvY29sUghwcm90b2NvbBIbCglwYWdlX3'
    'NpemUYBiABKAVSCHBhZ2VTaXplEh8KC3BhZ2Vfb2Zmc2V0GAcgASgFUgpwYWdlT2Zmc2V0EhIK'
    'BHNvcnQYCCADKAlSBHNvcnQ=');

@$core.Deprecated('Use listSensorsResponseDescriptor instead')
const ListSensorsResponse$json = {
  '1': 'ListSensorsResponse',
  '2': [
    {
      '1': 'sensors',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.sensor.v1.Sensor',
      '10': 'sensors'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListSensorsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listSensorsResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0U2Vuc29yc1Jlc3BvbnNlEjcKB3NlbnNvcnMYASADKAsyHS5hZ3JpY3VsdHVyZS5zZW'
    '5zb3IudjEuU2Vuc29yUgdzZW5zb3JzEh8KC3RvdGFsX2NvdW50GAIgASgFUgp0b3RhbENvdW50');

@$core.Deprecated('Use updateSensorRequestDescriptor instead')
const UpdateSensorRequest$json = {
  '1': 'UpdateSensorRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'update_mask',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.FieldMask',
      '10': 'updateMask'
    },
    {'1': 'firmware_version', '3': 3, '4': 1, '5': 9, '10': 'firmwareVersion'},
    {
      '1': 'location',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sensor.v1.GeoLocation',
      '10': 'location'
    },
    {
      '1': 'status',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.SensorStatus',
      '10': 'status'
    },
    {
      '1': 'protocol',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.SensorProtocol',
      '10': 'protocol'
    },
    {
      '1': 'reading_interval_seconds',
      '3': 7,
      '4': 1,
      '5': 5,
      '10': 'readingIntervalSeconds'
    },
    {
      '1': 'metadata',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.agriculture.sensor.v1.UpdateSensorRequest.MetadataEntry',
      '10': 'metadata'
    },
  ],
  '3': [UpdateSensorRequest_MetadataEntry$json],
};

@$core.Deprecated('Use updateSensorRequestDescriptor instead')
const UpdateSensorRequest_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `UpdateSensorRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSensorRequestDescriptor = $convert.base64Decode(
    'ChNVcGRhdGVTZW5zb3JSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBI7Cgt1cGRhdGVfbWFzaxgCIA'
    'EoCzIaLmdvb2dsZS5wcm90b2J1Zi5GaWVsZE1hc2tSCnVwZGF0ZU1hc2sSKQoQZmlybXdhcmVf'
    'dmVyc2lvbhgDIAEoCVIPZmlybXdhcmVWZXJzaW9uEj4KCGxvY2F0aW9uGAQgASgLMiIuYWdyaW'
    'N1bHR1cmUuc2Vuc29yLnYxLkdlb0xvY2F0aW9uUghsb2NhdGlvbhI7CgZzdGF0dXMYBSABKA4y'
    'Iy5hZ3JpY3VsdHVyZS5zZW5zb3IudjEuU2Vuc29yU3RhdHVzUgZzdGF0dXMSQQoIcHJvdG9jb2'
    'wYBiABKA4yJS5hZ3JpY3VsdHVyZS5zZW5zb3IudjEuU2Vuc29yUHJvdG9jb2xSCHByb3RvY29s'
    'EjgKGHJlYWRpbmdfaW50ZXJ2YWxfc2Vjb25kcxgHIAEoBVIWcmVhZGluZ0ludGVydmFsU2Vjb2'
    '5kcxJUCghtZXRhZGF0YRgIIAMoCzI4LmFncmljdWx0dXJlLnNlbnNvci52MS5VcGRhdGVTZW5z'
    'b3JSZXF1ZXN0Lk1ldGFkYXRhRW50cnlSCG1ldGFkYXRhGjsKDU1ldGFkYXRhRW50cnkSEAoDa2'
    'V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use updateSensorResponseDescriptor instead')
const UpdateSensorResponse$json = {
  '1': 'UpdateSensorResponse',
  '2': [
    {
      '1': 'sensor',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sensor.v1.Sensor',
      '10': 'sensor'
    },
  ],
};

/// Descriptor for `UpdateSensorResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List updateSensorResponseDescriptor = $convert.base64Decode(
    'ChRVcGRhdGVTZW5zb3JSZXNwb25zZRI1CgZzZW5zb3IYASABKAsyHS5hZ3JpY3VsdHVyZS5zZW'
    '5zb3IudjEuU2Vuc29yUgZzZW5zb3I=');

@$core.Deprecated('Use decommissionSensorRequestDescriptor instead')
const DecommissionSensorRequest$json = {
  '1': 'DecommissionSensorRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'reason', '3': 2, '4': 1, '5': 9, '10': 'reason'},
  ],
};

/// Descriptor for `DecommissionSensorRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decommissionSensorRequestDescriptor =
    $convert.base64Decode(
        'ChlEZWNvbW1pc3Npb25TZW5zb3JSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIWCgZyZWFzb24YAi'
        'ABKAlSBnJlYXNvbg==');

@$core.Deprecated('Use decommissionSensorResponseDescriptor instead')
const DecommissionSensorResponse$json = {
  '1': 'DecommissionSensorResponse',
  '2': [
    {
      '1': 'sensor',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sensor.v1.Sensor',
      '10': 'sensor'
    },
  ],
};

/// Descriptor for `DecommissionSensorResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List decommissionSensorResponseDescriptor =
    $convert.base64Decode(
        'ChpEZWNvbW1pc3Npb25TZW5zb3JSZXNwb25zZRI1CgZzZW5zb3IYASABKAsyHS5hZ3JpY3VsdH'
        'VyZS5zZW5zb3IudjEuU2Vuc29yUgZzZW5zb3I=');

@$core.Deprecated('Use ingestReadingRequestDescriptor instead')
const IngestReadingRequest$json = {
  '1': 'IngestReadingRequest',
  '2': [
    {'1': 'sensor_id', '3': 1, '4': 1, '5': 9, '10': 'sensorId'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
    {'1': 'unit', '3': 3, '4': 1, '5': 9, '10': 'unit'},
    {
      '1': 'timestamp',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {
      '1': 'quality',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.ReadingQuality',
      '10': 'quality'
    },
    {'1': 'battery_level_pct', '3': 6, '4': 1, '5': 1, '10': 'batteryLevelPct'},
    {
      '1': 'signal_strength_dbm',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'signalStrengthDbm'
    },
    {
      '1': 'metadata',
      '3': 8,
      '4': 3,
      '5': 11,
      '6': '.agriculture.sensor.v1.IngestReadingRequest.MetadataEntry',
      '10': 'metadata'
    },
  ],
  '3': [IngestReadingRequest_MetadataEntry$json],
};

@$core.Deprecated('Use ingestReadingRequestDescriptor instead')
const IngestReadingRequest_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `IngestReadingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ingestReadingRequestDescriptor = $convert.base64Decode(
    'ChRJbmdlc3RSZWFkaW5nUmVxdWVzdBIbCglzZW5zb3JfaWQYASABKAlSCHNlbnNvcklkEhQKBX'
    'ZhbHVlGAIgASgBUgV2YWx1ZRISCgR1bml0GAMgASgJUgR1bml0EjgKCXRpbWVzdGFtcBgEIAEo'
    'CzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXRpbWVzdGFtcBI/CgdxdWFsaXR5GAUgAS'
    'gOMiUuYWdyaWN1bHR1cmUuc2Vuc29yLnYxLlJlYWRpbmdRdWFsaXR5UgdxdWFsaXR5EioKEWJh'
    'dHRlcnlfbGV2ZWxfcGN0GAYgASgBUg9iYXR0ZXJ5TGV2ZWxQY3QSLgoTc2lnbmFsX3N0cmVuZ3'
    'RoX2RibRgHIAEoAVIRc2lnbmFsU3RyZW5ndGhEYm0SVQoIbWV0YWRhdGEYCCADKAsyOS5hZ3Jp'
    'Y3VsdHVyZS5zZW5zb3IudjEuSW5nZXN0UmVhZGluZ1JlcXVlc3QuTWV0YWRhdGFFbnRyeVIIbW'
    'V0YWRhdGEaOwoNTWV0YWRhdGFFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEo'
    'CVIFdmFsdWU6AjgB');

@$core.Deprecated('Use ingestReadingResponseDescriptor instead')
const IngestReadingResponse$json = {
  '1': 'IngestReadingResponse',
  '2': [
    {
      '1': 'reading',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sensor.v1.SensorReading',
      '10': 'reading'
    },
    {'1': 'alert_triggered', '3': 2, '4': 1, '5': 8, '10': 'alertTriggered'},
    {
      '1': 'alert',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sensor.v1.SensorAlert',
      '10': 'alert'
    },
  ],
};

/// Descriptor for `IngestReadingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ingestReadingResponseDescriptor = $convert.base64Decode(
    'ChVJbmdlc3RSZWFkaW5nUmVzcG9uc2USPgoHcmVhZGluZxgBIAEoCzIkLmFncmljdWx0dXJlLn'
    'NlbnNvci52MS5TZW5zb3JSZWFkaW5nUgdyZWFkaW5nEicKD2FsZXJ0X3RyaWdnZXJlZBgCIAEo'
    'CFIOYWxlcnRUcmlnZ2VyZWQSOAoFYWxlcnQYAyABKAsyIi5hZ3JpY3VsdHVyZS5zZW5zb3Iudj'
    'EuU2Vuc29yQWxlcnRSBWFsZXJ0');

@$core.Deprecated('Use batchIngestReadingsRequestDescriptor instead')
const BatchIngestReadingsRequest$json = {
  '1': 'BatchIngestReadingsRequest',
  '2': [
    {
      '1': 'readings',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.sensor.v1.IngestReadingRequest',
      '10': 'readings'
    },
  ],
};

/// Descriptor for `BatchIngestReadingsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List batchIngestReadingsRequestDescriptor =
    $convert.base64Decode(
        'ChpCYXRjaEluZ2VzdFJlYWRpbmdzUmVxdWVzdBJHCghyZWFkaW5ncxgBIAMoCzIrLmFncmljdW'
        'x0dXJlLnNlbnNvci52MS5Jbmdlc3RSZWFkaW5nUmVxdWVzdFIIcmVhZGluZ3M=');

@$core.Deprecated('Use batchIngestReadingsResponseDescriptor instead')
const BatchIngestReadingsResponse$json = {
  '1': 'BatchIngestReadingsResponse',
  '2': [
    {'1': 'ingested_count', '3': 1, '4': 1, '5': 5, '10': 'ingestedCount'},
    {'1': 'failed_count', '3': 2, '4': 1, '5': 5, '10': 'failedCount'},
    {'1': 'errors', '3': 3, '4': 3, '5': 9, '10': 'errors'},
    {
      '1': 'alerts',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.agriculture.sensor.v1.SensorAlert',
      '10': 'alerts'
    },
  ],
};

/// Descriptor for `BatchIngestReadingsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List batchIngestReadingsResponseDescriptor = $convert.base64Decode(
    'ChtCYXRjaEluZ2VzdFJlYWRpbmdzUmVzcG9uc2USJQoOaW5nZXN0ZWRfY291bnQYASABKAVSDW'
    'luZ2VzdGVkQ291bnQSIQoMZmFpbGVkX2NvdW50GAIgASgFUgtmYWlsZWRDb3VudBIWCgZlcnJv'
    'cnMYAyADKAlSBmVycm9ycxI6CgZhbGVydHMYBCADKAsyIi5hZ3JpY3VsdHVyZS5zZW5zb3Iudj'
    'EuU2Vuc29yQWxlcnRSBmFsZXJ0cw==');

@$core.Deprecated('Use getLatestReadingRequestDescriptor instead')
const GetLatestReadingRequest$json = {
  '1': 'GetLatestReadingRequest',
  '2': [
    {'1': 'sensor_id', '3': 1, '4': 1, '5': 9, '10': 'sensorId'},
  ],
};

/// Descriptor for `GetLatestReadingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLatestReadingRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRMYXRlc3RSZWFkaW5nUmVxdWVzdBIbCglzZW5zb3JfaWQYASABKAlSCHNlbnNvcklk');

@$core.Deprecated('Use getLatestReadingResponseDescriptor instead')
const GetLatestReadingResponse$json = {
  '1': 'GetLatestReadingResponse',
  '2': [
    {
      '1': 'reading',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sensor.v1.SensorReading',
      '10': 'reading'
    },
  ],
};

/// Descriptor for `GetLatestReadingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getLatestReadingResponseDescriptor =
    $convert.base64Decode(
        'ChhHZXRMYXRlc3RSZWFkaW5nUmVzcG9uc2USPgoHcmVhZGluZxgBIAEoCzIkLmFncmljdWx0dX'
        'JlLnNlbnNvci52MS5TZW5zb3JSZWFkaW5nUgdyZWFkaW5n');

@$core.Deprecated('Use getReadingHistoryRequestDescriptor instead')
const GetReadingHistoryRequest$json = {
  '1': 'GetReadingHistoryRequest',
  '2': [
    {'1': 'sensor_id', '3': 1, '4': 1, '5': 9, '10': 'sensorId'},
    {
      '1': 'start_time',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'startTime'
    },
    {
      '1': 'end_time',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'endTime'
    },
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 5, '4': 1, '5': 5, '10': 'pageOffset'},
    {
      '1': 'min_quality',
      '3': 6,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.ReadingQuality',
      '10': 'minQuality'
    },
  ],
};

/// Descriptor for `GetReadingHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReadingHistoryRequestDescriptor = $convert.base64Decode(
    'ChhHZXRSZWFkaW5nSGlzdG9yeVJlcXVlc3QSGwoJc2Vuc29yX2lkGAEgASgJUghzZW5zb3JJZB'
    'I5CgpzdGFydF90aW1lGAIgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJc3RhcnRU'
    'aW1lEjUKCGVuZF90aW1lGAMgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIHZW5kVG'
    'ltZRIbCglwYWdlX3NpemUYBCABKAVSCHBhZ2VTaXplEh8KC3BhZ2Vfb2Zmc2V0GAUgASgFUgpw'
    'YWdlT2Zmc2V0EkYKC21pbl9xdWFsaXR5GAYgASgOMiUuYWdyaWN1bHR1cmUuc2Vuc29yLnYxLl'
    'JlYWRpbmdRdWFsaXR5UgptaW5RdWFsaXR5');

@$core.Deprecated('Use getReadingHistoryResponseDescriptor instead')
const GetReadingHistoryResponse$json = {
  '1': 'GetReadingHistoryResponse',
  '2': [
    {
      '1': 'readings',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.sensor.v1.SensorReading',
      '10': 'readings'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `GetReadingHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReadingHistoryResponseDescriptor = $convert.base64Decode(
    'ChlHZXRSZWFkaW5nSGlzdG9yeVJlc3BvbnNlEkAKCHJlYWRpbmdzGAEgAygLMiQuYWdyaWN1bH'
    'R1cmUuc2Vuc29yLnYxLlNlbnNvclJlYWRpbmdSCHJlYWRpbmdzEh8KC3RvdGFsX2NvdW50GAIg'
    'ASgFUgp0b3RhbENvdW50');

@$core.Deprecated('Use createAlertRequestDescriptor instead')
const CreateAlertRequest$json = {
  '1': 'CreateAlertRequest',
  '2': [
    {'1': 'sensor_id', '3': 1, '4': 1, '5': 9, '10': 'sensorId'},
    {
      '1': 'sensor_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.SensorType',
      '10': 'sensorType'
    },
    {'1': 'threshold', '3': 3, '4': 1, '5': 1, '10': 'threshold'},
    {
      '1': 'condition',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.AlertCondition',
      '10': 'condition'
    },
    {
      '1': 'severity',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.AlertSeverity',
      '10': 'severity'
    },
    {'1': 'message', '3': 6, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `CreateAlertRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createAlertRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVBbGVydFJlcXVlc3QSGwoJc2Vuc29yX2lkGAEgASgJUghzZW5zb3JJZBJCCgtzZW'
    '5zb3JfdHlwZRgCIAEoDjIhLmFncmljdWx0dXJlLnNlbnNvci52MS5TZW5zb3JUeXBlUgpzZW5z'
    'b3JUeXBlEhwKCXRocmVzaG9sZBgDIAEoAVIJdGhyZXNob2xkEkMKCWNvbmRpdGlvbhgEIAEoDj'
    'IlLmFncmljdWx0dXJlLnNlbnNvci52MS5BbGVydENvbmRpdGlvblIJY29uZGl0aW9uEkAKCHNl'
    'dmVyaXR5GAUgASgOMiQuYWdyaWN1bHR1cmUuc2Vuc29yLnYxLkFsZXJ0U2V2ZXJpdHlSCHNldm'
    'VyaXR5EhgKB21lc3NhZ2UYBiABKAlSB21lc3NhZ2U=');

@$core.Deprecated('Use createAlertResponseDescriptor instead')
const CreateAlertResponse$json = {
  '1': 'CreateAlertResponse',
  '2': [
    {
      '1': 'alert',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sensor.v1.SensorAlert',
      '10': 'alert'
    },
  ],
};

/// Descriptor for `CreateAlertResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createAlertResponseDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVBbGVydFJlc3BvbnNlEjgKBWFsZXJ0GAEgASgLMiIuYWdyaWN1bHR1cmUuc2Vuc2'
    '9yLnYxLlNlbnNvckFsZXJ0UgVhbGVydA==');

@$core.Deprecated('Use listAlertsRequestDescriptor instead')
const ListAlertsRequest$json = {
  '1': 'ListAlertsRequest',
  '2': [
    {'1': 'sensor_id', '3': 1, '4': 1, '5': 9, '10': 'sensorId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'severity',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.sensor.v1.AlertSeverity',
      '10': 'severity'
    },
    {
      '1': 'unacknowledged_only',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'unacknowledgedOnly'
    },
    {'1': 'page_size', '3': 5, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 6, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListAlertsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAlertsRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0QWxlcnRzUmVxdWVzdBIbCglzZW5zb3JfaWQYASABKAlSCHNlbnNvcklkEhkKCGZpZW'
    'xkX2lkGAIgASgJUgdmaWVsZElkEkAKCHNldmVyaXR5GAMgASgOMiQuYWdyaWN1bHR1cmUuc2Vu'
    'c29yLnYxLkFsZXJ0U2V2ZXJpdHlSCHNldmVyaXR5Ei8KE3VuYWNrbm93bGVkZ2VkX29ubHkYBC'
    'ABKAhSEnVuYWNrbm93bGVkZ2VkT25seRIbCglwYWdlX3NpemUYBSABKAVSCHBhZ2VTaXplEh8K'
    'C3BhZ2Vfb2Zmc2V0GAYgASgFUgpwYWdlT2Zmc2V0');

@$core.Deprecated('Use listAlertsResponseDescriptor instead')
const ListAlertsResponse$json = {
  '1': 'ListAlertsResponse',
  '2': [
    {
      '1': 'alerts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.sensor.v1.SensorAlert',
      '10': 'alerts'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListAlertsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAlertsResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0QWxlcnRzUmVzcG9uc2USOgoGYWxlcnRzGAEgAygLMiIuYWdyaWN1bHR1cmUuc2Vuc2'
    '9yLnYxLlNlbnNvckFsZXJ0UgZhbGVydHMSHwoLdG90YWxfY291bnQYAiABKAVSCnRvdGFsQ291'
    'bnQ=');

@$core.Deprecated('Use acknowledgeAlertRequestDescriptor instead')
const AcknowledgeAlertRequest$json = {
  '1': 'AcknowledgeAlertRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'acknowledged_by', '3': 2, '4': 1, '5': 9, '10': 'acknowledgedBy'},
  ],
};

/// Descriptor for `AcknowledgeAlertRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List acknowledgeAlertRequestDescriptor =
    $convert.base64Decode(
        'ChdBY2tub3dsZWRnZUFsZXJ0UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSJwoPYWNrbm93bGVkZ2'
        'VkX2J5GAIgASgJUg5hY2tub3dsZWRnZWRCeQ==');

@$core.Deprecated('Use acknowledgeAlertResponseDescriptor instead')
const AcknowledgeAlertResponse$json = {
  '1': 'AcknowledgeAlertResponse',
  '2': [
    {
      '1': 'alert',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sensor.v1.SensorAlert',
      '10': 'alert'
    },
  ],
};

/// Descriptor for `AcknowledgeAlertResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List acknowledgeAlertResponseDescriptor =
    $convert.base64Decode(
        'ChhBY2tub3dsZWRnZUFsZXJ0UmVzcG9uc2USOAoFYWxlcnQYASABKAsyIi5hZ3JpY3VsdHVyZS'
        '5zZW5zb3IudjEuU2Vuc29yQWxlcnRSBWFsZXJ0');

@$core.Deprecated('Use getSensorNetworkRequestDescriptor instead')
const GetSensorNetworkRequest$json = {
  '1': 'GetSensorNetworkRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
  ],
};

/// Descriptor for `GetSensorNetworkRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSensorNetworkRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRTZW5zb3JOZXR3b3JrUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSFwoHZmFybV9pZBgCIA'
        'EoCVIGZmFybUlk');

@$core.Deprecated('Use getSensorNetworkResponseDescriptor instead')
const GetSensorNetworkResponse$json = {
  '1': 'GetSensorNetworkResponse',
  '2': [
    {
      '1': 'network',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sensor.v1.SensorNetwork',
      '10': 'network'
    },
  ],
};

/// Descriptor for `GetSensorNetworkResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSensorNetworkResponseDescriptor =
    $convert.base64Decode(
        'ChhHZXRTZW5zb3JOZXR3b3JrUmVzcG9uc2USPgoHbmV0d29yaxgBIAEoCzIkLmFncmljdWx0dX'
        'JlLnNlbnNvci52MS5TZW5zb3JOZXR3b3JrUgduZXR3b3Jr');

@$core.Deprecated('Use calibrateSensorRequestDescriptor instead')
const CalibrateSensorRequest$json = {
  '1': 'CalibrateSensorRequest',
  '2': [
    {'1': 'sensor_id', '3': 1, '4': 1, '5': 9, '10': 'sensorId'},
    {'1': 'offset', '3': 2, '4': 1, '5': 1, '10': 'offset'},
    {'1': 'scale_factor', '3': 3, '4': 1, '5': 1, '10': 'scaleFactor'},
    {'1': 'notes', '3': 4, '4': 1, '5': 9, '10': 'notes'},
    {
      '1': 'next_calibration_date',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'nextCalibrationDate'
    },
  ],
};

/// Descriptor for `CalibrateSensorRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calibrateSensorRequestDescriptor = $convert.base64Decode(
    'ChZDYWxpYnJhdGVTZW5zb3JSZXF1ZXN0EhsKCXNlbnNvcl9pZBgBIAEoCVIIc2Vuc29ySWQSFg'
    'oGb2Zmc2V0GAIgASgBUgZvZmZzZXQSIQoMc2NhbGVfZmFjdG9yGAMgASgBUgtzY2FsZUZhY3Rv'
    'chIUCgVub3RlcxgEIAEoCVIFbm90ZXMSTgoVbmV4dF9jYWxpYnJhdGlvbl9kYXRlGAUgASgLMh'
    'ouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFITbmV4dENhbGlicmF0aW9uRGF0ZQ==');

@$core.Deprecated('Use calibrateSensorResponseDescriptor instead')
const CalibrateSensorResponse$json = {
  '1': 'CalibrateSensorResponse',
  '2': [
    {
      '1': 'calibration',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.sensor.v1.SensorCalibration',
      '10': 'calibration'
    },
  ],
};

/// Descriptor for `CalibrateSensorResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List calibrateSensorResponseDescriptor =
    $convert.base64Decode(
        'ChdDYWxpYnJhdGVTZW5zb3JSZXNwb25zZRJKCgtjYWxpYnJhdGlvbhgBIAEoCzIoLmFncmljdW'
        'x0dXJlLnNlbnNvci52MS5TZW5zb3JDYWxpYnJhdGlvblILY2FsaWJyYXRpb24=');

const $core.Map<$core.String, $core.dynamic> SensorServiceBase$json = {
  '1': 'SensorService',
  '2': [
    {
      '1': 'RegisterSensor',
      '2': '.agriculture.sensor.v1.RegisterSensorRequest',
      '3': '.agriculture.sensor.v1.RegisterSensorResponse'
    },
    {
      '1': 'GetSensor',
      '2': '.agriculture.sensor.v1.GetSensorRequest',
      '3': '.agriculture.sensor.v1.GetSensorResponse'
    },
    {
      '1': 'ListSensors',
      '2': '.agriculture.sensor.v1.ListSensorsRequest',
      '3': '.agriculture.sensor.v1.ListSensorsResponse'
    },
    {
      '1': 'UpdateSensor',
      '2': '.agriculture.sensor.v1.UpdateSensorRequest',
      '3': '.agriculture.sensor.v1.UpdateSensorResponse'
    },
    {
      '1': 'DecommissionSensor',
      '2': '.agriculture.sensor.v1.DecommissionSensorRequest',
      '3': '.agriculture.sensor.v1.DecommissionSensorResponse'
    },
    {
      '1': 'IngestReading',
      '2': '.agriculture.sensor.v1.IngestReadingRequest',
      '3': '.agriculture.sensor.v1.IngestReadingResponse'
    },
    {
      '1': 'BatchIngestReadings',
      '2': '.agriculture.sensor.v1.BatchIngestReadingsRequest',
      '3': '.agriculture.sensor.v1.BatchIngestReadingsResponse'
    },
    {
      '1': 'GetLatestReading',
      '2': '.agriculture.sensor.v1.GetLatestReadingRequest',
      '3': '.agriculture.sensor.v1.GetLatestReadingResponse'
    },
    {
      '1': 'GetReadingHistory',
      '2': '.agriculture.sensor.v1.GetReadingHistoryRequest',
      '3': '.agriculture.sensor.v1.GetReadingHistoryResponse'
    },
    {
      '1': 'CreateAlert',
      '2': '.agriculture.sensor.v1.CreateAlertRequest',
      '3': '.agriculture.sensor.v1.CreateAlertResponse'
    },
    {
      '1': 'ListAlerts',
      '2': '.agriculture.sensor.v1.ListAlertsRequest',
      '3': '.agriculture.sensor.v1.ListAlertsResponse'
    },
    {
      '1': 'AcknowledgeAlert',
      '2': '.agriculture.sensor.v1.AcknowledgeAlertRequest',
      '3': '.agriculture.sensor.v1.AcknowledgeAlertResponse'
    },
    {
      '1': 'GetSensorNetwork',
      '2': '.agriculture.sensor.v1.GetSensorNetworkRequest',
      '3': '.agriculture.sensor.v1.GetSensorNetworkResponse'
    },
    {
      '1': 'CalibrateSensor',
      '2': '.agriculture.sensor.v1.CalibrateSensorRequest',
      '3': '.agriculture.sensor.v1.CalibrateSensorResponse'
    },
  ],
};

@$core.Deprecated('Use sensorServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    SensorServiceBase$messageJson = {
  '.agriculture.sensor.v1.RegisterSensorRequest': RegisterSensorRequest$json,
  '.agriculture.sensor.v1.GeoLocation': GeoLocation$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.sensor.v1.RegisterSensorRequest.MetadataEntry':
      RegisterSensorRequest_MetadataEntry$json,
  '.agriculture.sensor.v1.RegisterSensorResponse': RegisterSensorResponse$json,
  '.agriculture.sensor.v1.Sensor': Sensor$json,
  '.agriculture.sensor.v1.Sensor.MetadataEntry': Sensor_MetadataEntry$json,
  '.agriculture.sensor.v1.GetSensorRequest': GetSensorRequest$json,
  '.agriculture.sensor.v1.GetSensorResponse': GetSensorResponse$json,
  '.agriculture.sensor.v1.ListSensorsRequest': ListSensorsRequest$json,
  '.agriculture.sensor.v1.ListSensorsResponse': ListSensorsResponse$json,
  '.agriculture.sensor.v1.UpdateSensorRequest': UpdateSensorRequest$json,
  '.google.protobuf.FieldMask': $1.FieldMask$json,
  '.agriculture.sensor.v1.UpdateSensorRequest.MetadataEntry':
      UpdateSensorRequest_MetadataEntry$json,
  '.agriculture.sensor.v1.UpdateSensorResponse': UpdateSensorResponse$json,
  '.agriculture.sensor.v1.DecommissionSensorRequest':
      DecommissionSensorRequest$json,
  '.agriculture.sensor.v1.DecommissionSensorResponse':
      DecommissionSensorResponse$json,
  '.agriculture.sensor.v1.IngestReadingRequest': IngestReadingRequest$json,
  '.agriculture.sensor.v1.IngestReadingRequest.MetadataEntry':
      IngestReadingRequest_MetadataEntry$json,
  '.agriculture.sensor.v1.IngestReadingResponse': IngestReadingResponse$json,
  '.agriculture.sensor.v1.SensorReading': SensorReading$json,
  '.agriculture.sensor.v1.SensorReading.MetadataEntry':
      SensorReading_MetadataEntry$json,
  '.agriculture.sensor.v1.SensorAlert': SensorAlert$json,
  '.agriculture.sensor.v1.BatchIngestReadingsRequest':
      BatchIngestReadingsRequest$json,
  '.agriculture.sensor.v1.BatchIngestReadingsResponse':
      BatchIngestReadingsResponse$json,
  '.agriculture.sensor.v1.GetLatestReadingRequest':
      GetLatestReadingRequest$json,
  '.agriculture.sensor.v1.GetLatestReadingResponse':
      GetLatestReadingResponse$json,
  '.agriculture.sensor.v1.GetReadingHistoryRequest':
      GetReadingHistoryRequest$json,
  '.agriculture.sensor.v1.GetReadingHistoryResponse':
      GetReadingHistoryResponse$json,
  '.agriculture.sensor.v1.CreateAlertRequest': CreateAlertRequest$json,
  '.agriculture.sensor.v1.CreateAlertResponse': CreateAlertResponse$json,
  '.agriculture.sensor.v1.ListAlertsRequest': ListAlertsRequest$json,
  '.agriculture.sensor.v1.ListAlertsResponse': ListAlertsResponse$json,
  '.agriculture.sensor.v1.AcknowledgeAlertRequest':
      AcknowledgeAlertRequest$json,
  '.agriculture.sensor.v1.AcknowledgeAlertResponse':
      AcknowledgeAlertResponse$json,
  '.agriculture.sensor.v1.GetSensorNetworkRequest':
      GetSensorNetworkRequest$json,
  '.agriculture.sensor.v1.GetSensorNetworkResponse':
      GetSensorNetworkResponse$json,
  '.agriculture.sensor.v1.SensorNetwork': SensorNetwork$json,
  '.agriculture.sensor.v1.CalibrateSensorRequest': CalibrateSensorRequest$json,
  '.agriculture.sensor.v1.CalibrateSensorResponse':
      CalibrateSensorResponse$json,
  '.agriculture.sensor.v1.SensorCalibration': SensorCalibration$json,
};

/// Descriptor for `SensorService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List sensorServiceDescriptor = $convert.base64Decode(
    'Cg1TZW5zb3JTZXJ2aWNlEm0KDlJlZ2lzdGVyU2Vuc29yEiwuYWdyaWN1bHR1cmUuc2Vuc29yLn'
    'YxLlJlZ2lzdGVyU2Vuc29yUmVxdWVzdBotLmFncmljdWx0dXJlLnNlbnNvci52MS5SZWdpc3Rl'
    'clNlbnNvclJlc3BvbnNlEl4KCUdldFNlbnNvchInLmFncmljdWx0dXJlLnNlbnNvci52MS5HZX'
    'RTZW5zb3JSZXF1ZXN0GiguYWdyaWN1bHR1cmUuc2Vuc29yLnYxLkdldFNlbnNvclJlc3BvbnNl'
    'EmQKC0xpc3RTZW5zb3JzEikuYWdyaWN1bHR1cmUuc2Vuc29yLnYxLkxpc3RTZW5zb3JzUmVxdW'
    'VzdBoqLmFncmljdWx0dXJlLnNlbnNvci52MS5MaXN0U2Vuc29yc1Jlc3BvbnNlEmcKDFVwZGF0'
    'ZVNlbnNvchIqLmFncmljdWx0dXJlLnNlbnNvci52MS5VcGRhdGVTZW5zb3JSZXF1ZXN0GisuYW'
    'dyaWN1bHR1cmUuc2Vuc29yLnYxLlVwZGF0ZVNlbnNvclJlc3BvbnNlEnkKEkRlY29tbWlzc2lv'
    'blNlbnNvchIwLmFncmljdWx0dXJlLnNlbnNvci52MS5EZWNvbW1pc3Npb25TZW5zb3JSZXF1ZX'
    'N0GjEuYWdyaWN1bHR1cmUuc2Vuc29yLnYxLkRlY29tbWlzc2lvblNlbnNvclJlc3BvbnNlEmoK'
    'DUluZ2VzdFJlYWRpbmcSKy5hZ3JpY3VsdHVyZS5zZW5zb3IudjEuSW5nZXN0UmVhZGluZ1JlcX'
    'Vlc3QaLC5hZ3JpY3VsdHVyZS5zZW5zb3IudjEuSW5nZXN0UmVhZGluZ1Jlc3BvbnNlEnwKE0Jh'
    'dGNoSW5nZXN0UmVhZGluZ3MSMS5hZ3JpY3VsdHVyZS5zZW5zb3IudjEuQmF0Y2hJbmdlc3RSZW'
    'FkaW5nc1JlcXVlc3QaMi5hZ3JpY3VsdHVyZS5zZW5zb3IudjEuQmF0Y2hJbmdlc3RSZWFkaW5n'
    'c1Jlc3BvbnNlEnMKEEdldExhdGVzdFJlYWRpbmcSLi5hZ3JpY3VsdHVyZS5zZW5zb3IudjEuR2'
    'V0TGF0ZXN0UmVhZGluZ1JlcXVlc3QaLy5hZ3JpY3VsdHVyZS5zZW5zb3IudjEuR2V0TGF0ZXN0'
    'UmVhZGluZ1Jlc3BvbnNlEnYKEUdldFJlYWRpbmdIaXN0b3J5Ei8uYWdyaWN1bHR1cmUuc2Vuc2'
    '9yLnYxLkdldFJlYWRpbmdIaXN0b3J5UmVxdWVzdBowLmFncmljdWx0dXJlLnNlbnNvci52MS5H'
    'ZXRSZWFkaW5nSGlzdG9yeVJlc3BvbnNlEmQKC0NyZWF0ZUFsZXJ0EikuYWdyaWN1bHR1cmUuc2'
    'Vuc29yLnYxLkNyZWF0ZUFsZXJ0UmVxdWVzdBoqLmFncmljdWx0dXJlLnNlbnNvci52MS5DcmVh'
    'dGVBbGVydFJlc3BvbnNlEmEKCkxpc3RBbGVydHMSKC5hZ3JpY3VsdHVyZS5zZW5zb3IudjEuTG'
    'lzdEFsZXJ0c1JlcXVlc3QaKS5hZ3JpY3VsdHVyZS5zZW5zb3IudjEuTGlzdEFsZXJ0c1Jlc3Bv'
    'bnNlEnMKEEFja25vd2xlZGdlQWxlcnQSLi5hZ3JpY3VsdHVyZS5zZW5zb3IudjEuQWNrbm93bG'
    'VkZ2VBbGVydFJlcXVlc3QaLy5hZ3JpY3VsdHVyZS5zZW5zb3IudjEuQWNrbm93bGVkZ2VBbGVy'
    'dFJlc3BvbnNlEnMKEEdldFNlbnNvck5ldHdvcmsSLi5hZ3JpY3VsdHVyZS5zZW5zb3IudjEuR2'
    'V0U2Vuc29yTmV0d29ya1JlcXVlc3QaLy5hZ3JpY3VsdHVyZS5zZW5zb3IudjEuR2V0U2Vuc29y'
    'TmV0d29ya1Jlc3BvbnNlEnAKD0NhbGlicmF0ZVNlbnNvchItLmFncmljdWx0dXJlLnNlbnNvci'
    '52MS5DYWxpYnJhdGVTZW5zb3JSZXF1ZXN0Gi4uYWdyaWN1bHR1cmUuc2Vuc29yLnYxLkNhbGli'
    'cmF0ZVNlbnNvclJlc3BvbnNl');
