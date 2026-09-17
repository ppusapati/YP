// This is a generated file - do not edit.
//
// Generated from sustainability.proto.

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

import 'sustainability.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'sustainability.pbenum.dart';

/// InputUse is one recorded application to a field.
class InputUse extends $pb.GeneratedMessage {
  factory InputUse({
    $core.String? id,
    $core.String? fieldId,
    $core.String? crop,
    $core.int? year,
    InputCategory? category,
    $core.String? product,
    $core.double? quantity,
    $core.String? unit,
    $core.double? nitrogenKg,
    $0.Timestamp? appliedOn,
    $core.String? appliedBy,
    $core.String? notes,
    $core.bool? organicPermitted,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fieldId != null) result.fieldId = fieldId;
    if (crop != null) result.crop = crop;
    if (year != null) result.year = year;
    if (category != null) result.category = category;
    if (product != null) result.product = product;
    if (quantity != null) result.quantity = quantity;
    if (unit != null) result.unit = unit;
    if (nitrogenKg != null) result.nitrogenKg = nitrogenKg;
    if (appliedOn != null) result.appliedOn = appliedOn;
    if (appliedBy != null) result.appliedBy = appliedBy;
    if (notes != null) result.notes = notes;
    if (organicPermitted != null) result.organicPermitted = organicPermitted;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  InputUse._();

  factory InputUse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InputUse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InputUse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'crop')
    ..aI(4, _omitFieldNames ? '' : 'year')
    ..aE<InputCategory>(5, _omitFieldNames ? '' : 'category',
        enumValues: InputCategory.values)
    ..aOS(6, _omitFieldNames ? '' : 'product')
    ..aD(7, _omitFieldNames ? '' : 'quantity')
    ..aOS(8, _omitFieldNames ? '' : 'unit')
    ..aD(9, _omitFieldNames ? '' : 'nitrogenKg')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'appliedOn',
        subBuilder: $0.Timestamp.create)
    ..aOS(11, _omitFieldNames ? '' : 'appliedBy')
    ..aOS(12, _omitFieldNames ? '' : 'notes')
    ..aOB(13, _omitFieldNames ? '' : 'organicPermitted')
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InputUse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InputUse copyWith(void Function(InputUse) updates) =>
      super.copyWith((message) => updates(message as InputUse)) as InputUse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InputUse create() => InputUse._();
  @$core.override
  InputUse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InputUse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InputUse>(create);
  static InputUse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get crop => $_getSZ(2);
  @$pb.TagNumber(3)
  set crop($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCrop() => $_has(2);
  @$pb.TagNumber(3)
  void clearCrop() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get year => $_getIZ(3);
  @$pb.TagNumber(4)
  set year($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasYear() => $_has(3);
  @$pb.TagNumber(4)
  void clearYear() => $_clearField(4);

  @$pb.TagNumber(5)
  InputCategory get category => $_getN(4);
  @$pb.TagNumber(5)
  set category(InputCategory value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCategory() => $_has(4);
  @$pb.TagNumber(5)
  void clearCategory() => $_clearField(5);

  /// The product as the farmer knows it: "Urea 46%", "DAP", "HSD".
  @$pb.TagNumber(6)
  $core.String get product => $_getSZ(5);
  @$pb.TagNumber(6)
  set product($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProduct() => $_has(5);
  @$pb.TagNumber(6)
  void clearProduct() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get quantity => $_getN(6);
  @$pb.TagNumber(7)
  set quantity($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasQuantity() => $_has(6);
  @$pb.TagNumber(7)
  void clearQuantity() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get unit => $_getSZ(7);
  @$pb.TagNumber(8)
  set unit($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUnit() => $_has(7);
  @$pb.TagNumber(8)
  void clearUnit() => $_clearField(8);

  /// Nitrogen actually delivered, in kg. Derived from the product where the
  /// service knows it, and overridable where the farmer knows better.
  @$pb.TagNumber(9)
  $core.double get nitrogenKg => $_getN(8);
  @$pb.TagNumber(9)
  set nitrogenKg($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasNitrogenKg() => $_has(8);
  @$pb.TagNumber(9)
  void clearNitrogenKg() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Timestamp get appliedOn => $_getN(9);
  @$pb.TagNumber(10)
  set appliedOn($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasAppliedOn() => $_has(9);
  @$pb.TagNumber(10)
  void clearAppliedOn() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureAppliedOn() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.String get appliedBy => $_getSZ(10);
  @$pb.TagNumber(11)
  set appliedBy($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAppliedBy() => $_has(10);
  @$pb.TagNumber(11)
  void clearAppliedBy() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get notes => $_getSZ(11);
  @$pb.TagNumber(12)
  set notes($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasNotes() => $_has(11);
  @$pb.TagNumber(12)
  void clearNotes() => $_clearField(12);

  /// Whether this input is allowed under organic certification. Recorded at the
  /// time of use, because the standards change and a certificate has to be
  /// defensible against the rules that applied on the day.
  @$pb.TagNumber(13)
  $core.bool get organicPermitted => $_getBF(12);
  @$pb.TagNumber(13)
  set organicPermitted($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasOrganicPermitted() => $_has(12);
  @$pb.TagNumber(13)
  void clearOrganicPermitted() => $_clearField(13);

  @$pb.TagNumber(14)
  $0.Timestamp get createdAt => $_getN(13);
  @$pb.TagNumber(14)
  set createdAt($0.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasCreatedAt() => $_has(13);
  @$pb.TagNumber(14)
  void clearCreatedAt() => $_clearField(14);
  @$pb.TagNumber(14)
  $0.Timestamp ensureCreatedAt() => $_ensure(13);
}

/// EmissionLine is one source's contribution to a footprint.
class EmissionLine extends $pb.GeneratedMessage {
  factory EmissionLine({
    EmissionSource? source,
    $core.double? kgCo2e,
    $core.String? basis,
    Completeness? completeness,
  }) {
    final result = create();
    if (source != null) result.source = source;
    if (kgCo2e != null) result.kgCo2e = kgCo2e;
    if (basis != null) result.basis = basis;
    if (completeness != null) result.completeness = completeness;
    return result;
  }

  EmissionLine._();

  factory EmissionLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EmissionLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EmissionLine',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aE<EmissionSource>(1, _omitFieldNames ? '' : 'source',
        enumValues: EmissionSource.values)
    ..aD(2, _omitFieldNames ? '' : 'kgCo2e')
    ..aOS(3, _omitFieldNames ? '' : 'basis')
    ..aE<Completeness>(4, _omitFieldNames ? '' : 'completeness',
        enumValues: Completeness.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EmissionLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EmissionLine copyWith(void Function(EmissionLine) updates) =>
      super.copyWith((message) => updates(message as EmissionLine))
          as EmissionLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EmissionLine create() => EmissionLine._();
  @$core.override
  EmissionLine createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EmissionLine getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EmissionLine>(create);
  static EmissionLine? _defaultInstance;

  @$pb.TagNumber(1)
  EmissionSource get source => $_getN(0);
  @$pb.TagNumber(1)
  set source(EmissionSource value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSource() => $_has(0);
  @$pb.TagNumber(1)
  void clearSource() => $_clearField(1);

  /// In kg of CO2 equivalent, using AR6 100-year warming potentials.
  @$pb.TagNumber(2)
  $core.double get kgCo2e => $_getN(1);
  @$pb.TagNumber(2)
  set kgCo2e($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasKgCo2e() => $_has(1);
  @$pb.TagNumber(2)
  void clearKgCo2e() => $_clearField(2);

  /// What the figure was worked out from, in plain words.
  @$pb.TagNumber(3)
  $core.String get basis => $_getSZ(2);
  @$pb.TagNumber(3)
  set basis($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBasis() => $_has(2);
  @$pb.TagNumber(3)
  void clearBasis() => $_clearField(3);

  @$pb.TagNumber(4)
  Completeness get completeness => $_getN(3);
  @$pb.TagNumber(4)
  set completeness(Completeness value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCompleteness() => $_has(3);
  @$pb.TagNumber(4)
  void clearCompleteness() => $_clearField(4);
}

/// Footprint is one field's greenhouse gas account for one crop year.
class Footprint extends $pb.GeneratedMessage {
  factory Footprint({
    $core.String? id,
    $core.String? fieldId,
    $core.String? farmId,
    $core.String? crop,
    $core.int? year,
    $core.double? areaHectares,
    WaterRegime? waterRegime,
    $core.Iterable<EmissionLine>? lines,
    $core.double? totalKgCo2e,
    $core.double? kgCo2ePerHectare,
    $core.double? kgCo2ePerTonne,
    $core.double? yieldTonnes,
    $core.Iterable<EmissionSource>? missingSources,
    $core.bool? complete,
    $0.Timestamp? computedAt,
    $core.String? method,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (crop != null) result.crop = crop;
    if (year != null) result.year = year;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (waterRegime != null) result.waterRegime = waterRegime;
    if (lines != null) result.lines.addAll(lines);
    if (totalKgCo2e != null) result.totalKgCo2e = totalKgCo2e;
    if (kgCo2ePerHectare != null) result.kgCo2ePerHectare = kgCo2ePerHectare;
    if (kgCo2ePerTonne != null) result.kgCo2ePerTonne = kgCo2ePerTonne;
    if (yieldTonnes != null) result.yieldTonnes = yieldTonnes;
    if (missingSources != null) result.missingSources.addAll(missingSources);
    if (complete != null) result.complete = complete;
    if (computedAt != null) result.computedAt = computedAt;
    if (method != null) result.method = method;
    return result;
  }

  Footprint._();

  factory Footprint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Footprint.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Footprint',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'crop')
    ..aI(5, _omitFieldNames ? '' : 'year')
    ..aD(6, _omitFieldNames ? '' : 'areaHectares')
    ..aE<WaterRegime>(7, _omitFieldNames ? '' : 'waterRegime',
        enumValues: WaterRegime.values)
    ..pPM<EmissionLine>(8, _omitFieldNames ? '' : 'lines',
        subBuilder: EmissionLine.create)
    ..aD(9, _omitFieldNames ? '' : 'totalKgCo2e')
    ..aD(10, _omitFieldNames ? '' : 'kgCo2ePerHectare')
    ..aD(11, _omitFieldNames ? '' : 'kgCo2ePerTonne')
    ..aD(12, _omitFieldNames ? '' : 'yieldTonnes')
    ..pc<EmissionSource>(
        13, _omitFieldNames ? '' : 'missingSources', $pb.PbFieldType.KE,
        valueOf: EmissionSource.valueOf,
        enumValues: EmissionSource.values,
        defaultEnumValue: EmissionSource.EMISSION_SOURCE_UNSPECIFIED)
    ..aOB(14, _omitFieldNames ? '' : 'complete')
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'computedAt',
        subBuilder: $0.Timestamp.create)
    ..aOS(16, _omitFieldNames ? '' : 'method')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Footprint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Footprint copyWith(void Function(Footprint) updates) =>
      super.copyWith((message) => updates(message as Footprint)) as Footprint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Footprint create() => Footprint._();
  @$core.override
  Footprint createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Footprint getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Footprint>(create);
  static Footprint? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get crop => $_getSZ(3);
  @$pb.TagNumber(4)
  set crop($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCrop() => $_has(3);
  @$pb.TagNumber(4)
  void clearCrop() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get year => $_getIZ(4);
  @$pb.TagNumber(5)
  set year($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasYear() => $_has(4);
  @$pb.TagNumber(5)
  void clearYear() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get areaHectares => $_getN(5);
  @$pb.TagNumber(6)
  set areaHectares($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAreaHectares() => $_has(5);
  @$pb.TagNumber(6)
  void clearAreaHectares() => $_clearField(6);

  @$pb.TagNumber(7)
  WaterRegime get waterRegime => $_getN(6);
  @$pb.TagNumber(7)
  set waterRegime(WaterRegime value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasWaterRegime() => $_has(6);
  @$pb.TagNumber(7)
  void clearWaterRegime() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<EmissionLine> get lines => $_getList(7);

  @$pb.TagNumber(9)
  $core.double get totalKgCo2e => $_getN(8);
  @$pb.TagNumber(9)
  set totalKgCo2e($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTotalKgCo2e() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotalKgCo2e() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get kgCo2ePerHectare => $_getN(9);
  @$pb.TagNumber(10)
  set kgCo2ePerHectare($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasKgCo2ePerHectare() => $_has(9);
  @$pb.TagNumber(10)
  void clearKgCo2ePerHectare() => $_clearField(10);

  /// Per tonne of product, where a yield is known. This is the number a buyer
  /// asks for, and it is left at zero rather than guessed when no yield is
  /// recorded.
  @$pb.TagNumber(11)
  $core.double get kgCo2ePerTonne => $_getN(10);
  @$pb.TagNumber(11)
  set kgCo2ePerTonne($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasKgCo2ePerTonne() => $_has(10);
  @$pb.TagNumber(11)
  void clearKgCo2ePerTonne() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get yieldTonnes => $_getN(11);
  @$pb.TagNumber(12)
  set yieldTonnes($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasYieldTonnes() => $_has(11);
  @$pb.TagNumber(12)
  void clearYieldTonnes() => $_clearField(12);

  /// Sources with no activity data behind them. A footprint with entries here
  /// is a floor, not a total, and every surface that shows the number has to
  /// show this with it.
  @$pb.TagNumber(13)
  $pb.PbList<EmissionSource> get missingSources => $_getList(12);

  /// True when nothing is missing.
  @$pb.TagNumber(14)
  $core.bool get complete => $_getBF(13);
  @$pb.TagNumber(14)
  set complete($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasComplete() => $_has(13);
  @$pb.TagNumber(14)
  void clearComplete() => $_clearField(14);

  @$pb.TagNumber(15)
  $0.Timestamp get computedAt => $_getN(14);
  @$pb.TagNumber(15)
  set computedAt($0.Timestamp value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasComputedAt() => $_has(14);
  @$pb.TagNumber(15)
  void clearComputedAt() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Timestamp ensureComputedAt() => $_ensure(14);

  @$pb.TagNumber(16)
  $core.String get method => $_getSZ(15);
  @$pb.TagNumber(16)
  set method($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasMethod() => $_has(15);
  @$pb.TagNumber(16)
  void clearMethod() => $_clearField(16);
}

/// Finding is one thing standing between a field and a certificate.
class Finding extends $pb.GeneratedMessage {
  factory Finding({
    FindingSeverity? severity,
    $core.String? code,
    $core.String? message,
    $core.String? evidenceId,
    $0.Timestamp? occurredOn,
  }) {
    final result = create();
    if (severity != null) result.severity = severity;
    if (code != null) result.code = code;
    if (message != null) result.message = message;
    if (evidenceId != null) result.evidenceId = evidenceId;
    if (occurredOn != null) result.occurredOn = occurredOn;
    return result;
  }

  Finding._();

  factory Finding.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Finding.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Finding',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aE<FindingSeverity>(1, _omitFieldNames ? '' : 'severity',
        enumValues: FindingSeverity.values)
    ..aOS(2, _omitFieldNames ? '' : 'code')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..aOS(4, _omitFieldNames ? '' : 'evidenceId')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'occurredOn',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Finding clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Finding copyWith(void Function(Finding) updates) =>
      super.copyWith((message) => updates(message as Finding)) as Finding;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Finding create() => Finding._();
  @$core.override
  Finding createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Finding getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Finding>(create);
  static Finding? _defaultInstance;

  @$pb.TagNumber(1)
  FindingSeverity get severity => $_getN(0);
  @$pb.TagNumber(1)
  set severity(FindingSeverity value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSeverity() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeverity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get code => $_getSZ(1);
  @$pb.TagNumber(2)
  set code($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);

  /// The input record or date the finding is about, where there is one.
  @$pb.TagNumber(4)
  $core.String get evidenceId => $_getSZ(3);
  @$pb.TagNumber(4)
  set evidenceId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEvidenceId() => $_has(3);
  @$pb.TagNumber(4)
  void clearEvidenceId() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get occurredOn => $_getN(4);
  @$pb.TagNumber(5)
  set occurredOn($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasOccurredOn() => $_has(4);
  @$pb.TagNumber(5)
  void clearOccurredOn() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureOccurredOn() => $_ensure(4);
}

/// CertificationCheck is an assessment against one standard.
class CertificationCheck extends $pb.GeneratedMessage {
  factory CertificationCheck({
    $core.String? fieldId,
    CertificationStandard? standard,
    CertificationStatus? status,
    $0.Timestamp? conversionStartedOn,
    $0.Timestamp? eligibleFrom,
    $core.Iterable<Finding>? findings,
    $core.int? recordYears,
    $core.String? summary,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (standard != null) result.standard = standard;
    if (status != null) result.status = status;
    if (conversionStartedOn != null)
      result.conversionStartedOn = conversionStartedOn;
    if (eligibleFrom != null) result.eligibleFrom = eligibleFrom;
    if (findings != null) result.findings.addAll(findings);
    if (recordYears != null) result.recordYears = recordYears;
    if (summary != null) result.summary = summary;
    return result;
  }

  CertificationCheck._();

  factory CertificationCheck.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CertificationCheck.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CertificationCheck',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aE<CertificationStandard>(2, _omitFieldNames ? '' : 'standard',
        enumValues: CertificationStandard.values)
    ..aE<CertificationStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: CertificationStatus.values)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'conversionStartedOn',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'eligibleFrom',
        subBuilder: $0.Timestamp.create)
    ..pPM<Finding>(6, _omitFieldNames ? '' : 'findings',
        subBuilder: Finding.create)
    ..aI(7, _omitFieldNames ? '' : 'recordYears')
    ..aOS(8, _omitFieldNames ? '' : 'summary')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CertificationCheck clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CertificationCheck copyWith(void Function(CertificationCheck) updates) =>
      super.copyWith((message) => updates(message as CertificationCheck))
          as CertificationCheck;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CertificationCheck create() => CertificationCheck._();
  @$core.override
  CertificationCheck createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CertificationCheck getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CertificationCheck>(create);
  static CertificationCheck? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  CertificationStandard get standard => $_getN(1);
  @$pb.TagNumber(2)
  set standard(CertificationStandard value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStandard() => $_has(1);
  @$pb.TagNumber(2)
  void clearStandard() => $_clearField(2);

  @$pb.TagNumber(3)
  CertificationStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(CertificationStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  /// When the field started conversion, and when it becomes eligible.
  @$pb.TagNumber(4)
  $0.Timestamp get conversionStartedOn => $_getN(3);
  @$pb.TagNumber(4)
  set conversionStartedOn($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasConversionStartedOn() => $_has(3);
  @$pb.TagNumber(4)
  void clearConversionStartedOn() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureConversionStartedOn() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Timestamp get eligibleFrom => $_getN(4);
  @$pb.TagNumber(5)
  set eligibleFrom($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasEligibleFrom() => $_has(4);
  @$pb.TagNumber(5)
  void clearEligibleFrom() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureEligibleFrom() => $_ensure(4);

  @$pb.TagNumber(6)
  $pb.PbList<Finding> get findings => $_getList(5);

  /// Years of input records the check could see. A standard needing three and
  /// finding one is not a pass with a caveat.
  @$pb.TagNumber(7)
  $core.int get recordYears => $_getIZ(6);
  @$pb.TagNumber(7)
  set recordYears($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRecordYears() => $_has(6);
  @$pb.TagNumber(7)
  void clearRecordYears() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get summary => $_getSZ(7);
  @$pb.TagNumber(8)
  set summary($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSummary() => $_has(7);
  @$pb.TagNumber(8)
  void clearSummary() => $_clearField(8);
}

class RecordInputUseRequest extends $pb.GeneratedMessage {
  factory RecordInputUseRequest({
    $core.String? fieldId,
    $core.String? crop,
    $core.int? year,
    InputCategory? category,
    $core.String? product,
    $core.double? quantity,
    $core.String? unit,
    $core.double? nitrogenKg,
    $0.Timestamp? appliedOn,
    $core.String? notes,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (crop != null) result.crop = crop;
    if (year != null) result.year = year;
    if (category != null) result.category = category;
    if (product != null) result.product = product;
    if (quantity != null) result.quantity = quantity;
    if (unit != null) result.unit = unit;
    if (nitrogenKg != null) result.nitrogenKg = nitrogenKg;
    if (appliedOn != null) result.appliedOn = appliedOn;
    if (notes != null) result.notes = notes;
    return result;
  }

  RecordInputUseRequest._();

  factory RecordInputUseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecordInputUseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecordInputUseRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'crop')
    ..aI(3, _omitFieldNames ? '' : 'year')
    ..aE<InputCategory>(4, _omitFieldNames ? '' : 'category',
        enumValues: InputCategory.values)
    ..aOS(5, _omitFieldNames ? '' : 'product')
    ..aD(6, _omitFieldNames ? '' : 'quantity')
    ..aOS(7, _omitFieldNames ? '' : 'unit')
    ..aD(8, _omitFieldNames ? '' : 'nitrogenKg')
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'appliedOn',
        subBuilder: $0.Timestamp.create)
    ..aOS(10, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordInputUseRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordInputUseRequest copyWith(
          void Function(RecordInputUseRequest) updates) =>
      super.copyWith((message) => updates(message as RecordInputUseRequest))
          as RecordInputUseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecordInputUseRequest create() => RecordInputUseRequest._();
  @$core.override
  RecordInputUseRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecordInputUseRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecordInputUseRequest>(create);
  static RecordInputUseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get crop => $_getSZ(1);
  @$pb.TagNumber(2)
  set crop($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCrop() => $_has(1);
  @$pb.TagNumber(2)
  void clearCrop() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get year => $_getIZ(2);
  @$pb.TagNumber(3)
  set year($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasYear() => $_has(2);
  @$pb.TagNumber(3)
  void clearYear() => $_clearField(3);

  @$pb.TagNumber(4)
  InputCategory get category => $_getN(3);
  @$pb.TagNumber(4)
  set category(InputCategory value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCategory() => $_has(3);
  @$pb.TagNumber(4)
  void clearCategory() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get product => $_getSZ(4);
  @$pb.TagNumber(5)
  set product($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProduct() => $_has(4);
  @$pb.TagNumber(5)
  void clearProduct() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get quantity => $_getN(5);
  @$pb.TagNumber(6)
  set quantity($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasQuantity() => $_has(5);
  @$pb.TagNumber(6)
  void clearQuantity() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get unit => $_getSZ(6);
  @$pb.TagNumber(7)
  set unit($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUnit() => $_has(6);
  @$pb.TagNumber(7)
  void clearUnit() => $_clearField(7);

  /// Optional. Left at zero the service works it out from the product where it
  /// can, and says so when it cannot.
  @$pb.TagNumber(8)
  $core.double get nitrogenKg => $_getN(7);
  @$pb.TagNumber(8)
  set nitrogenKg($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNitrogenKg() => $_has(7);
  @$pb.TagNumber(8)
  void clearNitrogenKg() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get appliedOn => $_getN(8);
  @$pb.TagNumber(9)
  set appliedOn($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasAppliedOn() => $_has(8);
  @$pb.TagNumber(9)
  void clearAppliedOn() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureAppliedOn() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.String get notes => $_getSZ(9);
  @$pb.TagNumber(10)
  set notes($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNotes() => $_has(9);
  @$pb.TagNumber(10)
  void clearNotes() => $_clearField(10);
}

class RecordInputUseResponse extends $pb.GeneratedMessage {
  factory RecordInputUseResponse({
    InputUse? input,
  }) {
    final result = create();
    if (input != null) result.input = input;
    return result;
  }

  RecordInputUseResponse._();

  factory RecordInputUseResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecordInputUseResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecordInputUseResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOM<InputUse>(1, _omitFieldNames ? '' : 'input',
        subBuilder: InputUse.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordInputUseResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordInputUseResponse copyWith(
          void Function(RecordInputUseResponse) updates) =>
      super.copyWith((message) => updates(message as RecordInputUseResponse))
          as RecordInputUseResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecordInputUseResponse create() => RecordInputUseResponse._();
  @$core.override
  RecordInputUseResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecordInputUseResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecordInputUseResponse>(create);
  static RecordInputUseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InputUse get input => $_getN(0);
  @$pb.TagNumber(1)
  set input(InputUse value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasInput() => $_has(0);
  @$pb.TagNumber(1)
  void clearInput() => $_clearField(1);
  @$pb.TagNumber(1)
  InputUse ensureInput() => $_ensure(0);
}

class ListInputUseRequest extends $pb.GeneratedMessage {
  factory ListInputUseRequest({
    $core.String? fieldId,
    $core.int? year,
    InputCategory? category,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (year != null) result.year = year;
    if (category != null) result.category = category;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListInputUseRequest._();

  factory ListInputUseRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListInputUseRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListInputUseRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aI(2, _omitFieldNames ? '' : 'year')
    ..aE<InputCategory>(3, _omitFieldNames ? '' : 'category',
        enumValues: InputCategory.values)
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aOS(5, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInputUseRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInputUseRequest copyWith(void Function(ListInputUseRequest) updates) =>
      super.copyWith((message) => updates(message as ListInputUseRequest))
          as ListInputUseRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListInputUseRequest create() => ListInputUseRequest._();
  @$core.override
  ListInputUseRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListInputUseRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListInputUseRequest>(create);
  static ListInputUseRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get year => $_getIZ(1);
  @$pb.TagNumber(2)
  set year($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasYear() => $_has(1);
  @$pb.TagNumber(2)
  void clearYear() => $_clearField(2);

  @$pb.TagNumber(3)
  InputCategory get category => $_getN(2);
  @$pb.TagNumber(3)
  set category(InputCategory value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCategory() => $_has(2);
  @$pb.TagNumber(3)
  void clearCategory() => $_clearField(3);

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

class ListInputUseResponse extends $pb.GeneratedMessage {
  factory ListInputUseResponse({
    $core.Iterable<InputUse>? inputs,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (inputs != null) result.inputs.addAll(inputs);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListInputUseResponse._();

  factory ListInputUseResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListInputUseResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListInputUseResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..pPM<InputUse>(1, _omitFieldNames ? '' : 'inputs',
        subBuilder: InputUse.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInputUseResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListInputUseResponse copyWith(void Function(ListInputUseResponse) updates) =>
      super.copyWith((message) => updates(message as ListInputUseResponse))
          as ListInputUseResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListInputUseResponse create() => ListInputUseResponse._();
  @$core.override
  ListInputUseResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListInputUseResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListInputUseResponse>(create);
  static ListInputUseResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<InputUse> get inputs => $_getList(0);

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

class ComputeFootprintRequest extends $pb.GeneratedMessage {
  factory ComputeFootprintRequest({
    $core.String? fieldId,
    $core.int? year,
    $core.String? crop,
    $core.double? areaHectares,
    WaterRegime? waterRegime,
    $core.int? floodedDays,
    $core.double? yieldTonnes,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (year != null) result.year = year;
    if (crop != null) result.crop = crop;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (waterRegime != null) result.waterRegime = waterRegime;
    if (floodedDays != null) result.floodedDays = floodedDays;
    if (yieldTonnes != null) result.yieldTonnes = yieldTonnes;
    return result;
  }

  ComputeFootprintRequest._();

  factory ComputeFootprintRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ComputeFootprintRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ComputeFootprintRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aI(2, _omitFieldNames ? '' : 'year')
    ..aOS(3, _omitFieldNames ? '' : 'crop')
    ..aD(4, _omitFieldNames ? '' : 'areaHectares')
    ..aE<WaterRegime>(5, _omitFieldNames ? '' : 'waterRegime',
        enumValues: WaterRegime.values)
    ..aI(6, _omitFieldNames ? '' : 'floodedDays')
    ..aD(7, _omitFieldNames ? '' : 'yieldTonnes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeFootprintRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeFootprintRequest copyWith(
          void Function(ComputeFootprintRequest) updates) =>
      super.copyWith((message) => updates(message as ComputeFootprintRequest))
          as ComputeFootprintRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ComputeFootprintRequest create() => ComputeFootprintRequest._();
  @$core.override
  ComputeFootprintRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ComputeFootprintRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ComputeFootprintRequest>(create);
  static ComputeFootprintRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get year => $_getIZ(1);
  @$pb.TagNumber(2)
  set year($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasYear() => $_has(1);
  @$pb.TagNumber(2)
  void clearYear() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get crop => $_getSZ(2);
  @$pb.TagNumber(3)
  set crop($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCrop() => $_has(2);
  @$pb.TagNumber(3)
  void clearCrop() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get areaHectares => $_getN(3);
  @$pb.TagNumber(4)
  set areaHectares($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAreaHectares() => $_has(3);
  @$pb.TagNumber(4)
  void clearAreaHectares() => $_clearField(4);

  @$pb.TagNumber(5)
  WaterRegime get waterRegime => $_getN(4);
  @$pb.TagNumber(5)
  set waterRegime(WaterRegime value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasWaterRegime() => $_has(4);
  @$pb.TagNumber(5)
  void clearWaterRegime() => $_clearField(5);

  /// Days the paddy was flooded. Only read for a rice crop.
  @$pb.TagNumber(6)
  $core.int get floodedDays => $_getIZ(5);
  @$pb.TagNumber(6)
  set floodedDays($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFloodedDays() => $_has(5);
  @$pb.TagNumber(6)
  void clearFloodedDays() => $_clearField(6);

  /// Harvested tonnes, for the per-tonne intensity. Left at zero the intensity
  /// is not reported rather than divided by a guess.
  @$pb.TagNumber(7)
  $core.double get yieldTonnes => $_getN(6);
  @$pb.TagNumber(7)
  set yieldTonnes($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasYieldTonnes() => $_has(6);
  @$pb.TagNumber(7)
  void clearYieldTonnes() => $_clearField(7);
}

class ComputeFootprintResponse extends $pb.GeneratedMessage {
  factory ComputeFootprintResponse({
    Footprint? footprint,
  }) {
    final result = create();
    if (footprint != null) result.footprint = footprint;
    return result;
  }

  ComputeFootprintResponse._();

  factory ComputeFootprintResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ComputeFootprintResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ComputeFootprintResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOM<Footprint>(1, _omitFieldNames ? '' : 'footprint',
        subBuilder: Footprint.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeFootprintResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeFootprintResponse copyWith(
          void Function(ComputeFootprintResponse) updates) =>
      super.copyWith((message) => updates(message as ComputeFootprintResponse))
          as ComputeFootprintResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ComputeFootprintResponse create() => ComputeFootprintResponse._();
  @$core.override
  ComputeFootprintResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ComputeFootprintResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ComputeFootprintResponse>(create);
  static ComputeFootprintResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Footprint get footprint => $_getN(0);
  @$pb.TagNumber(1)
  set footprint(Footprint value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFootprint() => $_has(0);
  @$pb.TagNumber(1)
  void clearFootprint() => $_clearField(1);
  @$pb.TagNumber(1)
  Footprint ensureFootprint() => $_ensure(0);
}

class GetFootprintRequest extends $pb.GeneratedMessage {
  factory GetFootprintRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetFootprintRequest._();

  factory GetFootprintRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFootprintRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFootprintRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFootprintRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFootprintRequest copyWith(void Function(GetFootprintRequest) updates) =>
      super.copyWith((message) => updates(message as GetFootprintRequest))
          as GetFootprintRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFootprintRequest create() => GetFootprintRequest._();
  @$core.override
  GetFootprintRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFootprintRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFootprintRequest>(create);
  static GetFootprintRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetFootprintResponse extends $pb.GeneratedMessage {
  factory GetFootprintResponse({
    Footprint? footprint,
  }) {
    final result = create();
    if (footprint != null) result.footprint = footprint;
    return result;
  }

  GetFootprintResponse._();

  factory GetFootprintResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetFootprintResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetFootprintResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOM<Footprint>(1, _omitFieldNames ? '' : 'footprint',
        subBuilder: Footprint.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFootprintResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFootprintResponse copyWith(void Function(GetFootprintResponse) updates) =>
      super.copyWith((message) => updates(message as GetFootprintResponse))
          as GetFootprintResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFootprintResponse create() => GetFootprintResponse._();
  @$core.override
  GetFootprintResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetFootprintResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFootprintResponse>(create);
  static GetFootprintResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Footprint get footprint => $_getN(0);
  @$pb.TagNumber(1)
  set footprint(Footprint value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFootprint() => $_has(0);
  @$pb.TagNumber(1)
  void clearFootprint() => $_clearField(1);
  @$pb.TagNumber(1)
  Footprint ensureFootprint() => $_ensure(0);
}

class ListFootprintsRequest extends $pb.GeneratedMessage {
  factory ListFootprintsRequest({
    $core.String? fieldId,
    $core.String? farmId,
    $core.int? year,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (year != null) result.year = year;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListFootprintsRequest._();

  factory ListFootprintsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListFootprintsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFootprintsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aI(3, _omitFieldNames ? '' : 'year')
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aOS(5, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFootprintsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFootprintsRequest copyWith(
          void Function(ListFootprintsRequest) updates) =>
      super.copyWith((message) => updates(message as ListFootprintsRequest))
          as ListFootprintsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFootprintsRequest create() => ListFootprintsRequest._();
  @$core.override
  ListFootprintsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListFootprintsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFootprintsRequest>(create);
  static ListFootprintsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFarmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFarmId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get year => $_getIZ(2);
  @$pb.TagNumber(3)
  set year($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasYear() => $_has(2);
  @$pb.TagNumber(3)
  void clearYear() => $_clearField(3);

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

class ListFootprintsResponse extends $pb.GeneratedMessage {
  factory ListFootprintsResponse({
    $core.Iterable<Footprint>? footprints,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (footprints != null) result.footprints.addAll(footprints);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListFootprintsResponse._();

  factory ListFootprintsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListFootprintsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListFootprintsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..pPM<Footprint>(1, _omitFieldNames ? '' : 'footprints',
        subBuilder: Footprint.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFootprintsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFootprintsResponse copyWith(
          void Function(ListFootprintsResponse) updates) =>
      super.copyWith((message) => updates(message as ListFootprintsResponse))
          as ListFootprintsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFootprintsResponse create() => ListFootprintsResponse._();
  @$core.override
  ListFootprintsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListFootprintsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListFootprintsResponse>(create);
  static ListFootprintsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Footprint> get footprints => $_getList(0);

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

class CheckCertificationRequest extends $pb.GeneratedMessage {
  factory CheckCertificationRequest({
    $core.String? fieldId,
    CertificationStandard? standard,
    $0.Timestamp? conversionStartedOn,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (standard != null) result.standard = standard;
    if (conversionStartedOn != null)
      result.conversionStartedOn = conversionStartedOn;
    return result;
  }

  CheckCertificationRequest._();

  factory CheckCertificationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckCertificationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckCertificationRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aE<CertificationStandard>(2, _omitFieldNames ? '' : 'standard',
        enumValues: CertificationStandard.values)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'conversionStartedOn',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckCertificationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckCertificationRequest copyWith(
          void Function(CheckCertificationRequest) updates) =>
      super.copyWith((message) => updates(message as CheckCertificationRequest))
          as CheckCertificationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckCertificationRequest create() => CheckCertificationRequest._();
  @$core.override
  CheckCertificationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckCertificationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckCertificationRequest>(create);
  static CheckCertificationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  CertificationStandard get standard => $_getN(1);
  @$pb.TagNumber(2)
  set standard(CertificationStandard value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStandard() => $_has(1);
  @$pb.TagNumber(2)
  void clearStandard() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get conversionStartedOn => $_getN(2);
  @$pb.TagNumber(3)
  set conversionStartedOn($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasConversionStartedOn() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversionStartedOn() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureConversionStartedOn() => $_ensure(2);
}

class CheckCertificationResponse extends $pb.GeneratedMessage {
  factory CheckCertificationResponse({
    CertificationCheck? check_1,
  }) {
    final result = create();
    if (check_1 != null) result.check_1 = check_1;
    return result;
  }

  CheckCertificationResponse._();

  factory CheckCertificationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckCertificationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckCertificationResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOM<CertificationCheck>(1, _omitFieldNames ? '' : 'check',
        subBuilder: CertificationCheck.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckCertificationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckCertificationResponse copyWith(
          void Function(CheckCertificationResponse) updates) =>
      super.copyWith(
              (message) => updates(message as CheckCertificationResponse))
          as CheckCertificationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckCertificationResponse create() => CheckCertificationResponse._();
  @$core.override
  CheckCertificationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckCertificationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckCertificationResponse>(create);
  static CheckCertificationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CertificationCheck get check_1 => $_getN(0);
  @$pb.TagNumber(1)
  set check_1(CertificationCheck value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCheck_1() => $_has(0);
  @$pb.TagNumber(1)
  void clearCheck_1() => $_clearField(1);
  @$pb.TagNumber(1)
  CertificationCheck ensureCheck_1() => $_ensure(0);
}

class ExportCertificationPackRequest extends $pb.GeneratedMessage {
  factory ExportCertificationPackRequest({
    $core.String? fieldId,
    CertificationStandard? standard,
    $0.Timestamp? conversionStartedOn,
    $core.bool? allowIncomplete,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (standard != null) result.standard = standard;
    if (conversionStartedOn != null)
      result.conversionStartedOn = conversionStartedOn;
    if (allowIncomplete != null) result.allowIncomplete = allowIncomplete;
    return result;
  }

  ExportCertificationPackRequest._();

  factory ExportCertificationPackRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExportCertificationPackRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportCertificationPackRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aE<CertificationStandard>(2, _omitFieldNames ? '' : 'standard',
        enumValues: CertificationStandard.values)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'conversionStartedOn',
        subBuilder: $0.Timestamp.create)
    ..aOB(4, _omitFieldNames ? '' : 'allowIncomplete')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportCertificationPackRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportCertificationPackRequest copyWith(
          void Function(ExportCertificationPackRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ExportCertificationPackRequest))
          as ExportCertificationPackRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportCertificationPackRequest create() =>
      ExportCertificationPackRequest._();
  @$core.override
  ExportCertificationPackRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExportCertificationPackRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportCertificationPackRequest>(create);
  static ExportCertificationPackRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldId() => $_clearField(1);

  @$pb.TagNumber(2)
  CertificationStandard get standard => $_getN(1);
  @$pb.TagNumber(2)
  set standard(CertificationStandard value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStandard() => $_has(1);
  @$pb.TagNumber(2)
  void clearStandard() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get conversionStartedOn => $_getN(2);
  @$pb.TagNumber(3)
  set conversionStartedOn($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasConversionStartedOn() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversionStartedOn() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureConversionStartedOn() => $_ensure(2);

  /// Export the pack even though the check found blockers, clearly marked as
  /// a working document. Without this an export that would not pass is refused
  /// rather than handed over looking like a certificate.
  @$pb.TagNumber(4)
  $core.bool get allowIncomplete => $_getBF(3);
  @$pb.TagNumber(4)
  set allowIncomplete($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAllowIncomplete() => $_has(3);
  @$pb.TagNumber(4)
  void clearAllowIncomplete() => $_clearField(4);
}

class ExportCertificationPackResponse extends $pb.GeneratedMessage {
  factory ExportCertificationPackResponse({
    $core.String? filename,
    $core.List<$core.int>? content,
    $core.String? contentType,
    CertificationCheck? check_4,
  }) {
    final result = create();
    if (filename != null) result.filename = filename;
    if (content != null) result.content = content;
    if (contentType != null) result.contentType = contentType;
    if (check_4 != null) result.check_4 = check_4;
    return result;
  }

  ExportCertificationPackResponse._();

  factory ExportCertificationPackResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ExportCertificationPackResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ExportCertificationPackResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.sustainability.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filename')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aOS(3, _omitFieldNames ? '' : 'contentType')
    ..aOM<CertificationCheck>(4, _omitFieldNames ? '' : 'check',
        subBuilder: CertificationCheck.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportCertificationPackResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportCertificationPackResponse copyWith(
          void Function(ExportCertificationPackResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ExportCertificationPackResponse))
          as ExportCertificationPackResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExportCertificationPackResponse create() =>
      ExportCertificationPackResponse._();
  @$core.override
  ExportCertificationPackResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ExportCertificationPackResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportCertificationPackResponse>(
          create);
  static ExportCertificationPackResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filename => $_getSZ(0);
  @$pb.TagNumber(1)
  set filename($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFilename() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilename() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get content => $_getN(1);
  @$pb.TagNumber(2)
  set content($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get contentType => $_getSZ(2);
  @$pb.TagNumber(3)
  set contentType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasContentType() => $_has(2);
  @$pb.TagNumber(3)
  void clearContentType() => $_clearField(3);

  @$pb.TagNumber(4)
  CertificationCheck get check_4 => $_getN(3);
  @$pb.TagNumber(4)
  set check_4(CertificationCheck value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCheck_4() => $_has(3);
  @$pb.TagNumber(4)
  void clearCheck_4() => $_clearField(4);
  @$pb.TagNumber(4)
  CertificationCheck ensureCheck_4() => $_ensure(3);
}

/// SustainabilityService accounts for a field's emissions and its certification
/// record.
class SustainabilityServiceApi {
  final $pb.RpcClient _client;

  SustainabilityServiceApi(this._client);

  $async.Future<RecordInputUseResponse> recordInputUse(
          $pb.ClientContext? ctx, RecordInputUseRequest request) =>
      _client.invoke<RecordInputUseResponse>(ctx, 'SustainabilityService',
          'RecordInputUse', request, RecordInputUseResponse());
  $async.Future<ListInputUseResponse> listInputUse(
          $pb.ClientContext? ctx, ListInputUseRequest request) =>
      _client.invoke<ListInputUseResponse>(ctx, 'SustainabilityService',
          'ListInputUse', request, ListInputUseResponse());
  $async.Future<ComputeFootprintResponse> computeFootprint(
          $pb.ClientContext? ctx, ComputeFootprintRequest request) =>
      _client.invoke<ComputeFootprintResponse>(ctx, 'SustainabilityService',
          'ComputeFootprint', request, ComputeFootprintResponse());
  $async.Future<GetFootprintResponse> getFootprint(
          $pb.ClientContext? ctx, GetFootprintRequest request) =>
      _client.invoke<GetFootprintResponse>(ctx, 'SustainabilityService',
          'GetFootprint', request, GetFootprintResponse());
  $async.Future<ListFootprintsResponse> listFootprints(
          $pb.ClientContext? ctx, ListFootprintsRequest request) =>
      _client.invoke<ListFootprintsResponse>(ctx, 'SustainabilityService',
          'ListFootprints', request, ListFootprintsResponse());
  $async.Future<CheckCertificationResponse> checkCertification(
          $pb.ClientContext? ctx, CheckCertificationRequest request) =>
      _client.invoke<CheckCertificationResponse>(ctx, 'SustainabilityService',
          'CheckCertification', request, CheckCertificationResponse());
  $async.Future<ExportCertificationPackResponse> exportCertificationPack(
          $pb.ClientContext? ctx, ExportCertificationPackRequest request) =>
      _client.invoke<ExportCertificationPackResponse>(
          ctx,
          'SustainabilityService',
          'ExportCertificationPack',
          request,
          ExportCertificationPackResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
