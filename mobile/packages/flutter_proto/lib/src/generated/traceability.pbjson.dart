// This is a generated file - do not edit.
//
// Generated from traceability.proto.

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

@$core.Deprecated('Use supplyChainEventTypeDescriptor instead')
const SupplyChainEventType$json = {
  '1': 'SupplyChainEventType',
  '2': [
    {'1': 'SUPPLY_CHAIN_EVENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'SUPPLY_CHAIN_EVENT_TYPE_PLANTED', '2': 1},
    {'1': 'SUPPLY_CHAIN_EVENT_TYPE_FERTILIZED', '2': 2},
    {'1': 'SUPPLY_CHAIN_EVENT_TYPE_IRRIGATED', '2': 3},
    {'1': 'SUPPLY_CHAIN_EVENT_TYPE_SPRAYED', '2': 4},
    {'1': 'SUPPLY_CHAIN_EVENT_TYPE_HARVESTED', '2': 5},
    {'1': 'SUPPLY_CHAIN_EVENT_TYPE_PROCESSED', '2': 6},
    {'1': 'SUPPLY_CHAIN_EVENT_TYPE_PACKAGED', '2': 7},
    {'1': 'SUPPLY_CHAIN_EVENT_TYPE_SHIPPED', '2': 8},
    {'1': 'SUPPLY_CHAIN_EVENT_TYPE_RECEIVED', '2': 9},
    {'1': 'SUPPLY_CHAIN_EVENT_TYPE_SOLD', '2': 10},
  ],
};

/// Descriptor for `SupplyChainEventType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List supplyChainEventTypeDescriptor = $convert.base64Decode(
    'ChRTdXBwbHlDaGFpbkV2ZW50VHlwZRInCiNTVVBQTFlfQ0hBSU5fRVZFTlRfVFlQRV9VTlNQRU'
    'NJRklFRBAAEiMKH1NVUFBMWV9DSEFJTl9FVkVOVF9UWVBFX1BMQU5URUQQARImCiJTVVBQTFlf'
    'Q0hBSU5fRVZFTlRfVFlQRV9GRVJUSUxJWkVEEAISJQohU1VQUExZX0NIQUlOX0VWRU5UX1RZUE'
    'VfSVJSSUdBVEVEEAMSIwofU1VQUExZX0NIQUlOX0VWRU5UX1RZUEVfU1BSQVlFRBAEEiUKIVNV'
    'UFBMWV9DSEFJTl9FVkVOVF9UWVBFX0hBUlZFU1RFRBAFEiUKIVNVUFBMWV9DSEFJTl9FVkVOVF'
    '9UWVBFX1BST0NFU1NFRBAGEiQKIFNVUFBMWV9DSEFJTl9FVkVOVF9UWVBFX1BBQ0tBR0VEEAcS'
    'IwofU1VQUExZX0NIQUlOX0VWRU5UX1RZUEVfU0hJUFBFRBAIEiQKIFNVUFBMWV9DSEFJTl9FVk'
    'VOVF9UWVBFX1JFQ0VJVkVEEAkSIAocU1VQUExZX0NIQUlOX0VWRU5UX1RZUEVfU09MRBAK');

@$core.Deprecated('Use certificationTypeDescriptor instead')
const CertificationType$json = {
  '1': 'CertificationType',
  '2': [
    {'1': 'CERTIFICATION_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'CERTIFICATION_TYPE_ORGANIC', '2': 1},
    {'1': 'CERTIFICATION_TYPE_GAP', '2': 2},
    {'1': 'CERTIFICATION_TYPE_FAIRTRADE', '2': 3},
    {'1': 'CERTIFICATION_TYPE_RAINFOREST_ALLIANCE', '2': 4},
    {'1': 'CERTIFICATION_TYPE_USDA_ORGANIC', '2': 5},
    {'1': 'CERTIFICATION_TYPE_EU_ORGANIC', '2': 6},
  ],
};

/// Descriptor for `CertificationType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List certificationTypeDescriptor = $convert.base64Decode(
    'ChFDZXJ0aWZpY2F0aW9uVHlwZRIiCh5DRVJUSUZJQ0FUSU9OX1RZUEVfVU5TUEVDSUZJRUQQAB'
    'IeChpDRVJUSUZJQ0FUSU9OX1RZUEVfT1JHQU5JQxABEhoKFkNFUlRJRklDQVRJT05fVFlQRV9H'
    'QVAQAhIgChxDRVJUSUZJQ0FUSU9OX1RZUEVfRkFJUlRSQURFEAMSKgomQ0VSVElGSUNBVElPTl'
    '9UWVBFX1JBSU5GT1JFU1RfQUxMSUFOQ0UQBBIjCh9DRVJUSUZJQ0FUSU9OX1RZUEVfVVNEQV9P'
    'UkdBTklDEAUSIQodQ0VSVElGSUNBVElPTl9UWVBFX0VVX09SR0FOSUMQBg==');

@$core.Deprecated('Use certificationStatusDescriptor instead')
const CertificationStatus$json = {
  '1': 'CertificationStatus',
  '2': [
    {'1': 'CERTIFICATION_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'CERTIFICATION_STATUS_ACTIVE', '2': 1},
    {'1': 'CERTIFICATION_STATUS_EXPIRED', '2': 2},
    {'1': 'CERTIFICATION_STATUS_REVOKED', '2': 3},
    {'1': 'CERTIFICATION_STATUS_PENDING', '2': 4},
  ],
};

/// Descriptor for `CertificationStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List certificationStatusDescriptor = $convert.base64Decode(
    'ChNDZXJ0aWZpY2F0aW9uU3RhdHVzEiQKIENFUlRJRklDQVRJT05fU1RBVFVTX1VOU1BFQ0lGSU'
    'VEEAASHwobQ0VSVElGSUNBVElPTl9TVEFUVVNfQUNUSVZFEAESIAocQ0VSVElGSUNBVElPTl9T'
    'VEFUVVNfRVhQSVJFRBACEiAKHENFUlRJRklDQVRJT05fU1RBVFVTX1JFVk9LRUQQAxIgChxDRV'
    'JUSUZJQ0FUSU9OX1NUQVRVU19QRU5ESU5HEAQ=');

@$core.Deprecated('Use complianceStatusDescriptor instead')
const ComplianceStatus$json = {
  '1': 'ComplianceStatus',
  '2': [
    {'1': 'COMPLIANCE_STATUS_UNSPECIFIED', '2': 0},
    {'1': 'COMPLIANCE_STATUS_COMPLIANT', '2': 1},
    {'1': 'COMPLIANCE_STATUS_NON_COMPLIANT', '2': 2},
    {'1': 'COMPLIANCE_STATUS_PENDING_REVIEW', '2': 3},
  ],
};

/// Descriptor for `ComplianceStatus`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List complianceStatusDescriptor = $convert.base64Decode(
    'ChBDb21wbGlhbmNlU3RhdHVzEiEKHUNPTVBMSUFOQ0VfU1RBVFVTX1VOU1BFQ0lGSUVEEAASHw'
    'obQ09NUExJQU5DRV9TVEFUVVNfQ09NUExJQU5UEAESIwofQ09NUExJQU5DRV9TVEFUVVNfTk9O'
    'X0NPTVBMSUFOVBACEiQKIENPTVBMSUFOQ0VfU1RBVFVTX1BFTkRJTkdfUkVWSUVXEAM=');

@$core.Deprecated('Use supplyChainEventDescriptor instead')
const SupplyChainEvent$json = {
  '1': 'SupplyChainEvent',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'record_id', '3': 2, '4': 1, '5': 9, '10': 'recordId'},
    {
      '1': 'event_type',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.traceability.v1.SupplyChainEventType',
      '10': 'eventType'
    },
    {
      '1': 'timestamp',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'location', '3': 5, '4': 1, '5': 9, '10': 'location'},
    {'1': 'actor', '3': 6, '4': 1, '5': 9, '10': 'actor'},
    {'1': 'details', '3': 7, '4': 1, '5': 9, '10': 'details'},
    {
      '1': 'verification_hash',
      '3': 8,
      '4': 1,
      '5': 9,
      '10': 'verificationHash'
    },
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

/// Descriptor for `SupplyChainEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplyChainEventDescriptor = $convert.base64Decode(
    'ChBTdXBwbHlDaGFpbkV2ZW50Eg4KAmlkGAEgASgJUgJpZBIbCglyZWNvcmRfaWQYAiABKAlSCH'
    'JlY29yZElkElAKCmV2ZW50X3R5cGUYAyABKA4yMS5hZ3JpY3VsdHVyZS50cmFjZWFiaWxpdHku'
    'djEuU3VwcGx5Q2hhaW5FdmVudFR5cGVSCWV2ZW50VHlwZRI4Cgl0aW1lc3RhbXAYBCABKAsyGi'
    '5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASGgoIbG9jYXRpb24YBSABKAlS'
    'CGxvY2F0aW9uEhQKBWFjdG9yGAYgASgJUgVhY3RvchIYCgdkZXRhaWxzGAcgASgJUgdkZXRhaW'
    'xzEisKEXZlcmlmaWNhdGlvbl9oYXNoGAggASgJUhB2ZXJpZmljYXRpb25IYXNoEjkKCmNyZWF0'
    'ZWRfYXQYCSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use certificationDescriptor instead')
const Certification$json = {
  '1': 'Certification',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'record_id', '3': 3, '4': 1, '5': 9, '10': 'recordId'},
    {
      '1': 'cert_type',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.traceability.v1.CertificationType',
      '10': 'certType'
    },
    {'1': 'cert_number', '3': 5, '4': 1, '5': 9, '10': 'certNumber'},
    {'1': 'issued_by', '3': 6, '4': 1, '5': 9, '10': 'issuedBy'},
    {
      '1': 'issued_date',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'issuedDate'
    },
    {
      '1': 'expiry_date',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiryDate'
    },
    {
      '1': 'status',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.agriculture.traceability.v1.CertificationStatus',
      '10': 'status'
    },
    {'1': 'verified_by', '3': 10, '4': 1, '5': 9, '10': 'verifiedBy'},
    {
      '1': 'verified_at',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'verifiedAt'
    },
    {
      '1': 'metadata',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.agriculture.traceability.v1.Certification.MetadataEntry',
      '10': 'metadata'
    },
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
    {'1': 'version', '3': 15, '4': 1, '5': 3, '10': 'version'},
  ],
  '3': [Certification_MetadataEntry$json],
};

@$core.Deprecated('Use certificationDescriptor instead')
const Certification_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `Certification`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List certificationDescriptor = $convert.base64Decode(
    'Cg1DZXJ0aWZpY2F0aW9uEg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCHRlbm'
    'FudElkEhsKCXJlY29yZF9pZBgDIAEoCVIIcmVjb3JkSWQSSwoJY2VydF90eXBlGAQgASgOMi4u'
    'YWdyaWN1bHR1cmUudHJhY2VhYmlsaXR5LnYxLkNlcnRpZmljYXRpb25UeXBlUghjZXJ0VHlwZR'
    'IfCgtjZXJ0X251bWJlchgFIAEoCVIKY2VydE51bWJlchIbCglpc3N1ZWRfYnkYBiABKAlSCGlz'
    'c3VlZEJ5EjsKC2lzc3VlZF9kYXRlGAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcF'
    'IKaXNzdWVkRGF0ZRI7CgtleHBpcnlfZGF0ZRgIIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1l'
    'c3RhbXBSCmV4cGlyeURhdGUSSAoGc3RhdHVzGAkgASgOMjAuYWdyaWN1bHR1cmUudHJhY2VhYm'
    'lsaXR5LnYxLkNlcnRpZmljYXRpb25TdGF0dXNSBnN0YXR1cxIfCgt2ZXJpZmllZF9ieRgKIAEo'
    'CVIKdmVyaWZpZWRCeRI7Cgt2ZXJpZmllZF9hdBgLIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW'
    '1lc3RhbXBSCnZlcmlmaWVkQXQSVAoIbWV0YWRhdGEYDCADKAsyOC5hZ3JpY3VsdHVyZS50cmFj'
    'ZWFiaWxpdHkudjEuQ2VydGlmaWNhdGlvbi5NZXRhZGF0YUVudHJ5UghtZXRhZGF0YRI5Cgpjcm'
    'VhdGVkX2F0GA0gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIJY3JlYXRlZEF0EjkK'
    'CnVwZGF0ZWRfYXQYDiABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgl1cGRhdGVkQX'
    'QSGAoHdmVyc2lvbhgPIAEoA1IHdmVyc2lvbho7Cg1NZXRhZGF0YUVudHJ5EhAKA2tleRgBIAEo'
    'CVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use batchRecordDescriptor instead')
const BatchRecord$json = {
  '1': 'BatchRecord',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'record_id', '3': 3, '4': 1, '5': 9, '10': 'recordId'},
    {'1': 'batch_number', '3': 4, '4': 1, '5': 9, '10': 'batchNumber'},
    {'1': 'quantity', '3': 5, '4': 1, '5': 5, '10': 'quantity'},
    {'1': 'unit', '3': 6, '4': 1, '5': 9, '10': 'unit'},
    {
      '1': 'production_date',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'productionDate'
    },
    {
      '1': 'expiry_date',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiryDate'
    },
    {
      '1': 'storage_conditions',
      '3': 9,
      '4': 1,
      '5': 9,
      '10': 'storageConditions'
    },
    {'1': 'quality_grade', '3': 10, '4': 1, '5': 9, '10': 'qualityGrade'},
    {
      '1': 'metadata',
      '3': 11,
      '4': 3,
      '5': 11,
      '6': '.agriculture.traceability.v1.BatchRecord.MetadataEntry',
      '10': 'metadata'
    },
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
    {'1': 'version', '3': 14, '4': 1, '5': 3, '10': 'version'},
  ],
  '3': [BatchRecord_MetadataEntry$json],
};

@$core.Deprecated('Use batchRecordDescriptor instead')
const BatchRecord_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `BatchRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List batchRecordDescriptor = $convert.base64Decode(
    'CgtCYXRjaFJlY29yZBIOCgJpZBgBIAEoCVICaWQSGwoJdGVuYW50X2lkGAIgASgJUgh0ZW5hbn'
    'RJZBIbCglyZWNvcmRfaWQYAyABKAlSCHJlY29yZElkEiEKDGJhdGNoX251bWJlchgEIAEoCVIL'
    'YmF0Y2hOdW1iZXISGgoIcXVhbnRpdHkYBSABKAVSCHF1YW50aXR5EhIKBHVuaXQYBiABKAlSBH'
    'VuaXQSQwoPcHJvZHVjdGlvbl9kYXRlGAcgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFt'
    'cFIOcHJvZHVjdGlvbkRhdGUSOwoLZXhwaXJ5X2RhdGUYCCABKAsyGi5nb29nbGUucHJvdG9idW'
    'YuVGltZXN0YW1wUgpleHBpcnlEYXRlEi0KEnN0b3JhZ2VfY29uZGl0aW9ucxgJIAEoCVIRc3Rv'
    'cmFnZUNvbmRpdGlvbnMSIwoNcXVhbGl0eV9ncmFkZRgKIAEoCVIMcXVhbGl0eUdyYWRlElIKCG'
    '1ldGFkYXRhGAsgAygLMjYuYWdyaWN1bHR1cmUudHJhY2VhYmlsaXR5LnYxLkJhdGNoUmVjb3Jk'
    'Lk1ldGFkYXRhRW50cnlSCG1ldGFkYXRhEjkKCmNyZWF0ZWRfYXQYDCABKAsyGi5nb29nbGUucH'
    'JvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRlZF9hdBgNIAEoCzIaLmdvb2ds'
    'ZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdBIYCgd2ZXJzaW9uGA4gASgDUgd2ZXJzaW'
    '9uGjsKDU1ldGFkYXRhRW50cnkSEAoDa2V5GAEgASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZh'
    'bHVlOgI4AQ==');

@$core.Deprecated('Use qRCodeDescriptor instead')
const QRCode$json = {
  '1': 'QRCode',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'record_id', '3': 2, '4': 1, '5': 9, '10': 'recordId'},
    {'1': 'batch_id', '3': 3, '4': 1, '5': 9, '10': 'batchId'},
    {'1': 'qr_data', '3': 4, '4': 1, '5': 9, '10': 'qrData'},
    {'1': 'qr_image_url', '3': 5, '4': 1, '5': 9, '10': 'qrImageUrl'},
    {'1': 'scan_url', '3': 6, '4': 1, '5': 9, '10': 'scanUrl'},
    {
      '1': 'generated_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'generatedAt'
    },
    {
      '1': 'expires_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiresAt'
    },
    {'1': 'is_active', '3': 9, '4': 1, '5': 8, '10': 'isActive'},
  ],
};

/// Descriptor for `QRCode`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List qRCodeDescriptor = $convert.base64Decode(
    'CgZRUkNvZGUSDgoCaWQYASABKAlSAmlkEhsKCXJlY29yZF9pZBgCIAEoCVIIcmVjb3JkSWQSGQ'
    'oIYmF0Y2hfaWQYAyABKAlSB2JhdGNoSWQSFwoHcXJfZGF0YRgEIAEoCVIGcXJEYXRhEiAKDHFy'
    'X2ltYWdlX3VybBgFIAEoCVIKcXJJbWFnZVVybBIZCghzY2FuX3VybBgGIAEoCVIHc2NhblVybB'
    'I9CgxnZW5lcmF0ZWRfYXQYByABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgtnZW5l'
    'cmF0ZWRBdBI5CgpleHBpcmVzX2F0GAggASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcF'
    'IJZXhwaXJlc0F0EhsKCWlzX2FjdGl2ZRgJIAEoCFIIaXNBY3RpdmU=');

@$core.Deprecated('Use complianceReportDescriptor instead')
const ComplianceReport$json = {
  '1': 'ComplianceReport',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'record_id', '3': 3, '4': 1, '5': 9, '10': 'recordId'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.traceability.v1.ComplianceStatus',
      '10': 'status'
    },
    {'1': 'report_type', '3': 5, '4': 1, '5': 9, '10': 'reportType'},
    {'1': 'findings', '3': 6, '4': 3, '5': 9, '10': 'findings'},
    {'1': 'recommendations', '3': 7, '4': 3, '5': 9, '10': 'recommendations'},
    {'1': 'auditor', '3': 8, '4': 1, '5': 9, '10': 'auditor'},
    {
      '1': 'audit_date',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'auditDate'
    },
    {
      '1': 'next_audit_date',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'nextAuditDate'
    },
    {'1': 'compliance_score', '3': 11, '4': 1, '5': 1, '10': 'complianceScore'},
    {
      '1': 'metadata',
      '3': 12,
      '4': 3,
      '5': 11,
      '6': '.agriculture.traceability.v1.ComplianceReport.MetadataEntry',
      '10': 'metadata'
    },
    {
      '1': 'created_at',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
  ],
  '3': [ComplianceReport_MetadataEntry$json],
};

@$core.Deprecated('Use complianceReportDescriptor instead')
const ComplianceReport_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `ComplianceReport`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List complianceReportDescriptor = $convert.base64Decode(
    'ChBDb21wbGlhbmNlUmVwb3J0Eg4KAmlkGAEgASgJUgJpZBIbCgl0ZW5hbnRfaWQYAiABKAlSCH'
    'RlbmFudElkEhsKCXJlY29yZF9pZBgDIAEoCVIIcmVjb3JkSWQSRQoGc3RhdHVzGAQgASgOMi0u'
    'YWdyaWN1bHR1cmUudHJhY2VhYmlsaXR5LnYxLkNvbXBsaWFuY2VTdGF0dXNSBnN0YXR1cxIfCg'
    'tyZXBvcnRfdHlwZRgFIAEoCVIKcmVwb3J0VHlwZRIaCghmaW5kaW5ncxgGIAMoCVIIZmluZGlu'
    'Z3MSKAoPcmVjb21tZW5kYXRpb25zGAcgAygJUg9yZWNvbW1lbmRhdGlvbnMSGAoHYXVkaXRvch'
    'gIIAEoCVIHYXVkaXRvchI5CgphdWRpdF9kYXRlGAkgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRp'
    'bWVzdGFtcFIJYXVkaXREYXRlEkIKD25leHRfYXVkaXRfZGF0ZRgKIAEoCzIaLmdvb2dsZS5wcm'
    '90b2J1Zi5UaW1lc3RhbXBSDW5leHRBdWRpdERhdGUSKQoQY29tcGxpYW5jZV9zY29yZRgLIAEo'
    'AVIPY29tcGxpYW5jZVNjb3JlElcKCG1ldGFkYXRhGAwgAygLMjsuYWdyaWN1bHR1cmUudHJhY2'
    'VhYmlsaXR5LnYxLkNvbXBsaWFuY2VSZXBvcnQuTWV0YWRhdGFFbnRyeVIIbWV0YWRhdGESOQoK'
    'Y3JlYXRlZF9hdBgNIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCWNyZWF0ZWRBdB'
    'o7Cg1NZXRhZGF0YUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1'
    'ZToCOAE=');

@$core.Deprecated('Use traceabilityRecordDescriptor instead')
const TraceabilityRecord$json = {
  '1': 'TraceabilityRecord',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'tenant_id', '3': 2, '4': 1, '5': 9, '10': 'tenantId'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 4, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 5, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'batch_number', '3': 6, '4': 1, '5': 9, '10': 'batchNumber'},
    {'1': 'product_type', '3': 7, '4': 1, '5': 9, '10': 'productType'},
    {'1': 'origin_country', '3': 8, '4': 1, '5': 9, '10': 'originCountry'},
    {'1': 'origin_region', '3': 9, '4': 1, '5': 9, '10': 'originRegion'},
    {'1': 'seed_source', '3': 10, '4': 1, '5': 9, '10': 'seedSource'},
    {
      '1': 'planting_date',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'plantingDate'
    },
    {
      '1': 'harvest_date',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'harvestDate'
    },
    {
      '1': 'processing_date',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'processingDate'
    },
    {
      '1': 'packaging_date',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'packagingDate'
    },
    {
      '1': 'supply_chain_events',
      '3': 15,
      '4': 3,
      '5': 11,
      '6': '.agriculture.traceability.v1.SupplyChainEvent',
      '10': 'supplyChainEvents'
    },
    {
      '1': 'certifications',
      '3': 16,
      '4': 3,
      '5': 11,
      '6': '.agriculture.traceability.v1.Certification',
      '10': 'certifications'
    },
    {'1': 'qr_code_data', '3': 17, '4': 1, '5': 9, '10': 'qrCodeData'},
    {'1': 'blockchain_hash', '3': 18, '4': 1, '5': 9, '10': 'blockchainHash'},
    {'1': 'chain_of_custody', '3': 19, '4': 3, '5': 9, '10': 'chainOfCustody'},
    {
      '1': 'compliance_status',
      '3': 20,
      '4': 1,
      '5': 14,
      '6': '.agriculture.traceability.v1.ComplianceStatus',
      '10': 'complianceStatus'
    },
    {
      '1': 'metadata',
      '3': 21,
      '4': 3,
      '5': 11,
      '6': '.agriculture.traceability.v1.TraceabilityRecord.MetadataEntry',
      '10': 'metadata'
    },
    {'1': 'version', '3': 22, '4': 1, '5': 3, '10': 'version'},
    {'1': 'created_by', '3': 23, '4': 1, '5': 9, '10': 'createdBy'},
    {'1': 'updated_by', '3': 24, '4': 1, '5': 9, '10': 'updatedBy'},
    {
      '1': 'created_at',
      '3': 25,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'updated_at',
      '3': 26,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'updatedAt'
    },
  ],
  '3': [TraceabilityRecord_MetadataEntry$json],
};

@$core.Deprecated('Use traceabilityRecordDescriptor instead')
const TraceabilityRecord_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `TraceabilityRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List traceabilityRecordDescriptor = $convert.base64Decode(
    'ChJUcmFjZWFiaWxpdHlSZWNvcmQSDgoCaWQYASABKAlSAmlkEhsKCXRlbmFudF9pZBgCIAEoCV'
    'IIdGVuYW50SWQSFwoHZmFybV9pZBgDIAEoCVIGZmFybUlkEhkKCGZpZWxkX2lkGAQgASgJUgdm'
    'aWVsZElkEhcKB2Nyb3BfaWQYBSABKAlSBmNyb3BJZBIhCgxiYXRjaF9udW1iZXIYBiABKAlSC2'
    'JhdGNoTnVtYmVyEiEKDHByb2R1Y3RfdHlwZRgHIAEoCVILcHJvZHVjdFR5cGUSJQoOb3JpZ2lu'
    'X2NvdW50cnkYCCABKAlSDW9yaWdpbkNvdW50cnkSIwoNb3JpZ2luX3JlZ2lvbhgJIAEoCVIMb3'
    'JpZ2luUmVnaW9uEh8KC3NlZWRfc291cmNlGAogASgJUgpzZWVkU291cmNlEj8KDXBsYW50aW5n'
    'X2RhdGUYCyABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgxwbGFudGluZ0RhdGUSPQ'
    'oMaGFydmVzdF9kYXRlGAwgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFILaGFydmVz'
    'dERhdGUSQwoPcHJvY2Vzc2luZ19kYXRlGA0gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdG'
    'FtcFIOcHJvY2Vzc2luZ0RhdGUSQQoOcGFja2FnaW5nX2RhdGUYDiABKAsyGi5nb29nbGUucHJv'
    'dG9idWYuVGltZXN0YW1wUg1wYWNrYWdpbmdEYXRlEl0KE3N1cHBseV9jaGFpbl9ldmVudHMYDy'
    'ADKAsyLS5hZ3JpY3VsdHVyZS50cmFjZWFiaWxpdHkudjEuU3VwcGx5Q2hhaW5FdmVudFIRc3Vw'
    'cGx5Q2hhaW5FdmVudHMSUgoOY2VydGlmaWNhdGlvbnMYECADKAsyKi5hZ3JpY3VsdHVyZS50cm'
    'FjZWFiaWxpdHkudjEuQ2VydGlmaWNhdGlvblIOY2VydGlmaWNhdGlvbnMSIAoMcXJfY29kZV9k'
    'YXRhGBEgASgJUgpxckNvZGVEYXRhEicKD2Jsb2NrY2hhaW5faGFzaBgSIAEoCVIOYmxvY2tjaG'
    'Fpbkhhc2gSKAoQY2hhaW5fb2ZfY3VzdG9keRgTIAMoCVIOY2hhaW5PZkN1c3RvZHkSWgoRY29t'
    'cGxpYW5jZV9zdGF0dXMYFCABKA4yLS5hZ3JpY3VsdHVyZS50cmFjZWFiaWxpdHkudjEuQ29tcG'
    'xpYW5jZVN0YXR1c1IQY29tcGxpYW5jZVN0YXR1cxJZCghtZXRhZGF0YRgVIAMoCzI9LmFncmlj'
    'dWx0dXJlLnRyYWNlYWJpbGl0eS52MS5UcmFjZWFiaWxpdHlSZWNvcmQuTWV0YWRhdGFFbnRyeV'
    'IIbWV0YWRhdGESGAoHdmVyc2lvbhgWIAEoA1IHdmVyc2lvbhIdCgpjcmVhdGVkX2J5GBcgASgJ'
    'UgljcmVhdGVkQnkSHQoKdXBkYXRlZF9ieRgYIAEoCVIJdXBkYXRlZEJ5EjkKCmNyZWF0ZWRfYX'
    'QYGSABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQSOQoKdXBkYXRl'
    'ZF9hdBgaIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCXVwZGF0ZWRBdBo7Cg1NZX'
    'RhZGF0YUVudHJ5EhAKA2tleRgBIAEoCVIDa2V5EhQKBXZhbHVlGAIgASgJUgV2YWx1ZToCOAE=');

@$core.Deprecated('Use createRecordRequestDescriptor instead')
const CreateRecordRequest$json = {
  '1': 'CreateRecordRequest',
  '2': [
    {'1': 'farm_id', '3': 1, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'field_id', '3': 2, '4': 1, '5': 9, '10': 'fieldId'},
    {'1': 'crop_id', '3': 3, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'batch_number', '3': 4, '4': 1, '5': 9, '10': 'batchNumber'},
    {'1': 'product_type', '3': 5, '4': 1, '5': 9, '10': 'productType'},
    {'1': 'origin_country', '3': 6, '4': 1, '5': 9, '10': 'originCountry'},
    {'1': 'origin_region', '3': 7, '4': 1, '5': 9, '10': 'originRegion'},
    {'1': 'seed_source', '3': 8, '4': 1, '5': 9, '10': 'seedSource'},
    {
      '1': 'planting_date',
      '3': 9,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'plantingDate'
    },
    {
      '1': 'harvest_date',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'harvestDate'
    },
    {
      '1': 'processing_date',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'processingDate'
    },
    {
      '1': 'packaging_date',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'packagingDate'
    },
    {
      '1': 'metadata',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.agriculture.traceability.v1.CreateRecordRequest.MetadataEntry',
      '10': 'metadata'
    },
  ],
  '3': [CreateRecordRequest_MetadataEntry$json],
};

@$core.Deprecated('Use createRecordRequestDescriptor instead')
const CreateRecordRequest_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CreateRecordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createRecordRequestDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVSZWNvcmRSZXF1ZXN0EhcKB2Zhcm1faWQYASABKAlSBmZhcm1JZBIZCghmaWVsZF'
    '9pZBgCIAEoCVIHZmllbGRJZBIXCgdjcm9wX2lkGAMgASgJUgZjcm9wSWQSIQoMYmF0Y2hfbnVt'
    'YmVyGAQgASgJUgtiYXRjaE51bWJlchIhCgxwcm9kdWN0X3R5cGUYBSABKAlSC3Byb2R1Y3RUeX'
    'BlEiUKDm9yaWdpbl9jb3VudHJ5GAYgASgJUg1vcmlnaW5Db3VudHJ5EiMKDW9yaWdpbl9yZWdp'
    'b24YByABKAlSDG9yaWdpblJlZ2lvbhIfCgtzZWVkX3NvdXJjZRgIIAEoCVIKc2VlZFNvdXJjZR'
    'I/Cg1wbGFudGluZ19kYXRlGAkgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIMcGxh'
    'bnRpbmdEYXRlEj0KDGhhcnZlc3RfZGF0ZRgKIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3'
    'RhbXBSC2hhcnZlc3REYXRlEkMKD3Byb2Nlc3NpbmdfZGF0ZRgLIAEoCzIaLmdvb2dsZS5wcm90'
    'b2J1Zi5UaW1lc3RhbXBSDnByb2Nlc3NpbmdEYXRlEkEKDnBhY2thZ2luZ19kYXRlGAwgASgLMh'
    'ouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFINcGFja2FnaW5nRGF0ZRJaCghtZXRhZGF0YRgN'
    'IAMoCzI+LmFncmljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS5DcmVhdGVSZWNvcmRSZXF1ZXN0Lk'
    '1ldGFkYXRhRW50cnlSCG1ldGFkYXRhGjsKDU1ldGFkYXRhRW50cnkSEAoDa2V5GAEgASgJUgNr'
    'ZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use createRecordResponseDescriptor instead')
const CreateRecordResponse$json = {
  '1': 'CreateRecordResponse',
  '2': [
    {
      '1': 'record',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.traceability.v1.TraceabilityRecord',
      '10': 'record'
    },
  ],
};

/// Descriptor for `CreateRecordResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createRecordResponseDescriptor = $convert.base64Decode(
    'ChRDcmVhdGVSZWNvcmRSZXNwb25zZRJHCgZyZWNvcmQYASABKAsyLy5hZ3JpY3VsdHVyZS50cm'
    'FjZWFiaWxpdHkudjEuVHJhY2VhYmlsaXR5UmVjb3JkUgZyZWNvcmQ=');

@$core.Deprecated('Use getRecordRequestDescriptor instead')
const GetRecordRequest$json = {
  '1': 'GetRecordRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetRecordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRecordRequestDescriptor =
    $convert.base64Decode('ChBHZXRSZWNvcmRSZXF1ZXN0Eg4KAmlkGAEgASgJUgJpZA==');

@$core.Deprecated('Use getRecordResponseDescriptor instead')
const GetRecordResponse$json = {
  '1': 'GetRecordResponse',
  '2': [
    {
      '1': 'record',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.traceability.v1.TraceabilityRecord',
      '10': 'record'
    },
  ],
};

/// Descriptor for `GetRecordResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getRecordResponseDescriptor = $convert.base64Decode(
    'ChFHZXRSZWNvcmRSZXNwb25zZRJHCgZyZWNvcmQYASABKAsyLy5hZ3JpY3VsdHVyZS50cmFjZW'
    'FiaWxpdHkudjEuVHJhY2VhYmlsaXR5UmVjb3JkUgZyZWNvcmQ=');

@$core.Deprecated('Use listRecordsRequestDescriptor instead')
const ListRecordsRequest$json = {
  '1': 'ListRecordsRequest',
  '2': [
    {'1': 'page_size', '3': 1, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 2, '4': 1, '5': 9, '10': 'pageToken'},
    {'1': 'farm_id', '3': 3, '4': 1, '5': 9, '10': 'farmId'},
    {'1': 'crop_id', '3': 4, '4': 1, '5': 9, '10': 'cropId'},
    {'1': 'product_type', '3': 5, '4': 1, '5': 9, '10': 'productType'},
    {'1': 'origin_country', '3': 6, '4': 1, '5': 9, '10': 'originCountry'},
    {
      '1': 'compliance_status',
      '3': 7,
      '4': 1,
      '5': 14,
      '6': '.agriculture.traceability.v1.ComplianceStatus',
      '10': 'complianceStatus'
    },
    {'1': 'search', '3': 8, '4': 1, '5': 9, '10': 'search'},
    {'1': 'order_by', '3': 9, '4': 1, '5': 9, '10': 'orderBy'},
  ],
};

/// Descriptor for `ListRecordsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRecordsRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0UmVjb3Jkc1JlcXVlc3QSGwoJcGFnZV9zaXplGAEgASgFUghwYWdlU2l6ZRIdCgpwYW'
    'dlX3Rva2VuGAIgASgJUglwYWdlVG9rZW4SFwoHZmFybV9pZBgDIAEoCVIGZmFybUlkEhcKB2Ny'
    'b3BfaWQYBCABKAlSBmNyb3BJZBIhCgxwcm9kdWN0X3R5cGUYBSABKAlSC3Byb2R1Y3RUeXBlEi'
    'UKDm9yaWdpbl9jb3VudHJ5GAYgASgJUg1vcmlnaW5Db3VudHJ5EloKEWNvbXBsaWFuY2Vfc3Rh'
    'dHVzGAcgASgOMi0uYWdyaWN1bHR1cmUudHJhY2VhYmlsaXR5LnYxLkNvbXBsaWFuY2VTdGF0dX'
    'NSEGNvbXBsaWFuY2VTdGF0dXMSFgoGc2VhcmNoGAggASgJUgZzZWFyY2gSGQoIb3JkZXJfYnkY'
    'CSABKAlSB29yZGVyQnk=');

@$core.Deprecated('Use listRecordsResponseDescriptor instead')
const ListRecordsResponse$json = {
  '1': 'ListRecordsResponse',
  '2': [
    {
      '1': 'records',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.traceability.v1.TraceabilityRecord',
      '10': 'records'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListRecordsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listRecordsResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0UmVjb3Jkc1Jlc3BvbnNlEkkKB3JlY29yZHMYASADKAsyLy5hZ3JpY3VsdHVyZS50cm'
    'FjZWFiaWxpdHkudjEuVHJhY2VhYmlsaXR5UmVjb3JkUgdyZWNvcmRzEiYKD25leHRfcGFnZV90'
    'b2tlbhgCIAEoCVINbmV4dFBhZ2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3'
    'VudA==');

@$core.Deprecated('Use addSupplyChainEventRequestDescriptor instead')
const AddSupplyChainEventRequest$json = {
  '1': 'AddSupplyChainEventRequest',
  '2': [
    {'1': 'record_id', '3': 1, '4': 1, '5': 9, '10': 'recordId'},
    {
      '1': 'event_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.traceability.v1.SupplyChainEventType',
      '10': 'eventType'
    },
    {
      '1': 'timestamp',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'timestamp'
    },
    {'1': 'location', '3': 4, '4': 1, '5': 9, '10': 'location'},
    {'1': 'actor', '3': 5, '4': 1, '5': 9, '10': 'actor'},
    {'1': 'details', '3': 6, '4': 1, '5': 9, '10': 'details'},
  ],
};

/// Descriptor for `AddSupplyChainEventRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addSupplyChainEventRequestDescriptor = $convert.base64Decode(
    'ChpBZGRTdXBwbHlDaGFpbkV2ZW50UmVxdWVzdBIbCglyZWNvcmRfaWQYASABKAlSCHJlY29yZE'
    'lkElAKCmV2ZW50X3R5cGUYAiABKA4yMS5hZ3JpY3VsdHVyZS50cmFjZWFiaWxpdHkudjEuU3Vw'
    'cGx5Q2hhaW5FdmVudFR5cGVSCWV2ZW50VHlwZRI4Cgl0aW1lc3RhbXAYAyABKAsyGi5nb29nbG'
    'UucHJvdG9idWYuVGltZXN0YW1wUgl0aW1lc3RhbXASGgoIbG9jYXRpb24YBCABKAlSCGxvY2F0'
    'aW9uEhQKBWFjdG9yGAUgASgJUgVhY3RvchIYCgdkZXRhaWxzGAYgASgJUgdkZXRhaWxz');

@$core.Deprecated('Use addSupplyChainEventResponseDescriptor instead')
const AddSupplyChainEventResponse$json = {
  '1': 'AddSupplyChainEventResponse',
  '2': [
    {
      '1': 'event',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.traceability.v1.SupplyChainEvent',
      '10': 'event'
    },
  ],
};

/// Descriptor for `AddSupplyChainEventResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addSupplyChainEventResponseDescriptor =
    $convert.base64Decode(
        'ChtBZGRTdXBwbHlDaGFpbkV2ZW50UmVzcG9uc2USQwoFZXZlbnQYASABKAsyLS5hZ3JpY3VsdH'
        'VyZS50cmFjZWFiaWxpdHkudjEuU3VwcGx5Q2hhaW5FdmVudFIFZXZlbnQ=');

@$core.Deprecated('Use getSupplyChainRequestDescriptor instead')
const GetSupplyChainRequest$json = {
  '1': 'GetSupplyChainRequest',
  '2': [
    {'1': 'record_id', '3': 1, '4': 1, '5': 9, '10': 'recordId'},
  ],
};

/// Descriptor for `GetSupplyChainRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSupplyChainRequestDescriptor = $convert.base64Decode(
    'ChVHZXRTdXBwbHlDaGFpblJlcXVlc3QSGwoJcmVjb3JkX2lkGAEgASgJUghyZWNvcmRJZA==');

@$core.Deprecated('Use getSupplyChainResponseDescriptor instead')
const GetSupplyChainResponse$json = {
  '1': 'GetSupplyChainResponse',
  '2': [
    {
      '1': 'events',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.traceability.v1.SupplyChainEvent',
      '10': 'events'
    },
  ],
};

/// Descriptor for `GetSupplyChainResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSupplyChainResponseDescriptor =
    $convert.base64Decode(
        'ChZHZXRTdXBwbHlDaGFpblJlc3BvbnNlEkUKBmV2ZW50cxgBIAMoCzItLmFncmljdWx0dXJlLn'
        'RyYWNlYWJpbGl0eS52MS5TdXBwbHlDaGFpbkV2ZW50UgZldmVudHM=');

@$core.Deprecated('Use createCertificationRequestDescriptor instead')
const CreateCertificationRequest$json = {
  '1': 'CreateCertificationRequest',
  '2': [
    {'1': 'record_id', '3': 1, '4': 1, '5': 9, '10': 'recordId'},
    {
      '1': 'cert_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.traceability.v1.CertificationType',
      '10': 'certType'
    },
    {'1': 'cert_number', '3': 3, '4': 1, '5': 9, '10': 'certNumber'},
    {'1': 'issued_by', '3': 4, '4': 1, '5': 9, '10': 'issuedBy'},
    {
      '1': 'issued_date',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'issuedDate'
    },
    {
      '1': 'expiry_date',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiryDate'
    },
    {
      '1': 'metadata',
      '3': 7,
      '4': 3,
      '5': 11,
      '6':
          '.agriculture.traceability.v1.CreateCertificationRequest.MetadataEntry',
      '10': 'metadata'
    },
  ],
  '3': [CreateCertificationRequest_MetadataEntry$json],
};

@$core.Deprecated('Use createCertificationRequestDescriptor instead')
const CreateCertificationRequest_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CreateCertificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCertificationRequestDescriptor = $convert.base64Decode(
    'ChpDcmVhdGVDZXJ0aWZpY2F0aW9uUmVxdWVzdBIbCglyZWNvcmRfaWQYASABKAlSCHJlY29yZE'
    'lkEksKCWNlcnRfdHlwZRgCIAEoDjIuLmFncmljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS5DZXJ0'
    'aWZpY2F0aW9uVHlwZVIIY2VydFR5cGUSHwoLY2VydF9udW1iZXIYAyABKAlSCmNlcnROdW1iZX'
    'ISGwoJaXNzdWVkX2J5GAQgASgJUghpc3N1ZWRCeRI7Cgtpc3N1ZWRfZGF0ZRgFIAEoCzIaLmdv'
    'b2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCmlzc3VlZERhdGUSOwoLZXhwaXJ5X2RhdGUYBiABKA'
    'syGi5nb29nbGUucHJvdG9idWYuVGltZXN0YW1wUgpleHBpcnlEYXRlEmEKCG1ldGFkYXRhGAcg'
    'AygLMkUuYWdyaWN1bHR1cmUudHJhY2VhYmlsaXR5LnYxLkNyZWF0ZUNlcnRpZmljYXRpb25SZX'
    'F1ZXN0Lk1ldGFkYXRhRW50cnlSCG1ldGFkYXRhGjsKDU1ldGFkYXRhRW50cnkSEAoDa2V5GAEg'
    'ASgJUgNrZXkSFAoFdmFsdWUYAiABKAlSBXZhbHVlOgI4AQ==');

@$core.Deprecated('Use createCertificationResponseDescriptor instead')
const CreateCertificationResponse$json = {
  '1': 'CreateCertificationResponse',
  '2': [
    {
      '1': 'certification',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.traceability.v1.Certification',
      '10': 'certification'
    },
  ],
};

/// Descriptor for `CreateCertificationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createCertificationResponseDescriptor =
    $convert.base64Decode(
        'ChtDcmVhdGVDZXJ0aWZpY2F0aW9uUmVzcG9uc2USUAoNY2VydGlmaWNhdGlvbhgBIAEoCzIqLm'
        'FncmljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS5DZXJ0aWZpY2F0aW9uUg1jZXJ0aWZpY2F0aW9u');

@$core.Deprecated('Use getCertificationRequestDescriptor instead')
const GetCertificationRequest$json = {
  '1': 'GetCertificationRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetCertificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCertificationRequestDescriptor = $convert
    .base64Decode('ChdHZXRDZXJ0aWZpY2F0aW9uUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use getCertificationResponseDescriptor instead')
const GetCertificationResponse$json = {
  '1': 'GetCertificationResponse',
  '2': [
    {
      '1': 'certification',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.traceability.v1.Certification',
      '10': 'certification'
    },
  ],
};

/// Descriptor for `GetCertificationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getCertificationResponseDescriptor =
    $convert.base64Decode(
        'ChhHZXRDZXJ0aWZpY2F0aW9uUmVzcG9uc2USUAoNY2VydGlmaWNhdGlvbhgBIAEoCzIqLmFncm'
        'ljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS5DZXJ0aWZpY2F0aW9uUg1jZXJ0aWZpY2F0aW9u');

@$core.Deprecated('Use listCertificationsRequestDescriptor instead')
const ListCertificationsRequest$json = {
  '1': 'ListCertificationsRequest',
  '2': [
    {'1': 'record_id', '3': 1, '4': 1, '5': 9, '10': 'recordId'},
    {
      '1': 'cert_type',
      '3': 2,
      '4': 1,
      '5': 14,
      '6': '.agriculture.traceability.v1.CertificationType',
      '10': 'certType'
    },
    {
      '1': 'status',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.traceability.v1.CertificationStatus',
      '10': 'status'
    },
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 5, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListCertificationsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCertificationsRequestDescriptor = $convert.base64Decode(
    'ChlMaXN0Q2VydGlmaWNhdGlvbnNSZXF1ZXN0EhsKCXJlY29yZF9pZBgBIAEoCVIIcmVjb3JkSW'
    'QSSwoJY2VydF90eXBlGAIgASgOMi4uYWdyaWN1bHR1cmUudHJhY2VhYmlsaXR5LnYxLkNlcnRp'
    'ZmljYXRpb25UeXBlUghjZXJ0VHlwZRJICgZzdGF0dXMYAyABKA4yMC5hZ3JpY3VsdHVyZS50cm'
    'FjZWFiaWxpdHkudjEuQ2VydGlmaWNhdGlvblN0YXR1c1IGc3RhdHVzEhsKCXBhZ2Vfc2l6ZRgE'
    'IAEoBVIIcGFnZVNpemUSHQoKcGFnZV90b2tlbhgFIAEoCVIJcGFnZVRva2Vu');

@$core.Deprecated('Use listCertificationsResponseDescriptor instead')
const ListCertificationsResponse$json = {
  '1': 'ListCertificationsResponse',
  '2': [
    {
      '1': 'certifications',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.traceability.v1.Certification',
      '10': 'certifications'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListCertificationsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listCertificationsResponseDescriptor = $convert.base64Decode(
    'ChpMaXN0Q2VydGlmaWNhdGlvbnNSZXNwb25zZRJSCg5jZXJ0aWZpY2F0aW9ucxgBIAMoCzIqLm'
    'FncmljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS5DZXJ0aWZpY2F0aW9uUg5jZXJ0aWZpY2F0aW9u'
    'cxImCg9uZXh0X3BhZ2VfdG9rZW4YAiABKAlSDW5leHRQYWdlVG9rZW4SHwoLdG90YWxfY291bn'
    'QYAyABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use verifyCertificationRequestDescriptor instead')
const VerifyCertificationRequest$json = {
  '1': 'VerifyCertificationRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'verified_by', '3': 2, '4': 1, '5': 9, '10': 'verifiedBy'},
  ],
};

/// Descriptor for `VerifyCertificationRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyCertificationRequestDescriptor =
    $convert.base64Decode(
        'ChpWZXJpZnlDZXJ0aWZpY2F0aW9uUmVxdWVzdBIOCgJpZBgBIAEoCVICaWQSHwoLdmVyaWZpZW'
        'RfYnkYAiABKAlSCnZlcmlmaWVkQnk=');

@$core.Deprecated('Use verifyCertificationResponseDescriptor instead')
const VerifyCertificationResponse$json = {
  '1': 'VerifyCertificationResponse',
  '2': [
    {
      '1': 'certification',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.traceability.v1.Certification',
      '10': 'certification'
    },
  ],
};

/// Descriptor for `VerifyCertificationResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyCertificationResponseDescriptor =
    $convert.base64Decode(
        'ChtWZXJpZnlDZXJ0aWZpY2F0aW9uUmVzcG9uc2USUAoNY2VydGlmaWNhdGlvbhgBIAEoCzIqLm'
        'FncmljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS5DZXJ0aWZpY2F0aW9uUg1jZXJ0aWZpY2F0aW9u');

@$core.Deprecated('Use createBatchRequestDescriptor instead')
const CreateBatchRequest$json = {
  '1': 'CreateBatchRequest',
  '2': [
    {'1': 'record_id', '3': 1, '4': 1, '5': 9, '10': 'recordId'},
    {'1': 'batch_number', '3': 2, '4': 1, '5': 9, '10': 'batchNumber'},
    {'1': 'quantity', '3': 3, '4': 1, '5': 5, '10': 'quantity'},
    {'1': 'unit', '3': 4, '4': 1, '5': 9, '10': 'unit'},
    {
      '1': 'production_date',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'productionDate'
    },
    {
      '1': 'expiry_date',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'expiryDate'
    },
    {
      '1': 'storage_conditions',
      '3': 7,
      '4': 1,
      '5': 9,
      '10': 'storageConditions'
    },
    {'1': 'quality_grade', '3': 8, '4': 1, '5': 9, '10': 'qualityGrade'},
    {
      '1': 'metadata',
      '3': 9,
      '4': 3,
      '5': 11,
      '6': '.agriculture.traceability.v1.CreateBatchRequest.MetadataEntry',
      '10': 'metadata'
    },
  ],
  '3': [CreateBatchRequest_MetadataEntry$json],
};

@$core.Deprecated('Use createBatchRequestDescriptor instead')
const CreateBatchRequest_MetadataEntry$json = {
  '1': 'MetadataEntry',
  '2': [
    {'1': 'key', '3': 1, '4': 1, '5': 9, '10': 'key'},
    {'1': 'value', '3': 2, '4': 1, '5': 9, '10': 'value'},
  ],
  '7': {'7': true},
};

/// Descriptor for `CreateBatchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createBatchRequestDescriptor = $convert.base64Decode(
    'ChJDcmVhdGVCYXRjaFJlcXVlc3QSGwoJcmVjb3JkX2lkGAEgASgJUghyZWNvcmRJZBIhCgxiYX'
    'RjaF9udW1iZXIYAiABKAlSC2JhdGNoTnVtYmVyEhoKCHF1YW50aXR5GAMgASgFUghxdWFudGl0'
    'eRISCgR1bml0GAQgASgJUgR1bml0EkMKD3Byb2R1Y3Rpb25fZGF0ZRgFIAEoCzIaLmdvb2dsZS'
    '5wcm90b2J1Zi5UaW1lc3RhbXBSDnByb2R1Y3Rpb25EYXRlEjsKC2V4cGlyeV9kYXRlGAYgASgL'
    'MhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcFIKZXhwaXJ5RGF0ZRItChJzdG9yYWdlX2Nvbm'
    'RpdGlvbnMYByABKAlSEXN0b3JhZ2VDb25kaXRpb25zEiMKDXF1YWxpdHlfZ3JhZGUYCCABKAlS'
    'DHF1YWxpdHlHcmFkZRJZCghtZXRhZGF0YRgJIAMoCzI9LmFncmljdWx0dXJlLnRyYWNlYWJpbG'
    'l0eS52MS5DcmVhdGVCYXRjaFJlcXVlc3QuTWV0YWRhdGFFbnRyeVIIbWV0YWRhdGEaOwoNTWV0'
    'YWRhdGFFbnRyeRIQCgNrZXkYASABKAlSA2tleRIUCgV2YWx1ZRgCIAEoCVIFdmFsdWU6AjgB');

@$core.Deprecated('Use createBatchResponseDescriptor instead')
const CreateBatchResponse$json = {
  '1': 'CreateBatchResponse',
  '2': [
    {
      '1': 'batch',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.traceability.v1.BatchRecord',
      '10': 'batch'
    },
  ],
};

/// Descriptor for `CreateBatchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createBatchResponseDescriptor = $convert.base64Decode(
    'ChNDcmVhdGVCYXRjaFJlc3BvbnNlEj4KBWJhdGNoGAEgASgLMiguYWdyaWN1bHR1cmUudHJhY2'
    'VhYmlsaXR5LnYxLkJhdGNoUmVjb3JkUgViYXRjaA==');

@$core.Deprecated('Use getBatchRequestDescriptor instead')
const GetBatchRequest$json = {
  '1': 'GetBatchRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `GetBatchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBatchRequestDescriptor =
    $convert.base64Decode('Cg9HZXRCYXRjaFJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

@$core.Deprecated('Use getBatchResponseDescriptor instead')
const GetBatchResponse$json = {
  '1': 'GetBatchResponse',
  '2': [
    {
      '1': 'batch',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.traceability.v1.BatchRecord',
      '10': 'batch'
    },
  ],
};

/// Descriptor for `GetBatchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getBatchResponseDescriptor = $convert.base64Decode(
    'ChBHZXRCYXRjaFJlc3BvbnNlEj4KBWJhdGNoGAEgASgLMiguYWdyaWN1bHR1cmUudHJhY2VhYm'
    'lsaXR5LnYxLkJhdGNoUmVjb3JkUgViYXRjaA==');

@$core.Deprecated('Use listBatchesRequestDescriptor instead')
const ListBatchesRequest$json = {
  '1': 'ListBatchesRequest',
  '2': [
    {'1': 'record_id', '3': 1, '4': 1, '5': 9, '10': 'recordId'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 3, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListBatchesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBatchesRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0QmF0Y2hlc1JlcXVlc3QSGwoJcmVjb3JkX2lkGAEgASgJUghyZWNvcmRJZBIbCglwYW'
    'dlX3NpemUYAiABKAVSCHBhZ2VTaXplEh0KCnBhZ2VfdG9rZW4YAyABKAlSCXBhZ2VUb2tlbg==');

@$core.Deprecated('Use listBatchesResponseDescriptor instead')
const ListBatchesResponse$json = {
  '1': 'ListBatchesResponse',
  '2': [
    {
      '1': 'batches',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.traceability.v1.BatchRecord',
      '10': 'batches'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListBatchesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listBatchesResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0QmF0Y2hlc1Jlc3BvbnNlEkIKB2JhdGNoZXMYASADKAsyKC5hZ3JpY3VsdHVyZS50cm'
    'FjZWFiaWxpdHkudjEuQmF0Y2hSZWNvcmRSB2JhdGNoZXMSJgoPbmV4dF9wYWdlX3Rva2VuGAIg'
    'ASgJUg1uZXh0UGFnZVRva2VuEh8KC3RvdGFsX2NvdW50GAMgASgFUgp0b3RhbENvdW50');

@$core.Deprecated('Use generateQRCodeRequestDescriptor instead')
const GenerateQRCodeRequest$json = {
  '1': 'GenerateQRCodeRequest',
  '2': [
    {'1': 'record_id', '3': 1, '4': 1, '5': 9, '10': 'recordId'},
    {'1': 'batch_id', '3': 2, '4': 1, '5': 9, '10': 'batchId'},
    {'1': 'base_url', '3': 3, '4': 1, '5': 9, '10': 'baseUrl'},
  ],
};

/// Descriptor for `GenerateQRCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateQRCodeRequestDescriptor = $convert.base64Decode(
    'ChVHZW5lcmF0ZVFSQ29kZVJlcXVlc3QSGwoJcmVjb3JkX2lkGAEgASgJUghyZWNvcmRJZBIZCg'
    'hiYXRjaF9pZBgCIAEoCVIHYmF0Y2hJZBIZCghiYXNlX3VybBgDIAEoCVIHYmFzZVVybA==');

@$core.Deprecated('Use generateQRCodeResponseDescriptor instead')
const GenerateQRCodeResponse$json = {
  '1': 'GenerateQRCodeResponse',
  '2': [
    {
      '1': 'qr_code',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.traceability.v1.QRCode',
      '10': 'qrCode'
    },
  ],
};

/// Descriptor for `GenerateQRCodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateQRCodeResponseDescriptor =
    $convert.base64Decode(
        'ChZHZW5lcmF0ZVFSQ29kZVJlc3BvbnNlEjwKB3FyX2NvZGUYASABKAsyIy5hZ3JpY3VsdHVyZS'
        '50cmFjZWFiaWxpdHkudjEuUVJDb2RlUgZxckNvZGU=');

@$core.Deprecated('Use verifyQRCodeRequestDescriptor instead')
const VerifyQRCodeRequest$json = {
  '1': 'VerifyQRCodeRequest',
  '2': [
    {'1': 'qr_data', '3': 1, '4': 1, '5': 9, '10': 'qrData'},
  ],
};

/// Descriptor for `VerifyQRCodeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyQRCodeRequestDescriptor =
    $convert.base64Decode(
        'ChNWZXJpZnlRUkNvZGVSZXF1ZXN0EhcKB3FyX2RhdGEYASABKAlSBnFyRGF0YQ==');

@$core.Deprecated('Use verifyQRCodeResponseDescriptor instead')
const VerifyQRCodeResponse$json = {
  '1': 'VerifyQRCodeResponse',
  '2': [
    {'1': 'valid', '3': 1, '4': 1, '5': 8, '10': 'valid'},
    {
      '1': 'record',
      '3': 2,
      '4': 1,
      '5': 11,
      '6': '.agriculture.traceability.v1.TraceabilityRecord',
      '10': 'record'
    },
    {
      '1': 'batch',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.agriculture.traceability.v1.BatchRecord',
      '10': 'batch'
    },
  ],
};

/// Descriptor for `VerifyQRCodeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List verifyQRCodeResponseDescriptor = $convert.base64Decode(
    'ChRWZXJpZnlRUkNvZGVSZXNwb25zZRIUCgV2YWxpZBgBIAEoCFIFdmFsaWQSRwoGcmVjb3JkGA'
    'IgASgLMi8uYWdyaWN1bHR1cmUudHJhY2VhYmlsaXR5LnYxLlRyYWNlYWJpbGl0eVJlY29yZFIG'
    'cmVjb3JkEj4KBWJhdGNoGAMgASgLMiguYWdyaWN1bHR1cmUudHJhY2VhYmlsaXR5LnYxLkJhdG'
    'NoUmVjb3JkUgViYXRjaA==');

@$core.Deprecated('Use generateComplianceReportRequestDescriptor instead')
const GenerateComplianceReportRequest$json = {
  '1': 'GenerateComplianceReportRequest',
  '2': [
    {'1': 'record_id', '3': 1, '4': 1, '5': 9, '10': 'recordId'},
    {'1': 'report_type', '3': 2, '4': 1, '5': 9, '10': 'reportType'},
    {'1': 'auditor', '3': 3, '4': 1, '5': 9, '10': 'auditor'},
  ],
};

/// Descriptor for `GenerateComplianceReportRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateComplianceReportRequestDescriptor =
    $convert.base64Decode(
        'Ch9HZW5lcmF0ZUNvbXBsaWFuY2VSZXBvcnRSZXF1ZXN0EhsKCXJlY29yZF9pZBgBIAEoCVIIcm'
        'Vjb3JkSWQSHwoLcmVwb3J0X3R5cGUYAiABKAlSCnJlcG9ydFR5cGUSGAoHYXVkaXRvchgDIAEo'
        'CVIHYXVkaXRvcg==');

@$core.Deprecated('Use generateComplianceReportResponseDescriptor instead')
const GenerateComplianceReportResponse$json = {
  '1': 'GenerateComplianceReportResponse',
  '2': [
    {
      '1': 'report',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.traceability.v1.ComplianceReport',
      '10': 'report'
    },
  ],
};

/// Descriptor for `GenerateComplianceReportResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List generateComplianceReportResponseDescriptor =
    $convert.base64Decode(
        'CiBHZW5lcmF0ZUNvbXBsaWFuY2VSZXBvcnRSZXNwb25zZRJFCgZyZXBvcnQYASABKAsyLS5hZ3'
        'JpY3VsdHVyZS50cmFjZWFiaWxpdHkudjEuQ29tcGxpYW5jZVJlcG9ydFIGcmVwb3J0');

const $core.Map<$core.String, $core.dynamic> TraceabilityServiceBase$json = {
  '1': 'TraceabilityService',
  '2': [
    {
      '1': 'CreateRecord',
      '2': '.agriculture.traceability.v1.CreateRecordRequest',
      '3': '.agriculture.traceability.v1.CreateRecordResponse'
    },
    {
      '1': 'GetRecord',
      '2': '.agriculture.traceability.v1.GetRecordRequest',
      '3': '.agriculture.traceability.v1.GetRecordResponse'
    },
    {
      '1': 'ListRecords',
      '2': '.agriculture.traceability.v1.ListRecordsRequest',
      '3': '.agriculture.traceability.v1.ListRecordsResponse'
    },
    {
      '1': 'AddSupplyChainEvent',
      '2': '.agriculture.traceability.v1.AddSupplyChainEventRequest',
      '3': '.agriculture.traceability.v1.AddSupplyChainEventResponse'
    },
    {
      '1': 'GetSupplyChain',
      '2': '.agriculture.traceability.v1.GetSupplyChainRequest',
      '3': '.agriculture.traceability.v1.GetSupplyChainResponse'
    },
    {
      '1': 'CreateCertification',
      '2': '.agriculture.traceability.v1.CreateCertificationRequest',
      '3': '.agriculture.traceability.v1.CreateCertificationResponse'
    },
    {
      '1': 'GetCertification',
      '2': '.agriculture.traceability.v1.GetCertificationRequest',
      '3': '.agriculture.traceability.v1.GetCertificationResponse'
    },
    {
      '1': 'ListCertifications',
      '2': '.agriculture.traceability.v1.ListCertificationsRequest',
      '3': '.agriculture.traceability.v1.ListCertificationsResponse'
    },
    {
      '1': 'VerifyCertification',
      '2': '.agriculture.traceability.v1.VerifyCertificationRequest',
      '3': '.agriculture.traceability.v1.VerifyCertificationResponse'
    },
    {
      '1': 'CreateBatch',
      '2': '.agriculture.traceability.v1.CreateBatchRequest',
      '3': '.agriculture.traceability.v1.CreateBatchResponse'
    },
    {
      '1': 'GetBatch',
      '2': '.agriculture.traceability.v1.GetBatchRequest',
      '3': '.agriculture.traceability.v1.GetBatchResponse'
    },
    {
      '1': 'ListBatches',
      '2': '.agriculture.traceability.v1.ListBatchesRequest',
      '3': '.agriculture.traceability.v1.ListBatchesResponse'
    },
    {
      '1': 'GenerateQRCode',
      '2': '.agriculture.traceability.v1.GenerateQRCodeRequest',
      '3': '.agriculture.traceability.v1.GenerateQRCodeResponse'
    },
    {
      '1': 'VerifyQRCode',
      '2': '.agriculture.traceability.v1.VerifyQRCodeRequest',
      '3': '.agriculture.traceability.v1.VerifyQRCodeResponse'
    },
    {
      '1': 'GenerateComplianceReport',
      '2': '.agriculture.traceability.v1.GenerateComplianceReportRequest',
      '3': '.agriculture.traceability.v1.GenerateComplianceReportResponse'
    },
  ],
};

@$core.Deprecated('Use traceabilityServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    TraceabilityServiceBase$messageJson = {
  '.agriculture.traceability.v1.CreateRecordRequest': CreateRecordRequest$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.traceability.v1.CreateRecordRequest.MetadataEntry':
      CreateRecordRequest_MetadataEntry$json,
  '.agriculture.traceability.v1.CreateRecordResponse':
      CreateRecordResponse$json,
  '.agriculture.traceability.v1.TraceabilityRecord': TraceabilityRecord$json,
  '.agriculture.traceability.v1.SupplyChainEvent': SupplyChainEvent$json,
  '.agriculture.traceability.v1.Certification': Certification$json,
  '.agriculture.traceability.v1.Certification.MetadataEntry':
      Certification_MetadataEntry$json,
  '.agriculture.traceability.v1.TraceabilityRecord.MetadataEntry':
      TraceabilityRecord_MetadataEntry$json,
  '.agriculture.traceability.v1.GetRecordRequest': GetRecordRequest$json,
  '.agriculture.traceability.v1.GetRecordResponse': GetRecordResponse$json,
  '.agriculture.traceability.v1.ListRecordsRequest': ListRecordsRequest$json,
  '.agriculture.traceability.v1.ListRecordsResponse': ListRecordsResponse$json,
  '.agriculture.traceability.v1.AddSupplyChainEventRequest':
      AddSupplyChainEventRequest$json,
  '.agriculture.traceability.v1.AddSupplyChainEventResponse':
      AddSupplyChainEventResponse$json,
  '.agriculture.traceability.v1.GetSupplyChainRequest':
      GetSupplyChainRequest$json,
  '.agriculture.traceability.v1.GetSupplyChainResponse':
      GetSupplyChainResponse$json,
  '.agriculture.traceability.v1.CreateCertificationRequest':
      CreateCertificationRequest$json,
  '.agriculture.traceability.v1.CreateCertificationRequest.MetadataEntry':
      CreateCertificationRequest_MetadataEntry$json,
  '.agriculture.traceability.v1.CreateCertificationResponse':
      CreateCertificationResponse$json,
  '.agriculture.traceability.v1.GetCertificationRequest':
      GetCertificationRequest$json,
  '.agriculture.traceability.v1.GetCertificationResponse':
      GetCertificationResponse$json,
  '.agriculture.traceability.v1.ListCertificationsRequest':
      ListCertificationsRequest$json,
  '.agriculture.traceability.v1.ListCertificationsResponse':
      ListCertificationsResponse$json,
  '.agriculture.traceability.v1.VerifyCertificationRequest':
      VerifyCertificationRequest$json,
  '.agriculture.traceability.v1.VerifyCertificationResponse':
      VerifyCertificationResponse$json,
  '.agriculture.traceability.v1.CreateBatchRequest': CreateBatchRequest$json,
  '.agriculture.traceability.v1.CreateBatchRequest.MetadataEntry':
      CreateBatchRequest_MetadataEntry$json,
  '.agriculture.traceability.v1.CreateBatchResponse': CreateBatchResponse$json,
  '.agriculture.traceability.v1.BatchRecord': BatchRecord$json,
  '.agriculture.traceability.v1.BatchRecord.MetadataEntry':
      BatchRecord_MetadataEntry$json,
  '.agriculture.traceability.v1.GetBatchRequest': GetBatchRequest$json,
  '.agriculture.traceability.v1.GetBatchResponse': GetBatchResponse$json,
  '.agriculture.traceability.v1.ListBatchesRequest': ListBatchesRequest$json,
  '.agriculture.traceability.v1.ListBatchesResponse': ListBatchesResponse$json,
  '.agriculture.traceability.v1.GenerateQRCodeRequest':
      GenerateQRCodeRequest$json,
  '.agriculture.traceability.v1.GenerateQRCodeResponse':
      GenerateQRCodeResponse$json,
  '.agriculture.traceability.v1.QRCode': QRCode$json,
  '.agriculture.traceability.v1.VerifyQRCodeRequest': VerifyQRCodeRequest$json,
  '.agriculture.traceability.v1.VerifyQRCodeResponse':
      VerifyQRCodeResponse$json,
  '.agriculture.traceability.v1.GenerateComplianceReportRequest':
      GenerateComplianceReportRequest$json,
  '.agriculture.traceability.v1.GenerateComplianceReportResponse':
      GenerateComplianceReportResponse$json,
  '.agriculture.traceability.v1.ComplianceReport': ComplianceReport$json,
  '.agriculture.traceability.v1.ComplianceReport.MetadataEntry':
      ComplianceReport_MetadataEntry$json,
};

/// Descriptor for `TraceabilityService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List traceabilityServiceDescriptor = $convert.base64Decode(
    'ChNUcmFjZWFiaWxpdHlTZXJ2aWNlEnMKDENyZWF0ZVJlY29yZBIwLmFncmljdWx0dXJlLnRyYW'
    'NlYWJpbGl0eS52MS5DcmVhdGVSZWNvcmRSZXF1ZXN0GjEuYWdyaWN1bHR1cmUudHJhY2VhYmls'
    'aXR5LnYxLkNyZWF0ZVJlY29yZFJlc3BvbnNlEmoKCUdldFJlY29yZBItLmFncmljdWx0dXJlLn'
    'RyYWNlYWJpbGl0eS52MS5HZXRSZWNvcmRSZXF1ZXN0Gi4uYWdyaWN1bHR1cmUudHJhY2VhYmls'
    'aXR5LnYxLkdldFJlY29yZFJlc3BvbnNlEnAKC0xpc3RSZWNvcmRzEi8uYWdyaWN1bHR1cmUudH'
    'JhY2VhYmlsaXR5LnYxLkxpc3RSZWNvcmRzUmVxdWVzdBowLmFncmljdWx0dXJlLnRyYWNlYWJp'
    'bGl0eS52MS5MaXN0UmVjb3Jkc1Jlc3BvbnNlEogBChNBZGRTdXBwbHlDaGFpbkV2ZW50EjcuYW'
    'dyaWN1bHR1cmUudHJhY2VhYmlsaXR5LnYxLkFkZFN1cHBseUNoYWluRXZlbnRSZXF1ZXN0Gjgu'
    'YWdyaWN1bHR1cmUudHJhY2VhYmlsaXR5LnYxLkFkZFN1cHBseUNoYWluRXZlbnRSZXNwb25zZR'
    'J5Cg5HZXRTdXBwbHlDaGFpbhIyLmFncmljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS5HZXRTdXBw'
    'bHlDaGFpblJlcXVlc3QaMy5hZ3JpY3VsdHVyZS50cmFjZWFiaWxpdHkudjEuR2V0U3VwcGx5Q2'
    'hhaW5SZXNwb25zZRKIAQoTQ3JlYXRlQ2VydGlmaWNhdGlvbhI3LmFncmljdWx0dXJlLnRyYWNl'
    'YWJpbGl0eS52MS5DcmVhdGVDZXJ0aWZpY2F0aW9uUmVxdWVzdBo4LmFncmljdWx0dXJlLnRyYW'
    'NlYWJpbGl0eS52MS5DcmVhdGVDZXJ0aWZpY2F0aW9uUmVzcG9uc2USfwoQR2V0Q2VydGlmaWNh'
    'dGlvbhI0LmFncmljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS5HZXRDZXJ0aWZpY2F0aW9uUmVxdW'
    'VzdBo1LmFncmljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS5HZXRDZXJ0aWZpY2F0aW9uUmVzcG9u'
    'c2UShQEKEkxpc3RDZXJ0aWZpY2F0aW9ucxI2LmFncmljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS'
    '5MaXN0Q2VydGlmaWNhdGlvbnNSZXF1ZXN0GjcuYWdyaWN1bHR1cmUudHJhY2VhYmlsaXR5LnYx'
    'Lkxpc3RDZXJ0aWZpY2F0aW9uc1Jlc3BvbnNlEogBChNWZXJpZnlDZXJ0aWZpY2F0aW9uEjcuYW'
    'dyaWN1bHR1cmUudHJhY2VhYmlsaXR5LnYxLlZlcmlmeUNlcnRpZmljYXRpb25SZXF1ZXN0Gjgu'
    'YWdyaWN1bHR1cmUudHJhY2VhYmlsaXR5LnYxLlZlcmlmeUNlcnRpZmljYXRpb25SZXNwb25zZR'
    'JwCgtDcmVhdGVCYXRjaBIvLmFncmljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS5DcmVhdGVCYXRj'
    'aFJlcXVlc3QaMC5hZ3JpY3VsdHVyZS50cmFjZWFiaWxpdHkudjEuQ3JlYXRlQmF0Y2hSZXNwb2'
    '5zZRJnCghHZXRCYXRjaBIsLmFncmljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS5HZXRCYXRjaFJl'
    'cXVlc3QaLS5hZ3JpY3VsdHVyZS50cmFjZWFiaWxpdHkudjEuR2V0QmF0Y2hSZXNwb25zZRJwCg'
    'tMaXN0QmF0Y2hlcxIvLmFncmljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS5MaXN0QmF0Y2hlc1Jl'
    'cXVlc3QaMC5hZ3JpY3VsdHVyZS50cmFjZWFiaWxpdHkudjEuTGlzdEJhdGNoZXNSZXNwb25zZR'
    'J5Cg5HZW5lcmF0ZVFSQ29kZRIyLmFncmljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS5HZW5lcmF0'
    'ZVFSQ29kZVJlcXVlc3QaMy5hZ3JpY3VsdHVyZS50cmFjZWFiaWxpdHkudjEuR2VuZXJhdGVRUk'
    'NvZGVSZXNwb25zZRJzCgxWZXJpZnlRUkNvZGUSMC5hZ3JpY3VsdHVyZS50cmFjZWFiaWxpdHku'
    'djEuVmVyaWZ5UVJDb2RlUmVxdWVzdBoxLmFncmljdWx0dXJlLnRyYWNlYWJpbGl0eS52MS5WZX'
    'JpZnlRUkNvZGVSZXNwb25zZRKXAQoYR2VuZXJhdGVDb21wbGlhbmNlUmVwb3J0EjwuYWdyaWN1'
    'bHR1cmUudHJhY2VhYmlsaXR5LnYxLkdlbmVyYXRlQ29tcGxpYW5jZVJlcG9ydFJlcXVlc3QaPS'
    '5hZ3JpY3VsdHVyZS50cmFjZWFiaWxpdHkudjEuR2VuZXJhdGVDb21wbGlhbmNlUmVwb3J0UmVz'
    'cG9uc2U=');
