// This is a generated file - do not edit.
//
// Generated from diagnosis.proto.

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

@$core.Deprecated('Use imageTypeDescriptor instead')
const ImageType$json = {
  '1': 'ImageType',
  '2': [
    {'1': 'IMAGE_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'IMAGE_TYPE_LEAF', '2': 1},
    {'1': 'IMAGE_TYPE_STEM', '2': 2},
    {'1': 'IMAGE_TYPE_FRUIT', '2': 3},
    {'1': 'IMAGE_TYPE_WHOLE_PLANT', '2': 4},
    {'1': 'IMAGE_TYPE_ROOT', '2': 5},
  ],
};

/// Descriptor for `ImageType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List imageTypeDescriptor = $convert.base64Decode(
    'CglJbWFnZVR5cGUSGgoWSU1BR0VfVFlQRV9VTlNQRUNJRklFRBAAEhMKD0lNQUdFX1RZUEVfTE'
    'VBRhABEhMKD0lNQUdFX1RZUEVfU1RFTRACEhQKEElNQUdFX1RZUEVfRlJVSVQQAxIaChZJTUFH'
    'RV9UWVBFX1dIT0xFX1BMQU5UEAQSEwoPSU1BR0VfVFlQRV9ST09UEAU=');

@$core.Deprecated('Use diagnosisStatusDescriptor instead')
const DiagnosisStatus$json = {
  '1': 'DiagnosisStatus',
  '2': [
    {'1': 'DIAGNOSIS_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'DIAGNOSIS_STATUS_PENDING', '2': 1},
    {'1': 'DIAGNOSIS_STATUS_ANALYZING', '2': 2},
    {'1': 'DIAGNOSIS_STATUS_COMPLETED', '2': 3},
    {'1': 'DIAGNOSIS_STATUS_FAILED', '2': 4},
  ],
};

/// Descriptor for `DiagnosisStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List diagnosisStatusDescriptor = $convert.base64Decode(
    'Cg9EaWFnbm9zaXNTdGF0dXMSIAocRElBR05PU0lTX1NUQVRVU19VTlNQRUNJRklFRBAAEhwKGE'
    'RJQUdOT1NJU19TVEFUVVNfUEVORElORxABEh4KGkRJQUdOT1NJU19TVEFUVVNfQU5BTFlaSU5H'
    'EAISHgoaRElBR05PU0lTX1NUQVRVU19DT01QTEVURUQQAxIbChdESUFHTk9TSVNfU1RBVFVTX0'
    'ZBSUxFRBAE');

@$core.Deprecated('Use severityDescriptor instead')
const Severity$json = {
  '1': 'Severity',
  '2': [
    {'1': 'SEVERITY_UNSPECIFIED', '2': 0},
    {'1': 'SEVERITY_MILD', '2': 1},
    {'1': 'SEVERITY_MODERATE', '2': 2},
    {'1': 'SEVERITY_SEVERE', '2': 3},
    {'1': 'SEVERITY_CRITICAL', '2': 4},
  ],
};

/// Descriptor for `Severity`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List severityDescriptor = $convert.base64Decode(
    'CghTZXZlcml0eRIYChRTRVZFUklUWV9VTlNQRUNJRklFRBAAEhEKDVNFVkVSSVRZX01JTEQQAR'
    'IVChFTRVZFUklUWV9NT0RFUkFURRACEhMKD1NFVkVSSVRZX1NFVkVSRRADEhUKEVNFVkVSSVRZ'
    'X0NSSVRJQ0FMEAQ=');

@$core.Deprecated('Use diagnosisImageDescriptor instead')
const DiagnosisImage$json = {
  '1': 'DiagnosisImage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'image_url', '3': 2, '4': 1, '5': 9, '10': 'imageUrl'},
    {
      '1': 'image_type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.diagnosis.v1.ImageType',
      '10': 'imageType'
    },
    {'1': 'size_bytes', '3': 4, '4': 1, '5': 3, '10': 'sizeBytes'},
    {'1': 'mime_type', '3': 5, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'checksum', '3': 6, '4': 1, '5': 9, '10': 'checksum'},
    {
      '1': 'uploaded_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'uploadedAt'
    },
  ],
};

/// Descriptor for `DiagnosisImage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diagnosisImageDescriptor = $convert.base64Decode(
    'Cg5EaWFnbm9zaXNJbWFnZRIOCgJpZBgBIAEoCVICaWQSGwoJaW1hZ2VfdXJsGAIgASgJUghpbW'
    'FnZVVybBJCCgppbWFnZV90eXBlGAMgASgOMiMuYWdyaWN1bHR1cmUuZGlhZ25vc2lzLnYxLklt'
    'YWdlVHlwZVIJaW1hZ2VUeXBlEh0KCnNpemVfYnl0ZXMYBCABKANSCXNpemVCeXRlcxIbCgltaW'
    '1lX3R5cGUYBSABKAlSCG1pbWVUeXBlEhoKCGNoZWNrc3VtGAYgASgJUghjaGVja3N1bRI7Cgt1'
    'cGxvYWRlZF9hdBgHIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCnVwbG9hZGVkQX'
    'Q=');

@$core.Deprecated('Use diseaseInfoDescriptor instead')
const DiseaseInfo$json = {
  '1': 'DiseaseInfo',
  '2': [
    {'1': 'disease_id', '3': 1, '4': 1, '5': 9, '10': 'diseaseId'},
    {'1': 'disease_name', '3': 2, '4': 1, '5': 9, '10': 'diseaseName'},
    {'1': 'scientific_name', '3': 3, '4': 1, '5': 9, '10': 'scientificName'},
    {'1': 'confidence_score', '3': 4, '4': 1, '5': 1, '10': 'confidenceScore'},
    {
      '1': 'severity',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.diagnosis.v1.Severity',
      '10': 'severity'
    },
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

/// Descriptor for `DiseaseInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diseaseInfoDescriptor = $convert.base64Decode(
    'CgtEaXNlYXNlSW5mbxIdCgpkaXNlYXNlX2lkGAEgASgJUglkaXNlYXNlSWQSIQoMZGlzZWFzZV'
    '9uYW1lGAIgASgJUgtkaXNlYXNlTmFtZRInCg9zY2llbnRpZmljX25hbWUYAyABKAlSDnNjaWVu'
    'dGlmaWNOYW1lEikKEGNvbmZpZGVuY2Vfc2NvcmUYBCABKAFSD2NvbmZpZGVuY2VTY29yZRI+Cg'
    'hzZXZlcml0eRgFIAEoDjIiLmFncmljdWx0dXJlLmRpYWdub3Npcy52MS5TZXZlcml0eVIIc2V2'
    'ZXJpdHkSIAoLZGVzY3JpcHRpb24YBiABKAlSC2Rlc2NyaXB0aW9uEhoKCHN5bXB0b21zGAcgAS'
    'gJUghzeW1wdG9tcxIrChF0cmVhdG1lbnRfb3B0aW9ucxgIIAMoCVIQdHJlYXRtZW50T3B0aW9u'
    'cxIeCgpwcmV2ZW50aW9uGAkgASgJUgpwcmV2ZW50aW9u');

@$core.Deprecated('Use nutrientDeficiencyDescriptor instead')
const NutrientDeficiency$json = {
  '1': 'NutrientDeficiency',
  '2': [
    {'1': 'nutrient', '3': 1, '4': 1, '5': 9, '10': 'nutrient'},
    {'1': 'confidence_score', '3': 2, '4': 1, '5': 1, '10': 'confidenceScore'},
    {
      '1': 'severity',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.diagnosis.v1.Severity',
      '10': 'severity'
    },
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
    'ZpZGVuY2Vfc2NvcmUYAiABKAFSD2NvbmZpZGVuY2VTY29yZRI+CghzZXZlcml0eRgDIAEoDjIi'
    'LmFncmljdWx0dXJlLmRpYWdub3Npcy52MS5TZXZlcml0eVIIc2V2ZXJpdHkSIAoLZGVzY3JpcH'
    'Rpb24YBCABKAlSC2Rlc2NyaXB0aW9uEicKD3Zpc3VhbF9zeW1wdG9tcxgFIAEoCVIOdmlzdWFs'
    'U3ltcHRvbXMSNwoXcmVjb21tZW5kZWRfZmVydGlsaXplcnMYBiADKAlSFnJlY29tbWVuZGVkRm'
    'VydGlsaXplcnMSLQoSYXBwbGljYXRpb25fbWV0aG9kGAcgASgJUhFhcHBsaWNhdGlvbk1ldGhv'
    'ZA==');

@$core.Deprecated('Use pestDamageDescriptor instead')
const PestDamage$json = {
  '1': 'PestDamage',
  '2': [
    {'1': 'pest_id', '3': 1, '4': 1, '5': 9, '10': 'pestId'},
    {'1': 'pest_name', '3': 2, '4': 1, '5': 9, '10': 'pestName'},
    {'1': 'scientific_name', '3': 3, '4': 1, '5': 9, '10': 'scientificName'},
    {'1': 'confidence_score', '3': 4, '4': 1, '5': 1, '10': 'confidenceScore'},
    {
      '1': 'damage_level',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.diagnosis.v1.Severity',
      '10': 'damageLevel'
    },
    {'1': 'description', '3': 6, '4': 1, '5': 9, '10': 'description'},
    {'1': 'damage_pattern', '3': 7, '4': 1, '5': 9, '10': 'damagePattern'},
    {'1': 'control_methods', '3': 8, '4': 3, '5': 9, '10': 'controlMethods'},
  ],
};

/// Descriptor for `PestDamage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pestDamageDescriptor = $convert.base64Decode(
    'CgpQZXN0RGFtYWdlEhcKB3Blc3RfaWQYASABKAlSBnBlc3RJZBIbCglwZXN0X25hbWUYAiABKA'
    'lSCHBlc3ROYW1lEicKD3NjaWVudGlmaWNfbmFtZRgDIAEoCVIOc2NpZW50aWZpY05hbWUSKQoQ'
    'Y29uZmlkZW5jZV9zY29yZRgEIAEoAVIPY29uZmlkZW5jZVNjb3JlEkUKDGRhbWFnZV9sZXZlbB'
    'gFIAEoDjIiLmFncmljdWx0dXJlLmRpYWdub3Npcy52MS5TZXZlcml0eVILZGFtYWdlTGV2ZWwS'
    'IAoLZGVzY3JpcHRpb24YBiABKAlSC2Rlc2NyaXB0aW9uEiUKDmRhbWFnZV9wYXR0ZXJuGAcgAS'
    'gJUg1kYW1hZ2VQYXR0ZXJuEicKD2NvbnRyb2xfbWV0aG9kcxgIIAMoCVIOY29udHJvbE1ldGhv'
    'ZHM=');

@$core.Deprecated('Use plantSpeciesDescriptor instead')
const PlantSpecies$json = {
  '1': 'PlantSpecies',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'common_name', '3': 2, '4': 1, '5': 9, '10': 'commonName'},
    {'1': 'scientific_name', '3': 3, '4': 1, '5': 9, '10': 'scientificName'},
    {'1': 'family', '3': 4, '4': 1, '5': 9, '10': 'family'},
    {'1': 'confidence', '3': 5, '4': 1, '5': 1, '10': 'confidence'},
  ],
};

/// Descriptor for `PlantSpecies`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List plantSpeciesDescriptor = $convert.base64Decode(
    'CgxQbGFudFNwZWNpZXMSDgoCaWQYASABKAlSAmlkEh8KC2NvbW1vbl9uYW1lGAIgASgJUgpjb2'
    '1tb25OYW1lEicKD3NjaWVudGlmaWNfbmFtZRgDIAEoCVIOc2NpZW50aWZpY05hbWUSFgoGZmFt'
    'aWx5GAQgASgJUgZmYW1pbHkSHgoKY29uZmlkZW5jZRgFIAEoAVIKY29uZmlkZW5jZQ==');

@$core.Deprecated('Use treatmentPlanDescriptor instead')
const TreatmentPlan$json = {
  '1': 'TreatmentPlan',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'diagnosis_id', '3': 2, '4': 1, '5': 9, '10': 'diagnosisId'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {
      '1': 'priority',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.agriculture.diagnosis.v1.Severity',
      '10': 'priority'
    },
    {
      '1': 'steps',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.TreatmentStep',
      '10': 'steps'
    },
    {'1': 'estimated_cost', '3': 7, '4': 1, '5': 9, '10': 'estimatedCost'},
    {'1': 'estimated_days', '3': 8, '4': 1, '5': 5, '10': 'estimatedDays'},
    {
      '1': 'created_at',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `TreatmentPlan`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treatmentPlanDescriptor = $convert.base64Decode(
    'Cg1UcmVhdG1lbnRQbGFuEg4KAmlkGAEgASgJUgJpZBIhCgxkaWFnbm9zaXNfaWQYAiABKAlSC2'
    'RpYWdub3Npc0lkEhQKBXRpdGxlGAMgASgJUgV0aXRsZRIgCgtkZXNjcmlwdGlvbhgEIAEoCVIL'
    'ZGVzY3JpcHRpb24SPgoIcHJpb3JpdHkYBSABKA4yIi5hZ3JpY3VsdHVyZS5kaWFnbm9zaXMudj'
    'EuU2V2ZXJpdHlSCHByaW9yaXR5Ej0KBXN0ZXBzGAYgAygLMicuYWdyaWN1bHR1cmUuZGlhZ25v'
    'c2lzLnYxLlRyZWF0bWVudFN0ZXBSBXN0ZXBzEiUKDmVzdGltYXRlZF9jb3N0GAcgASgJUg1lc3'
    'RpbWF0ZWRDb3N0EiUKDmVzdGltYXRlZF9kYXlzGAggASgFUg1lc3RpbWF0ZWREYXlzEjkKCmNy'
    'ZWF0ZWRfYXQYCSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use treatmentStepDescriptor instead')
const TreatmentStep$json = {
  '1': 'TreatmentStep',
  '2': [
    {'1': 'step_number', '3': 1, '4': 1, '5': 5, '10': 'stepNumber'},
    {'1': 'action', '3': 2, '4': 1, '5': 9, '10': 'action'},
    {'1': 'product', '3': 3, '4': 1, '5': 9, '10': 'product'},
    {'1': 'dosage', '3': 4, '4': 1, '5': 9, '10': 'dosage'},
    {'1': 'frequency', '3': 5, '4': 1, '5': 9, '10': 'frequency'},
    {'1': 'notes', '3': 6, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'duration_days', '3': 7, '4': 1, '5': 5, '10': 'durationDays'},
  ],
};

/// Descriptor for `TreatmentStep`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List treatmentStepDescriptor = $convert.base64Decode(
    'Cg1UcmVhdG1lbnRTdGVwEh8KC3N0ZXBfbnVtYmVyGAEgASgFUgpzdGVwTnVtYmVyEhYKBmFjdG'
    'lvbhgCIAEoCVIGYWN0aW9uEhgKB3Byb2R1Y3QYAyABKAlSB3Byb2R1Y3QSFgoGZG9zYWdlGAQg'
    'ASgJUgZkb3NhZ2USHAoJZnJlcXVlbmN5GAUgASgJUglmcmVxdWVuY3kSFAoFbm90ZXMYBiABKA'
    'lSBW5vdGVzEiMKDWR1cmF0aW9uX2RheXMYByABKAVSDGR1cmF0aW9uRGF5cw==');

@$core.Deprecated('Use diagnosisResultDescriptor instead')
const DiagnosisResult$json = {
  '1': 'DiagnosisResult',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {
      '1': 'diagnosis_request_id',
      '3': 2,
      '4': 1,
      '5': 9,
      '10': 'diagnosisRequestId'
    },
    {
      '1': 'identified_species',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.PlantSpecies',
      '10': 'identifiedSpecies'
    },
    {
      '1': 'detected_diseases',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.DiseaseInfo',
      '10': 'detectedDiseases'
    },
    {
      '1': 'nutrient_deficiencies',
      '3': 5,
      '4': 3,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.NutrientDeficiency',
      '10': 'nutrientDeficiencies'
    },
    {
      '1': 'pest_damage',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.PestDamage',
      '10': 'pestDamage'
    },
    {
      '1': 'treatment_recommendations',
      '3': 7,
      '4': 3,
      '5': 9,
      '10': 'treatmentRecommendations'
    },
    {'1': 'ai_model_version', '3': 8, '4': 1, '5': 9, '10': 'aiModelVersion'},
    {
      '1': 'processing_time_ms',
      '3': 9,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
    {
      '1': 'overall_health_score',
      '3': 10,
      '4': 1,
      '5': 1,
      '10': 'overallHealthScore'
    },
    {'1': 'summary', '3': 11, '4': 1, '5': 9, '10': 'summary'},
    {
      '1': 'created_at',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
};

/// Descriptor for `DiagnosisResult`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diagnosisResultDescriptor = $convert.base64Decode(
    'Cg9EaWFnbm9zaXNSZXN1bHQSDgoCaWQYASABKAlSAmlkEjAKFGRpYWdub3Npc19yZXF1ZXN0X2'
    'lkGAIgASgJUhJkaWFnbm9zaXNSZXF1ZXN0SWQSVQoSaWRlbnRpZmllZF9zcGVjaWVzGAMgASgL'
    'MiYuYWdyaWN1bHR1cmUuZGlhZ25vc2lzLnYxLlBsYW50U3BlY2llc1IRaWRlbnRpZmllZFNwZW'
    'NpZXMSUgoRZGV0ZWN0ZWRfZGlzZWFzZXMYBCADKAsyJS5hZ3JpY3VsdHVyZS5kaWFnbm9zaXMu'
    'djEuRGlzZWFzZUluZm9SEGRldGVjdGVkRGlzZWFzZXMSYQoVbnV0cmllbnRfZGVmaWNpZW5jaW'
    'VzGAUgAygLMiwuYWdyaWN1bHR1cmUuZGlhZ25vc2lzLnYxLk51dHJpZW50RGVmaWNpZW5jeVIU'
    'bnV0cmllbnREZWZpY2llbmNpZXMSRQoLcGVzdF9kYW1hZ2UYBiADKAsyJC5hZ3JpY3VsdHVyZS'
    '5kaWFnbm9zaXMudjEuUGVzdERhbWFnZVIKcGVzdERhbWFnZRI7Chl0cmVhdG1lbnRfcmVjb21t'
    'ZW5kYXRpb25zGAcgAygJUhh0cmVhdG1lbnRSZWNvbW1lbmRhdGlvbnMSKAoQYWlfbW9kZWxfdm'
    'Vyc2lvbhgIIAEoCVIOYWlNb2RlbFZlcnNpb24SLAoScHJvY2Vzc2luZ190aW1lX21zGAkgASgD'
    'UhBwcm9jZXNzaW5nVGltZU1zEjAKFG92ZXJhbGxfaGVhbHRoX3Njb3JlGAogASgBUhJvdmVyYW'
    'xsSGVhbHRoU2NvcmUSGAoHc3VtbWFyeRgLIAEoCVIHc3VtbWFyeRI5CgpjcmVhdGVkX2F0GAwg'
    'ASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0');

@$core.Deprecated('Use diagnosisRequestDescriptor instead')
const DiagnosisRequest$json = {
  '1': 'DiagnosisRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'plant_species_id', '3': 5, '4': 1, '5': 9, '10': 'plantSpeciesId'},
    {
      '1': 'images',
      '3': 6,
      '4': 3,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.DiagnosisImage',
      '10': 'images'
    },
    {
      '1': 'status',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.diagnosis.v1.DiagnosisStatus',
      '10': 'status'
    },
    {
      '1': 'result',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.DiagnosisResult',
      '10': 'result'
    },
    {'1': 'notes', '3': 9, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'created_by', '3': 10, '4': 1, '5': 9, '10': 'createdBy'},
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
    {'1': 'version', '3': 13, '4': 1, '5': 5, '10': 'version'},
  ],
};

/// Descriptor for `DiagnosisRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List diagnosisRequestDescriptor = $convert.base64Decode(
    'ChBEaWFnbm9zaXNSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCH'
    'RlbmFudElkEhcKB2Zhcm1faWQYAyABKAlSBmZhcm1JZBIZCghmaWVsZF9pZBgEIAEoCVIHZmll'
    'bGRJZBIoChBwbGFudF9zcGVjaWVzX2lkGAUgASgJUg5wbGFudFNwZWNpZXNJZBJACgZpbWFnZX'
    'MYBiADKAsyKC5hZ3JpY3VsdHVyZS5kaWFnbm9zaXMudjEuRGlhZ25vc2lzSW1hZ2VSBmltYWdl'
    'cxJBCgZzdGF0dXMYByABKA4yKS5hZ3JpY3VsdHVyZS5kaWFnbm9zaXMudjEuRGlhZ25vc2lzU3'
    'RhdHVzUgZzdGF0dXMSQQoGcmVzdWx0GAggASgLMikuYWdyaWN1bHR1cmUuZGlhZ25vc2lzLnYx'
    'LkRpYWdub3Npc1Jlc3VsdFIGcmVzdWx0EhQKBW5vdGVzGAkgASgJUgVub3RlcxIdCgpjcmVhdG'
    'VkX2J5GAogASgJUgljcmVhdGVkQnkSOQoKY3JlYXRlZF9hdBgLIAEoCzIaLmdvb2dsZS5wcm90'
    'b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdBI5Cgp1cGRhdGVkX2F0GAwgASgLMhouZ29vZ2xlLn'
    'Byb3RvYnVmLlRpbWVzdGFtcFIJdXBkYXRlZEF0EhgKB3ZlcnNpb24YDSABKAVSB3ZlcnNpb24=');

@$core.Deprecated('Use submitDiagnosisRequestDescriptor instead')
const SubmitDiagnosisRequest$json = {
  '1': 'SubmitDiagnosisRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'plant_species_id', '3': 3, '4': 1, '5': 9, '10': 'plantSpeciesId'},
    {
      '1': 'images',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.ImageInput',
      '10': 'images'
    },
    {'1': 'notes', '3': 5, '4': 1, '5': 9, '10': 'notes'},
  ],
};

/// Descriptor for `SubmitDiagnosisRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitDiagnosisRequestDescriptor = $convert.base64Decode(
    'ChZTdWJtaXREaWFnbm9zaXNSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZBIZCghmaW'
    'VsZF9pZBgCIAEoCVIHZmllbGRJZBIoChBwbGFudF9zcGVjaWVzX2lkGAMgASgJUg5wbGFudFNw'
    'ZWNpZXNJZBI8CgZpbWFnZXMYBCADKAsyJC5hZ3JpY3VsdHVyZS5kaWFnbm9zaXMudjEuSW1hZ2'
    'VJbnB1dFIGaW1hZ2VzEhQKBW5vdGVzGAUgASgJUgVub3Rlcw==');

@$core.Deprecated('Use imageInputDescriptor instead')
const ImageInput$json = {
  '1': 'ImageInput',
  '2': [
    {'1': 'image_url', '3': 1, '4': 1, '5': 9, '10': 'imageUrl'},
    {
      '1': 'image_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.diagnosis.v1.ImageType',
      '10': 'imageType'
    },
    {'1': 'mime_type', '3': 3, '4': 1, '5': 9, '10': 'mimeType'},
  ],
};

/// Descriptor for `ImageInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List imageInputDescriptor = $convert.base64Decode(
    'CgpJbWFnZUlucHV0EhsKCWltYWdlX3VybBgBIAEoCVIIaW1hZ2VVcmwSQgoKaW1hZ2VfdHlwZR'
    'gCIAEoDjIjLmFncmljdWx0dXJlLmRpYWdub3Npcy52MS5JbWFnZVR5cGVSCWltYWdlVHlwZRIb'
    'CgltaW1lX3R5cGUYAyABKAlSCG1pbWVUeXBl');

@$core.Deprecated('Use submitDiagnosisResponseDescriptor instead')
const SubmitDiagnosisResponse$json = {
  '1': 'SubmitDiagnosisResponse',
  '2': [
    {
      '1': 'diagnosis',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.DiagnosisRequest',
      '10': 'diagnosis'
    },
  ],
};

/// Descriptor for `SubmitDiagnosisResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List submitDiagnosisResponseDescriptor =
    $convert.base64Decode(
        'ChdTdWJtaXREaWFnbm9zaXNSZXNwb25zZRJICglkaWFnbm9zaXMYASABKAsyKi5hZ3JpY3VsdH'
        'VyZS5kaWFnbm9zaXMudjEuRGlhZ25vc2lzUmVxdWVzdFIJZGlhZ25vc2lz');

@$core.Deprecated('Use getDiagnosisRequestDescriptor instead')
const GetDiagnosisRequest$json = {
  '1': 'GetDiagnosisRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetDiagnosisRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDiagnosisRequestDescriptor = $convert
    .base64Decode('ChNHZXREaWFnbm9zaXNSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use getDiagnosisResponseDescriptor instead')
const GetDiagnosisResponse$json = {
  '1': 'GetDiagnosisResponse',
  '2': [
    {
      '1': 'diagnosis',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.DiagnosisRequest',
      '10': 'diagnosis'
    },
  ],
};

/// Descriptor for `GetDiagnosisResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDiagnosisResponseDescriptor = $convert.base64Decode(
    'ChRHZXREaWFnbm9zaXNSZXNwb25zZRJICglkaWFnbm9zaXMYASABKAsyKi5hZ3JpY3VsdHVyZS'
    '5kaWFnbm9zaXMudjEuRGlhZ25vc2lzUmVxdWVzdFIJZGlhZ25vc2lz');

@$core.Deprecated('Use listDiagnosesRequestDescriptor instead')
const ListDiagnosesRequest$json = {
  '1': 'ListDiagnosesRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.diagnosis.v1.DiagnosisStatus',
      '10': 'status'
    },
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 5, '4': 1, '5': 5, '10': 'pageOffset'},
    {'1': 'sort_by', '3': 6, '4': 1, '5': 9, '10': 'sortBy'},
    {'1': 'sort_desc', '3': 7, '4': 1, '5': 8, '10': 'sortDesc'},
  ],
};

/// Descriptor for `ListDiagnosesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDiagnosesRequestDescriptor = $convert.base64Decode(
    'ChRMaXN0RGlhZ25vc2VzUmVxdWVzdBIXCgdmYXJtX2lkGAEgASgJUgZmYXJtSWQSGQoIZmllbG'
    'RfaWQYAiABKAlSB2ZpZWxkSWQSQQoGc3RhdHVzGAMgASgOMikuYWdyaWN1bHR1cmUuZGlhZ25v'
    'c2lzLnYxLkRpYWdub3Npc1N0YXR1c1IGc3RhdHVzEhsKCXBhZ2Vfc2l6ZRgEIAEoBVIIcGFnZV'
    'NpemUSHwoLcGFnZV9vZmZzZXQYBSABKAVSCnBhZ2VPZmZzZXQSFwoHc29ydF9ieRgGIAEoCVIG'
    'c29ydEJ5EhsKCXNvcnRfZGVzYxgHIAEoCFIIc29ydERlc2M=');

@$core.Deprecated('Use listDiagnosesResponseDescriptor instead')
const ListDiagnosesResponse$json = {
  '1': 'ListDiagnosesResponse',
  '2': [
    {
      '1': 'diagnoses',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.DiagnosisRequest',
      '10': 'diagnoses'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListDiagnosesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDiagnosesResponseDescriptor = $convert.base64Decode(
    'ChVMaXN0RGlhZ25vc2VzUmVzcG9uc2USSAoJZGlhZ25vc2VzGAEgAygLMiouYWdyaWN1bHR1cm'
    'UuZGlhZ25vc2lzLnYxLkRpYWdub3Npc1JlcXVlc3RSCWRpYWdub3NlcxIfCgt0b3RhbF9jb3Vu'
    'dBgCIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use getDiseaseInfoRequestDescriptor instead')
const GetDiseaseInfoRequest$json = {
  '1': 'GetDiseaseInfoRequest',
  '2': [
    {'1': 'disease_id', '3': 1, '4': 1, '5': 9, '10': 'diseaseId'},
  ],
};

/// Descriptor for `GetDiseaseInfoRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDiseaseInfoRequestDescriptor = $convert.base64Decode(
    'ChVHZXREaXNlYXNlSW5mb1JlcXVlc3QSHQoKZGlzZWFzZV9pZBgBIAEoCVIJZGlzZWFzZUlk');

@$core.Deprecated('Use getDiseaseInfoResponseDescriptor instead')
const GetDiseaseInfoResponse$json = {
  '1': 'GetDiseaseInfoResponse',
  '2': [
    {
      '1': 'disease',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.DiseaseInfo',
      '10': 'disease'
    },
  ],
};

/// Descriptor for `GetDiseaseInfoResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getDiseaseInfoResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXREaXNlYXNlSW5mb1Jlc3BvbnNlEj8KB2Rpc2Vhc2UYASABKAsyJS5hZ3JpY3VsdHVyZS'
        '5kaWFnbm9zaXMudjEuRGlzZWFzZUluZm9SB2Rpc2Vhc2U=');

@$core.Deprecated('Use listDiseasesRequestDescriptor instead')
const ListDiseasesRequest$json = {
  '1': 'ListDiseasesRequest',
  '2': [
    {'1': 'search_term', '3': 1, '4': 1, '5': 9, '10': 'searchTerm'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_offset', '3': 3, '4': 1, '5': 5, '10': 'pageOffset'},
  ],
};

/// Descriptor for `ListDiseasesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDiseasesRequestDescriptor = $convert.base64Decode(
    'ChNMaXN0RGlzZWFzZXNSZXF1ZXN0Eh8KC3NlYXJjaF90ZXJtGAEgASgJUgpzZWFyY2hUZXJtEh'
    'sKCXBhZ2Vfc2l6ZRgCIAEoBVIIcGFnZVNpemUSHwoLcGFnZV9vZmZzZXQYAyABKAVSCnBhZ2VP'
    'ZmZzZXQ=');

@$core.Deprecated('Use listDiseasesResponseDescriptor instead')
const ListDiseasesResponse$json = {
  '1': 'ListDiseasesResponse',
  '2': [
    {
      '1': 'diseases',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.DiseaseInfo',
      '10': 'diseases'
    },
    {'1': 'total_count', '3': 2, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListDiseasesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDiseasesResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0RGlzZWFzZXNSZXNwb25zZRJBCghkaXNlYXNlcxgBIAMoCzIlLmFncmljdWx0dXJlLm'
    'RpYWdub3Npcy52MS5EaXNlYXNlSW5mb1IIZGlzZWFzZXMSHwoLdG90YWxfY291bnQYAiABKAVS'
    'CnRvdGFsQ291bnQ=');

@$core.Deprecated('Use getTreatmentPlanRequestDescriptor instead')
const GetTreatmentPlanRequest$json = {
  '1': 'GetTreatmentPlanRequest',
  '2': [
    {'1': 'diagnosis_id', '3': 1, '4': 1, '5': 9, '10': 'diagnosisId'},
  ],
};

/// Descriptor for `GetTreatmentPlanRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTreatmentPlanRequestDescriptor =
    $convert.base64Decode(
        'ChdHZXRUcmVhdG1lbnRQbGFuUmVxdWVzdBIhCgxkaWFnbm9zaXNfaWQYASABKAlSC2RpYWdub3'
        'Npc0lk');

@$core.Deprecated('Use getTreatmentPlanResponseDescriptor instead')
const GetTreatmentPlanResponse$json = {
  '1': 'GetTreatmentPlanResponse',
  '2': [
    {
      '1': 'treatment_plan',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.TreatmentPlan',
      '10': 'treatmentPlan'
    },
  ],
};

/// Descriptor for `GetTreatmentPlanResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getTreatmentPlanResponseDescriptor =
    $convert.base64Decode(
        'ChhHZXRUcmVhdG1lbnRQbGFuUmVzcG9uc2USTgoOdHJlYXRtZW50X3BsYW4YASABKAsyJy5hZ3'
        'JpY3VsdHVyZS5kaWFnbm9zaXMudjEuVHJlYXRtZW50UGxhblINdHJlYXRtZW50UGxhbg==');

@$core.Deprecated('Use identifySpeciesRequestDescriptor instead')
const IdentifySpeciesRequest$json = {
  '1': 'IdentifySpeciesRequest',
  '2': [
    {
      '1': 'images',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.ImageInput',
      '10': 'images'
    },
  ],
};

/// Descriptor for `IdentifySpeciesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List identifySpeciesRequestDescriptor =
    $convert.base64Decode(
        'ChZJZGVudGlmeVNwZWNpZXNSZXF1ZXN0EjwKBmltYWdlcxgBIAMoCzIkLmFncmljdWx0dXJlLm'
        'RpYWdub3Npcy52MS5JbWFnZUlucHV0UgZpbWFnZXM=');

@$core.Deprecated('Use identifySpeciesResponseDescriptor instead')
const IdentifySpeciesResponse$json = {
  '1': 'IdentifySpeciesResponse',
  '2': [
    {
      '1': 'species',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.PlantSpecies',
      '10': 'species'
    },
    {'1': 'ai_model_version', '3': 2, '4': 1, '5': 9, '10': 'aiModelVersion'},
    {
      '1': 'processing_time_ms',
      '3': 3,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
  ],
};

/// Descriptor for `IdentifySpeciesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List identifySpeciesResponseDescriptor = $convert.base64Decode(
    'ChdJZGVudGlmeVNwZWNpZXNSZXNwb25zZRJACgdzcGVjaWVzGAEgAygLMiYuYWdyaWN1bHR1cm'
    'UuZGlhZ25vc2lzLnYxLlBsYW50U3BlY2llc1IHc3BlY2llcxIoChBhaV9tb2RlbF92ZXJzaW9u'
    'GAIgASgJUg5haU1vZGVsVmVyc2lvbhIsChJwcm9jZXNzaW5nX3RpbWVfbXMYAyABKANSEHByb2'
    'Nlc3NpbmdUaW1lTXM=');

@$core.Deprecated('Use detectNutrientDeficiencyRequestDescriptor instead')
const DetectNutrientDeficiencyRequest$json = {
  '1': 'DetectNutrientDeficiencyRequest',
  '2': [
    {'1': 'plant_species_id', '3': 1, '4': 1, '5': 9, '10': 'plantSpeciesId'},
    {
      '1': 'images',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.ImageInput',
      '10': 'images'
    },
  ],
};

/// Descriptor for `DetectNutrientDeficiencyRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectNutrientDeficiencyRequestDescriptor =
    $convert.base64Decode(
        'Ch9EZXRlY3ROdXRyaWVudERlZmljaWVuY3lSZXF1ZXN0EigKEHBsYW50X3NwZWNpZXNfaWQYAS'
        'ABKAlSDnBsYW50U3BlY2llc0lkEjwKBmltYWdlcxgCIAMoCzIkLmFncmljdWx0dXJlLmRpYWdu'
        'b3Npcy52MS5JbWFnZUlucHV0UgZpbWFnZXM=');

@$core.Deprecated('Use detectNutrientDeficiencyResponseDescriptor instead')
const DetectNutrientDeficiencyResponse$json = {
  '1': 'DetectNutrientDeficiencyResponse',
  '2': [
    {
      '1': 'deficiencies',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.NutrientDeficiency',
      '10': 'deficiencies'
    },
    {'1': 'ai_model_version', '3': 2, '4': 1, '5': 9, '10': 'aiModelVersion'},
    {
      '1': 'processing_time_ms',
      '3': 3,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
  ],
};

/// Descriptor for `DetectNutrientDeficiencyResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectNutrientDeficiencyResponseDescriptor =
    $convert.base64Decode(
        'CiBEZXRlY3ROdXRyaWVudERlZmljaWVuY3lSZXNwb25zZRJQCgxkZWZpY2llbmNpZXMYASADKA'
        'syLC5hZ3JpY3VsdHVyZS5kaWFnbm9zaXMudjEuTnV0cmllbnREZWZpY2llbmN5UgxkZWZpY2ll'
        'bmNpZXMSKAoQYWlfbW9kZWxfdmVyc2lvbhgCIAEoCVIOYWlNb2RlbFZlcnNpb24SLAoScHJvY2'
        'Vzc2luZ190aW1lX21zGAMgASgDUhBwcm9jZXNzaW5nVGltZU1z');

@$core.Deprecated('Use detectPestDamageRequestDescriptor instead')
const DetectPestDamageRequest$json = {
  '1': 'DetectPestDamageRequest',
  '2': [
    {'1': 'plant_species_id', '3': 1, '4': 1, '5': 9, '10': 'plantSpeciesId'},
    {
      '1': 'images',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.ImageInput',
      '10': 'images'
    },
  ],
};

/// Descriptor for `DetectPestDamageRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectPestDamageRequestDescriptor = $convert.base64Decode(
    'ChdEZXRlY3RQZXN0RGFtYWdlUmVxdWVzdBIoChBwbGFudF9zcGVjaWVzX2lkGAEgASgJUg5wbG'
    'FudFNwZWNpZXNJZBI8CgZpbWFnZXMYAiADKAsyJC5hZ3JpY3VsdHVyZS5kaWFnbm9zaXMudjEu'
    'SW1hZ2VJbnB1dFIGaW1hZ2Vz');

@$core.Deprecated('Use detectPestDamageResponseDescriptor instead')
const DetectPestDamageResponse$json = {
  '1': 'DetectPestDamageResponse',
  '2': [
    {
      '1': 'pests',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.diagnosis.v1.PestDamage',
      '10': 'pests'
    },
    {'1': 'ai_model_version', '3': 2, '4': 1, '5': 9, '10': 'aiModelVersion'},
    {
      '1': 'processing_time_ms',
      '3': 3,
      '4': 1,
      '5': 3,
      '10': 'processingTimeMs'
    },
  ],
};

/// Descriptor for `DetectPestDamageResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List detectPestDamageResponseDescriptor = $convert.base64Decode(
    'ChhEZXRlY3RQZXN0RGFtYWdlUmVzcG9uc2USOgoFcGVzdHMYASADKAsyJC5hZ3JpY3VsdHVyZS'
    '5kaWFnbm9zaXMudjEuUGVzdERhbWFnZVIFcGVzdHMSKAoQYWlfbW9kZWxfdmVyc2lvbhgCIAEo'
    'CVIOYWlNb2RlbFZlcnNpb24SLAoScHJvY2Vzc2luZ190aW1lX21zGAMgASgDUhBwcm9jZXNzaW'
    '5nVGltZU1z');

const $core.Map<$core.String, $core.dynamic> PlantDiagnosisServiceBase$json = {
  '1': 'PlantDiagnosisService',
  '2': [
    {
      '1': 'SubmitDiagnosis',
      '2': '.agriculture.diagnosis.v1.SubmitDiagnosisRequest',
      '3': '.agriculture.diagnosis.v1.SubmitDiagnosisResponse'
    },
    {
      '1': 'GetDiagnosis',
      '2': '.agriculture.diagnosis.v1.GetDiagnosisRequest',
      '3': '.agriculture.diagnosis.v1.GetDiagnosisResponse'
    },
    {
      '1': 'ListDiagnoses',
      '2': '.agriculture.diagnosis.v1.ListDiagnosesRequest',
      '3': '.agriculture.diagnosis.v1.ListDiagnosesResponse'
    },
    {
      '1': 'GetDiseaseInfo',
      '2': '.agriculture.diagnosis.v1.GetDiseaseInfoRequest',
      '3': '.agriculture.diagnosis.v1.GetDiseaseInfoResponse'
    },
    {
      '1': 'GetTreatmentPlan',
      '2': '.agriculture.diagnosis.v1.GetTreatmentPlanRequest',
      '3': '.agriculture.diagnosis.v1.GetTreatmentPlanResponse'
    },
    {
      '1': 'ListDiseases',
      '2': '.agriculture.diagnosis.v1.ListDiseasesRequest',
      '3': '.agriculture.diagnosis.v1.ListDiseasesResponse'
    },
    {
      '1': 'IdentifySpecies',
      '2': '.agriculture.diagnosis.v1.IdentifySpeciesRequest',
      '3': '.agriculture.diagnosis.v1.IdentifySpeciesResponse'
    },
    {
      '1': 'DetectNutrientDeficiency',
      '2': '.agriculture.diagnosis.v1.DetectNutrientDeficiencyRequest',
      '3': '.agriculture.diagnosis.v1.DetectNutrientDeficiencyResponse'
    },
    {
      '1': 'DetectPestDamage',
      '2': '.agriculture.diagnosis.v1.DetectPestDamageRequest',
      '3': '.agriculture.diagnosis.v1.DetectPestDamageResponse'
    },
  ],
};

@$core.Deprecated('Use plantDiagnosisServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    PlantDiagnosisServiceBase$messageJson = {
  '.agriculture.diagnosis.v1.SubmitDiagnosisRequest':
      SubmitDiagnosisRequest$json,
  '.agriculture.diagnosis.v1.ImageInput': ImageInput$json,
  '.agriculture.diagnosis.v1.SubmitDiagnosisResponse':
      SubmitDiagnosisResponse$json,
  '.agriculture.diagnosis.v1.DiagnosisRequest': DiagnosisRequest$json,
  '.agriculture.diagnosis.v1.DiagnosisImage': DiagnosisImage$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.diagnosis.v1.DiagnosisResult': DiagnosisResult$json,
  '.agriculture.diagnosis.v1.PlantSpecies': PlantSpecies$json,
  '.agriculture.diagnosis.v1.DiseaseInfo': DiseaseInfo$json,
  '.agriculture.diagnosis.v1.NutrientDeficiency': NutrientDeficiency$json,
  '.agriculture.diagnosis.v1.PestDamage': PestDamage$json,
  '.agriculture.diagnosis.v1.GetDiagnosisRequest': GetDiagnosisRequest$json,
  '.agriculture.diagnosis.v1.GetDiagnosisResponse': GetDiagnosisResponse$json,
  '.agriculture.diagnosis.v1.ListDiagnosesRequest': ListDiagnosesRequest$json,
  '.agriculture.diagnosis.v1.ListDiagnosesResponse': ListDiagnosesResponse$json,
  '.agriculture.diagnosis.v1.GetDiseaseInfoRequest': GetDiseaseInfoRequest$json,
  '.agriculture.diagnosis.v1.GetDiseaseInfoResponse':
      GetDiseaseInfoResponse$json,
  '.agriculture.diagnosis.v1.GetTreatmentPlanRequest':
      GetTreatmentPlanRequest$json,
  '.agriculture.diagnosis.v1.GetTreatmentPlanResponse':
      GetTreatmentPlanResponse$json,
  '.agriculture.diagnosis.v1.TreatmentPlan': TreatmentPlan$json,
  '.agriculture.diagnosis.v1.TreatmentStep': TreatmentStep$json,
  '.agriculture.diagnosis.v1.ListDiseasesRequest': ListDiseasesRequest$json,
  '.agriculture.diagnosis.v1.ListDiseasesResponse': ListDiseasesResponse$json,
  '.agriculture.diagnosis.v1.IdentifySpeciesRequest':
      IdentifySpeciesRequest$json,
  '.agriculture.diagnosis.v1.IdentifySpeciesResponse':
      IdentifySpeciesResponse$json,
  '.agriculture.diagnosis.v1.DetectNutrientDeficiencyRequest':
      DetectNutrientDeficiencyRequest$json,
  '.agriculture.diagnosis.v1.DetectNutrientDeficiencyResponse':
      DetectNutrientDeficiencyResponse$json,
  '.agriculture.diagnosis.v1.DetectPestDamageRequest':
      DetectPestDamageRequest$json,
  '.agriculture.diagnosis.v1.DetectPestDamageResponse':
      DetectPestDamageResponse$json,
};

/// Descriptor for `PlantDiagnosisService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List plantDiagnosisServiceDescriptor = $convert.base64Decode(
    'ChVQbGFudERpYWdub3Npc1NlcnZpY2USdgoPU3VibWl0RGlhZ25vc2lzEjAuYWdyaWN1bHR1cm'
    'UuZGlhZ25vc2lzLnYxLlN1Ym1pdERpYWdub3Npc1JlcXVlc3QaMS5hZ3JpY3VsdHVyZS5kaWFn'
    'bm9zaXMudjEuU3VibWl0RGlhZ25vc2lzUmVzcG9uc2USbQoMR2V0RGlhZ25vc2lzEi0uYWdyaW'
    'N1bHR1cmUuZGlhZ25vc2lzLnYxLkdldERpYWdub3Npc1JlcXVlc3QaLi5hZ3JpY3VsdHVyZS5k'
    'aWFnbm9zaXMudjEuR2V0RGlhZ25vc2lzUmVzcG9uc2UScAoNTGlzdERpYWdub3NlcxIuLmFncm'
    'ljdWx0dXJlLmRpYWdub3Npcy52MS5MaXN0RGlhZ25vc2VzUmVxdWVzdBovLmFncmljdWx0dXJl'
    'LmRpYWdub3Npcy52MS5MaXN0RGlhZ25vc2VzUmVzcG9uc2UScwoOR2V0RGlzZWFzZUluZm8SLy'
    '5hZ3JpY3VsdHVyZS5kaWFnbm9zaXMudjEuR2V0RGlzZWFzZUluZm9SZXF1ZXN0GjAuYWdyaWN1'
    'bHR1cmUuZGlhZ25vc2lzLnYxLkdldERpc2Vhc2VJbmZvUmVzcG9uc2USeQoQR2V0VHJlYXRtZW'
    '50UGxhbhIxLmFncmljdWx0dXJlLmRpYWdub3Npcy52MS5HZXRUcmVhdG1lbnRQbGFuUmVxdWVz'
    'dBoyLmFncmljdWx0dXJlLmRpYWdub3Npcy52MS5HZXRUcmVhdG1lbnRQbGFuUmVzcG9uc2USbQ'
    'oMTGlzdERpc2Vhc2VzEi0uYWdyaWN1bHR1cmUuZGlhZ25vc2lzLnYxLkxpc3REaXNlYXNlc1Jl'
    'cXVlc3QaLi5hZ3JpY3VsdHVyZS5kaWFnbm9zaXMudjEuTGlzdERpc2Vhc2VzUmVzcG9uc2USdg'
    'oPSWRlbnRpZnlTcGVjaWVzEjAuYWdyaWN1bHR1cmUuZGlhZ25vc2lzLnYxLklkZW50aWZ5U3Bl'
    'Y2llc1JlcXVlc3QaMS5hZ3JpY3VsdHVyZS5kaWFnbm9zaXMudjEuSWRlbnRpZnlTcGVjaWVzUm'
    'VzcG9uc2USkQEKGERldGVjdE51dHJpZW50RGVmaWNpZW5jeRI5LmFncmljdWx0dXJlLmRpYWdu'
    'b3Npcy52MS5EZXRlY3ROdXRyaWVudERlZmljaWVuY3lSZXF1ZXN0GjouYWdyaWN1bHR1cmUuZG'
    'lhZ25vc2lzLnYxLkRldGVjdE51dHJpZW50RGVmaWNpZW5jeVJlc3BvbnNlEnkKEERldGVjdFBl'
    'c3REYW1hZ2USMS5hZ3JpY3VsdHVyZS5kaWFnbm9zaXMudjEuRGV0ZWN0UGVzdERhbWFnZVJlcX'
    'Vlc3QaMi5hZ3JpY3VsdHVyZS5kaWFnbm9zaXMudjEuRGV0ZWN0UGVzdERhbWFnZVJlc3BvbnNl');
