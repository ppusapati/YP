// This is a generated file - do not edit.
//
// Generated from traceability.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'traceability.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'traceability.pbenum.dart';

/// SupplyChainEvent represents a single event in the supply chain.
class SupplyChainEvent extends $pb.GeneratedMessage {
  factory SupplyChainEvent({
    $core.String? id,
    $core.String? recordId,
    SupplyChainEventType? eventType,
    $0.Timestamp? timestamp,
    $core.String? location,
    $core.String? actor,
    $core.String? details,
    $core.String? verificationHash,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (recordId != null) result.recordId = recordId;
    if (eventType != null) result.eventType = eventType;
    if (timestamp != null) result.timestamp = timestamp;
    if (location != null) result.location = location;
    if (actor != null) result.actor = actor;
    if (details != null) result.details = details;
    if (verificationHash != null) result.verificationHash = verificationHash;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  SupplyChainEvent._();

  factory SupplyChainEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SupplyChainEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SupplyChainEvent',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'recordId')
    ..aE<SupplyChainEventType>(3, _omitFieldNames ? '' : 'eventType',
        enumValues: SupplyChainEventType.values)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(5, _omitFieldNames ? '' : 'location')
    ..aOS(6, _omitFieldNames ? '' : 'actor')
    ..aOS(7, _omitFieldNames ? '' : 'details')
    ..aOS(8, _omitFieldNames ? '' : 'verificationHash')
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplyChainEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SupplyChainEvent copyWith(void Function(SupplyChainEvent) updates) =>
      super.copyWith((message) => updates(message as SupplyChainEvent))
          as SupplyChainEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SupplyChainEvent create() => SupplyChainEvent._();
  @$core.override
  SupplyChainEvent createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SupplyChainEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SupplyChainEvent>(create);
  static SupplyChainEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get recordId => $_getSZ(1);
  @$pb.TagNumber(2)
  set recordId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRecordId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecordId() => $_clearField(2);

  @$pb.TagNumber(3)
  SupplyChainEventType get eventType => $_getN(2);
  @$pb.TagNumber(3)
  set eventType(SupplyChainEventType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEventType() => $_has(2);
  @$pb.TagNumber(3)
  void clearEventType() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get timestamp => $_getN(3);
  @$pb.TagNumber(4)
  set timestamp($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureTimestamp() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.String get location => $_getSZ(4);
  @$pb.TagNumber(5)
  set location($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLocation() => $_has(4);
  @$pb.TagNumber(5)
  void clearLocation() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get actor => $_getSZ(5);
  @$pb.TagNumber(6)
  set actor($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasActor() => $_has(5);
  @$pb.TagNumber(6)
  void clearActor() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get details => $_getSZ(6);
  @$pb.TagNumber(7)
  set details($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDetails() => $_has(6);
  @$pb.TagNumber(7)
  void clearDetails() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get verificationHash => $_getSZ(7);
  @$pb.TagNumber(8)
  set verificationHash($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasVerificationHash() => $_has(7);
  @$pb.TagNumber(8)
  void clearVerificationHash() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get createdAt => $_getN(8);
  @$pb.TagNumber(9)
  set createdAt($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasCreatedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearCreatedAt() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureCreatedAt() => $_ensure(8);
}

/// Certification represents a certification associated with a record.
class Certification extends $pb.GeneratedMessage {
  factory Certification({
    $core.String? id,
    $core.String? tenantId,
    $core.String? recordId,
    CertificationType? certType,
    $core.String? certNumber,
    $core.String? issuedBy,
    $0.Timestamp? issuedDate,
    $0.Timestamp? expiryDate,
    CertificationStatus? status,
    $core.String? verifiedBy,
    $0.Timestamp? verifiedAt,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (recordId != null) result.recordId = recordId;
    if (certType != null) result.certType = certType;
    if (certNumber != null) result.certNumber = certNumber;
    if (issuedBy != null) result.issuedBy = issuedBy;
    if (issuedDate != null) result.issuedDate = issuedDate;
    if (expiryDate != null) result.expiryDate = expiryDate;
    if (status != null) result.status = status;
    if (verifiedBy != null) result.verifiedBy = verifiedBy;
    if (verifiedAt != null) result.verifiedAt = verifiedAt;
    if (metadata != null) result.metadata.addEntries(metadata);
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (version != null) result.version = version;
    return result;
  }

  Certification._();

  factory Certification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Certification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Certification',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'recordId')
    ..aE<CertificationType>(4, _omitFieldNames ? '' : 'certType',
        enumValues: CertificationType.values)
    ..aOS(5, _omitFieldNames ? '' : 'certNumber')
    ..aOS(6, _omitFieldNames ? '' : 'issuedBy')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'issuedDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'expiryDate',
        subBuilder: $0.Timestamp.create)
    ..aE<CertificationStatus>(9, _omitFieldNames ? '' : 'status',
        enumValues: CertificationStatus.values)
    ..aOS(10, _omitFieldNames ? '' : 'verifiedBy')
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'verifiedAt',
        subBuilder: $0.Timestamp.create)
    ..m<$core.String, $core.String>(12, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'Certification.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.traceability.v1'))
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aInt64(15, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Certification clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Certification copyWith(void Function(Certification) updates) =>
      super.copyWith((message) => updates(message as Certification))
          as Certification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Certification create() => Certification._();
  @$core.override
  Certification createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Certification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Certification>(create);
  static Certification? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get recordId => $_getSZ(2);
  @$pb.TagNumber(3)
  set recordId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRecordId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecordId() => $_clearField(3);

  @$pb.TagNumber(4)
  CertificationType get certType => $_getN(3);
  @$pb.TagNumber(4)
  set certType(CertificationType value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCertType() => $_has(3);
  @$pb.TagNumber(4)
  void clearCertType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get certNumber => $_getSZ(4);
  @$pb.TagNumber(5)
  set certNumber($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCertNumber() => $_has(4);
  @$pb.TagNumber(5)
  void clearCertNumber() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get issuedBy => $_getSZ(5);
  @$pb.TagNumber(6)
  set issuedBy($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIssuedBy() => $_has(5);
  @$pb.TagNumber(6)
  void clearIssuedBy() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get issuedDate => $_getN(6);
  @$pb.TagNumber(7)
  set issuedDate($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasIssuedDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearIssuedDate() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureIssuedDate() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get expiryDate => $_getN(7);
  @$pb.TagNumber(8)
  set expiryDate($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasExpiryDate() => $_has(7);
  @$pb.TagNumber(8)
  void clearExpiryDate() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureExpiryDate() => $_ensure(7);

  @$pb.TagNumber(9)
  CertificationStatus get status => $_getN(8);
  @$pb.TagNumber(9)
  set status(CertificationStatus value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get verifiedBy => $_getSZ(9);
  @$pb.TagNumber(10)
  set verifiedBy($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasVerifiedBy() => $_has(9);
  @$pb.TagNumber(10)
  void clearVerifiedBy() => $_clearField(10);

  @$pb.TagNumber(11)
  $0.Timestamp get verifiedAt => $_getN(10);
  @$pb.TagNumber(11)
  set verifiedAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasVerifiedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearVerifiedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureVerifiedAt() => $_ensure(10);

  @$pb.TagNumber(12)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(11);

  @$pb.TagNumber(13)
  $0.Timestamp get createdAt => $_getN(12);
  @$pb.TagNumber(13)
  set createdAt($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasCreatedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearCreatedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureCreatedAt() => $_ensure(12);

  @$pb.TagNumber(14)
  $0.Timestamp get updatedAt => $_getN(13);
  @$pb.TagNumber(14)
  set updatedAt($0.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasUpdatedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearUpdatedAt() => $_clearField(14);
  @$pb.TagNumber(14)
  $0.Timestamp ensureUpdatedAt() => $_ensure(13);

  @$pb.TagNumber(15)
  $fixnum.Int64 get version => $_getI64(14);
  @$pb.TagNumber(15)
  set version($fixnum.Int64 value) => $_setInt64(14, value);
  @$pb.TagNumber(15)
  $core.bool hasVersion() => $_has(14);
  @$pb.TagNumber(15)
  void clearVersion() => $_clearField(15);
}

/// BatchRecord represents a batch of products.
class BatchRecord extends $pb.GeneratedMessage {
  factory BatchRecord({
    $core.String? id,
    $core.String? tenantId,
    $core.String? recordId,
    $core.String? batchNumber,
    $core.int? quantity,
    $core.String? unit,
    $0.Timestamp? productionDate,
    $0.Timestamp? expiryDate,
    $core.String? storageConditions,
    $core.String? qualityGrade,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (recordId != null) result.recordId = recordId;
    if (batchNumber != null) result.batchNumber = batchNumber;
    if (quantity != null) result.quantity = quantity;
    if (unit != null) result.unit = unit;
    if (productionDate != null) result.productionDate = productionDate;
    if (expiryDate != null) result.expiryDate = expiryDate;
    if (storageConditions != null) result.storageConditions = storageConditions;
    if (qualityGrade != null) result.qualityGrade = qualityGrade;
    if (metadata != null) result.metadata.addEntries(metadata);
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (version != null) result.version = version;
    return result;
  }

  BatchRecord._();

  factory BatchRecord.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BatchRecord.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BatchRecord',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'recordId')
    ..aOS(4, _omitFieldNames ? '' : 'batchNumber')
    ..aI(5, _omitFieldNames ? '' : 'quantity')
    ..aOS(6, _omitFieldNames ? '' : 'unit')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'productionDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'expiryDate',
        subBuilder: $0.Timestamp.create)
    ..aOS(9, _omitFieldNames ? '' : 'storageConditions')
    ..aOS(10, _omitFieldNames ? '' : 'qualityGrade')
    ..m<$core.String, $core.String>(11, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'BatchRecord.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.traceability.v1'))
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aInt64(14, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchRecord clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BatchRecord copyWith(void Function(BatchRecord) updates) =>
      super.copyWith((message) => updates(message as BatchRecord))
          as BatchRecord;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BatchRecord create() => BatchRecord._();
  @$core.override
  BatchRecord createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BatchRecord getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BatchRecord>(create);
  static BatchRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get recordId => $_getSZ(2);
  @$pb.TagNumber(3)
  set recordId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRecordId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecordId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get batchNumber => $_getSZ(3);
  @$pb.TagNumber(4)
  set batchNumber($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBatchNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearBatchNumber() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get quantity => $_getIZ(4);
  @$pb.TagNumber(5)
  set quantity($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasQuantity() => $_has(4);
  @$pb.TagNumber(5)
  void clearQuantity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get unit => $_getSZ(5);
  @$pb.TagNumber(6)
  set unit($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUnit() => $_has(5);
  @$pb.TagNumber(6)
  void clearUnit() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get productionDate => $_getN(6);
  @$pb.TagNumber(7)
  set productionDate($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasProductionDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearProductionDate() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureProductionDate() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get expiryDate => $_getN(7);
  @$pb.TagNumber(8)
  set expiryDate($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasExpiryDate() => $_has(7);
  @$pb.TagNumber(8)
  void clearExpiryDate() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureExpiryDate() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.String get storageConditions => $_getSZ(8);
  @$pb.TagNumber(9)
  set storageConditions($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasStorageConditions() => $_has(8);
  @$pb.TagNumber(9)
  void clearStorageConditions() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get qualityGrade => $_getSZ(9);
  @$pb.TagNumber(10)
  set qualityGrade($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasQualityGrade() => $_has(9);
  @$pb.TagNumber(10)
  void clearQualityGrade() => $_clearField(10);

  @$pb.TagNumber(11)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(10);

  @$pb.TagNumber(12)
  $0.Timestamp get createdAt => $_getN(11);
  @$pb.TagNumber(12)
  set createdAt($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasCreatedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearCreatedAt() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureCreatedAt() => $_ensure(11);

  @$pb.TagNumber(13)
  $0.Timestamp get updatedAt => $_getN(12);
  @$pb.TagNumber(13)
  set updatedAt($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasUpdatedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearUpdatedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureUpdatedAt() => $_ensure(12);

  @$pb.TagNumber(14)
  $fixnum.Int64 get version => $_getI64(13);
  @$pb.TagNumber(14)
  set version($fixnum.Int64 value) => $_setInt64(13, value);
  @$pb.TagNumber(14)
  $core.bool hasVersion() => $_has(13);
  @$pb.TagNumber(14)
  void clearVersion() => $_clearField(14);
}

/// QRCode represents a generated QR code for traceability.
class QRCode extends $pb.GeneratedMessage {
  factory QRCode({
    $core.String? id,
    $core.String? recordId,
    $core.String? batchId,
    $core.String? qrData,
    $core.String? qrImageUrl,
    $core.String? scanUrl,
    $0.Timestamp? generatedAt,
    $0.Timestamp? expiresAt,
    $core.bool? isActive,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (recordId != null) result.recordId = recordId;
    if (batchId != null) result.batchId = batchId;
    if (qrData != null) result.qrData = qrData;
    if (qrImageUrl != null) result.qrImageUrl = qrImageUrl;
    if (scanUrl != null) result.scanUrl = scanUrl;
    if (generatedAt != null) result.generatedAt = generatedAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    if (isActive != null) result.isActive = isActive;
    return result;
  }

  QRCode._();

  factory QRCode.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QRCode.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QRCode',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'recordId')
    ..aOS(3, _omitFieldNames ? '' : 'batchId')
    ..aOS(4, _omitFieldNames ? '' : 'qrData')
    ..aOS(5, _omitFieldNames ? '' : 'qrImageUrl')
    ..aOS(6, _omitFieldNames ? '' : 'scanUrl')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'generatedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $0.Timestamp.create)
    ..aOB(9, _omitFieldNames ? '' : 'isActive')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QRCode clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QRCode copyWith(void Function(QRCode) updates) =>
      super.copyWith((message) => updates(message as QRCode)) as QRCode;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QRCode create() => QRCode._();
  @$core.override
  QRCode createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QRCode getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<QRCode>(create);
  static QRCode? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get recordId => $_getSZ(1);
  @$pb.TagNumber(2)
  set recordId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRecordId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecordId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get batchId => $_getSZ(2);
  @$pb.TagNumber(3)
  set batchId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBatchId() => $_has(2);
  @$pb.TagNumber(3)
  void clearBatchId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get qrData => $_getSZ(3);
  @$pb.TagNumber(4)
  set qrData($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasQrData() => $_has(3);
  @$pb.TagNumber(4)
  void clearQrData() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get qrImageUrl => $_getSZ(4);
  @$pb.TagNumber(5)
  set qrImageUrl($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasQrImageUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearQrImageUrl() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get scanUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set scanUrl($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasScanUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearScanUrl() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get generatedAt => $_getN(6);
  @$pb.TagNumber(7)
  set generatedAt($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasGeneratedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearGeneratedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureGeneratedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get expiresAt => $_getN(7);
  @$pb.TagNumber(8)
  set expiresAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasExpiresAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearExpiresAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureExpiresAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.bool get isActive => $_getBF(8);
  @$pb.TagNumber(9)
  set isActive($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIsActive() => $_has(8);
  @$pb.TagNumber(9)
  void clearIsActive() => $_clearField(9);
}

/// ComplianceReport represents a compliance report.
class ComplianceReport extends $pb.GeneratedMessage {
  factory ComplianceReport({
    $core.String? id,
    $core.String? tenantId,
    $core.String? recordId,
    ComplianceStatus? status,
    $core.String? reportType,
    $core.Iterable<$core.String>? findings,
    $core.Iterable<$core.String>? recommendations,
    $core.String? auditor,
    $0.Timestamp? auditDate,
    $0.Timestamp? nextAuditDate,
    $core.double? complianceScore,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (recordId != null) result.recordId = recordId;
    if (status != null) result.status = status;
    if (reportType != null) result.reportType = reportType;
    if (findings != null) result.findings.addAll(findings);
    if (recommendations != null) result.recommendations.addAll(recommendations);
    if (auditor != null) result.auditor = auditor;
    if (auditDate != null) result.auditDate = auditDate;
    if (nextAuditDate != null) result.nextAuditDate = nextAuditDate;
    if (complianceScore != null) result.complianceScore = complianceScore;
    if (metadata != null) result.metadata.addEntries(metadata);
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  ComplianceReport._();

  factory ComplianceReport.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ComplianceReport.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ComplianceReport',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'recordId')
    ..aE<ComplianceStatus>(4, _omitFieldNames ? '' : 'status',
        enumValues: ComplianceStatus.values)
    ..aOS(5, _omitFieldNames ? '' : 'reportType')
    ..pPS(6, _omitFieldNames ? '' : 'findings')
    ..pPS(7, _omitFieldNames ? '' : 'recommendations')
    ..aOS(8, _omitFieldNames ? '' : 'auditor')
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'auditDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'nextAuditDate',
        subBuilder: $0.Timestamp.create)
    ..aD(11, _omitFieldNames ? '' : 'complianceScore')
    ..m<$core.String, $core.String>(12, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'ComplianceReport.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.traceability.v1'))
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComplianceReport clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComplianceReport copyWith(void Function(ComplianceReport) updates) =>
      super.copyWith((message) => updates(message as ComplianceReport))
          as ComplianceReport;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ComplianceReport create() => ComplianceReport._();
  @$core.override
  ComplianceReport createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ComplianceReport getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ComplianceReport>(create);
  static ComplianceReport? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get recordId => $_getSZ(2);
  @$pb.TagNumber(3)
  set recordId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRecordId() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecordId() => $_clearField(3);

  @$pb.TagNumber(4)
  ComplianceStatus get status => $_getN(3);
  @$pb.TagNumber(4)
  set status(ComplianceStatus value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get reportType => $_getSZ(4);
  @$pb.TagNumber(5)
  set reportType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReportType() => $_has(4);
  @$pb.TagNumber(5)
  void clearReportType() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get findings => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get recommendations => $_getList(6);

  @$pb.TagNumber(8)
  $core.String get auditor => $_getSZ(7);
  @$pb.TagNumber(8)
  set auditor($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAuditor() => $_has(7);
  @$pb.TagNumber(8)
  void clearAuditor() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get auditDate => $_getN(8);
  @$pb.TagNumber(9)
  set auditDate($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasAuditDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearAuditDate() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureAuditDate() => $_ensure(8);

  @$pb.TagNumber(10)
  $0.Timestamp get nextAuditDate => $_getN(9);
  @$pb.TagNumber(10)
  set nextAuditDate($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasNextAuditDate() => $_has(9);
  @$pb.TagNumber(10)
  void clearNextAuditDate() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureNextAuditDate() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.double get complianceScore => $_getN(10);
  @$pb.TagNumber(11)
  set complianceScore($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasComplianceScore() => $_has(10);
  @$pb.TagNumber(11)
  void clearComplianceScore() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(11);

  @$pb.TagNumber(13)
  $0.Timestamp get createdAt => $_getN(12);
  @$pb.TagNumber(13)
  set createdAt($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasCreatedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearCreatedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureCreatedAt() => $_ensure(12);
}

/// TraceabilityRecord represents the main traceability record from seed to shelf.
class TraceabilityRecord extends $pb.GeneratedMessage {
  factory TraceabilityRecord({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? batchNumber,
    $core.String? productType,
    $core.String? originCountry,
    $core.String? originRegion,
    $core.String? seedSource,
    $0.Timestamp? plantingDate,
    $0.Timestamp? harvestDate,
    $0.Timestamp? processingDate,
    $0.Timestamp? packagingDate,
    $core.Iterable<SupplyChainEvent>? supplyChainEvents,
    $core.Iterable<Certification>? certifications,
    $core.String? qrCodeData,
    $core.String? blockchainHash,
    $core.Iterable<$core.String>? chainOfCustody,
    ComplianceStatus? complianceStatus,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
    $fixnum.Int64? version,
    $core.String? createdBy,
    $core.String? updatedBy,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (batchNumber != null) result.batchNumber = batchNumber;
    if (productType != null) result.productType = productType;
    if (originCountry != null) result.originCountry = originCountry;
    if (originRegion != null) result.originRegion = originRegion;
    if (seedSource != null) result.seedSource = seedSource;
    if (plantingDate != null) result.plantingDate = plantingDate;
    if (harvestDate != null) result.harvestDate = harvestDate;
    if (processingDate != null) result.processingDate = processingDate;
    if (packagingDate != null) result.packagingDate = packagingDate;
    if (supplyChainEvents != null)
      result.supplyChainEvents.addAll(supplyChainEvents);
    if (certifications != null) result.certifications.addAll(certifications);
    if (qrCodeData != null) result.qrCodeData = qrCodeData;
    if (blockchainHash != null) result.blockchainHash = blockchainHash;
    if (chainOfCustody != null) result.chainOfCustody.addAll(chainOfCustody);
    if (complianceStatus != null) result.complianceStatus = complianceStatus;
    if (metadata != null) result.metadata.addEntries(metadata);
    if (version != null) result.version = version;
    if (createdBy != null) result.createdBy = createdBy;
    if (updatedBy != null) result.updatedBy = updatedBy;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  TraceabilityRecord._();

  factory TraceabilityRecord.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TraceabilityRecord.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TraceabilityRecord',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'cropId')
    ..aOS(6, _omitFieldNames ? '' : 'batchNumber')
    ..aOS(7, _omitFieldNames ? '' : 'productType')
    ..aOS(8, _omitFieldNames ? '' : 'originCountry')
    ..aOS(9, _omitFieldNames ? '' : 'originRegion')
    ..aOS(10, _omitFieldNames ? '' : 'seedSource')
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'plantingDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'harvestDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'processingDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'packagingDate',
        subBuilder: $0.Timestamp.create)
    ..pPM<SupplyChainEvent>(15, _omitFieldNames ? '' : 'supplyChainEvents',
        subBuilder: SupplyChainEvent.create)
    ..pPM<Certification>(16, _omitFieldNames ? '' : 'certifications',
        subBuilder: Certification.create)
    ..aOS(17, _omitFieldNames ? '' : 'qrCodeData')
    ..aOS(18, _omitFieldNames ? '' : 'blockchainHash')
    ..pPS(19, _omitFieldNames ? '' : 'chainOfCustody')
    ..aE<ComplianceStatus>(20, _omitFieldNames ? '' : 'complianceStatus',
        enumValues: ComplianceStatus.values)
    ..m<$core.String, $core.String>(21, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'TraceabilityRecord.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.traceability.v1'))
    ..aInt64(22, _omitFieldNames ? '' : 'version')
    ..aOS(23, _omitFieldNames ? '' : 'createdBy')
    ..aOS(24, _omitFieldNames ? '' : 'updatedBy')
    ..aOM<$0.Timestamp>(25, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(26, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TraceabilityRecord clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TraceabilityRecord copyWith(void Function(TraceabilityRecord) updates) =>
      super.copyWith((message) => updates(message as TraceabilityRecord))
          as TraceabilityRecord;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TraceabilityRecord create() => TraceabilityRecord._();
  @$core.override
  TraceabilityRecord createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TraceabilityRecord getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TraceabilityRecord>(create);
  static TraceabilityRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fieldId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fieldId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cropId => $_getSZ(4);
  @$pb.TagNumber(5)
  set cropId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCropId() => $_has(4);
  @$pb.TagNumber(5)
  void clearCropId() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get batchNumber => $_getSZ(5);
  @$pb.TagNumber(6)
  set batchNumber($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBatchNumber() => $_has(5);
  @$pb.TagNumber(6)
  void clearBatchNumber() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get productType => $_getSZ(6);
  @$pb.TagNumber(7)
  set productType($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasProductType() => $_has(6);
  @$pb.TagNumber(7)
  void clearProductType() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get originCountry => $_getSZ(7);
  @$pb.TagNumber(8)
  set originCountry($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasOriginCountry() => $_has(7);
  @$pb.TagNumber(8)
  void clearOriginCountry() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get originRegion => $_getSZ(8);
  @$pb.TagNumber(9)
  set originRegion($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOriginRegion() => $_has(8);
  @$pb.TagNumber(9)
  void clearOriginRegion() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get seedSource => $_getSZ(9);
  @$pb.TagNumber(10)
  set seedSource($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSeedSource() => $_has(9);
  @$pb.TagNumber(10)
  void clearSeedSource() => $_clearField(10);

  @$pb.TagNumber(11)
  $0.Timestamp get plantingDate => $_getN(10);
  @$pb.TagNumber(11)
  set plantingDate($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasPlantingDate() => $_has(10);
  @$pb.TagNumber(11)
  void clearPlantingDate() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensurePlantingDate() => $_ensure(10);

  @$pb.TagNumber(12)
  $0.Timestamp get harvestDate => $_getN(11);
  @$pb.TagNumber(12)
  set harvestDate($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasHarvestDate() => $_has(11);
  @$pb.TagNumber(12)
  void clearHarvestDate() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensureHarvestDate() => $_ensure(11);

  @$pb.TagNumber(13)
  $0.Timestamp get processingDate => $_getN(12);
  @$pb.TagNumber(13)
  set processingDate($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasProcessingDate() => $_has(12);
  @$pb.TagNumber(13)
  void clearProcessingDate() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureProcessingDate() => $_ensure(12);

  @$pb.TagNumber(14)
  $0.Timestamp get packagingDate => $_getN(13);
  @$pb.TagNumber(14)
  set packagingDate($0.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasPackagingDate() => $_has(13);
  @$pb.TagNumber(14)
  void clearPackagingDate() => $_clearField(14);
  @$pb.TagNumber(14)
  $0.Timestamp ensurePackagingDate() => $_ensure(13);

  @$pb.TagNumber(15)
  $pb.PbList<SupplyChainEvent> get supplyChainEvents => $_getList(14);

  @$pb.TagNumber(16)
  $pb.PbList<Certification> get certifications => $_getList(15);

  @$pb.TagNumber(17)
  $core.String get qrCodeData => $_getSZ(16);
  @$pb.TagNumber(17)
  set qrCodeData($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasQrCodeData() => $_has(16);
  @$pb.TagNumber(17)
  void clearQrCodeData() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get blockchainHash => $_getSZ(17);
  @$pb.TagNumber(18)
  set blockchainHash($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasBlockchainHash() => $_has(17);
  @$pb.TagNumber(18)
  void clearBlockchainHash() => $_clearField(18);

  @$pb.TagNumber(19)
  $pb.PbList<$core.String> get chainOfCustody => $_getList(18);

  @$pb.TagNumber(20)
  ComplianceStatus get complianceStatus => $_getN(19);
  @$pb.TagNumber(20)
  set complianceStatus(ComplianceStatus value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasComplianceStatus() => $_has(19);
  @$pb.TagNumber(20)
  void clearComplianceStatus() => $_clearField(20);

  @$pb.TagNumber(21)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(20);

  @$pb.TagNumber(22)
  $fixnum.Int64 get version => $_getI64(21);
  @$pb.TagNumber(22)
  set version($fixnum.Int64 value) => $_setInt64(21, value);
  @$pb.TagNumber(22)
  $core.bool hasVersion() => $_has(21);
  @$pb.TagNumber(22)
  void clearVersion() => $_clearField(22);

  @$pb.TagNumber(23)
  $core.String get createdBy => $_getSZ(22);
  @$pb.TagNumber(23)
  set createdBy($core.String value) => $_setString(22, value);
  @$pb.TagNumber(23)
  $core.bool hasCreatedBy() => $_has(22);
  @$pb.TagNumber(23)
  void clearCreatedBy() => $_clearField(23);

  @$pb.TagNumber(24)
  $core.String get updatedBy => $_getSZ(23);
  @$pb.TagNumber(24)
  set updatedBy($core.String value) => $_setString(23, value);
  @$pb.TagNumber(24)
  $core.bool hasUpdatedBy() => $_has(23);
  @$pb.TagNumber(24)
  void clearUpdatedBy() => $_clearField(24);

  @$pb.TagNumber(25)
  $0.Timestamp get createdAt => $_getN(24);
  @$pb.TagNumber(25)
  set createdAt($0.Timestamp value) => $_setField(25, value);
  @$pb.TagNumber(25)
  $core.bool hasCreatedAt() => $_has(24);
  @$pb.TagNumber(25)
  void clearCreatedAt() => $_clearField(25);
  @$pb.TagNumber(25)
  $0.Timestamp ensureCreatedAt() => $_ensure(24);

  @$pb.TagNumber(26)
  $0.Timestamp get updatedAt => $_getN(25);
  @$pb.TagNumber(26)
  set updatedAt($0.Timestamp value) => $_setField(26, value);
  @$pb.TagNumber(26)
  $core.bool hasUpdatedAt() => $_has(25);
  @$pb.TagNumber(26)
  void clearUpdatedAt() => $_clearField(26);
  @$pb.TagNumber(26)
  $0.Timestamp ensureUpdatedAt() => $_ensure(25);
}

class CreateRecordRequest extends $pb.GeneratedMessage {
  factory CreateRecordRequest({
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? cropId,
    $core.String? batchNumber,
    $core.String? productType,
    $core.String? originCountry,
    $core.String? originRegion,
    $core.String? seedSource,
    $0.Timestamp? plantingDate,
    $0.Timestamp? harvestDate,
    $0.Timestamp? processingDate,
    $0.Timestamp? packagingDate,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cropId != null) result.cropId = cropId;
    if (batchNumber != null) result.batchNumber = batchNumber;
    if (productType != null) result.productType = productType;
    if (originCountry != null) result.originCountry = originCountry;
    if (originRegion != null) result.originRegion = originRegion;
    if (seedSource != null) result.seedSource = seedSource;
    if (plantingDate != null) result.plantingDate = plantingDate;
    if (harvestDate != null) result.harvestDate = harvestDate;
    if (processingDate != null) result.processingDate = processingDate;
    if (packagingDate != null) result.packagingDate = packagingDate;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  CreateRecordRequest._();

  factory CreateRecordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateRecordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateRecordRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'cropId')
    ..aOS(4, _omitFieldNames ? '' : 'batchNumber')
    ..aOS(5, _omitFieldNames ? '' : 'productType')
    ..aOS(6, _omitFieldNames ? '' : 'originCountry')
    ..aOS(7, _omitFieldNames ? '' : 'originRegion')
    ..aOS(8, _omitFieldNames ? '' : 'seedSource')
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'plantingDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'harvestDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'processingDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'packagingDate',
        subBuilder: $0.Timestamp.create)
    ..m<$core.String, $core.String>(13, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'CreateRecordRequest.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.traceability.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRecordRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRecordRequest copyWith(void Function(CreateRecordRequest) updates) =>
      super.copyWith((message) => updates(message as CreateRecordRequest))
          as CreateRecordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateRecordRequest create() => CreateRecordRequest._();
  @$core.override
  CreateRecordRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateRecordRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateRecordRequest>(create);
  static CreateRecordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get cropId => $_getSZ(2);
  @$pb.TagNumber(3)
  set cropId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCropId() => $_has(2);
  @$pb.TagNumber(3)
  void clearCropId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get batchNumber => $_getSZ(3);
  @$pb.TagNumber(4)
  set batchNumber($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBatchNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearBatchNumber() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get productType => $_getSZ(4);
  @$pb.TagNumber(5)
  set productType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProductType() => $_has(4);
  @$pb.TagNumber(5)
  void clearProductType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get originCountry => $_getSZ(5);
  @$pb.TagNumber(6)
  set originCountry($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOriginCountry() => $_has(5);
  @$pb.TagNumber(6)
  void clearOriginCountry() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get originRegion => $_getSZ(6);
  @$pb.TagNumber(7)
  set originRegion($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOriginRegion() => $_has(6);
  @$pb.TagNumber(7)
  void clearOriginRegion() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get seedSource => $_getSZ(7);
  @$pb.TagNumber(8)
  set seedSource($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSeedSource() => $_has(7);
  @$pb.TagNumber(8)
  void clearSeedSource() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get plantingDate => $_getN(8);
  @$pb.TagNumber(9)
  set plantingDate($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasPlantingDate() => $_has(8);
  @$pb.TagNumber(9)
  void clearPlantingDate() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensurePlantingDate() => $_ensure(8);

  @$pb.TagNumber(10)
  $0.Timestamp get harvestDate => $_getN(9);
  @$pb.TagNumber(10)
  set harvestDate($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasHarvestDate() => $_has(9);
  @$pb.TagNumber(10)
  void clearHarvestDate() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureHarvestDate() => $_ensure(9);

  @$pb.TagNumber(11)
  $0.Timestamp get processingDate => $_getN(10);
  @$pb.TagNumber(11)
  set processingDate($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasProcessingDate() => $_has(10);
  @$pb.TagNumber(11)
  void clearProcessingDate() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureProcessingDate() => $_ensure(10);

  @$pb.TagNumber(12)
  $0.Timestamp get packagingDate => $_getN(11);
  @$pb.TagNumber(12)
  set packagingDate($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasPackagingDate() => $_has(11);
  @$pb.TagNumber(12)
  void clearPackagingDate() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensurePackagingDate() => $_ensure(11);

  @$pb.TagNumber(13)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(12);
}

class CreateRecordResponse extends $pb.GeneratedMessage {
  factory CreateRecordResponse({
    TraceabilityRecord? record,
  }) {
    final result = create();
    if (record != null) result.record = record;
    return result;
  }

  CreateRecordResponse._();

  factory CreateRecordResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateRecordResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateRecordResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOM<TraceabilityRecord>(1, _omitFieldNames ? '' : 'record',
        subBuilder: TraceabilityRecord.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRecordResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateRecordResponse copyWith(void Function(CreateRecordResponse) updates) =>
      super.copyWith((message) => updates(message as CreateRecordResponse))
          as CreateRecordResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateRecordResponse create() => CreateRecordResponse._();
  @$core.override
  CreateRecordResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateRecordResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateRecordResponse>(create);
  static CreateRecordResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TraceabilityRecord get record => $_getN(0);
  @$pb.TagNumber(1)
  set record(TraceabilityRecord value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRecord() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecord() => $_clearField(1);
  @$pb.TagNumber(1)
  TraceabilityRecord ensureRecord() => $_ensure(0);
}

class GetRecordRequest extends $pb.GeneratedMessage {
  factory GetRecordRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetRecordRequest._();

  factory GetRecordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRecordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRecordRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRecordRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRecordRequest copyWith(void Function(GetRecordRequest) updates) =>
      super.copyWith((message) => updates(message as GetRecordRequest))
          as GetRecordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRecordRequest create() => GetRecordRequest._();
  @$core.override
  GetRecordRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRecordRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRecordRequest>(create);
  static GetRecordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetRecordResponse extends $pb.GeneratedMessage {
  factory GetRecordResponse({
    TraceabilityRecord? record,
  }) {
    final result = create();
    if (record != null) result.record = record;
    return result;
  }

  GetRecordResponse._();

  factory GetRecordResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetRecordResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetRecordResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOM<TraceabilityRecord>(1, _omitFieldNames ? '' : 'record',
        subBuilder: TraceabilityRecord.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRecordResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRecordResponse copyWith(void Function(GetRecordResponse) updates) =>
      super.copyWith((message) => updates(message as GetRecordResponse))
          as GetRecordResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRecordResponse create() => GetRecordResponse._();
  @$core.override
  GetRecordResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetRecordResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRecordResponse>(create);
  static GetRecordResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TraceabilityRecord get record => $_getN(0);
  @$pb.TagNumber(1)
  set record(TraceabilityRecord value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRecord() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecord() => $_clearField(1);
  @$pb.TagNumber(1)
  TraceabilityRecord ensureRecord() => $_ensure(0);
}

class ListRecordsRequest extends $pb.GeneratedMessage {
  factory ListRecordsRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? farmId,
    $core.String? cropId,
    $core.String? productType,
    $core.String? originCountry,
    ComplianceStatus? complianceStatus,
    $core.String? search,
    $core.String? orderBy,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (farmId != null) result.farmId = farmId;
    if (cropId != null) result.cropId = cropId;
    if (productType != null) result.productType = productType;
    if (originCountry != null) result.originCountry = originCountry;
    if (complianceStatus != null) result.complianceStatus = complianceStatus;
    if (search != null) result.search = search;
    if (orderBy != null) result.orderBy = orderBy;
    return result;
  }

  ListRecordsRequest._();

  factory ListRecordsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListRecordsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListRecordsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'cropId')
    ..aOS(5, _omitFieldNames ? '' : 'productType')
    ..aOS(6, _omitFieldNames ? '' : 'originCountry')
    ..aE<ComplianceStatus>(7, _omitFieldNames ? '' : 'complianceStatus',
        enumValues: ComplianceStatus.values)
    ..aOS(8, _omitFieldNames ? '' : 'search')
    ..aOS(9, _omitFieldNames ? '' : 'orderBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRecordsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRecordsRequest copyWith(void Function(ListRecordsRequest) updates) =>
      super.copyWith((message) => updates(message as ListRecordsRequest))
          as ListRecordsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRecordsRequest create() => ListRecordsRequest._();
  @$core.override
  ListRecordsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListRecordsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListRecordsRequest>(create);
  static ListRecordsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set pageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get cropId => $_getSZ(3);
  @$pb.TagNumber(4)
  set cropId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCropId() => $_has(3);
  @$pb.TagNumber(4)
  void clearCropId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get productType => $_getSZ(4);
  @$pb.TagNumber(5)
  set productType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProductType() => $_has(4);
  @$pb.TagNumber(5)
  void clearProductType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get originCountry => $_getSZ(5);
  @$pb.TagNumber(6)
  set originCountry($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOriginCountry() => $_has(5);
  @$pb.TagNumber(6)
  void clearOriginCountry() => $_clearField(6);

  @$pb.TagNumber(7)
  ComplianceStatus get complianceStatus => $_getN(6);
  @$pb.TagNumber(7)
  set complianceStatus(ComplianceStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasComplianceStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearComplianceStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get search => $_getSZ(7);
  @$pb.TagNumber(8)
  set search($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSearch() => $_has(7);
  @$pb.TagNumber(8)
  void clearSearch() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get orderBy => $_getSZ(8);
  @$pb.TagNumber(9)
  set orderBy($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOrderBy() => $_has(8);
  @$pb.TagNumber(9)
  void clearOrderBy() => $_clearField(9);
}

class ListRecordsResponse extends $pb.GeneratedMessage {
  factory ListRecordsResponse({
    $core.Iterable<TraceabilityRecord>? records,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (records != null) result.records.addAll(records);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListRecordsResponse._();

  factory ListRecordsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListRecordsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListRecordsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..pPM<TraceabilityRecord>(1, _omitFieldNames ? '' : 'records',
        subBuilder: TraceabilityRecord.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRecordsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRecordsResponse copyWith(void Function(ListRecordsResponse) updates) =>
      super.copyWith((message) => updates(message as ListRecordsResponse))
          as ListRecordsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRecordsResponse create() => ListRecordsResponse._();
  @$core.override
  ListRecordsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListRecordsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListRecordsResponse>(create);
  static ListRecordsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TraceabilityRecord> get records => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class AddSupplyChainEventRequest extends $pb.GeneratedMessage {
  factory AddSupplyChainEventRequest({
    $core.String? recordId,
    SupplyChainEventType? eventType,
    $0.Timestamp? timestamp,
    $core.String? location,
    $core.String? actor,
    $core.String? details,
  }) {
    final result = create();
    if (recordId != null) result.recordId = recordId;
    if (eventType != null) result.eventType = eventType;
    if (timestamp != null) result.timestamp = timestamp;
    if (location != null) result.location = location;
    if (actor != null) result.actor = actor;
    if (details != null) result.details = details;
    return result;
  }

  AddSupplyChainEventRequest._();

  factory AddSupplyChainEventRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddSupplyChainEventRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddSupplyChainEventRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recordId')
    ..aE<SupplyChainEventType>(2, _omitFieldNames ? '' : 'eventType',
        enumValues: SupplyChainEventType.values)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'timestamp',
        subBuilder: $0.Timestamp.create)
    ..aOS(4, _omitFieldNames ? '' : 'location')
    ..aOS(5, _omitFieldNames ? '' : 'actor')
    ..aOS(6, _omitFieldNames ? '' : 'details')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddSupplyChainEventRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddSupplyChainEventRequest copyWith(
          void Function(AddSupplyChainEventRequest) updates) =>
      super.copyWith(
              (message) => updates(message as AddSupplyChainEventRequest))
          as AddSupplyChainEventRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddSupplyChainEventRequest create() => AddSupplyChainEventRequest._();
  @$core.override
  AddSupplyChainEventRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddSupplyChainEventRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddSupplyChainEventRequest>(create);
  static AddSupplyChainEventRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recordId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recordId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecordId() => $_clearField(1);

  @$pb.TagNumber(2)
  SupplyChainEventType get eventType => $_getN(1);
  @$pb.TagNumber(2)
  set eventType(SupplyChainEventType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEventType() => $_has(1);
  @$pb.TagNumber(2)
  void clearEventType() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get timestamp => $_getN(2);
  @$pb.TagNumber(3)
  set timestamp($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureTimestamp() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get location => $_getSZ(3);
  @$pb.TagNumber(4)
  set location($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLocation() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocation() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get actor => $_getSZ(4);
  @$pb.TagNumber(5)
  set actor($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasActor() => $_has(4);
  @$pb.TagNumber(5)
  void clearActor() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get details => $_getSZ(5);
  @$pb.TagNumber(6)
  set details($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDetails() => $_has(5);
  @$pb.TagNumber(6)
  void clearDetails() => $_clearField(6);
}

class AddSupplyChainEventResponse extends $pb.GeneratedMessage {
  factory AddSupplyChainEventResponse({
    SupplyChainEvent? event,
  }) {
    final result = create();
    if (event != null) result.event = event;
    return result;
  }

  AddSupplyChainEventResponse._();

  factory AddSupplyChainEventResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddSupplyChainEventResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddSupplyChainEventResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOM<SupplyChainEvent>(1, _omitFieldNames ? '' : 'event',
        subBuilder: SupplyChainEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddSupplyChainEventResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddSupplyChainEventResponse copyWith(
          void Function(AddSupplyChainEventResponse) updates) =>
      super.copyWith(
              (message) => updates(message as AddSupplyChainEventResponse))
          as AddSupplyChainEventResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddSupplyChainEventResponse create() =>
      AddSupplyChainEventResponse._();
  @$core.override
  AddSupplyChainEventResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddSupplyChainEventResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddSupplyChainEventResponse>(create);
  static AddSupplyChainEventResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SupplyChainEvent get event => $_getN(0);
  @$pb.TagNumber(1)
  set event(SupplyChainEvent value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEvent() => $_has(0);
  @$pb.TagNumber(1)
  void clearEvent() => $_clearField(1);
  @$pb.TagNumber(1)
  SupplyChainEvent ensureEvent() => $_ensure(0);
}

class GetSupplyChainRequest extends $pb.GeneratedMessage {
  factory GetSupplyChainRequest({
    $core.String? recordId,
  }) {
    final result = create();
    if (recordId != null) result.recordId = recordId;
    return result;
  }

  GetSupplyChainRequest._();

  factory GetSupplyChainRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSupplyChainRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSupplyChainRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recordId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSupplyChainRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSupplyChainRequest copyWith(
          void Function(GetSupplyChainRequest) updates) =>
      super.copyWith((message) => updates(message as GetSupplyChainRequest))
          as GetSupplyChainRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSupplyChainRequest create() => GetSupplyChainRequest._();
  @$core.override
  GetSupplyChainRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSupplyChainRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSupplyChainRequest>(create);
  static GetSupplyChainRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recordId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recordId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecordId() => $_clearField(1);
}

class GetSupplyChainResponse extends $pb.GeneratedMessage {
  factory GetSupplyChainResponse({
    $core.Iterable<SupplyChainEvent>? events,
  }) {
    final result = create();
    if (events != null) result.events.addAll(events);
    return result;
  }

  GetSupplyChainResponse._();

  factory GetSupplyChainResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSupplyChainResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSupplyChainResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..pPM<SupplyChainEvent>(1, _omitFieldNames ? '' : 'events',
        subBuilder: SupplyChainEvent.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSupplyChainResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSupplyChainResponse copyWith(
          void Function(GetSupplyChainResponse) updates) =>
      super.copyWith((message) => updates(message as GetSupplyChainResponse))
          as GetSupplyChainResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSupplyChainResponse create() => GetSupplyChainResponse._();
  @$core.override
  GetSupplyChainResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSupplyChainResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSupplyChainResponse>(create);
  static GetSupplyChainResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SupplyChainEvent> get events => $_getList(0);
}

class CreateCertificationRequest extends $pb.GeneratedMessage {
  factory CreateCertificationRequest({
    $core.String? recordId,
    CertificationType? certType,
    $core.String? certNumber,
    $core.String? issuedBy,
    $0.Timestamp? issuedDate,
    $0.Timestamp? expiryDate,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (recordId != null) result.recordId = recordId;
    if (certType != null) result.certType = certType;
    if (certNumber != null) result.certNumber = certNumber;
    if (issuedBy != null) result.issuedBy = issuedBy;
    if (issuedDate != null) result.issuedDate = issuedDate;
    if (expiryDate != null) result.expiryDate = expiryDate;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  CreateCertificationRequest._();

  factory CreateCertificationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateCertificationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateCertificationRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recordId')
    ..aE<CertificationType>(2, _omitFieldNames ? '' : 'certType',
        enumValues: CertificationType.values)
    ..aOS(3, _omitFieldNames ? '' : 'certNumber')
    ..aOS(4, _omitFieldNames ? '' : 'issuedBy')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'issuedDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'expiryDate',
        subBuilder: $0.Timestamp.create)
    ..m<$core.String, $core.String>(7, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'CreateCertificationRequest.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.traceability.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCertificationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCertificationRequest copyWith(
          void Function(CreateCertificationRequest) updates) =>
      super.copyWith(
              (message) => updates(message as CreateCertificationRequest))
          as CreateCertificationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateCertificationRequest create() => CreateCertificationRequest._();
  @$core.override
  CreateCertificationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateCertificationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateCertificationRequest>(create);
  static CreateCertificationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recordId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recordId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecordId() => $_clearField(1);

  @$pb.TagNumber(2)
  CertificationType get certType => $_getN(1);
  @$pb.TagNumber(2)
  set certType(CertificationType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCertType() => $_has(1);
  @$pb.TagNumber(2)
  void clearCertType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get certNumber => $_getSZ(2);
  @$pb.TagNumber(3)
  set certNumber($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCertNumber() => $_has(2);
  @$pb.TagNumber(3)
  void clearCertNumber() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get issuedBy => $_getSZ(3);
  @$pb.TagNumber(4)
  set issuedBy($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIssuedBy() => $_has(3);
  @$pb.TagNumber(4)
  void clearIssuedBy() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get issuedDate => $_getN(4);
  @$pb.TagNumber(5)
  set issuedDate($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasIssuedDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearIssuedDate() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureIssuedDate() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.Timestamp get expiryDate => $_getN(5);
  @$pb.TagNumber(6)
  set expiryDate($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasExpiryDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpiryDate() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureExpiryDate() => $_ensure(5);

  @$pb.TagNumber(7)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(6);
}

class CreateCertificationResponse extends $pb.GeneratedMessage {
  factory CreateCertificationResponse({
    Certification? certification,
  }) {
    final result = create();
    if (certification != null) result.certification = certification;
    return result;
  }

  CreateCertificationResponse._();

  factory CreateCertificationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateCertificationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateCertificationResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOM<Certification>(1, _omitFieldNames ? '' : 'certification',
        subBuilder: Certification.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCertificationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCertificationResponse copyWith(
          void Function(CreateCertificationResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CreateCertificationResponse))
          as CreateCertificationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateCertificationResponse create() =>
      CreateCertificationResponse._();
  @$core.override
  CreateCertificationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateCertificationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateCertificationResponse>(create);
  static CreateCertificationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Certification get certification => $_getN(0);
  @$pb.TagNumber(1)
  set certification(Certification value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCertification() => $_has(0);
  @$pb.TagNumber(1)
  void clearCertification() => $_clearField(1);
  @$pb.TagNumber(1)
  Certification ensureCertification() => $_ensure(0);
}

class GetCertificationRequest extends $pb.GeneratedMessage {
  factory GetCertificationRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetCertificationRequest._();

  factory GetCertificationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCertificationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCertificationRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCertificationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCertificationRequest copyWith(
          void Function(GetCertificationRequest) updates) =>
      super.copyWith((message) => updates(message as GetCertificationRequest))
          as GetCertificationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCertificationRequest create() => GetCertificationRequest._();
  @$core.override
  GetCertificationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCertificationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCertificationRequest>(create);
  static GetCertificationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetCertificationResponse extends $pb.GeneratedMessage {
  factory GetCertificationResponse({
    Certification? certification,
  }) {
    final result = create();
    if (certification != null) result.certification = certification;
    return result;
  }

  GetCertificationResponse._();

  factory GetCertificationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCertificationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCertificationResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOM<Certification>(1, _omitFieldNames ? '' : 'certification',
        subBuilder: Certification.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCertificationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCertificationResponse copyWith(
          void Function(GetCertificationResponse) updates) =>
      super.copyWith((message) => updates(message as GetCertificationResponse))
          as GetCertificationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCertificationResponse create() => GetCertificationResponse._();
  @$core.override
  GetCertificationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCertificationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCertificationResponse>(create);
  static GetCertificationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Certification get certification => $_getN(0);
  @$pb.TagNumber(1)
  set certification(Certification value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCertification() => $_has(0);
  @$pb.TagNumber(1)
  void clearCertification() => $_clearField(1);
  @$pb.TagNumber(1)
  Certification ensureCertification() => $_ensure(0);
}

class ListCertificationsRequest extends $pb.GeneratedMessage {
  factory ListCertificationsRequest({
    $core.String? recordId,
    CertificationType? certType,
    CertificationStatus? status,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (recordId != null) result.recordId = recordId;
    if (certType != null) result.certType = certType;
    if (status != null) result.status = status;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListCertificationsRequest._();

  factory ListCertificationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListCertificationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListCertificationsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recordId')
    ..aE<CertificationType>(2, _omitFieldNames ? '' : 'certType',
        enumValues: CertificationType.values)
    ..aE<CertificationStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: CertificationStatus.values)
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aOS(5, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCertificationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCertificationsRequest copyWith(
          void Function(ListCertificationsRequest) updates) =>
      super.copyWith((message) => updates(message as ListCertificationsRequest))
          as ListCertificationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListCertificationsRequest create() => ListCertificationsRequest._();
  @$core.override
  ListCertificationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListCertificationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListCertificationsRequest>(create);
  static ListCertificationsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recordId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recordId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecordId() => $_clearField(1);

  @$pb.TagNumber(2)
  CertificationType get certType => $_getN(1);
  @$pb.TagNumber(2)
  set certType(CertificationType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCertType() => $_has(1);
  @$pb.TagNumber(2)
  void clearCertType() => $_clearField(2);

  @$pb.TagNumber(3)
  CertificationStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(CertificationStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pageSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageSize($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get pageToken => $_getSZ(4);
  @$pb.TagNumber(5)
  set pageToken($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageToken() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageToken() => $_clearField(5);
}

class ListCertificationsResponse extends $pb.GeneratedMessage {
  factory ListCertificationsResponse({
    $core.Iterable<Certification>? certifications,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (certifications != null) result.certifications.addAll(certifications);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListCertificationsResponse._();

  factory ListCertificationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListCertificationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListCertificationsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..pPM<Certification>(1, _omitFieldNames ? '' : 'certifications',
        subBuilder: Certification.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCertificationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCertificationsResponse copyWith(
          void Function(ListCertificationsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListCertificationsResponse))
          as ListCertificationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListCertificationsResponse create() => ListCertificationsResponse._();
  @$core.override
  ListCertificationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListCertificationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListCertificationsResponse>(create);
  static ListCertificationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Certification> get certifications => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class VerifyCertificationRequest extends $pb.GeneratedMessage {
  factory VerifyCertificationRequest({
    $core.String? id,
    $core.String? verifiedBy,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (verifiedBy != null) result.verifiedBy = verifiedBy;
    return result;
  }

  VerifyCertificationRequest._();

  factory VerifyCertificationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VerifyCertificationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VerifyCertificationRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'verifiedBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyCertificationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyCertificationRequest copyWith(
          void Function(VerifyCertificationRequest) updates) =>
      super.copyWith(
              (message) => updates(message as VerifyCertificationRequest))
          as VerifyCertificationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyCertificationRequest create() => VerifyCertificationRequest._();
  @$core.override
  VerifyCertificationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VerifyCertificationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifyCertificationRequest>(create);
  static VerifyCertificationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get verifiedBy => $_getSZ(1);
  @$pb.TagNumber(2)
  set verifiedBy($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVerifiedBy() => $_has(1);
  @$pb.TagNumber(2)
  void clearVerifiedBy() => $_clearField(2);
}

class VerifyCertificationResponse extends $pb.GeneratedMessage {
  factory VerifyCertificationResponse({
    Certification? certification,
  }) {
    final result = create();
    if (certification != null) result.certification = certification;
    return result;
  }

  VerifyCertificationResponse._();

  factory VerifyCertificationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VerifyCertificationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VerifyCertificationResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOM<Certification>(1, _omitFieldNames ? '' : 'certification',
        subBuilder: Certification.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyCertificationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyCertificationResponse copyWith(
          void Function(VerifyCertificationResponse) updates) =>
      super.copyWith(
              (message) => updates(message as VerifyCertificationResponse))
          as VerifyCertificationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyCertificationResponse create() =>
      VerifyCertificationResponse._();
  @$core.override
  VerifyCertificationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VerifyCertificationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifyCertificationResponse>(create);
  static VerifyCertificationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Certification get certification => $_getN(0);
  @$pb.TagNumber(1)
  set certification(Certification value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCertification() => $_has(0);
  @$pb.TagNumber(1)
  void clearCertification() => $_clearField(1);
  @$pb.TagNumber(1)
  Certification ensureCertification() => $_ensure(0);
}

class CreateBatchRequest extends $pb.GeneratedMessage {
  factory CreateBatchRequest({
    $core.String? recordId,
    $core.String? batchNumber,
    $core.int? quantity,
    $core.String? unit,
    $0.Timestamp? productionDate,
    $0.Timestamp? expiryDate,
    $core.String? storageConditions,
    $core.String? qualityGrade,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? metadata,
  }) {
    final result = create();
    if (recordId != null) result.recordId = recordId;
    if (batchNumber != null) result.batchNumber = batchNumber;
    if (quantity != null) result.quantity = quantity;
    if (unit != null) result.unit = unit;
    if (productionDate != null) result.productionDate = productionDate;
    if (expiryDate != null) result.expiryDate = expiryDate;
    if (storageConditions != null) result.storageConditions = storageConditions;
    if (qualityGrade != null) result.qualityGrade = qualityGrade;
    if (metadata != null) result.metadata.addEntries(metadata);
    return result;
  }

  CreateBatchRequest._();

  factory CreateBatchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateBatchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateBatchRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recordId')
    ..aOS(2, _omitFieldNames ? '' : 'batchNumber')
    ..aI(3, _omitFieldNames ? '' : 'quantity')
    ..aOS(4, _omitFieldNames ? '' : 'unit')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'productionDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'expiryDate',
        subBuilder: $0.Timestamp.create)
    ..aOS(7, _omitFieldNames ? '' : 'storageConditions')
    ..aOS(8, _omitFieldNames ? '' : 'qualityGrade')
    ..m<$core.String, $core.String>(9, _omitFieldNames ? '' : 'metadata',
        entryClassName: 'CreateBatchRequest.MetadataEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.traceability.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBatchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBatchRequest copyWith(void Function(CreateBatchRequest) updates) =>
      super.copyWith((message) => updates(message as CreateBatchRequest))
          as CreateBatchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateBatchRequest create() => CreateBatchRequest._();
  @$core.override
  CreateBatchRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateBatchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateBatchRequest>(create);
  static CreateBatchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recordId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recordId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecordId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get batchNumber => $_getSZ(1);
  @$pb.TagNumber(2)
  set batchNumber($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBatchNumber() => $_has(1);
  @$pb.TagNumber(2)
  void clearBatchNumber() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get quantity => $_getIZ(2);
  @$pb.TagNumber(3)
  set quantity($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuantity() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get unit => $_getSZ(3);
  @$pb.TagNumber(4)
  set unit($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUnit() => $_has(3);
  @$pb.TagNumber(4)
  void clearUnit() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get productionDate => $_getN(4);
  @$pb.TagNumber(5)
  set productionDate($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasProductionDate() => $_has(4);
  @$pb.TagNumber(5)
  void clearProductionDate() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureProductionDate() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.Timestamp get expiryDate => $_getN(5);
  @$pb.TagNumber(6)
  set expiryDate($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasExpiryDate() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpiryDate() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureExpiryDate() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get storageConditions => $_getSZ(6);
  @$pb.TagNumber(7)
  set storageConditions($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStorageConditions() => $_has(6);
  @$pb.TagNumber(7)
  void clearStorageConditions() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get qualityGrade => $_getSZ(7);
  @$pb.TagNumber(8)
  set qualityGrade($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasQualityGrade() => $_has(7);
  @$pb.TagNumber(8)
  void clearQualityGrade() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbMap<$core.String, $core.String> get metadata => $_getMap(8);
}

class CreateBatchResponse extends $pb.GeneratedMessage {
  factory CreateBatchResponse({
    BatchRecord? batch,
  }) {
    final result = create();
    if (batch != null) result.batch = batch;
    return result;
  }

  CreateBatchResponse._();

  factory CreateBatchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreateBatchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreateBatchResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOM<BatchRecord>(1, _omitFieldNames ? '' : 'batch',
        subBuilder: BatchRecord.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBatchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBatchResponse copyWith(void Function(CreateBatchResponse) updates) =>
      super.copyWith((message) => updates(message as CreateBatchResponse))
          as CreateBatchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateBatchResponse create() => CreateBatchResponse._();
  @$core.override
  CreateBatchResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreateBatchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateBatchResponse>(create);
  static CreateBatchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BatchRecord get batch => $_getN(0);
  @$pb.TagNumber(1)
  set batch(BatchRecord value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBatch() => $_has(0);
  @$pb.TagNumber(1)
  void clearBatch() => $_clearField(1);
  @$pb.TagNumber(1)
  BatchRecord ensureBatch() => $_ensure(0);
}

class GetBatchRequest extends $pb.GeneratedMessage {
  factory GetBatchRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetBatchRequest._();

  factory GetBatchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBatchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBatchRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBatchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBatchRequest copyWith(void Function(GetBatchRequest) updates) =>
      super.copyWith((message) => updates(message as GetBatchRequest))
          as GetBatchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBatchRequest create() => GetBatchRequest._();
  @$core.override
  GetBatchRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBatchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBatchRequest>(create);
  static GetBatchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetBatchResponse extends $pb.GeneratedMessage {
  factory GetBatchResponse({
    BatchRecord? batch,
  }) {
    final result = create();
    if (batch != null) result.batch = batch;
    return result;
  }

  GetBatchResponse._();

  factory GetBatchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetBatchResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBatchResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOM<BatchRecord>(1, _omitFieldNames ? '' : 'batch',
        subBuilder: BatchRecord.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBatchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBatchResponse copyWith(void Function(GetBatchResponse) updates) =>
      super.copyWith((message) => updates(message as GetBatchResponse))
          as GetBatchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBatchResponse create() => GetBatchResponse._();
  @$core.override
  GetBatchResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetBatchResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBatchResponse>(create);
  static GetBatchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BatchRecord get batch => $_getN(0);
  @$pb.TagNumber(1)
  set batch(BatchRecord value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBatch() => $_has(0);
  @$pb.TagNumber(1)
  void clearBatch() => $_clearField(1);
  @$pb.TagNumber(1)
  BatchRecord ensureBatch() => $_ensure(0);
}

class ListBatchesRequest extends $pb.GeneratedMessage {
  factory ListBatchesRequest({
    $core.String? recordId,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (recordId != null) result.recordId = recordId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListBatchesRequest._();

  factory ListBatchesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListBatchesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListBatchesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recordId')
    ..aI(2, _omitFieldNames ? '' : 'pageSize')
    ..aOS(3, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBatchesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBatchesRequest copyWith(void Function(ListBatchesRequest) updates) =>
      super.copyWith((message) => updates(message as ListBatchesRequest))
          as ListBatchesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBatchesRequest create() => ListBatchesRequest._();
  @$core.override
  ListBatchesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListBatchesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListBatchesRequest>(create);
  static ListBatchesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recordId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recordId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecordId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get pageToken => $_getSZ(2);
  @$pb.TagNumber(3)
  set pageToken($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageToken() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageToken() => $_clearField(3);
}

class ListBatchesResponse extends $pb.GeneratedMessage {
  factory ListBatchesResponse({
    $core.Iterable<BatchRecord>? batches,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (batches != null) result.batches.addAll(batches);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListBatchesResponse._();

  factory ListBatchesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListBatchesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListBatchesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..pPM<BatchRecord>(1, _omitFieldNames ? '' : 'batches',
        subBuilder: BatchRecord.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBatchesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBatchesResponse copyWith(void Function(ListBatchesResponse) updates) =>
      super.copyWith((message) => updates(message as ListBatchesResponse))
          as ListBatchesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBatchesResponse create() => ListBatchesResponse._();
  @$core.override
  ListBatchesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListBatchesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListBatchesResponse>(create);
  static ListBatchesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<BatchRecord> get batches => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class GenerateQRCodeRequest extends $pb.GeneratedMessage {
  factory GenerateQRCodeRequest({
    $core.String? recordId,
    $core.String? batchId,
    $core.String? baseUrl,
  }) {
    final result = create();
    if (recordId != null) result.recordId = recordId;
    if (batchId != null) result.batchId = batchId;
    if (baseUrl != null) result.baseUrl = baseUrl;
    return result;
  }

  GenerateQRCodeRequest._();

  factory GenerateQRCodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateQRCodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateQRCodeRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recordId')
    ..aOS(2, _omitFieldNames ? '' : 'batchId')
    ..aOS(3, _omitFieldNames ? '' : 'baseUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateQRCodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateQRCodeRequest copyWith(
          void Function(GenerateQRCodeRequest) updates) =>
      super.copyWith((message) => updates(message as GenerateQRCodeRequest))
          as GenerateQRCodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateQRCodeRequest create() => GenerateQRCodeRequest._();
  @$core.override
  GenerateQRCodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateQRCodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateQRCodeRequest>(create);
  static GenerateQRCodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recordId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recordId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecordId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get batchId => $_getSZ(1);
  @$pb.TagNumber(2)
  set batchId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBatchId() => $_has(1);
  @$pb.TagNumber(2)
  void clearBatchId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get baseUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set baseUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBaseUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearBaseUrl() => $_clearField(3);
}

class GenerateQRCodeResponse extends $pb.GeneratedMessage {
  factory GenerateQRCodeResponse({
    QRCode? qrCode,
  }) {
    final result = create();
    if (qrCode != null) result.qrCode = qrCode;
    return result;
  }

  GenerateQRCodeResponse._();

  factory GenerateQRCodeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateQRCodeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateQRCodeResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOM<QRCode>(1, _omitFieldNames ? '' : 'qrCode', subBuilder: QRCode.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateQRCodeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateQRCodeResponse copyWith(
          void Function(GenerateQRCodeResponse) updates) =>
      super.copyWith((message) => updates(message as GenerateQRCodeResponse))
          as GenerateQRCodeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateQRCodeResponse create() => GenerateQRCodeResponse._();
  @$core.override
  GenerateQRCodeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateQRCodeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateQRCodeResponse>(create);
  static GenerateQRCodeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  QRCode get qrCode => $_getN(0);
  @$pb.TagNumber(1)
  set qrCode(QRCode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasQrCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearQrCode() => $_clearField(1);
  @$pb.TagNumber(1)
  QRCode ensureQrCode() => $_ensure(0);
}

class VerifyQRCodeRequest extends $pb.GeneratedMessage {
  factory VerifyQRCodeRequest({
    $core.String? qrData,
  }) {
    final result = create();
    if (qrData != null) result.qrData = qrData;
    return result;
  }

  VerifyQRCodeRequest._();

  factory VerifyQRCodeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VerifyQRCodeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VerifyQRCodeRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'qrData')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyQRCodeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyQRCodeRequest copyWith(void Function(VerifyQRCodeRequest) updates) =>
      super.copyWith((message) => updates(message as VerifyQRCodeRequest))
          as VerifyQRCodeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyQRCodeRequest create() => VerifyQRCodeRequest._();
  @$core.override
  VerifyQRCodeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VerifyQRCodeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifyQRCodeRequest>(create);
  static VerifyQRCodeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get qrData => $_getSZ(0);
  @$pb.TagNumber(1)
  set qrData($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQrData() => $_has(0);
  @$pb.TagNumber(1)
  void clearQrData() => $_clearField(1);
}

class VerifyQRCodeResponse extends $pb.GeneratedMessage {
  factory VerifyQRCodeResponse({
    $core.bool? valid,
    TraceabilityRecord? record,
    BatchRecord? batch,
  }) {
    final result = create();
    if (valid != null) result.valid = valid;
    if (record != null) result.record = record;
    if (batch != null) result.batch = batch;
    return result;
  }

  VerifyQRCodeResponse._();

  factory VerifyQRCodeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory VerifyQRCodeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'VerifyQRCodeResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'valid')
    ..aOM<TraceabilityRecord>(2, _omitFieldNames ? '' : 'record',
        subBuilder: TraceabilityRecord.create)
    ..aOM<BatchRecord>(3, _omitFieldNames ? '' : 'batch',
        subBuilder: BatchRecord.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyQRCodeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyQRCodeResponse copyWith(void Function(VerifyQRCodeResponse) updates) =>
      super.copyWith((message) => updates(message as VerifyQRCodeResponse))
          as VerifyQRCodeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyQRCodeResponse create() => VerifyQRCodeResponse._();
  @$core.override
  VerifyQRCodeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static VerifyQRCodeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifyQRCodeResponse>(create);
  static VerifyQRCodeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get valid => $_getBF(0);
  @$pb.TagNumber(1)
  set valid($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValid() => $_has(0);
  @$pb.TagNumber(1)
  void clearValid() => $_clearField(1);

  @$pb.TagNumber(2)
  TraceabilityRecord get record => $_getN(1);
  @$pb.TagNumber(2)
  set record(TraceabilityRecord value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasRecord() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecord() => $_clearField(2);
  @$pb.TagNumber(2)
  TraceabilityRecord ensureRecord() => $_ensure(1);

  @$pb.TagNumber(3)
  BatchRecord get batch => $_getN(2);
  @$pb.TagNumber(3)
  set batch(BatchRecord value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBatch() => $_has(2);
  @$pb.TagNumber(3)
  void clearBatch() => $_clearField(3);
  @$pb.TagNumber(3)
  BatchRecord ensureBatch() => $_ensure(2);
}

class GenerateComplianceReportRequest extends $pb.GeneratedMessage {
  factory GenerateComplianceReportRequest({
    $core.String? recordId,
    $core.String? reportType,
    $core.String? auditor,
  }) {
    final result = create();
    if (recordId != null) result.recordId = recordId;
    if (reportType != null) result.reportType = reportType;
    if (auditor != null) result.auditor = auditor;
    return result;
  }

  GenerateComplianceReportRequest._();

  factory GenerateComplianceReportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateComplianceReportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateComplianceReportRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'recordId')
    ..aOS(2, _omitFieldNames ? '' : 'reportType')
    ..aOS(3, _omitFieldNames ? '' : 'auditor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateComplianceReportRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateComplianceReportRequest copyWith(
          void Function(GenerateComplianceReportRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GenerateComplianceReportRequest))
          as GenerateComplianceReportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateComplianceReportRequest create() =>
      GenerateComplianceReportRequest._();
  @$core.override
  GenerateComplianceReportRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateComplianceReportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateComplianceReportRequest>(
          create);
  static GenerateComplianceReportRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get recordId => $_getSZ(0);
  @$pb.TagNumber(1)
  set recordId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecordId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecordId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reportType => $_getSZ(1);
  @$pb.TagNumber(2)
  set reportType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReportType() => $_has(1);
  @$pb.TagNumber(2)
  void clearReportType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get auditor => $_getSZ(2);
  @$pb.TagNumber(3)
  set auditor($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAuditor() => $_has(2);
  @$pb.TagNumber(3)
  void clearAuditor() => $_clearField(3);
}

class GenerateComplianceReportResponse extends $pb.GeneratedMessage {
  factory GenerateComplianceReportResponse({
    ComplianceReport? report,
  }) {
    final result = create();
    if (report != null) result.report = report;
    return result;
  }

  GenerateComplianceReportResponse._();

  factory GenerateComplianceReportResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateComplianceReportResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateComplianceReportResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.traceability.v1'),
      createEmptyInstance: create)
    ..aOM<ComplianceReport>(1, _omitFieldNames ? '' : 'report',
        subBuilder: ComplianceReport.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateComplianceReportResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateComplianceReportResponse copyWith(
          void Function(GenerateComplianceReportResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GenerateComplianceReportResponse))
          as GenerateComplianceReportResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateComplianceReportResponse create() =>
      GenerateComplianceReportResponse._();
  @$core.override
  GenerateComplianceReportResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateComplianceReportResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateComplianceReportResponse>(
          create);
  static GenerateComplianceReportResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ComplianceReport get report => $_getN(0);
  @$pb.TagNumber(1)
  set report(ComplianceReport value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReport() => $_has(0);
  @$pb.TagNumber(1)
  void clearReport() => $_clearField(1);
  @$pb.TagNumber(1)
  ComplianceReport ensureReport() => $_ensure(0);
}

/// TraceabilityService provides end-to-end organic traceability from seed to shelf.
class TraceabilityServiceApi {
  final $pb.RpcClient _client;

  TraceabilityServiceApi(this._client);

  /// CreateRecord creates a new traceability record.
  $async.Future<CreateRecordResponse> createRecord(
          $pb.ClientContext? ctx, CreateRecordRequest request) =>
      _client.invoke<CreateRecordResponse>(ctx, 'TraceabilityService',
          'CreateRecord', request, CreateRecordResponse());

  /// GetRecord retrieves a traceability record by ID.
  $async.Future<GetRecordResponse> getRecord(
          $pb.ClientContext? ctx, GetRecordRequest request) =>
      _client.invoke<GetRecordResponse>(ctx, 'TraceabilityService', 'GetRecord',
          request, GetRecordResponse());

  /// ListRecords lists traceability records with filtering and pagination.
  $async.Future<ListRecordsResponse> listRecords(
          $pb.ClientContext? ctx, ListRecordsRequest request) =>
      _client.invoke<ListRecordsResponse>(ctx, 'TraceabilityService',
          'ListRecords', request, ListRecordsResponse());

  /// AddSupplyChainEvent adds a new event to the supply chain.
  $async.Future<AddSupplyChainEventResponse> addSupplyChainEvent(
          $pb.ClientContext? ctx, AddSupplyChainEventRequest request) =>
      _client.invoke<AddSupplyChainEventResponse>(ctx, 'TraceabilityService',
          'AddSupplyChainEvent', request, AddSupplyChainEventResponse());

  /// GetSupplyChain retrieves the full supply chain for a record.
  $async.Future<GetSupplyChainResponse> getSupplyChain(
          $pb.ClientContext? ctx, GetSupplyChainRequest request) =>
      _client.invoke<GetSupplyChainResponse>(ctx, 'TraceabilityService',
          'GetSupplyChain', request, GetSupplyChainResponse());

  /// CreateCertification creates a new certification for a record.
  $async.Future<CreateCertificationResponse> createCertification(
          $pb.ClientContext? ctx, CreateCertificationRequest request) =>
      _client.invoke<CreateCertificationResponse>(ctx, 'TraceabilityService',
          'CreateCertification', request, CreateCertificationResponse());

  /// GetCertification retrieves a certification by ID.
  $async.Future<GetCertificationResponse> getCertification(
          $pb.ClientContext? ctx, GetCertificationRequest request) =>
      _client.invoke<GetCertificationResponse>(ctx, 'TraceabilityService',
          'GetCertification', request, GetCertificationResponse());

  /// ListCertifications lists certifications with filtering and pagination.
  $async.Future<ListCertificationsResponse> listCertifications(
          $pb.ClientContext? ctx, ListCertificationsRequest request) =>
      _client.invoke<ListCertificationsResponse>(ctx, 'TraceabilityService',
          'ListCertifications', request, ListCertificationsResponse());

  /// VerifyCertification verifies a certification.
  $async.Future<VerifyCertificationResponse> verifyCertification(
          $pb.ClientContext? ctx, VerifyCertificationRequest request) =>
      _client.invoke<VerifyCertificationResponse>(ctx, 'TraceabilityService',
          'VerifyCertification', request, VerifyCertificationResponse());

  /// CreateBatch creates a new batch record.
  $async.Future<CreateBatchResponse> createBatch(
          $pb.ClientContext? ctx, CreateBatchRequest request) =>
      _client.invoke<CreateBatchResponse>(ctx, 'TraceabilityService',
          'CreateBatch', request, CreateBatchResponse());

  /// GetBatch retrieves a batch record by ID.
  $async.Future<GetBatchResponse> getBatch(
          $pb.ClientContext? ctx, GetBatchRequest request) =>
      _client.invoke<GetBatchResponse>(
          ctx, 'TraceabilityService', 'GetBatch', request, GetBatchResponse());

  /// ListBatches lists batch records with filtering and pagination.
  $async.Future<ListBatchesResponse> listBatches(
          $pb.ClientContext? ctx, ListBatchesRequest request) =>
      _client.invoke<ListBatchesResponse>(ctx, 'TraceabilityService',
          'ListBatches', request, ListBatchesResponse());

  /// GenerateQRCode generates a QR code for a record or batch.
  $async.Future<GenerateQRCodeResponse> generateQRCode(
          $pb.ClientContext? ctx, GenerateQRCodeRequest request) =>
      _client.invoke<GenerateQRCodeResponse>(ctx, 'TraceabilityService',
          'GenerateQRCode', request, GenerateQRCodeResponse());

  /// VerifyQRCode verifies a QR code and returns the associated record.
  $async.Future<VerifyQRCodeResponse> verifyQRCode(
          $pb.ClientContext? ctx, VerifyQRCodeRequest request) =>
      _client.invoke<VerifyQRCodeResponse>(ctx, 'TraceabilityService',
          'VerifyQRCode', request, VerifyQRCodeResponse());

  /// GenerateComplianceReport generates a compliance report for a record.
  $async.Future<GenerateComplianceReportResponse> generateComplianceReport(
          $pb.ClientContext? ctx, GenerateComplianceReportRequest request) =>
      _client.invoke<GenerateComplianceReportResponse>(
          ctx,
          'TraceabilityService',
          'GenerateComplianceReport',
          request,
          GenerateComplianceReportResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
