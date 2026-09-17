// This is a generated file - do not edit.
//
// Generated from market.proto.

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

@$core.Deprecated('Use priceUnitDescriptor instead')
const PriceUnit$json = {
  '1': 'PriceUnit',
  '2': [
    {'1': 'PRICE_UNIT_UNSPECIFIED', '2': 0},
    {'1': 'PRICE_UNIT_PER_KG', '2': 1},
    {'1': 'PRICE_UNIT_PER_QUINTAL', '2': 2},
    {'1': 'PRICE_UNIT_PER_TONNE', '2': 3},
  ],
};

/// Descriptor for `PriceUnit`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List priceUnitDescriptor = $convert.base64Decode(
    'CglQcmljZVVuaXQSGgoWUFJJQ0VfVU5JVF9VTlNQRUNJRklFRBAAEhUKEVBSSUNFX1VOSVRfUE'
    'VSX0tHEAESGgoWUFJJQ0VfVU5JVF9QRVJfUVVJTlRBTBACEhgKFFBSSUNFX1VOSVRfUEVSX1RP'
    'Tk5FEAM=');

@$core.Deprecated('Use marketKindDescriptor instead')
const MarketKind$json = {
  '1': 'MarketKind',
  '2': [
    {'1': 'MARKET_KIND_UNSPECIFIED', '2': 0},
    {'1': 'MARKET_KIND_MANDI', '2': 1},
    {'1': 'MARKET_KIND_EXCHANGE', '2': 2},
    {'1': 'MARKET_KIND_FARM_GATE', '2': 3},
  ],
};

/// Descriptor for `MarketKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List marketKindDescriptor = $convert.base64Decode(
    'CgpNYXJrZXRLaW5kEhsKF01BUktFVF9LSU5EX1VOU1BFQ0lGSUVEEAASFQoRTUFSS0VUX0tJTk'
    'RfTUFOREkQARIYChRNQVJLRVRfS0lORF9FWENIQU5HRRACEhkKFU1BUktFVF9LSU5EX0ZBUk1f'
    'R0FURRAD');

@$core.Deprecated('Use priceTrendDescriptor instead')
const PriceTrend$json = {
  '1': 'PriceTrend',
  '2': [
    {'1': 'PRICE_TREND_UNSPECIFIED', '2': 0},
    {'1': 'PRICE_TREND_RISING', '2': 1},
    {'1': 'PRICE_TREND_FALLING', '2': 2},
    {'1': 'PRICE_TREND_FLAT', '2': 3},
  ],
};

/// Descriptor for `PriceTrend`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List priceTrendDescriptor = $convert.base64Decode(
    'CgpQcmljZVRyZW5kEhsKF1BSSUNFX1RSRU5EX1VOU1BFQ0lGSUVEEAASFgoSUFJJQ0VfVFJFTk'
    'RfUklTSU5HEAESFwoTUFJJQ0VfVFJFTkRfRkFMTElORxACEhQKEFBSSUNFX1RSRU5EX0ZMQVQQ'
    'Aw==');

@$core.Deprecated('Use sellRecommendationDescriptor instead')
const SellRecommendation$json = {
  '1': 'SellRecommendation',
  '2': [
    {'1': 'SELL_RECOMMENDATION_UNSPECIFIED', '2': 0},
    {'1': 'SELL_RECOMMENDATION_SELL_NOW', '2': 1},
    {'1': 'SELL_RECOMMENDATION_HOLD', '2': 2},
    {'1': 'SELL_RECOMMENDATION_INSUFFICIENT_DATA', '2': 3},
  ],
};

/// Descriptor for `SellRecommendation`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List sellRecommendationDescriptor = $convert.base64Decode(
    'ChJTZWxsUmVjb21tZW5kYXRpb24SIwofU0VMTF9SRUNPTU1FTkRBVElPTl9VTlNQRUNJRklFRB'
    'AAEiAKHFNFTExfUkVDT01NRU5EQVRJT05fU0VMTF9OT1cQARIcChhTRUxMX1JFQ09NTUVOREFU'
    'SU9OX0hPTEQQAhIpCiVTRUxMX1JFQ09NTUVOREFUSU9OX0lOU1VGRklDSUVOVF9EQVRBEAM=');

@$core.Deprecated('Use alertDirectionDescriptor instead')
const AlertDirection$json = {
  '1': 'AlertDirection',
  '2': [
    {'1': 'ALERT_DIRECTION_UNSPECIFIED', '2': 0},
    {'1': 'ALERT_DIRECTION_ABOVE', '2': 1},
    {'1': 'ALERT_DIRECTION_BELOW', '2': 2},
  ],
};

/// Descriptor for `AlertDirection`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List alertDirectionDescriptor = $convert.base64Decode(
    'Cg5BbGVydERpcmVjdGlvbhIfChtBTEVSVF9ESVJFQ1RJT05fVU5TUEVDSUZJRUQQABIZChVBTE'
    'VSVF9ESVJFQ1RJT05fQUJPVkUQARIZChVBTEVSVF9ESVJFQ1RJT05fQkVMT1cQAg==');

@$core.Deprecated('Use marketDescriptor instead')
const Market$json = {
  '1': 'Market',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'kind',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.market.v1.MarketKind',
      '10': 'kind'
    },
    {'1': 'state', '3': 4, '4': 1, '5': 9, '10': 'state'},
    {'1': 'district', '3': 5, '4': 1, '5': 9, '10': 'district'},
    {'1': 'latitude', '3': 6, '4': 1, '5': 1, '10': 'latitude'},
    {'1': 'longitude', '3': 7, '4': 1, '5': 1, '10': 'longitude'},
    {'1': 'external_ref', '3': 8, '4': 1, '5': 9, '10': 'externalRef'},
  ],
};

/// Descriptor for `Market`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketDescriptor = $convert.base64Decode(
    'CgZNYXJrZXQSDgoCaWQYASABKAlSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSNQoEa2luZBgDIA'
    'EoDjIhLmFncmljdWx0dXJlLm1hcmtldC52MS5NYXJrZXRLaW5kUgRraW5kEhQKBXN0YXRlGAQg'
    'ASgJUgVzdGF0ZRIaCghkaXN0cmljdBgFIAEoCVIIZGlzdHJpY3QSGgoIbGF0aXR1ZGUYBiABKA'
    'FSCGxhdGl0dWRlEhwKCWxvbmdpdHVkZRgHIAEoAVIJbG9uZ2l0dWRlEiEKDGV4dGVybmFsX3Jl'
    'ZhgIIAEoCVILZXh0ZXJuYWxSZWY=');

@$core.Deprecated('Use priceQuoteDescriptor instead')
const PriceQuote$json = {
  '1': 'PriceQuote',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'commodity', '3': 2, '4': 1, '5': 9, '10': 'commodity'},
    {'1': 'variety', '3': 3, '4': 1, '5': 9, '10': 'variety'},
    {'1': 'market_id', '3': 4, '4': 1, '5': 9, '10': 'marketId'},
    {'1': 'market_name', '3': 5, '4': 1, '5': 9, '10': 'marketName'},
    {'1': 'min_price', '3': 6, '4': 1, '5': 1, '10': 'minPrice'},
    {'1': 'max_price', '3': 7, '4': 1, '5': 1, '10': 'maxPrice'},
    {'1': 'modal_price', '3': 8, '4': 1, '5': 1, '10': 'modalPrice'},
    {
      '1': 'unit',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.agriculture.market.v1.PriceUnit',
      '10': 'unit'
    },
    {'1': 'currency', '3': 10, '4': 1, '5': 9, '10': 'currency'},
    {
      '1': 'price_per_quintal',
      '3': 11,
      '4': 1,
      '5': 1,
      '10': 'pricePerQuintal'
    },
    {'1': 'arrivals_tonnes', '3': 12, '4': 1, '5': 1, '10': 'arrivalsTonnes'},
    {
      '1': 'quoted_on',
      '3': 13,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'quotedOn'
    },
    {'1': 'source', '3': 14, '4': 1, '5': 9, '10': 'source'},
  ],
};

/// Descriptor for `PriceQuote`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceQuoteDescriptor = $convert.base64Decode(
    'CgpQcmljZVF1b3RlEg4KAmlkGAEgASgJUgJpZBIcCgljb21tb2RpdHkYAiABKAlSCWNvbW1vZG'
    'l0eRIYCgd2YXJpZXR5GAMgASgJUgd2YXJpZXR5EhsKCW1hcmtldF9pZBgEIAEoCVIIbWFya2V0'
    'SWQSHwoLbWFya2V0X25hbWUYBSABKAlSCm1hcmtldE5hbWUSGwoJbWluX3ByaWNlGAYgASgBUg'
    'htaW5QcmljZRIbCgltYXhfcHJpY2UYByABKAFSCG1heFByaWNlEh8KC21vZGFsX3ByaWNlGAgg'
    'ASgBUgptb2RhbFByaWNlEjQKBHVuaXQYCSABKA4yIC5hZ3JpY3VsdHVyZS5tYXJrZXQudjEuUH'
    'JpY2VVbml0UgR1bml0EhoKCGN1cnJlbmN5GAogASgJUghjdXJyZW5jeRIqChFwcmljZV9wZXJf'
    'cXVpbnRhbBgLIAEoAVIPcHJpY2VQZXJRdWludGFsEicKD2Fycml2YWxzX3Rvbm5lcxgMIAEoAV'
    'IOYXJyaXZhbHNUb25uZXMSNwoJcXVvdGVkX29uGA0gASgLMhouZ29vZ2xlLnByb3RvYnVmLlRp'
    'bWVzdGFtcFIIcXVvdGVkT24SFgoGc291cmNlGA4gASgJUgZzb3VyY2U=');

@$core.Deprecated('Use priceStatisticsDescriptor instead')
const PriceStatistics$json = {
  '1': 'PriceStatistics',
  '2': [
    {'1': 'commodity', '3': 1, '4': 1, '5': 9, '10': 'commodity'},
    {'1': 'market_id', '3': 2, '4': 1, '5': 9, '10': 'marketId'},
    {'1': 'mean_per_quintal', '3': 3, '4': 1, '5': 1, '10': 'meanPerQuintal'},
    {
      '1': 'median_per_quintal',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'medianPerQuintal'
    },
    {'1': 'min_per_quintal', '3': 5, '4': 1, '5': 1, '10': 'minPerQuintal'},
    {'1': 'max_per_quintal', '3': 6, '4': 1, '5': 1, '10': 'maxPerQuintal'},
    {
      '1': 'latest_per_quintal',
      '3': 7,
      '4': 1,
      '5': 1,
      '10': 'latestPerQuintal'
    },
    {'1': 'latest_z_score', '3': 8, '4': 1, '5': 1, '10': 'latestZScore'},
    {
      '1': 'trend',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.agriculture.market.v1.PriceTrend',
      '10': 'trend'
    },
    {'1': 'trend_per_day', '3': 10, '4': 1, '5': 1, '10': 'trendPerDay'},
    {'1': 'observation_days', '3': 11, '4': 1, '5': 5, '10': 'observationDays'},
  ],
};

/// Descriptor for `PriceStatistics`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceStatisticsDescriptor = $convert.base64Decode(
    'Cg9QcmljZVN0YXRpc3RpY3MSHAoJY29tbW9kaXR5GAEgASgJUgljb21tb2RpdHkSGwoJbWFya2'
    'V0X2lkGAIgASgJUghtYXJrZXRJZBIoChBtZWFuX3Blcl9xdWludGFsGAMgASgBUg5tZWFuUGVy'
    'UXVpbnRhbBIsChJtZWRpYW5fcGVyX3F1aW50YWwYBCABKAFSEG1lZGlhblBlclF1aW50YWwSJg'
    'oPbWluX3Blcl9xdWludGFsGAUgASgBUg1taW5QZXJRdWludGFsEiYKD21heF9wZXJfcXVpbnRh'
    'bBgGIAEoAVINbWF4UGVyUXVpbnRhbBIsChJsYXRlc3RfcGVyX3F1aW50YWwYByABKAFSEGxhdG'
    'VzdFBlclF1aW50YWwSJAoObGF0ZXN0X3pfc2NvcmUYCCABKAFSDGxhdGVzdFpTY29yZRI3CgV0'
    'cmVuZBgJIAEoDjIhLmFncmljdWx0dXJlLm1hcmtldC52MS5QcmljZVRyZW5kUgV0cmVuZBIiCg'
    '10cmVuZF9wZXJfZGF5GAogASgBUgt0cmVuZFBlckRheRIpChBvYnNlcnZhdGlvbl9kYXlzGAsg'
    'ASgFUg9vYnNlcnZhdGlvbkRheXM=');

@$core.Deprecated('Use sellSignalDescriptor instead')
const SellSignal$json = {
  '1': 'SellSignal',
  '2': [
    {'1': 'commodity', '3': 1, '4': 1, '5': 9, '10': 'commodity'},
    {'1': 'market_id', '3': 2, '4': 1, '5': 9, '10': 'marketId'},
    {
      '1': 'recommendation',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.market.v1.SellRecommendation',
      '10': 'recommendation'
    },
    {'1': 'confidence', '3': 4, '4': 1, '5': 1, '10': 'confidence'},
    {'1': 'rationale', '3': 5, '4': 1, '5': 9, '10': 'rationale'},
    {
      '1': 'statistics',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.agriculture.market.v1.PriceStatistics',
      '10': 'statistics'
    },
    {
      '1': 'generated_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'generatedAt'
    },
  ],
};

/// Descriptor for `SellSignal`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sellSignalDescriptor = $convert.base64Decode(
    'CgpTZWxsU2lnbmFsEhwKCWNvbW1vZGl0eRgBIAEoCVIJY29tbW9kaXR5EhsKCW1hcmtldF9pZB'
    'gCIAEoCVIIbWFya2V0SWQSUQoOcmVjb21tZW5kYXRpb24YAyABKA4yKS5hZ3JpY3VsdHVyZS5t'
    'YXJrZXQudjEuU2VsbFJlY29tbWVuZGF0aW9uUg5yZWNvbW1lbmRhdGlvbhIeCgpjb25maWRlbm'
    'NlGAQgASgBUgpjb25maWRlbmNlEhwKCXJhdGlvbmFsZRgFIAEoCVIJcmF0aW9uYWxlEkYKCnN0'
    'YXRpc3RpY3MYBiABKAsyJi5hZ3JpY3VsdHVyZS5tYXJrZXQudjEuUHJpY2VTdGF0aXN0aWNzUg'
    'pzdGF0aXN0aWNzEj0KDGdlbmVyYXRlZF9hdBgHIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1l'
    'c3RhbXBSC2dlbmVyYXRlZEF0');

@$core.Deprecated('Use priceAlertDescriptor instead')
const PriceAlert$json = {
  '1': 'PriceAlert',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'commodity', '3': 2, '4': 1, '5': 9, '10': 'commodity'},
    {'1': 'market_id', '3': 3, '4': 1, '5': 9, '10': 'marketId'},
    {
      '1': 'direction',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.agriculture.market.v1.AlertDirection',
      '10': 'direction'
    },
    {
      '1': 'threshold_per_quintal',
      '3': 5,
      '4': 1,
      '5': 1,
      '10': 'thresholdPerQuintal'
    },
    {'1': 'enabled', '3': 6, '4': 1, '5': 8, '10': 'enabled'},
    {
      '1': 'created_at',
      '3': 7,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'createdAt'
    },
    {
      '1': 'last_fired_at',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'lastFiredAt'
    },
    {'1': 'last_fired_price', '3': 9, '4': 1, '5': 1, '10': 'lastFiredPrice'},
  ],
};

/// Descriptor for `PriceAlert`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List priceAlertDescriptor = $convert.base64Decode(
    'CgpQcmljZUFsZXJ0Eg4KAmlkGAEgASgJUgJpZBIcCgljb21tb2RpdHkYAiABKAlSCWNvbW1vZG'
    'l0eRIbCgltYXJrZXRfaWQYAyABKAlSCG1hcmtldElkEkMKCWRpcmVjdGlvbhgEIAEoDjIlLmFn'
    'cmljdWx0dXJlLm1hcmtldC52MS5BbGVydERpcmVjdGlvblIJZGlyZWN0aW9uEjIKFXRocmVzaG'
    '9sZF9wZXJfcXVpbnRhbBgFIAEoAVITdGhyZXNob2xkUGVyUXVpbnRhbBIYCgdlbmFibGVkGAYg'
    'ASgIUgdlbmFibGVkEjkKCmNyZWF0ZWRfYXQYByABKAsyGi5nb29nbGUucHJvdG9idWYuVGltZX'
    'N0YW1wUgljcmVhdGVkQXQSPgoNbGFzdF9maXJlZF9hdBgIIAEoCzIaLmdvb2dsZS5wcm90b2J1'
    'Zi5UaW1lc3RhbXBSC2xhc3RGaXJlZEF0EigKEGxhc3RfZmlyZWRfcHJpY2UYCSABKAFSDmxhc3'
    'RGaXJlZFByaWNl');

@$core.Deprecated('Use listMarketsRequestDescriptor instead')
const ListMarketsRequest$json = {
  '1': 'ListMarketsRequest',
  '2': [
    {'1': 'state', '3': 1, '4': 1, '5': 9, '10': 'state'},
    {'1': 'district', '3': 2, '4': 1, '5': 9, '10': 'district'},
    {
      '1': 'kind',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.market.v1.MarketKind',
      '10': 'kind'
    },
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 5, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListMarketsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMarketsRequestDescriptor = $convert.base64Decode(
    'ChJMaXN0TWFya2V0c1JlcXVlc3QSFAoFc3RhdGUYASABKAlSBXN0YXRlEhoKCGRpc3RyaWN0GA'
    'IgASgJUghkaXN0cmljdBI1CgRraW5kGAMgASgOMiEuYWdyaWN1bHR1cmUubWFya2V0LnYxLk1h'
    'cmtldEtpbmRSBGtpbmQSGwoJcGFnZV9zaXplGAQgASgFUghwYWdlU2l6ZRIdCgpwYWdlX3Rva2'
    'VuGAUgASgJUglwYWdlVG9rZW4=');

@$core.Deprecated('Use listMarketsResponseDescriptor instead')
const ListMarketsResponse$json = {
  '1': 'ListMarketsResponse',
  '2': [
    {
      '1': 'markets',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.market.v1.Market',
      '10': 'markets'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListMarketsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listMarketsResponseDescriptor = $convert.base64Decode(
    'ChNMaXN0TWFya2V0c1Jlc3BvbnNlEjcKB21hcmtldHMYASADKAsyHS5hZ3JpY3VsdHVyZS5tYX'
    'JrZXQudjEuTWFya2V0UgdtYXJrZXRzEiYKD25leHRfcGFnZV90b2tlbhgCIAEoCVINbmV4dFBh'
    'Z2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use recordQuotesRequestDescriptor instead')
const RecordQuotesRequest$json = {
  '1': 'RecordQuotesRequest',
  '2': [
    {
      '1': 'quotes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.market.v1.PriceQuote',
      '10': 'quotes'
    },
  ],
};

/// Descriptor for `RecordQuotesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recordQuotesRequestDescriptor = $convert.base64Decode(
    'ChNSZWNvcmRRdW90ZXNSZXF1ZXN0EjkKBnF1b3RlcxgBIAMoCzIhLmFncmljdWx0dXJlLm1hcm'
    'tldC52MS5QcmljZVF1b3RlUgZxdW90ZXM=');

@$core.Deprecated('Use recordQuotesResponseDescriptor instead')
const RecordQuotesResponse$json = {
  '1': 'RecordQuotesResponse',
  '2': [
    {'1': 'recorded', '3': 1, '4': 1, '5': 5, '10': 'recorded'},
    {'1': 'rejected', '3': 2, '4': 3, '5': 9, '10': 'rejected'},
  ],
};

/// Descriptor for `RecordQuotesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List recordQuotesResponseDescriptor = $convert.base64Decode(
    'ChRSZWNvcmRRdW90ZXNSZXNwb25zZRIaCghyZWNvcmRlZBgBIAEoBVIIcmVjb3JkZWQSGgoIcm'
    'VqZWN0ZWQYAiADKAlSCHJlamVjdGVk');

@$core.Deprecated('Use listQuotesRequestDescriptor instead')
const ListQuotesRequest$json = {
  '1': 'ListQuotesRequest',
  '2': [
    {'1': 'commodity', '3': 1, '4': 1, '5': 9, '10': 'commodity'},
    {'1': 'market_id', '3': 2, '4': 1, '5': 9, '10': 'marketId'},
    {
      '1': 'from',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'from'
    },
    {
      '1': 'to',
      '3': 4,
      '4': 1,
      '5': 11,
      '6': '.google.protobuf.Timestamp',
      '10': 'to'
    },
    {'1': 'page_size', '3': 5, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 6, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListQuotesRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listQuotesRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0UXVvdGVzUmVxdWVzdBIcCgljb21tb2RpdHkYASABKAlSCWNvbW1vZGl0eRIbCgltYX'
    'JrZXRfaWQYAiABKAlSCG1hcmtldElkEi4KBGZyb20YAyABKAsyGi5nb29nbGUucHJvdG9idWYu'
    'VGltZXN0YW1wUgRmcm9tEioKAnRvGAQgASgLMhouZ29vZ2xlLnByb3RvYnVmLlRpbWVzdGFtcF'
    'ICdG8SGwoJcGFnZV9zaXplGAUgASgFUghwYWdlU2l6ZRIdCgpwYWdlX3Rva2VuGAYgASgJUglw'
    'YWdlVG9rZW4=');

@$core.Deprecated('Use listQuotesResponseDescriptor instead')
const ListQuotesResponse$json = {
  '1': 'ListQuotesResponse',
  '2': [
    {
      '1': 'quotes',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.market.v1.PriceQuote',
      '10': 'quotes'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListQuotesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listQuotesResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0UXVvdGVzUmVzcG9uc2USOQoGcXVvdGVzGAEgAygLMiEuYWdyaWN1bHR1cmUubWFya2'
    'V0LnYxLlByaWNlUXVvdGVSBnF1b3RlcxImCg9uZXh0X3BhZ2VfdG9rZW4YAiABKAlSDW5leHRQ'
    'YWdlVG9rZW4SHwoLdG90YWxfY291bnQYAyABKAVSCnRvdGFsQ291bnQ=');

@$core.Deprecated('Use getPriceStatisticsRequestDescriptor instead')
const GetPriceStatisticsRequest$json = {
  '1': 'GetPriceStatisticsRequest',
  '2': [
    {'1': 'commodity', '3': 1, '4': 1, '5': 9, '10': 'commodity'},
    {'1': 'market_id', '3': 2, '4': 1, '5': 9, '10': 'marketId'},
    {'1': 'days', '3': 3, '4': 1, '5': 5, '10': 'days'},
  ],
};

/// Descriptor for `GetPriceStatisticsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPriceStatisticsRequestDescriptor =
    $convert.base64Decode(
        'ChlHZXRQcmljZVN0YXRpc3RpY3NSZXF1ZXN0EhwKCWNvbW1vZGl0eRgBIAEoCVIJY29tbW9kaX'
        'R5EhsKCW1hcmtldF9pZBgCIAEoCVIIbWFya2V0SWQSEgoEZGF5cxgDIAEoBVIEZGF5cw==');

@$core.Deprecated('Use getPriceStatisticsResponseDescriptor instead')
const GetPriceStatisticsResponse$json = {
  '1': 'GetPriceStatisticsResponse',
  '2': [
    {
      '1': 'statistics',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.market.v1.PriceStatistics',
      '10': 'statistics'
    },
  ],
};

/// Descriptor for `GetPriceStatisticsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getPriceStatisticsResponseDescriptor =
    $convert.base64Decode(
        'ChpHZXRQcmljZVN0YXRpc3RpY3NSZXNwb25zZRJGCgpzdGF0aXN0aWNzGAEgASgLMiYuYWdyaW'
        'N1bHR1cmUubWFya2V0LnYxLlByaWNlU3RhdGlzdGljc1IKc3RhdGlzdGljcw==');

@$core.Deprecated('Use getSellSignalRequestDescriptor instead')
const GetSellSignalRequest$json = {
  '1': 'GetSellSignalRequest',
  '2': [
    {'1': 'commodity', '3': 1, '4': 1, '5': 9, '10': 'commodity'},
    {'1': 'market_id', '3': 2, '4': 1, '5': 9, '10': 'marketId'},
    {'1': 'days', '3': 3, '4': 1, '5': 5, '10': 'days'},
  ],
};

/// Descriptor for `GetSellSignalRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSellSignalRequestDescriptor = $convert.base64Decode(
    'ChRHZXRTZWxsU2lnbmFsUmVxdWVzdBIcCgljb21tb2RpdHkYASABKAlSCWNvbW1vZGl0eRIbCg'
    'ltYXJrZXRfaWQYAiABKAlSCG1hcmtldElkEhIKBGRheXMYAyABKAVSBGRheXM=');

@$core.Deprecated('Use getSellSignalResponseDescriptor instead')
const GetSellSignalResponse$json = {
  '1': 'GetSellSignalResponse',
  '2': [
    {
      '1': 'signal',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.market.v1.SellSignal',
      '10': 'signal'
    },
  ],
};

/// Descriptor for `GetSellSignalResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getSellSignalResponseDescriptor = $convert.base64Decode(
    'ChVHZXRTZWxsU2lnbmFsUmVzcG9uc2USOQoGc2lnbmFsGAEgASgLMiEuYWdyaWN1bHR1cmUubW'
    'Fya2V0LnYxLlNlbGxTaWduYWxSBnNpZ25hbA==');

@$core.Deprecated('Use createPriceAlertRequestDescriptor instead')
const CreatePriceAlertRequest$json = {
  '1': 'CreatePriceAlertRequest',
  '2': [
    {'1': 'commodity', '3': 1, '4': 1, '5': 9, '10': 'commodity'},
    {'1': 'market_id', '3': 2, '4': 1, '5': 9, '10': 'marketId'},
    {
      '1': 'direction',
      '3': 3,
      '4': 1,
      '5': 14,
      '6': '.agriculture.market.v1.AlertDirection',
      '10': 'direction'
    },
    {
      '1': 'threshold_per_quintal',
      '3': 4,
      '4': 1,
      '5': 1,
      '10': 'thresholdPerQuintal'
    },
  ],
};

/// Descriptor for `CreatePriceAlertRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createPriceAlertRequestDescriptor = $convert.base64Decode(
    'ChdDcmVhdGVQcmljZUFsZXJ0UmVxdWVzdBIcCgljb21tb2RpdHkYASABKAlSCWNvbW1vZGl0eR'
    'IbCgltYXJrZXRfaWQYAiABKAlSCG1hcmtldElkEkMKCWRpcmVjdGlvbhgDIAEoDjIlLmFncmlj'
    'dWx0dXJlLm1hcmtldC52MS5BbGVydERpcmVjdGlvblIJZGlyZWN0aW9uEjIKFXRocmVzaG9sZF'
    '9wZXJfcXVpbnRhbBgEIAEoAVITdGhyZXNob2xkUGVyUXVpbnRhbA==');

@$core.Deprecated('Use createPriceAlertResponseDescriptor instead')
const CreatePriceAlertResponse$json = {
  '1': 'CreatePriceAlertResponse',
  '2': [
    {
      '1': 'alert',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.agriculture.market.v1.PriceAlert',
      '10': 'alert'
    },
  ],
};

/// Descriptor for `CreatePriceAlertResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createPriceAlertResponseDescriptor =
    $convert.base64Decode(
        'ChhDcmVhdGVQcmljZUFsZXJ0UmVzcG9uc2USNwoFYWxlcnQYASABKAsyIS5hZ3JpY3VsdHVyZS'
        '5tYXJrZXQudjEuUHJpY2VBbGVydFIFYWxlcnQ=');

@$core.Deprecated('Use listPriceAlertsRequestDescriptor instead')
const ListPriceAlertsRequest$json = {
  '1': 'ListPriceAlertsRequest',
  '2': [
    {'1': 'commodity', '3': 1, '4': 1, '5': 9, '10': 'commodity'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
    {'1': 'page_token', '3': 3, '4': 1, '5': 9, '10': 'pageToken'},
  ],
};

/// Descriptor for `ListPriceAlertsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPriceAlertsRequestDescriptor = $convert.base64Decode(
    'ChZMaXN0UHJpY2VBbGVydHNSZXF1ZXN0EhwKCWNvbW1vZGl0eRgBIAEoCVIJY29tbW9kaXR5Eh'
    'sKCXBhZ2Vfc2l6ZRgCIAEoBVIIcGFnZVNpemUSHQoKcGFnZV90b2tlbhgDIAEoCVIJcGFnZVRv'
    'a2Vu');

@$core.Deprecated('Use listPriceAlertsResponseDescriptor instead')
const ListPriceAlertsResponse$json = {
  '1': 'ListPriceAlertsResponse',
  '2': [
    {
      '1': 'alerts',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.agriculture.market.v1.PriceAlert',
      '10': 'alerts'
    },
    {'1': 'next_page_token', '3': 2, '4': 1, '5': 9, '10': 'nextPageToken'},
    {'1': 'total_count', '3': 3, '4': 1, '5': 5, '10': 'totalCount'},
  ],
};

/// Descriptor for `ListPriceAlertsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listPriceAlertsResponseDescriptor = $convert.base64Decode(
    'ChdMaXN0UHJpY2VBbGVydHNSZXNwb25zZRI5CgZhbGVydHMYASADKAsyIS5hZ3JpY3VsdHVyZS'
    '5tYXJrZXQudjEuUHJpY2VBbGVydFIGYWxlcnRzEiYKD25leHRfcGFnZV90b2tlbhgCIAEoCVIN'
    'bmV4dFBhZ2VUb2tlbhIfCgt0b3RhbF9jb3VudBgDIAEoBVIKdG90YWxDb3VudA==');

@$core.Deprecated('Use deletePriceAlertRequestDescriptor instead')
const DeletePriceAlertRequest$json = {
  '1': 'DeletePriceAlertRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeletePriceAlertRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deletePriceAlertRequestDescriptor = $convert
    .base64Decode('ChdEZWxldGVQcmljZUFsZXJ0UmVxdWVzdBIOCgJpZBgBIAEoCVICaWQ=');

@$core.Deprecated('Use deletePriceAlertResponseDescriptor instead')
const DeletePriceAlertResponse$json = {
  '1': 'DeletePriceAlertResponse',
  '2': [
    {'1': 'deleted', '3': 1, '4': 1, '5': 8, '10': 'deleted'},
  ],
};

/// Descriptor for `DeletePriceAlertResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deletePriceAlertResponseDescriptor =
    $convert.base64Decode(
        'ChhEZWxldGVQcmljZUFsZXJ0UmVzcG9uc2USGAoHZGVsZXRlZBgBIAEoCFIHZGVsZXRlZA==');

const $core.Map<$core.String, $core.dynamic> MarketServiceBase$json = {
  '1': 'MarketService',
  '2': [
    {
      '1': 'ListMarkets',
      '2': '.agriculture.market.v1.ListMarketsRequest',
      '3': '.agriculture.market.v1.ListMarketsResponse'
    },
    {
      '1': 'RecordQuotes',
      '2': '.agriculture.market.v1.RecordQuotesRequest',
      '3': '.agriculture.market.v1.RecordQuotesResponse'
    },
    {
      '1': 'ListQuotes',
      '2': '.agriculture.market.v1.ListQuotesRequest',
      '3': '.agriculture.market.v1.ListQuotesResponse'
    },
    {
      '1': 'GetPriceStatistics',
      '2': '.agriculture.market.v1.GetPriceStatisticsRequest',
      '3': '.agriculture.market.v1.GetPriceStatisticsResponse'
    },
    {
      '1': 'GetSellSignal',
      '2': '.agriculture.market.v1.GetSellSignalRequest',
      '3': '.agriculture.market.v1.GetSellSignalResponse'
    },
    {
      '1': 'CreatePriceAlert',
      '2': '.agriculture.market.v1.CreatePriceAlertRequest',
      '3': '.agriculture.market.v1.CreatePriceAlertResponse'
    },
    {
      '1': 'ListPriceAlerts',
      '2': '.agriculture.market.v1.ListPriceAlertsRequest',
      '3': '.agriculture.market.v1.ListPriceAlertsResponse'
    },
    {
      '1': 'DeletePriceAlert',
      '2': '.agriculture.market.v1.DeletePriceAlertRequest',
      '3': '.agriculture.market.v1.DeletePriceAlertResponse'
    },
  ],
};

@$core.Deprecated('Use marketServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
    MarketServiceBase$messageJson = {
  '.agriculture.market.v1.ListMarketsRequest': ListMarketsRequest$json,
  '.agriculture.market.v1.ListMarketsResponse': ListMarketsResponse$json,
  '.agriculture.market.v1.Market': Market$json,
  '.agriculture.market.v1.RecordQuotesRequest': RecordQuotesRequest$json,
  '.agriculture.market.v1.PriceQuote': PriceQuote$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.agriculture.market.v1.RecordQuotesResponse': RecordQuotesResponse$json,
  '.agriculture.market.v1.ListQuotesRequest': ListQuotesRequest$json,
  '.agriculture.market.v1.ListQuotesResponse': ListQuotesResponse$json,
  '.agriculture.market.v1.GetPriceStatisticsRequest':
      GetPriceStatisticsRequest$json,
  '.agriculture.market.v1.GetPriceStatisticsResponse':
      GetPriceStatisticsResponse$json,
  '.agriculture.market.v1.PriceStatistics': PriceStatistics$json,
  '.agriculture.market.v1.GetSellSignalRequest': GetSellSignalRequest$json,
  '.agriculture.market.v1.GetSellSignalResponse': GetSellSignalResponse$json,
  '.agriculture.market.v1.SellSignal': SellSignal$json,
  '.agriculture.market.v1.CreatePriceAlertRequest':
      CreatePriceAlertRequest$json,
  '.agriculture.market.v1.CreatePriceAlertResponse':
      CreatePriceAlertResponse$json,
  '.agriculture.market.v1.PriceAlert': PriceAlert$json,
  '.agriculture.market.v1.ListPriceAlertsRequest': ListPriceAlertsRequest$json,
  '.agriculture.market.v1.ListPriceAlertsResponse':
      ListPriceAlertsResponse$json,
  '.agriculture.market.v1.DeletePriceAlertRequest':
      DeletePriceAlertRequest$json,
  '.agriculture.market.v1.DeletePriceAlertResponse':
      DeletePriceAlertResponse$json,
};

/// Descriptor for `MarketService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List marketServiceDescriptor = $convert.base64Decode(
    'Cg1NYXJrZXRTZXJ2aWNlEmQKC0xpc3RNYXJrZXRzEikuYWdyaWN1bHR1cmUubWFya2V0LnYxLk'
    'xpc3RNYXJrZXRzUmVxdWVzdBoqLmFncmljdWx0dXJlLm1hcmtldC52MS5MaXN0TWFya2V0c1Jl'
    'c3BvbnNlEmcKDFJlY29yZFF1b3RlcxIqLmFncmljdWx0dXJlLm1hcmtldC52MS5SZWNvcmRRdW'
    '90ZXNSZXF1ZXN0GisuYWdyaWN1bHR1cmUubWFya2V0LnYxLlJlY29yZFF1b3Rlc1Jlc3BvbnNl'
    'EmEKCkxpc3RRdW90ZXMSKC5hZ3JpY3VsdHVyZS5tYXJrZXQudjEuTGlzdFF1b3Rlc1JlcXVlc3'
    'QaKS5hZ3JpY3VsdHVyZS5tYXJrZXQudjEuTGlzdFF1b3Rlc1Jlc3BvbnNlEnkKEkdldFByaWNl'
    'U3RhdGlzdGljcxIwLmFncmljdWx0dXJlLm1hcmtldC52MS5HZXRQcmljZVN0YXRpc3RpY3NSZX'
    'F1ZXN0GjEuYWdyaWN1bHR1cmUubWFya2V0LnYxLkdldFByaWNlU3RhdGlzdGljc1Jlc3BvbnNl'
    'EmoKDUdldFNlbGxTaWduYWwSKy5hZ3JpY3VsdHVyZS5tYXJrZXQudjEuR2V0U2VsbFNpZ25hbF'
    'JlcXVlc3QaLC5hZ3JpY3VsdHVyZS5tYXJrZXQudjEuR2V0U2VsbFNpZ25hbFJlc3BvbnNlEnMK'
    'EENyZWF0ZVByaWNlQWxlcnQSLi5hZ3JpY3VsdHVyZS5tYXJrZXQudjEuQ3JlYXRlUHJpY2VBbG'
    'VydFJlcXVlc3QaLy5hZ3JpY3VsdHVyZS5tYXJrZXQudjEuQ3JlYXRlUHJpY2VBbGVydFJlc3Bv'
    'bnNlEnAKD0xpc3RQcmljZUFsZXJ0cxItLmFncmljdWx0dXJlLm1hcmtldC52MS5MaXN0UHJpY2'
    'VBbGVydHNSZXF1ZXN0Gi4uYWdyaWN1bHR1cmUubWFya2V0LnYxLkxpc3RQcmljZUFsZXJ0c1Jl'
    'c3BvbnNlEnMKEERlbGV0ZVByaWNlQWxlcnQSLi5hZ3JpY3VsdHVyZS5tYXJrZXQudjEuRGVsZX'
    'RlUHJpY2VBbGVydFJlcXVlc3QaLy5hZ3JpY3VsdHVyZS5tYXJrZXQudjEuRGVsZXRlUHJpY2VB'
    'bGVydFJlc3BvbnNl');
