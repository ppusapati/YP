// This is a generated file - do not edit.
//
// Generated from assistant.proto.

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

import 'assistant.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'assistant.pbenum.dart';

/// Citation is one thing the answer is allowed to lean on.
class Citation extends $pb.GeneratedMessage {
  factory Citation({
    $core.String? id,
    CitationKind? kind,
    $core.String? title,
    $core.String? snippet,
    $core.String? uri,
    $core.String? sourceId,
    $core.double? score,
    $core.int? marker,
    Locale? locale,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (kind != null) result.kind = kind;
    if (title != null) result.title = title;
    if (snippet != null) result.snippet = snippet;
    if (uri != null) result.uri = uri;
    if (sourceId != null) result.sourceId = sourceId;
    if (score != null) result.score = score;
    if (marker != null) result.marker = marker;
    if (locale != null) result.locale = locale;
    return result;
  }

  Citation._();

  factory Citation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Citation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Citation',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aE<CitationKind>(2, _omitFieldNames ? '' : 'kind',
        enumValues: CitationKind.values)
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'snippet')
    ..aOS(5, _omitFieldNames ? '' : 'uri')
    ..aOS(6, _omitFieldNames ? '' : 'sourceId')
    ..aD(7, _omitFieldNames ? '' : 'score')
    ..aI(8, _omitFieldNames ? '' : 'marker')
    ..aE<Locale>(9, _omitFieldNames ? '' : 'locale', enumValues: Locale.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Citation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Citation copyWith(void Function(Citation) updates) =>
      super.copyWith((message) => updates(message as Citation)) as Citation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Citation create() => Citation._();
  @$core.override
  Citation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Citation getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Citation>(create);
  static Citation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  CitationKind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(CitationKind value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  /// The text that was actually put in front of the model, so a reviewer can
  /// check the answer against it rather than against the whole source.
  @$pb.TagNumber(4)
  $core.String get snippet => $_getSZ(3);
  @$pb.TagNumber(4)
  set snippet($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSnippet() => $_has(3);
  @$pb.TagNumber(4)
  void clearSnippet() => $_clearField(4);

  /// Where to send someone who presses it: an app route for a record, a URL for
  /// a document.
  @$pb.TagNumber(5)
  $core.String get uri => $_getSZ(4);
  @$pb.TagNumber(5)
  set uri($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUri() => $_has(4);
  @$pb.TagNumber(5)
  void clearUri() => $_clearField(5);

  /// The id of the underlying record or document.
  @$pb.TagNumber(6)
  $core.String get sourceId => $_getSZ(5);
  @$pb.TagNumber(6)
  set sourceId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSourceId() => $_has(5);
  @$pb.TagNumber(6)
  void clearSourceId() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get score => $_getN(6);
  @$pb.TagNumber(7)
  set score($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasScore() => $_has(6);
  @$pb.TagNumber(7)
  void clearScore() => $_clearField(7);

  /// The bracketed number the answer refers to, 1-based.
  @$pb.TagNumber(8)
  $core.int get marker => $_getIZ(7);
  @$pb.TagNumber(8)
  set marker($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMarker() => $_has(7);
  @$pb.TagNumber(8)
  void clearMarker() => $_clearField(8);

  /// The language the cited material is in. An answer in Marathi grounded on an
  /// English crop guide is normal, and worth showing.
  @$pb.TagNumber(9)
  Locale get locale => $_getN(8);
  @$pb.TagNumber(9)
  set locale(Locale value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasLocale() => $_has(8);
  @$pb.TagNumber(9)
  void clearLocale() => $_clearField(9);
}

/// ToolCall records one call the assistant made into another service.
///
/// Stored with arguments and result, not just a name. "Called yield forecast"
/// is unauditable; "called yield forecast with this field and this crop and got
/// 4.1 t/ha" can be checked against the service that answered.
class ToolCall extends $pb.GeneratedMessage {
  factory ToolCall({
    $core.String? name,
    $core.String? argumentsJson,
    $core.String? resultJson,
    $core.bool? ok,
    $core.String? error,
    $fixnum.Int64? latencyMs,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (argumentsJson != null) result.argumentsJson = argumentsJson;
    if (resultJson != null) result.resultJson = resultJson;
    if (ok != null) result.ok = ok;
    if (error != null) result.error = error;
    if (latencyMs != null) result.latencyMs = latencyMs;
    return result;
  }

  ToolCall._();

  factory ToolCall.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ToolCall.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ToolCall',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'argumentsJson')
    ..aOS(3, _omitFieldNames ? '' : 'resultJson')
    ..aOB(4, _omitFieldNames ? '' : 'ok')
    ..aOS(5, _omitFieldNames ? '' : 'error')
    ..aInt64(6, _omitFieldNames ? '' : 'latencyMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ToolCall clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ToolCall copyWith(void Function(ToolCall) updates) =>
      super.copyWith((message) => updates(message as ToolCall)) as ToolCall;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ToolCall create() => ToolCall._();
  @$core.override
  ToolCall createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ToolCall getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ToolCall>(create);
  static ToolCall? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get argumentsJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set argumentsJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasArgumentsJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearArgumentsJson() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get resultJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set resultJson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasResultJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearResultJson() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get ok => $_getBF(3);
  @$pb.TagNumber(4)
  set ok($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOk() => $_has(3);
  @$pb.TagNumber(4)
  void clearOk() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get error => $_getSZ(4);
  @$pb.TagNumber(5)
  set error($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasError() => $_has(4);
  @$pb.TagNumber(5)
  void clearError() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get latencyMs => $_getI64(5);
  @$pb.TagNumber(6)
  set latencyMs($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLatencyMs() => $_has(5);
  @$pb.TagNumber(6)
  void clearLatencyMs() => $_clearField(6);
}

/// UnsupportedClaim is a sentence the evaluator could not tie to the context.
class UnsupportedClaim extends $pb.GeneratedMessage {
  factory UnsupportedClaim({
    $core.String? text,
    $core.String? reason,
  }) {
    final result = create();
    if (text != null) result.text = text;
    if (reason != null) result.reason = reason;
    return result;
  }

  UnsupportedClaim._();

  factory UnsupportedClaim.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnsupportedClaim.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnsupportedClaim',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aOS(2, _omitFieldNames ? '' : 'reason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnsupportedClaim clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnsupportedClaim copyWith(void Function(UnsupportedClaim) updates) =>
      super.copyWith((message) => updates(message as UnsupportedClaim))
          as UnsupportedClaim;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnsupportedClaim create() => UnsupportedClaim._();
  @$core.override
  UnsupportedClaim createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnsupportedClaim getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnsupportedClaim>(create);
  static UnsupportedClaim? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reason => $_getSZ(1);
  @$pb.TagNumber(2)
  set reason($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReason() => $_has(1);
  @$pb.TagNumber(2)
  void clearReason() => $_clearField(2);
}

/// Evaluation is the automated check that runs on every answer before it is
/// returned.
class Evaluation extends $pb.GeneratedMessage {
  factory Evaluation({
    GroundednessVerdict? verdict,
    $core.double? groundedness,
    $core.Iterable<UnsupportedClaim>? unsupported,
    $core.Iterable<$core.String>? unsupportedNumbers,
    $core.bool? needsReview,
    $core.String? notes,
  }) {
    final result = create();
    if (verdict != null) result.verdict = verdict;
    if (groundedness != null) result.groundedness = groundedness;
    if (unsupported != null) result.unsupported.addAll(unsupported);
    if (unsupportedNumbers != null)
      result.unsupportedNumbers.addAll(unsupportedNumbers);
    if (needsReview != null) result.needsReview = needsReview;
    if (notes != null) result.notes = notes;
    return result;
  }

  Evaluation._();

  factory Evaluation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Evaluation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Evaluation',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aE<GroundednessVerdict>(1, _omitFieldNames ? '' : 'verdict',
        enumValues: GroundednessVerdict.values)
    ..aD(2, _omitFieldNames ? '' : 'groundedness')
    ..pPM<UnsupportedClaim>(3, _omitFieldNames ? '' : 'unsupported',
        subBuilder: UnsupportedClaim.create)
    ..pPS(4, _omitFieldNames ? '' : 'unsupportedNumbers')
    ..aOB(5, _omitFieldNames ? '' : 'needsReview')
    ..aOS(6, _omitFieldNames ? '' : 'notes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Evaluation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Evaluation copyWith(void Function(Evaluation) updates) =>
      super.copyWith((message) => updates(message as Evaluation)) as Evaluation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Evaluation create() => Evaluation._();
  @$core.override
  Evaluation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Evaluation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Evaluation>(create);
  static Evaluation? _defaultInstance;

  @$pb.TagNumber(1)
  GroundednessVerdict get verdict => $_getN(0);
  @$pb.TagNumber(1)
  set verdict(GroundednessVerdict value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasVerdict() => $_has(0);
  @$pb.TagNumber(1)
  void clearVerdict() => $_clearField(1);

  /// Share of the answer's sentences that are supported by the context, 0..1.
  @$pb.TagNumber(2)
  $core.double get groundedness => $_getN(1);
  @$pb.TagNumber(2)
  set groundedness($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGroundedness() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroundedness() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<UnsupportedClaim> get unsupported => $_getList(2);

  /// Quantities that appear in the answer and nowhere in the context. Separated
  /// from prose because a fabricated dose rate is the failure that costs a
  /// farmer money, and it hides inside an otherwise well-supported sentence.
  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get unsupportedNumbers => $_getList(3);

  /// True when a human should look at this exchange.
  @$pb.TagNumber(5)
  $core.bool get needsReview => $_getBF(4);
  @$pb.TagNumber(5)
  set needsReview($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNeedsReview() => $_has(4);
  @$pb.TagNumber(5)
  void clearNeedsReview() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get notes => $_getSZ(5);
  @$pb.TagNumber(6)
  set notes($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNotes() => $_has(5);
  @$pb.TagNumber(6)
  void clearNotes() => $_clearField(6);
}

/// Usage is what one exchange cost.
class Usage extends $pb.GeneratedMessage {
  factory Usage({
    $core.int? promptTokens,
    $core.int? completionTokens,
    $fixnum.Int64? latencyMs,
    $fixnum.Int64? costMicros,
    $core.String? model,
  }) {
    final result = create();
    if (promptTokens != null) result.promptTokens = promptTokens;
    if (completionTokens != null) result.completionTokens = completionTokens;
    if (latencyMs != null) result.latencyMs = latencyMs;
    if (costMicros != null) result.costMicros = costMicros;
    if (model != null) result.model = model;
    return result;
  }

  Usage._();

  factory Usage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Usage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Usage',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'promptTokens')
    ..aI(2, _omitFieldNames ? '' : 'completionTokens')
    ..aInt64(3, _omitFieldNames ? '' : 'latencyMs')
    ..aInt64(4, _omitFieldNames ? '' : 'costMicros')
    ..aOS(5, _omitFieldNames ? '' : 'model')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Usage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Usage copyWith(void Function(Usage) updates) =>
      super.copyWith((message) => updates(message as Usage)) as Usage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Usage create() => Usage._();
  @$core.override
  Usage createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Usage getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Usage>(create);
  static Usage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get promptTokens => $_getIZ(0);
  @$pb.TagNumber(1)
  set promptTokens($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPromptTokens() => $_has(0);
  @$pb.TagNumber(1)
  void clearPromptTokens() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get completionTokens => $_getIZ(1);
  @$pb.TagNumber(2)
  set completionTokens($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCompletionTokens() => $_has(1);
  @$pb.TagNumber(2)
  void clearCompletionTokens() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get latencyMs => $_getI64(2);
  @$pb.TagNumber(3)
  set latencyMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLatencyMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearLatencyMs() => $_clearField(3);

  /// Cost in millionths of the billing currency unit. Integer because summing
  /// floats across a month of exchanges and comparing against a budget is how a
  /// budget silently stops being enforced.
  @$pb.TagNumber(4)
  $fixnum.Int64 get costMicros => $_getI64(3);
  @$pb.TagNumber(4)
  set costMicros($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCostMicros() => $_has(3);
  @$pb.TagNumber(4)
  void clearCostMicros() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get model => $_getSZ(4);
  @$pb.TagNumber(5)
  set model($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasModel() => $_has(4);
  @$pb.TagNumber(5)
  void clearModel() => $_clearField(5);
}

/// Exchange is one question and its answer.
class Exchange extends $pb.GeneratedMessage {
  factory Exchange({
    $core.String? id,
    $core.String? conversationId,
    $core.String? question,
    $core.String? answer,
    Locale? locale,
    AnswerKind? answerKind,
    $core.Iterable<Citation>? citations,
    $core.Iterable<ToolCall>? toolCalls,
    Evaluation? evaluation,
    Usage? usage,
    $core.String? askedBy,
    $0.Timestamp? createdAt,
    $core.bool? reviewed,
    $core.String? reviewerNote,
    $core.int? rating,
    $core.String? reviewedBy,
    $0.Timestamp? reviewedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (conversationId != null) result.conversationId = conversationId;
    if (question != null) result.question = question;
    if (answer != null) result.answer = answer;
    if (locale != null) result.locale = locale;
    if (answerKind != null) result.answerKind = answerKind;
    if (citations != null) result.citations.addAll(citations);
    if (toolCalls != null) result.toolCalls.addAll(toolCalls);
    if (evaluation != null) result.evaluation = evaluation;
    if (usage != null) result.usage = usage;
    if (askedBy != null) result.askedBy = askedBy;
    if (createdAt != null) result.createdAt = createdAt;
    if (reviewed != null) result.reviewed = reviewed;
    if (reviewerNote != null) result.reviewerNote = reviewerNote;
    if (rating != null) result.rating = rating;
    if (reviewedBy != null) result.reviewedBy = reviewedBy;
    if (reviewedAt != null) result.reviewedAt = reviewedAt;
    return result;
  }

  Exchange._();

  factory Exchange.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Exchange.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Exchange',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'conversationId')
    ..aOS(3, _omitFieldNames ? '' : 'question')
    ..aOS(4, _omitFieldNames ? '' : 'answer')
    ..aE<Locale>(5, _omitFieldNames ? '' : 'locale', enumValues: Locale.values)
    ..aE<AnswerKind>(6, _omitFieldNames ? '' : 'answerKind',
        enumValues: AnswerKind.values)
    ..pPM<Citation>(7, _omitFieldNames ? '' : 'citations',
        subBuilder: Citation.create)
    ..pPM<ToolCall>(8, _omitFieldNames ? '' : 'toolCalls',
        subBuilder: ToolCall.create)
    ..aOM<Evaluation>(9, _omitFieldNames ? '' : 'evaluation',
        subBuilder: Evaluation.create)
    ..aOM<Usage>(10, _omitFieldNames ? '' : 'usage', subBuilder: Usage.create)
    ..aOS(11, _omitFieldNames ? '' : 'askedBy')
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOB(13, _omitFieldNames ? '' : 'reviewed')
    ..aOS(14, _omitFieldNames ? '' : 'reviewerNote')
    ..aI(15, _omitFieldNames ? '' : 'rating')
    ..aOS(16, _omitFieldNames ? '' : 'reviewedBy')
    ..aOM<$0.Timestamp>(17, _omitFieldNames ? '' : 'reviewedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Exchange clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Exchange copyWith(void Function(Exchange) updates) =>
      super.copyWith((message) => updates(message as Exchange)) as Exchange;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Exchange create() => Exchange._();
  @$core.override
  Exchange createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Exchange getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Exchange>(create);
  static Exchange? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get conversationId => $_getSZ(1);
  @$pb.TagNumber(2)
  set conversationId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConversationId() => $_has(1);
  @$pb.TagNumber(2)
  void clearConversationId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get question => $_getSZ(2);
  @$pb.TagNumber(3)
  set question($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuestion() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuestion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get answer => $_getSZ(3);
  @$pb.TagNumber(4)
  set answer($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAnswer() => $_has(3);
  @$pb.TagNumber(4)
  void clearAnswer() => $_clearField(4);

  @$pb.TagNumber(5)
  Locale get locale => $_getN(4);
  @$pb.TagNumber(5)
  set locale(Locale value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLocale() => $_has(4);
  @$pb.TagNumber(5)
  void clearLocale() => $_clearField(5);

  @$pb.TagNumber(6)
  AnswerKind get answerKind => $_getN(5);
  @$pb.TagNumber(6)
  set answerKind(AnswerKind value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasAnswerKind() => $_has(5);
  @$pb.TagNumber(6)
  void clearAnswerKind() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<Citation> get citations => $_getList(6);

  @$pb.TagNumber(8)
  $pb.PbList<ToolCall> get toolCalls => $_getList(7);

  @$pb.TagNumber(9)
  Evaluation get evaluation => $_getN(8);
  @$pb.TagNumber(9)
  set evaluation(Evaluation value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasEvaluation() => $_has(8);
  @$pb.TagNumber(9)
  void clearEvaluation() => $_clearField(9);
  @$pb.TagNumber(9)
  Evaluation ensureEvaluation() => $_ensure(8);

  @$pb.TagNumber(10)
  Usage get usage => $_getN(9);
  @$pb.TagNumber(10)
  set usage(Usage value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasUsage() => $_has(9);
  @$pb.TagNumber(10)
  void clearUsage() => $_clearField(10);
  @$pb.TagNumber(10)
  Usage ensureUsage() => $_ensure(9);

  @$pb.TagNumber(11)
  $core.String get askedBy => $_getSZ(10);
  @$pb.TagNumber(11)
  set askedBy($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAskedBy() => $_has(10);
  @$pb.TagNumber(11)
  void clearAskedBy() => $_clearField(11);

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

  /// Human review, filled in later by an agronomist.
  @$pb.TagNumber(13)
  $core.bool get reviewed => $_getBF(12);
  @$pb.TagNumber(13)
  set reviewed($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasReviewed() => $_has(12);
  @$pb.TagNumber(13)
  void clearReviewed() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get reviewerNote => $_getSZ(13);
  @$pb.TagNumber(14)
  set reviewerNote($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasReviewerNote() => $_has(13);
  @$pb.TagNumber(14)
  void clearReviewerNote() => $_clearField(14);

  /// 1..5, 0 when unrated.
  @$pb.TagNumber(15)
  $core.int get rating => $_getIZ(14);
  @$pb.TagNumber(15)
  set rating($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasRating() => $_has(14);
  @$pb.TagNumber(15)
  void clearRating() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get reviewedBy => $_getSZ(15);
  @$pb.TagNumber(16)
  set reviewedBy($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasReviewedBy() => $_has(15);
  @$pb.TagNumber(16)
  void clearReviewedBy() => $_clearField(16);

  @$pb.TagNumber(17)
  $0.Timestamp get reviewedAt => $_getN(16);
  @$pb.TagNumber(17)
  set reviewedAt($0.Timestamp value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasReviewedAt() => $_has(16);
  @$pb.TagNumber(17)
  void clearReviewedAt() => $_clearField(17);
  @$pb.TagNumber(17)
  $0.Timestamp ensureReviewedAt() => $_ensure(16);
}

/// Conversation groups exchanges so follow-up questions have context.
class Conversation extends $pb.GeneratedMessage {
  factory Conversation({
    $core.String? id,
    $core.String? title,
    $core.String? fieldId,
    $core.String? farmId,
    Locale? locale,
    $0.Timestamp? createdAt,
    $0.Timestamp? updatedAt,
    $core.int? exchangeCount,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (title != null) result.title = title;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (locale != null) result.locale = locale;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (exchangeCount != null) result.exchangeCount = exchangeCount;
    return result;
  }

  Conversation._();

  factory Conversation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Conversation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Conversation',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'farmId')
    ..aE<Locale>(5, _omitFieldNames ? '' : 'locale', enumValues: Locale.values)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'updatedAt',
        subBuilder: $0.Timestamp.create)
    ..aI(8, _omitFieldNames ? '' : 'exchangeCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Conversation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Conversation copyWith(void Function(Conversation) updates) =>
      super.copyWith((message) => updates(message as Conversation))
          as Conversation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Conversation create() => Conversation._();
  @$core.override
  Conversation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Conversation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Conversation>(create);
  static Conversation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

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
  Locale get locale => $_getN(4);
  @$pb.TagNumber(5)
  set locale(Locale value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLocale() => $_has(4);
  @$pb.TagNumber(5)
  void clearLocale() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get createdAt => $_getN(5);
  @$pb.TagNumber(6)
  set createdAt($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureCreatedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Timestamp get updatedAt => $_getN(6);
  @$pb.TagNumber(7)
  set updatedAt($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasUpdatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearUpdatedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureUpdatedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.int get exchangeCount => $_getIZ(7);
  @$pb.TagNumber(8)
  set exchangeCount($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasExchangeCount() => $_has(7);
  @$pb.TagNumber(8)
  void clearExchangeCount() => $_clearField(8);
}

/// ReferenceDocument is one piece of indexed agronomy material.
class ReferenceDocument extends $pb.GeneratedMessage {
  factory ReferenceDocument({
    $core.String? id,
    $core.String? title,
    DocumentKind? kind,
    Locale? locale,
    $core.String? source,
    $core.String? uri,
    $core.Iterable<$core.String>? crops,
    $core.String? region,
    $core.int? chunkCount,
    $0.Timestamp? createdAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (title != null) result.title = title;
    if (kind != null) result.kind = kind;
    if (locale != null) result.locale = locale;
    if (source != null) result.source = source;
    if (uri != null) result.uri = uri;
    if (crops != null) result.crops.addAll(crops);
    if (region != null) result.region = region;
    if (chunkCount != null) result.chunkCount = chunkCount;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  ReferenceDocument._();

  factory ReferenceDocument.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReferenceDocument.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReferenceDocument',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aE<DocumentKind>(3, _omitFieldNames ? '' : 'kind',
        enumValues: DocumentKind.values)
    ..aE<Locale>(4, _omitFieldNames ? '' : 'locale', enumValues: Locale.values)
    ..aOS(5, _omitFieldNames ? '' : 'source')
    ..aOS(6, _omitFieldNames ? '' : 'uri')
    ..pPS(7, _omitFieldNames ? '' : 'crops')
    ..aOS(8, _omitFieldNames ? '' : 'region')
    ..aI(9, _omitFieldNames ? '' : 'chunkCount')
    ..aOM<$0.Timestamp>(10, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReferenceDocument clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReferenceDocument copyWith(void Function(ReferenceDocument) updates) =>
      super.copyWith((message) => updates(message as ReferenceDocument))
          as ReferenceDocument;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReferenceDocument create() => ReferenceDocument._();
  @$core.override
  ReferenceDocument createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReferenceDocument getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReferenceDocument>(create);
  static ReferenceDocument? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  DocumentKind get kind => $_getN(2);
  @$pb.TagNumber(3)
  set kind(DocumentKind value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasKind() => $_has(2);
  @$pb.TagNumber(3)
  void clearKind() => $_clearField(3);

  @$pb.TagNumber(4)
  Locale get locale => $_getN(3);
  @$pb.TagNumber(4)
  set locale(Locale value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLocale() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocale() => $_clearField(4);

  /// Who published it. Shown in the citation, because "ICAR package of
  /// practices" and "an unattributed PDF" carry different weight.
  @$pb.TagNumber(5)
  $core.String get source => $_getSZ(4);
  @$pb.TagNumber(5)
  set source($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSource() => $_has(4);
  @$pb.TagNumber(5)
  void clearSource() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get uri => $_getSZ(5);
  @$pb.TagNumber(6)
  set uri($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUri() => $_has(5);
  @$pb.TagNumber(6)
  void clearUri() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get crops => $_getList(6);

  /// Free-form region tag, e.g. a state or agro-climatic zone.
  @$pb.TagNumber(8)
  $core.String get region => $_getSZ(7);
  @$pb.TagNumber(8)
  set region($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasRegion() => $_has(7);
  @$pb.TagNumber(8)
  void clearRegion() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get chunkCount => $_getIZ(8);
  @$pb.TagNumber(9)
  set chunkCount($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasChunkCount() => $_has(8);
  @$pb.TagNumber(9)
  void clearChunkCount() => $_clearField(9);

  @$pb.TagNumber(10)
  $0.Timestamp get createdAt => $_getN(9);
  @$pb.TagNumber(10)
  set createdAt($0.Timestamp value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasCreatedAt() => $_has(9);
  @$pb.TagNumber(10)
  void clearCreatedAt() => $_clearField(10);
  @$pb.TagNumber(10)
  $0.Timestamp ensureCreatedAt() => $_ensure(9);
}

/// TenantBudget is the per-tenant ceiling on advisory spend.
class TenantBudget extends $pb.GeneratedMessage {
  factory TenantBudget({
    $core.String? tenantId,
    $fixnum.Int64? dailyCostMicros,
    $core.int? dailyQuestionLimit,
    $fixnum.Int64? requestLatencyBudgetMs,
    $fixnum.Int64? spentCostMicros,
    $core.int? spentQuestions,
    $core.bool? exhausted,
    $0.Timestamp? windowResetsAt,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    if (dailyCostMicros != null) result.dailyCostMicros = dailyCostMicros;
    if (dailyQuestionLimit != null)
      result.dailyQuestionLimit = dailyQuestionLimit;
    if (requestLatencyBudgetMs != null)
      result.requestLatencyBudgetMs = requestLatencyBudgetMs;
    if (spentCostMicros != null) result.spentCostMicros = spentCostMicros;
    if (spentQuestions != null) result.spentQuestions = spentQuestions;
    if (exhausted != null) result.exhausted = exhausted;
    if (windowResetsAt != null) result.windowResetsAt = windowResetsAt;
    return result;
  }

  TenantBudget._();

  factory TenantBudget.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TenantBudget.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TenantBudget',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aInt64(2, _omitFieldNames ? '' : 'dailyCostMicros')
    ..aI(3, _omitFieldNames ? '' : 'dailyQuestionLimit')
    ..aInt64(4, _omitFieldNames ? '' : 'requestLatencyBudgetMs')
    ..aInt64(5, _omitFieldNames ? '' : 'spentCostMicros')
    ..aI(6, _omitFieldNames ? '' : 'spentQuestions')
    ..aOB(7, _omitFieldNames ? '' : 'exhausted')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'windowResetsAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TenantBudget clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TenantBudget copyWith(void Function(TenantBudget) updates) =>
      super.copyWith((message) => updates(message as TenantBudget))
          as TenantBudget;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TenantBudget create() => TenantBudget._();
  @$core.override
  TenantBudget createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TenantBudget getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TenantBudget>(create);
  static TenantBudget? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => $_clearField(1);

  /// Zero means no ceiling is configured for that dimension.
  @$pb.TagNumber(2)
  $fixnum.Int64 get dailyCostMicros => $_getI64(1);
  @$pb.TagNumber(2)
  set dailyCostMicros($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDailyCostMicros() => $_has(1);
  @$pb.TagNumber(2)
  void clearDailyCostMicros() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get dailyQuestionLimit => $_getIZ(2);
  @$pb.TagNumber(3)
  set dailyQuestionLimit($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDailyQuestionLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearDailyQuestionLimit() => $_clearField(3);

  /// Per-request wall-clock ceiling. An advisory that takes ninety seconds has
  /// already failed the farmer standing in the field.
  @$pb.TagNumber(4)
  $fixnum.Int64 get requestLatencyBudgetMs => $_getI64(3);
  @$pb.TagNumber(4)
  set requestLatencyBudgetMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRequestLatencyBudgetMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearRequestLatencyBudgetMs() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get spentCostMicros => $_getI64(4);
  @$pb.TagNumber(5)
  set spentCostMicros($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSpentCostMicros() => $_has(4);
  @$pb.TagNumber(5)
  void clearSpentCostMicros() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get spentQuestions => $_getIZ(5);
  @$pb.TagNumber(6)
  set spentQuestions($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSpentQuestions() => $_has(5);
  @$pb.TagNumber(6)
  void clearSpentQuestions() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get exhausted => $_getBF(6);
  @$pb.TagNumber(7)
  set exhausted($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasExhausted() => $_has(6);
  @$pb.TagNumber(7)
  void clearExhausted() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get windowResetsAt => $_getN(7);
  @$pb.TagNumber(8)
  set windowResetsAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasWindowResetsAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearWindowResetsAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureWindowResetsAt() => $_ensure(7);
}

class AskRequest extends $pb.GeneratedMessage {
  factory AskRequest({
    $core.String? conversationId,
    $core.String? question,
    Locale? locale,
    $core.String? fieldId,
    $core.String? farmId,
    $core.bool? disableTools,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (question != null) result.question = question;
    if (locale != null) result.locale = locale;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (disableTools != null) result.disableTools = disableTools;
    return result;
  }

  AskRequest._();

  factory AskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AskRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOS(2, _omitFieldNames ? '' : 'question')
    ..aE<Locale>(3, _omitFieldNames ? '' : 'locale', enumValues: Locale.values)
    ..aOS(4, _omitFieldNames ? '' : 'fieldId')
    ..aOS(5, _omitFieldNames ? '' : 'farmId')
    ..aOB(6, _omitFieldNames ? '' : 'disableTools')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AskRequest copyWith(void Function(AskRequest) updates) =>
      super.copyWith((message) => updates(message as AskRequest)) as AskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AskRequest create() => AskRequest._();
  @$core.override
  AskRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AskRequest>(create);
  static AskRequest? _defaultInstance;

  /// Empty starts a new conversation.
  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get question => $_getSZ(1);
  @$pb.TagNumber(2)
  set question($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasQuestion() => $_has(1);
  @$pb.TagNumber(2)
  void clearQuestion() => $_clearField(2);

  @$pb.TagNumber(3)
  Locale get locale => $_getN(2);
  @$pb.TagNumber(3)
  set locale(Locale value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLocale() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocale() => $_clearField(3);

  /// Optional anchors. With a field id the assistant can look up that field's
  /// own weather, soil, prescriptions and diagnoses rather than answering in
  /// the abstract.
  @$pb.TagNumber(4)
  $core.String get fieldId => $_getSZ(3);
  @$pb.TagNumber(4)
  set fieldId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldId() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get farmId => $_getSZ(4);
  @$pb.TagNumber(5)
  set farmId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFarmId() => $_has(4);
  @$pb.TagNumber(5)
  void clearFarmId() => $_clearField(5);

  /// Opt *out* of tool use. Default-false so the useful behaviour is the
  /// default and a caller has to ask for the degraded one.
  @$pb.TagNumber(6)
  $core.bool get disableTools => $_getBF(5);
  @$pb.TagNumber(6)
  set disableTools($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDisableTools() => $_has(5);
  @$pb.TagNumber(6)
  void clearDisableTools() => $_clearField(6);
}

class AskResponse extends $pb.GeneratedMessage {
  factory AskResponse({
    $core.String? conversationId,
    Exchange? exchange,
    TenantBudget? budget,
  }) {
    final result = create();
    if (conversationId != null) result.conversationId = conversationId;
    if (exchange != null) result.exchange = exchange;
    if (budget != null) result.budget = budget;
    return result;
  }

  AskResponse._();

  factory AskResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AskResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AskResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'conversationId')
    ..aOM<Exchange>(2, _omitFieldNames ? '' : 'exchange',
        subBuilder: Exchange.create)
    ..aOM<TenantBudget>(3, _omitFieldNames ? '' : 'budget',
        subBuilder: TenantBudget.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AskResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AskResponse copyWith(void Function(AskResponse) updates) =>
      super.copyWith((message) => updates(message as AskResponse))
          as AskResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AskResponse create() => AskResponse._();
  @$core.override
  AskResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AskResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AskResponse>(create);
  static AskResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get conversationId => $_getSZ(0);
  @$pb.TagNumber(1)
  set conversationId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConversationId() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversationId() => $_clearField(1);

  @$pb.TagNumber(2)
  Exchange get exchange => $_getN(1);
  @$pb.TagNumber(2)
  set exchange(Exchange value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasExchange() => $_has(1);
  @$pb.TagNumber(2)
  void clearExchange() => $_clearField(2);
  @$pb.TagNumber(2)
  Exchange ensureExchange() => $_ensure(1);

  @$pb.TagNumber(3)
  TenantBudget get budget => $_getN(2);
  @$pb.TagNumber(3)
  set budget(TenantBudget value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBudget() => $_has(2);
  @$pb.TagNumber(3)
  void clearBudget() => $_clearField(3);
  @$pb.TagNumber(3)
  TenantBudget ensureBudget() => $_ensure(2);
}

class GetConversationRequest extends $pb.GeneratedMessage {
  factory GetConversationRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetConversationRequest._();

  factory GetConversationRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetConversationRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetConversationRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConversationRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConversationRequest copyWith(
          void Function(GetConversationRequest) updates) =>
      super.copyWith((message) => updates(message as GetConversationRequest))
          as GetConversationRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConversationRequest create() => GetConversationRequest._();
  @$core.override
  GetConversationRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetConversationRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetConversationRequest>(create);
  static GetConversationRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetConversationResponse extends $pb.GeneratedMessage {
  factory GetConversationResponse({
    Conversation? conversation,
    $core.Iterable<Exchange>? exchanges,
  }) {
    final result = create();
    if (conversation != null) result.conversation = conversation;
    if (exchanges != null) result.exchanges.addAll(exchanges);
    return result;
  }

  GetConversationResponse._();

  factory GetConversationResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetConversationResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetConversationResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOM<Conversation>(1, _omitFieldNames ? '' : 'conversation',
        subBuilder: Conversation.create)
    ..pPM<Exchange>(2, _omitFieldNames ? '' : 'exchanges',
        subBuilder: Exchange.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConversationResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetConversationResponse copyWith(
          void Function(GetConversationResponse) updates) =>
      super.copyWith((message) => updates(message as GetConversationResponse))
          as GetConversationResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetConversationResponse create() => GetConversationResponse._();
  @$core.override
  GetConversationResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetConversationResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetConversationResponse>(create);
  static GetConversationResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Conversation get conversation => $_getN(0);
  @$pb.TagNumber(1)
  set conversation(Conversation value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasConversation() => $_has(0);
  @$pb.TagNumber(1)
  void clearConversation() => $_clearField(1);
  @$pb.TagNumber(1)
  Conversation ensureConversation() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<Exchange> get exchanges => $_getList(1);
}

class ListConversationsRequest extends $pb.GeneratedMessage {
  factory ListConversationsRequest({
    $core.String? fieldId,
    $core.String? farmId,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListConversationsRequest._();

  factory ListConversationsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListConversationsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListConversationsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aI(3, _omitFieldNames ? '' : 'pageSize')
    ..aI(4, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConversationsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConversationsRequest copyWith(
          void Function(ListConversationsRequest) updates) =>
      super.copyWith((message) => updates(message as ListConversationsRequest))
          as ListConversationsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListConversationsRequest create() => ListConversationsRequest._();
  @$core.override
  ListConversationsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListConversationsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListConversationsRequest>(create);
  static ListConversationsRequest? _defaultInstance;

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
  $core.int get pageSize => $_getIZ(2);
  @$pb.TagNumber(3)
  set pageSize($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPageSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearPageSize() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pageOffset => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageOffset($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageOffset() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageOffset() => $_clearField(4);
}

class ListConversationsResponse extends $pb.GeneratedMessage {
  factory ListConversationsResponse({
    $core.Iterable<Conversation>? conversations,
    $core.int? totalCount,
  }) {
    final result = create();
    if (conversations != null) result.conversations.addAll(conversations);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListConversationsResponse._();

  factory ListConversationsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListConversationsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListConversationsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..pPM<Conversation>(1, _omitFieldNames ? '' : 'conversations',
        subBuilder: Conversation.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConversationsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListConversationsResponse copyWith(
          void Function(ListConversationsResponse) updates) =>
      super.copyWith((message) => updates(message as ListConversationsResponse))
          as ListConversationsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListConversationsResponse create() => ListConversationsResponse._();
  @$core.override
  ListConversationsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListConversationsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListConversationsResponse>(create);
  static ListConversationsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Conversation> get conversations => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class ListExchangesRequest extends $pb.GeneratedMessage {
  factory ListExchangesRequest({
    $core.bool? needsReviewOnly,
    $core.bool? unreviewedOnly,
    $core.String? conversationId,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (needsReviewOnly != null) result.needsReviewOnly = needsReviewOnly;
    if (unreviewedOnly != null) result.unreviewedOnly = unreviewedOnly;
    if (conversationId != null) result.conversationId = conversationId;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListExchangesRequest._();

  factory ListExchangesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListExchangesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListExchangesRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'needsReviewOnly')
    ..aOB(2, _omitFieldNames ? '' : 'unreviewedOnly')
    ..aOS(3, _omitFieldNames ? '' : 'conversationId')
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aI(5, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListExchangesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListExchangesRequest copyWith(void Function(ListExchangesRequest) updates) =>
      super.copyWith((message) => updates(message as ListExchangesRequest))
          as ListExchangesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListExchangesRequest create() => ListExchangesRequest._();
  @$core.override
  ListExchangesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListExchangesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListExchangesRequest>(create);
  static ListExchangesRequest? _defaultInstance;

  /// Review queue filters.
  @$pb.TagNumber(1)
  $core.bool get needsReviewOnly => $_getBF(0);
  @$pb.TagNumber(1)
  set needsReviewOnly($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNeedsReviewOnly() => $_has(0);
  @$pb.TagNumber(1)
  void clearNeedsReviewOnly() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get unreviewedOnly => $_getBF(1);
  @$pb.TagNumber(2)
  set unreviewedOnly($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUnreviewedOnly() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnreviewedOnly() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get conversationId => $_getSZ(2);
  @$pb.TagNumber(3)
  set conversationId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConversationId() => $_has(2);
  @$pb.TagNumber(3)
  void clearConversationId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pageSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageSize($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pageOffset => $_getIZ(4);
  @$pb.TagNumber(5)
  set pageOffset($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageOffset() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageOffset() => $_clearField(5);
}

class ListExchangesResponse extends $pb.GeneratedMessage {
  factory ListExchangesResponse({
    $core.Iterable<Exchange>? exchanges,
    $core.int? totalCount,
  }) {
    final result = create();
    if (exchanges != null) result.exchanges.addAll(exchanges);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListExchangesResponse._();

  factory ListExchangesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListExchangesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListExchangesResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..pPM<Exchange>(1, _omitFieldNames ? '' : 'exchanges',
        subBuilder: Exchange.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListExchangesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListExchangesResponse copyWith(
          void Function(ListExchangesResponse) updates) =>
      super.copyWith((message) => updates(message as ListExchangesResponse))
          as ListExchangesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListExchangesResponse create() => ListExchangesResponse._();
  @$core.override
  ListExchangesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListExchangesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListExchangesResponse>(create);
  static ListExchangesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Exchange> get exchanges => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class ReviewExchangeRequest extends $pb.GeneratedMessage {
  factory ReviewExchangeRequest({
    $core.String? exchangeId,
    $core.String? note,
    $core.int? rating,
  }) {
    final result = create();
    if (exchangeId != null) result.exchangeId = exchangeId;
    if (note != null) result.note = note;
    if (rating != null) result.rating = rating;
    return result;
  }

  ReviewExchangeRequest._();

  factory ReviewExchangeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReviewExchangeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReviewExchangeRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'exchangeId')
    ..aOS(2, _omitFieldNames ? '' : 'note')
    ..aI(3, _omitFieldNames ? '' : 'rating')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReviewExchangeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReviewExchangeRequest copyWith(
          void Function(ReviewExchangeRequest) updates) =>
      super.copyWith((message) => updates(message as ReviewExchangeRequest))
          as ReviewExchangeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReviewExchangeRequest create() => ReviewExchangeRequest._();
  @$core.override
  ReviewExchangeRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReviewExchangeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReviewExchangeRequest>(create);
  static ReviewExchangeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get exchangeId => $_getSZ(0);
  @$pb.TagNumber(1)
  set exchangeId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasExchangeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearExchangeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get note => $_getSZ(1);
  @$pb.TagNumber(2)
  set note($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNote() => $_has(1);
  @$pb.TagNumber(2)
  void clearNote() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get rating => $_getIZ(2);
  @$pb.TagNumber(3)
  set rating($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRating() => $_has(2);
  @$pb.TagNumber(3)
  void clearRating() => $_clearField(3);
}

class ReviewExchangeResponse extends $pb.GeneratedMessage {
  factory ReviewExchangeResponse({
    Exchange? exchange,
  }) {
    final result = create();
    if (exchange != null) result.exchange = exchange;
    return result;
  }

  ReviewExchangeResponse._();

  factory ReviewExchangeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReviewExchangeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReviewExchangeResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOM<Exchange>(1, _omitFieldNames ? '' : 'exchange',
        subBuilder: Exchange.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReviewExchangeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReviewExchangeResponse copyWith(
          void Function(ReviewExchangeResponse) updates) =>
      super.copyWith((message) => updates(message as ReviewExchangeResponse))
          as ReviewExchangeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReviewExchangeResponse create() => ReviewExchangeResponse._();
  @$core.override
  ReviewExchangeResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReviewExchangeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReviewExchangeResponse>(create);
  static ReviewExchangeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Exchange get exchange => $_getN(0);
  @$pb.TagNumber(1)
  set exchange(Exchange value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasExchange() => $_has(0);
  @$pb.TagNumber(1)
  void clearExchange() => $_clearField(1);
  @$pb.TagNumber(1)
  Exchange ensureExchange() => $_ensure(0);
}

class GetTenantBudgetRequest extends $pb.GeneratedMessage {
  factory GetTenantBudgetRequest() => create();

  GetTenantBudgetRequest._();

  factory GetTenantBudgetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTenantBudgetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTenantBudgetRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTenantBudgetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTenantBudgetRequest copyWith(
          void Function(GetTenantBudgetRequest) updates) =>
      super.copyWith((message) => updates(message as GetTenantBudgetRequest))
          as GetTenantBudgetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTenantBudgetRequest create() => GetTenantBudgetRequest._();
  @$core.override
  GetTenantBudgetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTenantBudgetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTenantBudgetRequest>(create);
  static GetTenantBudgetRequest? _defaultInstance;
}

class GetTenantBudgetResponse extends $pb.GeneratedMessage {
  factory GetTenantBudgetResponse({
    TenantBudget? budget,
  }) {
    final result = create();
    if (budget != null) result.budget = budget;
    return result;
  }

  GetTenantBudgetResponse._();

  factory GetTenantBudgetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTenantBudgetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTenantBudgetResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOM<TenantBudget>(1, _omitFieldNames ? '' : 'budget',
        subBuilder: TenantBudget.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTenantBudgetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTenantBudgetResponse copyWith(
          void Function(GetTenantBudgetResponse) updates) =>
      super.copyWith((message) => updates(message as GetTenantBudgetResponse))
          as GetTenantBudgetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTenantBudgetResponse create() => GetTenantBudgetResponse._();
  @$core.override
  GetTenantBudgetResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTenantBudgetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTenantBudgetResponse>(create);
  static GetTenantBudgetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TenantBudget get budget => $_getN(0);
  @$pb.TagNumber(1)
  set budget(TenantBudget value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBudget() => $_has(0);
  @$pb.TagNumber(1)
  void clearBudget() => $_clearField(1);
  @$pb.TagNumber(1)
  TenantBudget ensureBudget() => $_ensure(0);
}

class SetTenantBudgetRequest extends $pb.GeneratedMessage {
  factory SetTenantBudgetRequest({
    $fixnum.Int64? dailyCostMicros,
    $core.int? dailyQuestionLimit,
    $fixnum.Int64? requestLatencyBudgetMs,
  }) {
    final result = create();
    if (dailyCostMicros != null) result.dailyCostMicros = dailyCostMicros;
    if (dailyQuestionLimit != null)
      result.dailyQuestionLimit = dailyQuestionLimit;
    if (requestLatencyBudgetMs != null)
      result.requestLatencyBudgetMs = requestLatencyBudgetMs;
    return result;
  }

  SetTenantBudgetRequest._();

  factory SetTenantBudgetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetTenantBudgetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetTenantBudgetRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'dailyCostMicros')
    ..aI(2, _omitFieldNames ? '' : 'dailyQuestionLimit')
    ..aInt64(3, _omitFieldNames ? '' : 'requestLatencyBudgetMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTenantBudgetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTenantBudgetRequest copyWith(
          void Function(SetTenantBudgetRequest) updates) =>
      super.copyWith((message) => updates(message as SetTenantBudgetRequest))
          as SetTenantBudgetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetTenantBudgetRequest create() => SetTenantBudgetRequest._();
  @$core.override
  SetTenantBudgetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetTenantBudgetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetTenantBudgetRequest>(create);
  static SetTenantBudgetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get dailyCostMicros => $_getI64(0);
  @$pb.TagNumber(1)
  set dailyCostMicros($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDailyCostMicros() => $_has(0);
  @$pb.TagNumber(1)
  void clearDailyCostMicros() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get dailyQuestionLimit => $_getIZ(1);
  @$pb.TagNumber(2)
  set dailyQuestionLimit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDailyQuestionLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearDailyQuestionLimit() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get requestLatencyBudgetMs => $_getI64(2);
  @$pb.TagNumber(3)
  set requestLatencyBudgetMs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRequestLatencyBudgetMs() => $_has(2);
  @$pb.TagNumber(3)
  void clearRequestLatencyBudgetMs() => $_clearField(3);
}

class SetTenantBudgetResponse extends $pb.GeneratedMessage {
  factory SetTenantBudgetResponse({
    TenantBudget? budget,
  }) {
    final result = create();
    if (budget != null) result.budget = budget;
    return result;
  }

  SetTenantBudgetResponse._();

  factory SetTenantBudgetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SetTenantBudgetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SetTenantBudgetResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOM<TenantBudget>(1, _omitFieldNames ? '' : 'budget',
        subBuilder: TenantBudget.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTenantBudgetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTenantBudgetResponse copyWith(
          void Function(SetTenantBudgetResponse) updates) =>
      super.copyWith((message) => updates(message as SetTenantBudgetResponse))
          as SetTenantBudgetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetTenantBudgetResponse create() => SetTenantBudgetResponse._();
  @$core.override
  SetTenantBudgetResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SetTenantBudgetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetTenantBudgetResponse>(create);
  static SetTenantBudgetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TenantBudget get budget => $_getN(0);
  @$pb.TagNumber(1)
  set budget(TenantBudget value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBudget() => $_has(0);
  @$pb.TagNumber(1)
  void clearBudget() => $_clearField(1);
  @$pb.TagNumber(1)
  TenantBudget ensureBudget() => $_ensure(0);
}

class IngestDocumentRequest extends $pb.GeneratedMessage {
  factory IngestDocumentRequest({
    $core.String? title,
    DocumentKind? kind,
    Locale? locale,
    $core.String? source,
    $core.String? uri,
    $core.Iterable<$core.String>? crops,
    $core.String? region,
    $core.String? text,
  }) {
    final result = create();
    if (title != null) result.title = title;
    if (kind != null) result.kind = kind;
    if (locale != null) result.locale = locale;
    if (source != null) result.source = source;
    if (uri != null) result.uri = uri;
    if (crops != null) result.crops.addAll(crops);
    if (region != null) result.region = region;
    if (text != null) result.text = text;
    return result;
  }

  IngestDocumentRequest._();

  factory IngestDocumentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IngestDocumentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IngestDocumentRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aE<DocumentKind>(2, _omitFieldNames ? '' : 'kind',
        enumValues: DocumentKind.values)
    ..aE<Locale>(3, _omitFieldNames ? '' : 'locale', enumValues: Locale.values)
    ..aOS(4, _omitFieldNames ? '' : 'source')
    ..aOS(5, _omitFieldNames ? '' : 'uri')
    ..pPS(6, _omitFieldNames ? '' : 'crops')
    ..aOS(7, _omitFieldNames ? '' : 'region')
    ..aOS(8, _omitFieldNames ? '' : 'text')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IngestDocumentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IngestDocumentRequest copyWith(
          void Function(IngestDocumentRequest) updates) =>
      super.copyWith((message) => updates(message as IngestDocumentRequest))
          as IngestDocumentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IngestDocumentRequest create() => IngestDocumentRequest._();
  @$core.override
  IngestDocumentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IngestDocumentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IngestDocumentRequest>(create);
  static IngestDocumentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  DocumentKind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(DocumentKind value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => $_clearField(2);

  @$pb.TagNumber(3)
  Locale get locale => $_getN(2);
  @$pb.TagNumber(3)
  set locale(Locale value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLocale() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocale() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get source => $_getSZ(3);
  @$pb.TagNumber(4)
  set source($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSource() => $_has(3);
  @$pb.TagNumber(4)
  void clearSource() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get uri => $_getSZ(4);
  @$pb.TagNumber(5)
  set uri($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUri() => $_has(4);
  @$pb.TagNumber(5)
  void clearUri() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get crops => $_getList(5);

  @$pb.TagNumber(7)
  $core.String get region => $_getSZ(6);
  @$pb.TagNumber(7)
  set region($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRegion() => $_has(6);
  @$pb.TagNumber(7)
  void clearRegion() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get text => $_getSZ(7);
  @$pb.TagNumber(8)
  set text($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasText() => $_has(7);
  @$pb.TagNumber(8)
  void clearText() => $_clearField(8);
}

class IngestDocumentResponse extends $pb.GeneratedMessage {
  factory IngestDocumentResponse({
    ReferenceDocument? document,
  }) {
    final result = create();
    if (document != null) result.document = document;
    return result;
  }

  IngestDocumentResponse._();

  factory IngestDocumentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory IngestDocumentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'IngestDocumentResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOM<ReferenceDocument>(1, _omitFieldNames ? '' : 'document',
        subBuilder: ReferenceDocument.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IngestDocumentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  IngestDocumentResponse copyWith(
          void Function(IngestDocumentResponse) updates) =>
      super.copyWith((message) => updates(message as IngestDocumentResponse))
          as IngestDocumentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static IngestDocumentResponse create() => IngestDocumentResponse._();
  @$core.override
  IngestDocumentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static IngestDocumentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<IngestDocumentResponse>(create);
  static IngestDocumentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ReferenceDocument get document => $_getN(0);
  @$pb.TagNumber(1)
  set document(ReferenceDocument value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDocument() => $_has(0);
  @$pb.TagNumber(1)
  void clearDocument() => $_clearField(1);
  @$pb.TagNumber(1)
  ReferenceDocument ensureDocument() => $_ensure(0);
}

class ListDocumentsRequest extends $pb.GeneratedMessage {
  factory ListDocumentsRequest({
    Locale? locale,
    $core.String? crop,
    $core.String? region,
    $core.int? pageSize,
    $core.int? pageOffset,
  }) {
    final result = create();
    if (locale != null) result.locale = locale;
    if (crop != null) result.crop = crop;
    if (region != null) result.region = region;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    return result;
  }

  ListDocumentsRequest._();

  factory ListDocumentsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListDocumentsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListDocumentsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aE<Locale>(1, _omitFieldNames ? '' : 'locale', enumValues: Locale.values)
    ..aOS(2, _omitFieldNames ? '' : 'crop')
    ..aOS(3, _omitFieldNames ? '' : 'region')
    ..aI(4, _omitFieldNames ? '' : 'pageSize')
    ..aI(5, _omitFieldNames ? '' : 'pageOffset')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDocumentsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDocumentsRequest copyWith(void Function(ListDocumentsRequest) updates) =>
      super.copyWith((message) => updates(message as ListDocumentsRequest))
          as ListDocumentsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDocumentsRequest create() => ListDocumentsRequest._();
  @$core.override
  ListDocumentsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListDocumentsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDocumentsRequest>(create);
  static ListDocumentsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  Locale get locale => $_getN(0);
  @$pb.TagNumber(1)
  set locale(Locale value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasLocale() => $_has(0);
  @$pb.TagNumber(1)
  void clearLocale() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get crop => $_getSZ(1);
  @$pb.TagNumber(2)
  set crop($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCrop() => $_has(1);
  @$pb.TagNumber(2)
  void clearCrop() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get region => $_getSZ(2);
  @$pb.TagNumber(3)
  set region($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRegion() => $_has(2);
  @$pb.TagNumber(3)
  void clearRegion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get pageSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageSize($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPageSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageSize() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get pageOffset => $_getIZ(4);
  @$pb.TagNumber(5)
  set pageOffset($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPageOffset() => $_has(4);
  @$pb.TagNumber(5)
  void clearPageOffset() => $_clearField(5);
}

class ListDocumentsResponse extends $pb.GeneratedMessage {
  factory ListDocumentsResponse({
    $core.Iterable<ReferenceDocument>? documents,
    $core.int? totalCount,
  }) {
    final result = create();
    if (documents != null) result.documents.addAll(documents);
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListDocumentsResponse._();

  factory ListDocumentsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListDocumentsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListDocumentsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..pPM<ReferenceDocument>(1, _omitFieldNames ? '' : 'documents',
        subBuilder: ReferenceDocument.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDocumentsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDocumentsResponse copyWith(
          void Function(ListDocumentsResponse) updates) =>
      super.copyWith((message) => updates(message as ListDocumentsResponse))
          as ListDocumentsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDocumentsResponse create() => ListDocumentsResponse._();
  @$core.override
  ListDocumentsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListDocumentsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDocumentsResponse>(create);
  static ListDocumentsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ReferenceDocument> get documents => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);
}

class DeleteDocumentRequest extends $pb.GeneratedMessage {
  factory DeleteDocumentRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteDocumentRequest._();

  factory DeleteDocumentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteDocumentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteDocumentRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteDocumentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteDocumentRequest copyWith(
          void Function(DeleteDocumentRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteDocumentRequest))
          as DeleteDocumentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteDocumentRequest create() => DeleteDocumentRequest._();
  @$core.override
  DeleteDocumentRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteDocumentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteDocumentRequest>(create);
  static DeleteDocumentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteDocumentResponse extends $pb.GeneratedMessage {
  factory DeleteDocumentResponse({
    $core.bool? deleted,
  }) {
    final result = create();
    if (deleted != null) result.deleted = deleted;
    return result;
  }

  DeleteDocumentResponse._();

  factory DeleteDocumentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteDocumentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteDocumentResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'deleted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteDocumentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteDocumentResponse copyWith(
          void Function(DeleteDocumentResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteDocumentResponse))
          as DeleteDocumentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteDocumentResponse create() => DeleteDocumentResponse._();
  @$core.override
  DeleteDocumentResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteDocumentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteDocumentResponse>(create);
  static DeleteDocumentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get deleted => $_getBF(0);
  @$pb.TagNumber(1)
  set deleted($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDeleted() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeleted() => $_clearField(1);
}

class SearchReferenceRequest extends $pb.GeneratedMessage {
  factory SearchReferenceRequest({
    $core.String? query,
    Locale? locale,
    $core.String? crop,
    $core.int? limit,
  }) {
    final result = create();
    if (query != null) result.query = query;
    if (locale != null) result.locale = locale;
    if (crop != null) result.crop = crop;
    if (limit != null) result.limit = limit;
    return result;
  }

  SearchReferenceRequest._();

  factory SearchReferenceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchReferenceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchReferenceRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'query')
    ..aE<Locale>(2, _omitFieldNames ? '' : 'locale', enumValues: Locale.values)
    ..aOS(3, _omitFieldNames ? '' : 'crop')
    ..aI(4, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchReferenceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchReferenceRequest copyWith(
          void Function(SearchReferenceRequest) updates) =>
      super.copyWith((message) => updates(message as SearchReferenceRequest))
          as SearchReferenceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchReferenceRequest create() => SearchReferenceRequest._();
  @$core.override
  SearchReferenceRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchReferenceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchReferenceRequest>(create);
  static SearchReferenceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get query => $_getSZ(0);
  @$pb.TagNumber(1)
  set query($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasQuery() => $_has(0);
  @$pb.TagNumber(1)
  void clearQuery() => $_clearField(1);

  @$pb.TagNumber(2)
  Locale get locale => $_getN(1);
  @$pb.TagNumber(2)
  set locale(Locale value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasLocale() => $_has(1);
  @$pb.TagNumber(2)
  void clearLocale() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get crop => $_getSZ(2);
  @$pb.TagNumber(3)
  set crop($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCrop() => $_has(2);
  @$pb.TagNumber(3)
  void clearCrop() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get limit => $_getIZ(3);
  @$pb.TagNumber(4)
  set limit($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLimit() => $_has(3);
  @$pb.TagNumber(4)
  void clearLimit() => $_clearField(4);
}

class SearchReferenceResponse extends $pb.GeneratedMessage {
  factory SearchReferenceResponse({
    $core.Iterable<Citation>? results,
  }) {
    final result = create();
    if (results != null) result.results.addAll(results);
    return result;
  }

  SearchReferenceResponse._();

  factory SearchReferenceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SearchReferenceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SearchReferenceResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.advisory.v1'),
      createEmptyInstance: create)
    ..pPM<Citation>(1, _omitFieldNames ? '' : 'results',
        subBuilder: Citation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchReferenceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SearchReferenceResponse copyWith(
          void Function(SearchReferenceResponse) updates) =>
      super.copyWith((message) => updates(message as SearchReferenceResponse))
          as SearchReferenceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SearchReferenceResponse create() => SearchReferenceResponse._();
  @$core.override
  SearchReferenceResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SearchReferenceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SearchReferenceResponse>(create);
  static SearchReferenceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Citation> get results => $_getList(0);
}

/// AdvisoryService answers agronomy questions grounded on the tenant's own data
/// and on indexed reference material, and records every exchange for review.
class AdvisoryServiceApi {
  final $pb.RpcClient _client;

  AdvisoryServiceApi(this._client);

  $async.Future<AskResponse> ask($pb.ClientContext? ctx, AskRequest request) =>
      _client.invoke<AskResponse>(
          ctx, 'AdvisoryService', 'Ask', request, AskResponse());
  $async.Future<GetConversationResponse> getConversation(
          $pb.ClientContext? ctx, GetConversationRequest request) =>
      _client.invoke<GetConversationResponse>(ctx, 'AdvisoryService',
          'GetConversation', request, GetConversationResponse());
  $async.Future<ListConversationsResponse> listConversations(
          $pb.ClientContext? ctx, ListConversationsRequest request) =>
      _client.invoke<ListConversationsResponse>(ctx, 'AdvisoryService',
          'ListConversations', request, ListConversationsResponse());

  /// The review queue, and the reviewer's verdict on one exchange.
  $async.Future<ListExchangesResponse> listExchanges(
          $pb.ClientContext? ctx, ListExchangesRequest request) =>
      _client.invoke<ListExchangesResponse>(ctx, 'AdvisoryService',
          'ListExchanges', request, ListExchangesResponse());
  $async.Future<ReviewExchangeResponse> reviewExchange(
          $pb.ClientContext? ctx, ReviewExchangeRequest request) =>
      _client.invoke<ReviewExchangeResponse>(ctx, 'AdvisoryService',
          'ReviewExchange', request, ReviewExchangeResponse());
  $async.Future<GetTenantBudgetResponse> getTenantBudget(
          $pb.ClientContext? ctx, GetTenantBudgetRequest request) =>
      _client.invoke<GetTenantBudgetResponse>(ctx, 'AdvisoryService',
          'GetTenantBudget', request, GetTenantBudgetResponse());
  $async.Future<SetTenantBudgetResponse> setTenantBudget(
          $pb.ClientContext? ctx, SetTenantBudgetRequest request) =>
      _client.invoke<SetTenantBudgetResponse>(ctx, 'AdvisoryService',
          'SetTenantBudget', request, SetTenantBudgetResponse());
  $async.Future<IngestDocumentResponse> ingestDocument(
          $pb.ClientContext? ctx, IngestDocumentRequest request) =>
      _client.invoke<IngestDocumentResponse>(ctx, 'AdvisoryService',
          'IngestDocument', request, IngestDocumentResponse());
  $async.Future<ListDocumentsResponse> listDocuments(
          $pb.ClientContext? ctx, ListDocumentsRequest request) =>
      _client.invoke<ListDocumentsResponse>(ctx, 'AdvisoryService',
          'ListDocuments', request, ListDocumentsResponse());
  $async.Future<DeleteDocumentResponse> deleteDocument(
          $pb.ClientContext? ctx, DeleteDocumentRequest request) =>
      _client.invoke<DeleteDocumentResponse>(ctx, 'AdvisoryService',
          'DeleteDocument', request, DeleteDocumentResponse());

  /// Retrieval on its own, without an answer. Used by the citations panel and
  /// by anyone checking what the assistant would have been given.
  $async.Future<SearchReferenceResponse> searchReference(
          $pb.ClientContext? ctx, SearchReferenceRequest request) =>
      _client.invoke<SearchReferenceResponse>(ctx, 'AdvisoryService',
          'SearchReference', request, SearchReferenceResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
