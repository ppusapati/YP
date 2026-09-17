// This is a generated file - do not edit.
//
// Generated from assistant.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Locale is the set of languages the platform already ships.
///
/// Closed enum rather than a free string. An advisory answered in a language
/// nobody asked for is worse than one that says it cannot answer in that
/// language, and a string field would let a typo through as "a language we
/// apparently support".
class Locale extends $pb.ProtobufEnum {
  static const Locale LOCALE_UNSPECIFIED =
      Locale._(0, _omitEnumNames ? '' : 'LOCALE_UNSPECIFIED');
  static const Locale LOCALE_EN =
      Locale._(1, _omitEnumNames ? '' : 'LOCALE_EN');
  static const Locale LOCALE_HI =
      Locale._(2, _omitEnumNames ? '' : 'LOCALE_HI');
  static const Locale LOCALE_MR =
      Locale._(3, _omitEnumNames ? '' : 'LOCALE_MR');
  static const Locale LOCALE_TE =
      Locale._(4, _omitEnumNames ? '' : 'LOCALE_TE');
  static const Locale LOCALE_TA =
      Locale._(5, _omitEnumNames ? '' : 'LOCALE_TA');
  static const Locale LOCALE_KN =
      Locale._(6, _omitEnumNames ? '' : 'LOCALE_KN');
  static const Locale LOCALE_PA =
      Locale._(7, _omitEnumNames ? '' : 'LOCALE_PA');
  static const Locale LOCALE_BN =
      Locale._(8, _omitEnumNames ? '' : 'LOCALE_BN');

  static const $core.List<Locale> values = <Locale>[
    LOCALE_UNSPECIFIED,
    LOCALE_EN,
    LOCALE_HI,
    LOCALE_MR,
    LOCALE_TE,
    LOCALE_TA,
    LOCALE_KN,
    LOCALE_PA,
    LOCALE_BN,
  ];

  static final $core.List<Locale?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 8);
  static Locale? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Locale._(super.value, super.name);
}

/// CitationKind says what a citation points at.
///
/// The distinction is not cosmetic: a document citation opens a reference page,
/// and a record citation deep-links into the tenant's own data. A farmer being
/// told "your field's soil test says" should be able to press it and see the
/// soil test.
class CitationKind extends $pb.ProtobufEnum {
  static const CitationKind CITATION_KIND_UNSPECIFIED =
      CitationKind._(0, _omitEnumNames ? '' : 'CITATION_KIND_UNSPECIFIED');

  /// A chunk of agronomy reference material, crop guide or regional advisory.
  static const CitationKind CITATION_KIND_DOCUMENT =
      CitationKind._(1, _omitEnumNames ? '' : 'CITATION_KIND_DOCUMENT');
  static const CitationKind CITATION_KIND_FIELD =
      CitationKind._(2, _omitEnumNames ? '' : 'CITATION_KIND_FIELD');
  static const CitationKind CITATION_KIND_PRESCRIPTION =
      CitationKind._(3, _omitEnumNames ? '' : 'CITATION_KIND_PRESCRIPTION');
  static const CitationKind CITATION_KIND_ALERT =
      CitationKind._(4, _omitEnumNames ? '' : 'CITATION_KIND_ALERT');
  static const CitationKind CITATION_KIND_WEATHER =
      CitationKind._(5, _omitEnumNames ? '' : 'CITATION_KIND_WEATHER');
  static const CitationKind CITATION_KIND_DIAGNOSIS =
      CitationKind._(6, _omitEnumNames ? '' : 'CITATION_KIND_DIAGNOSIS');
  static const CitationKind CITATION_KIND_YIELD_FORECAST =
      CitationKind._(7, _omitEnumNames ? '' : 'CITATION_KIND_YIELD_FORECAST');
  static const CitationKind CITATION_KIND_IRRIGATION =
      CitationKind._(8, _omitEnumNames ? '' : 'CITATION_KIND_IRRIGATION');
  static const CitationKind CITATION_KIND_PEST_RISK =
      CitationKind._(9, _omitEnumNames ? '' : 'CITATION_KIND_PEST_RISK');
  static const CitationKind CITATION_KIND_SOIL =
      CitationKind._(10, _omitEnumNames ? '' : 'CITATION_KIND_SOIL');

  static const $core.List<CitationKind> values = <CitationKind>[
    CITATION_KIND_UNSPECIFIED,
    CITATION_KIND_DOCUMENT,
    CITATION_KIND_FIELD,
    CITATION_KIND_PRESCRIPTION,
    CITATION_KIND_ALERT,
    CITATION_KIND_WEATHER,
    CITATION_KIND_DIAGNOSIS,
    CITATION_KIND_YIELD_FORECAST,
    CITATION_KIND_IRRIGATION,
    CITATION_KIND_PEST_RISK,
    CITATION_KIND_SOIL,
  ];

  static final $core.List<CitationKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 10);
  static CitationKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CitationKind._(super.value, super.name);
}

/// AnswerKind is how the answer was produced.
///
/// Kept on every exchange because a sentence assembled from a retrieved
/// paragraph and a sentence written by a language model are not the same claim,
/// and a UI that renders them identically is lying by omission. A deployment
/// with no model configured still answers — extractively — and says so.
class AnswerKind extends $pb.ProtobufEnum {
  static const AnswerKind ANSWER_KIND_UNSPECIFIED =
      AnswerKind._(0, _omitEnumNames ? '' : 'ANSWER_KIND_UNSPECIFIED');

  /// A language model wrote it, grounded on the context below.
  static const AnswerKind ANSWER_KIND_GENERATED =
      AnswerKind._(1, _omitEnumNames ? '' : 'ANSWER_KIND_GENERATED');

  /// Assembled from the retrieved passages themselves. No model was called.
  static const AnswerKind ANSWER_KIND_EXTRACTIVE =
      AnswerKind._(2, _omitEnumNames ? '' : 'ANSWER_KIND_EXTRACTIVE');

  /// Nothing was found to ground an answer on, so none was given.
  static const AnswerKind ANSWER_KIND_REFUSED =
      AnswerKind._(3, _omitEnumNames ? '' : 'ANSWER_KIND_REFUSED');

  static const $core.List<AnswerKind> values = <AnswerKind>[
    ANSWER_KIND_UNSPECIFIED,
    ANSWER_KIND_GENERATED,
    ANSWER_KIND_EXTRACTIVE,
    ANSWER_KIND_REFUSED,
  ];

  static final $core.List<AnswerKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static AnswerKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AnswerKind._(super.value, super.name);
}

/// GroundednessVerdict is the evaluator's read on the answer.
class GroundednessVerdict extends $pb.ProtobufEnum {
  static const GroundednessVerdict GROUNDEDNESS_VERDICT_UNSPECIFIED =
      GroundednessVerdict._(
          0, _omitEnumNames ? '' : 'GROUNDEDNESS_VERDICT_UNSPECIFIED');
  static const GroundednessVerdict GROUNDEDNESS_VERDICT_GROUNDED =
      GroundednessVerdict._(
          1, _omitEnumNames ? '' : 'GROUNDEDNESS_VERDICT_GROUNDED');

  /// Some of it is supported and some of it is not.
  static const GroundednessVerdict GROUNDEDNESS_VERDICT_PARTIAL =
      GroundednessVerdict._(
          2, _omitEnumNames ? '' : 'GROUNDEDNESS_VERDICT_PARTIAL');
  static const GroundednessVerdict GROUNDEDNESS_VERDICT_UNGROUNDED =
      GroundednessVerdict._(
          3, _omitEnumNames ? '' : 'GROUNDEDNESS_VERDICT_UNGROUNDED');

  static const $core.List<GroundednessVerdict> values = <GroundednessVerdict>[
    GROUNDEDNESS_VERDICT_UNSPECIFIED,
    GROUNDEDNESS_VERDICT_GROUNDED,
    GROUNDEDNESS_VERDICT_PARTIAL,
    GROUNDEDNESS_VERDICT_UNGROUNDED,
  ];

  static final $core.List<GroundednessVerdict?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static GroundednessVerdict? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GroundednessVerdict._(super.value, super.name);
}

/// DocumentKind is what a piece of reference material is.
class DocumentKind extends $pb.ProtobufEnum {
  static const DocumentKind DOCUMENT_KIND_UNSPECIFIED =
      DocumentKind._(0, _omitEnumNames ? '' : 'DOCUMENT_KIND_UNSPECIFIED');
  static const DocumentKind DOCUMENT_KIND_AGRONOMY_REFERENCE = DocumentKind._(
      1, _omitEnumNames ? '' : 'DOCUMENT_KIND_AGRONOMY_REFERENCE');
  static const DocumentKind DOCUMENT_KIND_CROP_GUIDE =
      DocumentKind._(2, _omitEnumNames ? '' : 'DOCUMENT_KIND_CROP_GUIDE');
  static const DocumentKind DOCUMENT_KIND_REGIONAL_ADVISORY = DocumentKind._(
      3, _omitEnumNames ? '' : 'DOCUMENT_KIND_REGIONAL_ADVISORY');
  static const DocumentKind DOCUMENT_KIND_PACKAGE_OF_PRACTICES = DocumentKind._(
      4, _omitEnumNames ? '' : 'DOCUMENT_KIND_PACKAGE_OF_PRACTICES');

  static const $core.List<DocumentKind> values = <DocumentKind>[
    DOCUMENT_KIND_UNSPECIFIED,
    DOCUMENT_KIND_AGRONOMY_REFERENCE,
    DOCUMENT_KIND_CROP_GUIDE,
    DOCUMENT_KIND_REGIONAL_ADVISORY,
    DOCUMENT_KIND_PACKAGE_OF_PRACTICES,
  ];

  static final $core.List<DocumentKind?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static DocumentKind? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DocumentKind._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
