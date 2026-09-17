// This is a generated file - do not edit.
//
// Generated from finance.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Season is the Indian cropping calendar, which is what the insurance
/// schemes are written against.
class Season extends $pb.ProtobufEnum {
  static const Season SEASON_UNSPECIFIED =
      Season._(0, _omitEnumNames ? '' : 'SEASON_UNSPECIFIED');
  static const Season SEASON_KHARIF =
      Season._(1, _omitEnumNames ? '' : 'SEASON_KHARIF');
  static const Season SEASON_RABI =
      Season._(2, _omitEnumNames ? '' : 'SEASON_RABI');
  static const Season SEASON_ZAID =
      Season._(3, _omitEnumNames ? '' : 'SEASON_ZAID');

  static const $core.List<Season> values = <Season>[
    SEASON_UNSPECIFIED,
    SEASON_KHARIF,
    SEASON_RABI,
    SEASON_ZAID,
  ];

  static final $core.List<Season?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static Season? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Season._(super.value, super.name);
}

/// CropCategory decides the farmer's premium share under PMFBY.
///
/// The scheme caps what a farmer pays at 2% of the sum insured for kharif food
/// crops, 1.5% for rabi, and 5% for commercial and horticultural crops. The
/// government pays the rest of the actuarial premium, so the category is not a
/// label — it is most of the price the farmer sees.
class CropCategory extends $pb.ProtobufEnum {
  static const CropCategory CROP_CATEGORY_UNSPECIFIED =
      CropCategory._(0, _omitEnumNames ? '' : 'CROP_CATEGORY_UNSPECIFIED');
  static const CropCategory CROP_CATEGORY_FOOD_GRAIN =
      CropCategory._(1, _omitEnumNames ? '' : 'CROP_CATEGORY_FOOD_GRAIN');
  static const CropCategory CROP_CATEGORY_OILSEED =
      CropCategory._(2, _omitEnumNames ? '' : 'CROP_CATEGORY_OILSEED');
  static const CropCategory CROP_CATEGORY_COMMERCIAL =
      CropCategory._(3, _omitEnumNames ? '' : 'CROP_CATEGORY_COMMERCIAL');
  static const CropCategory CROP_CATEGORY_HORTICULTURE =
      CropCategory._(4, _omitEnumNames ? '' : 'CROP_CATEGORY_HORTICULTURE');

  static const $core.List<CropCategory> values = <CropCategory>[
    CROP_CATEGORY_UNSPECIFIED,
    CROP_CATEGORY_FOOD_GRAIN,
    CROP_CATEGORY_OILSEED,
    CROP_CATEGORY_COMMERCIAL,
    CROP_CATEGORY_HORTICULTURE,
  ];

  static final $core.List<CropCategory?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static CropCategory? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CropCategory._(super.value, super.name);
}

/// QuoteConfidence is how much the yield history behind a quote supports it.
class QuoteConfidence extends $pb.ProtobufEnum {
  static const QuoteConfidence QUOTE_CONFIDENCE_UNSPECIFIED = QuoteConfidence._(
      0, _omitEnumNames ? '' : 'QUOTE_CONFIDENCE_UNSPECIFIED');

  /// Enough seasons of this field's own yields to estimate the risk from them.
  static const QuoteConfidence QUOTE_CONFIDENCE_FIELD_HISTORY =
      QuoteConfidence._(
          1, _omitEnumNames ? '' : 'QUOTE_CONFIDENCE_FIELD_HISTORY');

  /// Some history, but short enough that the estimate carries a large
  /// uncertainty loading, which the quote shows.
  static const QuoteConfidence QUOTE_CONFIDENCE_SHORT_HISTORY =
      QuoteConfidence._(
          2, _omitEnumNames ? '' : 'QUOTE_CONFIDENCE_SHORT_HISTORY');

  /// No usable history. The rate is a crop benchmark, not this field's risk,
  /// and the quote says so rather than presenting a benchmark as a measurement.
  static const QuoteConfidence QUOTE_CONFIDENCE_BENCHMARK_ONLY =
      QuoteConfidence._(
          3, _omitEnumNames ? '' : 'QUOTE_CONFIDENCE_BENCHMARK_ONLY');

  static const $core.List<QuoteConfidence> values = <QuoteConfidence>[
    QUOTE_CONFIDENCE_UNSPECIFIED,
    QUOTE_CONFIDENCE_FIELD_HISTORY,
    QUOTE_CONFIDENCE_SHORT_HISTORY,
    QUOTE_CONFIDENCE_BENCHMARK_ONLY,
  ];

  static final $core.List<QuoteConfidence?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static QuoteConfidence? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const QuoteConfidence._(super.value, super.name);
}

/// CreditBand is the coarse reading of a credit score.
class CreditBand extends $pb.ProtobufEnum {
  static const CreditBand CREDIT_BAND_UNSPECIFIED =
      CreditBand._(0, _omitEnumNames ? '' : 'CREDIT_BAND_UNSPECIFIED');
  static const CreditBand CREDIT_BAND_POOR =
      CreditBand._(1, _omitEnumNames ? '' : 'CREDIT_BAND_POOR');
  static const CreditBand CREDIT_BAND_FAIR =
      CreditBand._(2, _omitEnumNames ? '' : 'CREDIT_BAND_FAIR');
  static const CreditBand CREDIT_BAND_GOOD =
      CreditBand._(3, _omitEnumNames ? '' : 'CREDIT_BAND_GOOD');
  static const CreditBand CREDIT_BAND_EXCELLENT =
      CreditBand._(4, _omitEnumNames ? '' : 'CREDIT_BAND_EXCELLENT');

  static const $core.List<CreditBand> values = <CreditBand>[
    CREDIT_BAND_UNSPECIFIED,
    CREDIT_BAND_POOR,
    CREDIT_BAND_FAIR,
    CREDIT_BAND_GOOD,
    CREDIT_BAND_EXCELLENT,
  ];

  static final $core.List<CreditBand?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static CreditBand? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CreditBand._(super.value, super.name);
}

/// ScoreStatus says whether a score could be produced at all.
class ScoreStatus extends $pb.ProtobufEnum {
  static const ScoreStatus SCORE_STATUS_UNSPECIFIED =
      ScoreStatus._(0, _omitEnumNames ? '' : 'SCORE_STATUS_UNSPECIFIED');
  static const ScoreStatus SCORE_STATUS_SCORED =
      ScoreStatus._(1, _omitEnumNames ? '' : 'SCORE_STATUS_SCORED');

  /// Too few seasons to say anything. Deliberately not a low score: a thin
  /// file is not a bad file, and a farmer with one harvest on record must not
  /// be handed a number that reads like a default history.
  static const ScoreStatus SCORE_STATUS_INSUFFICIENT_HISTORY = ScoreStatus._(
      2, _omitEnumNames ? '' : 'SCORE_STATUS_INSUFFICIENT_HISTORY');

  static const $core.List<ScoreStatus> values = <ScoreStatus>[
    SCORE_STATUS_UNSPECIFIED,
    SCORE_STATUS_SCORED,
    SCORE_STATUS_INSUFFICIENT_HISTORY,
  ];

  static final $core.List<ScoreStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static ScoreStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ScoreStatus._(super.value, super.name);
}

/// LossCause is what the claimant says damaged the crop.
class LossCause extends $pb.ProtobufEnum {
  static const LossCause LOSS_CAUSE_UNSPECIFIED =
      LossCause._(0, _omitEnumNames ? '' : 'LOSS_CAUSE_UNSPECIFIED');
  static const LossCause LOSS_CAUSE_DROUGHT =
      LossCause._(1, _omitEnumNames ? '' : 'LOSS_CAUSE_DROUGHT');
  static const LossCause LOSS_CAUSE_FLOOD =
      LossCause._(2, _omitEnumNames ? '' : 'LOSS_CAUSE_FLOOD');
  static const LossCause LOSS_CAUSE_UNSEASONAL_RAIN =
      LossCause._(3, _omitEnumNames ? '' : 'LOSS_CAUSE_UNSEASONAL_RAIN');
  static const LossCause LOSS_CAUSE_HAIL =
      LossCause._(4, _omitEnumNames ? '' : 'LOSS_CAUSE_HAIL');
  static const LossCause LOSS_CAUSE_CYCLONE =
      LossCause._(5, _omitEnumNames ? '' : 'LOSS_CAUSE_CYCLONE');
  static const LossCause LOSS_CAUSE_PEST =
      LossCause._(6, _omitEnumNames ? '' : 'LOSS_CAUSE_PEST');
  static const LossCause LOSS_CAUSE_DISEASE =
      LossCause._(7, _omitEnumNames ? '' : 'LOSS_CAUSE_DISEASE');
  static const LossCause LOSS_CAUSE_FIRE =
      LossCause._(8, _omitEnumNames ? '' : 'LOSS_CAUSE_FIRE');

  static const $core.List<LossCause> values = <LossCause>[
    LOSS_CAUSE_UNSPECIFIED,
    LOSS_CAUSE_DROUGHT,
    LOSS_CAUSE_FLOOD,
    LOSS_CAUSE_UNSEASONAL_RAIN,
    LOSS_CAUSE_HAIL,
    LOSS_CAUSE_CYCLONE,
    LOSS_CAUSE_PEST,
    LOSS_CAUSE_DISEASE,
    LOSS_CAUSE_FIRE,
  ];

  static final $core.List<LossCause?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static LossCause? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const LossCause._(super.value, super.name);
}

/// ClaimStatus is where a claim has got to.
class ClaimStatus extends $pb.ProtobufEnum {
  static const ClaimStatus CLAIM_STATUS_UNSPECIFIED =
      ClaimStatus._(0, _omitEnumNames ? '' : 'CLAIM_STATUS_UNSPECIFIED');
  static const ClaimStatus CLAIM_STATUS_DRAFT =
      ClaimStatus._(1, _omitEnumNames ? '' : 'CLAIM_STATUS_DRAFT');
  static const ClaimStatus CLAIM_STATUS_SUBMITTED =
      ClaimStatus._(2, _omitEnumNames ? '' : 'CLAIM_STATUS_SUBMITTED');

  /// Evidence has been gathered and the pack is ready for the insurer.
  static const ClaimStatus CLAIM_STATUS_EVIDENCE_READY =
      ClaimStatus._(3, _omitEnumNames ? '' : 'CLAIM_STATUS_EVIDENCE_READY');

  /// The insurer has decided. This service never sets these itself.
  static const ClaimStatus CLAIM_STATUS_SETTLED =
      ClaimStatus._(4, _omitEnumNames ? '' : 'CLAIM_STATUS_SETTLED');
  static const ClaimStatus CLAIM_STATUS_REJECTED =
      ClaimStatus._(5, _omitEnumNames ? '' : 'CLAIM_STATUS_REJECTED');
  static const ClaimStatus CLAIM_STATUS_WITHDRAWN =
      ClaimStatus._(6, _omitEnumNames ? '' : 'CLAIM_STATUS_WITHDRAWN');

  static const $core.List<ClaimStatus> values = <ClaimStatus>[
    CLAIM_STATUS_UNSPECIFIED,
    CLAIM_STATUS_DRAFT,
    CLAIM_STATUS_SUBMITTED,
    CLAIM_STATUS_EVIDENCE_READY,
    CLAIM_STATUS_SETTLED,
    CLAIM_STATUS_REJECTED,
    CLAIM_STATUS_WITHDRAWN,
  ];

  static final $core.List<ClaimStatus?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 6);
  static ClaimStatus? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const ClaimStatus._(super.value, super.name);
}

/// EvidenceSource is where a piece of evidence came from.
class EvidenceSource extends $pb.ProtobufEnum {
  static const EvidenceSource EVIDENCE_SOURCE_UNSPECIFIED =
      EvidenceSource._(0, _omitEnumNames ? '' : 'EVIDENCE_SOURCE_UNSPECIFIED');
  static const EvidenceSource EVIDENCE_SOURCE_SATELLITE_NDVI = EvidenceSource._(
      1, _omitEnumNames ? '' : 'EVIDENCE_SOURCE_SATELLITE_NDVI');
  static const EvidenceSource EVIDENCE_SOURCE_WEATHER =
      EvidenceSource._(2, _omitEnumNames ? '' : 'EVIDENCE_SOURCE_WEATHER');
  static const EvidenceSource EVIDENCE_SOURCE_FIELD_INSPECTION =
      EvidenceSource._(
          3, _omitEnumNames ? '' : 'EVIDENCE_SOURCE_FIELD_INSPECTION');
  static const EvidenceSource EVIDENCE_SOURCE_YIELD_RECORD =
      EvidenceSource._(4, _omitEnumNames ? '' : 'EVIDENCE_SOURCE_YIELD_RECORD');
  static const EvidenceSource EVIDENCE_SOURCE_PHOTO =
      EvidenceSource._(5, _omitEnumNames ? '' : 'EVIDENCE_SOURCE_PHOTO');

  static const $core.List<EvidenceSource> values = <EvidenceSource>[
    EVIDENCE_SOURCE_UNSPECIFIED,
    EVIDENCE_SOURCE_SATELLITE_NDVI,
    EVIDENCE_SOURCE_WEATHER,
    EVIDENCE_SOURCE_FIELD_INSPECTION,
    EVIDENCE_SOURCE_YIELD_RECORD,
    EVIDENCE_SOURCE_PHOTO,
  ];

  static final $core.List<EvidenceSource?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 5);
  static EvidenceSource? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EvidenceSource._(super.value, super.name);
}

/// EvidenceVerdict is what one piece of evidence says about the claim.
///
/// Three values, not two. "Cannot be determined" is a real answer and the most
/// common one — a cloudy fortnight over a monsoon flood leaves no usable
/// satellite image, and treating that silence as "inconsistent" would deny a
/// claim on the strength of the weather over the satellite.
class EvidenceVerdict extends $pb.ProtobufEnum {
  static const EvidenceVerdict EVIDENCE_VERDICT_UNSPECIFIED = EvidenceVerdict._(
      0, _omitEnumNames ? '' : 'EVIDENCE_VERDICT_UNSPECIFIED');
  static const EvidenceVerdict EVIDENCE_VERDICT_SUPPORTS =
      EvidenceVerdict._(1, _omitEnumNames ? '' : 'EVIDENCE_VERDICT_SUPPORTS');
  static const EvidenceVerdict EVIDENCE_VERDICT_CONTRADICTS = EvidenceVerdict._(
      2, _omitEnumNames ? '' : 'EVIDENCE_VERDICT_CONTRADICTS');
  static const EvidenceVerdict EVIDENCE_VERDICT_INCONCLUSIVE =
      EvidenceVerdict._(
          3, _omitEnumNames ? '' : 'EVIDENCE_VERDICT_INCONCLUSIVE');

  static const $core.List<EvidenceVerdict> values = <EvidenceVerdict>[
    EVIDENCE_VERDICT_UNSPECIFIED,
    EVIDENCE_VERDICT_SUPPORTS,
    EVIDENCE_VERDICT_CONTRADICTS,
    EVIDENCE_VERDICT_INCONCLUSIVE,
  ];

  static final $core.List<EvidenceVerdict?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static EvidenceVerdict? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const EvidenceVerdict._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
