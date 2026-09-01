// This is a generated file - do not edit.
//
// Generated from traceability.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// SupplyChainEventType represents the type of supply chain event.
class SupplyChainEventType extends $pb.ProtobufEnum {
  static const SupplyChainEventType SUPPLY_CHAIN_EVENT_TYPE_UNSPECIFIED =
      SupplyChainEventType._(
          0, _omitEnumNames ? '' : 'SUPPLY_CHAIN_EVENT_TYPE_UNSPECIFIED');
  static const SupplyChainEventType SUPPLY_CHAIN_EVENT_TYPE_PLANTED =
      SupplyChainEventType._(
          1, _omitEnumNames ? '' : 'SUPPLY_CHAIN_EVENT_TYPE_PLANTED');
  static const SupplyChainEventType SUPPLY_CHAIN_EVENT_TYPE_FERTILIZED =
      SupplyChainEventType._(
          2, _omitEnumNames ? '' : 'SUPPLY_CHAIN_EVENT_TYPE_FERTILIZED');
  static const SupplyChainEventType SUPPLY_CHAIN_EVENT_TYPE_IRRIGATED =
      SupplyChainEventType._(
          3, _omitEnumNames ? '' : 'SUPPLY_CHAIN_EVENT_TYPE_IRRIGATED');
  static const SupplyChainEventType SUPPLY_CHAIN_EVENT_TYPE_SPRAYED =
      SupplyChainEventType._(
          4, _omitEnumNames ? '' : 'SUPPLY_CHAIN_EVENT_TYPE_SPRAYED');
  static const SupplyChainEventType SUPPLY_CHAIN_EVENT_TYPE_HARVESTED =
      SupplyChainEventType._(
          5, _omitEnumNames ? '' : 'SUPPLY_CHAIN_EVENT_TYPE_HARVESTED');
  static const SupplyChainEventType SUPPLY_CHAIN_EVENT_TYPE_PROCESSED =
      SupplyChainEventType._(
          6, _omitEnumNames ? '' : 'SUPPLY_CHAIN_EVENT_TYPE_PROCESSED');
  static const SupplyChainEventType SUPPLY_CHAIN_EVENT_TYPE_PACKAGED =
      SupplyChainEventType._(
          7, _omitEnumNames ? '' : 'SUPPLY_CHAIN_EVENT_TYPE_PACKAGED');
  static const SupplyChainEventType SUPPLY_CHAIN_EVENT_TYPE_SHIPPED =
      SupplyChainEventType._(
          8, _omitEnumNames ? '' : 'SUPPLY_CHAIN_EVENT_TYPE_SHIPPED');
  static const SupplyChainEventType SUPPLY_CHAIN_EVENT_TYPE_RECEIVED =
      SupplyChainEventType._(
          9, _omitEnumNames ? '' : 'SUPPLY_CHAIN_EVENT_TYPE_RECEIVED');
  static const SupplyChainEventType SUPPLY_CHAIN_EVENT_TYPE_SOLD =
      SupplyChainEventType._(
          10, _omitEnumNames ? '' : 'SUPPLY_CHAIN_EVENT_TYPE_SOLD');

  static const $core.List<SupplyChainEventType> values = <SupplyChainEventType>[
    SUPPLY_CHAIN_EVENT_TYPE_UNSPECIFIED,
    SUPPLY_CHAIN_EVENT_TYPE_PLANTED,
    SUPPLY_CHAIN_EVENT_TYPE_FERTILIZED,
    SUPPLY_CHAIN_EVENT_TYPE_IRRIGATED,
    SUPPLY_CHAIN_EVENT_TYPE_SPRAYED,
    SUPPLY_CHAIN_EVENT_TYPE_HARVESTED,
    SUPPLY_CHAIN_EVENT_TYPE_PROCESSED,
    SUPPLY_CHAIN_EVENT_TYPE_PACKAGED,
    SUPPLY_CHAIN_EVENT_TYPE_SHIPPED,
    SUPPLY_CHAIN_EVENT_TYPE_RECEIVED,
    SUPPLY_CHAIN_EVENT_TYPE_SOLD,
  ];

  static final $core.List<SupplyChainEventType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 10);
  static SupplyChainEventType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SupplyChainEventType._(super.value, super.name);
}

/// CertificationType represents the type of certification.
class CertificationType extends $pb.ProtobufEnum {
  static const CertificationType CERTIFICATION_TYPE_UNSPECIFIED =
      CertificationType._(
          0, _omitEnumNames ? '' : 'CERTIFICATION_TYPE_UNSPECIFIED');
  static const CertificationType CERTIFICATION_TYPE_ORGANIC =
      CertificationType._(
          1, _omitEnumNames ? '' : 'CERTIFICATION_TYPE_ORGANIC');
  static const CertificationType CERTIFICATION_TYPE_GAP =
      CertificationType._(2, _omitEnumNames ? '' : 'CERTIFICATION_TYPE_GAP');
  static const CertificationType CERTIFICATION_TYPE_FAIRTRADE =
      CertificationType._(
          3, _omitEnumNames ? '' : 'CERTIFICATION_TYPE_FAIRTRADE');
  static const CertificationType CERTIFICATION_TYPE_RAINFOREST_ALLIANCE =
      CertificationType._(
          4, _omitEnumNames ? '' : 'CERTIFICATION_TYPE_RAINFOREST_ALLIANCE');
  static const CertificationType CERTIFICATION_TYPE_USDA_ORGANIC =
      CertificationType._(
          5, _omitEnumNames ? '' : 'CERTIFICATION_TYPE_USDA_ORGANIC');
  static const CertificationType CERTIFICATION_TYPE_EU_ORGANIC =
      CertificationType._(
          6, _omitEnumNames ? '' : 'CERTIFICATION_TYPE_EU_ORGANIC');

  static const $core.List<CertificationType> values = <CertificationType>[
    CERTIFICATION_TYPE_UNSPECIFIED,
    CERTIFICATION_TYPE_ORGANIC,
    CERTIFICATION_TYPE_GAP,
    CERTIFICATION_TYPE_FAIRTRADE,
    CERTIFICATION_TYPE_RAINFOREST_ALLIANCE,
    CERTIFICATION_TYPE_USDA_ORGANIC,
    CERTIFICATION_TYPE_EU_ORGANIC,
  ];

  static final $core.List<CertificationType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static CertificationType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CertificationType._(super.value, super.name);
}

/// CertificationStatus represents the status of a certification.
class CertificationStatus extends $pb.ProtobufEnum {
  static const CertificationStatus CERTIFICATION_STATUS_UNSPECIFIED =
      CertificationStatus._(
          0, _omitEnumNames ? '' : 'CERTIFICATION_STATUS_UNSPECIFIED');
  static const CertificationStatus CERTIFICATION_STATUS_ACTIVE =
      CertificationStatus._(
          1, _omitEnumNames ? '' : 'CERTIFICATION_STATUS_ACTIVE');
  static const CertificationStatus CERTIFICATION_STATUS_EXPIRED =
      CertificationStatus._(
          2, _omitEnumNames ? '' : 'CERTIFICATION_STATUS_EXPIRED');
  static const CertificationStatus CERTIFICATION_STATUS_REVOKED =
      CertificationStatus._(
          3, _omitEnumNames ? '' : 'CERTIFICATION_STATUS_REVOKED');
  static const CertificationStatus CERTIFICATION_STATUS_PENDING =
      CertificationStatus._(
          4, _omitEnumNames ? '' : 'CERTIFICATION_STATUS_PENDING');

  static const $core.List<CertificationStatus> values = <CertificationStatus>[
    CERTIFICATION_STATUS_UNSPECIFIED,
    CERTIFICATION_STATUS_ACTIVE,
    CERTIFICATION_STATUS_EXPIRED,
    CERTIFICATION_STATUS_REVOKED,
    CERTIFICATION_STATUS_PENDING,
  ];

  static final $core.List<CertificationStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static CertificationStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CertificationStatus._(super.value, super.name);
}

/// ComplianceStatus represents the compliance status of a traceability record.
class ComplianceStatus extends $pb.ProtobufEnum {
  static const ComplianceStatus COMPLIANCE_STATUS_UNSPECIFIED =
      ComplianceStatus._(
          0, _omitEnumNames ? '' : 'COMPLIANCE_STATUS_UNSPECIFIED');
  static const ComplianceStatus COMPLIANCE_STATUS_COMPLIANT =
      ComplianceStatus._(
          1, _omitEnumNames ? '' : 'COMPLIANCE_STATUS_COMPLIANT');
  static const ComplianceStatus COMPLIANCE_STATUS_NON_COMPLIANT =
      ComplianceStatus._(
          2, _omitEnumNames ? '' : 'COMPLIANCE_STATUS_NON_COMPLIANT');
  static const ComplianceStatus COMPLIANCE_STATUS_PENDING_REVIEW =
      ComplianceStatus._(
          3, _omitEnumNames ? '' : 'COMPLIANCE_STATUS_PENDING_REVIEW');

  static const $core.List<ComplianceStatus> values = <ComplianceStatus>[
    COMPLIANCE_STATUS_UNSPECIFIED,
    COMPLIANCE_STATUS_COMPLIANT,
    COMPLIANCE_STATUS_NON_COMPLIANT,
    COMPLIANCE_STATUS_PENDING_REVIEW,
  ];

  static final $core.List<ComplianceStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static ComplianceStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ComplianceStatus._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
