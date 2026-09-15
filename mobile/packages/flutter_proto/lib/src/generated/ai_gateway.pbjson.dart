// This is a generated file - do not edit.
//
// Generated from ai_gateway.proto.

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

@$core.Deprecated('Use sampleContextDescriptor instead')
const SampleContext$json = {
  '1': 'SampleContext',
  '2': [
    {'1': 'tenant_id', '3': 1, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 2, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 3, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop', '3': 4, '4': 1, '5': 9, '10': 'crop'},
    {'1': 'latitude', '3': 5, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 6, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'submitted_by', '3': 7, '4': 1, '5': 9, '10': 'submittedBy'},
  ],
};

/// Descriptor for `SampleContext`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sampleContextDescriptor = $convert.base64Decode(
    'Cg1TYW1wbGVDb250ZXh0EhsKCXRlbmFudF9pZBgBIAEoCVIIdGVuYW50SWQSFwoHZmFybV9pZB'
    'gCIAEoCVIGZmFybUlkEhkKCGZpZWxkX2lkGAMgASgJUgdmaWVsZElkEhIKBGNyb3AYBCABKAlS'
    'BGNyb3ASGgoIbGF0aXR1ZGUYBSABKAFSCGxhdGl0dWRlEhwKCWxvbmdpdHVkZRgGIAEoAVIJbG'
    '9uZ2l0dWRlEiEKDHN1Ym1pdHRlZF9ieRgHIAEoCVILc3VibWl0dGVkQnk=');

@$core.Deprecated('Use diagnoseImageRequestDescriptor instead')
const DiagnoseImageRequest$json = {
  '1': 'DiagnoseImageRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'images',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.ImageData',
      '10': 'images'
    },
    {'1': 'plant_species_id', '3': 3, '4': 1, '5': 9, '10': 'plantSpeciesId'},
    {'1': 'operations', '3': 4, '4': 3, '5': 9, '10': 'operations'},
    {
      '1': 'context',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.SampleContext',
      '10': 'context'
    },
  ],
};

/// Descriptor for `DiagnoseImageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diagnoseImageRequestDescriptor = $convert.base64Decode(
    'ChREaWFnbm9zZUltYWdlUmVxdWVzdBIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZXF1ZXN0SWQSNA'
    'oGaW1hZ2VzGAIgAygLMhwuYWdyaWN1bHR1cmUuYWkudjEuSW1hZ2VEYXRhUgZpbWFnZXMSKAoQ'
    'cGxhbnRfc3BlY2llc19pZBgDIAEoCVIOcGxhbnRTcGVjaWVzSWQSHgoKb3BlcmF0aW9ucxgEIA'
    'MoCVIKb3BlcmF0aW9ucxI6Cgdjb250ZXh0GAUgASgLMiAuYWdyaWN1bHR1cmUuYWkudjEuU2Ft'
    'cGxlQ29udGV4dFIHY29udGV4dA==');

@$core.Deprecated('Use explanationDescriptor instead')
const Explanation$json = {
  '1': 'Explanation',
  '2': [
    {'1': 'task', '3': 1, '4': 1, '5': 9, '10': 'task'},
    {'1': 'class_name', '3': 2, '4': 1, '5': 9, '10': 'className'},
    {'1': 'heatmap_png', '3': 3, '4': 1, '5': 12, '10': 'heatmapPng'},
    {'1': 'heatmap_width', '3': 4, '4': 1, '5': 5, '10': 'heatmapWidth'},
    {'1': 'heatmap_height', '3': 5, '4': 1, '5': 5, '10': 'heatmapHeight'},
    {'1': 'focus_x', '3': 6, '4': 1, '5': 1, '10': 'focusX'},
    {'1': 'focus_y', '3': 7, '4': 1, '5': 1, '10': 'focusY'},
    {'1': 'focus_width', '3': 8, '4': 1, '5': 1, '10': 'focusWidth'},
    {'1': 'focus_height', '3': 9, '4': 1, '5': 1, '10': 'focusHeight'},
    {'1': 'focus_coverage', '3': 10, '4': 1, '5': 1, '10': 'focusCoverage'},
    {'1': 'summary', '3': 11, '4': 1, '5': 9, '10': 'summary'},
    {'1': 'method', '3': 12, '4': 1, '5': 9, '10': 'method'},
    {'1': 'localised', '3': 13, '4': 1, '5': 8, '10': 'localised'},
  ],
};

/// Descriptor for `Explanation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List explanationDescriptor = $convert.base64Decode(
    'CgtFeHBsYW5hdGlvbhISCgR0YXNrGAEgASgJUgR0YXNrEh0KCmNsYXNzX25hbWUYAiABKAlSCW'
    'NsYXNzTmFtZRIfCgtoZWF0bWFwX3BuZxgDIAEoDFIKaGVhdG1hcFBuZxIjCg1oZWF0bWFwX3dp'
    'ZHRoGAQgASgFUgxoZWF0bWFwV2lkdGgSJQoOaGVhdG1hcF9oZWlnaHQYBSABKAVSDWhlYXRtYX'
    'BIZWlnaHQSFwoHZm9jdXNfeBgGIAEoAVIGZm9jdXNYEhcKB2ZvY3VzX3kYByABKAFSBmZvY3Vz'
    'WRIfCgtmb2N1c193aWR0aBgIIAEoAVIKZm9jdXNXaWR0aBIhCgxmb2N1c19oZWlnaHQYCSABKA'
    'FSC2ZvY3VzSGVpZ2h0EiUKDmZvY3VzX2NvdmVyYWdlGAogASgBUg1mb2N1c0NvdmVyYWdlEhgK'
    'B3N1bW1hcnkYCyABKAlSB3N1bW1hcnkSFgoGbWV0aG9kGAwgASgJUgZtZXRob2QSHAoJbG9jYW'
    'xpc2VkGA0gASgIUglsb2NhbGlzZWQ=');

@$core.Deprecated('Use diagnoseImageResponseDescriptor instead')
const DiagnoseImageResponse$json = {
  '1': 'DiagnoseImageResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'diseases',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.DiseaseDetection',
      '10': 'diseases'
    },
    {
      '1': 'overall_health_score',
      '3': 3,
      '4': 1,
      '5': 1,
      '10': 'overallHealthScore'
    },
    {'1': 'summary', '3': 4, '4': 1, '5': 9, '10': 'summary'},
    {'1': 'model_version', '3': 5, '4': 1, '5': 9, '10': 'modelVersion'},
    {
      '1': 'processing_time_ms',
      '3': 6,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
    {
      '1': 'explanations',
      '3': 7,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.Explanation',
      '10': 'explanations'
    },
  ],
};

/// Descriptor for `DiagnoseImageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diagnoseImageResponseDescriptor = $convert.base64Decode(
    'ChVEaWFnbm9zZUltYWdlUmVzcG9uc2USHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdWVzdElkEj'
    '8KCGRpc2Vhc2VzGAIgAygLMiMuYWdyaWN1bHR1cmUuYWkudjEuRGlzZWFzZURldGVjdGlvblII'
    'ZGlzZWFzZXMSMAoUb3ZlcmFsbF9oZWFsdGhfc2NvcmUYAyABKAFSEm92ZXJhbGxIZWFsdGhTY2'
    '9yZRIYCgdzdW1tYXJ5GAQgASgJUgdzdW1tYXJ5EiMKDW1vZGVsX3ZlcnNpb24YBSABKAlSDG1v'
    'ZGVsVmVyc2lvbhIsChJwcm9jZXNzaW5nX3RpbWVfbXMYBiABKANSEHByb2Nlc3NpbmdUaW1lTX'
    'MSQgoMZXhwbGFuYXRpb25zGAcgAygLMh4uYWdyaWN1bHR1cmUuYWkudjEuRXhwbGFuYXRpb25S'
    'DGV4cGxhbmF0aW9ucw==');

@$core.Deprecated('Use diseaseDetectionDescriptor instead')
const DiseaseDetection$json = {
  '1': 'DiseaseDetection',
  '2': [
    {'1': 'disease_id', '3': 1, '4': 1, '5': 9, '10': 'diseaseId'},
    {'1': 'disease_name', '3': 2, '4': 1, '5': 9, '10': 'diseaseName'},
    {'1': 'scientific_name', '3': 3, '4': 1, '5': 9, '10': 'scientificName'},
    {'1': 'confidence_score', '3': 4, '4': 1, '5': 1, '10': 'confidenceScore'},
    {'1': 'severity', '3': 5, '4': 1, '5': 9, '10': 'severity'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {'1': 'symptoms', '3': 7, '4': 1, '5': 9, '10': 'symptoms'},
    {
      '1': 'treatment_options',
      '3': 8,
      '4': 3,
      '5': 9,
      '10': 'treatmentOptions'
    },
    {'1': 'prevention', '3': 9, '4': 1, '5': 9, '10': 'prevention'},
  ],
};

/// Descriptor for `DiseaseDetection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diseaseDetectionDescriptor = $convert.base64Decode(
    'ChBEaXNlYXNlRGV0ZWN0aW9uEh0KCmRpc2Vhc2VfaWQYASABKAlSCWRpc2Vhc2VJZBIhCgxkaX'
    'NlYXNlX25hbWUYAiABKAlSC2Rpc2Vhc2VOYW1lEicKD3NjaWVudGlmaWNfbmFtZRgDIAEoCVIO'
    'c2NpZW50aWZpY05hbWUSKQoQY29uZmlkZW5jZV9zY29yZRgEIAEoAVIPY29uZmlkZW5jZVNjb3'
    'JlEhoKCHNldmVyaXR5GAUgASgJUghzZXZlcml0eRIgCgtkZXNjcmlwdGlvbhgGIAEoCVILZGVz'
    'Y3JpcHRpb24SGgoIc3ltcHRvbXMYByABKAlSCHN5bXB0b21zEisKEXRyZWF0bWVudF9vcHRpb2'
    '5zGAggAygJUhB0cmVhdG1lbnRPcHRpb25zEh4KCnByZXZlbnRpb24YCSABKAlSCnByZXZlbnRp'
    'b24=');

@$core.Deprecated('Use detectPestsRequestDescriptor instead')
const DetectPestsRequest$json = {
  '1': 'DetectPestsRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'images',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.ImageData',
      '10': 'images'
    },
    {'1': 'plant_species_id', '3': 3, '4': 1, '5': 9, '10': 'plantSpeciesId'},
    {
      '1': 'context',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.SampleContext',
      '10': 'context'
    },
  ],
};

/// Descriptor for `DetectPestsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectPestsRequestDescriptor = $convert.base64Decode(
    'ChJEZXRlY3RQZXN0c1JlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdWVzdElkEjQKBm'
    'ltYWdlcxgCIAMoCzIcLmFncmljdWx0dXJlLmFpLnYxLkltYWdlRGF0YVIGaW1hZ2VzEigKEHBs'
    'YW50X3NwZWNpZXNfaWQYAyABKAlSDnBsYW50U3BlY2llc0lkEjoKB2NvbnRleHQYBCABKAsyIC'
    '5hZ3JpY3VsdHVyZS5haS52MS5TYW1wbGVDb250ZXh0Ugdjb250ZXh0');

@$core.Deprecated('Use detectPestsResponseDescriptor instead')
const DetectPestsResponse$json = {
  '1': 'DetectPestsResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'pests',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.PestDetection',
      '10': 'pests'
    },
    {'1': 'model_version', '3': 3, '4': 1, '5': 9, '10': 'modelVersion'},
    {
      '1': 'processing_time_ms',
      '3': 4,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
    {
      '1': 'explanations',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.Explanation',
      '10': 'explanations'
    },
  ],
};

/// Descriptor for `DetectPestsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectPestsResponseDescriptor = $convert.base64Decode(
    'ChNEZXRlY3RQZXN0c1Jlc3BvbnNlEh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcXVlc3RJZBI2Cg'
    'VwZXN0cxgCIAMoCzIgLmFncmljdWx0dXJlLmFpLnYxLlBlc3REZXRlY3Rpb25SBXBlc3RzEiMK'
    'DW1vZGVsX3ZlcnNpb24YAyABKAlSDG1vZGVsVmVyc2lvbhIsChJwcm9jZXNzaW5nX3RpbWVfbX'
    'MYBCABKANSEHByb2Nlc3NpbmdUaW1lTXMSQgoMZXhwbGFuYXRpb25zGAUgAygLMh4uYWdyaWN1'
    'bHR1cmUuYWkudjEuRXhwbGFuYXRpb25SDGV4cGxhbmF0aW9ucw==');

@$core.Deprecated('Use pestDetectionDescriptor instead')
const PestDetection$json = {
  '1': 'PestDetection',
  '2': [
    {'1': 'pest_id', '3': 1, '4': 1, '5': 9, '10': 'pestId'},
    {'1': 'pest_name', '3': 2, '4': 1, '5': 9, '10': 'pestName'},
    {'1': 'scientific_name', '3': 3, '4': 1, '5': 9, '10': 'scientificName'},
    {'1': 'confidence_score', '3': 4, '4': 1, '5': 1, '10': 'confidenceScore'},
    {'1': 'damage_level', '3': 5, '4': 1, '5': 9, '10': 'damageLevel'},
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {'1': 'damage_pattern', '3': 7, '4': 1, '5': 9, '10': 'damagePattern'},
    {'1': 'control_methods', '3': 8, '4': 3, '5': 9, '10': 'controlMethods'},
  ],
};

/// Descriptor for `PestDetection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pestDetectionDescriptor = $convert.base64Decode(
    'Cg1QZXN0RGV0ZWN0aW9uEhcKB3Blc3RfaWQYASABKAlSBnBlc3RJZBIbCglwZXN0X25hbWUYAi'
    'ABKAlSCHBlc3ROYW1lEicKD3NjaWVudGlmaWNfbmFtZRgDIAEoCVIOc2NpZW50aWZpY05hbWUS'
    'KQoQY29uZmlkZW5jZV9zY29yZRgEIAEoAVIPY29uZmlkZW5jZVNjb3JlEiEKDGRhbWFnZV9sZX'
    'ZlbBgFIAEoCVILZGFtYWdlTGV2ZWwSIAoLZGVzY3JpcHRpb24YBiABKAlSC2Rlc2NyaXB0aW9u'
    'EiUKDmRhbWFnZV9wYXR0ZXJuGAcgASgJUg1kYW1hZ2VQYXR0ZXJuEicKD2NvbnRyb2xfbWV0aG'
    '9kcxgIIAMoCVIOY29udHJvbE1ldGhvZHM=');

@$core.Deprecated('Use detectNutrientDeficiencyRequestDescriptor instead')
const DetectNutrientDeficiencyRequest$json = {
  '1': 'DetectNutrientDeficiencyRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'images',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.ImageData',
      '10': 'images'
    },
    {'1': 'plant_species_id', '3': 3, '4': 1, '5': 9, '10': 'plantSpeciesId'},
    {
      '1': 'context',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.SampleContext',
      '10': 'context'
    },
  ],
};

/// Descriptor for `DetectNutrientDeficiencyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectNutrientDeficiencyRequestDescriptor = $convert.base64Decode(
    'Ch9EZXRlY3ROdXRyaWVudERlZmljaWVuY3lSZXF1ZXN0Eh0KCnJlcXVlc3RfaWQYASABKAlSCX'
    'JlcXVlc3RJZBI0CgZpbWFnZXMYAiADKAsyHC5hZ3JpY3VsdHVyZS5haS52MS5JbWFnZURhdGFS'
    'BmltYWdlcxIoChBwbGFudF9zcGVjaWVzX2lkGAMgASgJUg5wbGFudFNwZWNpZXNJZBI6Cgdjb2'
    '50ZXh0GAQgASgLMiAuYWdyaWN1bHR1cmUuYWkudjEuU2FtcGxlQ29udGV4dFIHY29udGV4dA==');

@$core.Deprecated('Use detectNutrientDeficiencyResponseDescriptor instead')
const DetectNutrientDeficiencyResponse$json = {
  '1': 'DetectNutrientDeficiencyResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'deficiencies',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.NutrientDeficiency',
      '10': 'deficiencies'
    },
    {'1': 'model_version', '3': 3, '4': 1, '5': 9, '10': 'modelVersion'},
    {
      '1': 'processing_time_ms',
      '3': 4,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
    {
      '1': 'explanations',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.Explanation',
      '10': 'explanations'
    },
  ],
};

/// Descriptor for `DetectNutrientDeficiencyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectNutrientDeficiencyResponseDescriptor = $convert.base64Decode(
    'CiBEZXRlY3ROdXRyaWVudERlZmljaWVuY3lSZXNwb25zZRIdCgpyZXF1ZXN0X2lkGAEgASgJUg'
    'lyZXF1ZXN0SWQSSQoMZGVmaWNpZW5jaWVzGAIgAygLMiUuYWdyaWN1bHR1cmUuYWkudjEuTnV0'
    'cmllbnREZWZpY2llbmN5UgxkZWZpY2llbmNpZXMSIwoNbW9kZWxfdmVyc2lvbhgDIAEoCVIMbW'
    '9kZWxWZXJzaW9uEiwKEnByb2Nlc3NpbmdfdGltZV9tcxgEIAEoA1IQcHJvY2Vzc2luZ1RpbWVN'
    'cxJCCgxleHBsYW5hdGlvbnMYBSADKAsyHi5hZ3JpY3VsdHVyZS5haS52MS5FeHBsYW5hdGlvbl'
    'IMZXhwbGFuYXRpb25z');

@$core.Deprecated('Use nutrientDeficiencyDescriptor instead')
const NutrientDeficiency$json = {
  '1': 'NutrientDeficiency',
  '2': [
    {'1': 'nutrient', '3': 1, '4': 1, '5': 9, '10': 'nutrient'},
    {'1': 'confidence_score', '3': 2, '4': 1, '5': 1, '10': 'confidenceScore'},
    {'1': 'severity', '3': 3, '4': 1, '5': 9, '10': 'severity'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'visual_symptoms', '3': 5, '4': 1, '5': 9, '10': 'visualSymptoms'},
    {
      '1': 'recommended_fertilizers',
      '3': 6,
      '4': 3,
      '5': 9,
      '10': 'recommendedFertilizers'
    },
    {
      '1': 'application_method',
      '3': 7,
      '4': 1,
      '5': 9,
      '10': 'applicationMethod'
    },
  ],
};

/// Descriptor for `NutrientDeficiency`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List nutrientDeficiencyDescriptor = $convert.base64Decode(
    'ChJOdXRyaWVudERlZmljaWVuY3kSGgoIbnV0cmllbnQYASABKAlSCG51dHJpZW50EikKEGNvbm'
    'ZpZGVuY2Vfc2NvcmUYAiABKAFSD2NvbmZpZGVuY2VTY29yZRIaCghzZXZlcml0eRgDIAEoCVII'
    'c2V2ZXJpdHkSIAoLZGVzY3JpcHRpb24YBCABKAlSC2Rlc2NyaXB0aW9uEicKD3Zpc3VhbF9zeW'
    '1wdG9tcxgFIAEoCVIOdmlzdWFsU3ltcHRvbXMSNwoXcmVjb21tZW5kZWRfZmVydGlsaXplcnMY'
    'BiADKAlSFnJlY29tbWVuZGVkRmVydGlsaXplcnMSLQoSYXBwbGljYXRpb25fbWV0aG9kGAcgAS'
    'gJUhFhcHBsaWNhdGlvbk1ldGhvZA==');

@$core.Deprecated('Use classifyPlantRequestDescriptor instead')
const ClassifyPlantRequest$json = {
  '1': 'ClassifyPlantRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'images',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.ImageData',
      '10': 'images'
    },
    {
      '1': 'context',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.SampleContext',
      '10': 'context'
    },
  ],
};

/// Descriptor for `ClassifyPlantRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List classifyPlantRequestDescriptor = $convert.base64Decode(
    'ChRDbGFzc2lmeVBsYW50UmVxdWVzdBIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZXF1ZXN0SWQSNA'
    'oGaW1hZ2VzGAIgAygLMhwuYWdyaWN1bHR1cmUuYWkudjEuSW1hZ2VEYXRhUgZpbWFnZXMSOgoH'
    'Y29udGV4dBgDIAEoCzIgLmFncmljdWx0dXJlLmFpLnYxLlNhbXBsZUNvbnRleHRSB2NvbnRleH'
    'Q=');

@$core.Deprecated('Use trainingLabelDescriptor instead')
const TrainingLabel$json = {
  '1': 'TrainingLabel',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'confidence', '3': 2, '4': 1, '5': 1, '10': 'confidence'},
    {'1': 'category', '3': 3, '4': 1, '5': 9, '10': 'category'},
    {'1': 'severity', '3': 4, '4': 1, '5': 9, '10': 'severity'},
  ],
};

/// Descriptor for `TrainingLabel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trainingLabelDescriptor = $convert.base64Decode(
    'Cg1UcmFpbmluZ0xhYmVsEhIKBG5hbWUYASABKAlSBG5hbWUSHgoKY29uZmlkZW5jZRgCIAEoAV'
    'IKY29uZmlkZW5jZRIaCghjYXRlZ29yeRgDIAEoCVIIY2F0ZWdvcnkSGgoIc2V2ZXJpdHkYBCAB'
    'KAlSCHNldmVyaXR5');

@$core.Deprecated('Use labelReviewDescriptor instead')
const LabelReview$json = {
  '1': 'LabelReview',
  '2': [
    {'1': 'decision', '3': 1, '4': 1, '5': 9, '10': 'decision'},
    {'1': 'corrected_label', '3': 2, '4': 1, '5': 9, '10': 'correctedLabel'},
    {'1': 'reviewer_id', '3': 3, '4': 1, '5': 9, '10': 'reviewerId'},
    {'1': 'tenant_id', '3': 4, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'notes', '3': 5, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'reviewed_at', '3': 6, '4': 1, '5': 9, '10': 'reviewedAt'},
  ],
};

/// Descriptor for `LabelReview`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List labelReviewDescriptor = $convert.base64Decode(
    'CgtMYWJlbFJldmlldxIaCghkZWNpc2lvbhgBIAEoCVIIZGVjaXNpb24SJwoPY29ycmVjdGVkX2'
    'xhYmVsGAIgASgJUg5jb3JyZWN0ZWRMYWJlbBIfCgtyZXZpZXdlcl9pZBgDIAEoCVIKcmV2aWV3'
    'ZXJJZBIbCgl0ZW5hbnRfaWQYBCABKAlSCHRlbmFudElkEhQKBW5vdGVzGAUgASgJUgVub3Rlcx'
    'IfCgtyZXZpZXdlZF9hdBgGIAEoCVIKcmV2aWV3ZWRBdA==');

@$core.Deprecated('Use labelSuspicionDescriptor instead')
const LabelSuspicion$json = {
  '1': 'LabelSuspicion',
  '2': [
    {'1': 'predicted', '3': 1, '4': 1, '5': 9, '10': 'predicted'},
    {'1': 'predicted_prob', '3': 2, '4': 1, '5': 1, '10': 'predictedProb'},
    {'1': 'label_prob', '3': 3, '4': 1, '5': 1, '10': 'labelProb'},
    {'1': 'model_version', '3': 4, '4': 1, '5': 9, '10': 'modelVersion'},
    {'1': 'flagged_at', '3': 5, '4': 1, '5': 9, '10': 'flaggedAt'},
  ],
};

/// Descriptor for `LabelSuspicion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List labelSuspicionDescriptor = $convert.base64Decode(
    'Cg5MYWJlbFN1c3BpY2lvbhIcCglwcmVkaWN0ZWQYASABKAlSCXByZWRpY3RlZBIlCg5wcmVkaW'
    'N0ZWRfcHJvYhgCIAEoAVINcHJlZGljdGVkUHJvYhIdCgpsYWJlbF9wcm9iGAMgASgBUglsYWJl'
    'bFByb2ISIwoNbW9kZWxfdmVyc2lvbhgEIAEoCVIMbW9kZWxWZXJzaW9uEh0KCmZsYWdnZWRfYX'
    'QYBSABKAlSCWZsYWdnZWRBdA==');

@$core.Deprecated('Use trainingSampleInfoDescriptor instead')
const TrainingSampleInfo$json = {
  '1': 'TrainingSampleInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'task', '3': 2, '4': 1, '5': 9, '10': 'task'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 9, '10': 'timestamp'},
    {'1': 'provenance', '3': 4, '4': 1, '5': 9, '10': 'provenance'},
    {'1': 'provider', '3': 5, '4': 1, '5': 9, '10': 'provider'},
    {
      '1': 'labels',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.TrainingLabel',
      '10': 'labels'
    },
    {'1': 'top_confidence', '3': 7, '4': 1, '5': 1, '10': 'topConfidence'},
    {
      '1': 'context',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.SampleContext',
      '10': 'context'
    },
    {
      '1': 'review',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.LabelReview',
      '10': 'review'
    },
    {'1': 'effective_label', '3': 10, '4': 1, '5': 9, '10': 'effectiveLabel'},
    {
      '1': 'suspect',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.LabelSuspicion',
      '10': 'suspect'
    },
    {
      '1': 'needs_second_opinion',
      '3': 12,
      '4': 1,
      '5': 8,
      '10': 'needsSecondOpinion'
    },
    {
      '1': 'reviews',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.LabelReview',
      '10': 'reviews'
    },
  ],
};

/// Descriptor for `TrainingSampleInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List trainingSampleInfoDescriptor = $convert.base64Decode(
    'ChJUcmFpbmluZ1NhbXBsZUluZm8SDgoCaWQYASABKAlSAmlkEhIKBHRhc2sYAiABKAlSBHRhc2'
    'sSHAoJdGltZXN0YW1wGAMgASgJUgl0aW1lc3RhbXASHgoKcHJvdmVuYW5jZRgEIAEoCVIKcHJv'
    'dmVuYW5jZRIaCghwcm92aWRlchgFIAEoCVIIcHJvdmlkZXISOAoGbGFiZWxzGAYgAygLMiAuYW'
    'dyaWN1bHR1cmUuYWkudjEuVHJhaW5pbmdMYWJlbFIGbGFiZWxzEiUKDnRvcF9jb25maWRlbmNl'
    'GAcgASgBUg10b3BDb25maWRlbmNlEjoKB2NvbnRleHQYCCABKAsyIC5hZ3JpY3VsdHVyZS5haS'
    '52MS5TYW1wbGVDb250ZXh0Ugdjb250ZXh0EjYKBnJldmlldxgJIAEoCzIeLmFncmljdWx0dXJl'
    'LmFpLnYxLkxhYmVsUmV2aWV3UgZyZXZpZXcSJwoPZWZmZWN0aXZlX2xhYmVsGAogASgJUg5lZm'
    'ZlY3RpdmVMYWJlbBI7CgdzdXNwZWN0GAsgASgLMiEuYWdyaWN1bHR1cmUuYWkudjEuTGFiZWxT'
    'dXNwaWNpb25SB3N1c3BlY3QSMAoUbmVlZHNfc2Vjb25kX29waW5pb24YDCABKAhSEm5lZWRzU2'
    'Vjb25kT3BpbmlvbhI4CgdyZXZpZXdzGA0gAygLMh4uYWdyaWN1bHR1cmUuYWkudjEuTGFiZWxS'
    'ZXZpZXdSB3Jldmlld3M=');

@$core.Deprecated('Use reviewAgreementDescriptor instead')
const ReviewAgreement$json = {
  '1': 'ReviewAgreement',
  '2': [
    {'1': 'compared', '3': 1, '4': 1, '5': 5, '10': 'compared'},
    {'1': 'raw_agreement', '3': 2, '4': 1, '5': 1, '10': 'rawAgreement'},
    {'1': 'kappa', '3': 3, '4': 1, '5': 1, '10': 'kappa'},
    {'1': 'strength', '3': 4, '4': 1, '5': 9, '10': 'strength'},
    {
      '1': 'disagreements',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.LabelDisagreement',
      '10': 'disagreements'
    },
  ],
};

/// Descriptor for `ReviewAgreement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reviewAgreementDescriptor = $convert.base64Decode(
    'Cg9SZXZpZXdBZ3JlZW1lbnQSGgoIY29tcGFyZWQYASABKAVSCGNvbXBhcmVkEiMKDXJhd19hZ3'
    'JlZW1lbnQYAiABKAFSDHJhd0FncmVlbWVudBIUCgVrYXBwYRgDIAEoAVIFa2FwcGESGgoIc3Ry'
    'ZW5ndGgYBCABKAlSCHN0cmVuZ3RoEkoKDWRpc2FncmVlbWVudHMYBSADKAsyJC5hZ3JpY3VsdH'
    'VyZS5haS52MS5MYWJlbERpc2FncmVlbWVudFINZGlzYWdyZWVtZW50cw==');

@$core.Deprecated('Use labelDisagreementDescriptor instead')
const LabelDisagreement$json = {
  '1': 'LabelDisagreement',
  '2': [
    {'1': 'first', '3': 1, '4': 1, '5': 9, '10': 'first'},
    {'1': 'second', '3': 2, '4': 1, '5': 9, '10': 'second'},
    {'1': 'count', '3': 3, '4': 1, '5': 5, '10': 'count'},
  ],
};

/// Descriptor for `LabelDisagreement`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List labelDisagreementDescriptor = $convert.base64Decode(
    'ChFMYWJlbERpc2FncmVlbWVudBIUCgVmaXJzdBgBIAEoCVIFZmlyc3QSFgoGc2Vjb25kGAIgAS'
    'gJUgZzZWNvbmQSFAoFY291bnQYAyABKAVSBWNvdW50');

@$core.Deprecated('Use requestSecondOpinionRequestDescriptor instead')
const RequestSecondOpinionRequest$json = {
  '1': 'RequestSecondOpinionRequest',
  '2': [
    {'1': 'task', '3': 1, '4': 1, '5': 9, '10': 'task'},
    {'1': 'sample_id', '3': 2, '4': 1, '5': 9, '10': 'sampleId'},
    {'1': 'tenant_id', '3': 3, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'wanted', '3': 4, '4': 1, '5': 8, '10': 'wanted'},
  ],
};

/// Descriptor for `RequestSecondOpinionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestSecondOpinionRequestDescriptor =
    $convert.base64Decode(
        'ChtSZXF1ZXN0U2Vjb25kT3BpbmlvblJlcXVlc3QSEgoEdGFzaxgBIAEoCVIEdGFzaxIbCglzYW'
        '1wbGVfaWQYAiABKAlSCHNhbXBsZUlkEhsKCXRlbmFudF9pZBgDIAEoCVIIdGVuYW50SWQSFgoG'
        'd2FudGVkGAQgASgIUgZ3YW50ZWQ=');

@$core.Deprecated('Use requestSecondOpinionResponseDescriptor instead')
const RequestSecondOpinionResponse$json = {
  '1': 'RequestSecondOpinionResponse',
  '2': [
    {
      '1': 'sample',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.TrainingSampleInfo',
      '10': 'sample'
    },
  ],
};

/// Descriptor for `RequestSecondOpinionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestSecondOpinionResponseDescriptor =
    $convert.base64Decode(
        'ChxSZXF1ZXN0U2Vjb25kT3BpbmlvblJlc3BvbnNlEj0KBnNhbXBsZRgBIAEoCzIlLmFncmljdW'
        'x0dXJlLmFpLnYxLlRyYWluaW5nU2FtcGxlSW5mb1IGc2FtcGxl');

@$core.Deprecated('Use getReviewAgreementRequestDescriptor instead')
const GetReviewAgreementRequest$json = {
  '1': 'GetReviewAgreementRequest',
  '2': [
    {'1': 'task', '3': 1, '4': 1, '5': 9, '10': 'task'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
  ],
};

/// Descriptor for `GetReviewAgreementRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReviewAgreementRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRSZXZpZXdBZ3JlZW1lbnRSZXF1ZXN0EhIKBHRhc2sYASABKAlSBHRhc2sSGwoJdGVuYW'
        '50X2lkGAIgASgJUgh0ZW5hbnRJZA==');

@$core.Deprecated('Use getReviewAgreementResponseDescriptor instead')
const GetReviewAgreementResponse$json = {
  '1': 'GetReviewAgreementResponse',
  '2': [
    {
      '1': 'agreement',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.ReviewAgreement',
      '10': 'agreement'
    },
  ],
};

/// Descriptor for `GetReviewAgreementResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getReviewAgreementResponseDescriptor =
    $convert.base64Decode(
        'ChpHZXRSZXZpZXdBZ3JlZW1lbnRSZXNwb25zZRJACglhZ3JlZW1lbnQYASABKAsyIi5hZ3JpY3'
        'VsdHVyZS5haS52MS5SZXZpZXdBZ3JlZW1lbnRSCWFncmVlbWVudA==');

@$core.Deprecated('Use listTrainingSamplesRequestDescriptor instead')
const ListTrainingSamplesRequest$json = {
  '1': 'ListTrainingSamplesRequest',
  '2': [
    {'1': 'task', '3': 1, '4': 1, '5': 9, '10': 'task'},
    {'1': 'review_status', '3': 2, '4': 1, '5': 9, '10': 'reviewStatus'},
    {'1': 'tenant_id', '3': 3, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'min_confidence', '3': 4, '4': 1, '5': 1, '10': 'minConfidence'},
    {'1': 'max_confidence', '3': 5, '4': 1, '5': 1, '10': 'maxConfidence'},
    {'1': 'provenance', '3': 6, '4': 1, '5': 9, '10': 'provenance'},
    {'1': 'page_size', '3': 7, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 8, '4': 1, '5': 5, '10': 'pageOffset'},
    {'1': 'order', '3': 9, '4': 1, '5': 9, '10': 'order'},
    {'1': 'suspect_only', '3': 10, '4': 1, '5': 8, '10': 'suspectOnly'},
    {
      '1': 'second_opinion_only',
      '3': 11,
      '4': 1,
      '5': 8,
      '10': 'secondOpinionOnly'
    },
  ],
};

/// Descriptor for `ListTrainingSamplesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTrainingSamplesRequestDescriptor = $convert.base64Decode(
    'ChpMaXN0VHJhaW5pbmdTYW1wbGVzUmVxdWVzdBISCgR0YXNrGAEgASgJUgR0YXNrEiMKDXJldm'
    'lld19zdGF0dXMYAiABKAlSDHJldmlld1N0YXR1cxIbCgl0ZW5hbnRfaWQYAyABKAlSCHRlbmFu'
    'dElkEiUKDm1pbl9jb25maWRlbmNlGAQgASgBUg1taW5Db25maWRlbmNlEiUKDm1heF9jb25maW'
    'RlbmNlGAUgASgBUg1tYXhDb25maWRlbmNlEh4KCnByb3ZlbmFuY2UYBiABKAlSCnByb3ZlbmFu'
    'Y2USGwoJcGFnZV9zaXplGAcgASgFUghwYWdlU2l6ZRIfCgtwYWdlX29mZnNldBgIIAEoBVIKcG'
    'FnZU9mZnNldBIUCgVvcmRlchgJIAEoCVIFb3JkZXISIQoMc3VzcGVjdF9vbmx5GAogASgIUgtz'
    'dXNwZWN0T25seRIuChNzZWNvbmRfb3Bpbmlvbl9vbmx5GAsgASgIUhFzZWNvbmRPcGluaW9uT2'
    '5seQ==');

@$core.Deprecated('Use listTrainingSamplesResponseDescriptor instead')
const ListTrainingSamplesResponse$json = {
  '1': 'ListTrainingSamplesResponse',
  '2': [
    {
      '1': 'samples',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.TrainingSampleInfo',
      '10': 'samples'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
    {'1': 'unreviewed_count', '3': 3, '4': 1, '5': 5, '10': 'unreviewedCount'},
  ],
};

/// Descriptor for `ListTrainingSamplesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listTrainingSamplesResponseDescriptor = $convert.base64Decode(
    'ChtMaXN0VHJhaW5pbmdTYW1wbGVzUmVzcG9uc2USPwoHc2FtcGxlcxgBIAMoCzIlLmFncmljdW'
    'x0dXJlLmFpLnYxLlRyYWluaW5nU2FtcGxlSW5mb1IHc2FtcGxlcxIfCgt0b3RhbF9jb3VudBgC'
    'IAEoBVIKdG90YWxDb3VudBIpChB1bnJldmlld2VkX2NvdW50GAMgASgFUg91bnJldmlld2VkQ2'
    '91bnQ=');

@$core.Deprecated('Use submitLabelReviewRequestDescriptor instead')
const SubmitLabelReviewRequest$json = {
  '1': 'SubmitLabelReviewRequest',
  '2': [
    {'1': 'task', '3': 1, '4': 1, '5': 9, '10': 'task'},
    {'1': 'sample_id', '3': 2, '4': 1, '5': 9, '10': 'sampleId'},
    {
      '1': 'review',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.LabelReview',
      '10': 'review'
    },
  ],
};

/// Descriptor for `SubmitLabelReviewRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitLabelReviewRequestDescriptor = $convert.base64Decode(
    'ChhTdWJtaXRMYWJlbFJldmlld1JlcXVlc3QSEgoEdGFzaxgBIAEoCVIEdGFzaxIbCglzYW1wbG'
    'VfaWQYAiABKAlSCHNhbXBsZUlkEjYKBnJldmlldxgDIAEoCzIeLmFncmljdWx0dXJlLmFpLnYx'
    'LkxhYmVsUmV2aWV3UgZyZXZpZXc=');

@$core.Deprecated('Use submitLabelReviewResponseDescriptor instead')
const SubmitLabelReviewResponse$json = {
  '1': 'SubmitLabelReviewResponse',
  '2': [
    {
      '1': 'sample',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.TrainingSampleInfo',
      '10': 'sample'
    },
  ],
};

/// Descriptor for `SubmitLabelReviewResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitLabelReviewResponseDescriptor =
    $convert.base64Decode(
        'ChlTdWJtaXRMYWJlbFJldmlld1Jlc3BvbnNlEj0KBnNhbXBsZRgBIAEoCzIlLmFncmljdWx0dX'
        'JlLmFpLnYxLlRyYWluaW5nU2FtcGxlSW5mb1IGc2FtcGxl');

@$core.Deprecated('Use getTrainingSampleImageRequestDescriptor instead')
const GetTrainingSampleImageRequest$json = {
  '1': 'GetTrainingSampleImageRequest',
  '2': [
    {'1': 'task', '3': 1, '4': 1, '5': 9, '10': 'task'},
    {'1': 'sample_id', '3': 2, '4': 1, '5': 9, '10': 'sampleId'},
    {'1': 'tenant_id', '3': 3, '4': 1, '5': 9, '10': 'tenantId'},
  ],
};

/// Descriptor for `GetTrainingSampleImageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTrainingSampleImageRequestDescriptor =
    $convert.base64Decode(
        'Ch1HZXRUcmFpbmluZ1NhbXBsZUltYWdlUmVxdWVzdBISCgR0YXNrGAEgASgJUgR0YXNrEhsKCX'
        'NhbXBsZV9pZBgCIAEoCVIIc2FtcGxlSWQSGwoJdGVuYW50X2lkGAMgASgJUgh0ZW5hbnRJZA==');

@$core.Deprecated('Use getTrainingSampleImageResponseDescriptor instead')
const GetTrainingSampleImageResponse$json = {
  '1': 'GetTrainingSampleImageResponse',
  '2': [
    {'1': 'image_bytes', '3': 1, '4': 1, '5': 12, '10': 'imageBytes'},
    {'1': 'mime_type', '3': 2, '4': 1, '5': 9, '10': 'mimeType'},
  ],
};

/// Descriptor for `GetTrainingSampleImageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTrainingSampleImageResponseDescriptor =
    $convert.base64Decode(
        'Ch5HZXRUcmFpbmluZ1NhbXBsZUltYWdlUmVzcG9uc2USHwoLaW1hZ2VfYnl0ZXMYASABKAxSCm'
        'ltYWdlQnl0ZXMSGwoJbWltZV90eXBlGAIgASgJUghtaW1lVHlwZQ==');

@$core.Deprecated('Use classifyPlantResponseDescriptor instead')
const ClassifyPlantResponse$json = {
  '1': 'ClassifyPlantResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'species',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.PlantClassification',
      '10': 'species'
    },
    {'1': 'model_version', '3': 3, '4': 1, '5': 9, '10': 'modelVersion'},
    {
      '1': 'processing_time_ms',
      '3': 4,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
    {
      '1': 'explanations',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.Explanation',
      '10': 'explanations'
    },
  ],
};

/// Descriptor for `ClassifyPlantResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List classifyPlantResponseDescriptor = $convert.base64Decode(
    'ChVDbGFzc2lmeVBsYW50UmVzcG9uc2USHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdWVzdElkEk'
    'AKB3NwZWNpZXMYAiABKAsyJi5hZ3JpY3VsdHVyZS5haS52MS5QbGFudENsYXNzaWZpY2F0aW9u'
    'UgdzcGVjaWVzEiMKDW1vZGVsX3ZlcnNpb24YAyABKAlSDG1vZGVsVmVyc2lvbhIsChJwcm9jZX'
    'NzaW5nX3RpbWVfbXMYBCABKANSEHByb2Nlc3NpbmdUaW1lTXMSQgoMZXhwbGFuYXRpb25zGAUg'
    'AygLMh4uYWdyaWN1bHR1cmUuYWkudjEuRXhwbGFuYXRpb25SDGV4cGxhbmF0aW9ucw==');

@$core.Deprecated('Use plantClassificationDescriptor instead')
const PlantClassification$json = {
  '1': 'PlantClassification',
  '2': [
    {'1': 'species_id', '3': 1, '4': 1, '5': 9, '10': 'speciesId'},
    {'1': 'common_name', '3': 2, '4': 1, '5': 9, '10': 'commonName'},
    {'1': 'scientific_name', '3': 3, '4': 1, '5': 9, '10': 'scientificName'},
    {'1': 'family', '3': 4, '4': 1, '5': 9, '10': 'family'},
    {'1': 'confidence', '3': 5, '4': 1, '5': 1, '10': 'confidence'},
  ],
};

/// Descriptor for `PlantClassification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List plantClassificationDescriptor = $convert.base64Decode(
    'ChNQbGFudENsYXNzaWZpY2F0aW9uEh0KCnNwZWNpZXNfaWQYASABKAlSCXNwZWNpZXNJZBIfCg'
    'tjb21tb25fbmFtZRgCIAEoCVIKY29tbW9uTmFtZRInCg9zY2llbnRpZmljX25hbWUYAyABKAlS'
    'DnNjaWVudGlmaWNOYW1lEhYKBmZhbWlseRgEIAEoCVIGZmFtaWx5Eh4KCmNvbmZpZGVuY2UYBS'
    'ABKAFSCmNvbmZpZGVuY2U=');

@$core.Deprecated('Use predictYieldRequestDescriptor instead')
const PredictYieldRequest$json = {
  '1': 'PredictYieldRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'crop_type', '3': 2, '4': 1, '5': 9, '10': 'cropType'},
    {
      '1': 'environment',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.EnvironmentFactors',
      '10': 'environment'
    },
    {
      '1': 'soil',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.SoilFactors',
      '10': 'soil'
    },
    {
      '1': 'management',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.ManagementFactors',
      '10': 'management'
    },
    {
      '1': 'field_area_hectares',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'fieldAreaHectares'
    },
  ],
};

/// Descriptor for `PredictYieldRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List predictYieldRequestDescriptor = $convert.base64Decode(
    'ChNQcmVkaWN0WWllbGRSZXF1ZXN0Eh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcXVlc3RJZBIbCg'
    'ljcm9wX3R5cGUYAiABKAlSCGNyb3BUeXBlEkcKC2Vudmlyb25tZW50GAMgASgLMiUuYWdyaWN1'
    'bHR1cmUuYWkudjEuRW52aXJvbm1lbnRGYWN0b3JzUgtlbnZpcm9ubWVudBIyCgRzb2lsGAQgAS'
    'gLMh4uYWdyaWN1bHR1cmUuYWkudjEuU29pbEZhY3RvcnNSBHNvaWwSRAoKbWFuYWdlbWVudBgF'
    'IAEoCzIkLmFncmljdWx0dXJlLmFpLnYxLk1hbmFnZW1lbnRGYWN0b3JzUgptYW5hZ2VtZW50Ei'
    '4KE2ZpZWxkX2FyZWFfaGVjdGFyZXMYBiABKAFSEWZpZWxkQXJlYUhlY3RhcmVz');

@$core.Deprecated('Use featureAttributionDescriptor instead')
const FeatureAttribution$json = {
  '1': 'FeatureAttribution',
  '2': [
    {'1': 'feature', '3': 1, '4': 1, '5': 9, '10': 'feature'},
    {'1': 'value', '3': 2, '4': 1, '5': 1, '10': 'value'},
    {'1': 'contribution', '3': 3, '4': 1, '5': 1, '10': 'contribution'},
  ],
};

/// Descriptor for `FeatureAttribution`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List featureAttributionDescriptor = $convert.base64Decode(
    'ChJGZWF0dXJlQXR0cmlidXRpb24SGAoHZmVhdHVyZRgBIAEoCVIHZmVhdHVyZRIUCgV2YWx1ZR'
    'gCIAEoAVIFdmFsdWUSIgoMY29udHJpYnV0aW9uGAMgASgBUgxjb250cmlidXRpb24=');

@$core.Deprecated('Use attributionSummaryDescriptor instead')
const AttributionSummary$json = {
  '1': 'AttributionSummary',
  '2': [
    {'1': 'baseline', '3': 1, '4': 1, '5': 1, '10': 'baseline'},
    {'1': 'prediction', '3': 2, '4': 1, '5': 1, '10': 'prediction'},
    {
      '1': 'features',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.FeatureAttribution',
      '10': 'features'
    },
    {'1': 'attributed_share', '3': 4, '4': 1, '5': 1, '10': 'attributedShare'},
    {'1': 'method', '3': 5, '4': 1, '5': 9, '10': 'method'},
    {'1': 'residual', '3': 6, '4': 1, '5': 1, '10': 'residual'},
    {'1': 'summary', '3': 7, '4': 1, '5': 9, '10': 'summary'},
    {'1': 'units', '3': 8, '4': 1, '5': 9, '10': 'units'},
  ],
};

/// Descriptor for `AttributionSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attributionSummaryDescriptor = $convert.base64Decode(
    'ChJBdHRyaWJ1dGlvblN1bW1hcnkSGgoIYmFzZWxpbmUYASABKAFSCGJhc2VsaW5lEh4KCnByZW'
    'RpY3Rpb24YAiABKAFSCnByZWRpY3Rpb24SQQoIZmVhdHVyZXMYAyADKAsyJS5hZ3JpY3VsdHVy'
    'ZS5haS52MS5GZWF0dXJlQXR0cmlidXRpb25SCGZlYXR1cmVzEikKEGF0dHJpYnV0ZWRfc2hhcm'
    'UYBCABKAFSD2F0dHJpYnV0ZWRTaGFyZRIWCgZtZXRob2QYBSABKAlSBm1ldGhvZBIaCghyZXNp'
    'ZHVhbBgGIAEoAVIIcmVzaWR1YWwSGAoHc3VtbWFyeRgHIAEoCVIHc3VtbWFyeRIUCgV1bml0cx'
    'gIIAEoCVIFdW5pdHM=');

@$core.Deprecated('Use predictYieldResponseDescriptor instead')
const PredictYieldResponse$json = {
  '1': 'PredictYieldResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'predicted_yield_kg_per_hectare',
      '3': 2,
      '4': 1,
      '5': 1,
      '10': 'predictedYieldKgPerHectare'
    },
    {'1': 'confidence_pct', '3': 3, '4': 1, '5': 1, '10': 'confidencePct'},
    {'1': 'yield_lower_bound', '3': 4, '4': 1, '5': 1, '10': 'yieldLowerBound'},
    {'1': 'yield_upper_bound', '3': 5, '4': 1, '5': 1, '10': 'yieldUpperBound'},
    {
      '1': 'stress_factors',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.StressFactor',
      '10': 'stressFactors'
    },
    {'1': 'model_version', '3': 7, '4': 1, '5': 9, '10': 'modelVersion'},
    {
      '1': 'processing_time_ms',
      '3': 8,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
    {'1': 'model_source', '3': 9, '4': 1, '5': 9, '10': 'modelSource'},
    {'1': 'tabular_weight', '3': 10, '4': 1, '5': 1, '10': 'tabularWeight'},
    {'1': 'crop_supported', '3': 11, '4': 1, '5': 8, '10': 'cropSupported'},
    {
      '1': 'interval_coverage',
      '3': 12,
      '4': 1,
      '5': 1,
      '10': 'intervalCoverage'
    },
    {
      '1': 'attribution',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.AttributionSummary',
      '10': 'attribution'
    },
    {
      '1': 'parametric_yield_kg_per_hectare',
      '3': 13,
      '4': 1,
      '5': 1,
      '10': 'parametricYieldKgPerHectare'
    },
  ],
};

/// Descriptor for `PredictYieldResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List predictYieldResponseDescriptor = $convert.base64Decode(
    'ChRQcmVkaWN0WWllbGRSZXNwb25zZRIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZXF1ZXN0SWQSQg'
    'oecHJlZGljdGVkX3lpZWxkX2tnX3Blcl9oZWN0YXJlGAIgASgBUhpwcmVkaWN0ZWRZaWVsZEtn'
    'UGVySGVjdGFyZRIlCg5jb25maWRlbmNlX3BjdBgDIAEoAVINY29uZmlkZW5jZVBjdBIqChF5aW'
    'VsZF9sb3dlcl9ib3VuZBgEIAEoAVIPeWllbGRMb3dlckJvdW5kEioKEXlpZWxkX3VwcGVyX2Jv'
    'dW5kGAUgASgBUg95aWVsZFVwcGVyQm91bmQSRgoOc3RyZXNzX2ZhY3RvcnMYBiADKAsyHy5hZ3'
    'JpY3VsdHVyZS5haS52MS5TdHJlc3NGYWN0b3JSDXN0cmVzc0ZhY3RvcnMSIwoNbW9kZWxfdmVy'
    'c2lvbhgHIAEoCVIMbW9kZWxWZXJzaW9uEiwKEnByb2Nlc3NpbmdfdGltZV9tcxgIIAEoA1IQcH'
    'JvY2Vzc2luZ1RpbWVNcxIhCgxtb2RlbF9zb3VyY2UYCSABKAlSC21vZGVsU291cmNlEiUKDnRh'
    'YnVsYXJfd2VpZ2h0GAogASgBUg10YWJ1bGFyV2VpZ2h0EiUKDmNyb3Bfc3VwcG9ydGVkGAsgAS'
    'gIUg1jcm9wU3VwcG9ydGVkEisKEWludGVydmFsX2NvdmVyYWdlGAwgASgBUhBpbnRlcnZhbENv'
    'dmVyYWdlEkcKC2F0dHJpYnV0aW9uGA4gASgLMiUuYWdyaWN1bHR1cmUuYWkudjEuQXR0cmlidX'
    'Rpb25TdW1tYXJ5UgthdHRyaWJ1dGlvbhJECh9wYXJhbWV0cmljX3lpZWxkX2tnX3Blcl9oZWN0'
    'YXJlGA0gASgBUhtwYXJhbWV0cmljWWllbGRLZ1BlckhlY3RhcmU=');

@$core.Deprecated('Use environmentFactorsDescriptor instead')
const EnvironmentFactors$json = {
  '1': 'EnvironmentFactors',
  '2': [
    {
      '1': 'temperature_celsius',
      '3': 1,
      '4': 1,
      '5': 1,
      '10': 'temperatureCelsius'
    },
    {'1': 'humidity_pct', '3': 2, '4': 1, '5': 1, '10': 'humidityPct'},
    {'1': 'rainfall_mm', '3': 3, '4': 1, '5': 1, '10': 'rainfallMm'},
    {'1': 'solar_radiation', '3': 4, '4': 1, '5': 1, '10': 'solarRadiation'},
    {'1': 'wind_speed_kmh', '3': 5, '4': 1, '5': 1, '10': 'windSpeedKmh'},
    {
      '1': 'growing_degree_days',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'growingDegreeDays'
    },
    {'1': 'frost_days', '3': 7, '4': 1, '5': 5, '10': 'frostDays'},
    {'1': 'heat_stress_days', '3': 8, '4': 1, '5': 5, '10': 'heatStressDays'},
  ],
};

/// Descriptor for `EnvironmentFactors`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List environmentFactorsDescriptor = $convert.base64Decode(
    'ChJFbnZpcm9ubWVudEZhY3RvcnMSLwoTdGVtcGVyYXR1cmVfY2Vsc2l1cxgBIAEoAVISdGVtcG'
    'VyYXR1cmVDZWxzaXVzEiEKDGh1bWlkaXR5X3BjdBgCIAEoAVILaHVtaWRpdHlQY3QSHwoLcmFp'
    'bmZhbGxfbW0YAyABKAFSCnJhaW5mYWxsTW0SJwoPc29sYXJfcmFkaWF0aW9uGAQgASgBUg5zb2'
    'xhclJhZGlhdGlvbhIkCg53aW5kX3NwZWVkX2ttaBgFIAEoAVIMd2luZFNwZWVkS21oEi4KE2dy'
    'b3dpbmdfZGVncmVlX2RheXMYBiABKAFSEWdyb3dpbmdEZWdyZWVEYXlzEh0KCmZyb3N0X2RheX'
    'MYByABKAVSCWZyb3N0RGF5cxIoChBoZWF0X3N0cmVzc19kYXlzGAggASgFUg5oZWF0U3RyZXNz'
    'RGF5cw==');

@$core.Deprecated('Use soilFactorsDescriptor instead')
const SoilFactors$json = {
  '1': 'SoilFactors',
  '2': [
    {'1': 'ph', '3': 1, '4': 1, '5': 1, '10': 'ph'},
    {
      '1': 'organic_matter_pct',
      '3': 2,
      '4': 1,
      '5': 1,
      '10': 'organicMatterPct'
    },
    {'1': 'nitrogen_ppm', '3': 3, '4': 1, '5': 1, '10': 'nitrogenPpm'},
    {'1': 'phosphorus_ppm', '3': 4, '4': 1, '5': 1, '10': 'phosphorusPpm'},
    {'1': 'potassium_ppm', '3': 5, '4': 1, '5': 1, '10': 'potassiumPpm'},
    {'1': 'moisture_pct', '3': 6, '4': 1, '5': 1, '10': 'moisturePct'},
    {'1': 'texture', '3': 7, '4': 1, '5': 9, '10': 'texture'},
    {'1': 'compaction_index', '3': 8, '4': 1, '5': 1, '10': 'compactionIndex'},
  ],
};

/// Descriptor for `SoilFactors`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List soilFactorsDescriptor = $convert.base64Decode(
    'CgtTb2lsRmFjdG9ycxIOCgJwaBgBIAEoAVICcGgSLAoSb3JnYW5pY19tYXR0ZXJfcGN0GAIgAS'
    'gBUhBvcmdhbmljTWF0dGVyUGN0EiEKDG5pdHJvZ2VuX3BwbRgDIAEoAVILbml0cm9nZW5QcG0S'
    'JQoOcGhvc3Bob3J1c19wcG0YBCABKAFSDXBob3NwaG9ydXNQcG0SIwoNcG90YXNzaXVtX3BwbR'
    'gFIAEoAVIMcG90YXNzaXVtUHBtEiEKDG1vaXN0dXJlX3BjdBgGIAEoAVILbW9pc3R1cmVQY3QS'
    'GAoHdGV4dHVyZRgHIAEoCVIHdGV4dHVyZRIpChBjb21wYWN0aW9uX2luZGV4GAggASgBUg9jb2'
    '1wYWN0aW9uSW5kZXg=');

@$core.Deprecated('Use managementFactorsDescriptor instead')
const ManagementFactors$json = {
  '1': 'ManagementFactors',
  '2': [
    {
      '1': 'irrigation_efficiency',
      '3': 1,
      '4': 1,
      '5': 1,
      '10': 'irrigationEfficiency'
    },
    {
      '1': 'fertilizer_rate_kg_per_ha',
      '3': 2,
      '4': 1,
      '5': 1,
      '10': 'fertilizerRateKgPerHa'
    },
    {'1': 'tillage_type', '3': 3, '4': 1, '5': 9, '10': 'tillageType'},
    {'1': 'planting_density', '3': 4, '4': 1, '5': 1, '10': 'plantingDensity'},
    {
      '1': 'pest_management_level',
      '3': 5,
      '4': 1,
      '5': 9,
      '10': 'pestManagementLevel'
    },
    {'1': 'planting_day', '3': 6, '4': 1, '5': 5, '10': 'plantingDay'},
    {'1': 'irrigation_mm', '3': 7, '4': 1, '5': 1, '10': 'irrigationMm'},
  ],
};

/// Descriptor for `ManagementFactors`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List managementFactorsDescriptor = $convert.base64Decode(
    'ChFNYW5hZ2VtZW50RmFjdG9ycxIzChVpcnJpZ2F0aW9uX2VmZmljaWVuY3kYASABKAFSFGlycm'
    'lnYXRpb25FZmZpY2llbmN5EjgKGWZlcnRpbGl6ZXJfcmF0ZV9rZ19wZXJfaGEYAiABKAFSFWZl'
    'cnRpbGl6ZXJSYXRlS2dQZXJIYRIhCgx0aWxsYWdlX3R5cGUYAyABKAlSC3RpbGxhZ2VUeXBlEi'
    'kKEHBsYW50aW5nX2RlbnNpdHkYBCABKAFSD3BsYW50aW5nRGVuc2l0eRIyChVwZXN0X21hbmFn'
    'ZW1lbnRfbGV2ZWwYBSABKAlSE3Blc3RNYW5hZ2VtZW50TGV2ZWwSIQoMcGxhbnRpbmdfZGF5GA'
    'YgASgFUgtwbGFudGluZ0RheRIjCg1pcnJpZ2F0aW9uX21tGAcgASgBUgxpcnJpZ2F0aW9uTW0=');

@$core.Deprecated('Use stressFactorDescriptor instead')
const StressFactor$json = {
  '1': 'StressFactor',
  '2': [
    {'1': 'factor_name', '3': 1, '4': 1, '5': 9, '10': 'factorName'},
    {'1': 'severity', '3': 2, '4': 1, '5': 1, '10': 'severity'},
    {'1': 'yield_impact_pct', '3': 3, '4': 1, '5': 1, '10': 'yieldImpactPct'},
  ],
};

/// Descriptor for `StressFactor`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stressFactorDescriptor = $convert.base64Decode(
    'CgxTdHJlc3NGYWN0b3ISHwoLZmFjdG9yX25hbWUYASABKAlSCmZhY3Rvck5hbWUSGgoIc2V2ZX'
    'JpdHkYAiABKAFSCHNldmVyaXR5EigKEHlpZWxkX2ltcGFjdF9wY3QYAyABKAFSDnlpZWxkSW1w'
    'YWN0UGN0');

@$core.Deprecated('Use simulateCropGrowthRequestDescriptor instead')
const SimulateCropGrowthRequest$json = {
  '1': 'SimulateCropGrowthRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'crop_type', '3': 2, '4': 1, '5': 9, '10': 'cropType'},
    {'1': 'simulation_days', '3': 3, '4': 1, '5': 5, '10': 'simulationDays'},
    {
      '1': 'initial_environment',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.EnvironmentFactors',
      '10': 'initialEnvironment'
    },
    {
      '1': 'initial_soil',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.SoilFactors',
      '10': 'initialSoil'
    },
    {'1': 'planting_density', '3': 6, '4': 1, '5': 1, '10': 'plantingDensity'},
  ],
};

/// Descriptor for `SimulateCropGrowthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List simulateCropGrowthRequestDescriptor = $convert.base64Decode(
    'ChlTaW11bGF0ZUNyb3BHcm93dGhSZXF1ZXN0Eh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcXVlc3'
    'RJZBIbCgljcm9wX3R5cGUYAiABKAlSCGNyb3BUeXBlEicKD3NpbXVsYXRpb25fZGF5cxgDIAEo'
    'BVIOc2ltdWxhdGlvbkRheXMSVgoTaW5pdGlhbF9lbnZpcm9ubWVudBgEIAEoCzIlLmFncmljdW'
    'x0dXJlLmFpLnYxLkVudmlyb25tZW50RmFjdG9yc1ISaW5pdGlhbEVudmlyb25tZW50EkEKDGlu'
    'aXRpYWxfc29pbBgFIAEoCzIeLmFncmljdWx0dXJlLmFpLnYxLlNvaWxGYWN0b3JzUgtpbml0aW'
    'FsU29pbBIpChBwbGFudGluZ19kZW5zaXR5GAYgASgBUg9wbGFudGluZ0RlbnNpdHk=');

@$core.Deprecated('Use simulateCropGrowthResponseDescriptor instead')
const SimulateCropGrowthResponse$json = {
  '1': 'SimulateCropGrowthResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'stages',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.GrowthStageResult',
      '10': 'stages'
    },
    {
      '1': 'final_biomass_kg_per_ha',
      '3': 3,
      '4': 1,
      '5': 1,
      '10': 'finalBiomassKgPerHa'
    },
    {
      '1': 'estimated_days_to_maturity',
      '3': 4,
      '4': 1,
      '5': 5,
      '10': 'estimatedDaysToMaturity'
    },
    {'1': 'model_version', '3': 5, '4': 1, '5': 9, '10': 'modelVersion'},
    {
      '1': 'processing_time_ms',
      '3': 6,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
  ],
};

/// Descriptor for `SimulateCropGrowthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List simulateCropGrowthResponseDescriptor = $convert.base64Decode(
    'ChpTaW11bGF0ZUNyb3BHcm93dGhSZXNwb25zZRIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZXF1ZX'
    'N0SWQSPAoGc3RhZ2VzGAIgAygLMiQuYWdyaWN1bHR1cmUuYWkudjEuR3Jvd3RoU3RhZ2VSZXN1'
    'bHRSBnN0YWdlcxI0ChdmaW5hbF9iaW9tYXNzX2tnX3Blcl9oYRgDIAEoAVITZmluYWxCaW9tYX'
    'NzS2dQZXJIYRI7Chplc3RpbWF0ZWRfZGF5c190b19tYXR1cml0eRgEIAEoBVIXZXN0aW1hdGVk'
    'RGF5c1RvTWF0dXJpdHkSIwoNbW9kZWxfdmVyc2lvbhgFIAEoCVIMbW9kZWxWZXJzaW9uEiwKEn'
    'Byb2Nlc3NpbmdfdGltZV9tcxgGIAEoA1IQcHJvY2Vzc2luZ1RpbWVNcw==');

@$core.Deprecated('Use growthStageResultDescriptor instead')
const GrowthStageResult$json = {
  '1': 'GrowthStageResult',
  '2': [
    {'1': 'day', '3': 1, '4': 1, '5': 5, '10': 'day'},
    {'1': 'stage_name', '3': 2, '4': 1, '5': 9, '10': 'stageName'},
    {'1': 'biomass_kg_per_ha', '3': 3, '4': 1, '5': 1, '10': 'biomassKgPerHa'},
    {'1': 'leaf_area_index', '3': 4, '4': 1, '5': 1, '10': 'leafAreaIndex'},
    {'1': 'canopy_height_cm', '3': 5, '4': 1, '5': 1, '10': 'canopyHeightCm'},
    {'1': 'water_demand_mm', '3': 6, '4': 1, '5': 1, '10': 'waterDemandMm'},
  ],
};

/// Descriptor for `GrowthStageResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List growthStageResultDescriptor = $convert.base64Decode(
    'ChFHcm93dGhTdGFnZVJlc3VsdBIQCgNkYXkYASABKAVSA2RheRIdCgpzdGFnZV9uYW1lGAIgAS'
    'gJUglzdGFnZU5hbWUSKQoRYmlvbWFzc19rZ19wZXJfaGEYAyABKAFSDmJpb21hc3NLZ1Blckhh'
    'EiYKD2xlYWZfYXJlYV9pbmRleBgEIAEoAVINbGVhZkFyZWFJbmRleBIoChBjYW5vcHlfaGVpZ2'
    'h0X2NtGAUgASgBUg5jYW5vcHlIZWlnaHRDbRImCg93YXRlcl9kZW1hbmRfbW0YBiABKAFSDXdh'
    'dGVyRGVtYW5kTW0=');

@$core.Deprecated('Use computeNDVIRequestDescriptor instead')
const ComputeNDVIRequest$json = {
  '1': 'ComputeNDVIRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'raster_url', '3': 2, '4': 1, '5': 9, '10': 'rasterUrl'},
    {
      '1': 'bands',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.RasterBands',
      '10': 'bands'
    },
    {
      '1': 'clip_bounds',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.BoundingBox',
      '10': 'clipBounds'
    },
  ],
};

/// Descriptor for `ComputeNDVIRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List computeNDVIRequestDescriptor = $convert.base64Decode(
    'ChJDb21wdXRlTkRWSVJlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdWVzdElkEh0KCn'
    'Jhc3Rlcl91cmwYAiABKAlSCXJhc3RlclVybBI0CgViYW5kcxgDIAEoCzIeLmFncmljdWx0dXJl'
    'LmFpLnYxLlJhc3RlckJhbmRzUgViYW5kcxI/CgtjbGlwX2JvdW5kcxgEIAEoCzIeLmFncmljdW'
    'x0dXJlLmFpLnYxLkJvdW5kaW5nQm94UgpjbGlwQm91bmRz');

@$core.Deprecated('Use rasterBandsDescriptor instead')
const RasterBands$json = {
  '1': 'RasterBands',
  '2': [
    {'1': 'nir_band', '3': 1, '4': 3, '5': 1, '10': 'nirBand'},
    {'1': 'red_band', '3': 2, '4': 3, '5': 1, '10': 'redBand'},
    {'1': 'green_band', '3': 3, '4': 3, '5': 1, '10': 'greenBand'},
    {'1': 'blue_band', '3': 4, '4': 3, '5': 1, '10': 'blueBand'},
    {'1': 'red_edge_band', '3': 5, '4': 3, '5': 1, '10': 'redEdgeBand'},
    {'1': 'width', '3': 6, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 7, '4': 1, '5': 5, '10': 'height'},
    {'1': 'scl_band', '3': 8, '4': 3, '5': 1, '10': 'sclBand'},
    {'1': 'qa_pixel_band', '3': 9, '4': 3, '5': 1, '10': 'qaPixelBand'},
    {'1': 'processing_level', '3': 10, '4': 1, '5': 9, '10': 'processingLevel'},
    {'1': 'sensor', '3': 11, '4': 1, '5': 9, '10': 'sensor'},
    {
      '1': 'cloud_buffer_pixels',
      '3': 12,
      '4': 1,
      '5': 5,
      '10': 'cloudBufferPixels'
    },
  ],
};

/// Descriptor for `RasterBands`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rasterBandsDescriptor = $convert.base64Decode(
    'CgtSYXN0ZXJCYW5kcxIZCghuaXJfYmFuZBgBIAMoAVIHbmlyQmFuZBIZCghyZWRfYmFuZBgCIA'
    'MoAVIHcmVkQmFuZBIdCgpncmVlbl9iYW5kGAMgAygBUglncmVlbkJhbmQSGwoJYmx1ZV9iYW5k'
    'GAQgAygBUghibHVlQmFuZBIiCg1yZWRfZWRnZV9iYW5kGAUgAygBUgtyZWRFZGdlQmFuZBIUCg'
    'V3aWR0aBgGIAEoBVIFd2lkdGgSFgoGaGVpZ2h0GAcgASgFUgZoZWlnaHQSGQoIc2NsX2JhbmQY'
    'CCADKAFSB3NjbEJhbmQSIgoNcWFfcGl4ZWxfYmFuZBgJIAMoAVILcWFQaXhlbEJhbmQSKQoQcH'
    'JvY2Vzc2luZ19sZXZlbBgKIAEoCVIPcHJvY2Vzc2luZ0xldmVsEhYKBnNlbnNvchgLIAEoCVIG'
    'c2Vuc29yEi4KE2Nsb3VkX2J1ZmZlcl9waXhlbHMYDCABKAVSEWNsb3VkQnVmZmVyUGl4ZWxz');

@$core.Deprecated('Use boundingBoxDescriptor instead')
const BoundingBox$json = {
  '1': 'BoundingBox',
  '2': [
    {'1': 'min_lon', '3': 1, '4': 1, '5': 1, '10': 'minLon'},
    {'1': 'min_lat', '3': 2, '4': 1, '5': 1, '10': 'minLat'},
    {'1': 'max_lon', '3': 3, '4': 1, '5': 1, '10': 'maxLon'},
    {'1': 'max_lat', '3': 4, '4': 1, '5': 1, '10': 'maxLat'},
  ],
};

/// Descriptor for `BoundingBox`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boundingBoxDescriptor = $convert.base64Decode(
    'CgtCb3VuZGluZ0JveBIXCgdtaW5fbG9uGAEgASgBUgZtaW5Mb24SFwoHbWluX2xhdBgCIAEoAV'
    'IGbWluTGF0EhcKB21heF9sb24YAyABKAFSBm1heExvbhIXCgdtYXhfbGF0GAQgASgBUgZtYXhM'
    'YXQ=');

@$core.Deprecated('Use computeNDVIResponseDescriptor instead')
const ComputeNDVIResponse$json = {
  '1': 'ComputeNDVIResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'ndvi_values', '3': 2, '4': 3, '5': 1, '10': 'ndviValues'},
    {'1': 'width', '3': 3, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 4, '4': 1, '5': 5, '10': 'height'},
    {
      '1': 'statistics',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.BandStatistics',
      '10': 'statistics'
    },
    {
      '1': 'zones',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.NdviZone',
      '10': 'zones'
    },
    {'1': 'model_version', '3': 7, '4': 1, '5': 9, '10': 'modelVersion'},
    {
      '1': 'processing_time_ms',
      '3': 8,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
    {'1': 'cloud_masked', '3': 9, '4': 1, '5': 8, '10': 'cloudMasked'},
    {'1': 'cloud_fraction', '3': 10, '4': 1, '5': 1, '10': 'cloudFraction'},
    {
      '1': 'valid_pixel_fraction',
      '3': 11,
      '4': 1,
      '5': 1,
      '10': 'validPixelFraction'
    },
    {'1': 'processing_level', '3': 12, '4': 1, '5': 9, '10': 'processingLevel'},
    {
      '1': 'processing_advisory',
      '3': 13,
      '4': 1,
      '5': 9,
      '10': 'processingAdvisory'
    },
    {'1': 'sensor', '3': 14, '4': 1, '5': 9, '10': 'sensor'},
    {'1': 'harmonized', '3': 15, '4': 1, '5': 8, '10': 'harmonized'},
  ],
};

/// Descriptor for `ComputeNDVIResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List computeNDVIResponseDescriptor = $convert.base64Decode(
    'ChNDb21wdXRlTkRWSVJlc3BvbnNlEh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcXVlc3RJZBIfCg'
    'tuZHZpX3ZhbHVlcxgCIAMoAVIKbmR2aVZhbHVlcxIUCgV3aWR0aBgDIAEoBVIFd2lkdGgSFgoG'
    'aGVpZ2h0GAQgASgFUgZoZWlnaHQSQQoKc3RhdGlzdGljcxgFIAEoCzIhLmFncmljdWx0dXJlLm'
    'FpLnYxLkJhbmRTdGF0aXN0aWNzUgpzdGF0aXN0aWNzEjEKBXpvbmVzGAYgAygLMhsuYWdyaWN1'
    'bHR1cmUuYWkudjEuTmR2aVpvbmVSBXpvbmVzEiMKDW1vZGVsX3ZlcnNpb24YByABKAlSDG1vZG'
    'VsVmVyc2lvbhIsChJwcm9jZXNzaW5nX3RpbWVfbXMYCCABKANSEHByb2Nlc3NpbmdUaW1lTXMS'
    'IQoMY2xvdWRfbWFza2VkGAkgASgIUgtjbG91ZE1hc2tlZBIlCg5jbG91ZF9mcmFjdGlvbhgKIA'
    'EoAVINY2xvdWRGcmFjdGlvbhIwChR2YWxpZF9waXhlbF9mcmFjdGlvbhgLIAEoAVISdmFsaWRQ'
    'aXhlbEZyYWN0aW9uEikKEHByb2Nlc3NpbmdfbGV2ZWwYDCABKAlSD3Byb2Nlc3NpbmdMZXZlbB'
    'IvChNwcm9jZXNzaW5nX2Fkdmlzb3J5GA0gASgJUhJwcm9jZXNzaW5nQWR2aXNvcnkSFgoGc2Vu'
    'c29yGA4gASgJUgZzZW5zb3ISHgoKaGFybW9uaXplZBgPIAEoCFIKaGFybW9uaXplZA==');

@$core.Deprecated('Use bandStatisticsDescriptor instead')
const BandStatistics$json = {
  '1': 'BandStatistics',
  '2': [
    {'1': 'min', '3': 1, '4': 1, '5': 1, '10': 'min'},
    {'1': 'max', '3': 2, '4': 1, '5': 1, '10': 'max'},
    {'1': 'mean', '3': 3, '4': 1, '5': 1, '10': 'mean'},
    {'1': 'std_dev', '3': 4, '4': 1, '5': 1, '10': 'stdDev'},
    {'1': 'median', '3': 5, '4': 1, '5': 1, '10': 'median'},
    {'1': 'valid_pixel_count', '3': 6, '4': 1, '5': 3, '10': 'validPixelCount'},
  ],
};

/// Descriptor for `BandStatistics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bandStatisticsDescriptor = $convert.base64Decode(
    'Cg5CYW5kU3RhdGlzdGljcxIQCgNtaW4YASABKAFSA21pbhIQCgNtYXgYAiABKAFSA21heBISCg'
    'RtZWFuGAMgASgBUgRtZWFuEhcKB3N0ZF9kZXYYBCABKAFSBnN0ZERldhIWCgZtZWRpYW4YBSAB'
    'KAFSBm1lZGlhbhIqChF2YWxpZF9waXhlbF9jb3VudBgGIAEoA1IPdmFsaWRQaXhlbENvdW50');

@$core.Deprecated('Use ndviZoneDescriptor instead')
const NdviZone$json = {
  '1': 'NdviZone',
  '2': [
    {'1': 'classification', '3': 1, '4': 1, '5': 9, '10': 'classification'},
    {'1': 'min_value', '3': 2, '4': 1, '5': 1, '10': 'minValue'},
    {'1': 'max_value', '3': 3, '4': 1, '5': 1, '10': 'maxValue'},
    {'1': 'pixel_count', '3': 4, '4': 1, '5': 3, '10': 'pixelCount'},
    {'1': 'area_pct', '3': 5, '4': 1, '5': 1, '10': 'areaPct'},
  ],
};

/// Descriptor for `NdviZone`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ndviZoneDescriptor = $convert.base64Decode(
    'CghOZHZpWm9uZRImCg5jbGFzc2lmaWNhdGlvbhgBIAEoCVIOY2xhc3NpZmljYXRpb24SGwoJbW'
    'luX3ZhbHVlGAIgASgBUghtaW5WYWx1ZRIbCgltYXhfdmFsdWUYAyABKAFSCG1heFZhbHVlEh8K'
    'C3BpeGVsX2NvdW50GAQgASgDUgpwaXhlbENvdW50EhkKCGFyZWFfcGN0GAUgASgBUgdhcmVhUG'
    'N0');

@$core.Deprecated('Use detectVegetationStressRequestDescriptor instead')
const DetectVegetationStressRequest$json = {
  '1': 'DetectVegetationStressRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'raster_url', '3': 2, '4': 1, '5': 9, '10': 'rasterUrl'},
    {
      '1': 'bands',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.RasterBands',
      '10': 'bands'
    },
    {
      '1': 'clip_bounds',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.BoundingBox',
      '10': 'clipBounds'
    },
    {
      '1': 'ndvi_stress_threshold',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'ndviStressThreshold'
    },
    {
      '1': 'ndwi_stress_threshold',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'ndwiStressThreshold'
    },
  ],
};

/// Descriptor for `DetectVegetationStressRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectVegetationStressRequestDescriptor = $convert.base64Decode(
    'Ch1EZXRlY3RWZWdldGF0aW9uU3RyZXNzUmVxdWVzdBIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZX'
    'F1ZXN0SWQSHQoKcmFzdGVyX3VybBgCIAEoCVIJcmFzdGVyVXJsEjQKBWJhbmRzGAMgASgLMh4u'
    'YWdyaWN1bHR1cmUuYWkudjEuUmFzdGVyQmFuZHNSBWJhbmRzEj8KC2NsaXBfYm91bmRzGAQgAS'
    'gLMh4uYWdyaWN1bHR1cmUuYWkudjEuQm91bmRpbmdCb3hSCmNsaXBCb3VuZHMSMgoVbmR2aV9z'
    'dHJlc3NfdGhyZXNob2xkGAUgASgBUhNuZHZpU3RyZXNzVGhyZXNob2xkEjIKFW5kd2lfc3RyZX'
    'NzX3RocmVzaG9sZBgGIAEoAVITbmR3aVN0cmVzc1RocmVzaG9sZA==');

@$core.Deprecated('Use detectVegetationStressResponseDescriptor instead')
const DetectVegetationStressResponse$json = {
  '1': 'DetectVegetationStressResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'stress_zones',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.StressZone',
      '10': 'stressZones'
    },
    {
      '1': 'overall_stress_pct',
      '3': 3,
      '4': 1,
      '5': 1,
      '10': 'overallStressPct'
    },
    {'1': 'healthy_pct', '3': 4, '4': 1, '5': 1, '10': 'healthyPct'},
    {
      '1': 'ndvi_statistics',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.BandStatistics',
      '10': 'ndviStatistics'
    },
    {'1': 'model_version', '3': 6, '4': 1, '5': 9, '10': 'modelVersion'},
    {
      '1': 'processing_time_ms',
      '3': 7,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
  ],
};

/// Descriptor for `DetectVegetationStressResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectVegetationStressResponseDescriptor = $convert.base64Decode(
    'Ch5EZXRlY3RWZWdldGF0aW9uU3RyZXNzUmVzcG9uc2USHQoKcmVxdWVzdF9pZBgBIAEoCVIJcm'
    'VxdWVzdElkEkAKDHN0cmVzc196b25lcxgCIAMoCzIdLmFncmljdWx0dXJlLmFpLnYxLlN0cmVz'
    'c1pvbmVSC3N0cmVzc1pvbmVzEiwKEm92ZXJhbGxfc3RyZXNzX3BjdBgDIAEoAVIQb3ZlcmFsbF'
    'N0cmVzc1BjdBIfCgtoZWFsdGh5X3BjdBgEIAEoAVIKaGVhbHRoeVBjdBJKCg9uZHZpX3N0YXRp'
    'c3RpY3MYBSABKAsyIS5hZ3JpY3VsdHVyZS5haS52MS5CYW5kU3RhdGlzdGljc1IObmR2aVN0YX'
    'Rpc3RpY3MSIwoNbW9kZWxfdmVyc2lvbhgGIAEoCVIMbW9kZWxWZXJzaW9uEiwKEnByb2Nlc3Np'
    'bmdfdGltZV9tcxgHIAEoA1IQcHJvY2Vzc2luZ1RpbWVNcw==');

@$core.Deprecated('Use stressZoneDescriptor instead')
const StressZone$json = {
  '1': 'StressZone',
  '2': [
    {'1': 'stress_type', '3': 1, '4': 1, '5': 9, '10': 'stressType'},
    {'1': 'severity', '3': 2, '4': 1, '5': 9, '10': 'severity'},
    {'1': 'affected_area_pct', '3': 3, '4': 1, '5': 1, '10': 'affectedAreaPct'},
    {'1': 'confidence', '3': 4, '4': 1, '5': 1, '10': 'confidence'},
    {
      '1': 'bounds',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.BoundingBox',
      '10': 'bounds'
    },
  ],
};

/// Descriptor for `StressZone`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stressZoneDescriptor = $convert.base64Decode(
    'CgpTdHJlc3Nab25lEh8KC3N0cmVzc190eXBlGAEgASgJUgpzdHJlc3NUeXBlEhoKCHNldmVyaX'
    'R5GAIgASgJUghzZXZlcml0eRIqChFhZmZlY3RlZF9hcmVhX3BjdBgDIAEoAVIPYWZmZWN0ZWRB'
    'cmVhUGN0Eh4KCmNvbmZpZGVuY2UYBCABKAFSCmNvbmZpZGVuY2USNgoGYm91bmRzGAUgASgLMh'
    '4uYWdyaWN1bHR1cmUuYWkudjEuQm91bmRpbmdCb3hSBmJvdW5kcw==');

@$core.Deprecated('Use recommendCropsRequestDescriptor instead')
const RecommendCropsRequest$json = {
  '1': 'RecommendCropsRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'soil',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.SoilConditions',
      '10': 'soil'
    },
    {
      '1': 'climate',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.ClimateConditions',
      '10': 'climate'
    },
    {
      '1': 'economics',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.EconomicFactors',
      '10': 'economics'
    },
    {
      '1': 'max_recommendations',
      '3': 5,
      '4': 1,
      '5': 5,
      '10': 'maxRecommendations'
    },
  ],
};

/// Descriptor for `RecommendCropsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recommendCropsRequestDescriptor = $convert.base64Decode(
    'ChVSZWNvbW1lbmRDcm9wc1JlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdWVzdElkEj'
    'UKBHNvaWwYAiABKAsyIS5hZ3JpY3VsdHVyZS5haS52MS5Tb2lsQ29uZGl0aW9uc1IEc29pbBI+'
    'CgdjbGltYXRlGAMgASgLMiQuYWdyaWN1bHR1cmUuYWkudjEuQ2xpbWF0ZUNvbmRpdGlvbnNSB2'
    'NsaW1hdGUSQAoJZWNvbm9taWNzGAQgASgLMiIuYWdyaWN1bHR1cmUuYWkudjEuRWNvbm9taWNG'
    'YWN0b3JzUgllY29ub21pY3MSLwoTbWF4X3JlY29tbWVuZGF0aW9ucxgFIAEoBVISbWF4UmVjb2'
    '1tZW5kYXRpb25z');

@$core.Deprecated('Use soilConditionsDescriptor instead')
const SoilConditions$json = {
  '1': 'SoilConditions',
  '2': [
    {'1': 'ph', '3': 1, '4': 1, '5': 1, '10': 'ph'},
    {
      '1': 'organic_matter_pct',
      '3': 2,
      '4': 1,
      '5': 1,
      '10': 'organicMatterPct'
    },
    {'1': 'nitrogen_ppm', '3': 3, '4': 1, '5': 1, '10': 'nitrogenPpm'},
    {'1': 'phosphorus_ppm', '3': 4, '4': 1, '5': 1, '10': 'phosphorusPpm'},
    {'1': 'potassium_ppm', '3': 5, '4': 1, '5': 1, '10': 'potassiumPpm'},
    {'1': 'texture', '3': 6, '4': 1, '5': 9, '10': 'texture'},
    {'1': 'drainage_class', '3': 7, '4': 1, '5': 9, '10': 'drainageClass'},
  ],
};

/// Descriptor for `SoilConditions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List soilConditionsDescriptor = $convert.base64Decode(
    'Cg5Tb2lsQ29uZGl0aW9ucxIOCgJwaBgBIAEoAVICcGgSLAoSb3JnYW5pY19tYXR0ZXJfcGN0GA'
    'IgASgBUhBvcmdhbmljTWF0dGVyUGN0EiEKDG5pdHJvZ2VuX3BwbRgDIAEoAVILbml0cm9nZW5Q'
    'cG0SJQoOcGhvc3Bob3J1c19wcG0YBCABKAFSDXBob3NwaG9ydXNQcG0SIwoNcG90YXNzaXVtX3'
    'BwbRgFIAEoAVIMcG90YXNzaXVtUHBtEhgKB3RleHR1cmUYBiABKAlSB3RleHR1cmUSJQoOZHJh'
    'aW5hZ2VfY2xhc3MYByABKAlSDWRyYWluYWdlQ2xhc3M=');

@$core.Deprecated('Use climateConditionsDescriptor instead')
const ClimateConditions$json = {
  '1': 'ClimateConditions',
  '2': [
    {
      '1': 'avg_temperature_celsius',
      '3': 1,
      '4': 1,
      '5': 1,
      '10': 'avgTemperatureCelsius'
    },
    {
      '1': 'annual_rainfall_mm',
      '3': 2,
      '4': 1,
      '5': 1,
      '10': 'annualRainfallMm'
    },
    {'1': 'avg_humidity_pct', '3': 3, '4': 1, '5': 1, '10': 'avgHumidityPct'},
    {'1': 'frost_free_days', '3': 4, '4': 1, '5': 1, '10': 'frostFreeDays'},
    {
      '1': 'solar_radiation_kwh',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'solarRadiationKwh'
    },
    {'1': 'climate_zone', '3': 6, '4': 1, '5': 9, '10': 'climateZone'},
  ],
};

/// Descriptor for `ClimateConditions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List climateConditionsDescriptor = $convert.base64Decode(
    'ChFDbGltYXRlQ29uZGl0aW9ucxI2ChdhdmdfdGVtcGVyYXR1cmVfY2Vsc2l1cxgBIAEoAVIVYX'
    'ZnVGVtcGVyYXR1cmVDZWxzaXVzEiwKEmFubnVhbF9yYWluZmFsbF9tbRgCIAEoAVIQYW5udWFs'
    'UmFpbmZhbGxNbRIoChBhdmdfaHVtaWRpdHlfcGN0GAMgASgBUg5hdmdIdW1pZGl0eVBjdBImCg'
    '9mcm9zdF9mcmVlX2RheXMYBCABKAFSDWZyb3N0RnJlZURheXMSLgoTc29sYXJfcmFkaWF0aW9u'
    'X2t3aBgFIAEoAVIRc29sYXJSYWRpYXRpb25Ld2gSIQoMY2xpbWF0ZV96b25lGAYgASgJUgtjbG'
    'ltYXRlWm9uZQ==');

@$core.Deprecated('Use economicFactorsDescriptor instead')
const EconomicFactors$json = {
  '1': 'EconomicFactors',
  '2': [
    {
      '1': 'market_price_per_kg',
      '3': 1,
      '4': 1,
      '5': 1,
      '10': 'marketPricePerKg'
    },
    {
      '1': 'input_cost_per_hectare',
      '3': 2,
      '4': 1,
      '5': 1,
      '10': 'inputCostPerHectare'
    },
    {
      '1': 'labor_cost_per_hectare',
      '3': 3,
      '4': 1,
      '5': 1,
      '10': 'laborCostPerHectare'
    },
    {
      '1': 'water_cost_per_cubic_meter',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'waterCostPerCubicMeter'
    },
    {'1': 'organic_premium', '3': 5, '4': 1, '5': 8, '10': 'organicPremium'},
  ],
};

/// Descriptor for `EconomicFactors`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List economicFactorsDescriptor = $convert.base64Decode(
    'Cg9FY29ub21pY0ZhY3RvcnMSLQoTbWFya2V0X3ByaWNlX3Blcl9rZxgBIAEoAVIQbWFya2V0UH'
    'JpY2VQZXJLZxIzChZpbnB1dF9jb3N0X3Blcl9oZWN0YXJlGAIgASgBUhNpbnB1dENvc3RQZXJI'
    'ZWN0YXJlEjMKFmxhYm9yX2Nvc3RfcGVyX2hlY3RhcmUYAyABKAFSE2xhYm9yQ29zdFBlckhlY3'
    'RhcmUSOgoad2F0ZXJfY29zdF9wZXJfY3ViaWNfbWV0ZXIYBCABKAFSFndhdGVyQ29zdFBlckN1'
    'YmljTWV0ZXISJwoPb3JnYW5pY19wcmVtaXVtGAUgASgIUg5vcmdhbmljUHJlbWl1bQ==');

@$core.Deprecated('Use recommendCropsResponseDescriptor instead')
const RecommendCropsResponse$json = {
  '1': 'RecommendCropsResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'recommendations',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.CropRecommendation',
      '10': 'recommendations'
    },
    {'1': 'model_version', '3': 3, '4': 1, '5': 9, '10': 'modelVersion'},
    {
      '1': 'processing_time_ms',
      '3': 4,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
  ],
};

/// Descriptor for `RecommendCropsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recommendCropsResponseDescriptor = $convert.base64Decode(
    'ChZSZWNvbW1lbmRDcm9wc1Jlc3BvbnNlEh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcXVlc3RJZB'
    'JPCg9yZWNvbW1lbmRhdGlvbnMYAiADKAsyJS5hZ3JpY3VsdHVyZS5haS52MS5Dcm9wUmVjb21t'
    'ZW5kYXRpb25SD3JlY29tbWVuZGF0aW9ucxIjCg1tb2RlbF92ZXJzaW9uGAMgASgJUgxtb2RlbF'
    'ZlcnNpb24SLAoScHJvY2Vzc2luZ190aW1lX21zGAQgASgDUhBwcm9jZXNzaW5nVGltZU1z');

@$core.Deprecated('Use cropRecommendationDescriptor instead')
const CropRecommendation$json = {
  '1': 'CropRecommendation',
  '2': [
    {'1': 'crop_name', '3': 1, '4': 1, '5': 9, '10': 'cropName'},
    {'1': 'scientific_name', '3': 2, '4': 1, '5': 9, '10': 'scientificName'},
    {'1': 'category', '3': 3, '4': 1, '5': 9, '10': 'category'},
    {
      '1': 'suitability_score',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'suitabilityScore'
    },
    {'1': 'confidence', '3': 5, '4': 1, '5': 1, '10': 'confidence'},
    {
      '1': 'expected_yield_kg_per_ha',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'expectedYieldKgPerHa'
    },
    {
      '1': 'expected_profit_per_ha',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'expectedProfitPerHa'
    },
    {
      '1': 'water_requirement_mm',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'waterRequirementMm'
    },
    {'1': 'rationale', '3': 9, '4': 1, '5': 9, '10': 'rationale'},
    {'1': 'risk_factors', '3': 10, '4': 3, '5': 9, '10': 'riskFactors'},
  ],
};

/// Descriptor for `CropRecommendation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cropRecommendationDescriptor = $convert.base64Decode(
    'ChJDcm9wUmVjb21tZW5kYXRpb24SGwoJY3JvcF9uYW1lGAEgASgJUghjcm9wTmFtZRInCg9zY2'
    'llbnRpZmljX25hbWUYAiABKAlSDnNjaWVudGlmaWNOYW1lEhoKCGNhdGVnb3J5GAMgASgJUghj'
    'YXRlZ29yeRIrChFzdWl0YWJpbGl0eV9zY29yZRgEIAEoAVIQc3VpdGFiaWxpdHlTY29yZRIeCg'
    'pjb25maWRlbmNlGAUgASgBUgpjb25maWRlbmNlEjYKGGV4cGVjdGVkX3lpZWxkX2tnX3Blcl9o'
    'YRgGIAEoAVIUZXhwZWN0ZWRZaWVsZEtnUGVySGESMwoWZXhwZWN0ZWRfcHJvZml0X3Blcl9oYR'
    'gHIAEoAVITZXhwZWN0ZWRQcm9maXRQZXJIYRIwChR3YXRlcl9yZXF1aXJlbWVudF9tbRgIIAEo'
    'AVISd2F0ZXJSZXF1aXJlbWVudE1tEhwKCXJhdGlvbmFsZRgJIAEoCVIJcmF0aW9uYWxlEiEKDH'
    'Jpc2tfZmFjdG9ycxgKIAMoCVILcmlza0ZhY3RvcnM=');

@$core.Deprecated('Use imageDataDescriptor instead')
const ImageData$json = {
  '1': 'ImageData',
  '2': [
    {'1': 'image_url', '3': 1, '4': 1, '5': 9, '10': 'imageUrl'},
    {'1': 'image_bytes', '3': 2, '4': 1, '5': 12, '10': 'imageBytes'},
    {'1': 'image_type', '3': 3, '4': 1, '5': 9, '10': 'imageType'},
    {'1': 'mime_type', '3': 4, '4': 1, '5': 9, '10': 'mimeType'},
  ],
};

/// Descriptor for `ImageData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageDataDescriptor = $convert.base64Decode(
    'CglJbWFnZURhdGESGwoJaW1hZ2VfdXJsGAEgASgJUghpbWFnZVVybBIfCgtpbWFnZV9ieXRlcx'
    'gCIAEoDFIKaW1hZ2VCeXRlcxIdCgppbWFnZV90eXBlGAMgASgJUglpbWFnZVR5cGUSGwoJbWlt'
    'ZV90eXBlGAQgASgJUghtaW1lVHlwZQ==');

@$core.Deprecated('Use evaluateFieldRiskRequestDescriptor instead')
const EvaluateFieldRiskRequest$json = {
  '1': 'EvaluateFieldRiskRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'crop_type', '3': 4, '4': 1, '5': 9, '10': 'cropType'},
    {
      '1': 'weather',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.FieldWeather',
      '10': 'weather'
    },
    {
      '1': 'soil_state',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.FieldSoilState',
      '10': 'soilState'
    },
    {
      '1': 'detections',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.DetectionResults',
      '10': 'detections'
    },
    {
      '1': 'growth',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.GrowthState',
      '10': 'growth'
    },
  ],
};

/// Descriptor for `EvaluateFieldRiskRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List evaluateFieldRiskRequestDescriptor = $convert.base64Decode(
    'ChhFdmFsdWF0ZUZpZWxkUmlza1JlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdWVzdE'
    'lkEhkKCGZpZWxkX2lkGAIgASgJUgdmaWVsZElkEhcKB2Zhcm1faWQYAyABKAlSBmZhcm1JZBIb'
    'Cgljcm9wX3R5cGUYBCABKAlSCGNyb3BUeXBlEjkKB3dlYXRoZXIYBSABKAsyHy5hZ3JpY3VsdH'
    'VyZS5haS52MS5GaWVsZFdlYXRoZXJSB3dlYXRoZXISQAoKc29pbF9zdGF0ZRgGIAEoCzIhLmFn'
    'cmljdWx0dXJlLmFpLnYxLkZpZWxkU29pbFN0YXRlUglzb2lsU3RhdGUSQwoKZGV0ZWN0aW9ucx'
    'gHIAEoCzIjLmFncmljdWx0dXJlLmFpLnYxLkRldGVjdGlvblJlc3VsdHNSCmRldGVjdGlvbnMS'
    'NgoGZ3Jvd3RoGAggASgLMh4uYWdyaWN1bHR1cmUuYWkudjEuR3Jvd3RoU3RhdGVSBmdyb3d0aA'
    '==');

@$core.Deprecated('Use fieldWeatherDescriptor instead')
const FieldWeather$json = {
  '1': 'FieldWeather',
  '2': [
    {
      '1': 'temperature_current',
      '3': 1,
      '4': 1,
      '5': 1,
      '10': 'temperatureCurrent'
    },
    {
      '1': 'temperature_min_forecast',
      '3': 2,
      '4': 1,
      '5': 1,
      '10': 'temperatureMinForecast'
    },
    {
      '1': 'temperature_max_forecast',
      '3': 3,
      '4': 1,
      '5': 1,
      '10': 'temperatureMaxForecast'
    },
    {'1': 'precipitation_mm', '3': 4, '4': 1, '5': 1, '10': 'precipitationMm'},
    {
      '1': 'precipitation_forecast_mm',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'precipitationForecastMm'
    },
    {'1': 'et_reference_mm', '3': 6, '4': 1, '5': 1, '10': 'etReferenceMm'},
    {'1': 'co2_ppm', '3': 7, '4': 1, '5': 1, '10': 'co2Ppm'},
  ],
};

/// Descriptor for `FieldWeather`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldWeatherDescriptor = $convert.base64Decode(
    'CgxGaWVsZFdlYXRoZXISLwoTdGVtcGVyYXR1cmVfY3VycmVudBgBIAEoAVISdGVtcGVyYXR1cm'
    'VDdXJyZW50EjgKGHRlbXBlcmF0dXJlX21pbl9mb3JlY2FzdBgCIAEoAVIWdGVtcGVyYXR1cmVN'
    'aW5Gb3JlY2FzdBI4Chh0ZW1wZXJhdHVyZV9tYXhfZm9yZWNhc3QYAyABKAFSFnRlbXBlcmF0dX'
    'JlTWF4Rm9yZWNhc3QSKQoQcHJlY2lwaXRhdGlvbl9tbRgEIAEoAVIPcHJlY2lwaXRhdGlvbk1t'
    'EjoKGXByZWNpcGl0YXRpb25fZm9yZWNhc3RfbW0YBSABKAFSF3ByZWNpcGl0YXRpb25Gb3JlY2'
    'FzdE1tEiYKD2V0X3JlZmVyZW5jZV9tbRgGIAEoAVINZXRSZWZlcmVuY2VNbRIXCgdjbzJfcHBt'
    'GAcgASgBUgZjbzJQcG0=');

@$core.Deprecated('Use fieldSoilStateDescriptor instead')
const FieldSoilState$json = {
  '1': 'FieldSoilState',
  '2': [
    {'1': 'soil_moisture', '3': 1, '4': 1, '5': 1, '10': 'soilMoisture'},
  ],
};

/// Descriptor for `FieldSoilState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldSoilStateDescriptor = $convert.base64Decode(
    'Cg5GaWVsZFNvaWxTdGF0ZRIjCg1zb2lsX21vaXN0dXJlGAEgASgBUgxzb2lsTW9pc3R1cmU=');

@$core.Deprecated('Use detectionResultsDescriptor instead')
const DetectionResults$json = {
  '1': 'DetectionResults',
  '2': [
    {'1': 'pest_confidence', '3': 1, '4': 1, '5': 1, '10': 'pestConfidence'},
    {'1': 'pest_species', '3': 2, '4': 1, '5': 9, '10': 'pestSpecies'},
    {
      '1': 'disease_confidence',
      '3': 3,
      '4': 1,
      '5': 1,
      '10': 'diseaseConfidence'
    },
    {'1': 'disease_name', '3': 4, '4': 1, '5': 9, '10': 'diseaseName'},
    {
      '1': 'nutrient_severity',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'nutrientSeverity'
    },
    {'1': 'nutrient_type', '3': 6, '4': 1, '5': 9, '10': 'nutrientType'},
  ],
};

/// Descriptor for `DetectionResults`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectionResultsDescriptor = $convert.base64Decode(
    'ChBEZXRlY3Rpb25SZXN1bHRzEicKD3Blc3RfY29uZmlkZW5jZRgBIAEoAVIOcGVzdENvbmZpZG'
    'VuY2USIQoMcGVzdF9zcGVjaWVzGAIgASgJUgtwZXN0U3BlY2llcxItChJkaXNlYXNlX2NvbmZp'
    'ZGVuY2UYAyABKAFSEWRpc2Vhc2VDb25maWRlbmNlEiEKDGRpc2Vhc2VfbmFtZRgEIAEoCVILZG'
    'lzZWFzZU5hbWUSKwoRbnV0cmllbnRfc2V2ZXJpdHkYBSABKAFSEG51dHJpZW50U2V2ZXJpdHkS'
    'IwoNbnV0cmllbnRfdHlwZRgGIAEoCVIMbnV0cmllbnRUeXBl');

@$core.Deprecated('Use growthStateDescriptor instead')
const GrowthState$json = {
  '1': 'GrowthState',
  '2': [
    {'1': 'ndvi_current', '3': 1, '4': 1, '5': 1, '10': 'ndviCurrent'},
    {'1': 'ndvi_previous', '3': 2, '4': 1, '5': 1, '10': 'ndviPrevious'},
    {'1': 'growth_expected', '3': 3, '4': 1, '5': 1, '10': 'growthExpected'},
    {'1': 'growth_actual', '3': 4, '4': 1, '5': 1, '10': 'growthActual'},
  ],
};

/// Descriptor for `GrowthState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List growthStateDescriptor = $convert.base64Decode(
    'CgtHcm93dGhTdGF0ZRIhCgxuZHZpX2N1cnJlbnQYASABKAFSC25kdmlDdXJyZW50EiMKDW5kdm'
    'lfcHJldmlvdXMYAiABKAFSDG5kdmlQcmV2aW91cxInCg9ncm93dGhfZXhwZWN0ZWQYAyABKAFS'
    'Dmdyb3d0aEV4cGVjdGVkEiMKDWdyb3d0aF9hY3R1YWwYBCABKAFSDGdyb3d0aEFjdHVhbA==');

@$core.Deprecated('Use evaluateFieldRiskResponseDescriptor instead')
const EvaluateFieldRiskResponse$json = {
  '1': 'EvaluateFieldRiskResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'overall_risk', '3': 3, '4': 1, '5': 1, '10': 'overallRisk'},
    {'1': 'temperature_risk', '3': 4, '4': 1, '5': 1, '10': 'temperatureRisk'},
    {'1': 'water_risk', '3': 5, '4': 1, '5': 1, '10': 'waterRisk'},
    {'1': 'pest_risk', '3': 6, '4': 1, '5': 1, '10': 'pestRisk'},
    {'1': 'disease_risk', '3': 7, '4': 1, '5': 1, '10': 'diseaseRisk'},
    {'1': 'nutrient_risk', '3': 8, '4': 1, '5': 1, '10': 'nutrientRisk'},
    {'1': 'growth_risk', '3': 9, '4': 1, '5': 1, '10': 'growthRisk'},
    {
      '1': 'alerts',
      '3': 10,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.FieldAlert',
      '10': 'alerts'
    },
    {
      '1': 'processing_time_ms',
      '3': 11,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
  ],
};

/// Descriptor for `EvaluateFieldRiskResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List evaluateFieldRiskResponseDescriptor = $convert.base64Decode(
    'ChlFdmFsdWF0ZUZpZWxkUmlza1Jlc3BvbnNlEh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcXVlc3'
    'RJZBIZCghmaWVsZF9pZBgCIAEoCVIHZmllbGRJZBIhCgxvdmVyYWxsX3Jpc2sYAyABKAFSC292'
    'ZXJhbGxSaXNrEikKEHRlbXBlcmF0dXJlX3Jpc2sYBCABKAFSD3RlbXBlcmF0dXJlUmlzaxIdCg'
    'p3YXRlcl9yaXNrGAUgASgBUgl3YXRlclJpc2sSGwoJcGVzdF9yaXNrGAYgASgBUghwZXN0Umlz'
    'axIhCgxkaXNlYXNlX3Jpc2sYByABKAFSC2Rpc2Vhc2VSaXNrEiMKDW51dHJpZW50X3Jpc2sYCC'
    'ABKAFSDG51dHJpZW50UmlzaxIfCgtncm93dGhfcmlzaxgJIAEoAVIKZ3Jvd3RoUmlzaxI1CgZh'
    'bGVydHMYCiADKAsyHS5hZ3JpY3VsdHVyZS5haS52MS5GaWVsZEFsZXJ0UgZhbGVydHMSLAoScH'
    'JvY2Vzc2luZ190aW1lX21zGAsgASgDUhBwcm9jZXNzaW5nVGltZU1z');

@$core.Deprecated('Use fieldAlertDescriptor instead')
const FieldAlert$json = {
  '1': 'FieldAlert',
  '2': [
    {'1': 'alert_type', '3': 1, '4': 1, '5': 9, '10': 'alertType'},
    {'1': 'severity', '3': 2, '4': 1, '5': 9, '10': 'severity'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'message', '3': 4, '4': 1, '5': 9, '10': 'message'},
    {'1': 'recommendations', '3': 5, '4': 3, '5': 9, '10': 'recommendations'},
    {'1': 'metric_value', '3': 6, '4': 1, '5': 1, '10': 'metricValue'},
    {'1': 'threshold_value', '3': 7, '4': 1, '5': 1, '10': 'thresholdValue'},
  ],
};

/// Descriptor for `FieldAlert`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fieldAlertDescriptor = $convert.base64Decode(
    'CgpGaWVsZEFsZXJ0Eh0KCmFsZXJ0X3R5cGUYASABKAlSCWFsZXJ0VHlwZRIaCghzZXZlcml0eR'
    'gCIAEoCVIIc2V2ZXJpdHkSFAoFdGl0bGUYAyABKAlSBXRpdGxlEhgKB21lc3NhZ2UYBCABKAlS'
    'B21lc3NhZ2USKAoPcmVjb21tZW5kYXRpb25zGAUgAygJUg9yZWNvbW1lbmRhdGlvbnMSIQoMbW'
    'V0cmljX3ZhbHVlGAYgASgBUgttZXRyaWNWYWx1ZRInCg90aHJlc2hvbGRfdmFsdWUYByABKAFS'
    'DnRocmVzaG9sZFZhbHVl');

@$core.Deprecated('Use computeFieldAnalyticsRequestDescriptor instead')
const ComputeFieldAnalyticsRequest$json = {
  '1': 'ComputeFieldAnalyticsRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {
      '1': 'seasons',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.SeasonRecord',
      '10': 'seasons'
    },
    {
      '1': 'ndvi_series',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.NdviDataPoint',
      '10': 'ndviSeries'
    },
  ],
};

/// Descriptor for `ComputeFieldAnalyticsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List computeFieldAnalyticsRequestDescriptor = $convert.base64Decode(
    'ChxDb21wdXRlRmllbGRBbmFseXRpY3NSZXF1ZXN0Eh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcX'
    'Vlc3RJZBIZCghmaWVsZF9pZBgCIAEoCVIHZmllbGRJZBIXCgdmYXJtX2lkGAMgASgJUgZmYXJt'
    'SWQSOQoHc2Vhc29ucxgEIAMoCzIfLmFncmljdWx0dXJlLmFpLnYxLlNlYXNvblJlY29yZFIHc2'
    'Vhc29ucxJBCgtuZHZpX3NlcmllcxgFIAMoCzIgLmFncmljdWx0dXJlLmFpLnYxLk5kdmlEYXRh'
    'UG9pbnRSCm5kdmlTZXJpZXM=');

@$core.Deprecated('Use seasonRecordDescriptor instead')
const SeasonRecord$json = {
  '1': 'SeasonRecord',
  '2': [
    {'1': 'crop_type', '3': 1, '4': 1, '5': 9, '10': 'cropType'},
    {'1': 'season', '3': 2, '4': 1, '5': 9, '10': 'season'},
    {'1': 'year', '3': 3, '4': 1, '5': 5, '10': 'year'},
    {'1': 'yield_kg_per_ha', '3': 4, '4': 1, '5': 1, '10': 'yieldKgPerHa'},
    {'1': 'stress_days', '3': 5, '4': 1, '5': 13, '10': 'stressDays'},
    {'1': 'frost_events', '3': 6, '4': 1, '5': 13, '10': 'frostEvents'},
    {'1': 'heat_events', '3': 7, '4': 1, '5': 13, '10': 'heatEvents'},
    {'1': 'drought_days', '3': 8, '4': 1, '5': 13, '10': 'droughtDays'},
    {
      '1': 'total_precipitation_mm',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'totalPrecipitationMm'
    },
    {'1': 'mean_temperature', '3': 10, '4': 1, '5': 1, '10': 'meanTemperature'},
    {'1': 'mean_ndvi', '3': 11, '4': 1, '5': 1, '10': 'meanNdvi'},
    {'1': 'peak_ndvi', '3': 12, '4': 1, '5': 1, '10': 'peakNdvi'},
    {
      '1': 'total_thermal_time',
      '3': 13,
      '4': 1,
      '5': 1,
      '10': 'totalThermalTime'
    },
  ],
};

/// Descriptor for `SeasonRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List seasonRecordDescriptor = $convert.base64Decode(
    'CgxTZWFzb25SZWNvcmQSGwoJY3JvcF90eXBlGAEgASgJUghjcm9wVHlwZRIWCgZzZWFzb24YAi'
    'ABKAlSBnNlYXNvbhISCgR5ZWFyGAMgASgFUgR5ZWFyEiUKD3lpZWxkX2tnX3Blcl9oYRgEIAEo'
    'AVIMeWllbGRLZ1BlckhhEh8KC3N0cmVzc19kYXlzGAUgASgNUgpzdHJlc3NEYXlzEiEKDGZyb3'
    'N0X2V2ZW50cxgGIAEoDVILZnJvc3RFdmVudHMSHwoLaGVhdF9ldmVudHMYByABKA1SCmhlYXRF'
    'dmVudHMSIQoMZHJvdWdodF9kYXlzGAggASgNUgtkcm91Z2h0RGF5cxI0ChZ0b3RhbF9wcmVjaX'
    'BpdGF0aW9uX21tGAkgASgBUhR0b3RhbFByZWNpcGl0YXRpb25NbRIpChBtZWFuX3RlbXBlcmF0'
    'dXJlGAogASgBUg9tZWFuVGVtcGVyYXR1cmUSGwoJbWVhbl9uZHZpGAsgASgBUghtZWFuTmR2aR'
    'IbCglwZWFrX25kdmkYDCABKAFSCHBlYWtOZHZpEiwKEnRvdGFsX3RoZXJtYWxfdGltZRgNIAEo'
    'AVIQdG90YWxUaGVybWFsVGltZQ==');

@$core.Deprecated('Use ndviDataPointDescriptor instead')
const NdviDataPoint$json = {
  '1': 'NdviDataPoint',
  '2': [
    {'1': 'date', '3': 1, '4': 1, '5': 9, '10': 'date'},
    {'1': 'mean_ndvi', '3': 2, '4': 1, '5': 1, '10': 'meanNdvi'},
    {'1': 'min_ndvi', '3': 3, '4': 1, '5': 1, '10': 'minNdvi'},
    {'1': 'max_ndvi', '3': 4, '4': 1, '5': 1, '10': 'maxNdvi'},
    {'1': 'std_dev', '3': 5, '4': 1, '5': 1, '10': 'stdDev'},
  ],
};

/// Descriptor for `NdviDataPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ndviDataPointDescriptor = $convert.base64Decode(
    'Cg1OZHZpRGF0YVBvaW50EhIKBGRhdGUYASABKAlSBGRhdGUSGwoJbWVhbl9uZHZpGAIgASgBUg'
    'htZWFuTmR2aRIZCghtaW5fbmR2aRgDIAEoAVIHbWluTmR2aRIZCghtYXhfbmR2aRgEIAEoAVIH'
    'bWF4TmR2aRIXCgdzdGRfZGV2GAUgASgBUgZzdGREZXY=');

@$core.Deprecated('Use computeFieldAnalyticsResponseDescriptor instead')
const ComputeFieldAnalyticsResponse$json = {
  '1': 'ComputeFieldAnalyticsResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'season_count', '3': 3, '4': 1, '5': 5, '10': 'seasonCount'},
    {'1': 'yield_trend', '3': 4, '4': 1, '5': 9, '10': 'yieldTrend'},
    {
      '1': 'yield_trend_pct_per_year',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'yieldTrendPctPerYear'
    },
    {'1': 'mean_yield', '3': 6, '4': 1, '5': 1, '10': 'meanYield'},
    {'1': 'best_yield', '3': 7, '4': 1, '5': 1, '10': 'bestYield'},
    {'1': 'worst_yield', '3': 8, '4': 1, '5': 1, '10': 'worstYield'},
    {
      '1': 'yield_variability_cv',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'yieldVariabilityCv'
    },
    {'1': 'ndvi_trend', '3': 10, '4': 1, '5': 9, '10': 'ndviTrend'},
    {
      '1': 'ndvi_trend_per_year',
      '3': 11,
      '4': 1,
      '5': 1,
      '10': 'ndviTrendPerYear'
    },
    {
      '1': 'mean_stress_days_per_season',
      '3': 12,
      '4': 1,
      '5': 1,
      '10': 'meanStressDaysPerSeason'
    },
    {
      '1': 'rotation',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.RotationAnalysis',
      '10': 'rotation'
    },
    {
      '1': 'season_comparisons',
      '3': 14,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.SeasonComparisonResult',
      '10': 'seasonComparisons'
    },
    {
      '1': 'processing_time_ms',
      '3': 15,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
  ],
};

/// Descriptor for `ComputeFieldAnalyticsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List computeFieldAnalyticsResponseDescriptor = $convert.base64Decode(
    'Ch1Db21wdXRlRmllbGRBbmFseXRpY3NSZXNwb25zZRIdCgpyZXF1ZXN0X2lkGAEgASgJUglyZX'
    'F1ZXN0SWQSGQoIZmllbGRfaWQYAiABKAlSB2ZpZWxkSWQSIQoMc2Vhc29uX2NvdW50GAMgASgF'
    'UgtzZWFzb25Db3VudBIfCgt5aWVsZF90cmVuZBgEIAEoCVIKeWllbGRUcmVuZBI2Chh5aWVsZF'
    '90cmVuZF9wY3RfcGVyX3llYXIYBSABKAFSFHlpZWxkVHJlbmRQY3RQZXJZZWFyEh0KCm1lYW5f'
    'eWllbGQYBiABKAFSCW1lYW5ZaWVsZBIdCgpiZXN0X3lpZWxkGAcgASgBUgliZXN0WWllbGQSHw'
    'oLd29yc3RfeWllbGQYCCABKAFSCndvcnN0WWllbGQSMAoUeWllbGRfdmFyaWFiaWxpdHlfY3YY'
    'CSABKAFSEnlpZWxkVmFyaWFiaWxpdHlDdhIdCgpuZHZpX3RyZW5kGAogASgJUgluZHZpVHJlbm'
    'QSLQoTbmR2aV90cmVuZF9wZXJfeWVhchgLIAEoAVIQbmR2aVRyZW5kUGVyWWVhchI8ChttZWFu'
    'X3N0cmVzc19kYXlzX3Blcl9zZWFzb24YDCABKAFSF21lYW5TdHJlc3NEYXlzUGVyU2Vhc29uEj'
    '8KCHJvdGF0aW9uGA0gASgLMiMuYWdyaWN1bHR1cmUuYWkudjEuUm90YXRpb25BbmFseXNpc1II'
    'cm90YXRpb24SWAoSc2Vhc29uX2NvbXBhcmlzb25zGA4gAygLMikuYWdyaWN1bHR1cmUuYWkudj'
    'EuU2Vhc29uQ29tcGFyaXNvblJlc3VsdFIRc2Vhc29uQ29tcGFyaXNvbnMSLAoScHJvY2Vzc2lu'
    'Z190aW1lX21zGA8gASgDUhBwcm9jZXNzaW5nVGltZU1z');

@$core.Deprecated('Use rotationAnalysisDescriptor instead')
const RotationAnalysis$json = {
  '1': 'RotationAnalysis',
  '2': [
    {'1': 'rotation_pattern', '3': 1, '4': 3, '5': 9, '10': 'rotationPattern'},
    {
      '1': 'effectiveness_score',
      '3': 2,
      '4': 1,
      '5': 1,
      '10': 'effectivenessScore'
    },
    {'1': 'yield_impact_pct', '3': 3, '4': 1, '5': 1, '10': 'yieldImpactPct'},
    {
      '1': 'stress_reduction_pct',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'stressReductionPct'
    },
    {'1': 'recommendation', '3': 5, '4': 1, '5': 9, '10': 'recommendation'},
  ],
};

/// Descriptor for `RotationAnalysis`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List rotationAnalysisDescriptor = $convert.base64Decode(
    'ChBSb3RhdGlvbkFuYWx5c2lzEikKEHJvdGF0aW9uX3BhdHRlcm4YASADKAlSD3JvdGF0aW9uUG'
    'F0dGVybhIvChNlZmZlY3RpdmVuZXNzX3Njb3JlGAIgASgBUhJlZmZlY3RpdmVuZXNzU2NvcmUS'
    'KAoQeWllbGRfaW1wYWN0X3BjdBgDIAEoAVIOeWllbGRJbXBhY3RQY3QSMAoUc3RyZXNzX3JlZH'
    'VjdGlvbl9wY3QYBCABKAFSEnN0cmVzc1JlZHVjdGlvblBjdBImCg5yZWNvbW1lbmRhdGlvbhgF'
    'IAEoCVIOcmVjb21tZW5kYXRpb24=');

@$core.Deprecated('Use seasonComparisonResultDescriptor instead')
const SeasonComparisonResult$json = {
  '1': 'SeasonComparisonResult',
  '2': [
    {'1': 'season', '3': 1, '4': 1, '5': 9, '10': 'season'},
    {'1': 'year', '3': 2, '4': 1, '5': 5, '10': 'year'},
    {'1': 'crop_type', '3': 3, '4': 1, '5': 9, '10': 'cropType'},
    {'1': 'yield_vs_mean_pct', '3': 4, '4': 1, '5': 1, '10': 'yieldVsMeanPct'},
    {
      '1': 'stress_vs_mean_pct',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'stressVsMeanPct'
    },
    {'1': 'ndvi_vs_mean_pct', '3': 6, '4': 1, '5': 1, '10': 'ndviVsMeanPct'},
    {'1': 'notable_events', '3': 7, '4': 3, '5': 9, '10': 'notableEvents'},
  ],
};

/// Descriptor for `SeasonComparisonResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List seasonComparisonResultDescriptor = $convert.base64Decode(
    'ChZTZWFzb25Db21wYXJpc29uUmVzdWx0EhYKBnNlYXNvbhgBIAEoCVIGc2Vhc29uEhIKBHllYX'
    'IYAiABKAVSBHllYXISGwoJY3JvcF90eXBlGAMgASgJUghjcm9wVHlwZRIpChF5aWVsZF92c19t'
    'ZWFuX3BjdBgEIAEoAVIOeWllbGRWc01lYW5QY3QSKwoSc3RyZXNzX3ZzX21lYW5fcGN0GAUgAS'
    'gBUg9zdHJlc3NWc01lYW5QY3QSJwoQbmR2aV92c19tZWFuX3BjdBgGIAEoAVINbmR2aVZzTWVh'
    'blBjdBIlCg5ub3RhYmxlX2V2ZW50cxgHIAMoCVINbm90YWJsZUV2ZW50cw==');

@$core.Deprecated('Use generatePrescriptionRequestDescriptor instead')
const GeneratePrescriptionRequest$json = {
  '1': 'GeneratePrescriptionRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'grid',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.PrescriptionGrid',
      '10': 'grid'
    },
    {
      '1': 'zone_input',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.PrescriptionZoneInput',
      '10': 'zoneInput'
    },
    {
      '1': 'crop_requirements',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.PrescriptionCropRequirements',
      '10': 'cropRequirements'
    },
    {
      '1': 'prescription_types',
      '3': 6,
      '4': 3,
      '5': 9,
      '10': 'prescriptionTypes'
    },
  ],
};

/// Descriptor for `GeneratePrescriptionRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generatePrescriptionRequestDescriptor = $convert.base64Decode(
    'ChtHZW5lcmF0ZVByZXNjcmlwdGlvblJlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdW'
    'VzdElkEhkKCGZpZWxkX2lkGAIgASgJUgdmaWVsZElkEjcKBGdyaWQYAyABKAsyIy5hZ3JpY3Vs'
    'dHVyZS5haS52MS5QcmVzY3JpcHRpb25HcmlkUgRncmlkEkcKCnpvbmVfaW5wdXQYBCABKAsyKC'
    '5hZ3JpY3VsdHVyZS5haS52MS5QcmVzY3JpcHRpb25ab25lSW5wdXRSCXpvbmVJbnB1dBJcChFj'
    'cm9wX3JlcXVpcmVtZW50cxgFIAEoCzIvLmFncmljdWx0dXJlLmFpLnYxLlByZXNjcmlwdGlvbk'
    'Nyb3BSZXF1aXJlbWVudHNSEGNyb3BSZXF1aXJlbWVudHMSLQoScHJlc2NyaXB0aW9uX3R5cGVz'
    'GAYgAygJUhFwcmVzY3JpcHRpb25UeXBlcw==');

@$core.Deprecated('Use prescriptionGridDescriptor instead')
const PrescriptionGrid$json = {
  '1': 'PrescriptionGrid',
  '2': [
    {'1': 'rows', '3': 1, '4': 1, '5': 5, '10': 'rows'},
    {'1': 'cols', '3': 2, '4': 1, '5': 5, '10': 'cols'},
    {'1': 'cell_size_m', '3': 3, '4': 1, '5': 1, '10': 'cellSizeM'},
    {'1': 'origin_lat', '3': 4, '4': 1, '5': 1, '10': 'originLat'},
    {'1': 'origin_lon', '3': 5, '4': 1, '5': 1, '10': 'originLon'},
  ],
};

/// Descriptor for `PrescriptionGrid`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List prescriptionGridDescriptor = $convert.base64Decode(
    'ChBQcmVzY3JpcHRpb25HcmlkEhIKBHJvd3MYASABKAVSBHJvd3MSEgoEY29scxgCIAEoBVIEY2'
    '9scxIeCgtjZWxsX3NpemVfbRgDIAEoAVIJY2VsbFNpemVNEh0KCm9yaWdpbl9sYXQYBCABKAFS'
    'CW9yaWdpbkxhdBIdCgpvcmlnaW5fbG9uGAUgASgBUglvcmlnaW5Mb24=');

@$core.Deprecated('Use prescriptionZoneInputDescriptor instead')
const PrescriptionZoneInput$json = {
  '1': 'PrescriptionZoneInput',
  '2': [
    {'1': 'ndvi', '3': 1, '4': 3, '5': 1, '10': 'ndvi'},
    {'1': 'soil_nitrogen', '3': 2, '4': 3, '5': 1, '10': 'soilNitrogen'},
    {'1': 'soil_phosphorus', '3': 3, '4': 3, '5': 1, '10': 'soilPhosphorus'},
    {'1': 'soil_potassium', '3': 4, '4': 3, '5': 1, '10': 'soilPotassium'},
    {'1': 'soil_ph', '3': 5, '4': 3, '5': 1, '10': 'soilPh'},
    {'1': 'soil_moisture', '3': 6, '4': 3, '5': 1, '10': 'soilMoisture'},
    {
      '1': 'soil_organic_matter',
      '3': 7,
      '4': 3,
      '5': 1,
      '10': 'soilOrganicMatter'
    },
  ],
};

/// Descriptor for `PrescriptionZoneInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List prescriptionZoneInputDescriptor = $convert.base64Decode(
    'ChVQcmVzY3JpcHRpb25ab25lSW5wdXQSEgoEbmR2aRgBIAMoAVIEbmR2aRIjCg1zb2lsX25pdH'
    'JvZ2VuGAIgAygBUgxzb2lsTml0cm9nZW4SJwoPc29pbF9waG9zcGhvcnVzGAMgAygBUg5zb2ls'
    'UGhvc3Bob3J1cxIlCg5zb2lsX3BvdGFzc2l1bRgEIAMoAVINc29pbFBvdGFzc2l1bRIXCgdzb2'
    'lsX3BoGAUgAygBUgZzb2lsUGgSIwoNc29pbF9tb2lzdHVyZRgGIAMoAVIMc29pbE1vaXN0dXJl'
    'Ei4KE3NvaWxfb3JnYW5pY19tYXR0ZXIYByADKAFSEXNvaWxPcmdhbmljTWF0dGVy');

@$core.Deprecated('Use prescriptionCropRequirementsDescriptor instead')
const PrescriptionCropRequirements$json = {
  '1': 'PrescriptionCropRequirements',
  '2': [
    {'1': 'crop_type', '3': 1, '4': 1, '5': 9, '10': 'cropType'},
    {
      '1': 'target_yield_kg_ha',
      '3': 2,
      '4': 1,
      '5': 1,
      '10': 'targetYieldKgHa'
    },
    {'1': 'nitrogen_kg_ha', '3': 3, '4': 1, '5': 1, '10': 'nitrogenKgHa'},
    {'1': 'phosphorus_kg_ha', '3': 4, '4': 1, '5': 1, '10': 'phosphorusKgHa'},
    {'1': 'potassium_kg_ha', '3': 5, '4': 1, '5': 1, '10': 'potassiumKgHa'},
    {'1': 'optimal_ph_low', '3': 6, '4': 1, '5': 1, '10': 'optimalPhLow'},
    {'1': 'optimal_ph_high', '3': 7, '4': 1, '5': 1, '10': 'optimalPhHigh'},
    {
      '1': 'water_requirement_mm',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'waterRequirementMm'
    },
    {'1': 'seed_rate_per_ha', '3': 9, '4': 1, '5': 1, '10': 'seedRatePerHa'},
  ],
};

/// Descriptor for `PrescriptionCropRequirements`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List prescriptionCropRequirementsDescriptor = $convert.base64Decode(
    'ChxQcmVzY3JpcHRpb25Dcm9wUmVxdWlyZW1lbnRzEhsKCWNyb3BfdHlwZRgBIAEoCVIIY3JvcF'
    'R5cGUSKwoSdGFyZ2V0X3lpZWxkX2tnX2hhGAIgASgBUg90YXJnZXRZaWVsZEtnSGESJAoObml0'
    'cm9nZW5fa2dfaGEYAyABKAFSDG5pdHJvZ2VuS2dIYRIoChBwaG9zcGhvcnVzX2tnX2hhGAQgAS'
    'gBUg5waG9zcGhvcnVzS2dIYRImCg9wb3Rhc3NpdW1fa2dfaGEYBSABKAFSDXBvdGFzc2l1bUtn'
    'SGESJAoOb3B0aW1hbF9waF9sb3cYBiABKAFSDG9wdGltYWxQaExvdxImCg9vcHRpbWFsX3BoX2'
    'hpZ2gYByABKAFSDW9wdGltYWxQaEhpZ2gSMAoUd2F0ZXJfcmVxdWlyZW1lbnRfbW0YCCABKAFS'
    'EndhdGVyUmVxdWlyZW1lbnRNbRInChBzZWVkX3JhdGVfcGVyX2hhGAkgASgBUg1zZWVkUmF0ZV'
    'Blckhh');

@$core.Deprecated('Use generatePrescriptionResponseDescriptor instead')
const GeneratePrescriptionResponse$json = {
  '1': 'GeneratePrescriptionResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'prescriptions',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.PrescriptionMapResult',
      '10': 'prescriptions'
    },
    {
      '1': 'estimated_cost_savings_pct',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'estimatedCostSavingsPct'
    },
    {
      '1': 'estimated_yield_gain_pct',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'estimatedYieldGainPct'
    },
    {
      '1': 'processing_time_ms',
      '3': 6,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
  ],
};

/// Descriptor for `GeneratePrescriptionResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generatePrescriptionResponseDescriptor = $convert.base64Decode(
    'ChxHZW5lcmF0ZVByZXNjcmlwdGlvblJlc3BvbnNlEh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcX'
    'Vlc3RJZBIZCghmaWVsZF9pZBgCIAEoCVIHZmllbGRJZBJOCg1wcmVzY3JpcHRpb25zGAMgAygL'
    'MiguYWdyaWN1bHR1cmUuYWkudjEuUHJlc2NyaXB0aW9uTWFwUmVzdWx0Ug1wcmVzY3JpcHRpb2'
    '5zEjsKGmVzdGltYXRlZF9jb3N0X3NhdmluZ3NfcGN0GAQgASgBUhdlc3RpbWF0ZWRDb3N0U2F2'
    'aW5nc1BjdBI3Chhlc3RpbWF0ZWRfeWllbGRfZ2Fpbl9wY3QYBSABKAFSFWVzdGltYXRlZFlpZW'
    'xkR2FpblBjdBIsChJwcm9jZXNzaW5nX3RpbWVfbXMYBiABKANSEHByb2Nlc3NpbmdUaW1lTXM=');

@$core.Deprecated('Use prescriptionMapResultDescriptor instead')
const PrescriptionMapResult$json = {
  '1': 'PrescriptionMapResult',
  '2': [
    {
      '1': 'prescription_type',
      '3': 1,
      '4': 1,
      '5': 9,
      '10': 'prescriptionType'
    },
    {'1': 'rates', '3': 2, '4': 3, '5': 1, '10': 'rates'},
    {'1': 'unit', '3': 3, '4': 1, '5': 9, '10': 'unit'},
    {'1': 'total_amount', '3': 4, '4': 1, '5': 1, '10': 'totalAmount'},
    {
      '1': 'zone_summaries',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.PrescriptionZoneSummary',
      '10': 'zoneSummaries'
    },
  ],
};

/// Descriptor for `PrescriptionMapResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List prescriptionMapResultDescriptor = $convert.base64Decode(
    'ChVQcmVzY3JpcHRpb25NYXBSZXN1bHQSKwoRcHJlc2NyaXB0aW9uX3R5cGUYASABKAlSEHByZX'
    'NjcmlwdGlvblR5cGUSFAoFcmF0ZXMYAiADKAFSBXJhdGVzEhIKBHVuaXQYAyABKAlSBHVuaXQS'
    'IQoMdG90YWxfYW1vdW50GAQgASgBUgt0b3RhbEFtb3VudBJRCg56b25lX3N1bW1hcmllcxgFIA'
    'MoCzIqLmFncmljdWx0dXJlLmFpLnYxLlByZXNjcmlwdGlvblpvbmVTdW1tYXJ5Ug16b25lU3Vt'
    'bWFyaWVz');

@$core.Deprecated('Use prescriptionZoneSummaryDescriptor instead')
const PrescriptionZoneSummary$json = {
  '1': 'PrescriptionZoneSummary',
  '2': [
    {'1': 'zone', '3': 1, '4': 1, '5': 9, '10': 'zone'},
    {'1': 'cell_count', '3': 2, '4': 1, '5': 5, '10': 'cellCount'},
    {'1': 'area_ha', '3': 3, '4': 1, '5': 1, '10': 'areaHa'},
    {'1': 'mean_rate', '3': 4, '4': 1, '5': 1, '10': 'meanRate'},
    {'1': 'min_rate', '3': 5, '4': 1, '5': 1, '10': 'minRate'},
    {'1': 'max_rate', '3': 6, '4': 1, '5': 1, '10': 'maxRate'},
    {'1': 'total_amount', '3': 7, '4': 1, '5': 1, '10': 'totalAmount'},
    {
      '1': 'attribution',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.AttributionSummary',
      '10': 'attribution'
    },
  ],
};

/// Descriptor for `PrescriptionZoneSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List prescriptionZoneSummaryDescriptor = $convert.base64Decode(
    'ChdQcmVzY3JpcHRpb25ab25lU3VtbWFyeRISCgR6b25lGAEgASgJUgR6b25lEh0KCmNlbGxfY2'
    '91bnQYAiABKAVSCWNlbGxDb3VudBIXCgdhcmVhX2hhGAMgASgBUgZhcmVhSGESGwoJbWVhbl9y'
    'YXRlGAQgASgBUghtZWFuUmF0ZRIZCghtaW5fcmF0ZRgFIAEoAVIHbWluUmF0ZRIZCghtYXhfcm'
    'F0ZRgGIAEoAVIHbWF4UmF0ZRIhCgx0b3RhbF9hbW91bnQYByABKAFSC3RvdGFsQW1vdW50EkcK'
    'C2F0dHJpYnV0aW9uGAggASgLMiUuYWdyaWN1bHR1cmUuYWkudjEuQXR0cmlidXRpb25TdW1tYX'
    'J5UgthdHRyaWJ1dGlvbg==');

@$core.Deprecated('Use analyzeTerrainRequestDescriptor instead')
const AnalyzeTerrainRequest$json = {
  '1': 'AnalyzeTerrainRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'elevation', '3': 2, '4': 3, '5': 1, '10': 'elevation'},
    {'1': 'width', '3': 3, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 4, '4': 1, '5': 5, '10': 'height'},
    {'1': 'cell_size', '3': 5, '4': 1, '5': 1, '10': 'cellSize'},
    {'1': 'nodata_value', '3': 6, '4': 1, '5': 1, '10': 'nodataValue'},
    {'1': 'analyses', '3': 7, '4': 3, '5': 9, '10': 'analyses'},
    {'1': 'contour_interval', '3': 8, '4': 1, '5': 1, '10': 'contourInterval'},
    {'1': 'stream_threshold', '3': 9, '4': 1, '5': 1, '10': 'streamThreshold'},
    {
      '1': 'hillshade_azimuth',
      '3': 10,
      '4': 1,
      '5': 1,
      '10': 'hillshadeAzimuth'
    },
    {
      '1': 'hillshade_altitude',
      '3': 11,
      '4': 1,
      '5': 1,
      '10': 'hillshadeAltitude'
    },
    {
      '1': 'hillshade_z_factor',
      '3': 12,
      '4': 1,
      '5': 1,
      '10': 'hillshadeZFactor'
    },
  ],
};

/// Descriptor for `AnalyzeTerrainRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List analyzeTerrainRequestDescriptor = $convert.base64Decode(
    'ChVBbmFseXplVGVycmFpblJlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdWVzdElkEh'
    'wKCWVsZXZhdGlvbhgCIAMoAVIJZWxldmF0aW9uEhQKBXdpZHRoGAMgASgFUgV3aWR0aBIWCgZo'
    'ZWlnaHQYBCABKAVSBmhlaWdodBIbCgljZWxsX3NpemUYBSABKAFSCGNlbGxTaXplEiEKDG5vZG'
    'F0YV92YWx1ZRgGIAEoAVILbm9kYXRhVmFsdWUSGgoIYW5hbHlzZXMYByADKAlSCGFuYWx5c2Vz'
    'EikKEGNvbnRvdXJfaW50ZXJ2YWwYCCABKAFSD2NvbnRvdXJJbnRlcnZhbBIpChBzdHJlYW1fdG'
    'hyZXNob2xkGAkgASgBUg9zdHJlYW1UaHJlc2hvbGQSKwoRaGlsbHNoYWRlX2F6aW11dGgYCiAB'
    'KAFSEGhpbGxzaGFkZUF6aW11dGgSLQoSaGlsbHNoYWRlX2FsdGl0dWRlGAsgASgBUhFoaWxsc2'
    'hhZGVBbHRpdHVkZRIsChJoaWxsc2hhZGVfel9mYWN0b3IYDCABKAFSEGhpbGxzaGFkZVpGYWN0'
    'b3I=');

@$core.Deprecated('Use analyzeTerrainResponseDescriptor instead')
const AnalyzeTerrainResponse$json = {
  '1': 'AnalyzeTerrainResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {'1': 'width', '3': 2, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 3, '4': 1, '5': 5, '10': 'height'},
    {'1': 'slope', '3': 4, '4': 3, '5': 1, '10': 'slope'},
    {'1': 'aspect', '3': 5, '4': 3, '5': 1, '10': 'aspect'},
    {'1': 'hillshade', '3': 6, '4': 3, '5': 1, '10': 'hillshade'},
    {'1': 'tri', '3': 7, '4': 3, '5': 1, '10': 'tri'},
    {'1': 'tpi', '3': 8, '4': 3, '5': 1, '10': 'tpi'},
    {'1': 'flow_direction', '3': 9, '4': 3, '5': 5, '10': 'flowDirection'},
    {
      '1': 'flow_accumulation',
      '3': 10,
      '4': 3,
      '5': 1,
      '10': 'flowAccumulation'
    },
    {'1': 'watershed_ids', '3': 11, '4': 3, '5': 13, '10': 'watershedIds'},
    {
      '1': 'contour_lines',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.TerrainContourLine',
      '10': 'contourLines'
    },
    {
      '1': 'dem_statistics',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.TerrainDemStatistics',
      '10': 'demStatistics'
    },
    {
      '1': 'flow_statistics',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.TerrainFlowStats',
      '10': 'flowStatistics'
    },
    {
      '1': 'watershed_statistics',
      '3': 15,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.TerrainWatershedInfo',
      '10': 'watershedStatistics'
    },
    {
      '1': 'processing_time_ms',
      '3': 16,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
  ],
};

/// Descriptor for `AnalyzeTerrainResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List analyzeTerrainResponseDescriptor = $convert.base64Decode(
    'ChZBbmFseXplVGVycmFpblJlc3BvbnNlEh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcXVlc3RJZB'
    'IUCgV3aWR0aBgCIAEoBVIFd2lkdGgSFgoGaGVpZ2h0GAMgASgFUgZoZWlnaHQSFAoFc2xvcGUY'
    'BCADKAFSBXNsb3BlEhYKBmFzcGVjdBgFIAMoAVIGYXNwZWN0EhwKCWhpbGxzaGFkZRgGIAMoAV'
    'IJaGlsbHNoYWRlEhAKA3RyaRgHIAMoAVIDdHJpEhAKA3RwaRgIIAMoAVIDdHBpEiUKDmZsb3df'
    'ZGlyZWN0aW9uGAkgAygFUg1mbG93RGlyZWN0aW9uEisKEWZsb3dfYWNjdW11bGF0aW9uGAogAy'
    'gBUhBmbG93QWNjdW11bGF0aW9uEiMKDXdhdGVyc2hlZF9pZHMYCyADKA1SDHdhdGVyc2hlZElk'
    'cxJKCg1jb250b3VyX2xpbmVzGAwgAygLMiUuYWdyaWN1bHR1cmUuYWkudjEuVGVycmFpbkNvbn'
    'RvdXJMaW5lUgxjb250b3VyTGluZXMSTgoOZGVtX3N0YXRpc3RpY3MYDSABKAsyJy5hZ3JpY3Vs'
    'dHVyZS5haS52MS5UZXJyYWluRGVtU3RhdGlzdGljc1INZGVtU3RhdGlzdGljcxJMCg9mbG93X3'
    'N0YXRpc3RpY3MYDiABKAsyIy5hZ3JpY3VsdHVyZS5haS52MS5UZXJyYWluRmxvd1N0YXRzUg5m'
    'bG93U3RhdGlzdGljcxJaChR3YXRlcnNoZWRfc3RhdGlzdGljcxgPIAMoCzInLmFncmljdWx0dX'
    'JlLmFpLnYxLlRlcnJhaW5XYXRlcnNoZWRJbmZvUhN3YXRlcnNoZWRTdGF0aXN0aWNzEiwKEnBy'
    'b2Nlc3NpbmdfdGltZV9tcxgQIAEoA1IQcHJvY2Vzc2luZ1RpbWVNcw==');

@$core.Deprecated('Use terrainContourLineDescriptor instead')
const TerrainContourLine$json = {
  '1': 'TerrainContourLine',
  '2': [
    {'1': 'elevation', '3': 1, '4': 1, '5': 1, '10': 'elevation'},
    {'1': 'coordinates', '3': 2, '4': 3, '5': 1, '10': 'coordinates'},
  ],
};

/// Descriptor for `TerrainContourLine`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List terrainContourLineDescriptor = $convert.base64Decode(
    'ChJUZXJyYWluQ29udG91ckxpbmUSHAoJZWxldmF0aW9uGAEgASgBUgllbGV2YXRpb24SIAoLY2'
    '9vcmRpbmF0ZXMYAiADKAFSC2Nvb3JkaW5hdGVz');

@$core.Deprecated('Use terrainDemStatisticsDescriptor instead')
const TerrainDemStatistics$json = {
  '1': 'TerrainDemStatistics',
  '2': [
    {'1': 'min_elevation', '3': 1, '4': 1, '5': 1, '10': 'minElevation'},
    {'1': 'max_elevation', '3': 2, '4': 1, '5': 1, '10': 'maxElevation'},
    {'1': 'mean_elevation', '3': 3, '4': 1, '5': 1, '10': 'meanElevation'},
    {'1': 'elevation_range', '3': 4, '4': 1, '5': 1, '10': 'elevationRange'},
    {'1': 'valid_cells', '3': 5, '4': 1, '5': 3, '10': 'validCells'},
    {'1': 'total_cells', '3': 6, '4': 1, '5': 3, '10': 'totalCells'},
  ],
};

/// Descriptor for `TerrainDemStatistics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List terrainDemStatisticsDescriptor = $convert.base64Decode(
    'ChRUZXJyYWluRGVtU3RhdGlzdGljcxIjCg1taW5fZWxldmF0aW9uGAEgASgBUgxtaW5FbGV2YX'
    'Rpb24SIwoNbWF4X2VsZXZhdGlvbhgCIAEoAVIMbWF4RWxldmF0aW9uEiUKDm1lYW5fZWxldmF0'
    'aW9uGAMgASgBUg1tZWFuRWxldmF0aW9uEicKD2VsZXZhdGlvbl9yYW5nZRgEIAEoAVIOZWxldm'
    'F0aW9uUmFuZ2USHwoLdmFsaWRfY2VsbHMYBSABKANSCnZhbGlkQ2VsbHMSHwoLdG90YWxfY2Vs'
    'bHMYBiABKANSCnRvdGFsQ2VsbHM=');

@$core.Deprecated('Use terrainFlowStatsDescriptor instead')
const TerrainFlowStats$json = {
  '1': 'TerrainFlowStats',
  '2': [
    {'1': 'max_accumulation', '3': 1, '4': 1, '5': 1, '10': 'maxAccumulation'},
    {
      '1': 'mean_accumulation',
      '3': 2,
      '4': 1,
      '5': 1,
      '10': 'meanAccumulation'
    },
    {'1': 'stream_cell_count', '3': 3, '4': 1, '5': 3, '10': 'streamCellCount'},
    {'1': 'total_cells', '3': 4, '4': 1, '5': 3, '10': 'totalCells'},
    {'1': 'drainage_density', '3': 5, '4': 1, '5': 1, '10': 'drainageDensity'},
  ],
};

/// Descriptor for `TerrainFlowStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List terrainFlowStatsDescriptor = $convert.base64Decode(
    'ChBUZXJyYWluRmxvd1N0YXRzEikKEG1heF9hY2N1bXVsYXRpb24YASABKAFSD21heEFjY3VtdW'
    'xhdGlvbhIrChFtZWFuX2FjY3VtdWxhdGlvbhgCIAEoAVIQbWVhbkFjY3VtdWxhdGlvbhIqChFz'
    'dHJlYW1fY2VsbF9jb3VudBgDIAEoA1IPc3RyZWFtQ2VsbENvdW50Eh8KC3RvdGFsX2NlbGxzGA'
    'QgASgDUgp0b3RhbENlbGxzEikKEGRyYWluYWdlX2RlbnNpdHkYBSABKAFSD2RyYWluYWdlRGVu'
    'c2l0eQ==');

@$core.Deprecated('Use terrainWatershedInfoDescriptor instead')
const TerrainWatershedInfo$json = {
  '1': 'TerrainWatershedInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 13, '10': 'id'},
    {'1': 'cell_count', '3': 2, '4': 1, '5': 3, '10': 'cellCount'},
    {'1': 'area_sq_m', '3': 3, '4': 1, '5': 1, '10': 'areaSqM'},
    {'1': 'mean_elevation', '3': 4, '4': 1, '5': 1, '10': 'meanElevation'},
    {'1': 'min_elevation', '3': 5, '4': 1, '5': 1, '10': 'minElevation'},
    {'1': 'max_elevation', '3': 6, '4': 1, '5': 1, '10': 'maxElevation'},
    {'1': 'relief', '3': 7, '4': 1, '5': 1, '10': 'relief'},
  ],
};

/// Descriptor for `TerrainWatershedInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List terrainWatershedInfoDescriptor = $convert.base64Decode(
    'ChRUZXJyYWluV2F0ZXJzaGVkSW5mbxIOCgJpZBgBIAEoDVICaWQSHQoKY2VsbF9jb3VudBgCIA'
    'EoA1IJY2VsbENvdW50EhoKCWFyZWFfc3FfbRgDIAEoAVIHYXJlYVNxTRIlCg5tZWFuX2VsZXZh'
    'dGlvbhgEIAEoAVINbWVhbkVsZXZhdGlvbhIjCg1taW5fZWxldmF0aW9uGAUgASgBUgxtaW5FbG'
    'V2YXRpb24SIwoNbWF4X2VsZXZhdGlvbhgGIAEoAVIMbWF4RWxldmF0aW9uEhYKBnJlbGllZhgH'
    'IAEoAVIGcmVsaWVm');

@$core.Deprecated('Use simulateWaterFlowRequestDescriptor instead')
const SimulateWaterFlowRequest$json = {
  '1': 'SimulateWaterFlowRequest',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'moisture_params',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.WaterFlowMoistureParams',
      '10': 'moistureParams'
    },
    {
      '1': 'balance_params',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.WaterFlowBalanceParams',
      '10': 'balanceParams'
    },
    {'1': 'rainfall_mm_day', '3': 4, '4': 1, '5': 1, '10': 'rainfallMmDay'},
    {'1': 'et_mm_day', '3': 5, '4': 1, '5': 1, '10': 'etMmDay'},
    {'1': 'irrigation_mm_day', '3': 6, '4': 1, '5': 1, '10': 'irrigationMmDay'},
    {'1': 'simulation_days', '3': 7, '4': 1, '5': 1, '10': 'simulationDays'},
    {'1': 'daily_rainfall_mm', '3': 8, '4': 3, '5': 1, '10': 'dailyRainfallMm'},
    {
      '1': 'initial_depletion_mm',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'initialDepletionMm'
    },
  ],
};

/// Descriptor for `SimulateWaterFlowRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List simulateWaterFlowRequestDescriptor = $convert.base64Decode(
    'ChhTaW11bGF0ZVdhdGVyRmxvd1JlcXVlc3QSHQoKcmVxdWVzdF9pZBgBIAEoCVIJcmVxdWVzdE'
    'lkElMKD21vaXN0dXJlX3BhcmFtcxgCIAEoCzIqLmFncmljdWx0dXJlLmFpLnYxLldhdGVyRmxv'
    'd01vaXN0dXJlUGFyYW1zUg5tb2lzdHVyZVBhcmFtcxJQCg5iYWxhbmNlX3BhcmFtcxgDIAEoCz'
    'IpLmFncmljdWx0dXJlLmFpLnYxLldhdGVyRmxvd0JhbGFuY2VQYXJhbXNSDWJhbGFuY2VQYXJh'
    'bXMSJgoPcmFpbmZhbGxfbW1fZGF5GAQgASgBUg1yYWluZmFsbE1tRGF5EhoKCWV0X21tX2RheR'
    'gFIAEoAVIHZXRNbURheRIqChFpcnJpZ2F0aW9uX21tX2RheRgGIAEoAVIPaXJyaWdhdGlvbk1t'
    'RGF5EicKD3NpbXVsYXRpb25fZGF5cxgHIAEoAVIOc2ltdWxhdGlvbkRheXMSKgoRZGFpbHlfcm'
    'FpbmZhbGxfbW0YCCADKAFSD2RhaWx5UmFpbmZhbGxNbRIwChRpbml0aWFsX2RlcGxldGlvbl9t'
    'bRgJIAEoAVISaW5pdGlhbERlcGxldGlvbk1t');

@$core.Deprecated('Use waterFlowMoistureParamsDescriptor instead')
const WaterFlowMoistureParams$json = {
  '1': 'WaterFlowMoistureParams',
  '2': [
    {'1': 'num_layers', '3': 1, '4': 1, '5': 5, '10': 'numLayers'},
    {'1': 'layer_thickness_m', '3': 2, '4': 1, '5': 1, '10': 'layerThicknessM'},
    {'1': 'k_sat_m_day', '3': 3, '4': 1, '5': 1, '10': 'kSatMDay'},
    {'1': 'field_capacity', '3': 4, '4': 1, '5': 1, '10': 'fieldCapacity'},
    {'1': 'wilting_point', '3': 5, '4': 1, '5': 1, '10': 'wiltingPoint'},
    {'1': 'saturation', '3': 6, '4': 1, '5': 1, '10': 'saturation'},
    {'1': 'root_zone_depth_m', '3': 7, '4': 1, '5': 1, '10': 'rootZoneDepthM'},
  ],
};

/// Descriptor for `WaterFlowMoistureParams`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List waterFlowMoistureParamsDescriptor = $convert.base64Decode(
    'ChdXYXRlckZsb3dNb2lzdHVyZVBhcmFtcxIdCgpudW1fbGF5ZXJzGAEgASgFUgludW1MYXllcn'
    'MSKgoRbGF5ZXJfdGhpY2tuZXNzX20YAiABKAFSD2xheWVyVGhpY2tuZXNzTRIdCgtrX3NhdF9t'
    'X2RheRgDIAEoAVIIa1NhdE1EYXkSJQoOZmllbGRfY2FwYWNpdHkYBCABKAFSDWZpZWxkQ2FwYW'
    'NpdHkSIwoNd2lsdGluZ19wb2ludBgFIAEoAVIMd2lsdGluZ1BvaW50Eh4KCnNhdHVyYXRpb24Y'
    'BiABKAFSCnNhdHVyYXRpb24SKQoRcm9vdF96b25lX2RlcHRoX20YByABKAFSDnJvb3Rab25lRG'
    'VwdGhN');

@$core.Deprecated('Use waterFlowBalanceParamsDescriptor instead')
const WaterFlowBalanceParams$json = {
  '1': 'WaterFlowBalanceParams',
  '2': [
    {'1': 'field_area_ha', '3': 1, '4': 1, '5': 1, '10': 'fieldAreaHa'},
    {'1': 'crop_coefficient', '3': 2, '4': 1, '5': 1, '10': 'cropCoefficient'},
    {
      '1': 'reference_et_mm_day',
      '3': 3,
      '4': 1,
      '5': 1,
      '10': 'referenceEtMmDay'
    },
    {'1': 'root_zone_depth_m', '3': 4, '4': 1, '5': 1, '10': 'rootZoneDepthM'},
    {'1': 'field_capacity', '3': 5, '4': 1, '5': 1, '10': 'fieldCapacity'},
    {'1': 'wilting_point', '3': 6, '4': 1, '5': 1, '10': 'wiltingPoint'},
    {
      '1': 'management_allowed_depletion',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'managementAllowedDepletion'
    },
    {'1': 'crop_type', '3': 8, '4': 1, '5': 9, '10': 'cropType'},
    {'1': 'growth_stage', '3': 9, '4': 1, '5': 9, '10': 'growthStage'},
    {
      '1': 'days_after_planting',
      '3': 10,
      '4': 1,
      '5': 5,
      '10': 'daysAfterPlanting'
    },
  ],
};

/// Descriptor for `WaterFlowBalanceParams`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List waterFlowBalanceParamsDescriptor = $convert.base64Decode(
    'ChZXYXRlckZsb3dCYWxhbmNlUGFyYW1zEiIKDWZpZWxkX2FyZWFfaGEYASABKAFSC2ZpZWxkQX'
    'JlYUhhEikKEGNyb3BfY29lZmZpY2llbnQYAiABKAFSD2Nyb3BDb2VmZmljaWVudBItChNyZWZl'
    'cmVuY2VfZXRfbW1fZGF5GAMgASgBUhByZWZlcmVuY2VFdE1tRGF5EikKEXJvb3Rfem9uZV9kZX'
    'B0aF9tGAQgASgBUg5yb290Wm9uZURlcHRoTRIlCg5maWVsZF9jYXBhY2l0eRgFIAEoAVINZmll'
    'bGRDYXBhY2l0eRIjCg13aWx0aW5nX3BvaW50GAYgASgBUgx3aWx0aW5nUG9pbnQSQAocbWFuYW'
    'dlbWVudF9hbGxvd2VkX2RlcGxldGlvbhgHIAEoAVIabWFuYWdlbWVudEFsbG93ZWREZXBsZXRp'
    'b24SGwoJY3JvcF90eXBlGAggASgJUghjcm9wVHlwZRIhCgxncm93dGhfc3RhZ2UYCSABKAlSC2'
    'dyb3d0aFN0YWdlEi4KE2RheXNfYWZ0ZXJfcGxhbnRpbmcYCiABKAVSEWRheXNBZnRlclBsYW50'
    'aW5n');

@$core.Deprecated('Use simulateWaterFlowResponseDescriptor instead')
const SimulateWaterFlowResponse$json = {
  '1': 'SimulateWaterFlowResponse',
  '2': [
    {'1': 'request_id', '3': 1, '4': 1, '5': 9, '10': 'requestId'},
    {
      '1': 'moisture_profiles',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.SoilMoistureSnapshot',
      '10': 'moistureProfiles'
    },
    {
      '1': 'water_balance',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.agriculture.ai.v1.WaterBalanceDay',
      '10': 'waterBalance'
    },
    {
      '1': 'irrigation_summary',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.agriculture.ai.v1.WaterFlowIrrigationSummary',
      '10': 'irrigationSummary'
    },
    {
      '1': 'processing_time_ms',
      '3': 5,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
  ],
};

/// Descriptor for `SimulateWaterFlowResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List simulateWaterFlowResponseDescriptor = $convert.base64Decode(
    'ChlTaW11bGF0ZVdhdGVyRmxvd1Jlc3BvbnNlEh0KCnJlcXVlc3RfaWQYASABKAlSCXJlcXVlc3'
    'RJZBJUChFtb2lzdHVyZV9wcm9maWxlcxgCIAMoCzInLmFncmljdWx0dXJlLmFpLnYxLlNvaWxN'
    'b2lzdHVyZVNuYXBzaG90UhBtb2lzdHVyZVByb2ZpbGVzEkcKDXdhdGVyX2JhbGFuY2UYAyADKA'
    'syIi5hZ3JpY3VsdHVyZS5haS52MS5XYXRlckJhbGFuY2VEYXlSDHdhdGVyQmFsYW5jZRJcChJp'
    'cnJpZ2F0aW9uX3N1bW1hcnkYBCABKAsyLS5hZ3JpY3VsdHVyZS5haS52MS5XYXRlckZsb3dJcn'
    'JpZ2F0aW9uU3VtbWFyeVIRaXJyaWdhdGlvblN1bW1hcnkSLAoScHJvY2Vzc2luZ190aW1lX21z'
    'GAUgASgDUhBwcm9jZXNzaW5nVGltZU1z');

@$core.Deprecated('Use soilMoistureSnapshotDescriptor instead')
const SoilMoistureSnapshot$json = {
  '1': 'SoilMoistureSnapshot',
  '2': [
    {'1': 'time_days', '3': 1, '4': 1, '5': 1, '10': 'timeDays'},
    {'1': 'layer_moisture', '3': 2, '4': 3, '5': 1, '10': 'layerMoisture'},
    {
      '1': 'root_zone_water_mm',
      '3': 3,
      '4': 1,
      '5': 1,
      '10': 'rootZoneWaterMm'
    },
    {
      '1': 'available_water_mm',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'availableWaterMm'
    },
    {'1': 'drainage_mm_day', '3': 5, '4': 1, '5': 1, '10': 'drainageMmDay'},
  ],
};

/// Descriptor for `SoilMoistureSnapshot`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List soilMoistureSnapshotDescriptor = $convert.base64Decode(
    'ChRTb2lsTW9pc3R1cmVTbmFwc2hvdBIbCgl0aW1lX2RheXMYASABKAFSCHRpbWVEYXlzEiUKDm'
    'xheWVyX21vaXN0dXJlGAIgAygBUg1sYXllck1vaXN0dXJlEisKEnJvb3Rfem9uZV93YXRlcl9t'
    'bRgDIAEoAVIPcm9vdFpvbmVXYXRlck1tEiwKEmF2YWlsYWJsZV93YXRlcl9tbRgEIAEoAVIQYX'
    'ZhaWxhYmxlV2F0ZXJNbRImCg9kcmFpbmFnZV9tbV9kYXkYBSABKAFSDWRyYWluYWdlTW1EYXk=');

@$core.Deprecated('Use waterBalanceDayDescriptor instead')
const WaterBalanceDay$json = {
  '1': 'WaterBalanceDay',
  '2': [
    {'1': 'day', '3': 1, '4': 1, '5': 5, '10': 'day'},
    {'1': 'etc_mm_day', '3': 2, '4': 1, '5': 1, '10': 'etcMmDay'},
    {'1': 'depletion_mm', '3': 3, '4': 1, '5': 1, '10': 'depletionMm'},
    {
      '1': 'total_available_water_mm',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'totalAvailableWaterMm'
    },
    {
      '1': 'readily_available_water_mm',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'readilyAvailableWaterMm'
    },
    {
      '1': 'irrigation_needed',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'irrigationNeeded'
    },
    {
      '1': 'irrigation_amount_mm',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'irrigationAmountMm'
    },
    {
      '1': 'effective_rainfall_mm',
      '3': 8,
      '4': 1,
      '5': 1,
      '10': 'effectiveRainfallMm'
    },
    {
      '1': 'deep_percolation_mm',
      '3': 9,
      '4': 1,
      '5': 1,
      '10': 'deepPercolationMm'
    },
  ],
};

/// Descriptor for `WaterBalanceDay`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List waterBalanceDayDescriptor = $convert.base64Decode(
    'Cg9XYXRlckJhbGFuY2VEYXkSEAoDZGF5GAEgASgFUgNkYXkSHAoKZXRjX21tX2RheRgCIAEoAV'
    'IIZXRjTW1EYXkSIQoMZGVwbGV0aW9uX21tGAMgASgBUgtkZXBsZXRpb25NbRI3Chh0b3RhbF9h'
    'dmFpbGFibGVfd2F0ZXJfbW0YBCABKAFSFXRvdGFsQXZhaWxhYmxlV2F0ZXJNbRI7ChpyZWFkaW'
    'x5X2F2YWlsYWJsZV93YXRlcl9tbRgFIAEoAVIXcmVhZGlseUF2YWlsYWJsZVdhdGVyTW0SKwoR'
    'aXJyaWdhdGlvbl9uZWVkZWQYBiABKAhSEGlycmlnYXRpb25OZWVkZWQSMAoUaXJyaWdhdGlvbl'
    '9hbW91bnRfbW0YByABKAFSEmlycmlnYXRpb25BbW91bnRNbRIyChVlZmZlY3RpdmVfcmFpbmZh'
    'bGxfbW0YCCABKAFSE2VmZmVjdGl2ZVJhaW5mYWxsTW0SLgoTZGVlcF9wZXJjb2xhdGlvbl9tbR'
    'gJIAEoAVIRZGVlcFBlcmNvbGF0aW9uTW0=');

@$core.Deprecated('Use waterFlowIrrigationSummaryDescriptor instead')
const WaterFlowIrrigationSummary$json = {
  '1': 'WaterFlowIrrigationSummary',
  '2': [
    {
      '1': 'total_irrigation_mm',
      '3': 1,
      '4': 1,
      '5': 1,
      '10': 'totalIrrigationMm'
    },
    {
      '1': 'total_effective_rainfall_mm',
      '3': 2,
      '4': 1,
      '5': 1,
      '10': 'totalEffectiveRainfallMm'
    },
    {'1': 'total_crop_et_mm', '3': 3, '4': 1, '5': 1, '10': 'totalCropEtMm'},
    {
      '1': 'total_deep_percolation_mm',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'totalDeepPercolationMm'
    },
    {
      '1': 'irrigation_events',
      '3': 5,
      '4': 1,
      '5': 5,
      '10': 'irrigationEvents'
    },
    {
      '1': 'average_interval_days',
      '3': 6,
      '4': 1,
      '5': 1,
      '10': 'averageIntervalDays'
    },
    {
      '1': 'water_use_efficiency',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'waterUseEfficiency'
    },
  ],
};

/// Descriptor for `WaterFlowIrrigationSummary`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List waterFlowIrrigationSummaryDescriptor = $convert.base64Decode(
    'ChpXYXRlckZsb3dJcnJpZ2F0aW9uU3VtbWFyeRIuChN0b3RhbF9pcnJpZ2F0aW9uX21tGAEgAS'
    'gBUhF0b3RhbElycmlnYXRpb25NbRI9Cht0b3RhbF9lZmZlY3RpdmVfcmFpbmZhbGxfbW0YAiAB'
    'KAFSGHRvdGFsRWZmZWN0aXZlUmFpbmZhbGxNbRInChB0b3RhbF9jcm9wX2V0X21tGAMgASgBUg'
    '10b3RhbENyb3BFdE1tEjkKGXRvdGFsX2RlZXBfcGVyY29sYXRpb25fbW0YBCABKAFSFnRvdGFs'
    'RGVlcFBlcmNvbGF0aW9uTW0SKwoRaXJyaWdhdGlvbl9ldmVudHMYBSABKAVSEGlycmlnYXRpb2'
    '5FdmVudHMSMgoVYXZlcmFnZV9pbnRlcnZhbF9kYXlzGAYgASgBUhNhdmVyYWdlSW50ZXJ2YWxE'
    'YXlzEjAKFHdhdGVyX3VzZV9lZmZpY2llbmN5GAcgASgBUhJ3YXRlclVzZUVmZmljaWVuY3k=');

const $core.Map<$core.String, $core.dynamic> AIGatewayServiceBase$json = {
  '1': 'AIGatewayService',
  '2': [
    {
      '1': 'DiagnoseImage',
      '2': '.agriculture.ai.v1.DiagnoseImageRequest',
      '3': '.agriculture.ai.v1.DiagnoseImageResponse'
    },
    {
      '1': 'DetectPests',
      '2': '.agriculture.ai.v1.DetectPestsRequest',
      '3': '.agriculture.ai.v1.DetectPestsResponse'
    },
    {
      '1': 'DetectNutrientDeficiency',
      '2': '.agriculture.ai.v1.DetectNutrientDeficiencyRequest',
      '3': '.agriculture.ai.v1.DetectNutrientDeficiencyResponse'
    },
    {
      '1': 'ClassifyPlant',
      '2': '.agriculture.ai.v1.ClassifyPlantRequest',
      '3': '.agriculture.ai.v1.ClassifyPlantResponse'
    },
    {
      '1': 'PredictYield',
      '2': '.agriculture.ai.v1.PredictYieldRequest',
      '3': '.agriculture.ai.v1.PredictYieldResponse'
    },
    {
      '1': 'SimulateCropGrowth',
      '2': '.agriculture.ai.v1.SimulateCropGrowthRequest',
      '3': '.agriculture.ai.v1.SimulateCropGrowthResponse'
    },
    {
      '1': 'ComputeNDVI',
      '2': '.agriculture.ai.v1.ComputeNDVIRequest',
      '3': '.agriculture.ai.v1.ComputeNDVIResponse'
    },
    {
      '1': 'DetectVegetationStress',
      '2': '.agriculture.ai.v1.DetectVegetationStressRequest',
      '3': '.agriculture.ai.v1.DetectVegetationStressResponse'
    },
    {
      '1': 'RecommendCrops',
      '2': '.agriculture.ai.v1.RecommendCropsRequest',
      '3': '.agriculture.ai.v1.RecommendCropsResponse'
    },
    {
      '1': 'EvaluateFieldRisk',
      '2': '.agriculture.ai.v1.EvaluateFieldRiskRequest',
      '3': '.agriculture.ai.v1.EvaluateFieldRiskResponse'
    },
    {
      '1': 'ComputeFieldAnalytics',
      '2': '.agriculture.ai.v1.ComputeFieldAnalyticsRequest',
      '3': '.agriculture.ai.v1.ComputeFieldAnalyticsResponse'
    },
    {
      '1': 'GeneratePrescription',
      '2': '.agriculture.ai.v1.GeneratePrescriptionRequest',
      '3': '.agriculture.ai.v1.GeneratePrescriptionResponse'
    },
    {
      '1': 'AnalyzeTerrain',
      '2': '.agriculture.ai.v1.AnalyzeTerrainRequest',
      '3': '.agriculture.ai.v1.AnalyzeTerrainResponse'
    },
    {
      '1': 'SimulateWaterFlow',
      '2': '.agriculture.ai.v1.SimulateWaterFlowRequest',
      '3': '.agriculture.ai.v1.SimulateWaterFlowResponse'
    },
    {
      '1': 'ListTrainingSamples',
      '2': '.agriculture.ai.v1.ListTrainingSamplesRequest',
      '3': '.agriculture.ai.v1.ListTrainingSamplesResponse'
    },
    {
      '1': 'SubmitLabelReview',
      '2': '.agriculture.ai.v1.SubmitLabelReviewRequest',
      '3': '.agriculture.ai.v1.SubmitLabelReviewResponse'
    },
    {
      '1': 'GetTrainingSampleImage',
      '2': '.agriculture.ai.v1.GetTrainingSampleImageRequest',
      '3': '.agriculture.ai.v1.GetTrainingSampleImageResponse'
    },
    {
      '1': 'RequestSecondOpinion',
      '2': '.agriculture.ai.v1.RequestSecondOpinionRequest',
      '3': '.agriculture.ai.v1.RequestSecondOpinionResponse'
    },
    {
      '1': 'GetReviewAgreement',
      '2': '.agriculture.ai.v1.GetReviewAgreementRequest',
      '3': '.agriculture.ai.v1.GetReviewAgreementResponse'
    },
  ],
};

@$core.Deprecated('Use aIGatewayServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    AIGatewayServiceBase$messageJson = {
  '.agriculture.ai.v1.DiagnoseImageRequest': DiagnoseImageRequest$json,
  '.agriculture.ai.v1.ImageData': ImageData$json,
  '.agriculture.ai.v1.SampleContext': SampleContext$json,
  '.agriculture.ai.v1.DiagnoseImageResponse': DiagnoseImageResponse$json,
  '.agriculture.ai.v1.DiseaseDetection': DiseaseDetection$json,
  '.agriculture.ai.v1.Explanation': Explanation$json,
  '.agriculture.ai.v1.DetectPestsRequest': DetectPestsRequest$json,
  '.agriculture.ai.v1.DetectPestsResponse': DetectPestsResponse$json,
  '.agriculture.ai.v1.PestDetection': PestDetection$json,
  '.agriculture.ai.v1.DetectNutrientDeficiencyRequest':
      DetectNutrientDeficiencyRequest$json,
  '.agriculture.ai.v1.DetectNutrientDeficiencyResponse':
      DetectNutrientDeficiencyResponse$json,
  '.agriculture.ai.v1.NutrientDeficiency': NutrientDeficiency$json,
  '.agriculture.ai.v1.ClassifyPlantRequest': ClassifyPlantRequest$json,
  '.agriculture.ai.v1.ClassifyPlantResponse': ClassifyPlantResponse$json,
  '.agriculture.ai.v1.PlantClassification': PlantClassification$json,
  '.agriculture.ai.v1.PredictYieldRequest': PredictYieldRequest$json,
  '.agriculture.ai.v1.EnvironmentFactors': EnvironmentFactors$json,
  '.agriculture.ai.v1.SoilFactors': SoilFactors$json,
  '.agriculture.ai.v1.ManagementFactors': ManagementFactors$json,
  '.agriculture.ai.v1.PredictYieldResponse': PredictYieldResponse$json,
  '.agriculture.ai.v1.StressFactor': StressFactor$json,
  '.agriculture.ai.v1.AttributionSummary': AttributionSummary$json,
  '.agriculture.ai.v1.FeatureAttribution': FeatureAttribution$json,
  '.agriculture.ai.v1.SimulateCropGrowthRequest':
      SimulateCropGrowthRequest$json,
  '.agriculture.ai.v1.SimulateCropGrowthResponse':
      SimulateCropGrowthResponse$json,
  '.agriculture.ai.v1.GrowthStageResult': GrowthStageResult$json,
  '.agriculture.ai.v1.ComputeNDVIRequest': ComputeNDVIRequest$json,
  '.agriculture.ai.v1.RasterBands': RasterBands$json,
  '.agriculture.ai.v1.BoundingBox': BoundingBox$json,
  '.agriculture.ai.v1.ComputeNDVIResponse': ComputeNDVIResponse$json,
  '.agriculture.ai.v1.BandStatistics': BandStatistics$json,
  '.agriculture.ai.v1.NdviZone': NdviZone$json,
  '.agriculture.ai.v1.DetectVegetationStressRequest':
      DetectVegetationStressRequest$json,
  '.agriculture.ai.v1.DetectVegetationStressResponse':
      DetectVegetationStressResponse$json,
  '.agriculture.ai.v1.StressZone': StressZone$json,
  '.agriculture.ai.v1.RecommendCropsRequest': RecommendCropsRequest$json,
  '.agriculture.ai.v1.SoilConditions': SoilConditions$json,
  '.agriculture.ai.v1.ClimateConditions': ClimateConditions$json,
  '.agriculture.ai.v1.EconomicFactors': EconomicFactors$json,
  '.agriculture.ai.v1.RecommendCropsResponse': RecommendCropsResponse$json,
  '.agriculture.ai.v1.CropRecommendation': CropRecommendation$json,
  '.agriculture.ai.v1.EvaluateFieldRiskRequest': EvaluateFieldRiskRequest$json,
  '.agriculture.ai.v1.FieldWeather': FieldWeather$json,
  '.agriculture.ai.v1.FieldSoilState': FieldSoilState$json,
  '.agriculture.ai.v1.DetectionResults': DetectionResults$json,
  '.agriculture.ai.v1.GrowthState': GrowthState$json,
  '.agriculture.ai.v1.EvaluateFieldRiskResponse':
      EvaluateFieldRiskResponse$json,
  '.agriculture.ai.v1.FieldAlert': FieldAlert$json,
  '.agriculture.ai.v1.ComputeFieldAnalyticsRequest':
      ComputeFieldAnalyticsRequest$json,
  '.agriculture.ai.v1.SeasonRecord': SeasonRecord$json,
  '.agriculture.ai.v1.NdviDataPoint': NdviDataPoint$json,
  '.agriculture.ai.v1.ComputeFieldAnalyticsResponse':
      ComputeFieldAnalyticsResponse$json,
  '.agriculture.ai.v1.RotationAnalysis': RotationAnalysis$json,
  '.agriculture.ai.v1.SeasonComparisonResult': SeasonComparisonResult$json,
  '.agriculture.ai.v1.GeneratePrescriptionRequest':
      GeneratePrescriptionRequest$json,
  '.agriculture.ai.v1.PrescriptionGrid': PrescriptionGrid$json,
  '.agriculture.ai.v1.PrescriptionZoneInput': PrescriptionZoneInput$json,
  '.agriculture.ai.v1.PrescriptionCropRequirements':
      PrescriptionCropRequirements$json,
  '.agriculture.ai.v1.GeneratePrescriptionResponse':
      GeneratePrescriptionResponse$json,
  '.agriculture.ai.v1.PrescriptionMapResult': PrescriptionMapResult$json,
  '.agriculture.ai.v1.PrescriptionZoneSummary': PrescriptionZoneSummary$json,
  '.agriculture.ai.v1.AnalyzeTerrainRequest': AnalyzeTerrainRequest$json,
  '.agriculture.ai.v1.AnalyzeTerrainResponse': AnalyzeTerrainResponse$json,
  '.agriculture.ai.v1.TerrainContourLine': TerrainContourLine$json,
  '.agriculture.ai.v1.TerrainDemStatistics': TerrainDemStatistics$json,
  '.agriculture.ai.v1.TerrainFlowStats': TerrainFlowStats$json,
  '.agriculture.ai.v1.TerrainWatershedInfo': TerrainWatershedInfo$json,
  '.agriculture.ai.v1.SimulateWaterFlowRequest': SimulateWaterFlowRequest$json,
  '.agriculture.ai.v1.WaterFlowMoistureParams': WaterFlowMoistureParams$json,
  '.agriculture.ai.v1.WaterFlowBalanceParams': WaterFlowBalanceParams$json,
  '.agriculture.ai.v1.SimulateWaterFlowResponse':
      SimulateWaterFlowResponse$json,
  '.agriculture.ai.v1.SoilMoistureSnapshot': SoilMoistureSnapshot$json,
  '.agriculture.ai.v1.WaterBalanceDay': WaterBalanceDay$json,
  '.agriculture.ai.v1.WaterFlowIrrigationSummary':
      WaterFlowIrrigationSummary$json,
  '.agriculture.ai.v1.ListTrainingSamplesRequest':
      ListTrainingSamplesRequest$json,
  '.agriculture.ai.v1.ListTrainingSamplesResponse':
      ListTrainingSamplesResponse$json,
  '.agriculture.ai.v1.TrainingSampleInfo': TrainingSampleInfo$json,
  '.agriculture.ai.v1.TrainingLabel': TrainingLabel$json,
  '.agriculture.ai.v1.LabelReview': LabelReview$json,
  '.agriculture.ai.v1.LabelSuspicion': LabelSuspicion$json,
  '.agriculture.ai.v1.SubmitLabelReviewRequest': SubmitLabelReviewRequest$json,
  '.agriculture.ai.v1.SubmitLabelReviewResponse':
      SubmitLabelReviewResponse$json,
  '.agriculture.ai.v1.GetTrainingSampleImageRequest':
      GetTrainingSampleImageRequest$json,
  '.agriculture.ai.v1.GetTrainingSampleImageResponse':
      GetTrainingSampleImageResponse$json,
  '.agriculture.ai.v1.RequestSecondOpinionRequest':
      RequestSecondOpinionRequest$json,
  '.agriculture.ai.v1.RequestSecondOpinionResponse':
      RequestSecondOpinionResponse$json,
  '.agriculture.ai.v1.GetReviewAgreementRequest':
      GetReviewAgreementRequest$json,
  '.agriculture.ai.v1.GetReviewAgreementResponse':
      GetReviewAgreementResponse$json,
  '.agriculture.ai.v1.ReviewAgreement': ReviewAgreement$json,
  '.agriculture.ai.v1.LabelDisagreement': LabelDisagreement$json,
};

/// Descriptor for `AIGatewayService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List aIGatewayServiceDescriptor = $convert.base64Decode(
    'ChBBSUdhdGV3YXlTZXJ2aWNlEmIKDURpYWdub3NlSW1hZ2USJy5hZ3JpY3VsdHVyZS5haS52MS'
    '5EaWFnbm9zZUltYWdlUmVxdWVzdBooLmFncmljdWx0dXJlLmFpLnYxLkRpYWdub3NlSW1hZ2VS'
    'ZXNwb25zZRJcCgtEZXRlY3RQZXN0cxIlLmFncmljdWx0dXJlLmFpLnYxLkRldGVjdFBlc3RzUm'
    'VxdWVzdBomLmFncmljdWx0dXJlLmFpLnYxLkRldGVjdFBlc3RzUmVzcG9uc2USgwEKGERldGVj'
    'dE51dHJpZW50RGVmaWNpZW5jeRIyLmFncmljdWx0dXJlLmFpLnYxLkRldGVjdE51dHJpZW50RG'
    'VmaWNpZW5jeVJlcXVlc3QaMy5hZ3JpY3VsdHVyZS5haS52MS5EZXRlY3ROdXRyaWVudERlZmlj'
    'aWVuY3lSZXNwb25zZRJiCg1DbGFzc2lmeVBsYW50EicuYWdyaWN1bHR1cmUuYWkudjEuQ2xhc3'
    'NpZnlQbGFudFJlcXVlc3QaKC5hZ3JpY3VsdHVyZS5haS52MS5DbGFzc2lmeVBsYW50UmVzcG9u'
    'c2USXwoMUHJlZGljdFlpZWxkEiYuYWdyaWN1bHR1cmUuYWkudjEuUHJlZGljdFlpZWxkUmVxdW'
    'VzdBonLmFncmljdWx0dXJlLmFpLnYxLlByZWRpY3RZaWVsZFJlc3BvbnNlEnEKElNpbXVsYXRl'
    'Q3JvcEdyb3d0aBIsLmFncmljdWx0dXJlLmFpLnYxLlNpbXVsYXRlQ3JvcEdyb3d0aFJlcXVlc3'
    'QaLS5hZ3JpY3VsdHVyZS5haS52MS5TaW11bGF0ZUNyb3BHcm93dGhSZXNwb25zZRJcCgtDb21w'
    'dXRlTkRWSRIlLmFncmljdWx0dXJlLmFpLnYxLkNvbXB1dGVORFZJUmVxdWVzdBomLmFncmljdW'
    'x0dXJlLmFpLnYxLkNvbXB1dGVORFZJUmVzcG9uc2USfQoWRGV0ZWN0VmVnZXRhdGlvblN0cmVz'
    'cxIwLmFncmljdWx0dXJlLmFpLnYxLkRldGVjdFZlZ2V0YXRpb25TdHJlc3NSZXF1ZXN0GjEuYW'
    'dyaWN1bHR1cmUuYWkudjEuRGV0ZWN0VmVnZXRhdGlvblN0cmVzc1Jlc3BvbnNlEmUKDlJlY29t'
    'bWVuZENyb3BzEiguYWdyaWN1bHR1cmUuYWkudjEuUmVjb21tZW5kQ3JvcHNSZXF1ZXN0GikuYW'
    'dyaWN1bHR1cmUuYWkudjEuUmVjb21tZW5kQ3JvcHNSZXNwb25zZRJuChFFdmFsdWF0ZUZpZWxk'
    'UmlzaxIrLmFncmljdWx0dXJlLmFpLnYxLkV2YWx1YXRlRmllbGRSaXNrUmVxdWVzdBosLmFncm'
    'ljdWx0dXJlLmFpLnYxLkV2YWx1YXRlRmllbGRSaXNrUmVzcG9uc2USegoVQ29tcHV0ZUZpZWxk'
    'QW5hbHl0aWNzEi8uYWdyaWN1bHR1cmUuYWkudjEuQ29tcHV0ZUZpZWxkQW5hbHl0aWNzUmVxdW'
    'VzdBowLmFncmljdWx0dXJlLmFpLnYxLkNvbXB1dGVGaWVsZEFuYWx5dGljc1Jlc3BvbnNlEncK'
    'FEdlbmVyYXRlUHJlc2NyaXB0aW9uEi4uYWdyaWN1bHR1cmUuYWkudjEuR2VuZXJhdGVQcmVzY3'
    'JpcHRpb25SZXF1ZXN0Gi8uYWdyaWN1bHR1cmUuYWkudjEuR2VuZXJhdGVQcmVzY3JpcHRpb25S'
    'ZXNwb25zZRJlCg5BbmFseXplVGVycmFpbhIoLmFncmljdWx0dXJlLmFpLnYxLkFuYWx5emVUZX'
    'JyYWluUmVxdWVzdBopLmFncmljdWx0dXJlLmFpLnYxLkFuYWx5emVUZXJyYWluUmVzcG9uc2US'
    'bgoRU2ltdWxhdGVXYXRlckZsb3cSKy5hZ3JpY3VsdHVyZS5haS52MS5TaW11bGF0ZVdhdGVyRm'
    'xvd1JlcXVlc3QaLC5hZ3JpY3VsdHVyZS5haS52MS5TaW11bGF0ZVdhdGVyRmxvd1Jlc3BvbnNl'
    'EnQKE0xpc3RUcmFpbmluZ1NhbXBsZXMSLS5hZ3JpY3VsdHVyZS5haS52MS5MaXN0VHJhaW5pbm'
    'dTYW1wbGVzUmVxdWVzdBouLmFncmljdWx0dXJlLmFpLnYxLkxpc3RUcmFpbmluZ1NhbXBsZXNS'
    'ZXNwb25zZRJuChFTdWJtaXRMYWJlbFJldmlldxIrLmFncmljdWx0dXJlLmFpLnYxLlN1Ym1pdE'
    'xhYmVsUmV2aWV3UmVxdWVzdBosLmFncmljdWx0dXJlLmFpLnYxLlN1Ym1pdExhYmVsUmV2aWV3'
    'UmVzcG9uc2USfQoWR2V0VHJhaW5pbmdTYW1wbGVJbWFnZRIwLmFncmljdWx0dXJlLmFpLnYxLk'
    'dldFRyYWluaW5nU2FtcGxlSW1hZ2VSZXF1ZXN0GjEuYWdyaWN1bHR1cmUuYWkudjEuR2V0VHJh'
    'aW5pbmdTYW1wbGVJbWFnZVJlc3BvbnNlEncKFFJlcXVlc3RTZWNvbmRPcGluaW9uEi4uYWdyaW'
    'N1bHR1cmUuYWkudjEuUmVxdWVzdFNlY29uZE9waW5pb25SZXF1ZXN0Gi8uYWdyaWN1bHR1cmUu'
    'YWkudjEuUmVxdWVzdFNlY29uZE9waW5pb25SZXNwb25zZRJxChJHZXRSZXZpZXdBZ3JlZW1lbn'
    'QSLC5hZ3JpY3VsdHVyZS5haS52MS5HZXRSZXZpZXdBZ3JlZW1lbnRSZXF1ZXN0Gi0uYWdyaWN1'
    'bHR1cmUuYWkudjEuR2V0UmV2aWV3QWdyZWVtZW50UmVzcG9uc2U=');
