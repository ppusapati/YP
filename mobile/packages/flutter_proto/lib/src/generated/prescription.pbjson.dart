// This is a generated file - do not edit.
//
// Generated from prescription.proto.

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

@$core.Deprecated('Use prescriptionTypeDescriptor instead')
const PrescriptionType$json = {
  '1': 'PrescriptionType',
  '2': [
    {'1': 'PRESCRIPTION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'PRESCRIPTION_TYPE_FERTILIZER', '2': 1},
    {'1': 'PRESCRIPTION_TYPE_IRRIGATION', '2': 2},
    {'1': 'PRESCRIPTION_TYPE_SEEDING', '2': 3},
    {'1': 'PRESCRIPTION_TYPE_LIMING', '2': 4},
  ],
};

/// Descriptor for `PrescriptionType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List prescriptionTypeDescriptor = $convert.base64Decode(
    'ChBQcmVzY3JpcHRpb25UeXBlEiEKHVBSRVNDUklQVElPTl9UWVBFX1VOU1BFQ0lGSUVEEAASIA'
    'ocUFJFU0NSSVBUSU9OX1RZUEVfRkVSVElMSVpFUhABEiAKHFBSRVNDUklQVElPTl9UWVBFX0lS'
    'UklHQVRJT04QAhIdChlQUkVTQ1JJUFRJT05fVFlQRV9TRUVESU5HEAMSHAoYUFJFU0NSSVBUSU'
    '9OX1RZUEVfTElNSU5HEAQ=');

@$core.Deprecated('Use rateRowDescriptor instead')
const RateRow$json = {
  '1': 'RateRow',
  '2': [
    {'1': 'values', '3': 1, '4': 3, '5': 1, '10': 'values'},
  ],
};

/// Descriptor for `RateRow`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rateRowDescriptor =
    $convert.base64Decode('CgdSYXRlUm93EhYKBnZhbHVlcxgBIAMoAVIGdmFsdWVz');

@$core.Deprecated('Use soilDataRowDescriptor instead')
const SoilDataRow$json = {
  '1': 'SoilDataRow',
  '2': [
    {'1': 'values', '3': 1, '4': 3, '5': 1, '10': 'values'},
  ],
};

/// Descriptor for `SoilDataRow`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List soilDataRowDescriptor = $convert
    .base64Decode('CgtTb2lsRGF0YVJvdxIWCgZ2YWx1ZXMYASADKAFSBnZhbHVlcw==');

@$core.Deprecated('Use prescriptionMapDescriptor instead')
const PrescriptionMap$json = {
  '1': 'PrescriptionMap',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'prescription_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.prescription.v1.PrescriptionType',
      '10': 'prescriptionType'
    },
    {'1': 'unit', '3': 3, '4': 1, '5': 9, '10': 'unit'},
    {
      '1': 'rates',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.agriculture.prescription.v1.RateRow',
      '10': 'rates'
    },
    {'1': 'avg_rate', '3': 5, '4': 1, '5': 1, '10': 'avgRate'},
  ],
};

/// Descriptor for `PrescriptionMap`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List prescriptionMapDescriptor = $convert.base64Decode(
    'Cg9QcmVzY3JpcHRpb25NYXASDgoCaWQYASABKAlSAmlkEloKEXByZXNjcmlwdGlvbl90eXBlGA'
    'IgASgOMi0uYWdyaWN1bHR1cmUucHJlc2NyaXB0aW9uLnYxLlByZXNjcmlwdGlvblR5cGVSEHBy'
    'ZXNjcmlwdGlvblR5cGUSEgoEdW5pdBgDIAEoCVIEdW5pdBI6CgVyYXRlcxgEIAMoCzIkLmFncm'
    'ljdWx0dXJlLnByZXNjcmlwdGlvbi52MS5SYXRlUm93UgVyYXRlcxIZCghhdmdfcmF0ZRgFIAEo'
    'AVIHYXZnUmF0ZQ==');

@$core.Deprecated('Use zoneSummaryDescriptor instead')
const ZoneSummary$json = {
  '1': 'ZoneSummary',
  '2': [
    {'1': 'zone', '3': 1, '4': 1, '5': 9, '10': 'zone'},
    {
      '1': 'prescription_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.prescription.v1.PrescriptionType',
      '10': 'prescriptionType'
    },
    {'1': 'area_hectares', '3': 3, '4': 1, '5': 1, '10': 'areaHectares'},
    {'1': 'min_rate', '3': 4, '4': 1, '5': 1, '10': 'minRate'},
    {'1': 'mean_rate', '3': 5, '4': 1, '5': 1, '10': 'meanRate'},
    {'1': 'max_rate', '3': 6, '4': 1, '5': 1, '10': 'maxRate'},
    {'1': 'total_amount', '3': 7, '4': 1, '5': 1, '10': 'totalAmount'},
  ],
};

/// Descriptor for `ZoneSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List zoneSummaryDescriptor = $convert.base64Decode(
    'Cgtab25lU3VtbWFyeRISCgR6b25lGAEgASgJUgR6b25lEloKEXByZXNjcmlwdGlvbl90eXBlGA'
    'IgASgOMi0uYWdyaWN1bHR1cmUucHJlc2NyaXB0aW9uLnYxLlByZXNjcmlwdGlvblR5cGVSEHBy'
    'ZXNjcmlwdGlvblR5cGUSIwoNYXJlYV9oZWN0YXJlcxgDIAEoAVIMYXJlYUhlY3RhcmVzEhkKCG'
    '1pbl9yYXRlGAQgASgBUgdtaW5SYXRlEhsKCW1lYW5fcmF0ZRgFIAEoAVIIbWVhblJhdGUSGQoI'
    'bWF4X3JhdGUYBiABKAFSB21heFJhdGUSIQoMdG90YWxfYW1vdW50GAcgASgBUgt0b3RhbEFtb3'
    'VudA==');

@$core.Deprecated('Use prescriptionBundleDescriptor instead')
const PrescriptionBundle$json = {
  '1': 'PrescriptionBundle',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'field_name', '3': 3, '4': 1, '5': 9, '10': 'fieldName'},
    {'1': 'crop_type', '3': 4, '4': 1, '5': 9, '10': 'cropType'},
    {'1': 'target_yield', '3': 5, '4': 1, '5': 1, '10': 'targetYield'},
    {'1': 'created_at', '3': 6, '4': 1, '5': 9, '10': 'createdAt'},
    {
      '1': 'estimated_cost_savings',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'estimatedCostSavings'
    },
    {
      '1': 'estimated_yield_gain',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'estimatedYieldGain'
    },
    {
      '1': 'prescriptions',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.agriculture.prescription.v1.PrescriptionMap',
      '10': 'prescriptions'
    },
    {
      '1': 'zone_summaries',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.agriculture.prescription.v1.ZoneSummary',
      '10': 'zoneSummaries'
    },
  ],
};

/// Descriptor for `PrescriptionBundle`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List prescriptionBundleDescriptor = $convert.base64Decode(
    'ChJQcmVzY3JpcHRpb25CdW5kbGUSDgoCaWQYASABKAlSAmlkEhkKCGZpZWxkX2lkGAIgASgJUg'
    'dmaWVsZElkEh0KCmZpZWxkX25hbWUYAyABKAlSCWZpZWxkTmFtZRIbCgljcm9wX3R5cGUYBCAB'
    'KAlSCGNyb3BUeXBlEiEKDHRhcmdldF95aWVsZBgFIAEoAVILdGFyZ2V0WWllbGQSHQoKY3JlYX'
    'RlZF9hdBgGIAEoCVIJY3JlYXRlZEF0EjQKFmVzdGltYXRlZF9jb3N0X3NhdmluZ3MYByABKAFS'
    'FGVzdGltYXRlZENvc3RTYXZpbmdzEjAKFGVzdGltYXRlZF95aWVsZF9nYWluGAggASgBUhJlc3'
    'RpbWF0ZWRZaWVsZEdhaW4SUgoNcHJlc2NyaXB0aW9ucxgJIAMoCzIsLmFncmljdWx0dXJlLnBy'
    'ZXNjcmlwdGlvbi52MS5QcmVzY3JpcHRpb25NYXBSDXByZXNjcmlwdGlvbnMSTwoOem9uZV9zdW'
    '1tYXJpZXMYCiADKAsyKC5hZ3JpY3VsdHVyZS5wcmVzY3JpcHRpb24udjEuWm9uZVN1bW1hcnlS'
    'DXpvbmVTdW1tYXJpZXM=');

@$core.Deprecated('Use listPrescriptionsRequestDescriptor instead')
const ListPrescriptionsRequest$json = {
  '1': 'ListPrescriptionsRequest',
  '2': [
    {
      '1': 'prescription_type',
      '3': 1,
      '4': 1,
      '5': 14,
      '6': '.agriculture.prescription.v1.PrescriptionType',
      '10': 'prescriptionType'
    },
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 3, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListPrescriptionsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPrescriptionsRequestDescriptor = $convert.base64Decode(
    'ChhMaXN0UHJlc2NyaXB0aW9uc1JlcXVlc3QSWgoRcHJlc2NyaXB0aW9uX3R5cGUYASABKA4yLS'
    '5hZ3JpY3VsdHVyZS5wcmVzY3JpcHRpb24udjEuUHJlc2NyaXB0aW9uVHlwZVIQcHJlc2NyaXB0'
    'aW9uVHlwZRIbCglwYWdlX3NpemUYAiABKAVSCHBhZ2VTaXplEh0KCnBhZ2VfdG9rZW4YAyABKA'
    'lSCXBhZ2VUb2tlbg==');

@$core.Deprecated('Use listPrescriptionsResponseDescriptor instead')
const ListPrescriptionsResponse$json = {
  '1': 'ListPrescriptionsResponse',
  '2': [
    {
      '1': 'prescriptions',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.prescription.v1.PrescriptionBundle',
      '10': 'prescriptions'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
  ],
};

/// Descriptor for `ListPrescriptionsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPrescriptionsResponseDescriptor = $convert.base64Decode(
    'ChlMaXN0UHJlc2NyaXB0aW9uc1Jlc3BvbnNlElUKDXByZXNjcmlwdGlvbnMYASADKAsyLy5hZ3'
    'JpY3VsdHVyZS5wcmVzY3JpcHRpb24udjEuUHJlc2NyaXB0aW9uQnVuZGxlUg1wcmVzY3JpcHRp'
    'b25zEiYKD25leHRfcGFnZV90b2tlbhgCIAEoCVINbmV4dFBhZ2VUb2tlbg==');

@$core.Deprecated('Use getPrescriptionRequestDescriptor instead')
const GetPrescriptionRequest$json = {
  '1': 'GetPrescriptionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetPrescriptionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPrescriptionRequestDescriptor = $convert
    .base64Decode('ChZHZXRQcmVzY3JpcHRpb25SZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use getPrescriptionResponseDescriptor instead')
const GetPrescriptionResponse$json = {
  '1': 'GetPrescriptionResponse',
  '2': [
    {
      '1': 'prescription',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.prescription.v1.PrescriptionBundle',
      '10': 'prescription'
    },
  ],
};

/// Descriptor for `GetPrescriptionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPrescriptionResponseDescriptor = $convert.base64Decode(
    'ChdHZXRQcmVzY3JpcHRpb25SZXNwb25zZRJTCgxwcmVzY3JpcHRpb24YASABKAsyLy5hZ3JpY3'
    'VsdHVyZS5wcmVzY3JpcHRpb24udjEuUHJlc2NyaXB0aW9uQnVuZGxlUgxwcmVzY3JpcHRpb24=');

@$core.Deprecated('Use generatePrescriptionRequestDescriptor instead')
const GeneratePrescriptionRequest$json = {
  '1': 'GeneratePrescriptionRequest',
  '2': [
    {'1': 'field_id', '3': 1, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_type', '3': 2, '4': 1, '5': 9, '10': 'cropType'},
    {'1': 'target_yield', '3': 3, '4': 1, '5': 1, '10': 'targetYield'},
    {
      '1': 'soil_data',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.agriculture.prescription.v1.SoilDataRow',
      '10': 'soilData'
    },
  ],
};

/// Descriptor for `GeneratePrescriptionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generatePrescriptionRequestDescriptor = $convert.base64Decode(
    'ChtHZW5lcmF0ZVByZXNjcmlwdGlvblJlcXVlc3QSGQoIZmllbGRfaWQYASABKAlSB2ZpZWxkSW'
    'QSGwoJY3JvcF90eXBlGAIgASgJUghjcm9wVHlwZRIhCgx0YXJnZXRfeWllbGQYAyABKAFSC3Rh'
    'cmdldFlpZWxkEkUKCXNvaWxfZGF0YRgEIAMoCzIoLmFncmljdWx0dXJlLnByZXNjcmlwdGlvbi'
    '52MS5Tb2lsRGF0YVJvd1IIc29pbERhdGE=');

@$core.Deprecated('Use generatePrescriptionResponseDescriptor instead')
const GeneratePrescriptionResponse$json = {
  '1': 'GeneratePrescriptionResponse',
  '2': [
    {
      '1': 'prescription',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.prescription.v1.PrescriptionBundle',
      '10': 'prescription'
    },
  ],
};

/// Descriptor for `GeneratePrescriptionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generatePrescriptionResponseDescriptor =
    $convert.base64Decode(
        'ChxHZW5lcmF0ZVByZXNjcmlwdGlvblJlc3BvbnNlElMKDHByZXNjcmlwdGlvbhgBIAEoCzIvLm'
        'FncmljdWx0dXJlLnByZXNjcmlwdGlvbi52MS5QcmVzY3JpcHRpb25CdW5kbGVSDHByZXNjcmlw'
        'dGlvbg==');

@$core.Deprecated('Use exportPrescriptionRequestDescriptor instead')
const ExportPrescriptionRequest$json = {
  '1': 'ExportPrescriptionRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'format', '3': 2, '4': 1, '5': 9, '10': 'format'},
  ],
};

/// Descriptor for `ExportPrescriptionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportPrescriptionRequestDescriptor =
    $convert.base64Decode(
        'ChlFeHBvcnRQcmVzY3JpcHRpb25SZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIWCgZmb3JtYXQYAi'
        'ABKAlSBmZvcm1hdA==');

@$core.Deprecated('Use exportPrescriptionResponseDescriptor instead')
const ExportPrescriptionResponse$json = {
  '1': 'ExportPrescriptionResponse',
  '2': [
    {'1': 'download_url', '3': 1, '4': 1, '5': 9, '10': 'downloadUrl'},
    {'1': 'file_name', '3': 2, '4': 1, '5': 9, '10': 'fileName'},
  ],
};

/// Descriptor for `ExportPrescriptionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List exportPrescriptionResponseDescriptor =
    $convert.base64Decode(
        'ChpFeHBvcnRQcmVzY3JpcHRpb25SZXNwb25zZRIhCgxkb3dubG9hZF91cmwYASABKAlSC2Rvd2'
        '5sb2FkVXJsEhsKCWZpbGVfbmFtZRgCIAEoCVIIZmlsZU5hbWU=');

const $core.Map<$core.String, $core.dynamic> PrescriptionServiceBase$json = {
  '1': 'PrescriptionService',
  '2': [
    {
      '1': 'ListPrescriptions',
      '2': '.agriculture.prescription.v1.ListPrescriptionsRequest',
      '3': '.agriculture.prescription.v1.ListPrescriptionsResponse'
    },
    {
      '1': 'GetPrescription',
      '2': '.agriculture.prescription.v1.GetPrescriptionRequest',
      '3': '.agriculture.prescription.v1.GetPrescriptionResponse'
    },
    {
      '1': 'GeneratePrescription',
      '2': '.agriculture.prescription.v1.GeneratePrescriptionRequest',
      '3': '.agriculture.prescription.v1.GeneratePrescriptionResponse'
    },
    {
      '1': 'ExportPrescription',
      '2': '.agriculture.prescription.v1.ExportPrescriptionRequest',
      '3': '.agriculture.prescription.v1.ExportPrescriptionResponse'
    },
  ],
};

@$core.Deprecated('Use prescriptionServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    PrescriptionServiceBase$messageJson = {
  '.agriculture.prescription.v1.ListPrescriptionsRequest':
      ListPrescriptionsRequest$json,
  '.agriculture.prescription.v1.ListPrescriptionsResponse':
      ListPrescriptionsResponse$json,
  '.agriculture.prescription.v1.PrescriptionBundle': PrescriptionBundle$json,
  '.agriculture.prescription.v1.PrescriptionMap': PrescriptionMap$json,
  '.agriculture.prescription.v1.RateRow': RateRow$json,
  '.agriculture.prescription.v1.ZoneSummary': ZoneSummary$json,
  '.agriculture.prescription.v1.GetPrescriptionRequest':
      GetPrescriptionRequest$json,
  '.agriculture.prescription.v1.GetPrescriptionResponse':
      GetPrescriptionResponse$json,
  '.agriculture.prescription.v1.GeneratePrescriptionRequest':
      GeneratePrescriptionRequest$json,
  '.agriculture.prescription.v1.SoilDataRow': SoilDataRow$json,
  '.agriculture.prescription.v1.GeneratePrescriptionResponse':
      GeneratePrescriptionResponse$json,
  '.agriculture.prescription.v1.ExportPrescriptionRequest':
      ExportPrescriptionRequest$json,
  '.agriculture.prescription.v1.ExportPrescriptionResponse':
      ExportPrescriptionResponse$json,
};

/// Descriptor for `PrescriptionService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List prescriptionServiceDescriptor = $convert.base64Decode(
    'ChNQcmVzY3JpcHRpb25TZXJ2aWNlEoIBChFMaXN0UHJlc2NyaXB0aW9ucxI1LmFncmljdWx0dX'
    'JlLnByZXNjcmlwdGlvbi52MS5MaXN0UHJlc2NyaXB0aW9uc1JlcXVlc3QaNi5hZ3JpY3VsdHVy'
    'ZS5wcmVzY3JpcHRpb24udjEuTGlzdFByZXNjcmlwdGlvbnNSZXNwb25zZRJ8Cg9HZXRQcmVzY3'
    'JpcHRpb24SMy5hZ3JpY3VsdHVyZS5wcmVzY3JpcHRpb24udjEuR2V0UHJlc2NyaXB0aW9uUmVx'
    'dWVzdBo0LmFncmljdWx0dXJlLnByZXNjcmlwdGlvbi52MS5HZXRQcmVzY3JpcHRpb25SZXNwb2'
    '5zZRKLAQoUR2VuZXJhdGVQcmVzY3JpcHRpb24SOC5hZ3JpY3VsdHVyZS5wcmVzY3JpcHRpb24u'
    'djEuR2VuZXJhdGVQcmVzY3JpcHRpb25SZXF1ZXN0GjkuYWdyaWN1bHR1cmUucHJlc2NyaXB0aW'
    '9uLnYxLkdlbmVyYXRlUHJlc2NyaXB0aW9uUmVzcG9uc2UShQEKEkV4cG9ydFByZXNjcmlwdGlv'
    'bhI2LmFncmljdWx0dXJlLnByZXNjcmlwdGlvbi52MS5FeHBvcnRQcmVzY3JpcHRpb25SZXF1ZX'
    'N0GjcuYWdyaWN1bHR1cmUucHJlc2NyaXB0aW9uLnYxLkV4cG9ydFByZXNjcmlwdGlvblJlc3Bv'
    'bnNl');
