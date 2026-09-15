// This is a generated file - do not edit.
//
// Generated from weather.proto.

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

@$core.Deprecated('Use weatherProviderDescriptor instead')
const WeatherProvider$json = {
  '1': 'WeatherProvider',
  '2': [
    {'1': 'WEATHER_PROVIDER_UNSPECIFIED', '2': 0},
    {'1': 'WEATHER_PROVIDER_OPEN_METEO', '2': 1},
    {'1': 'WEATHER_PROVIDER_OPENWEATHER', '2': 2},
    {'1': 'WEATHER_PROVIDER_IMD', '2': 3},
  ],
};

/// Descriptor for `WeatherProvider`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List weatherProviderDescriptor = $convert.base64Decode(
    'Cg9XZWF0aGVyUHJvdmlkZXISIAocV0VBVEhFUl9QUk9WSURFUl9VTlNQRUNJRklFRBAAEh8KG1'
    'dFQVRIRVJfUFJPVklERVJfT1BFTl9NRVRFTxABEiAKHFdFQVRIRVJfUFJPVklERVJfT1BFTldF'
    'QVRIRVIQAhIYChRXRUFUSEVSX1BST1ZJREVSX0lNRBAD');

@$core.Deprecated('Use weatherAlertTypeDescriptor instead')
const WeatherAlertType$json = {
  '1': 'WeatherAlertType',
  '2': [
    {'1': 'WEATHER_ALERT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'WEATHER_ALERT_TYPE_FROST', '2': 1},
    {'1': 'WEATHER_ALERT_TYPE_HEAT_STRESS', '2': 2},
    {'1': 'WEATHER_ALERT_TYPE_HEAVY_RAINFALL', '2': 3},
    {'1': 'WEATHER_ALERT_TYPE_HIGH_WIND', '2': 4},
    {'1': 'WEATHER_ALERT_TYPE_DROUGHT', '2': 5},
  ],
};

/// Descriptor for `WeatherAlertType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List weatherAlertTypeDescriptor = $convert.base64Decode(
    'ChBXZWF0aGVyQWxlcnRUeXBlEiIKHldFQVRIRVJfQUxFUlRfVFlQRV9VTlNQRUNJRklFRBAAEh'
    'wKGFdFQVRIRVJfQUxFUlRfVFlQRV9GUk9TVBABEiIKHldFQVRIRVJfQUxFUlRfVFlQRV9IRUFU'
    'X1NUUkVTUxACEiUKIVdFQVRIRVJfQUxFUlRfVFlQRV9IRUFWWV9SQUlORkFMTBADEiAKHFdFQV'
    'RIRVJfQUxFUlRfVFlQRV9ISUdIX1dJTkQQBBIeChpXRUFUSEVSX0FMRVJUX1RZUEVfRFJPVUdI'
    'VBAF');

@$core.Deprecated('Use alertSeverityDescriptor instead')
const AlertSeverity$json = {
  '1': 'AlertSeverity',
  '2': [
    {'1': 'ALERT_SEVERITY_UNSPECIFIED', '2': 0},
    {'1': 'ALERT_SEVERITY_INFO', '2': 1},
    {'1': 'ALERT_SEVERITY_WARNING', '2': 2},
    {'1': 'ALERT_SEVERITY_CRITICAL', '2': 3},
  ],
};

/// Descriptor for `AlertSeverity`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List alertSeverityDescriptor = $convert.base64Decode(
    'Cg1BbGVydFNldmVyaXR5Eh4KGkFMRVJUX1NFVkVSSVRZX1VOU1BFQ0lGSUVEEAASFwoTQUxFUl'
    'RfU0VWRVJJVFlfSU5GTxABEhoKFkFMRVJUX1NFVkVSSVRZX1dBUk5JTkcQAhIbChdBTEVSVF9T'
    'RVZFUklUWV9DUklUSUNBTBAD');

@$core.Deprecated('Use fieldLocationDescriptor instead')
const FieldLocation$json = {
  '1': 'FieldLocation',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 4, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'latitude', '3': 5, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 6, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'elevation_m', '3': 7, '4': 1, '5': 1, '10': 'elevationM'},
    {'1': 'timezone', '3': 8, '4': 1, '5': 9, '10': 'timezone'},
    {
      '1': 'provider',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.agriculture.weather.v1.WeatherProvider',
      '10': 'provider'
    },
    {
      '1': 'last_polled_at',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastPolledAt'
    },
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

/// Descriptor for `FieldLocation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldLocationDescriptor = $convert.base64Decode(
    'Cg1GaWVsZExvY2F0aW9uEg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbm'
    'FudElkEhkKCGZpZWxkX2lkGAMgASgJUgdmaWVsZElkEhcKB2Zhcm1faWQYBCABKAlSBmZhcm1J'
    'ZBIaCghsYXRpdHVkZRgFIAEoAVIIbGF0aXR1ZGUSHAoJbG9uZ2l0dWRlGAYgASgBUglsb25naX'
    'R1ZGUSHwoLZWxldmF0aW9uX20YByABKAFSCmVsZXZhdGlvbk0SGgoIdGltZXpvbmUYCCABKAlS'
    'CHRpbWV6b25lEkMKCHByb3ZpZGVyGAkgASgOMicuYWdyaWN1bHR1cmUud2VhdGhlci52MS5XZW'
    'F0aGVyUHJvdmlkZXJSCHByb3ZpZGVyEkAKDmxhc3RfcG9sbGVkX2F0GAogASgLMhouZ29vZ2xl'
    'LnByb3RvYnVmLlRpbWVzdGFtcFIMbGFzdFBvbGxlZEF0EjkKCmNyZWF0ZWRfYXQYCyABKAsyGi'
    '5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRlZF9hdBgMIAEo'
    'CzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdA==');

@$core.Deprecated('Use observationDescriptor instead')
const Observation$json = {
  '1': 'Observation',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'observed_at',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'observedAt'
    },
    {'1': 'temperature_c', '3': 5, '4': 1, '5': 1, '10': 'temperatureC'},
    {'1': 'humidity_pct', '3': 6, '4': 1, '5': 1, '10': 'humidityPct'},
    {'1': 'precipitation_mm', '3': 7, '4': 1, '5': 1, '10': 'precipitationMm'},
    {'1': 'wind_speed_ms', '3': 8, '4': 1, '5': 1, '10': 'windSpeedMs'},
    {
      '1': 'wind_direction_deg',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'windDirectionDeg'
    },
    {'1': 'pressure_hpa', '3': 10, '4': 1, '5': 1, '10': 'pressureHpa'},
    {
      '1': 'solar_radiation_wm2',
      '3': 11,
      '4': 1,
      '5': 1,
      '10': 'solarRadiationWm2'
    },
    {'1': 'cloud_cover_pct', '3': 12, '4': 1, '5': 1, '10': 'cloudCoverPct'},
    {'1': 'dew_point_c', '3': 13, '4': 1, '5': 1, '10': 'dewPointC'},
    {
      '1': 'soil_temperature_c',
      '3': 14,
      '4': 1,
      '5': 1,
      '10': 'soilTemperatureC'
    },
    {
      '1': 'soil_moisture_m3m3',
      '3': 15,
      '4': 1,
      '5': 1,
      '10': 'soilMoistureM3m3'
    },
    {
      '1': 'provider',
      '3': 16,
      '4': 1,
      '5': 14,
      '6': '.agriculture.weather.v1.WeatherProvider',
      '10': 'provider'
    },
  ],
};

/// Descriptor for `Observation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List observationDescriptor = $convert.base64Decode(
    'CgtPYnNlcnZhdGlvbhIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW5hbn'
    'RJZBIZCghmaWVsZF9pZBgDIAEoCVIHZmllbGRJZBI7CgtvYnNlcnZlZF9hdBgEIAEoCzIaLmdv'
    'b2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCm9ic2VydmVkQXQSIwoNdGVtcGVyYXR1cmVfYxgFIA'
    'EoAVIMdGVtcGVyYXR1cmVDEiEKDGh1bWlkaXR5X3BjdBgGIAEoAVILaHVtaWRpdHlQY3QSKQoQ'
    'cHJlY2lwaXRhdGlvbl9tbRgHIAEoAVIPcHJlY2lwaXRhdGlvbk1tEiIKDXdpbmRfc3BlZWRfbX'
    'MYCCABKAFSC3dpbmRTcGVlZE1zEiwKEndpbmRfZGlyZWN0aW9uX2RlZxgJIAEoAVIQd2luZERp'
    'cmVjdGlvbkRlZxIhCgxwcmVzc3VyZV9ocGEYCiABKAFSC3ByZXNzdXJlSHBhEi4KE3NvbGFyX3'
    'JhZGlhdGlvbl93bTIYCyABKAFSEXNvbGFyUmFkaWF0aW9uV20yEiYKD2Nsb3VkX2NvdmVyX3Bj'
    'dBgMIAEoAVINY2xvdWRDb3ZlclBjdBIeCgtkZXdfcG9pbnRfYxgNIAEoAVIJZGV3UG9pbnRDEi'
    'wKEnNvaWxfdGVtcGVyYXR1cmVfYxgOIAEoAVIQc29pbFRlbXBlcmF0dXJlQxIsChJzb2lsX21v'
    'aXN0dXJlX20zbTMYDyABKAFSEHNvaWxNb2lzdHVyZU0zbTMSQwoIcHJvdmlkZXIYECABKA4yJy'
    '5hZ3JpY3VsdHVyZS53ZWF0aGVyLnYxLldlYXRoZXJQcm92aWRlclIIcHJvdmlkZXI=');

@$core.Deprecated('Use dailyForecastDescriptor instead')
const DailyForecast$json = {
  '1': 'DailyForecast',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'forecast_date',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'forecastDate'
    },
    {
      '1': 'issued_at',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'issuedAt'
    },
    {'1': 'temperature_min_c', '3': 6, '4': 1, '5': 1, '10': 'temperatureMinC'},
    {'1': 'temperature_max_c', '3': 7, '4': 1, '5': 1, '10': 'temperatureMaxC'},
    {
      '1': 'temperature_mean_c',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'temperatureMeanC'
    },
    {'1': 'precipitation_mm', '3': 9, '4': 1, '5': 1, '10': 'precipitationMm'},
    {
      '1': 'precipitation_prob',
      '3': 10,
      '4': 1,
      '5': 1,
      '10': 'precipitationProb'
    },
    {
      '1': 'humidity_mean_pct',
      '3': 11,
      '4': 1,
      '5': 1,
      '10': 'humidityMeanPct'
    },
    {'1': 'wind_speed_max_ms', '3': 12, '4': 1, '5': 1, '10': 'windSpeedMaxMs'},
    {
      '1': 'solar_radiation_mj',
      '3': 13,
      '4': 1,
      '5': 1,
      '10': 'solarRadiationMj'
    },
    {'1': 'et0_mm', '3': 14, '4': 1, '5': 1, '10': 'et0Mm'},
    {'1': 'condition', '3': 15, '4': 1, '5': 9, '10': 'condition'},
    {
      '1': 'provider',
      '3': 16,
      '4': 1,
      '5': 14,
      '6': '.agriculture.weather.v1.WeatherProvider',
      '10': 'provider'
    },
  ],
};

/// Descriptor for `DailyForecast`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dailyForecastDescriptor = $convert.base64Decode(
    'Cg1EYWlseUZvcmVjYXN0Eg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbm'
    'FudElkEhkKCGZpZWxkX2lkGAMgASgJUgdmaWVsZElkEj8KDWZvcmVjYXN0X2RhdGUYBCABKAsy'
    'Gi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgxmb3JlY2FzdERhdGUSNwoJaXNzdWVkX2F0GA'
    'UgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIIaXNzdWVkQXQSKgoRdGVtcGVyYXR1'
    'cmVfbWluX2MYBiABKAFSD3RlbXBlcmF0dXJlTWluQxIqChF0ZW1wZXJhdHVyZV9tYXhfYxgHIA'
    'EoAVIPdGVtcGVyYXR1cmVNYXhDEiwKEnRlbXBlcmF0dXJlX21lYW5fYxgIIAEoAVIQdGVtcGVy'
    'YXR1cmVNZWFuQxIpChBwcmVjaXBpdGF0aW9uX21tGAkgASgBUg9wcmVjaXBpdGF0aW9uTW0SLQ'
    'oScHJlY2lwaXRhdGlvbl9wcm9iGAogASgBUhFwcmVjaXBpdGF0aW9uUHJvYhIqChFodW1pZGl0'
    'eV9tZWFuX3BjdBgLIAEoAVIPaHVtaWRpdHlNZWFuUGN0EikKEXdpbmRfc3BlZWRfbWF4X21zGA'
    'wgASgBUg53aW5kU3BlZWRNYXhNcxIsChJzb2xhcl9yYWRpYXRpb25fbWoYDSABKAFSEHNvbGFy'
    'UmFkaWF0aW9uTWoSFQoGZXQwX21tGA4gASgBUgVldDBNbRIcCgljb25kaXRpb24YDyABKAlSCW'
    'NvbmRpdGlvbhJDCghwcm92aWRlchgQIAEoDjInLmFncmljdWx0dXJlLndlYXRoZXIudjEuV2Vh'
    'dGhlclByb3ZpZGVyUghwcm92aWRlcg==');

@$core.Deprecated('Use dailyAgroMetricsDescriptor instead')
const DailyAgroMetrics$json = {
  '1': 'DailyAgroMetrics',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'date',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'date'
    },
    {'1': 'temperature_min_c', '3': 3, '4': 1, '5': 1, '10': 'temperatureMinC'},
    {'1': 'temperature_max_c', '3': 4, '4': 1, '5': 1, '10': 'temperatureMaxC'},
    {
      '1': 'temperature_mean_c',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'temperatureMeanC'
    },
    {'1': 'precipitation_mm', '3': 6, '4': 1, '5': 1, '10': 'precipitationMm'},
    {'1': 'gdd', '3': 7, '4': 1, '5': 1, '10': 'gdd'},
    {'1': 'et0_mm', '3': 8, '4': 1, '5': 1, '10': 'et0Mm'},
    {'1': 'chill_hours', '3': 9, '4': 1, '5': 1, '10': 'chillHours'},
    {
      '1': 'rainfall_deficit_mm',
      '3': 10,
      '4': 1,
      '5': 1,
      '10': 'rainfallDeficitMm'
    },
    {
      '1': 'humidity_mean_pct',
      '3': 11,
      '4': 1,
      '5': 1,
      '10': 'humidityMeanPct'
    },
    {
      '1': 'solar_radiation_mj',
      '3': 12,
      '4': 1,
      '5': 1,
      '10': 'solarRadiationMj'
    },
  ],
};

/// Descriptor for `DailyAgroMetrics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dailyAgroMetricsDescriptor = $convert.base64Decode(
    'ChBEYWlseUFncm9NZXRyaWNzEhkKCGZpZWxkX2lkGAEgASgJUgdmaWVsZElkEi4KBGRhdGUYAi'
    'ABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgRkYXRlEioKEXRlbXBlcmF0dXJlX21p'
    'bl9jGAMgASgBUg90ZW1wZXJhdHVyZU1pbkMSKgoRdGVtcGVyYXR1cmVfbWF4X2MYBCABKAFSD3'
    'RlbXBlcmF0dXJlTWF4QxIsChJ0ZW1wZXJhdHVyZV9tZWFuX2MYBSABKAFSEHRlbXBlcmF0dXJl'
    'TWVhbkMSKQoQcHJlY2lwaXRhdGlvbl9tbRgGIAEoAVIPcHJlY2lwaXRhdGlvbk1tEhAKA2dkZB'
    'gHIAEoAVIDZ2RkEhUKBmV0MF9tbRgIIAEoAVIFZXQwTW0SHwoLY2hpbGxfaG91cnMYCSABKAFS'
    'CmNoaWxsSG91cnMSLgoTcmFpbmZhbGxfZGVmaWNpdF9tbRgKIAEoAVIRcmFpbmZhbGxEZWZpY2'
    'l0TW0SKgoRaHVtaWRpdHlfbWVhbl9wY3QYCyABKAFSD2h1bWlkaXR5TWVhblBjdBIsChJzb2xh'
    'cl9yYWRpYXRpb25fbWoYDCABKAFSEHNvbGFyUmFkaWF0aW9uTWo=');

@$core.Deprecated('Use agroMetricsSummaryDescriptor instead')
const AgroMetricsSummary$json = {
  '1': 'AgroMetricsSummary',
  '2': [
    {'1': 'cumulative_gdd', '3': 1, '4': 1, '5': 1, '10': 'cumulativeGdd'},
    {'1': 'cumulative_et0_mm', '3': 2, '4': 1, '5': 1, '10': 'cumulativeEt0Mm'},
    {
      '1': 'cumulative_precipitation_mm',
      '3': 3,
      '4': 1,
      '5': 1,
      '10': 'cumulativePrecipitationMm'
    },
    {
      '1': 'cumulative_chill_hours',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'cumulativeChillHours'
    },
    {
      '1': 'cumulative_deficit_mm',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'cumulativeDeficitMm'
    },
    {'1': 'days', '3': 6, '4': 1, '5': 5, '10': 'days'},
    {'1': 'frost_days', '3': 7, '4': 1, '5': 5, '10': 'frostDays'},
    {'1': 'heat_stress_days', '3': 8, '4': 1, '5': 5, '10': 'heatStressDays'},
  ],
};

/// Descriptor for `AgroMetricsSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List agroMetricsSummaryDescriptor = $convert.base64Decode(
    'ChJBZ3JvTWV0cmljc1N1bW1hcnkSJQoOY3VtdWxhdGl2ZV9nZGQYASABKAFSDWN1bXVsYXRpdm'
    'VHZGQSKgoRY3VtdWxhdGl2ZV9ldDBfbW0YAiABKAFSD2N1bXVsYXRpdmVFdDBNbRI+ChtjdW11'
    'bGF0aXZlX3ByZWNpcGl0YXRpb25fbW0YAyABKAFSGWN1bXVsYXRpdmVQcmVjaXBpdGF0aW9uTW'
    '0SNAoWY3VtdWxhdGl2ZV9jaGlsbF9ob3VycxgEIAEoAVIUY3VtdWxhdGl2ZUNoaWxsSG91cnMS'
    'MgoVY3VtdWxhdGl2ZV9kZWZpY2l0X21tGAUgASgBUhNjdW11bGF0aXZlRGVmaWNpdE1tEhIKBG'
    'RheXMYBiABKAVSBGRheXMSHQoKZnJvc3RfZGF5cxgHIAEoBVIJZnJvc3REYXlzEigKEGhlYXRf'
    'c3RyZXNzX2RheXMYCCABKAVSDmhlYXRTdHJlc3NEYXlz');

@$core.Deprecated('Use weatherAlertDescriptor instead')
const WeatherAlert$json = {
  '1': 'WeatherAlert',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.weather.v1.WeatherAlertType',
      '10': 'type'
    },
    {
      '1': 'severity',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.weather.v1.AlertSeverity',
      '10': 'severity'
    },
    {'1': 'message', '3': 6, '4': 1, '5': 9, '10': 'message'},
    {'1': 'value', '3': 7, '4': 1, '5': 1, '10': 'value'},
    {'1': 'threshold', '3': 8, '4': 1, '5': 1, '10': 'threshold'},
    {
      '1': 'valid_from',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validFrom'
    },
    {
      '1': 'valid_to',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'validTo'
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
};

/// Descriptor for `WeatherAlert`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List weatherAlertDescriptor = $convert.base64Decode(
    'CgxXZWF0aGVyQWxlcnQSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCVIIdGVuYW'
    '50SWQSGQoIZmllbGRfaWQYAyABKAlSB2ZpZWxkSWQSPAoEdHlwZRgEIAEoDjIoLmFncmljdWx0'
    'dXJlLndlYXRoZXIudjEuV2VhdGhlckFsZXJ0VHlwZVIEdHlwZRJBCghzZXZlcml0eRgFIAEoDj'
    'IlLmFncmljdWx0dXJlLndlYXRoZXIudjEuQWxlcnRTZXZlcml0eVIIc2V2ZXJpdHkSGAoHbWVz'
    'c2FnZRgGIAEoCVIHbWVzc2FnZRIUCgV2YWx1ZRgHIAEoAVIFdmFsdWUSHAoJdGhyZXNob2xkGA'
    'ggASgBUgl0aHJlc2hvbGQSOQoKdmFsaWRfZnJvbRgJIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5U'
    'aW1lc3RhbXBSCXZhbGlkRnJvbRI1Cgh2YWxpZF90bxgKIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi'
    '5UaW1lc3RhbXBSB3ZhbGlkVG8SOQoKY3JlYXRlZF9hdBgLIAEoCzIaLmdvb2dsZS5wcm90b2J1'
    'Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdA==');

@$core.Deprecated('Use registerFieldLocationRequestDescriptor instead')
const RegisterFieldLocationRequest$json = {
  '1': 'RegisterFieldLocationRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'latitude', '3': 3, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 4, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'elevation_m', '3': 5, '4': 1, '5': 1, '10': 'elevationM'},
    {'1': 'timezone', '3': 6, '4': 1, '5': 9, '10': 'timezone'},
    {
      '1': 'provider',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.weather.v1.WeatherProvider',
      '10': 'provider'
    },
  ],
};

/// Descriptor for `RegisterFieldLocationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerFieldLocationRequestDescriptor = $convert.base64Decode(
    'ChxSZWdpc3RlckZpZWxkTG9jYXRpb25SZXF1ZXN0EhkKCGZpZWxkX2lkGAEgASgJUgdmaWVsZE'
    'lkEhcKB2Zhcm1faWQYAiABKAlSBmZhcm1JZBIaCghsYXRpdHVkZRgDIAEoAVIIbGF0aXR1ZGUS'
    'HAoJbG9uZ2l0dWRlGAQgASgBUglsb25naXR1ZGUSHwoLZWxldmF0aW9uX20YBSABKAFSCmVsZX'
    'ZhdGlvbk0SGgoIdGltZXpvbmUYBiABKAlSCHRpbWV6b25lEkMKCHByb3ZpZGVyGAcgASgOMicu'
    'YWdyaWN1bHR1cmUud2VhdGhlci52MS5XZWF0aGVyUHJvdmlkZXJSCHByb3ZpZGVy');

@$core.Deprecated('Use registerFieldLocationResponseDescriptor instead')
const RegisterFieldLocationResponse$json = {
  '1': 'RegisterFieldLocationResponse',
  '2': [
    {
      '1': 'location',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.weather.v1.FieldLocation',
      '10': 'location'
    },
  ],
};

/// Descriptor for `RegisterFieldLocationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List registerFieldLocationResponseDescriptor =
    $convert.base64Decode(
        'Ch1SZWdpc3RlckZpZWxkTG9jYXRpb25SZXNwb25zZRJBCghsb2NhdGlvbhgBIAEoCzIlLmFncm'
        'ljdWx0dXJlLndlYXRoZXIudjEuRmllbGRMb2NhdGlvblIIbG9jYXRpb24=');

@$core.Deprecated('Use getFieldLocationRequestDescriptor instead')
const GetFieldLocationRequest$json = {
  '1': 'GetFieldLocationRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
  ],
};

/// Descriptor for `GetFieldLocationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFieldLocationRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRGaWVsZExvY2F0aW9uUmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZA==');

@$core.Deprecated('Use getFieldLocationResponseDescriptor instead')
const GetFieldLocationResponse$json = {
  '1': 'GetFieldLocationResponse',
  '2': [
    {
      '1': 'location',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.weather.v1.FieldLocation',
      '10': 'location'
    },
  ],
};

/// Descriptor for `GetFieldLocationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFieldLocationResponseDescriptor =
    $convert.base64Decode(
        'ChhHZXRGaWVsZExvY2F0aW9uUmVzcG9uc2USQQoIbG9jYXRpb24YASABKAsyJS5hZ3JpY3VsdH'
        'VyZS53ZWF0aGVyLnYxLkZpZWxkTG9jYXRpb25SCGxvY2F0aW9u');

@$core.Deprecated('Use listFieldLocationsRequestDescriptor instead')
const ListFieldLocationsRequest$json = {
  '1': 'ListFieldLocationsRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 3, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListFieldLocationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFieldLocationsRequestDescriptor = $convert.base64Decode(
    'ChlMaXN0RmllbGRMb2NhdGlvbnNSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZBIbCg'
    'lwYWdlX3NpemUYAiABKAVSCHBhZ2VTaXplEh8KC3BhZ2Vfb2Zmc2V0GAMgASgFUgpwYWdlT2Zm'
    'c2V0');

@$core.Deprecated('Use listFieldLocationsResponseDescriptor instead')
const ListFieldLocationsResponse$json = {
  '1': 'ListFieldLocationsResponse',
  '2': [
    {
      '1': 'locations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.weather.v1.FieldLocation',
      '10': 'locations'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListFieldLocationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFieldLocationsResponseDescriptor =
    $convert.base64Decode(
        'ChpMaXN0RmllbGRMb2NhdGlvbnNSZXNwb25zZRJDCglsb2NhdGlvbnMYASADKAsyJS5hZ3JpY3'
        'VsdHVyZS53ZWF0aGVyLnYxLkZpZWxkTG9jYXRpb25SCWxvY2F0aW9ucxIfCgt0b3RhbF9jb3Vu'
        'dBgCIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use getCurrentWeatherRequestDescriptor instead')
const GetCurrentWeatherRequest$json = {
  '1': 'GetCurrentWeatherRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
  ],
};

/// Descriptor for `GetCurrentWeatherRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCurrentWeatherRequestDescriptor =
    $convert.base64Decode(
        'ChhHZXRDdXJyZW50V2VhdGhlclJlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQ=');

@$core.Deprecated('Use getCurrentWeatherResponseDescriptor instead')
const GetCurrentWeatherResponse$json = {
  '1': 'GetCurrentWeatherResponse',
  '2': [
    {
      '1': 'observation',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.weather.v1.Observation',
      '10': 'observation'
    },
  ],
};

/// Descriptor for `GetCurrentWeatherResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCurrentWeatherResponseDescriptor =
    $convert.base64Decode(
        'ChlHZXRDdXJyZW50V2VhdGhlclJlc3BvbnNlEkUKC29ic2VydmF0aW9uGAEgASgLMiMuYWdyaW'
        'N1bHR1cmUud2VhdGhlci52MS5PYnNlcnZhdGlvblILb2JzZXJ2YXRpb24=');

@$core.Deprecated('Use getForecastRequestDescriptor instead')
const GetForecastRequest$json = {
  '1': 'GetForecastRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'days', '3': 2, '4': 1, '5': 5, '10': 'days'},
  ],
};

/// Descriptor for `GetForecastRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getForecastRequestDescriptor = $convert.base64Decode(
    'ChJHZXRGb3JlY2FzdFJlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQSEgoEZGF5cx'
    'gCIAEoBVIEZGF5cw==');

@$core.Deprecated('Use getForecastResponseDescriptor instead')
const GetForecastResponse$json = {
  '1': 'GetForecastResponse',
  '2': [
    {
      '1': 'forecasts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.weather.v1.DailyForecast',
      '10': 'forecasts'
    },
  ],
};

/// Descriptor for `GetForecastResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getForecastResponseDescriptor = $convert.base64Decode(
    'ChNHZXRGb3JlY2FzdFJlc3BvbnNlEkMKCWZvcmVjYXN0cxgBIAMoCzIlLmFncmljdWx0dXJlLn'
    'dlYXRoZXIudjEuRGFpbHlGb3JlY2FzdFIJZm9yZWNhc3Rz');

@$core.Deprecated('Use listObservationsRequestDescriptor instead')
const ListObservationsRequest$json = {
  '1': 'ListObservationsRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'start',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'start'
    },
    {
      '1': 'end',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'end'
    },
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 5, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListObservationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listObservationsRequestDescriptor = $convert.base64Decode(
    'ChdMaXN0T2JzZXJ2YXRpb25zUmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZBIwCg'
    'VzdGFydBgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSBXN0YXJ0EiwKA2VuZBgD'
    'IAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSA2VuZBIbCglwYWdlX3NpemUYBCABKA'
    'VSCHBhZ2VTaXplEh8KC3BhZ2Vfb2Zmc2V0GAUgASgFUgpwYWdlT2Zmc2V0');

@$core.Deprecated('Use listObservationsResponseDescriptor instead')
const ListObservationsResponse$json = {
  '1': 'ListObservationsResponse',
  '2': [
    {
      '1': 'observations',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.weather.v1.Observation',
      '10': 'observations'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListObservationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listObservationsResponseDescriptor = $convert.base64Decode(
    'ChhMaXN0T2JzZXJ2YXRpb25zUmVzcG9uc2USRwoMb2JzZXJ2YXRpb25zGAEgAygLMiMuYWdyaW'
    'N1bHR1cmUud2VhdGhlci52MS5PYnNlcnZhdGlvblIMb2JzZXJ2YXRpb25zEh8KC3RvdGFsX2Nv'
    'dW50GAIgASgFUgp0b3RhbENvdW50');

@$core.Deprecated('Use getAgroMetricsRequestDescriptor instead')
const GetAgroMetricsRequest$json = {
  '1': 'GetAgroMetricsRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'start',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'start'
    },
    {
      '1': 'end',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'end'
    },
    {'1': 'base_temp_c', '3': 4, '4': 1, '5': 1, '10': 'baseTempC'},
    {'1': 'cap_temp_c', '3': 5, '4': 1, '5': 1, '10': 'capTempC'},
  ],
};

/// Descriptor for `GetAgroMetricsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAgroMetricsRequestDescriptor = $convert.base64Decode(
    'ChVHZXRBZ3JvTWV0cmljc1JlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQSMAoFc3'
    'RhcnQYAiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgVzdGFydBIsCgNlbmQYAyAB'
    'KAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgNlbmQSHgoLYmFzZV90ZW1wX2MYBCABKA'
    'FSCWJhc2VUZW1wQxIcCgpjYXBfdGVtcF9jGAUgASgBUghjYXBUZW1wQw==');

@$core.Deprecated('Use getAgroMetricsResponseDescriptor instead')
const GetAgroMetricsResponse$json = {
  '1': 'GetAgroMetricsResponse',
  '2': [
    {
      '1': 'daily',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.weather.v1.DailyAgroMetrics',
      '10': 'daily'
    },
    {
      '1': 'summary',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.agriculture.weather.v1.AgroMetricsSummary',
      '10': 'summary'
    },
  ],
};

/// Descriptor for `GetAgroMetricsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAgroMetricsResponseDescriptor = $convert.base64Decode(
    'ChZHZXRBZ3JvTWV0cmljc1Jlc3BvbnNlEj4KBWRhaWx5GAEgAygLMiguYWdyaWN1bHR1cmUud2'
    'VhdGhlci52MS5EYWlseUFncm9NZXRyaWNzUgVkYWlseRJECgdzdW1tYXJ5GAIgASgLMiouYWdy'
    'aWN1bHR1cmUud2VhdGhlci52MS5BZ3JvTWV0cmljc1N1bW1hcnlSB3N1bW1hcnk=');

@$core.Deprecated('Use refreshFieldWeatherRequestDescriptor instead')
const RefreshFieldWeatherRequest$json = {
  '1': 'RefreshFieldWeatherRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
  ],
};

/// Descriptor for `RefreshFieldWeatherRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshFieldWeatherRequestDescriptor =
    $convert.base64Decode(
        'ChpSZWZyZXNoRmllbGRXZWF0aGVyUmVxdWVzdBIZCghmaWVsZF9pZBgBIAEoCVIHZmllbGRJZA'
        '==');

@$core.Deprecated('Use refreshFieldWeatherResponseDescriptor instead')
const RefreshFieldWeatherResponse$json = {
  '1': 'RefreshFieldWeatherResponse',
  '2': [
    {
      '1': 'observations_ingested',
      '3': 1,
      '4': 1,
      '5': 5,
      '10': 'observationsIngested'
    },
    {
      '1': 'forecasts_ingested',
      '3': 2,
      '4': 1,
      '5': 5,
      '10': 'forecastsIngested'
    },
  ],
};

/// Descriptor for `RefreshFieldWeatherResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List refreshFieldWeatherResponseDescriptor =
    $convert.base64Decode(
        'ChtSZWZyZXNoRmllbGRXZWF0aGVyUmVzcG9uc2USMwoVb2JzZXJ2YXRpb25zX2luZ2VzdGVkGA'
        'EgASgFUhRvYnNlcnZhdGlvbnNJbmdlc3RlZBItChJmb3JlY2FzdHNfaW5nZXN0ZWQYAiABKAVS'
        'EWZvcmVjYXN0c0luZ2VzdGVk');

@$core.Deprecated('Use backfillHistoryRequestDescriptor instead')
const BackfillHistoryRequest$json = {
  '1': 'BackfillHistoryRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'years', '3': 2, '4': 1, '5': 5, '10': 'years'},
  ],
};

/// Descriptor for `BackfillHistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List backfillHistoryRequestDescriptor =
    $convert.base64Decode(
        'ChZCYWNrZmlsbEhpc3RvcnlSZXF1ZXN0EhkKCGZpZWxkX2lkGAEgASgJUgdmaWVsZElkEhQKBX'
        'llYXJzGAIgASgFUgV5ZWFycw==');

@$core.Deprecated('Use backfillHistoryResponseDescriptor instead')
const BackfillHistoryResponse$json = {
  '1': 'BackfillHistoryResponse',
  '2': [
    {'1': 'days_ingested', '3': 1, '4': 1, '5': 5, '10': 'daysIngested'},
    {
      '1': 'from',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'from'
    },
    {
      '1': 'to',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'to'
    },
  ],
};

/// Descriptor for `BackfillHistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List backfillHistoryResponseDescriptor = $convert.base64Decode(
    'ChdCYWNrZmlsbEhpc3RvcnlSZXNwb25zZRIjCg1kYXlzX2luZ2VzdGVkGAEgASgFUgxkYXlzSW'
    '5nZXN0ZWQSLgoEZnJvbRgCIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSBGZyb20S'
    'KgoCdG8YAyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgJ0bw==');

@$core.Deprecated('Use listWeatherAlertsRequestDescriptor instead')
const ListWeatherAlertsRequest$json = {
  '1': 'ListWeatherAlertsRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'active_only', '3': 2, '4': 1, '5': 8, '10': 'activeOnly'},
    {'1': 'page_size', '3': 3, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 4, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListWeatherAlertsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listWeatherAlertsRequestDescriptor = $convert.base64Decode(
    'ChhMaXN0V2VhdGhlckFsZXJ0c1JlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSWQSHw'
    'oLYWN0aXZlX29ubHkYAiABKAhSCmFjdGl2ZU9ubHkSGwoJcGFnZV9zaXplGAMgASgFUghwYWdl'
    'U2l6ZRIfCgtwYWdlX29mZnNldBgEIAEoBVIKcGFnZU9mZnNldA==');

@$core.Deprecated('Use listWeatherAlertsResponseDescriptor instead')
const ListWeatherAlertsResponse$json = {
  '1': 'ListWeatherAlertsResponse',
  '2': [
    {
      '1': 'alerts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.weather.v1.WeatherAlert',
      '10': 'alerts'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListWeatherAlertsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listWeatherAlertsResponseDescriptor = $convert.base64Decode(
    'ChlMaXN0V2VhdGhlckFsZXJ0c1Jlc3BvbnNlEjwKBmFsZXJ0cxgBIAMoCzIkLmFncmljdWx0dX'
    'JlLndlYXRoZXIudjEuV2VhdGhlckFsZXJ0UgZhbGVydHMSHwoLdG90YWxfY291bnQYAiABKAVS'
    'CnRvdGFsQ291bnQ=');

const $core.Map<$core.String, $core.dynamic> WeatherServiceBase$json = {
  '1': 'WeatherService',
  '2': [
    {
      '1': 'RegisterFieldLocation',
      '2': '.agriculture.weather.v1.RegisterFieldLocationRequest',
      '3': '.agriculture.weather.v1.RegisterFieldLocationResponse'
    },
    {
      '1': 'GetFieldLocation',
      '2': '.agriculture.weather.v1.GetFieldLocationRequest',
      '3': '.agriculture.weather.v1.GetFieldLocationResponse'
    },
    {
      '1': 'ListFieldLocations',
      '2': '.agriculture.weather.v1.ListFieldLocationsRequest',
      '3': '.agriculture.weather.v1.ListFieldLocationsResponse'
    },
    {
      '1': 'GetCurrentWeather',
      '2': '.agriculture.weather.v1.GetCurrentWeatherRequest',
      '3': '.agriculture.weather.v1.GetCurrentWeatherResponse'
    },
    {
      '1': 'GetForecast',
      '2': '.agriculture.weather.v1.GetForecastRequest',
      '3': '.agriculture.weather.v1.GetForecastResponse'
    },
    {
      '1': 'ListObservations',
      '2': '.agriculture.weather.v1.ListObservationsRequest',
      '3': '.agriculture.weather.v1.ListObservationsResponse'
    },
    {
      '1': 'GetAgroMetrics',
      '2': '.agriculture.weather.v1.GetAgroMetricsRequest',
      '3': '.agriculture.weather.v1.GetAgroMetricsResponse'
    },
    {
      '1': 'RefreshFieldWeather',
      '2': '.agriculture.weather.v1.RefreshFieldWeatherRequest',
      '3': '.agriculture.weather.v1.RefreshFieldWeatherResponse'
    },
    {
      '1': 'BackfillHistory',
      '2': '.agriculture.weather.v1.BackfillHistoryRequest',
      '3': '.agriculture.weather.v1.BackfillHistoryResponse'
    },
    {
      '1': 'ListWeatherAlerts',
      '2': '.agriculture.weather.v1.ListWeatherAlertsRequest',
      '3': '.agriculture.weather.v1.ListWeatherAlertsResponse'
    },
  ],
};

@$core.Deprecated('Use weatherServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    WeatherServiceBase$messageJson = {
  '.agriculture.weather.v1.RegisterFieldLocationRequest':
      RegisterFieldLocationRequest$json,
  '.agriculture.weather.v1.RegisterFieldLocationResponse':
      RegisterFieldLocationResponse$json,
  '.agriculture.weather.v1.FieldLocation': FieldLocation$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.weather.v1.GetFieldLocationRequest':
      GetFieldLocationRequest$json,
  '.agriculture.weather.v1.GetFieldLocationResponse':
      GetFieldLocationResponse$json,
  '.agriculture.weather.v1.ListFieldLocationsRequest':
      ListFieldLocationsRequest$json,
  '.agriculture.weather.v1.ListFieldLocationsResponse':
      ListFieldLocationsResponse$json,
  '.agriculture.weather.v1.GetCurrentWeatherRequest':
      GetCurrentWeatherRequest$json,
  '.agriculture.weather.v1.GetCurrentWeatherResponse':
      GetCurrentWeatherResponse$json,
  '.agriculture.weather.v1.Observation': Observation$json,
  '.agriculture.weather.v1.GetForecastRequest': GetForecastRequest$json,
  '.agriculture.weather.v1.GetForecastResponse': GetForecastResponse$json,
  '.agriculture.weather.v1.DailyForecast': DailyForecast$json,
  '.agriculture.weather.v1.ListObservationsRequest':
      ListObservationsRequest$json,
  '.agriculture.weather.v1.ListObservationsResponse':
      ListObservationsResponse$json,
  '.agriculture.weather.v1.GetAgroMetricsRequest': GetAgroMetricsRequest$json,
  '.agriculture.weather.v1.GetAgroMetricsResponse': GetAgroMetricsResponse$json,
  '.agriculture.weather.v1.DailyAgroMetrics': DailyAgroMetrics$json,
  '.agriculture.weather.v1.AgroMetricsSummary': AgroMetricsSummary$json,
  '.agriculture.weather.v1.RefreshFieldWeatherRequest':
      RefreshFieldWeatherRequest$json,
  '.agriculture.weather.v1.RefreshFieldWeatherResponse':
      RefreshFieldWeatherResponse$json,
  '.agriculture.weather.v1.BackfillHistoryRequest': BackfillHistoryRequest$json,
  '.agriculture.weather.v1.BackfillHistoryResponse':
      BackfillHistoryResponse$json,
  '.agriculture.weather.v1.ListWeatherAlertsRequest':
      ListWeatherAlertsRequest$json,
  '.agriculture.weather.v1.ListWeatherAlertsResponse':
      ListWeatherAlertsResponse$json,
  '.agriculture.weather.v1.WeatherAlert': WeatherAlert$json,
};

/// Descriptor for `WeatherService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List weatherServiceDescriptor = $convert.base64Decode(
    'Cg5XZWF0aGVyU2VydmljZRKEAQoVUmVnaXN0ZXJGaWVsZExvY2F0aW9uEjQuYWdyaWN1bHR1cm'
    'Uud2VhdGhlci52MS5SZWdpc3RlckZpZWxkTG9jYXRpb25SZXF1ZXN0GjUuYWdyaWN1bHR1cmUu'
    'd2VhdGhlci52MS5SZWdpc3RlckZpZWxkTG9jYXRpb25SZXNwb25zZRJ1ChBHZXRGaWVsZExvY2'
    'F0aW9uEi8uYWdyaWN1bHR1cmUud2VhdGhlci52MS5HZXRGaWVsZExvY2F0aW9uUmVxdWVzdBow'
    'LmFncmljdWx0dXJlLndlYXRoZXIudjEuR2V0RmllbGRMb2NhdGlvblJlc3BvbnNlEnsKEkxpc3'
    'RGaWVsZExvY2F0aW9ucxIxLmFncmljdWx0dXJlLndlYXRoZXIudjEuTGlzdEZpZWxkTG9jYXRp'
    'b25zUmVxdWVzdBoyLmFncmljdWx0dXJlLndlYXRoZXIudjEuTGlzdEZpZWxkTG9jYXRpb25zUm'
    'VzcG9uc2USeAoRR2V0Q3VycmVudFdlYXRoZXISMC5hZ3JpY3VsdHVyZS53ZWF0aGVyLnYxLkdl'
    'dEN1cnJlbnRXZWF0aGVyUmVxdWVzdBoxLmFncmljdWx0dXJlLndlYXRoZXIudjEuR2V0Q3Vycm'
    'VudFdlYXRoZXJSZXNwb25zZRJmCgtHZXRGb3JlY2FzdBIqLmFncmljdWx0dXJlLndlYXRoZXIu'
    'djEuR2V0Rm9yZWNhc3RSZXF1ZXN0GisuYWdyaWN1bHR1cmUud2VhdGhlci52MS5HZXRGb3JlY2'
    'FzdFJlc3BvbnNlEnUKEExpc3RPYnNlcnZhdGlvbnMSLy5hZ3JpY3VsdHVyZS53ZWF0aGVyLnYx'
    'Lkxpc3RPYnNlcnZhdGlvbnNSZXF1ZXN0GjAuYWdyaWN1bHR1cmUud2VhdGhlci52MS5MaXN0T2'
    'JzZXJ2YXRpb25zUmVzcG9uc2USbwoOR2V0QWdyb01ldHJpY3MSLS5hZ3JpY3VsdHVyZS53ZWF0'
    'aGVyLnYxLkdldEFncm9NZXRyaWNzUmVxdWVzdBouLmFncmljdWx0dXJlLndlYXRoZXIudjEuR2'
    'V0QWdyb01ldHJpY3NSZXNwb25zZRJ+ChNSZWZyZXNoRmllbGRXZWF0aGVyEjIuYWdyaWN1bHR1'
    'cmUud2VhdGhlci52MS5SZWZyZXNoRmllbGRXZWF0aGVyUmVxdWVzdBozLmFncmljdWx0dXJlLn'
    'dlYXRoZXIudjEuUmVmcmVzaEZpZWxkV2VhdGhlclJlc3BvbnNlEnIKD0JhY2tmaWxsSGlzdG9y'
    'eRIuLmFncmljdWx0dXJlLndlYXRoZXIudjEuQmFja2ZpbGxIaXN0b3J5UmVxdWVzdBovLmFncm'
    'ljdWx0dXJlLndlYXRoZXIudjEuQmFja2ZpbGxIaXN0b3J5UmVzcG9uc2USeAoRTGlzdFdlYXRo'
    'ZXJBbGVydHMSMC5hZ3JpY3VsdHVyZS53ZWF0aGVyLnYxLkxpc3RXZWF0aGVyQWxlcnRzUmVxdW'
    'VzdBoxLmFncmljdWx0dXJlLndlYXRoZXIudjEuTGlzdFdlYXRoZXJBbGVydHNSZXNwb25zZQ==');
