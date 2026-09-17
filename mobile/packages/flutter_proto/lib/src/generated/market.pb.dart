// This is a generated file - do not edit.
//
// Generated from market.proto.

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

import 'market.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'market.pbenum.dart';

/// Market is a place prices are quoted.
class Market extends $pb.GeneratedMessage {
  factory Market({
    $core.String? id,
    $core.String? name,
    MarketKind? kind,
    $core.String? state,
    $core.String? district,
    $core.double? latitude,
    $core.double? longitude,
    $core.String? externalRef,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (kind != null) result.kind = kind;
    if (state != null) result.state = state;
    if (district != null) result.district = district;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (externalRef != null) result.externalRef = externalRef;
    return result;
  }

  Market._();

  factory Market.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Market.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Market',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aE<MarketKind>(3, _omitFieldNames ? '' : 'kind',
        enumValues: MarketKind.values)
    ..aOS(4, _omitFieldNames ? '' : 'state')
    ..aOS(5, _omitFieldNames ? '' : 'district')
    ..aD(6, _omitFieldNames ? '' : 'latitude')
    ..aD(7, _omitFieldNames ? '' : 'longitude')
    ..aOS(8, _omitFieldNames ? '' : 'externalRef')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Market clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Market copyWith(void Function(Market) updates) =>
      super.copyWith((message) => updates(message as Market)) as Market;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Market create() => Market._();
  @$core.override
  Market createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Market getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Market>(create);
  static Market? _defaultInstance;

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
  MarketKind get kind => $_getN(2);
  @$pb.TagNumber(3)
  set kind(MarketKind value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get state => $_getSZ(3);
  @$pb.TagNumber(4)
  set state($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasState() => $_has(3);
  @$pb.TagNumber(4)
  void clearState() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get district => $_getSZ(4);
  @$pb.TagNumber(5)
  set district($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDistrict() => $_has(4);
  @$pb.TagNumber(5)
  void clearDistrict() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get latitude => $_getN(5);
  @$pb.TagNumber(6)
  set latitude($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLatitude() => $_has(5);
  @$pb.TagNumber(6)
  void clearLatitude() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get longitude => $_getN(6);
  @$pb.TagNumber(7)
  set longitude($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLongitude() => $_has(6);
  @$pb.TagNumber(7)
  void clearLongitude() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get externalRef => $_getSZ(7);
  @$pb.TagNumber(8)
  set externalRef($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasExternalRef() => $_has(7);
  @$pb.TagNumber(8)
  void clearExternalRef() => $_clearField(8);
}

/// PriceQuote is one commodity's price at one market on one day.
class PriceQuote extends $pb.GeneratedMessage {
  factory PriceQuote({
    $core.String? id,
    $core.String? commodity,
    $core.String? variety,
    $core.String? marketId,
    $core.String? marketName,
    $core.double? minPrice,
    $core.double? maxPrice,
    $core.double? modalPrice,
    PriceUnit? unit,
    $core.String? currency,
    $core.double? pricePerQuintal,
    $core.double? arrivalsTonnes,
    $0.Timestamp? quotedOn,
    $core.String? source,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (commodity != null) result.commodity = commodity;
    if (variety != null) result.variety = variety;
    if (marketId != null) result.marketId = marketId;
    if (marketName != null) result.marketName = marketName;
    if (minPrice != null) result.minPrice = minPrice;
    if (maxPrice != null) result.maxPrice = maxPrice;
    if (modalPrice != null) result.modalPrice = modalPrice;
    if (unit != null) result.unit = unit;
    if (currency != null) result.currency = currency;
    if (pricePerQuintal != null) result.pricePerQuintal = pricePerQuintal;
    if (arrivalsTonnes != null) result.arrivalsTonnes = arrivalsTonnes;
    if (quotedOn != null) result.quotedOn = quotedOn;
    if (source != null) result.source = source;
    return result;
  }

  PriceQuote._();

  factory PriceQuote.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PriceQuote.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PriceQuote',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'commodity')
    ..aOS(3, _omitFieldNames ? '' : 'variety')
    ..aOS(4, _omitFieldNames ? '' : 'marketId')
    ..aOS(5, _omitFieldNames ? '' : 'marketName')
    ..aD(6, _omitFieldNames ? '' : 'minPrice')
    ..aD(7, _omitFieldNames ? '' : 'maxPrice')
    ..aD(8, _omitFieldNames ? '' : 'modalPrice')
    ..aE<PriceUnit>(9, _omitFieldNames ? '' : 'unit',
        enumValues: PriceUnit.values)
    ..aOS(10, _omitFieldNames ? '' : 'currency')
    ..aD(11, _omitFieldNames ? '' : 'pricePerQuintal')
    ..aD(12, _omitFieldNames ? '' : 'arrivalsTonnes')
    ..aOM<$0.Timestamp>(13, _omitFieldNames ? '' : 'quotedOn',
        subBuilder: $0.Timestamp.create)
    ..aOS(14, _omitFieldNames ? '' : 'source')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceQuote clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceQuote copyWith(void Function(PriceQuote) updates) =>
      super.copyWith((message) => updates(message as PriceQuote)) as PriceQuote;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PriceQuote create() => PriceQuote._();
  @$core.override
  PriceQuote createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PriceQuote getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PriceQuote>(create);
  static PriceQuote? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commodity => $_getSZ(1);
  @$pb.TagNumber(2)
  set commodity($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommodity() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommodity() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get variety => $_getSZ(2);
  @$pb.TagNumber(3)
  set variety($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVariety() => $_has(2);
  @$pb.TagNumber(3)
  void clearVariety() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get marketId => $_getSZ(3);
  @$pb.TagNumber(4)
  set marketId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMarketId() => $_has(3);
  @$pb.TagNumber(4)
  void clearMarketId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get marketName => $_getSZ(4);
  @$pb.TagNumber(5)
  set marketName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMarketName() => $_has(4);
  @$pb.TagNumber(5)
  void clearMarketName() => $_clearField(5);

  /// Quoted as reported, in its own unit.
  @$pb.TagNumber(6)
  $core.double get minPrice => $_getN(5);
  @$pb.TagNumber(6)
  set minPrice($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMinPrice() => $_has(5);
  @$pb.TagNumber(6)
  void clearMinPrice() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get maxPrice => $_getN(6);
  @$pb.TagNumber(7)
  set maxPrice($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMaxPrice() => $_has(6);
  @$pb.TagNumber(7)
  void clearMaxPrice() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get modalPrice => $_getN(7);
  @$pb.TagNumber(8)
  set modalPrice($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasModalPrice() => $_has(7);
  @$pb.TagNumber(8)
  void clearModalPrice() => $_clearField(8);

  @$pb.TagNumber(9)
  PriceUnit get unit => $_getN(8);
  @$pb.TagNumber(9)
  set unit(PriceUnit value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasUnit() => $_has(8);
  @$pb.TagNumber(9)
  void clearUnit() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get currency => $_getSZ(9);
  @$pb.TagNumber(10)
  set currency($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCurrency() => $_has(9);
  @$pb.TagNumber(10)
  void clearCurrency() => $_clearField(10);

  /// Normalised to rupees per quintal, so quotes from different sources are
  /// comparable without every caller repeating the conversion.
  @$pb.TagNumber(11)
  $core.double get pricePerQuintal => $_getN(10);
  @$pb.TagNumber(11)
  set pricePerQuintal($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPricePerQuintal() => $_has(10);
  @$pb.TagNumber(11)
  void clearPricePerQuintal() => $_clearField(11);

  /// Arrivals in tonnes, where the source reports them. Volume is what makes a
  /// modal price meaningful: one lot changing hands is not a market price.
  @$pb.TagNumber(12)
  $core.double get arrivalsTonnes => $_getN(11);
  @$pb.TagNumber(12)
  set arrivalsTonnes($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasArrivalsTonnes() => $_has(11);
  @$pb.TagNumber(12)
  void clearArrivalsTonnes() => $_clearField(12);

  @$pb.TagNumber(13)
  $0.Timestamp get quotedOn => $_getN(12);
  @$pb.TagNumber(13)
  set quotedOn($0.Timestamp value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasQuotedOn() => $_has(12);
  @$pb.TagNumber(13)
  void clearQuotedOn() => $_clearField(13);
  @$pb.TagNumber(13)
  $0.Timestamp ensureQuotedOn() => $_ensure(12);

  @$pb.TagNumber(14)
  $core.String get source => $_getSZ(13);
  @$pb.TagNumber(14)
  set source($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasSource() => $_has(13);
  @$pb.TagNumber(14)
  void clearSource() => $_clearField(14);
}

/// PriceStatistics summarises a commodity's recent prices at a market.
class PriceStatistics extends $pb.GeneratedMessage {
  factory PriceStatistics({
    $core.String? commodity,
    $core.String? marketId,
    $core.double? meanPerQuintal,
    $core.double? medianPerQuintal,
    $core.double? minPerQuintal,
    $core.double? maxPerQuintal,
    $core.double? latestPerQuintal,
    $core.double? latestZScore,
    PriceTrend? trend,
    $core.double? trendPerDay,
    $core.int? observationDays,
  }) {
    final result = create();
    if (commodity != null) result.commodity = commodity;
    if (marketId != null) result.marketId = marketId;
    if (meanPerQuintal != null) result.meanPerQuintal = meanPerQuintal;
    if (medianPerQuintal != null) result.medianPerQuintal = medianPerQuintal;
    if (minPerQuintal != null) result.minPerQuintal = minPerQuintal;
    if (maxPerQuintal != null) result.maxPerQuintal = maxPerQuintal;
    if (latestPerQuintal != null) result.latestPerQuintal = latestPerQuintal;
    if (latestZScore != null) result.latestZScore = latestZScore;
    if (trend != null) result.trend = trend;
    if (trendPerDay != null) result.trendPerDay = trendPerDay;
    if (observationDays != null) result.observationDays = observationDays;
    return result;
  }

  PriceStatistics._();

  factory PriceStatistics.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PriceStatistics.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PriceStatistics',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'commodity')
    ..aOS(2, _omitFieldNames ? '' : 'marketId')
    ..aD(3, _omitFieldNames ? '' : 'meanPerQuintal')
    ..aD(4, _omitFieldNames ? '' : 'medianPerQuintal')
    ..aD(5, _omitFieldNames ? '' : 'minPerQuintal')
    ..aD(6, _omitFieldNames ? '' : 'maxPerQuintal')
    ..aD(7, _omitFieldNames ? '' : 'latestPerQuintal')
    ..aD(8, _omitFieldNames ? '' : 'latestZScore')
    ..aE<PriceTrend>(9, _omitFieldNames ? '' : 'trend',
        enumValues: PriceTrend.values)
    ..aD(10, _omitFieldNames ? '' : 'trendPerDay')
    ..aI(11, _omitFieldNames ? '' : 'observationDays')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceStatistics clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceStatistics copyWith(void Function(PriceStatistics) updates) =>
      super.copyWith((message) => updates(message as PriceStatistics))
          as PriceStatistics;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PriceStatistics create() => PriceStatistics._();
  @$core.override
  PriceStatistics createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PriceStatistics getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PriceStatistics>(create);
  static PriceStatistics? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get commodity => $_getSZ(0);
  @$pb.TagNumber(1)
  set commodity($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommodity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommodity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get marketId => $_getSZ(1);
  @$pb.TagNumber(2)
  set marketId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMarketId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMarketId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get meanPerQuintal => $_getN(2);
  @$pb.TagNumber(3)
  set meanPerQuintal($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMeanPerQuintal() => $_has(2);
  @$pb.TagNumber(3)
  void clearMeanPerQuintal() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get medianPerQuintal => $_getN(3);
  @$pb.TagNumber(4)
  set medianPerQuintal($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMedianPerQuintal() => $_has(3);
  @$pb.TagNumber(4)
  void clearMedianPerQuintal() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get minPerQuintal => $_getN(4);
  @$pb.TagNumber(5)
  set minPerQuintal($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMinPerQuintal() => $_has(4);
  @$pb.TagNumber(5)
  void clearMinPerQuintal() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get maxPerQuintal => $_getN(5);
  @$pb.TagNumber(6)
  set maxPerQuintal($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxPerQuintal() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxPerQuintal() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get latestPerQuintal => $_getN(6);
  @$pb.TagNumber(7)
  set latestPerQuintal($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLatestPerQuintal() => $_has(6);
  @$pb.TagNumber(7)
  void clearLatestPerQuintal() => $_clearField(7);

  /// How far the latest price sits from the mean, in standard deviations.
  /// Reported rather than a bare percentage because it is what decides whether
  /// a move is unusual or ordinary noise for this commodity.
  @$pb.TagNumber(8)
  $core.double get latestZScore => $_getN(7);
  @$pb.TagNumber(8)
  set latestZScore($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasLatestZScore() => $_has(7);
  @$pb.TagNumber(8)
  void clearLatestZScore() => $_clearField(8);

  @$pb.TagNumber(9)
  PriceTrend get trend => $_getN(8);
  @$pb.TagNumber(9)
  set trend(PriceTrend value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasTrend() => $_has(8);
  @$pb.TagNumber(9)
  void clearTrend() => $_clearField(9);

  /// Least-squares slope in rupees per quintal per day.
  @$pb.TagNumber(10)
  $core.double get trendPerDay => $_getN(9);
  @$pb.TagNumber(10)
  set trendPerDay($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTrendPerDay() => $_has(9);
  @$pb.TagNumber(10)
  void clearTrendPerDay() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get observationDays => $_getIZ(10);
  @$pb.TagNumber(11)
  set observationDays($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasObservationDays() => $_has(10);
  @$pb.TagNumber(11)
  void clearObservationDays() => $_clearField(11);
}

/// SellSignal is the timing advice for one commodity at one market.
class SellSignal extends $pb.GeneratedMessage {
  factory SellSignal({
    $core.String? commodity,
    $core.String? marketId,
    SellRecommendation? recommendation,
    $core.double? confidence,
    $core.String? rationale,
    PriceStatistics? statistics,
    $0.Timestamp? generatedAt,
  }) {
    final result = create();
    if (commodity != null) result.commodity = commodity;
    if (marketId != null) result.marketId = marketId;
    if (recommendation != null) result.recommendation = recommendation;
    if (confidence != null) result.confidence = confidence;
    if (rationale != null) result.rationale = rationale;
    if (statistics != null) result.statistics = statistics;
    if (generatedAt != null) result.generatedAt = generatedAt;
    return result;
  }

  SellSignal._();

  factory SellSignal.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SellSignal.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SellSignal',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'commodity')
    ..aOS(2, _omitFieldNames ? '' : 'marketId')
    ..aE<SellRecommendation>(3, _omitFieldNames ? '' : 'recommendation',
        enumValues: SellRecommendation.values)
    ..aD(4, _omitFieldNames ? '' : 'confidence')
    ..aOS(5, _omitFieldNames ? '' : 'rationale')
    ..aOM<PriceStatistics>(6, _omitFieldNames ? '' : 'statistics',
        subBuilder: PriceStatistics.create)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'generatedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SellSignal clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SellSignal copyWith(void Function(SellSignal) updates) =>
      super.copyWith((message) => updates(message as SellSignal)) as SellSignal;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SellSignal create() => SellSignal._();
  @$core.override
  SellSignal createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SellSignal getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SellSignal>(create);
  static SellSignal? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get commodity => $_getSZ(0);
  @$pb.TagNumber(1)
  set commodity($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommodity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommodity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get marketId => $_getSZ(1);
  @$pb.TagNumber(2)
  set marketId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMarketId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMarketId() => $_clearField(2);

  @$pb.TagNumber(3)
  SellRecommendation get recommendation => $_getN(2);
  @$pb.TagNumber(3)
  set recommendation(SellRecommendation value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasRecommendation() => $_has(2);
  @$pb.TagNumber(3)
  void clearRecommendation() => $_clearField(3);

  /// 0–1. Low when the history is short or the price is not far from its mean:
  /// a recommendation given with false certainty is worse than none.
  @$pb.TagNumber(4)
  $core.double get confidence => $_getN(3);
  @$pb.TagNumber(4)
  set confidence($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfidence() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfidence() => $_clearField(4);

  /// Written for the person reading it, naming the numbers behind the advice.
  @$pb.TagNumber(5)
  $core.String get rationale => $_getSZ(4);
  @$pb.TagNumber(5)
  set rationale($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRationale() => $_has(4);
  @$pb.TagNumber(5)
  void clearRationale() => $_clearField(5);

  @$pb.TagNumber(6)
  PriceStatistics get statistics => $_getN(5);
  @$pb.TagNumber(6)
  set statistics(PriceStatistics value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStatistics() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatistics() => $_clearField(6);
  @$pb.TagNumber(6)
  PriceStatistics ensureStatistics() => $_ensure(5);

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
}

/// PriceAlert fires when a commodity crosses a threshold at a market.
class PriceAlert extends $pb.GeneratedMessage {
  factory PriceAlert({
    $core.String? id,
    $core.String? commodity,
    $core.String? marketId,
    AlertDirection? direction,
    $core.double? thresholdPerQuintal,
    $core.bool? enabled,
    $0.Timestamp? createdAt,
    $0.Timestamp? lastFiredAt,
    $core.double? lastFiredPrice,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (commodity != null) result.commodity = commodity;
    if (marketId != null) result.marketId = marketId;
    if (direction != null) result.direction = direction;
    if (thresholdPerQuintal != null)
      result.thresholdPerQuintal = thresholdPerQuintal;
    if (enabled != null) result.enabled = enabled;
    if (createdAt != null) result.createdAt = createdAt;
    if (lastFiredAt != null) result.lastFiredAt = lastFiredAt;
    if (lastFiredPrice != null) result.lastFiredPrice = lastFiredPrice;
    return result;
  }

  PriceAlert._();

  factory PriceAlert.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PriceAlert.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PriceAlert',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'commodity')
    ..aOS(3, _omitFieldNames ? '' : 'marketId')
    ..aE<AlertDirection>(4, _omitFieldNames ? '' : 'direction',
        enumValues: AlertDirection.values)
    ..aD(5, _omitFieldNames ? '' : 'thresholdPerQuintal')
    ..aOB(6, _omitFieldNames ? '' : 'enabled')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'lastFiredAt',
        subBuilder: $0.Timestamp.create)
    ..aD(9, _omitFieldNames ? '' : 'lastFiredPrice')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceAlert clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PriceAlert copyWith(void Function(PriceAlert) updates) =>
      super.copyWith((message) => updates(message as PriceAlert)) as PriceAlert;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PriceAlert create() => PriceAlert._();
  @$core.override
  PriceAlert createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PriceAlert getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PriceAlert>(create);
  static PriceAlert? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commodity => $_getSZ(1);
  @$pb.TagNumber(2)
  set commodity($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommodity() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommodity() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get marketId => $_getSZ(2);
  @$pb.TagNumber(3)
  set marketId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMarketId() => $_has(2);
  @$pb.TagNumber(3)
  void clearMarketId() => $_clearField(3);

  @$pb.TagNumber(4)
  AlertDirection get direction => $_getN(3);
  @$pb.TagNumber(4)
  set direction(AlertDirection value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDirection() => $_has(3);
  @$pb.TagNumber(4)
  void clearDirection() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get thresholdPerQuintal => $_getN(4);
  @$pb.TagNumber(5)
  set thresholdPerQuintal($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasThresholdPerQuintal() => $_has(4);
  @$pb.TagNumber(5)
  void clearThresholdPerQuintal() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get enabled => $_getBF(5);
  @$pb.TagNumber(6)
  set enabled($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEnabled() => $_has(5);
  @$pb.TagNumber(6)
  void clearEnabled() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get createdAt => $_getN(6);
  @$pb.TagNumber(7)
  set createdAt($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureCreatedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get lastFiredAt => $_getN(7);
  @$pb.TagNumber(8)
  set lastFiredAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasLastFiredAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastFiredAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureLastFiredAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.double get lastFiredPrice => $_getN(8);
  @$pb.TagNumber(9)
  set lastFiredPrice($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasLastFiredPrice() => $_has(8);
  @$pb.TagNumber(9)
  void clearLastFiredPrice() => $_clearField(9);
}

class ListMarketsRequest extends $pb.GeneratedMessage {
  factory ListMarketsRequest({
    $core.String? state,
    $core.String? district,
    MarketKind? kind,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (state != null) result.state = state;
    if (district != null) result.district = district;
    if (kind != null) result.kind = kind;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListMarketsRequest._();

  factory ListMarketsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListMarketsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMarketsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'state')
    ..aOS(2, _omitFieldNames ? '' : 'district')
    ..aE<MarketKind>(3, _omitFieldNames ? '' : 'kind',
        enumValues: MarketKind.values)
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aOS(5, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMarketsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMarketsRequest copyWith(void Function(ListMarketsRequest) updates) =>
      super.copyWith((message) => updates(message as ListMarketsRequest))
          as ListMarketsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMarketsRequest create() => ListMarketsRequest._();
  @$core.override
  ListMarketsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListMarketsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMarketsRequest>(create);
  static ListMarketsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get state => $_getSZ(0);
  @$pb.TagNumber(1)
  set state($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasState() => $_has(0);
  @$pb.TagNumber(1)
  void clearState() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get district => $_getSZ(1);
  @$pb.TagNumber(2)
  set district($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDistrict() => $_has(1);
  @$pb.TagNumber(2)
  void clearDistrict() => $_clearField(2);

  @$pb.TagNumber(3)
  MarketKind get kind => $_getN(2);
  @$pb.TagNumber(3)
  set kind(MarketKind value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);

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

class ListMarketsResponse extends $pb.GeneratedMessage {
  factory ListMarketsResponse({
    $core.Iterable<Market>? markets,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (markets != null) result.markets.addAll(markets);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListMarketsResponse._();

  factory ListMarketsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListMarketsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListMarketsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..pPM<Market>(1, _omitFieldNames ? '' : 'markets',
        subBuilder: Market.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMarketsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMarketsResponse copyWith(void Function(ListMarketsResponse) updates) =>
      super.copyWith((message) => updates(message as ListMarketsResponse))
          as ListMarketsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListMarketsResponse create() => ListMarketsResponse._();
  @$core.override
  ListMarketsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListMarketsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMarketsResponse>(create);
  static ListMarketsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Market> get markets => $_getList(0);

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

class RecordQuotesRequest extends $pb.GeneratedMessage {
  factory RecordQuotesRequest({
    $core.Iterable<PriceQuote>? quotes,
  }) {
    final result = create();
    if (quotes != null) result.quotes.addAll(quotes);
    return result;
  }

  RecordQuotesRequest._();

  factory RecordQuotesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecordQuotesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecordQuotesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..pPM<PriceQuote>(1, _omitFieldNames ? '' : 'quotes',
        subBuilder: PriceQuote.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordQuotesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordQuotesRequest copyWith(void Function(RecordQuotesRequest) updates) =>
      super.copyWith((message) => updates(message as RecordQuotesRequest))
          as RecordQuotesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecordQuotesRequest create() => RecordQuotesRequest._();
  @$core.override
  RecordQuotesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecordQuotesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecordQuotesRequest>(create);
  static RecordQuotesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PriceQuote> get quotes => $_getList(0);
}

class RecordQuotesResponse extends $pb.GeneratedMessage {
  factory RecordQuotesResponse({
    $core.int? recorded,
    $core.Iterable<$core.String>? rejected,
  }) {
    final result = create();
    if (recorded != null) result.recorded = recorded;
    if (rejected != null) result.rejected.addAll(rejected);
    return result;
  }

  RecordQuotesResponse._();

  factory RecordQuotesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecordQuotesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecordQuotesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'recorded')
    ..pPS(2, _omitFieldNames ? '' : 'rejected')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordQuotesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecordQuotesResponse copyWith(void Function(RecordQuotesResponse) updates) =>
      super.copyWith((message) => updates(message as RecordQuotesResponse))
          as RecordQuotesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecordQuotesResponse create() => RecordQuotesResponse._();
  @$core.override
  RecordQuotesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecordQuotesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecordQuotesResponse>(create);
  static RecordQuotesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get recorded => $_getIZ(0);
  @$pb.TagNumber(1)
  set recorded($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecorded() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecorded() => $_clearField(1);

  /// Quotes the service refused, with the reason. Returned rather than counted,
  /// so an ingester that is silently dropping half its feed can tell.
  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get rejected => $_getList(1);
}

class ListQuotesRequest extends $pb.GeneratedMessage {
  factory ListQuotesRequest({
    $core.String? commodity,
    $core.String? marketId,
    $0.Timestamp? from,
    $0.Timestamp? to,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (commodity != null) result.commodity = commodity;
    if (marketId != null) result.marketId = marketId;
    if (from != null) result.from = from;
    if (to != null) result.to = to;
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
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'commodity')
    ..aOS(2, _omitFieldNames ? '' : 'marketId')
    ..aOM<$0.Timestamp>(3, _omitFieldNames ? '' : 'from',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'to',
        subBuilder: $0.Timestamp.create)
    ..aI(5, _omitFieldNames ? '' : 'pageSize')
    ..aOS(6, _omitFieldNames ? '' : 'pageToken')
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
  $core.String get commodity => $_getSZ(0);
  @$pb.TagNumber(1)
  set commodity($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommodity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommodity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get marketId => $_getSZ(1);
  @$pb.TagNumber(2)
  set marketId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMarketId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMarketId() => $_clearField(2);

  @$pb.TagNumber(3)
  $0.Timestamp get from => $_getN(2);
  @$pb.TagNumber(3)
  set from($0.Timestamp value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasFrom() => $_has(2);
  @$pb.TagNumber(3)
  void clearFrom() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.Timestamp ensureFrom() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.Timestamp get to => $_getN(3);
  @$pb.TagNumber(4)
  set to($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTo() => $_has(3);
  @$pb.TagNumber(4)
  void clearTo() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureTo() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get pageSize => $_getIZ(4);
  @$pb.TagNumber(5)
  set pageSize($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageSize() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get pageToken => $_getSZ(5);
  @$pb.TagNumber(6)
  set pageToken($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPageToken() => $_has(5);
  @$pb.TagNumber(6)
  void clearPageToken() => $_clearField(6);
}

class ListQuotesResponse extends $pb.GeneratedMessage {
  factory ListQuotesResponse({
    $core.Iterable<PriceQuote>? quotes,
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
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..pPM<PriceQuote>(1, _omitFieldNames ? '' : 'quotes',
        subBuilder: PriceQuote.create)
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
  $pb.PbList<PriceQuote> get quotes => $_getList(0);

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

class GetPriceStatisticsRequest extends $pb.GeneratedMessage {
  factory GetPriceStatisticsRequest({
    $core.String? commodity,
    $core.String? marketId,
    $core.int? days,
  }) {
    final result = create();
    if (commodity != null) result.commodity = commodity;
    if (marketId != null) result.marketId = marketId;
    if (days != null) result.days = days;
    return result;
  }

  GetPriceStatisticsRequest._();

  factory GetPriceStatisticsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPriceStatisticsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPriceStatisticsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'commodity')
    ..aOS(2, _omitFieldNames ? '' : 'marketId')
    ..aI(3, _omitFieldNames ? '' : 'days')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPriceStatisticsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPriceStatisticsRequest copyWith(
          void Function(GetPriceStatisticsRequest) updates) =>
      super.copyWith((message) => updates(message as GetPriceStatisticsRequest))
          as GetPriceStatisticsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPriceStatisticsRequest create() => GetPriceStatisticsRequest._();
  @$core.override
  GetPriceStatisticsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPriceStatisticsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPriceStatisticsRequest>(create);
  static GetPriceStatisticsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get commodity => $_getSZ(0);
  @$pb.TagNumber(1)
  set commodity($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommodity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommodity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get marketId => $_getSZ(1);
  @$pb.TagNumber(2)
  set marketId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMarketId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMarketId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get days => $_getIZ(2);
  @$pb.TagNumber(3)
  set days($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDays() => $_has(2);
  @$pb.TagNumber(3)
  void clearDays() => $_clearField(3);
}

class GetPriceStatisticsResponse extends $pb.GeneratedMessage {
  factory GetPriceStatisticsResponse({
    PriceStatistics? statistics,
  }) {
    final result = create();
    if (statistics != null) result.statistics = statistics;
    return result;
  }

  GetPriceStatisticsResponse._();

  factory GetPriceStatisticsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetPriceStatisticsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetPriceStatisticsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOM<PriceStatistics>(1, _omitFieldNames ? '' : 'statistics',
        subBuilder: PriceStatistics.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPriceStatisticsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetPriceStatisticsResponse copyWith(
          void Function(GetPriceStatisticsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetPriceStatisticsResponse))
          as GetPriceStatisticsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetPriceStatisticsResponse create() => GetPriceStatisticsResponse._();
  @$core.override
  GetPriceStatisticsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetPriceStatisticsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetPriceStatisticsResponse>(create);
  static GetPriceStatisticsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PriceStatistics get statistics => $_getN(0);
  @$pb.TagNumber(1)
  set statistics(PriceStatistics value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatistics() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatistics() => $_clearField(1);
  @$pb.TagNumber(1)
  PriceStatistics ensureStatistics() => $_ensure(0);
}

class GetSellSignalRequest extends $pb.GeneratedMessage {
  factory GetSellSignalRequest({
    $core.String? commodity,
    $core.String? marketId,
    $core.int? days,
  }) {
    final result = create();
    if (commodity != null) result.commodity = commodity;
    if (marketId != null) result.marketId = marketId;
    if (days != null) result.days = days;
    return result;
  }

  GetSellSignalRequest._();

  factory GetSellSignalRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSellSignalRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSellSignalRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'commodity')
    ..aOS(2, _omitFieldNames ? '' : 'marketId')
    ..aI(3, _omitFieldNames ? '' : 'days')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSellSignalRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSellSignalRequest copyWith(void Function(GetSellSignalRequest) updates) =>
      super.copyWith((message) => updates(message as GetSellSignalRequest))
          as GetSellSignalRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSellSignalRequest create() => GetSellSignalRequest._();
  @$core.override
  GetSellSignalRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSellSignalRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSellSignalRequest>(create);
  static GetSellSignalRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get commodity => $_getSZ(0);
  @$pb.TagNumber(1)
  set commodity($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommodity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommodity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get marketId => $_getSZ(1);
  @$pb.TagNumber(2)
  set marketId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMarketId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMarketId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get days => $_getIZ(2);
  @$pb.TagNumber(3)
  set days($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDays() => $_has(2);
  @$pb.TagNumber(3)
  void clearDays() => $_clearField(3);
}

class GetSellSignalResponse extends $pb.GeneratedMessage {
  factory GetSellSignalResponse({
    SellSignal? signal,
  }) {
    final result = create();
    if (signal != null) result.signal = signal;
    return result;
  }

  GetSellSignalResponse._();

  factory GetSellSignalResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetSellSignalResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSellSignalResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOM<SellSignal>(1, _omitFieldNames ? '' : 'signal',
        subBuilder: SellSignal.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSellSignalResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSellSignalResponse copyWith(
          void Function(GetSellSignalResponse) updates) =>
      super.copyWith((message) => updates(message as GetSellSignalResponse))
          as GetSellSignalResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSellSignalResponse create() => GetSellSignalResponse._();
  @$core.override
  GetSellSignalResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetSellSignalResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSellSignalResponse>(create);
  static GetSellSignalResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SellSignal get signal => $_getN(0);
  @$pb.TagNumber(1)
  set signal(SellSignal value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSignal() => $_has(0);
  @$pb.TagNumber(1)
  void clearSignal() => $_clearField(1);
  @$pb.TagNumber(1)
  SellSignal ensureSignal() => $_ensure(0);
}

class CreatePriceAlertRequest extends $pb.GeneratedMessage {
  factory CreatePriceAlertRequest({
    $core.String? commodity,
    $core.String? marketId,
    AlertDirection? direction,
    $core.double? thresholdPerQuintal,
  }) {
    final result = create();
    if (commodity != null) result.commodity = commodity;
    if (marketId != null) result.marketId = marketId;
    if (direction != null) result.direction = direction;
    if (thresholdPerQuintal != null)
      result.thresholdPerQuintal = thresholdPerQuintal;
    return result;
  }

  CreatePriceAlertRequest._();

  factory CreatePriceAlertRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreatePriceAlertRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreatePriceAlertRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'commodity')
    ..aOS(2, _omitFieldNames ? '' : 'marketId')
    ..aE<AlertDirection>(3, _omitFieldNames ? '' : 'direction',
        enumValues: AlertDirection.values)
    ..aD(4, _omitFieldNames ? '' : 'thresholdPerQuintal')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePriceAlertRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePriceAlertRequest copyWith(
          void Function(CreatePriceAlertRequest) updates) =>
      super.copyWith((message) => updates(message as CreatePriceAlertRequest))
          as CreatePriceAlertRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePriceAlertRequest create() => CreatePriceAlertRequest._();
  @$core.override
  CreatePriceAlertRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreatePriceAlertRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreatePriceAlertRequest>(create);
  static CreatePriceAlertRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get commodity => $_getSZ(0);
  @$pb.TagNumber(1)
  set commodity($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommodity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommodity() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get marketId => $_getSZ(1);
  @$pb.TagNumber(2)
  set marketId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMarketId() => $_has(1);
  @$pb.TagNumber(2)
  void clearMarketId() => $_clearField(2);

  @$pb.TagNumber(3)
  AlertDirection get direction => $_getN(2);
  @$pb.TagNumber(3)
  set direction(AlertDirection value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDirection() => $_has(2);
  @$pb.TagNumber(3)
  void clearDirection() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get thresholdPerQuintal => $_getN(3);
  @$pb.TagNumber(4)
  set thresholdPerQuintal($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasThresholdPerQuintal() => $_has(3);
  @$pb.TagNumber(4)
  void clearThresholdPerQuintal() => $_clearField(4);
}

class CreatePriceAlertResponse extends $pb.GeneratedMessage {
  factory CreatePriceAlertResponse({
    PriceAlert? alert,
  }) {
    final result = create();
    if (alert != null) result.alert = alert;
    return result;
  }

  CreatePriceAlertResponse._();

  factory CreatePriceAlertResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CreatePriceAlertResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CreatePriceAlertResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOM<PriceAlert>(1, _omitFieldNames ? '' : 'alert',
        subBuilder: PriceAlert.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePriceAlertResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePriceAlertResponse copyWith(
          void Function(CreatePriceAlertResponse) updates) =>
      super.copyWith((message) => updates(message as CreatePriceAlertResponse))
          as CreatePriceAlertResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePriceAlertResponse create() => CreatePriceAlertResponse._();
  @$core.override
  CreatePriceAlertResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CreatePriceAlertResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreatePriceAlertResponse>(create);
  static CreatePriceAlertResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PriceAlert get alert => $_getN(0);
  @$pb.TagNumber(1)
  set alert(PriceAlert value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAlert() => $_has(0);
  @$pb.TagNumber(1)
  void clearAlert() => $_clearField(1);
  @$pb.TagNumber(1)
  PriceAlert ensureAlert() => $_ensure(0);
}

class ListPriceAlertsRequest extends $pb.GeneratedMessage {
  factory ListPriceAlertsRequest({
    $core.String? commodity,
    $core.int? pageSize,
    $core.String? pageToken,
  }) {
    final result = create();
    if (commodity != null) result.commodity = commodity;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    return result;
  }

  ListPriceAlertsRequest._();

  factory ListPriceAlertsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPriceAlertsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPriceAlertsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'commodity')
    ..aI(2, _omitFieldNames ? '' : 'pageSize')
    ..aOS(3, _omitFieldNames ? '' : 'pageToken')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPriceAlertsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPriceAlertsRequest copyWith(
          void Function(ListPriceAlertsRequest) updates) =>
      super.copyWith((message) => updates(message as ListPriceAlertsRequest))
          as ListPriceAlertsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPriceAlertsRequest create() => ListPriceAlertsRequest._();
  @$core.override
  ListPriceAlertsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPriceAlertsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPriceAlertsRequest>(create);
  static ListPriceAlertsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get commodity => $_getSZ(0);
  @$pb.TagNumber(1)
  set commodity($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommodity() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommodity() => $_clearField(1);

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

class ListPriceAlertsResponse extends $pb.GeneratedMessage {
  factory ListPriceAlertsResponse({
    $core.Iterable<PriceAlert>? alerts,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (alerts != null) result.alerts.addAll(alerts);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListPriceAlertsResponse._();

  factory ListPriceAlertsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListPriceAlertsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListPriceAlertsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..pPM<PriceAlert>(1, _omitFieldNames ? '' : 'alerts',
        subBuilder: PriceAlert.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPriceAlertsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListPriceAlertsResponse copyWith(
          void Function(ListPriceAlertsResponse) updates) =>
      super.copyWith((message) => updates(message as ListPriceAlertsResponse))
          as ListPriceAlertsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPriceAlertsResponse create() => ListPriceAlertsResponse._();
  @$core.override
  ListPriceAlertsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListPriceAlertsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListPriceAlertsResponse>(create);
  static ListPriceAlertsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PriceAlert> get alerts => $_getList(0);

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

class DeletePriceAlertRequest extends $pb.GeneratedMessage {
  factory DeletePriceAlertRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeletePriceAlertRequest._();

  factory DeletePriceAlertRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeletePriceAlertRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeletePriceAlertRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletePriceAlertRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletePriceAlertRequest copyWith(
          void Function(DeletePriceAlertRequest) updates) =>
      super.copyWith((message) => updates(message as DeletePriceAlertRequest))
          as DeletePriceAlertRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeletePriceAlertRequest create() => DeletePriceAlertRequest._();
  @$core.override
  DeletePriceAlertRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeletePriceAlertRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeletePriceAlertRequest>(create);
  static DeletePriceAlertRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeletePriceAlertResponse extends $pb.GeneratedMessage {
  factory DeletePriceAlertResponse({
    $core.bool? deleted,
  }) {
    final result = create();
    if (deleted != null) result.deleted = deleted;
    return result;
  }

  DeletePriceAlertResponse._();

  factory DeletePriceAlertResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeletePriceAlertResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeletePriceAlertResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.market.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'deleted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletePriceAlertResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeletePriceAlertResponse copyWith(
          void Function(DeletePriceAlertResponse) updates) =>
      super.copyWith((message) => updates(message as DeletePriceAlertResponse))
          as DeletePriceAlertResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeletePriceAlertResponse create() => DeletePriceAlertResponse._();
  @$core.override
  DeletePriceAlertResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeletePriceAlertResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeletePriceAlertResponse>(create);
  static DeletePriceAlertResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get deleted => $_getBF(0);
  @$pb.TagNumber(1)
  set deleted($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeleted() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeleted() => $_clearField(1);
}

/// MarketService provides commodity price data, statistics and sell timing.
class MarketServiceApi {
  final $pb.RpcClient _client;

  MarketServiceApi(this._client);

  $async.Future<ListMarketsResponse> listMarkets(
          $pb.ClientContext? ctx, ListMarketsRequest request) =>
      _client.invoke<ListMarketsResponse>(
          ctx, 'MarketService', 'ListMarkets', request, ListMarketsResponse());
  $async.Future<RecordQuotesResponse> recordQuotes(
          $pb.ClientContext? ctx, RecordQuotesRequest request) =>
      _client.invoke<RecordQuotesResponse>(ctx, 'MarketService', 'RecordQuotes',
          request, RecordQuotesResponse());
  $async.Future<ListQuotesResponse> listQuotes(
          $pb.ClientContext? ctx, ListQuotesRequest request) =>
      _client.invoke<ListQuotesResponse>(
          ctx, 'MarketService', 'ListQuotes', request, ListQuotesResponse());
  $async.Future<GetPriceStatisticsResponse> getPriceStatistics(
          $pb.ClientContext? ctx, GetPriceStatisticsRequest request) =>
      _client.invoke<GetPriceStatisticsResponse>(ctx, 'MarketService',
          'GetPriceStatistics', request, GetPriceStatisticsResponse());
  $async.Future<GetSellSignalResponse> getSellSignal(
          $pb.ClientContext? ctx, GetSellSignalRequest request) =>
      _client.invoke<GetSellSignalResponse>(ctx, 'MarketService',
          'GetSellSignal', request, GetSellSignalResponse());
  $async.Future<CreatePriceAlertResponse> createPriceAlert(
          $pb.ClientContext? ctx, CreatePriceAlertRequest request) =>
      _client.invoke<CreatePriceAlertResponse>(ctx, 'MarketService',
          'CreatePriceAlert', request, CreatePriceAlertResponse());
  $async.Future<ListPriceAlertsResponse> listPriceAlerts(
          $pb.ClientContext? ctx, ListPriceAlertsRequest request) =>
      _client.invoke<ListPriceAlertsResponse>(ctx, 'MarketService',
          'ListPriceAlerts', request, ListPriceAlertsResponse());
  $async.Future<DeletePriceAlertResponse> deletePriceAlert(
          $pb.ClientContext? ctx, DeletePriceAlertRequest request) =>
      _client.invoke<DeletePriceAlertResponse>(ctx, 'MarketService',
          'DeletePriceAlert', request, DeletePriceAlertResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
