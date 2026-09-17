// This is a generated file - do not edit.
//
// Generated from soillab.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'soillab.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'soillab.pbenum.dart';

/// Lab is an accredited soil testing laboratory.
class Lab extends $pb.GeneratedMessage {
  factory Lab({
    $core.String? id,
    $core.String? name,
    $core.String? accreditation,
    $core.String? contactEmail,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? columnAliases,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (accreditation != null) result.accreditation = accreditation;
    if (contactEmail != null) result.contactEmail = contactEmail;
    if (columnAliases != null) result.columnAliases.addEntries(columnAliases);
    return result;
  }

  Lab._();

  factory Lab.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Lab.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Lab',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'accreditation')
    ..aOS(4, _omitFieldNames ? '' : 'contactEmail')
    ..m<$core.String, $core.String>(5, _omitFieldNames ? '' : 'columnAliases',
        entryClassName: 'Lab.ColumnAliasesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.soillab.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Lab clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Lab copyWith(void Function(Lab) updates) =>
      super.copyWith((message) => updates(message as Lab)) as Lab;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Lab create() => Lab._();
  @$core.override
  Lab createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Lab getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Lab>(create);
  static Lab? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get accreditation => $_getSZ(2);
  @$pb.TagNumber(3)
  set accreditation($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAccreditation() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccreditation() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get contactEmail => $_getSZ(3);
  @$pb.TagNumber(4)
  set contactEmail($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasContactEmail() => $_has(3);
  @$pb.TagNumber(4)
  void clearContactEmail() => $_clearField(4);

  /// The column names this lab uses, so its CSVs parse without a person having
  /// to rename headers before every upload.
  @$pb.TagNumber(5)
  $pb.PbMap<$core.String, $core.String> get columnAliases => $_getMap(4);
}

/// LabResult is one analyte reading from a report row.
class LabResult extends $pb.GeneratedMessage {
  factory LabResult({
    $core.String? analyte,
    $core.double? value,
    $core.String? unit,
    $core.bool? suspect,
    $core.String? note,
  }) {
    final result = create();
    if (analyte != null) result.analyte = analyte;
    if (value != null) result.value = value;
    if (unit != null) result.unit = unit;
    if (suspect != null) result.suspect = suspect;
    if (note != null) result.note = note;
    return result;
  }

  LabResult._();

  factory LabResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LabResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LabResult',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'analyte')
    ..aD(2, _omitFieldNames ? '' : 'value')
    ..aOS(3, _omitFieldNames ? '' : 'unit')
    ..aOB(4, _omitFieldNames ? '' : 'suspect')
    ..aOS(5, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabResult copyWith(void Function(LabResult) updates) =>
      super.copyWith((message) => updates(message as LabResult)) as LabResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LabResult create() => LabResult._();
  @$core.override
  LabResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LabResult getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LabResult>(create);
  static LabResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get analyte => $_getSZ(0);
  @$pb.TagNumber(1)
  set analyte($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAnalyte() => $_has(0);
  @$pb.TagNumber(1)
  void clearAnalyte() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get unit => $_getSZ(2);
  @$pb.TagNumber(3)
  set unit($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnit() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnit() => $_clearField(3);

  /// True when the value was outside the range this analyte can plausibly take,
  /// which is usually a unit mismatch in the lab's export.
  @$pb.TagNumber(4)
  $core.bool get suspect => $_getBF(3);
  @$pb.TagNumber(4)
  set suspect($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSuspect() => $_has(3);
  @$pb.TagNumber(4)
  void clearSuspect() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get note => $_getSZ(4);
  @$pb.TagNumber(5)
  set note($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNote() => $_has(4);
  @$pb.TagNumber(5)
  void clearNote() => $_clearField(5);
}

/// ReportRow is one sample's worth of results.
class ReportRow extends $pb.GeneratedMessage {
  factory ReportRow({
    $core.int? lineNumber,
    $core.String? sampleRef,
    $core.String? fieldId,
    $core.double? depthCm,
    $0.Timestamp? collectedOn,
    $core.Iterable<LabResult>? results,
    $core.String? blocker,
  }) {
    final result = create();
    if (lineNumber != null) result.lineNumber = lineNumber;
    if (sampleRef != null) result.sampleRef = sampleRef;
    if (fieldId != null) result.fieldId = fieldId;
    if (depthCm != null) result.depthCm = depthCm;
    if (collectedOn != null) result.collectedOn = collectedOn;
    if (results != null) result.results.addAll(results);
    if (blocker != null) result.blocker = blocker;
    return result;
  }

  ReportRow._();

  factory ReportRow.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReportRow.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReportRow',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'lineNumber')
    ..aOS(2, _omitFieldNames ? '' : 'sampleRef')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aD(4, _omitFieldNames ? '' : 'depthCm')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'collectedOn',
        subBuilder: $0.Timestamp.create)
    ..pPM<LabResult>(6, _omitFieldNames ? '' : 'results',
        subBuilder: LabResult.create)
    ..aOS(7, _omitFieldNames ? '' : 'blocker')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReportRow clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReportRow copyWith(void Function(ReportRow) updates) =>
      super.copyWith((message) => updates(message as ReportRow)) as ReportRow;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReportRow create() => ReportRow._();
  @$core.override
  ReportRow createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReportRow getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReportRow>(create);
  static ReportRow? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get lineNumber => $_getIZ(0);
  @$pb.TagNumber(1)
  set lineNumber($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLineNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearLineNumber() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sampleRef => $_getSZ(1);
  @$pb.TagNumber(2)
  set sampleRef($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSampleRef() => $_has(1);
  @$pb.TagNumber(2)
  void clearSampleRef() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fieldId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get depthCm => $_getN(3);
  @$pb.TagNumber(4)
  set depthCm($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDepthCm() => $_has(3);
  @$pb.TagNumber(4)
  void clearDepthCm() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get collectedOn => $_getN(4);
  @$pb.TagNumber(5)
  set collectedOn($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCollectedOn() => $_has(4);
  @$pb.TagNumber(5)
  void clearCollectedOn() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureCollectedOn() => $_ensure(4);

  @$pb.TagNumber(6)
  $pb.PbList<LabResult> get results => $_getList(5);

  /// Why this row cannot be applied, if it cannot.
  @$pb.TagNumber(7)
  $core.String get blocker => $_getSZ(6);
  @$pb.TagNumber(7)
  set blocker($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBlocker() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlocker() => $_clearField(7);
}

/// LabReport is one uploaded file and what came of it.
class LabReport extends $pb.GeneratedMessage {
  factory LabReport({
    $core.String? id,
    $core.String? labId,
    $core.String? labName,
    ReportFormat? format,
    $core.String? filename,
    $core.String? storageUrl,
    $core.String? contentSha256,
    ImportStatus? status,
    $core.int? rowCount,
    $core.int? appliedCount,
    $core.int? blockedCount,
    $core.Iterable<ReportRow>? rows,
    $0.Timestamp? uploadedAt,
    $0.Timestamp? appliedAt,
    $core.String? uploadedBy,
    $core.String? rejectionReason,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (labId != null) result.labId = labId;
    if (labName != null) result.labName = labName;
    if (format != null) result.format = format;
    if (filename != null) result.filename = filename;
    if (storageUrl != null) result.storageUrl = storageUrl;
    if (contentSha256 != null) result.contentSha256 = contentSha256;
    if (status != null) result.status = status;
    if (rowCount != null) result.rowCount = rowCount;
    if (appliedCount != null) result.appliedCount = appliedCount;
    if (blockedCount != null) result.blockedCount = blockedCount;
    if (rows != null) result.rows.addAll(rows);
    if (uploadedAt != null) result.uploadedAt = uploadedAt;
    if (appliedAt != null) result.appliedAt = appliedAt;
    if (uploadedBy != null) result.uploadedBy = uploadedBy;
    if (rejectionReason != null) result.rejectionReason = rejectionReason;
    return result;
  }

  LabReport._();

  factory LabReport.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LabReport.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LabReport',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'labId')
    ..aOS(3, _omitFieldNames ? '' : 'labName')
    ..aE<ReportFormat>(4, _omitFieldNames ? '' : 'format',
        enumValues: ReportFormat.values)
    ..aOS(5, _omitFieldNames ? '' : 'filename')
    ..aOS(6, _omitFieldNames ? '' : 'storageUrl')
    ..aOS(7, _omitFieldNames ? '' : 'contentSha256')
    ..aE<ImportStatus>(8, _omitFieldNames ? '' : 'status',
        enumValues: ImportStatus.values)
    ..aI(9, _omitFieldNames ? '' : 'rowCount')
    ..aI(10, _omitFieldNames ? '' : 'appliedCount')
    ..aI(11, _omitFieldNames ? '' : 'blockedCount')
    ..pPM<ReportRow>(12, _omitFieldNames ? '' : 'rows',
        subBuilder: ReportRow.create)
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'uploadedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'appliedAt',
        subBuilder: $0.Timestamp.create)
    ..aOS(15, _omitFieldNames ? '' : 'uploadedBy')
    ..aOS(16, _omitFieldNames ? '' : 'rejectionReason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabReport clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabReport copyWith(void Function(LabReport) updates) =>
      super.copyWith((message) => updates(message as LabReport)) as LabReport;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LabReport create() => LabReport._();
  @$core.override
  LabReport createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LabReport getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LabReport>(create);
  static LabReport? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get labId => $_getSZ(1);
  @$pb.TagNumber(2)
  set labId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabId() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get labName => $_getSZ(2);
  @$pb.TagNumber(3)
  set labName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLabName() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabName() => $_clearField(3);

  @$pb.TagNumber(4)
  ReportFormat get format => $_getN(3);
  @$pb.TagNumber(4)
  set format(ReportFormat value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFormat() => $_has(3);
  @$pb.TagNumber(4)
  void clearFormat() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get filename => $_getSZ(4);
  @$pb.TagNumber(5)
  set filename($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFilename() => $_has(4);
  @$pb.TagNumber(5)
  void clearFilename() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get storageUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set storageUrl($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStorageUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearStorageUrl() => $_clearField(6);

  /// Content hash, so the same file uploaded twice is recognised rather than
  /// creating a second set of soil samples for one set of results.
  @$pb.TagNumber(7)
  $core.String get contentSha256 => $_getSZ(6);
  @$pb.TagNumber(7)
  set contentSha256($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasContentSha256() => $_has(6);
  @$pb.TagNumber(7)
  void clearContentSha256() => $_clearField(7);

  @$pb.TagNumber(8)
  ImportStatus get status => $_getN(7);
  @$pb.TagNumber(8)
  set status(ImportStatus value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasStatus() => $_has(7);
  @$pb.TagNumber(8)
  void clearStatus() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get rowCount => $_getIZ(8);
  @$pb.TagNumber(9)
  set rowCount($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRowCount() => $_has(8);
  @$pb.TagNumber(9)
  void clearRowCount() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get appliedCount => $_getIZ(9);
  @$pb.TagNumber(10)
  set appliedCount($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasAppliedCount() => $_has(9);
  @$pb.TagNumber(10)
  void clearAppliedCount() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get blockedCount => $_getIZ(10);
  @$pb.TagNumber(11)
  set blockedCount($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasBlockedCount() => $_has(10);
  @$pb.TagNumber(11)
  void clearBlockedCount() => $_clearField(11);

  @$pb.TagNumber(12)
  $pb.PbList<ReportRow> get rows => $_getList(11);

  @$pb.TagNumber(13)
  $0.Timestamp get uploadedAt => $_getN(12);
  @$pb.TagNumber(13)
  set uploadedAt($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasUploadedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearUploadedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureUploadedAt() => $_ensure(12);

  @$pb.TagNumber(14)
  $0.Timestamp get appliedAt => $_getN(13);
  @$pb.TagNumber(14)
  set appliedAt($0.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasAppliedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearAppliedAt() => $_clearField(14);
  @$pb.TagNumber(14)
  $0.Timestamp ensureAppliedAt() => $_ensure(13);

  @$pb.TagNumber(15)
  $core.String get uploadedBy => $_getSZ(14);
  @$pb.TagNumber(15)
  set uploadedBy($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasUploadedBy() => $_has(14);
  @$pb.TagNumber(15)
  void clearUploadedBy() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get rejectionReason => $_getSZ(15);
  @$pb.TagNumber(16)
  set rejectionReason($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasRejectionReason() => $_has(15);
  @$pb.TagNumber(16)
  void clearRejectionReason() => $_clearField(16);
}

class RegisterLabRequest extends $pb.GeneratedMessage {
  factory RegisterLabRequest({
    $core.String? name,
    $core.String? accreditation,
    $core.String? contactEmail,
    $core.Iterable<$core.MapEntry<$core.String, $core.String>>? columnAliases,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (accreditation != null) result.accreditation = accreditation;
    if (contactEmail != null) result.contactEmail = contactEmail;
    if (columnAliases != null) result.columnAliases.addEntries(columnAliases);
    return result;
  }

  RegisterLabRequest._();

  factory RegisterLabRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterLabRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterLabRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'accreditation')
    ..aOS(3, _omitFieldNames ? '' : 'contactEmail')
    ..m<$core.String, $core.String>(4, _omitFieldNames ? '' : 'columnAliases',
        entryClassName: 'RegisterLabRequest.ColumnAliasesEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.OS,
        packageName: const $pb.PackageName('agriculture.soillab.v1'))
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterLabRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterLabRequest copyWith(void Function(RegisterLabRequest) updates) =>
      super.copyWith((message) => updates(message as RegisterLabRequest))
          as RegisterLabRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterLabRequest create() => RegisterLabRequest._();
  @$core.override
  RegisterLabRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterLabRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterLabRequest>(create);
  static RegisterLabRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get accreditation => $_getSZ(1);
  @$pb.TagNumber(2)
  set accreditation($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAccreditation() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccreditation() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get contactEmail => $_getSZ(2);
  @$pb.TagNumber(3)
  set contactEmail($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasContactEmail() => $_has(2);
  @$pb.TagNumber(3)
  void clearContactEmail() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbMap<$core.String, $core.String> get columnAliases => $_getMap(3);
}

class RegisterLabResponse extends $pb.GeneratedMessage {
  factory RegisterLabResponse({
    Lab? lab,
  }) {
    final result = create();
    if (lab != null) result.lab = lab;
    return result;
  }

  RegisterLabResponse._();

  factory RegisterLabResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegisterLabResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegisterLabResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aOM<Lab>(1, _omitFieldNames ? '' : 'lab', subBuilder: Lab.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterLabResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegisterLabResponse copyWith(void Function(RegisterLabResponse) updates) =>
      super.copyWith((message) => updates(message as RegisterLabResponse))
          as RegisterLabResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegisterLabResponse create() => RegisterLabResponse._();
  @$core.override
  RegisterLabResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RegisterLabResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegisterLabResponse>(create);
  static RegisterLabResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Lab get lab => $_getN(0);
  @$pb.TagNumber(1)
  set lab(Lab value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasLab() => $_has(0);
  @$pb.TagNumber(1)
  void clearLab() => $_clearField(1);
  @$pb.TagNumber(1)
  Lab ensureLab() => $_ensure(0);
}

class ListLabsRequest extends $pb.GeneratedMessage {
  factory ListLabsRequest({
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListLabsRequest._();

  factory ListLabsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListLabsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListLabsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLabsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLabsRequest copyWith(void Function(ListLabsRequest) updates) =>
      super.copyWith((message) => updates(message as ListLabsRequest))
          as ListLabsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListLabsRequest create() => ListLabsRequest._();
  @$core.override
  ListLabsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListLabsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListLabsRequest>(create);
  static ListLabsRequest? _defaultInstance;

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
}

class ListLabsResponse extends $pb.GeneratedMessage {
  factory ListLabsResponse({
    $core.Iterable<Lab>? labs,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (labs != null) result.labs.addAll(labs);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListLabsResponse._();

  factory ListLabsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListLabsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListLabsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..pPM<Lab>(1, _omitFieldNames ? '' : 'labs', subBuilder: Lab.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLabsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListLabsResponse copyWith(void Function(ListLabsResponse) updates) =>
      super.copyWith((message) => updates(message as ListLabsResponse))
          as ListLabsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListLabsResponse create() => ListLabsResponse._();
  @$core.override
  ListLabsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListLabsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListLabsResponse>(create);
  static ListLabsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Lab> get labs => $_getList(0);

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

class UploadReportRequest extends $pb.GeneratedMessage {
  factory UploadReportRequest({
    $core.String? labId,
    ReportFormat? format,
    $core.String? filename,
    $core.List<$core.int>? content,
  }) {
    final result = create();
    if (labId != null) result.labId = labId;
    if (format != null) result.format = format;
    if (filename != null) result.filename = filename;
    if (content != null) result.content = content;
    return result;
  }

  UploadReportRequest._();

  factory UploadReportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadReportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadReportRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'labId')
    ..aE<ReportFormat>(2, _omitFieldNames ? '' : 'format',
        enumValues: ReportFormat.values)
    ..aOS(3, _omitFieldNames ? '' : 'filename')
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadReportRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadReportRequest copyWith(void Function(UploadReportRequest) updates) =>
      super.copyWith((message) => updates(message as UploadReportRequest))
          as UploadReportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadReportRequest create() => UploadReportRequest._();
  @$core.override
  UploadReportRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadReportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadReportRequest>(create);
  static UploadReportRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get labId => $_getSZ(0);
  @$pb.TagNumber(1)
  set labId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabId() => $_clearField(1);

  @$pb.TagNumber(2)
  ReportFormat get format => $_getN(1);
  @$pb.TagNumber(2)
  set format(ReportFormat value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasFormat() => $_has(1);
  @$pb.TagNumber(2)
  void clearFormat() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get filename => $_getSZ(2);
  @$pb.TagNumber(3)
  set filename($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFilename() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilename() => $_clearField(3);

  /// The file itself. CSVs are parsed here; a PDF is stored and left for a
  /// person, because reading numbers off a lab's PDF layout is guesswork and
  /// the numbers drive fertiliser rates.
  @$pb.TagNumber(4)
  $core.List<$core.int> get content => $_getN(3);
  @$pb.TagNumber(4)
  set content($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => $_clearField(4);
}

class UploadReportResponse extends $pb.GeneratedMessage {
  factory UploadReportResponse({
    LabReport? report,
    $core.bool? duplicate,
  }) {
    final result = create();
    if (report != null) result.report = report;
    if (duplicate != null) result.duplicate = duplicate;
    return result;
  }

  UploadReportResponse._();

  factory UploadReportResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UploadReportResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UploadReportResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aOM<LabReport>(1, _omitFieldNames ? '' : 'report',
        subBuilder: LabReport.create)
    ..aOB(2, _omitFieldNames ? '' : 'duplicate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadReportResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UploadReportResponse copyWith(void Function(UploadReportResponse) updates) =>
      super.copyWith((message) => updates(message as UploadReportResponse))
          as UploadReportResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UploadReportResponse create() => UploadReportResponse._();
  @$core.override
  UploadReportResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UploadReportResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UploadReportResponse>(create);
  static UploadReportResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LabReport get report => $_getN(0);
  @$pb.TagNumber(1)
  set report(LabReport value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReport() => $_has(0);
  @$pb.TagNumber(1)
  void clearReport() => $_clearField(1);
  @$pb.TagNumber(1)
  LabReport ensureReport() => $_ensure(0);

  /// True when this exact file has been uploaded before; the existing report is
  /// returned rather than a second one created.
  @$pb.TagNumber(2)
  $core.bool get duplicate => $_getBF(1);
  @$pb.TagNumber(2)
  set duplicate($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDuplicate() => $_has(1);
  @$pb.TagNumber(2)
  void clearDuplicate() => $_clearField(2);
}

class GetReportRequest extends $pb.GeneratedMessage {
  factory GetReportRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetReportRequest._();

  factory GetReportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReportRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReportRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReportRequest copyWith(void Function(GetReportRequest) updates) =>
      super.copyWith((message) => updates(message as GetReportRequest))
          as GetReportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReportRequest create() => GetReportRequest._();
  @$core.override
  GetReportRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReportRequest>(create);
  static GetReportRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetReportResponse extends $pb.GeneratedMessage {
  factory GetReportResponse({
    LabReport? report,
  }) {
    final result = create();
    if (report != null) result.report = report;
    return result;
  }

  GetReportResponse._();

  factory GetReportResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReportResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReportResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aOM<LabReport>(1, _omitFieldNames ? '' : 'report',
        subBuilder: LabReport.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReportResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReportResponse copyWith(void Function(GetReportResponse) updates) =>
      super.copyWith((message) => updates(message as GetReportResponse))
          as GetReportResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReportResponse create() => GetReportResponse._();
  @$core.override
  GetReportResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReportResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReportResponse>(create);
  static GetReportResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LabReport get report => $_getN(0);
  @$pb.TagNumber(1)
  set report(LabReport value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReport() => $_has(0);
  @$pb.TagNumber(1)
  void clearReport() => $_clearField(1);
  @$pb.TagNumber(1)
  LabReport ensureReport() => $_ensure(0);
}

class ListReportsRequest extends $pb.GeneratedMessage {
  factory ListReportsRequest({
    $core.String? labId,
    ImportStatus? status,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (labId != null) result.labId = labId;
    if (status != null) result.status = status;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListReportsRequest._();

  factory ListReportsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListReportsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListReportsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'labId')
    ..aE<ImportStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: ImportStatus.values)
    ..aI(3, _omitFieldNames ? '' : 'pageSize')
    ..aOS(4, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReportsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReportsRequest copyWith(void Function(ListReportsRequest) updates) =>
      super.copyWith((message) => updates(message as ListReportsRequest))
          as ListReportsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListReportsRequest create() => ListReportsRequest._();
  @$core.override
  ListReportsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListReportsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListReportsRequest>(create);
  static ListReportsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get labId => $_getSZ(0);
  @$pb.TagNumber(1)
  set labId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabId() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabId() => $_clearField(1);

  @$pb.TagNumber(2)
  ImportStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(ImportStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get pageToken => $_getSZ(3);
  @$pb.TagNumber(4)
  set pageToken($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageToken() => $_clearField(4);
}

class ListReportsResponse extends $pb.GeneratedMessage {
  factory ListReportsResponse({
    $core.Iterable<LabReport>? reports,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (reports != null) result.reports.addAll(reports);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListReportsResponse._();

  factory ListReportsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListReportsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListReportsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..pPM<LabReport>(1, _omitFieldNames ? '' : 'reports',
        subBuilder: LabReport.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReportsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReportsResponse copyWith(void Function(ListReportsResponse) updates) =>
      super.copyWith((message) => updates(message as ListReportsResponse))
          as ListReportsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListReportsResponse create() => ListReportsResponse._();
  @$core.override
  ListReportsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListReportsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListReportsResponse>(create);
  static ListReportsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<LabReport> get reports => $_getList(0);

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

class ApplyReportRequest extends $pb.GeneratedMessage {
  factory ApplyReportRequest({
    $core.String? id,
    $core.bool? skipBlocked,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (skipBlocked != null) result.skipBlocked = skipBlocked;
    return result;
  }

  ApplyReportRequest._();

  factory ApplyReportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApplyReportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApplyReportRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOB(2, _omitFieldNames ? '' : 'skipBlocked')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyReportRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyReportRequest copyWith(void Function(ApplyReportRequest) updates) =>
      super.copyWith((message) => updates(message as ApplyReportRequest))
          as ApplyReportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApplyReportRequest create() => ApplyReportRequest._();
  @$core.override
  ApplyReportRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApplyReportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApplyReportRequest>(create);
  static ApplyReportRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  /// Apply the rows that are usable even though others are blocked. Off by
  /// default: a partial import that nobody notices leaves a field with results
  /// from half its samples.
  @$pb.TagNumber(2)
  $core.bool get skipBlocked => $_getBF(1);
  @$pb.TagNumber(2)
  set skipBlocked($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSkipBlocked() => $_has(1);
  @$pb.TagNumber(2)
  void clearSkipBlocked() => $_clearField(2);
}

class ApplyReportResponse extends $pb.GeneratedMessage {
  factory ApplyReportResponse({
    LabReport? report,
    $core.Iterable<$core.String>? createdSampleIds,
  }) {
    final result = create();
    if (report != null) result.report = report;
    if (createdSampleIds != null)
      result.createdSampleIds.addAll(createdSampleIds);
    return result;
  }

  ApplyReportResponse._();

  factory ApplyReportResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ApplyReportResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ApplyReportResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aOM<LabReport>(1, _omitFieldNames ? '' : 'report',
        subBuilder: LabReport.create)
    ..pPS(2, _omitFieldNames ? '' : 'createdSampleIds')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyReportResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ApplyReportResponse copyWith(void Function(ApplyReportResponse) updates) =>
      super.copyWith((message) => updates(message as ApplyReportResponse))
          as ApplyReportResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ApplyReportResponse create() => ApplyReportResponse._();
  @$core.override
  ApplyReportResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ApplyReportResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ApplyReportResponse>(create);
  static ApplyReportResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LabReport get report => $_getN(0);
  @$pb.TagNumber(1)
  set report(LabReport value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReport() => $_has(0);
  @$pb.TagNumber(1)
  void clearReport() => $_clearField(1);
  @$pb.TagNumber(1)
  LabReport ensureReport() => $_ensure(0);

  /// The soil-service sample ids created, so a caller can follow them.
  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get createdSampleIds => $_getList(1);
}

class RejectReportRequest extends $pb.GeneratedMessage {
  factory RejectReportRequest({
    $core.String? id,
    $core.String? reason,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (reason != null) result.reason = reason;
    return result;
  }

  RejectReportRequest._();

  factory RejectReportRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RejectReportRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RejectReportRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectReportRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectReportRequest copyWith(void Function(RejectReportRequest) updates) =>
      super.copyWith((message) => updates(message as RejectReportRequest))
          as RejectReportRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RejectReportRequest create() => RejectReportRequest._();
  @$core.override
  RejectReportRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RejectReportRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RejectReportRequest>(create);
  static RejectReportRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

class RejectReportResponse extends $pb.GeneratedMessage {
  factory RejectReportResponse({
    LabReport? report,
  }) {
    final result = create();
    if (report != null) result.report = report;
    return result;
  }

  RejectReportResponse._();

  factory RejectReportResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RejectReportResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RejectReportResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.soillab.v1'),
      createEmptyInstance: create)
    ..aOM<LabReport>(1, _omitFieldNames ? '' : 'report',
        subBuilder: LabReport.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectReportResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RejectReportResponse copyWith(void Function(RejectReportResponse) updates) =>
      super.copyWith((message) => updates(message as RejectReportResponse))
          as RejectReportResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RejectReportResponse create() => RejectReportResponse._();
  @$core.override
  RejectReportResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RejectReportResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RejectReportResponse>(create);
  static RejectReportResponse? _defaultInstance;

  @$pb.TagNumber(1)
  LabReport get report => $_getN(0);
  @$pb.TagNumber(1)
  set report(LabReport value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasReport() => $_has(0);
  @$pb.TagNumber(1)
  void clearReport() => $_clearField(1);
  @$pb.TagNumber(1)
  LabReport ensureReport() => $_ensure(0);
}

/// SoilLabService imports laboratory reports and maps them onto soil samples.
class SoilLabServiceApi {
  final $pb.RpcClient _client;

  SoilLabServiceApi(this._client);

  $async.Future<RegisterLabResponse> registerLab(
          $pb.ClientContext? ctx, RegisterLabRequest request) =>
      _client.invoke<RegisterLabResponse>(
          ctx, 'SoilLabService', 'RegisterLab', request, RegisterLabResponse());
  $async.Future<ListLabsResponse> listLabs(
          $pb.ClientContext? ctx, ListLabsRequest request) =>
      _client.invoke<ListLabsResponse>(
          ctx, 'SoilLabService', 'ListLabs', request, ListLabsResponse());
  $async.Future<UploadReportResponse> uploadReport(
          $pb.ClientContext? ctx, UploadReportRequest request) =>
      _client.invoke<UploadReportResponse>(ctx, 'SoilLabService',
          'UploadReport', request, UploadReportResponse());
  $async.Future<GetReportResponse> getReport(
          $pb.ClientContext? ctx, GetReportRequest request) =>
      _client.invoke<GetReportResponse>(
          ctx, 'SoilLabService', 'GetReport', request, GetReportResponse());
  $async.Future<ListReportsResponse> listReports(
          $pb.ClientContext? ctx, ListReportsRequest request) =>
      _client.invoke<ListReportsResponse>(
          ctx, 'SoilLabService', 'ListReports', request, ListReportsResponse());
  $async.Future<ApplyReportResponse> applyReport(
          $pb.ClientContext? ctx, ApplyReportRequest request) =>
      _client.invoke<ApplyReportResponse>(
          ctx, 'SoilLabService', 'ApplyReport', request, ApplyReportResponse());
  $async.Future<RejectReportResponse> rejectReport(
          $pb.ClientContext? ctx, RejectReportRequest request) =>
      _client.invoke<RejectReportResponse>(ctx, 'SoilLabService',
          'RejectReport', request, RejectReportResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
