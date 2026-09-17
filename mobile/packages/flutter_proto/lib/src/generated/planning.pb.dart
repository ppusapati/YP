// This is a generated file - do not edit.
//
// Generated from planning.proto.

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

import 'planning.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'planning.pbenum.dart';

/// SowingWindow is when a crop can go in the ground.
class SowingWindow extends $pb.GeneratedMessage {
  factory SowingWindow({
    $core.String? crop,
    Season? season,
    $0.Timestamp? opens,
    $0.Timestamp? closes,
    $0.Timestamp? optimal,
    $core.String? basis,
    $core.bool? weatherInformed,
  }) {
    final result = create();
    if (crop != null) result.crop = crop;
    if (season != null) result.season = season;
    if (opens != null) result.opens = opens;
    if (closes != null) result.closes = closes;
    if (optimal != null) result.optimal = optimal;
    if (basis != null) result.basis = basis;
    if (weatherInformed != null) result.weatherInformed = weatherInformed;
    return result;
  }

  SowingWindow._();

  factory SowingWindow.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SowingWindow.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SowingWindow',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'crop')
    ..aE<Season>(2, _omitFieldNames ? '' : 'season', enumValues: Season.values)
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'opens',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'closes',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'optimal',
        subBuilder: $0.Timestamp.create)
    ..aOS(6, _omitFieldNames ? '' : 'basis')
    ..aOB(7, _omitFieldNames ? '' : 'weatherInformed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SowingWindow clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SowingWindow copyWith(void Function(SowingWindow) updates) =>
      super.copyWith((message) => updates(message as SowingWindow))
          as SowingWindow;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SowingWindow create() => SowingWindow._();
  @$core.override
  SowingWindow createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SowingWindow getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SowingWindow>(create);
  static SowingWindow? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get crop => $_getSZ(0);
  @$pb.TagNumber(1)
  set crop($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCrop() => $_has(0);
  @$pb.TagNumber(1)
  void clearCrop() => $_clearField(1);

  @$pb.TagNumber(2)
  Season get season => $_getN(1);
  @$pb.TagNumber(2)
  set season(Season value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSeason() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeason() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get opens => $_getN(2);
  @$pb.TagNumber(3)
  set opens($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOpens() => $_has(2);
  @$pb.TagNumber(3)
  void clearOpens() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureOpens() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Timestamp get closes => $_getN(3);
  @$pb.TagNumber(4)
  set closes($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCloses() => $_has(3);
  @$pb.TagNumber(4)
  void clearCloses() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureCloses() => $_ensure(3);

  /// The middle of the window, where yield potential is usually highest.
  @$pb.TagNumber(5)
  $0.Timestamp get optimal => $_getN(4);
  @$pb.TagNumber(5)
  set optimal($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasOptimal() => $_has(4);
  @$pb.TagNumber(5)
  void clearOptimal() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureOptimal() => $_ensure(4);

  /// Why the window is where it is — rainfall onset, temperature, or the
  /// agronomic default when neither is known.
  @$pb.TagNumber(6)
  $core.String get basis => $_getSZ(5);
  @$pb.TagNumber(6)
  set basis($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBasis() => $_has(5);
  @$pb.TagNumber(6)
  void clearBasis() => $_clearField(6);

  /// False when the window came from the crop calendar alone because no
  /// weather history was available. Said out loud rather than presented with
  /// the same confidence as a window derived from ten years of rainfall.
  @$pb.TagNumber(7)
  $core.bool get weatherInformed => $_getBF(6);
  @$pb.TagNumber(7)
  set weatherInformed($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasWeatherInformed() => $_has(6);
  @$pb.TagNumber(7)
  void clearWeatherInformed() => $_clearField(7);
}

/// InputLine is one budgeted purchase.
class InputLine extends $pb.GeneratedMessage {
  factory InputLine({
    InputKind? kind,
    $core.String? item,
    $core.double? quantity,
    $core.String? unit,
    $core.double? unitCost,
    $core.double? totalCost,
    $core.String? note,
  }) {
    final result = create();
    if (kind != null) result.kind = kind;
    if (item != null) result.item = item;
    if (quantity != null) result.quantity = quantity;
    if (unit != null) result.unit = unit;
    if (unitCost != null) result.unitCost = unitCost;
    if (totalCost != null) result.totalCost = totalCost;
    if (note != null) result.note = note;
    return result;
  }

  InputLine._();

  factory InputLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InputLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InputLine',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aE<InputKind>(1, _omitFieldNames ? '' : 'kind',
        enumValues: InputKind.values)
    ..aOS(2, _omitFieldNames ? '' : 'item')
    ..aD(3, _omitFieldNames ? '' : 'quantity')
    ..aOS(4, _omitFieldNames ? '' : 'unit')
    ..aD(5, _omitFieldNames ? '' : 'unitCost')
    ..aD(6, _omitFieldNames ? '' : 'totalCost')
    ..aOS(7, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InputLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InputLine copyWith(void Function(InputLine) updates) =>
      super.copyWith((message) => updates(message as InputLine)) as InputLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InputLine create() => InputLine._();
  @$core.override
  InputLine createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InputLine getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InputLine>(create);
  static InputLine? _defaultInstance;

  @$pb.TagNumber(1)
  InputKind get kind => $_getN(0);
  @$pb.TagNumber(1)
  set kind(InputKind value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get item => $_getSZ(1);
  @$pb.TagNumber(2)
  set item($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasItem() => $_has(1);
  @$pb.TagNumber(2)
  void clearItem() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get quantity => $_getN(2);
  @$pb.TagNumber(3)
  set quantity($core.double value) => $_setDouble(2, value);
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
  $core.double get unitCost => $_getN(4);
  @$pb.TagNumber(5)
  set unitCost($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUnitCost() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnitCost() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get totalCost => $_getN(5);
  @$pb.TagNumber(6)
  set totalCost($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalCost() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalCost() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get note => $_getSZ(6);
  @$pb.TagNumber(7)
  set note($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNote() => $_has(6);
  @$pb.TagNumber(7)
  void clearNote() => $_clearField(7);
}

/// InputBudget is what a plan expects to spend.
class InputBudget extends $pb.GeneratedMessage {
  factory InputBudget({
    $core.Iterable<InputLine>? lines,
    $core.double? totalCost,
    $core.double? costPerHectare,
    $core.String? currency,
  }) {
    final result = create();
    if (lines != null) result.lines.addAll(lines);
    if (totalCost != null) result.totalCost = totalCost;
    if (costPerHectare != null) result.costPerHectare = costPerHectare;
    if (currency != null) result.currency = currency;
    return result;
  }

  InputBudget._();

  factory InputBudget.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InputBudget.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InputBudget',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..pPM<InputLine>(1, _omitFieldNames ? '' : 'lines',
        subBuilder: InputLine.create)
    ..aD(2, _omitFieldNames ? '' : 'totalCost')
    ..aD(3, _omitFieldNames ? '' : 'costPerHectare')
    ..aOS(4, _omitFieldNames ? '' : 'currency')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InputBudget clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InputBudget copyWith(void Function(InputBudget) updates) =>
      super.copyWith((message) => updates(message as InputBudget))
          as InputBudget;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InputBudget create() => InputBudget._();
  @$core.override
  InputBudget createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InputBudget getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InputBudget>(create);
  static InputBudget? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<InputLine> get lines => $_getList(0);

  @$pb.TagNumber(2)
  $core.double get totalCost => $_getN(1);
  @$pb.TagNumber(2)
  set totalCost($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCost() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCost() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get costPerHectare => $_getN(2);
  @$pb.TagNumber(3)
  set costPerHectare($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCostPerHectare() => $_has(2);
  @$pb.TagNumber(3)
  void clearCostPerHectare() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get currency => $_getSZ(3);
  @$pb.TagNumber(4)
  set currency($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCurrency() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrency() => $_clearField(4);
}

/// RotationCheck is the verdict on a crop following what came before it.
class RotationCheck extends $pb.GeneratedMessage {
  factory RotationCheck({
    $core.String? crop,
    $core.String? previousCrop,
    RotationVerdict? verdict,
    $core.String? rationale,
    $core.double? nitrogenCreditKgHa,
  }) {
    final result = create();
    if (crop != null) result.crop = crop;
    if (previousCrop != null) result.previousCrop = previousCrop;
    if (verdict != null) result.verdict = verdict;
    if (rationale != null) result.rationale = rationale;
    if (nitrogenCreditKgHa != null)
      result.nitrogenCreditKgHa = nitrogenCreditKgHa;
    return result;
  }

  RotationCheck._();

  factory RotationCheck.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RotationCheck.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RotationCheck',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'crop')
    ..aOS(2, _omitFieldNames ? '' : 'previousCrop')
    ..aE<RotationVerdict>(3, _omitFieldNames ? '' : 'verdict',
        enumValues: RotationVerdict.values)
    ..aOS(4, _omitFieldNames ? '' : 'rationale')
    ..aD(5, _omitFieldNames ? '' : 'nitrogenCreditKgHa')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RotationCheck clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RotationCheck copyWith(void Function(RotationCheck) updates) =>
      super.copyWith((message) => updates(message as RotationCheck))
          as RotationCheck;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RotationCheck create() => RotationCheck._();
  @$core.override
  RotationCheck createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RotationCheck getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RotationCheck>(create);
  static RotationCheck? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get crop => $_getSZ(0);
  @$pb.TagNumber(1)
  set crop($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCrop() => $_has(0);
  @$pb.TagNumber(1)
  void clearCrop() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get previousCrop => $_getSZ(1);
  @$pb.TagNumber(2)
  set previousCrop($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPreviousCrop() => $_has(1);
  @$pb.TagNumber(2)
  void clearPreviousCrop() => $_clearField(2);

  @$pb.TagNumber(3)
  RotationVerdict get verdict => $_getN(2);
  @$pb.TagNumber(3)
  set verdict(RotationVerdict value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasVerdict() => $_has(2);
  @$pb.TagNumber(3)
  void clearVerdict() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get rationale => $_getSZ(3);
  @$pb.TagNumber(4)
  set rationale($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRationale() => $_has(3);
  @$pb.TagNumber(4)
  void clearRationale() => $_clearField(4);

  /// Nitrogen the previous crop left behind, in kg/ha. A legume credit that is
  /// ignored means a farmer buys urea they do not need.
  @$pb.TagNumber(5)
  $core.double get nitrogenCreditKgHa => $_getN(4);
  @$pb.TagNumber(5)
  set nitrogenCreditKgHa($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNitrogenCreditKgHa() => $_has(4);
  @$pb.TagNumber(5)
  void clearNitrogenCreditKgHa() => $_clearField(5);
}

/// SeasonPlan is one field's plan for one season.
class SeasonPlan extends $pb.GeneratedMessage {
  factory SeasonPlan({
    $core.String? id,
    $core.String? fieldId,
    $core.String? farmId,
    Season? season,
    $core.int? year,
    $core.String? crop,
    $core.String? variety,
    $core.double? areaHectares,
    PlanStatus? status,
    SowingWindow? sowingWindow,
    RotationCheck? rotationCheck,
    InputBudget? budget,
    $core.double? targetYieldTonnesHa,
    $core.String? notes,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (crop != null) result.crop = crop;
    if (variety != null) result.variety = variety;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (status != null) result.status = status;
    if (sowingWindow != null) result.sowingWindow = sowingWindow;
    if (rotationCheck != null) result.rotationCheck = rotationCheck;
    if (budget != null) result.budget = budget;
    if (targetYieldTonnesHa != null)
      result.targetYieldTonnesHa = targetYieldTonnesHa;
    if (notes != null) result.notes = notes;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (version != null) result.version = version;
    return result;
  }

  SeasonPlan._();

  factory SeasonPlan.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SeasonPlan.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SeasonPlan',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aE<Season>(4, _omitFieldNames ? '' : 'season', enumValues: Season.values)
    ..aI(5, _omitFieldNames ? '' : 'year')
    ..aOS(6, _omitFieldNames ? '' : 'crop')
    ..aOS(7, _omitFieldNames ? '' : 'variety')
    ..aD(8, _omitFieldNames ? '' : 'areaHectares')
    ..aE<PlanStatus>(9, _omitFieldNames ? '' : 'status',
        enumValues: PlanStatus.values)
    ..aOM<SowingWindow>(10, _omitFieldNames ? '' : 'sowingWindow',
        subBuilder: SowingWindow.create)
    ..aOM<RotationCheck>(11, _omitFieldNames ? '' : 'rotationCheck',
        subBuilder: RotationCheck.create)
    ..aOM<InputBudget>(12, _omitFieldNames ? '' : 'budget',
        subBuilder: InputBudget.create)
    ..aD(13, _omitFieldNames ? '' : 'targetYieldTonnesHa')
    ..aOS(14, _omitFieldNames ? '' : 'notes')
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(16, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aInt64(17, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SeasonPlan clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SeasonPlan copyWith(void Function(SeasonPlan) updates) =>
      super.copyWith((message) => updates(message as SeasonPlan)) as SeasonPlan;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SeasonPlan create() => SeasonPlan._();
  @$core.override
  SeasonPlan createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SeasonPlan getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SeasonPlan>(create);
  static SeasonPlan? _defaultInstance;

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
  Season get season => $_getN(3);
  @$pb.TagNumber(4)
  set season(Season value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSeason() => $_has(3);
  @$pb.TagNumber(4)
  void clearSeason() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get year => $_getIZ(4);
  @$pb.TagNumber(5)
  set year($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasYear() => $_has(4);
  @$pb.TagNumber(5)
  void clearYear() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get crop => $_getSZ(5);
  @$pb.TagNumber(6)
  set crop($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCrop() => $_has(5);
  @$pb.TagNumber(6)
  void clearCrop() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get variety => $_getSZ(6);
  @$pb.TagNumber(7)
  set variety($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasVariety() => $_has(6);
  @$pb.TagNumber(7)
  void clearVariety() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get areaHectares => $_getN(7);
  @$pb.TagNumber(8)
  set areaHectares($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAreaHectares() => $_has(7);
  @$pb.TagNumber(8)
  void clearAreaHectares() => $_clearField(8);

  @$pb.TagNumber(9)
  PlanStatus get status => $_getN(8);
  @$pb.TagNumber(9)
  set status(PlanStatus value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasStatus() => $_has(8);
  @$pb.TagNumber(9)
  void clearStatus() => $_clearField(9);

  @$pb.TagNumber(10)
  SowingWindow get sowingWindow => $_getN(9);
  @$pb.TagNumber(10)
  set sowingWindow(SowingWindow value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasSowingWindow() => $_has(9);
  @$pb.TagNumber(10)
  void clearSowingWindow() => $_clearField(10);
  @$pb.TagNumber(10)
  SowingWindow ensureSowingWindow() => $_ensure(9);

  @$pb.TagNumber(11)
  RotationCheck get rotationCheck => $_getN(10);
  @$pb.TagNumber(11)
  set rotationCheck(RotationCheck value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasRotationCheck() => $_has(10);
  @$pb.TagNumber(11)
  void clearRotationCheck() => $_clearField(11);
  @$pb.TagNumber(11)
  RotationCheck ensureRotationCheck() => $_ensure(10);

  @$pb.TagNumber(12)
  InputBudget get budget => $_getN(11);
  @$pb.TagNumber(12)
  set budget(InputBudget value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasBudget() => $_has(11);
  @$pb.TagNumber(12)
  void clearBudget() => $_clearField(12);
  @$pb.TagNumber(12)
  InputBudget ensureBudget() => $_ensure(11);

  @$pb.TagNumber(13)
  $core.double get targetYieldTonnesHa => $_getN(12);
  @$pb.TagNumber(13)
  set targetYieldTonnesHa($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasTargetYieldTonnesHa() => $_has(12);
  @$pb.TagNumber(13)
  void clearTargetYieldTonnesHa() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get notes => $_getSZ(13);
  @$pb.TagNumber(14)
  set notes($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasNotes() => $_has(13);
  @$pb.TagNumber(14)
  void clearNotes() => $_clearField(14);

  @$pb.TagNumber(15)
  $0.Timestamp get createdAt => $_getN(14);
  @$pb.TagNumber(15)
  set createdAt($0.Timestamp value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(14);
  @$pb.TagNumber(15)
  void clearCreatedAt() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Timestamp ensureCreatedAt() => $_ensure(14);

  @$pb.TagNumber(16)
  $0.Timestamp get updatedAt => $_getN(15);
  @$pb.TagNumber(16)
  set updatedAt($0.Timestamp value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasUpdatedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearUpdatedAt() => $_clearField(16);
  @$pb.TagNumber(16)
  $0.Timestamp ensureUpdatedAt() => $_ensure(15);

  @$pb.TagNumber(17)
  $fixnum.Int64 get version => $_getI64(16);
  @$pb.TagNumber(17)
  set version($fixnum.Int64 value) => $_setInt64(16, value);
  @$pb.TagNumber(17)
  $core.bool hasVersion() => $_has(16);
  @$pb.TagNumber(17)
  void clearVersion() => $_clearField(17);
}

class CreatePlanRequest extends $pb.GeneratedMessage {
  factory CreatePlanRequest({
    $core.String? fieldId,
    $core.String? farmId,
    Season? season,
    $core.int? year,
    $core.String? crop,
    $core.String? variety,
    $core.double? areaHectares,
    $core.double? targetYieldTonnesHa,
    $core.String? notes,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (crop != null) result.crop = crop;
    if (variety != null) result.variety = variety;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (targetYieldTonnesHa != null)
      result.targetYieldTonnesHa = targetYieldTonnesHa;
    if (notes != null) result.notes = notes;
    return result;
  }

  CreatePlanRequest._();

  factory CreatePlanRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreatePlanRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreatePlanRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aE<Season>(3, _omitFieldNames ? '' : 'season', enumValues: Season.values)
    ..aI(4, _omitFieldNames ? '' : 'year')
    ..aOS(5, _omitFieldNames ? '' : 'crop')
    ..aOS(6, _omitFieldNames ? '' : 'variety')
    ..aD(7, _omitFieldNames ? '' : 'areaHectares')
    ..aD(8, _omitFieldNames ? '' : 'targetYieldTonnesHa')
    ..aOS(9, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePlanRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePlanRequest copyWith(void Function(CreatePlanRequest) updates) =>
      super.copyWith((message) => updates(message as CreatePlanRequest))
          as CreatePlanRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePlanRequest create() => CreatePlanRequest._();
  @$core.override
  CreatePlanRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreatePlanRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreatePlanRequest>(create);
  static CreatePlanRequest? _defaultInstance;

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
  Season get season => $_getN(2);
  @$pb.TagNumber(3)
  set season(Season value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSeason() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeason() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get year => $_getIZ(3);
  @$pb.TagNumber(4)
  set year($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasYear() => $_has(3);
  @$pb.TagNumber(4)
  void clearYear() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get crop => $_getSZ(4);
  @$pb.TagNumber(5)
  set crop($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCrop() => $_has(4);
  @$pb.TagNumber(5)
  void clearCrop() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get variety => $_getSZ(5);
  @$pb.TagNumber(6)
  set variety($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVariety() => $_has(5);
  @$pb.TagNumber(6)
  void clearVariety() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get areaHectares => $_getN(6);
  @$pb.TagNumber(7)
  set areaHectares($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAreaHectares() => $_has(6);
  @$pb.TagNumber(7)
  void clearAreaHectares() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get targetYieldTonnesHa => $_getN(7);
  @$pb.TagNumber(8)
  set targetYieldTonnesHa($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTargetYieldTonnesHa() => $_has(7);
  @$pb.TagNumber(8)
  void clearTargetYieldTonnesHa() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get notes => $_getSZ(8);
  @$pb.TagNumber(9)
  set notes($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasNotes() => $_has(8);
  @$pb.TagNumber(9)
  void clearNotes() => $_clearField(9);
}

class CreatePlanResponse extends $pb.GeneratedMessage {
  factory CreatePlanResponse({
    SeasonPlan? plan,
  }) {
    final result = create();
    if (plan != null) result.plan = plan;
    return result;
  }

  CreatePlanResponse._();

  factory CreatePlanResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreatePlanResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreatePlanResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOM<SeasonPlan>(1, _omitFieldNames ? '' : 'plan',
        subBuilder: SeasonPlan.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePlanResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePlanResponse copyWith(void Function(CreatePlanResponse) updates) =>
      super.copyWith((message) => updates(message as CreatePlanResponse))
          as CreatePlanResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePlanResponse create() => CreatePlanResponse._();
  @$core.override
  CreatePlanResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreatePlanResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreatePlanResponse>(create);
  static CreatePlanResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SeasonPlan get plan => $_getN(0);
  @$pb.TagNumber(1)
  set plan(SeasonPlan value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPlan() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlan() => $_clearField(1);
  @$pb.TagNumber(1)
  SeasonPlan ensurePlan() => $_ensure(0);
}

class GetPlanRequest extends $pb.GeneratedMessage {
  factory GetPlanRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetPlanRequest._();

  factory GetPlanRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPlanRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPlanRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPlanRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPlanRequest copyWith(void Function(GetPlanRequest) updates) =>
      super.copyWith((message) => updates(message as GetPlanRequest))
          as GetPlanRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPlanRequest create() => GetPlanRequest._();
  @$core.override
  GetPlanRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPlanRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPlanRequest>(create);
  static GetPlanRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetPlanResponse extends $pb.GeneratedMessage {
  factory GetPlanResponse({
    SeasonPlan? plan,
  }) {
    final result = create();
    if (plan != null) result.plan = plan;
    return result;
  }

  GetPlanResponse._();

  factory GetPlanResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPlanResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPlanResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOM<SeasonPlan>(1, _omitFieldNames ? '' : 'plan',
        subBuilder: SeasonPlan.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPlanResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPlanResponse copyWith(void Function(GetPlanResponse) updates) =>
      super.copyWith((message) => updates(message as GetPlanResponse))
          as GetPlanResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPlanResponse create() => GetPlanResponse._();
  @$core.override
  GetPlanResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPlanResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPlanResponse>(create);
  static GetPlanResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SeasonPlan get plan => $_getN(0);
  @$pb.TagNumber(1)
  set plan(SeasonPlan value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPlan() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlan() => $_clearField(1);
  @$pb.TagNumber(1)
  SeasonPlan ensurePlan() => $_ensure(0);
}

class ListPlansRequest extends $pb.GeneratedMessage {
  factory ListPlansRequest({
    $core.String? fieldId,
    $core.String? farmId,
    Season? season,
    $core.int? year,
    PlanStatus? status,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (status != null) result.status = status;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListPlansRequest._();

  factory ListPlansRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPlansRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPlansRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aE<Season>(3, _omitFieldNames ? '' : 'season', enumValues: Season.values)
    ..aI(4, _omitFieldNames ? '' : 'year')
    ..aE<PlanStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: PlanStatus.values)
    ..aI(6, _omitFieldNames ? '' : 'pageSize')
    ..aOS(7, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPlansRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPlansRequest copyWith(void Function(ListPlansRequest) updates) =>
      super.copyWith((message) => updates(message as ListPlansRequest))
          as ListPlansRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPlansRequest create() => ListPlansRequest._();
  @$core.override
  ListPlansRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPlansRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPlansRequest>(create);
  static ListPlansRequest? _defaultInstance;

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
  Season get season => $_getN(2);
  @$pb.TagNumber(3)
  set season(Season value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSeason() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeason() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get year => $_getIZ(3);
  @$pb.TagNumber(4)
  set year($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasYear() => $_has(3);
  @$pb.TagNumber(4)
  void clearYear() => $_clearField(4);

  @$pb.TagNumber(5)
  PlanStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(PlanStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get pageSize => $_getIZ(5);
  @$pb.TagNumber(6)
  set pageSize($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageSize() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageSize() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get pageToken => $_getSZ(6);
  @$pb.TagNumber(7)
  set pageToken($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPageToken() => $_has(6);
  @$pb.TagNumber(7)
  void clearPageToken() => $_clearField(7);
}

class ListPlansResponse extends $pb.GeneratedMessage {
  factory ListPlansResponse({
    $core.Iterable<SeasonPlan>? plans,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (plans != null) result.plans.addAll(plans);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListPlansResponse._();

  factory ListPlansResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPlansResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPlansResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..pPM<SeasonPlan>(1, _omitFieldNames ? '' : 'plans',
        subBuilder: SeasonPlan.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPlansResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPlansResponse copyWith(void Function(ListPlansResponse) updates) =>
      super.copyWith((message) => updates(message as ListPlansResponse))
          as ListPlansResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPlansResponse create() => ListPlansResponse._();
  @$core.override
  ListPlansResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPlansResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPlansResponse>(create);
  static ListPlansResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SeasonPlan> get plans => $_getList(0);

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

class UpdatePlanRequest extends $pb.GeneratedMessage {
  factory UpdatePlanRequest({
    $core.String? id,
    $core.String? crop,
    $core.String? variety,
    $core.double? areaHectares,
    $core.double? targetYieldTonnesHa,
    $core.String? notes,
    $fixnum.Int64? baseVersion,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (crop != null) result.crop = crop;
    if (variety != null) result.variety = variety;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (targetYieldTonnesHa != null)
      result.targetYieldTonnesHa = targetYieldTonnesHa;
    if (notes != null) result.notes = notes;
    if (baseVersion != null) result.baseVersion = baseVersion;
    return result;
  }

  UpdatePlanRequest._();

  factory UpdatePlanRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdatePlanRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdatePlanRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'crop')
    ..aOS(3, _omitFieldNames ? '' : 'variety')
    ..aD(4, _omitFieldNames ? '' : 'areaHectares')
    ..aD(5, _omitFieldNames ? '' : 'targetYieldTonnesHa')
    ..aOS(6, _omitFieldNames ? '' : 'notes')
    ..aInt64(7, _omitFieldNames ? '' : 'baseVersion')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePlanRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePlanRequest copyWith(void Function(UpdatePlanRequest) updates) =>
      super.copyWith((message) => updates(message as UpdatePlanRequest))
          as UpdatePlanRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdatePlanRequest create() => UpdatePlanRequest._();
  @$core.override
  UpdatePlanRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdatePlanRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdatePlanRequest>(create);
  static UpdatePlanRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get crop => $_getSZ(1);
  @$pb.TagNumber(2)
  set crop($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCrop() => $_has(1);
  @$pb.TagNumber(2)
  void clearCrop() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get variety => $_getSZ(2);
  @$pb.TagNumber(3)
  set variety($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVariety() => $_has(2);
  @$pb.TagNumber(3)
  void clearVariety() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get areaHectares => $_getN(3);
  @$pb.TagNumber(4)
  set areaHectares($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAreaHectares() => $_has(3);
  @$pb.TagNumber(4)
  void clearAreaHectares() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get targetYieldTonnesHa => $_getN(4);
  @$pb.TagNumber(5)
  set targetYieldTonnesHa($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTargetYieldTonnesHa() => $_has(4);
  @$pb.TagNumber(5)
  void clearTargetYieldTonnesHa() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get notes => $_getSZ(5);
  @$pb.TagNumber(6)
  set notes($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNotes() => $_has(5);
  @$pb.TagNumber(6)
  void clearNotes() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get baseVersion => $_getI64(6);
  @$pb.TagNumber(7)
  set baseVersion($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBaseVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearBaseVersion() => $_clearField(7);
}

class UpdatePlanResponse extends $pb.GeneratedMessage {
  factory UpdatePlanResponse({
    SeasonPlan? plan,
  }) {
    final result = create();
    if (plan != null) result.plan = plan;
    return result;
  }

  UpdatePlanResponse._();

  factory UpdatePlanResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdatePlanResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdatePlanResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOM<SeasonPlan>(1, _omitFieldNames ? '' : 'plan',
        subBuilder: SeasonPlan.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePlanResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdatePlanResponse copyWith(void Function(UpdatePlanResponse) updates) =>
      super.copyWith((message) => updates(message as UpdatePlanResponse))
          as UpdatePlanResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdatePlanResponse create() => UpdatePlanResponse._();
  @$core.override
  UpdatePlanResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdatePlanResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdatePlanResponse>(create);
  static UpdatePlanResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SeasonPlan get plan => $_getN(0);
  @$pb.TagNumber(1)
  set plan(SeasonPlan value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPlan() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlan() => $_clearField(1);
  @$pb.TagNumber(1)
  SeasonPlan ensurePlan() => $_ensure(0);
}

class CommitPlanRequest extends $pb.GeneratedMessage {
  factory CommitPlanRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  CommitPlanRequest._();

  factory CommitPlanRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommitPlanRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommitPlanRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommitPlanRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommitPlanRequest copyWith(void Function(CommitPlanRequest) updates) =>
      super.copyWith((message) => updates(message as CommitPlanRequest))
          as CommitPlanRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommitPlanRequest create() => CommitPlanRequest._();
  @$core.override
  CommitPlanRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CommitPlanRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommitPlanRequest>(create);
  static CommitPlanRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class CommitPlanResponse extends $pb.GeneratedMessage {
  factory CommitPlanResponse({
    SeasonPlan? plan,
  }) {
    final result = create();
    if (plan != null) result.plan = plan;
    return result;
  }

  CommitPlanResponse._();

  factory CommitPlanResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CommitPlanResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CommitPlanResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOM<SeasonPlan>(1, _omitFieldNames ? '' : 'plan',
        subBuilder: SeasonPlan.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommitPlanResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommitPlanResponse copyWith(void Function(CommitPlanResponse) updates) =>
      super.copyWith((message) => updates(message as CommitPlanResponse))
          as CommitPlanResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CommitPlanResponse create() => CommitPlanResponse._();
  @$core.override
  CommitPlanResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CommitPlanResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CommitPlanResponse>(create);
  static CommitPlanResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SeasonPlan get plan => $_getN(0);
  @$pb.TagNumber(1)
  set plan(SeasonPlan value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPlan() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlan() => $_clearField(1);
  @$pb.TagNumber(1)
  SeasonPlan ensurePlan() => $_ensure(0);
}

class CheckRotationRequest extends $pb.GeneratedMessage {
  factory CheckRotationRequest({
    $core.String? fieldId,
    $core.String? crop,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (crop != null) result.crop = crop;
    return result;
  }

  CheckRotationRequest._();

  factory CheckRotationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckRotationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckRotationRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'crop')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckRotationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckRotationRequest copyWith(void Function(CheckRotationRequest) updates) =>
      super.copyWith((message) => updates(message as CheckRotationRequest))
          as CheckRotationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckRotationRequest create() => CheckRotationRequest._();
  @$core.override
  CheckRotationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckRotationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckRotationRequest>(create);
  static CheckRotationRequest? _defaultInstance;

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
}

class CheckRotationResponse extends $pb.GeneratedMessage {
  factory CheckRotationResponse({
    RotationCheck? check_1,
  }) {
    final result = create();
    if (check_1 != null) result.check_1 = check_1;
    return result;
  }

  CheckRotationResponse._();

  factory CheckRotationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CheckRotationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CheckRotationResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOM<RotationCheck>(1, _omitFieldNames ? '' : 'check',
        subBuilder: RotationCheck.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckRotationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CheckRotationResponse copyWith(
          void Function(CheckRotationResponse) updates) =>
      super.copyWith((message) => updates(message as CheckRotationResponse))
          as CheckRotationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CheckRotationResponse create() => CheckRotationResponse._();
  @$core.override
  CheckRotationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CheckRotationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CheckRotationResponse>(create);
  static CheckRotationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RotationCheck get check_1 => $_getN(0);
  @$pb.TagNumber(1)
  set check_1(RotationCheck value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCheck_1() => $_has(0);
  @$pb.TagNumber(1)
  void clearCheck_1() => $_clearField(1);
  @$pb.TagNumber(1)
  RotationCheck ensureCheck_1() => $_ensure(0);
}

class GetSowingWindowRequest extends $pb.GeneratedMessage {
  factory GetSowingWindowRequest({
    $core.String? fieldId,
    $core.String? crop,
    Season? season,
    $core.int? year,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (crop != null) result.crop = crop;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    return result;
  }

  GetSowingWindowRequest._();

  factory GetSowingWindowRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSowingWindowRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSowingWindowRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'crop')
    ..aE<Season>(3, _omitFieldNames ? '' : 'season', enumValues: Season.values)
    ..aI(4, _omitFieldNames ? '' : 'year')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSowingWindowRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSowingWindowRequest copyWith(
          void Function(GetSowingWindowRequest) updates) =>
      super.copyWith((message) => updates(message as GetSowingWindowRequest))
          as GetSowingWindowRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSowingWindowRequest create() => GetSowingWindowRequest._();
  @$core.override
  GetSowingWindowRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSowingWindowRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSowingWindowRequest>(create);
  static GetSowingWindowRequest? _defaultInstance;

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
  Season get season => $_getN(2);
  @$pb.TagNumber(3)
  set season(Season value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSeason() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeason() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get year => $_getIZ(3);
  @$pb.TagNumber(4)
  set year($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasYear() => $_has(3);
  @$pb.TagNumber(4)
  void clearYear() => $_clearField(4);
}

class GetSowingWindowResponse extends $pb.GeneratedMessage {
  factory GetSowingWindowResponse({
    SowingWindow? window,
  }) {
    final result = create();
    if (window != null) result.window = window;
    return result;
  }

  GetSowingWindowResponse._();

  factory GetSowingWindowResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSowingWindowResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSowingWindowResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.planning.v1'),
      createEmptyInstance: create)
    ..aOM<SowingWindow>(1, _omitFieldNames ? '' : 'window',
        subBuilder: SowingWindow.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSowingWindowResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSowingWindowResponse copyWith(
          void Function(GetSowingWindowResponse) updates) =>
      super.copyWith((message) => updates(message as GetSowingWindowResponse))
          as GetSowingWindowResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSowingWindowResponse create() => GetSowingWindowResponse._();
  @$core.override
  GetSowingWindowResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSowingWindowResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSowingWindowResponse>(create);
  static GetSowingWindowResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SowingWindow get window => $_getN(0);
  @$pb.TagNumber(1)
  set window(SowingWindow value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasWindow() => $_has(0);
  @$pb.TagNumber(1)
  void clearWindow() => $_clearField(1);
  @$pb.TagNumber(1)
  SowingWindow ensureWindow() => $_ensure(0);
}

/// PlanningService plans a season: crop choice, sowing window and input budget.
class PlanningServiceApi {
  final $pb.RpcClient _client;

  PlanningServiceApi(this._client);

  $async.Future<CreatePlanResponse> createPlan(
          $pb.ClientContext? ctx, CreatePlanRequest request) =>
      _client.invoke<CreatePlanResponse>(
          ctx, 'PlanningService', 'CreatePlan', request, CreatePlanResponse());
  $async.Future<GetPlanResponse> getPlan(
          $pb.ClientContext? ctx, GetPlanRequest request) =>
      _client.invoke<GetPlanResponse>(
          ctx, 'PlanningService', 'GetPlan', request, GetPlanResponse());
  $async.Future<ListPlansResponse> listPlans(
          $pb.ClientContext? ctx, ListPlansRequest request) =>
      _client.invoke<ListPlansResponse>(
          ctx, 'PlanningService', 'ListPlans', request, ListPlansResponse());
  $async.Future<UpdatePlanResponse> updatePlan(
          $pb.ClientContext? ctx, UpdatePlanRequest request) =>
      _client.invoke<UpdatePlanResponse>(
          ctx, 'PlanningService', 'UpdatePlan', request, UpdatePlanResponse());
  $async.Future<CommitPlanResponse> commitPlan(
          $pb.ClientContext? ctx, CommitPlanRequest request) =>
      _client.invoke<CommitPlanResponse>(
          ctx, 'PlanningService', 'CommitPlan', request, CommitPlanResponse());
  $async.Future<CheckRotationResponse> checkRotation(
          $pb.ClientContext? ctx, CheckRotationRequest request) =>
      _client.invoke<CheckRotationResponse>(ctx, 'PlanningService',
          'CheckRotation', request, CheckRotationResponse());
  $async.Future<GetSowingWindowResponse> getSowingWindow(
          $pb.ClientContext? ctx, GetSowingWindowRequest request) =>
      _client.invoke<GetSowingWindowResponse>(ctx, 'PlanningService',
          'GetSowingWindow', request, GetSowingWindowResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
