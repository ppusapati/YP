// This is a generated file - do not edit.
//
// Generated from market.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// PriceUnit is the quantity a price is quoted against.
///
/// India's mandi prices are per quintal (100 kg), exchanges quote per tonne, and
/// farm-gate deals are often per kilogram. Storing the unit alongside the number
/// is what stops a ₹5,000/quintal price being compared against a ₹50/kg one and
/// looking like a hundredfold difference.
class PriceUnit extends $pb.ProtobufEnum {
  static const PriceUnit PRICE_UNIT_UNSPECIFIED =
      PriceUnit._(0, _omitEnumNames ? '' : 'PRICE_UNIT_UNSPECIFIED');
  static const PriceUnit PRICE_UNIT_PER_KG =
      PriceUnit._(1, _omitEnumNames ? '' : 'PRICE_UNIT_PER_KG');
  static const PriceUnit PRICE_UNIT_PER_QUINTAL =
      PriceUnit._(2, _omitEnumNames ? '' : 'PRICE_UNIT_PER_QUINTAL');
  static const PriceUnit PRICE_UNIT_PER_TONNE =
      PriceUnit._(3, _omitEnumNames ? '' : 'PRICE_UNIT_PER_TONNE');

  static const $core.List<PriceUnit> values = <PriceUnit>[
    PRICE_UNIT_UNSPECIFIED,
    PRICE_UNIT_PER_KG,
    PRICE_UNIT_PER_QUINTAL,
    PRICE_UNIT_PER_TONNE,
  ];

  static final $core.List<PriceUnit?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static PriceUnit? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PriceUnit._(super.value, super.name);
}

/// MarketKind is where a price came from.
class MarketKind extends $pb.ProtobufEnum {
  static const MarketKind MARKET_KIND_UNSPECIFIED =
      MarketKind._(0, _omitEnumNames ? '' : 'MARKET_KIND_UNSPECIFIED');

  /// A regulated APMC/mandi yard, reported daily.
  static const MarketKind MARKET_KIND_MANDI =
      MarketKind._(1, _omitEnumNames ? '' : 'MARKET_KIND_MANDI');

  /// A commodity exchange contract.
  static const MarketKind MARKET_KIND_EXCHANGE =
      MarketKind._(2, _omitEnumNames ? '' : 'MARKET_KIND_EXCHANGE');

  /// A price offered directly by a buyer.
  static const MarketKind MARKET_KIND_FARM_GATE =
      MarketKind._(3, _omitEnumNames ? '' : 'MARKET_KIND_FARM_GATE');

  static const $core.List<MarketKind> values = <MarketKind>[
    MARKET_KIND_UNSPECIFIED,
    MARKET_KIND_MANDI,
    MARKET_KIND_EXCHANGE,
    MARKET_KIND_FARM_GATE,
  ];

  static final $core.List<MarketKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static MarketKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MarketKind._(super.value, super.name);
}

/// PriceTrend summarises where a commodity's price has been going.
class PriceTrend extends $pb.ProtobufEnum {
  static const PriceTrend PRICE_TREND_UNSPECIFIED =
      PriceTrend._(0, _omitEnumNames ? '' : 'PRICE_TREND_UNSPECIFIED');
  static const PriceTrend PRICE_TREND_RISING =
      PriceTrend._(1, _omitEnumNames ? '' : 'PRICE_TREND_RISING');
  static const PriceTrend PRICE_TREND_FALLING =
      PriceTrend._(2, _omitEnumNames ? '' : 'PRICE_TREND_FALLING');
  static const PriceTrend PRICE_TREND_FLAT =
      PriceTrend._(3, _omitEnumNames ? '' : 'PRICE_TREND_FLAT');

  static const $core.List<PriceTrend> values = <PriceTrend>[
    PRICE_TREND_UNSPECIFIED,
    PRICE_TREND_RISING,
    PRICE_TREND_FALLING,
    PRICE_TREND_FLAT,
  ];

  static final $core.List<PriceTrend?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static PriceTrend? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const PriceTrend._(super.value, super.name);
}

/// SellRecommendation is what the timing signal suggests.
class SellRecommendation extends $pb.ProtobufEnum {
  static const SellRecommendation SELL_RECOMMENDATION_UNSPECIFIED =
      SellRecommendation._(
          0, _omitEnumNames ? '' : 'SELL_RECOMMENDATION_UNSPECIFIED');
  static const SellRecommendation SELL_RECOMMENDATION_SELL_NOW =
      SellRecommendation._(
          1, _omitEnumNames ? '' : 'SELL_RECOMMENDATION_SELL_NOW');
  static const SellRecommendation SELL_RECOMMENDATION_HOLD =
      SellRecommendation._(2, _omitEnumNames ? '' : 'SELL_RECOMMENDATION_HOLD');

  /// Not enough price history to say anything. Distinct from HOLD, which is
  /// advice; this is the absence of advice.
  static const SellRecommendation SELL_RECOMMENDATION_INSUFFICIENT_DATA =
      SellRecommendation._(
          3, _omitEnumNames ? '' : 'SELL_RECOMMENDATION_INSUFFICIENT_DATA');

  static const $core.List<SellRecommendation> values = <SellRecommendation>[
    SELL_RECOMMENDATION_UNSPECIFIED,
    SELL_RECOMMENDATION_SELL_NOW,
    SELL_RECOMMENDATION_HOLD,
    SELL_RECOMMENDATION_INSUFFICIENT_DATA,
  ];

  static final $core.List<SellRecommendation?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static SellRecommendation? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SellRecommendation._(super.value, super.name);
}

/// AlertDirection is which way a price must move to fire an alert.
class AlertDirection extends $pb.ProtobufEnum {
  static const AlertDirection ALERT_DIRECTION_UNSPECIFIED =
      AlertDirection._(0, _omitEnumNames ? '' : 'ALERT_DIRECTION_UNSPECIFIED');
  static const AlertDirection ALERT_DIRECTION_ABOVE =
      AlertDirection._(1, _omitEnumNames ? '' : 'ALERT_DIRECTION_ABOVE');
  static const AlertDirection ALERT_DIRECTION_BELOW =
      AlertDirection._(2, _omitEnumNames ? '' : 'ALERT_DIRECTION_BELOW');

  static const $core.List<AlertDirection> values = <AlertDirection>[
    ALERT_DIRECTION_UNSPECIFIED,
    ALERT_DIRECTION_ABOVE,
    ALERT_DIRECTION_BELOW,
  ];

  static final $core.List<AlertDirection?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static AlertDirection? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AlertDirection._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
