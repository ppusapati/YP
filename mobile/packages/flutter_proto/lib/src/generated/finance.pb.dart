// This is a generated file - do not edit.
//
// Generated from finance.proto.

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

import 'finance.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'finance.pbenum.dart';

/// PremiumLine is one component of the actuarial premium.
class PremiumLine extends $pb.GeneratedMessage {
  factory PremiumLine({
    $core.String? label,
    $core.double? rate,
    $core.double? amount,
    $core.String? basis,
  }) {
    final result = create();
    if (label != null) result.label = label;
    if (rate != null) result.rate = rate;
    if (amount != null) result.amount = amount;
    if (basis != null) result.basis = basis;
    return result;
  }

  PremiumLine._();

  factory PremiumLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PremiumLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PremiumLine',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aD(2, _omitFieldNames ? '' : 'rate')
    ..aD(3, _omitFieldNames ? '' : 'amount')
    ..aOS(4, _omitFieldNames ? '' : 'basis')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PremiumLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PremiumLine copyWith(void Function(PremiumLine) updates) =>
      super.copyWith((message) => updates(message as PremiumLine))
          as PremiumLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PremiumLine create() => PremiumLine._();
  @$core.override
  PremiumLine createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PremiumLine getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PremiumLine>(create);
  static PremiumLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => $_clearField(1);

  /// As a fraction of the sum insured.
  @$pb.TagNumber(2)
  $core.double get rate => $_getN(1);
  @$pb.TagNumber(2)
  set rate($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRate() => $_has(1);
  @$pb.TagNumber(2)
  void clearRate() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get amount => $_getN(2);
  @$pb.TagNumber(3)
  set amount($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get basis => $_getSZ(3);
  @$pb.TagNumber(4)
  set basis($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBasis() => $_has(3);
  @$pb.TagNumber(4)
  void clearBasis() => $_clearField(4);
}

/// InsuranceQuote prices one season's cover for one field.
class InsuranceQuote extends $pb.GeneratedMessage {
  factory InsuranceQuote({
    $core.String? id,
    $core.String? fieldId,
    $core.String? farmId,
    $core.String? crop,
    CropCategory? category,
    Season? season,
    $core.int? year,
    $core.double? areaHectares,
    $core.double? sumInsuredPerHectare,
    $core.double? totalSumInsured,
    $core.double? indemnityLevel,
    $core.double? thresholdYieldKgHa,
    $core.Iterable<PremiumLine>? lines,
    $core.double? actuarialPremium,
    $core.double? actuarialRate,
    $core.double? farmerPremium,
    $core.double? subsidy,
    QuoteConfidence? confidence,
    $core.int? historySeasons,
    $core.String? basis,
    $0.Timestamp? quotedAt,
    $0.Timestamp? expiresAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (crop != null) result.crop = crop;
    if (category != null) result.category = category;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (sumInsuredPerHectare != null)
      result.sumInsuredPerHectare = sumInsuredPerHectare;
    if (totalSumInsured != null) result.totalSumInsured = totalSumInsured;
    if (indemnityLevel != null) result.indemnityLevel = indemnityLevel;
    if (thresholdYieldKgHa != null)
      result.thresholdYieldKgHa = thresholdYieldKgHa;
    if (lines != null) result.lines.addAll(lines);
    if (actuarialPremium != null) result.actuarialPremium = actuarialPremium;
    if (actuarialRate != null) result.actuarialRate = actuarialRate;
    if (farmerPremium != null) result.farmerPremium = farmerPremium;
    if (subsidy != null) result.subsidy = subsidy;
    if (confidence != null) result.confidence = confidence;
    if (historySeasons != null) result.historySeasons = historySeasons;
    if (basis != null) result.basis = basis;
    if (quotedAt != null) result.quotedAt = quotedAt;
    if (expiresAt != null) result.expiresAt = expiresAt;
    return result;
  }

  InsuranceQuote._();

  factory InsuranceQuote.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory InsuranceQuote.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'InsuranceQuote',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'crop')
    ..aE<CropCategory>(5, _omitFieldNames ? '' : 'category',
        enumValues: CropCategory.values)
    ..aE<Season>(6, _omitFieldNames ? '' : 'season', enumValues: Season.values)
    ..aI(7, _omitFieldNames ? '' : 'year')
    ..aD(8, _omitFieldNames ? '' : 'areaHectares')
    ..aD(9, _omitFieldNames ? '' : 'sumInsuredPerHectare')
    ..aD(10, _omitFieldNames ? '' : 'totalSumInsured')
    ..aD(11, _omitFieldNames ? '' : 'indemnityLevel')
    ..aD(12, _omitFieldNames ? '' : 'thresholdYieldKgHa')
    ..pPM<PremiumLine>(13, _omitFieldNames ? '' : 'lines',
        subBuilder: PremiumLine.create)
    ..aD(14, _omitFieldNames ? '' : 'actuarialPremium')
    ..aD(15, _omitFieldNames ? '' : 'actuarialRate')
    ..aD(16, _omitFieldNames ? '' : 'farmerPremium')
    ..aD(17, _omitFieldNames ? '' : 'subsidy')
    ..aE<QuoteConfidence>(18, _omitFieldNames ? '' : 'confidence',
        enumValues: QuoteConfidence.values)
    ..aI(19, _omitFieldNames ? '' : 'historySeasons')
    ..aOS(20, _omitFieldNames ? '' : 'basis')
    ..aOM<$0.Timestamp>(21, _omitFieldNames ? '' : 'quotedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(22, _omitFieldNames ? '' : 'expiresAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InsuranceQuote clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InsuranceQuote copyWith(void Function(InsuranceQuote) updates) =>
      super.copyWith((message) => updates(message as InsuranceQuote))
          as InsuranceQuote;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InsuranceQuote create() => InsuranceQuote._();
  @$core.override
  InsuranceQuote createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static InsuranceQuote getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InsuranceQuote>(create);
  static InsuranceQuote? _defaultInstance;

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
  CropCategory get category => $_getN(4);
  @$pb.TagNumber(5)
  set category(CropCategory value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCategory() => $_has(4);
  @$pb.TagNumber(5)
  void clearCategory() => $_clearField(5);

  @$pb.TagNumber(6)
  Season get season => $_getN(5);
  @$pb.TagNumber(6)
  set season(Season value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSeason() => $_has(5);
  @$pb.TagNumber(6)
  void clearSeason() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get year => $_getIZ(6);
  @$pb.TagNumber(7)
  set year($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasYear() => $_has(6);
  @$pb.TagNumber(7)
  void clearYear() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get areaHectares => $_getN(7);
  @$pb.TagNumber(8)
  set areaHectares($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAreaHectares() => $_has(7);
  @$pb.TagNumber(8)
  void clearAreaHectares() => $_clearField(8);

  /// Sum insured per hectare, and the total it comes to.
  @$pb.TagNumber(9)
  $core.double get sumInsuredPerHectare => $_getN(8);
  @$pb.TagNumber(9)
  set sumInsuredPerHectare($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSumInsuredPerHectare() => $_has(8);
  @$pb.TagNumber(9)
  void clearSumInsuredPerHectare() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get totalSumInsured => $_getN(9);
  @$pb.TagNumber(10)
  set totalSumInsured($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTotalSumInsured() => $_has(9);
  @$pb.TagNumber(10)
  void clearTotalSumInsured() => $_clearField(10);

  /// The indemnity level the cover is written at: 70, 80 or 90 percent of the
  /// threshold yield.
  @$pb.TagNumber(11)
  $core.double get indemnityLevel => $_getN(10);
  @$pb.TagNumber(11)
  set indemnityLevel($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasIndemnityLevel() => $_has(10);
  @$pb.TagNumber(11)
  void clearIndemnityLevel() => $_clearField(11);

  /// Threshold yield in kg/ha — the average of the best five of the last seven
  /// seasons, scaled by the indemnity level. Below this a claim pays out.
  @$pb.TagNumber(12)
  $core.double get thresholdYieldKgHa => $_getN(11);
  @$pb.TagNumber(12)
  set thresholdYieldKgHa($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasThresholdYieldKgHa() => $_has(11);
  @$pb.TagNumber(12)
  void clearThresholdYieldKgHa() => $_clearField(12);

  @$pb.TagNumber(13)
  $pb.PbList<PremiumLine> get lines => $_getList(12);

  /// The full risk-bearing premium, before any subsidy.
  @$pb.TagNumber(14)
  $core.double get actuarialPremium => $_getN(13);
  @$pb.TagNumber(14)
  set actuarialPremium($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasActuarialPremium() => $_has(13);
  @$pb.TagNumber(14)
  void clearActuarialPremium() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get actuarialRate => $_getN(14);
  @$pb.TagNumber(15)
  set actuarialRate($core.double value) => $_setDouble(14, value);
  @$pb.TagNumber(15)
  $core.bool hasActuarialRate() => $_has(14);
  @$pb.TagNumber(15)
  void clearActuarialRate() => $_clearField(15);

  /// What the farmer actually pays after the scheme's cap.
  @$pb.TagNumber(16)
  $core.double get farmerPremium => $_getN(15);
  @$pb.TagNumber(16)
  set farmerPremium($core.double value) => $_setDouble(15, value);
  @$pb.TagNumber(16)
  $core.bool hasFarmerPremium() => $_has(15);
  @$pb.TagNumber(16)
  void clearFarmerPremium() => $_clearField(16);

  /// What the government pays to make up the difference.
  @$pb.TagNumber(17)
  $core.double get subsidy => $_getN(16);
  @$pb.TagNumber(17)
  set subsidy($core.double value) => $_setDouble(16, value);
  @$pb.TagNumber(17)
  $core.bool hasSubsidy() => $_has(16);
  @$pb.TagNumber(17)
  void clearSubsidy() => $_clearField(17);

  @$pb.TagNumber(18)
  QuoteConfidence get confidence => $_getN(17);
  @$pb.TagNumber(18)
  set confidence(QuoteConfidence value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasConfidence() => $_has(17);
  @$pb.TagNumber(18)
  void clearConfidence() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.int get historySeasons => $_getIZ(18);
  @$pb.TagNumber(19)
  set historySeasons($core.int value) => $_setSignedInt32(18, value);
  @$pb.TagNumber(19)
  $core.bool hasHistorySeasons() => $_has(18);
  @$pb.TagNumber(19)
  void clearHistorySeasons() => $_clearField(19);

  /// Said in plain words: what the quote rests on and where it is weak.
  @$pb.TagNumber(20)
  $core.String get basis => $_getSZ(19);
  @$pb.TagNumber(20)
  set basis($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasBasis() => $_has(19);
  @$pb.TagNumber(20)
  void clearBasis() => $_clearField(20);

  @$pb.TagNumber(21)
  $0.Timestamp get quotedAt => $_getN(20);
  @$pb.TagNumber(21)
  set quotedAt($0.Timestamp value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasQuotedAt() => $_has(20);
  @$pb.TagNumber(21)
  void clearQuotedAt() => $_clearField(21);
  @$pb.TagNumber(21)
  $0.Timestamp ensureQuotedAt() => $_ensure(20);

  @$pb.TagNumber(22)
  $0.Timestamp get expiresAt => $_getN(21);
  @$pb.TagNumber(22)
  set expiresAt($0.Timestamp value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasExpiresAt() => $_has(21);
  @$pb.TagNumber(22)
  void clearExpiresAt() => $_clearField(22);
  @$pb.TagNumber(22)
  $0.Timestamp ensureExpiresAt() => $_ensure(21);
}

/// ScoreFactor is one thing that moved the score, and by how much.
class ScoreFactor extends $pb.GeneratedMessage {
  factory ScoreFactor({
    $core.String? code,
    $core.String? label,
    $core.double? points,
    $core.double? value,
    $core.String? explanation,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (label != null) result.label = label;
    if (points != null) result.points = points;
    if (value != null) result.value = value;
    if (explanation != null) result.explanation = explanation;
    return result;
  }

  ScoreFactor._();

  factory ScoreFactor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScoreFactor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScoreFactor',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'code')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aD(3, _omitFieldNames ? '' : 'points')
    ..aD(4, _omitFieldNames ? '' : 'value')
    ..aOS(5, _omitFieldNames ? '' : 'explanation')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScoreFactor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScoreFactor copyWith(void Function(ScoreFactor) updates) =>
      super.copyWith((message) => updates(message as ScoreFactor))
          as ScoreFactor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScoreFactor create() => ScoreFactor._();
  @$core.override
  ScoreFactor createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScoreFactor getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScoreFactor>(create);
  static ScoreFactor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get code => $_getSZ(0);
  @$pb.TagNumber(1)
  set code($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  /// Points added or subtracted, so the arithmetic can be followed.
  @$pb.TagNumber(3)
  $core.double get points => $_getN(2);
  @$pb.TagNumber(3)
  set points($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPoints() => $_has(2);
  @$pb.TagNumber(3)
  void clearPoints() => $_clearField(3);

  /// The measured value the points came from.
  @$pb.TagNumber(4)
  $core.double get value => $_getN(3);
  @$pb.TagNumber(4)
  set value($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasValue() => $_has(3);
  @$pb.TagNumber(4)
  void clearValue() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get explanation => $_getSZ(4);
  @$pb.TagNumber(5)
  set explanation($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExplanation() => $_has(4);
  @$pb.TagNumber(5)
  void clearExplanation() => $_clearField(5);
}

/// CreditAssessment is a repayment-capacity reading built from farm records.
class CreditAssessment extends $pb.GeneratedMessage {
  factory CreditAssessment({
    $core.String? id,
    $core.String? farmId,
    ScoreStatus? status,
    $core.int? score,
    CreditBand? band,
    $core.Iterable<ScoreFactor>? factors,
    $core.int? seasonsConsidered,
    $core.double? meanYieldKgHa,
    $core.double? yieldVariability,
    $core.double? meanProfitPerHectare,
    $core.double? indicativeLimit,
    $core.String? caveat,
    $0.Timestamp? assessedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (farmId != null) result.farmId = farmId;
    if (status != null) result.status = status;
    if (score != null) result.score = score;
    if (band != null) result.band = band;
    if (factors != null) result.factors.addAll(factors);
    if (seasonsConsidered != null) result.seasonsConsidered = seasonsConsidered;
    if (meanYieldKgHa != null) result.meanYieldKgHa = meanYieldKgHa;
    if (yieldVariability != null) result.yieldVariability = yieldVariability;
    if (meanProfitPerHectare != null)
      result.meanProfitPerHectare = meanProfitPerHectare;
    if (indicativeLimit != null) result.indicativeLimit = indicativeLimit;
    if (caveat != null) result.caveat = caveat;
    if (assessedAt != null) result.assessedAt = assessedAt;
    return result;
  }

  CreditAssessment._();

  factory CreditAssessment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreditAssessment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreditAssessment',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aE<ScoreStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: ScoreStatus.values)
    ..aI(4, _omitFieldNames ? '' : 'score')
    ..aE<CreditBand>(5, _omitFieldNames ? '' : 'band',
        enumValues: CreditBand.values)
    ..pPM<ScoreFactor>(6, _omitFieldNames ? '' : 'factors',
        subBuilder: ScoreFactor.create)
    ..aI(7, _omitFieldNames ? '' : 'seasonsConsidered')
    ..aD(8, _omitFieldNames ? '' : 'meanYieldKgHa')
    ..aD(9, _omitFieldNames ? '' : 'yieldVariability')
    ..aD(10, _omitFieldNames ? '' : 'meanProfitPerHectare')
    ..aD(11, _omitFieldNames ? '' : 'indicativeLimit')
    ..aOS(12, _omitFieldNames ? '' : 'caveat')
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'assessedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreditAssessment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreditAssessment copyWith(void Function(CreditAssessment) updates) =>
      super.copyWith((message) => updates(message as CreditAssessment))
          as CreditAssessment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreditAssessment create() => CreditAssessment._();
  @$core.override
  CreditAssessment createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreditAssessment getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreditAssessment>(create);
  static CreditAssessment? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFarmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFarmId() => $_clearField(2);

  @$pb.TagNumber(3)
  ScoreStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(ScoreStatus value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  /// 300 to 900, the range Indian lenders read. Zero when not scored.
  @$pb.TagNumber(4)
  $core.int get score => $_getIZ(3);
  @$pb.TagNumber(4)
  set score($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasScore() => $_has(3);
  @$pb.TagNumber(4)
  void clearScore() => $_clearField(4);

  @$pb.TagNumber(5)
  CreditBand get band => $_getN(4);
  @$pb.TagNumber(5)
  set band(CreditBand value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasBand() => $_has(4);
  @$pb.TagNumber(5)
  void clearBand() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<ScoreFactor> get factors => $_getList(5);

  @$pb.TagNumber(7)
  $core.int get seasonsConsidered => $_getIZ(6);
  @$pb.TagNumber(7)
  set seasonsConsidered($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSeasonsConsidered() => $_has(6);
  @$pb.TagNumber(7)
  void clearSeasonsConsidered() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get meanYieldKgHa => $_getN(7);
  @$pb.TagNumber(8)
  set meanYieldKgHa($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMeanYieldKgHa() => $_has(7);
  @$pb.TagNumber(8)
  void clearMeanYieldKgHa() => $_clearField(8);

  /// Coefficient of variation of the yield history: the volatility a lender
  /// actually cares about.
  @$pb.TagNumber(9)
  $core.double get yieldVariability => $_getN(8);
  @$pb.TagNumber(9)
  set yieldVariability($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasYieldVariability() => $_has(8);
  @$pb.TagNumber(9)
  void clearYieldVariability() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get meanProfitPerHectare => $_getN(9);
  @$pb.TagNumber(10)
  set meanProfitPerHectare($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMeanProfitPerHectare() => $_has(9);
  @$pb.TagNumber(10)
  void clearMeanProfitPerHectare() => $_clearField(10);

  /// An indicative borrowing capacity from the records, not an offer.
  @$pb.TagNumber(11)
  $core.double get indicativeLimit => $_getN(10);
  @$pb.TagNumber(11)
  set indicativeLimit($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasIndicativeLimit() => $_has(10);
  @$pb.TagNumber(11)
  void clearIndicativeLimit() => $_clearField(11);

  /// Says out loud that this is a reading of farm records, not a lending
  /// decision, and what it does not include.
  @$pb.TagNumber(12)
  $core.String get caveat => $_getSZ(11);
  @$pb.TagNumber(12)
  set caveat($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasCaveat() => $_has(11);
  @$pb.TagNumber(12)
  void clearCaveat() => $_clearField(12);

  @$pb.TagNumber(13)
  $0.Timestamp get assessedAt => $_getN(12);
  @$pb.TagNumber(13)
  set assessedAt($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasAssessedAt() => $_has(12);
  @$pb.TagNumber(13)
  void clearAssessedAt() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureAssessedAt() => $_ensure(12);
}

/// Evidence is one item in a claim's pack.
class Evidence extends $pb.GeneratedMessage {
  factory Evidence({
    $core.String? id,
    EvidenceSource? source,
    EvidenceVerdict? verdict,
    $core.String? summary,
    $core.double? observed,
    $core.double? baseline,
    $core.String? unit,
    $0.Timestamp? observedAt,
    $core.String? reference,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (source != null) result.source = source;
    if (verdict != null) result.verdict = verdict;
    if (summary != null) result.summary = summary;
    if (observed != null) result.observed = observed;
    if (baseline != null) result.baseline = baseline;
    if (unit != null) result.unit = unit;
    if (observedAt != null) result.observedAt = observedAt;
    if (reference != null) result.reference = reference;
    return result;
  }

  Evidence._();

  factory Evidence.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Evidence.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Evidence',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<EvidenceSource>(2, _omitFieldNames ? '' : 'source',
        enumValues: EvidenceSource.values)
    ..aE<EvidenceVerdict>(3, _omitFieldNames ? '' : 'verdict',
        enumValues: EvidenceVerdict.values)
    ..aOS(4, _omitFieldNames ? '' : 'summary')
    ..aD(5, _omitFieldNames ? '' : 'observed')
    ..aD(6, _omitFieldNames ? '' : 'baseline')
    ..aOS(7, _omitFieldNames ? '' : 'unit')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'observedAt',
        subBuilder: $0.Timestamp.create)
    ..aOS(9, _omitFieldNames ? '' : 'reference')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Evidence clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Evidence copyWith(void Function(Evidence) updates) =>
      super.copyWith((message) => updates(message as Evidence)) as Evidence;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Evidence create() => Evidence._();
  @$core.override
  Evidence createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Evidence getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Evidence>(create);
  static Evidence? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  EvidenceSource get source => $_getN(1);
  @$pb.TagNumber(2)
  set source(EvidenceSource value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSource() => $_has(1);
  @$pb.TagNumber(2)
  void clearSource() => $_clearField(2);

  @$pb.TagNumber(3)
  EvidenceVerdict get verdict => $_getN(2);
  @$pb.TagNumber(3)
  set verdict(EvidenceVerdict value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasVerdict() => $_has(2);
  @$pb.TagNumber(3)
  void clearVerdict() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get summary => $_getSZ(3);
  @$pb.TagNumber(4)
  set summary($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSummary() => $_has(3);
  @$pb.TagNumber(4)
  void clearSummary() => $_clearField(4);

  /// The measured figure behind the verdict, and what it is compared against.
  @$pb.TagNumber(5)
  $core.double get observed => $_getN(4);
  @$pb.TagNumber(5)
  set observed($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasObserved() => $_has(4);
  @$pb.TagNumber(5)
  void clearObserved() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get baseline => $_getN(5);
  @$pb.TagNumber(6)
  set baseline($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBaseline() => $_has(5);
  @$pb.TagNumber(6)
  void clearBaseline() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get unit => $_getSZ(6);
  @$pb.TagNumber(7)
  set unit($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUnit() => $_has(6);
  @$pb.TagNumber(7)
  void clearUnit() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get observedAt => $_getN(7);
  @$pb.TagNumber(8)
  set observedAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasObservedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearObservedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureObservedAt() => $_ensure(7);

  /// A link to the image, reading or report this came from.
  @$pb.TagNumber(9)
  $core.String get reference => $_getSZ(8);
  @$pb.TagNumber(9)
  set reference($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasReference() => $_has(8);
  @$pb.TagNumber(9)
  void clearReference() => $_clearField(9);
}

/// Claim is a loss claim against a quote.
class Claim extends $pb.GeneratedMessage {
  factory Claim({
    $core.String? id,
    $core.String? quoteId,
    $core.String? fieldId,
    $core.String? farmId,
    $core.String? crop,
    Season? season,
    $core.int? year,
    LossCause? cause,
    $0.Timestamp? lossStartedOn,
    $0.Timestamp? lossEndedOn,
    $core.String? description,
    ClaimStatus? status,
    $core.double? claimedAreaHectares,
    $core.double? reportedYieldKgHa,
    $core.double? thresholdYieldKgHa,
    $core.double? indicatedPayout,
    $core.Iterable<Evidence>? evidence,
    $core.String? evidenceSummary,
    $core.String? submittedBy,
    $0.Timestamp? submittedAt,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $fixnum.Int64? version,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (quoteId != null) result.quoteId = quoteId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (crop != null) result.crop = crop;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (cause != null) result.cause = cause;
    if (lossStartedOn != null) result.lossStartedOn = lossStartedOn;
    if (lossEndedOn != null) result.lossEndedOn = lossEndedOn;
    if (description != null) result.description = description;
    if (status != null) result.status = status;
    if (claimedAreaHectares != null)
      result.claimedAreaHectares = claimedAreaHectares;
    if (reportedYieldKgHa != null) result.reportedYieldKgHa = reportedYieldKgHa;
    if (thresholdYieldKgHa != null)
      result.thresholdYieldKgHa = thresholdYieldKgHa;
    if (indicatedPayout != null) result.indicatedPayout = indicatedPayout;
    if (evidence != null) result.evidence.addAll(evidence);
    if (evidenceSummary != null) result.evidenceSummary = evidenceSummary;
    if (submittedBy != null) result.submittedBy = submittedBy;
    if (submittedAt != null) result.submittedAt = submittedAt;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (version != null) result.version = version;
    return result;
  }

  Claim._();

  factory Claim.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Claim.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Claim',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'quoteId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..aOS(5, _omitFieldNames ? '' : 'crop')
    ..aE<Season>(6, _omitFieldNames ? '' : 'season', enumValues: Season.values)
    ..aI(7, _omitFieldNames ? '' : 'year')
    ..aE<LossCause>(8, _omitFieldNames ? '' : 'cause',
        enumValues: LossCause.values)
    ..aOM<$0.Timestamp>(9, _omitFieldNames ? '' : 'lossStartedOn',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'lossEndedOn',
        subBuilder: $0.Timestamp.create)
    ..aOS(11, _omitFieldNames ? '' : 'description')
    ..aE<ClaimStatus>(12, _omitFieldNames ? '' : 'status',
        enumValues: ClaimStatus.values)
    ..aD(13, _omitFieldNames ? '' : 'claimedAreaHectares')
    ..aD(14, _omitFieldNames ? '' : 'reportedYieldKgHa')
    ..aD(15, _omitFieldNames ? '' : 'thresholdYieldKgHa')
    ..aD(16, _omitFieldNames ? '' : 'indicatedPayout')
    ..pPM<Evidence>(17, _omitFieldNames ? '' : 'evidence',
        subBuilder: Evidence.create)
    ..aOS(18, _omitFieldNames ? '' : 'evidenceSummary')
    ..aOS(19, _omitFieldNames ? '' : 'submittedBy')
    ..aOM<$0.Timestamp>(20, _omitFieldNames ? '' : 'submittedAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(21, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(22, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aInt64(23, _omitFieldNames ? '' : 'version')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Claim clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Claim copyWith(void Function(Claim) updates) =>
      super.copyWith((message) => updates(message as Claim)) as Claim;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Claim create() => Claim._();
  @$core.override
  Claim createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Claim getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Claim>(create);
  static Claim? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get quoteId => $_getSZ(1);
  @$pb.TagNumber(2)
  set quoteId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuoteId() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuoteId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fieldId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get farmId => $_getSZ(3);
  @$pb.TagNumber(4)
  set farmId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFarmId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFarmId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get crop => $_getSZ(4);
  @$pb.TagNumber(5)
  set crop($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCrop() => $_has(4);
  @$pb.TagNumber(5)
  void clearCrop() => $_clearField(5);

  @$pb.TagNumber(6)
  Season get season => $_getN(5);
  @$pb.TagNumber(6)
  set season(Season value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSeason() => $_has(5);
  @$pb.TagNumber(6)
  void clearSeason() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get year => $_getIZ(6);
  @$pb.TagNumber(7)
  set year($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasYear() => $_has(6);
  @$pb.TagNumber(7)
  void clearYear() => $_clearField(7);

  @$pb.TagNumber(8)
  LossCause get cause => $_getN(7);
  @$pb.TagNumber(8)
  set cause(LossCause value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCause() => $_has(7);
  @$pb.TagNumber(8)
  void clearCause() => $_clearField(8);

  @$pb.TagNumber(9)
  $0.Timestamp get lossStartedOn => $_getN(8);
  @$pb.TagNumber(9)
  set lossStartedOn($0.Timestamp value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasLossStartedOn() => $_has(8);
  @$pb.TagNumber(9)
  void clearLossStartedOn() => $_clearField(9);
  @$pb.TagNumber(9)
  $0.Timestamp ensureLossStartedOn() => $_ensure(8);

  @$pb.TagNumber(10)
  $0.Timestamp get lossEndedOn => $_getN(9);
  @$pb.TagNumber(10)
  set lossEndedOn($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasLossEndedOn() => $_has(9);
  @$pb.TagNumber(10)
  void clearLossEndedOn() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureLossEndedOn() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.String get description => $_getSZ(10);
  @$pb.TagNumber(11)
  set description($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasDescription() => $_has(10);
  @$pb.TagNumber(11)
  void clearDescription() => $_clearField(11);

  @$pb.TagNumber(12)
  ClaimStatus get status => $_getN(11);
  @$pb.TagNumber(12)
  set status(ClaimStatus value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasStatus() => $_has(11);
  @$pb.TagNumber(12)
  void clearStatus() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get claimedAreaHectares => $_getN(12);
  @$pb.TagNumber(13)
  set claimedAreaHectares($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasClaimedAreaHectares() => $_has(12);
  @$pb.TagNumber(13)
  void clearClaimedAreaHectares() => $_clearField(13);

  /// The yield the claimant reports, against the threshold the quote insured.
  @$pb.TagNumber(14)
  $core.double get reportedYieldKgHa => $_getN(13);
  @$pb.TagNumber(14)
  set reportedYieldKgHa($core.double value) => $_setDouble(13, value);
  @$pb.TagNumber(14)
  $core.bool hasReportedYieldKgHa() => $_has(13);
  @$pb.TagNumber(14)
  void clearReportedYieldKgHa() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get thresholdYieldKgHa => $_getN(14);
  @$pb.TagNumber(15)
  set thresholdYieldKgHa($core.double value) => $_setDouble(14, value);
  @$pb.TagNumber(15)
  $core.bool hasThresholdYieldKgHa() => $_has(14);
  @$pb.TagNumber(15)
  void clearThresholdYieldKgHa() => $_clearField(15);

  /// What the policy formula produces from those two figures. An arithmetic
  /// result, not an approval.
  @$pb.TagNumber(16)
  $core.double get indicatedPayout => $_getN(15);
  @$pb.TagNumber(16)
  set indicatedPayout($core.double value) => $_setDouble(15, value);
  @$pb.TagNumber(16)
  $core.bool hasIndicatedPayout() => $_has(15);
  @$pb.TagNumber(16)
  void clearIndicatedPayout() => $_clearField(16);

  @$pb.TagNumber(17)
  $pb.PbList<Evidence> get evidence => $_getList(16);

  /// What the pack as a whole says, in plain words, without deciding the claim.
  @$pb.TagNumber(18)
  $core.String get evidenceSummary => $_getSZ(17);
  @$pb.TagNumber(18)
  set evidenceSummary($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasEvidenceSummary() => $_has(17);
  @$pb.TagNumber(18)
  void clearEvidenceSummary() => $_clearField(18);

  @$pb.TagNumber(19)
  $core.String get submittedBy => $_getSZ(18);
  @$pb.TagNumber(19)
  set submittedBy($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasSubmittedBy() => $_has(18);
  @$pb.TagNumber(19)
  void clearSubmittedBy() => $_clearField(19);

  @$pb.TagNumber(20)
  $0.Timestamp get submittedAt => $_getN(19);
  @$pb.TagNumber(20)
  set submittedAt($0.Timestamp value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasSubmittedAt() => $_has(19);
  @$pb.TagNumber(20)
  void clearSubmittedAt() => $_clearField(20);
  @$pb.TagNumber(20)
  $0.Timestamp ensureSubmittedAt() => $_ensure(19);

  @$pb.TagNumber(21)
  $0.Timestamp get createdAt => $_getN(20);
  @$pb.TagNumber(21)
  set createdAt($0.Timestamp value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasCreatedAt() => $_has(20);
  @$pb.TagNumber(21)
  void clearCreatedAt() => $_clearField(21);
  @$pb.TagNumber(21)
  $0.Timestamp ensureCreatedAt() => $_ensure(20);

  @$pb.TagNumber(22)
  $0.Timestamp get updatedAt => $_getN(21);
  @$pb.TagNumber(22)
  set updatedAt($0.Timestamp value) => $_setField(22, value);
  @$pb.TagNumber(22)
  $core.bool hasUpdatedAt() => $_has(21);
  @$pb.TagNumber(22)
  void clearUpdatedAt() => $_clearField(22);
  @$pb.TagNumber(22)
  $0.Timestamp ensureUpdatedAt() => $_ensure(21);

  @$pb.TagNumber(23)
  $fixnum.Int64 get version => $_getI64(22);
  @$pb.TagNumber(23)
  set version($fixnum.Int64 value) => $_setInt64(22, value);
  @$pb.TagNumber(23)
  $core.bool hasVersion() => $_has(22);
  @$pb.TagNumber(23)
  void clearVersion() => $_clearField(23);
}

class QuoteInsuranceRequest extends $pb.GeneratedMessage {
  factory QuoteInsuranceRequest({
    $core.String? fieldId,
    $core.String? farmId,
    $core.String? crop,
    CropCategory? category,
    Season? season,
    $core.int? year,
    $core.double? areaHectares,
    $core.double? sumInsuredPerHectare,
    $core.double? indemnityLevel,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (crop != null) result.crop = crop;
    if (category != null) result.category = category;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (areaHectares != null) result.areaHectares = areaHectares;
    if (sumInsuredPerHectare != null)
      result.sumInsuredPerHectare = sumInsuredPerHectare;
    if (indemnityLevel != null) result.indemnityLevel = indemnityLevel;
    return result;
  }

  QuoteInsuranceRequest._();

  factory QuoteInsuranceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QuoteInsuranceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuoteInsuranceRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aOS(3, _omitFieldNames ? '' : 'crop')
    ..aE<CropCategory>(4, _omitFieldNames ? '' : 'category',
        enumValues: CropCategory.values)
    ..aE<Season>(5, _omitFieldNames ? '' : 'season', enumValues: Season.values)
    ..aI(6, _omitFieldNames ? '' : 'year')
    ..aD(7, _omitFieldNames ? '' : 'areaHectares')
    ..aD(8, _omitFieldNames ? '' : 'sumInsuredPerHectare')
    ..aD(9, _omitFieldNames ? '' : 'indemnityLevel')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuoteInsuranceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuoteInsuranceRequest copyWith(
          void Function(QuoteInsuranceRequest) updates) =>
      super.copyWith((message) => updates(message as QuoteInsuranceRequest))
          as QuoteInsuranceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QuoteInsuranceRequest create() => QuoteInsuranceRequest._();
  @$core.override
  QuoteInsuranceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QuoteInsuranceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QuoteInsuranceRequest>(create);
  static QuoteInsuranceRequest? _defaultInstance;

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
  $core.String get crop => $_getSZ(2);
  @$pb.TagNumber(3)
  set crop($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCrop() => $_has(2);
  @$pb.TagNumber(3)
  void clearCrop() => $_clearField(3);

  @$pb.TagNumber(4)
  CropCategory get category => $_getN(3);
  @$pb.TagNumber(4)
  set category(CropCategory value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCategory() => $_has(3);
  @$pb.TagNumber(4)
  void clearCategory() => $_clearField(4);

  @$pb.TagNumber(5)
  Season get season => $_getN(4);
  @$pb.TagNumber(5)
  set season(Season value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSeason() => $_has(4);
  @$pb.TagNumber(5)
  void clearSeason() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get year => $_getIZ(5);
  @$pb.TagNumber(6)
  set year($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasYear() => $_has(5);
  @$pb.TagNumber(6)
  void clearYear() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get areaHectares => $_getN(6);
  @$pb.TagNumber(7)
  set areaHectares($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAreaHectares() => $_has(6);
  @$pb.TagNumber(7)
  void clearAreaHectares() => $_clearField(7);

  /// Optional. Defaults to the scale-of-finance figure for the crop.
  @$pb.TagNumber(8)
  $core.double get sumInsuredPerHectare => $_getN(7);
  @$pb.TagNumber(8)
  set sumInsuredPerHectare($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSumInsuredPerHectare() => $_has(7);
  @$pb.TagNumber(8)
  void clearSumInsuredPerHectare() => $_clearField(8);

  /// 70, 80 or 90. Defaults to 80.
  @$pb.TagNumber(9)
  $core.double get indemnityLevel => $_getN(8);
  @$pb.TagNumber(9)
  set indemnityLevel($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasIndemnityLevel() => $_has(8);
  @$pb.TagNumber(9)
  void clearIndemnityLevel() => $_clearField(9);
}

class QuoteInsuranceResponse extends $pb.GeneratedMessage {
  factory QuoteInsuranceResponse({
    InsuranceQuote? quote,
  }) {
    final result = create();
    if (quote != null) result.quote = quote;
    return result;
  }

  QuoteInsuranceResponse._();

  factory QuoteInsuranceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory QuoteInsuranceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'QuoteInsuranceResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOM<InsuranceQuote>(1, _omitFieldNames ? '' : 'quote',
        subBuilder: InsuranceQuote.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuoteInsuranceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  QuoteInsuranceResponse copyWith(
          void Function(QuoteInsuranceResponse) updates) =>
      super.copyWith((message) => updates(message as QuoteInsuranceResponse))
          as QuoteInsuranceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static QuoteInsuranceResponse create() => QuoteInsuranceResponse._();
  @$core.override
  QuoteInsuranceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static QuoteInsuranceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<QuoteInsuranceResponse>(create);
  static QuoteInsuranceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InsuranceQuote get quote => $_getN(0);
  @$pb.TagNumber(1)
  set quote(InsuranceQuote value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasQuote() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuote() => $_clearField(1);
  @$pb.TagNumber(1)
  InsuranceQuote ensureQuote() => $_ensure(0);
}

class GetQuoteRequest extends $pb.GeneratedMessage {
  factory GetQuoteRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetQuoteRequest._();

  factory GetQuoteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetQuoteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetQuoteRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetQuoteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetQuoteRequest copyWith(void Function(GetQuoteRequest) updates) =>
      super.copyWith((message) => updates(message as GetQuoteRequest))
          as GetQuoteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetQuoteRequest create() => GetQuoteRequest._();
  @$core.override
  GetQuoteRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetQuoteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetQuoteRequest>(create);
  static GetQuoteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetQuoteResponse extends $pb.GeneratedMessage {
  factory GetQuoteResponse({
    InsuranceQuote? quote,
  }) {
    final result = create();
    if (quote != null) result.quote = quote;
    return result;
  }

  GetQuoteResponse._();

  factory GetQuoteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetQuoteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetQuoteResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOM<InsuranceQuote>(1, _omitFieldNames ? '' : 'quote',
        subBuilder: InsuranceQuote.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetQuoteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetQuoteResponse copyWith(void Function(GetQuoteResponse) updates) =>
      super.copyWith((message) => updates(message as GetQuoteResponse))
          as GetQuoteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetQuoteResponse create() => GetQuoteResponse._();
  @$core.override
  GetQuoteResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetQuoteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetQuoteResponse>(create);
  static GetQuoteResponse? _defaultInstance;

  @$pb.TagNumber(1)
  InsuranceQuote get quote => $_getN(0);
  @$pb.TagNumber(1)
  set quote(InsuranceQuote value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasQuote() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuote() => $_clearField(1);
  @$pb.TagNumber(1)
  InsuranceQuote ensureQuote() => $_ensure(0);
}

class ListQuotesRequest extends $pb.GeneratedMessage {
  factory ListQuotesRequest({
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

  ListQuotesRequest._();

  factory ListQuotesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListQuotesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListQuotesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aI(3, _omitFieldNames ? '' : 'year')
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aOS(5, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListQuotesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListQuotesRequest copyWith(void Function(ListQuotesRequest) updates) =>
      super.copyWith((message) => updates(message as ListQuotesRequest))
          as ListQuotesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListQuotesRequest create() => ListQuotesRequest._();
  @$core.override
  ListQuotesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListQuotesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListQuotesRequest>(create);
  static ListQuotesRequest? _defaultInstance;

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

class ListQuotesResponse extends $pb.GeneratedMessage {
  factory ListQuotesResponse({
    $core.Iterable<InsuranceQuote>? quotes,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (quotes != null) result.quotes.addAll(quotes);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListQuotesResponse._();

  factory ListQuotesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListQuotesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListQuotesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..pPM<InsuranceQuote>(1, _omitFieldNames ? '' : 'quotes',
        subBuilder: InsuranceQuote.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListQuotesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListQuotesResponse copyWith(void Function(ListQuotesResponse) updates) =>
      super.copyWith((message) => updates(message as ListQuotesResponse))
          as ListQuotesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListQuotesResponse create() => ListQuotesResponse._();
  @$core.override
  ListQuotesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListQuotesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListQuotesResponse>(create);
  static ListQuotesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<InsuranceQuote> get quotes => $_getList(0);

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

class AssessCreditRequest extends $pb.GeneratedMessage {
  factory AssessCreditRequest({
    $core.String? farmId,
    $core.int? fromYear,
    $core.int? toYear,
  }) {
    final result = create();
    if (farmId != null) result.farmId = farmId;
    if (fromYear != null) result.fromYear = fromYear;
    if (toYear != null) result.toYear = toYear;
    return result;
  }

  AssessCreditRequest._();

  factory AssessCreditRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AssessCreditRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AssessCreditRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'farmId')
    ..aI(2, _omitFieldNames ? '' : 'fromYear')
    ..aI(3, _omitFieldNames ? '' : 'toYear')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssessCreditRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssessCreditRequest copyWith(void Function(AssessCreditRequest) updates) =>
      super.copyWith((message) => updates(message as AssessCreditRequest))
          as AssessCreditRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AssessCreditRequest create() => AssessCreditRequest._();
  @$core.override
  AssessCreditRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AssessCreditRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AssessCreditRequest>(create);
  static AssessCreditRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFarmId() => $_has(0);
  @$pb.TagNumber(1)
  void clearFarmId() => $_clearField(1);

  /// How far back to look. Defaults to the last ten seasons.
  @$pb.TagNumber(2)
  $core.int get fromYear => $_getIZ(1);
  @$pb.TagNumber(2)
  set fromYear($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFromYear() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromYear() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get toYear => $_getIZ(2);
  @$pb.TagNumber(3)
  set toYear($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasToYear() => $_has(2);
  @$pb.TagNumber(3)
  void clearToYear() => $_clearField(3);
}

class AssessCreditResponse extends $pb.GeneratedMessage {
  factory AssessCreditResponse({
    CreditAssessment? assessment,
  }) {
    final result = create();
    if (assessment != null) result.assessment = assessment;
    return result;
  }

  AssessCreditResponse._();

  factory AssessCreditResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AssessCreditResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AssessCreditResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOM<CreditAssessment>(1, _omitFieldNames ? '' : 'assessment',
        subBuilder: CreditAssessment.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssessCreditResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AssessCreditResponse copyWith(void Function(AssessCreditResponse) updates) =>
      super.copyWith((message) => updates(message as AssessCreditResponse))
          as AssessCreditResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AssessCreditResponse create() => AssessCreditResponse._();
  @$core.override
  AssessCreditResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AssessCreditResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AssessCreditResponse>(create);
  static AssessCreditResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CreditAssessment get assessment => $_getN(0);
  @$pb.TagNumber(1)
  set assessment(CreditAssessment value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAssessment() => $_has(0);
  @$pb.TagNumber(1)
  void clearAssessment() => $_clearField(1);
  @$pb.TagNumber(1)
  CreditAssessment ensureAssessment() => $_ensure(0);
}

class GetCreditAssessmentRequest extends $pb.GeneratedMessage {
  factory GetCreditAssessmentRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetCreditAssessmentRequest._();

  factory GetCreditAssessmentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCreditAssessmentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCreditAssessmentRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCreditAssessmentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCreditAssessmentRequest copyWith(
          void Function(GetCreditAssessmentRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetCreditAssessmentRequest))
          as GetCreditAssessmentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCreditAssessmentRequest create() => GetCreditAssessmentRequest._();
  @$core.override
  GetCreditAssessmentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCreditAssessmentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCreditAssessmentRequest>(create);
  static GetCreditAssessmentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetCreditAssessmentResponse extends $pb.GeneratedMessage {
  factory GetCreditAssessmentResponse({
    CreditAssessment? assessment,
  }) {
    final result = create();
    if (assessment != null) result.assessment = assessment;
    return result;
  }

  GetCreditAssessmentResponse._();

  factory GetCreditAssessmentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetCreditAssessmentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCreditAssessmentResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOM<CreditAssessment>(1, _omitFieldNames ? '' : 'assessment',
        subBuilder: CreditAssessment.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCreditAssessmentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCreditAssessmentResponse copyWith(
          void Function(GetCreditAssessmentResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetCreditAssessmentResponse))
          as GetCreditAssessmentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCreditAssessmentResponse create() =>
      GetCreditAssessmentResponse._();
  @$core.override
  GetCreditAssessmentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetCreditAssessmentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCreditAssessmentResponse>(create);
  static GetCreditAssessmentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  CreditAssessment get assessment => $_getN(0);
  @$pb.TagNumber(1)
  set assessment(CreditAssessment value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAssessment() => $_has(0);
  @$pb.TagNumber(1)
  void clearAssessment() => $_clearField(1);
  @$pb.TagNumber(1)
  CreditAssessment ensureAssessment() => $_ensure(0);
}

class FileClaimRequest extends $pb.GeneratedMessage {
  factory FileClaimRequest({
    $core.String? quoteId,
    $core.String? fieldId,
    LossCause? cause,
    $0.Timestamp? lossStartedOn,
    $0.Timestamp? lossEndedOn,
    $core.String? description,
    $core.double? claimedAreaHectares,
    $core.double? reportedYieldKgHa,
  }) {
    final result = create();
    if (quoteId != null) result.quoteId = quoteId;
    if (fieldId != null) result.fieldId = fieldId;
    if (cause != null) result.cause = cause;
    if (lossStartedOn != null) result.lossStartedOn = lossStartedOn;
    if (lossEndedOn != null) result.lossEndedOn = lossEndedOn;
    if (description != null) result.description = description;
    if (claimedAreaHectares != null)
      result.claimedAreaHectares = claimedAreaHectares;
    if (reportedYieldKgHa != null) result.reportedYieldKgHa = reportedYieldKgHa;
    return result;
  }

  FileClaimRequest._();

  factory FileClaimRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FileClaimRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileClaimRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'quoteId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aE<LossCause>(3, _omitFieldNames ? '' : 'cause',
        enumValues: LossCause.values)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'lossStartedOn',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'lossEndedOn',
        subBuilder: $0.Timestamp.create)
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aD(7, _omitFieldNames ? '' : 'claimedAreaHectares')
    ..aD(8, _omitFieldNames ? '' : 'reportedYieldKgHa')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileClaimRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileClaimRequest copyWith(void Function(FileClaimRequest) updates) =>
      super.copyWith((message) => updates(message as FileClaimRequest))
          as FileClaimRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileClaimRequest create() => FileClaimRequest._();
  @$core.override
  FileClaimRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FileClaimRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileClaimRequest>(create);
  static FileClaimRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get quoteId => $_getSZ(0);
  @$pb.TagNumber(1)
  set quoteId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuoteId() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuoteId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  LossCause get cause => $_getN(2);
  @$pb.TagNumber(3)
  set cause(LossCause value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasCause() => $_has(2);
  @$pb.TagNumber(3)
  void clearCause() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get lossStartedOn => $_getN(3);
  @$pb.TagNumber(4)
  set lossStartedOn($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLossStartedOn() => $_has(3);
  @$pb.TagNumber(4)
  void clearLossStartedOn() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureLossStartedOn() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Timestamp get lossEndedOn => $_getN(4);
  @$pb.TagNumber(5)
  set lossEndedOn($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLossEndedOn() => $_has(4);
  @$pb.TagNumber(5)
  void clearLossEndedOn() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureLossEndedOn() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get claimedAreaHectares => $_getN(6);
  @$pb.TagNumber(7)
  set claimedAreaHectares($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasClaimedAreaHectares() => $_has(6);
  @$pb.TagNumber(7)
  void clearClaimedAreaHectares() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get reportedYieldKgHa => $_getN(7);
  @$pb.TagNumber(8)
  set reportedYieldKgHa($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasReportedYieldKgHa() => $_has(7);
  @$pb.TagNumber(8)
  void clearReportedYieldKgHa() => $_clearField(8);
}

class FileClaimResponse extends $pb.GeneratedMessage {
  factory FileClaimResponse({
    Claim? claim,
  }) {
    final result = create();
    if (claim != null) result.claim = claim;
    return result;
  }

  FileClaimResponse._();

  factory FileClaimResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FileClaimResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FileClaimResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOM<Claim>(1, _omitFieldNames ? '' : 'claim', subBuilder: Claim.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileClaimResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileClaimResponse copyWith(void Function(FileClaimResponse) updates) =>
      super.copyWith((message) => updates(message as FileClaimResponse))
          as FileClaimResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileClaimResponse create() => FileClaimResponse._();
  @$core.override
  FileClaimResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FileClaimResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FileClaimResponse>(create);
  static FileClaimResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Claim get claim => $_getN(0);
  @$pb.TagNumber(1)
  set claim(Claim value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasClaim() => $_has(0);
  @$pb.TagNumber(1)
  void clearClaim() => $_clearField(1);
  @$pb.TagNumber(1)
  Claim ensureClaim() => $_ensure(0);
}

class GatherEvidenceRequest extends $pb.GeneratedMessage {
  factory GatherEvidenceRequest({
    $core.String? claimId,
  }) {
    final result = create();
    if (claimId != null) result.claimId = claimId;
    return result;
  }

  GatherEvidenceRequest._();

  factory GatherEvidenceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GatherEvidenceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GatherEvidenceRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'claimId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GatherEvidenceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GatherEvidenceRequest copyWith(
          void Function(GatherEvidenceRequest) updates) =>
      super.copyWith((message) => updates(message as GatherEvidenceRequest))
          as GatherEvidenceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GatherEvidenceRequest create() => GatherEvidenceRequest._();
  @$core.override
  GatherEvidenceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GatherEvidenceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GatherEvidenceRequest>(create);
  static GatherEvidenceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get claimId => $_getSZ(0);
  @$pb.TagNumber(1)
  set claimId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClaimId() => $_has(0);
  @$pb.TagNumber(1)
  void clearClaimId() => $_clearField(1);
}

class GatherEvidenceResponse extends $pb.GeneratedMessage {
  factory GatherEvidenceResponse({
    Claim? claim,
  }) {
    final result = create();
    if (claim != null) result.claim = claim;
    return result;
  }

  GatherEvidenceResponse._();

  factory GatherEvidenceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GatherEvidenceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GatherEvidenceResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOM<Claim>(1, _omitFieldNames ? '' : 'claim', subBuilder: Claim.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GatherEvidenceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GatherEvidenceResponse copyWith(
          void Function(GatherEvidenceResponse) updates) =>
      super.copyWith((message) => updates(message as GatherEvidenceResponse))
          as GatherEvidenceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GatherEvidenceResponse create() => GatherEvidenceResponse._();
  @$core.override
  GatherEvidenceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GatherEvidenceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GatherEvidenceResponse>(create);
  static GatherEvidenceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Claim get claim => $_getN(0);
  @$pb.TagNumber(1)
  set claim(Claim value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasClaim() => $_has(0);
  @$pb.TagNumber(1)
  void clearClaim() => $_clearField(1);
  @$pb.TagNumber(1)
  Claim ensureClaim() => $_ensure(0);
}

class GetClaimRequest extends $pb.GeneratedMessage {
  factory GetClaimRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetClaimRequest._();

  factory GetClaimRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetClaimRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetClaimRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetClaimRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetClaimRequest copyWith(void Function(GetClaimRequest) updates) =>
      super.copyWith((message) => updates(message as GetClaimRequest))
          as GetClaimRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetClaimRequest create() => GetClaimRequest._();
  @$core.override
  GetClaimRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetClaimRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetClaimRequest>(create);
  static GetClaimRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetClaimResponse extends $pb.GeneratedMessage {
  factory GetClaimResponse({
    Claim? claim,
  }) {
    final result = create();
    if (claim != null) result.claim = claim;
    return result;
  }

  GetClaimResponse._();

  factory GetClaimResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetClaimResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetClaimResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOM<Claim>(1, _omitFieldNames ? '' : 'claim', subBuilder: Claim.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetClaimResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetClaimResponse copyWith(void Function(GetClaimResponse) updates) =>
      super.copyWith((message) => updates(message as GetClaimResponse))
          as GetClaimResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetClaimResponse create() => GetClaimResponse._();
  @$core.override
  GetClaimResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetClaimResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetClaimResponse>(create);
  static GetClaimResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Claim get claim => $_getN(0);
  @$pb.TagNumber(1)
  set claim(Claim value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasClaim() => $_has(0);
  @$pb.TagNumber(1)
  void clearClaim() => $_clearField(1);
  @$pb.TagNumber(1)
  Claim ensureClaim() => $_ensure(0);
}

class ListClaimsRequest extends $pb.GeneratedMessage {
  factory ListClaimsRequest({
    $core.String? fieldId,
    $core.String? farmId,
    ClaimStatus? status,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (status != null) result.status = status;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListClaimsRequest._();

  factory ListClaimsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListClaimsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListClaimsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aE<ClaimStatus>(3, _omitFieldNames ? '' : 'status',
        enumValues: ClaimStatus.values)
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aOS(5, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListClaimsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListClaimsRequest copyWith(void Function(ListClaimsRequest) updates) =>
      super.copyWith((message) => updates(message as ListClaimsRequest))
          as ListClaimsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListClaimsRequest create() => ListClaimsRequest._();
  @$core.override
  ListClaimsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListClaimsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListClaimsRequest>(create);
  static ListClaimsRequest? _defaultInstance;

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
  ClaimStatus get status => $_getN(2);
  @$pb.TagNumber(3)
  set status(ClaimStatus value) => $_setField(3, value);
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

class ListClaimsResponse extends $pb.GeneratedMessage {
  factory ListClaimsResponse({
    $core.Iterable<Claim>? claims,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (claims != null) result.claims.addAll(claims);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListClaimsResponse._();

  factory ListClaimsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListClaimsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListClaimsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..pPM<Claim>(1, _omitFieldNames ? '' : 'claims', subBuilder: Claim.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListClaimsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListClaimsResponse copyWith(void Function(ListClaimsResponse) updates) =>
      super.copyWith((message) => updates(message as ListClaimsResponse))
          as ListClaimsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListClaimsResponse create() => ListClaimsResponse._();
  @$core.override
  ListClaimsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListClaimsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListClaimsResponse>(create);
  static ListClaimsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Claim> get claims => $_getList(0);

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

class UpdateClaimStatusRequest extends $pb.GeneratedMessage {
  factory UpdateClaimStatusRequest({
    $core.String? id,
    ClaimStatus? status,
    $core.String? note,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (status != null) result.status = status;
    if (note != null) result.note = note;
    return result;
  }

  UpdateClaimStatusRequest._();

  factory UpdateClaimStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateClaimStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateClaimStatusRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<ClaimStatus>(2, _omitFieldNames ? '' : 'status',
        enumValues: ClaimStatus.values)
    ..aOS(3, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateClaimStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateClaimStatusRequest copyWith(
          void Function(UpdateClaimStatusRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateClaimStatusRequest))
          as UpdateClaimStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateClaimStatusRequest create() => UpdateClaimStatusRequest._();
  @$core.override
  UpdateClaimStatusRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateClaimStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateClaimStatusRequest>(create);
  static UpdateClaimStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  ClaimStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(ClaimStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get note => $_getSZ(2);
  @$pb.TagNumber(3)
  set note($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNote() => $_has(2);
  @$pb.TagNumber(3)
  void clearNote() => $_clearField(3);
}

class UpdateClaimStatusResponse extends $pb.GeneratedMessage {
  factory UpdateClaimStatusResponse({
    Claim? claim,
  }) {
    final result = create();
    if (claim != null) result.claim = claim;
    return result;
  }

  UpdateClaimStatusResponse._();

  factory UpdateClaimStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UpdateClaimStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UpdateClaimStatusResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.finance.v1'),
      createEmptyInstance: create)
    ..aOM<Claim>(1, _omitFieldNames ? '' : 'claim', subBuilder: Claim.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateClaimStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateClaimStatusResponse copyWith(
          void Function(UpdateClaimStatusResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateClaimStatusResponse))
          as UpdateClaimStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateClaimStatusResponse create() => UpdateClaimStatusResponse._();
  @$core.override
  UpdateClaimStatusResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UpdateClaimStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateClaimStatusResponse>(create);
  static UpdateClaimStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Claim get claim => $_getN(0);
  @$pb.TagNumber(1)
  set claim(Claim value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasClaim() => $_has(0);
  @$pb.TagNumber(1)
  void clearClaim() => $_clearField(1);
  @$pb.TagNumber(1)
  Claim ensureClaim() => $_ensure(0);
}

/// FinanceService prices crop cover, reads farm records for credit, and
/// assembles the evidence behind a loss claim.
class FinanceServiceApi {
  final $pb.RpcClient _client;

  FinanceServiceApi(this._client);

  $async.Future<QuoteInsuranceResponse> quoteInsurance(
          $pb.ClientContext? ctx, QuoteInsuranceRequest request) =>
      _client.invoke<QuoteInsuranceResponse>(ctx, 'FinanceService',
          'QuoteInsurance', request, QuoteInsuranceResponse());
  $async.Future<GetQuoteResponse> getQuote(
          $pb.ClientContext? ctx, GetQuoteRequest request) =>
      _client.invoke<GetQuoteResponse>(
          ctx, 'FinanceService', 'GetQuote', request, GetQuoteResponse());
  $async.Future<ListQuotesResponse> listQuotes(
          $pb.ClientContext? ctx, ListQuotesRequest request) =>
      _client.invoke<ListQuotesResponse>(
          ctx, 'FinanceService', 'ListQuotes', request, ListQuotesResponse());
  $async.Future<AssessCreditResponse> assessCredit(
          $pb.ClientContext? ctx, AssessCreditRequest request) =>
      _client.invoke<AssessCreditResponse>(ctx, 'FinanceService',
          'AssessCredit', request, AssessCreditResponse());
  $async.Future<GetCreditAssessmentResponse> getCreditAssessment(
          $pb.ClientContext? ctx, GetCreditAssessmentRequest request) =>
      _client.invoke<GetCreditAssessmentResponse>(ctx, 'FinanceService',
          'GetCreditAssessment', request, GetCreditAssessmentResponse());
  $async.Future<FileClaimResponse> fileClaim(
          $pb.ClientContext? ctx, FileClaimRequest request) =>
      _client.invoke<FileClaimResponse>(
          ctx, 'FinanceService', 'FileClaim', request, FileClaimResponse());
  $async.Future<GatherEvidenceResponse> gatherEvidence(
          $pb.ClientContext? ctx, GatherEvidenceRequest request) =>
      _client.invoke<GatherEvidenceResponse>(ctx, 'FinanceService',
          'GatherEvidence', request, GatherEvidenceResponse());
  $async.Future<GetClaimResponse> getClaim(
          $pb.ClientContext? ctx, GetClaimRequest request) =>
      _client.invoke<GetClaimResponse>(
          ctx, 'FinanceService', 'GetClaim', request, GetClaimResponse());
  $async.Future<ListClaimsResponse> listClaims(
          $pb.ClientContext? ctx, ListClaimsRequest request) =>
      _client.invoke<ListClaimsResponse>(
          ctx, 'FinanceService', 'ListClaims', request, ListClaimsResponse());
  $async.Future<UpdateClaimStatusResponse> updateClaimStatus(
          $pb.ClientContext? ctx, UpdateClaimStatusRequest request) =>
      _client.invoke<UpdateClaimStatusResponse>(ctx, 'FinanceService',
          'UpdateClaimStatus', request, UpdateClaimStatusResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
