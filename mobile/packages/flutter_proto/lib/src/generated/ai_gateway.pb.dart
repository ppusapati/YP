// This is a generated file - do not edit.
//
// Generated from ai_gateway.proto.

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

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Where a sample came from; stored with collected training data so labels
/// carry provenance and geographic/crop context for slicing and review.
class SampleContext extends $pb.GeneratedMessage {
  factory SampleContext({
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? fieldId,
    $core.String? crop,
    $core.double? latitude,
    $core.double? longitude,
    $core.String? submittedBy,
  }) {
    final result = create();
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (fieldId != null) result.fieldId = fieldId;
    if (crop != null) result.crop = crop;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (submittedBy != null) result.submittedBy = submittedBy;
    return result;
  }

  SampleContext._();

  factory SampleContext.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SampleContext.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SampleContext',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tenantId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aOS(3, _omitFieldNames ? '' : 'fieldId')
    ..aOS(4, _omitFieldNames ? '' : 'crop')
    ..aD(5, _omitFieldNames ? '' : 'latitude')
    ..aD(6, _omitFieldNames ? '' : 'longitude')
    ..aOS(7, _omitFieldNames ? '' : 'submittedBy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SampleContext clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SampleContext copyWith(void Function(SampleContext) updates) =>
      super.copyWith((message) => updates(message as SampleContext))
          as SampleContext;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SampleContext create() => SampleContext._();
  @$core.override
  SampleContext createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SampleContext getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SampleContext>(create);
  static SampleContext? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tenantId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tenantId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTenantId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTenantId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFarmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFarmId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fieldId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFieldId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFieldId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get crop => $_getSZ(3);
  @$pb.TagNumber(4)
  set crop($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCrop() => $_has(3);
  @$pb.TagNumber(4)
  void clearCrop() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get latitude => $_getN(4);
  @$pb.TagNumber(5)
  set latitude($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLatitude() => $_has(4);
  @$pb.TagNumber(5)
  void clearLatitude() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get longitude => $_getN(5);
  @$pb.TagNumber(6)
  set longitude($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLongitude() => $_has(5);
  @$pb.TagNumber(6)
  void clearLongitude() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get submittedBy => $_getSZ(6);
  @$pb.TagNumber(7)
  set submittedBy($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSubmittedBy() => $_has(6);
  @$pb.TagNumber(7)
  void clearSubmittedBy() => $_clearField(7);
}

class DiagnoseImageRequest extends $pb.GeneratedMessage {
  factory DiagnoseImageRequest({
    $core.String? requestId,
    $core.Iterable<ImageData>? images,
    $core.String? plantSpeciesId,
    $core.Iterable<$core.String>? operations,
    SampleContext? context,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (images != null) result.images.addAll(images);
    if (plantSpeciesId != null) result.plantSpeciesId = plantSpeciesId;
    if (operations != null) result.operations.addAll(operations);
    if (context != null) result.context = context;
    return result;
  }

  DiagnoseImageRequest._();

  factory DiagnoseImageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiagnoseImageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiagnoseImageRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..pPM<ImageData>(2, _omitFieldNames ? '' : 'images',
        subBuilder: ImageData.create)
    ..aOS(3, _omitFieldNames ? '' : 'plantSpeciesId')
    ..pPS(4, _omitFieldNames ? '' : 'operations')
    ..aOM<SampleContext>(5, _omitFieldNames ? '' : 'context',
        subBuilder: SampleContext.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiagnoseImageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiagnoseImageRequest copyWith(void Function(DiagnoseImageRequest) updates) =>
      super.copyWith((message) => updates(message as DiagnoseImageRequest))
          as DiagnoseImageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiagnoseImageRequest create() => DiagnoseImageRequest._();
  @$core.override
  DiagnoseImageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiagnoseImageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiagnoseImageRequest>(create);
  static DiagnoseImageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<ImageData> get images => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get plantSpeciesId => $_getSZ(2);
  @$pb.TagNumber(3)
  set plantSpeciesId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPlantSpeciesId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlantSpeciesId() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get operations => $_getList(3);

  @$pb.TagNumber(5)
  SampleContext get context => $_getN(4);
  @$pb.TagNumber(5)
  set context(SampleContext value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasContext() => $_has(4);
  @$pb.TagNumber(5)
  void clearContext() => $_clearField(5);
  @$pb.TagNumber(5)
  SampleContext ensureContext() => $_ensure(4);
}

/// Why a vision model answered the way it did.
///
/// A confidence score says how sure the model is; this says what it looked at,
/// which is what lets someone check the answer instead of trusting it. Produced
/// by Grad-CAM over the backbone's last feature map, so it reflects the real
/// gradient of the predicted class rather than a generic saliency estimate.
class Explanation extends $pb.GeneratedMessage {
  factory Explanation({
    $core.String? task,
    $core.String? className,
    $core.List<$core.int>? heatmapPng,
    $core.int? heatmapWidth,
    $core.int? heatmapHeight,
    $core.double? focusX,
    $core.double? focusY,
    $core.double? focusWidth,
    $core.double? focusHeight,
    $core.double? focusCoverage,
    $core.String? summary,
    $core.String? method,
    $core.bool? localised,
  }) {
    final result = create();
    if (task != null) result.task = task;
    if (className != null) result.className = className;
    if (heatmapPng != null) result.heatmapPng = heatmapPng;
    if (heatmapWidth != null) result.heatmapWidth = heatmapWidth;
    if (heatmapHeight != null) result.heatmapHeight = heatmapHeight;
    if (focusX != null) result.focusX = focusX;
    if (focusY != null) result.focusY = focusY;
    if (focusWidth != null) result.focusWidth = focusWidth;
    if (focusHeight != null) result.focusHeight = focusHeight;
    if (focusCoverage != null) result.focusCoverage = focusCoverage;
    if (summary != null) result.summary = summary;
    if (method != null) result.method = method;
    if (localised != null) result.localised = localised;
    return result;
  }

  Explanation._();

  factory Explanation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Explanation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Explanation',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'task')
    ..aOS(2, _omitFieldNames ? '' : 'className')
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'heatmapPng', $pb.PbFieldType.OY)
    ..aI(4, _omitFieldNames ? '' : 'heatmapWidth')
    ..aI(5, _omitFieldNames ? '' : 'heatmapHeight')
    ..aD(6, _omitFieldNames ? '' : 'focusX')
    ..aD(7, _omitFieldNames ? '' : 'focusY')
    ..aD(8, _omitFieldNames ? '' : 'focusWidth')
    ..aD(9, _omitFieldNames ? '' : 'focusHeight')
    ..aD(10, _omitFieldNames ? '' : 'focusCoverage')
    ..aOS(11, _omitFieldNames ? '' : 'summary')
    ..aOS(12, _omitFieldNames ? '' : 'method')
    ..aOB(13, _omitFieldNames ? '' : 'localised')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Explanation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Explanation copyWith(void Function(Explanation) updates) =>
      super.copyWith((message) => updates(message as Explanation))
          as Explanation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Explanation create() => Explanation._();
  @$core.override
  Explanation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Explanation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Explanation>(create);
  static Explanation? _defaultInstance;

  /// Which task and class this explains.
  @$pb.TagNumber(1)
  $core.String get task => $_getSZ(0);
  @$pb.TagNumber(1)
  set task($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get className => $_getSZ(1);
  @$pb.TagNumber(2)
  set className($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasClassName() => $_has(1);
  @$pb.TagNumber(2)
  void clearClassName() => $_clearField(2);

  /// Greyscale PNG, brightest where the evidence is. Empty when the serving
  /// model carries no explanation outputs.
  @$pb.TagNumber(3)
  $core.List<$core.int> get heatmapPng => $_getN(2);
  @$pb.TagNumber(3)
  set heatmapPng($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeatmapPng() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeatmapPng() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get heatmapWidth => $_getIZ(3);
  @$pb.TagNumber(4)
  set heatmapWidth($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeatmapWidth() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeatmapWidth() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get heatmapHeight => $_getIZ(4);
  @$pb.TagNumber(5)
  set heatmapHeight($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHeatmapHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeatmapHeight() => $_clearField(5);

  /// Region the model keyed on, normalised to [0,1] with 0,0 at the top left so
  /// it survives any later resize of the image.
  @$pb.TagNumber(6)
  $core.double get focusX => $_getN(5);
  @$pb.TagNumber(6)
  set focusX($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFocusX() => $_has(5);
  @$pb.TagNumber(6)
  void clearFocusX() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get focusY => $_getN(6);
  @$pb.TagNumber(7)
  set focusY($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFocusY() => $_has(6);
  @$pb.TagNumber(7)
  void clearFocusY() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get focusWidth => $_getN(7);
  @$pb.TagNumber(8)
  set focusWidth($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasFocusWidth() => $_has(7);
  @$pb.TagNumber(8)
  void clearFocusWidth() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get focusHeight => $_getN(8);
  @$pb.TagNumber(9)
  set focusHeight($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFocusHeight() => $_has(8);
  @$pb.TagNumber(9)
  void clearFocusHeight() => $_clearField(9);

  /// Share of the image inside that region. A value near 1 means the model used
  /// the whole picture and located nothing in particular.
  @$pb.TagNumber(10)
  $core.double get focusCoverage => $_getN(9);
  @$pb.TagNumber(10)
  set focusCoverage($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasFocusCoverage() => $_has(9);
  @$pb.TagNumber(10)
  void clearFocusCoverage() => $_clearField(10);

  /// One sentence describing where the model looked, for display.
  @$pb.TagNumber(11)
  $core.String get summary => $_getSZ(10);
  @$pb.TagNumber(11)
  set summary($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSummary() => $_has(10);
  @$pb.TagNumber(11)
  void clearSummary() => $_clearField(11);

  /// How the explanation was produced, e.g. "grad-cam".
  @$pb.TagNumber(12)
  $core.String get method => $_getSZ(11);
  @$pb.TagNumber(12)
  set method($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasMethod() => $_has(11);
  @$pb.TagNumber(12)
  void clearMethod() => $_clearField(12);

  /// False when the map was flat and nothing can be pointed at.
  @$pb.TagNumber(13)
  $core.bool get localised => $_getBF(12);
  @$pb.TagNumber(13)
  set localised($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasLocalised() => $_has(12);
  @$pb.TagNumber(13)
  void clearLocalised() => $_clearField(13);
}

class DiagnoseImageResponse extends $pb.GeneratedMessage {
  factory DiagnoseImageResponse({
    $core.String? requestId,
    $core.Iterable<DiseaseDetection>? diseases,
    $core.double? overallHealthScore,
    $core.String? summary,
    $core.String? modelVersion,
    $fixnum.Int64? processingTimeMs,
    $core.Iterable<Explanation>? explanations,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (diseases != null) result.diseases.addAll(diseases);
    if (overallHealthScore != null)
      result.overallHealthScore = overallHealthScore;
    if (summary != null) result.summary = summary;
    if (modelVersion != null) result.modelVersion = modelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    if (explanations != null) result.explanations.addAll(explanations);
    return result;
  }

  DiagnoseImageResponse._();

  factory DiagnoseImageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiagnoseImageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiagnoseImageResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..pPM<DiseaseDetection>(2, _omitFieldNames ? '' : 'diseases',
        subBuilder: DiseaseDetection.create)
    ..aD(3, _omitFieldNames ? '' : 'overallHealthScore')
    ..aOS(4, _omitFieldNames ? '' : 'summary')
    ..aOS(5, _omitFieldNames ? '' : 'modelVersion')
    ..aInt64(6, _omitFieldNames ? '' : 'processingTimeMs')
    ..pPM<Explanation>(7, _omitFieldNames ? '' : 'explanations',
        subBuilder: Explanation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiagnoseImageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiagnoseImageResponse copyWith(
          void Function(DiagnoseImageResponse) updates) =>
      super.copyWith((message) => updates(message as DiagnoseImageResponse))
          as DiagnoseImageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiagnoseImageResponse create() => DiagnoseImageResponse._();
  @$core.override
  DiagnoseImageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiagnoseImageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiagnoseImageResponse>(create);
  static DiagnoseImageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<DiseaseDetection> get diseases => $_getList(1);

  @$pb.TagNumber(3)
  $core.double get overallHealthScore => $_getN(2);
  @$pb.TagNumber(3)
  set overallHealthScore($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOverallHealthScore() => $_has(2);
  @$pb.TagNumber(3)
  void clearOverallHealthScore() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get summary => $_getSZ(3);
  @$pb.TagNumber(4)
  set summary($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSummary() => $_has(3);
  @$pb.TagNumber(4)
  void clearSummary() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get modelVersion => $_getSZ(4);
  @$pb.TagNumber(5)
  set modelVersion($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasModelVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearModelVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get processingTimeMs => $_getI64(5);
  @$pb.TagNumber(6)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProcessingTimeMs() => $_has(5);
  @$pb.TagNumber(6)
  void clearProcessingTimeMs() => $_clearField(6);

  /// One per analysed image, in request order. Empty when the serving model
  /// cannot explain itself.
  @$pb.TagNumber(7)
  $pb.PbList<Explanation> get explanations => $_getList(6);
}

class DiseaseDetection extends $pb.GeneratedMessage {
  factory DiseaseDetection({
    $core.String? diseaseId,
    $core.String? diseaseName,
    $core.String? scientificName,
    $core.double? confidenceScore,
    $core.String? severity,
    $core.String? description,
    $core.String? symptoms,
    $core.Iterable<$core.String>? treatmentOptions,
    $core.String? prevention,
  }) {
    final result = create();
    if (diseaseId != null) result.diseaseId = diseaseId;
    if (diseaseName != null) result.diseaseName = diseaseName;
    if (scientificName != null) result.scientificName = scientificName;
    if (confidenceScore != null) result.confidenceScore = confidenceScore;
    if (severity != null) result.severity = severity;
    if (description != null) result.description = description;
    if (symptoms != null) result.symptoms = symptoms;
    if (treatmentOptions != null)
      result.treatmentOptions.addAll(treatmentOptions);
    if (prevention != null) result.prevention = prevention;
    return result;
  }

  DiseaseDetection._();

  factory DiseaseDetection.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DiseaseDetection.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DiseaseDetection',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'diseaseId')
    ..aOS(2, _omitFieldNames ? '' : 'diseaseName')
    ..aOS(3, _omitFieldNames ? '' : 'scientificName')
    ..aD(4, _omitFieldNames ? '' : 'confidenceScore')
    ..aOS(5, _omitFieldNames ? '' : 'severity')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'symptoms')
    ..pPS(8, _omitFieldNames ? '' : 'treatmentOptions')
    ..aOS(9, _omitFieldNames ? '' : 'prevention')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiseaseDetection clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DiseaseDetection copyWith(void Function(DiseaseDetection) updates) =>
      super.copyWith((message) => updates(message as DiseaseDetection))
          as DiseaseDetection;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DiseaseDetection create() => DiseaseDetection._();
  @$core.override
  DiseaseDetection createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DiseaseDetection getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DiseaseDetection>(create);
  static DiseaseDetection? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get diseaseId => $_getSZ(0);
  @$pb.TagNumber(1)
  set diseaseId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDiseaseId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDiseaseId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get diseaseName => $_getSZ(1);
  @$pb.TagNumber(2)
  set diseaseName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDiseaseName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDiseaseName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get scientificName => $_getSZ(2);
  @$pb.TagNumber(3)
  set scientificName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScientificName() => $_has(2);
  @$pb.TagNumber(3)
  void clearScientificName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get confidenceScore => $_getN(3);
  @$pb.TagNumber(4)
  set confidenceScore($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfidenceScore() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfidenceScore() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get severity => $_getSZ(4);
  @$pb.TagNumber(5)
  set severity($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSeverity() => $_has(4);
  @$pb.TagNumber(5)
  void clearSeverity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get symptoms => $_getSZ(6);
  @$pb.TagNumber(7)
  set symptoms($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSymptoms() => $_has(6);
  @$pb.TagNumber(7)
  void clearSymptoms() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get treatmentOptions => $_getList(7);

  @$pb.TagNumber(9)
  $core.String get prevention => $_getSZ(8);
  @$pb.TagNumber(9)
  set prevention($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasPrevention() => $_has(8);
  @$pb.TagNumber(9)
  void clearPrevention() => $_clearField(9);
}

class DetectPestsRequest extends $pb.GeneratedMessage {
  factory DetectPestsRequest({
    $core.String? requestId,
    $core.Iterable<ImageData>? images,
    $core.String? plantSpeciesId,
    SampleContext? context,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (images != null) result.images.addAll(images);
    if (plantSpeciesId != null) result.plantSpeciesId = plantSpeciesId;
    if (context != null) result.context = context;
    return result;
  }

  DetectPestsRequest._();

  factory DetectPestsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectPestsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectPestsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..pPM<ImageData>(2, _omitFieldNames ? '' : 'images',
        subBuilder: ImageData.create)
    ..aOS(3, _omitFieldNames ? '' : 'plantSpeciesId')
    ..aOM<SampleContext>(4, _omitFieldNames ? '' : 'context',
        subBuilder: SampleContext.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectPestsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectPestsRequest copyWith(void Function(DetectPestsRequest) updates) =>
      super.copyWith((message) => updates(message as DetectPestsRequest))
          as DetectPestsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectPestsRequest create() => DetectPestsRequest._();
  @$core.override
  DetectPestsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectPestsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectPestsRequest>(create);
  static DetectPestsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<ImageData> get images => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get plantSpeciesId => $_getSZ(2);
  @$pb.TagNumber(3)
  set plantSpeciesId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPlantSpeciesId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlantSpeciesId() => $_clearField(3);

  @$pb.TagNumber(4)
  SampleContext get context => $_getN(3);
  @$pb.TagNumber(4)
  set context(SampleContext value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasContext() => $_has(3);
  @$pb.TagNumber(4)
  void clearContext() => $_clearField(4);
  @$pb.TagNumber(4)
  SampleContext ensureContext() => $_ensure(3);
}

class DetectPestsResponse extends $pb.GeneratedMessage {
  factory DetectPestsResponse({
    $core.String? requestId,
    $core.Iterable<PestDetection>? pests,
    $core.String? modelVersion,
    $fixnum.Int64? processingTimeMs,
    $core.Iterable<Explanation>? explanations,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (pests != null) result.pests.addAll(pests);
    if (modelVersion != null) result.modelVersion = modelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    if (explanations != null) result.explanations.addAll(explanations);
    return result;
  }

  DetectPestsResponse._();

  factory DetectPestsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectPestsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectPestsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..pPM<PestDetection>(2, _omitFieldNames ? '' : 'pests',
        subBuilder: PestDetection.create)
    ..aOS(3, _omitFieldNames ? '' : 'modelVersion')
    ..aInt64(4, _omitFieldNames ? '' : 'processingTimeMs')
    ..pPM<Explanation>(5, _omitFieldNames ? '' : 'explanations',
        subBuilder: Explanation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectPestsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectPestsResponse copyWith(void Function(DetectPestsResponse) updates) =>
      super.copyWith((message) => updates(message as DetectPestsResponse))
          as DetectPestsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectPestsResponse create() => DetectPestsResponse._();
  @$core.override
  DetectPestsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectPestsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectPestsResponse>(create);
  static DetectPestsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<PestDetection> get pests => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get modelVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set modelVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasModelVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearModelVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get processingTimeMs => $_getI64(3);
  @$pb.TagNumber(4)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProcessingTimeMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearProcessingTimeMs() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<Explanation> get explanations => $_getList(4);
}

class PestDetection extends $pb.GeneratedMessage {
  factory PestDetection({
    $core.String? pestId,
    $core.String? pestName,
    $core.String? scientificName,
    $core.double? confidenceScore,
    $core.String? damageLevel,
    $core.String? description,
    $core.String? damagePattern,
    $core.Iterable<$core.String>? controlMethods,
  }) {
    final result = create();
    if (pestId != null) result.pestId = pestId;
    if (pestName != null) result.pestName = pestName;
    if (scientificName != null) result.scientificName = scientificName;
    if (confidenceScore != null) result.confidenceScore = confidenceScore;
    if (damageLevel != null) result.damageLevel = damageLevel;
    if (description != null) result.description = description;
    if (damagePattern != null) result.damagePattern = damagePattern;
    if (controlMethods != null) result.controlMethods.addAll(controlMethods);
    return result;
  }

  PestDetection._();

  factory PestDetection.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PestDetection.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PestDetection',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pestId')
    ..aOS(2, _omitFieldNames ? '' : 'pestName')
    ..aOS(3, _omitFieldNames ? '' : 'scientificName')
    ..aD(4, _omitFieldNames ? '' : 'confidenceScore')
    ..aOS(5, _omitFieldNames ? '' : 'damageLevel')
    ..aOS(6, _omitFieldNames ? '' : 'description')
    ..aOS(7, _omitFieldNames ? '' : 'damagePattern')
    ..pPS(8, _omitFieldNames ? '' : 'controlMethods')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestDetection clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PestDetection copyWith(void Function(PestDetection) updates) =>
      super.copyWith((message) => updates(message as PestDetection))
          as PestDetection;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PestDetection create() => PestDetection._();
  @$core.override
  PestDetection createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PestDetection getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PestDetection>(create);
  static PestDetection? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set pestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pestName => $_getSZ(1);
  @$pb.TagNumber(2)
  set pestName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPestName() => $_has(1);
  @$pb.TagNumber(2)
  void clearPestName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get scientificName => $_getSZ(2);
  @$pb.TagNumber(3)
  set scientificName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScientificName() => $_has(2);
  @$pb.TagNumber(3)
  void clearScientificName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get confidenceScore => $_getN(3);
  @$pb.TagNumber(4)
  set confidenceScore($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfidenceScore() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfidenceScore() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get damageLevel => $_getSZ(4);
  @$pb.TagNumber(5)
  set damageLevel($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDamageLevel() => $_has(4);
  @$pb.TagNumber(5)
  void clearDamageLevel() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get description => $_getSZ(5);
  @$pb.TagNumber(6)
  set description($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescription() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescription() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get damagePattern => $_getSZ(6);
  @$pb.TagNumber(7)
  set damagePattern($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDamagePattern() => $_has(6);
  @$pb.TagNumber(7)
  void clearDamagePattern() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get controlMethods => $_getList(7);
}

class DetectNutrientDeficiencyRequest extends $pb.GeneratedMessage {
  factory DetectNutrientDeficiencyRequest({
    $core.String? requestId,
    $core.Iterable<ImageData>? images,
    $core.String? plantSpeciesId,
    SampleContext? context,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (images != null) result.images.addAll(images);
    if (plantSpeciesId != null) result.plantSpeciesId = plantSpeciesId;
    if (context != null) result.context = context;
    return result;
  }

  DetectNutrientDeficiencyRequest._();

  factory DetectNutrientDeficiencyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectNutrientDeficiencyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectNutrientDeficiencyRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..pPM<ImageData>(2, _omitFieldNames ? '' : 'images',
        subBuilder: ImageData.create)
    ..aOS(3, _omitFieldNames ? '' : 'plantSpeciesId')
    ..aOM<SampleContext>(4, _omitFieldNames ? '' : 'context',
        subBuilder: SampleContext.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectNutrientDeficiencyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectNutrientDeficiencyRequest copyWith(
          void Function(DetectNutrientDeficiencyRequest) updates) =>
      super.copyWith(
              (message) => updates(message as DetectNutrientDeficiencyRequest))
          as DetectNutrientDeficiencyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectNutrientDeficiencyRequest create() =>
      DetectNutrientDeficiencyRequest._();
  @$core.override
  DetectNutrientDeficiencyRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectNutrientDeficiencyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectNutrientDeficiencyRequest>(
          create);
  static DetectNutrientDeficiencyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<ImageData> get images => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get plantSpeciesId => $_getSZ(2);
  @$pb.TagNumber(3)
  set plantSpeciesId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPlantSpeciesId() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlantSpeciesId() => $_clearField(3);

  @$pb.TagNumber(4)
  SampleContext get context => $_getN(3);
  @$pb.TagNumber(4)
  set context(SampleContext value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasContext() => $_has(3);
  @$pb.TagNumber(4)
  void clearContext() => $_clearField(4);
  @$pb.TagNumber(4)
  SampleContext ensureContext() => $_ensure(3);
}

class DetectNutrientDeficiencyResponse extends $pb.GeneratedMessage {
  factory DetectNutrientDeficiencyResponse({
    $core.String? requestId,
    $core.Iterable<NutrientDeficiency>? deficiencies,
    $core.String? modelVersion,
    $fixnum.Int64? processingTimeMs,
    $core.Iterable<Explanation>? explanations,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (deficiencies != null) result.deficiencies.addAll(deficiencies);
    if (modelVersion != null) result.modelVersion = modelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    if (explanations != null) result.explanations.addAll(explanations);
    return result;
  }

  DetectNutrientDeficiencyResponse._();

  factory DetectNutrientDeficiencyResponse.fromBuffer(
          $core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectNutrientDeficiencyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectNutrientDeficiencyResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..pPM<NutrientDeficiency>(2, _omitFieldNames ? '' : 'deficiencies',
        subBuilder: NutrientDeficiency.create)
    ..aOS(3, _omitFieldNames ? '' : 'modelVersion')
    ..aInt64(4, _omitFieldNames ? '' : 'processingTimeMs')
    ..pPM<Explanation>(5, _omitFieldNames ? '' : 'explanations',
        subBuilder: Explanation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectNutrientDeficiencyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectNutrientDeficiencyResponse copyWith(
          void Function(DetectNutrientDeficiencyResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DetectNutrientDeficiencyResponse))
          as DetectNutrientDeficiencyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectNutrientDeficiencyResponse create() =>
      DetectNutrientDeficiencyResponse._();
  @$core.override
  DetectNutrientDeficiencyResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectNutrientDeficiencyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectNutrientDeficiencyResponse>(
          create);
  static DetectNutrientDeficiencyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<NutrientDeficiency> get deficiencies => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get modelVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set modelVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasModelVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearModelVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get processingTimeMs => $_getI64(3);
  @$pb.TagNumber(4)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProcessingTimeMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearProcessingTimeMs() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<Explanation> get explanations => $_getList(4);
}

class NutrientDeficiency extends $pb.GeneratedMessage {
  factory NutrientDeficiency({
    $core.String? nutrient,
    $core.double? confidenceScore,
    $core.String? severity,
    $core.String? description,
    $core.String? visualSymptoms,
    $core.Iterable<$core.String>? recommendedFertilizers,
    $core.String? applicationMethod,
  }) {
    final result = create();
    if (nutrient != null) result.nutrient = nutrient;
    if (confidenceScore != null) result.confidenceScore = confidenceScore;
    if (severity != null) result.severity = severity;
    if (description != null) result.description = description;
    if (visualSymptoms != null) result.visualSymptoms = visualSymptoms;
    if (recommendedFertilizers != null)
      result.recommendedFertilizers.addAll(recommendedFertilizers);
    if (applicationMethod != null) result.applicationMethod = applicationMethod;
    return result;
  }

  NutrientDeficiency._();

  factory NutrientDeficiency.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NutrientDeficiency.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NutrientDeficiency',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'nutrient')
    ..aD(2, _omitFieldNames ? '' : 'confidenceScore')
    ..aOS(3, _omitFieldNames ? '' : 'severity')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'visualSymptoms')
    ..pPS(6, _omitFieldNames ? '' : 'recommendedFertilizers')
    ..aOS(7, _omitFieldNames ? '' : 'applicationMethod')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NutrientDeficiency clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NutrientDeficiency copyWith(void Function(NutrientDeficiency) updates) =>
      super.copyWith((message) => updates(message as NutrientDeficiency))
          as NutrientDeficiency;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NutrientDeficiency create() => NutrientDeficiency._();
  @$core.override
  NutrientDeficiency createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NutrientDeficiency getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NutrientDeficiency>(create);
  static NutrientDeficiency? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get nutrient => $_getSZ(0);
  @$pb.TagNumber(1)
  set nutrient($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNutrient() => $_has(0);
  @$pb.TagNumber(1)
  void clearNutrient() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get confidenceScore => $_getN(1);
  @$pb.TagNumber(2)
  set confidenceScore($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConfidenceScore() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfidenceScore() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get severity => $_getSZ(2);
  @$pb.TagNumber(3)
  set severity($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSeverity() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeverity() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get visualSymptoms => $_getSZ(4);
  @$pb.TagNumber(5)
  set visualSymptoms($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVisualSymptoms() => $_has(4);
  @$pb.TagNumber(5)
  void clearVisualSymptoms() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get recommendedFertilizers => $_getList(5);

  @$pb.TagNumber(7)
  $core.String get applicationMethod => $_getSZ(6);
  @$pb.TagNumber(7)
  set applicationMethod($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasApplicationMethod() => $_has(6);
  @$pb.TagNumber(7)
  void clearApplicationMethod() => $_clearField(7);
}

class ClassifyPlantRequest extends $pb.GeneratedMessage {
  factory ClassifyPlantRequest({
    $core.String? requestId,
    $core.Iterable<ImageData>? images,
    SampleContext? context,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (images != null) result.images.addAll(images);
    if (context != null) result.context = context;
    return result;
  }

  ClassifyPlantRequest._();

  factory ClassifyPlantRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClassifyPlantRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClassifyPlantRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..pPM<ImageData>(2, _omitFieldNames ? '' : 'images',
        subBuilder: ImageData.create)
    ..aOM<SampleContext>(3, _omitFieldNames ? '' : 'context',
        subBuilder: SampleContext.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClassifyPlantRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClassifyPlantRequest copyWith(void Function(ClassifyPlantRequest) updates) =>
      super.copyWith((message) => updates(message as ClassifyPlantRequest))
          as ClassifyPlantRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClassifyPlantRequest create() => ClassifyPlantRequest._();
  @$core.override
  ClassifyPlantRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClassifyPlantRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClassifyPlantRequest>(create);
  static ClassifyPlantRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<ImageData> get images => $_getList(1);

  @$pb.TagNumber(3)
  SampleContext get context => $_getN(2);
  @$pb.TagNumber(3)
  set context(SampleContext value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasContext() => $_has(2);
  @$pb.TagNumber(3)
  void clearContext() => $_clearField(3);
  @$pb.TagNumber(3)
  SampleContext ensureContext() => $_ensure(2);
}

class TrainingLabel extends $pb.GeneratedMessage {
  factory TrainingLabel({
    $core.String? name,
    $core.double? confidence,
    $core.String? category,
    $core.String? severity,
  }) {
    final result = create();
    if (name != null) result.name = name;
    if (confidence != null) result.confidence = confidence;
    if (category != null) result.category = category;
    if (severity != null) result.severity = severity;
    return result;
  }

  TrainingLabel._();

  factory TrainingLabel.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TrainingLabel.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TrainingLabel',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aD(2, _omitFieldNames ? '' : 'confidence')
    ..aOS(3, _omitFieldNames ? '' : 'category')
    ..aOS(4, _omitFieldNames ? '' : 'severity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrainingLabel clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrainingLabel copyWith(void Function(TrainingLabel) updates) =>
      super.copyWith((message) => updates(message as TrainingLabel))
          as TrainingLabel;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrainingLabel create() => TrainingLabel._();
  @$core.override
  TrainingLabel createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TrainingLabel getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TrainingLabel>(create);
  static TrainingLabel? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get confidence => $_getN(1);
  @$pb.TagNumber(2)
  set confidence($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasConfidence() => $_has(1);
  @$pb.TagNumber(2)
  void clearConfidence() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get category => $_getSZ(2);
  @$pb.TagNumber(3)
  set category($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCategory() => $_has(2);
  @$pb.TagNumber(3)
  void clearCategory() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get severity => $_getSZ(3);
  @$pb.TagNumber(4)
  set severity($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSeverity() => $_has(3);
  @$pb.TagNumber(4)
  void clearSeverity() => $_clearField(4);
}

class LabelReview extends $pb.GeneratedMessage {
  factory LabelReview({
    $core.String? decision,
    $core.String? correctedLabel,
    $core.String? reviewerId,
    $core.String? tenantId,
    $core.String? notes,
    $core.String? reviewedAt,
  }) {
    final result = create();
    if (decision != null) result.decision = decision;
    if (correctedLabel != null) result.correctedLabel = correctedLabel;
    if (reviewerId != null) result.reviewerId = reviewerId;
    if (tenantId != null) result.tenantId = tenantId;
    if (notes != null) result.notes = notes;
    if (reviewedAt != null) result.reviewedAt = reviewedAt;
    return result;
  }

  LabelReview._();

  factory LabelReview.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LabelReview.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LabelReview',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'decision')
    ..aOS(2, _omitFieldNames ? '' : 'correctedLabel')
    ..aOS(3, _omitFieldNames ? '' : 'reviewerId')
    ..aOS(4, _omitFieldNames ? '' : 'tenantId')
    ..aOS(5, _omitFieldNames ? '' : 'notes')
    ..aOS(6, _omitFieldNames ? '' : 'reviewedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelReview clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelReview copyWith(void Function(LabelReview) updates) =>
      super.copyWith((message) => updates(message as LabelReview))
          as LabelReview;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LabelReview create() => LabelReview._();
  @$core.override
  LabelReview createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LabelReview getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LabelReview>(create);
  static LabelReview? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get decision => $_getSZ(0);
  @$pb.TagNumber(1)
  set decision($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDecision() => $_has(0);
  @$pb.TagNumber(1)
  void clearDecision() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get correctedLabel => $_getSZ(1);
  @$pb.TagNumber(2)
  set correctedLabel($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCorrectedLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearCorrectedLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get reviewerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set reviewerId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReviewerId() => $_has(2);
  @$pb.TagNumber(3)
  void clearReviewerId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get tenantId => $_getSZ(3);
  @$pb.TagNumber(4)
  set tenantId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTenantId() => $_has(3);
  @$pb.TagNumber(4)
  void clearTenantId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get notes => $_getSZ(4);
  @$pb.TagNumber(5)
  set notes($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNotes() => $_has(4);
  @$pb.TagNumber(5)
  void clearNotes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get reviewedAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set reviewedAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasReviewedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearReviewedAt() => $_clearField(6);
}

/// A trained model's confident disagreement with a stored label.
///
/// When a model puts almost all its probability on a class the label does not
/// name, the label is the more likely thing to be wrong — and a wrong label does
/// not merely waste one example, it teaches the next model the same mistake.
class LabelSuspicion extends $pb.GeneratedMessage {
  factory LabelSuspicion({
    $core.String? predicted,
    $core.double? predictedProb,
    $core.double? labelProb,
    $core.String? modelVersion,
    $core.String? flaggedAt,
  }) {
    final result = create();
    if (predicted != null) result.predicted = predicted;
    if (predictedProb != null) result.predictedProb = predictedProb;
    if (labelProb != null) result.labelProb = labelProb;
    if (modelVersion != null) result.modelVersion = modelVersion;
    if (flaggedAt != null) result.flaggedAt = flaggedAt;
    return result;
  }

  LabelSuspicion._();

  factory LabelSuspicion.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LabelSuspicion.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LabelSuspicion',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'predicted')
    ..aD(2, _omitFieldNames ? '' : 'predictedProb')
    ..aD(3, _omitFieldNames ? '' : 'labelProb')
    ..aOS(4, _omitFieldNames ? '' : 'modelVersion')
    ..aOS(5, _omitFieldNames ? '' : 'flaggedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelSuspicion clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelSuspicion copyWith(void Function(LabelSuspicion) updates) =>
      super.copyWith((message) => updates(message as LabelSuspicion))
          as LabelSuspicion;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LabelSuspicion create() => LabelSuspicion._();
  @$core.override
  LabelSuspicion createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LabelSuspicion getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LabelSuspicion>(create);
  static LabelSuspicion? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get predicted => $_getSZ(0);
  @$pb.TagNumber(1)
  set predicted($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPredicted() => $_has(0);
  @$pb.TagNumber(1)
  void clearPredicted() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get predictedProb => $_getN(1);
  @$pb.TagNumber(2)
  set predictedProb($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPredictedProb() => $_has(1);
  @$pb.TagNumber(2)
  void clearPredictedProb() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get labelProb => $_getN(2);
  @$pb.TagNumber(3)
  set labelProb($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLabelProb() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabelProb() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get modelVersion => $_getSZ(3);
  @$pb.TagNumber(4)
  set modelVersion($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasModelVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearModelVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get flaggedAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set flaggedAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFlaggedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearFlaggedAt() => $_clearField(5);
}

class TrainingSampleInfo extends $pb.GeneratedMessage {
  factory TrainingSampleInfo({
    $core.String? id,
    $core.String? task,
    $core.String? timestamp,
    $core.String? provenance,
    $core.String? provider,
    $core.Iterable<TrainingLabel>? labels,
    $core.double? topConfidence,
    SampleContext? context,
    LabelReview? review,
    $core.String? effectiveLabel,
    LabelSuspicion? suspect,
    $core.bool? needsSecondOpinion,
    $core.Iterable<LabelReview>? reviews,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (task != null) result.task = task;
    if (timestamp != null) result.timestamp = timestamp;
    if (provenance != null) result.provenance = provenance;
    if (provider != null) result.provider = provider;
    if (labels != null) result.labels.addAll(labels);
    if (topConfidence != null) result.topConfidence = topConfidence;
    if (context != null) result.context = context;
    if (review != null) result.review = review;
    if (effectiveLabel != null) result.effectiveLabel = effectiveLabel;
    if (suspect != null) result.suspect = suspect;
    if (needsSecondOpinion != null)
      result.needsSecondOpinion = needsSecondOpinion;
    if (reviews != null) result.reviews.addAll(reviews);
    return result;
  }

  TrainingSampleInfo._();

  factory TrainingSampleInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TrainingSampleInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TrainingSampleInfo',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'task')
    ..aOS(3, _omitFieldNames ? '' : 'timestamp')
    ..aOS(4, _omitFieldNames ? '' : 'provenance')
    ..aOS(5, _omitFieldNames ? '' : 'provider')
    ..pPM<TrainingLabel>(6, _omitFieldNames ? '' : 'labels',
        subBuilder: TrainingLabel.create)
    ..aD(7, _omitFieldNames ? '' : 'topConfidence')
    ..aOM<SampleContext>(8, _omitFieldNames ? '' : 'context',
        subBuilder: SampleContext.create)
    ..aOM<LabelReview>(9, _omitFieldNames ? '' : 'review',
        subBuilder: LabelReview.create)
    ..aOS(10, _omitFieldNames ? '' : 'effectiveLabel')
    ..aOM<LabelSuspicion>(11, _omitFieldNames ? '' : 'suspect',
        subBuilder: LabelSuspicion.create)
    ..aOB(12, _omitFieldNames ? '' : 'needsSecondOpinion')
    ..pPM<LabelReview>(13, _omitFieldNames ? '' : 'reviews',
        subBuilder: LabelReview.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrainingSampleInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TrainingSampleInfo copyWith(void Function(TrainingSampleInfo) updates) =>
      super.copyWith((message) => updates(message as TrainingSampleInfo))
          as TrainingSampleInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TrainingSampleInfo create() => TrainingSampleInfo._();
  @$core.override
  TrainingSampleInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TrainingSampleInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TrainingSampleInfo>(create);
  static TrainingSampleInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get task => $_getSZ(1);
  @$pb.TagNumber(2)
  set task($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTask() => $_has(1);
  @$pb.TagNumber(2)
  void clearTask() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get timestamp => $_getSZ(2);
  @$pb.TagNumber(3)
  set timestamp($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get provenance => $_getSZ(3);
  @$pb.TagNumber(4)
  set provenance($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProvenance() => $_has(3);
  @$pb.TagNumber(4)
  void clearProvenance() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get provider => $_getSZ(4);
  @$pb.TagNumber(5)
  set provider($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProvider() => $_has(4);
  @$pb.TagNumber(5)
  void clearProvider() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<TrainingLabel> get labels => $_getList(5);

  @$pb.TagNumber(7)
  $core.double get topConfidence => $_getN(6);
  @$pb.TagNumber(7)
  set topConfidence($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTopConfidence() => $_has(6);
  @$pb.TagNumber(7)
  void clearTopConfidence() => $_clearField(7);

  @$pb.TagNumber(8)
  SampleContext get context => $_getN(7);
  @$pb.TagNumber(8)
  set context(SampleContext value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasContext() => $_has(7);
  @$pb.TagNumber(8)
  void clearContext() => $_clearField(8);
  @$pb.TagNumber(8)
  SampleContext ensureContext() => $_ensure(7);

  @$pb.TagNumber(9)
  LabelReview get review => $_getN(8);
  @$pb.TagNumber(9)
  set review(LabelReview value) => $_setField(9, value);
  @$pb.TagNumber(9)
  $core.bool hasReview() => $_has(8);
  @$pb.TagNumber(9)
  void clearReview() => $_clearField(9);
  @$pb.TagNumber(9)
  LabelReview ensureReview() => $_ensure(8);

  @$pb.TagNumber(10)
  $core.String get effectiveLabel => $_getSZ(9);
  @$pb.TagNumber(10)
  set effectiveLabel($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasEffectiveLabel() => $_has(9);
  @$pb.TagNumber(10)
  void clearEffectiveLabel() => $_clearField(10);

  @$pb.TagNumber(11)
  LabelSuspicion get suspect => $_getN(10);
  @$pb.TagNumber(11)
  set suspect(LabelSuspicion value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasSuspect() => $_has(10);
  @$pb.TagNumber(11)
  void clearSuspect() => $_clearField(11);
  @$pb.TagNumber(11)
  LabelSuspicion ensureSuspect() => $_ensure(10);

  /// True when this sample wants another pair of eyes, because a reviewer asked
  /// or because two reviewers already disagreed.
  @$pb.TagNumber(12)
  $core.bool get needsSecondOpinion => $_getBF(11);
  @$pb.TagNumber(12)
  set needsSecondOpinion($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasNeedsSecondOpinion() => $_has(11);
  @$pb.TagNumber(12)
  void clearNeedsSecondOpinion() => $_clearField(12);

  /// Every review, oldest first. `review` above stays the most recent.
  @$pb.TagNumber(13)
  $pb.PbList<LabelReview> get reviews => $_getList(12);
}

/// How much two reviewers agree, and whether that is more than chance.
///
/// Raw agreement flatters an imbalanced labelling task: two reviewers who both
/// answer "healthy" on a set that is ninety percent healthy agree ninety percent
/// of the time having demonstrated nothing. Kappa measures agreement above what
/// their individual answer rates would produce by chance.
class ReviewAgreement extends $pb.GeneratedMessage {
  factory ReviewAgreement({
    $core.int? compared,
    $core.double? rawAgreement,
    $core.double? kappa,
    $core.String? strength,
    $core.Iterable<LabelDisagreement>? disagreements,
  }) {
    final result = create();
    if (compared != null) result.compared = compared;
    if (rawAgreement != null) result.rawAgreement = rawAgreement;
    if (kappa != null) result.kappa = kappa;
    if (strength != null) result.strength = strength;
    if (disagreements != null) result.disagreements.addAll(disagreements);
    return result;
  }

  ReviewAgreement._();

  factory ReviewAgreement.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ReviewAgreement.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ReviewAgreement',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'compared')
    ..aD(2, _omitFieldNames ? '' : 'rawAgreement')
    ..aD(3, _omitFieldNames ? '' : 'kappa')
    ..aOS(4, _omitFieldNames ? '' : 'strength')
    ..pPM<LabelDisagreement>(5, _omitFieldNames ? '' : 'disagreements',
        subBuilder: LabelDisagreement.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReviewAgreement clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReviewAgreement copyWith(void Function(ReviewAgreement) updates) =>
      super.copyWith((message) => updates(message as ReviewAgreement))
          as ReviewAgreement;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReviewAgreement create() => ReviewAgreement._();
  @$core.override
  ReviewAgreement createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ReviewAgreement getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ReviewAgreement>(create);
  static ReviewAgreement? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get compared => $_getIZ(0);
  @$pb.TagNumber(1)
  set compared($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCompared() => $_has(0);
  @$pb.TagNumber(1)
  void clearCompared() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get rawAgreement => $_getN(1);
  @$pb.TagNumber(2)
  set rawAgreement($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRawAgreement() => $_has(1);
  @$pb.TagNumber(2)
  void clearRawAgreement() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get kappa => $_getN(2);
  @$pb.TagNumber(3)
  set kappa($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKappa() => $_has(2);
  @$pb.TagNumber(3)
  void clearKappa() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get strength => $_getSZ(3);
  @$pb.TagNumber(4)
  set strength($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStrength() => $_has(3);
  @$pb.TagNumber(4)
  void clearStrength() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<LabelDisagreement> get disagreements => $_getList(4);
}

class LabelDisagreement extends $pb.GeneratedMessage {
  factory LabelDisagreement({
    $core.String? first,
    $core.String? second,
    $core.int? count,
  }) {
    final result = create();
    if (first != null) result.first = first;
    if (second != null) result.second = second;
    if (count != null) result.count = count;
    return result;
  }

  LabelDisagreement._();

  factory LabelDisagreement.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LabelDisagreement.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LabelDisagreement',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'first')
    ..aOS(2, _omitFieldNames ? '' : 'second')
    ..aI(3, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelDisagreement clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LabelDisagreement copyWith(void Function(LabelDisagreement) updates) =>
      super.copyWith((message) => updates(message as LabelDisagreement))
          as LabelDisagreement;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LabelDisagreement create() => LabelDisagreement._();
  @$core.override
  LabelDisagreement createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LabelDisagreement getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LabelDisagreement>(create);
  static LabelDisagreement? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get first => $_getSZ(0);
  @$pb.TagNumber(1)
  set first($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFirst() => $_has(0);
  @$pb.TagNumber(1)
  void clearFirst() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get second => $_getSZ(1);
  @$pb.TagNumber(2)
  set second($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSecond() => $_has(1);
  @$pb.TagNumber(2)
  void clearSecond() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get count => $_getIZ(2);
  @$pb.TagNumber(3)
  set count($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearCount() => $_clearField(3);
}

class RequestSecondOpinionRequest extends $pb.GeneratedMessage {
  factory RequestSecondOpinionRequest({
    $core.String? task,
    $core.String? sampleId,
    $core.String? tenantId,
    $core.bool? wanted,
  }) {
    final result = create();
    if (task != null) result.task = task;
    if (sampleId != null) result.sampleId = sampleId;
    if (tenantId != null) result.tenantId = tenantId;
    if (wanted != null) result.wanted = wanted;
    return result;
  }

  RequestSecondOpinionRequest._();

  factory RequestSecondOpinionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestSecondOpinionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestSecondOpinionRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'task')
    ..aOS(2, _omitFieldNames ? '' : 'sampleId')
    ..aOS(3, _omitFieldNames ? '' : 'tenantId')
    ..aOB(4, _omitFieldNames ? '' : 'wanted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestSecondOpinionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestSecondOpinionRequest copyWith(
          void Function(RequestSecondOpinionRequest) updates) =>
      super.copyWith(
              (message) => updates(message as RequestSecondOpinionRequest))
          as RequestSecondOpinionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestSecondOpinionRequest create() =>
      RequestSecondOpinionRequest._();
  @$core.override
  RequestSecondOpinionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestSecondOpinionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestSecondOpinionRequest>(create);
  static RequestSecondOpinionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get task => $_getSZ(0);
  @$pb.TagNumber(1)
  set task($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sampleId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sampleId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSampleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSampleId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tenantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set tenantId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTenantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTenantId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get wanted => $_getBF(3);
  @$pb.TagNumber(4)
  set wanted($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWanted() => $_has(3);
  @$pb.TagNumber(4)
  void clearWanted() => $_clearField(4);
}

class RequestSecondOpinionResponse extends $pb.GeneratedMessage {
  factory RequestSecondOpinionResponse({
    TrainingSampleInfo? sample,
  }) {
    final result = create();
    if (sample != null) result.sample = sample;
    return result;
  }

  RequestSecondOpinionResponse._();

  factory RequestSecondOpinionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RequestSecondOpinionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RequestSecondOpinionResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOM<TrainingSampleInfo>(1, _omitFieldNames ? '' : 'sample',
        subBuilder: TrainingSampleInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestSecondOpinionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RequestSecondOpinionResponse copyWith(
          void Function(RequestSecondOpinionResponse) updates) =>
      super.copyWith(
              (message) => updates(message as RequestSecondOpinionResponse))
          as RequestSecondOpinionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RequestSecondOpinionResponse create() =>
      RequestSecondOpinionResponse._();
  @$core.override
  RequestSecondOpinionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RequestSecondOpinionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RequestSecondOpinionResponse>(create);
  static RequestSecondOpinionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TrainingSampleInfo get sample => $_getN(0);
  @$pb.TagNumber(1)
  set sample(TrainingSampleInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSample() => $_has(0);
  @$pb.TagNumber(1)
  void clearSample() => $_clearField(1);
  @$pb.TagNumber(1)
  TrainingSampleInfo ensureSample() => $_ensure(0);
}

class GetReviewAgreementRequest extends $pb.GeneratedMessage {
  factory GetReviewAgreementRequest({
    $core.String? task,
    $core.String? tenantId,
  }) {
    final result = create();
    if (task != null) result.task = task;
    if (tenantId != null) result.tenantId = tenantId;
    return result;
  }

  GetReviewAgreementRequest._();

  factory GetReviewAgreementRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReviewAgreementRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReviewAgreementRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'task')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReviewAgreementRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReviewAgreementRequest copyWith(
          void Function(GetReviewAgreementRequest) updates) =>
      super.copyWith((message) => updates(message as GetReviewAgreementRequest))
          as GetReviewAgreementRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReviewAgreementRequest create() => GetReviewAgreementRequest._();
  @$core.override
  GetReviewAgreementRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReviewAgreementRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReviewAgreementRequest>(create);
  static GetReviewAgreementRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get task => $_getSZ(0);
  @$pb.TagNumber(1)
  set task($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);
}

class GetReviewAgreementResponse extends $pb.GeneratedMessage {
  factory GetReviewAgreementResponse({
    ReviewAgreement? agreement,
  }) {
    final result = create();
    if (agreement != null) result.agreement = agreement;
    return result;
  }

  GetReviewAgreementResponse._();

  factory GetReviewAgreementResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetReviewAgreementResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetReviewAgreementResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOM<ReviewAgreement>(1, _omitFieldNames ? '' : 'agreement',
        subBuilder: ReviewAgreement.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReviewAgreementResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetReviewAgreementResponse copyWith(
          void Function(GetReviewAgreementResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetReviewAgreementResponse))
          as GetReviewAgreementResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetReviewAgreementResponse create() => GetReviewAgreementResponse._();
  @$core.override
  GetReviewAgreementResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetReviewAgreementResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetReviewAgreementResponse>(create);
  static GetReviewAgreementResponse? _defaultInstance;

  @$pb.TagNumber(1)
  ReviewAgreement get agreement => $_getN(0);
  @$pb.TagNumber(1)
  set agreement(ReviewAgreement value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAgreement() => $_has(0);
  @$pb.TagNumber(1)
  void clearAgreement() => $_clearField(1);
  @$pb.TagNumber(1)
  ReviewAgreement ensureAgreement() => $_ensure(0);
}

class ListTrainingSamplesRequest extends $pb.GeneratedMessage {
  factory ListTrainingSamplesRequest({
    $core.String? task,
    $core.String? reviewStatus,
    $core.String? tenantId,
    $core.double? minConfidence,
    $core.double? maxConfidence,
    $core.String? provenance,
    $core.int? pageSize,
    $core.int? pageOffset,
    $core.String? order,
    $core.bool? suspectOnly,
    $core.bool? secondOpinionOnly,
  }) {
    final result = create();
    if (task != null) result.task = task;
    if (reviewStatus != null) result.reviewStatus = reviewStatus;
    if (tenantId != null) result.tenantId = tenantId;
    if (minConfidence != null) result.minConfidence = minConfidence;
    if (maxConfidence != null) result.maxConfidence = maxConfidence;
    if (provenance != null) result.provenance = provenance;
    if (pageSize != null) result.pageSize = pageSize;
    if (pageOffset != null) result.pageOffset = pageOffset;
    if (order != null) result.order = order;
    if (suspectOnly != null) result.suspectOnly = suspectOnly;
    if (secondOpinionOnly != null) result.secondOpinionOnly = secondOpinionOnly;
    return result;
  }

  ListTrainingSamplesRequest._();

  factory ListTrainingSamplesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTrainingSamplesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTrainingSamplesRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'task')
    ..aOS(2, _omitFieldNames ? '' : 'reviewStatus')
    ..aOS(3, _omitFieldNames ? '' : 'tenantId')
    ..aD(4, _omitFieldNames ? '' : 'minConfidence')
    ..aD(5, _omitFieldNames ? '' : 'maxConfidence')
    ..aOS(6, _omitFieldNames ? '' : 'provenance')
    ..aI(7, _omitFieldNames ? '' : 'pageSize')
    ..aI(8, _omitFieldNames ? '' : 'pageOffset')
    ..aOS(9, _omitFieldNames ? '' : 'order')
    ..aOB(10, _omitFieldNames ? '' : 'suspectOnly')
    ..aOB(11, _omitFieldNames ? '' : 'secondOpinionOnly')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTrainingSamplesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTrainingSamplesRequest copyWith(
          void Function(ListTrainingSamplesRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ListTrainingSamplesRequest))
          as ListTrainingSamplesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTrainingSamplesRequest create() => ListTrainingSamplesRequest._();
  @$core.override
  ListTrainingSamplesRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTrainingSamplesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTrainingSamplesRequest>(create);
  static ListTrainingSamplesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get task => $_getSZ(0);
  @$pb.TagNumber(1)
  set task($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get reviewStatus => $_getSZ(1);
  @$pb.TagNumber(2)
  set reviewStatus($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasReviewStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearReviewStatus() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tenantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set tenantId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTenantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTenantId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get minConfidence => $_getN(3);
  @$pb.TagNumber(4)
  set minConfidence($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMinConfidence() => $_has(3);
  @$pb.TagNumber(4)
  void clearMinConfidence() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get maxConfidence => $_getN(4);
  @$pb.TagNumber(5)
  set maxConfidence($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMaxConfidence() => $_has(4);
  @$pb.TagNumber(5)
  void clearMaxConfidence() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get provenance => $_getSZ(5);
  @$pb.TagNumber(6)
  set provenance($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProvenance() => $_has(5);
  @$pb.TagNumber(6)
  void clearProvenance() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get pageSize => $_getIZ(6);
  @$pb.TagNumber(7)
  set pageSize($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPageSize() => $_has(6);
  @$pb.TagNumber(7)
  void clearPageSize() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get pageOffset => $_getIZ(7);
  @$pb.TagNumber(8)
  set pageOffset($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPageOffset() => $_has(7);
  @$pb.TagNumber(8)
  void clearPageOffset() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get order => $_getSZ(8);
  @$pb.TagNumber(9)
  set order($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasOrder() => $_has(8);
  @$pb.TagNumber(9)
  void clearOrder() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get suspectOnly => $_getBF(9);
  @$pb.TagNumber(10)
  set suspectOnly($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasSuspectOnly() => $_has(9);
  @$pb.TagNumber(10)
  void clearSuspectOnly() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.bool get secondOpinionOnly => $_getBF(10);
  @$pb.TagNumber(11)
  set secondOpinionOnly($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSecondOpinionOnly() => $_has(10);
  @$pb.TagNumber(11)
  void clearSecondOpinionOnly() => $_clearField(11);
}

class ListTrainingSamplesResponse extends $pb.GeneratedMessage {
  factory ListTrainingSamplesResponse({
    $core.Iterable<TrainingSampleInfo>? samples,
    $core.int? totalCount,
    $core.int? unreviewedCount,
  }) {
    final result = create();
    if (samples != null) result.samples.addAll(samples);
    if (totalCount != null) result.totalCount = totalCount;
    if (unreviewedCount != null) result.unreviewedCount = unreviewedCount;
    return result;
  }

  ListTrainingSamplesResponse._();

  factory ListTrainingSamplesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTrainingSamplesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTrainingSamplesResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..pPM<TrainingSampleInfo>(1, _omitFieldNames ? '' : 'samples',
        subBuilder: TrainingSampleInfo.create)
    ..aI(2, _omitFieldNames ? '' : 'totalCount')
    ..aI(3, _omitFieldNames ? '' : 'unreviewedCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTrainingSamplesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTrainingSamplesResponse copyWith(
          void Function(ListTrainingSamplesResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ListTrainingSamplesResponse))
          as ListTrainingSamplesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTrainingSamplesResponse create() =>
      ListTrainingSamplesResponse._();
  @$core.override
  ListTrainingSamplesResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTrainingSamplesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTrainingSamplesResponse>(create);
  static ListTrainingSamplesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TrainingSampleInfo> get samples => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get totalCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get unreviewedCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set unreviewedCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnreviewedCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnreviewedCount() => $_clearField(3);
}

class SubmitLabelReviewRequest extends $pb.GeneratedMessage {
  factory SubmitLabelReviewRequest({
    $core.String? task,
    $core.String? sampleId,
    LabelReview? review,
  }) {
    final result = create();
    if (task != null) result.task = task;
    if (sampleId != null) result.sampleId = sampleId;
    if (review != null) result.review = review;
    return result;
  }

  SubmitLabelReviewRequest._();

  factory SubmitLabelReviewRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubmitLabelReviewRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmitLabelReviewRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'task')
    ..aOS(2, _omitFieldNames ? '' : 'sampleId')
    ..aOM<LabelReview>(3, _omitFieldNames ? '' : 'review',
        subBuilder: LabelReview.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitLabelReviewRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitLabelReviewRequest copyWith(
          void Function(SubmitLabelReviewRequest) updates) =>
      super.copyWith((message) => updates(message as SubmitLabelReviewRequest))
          as SubmitLabelReviewRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitLabelReviewRequest create() => SubmitLabelReviewRequest._();
  @$core.override
  SubmitLabelReviewRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubmitLabelReviewRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitLabelReviewRequest>(create);
  static SubmitLabelReviewRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get task => $_getSZ(0);
  @$pb.TagNumber(1)
  set task($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sampleId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sampleId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSampleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSampleId() => $_clearField(2);

  @$pb.TagNumber(3)
  LabelReview get review => $_getN(2);
  @$pb.TagNumber(3)
  set review(LabelReview value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasReview() => $_has(2);
  @$pb.TagNumber(3)
  void clearReview() => $_clearField(3);
  @$pb.TagNumber(3)
  LabelReview ensureReview() => $_ensure(2);
}

class SubmitLabelReviewResponse extends $pb.GeneratedMessage {
  factory SubmitLabelReviewResponse({
    TrainingSampleInfo? sample,
  }) {
    final result = create();
    if (sample != null) result.sample = sample;
    return result;
  }

  SubmitLabelReviewResponse._();

  factory SubmitLabelReviewResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SubmitLabelReviewResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubmitLabelReviewResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOM<TrainingSampleInfo>(1, _omitFieldNames ? '' : 'sample',
        subBuilder: TrainingSampleInfo.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitLabelReviewResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitLabelReviewResponse copyWith(
          void Function(SubmitLabelReviewResponse) updates) =>
      super.copyWith((message) => updates(message as SubmitLabelReviewResponse))
          as SubmitLabelReviewResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitLabelReviewResponse create() => SubmitLabelReviewResponse._();
  @$core.override
  SubmitLabelReviewResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SubmitLabelReviewResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitLabelReviewResponse>(create);
  static SubmitLabelReviewResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TrainingSampleInfo get sample => $_getN(0);
  @$pb.TagNumber(1)
  set sample(TrainingSampleInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSample() => $_has(0);
  @$pb.TagNumber(1)
  void clearSample() => $_clearField(1);
  @$pb.TagNumber(1)
  TrainingSampleInfo ensureSample() => $_ensure(0);
}

class GetTrainingSampleImageRequest extends $pb.GeneratedMessage {
  factory GetTrainingSampleImageRequest({
    $core.String? task,
    $core.String? sampleId,
    $core.String? tenantId,
  }) {
    final result = create();
    if (task != null) result.task = task;
    if (sampleId != null) result.sampleId = sampleId;
    if (tenantId != null) result.tenantId = tenantId;
    return result;
  }

  GetTrainingSampleImageRequest._();

  factory GetTrainingSampleImageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTrainingSampleImageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTrainingSampleImageRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'task')
    ..aOS(2, _omitFieldNames ? '' : 'sampleId')
    ..aOS(3, _omitFieldNames ? '' : 'tenantId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTrainingSampleImageRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTrainingSampleImageRequest copyWith(
          void Function(GetTrainingSampleImageRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GetTrainingSampleImageRequest))
          as GetTrainingSampleImageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTrainingSampleImageRequest create() =>
      GetTrainingSampleImageRequest._();
  @$core.override
  GetTrainingSampleImageRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTrainingSampleImageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTrainingSampleImageRequest>(create);
  static GetTrainingSampleImageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get task => $_getSZ(0);
  @$pb.TagNumber(1)
  set task($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTask() => $_has(0);
  @$pb.TagNumber(1)
  void clearTask() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get sampleId => $_getSZ(1);
  @$pb.TagNumber(2)
  set sampleId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSampleId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSampleId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tenantId => $_getSZ(2);
  @$pb.TagNumber(3)
  set tenantId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTenantId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTenantId() => $_clearField(3);
}

class GetTrainingSampleImageResponse extends $pb.GeneratedMessage {
  factory GetTrainingSampleImageResponse({
    $core.List<$core.int>? imageBytes,
    $core.String? mimeType,
  }) {
    final result = create();
    if (imageBytes != null) result.imageBytes = imageBytes;
    if (mimeType != null) result.mimeType = mimeType;
    return result;
  }

  GetTrainingSampleImageResponse._();

  factory GetTrainingSampleImageResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTrainingSampleImageResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTrainingSampleImageResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'imageBytes', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'mimeType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTrainingSampleImageResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTrainingSampleImageResponse copyWith(
          void Function(GetTrainingSampleImageResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GetTrainingSampleImageResponse))
          as GetTrainingSampleImageResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTrainingSampleImageResponse create() =>
      GetTrainingSampleImageResponse._();
  @$core.override
  GetTrainingSampleImageResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTrainingSampleImageResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTrainingSampleImageResponse>(create);
  static GetTrainingSampleImageResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get imageBytes => $_getN(0);
  @$pb.TagNumber(1)
  set imageBytes($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasImageBytes() => $_has(0);
  @$pb.TagNumber(1)
  void clearImageBytes() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get mimeType => $_getSZ(1);
  @$pb.TagNumber(2)
  set mimeType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMimeType() => $_has(1);
  @$pb.TagNumber(2)
  void clearMimeType() => $_clearField(2);
}

class ClassifyPlantResponse extends $pb.GeneratedMessage {
  factory ClassifyPlantResponse({
    $core.String? requestId,
    PlantClassification? species,
    $core.String? modelVersion,
    $fixnum.Int64? processingTimeMs,
    $core.Iterable<Explanation>? explanations,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (species != null) result.species = species;
    if (modelVersion != null) result.modelVersion = modelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    if (explanations != null) result.explanations.addAll(explanations);
    return result;
  }

  ClassifyPlantResponse._();

  factory ClassifyPlantResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClassifyPlantResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClassifyPlantResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOM<PlantClassification>(2, _omitFieldNames ? '' : 'species',
        subBuilder: PlantClassification.create)
    ..aOS(3, _omitFieldNames ? '' : 'modelVersion')
    ..aInt64(4, _omitFieldNames ? '' : 'processingTimeMs')
    ..pPM<Explanation>(5, _omitFieldNames ? '' : 'explanations',
        subBuilder: Explanation.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClassifyPlantResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClassifyPlantResponse copyWith(
          void Function(ClassifyPlantResponse) updates) =>
      super.copyWith((message) => updates(message as ClassifyPlantResponse))
          as ClassifyPlantResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClassifyPlantResponse create() => ClassifyPlantResponse._();
  @$core.override
  ClassifyPlantResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClassifyPlantResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClassifyPlantResponse>(create);
  static ClassifyPlantResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  PlantClassification get species => $_getN(1);
  @$pb.TagNumber(2)
  set species(PlantClassification value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSpecies() => $_has(1);
  @$pb.TagNumber(2)
  void clearSpecies() => $_clearField(2);
  @$pb.TagNumber(2)
  PlantClassification ensureSpecies() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get modelVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set modelVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasModelVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearModelVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get processingTimeMs => $_getI64(3);
  @$pb.TagNumber(4)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProcessingTimeMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearProcessingTimeMs() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<Explanation> get explanations => $_getList(4);
}

class PlantClassification extends $pb.GeneratedMessage {
  factory PlantClassification({
    $core.String? speciesId,
    $core.String? commonName,
    $core.String? scientificName,
    $core.String? family,
    $core.double? confidence,
  }) {
    final result = create();
    if (speciesId != null) result.speciesId = speciesId;
    if (commonName != null) result.commonName = commonName;
    if (scientificName != null) result.scientificName = scientificName;
    if (family != null) result.family = family;
    if (confidence != null) result.confidence = confidence;
    return result;
  }

  PlantClassification._();

  factory PlantClassification.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PlantClassification.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PlantClassification',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'speciesId')
    ..aOS(2, _omitFieldNames ? '' : 'commonName')
    ..aOS(3, _omitFieldNames ? '' : 'scientificName')
    ..aOS(4, _omitFieldNames ? '' : 'family')
    ..aD(5, _omitFieldNames ? '' : 'confidence')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlantClassification clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PlantClassification copyWith(void Function(PlantClassification) updates) =>
      super.copyWith((message) => updates(message as PlantClassification))
          as PlantClassification;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlantClassification create() => PlantClassification._();
  @$core.override
  PlantClassification createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PlantClassification getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PlantClassification>(create);
  static PlantClassification? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get speciesId => $_getSZ(0);
  @$pb.TagNumber(1)
  set speciesId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSpeciesId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSpeciesId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get commonName => $_getSZ(1);
  @$pb.TagNumber(2)
  set commonName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCommonName() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommonName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get scientificName => $_getSZ(2);
  @$pb.TagNumber(3)
  set scientificName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScientificName() => $_has(2);
  @$pb.TagNumber(3)
  void clearScientificName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get family => $_getSZ(3);
  @$pb.TagNumber(4)
  set family($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFamily() => $_has(3);
  @$pb.TagNumber(4)
  void clearFamily() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get confidence => $_getN(4);
  @$pb.TagNumber(5)
  set confidence($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConfidence() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfidence() => $_clearField(5);
}

class PredictYieldRequest extends $pb.GeneratedMessage {
  factory PredictYieldRequest({
    $core.String? requestId,
    $core.String? cropType,
    EnvironmentFactors? environment,
    SoilFactors? soil,
    ManagementFactors? management,
    $core.double? fieldAreaHectares,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (cropType != null) result.cropType = cropType;
    if (environment != null) result.environment = environment;
    if (soil != null) result.soil = soil;
    if (management != null) result.management = management;
    if (fieldAreaHectares != null) result.fieldAreaHectares = fieldAreaHectares;
    return result;
  }

  PredictYieldRequest._();

  factory PredictYieldRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PredictYieldRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PredictYieldRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'cropType')
    ..aOM<EnvironmentFactors>(3, _omitFieldNames ? '' : 'environment',
        subBuilder: EnvironmentFactors.create)
    ..aOM<SoilFactors>(4, _omitFieldNames ? '' : 'soil',
        subBuilder: SoilFactors.create)
    ..aOM<ManagementFactors>(5, _omitFieldNames ? '' : 'management',
        subBuilder: ManagementFactors.create)
    ..aD(6, _omitFieldNames ? '' : 'fieldAreaHectares')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PredictYieldRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PredictYieldRequest copyWith(void Function(PredictYieldRequest) updates) =>
      super.copyWith((message) => updates(message as PredictYieldRequest))
          as PredictYieldRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PredictYieldRequest create() => PredictYieldRequest._();
  @$core.override
  PredictYieldRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PredictYieldRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PredictYieldRequest>(create);
  static PredictYieldRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cropType => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropType() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropType() => $_clearField(2);

  @$pb.TagNumber(3)
  EnvironmentFactors get environment => $_getN(2);
  @$pb.TagNumber(3)
  set environment(EnvironmentFactors value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEnvironment() => $_has(2);
  @$pb.TagNumber(3)
  void clearEnvironment() => $_clearField(3);
  @$pb.TagNumber(3)
  EnvironmentFactors ensureEnvironment() => $_ensure(2);

  @$pb.TagNumber(4)
  SoilFactors get soil => $_getN(3);
  @$pb.TagNumber(4)
  set soil(SoilFactors value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSoil() => $_has(3);
  @$pb.TagNumber(4)
  void clearSoil() => $_clearField(4);
  @$pb.TagNumber(4)
  SoilFactors ensureSoil() => $_ensure(3);

  @$pb.TagNumber(5)
  ManagementFactors get management => $_getN(4);
  @$pb.TagNumber(5)
  set management(ManagementFactors value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasManagement() => $_has(4);
  @$pb.TagNumber(5)
  void clearManagement() => $_clearField(5);
  @$pb.TagNumber(5)
  ManagementFactors ensureManagement() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.double get fieldAreaHectares => $_getN(5);
  @$pb.TagNumber(6)
  set fieldAreaHectares($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFieldAreaHectares() => $_has(5);
  @$pb.TagNumber(6)
  void clearFieldAreaHectares() => $_clearField(6);
}

/// How much each input moved a numeric prediction away from a typical one.
///
/// Shapley values: the contributions sum to prediction minus baseline, an input
/// the model ignores gets exactly zero, and inputs that act alike get the same
/// number. That makes the split checkable rather than merely plausible.
class FeatureAttribution extends $pb.GeneratedMessage {
  factory FeatureAttribution({
    $core.String? feature,
    $core.double? value,
    $core.double? contribution,
  }) {
    final result = create();
    if (feature != null) result.feature = feature;
    if (value != null) result.value = value;
    if (contribution != null) result.contribution = contribution;
    return result;
  }

  FeatureAttribution._();

  factory FeatureAttribution.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FeatureAttribution.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FeatureAttribution',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'feature')
    ..aD(2, _omitFieldNames ? '' : 'value')
    ..aD(3, _omitFieldNames ? '' : 'contribution')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeatureAttribution clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeatureAttribution copyWith(void Function(FeatureAttribution) updates) =>
      super.copyWith((message) => updates(message as FeatureAttribution))
          as FeatureAttribution;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FeatureAttribution create() => FeatureAttribution._();
  @$core.override
  FeatureAttribution createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FeatureAttribution getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FeatureAttribution>(create);
  static FeatureAttribution? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get feature => $_getSZ(0);
  @$pb.TagNumber(1)
  set feature($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFeature() => $_has(0);
  @$pb.TagNumber(1)
  void clearFeature() => $_clearField(1);

  /// The feature's value for this prediction.
  @$pb.TagNumber(2)
  $core.double get value => $_getN(1);
  @$pb.TagNumber(2)
  set value($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearValue() => $_clearField(2);

  /// How much it moved the prediction, in the prediction's own units.
  @$pb.TagNumber(3)
  $core.double get contribution => $_getN(2);
  @$pb.TagNumber(3)
  set contribution($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasContribution() => $_has(2);
  @$pb.TagNumber(3)
  void clearContribution() => $_clearField(3);
}

class AttributionSummary extends $pb.GeneratedMessage {
  factory AttributionSummary({
    $core.double? baseline,
    $core.double? prediction,
    $core.Iterable<FeatureAttribution>? features,
    $core.double? attributedShare,
    $core.String? method,
    $core.double? residual,
    $core.String? summary,
    $core.String? units,
  }) {
    final result = create();
    if (baseline != null) result.baseline = baseline;
    if (prediction != null) result.prediction = prediction;
    if (features != null) result.features.addAll(features);
    if (attributedShare != null) result.attributedShare = attributedShare;
    if (method != null) result.method = method;
    if (residual != null) result.residual = residual;
    if (summary != null) result.summary = summary;
    if (units != null) result.units = units;
    return result;
  }

  AttributionSummary._();

  factory AttributionSummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AttributionSummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AttributionSummary',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'baseline')
    ..aD(2, _omitFieldNames ? '' : 'prediction')
    ..pPM<FeatureAttribution>(3, _omitFieldNames ? '' : 'features',
        subBuilder: FeatureAttribution.create)
    ..aD(4, _omitFieldNames ? '' : 'attributedShare')
    ..aOS(5, _omitFieldNames ? '' : 'method')
    ..aD(6, _omitFieldNames ? '' : 'residual')
    ..aOS(7, _omitFieldNames ? '' : 'summary')
    ..aOS(8, _omitFieldNames ? '' : 'units')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttributionSummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AttributionSummary copyWith(void Function(AttributionSummary) updates) =>
      super.copyWith((message) => updates(message as AttributionSummary))
          as AttributionSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AttributionSummary create() => AttributionSummary._();
  @$core.override
  AttributionSummary createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AttributionSummary getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AttributionSummary>(create);
  static AttributionSummary? _defaultInstance;

  /// What the model says about a typical case: the point contributions are
  /// measured from.
  @$pb.TagNumber(1)
  $core.double get baseline => $_getN(0);
  @$pb.TagNumber(1)
  set baseline($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBaseline() => $_has(0);
  @$pb.TagNumber(1)
  void clearBaseline() => $_clearField(1);

  /// The prediction that was attributed. For a blended estimate this is the
  /// learned component, not necessarily the number that was served.
  @$pb.TagNumber(2)
  $core.double get prediction => $_getN(1);
  @$pb.TagNumber(2)
  set prediction($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPrediction() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrediction() => $_clearField(2);

  /// Largest absolute contribution first.
  @$pb.TagNumber(3)
  $pb.PbList<FeatureAttribution> get features => $_getList(2);

  /// Share of the served number this attribution accounts for (0..1). Below 1
  /// when the served value blends an unattributed component.
  @$pb.TagNumber(4)
  $core.double get attributedShare => $_getN(3);
  @$pb.TagNumber(4)
  set attributedShare($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAttributedShare() => $_has(3);
  @$pb.TagNumber(4)
  void clearAttributedShare() => $_clearField(4);

  /// How the split was computed, e.g. "shapley-sampling" or "shapley-exact".
  @$pb.TagNumber(5)
  $core.String get method => $_getSZ(4);
  @$pb.TagNumber(5)
  set method($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMethod() => $_has(4);
  @$pb.TagNumber(5)
  void clearMethod() => $_clearField(5);

  /// Gap the contributions do not explain; zero for exact attribution, Monte
  /// Carlo error for the sampled estimator.
  @$pb.TagNumber(6)
  $core.double get residual => $_getN(5);
  @$pb.TagNumber(6)
  set residual($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasResidual() => $_has(5);
  @$pb.TagNumber(6)
  void clearResidual() => $_clearField(6);

  /// One sentence naming the main drivers, for display.
  @$pb.TagNumber(7)
  $core.String get summary => $_getSZ(6);
  @$pb.TagNumber(7)
  set summary($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSummary() => $_has(6);
  @$pb.TagNumber(7)
  void clearSummary() => $_clearField(7);

  /// Units the contributions are expressed in, e.g. "kg/ha".
  @$pb.TagNumber(8)
  $core.String get units => $_getSZ(7);
  @$pb.TagNumber(8)
  set units($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUnits() => $_has(7);
  @$pb.TagNumber(8)
  void clearUnits() => $_clearField(8);
}

class PredictYieldResponse extends $pb.GeneratedMessage {
  factory PredictYieldResponse({
    $core.String? requestId,
    $core.double? predictedYieldKgPerHectare,
    $core.double? confidencePct,
    $core.double? yieldLowerBound,
    $core.double? yieldUpperBound,
    $core.Iterable<StressFactor>? stressFactors,
    $core.String? modelVersion,
    $fixnum.Int64? processingTimeMs,
    $core.String? modelSource,
    $core.double? tabularWeight,
    $core.bool? cropSupported,
    $core.double? intervalCoverage,
    $core.double? parametricYieldKgPerHectare,
    AttributionSummary? attribution,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (predictedYieldKgPerHectare != null)
      result.predictedYieldKgPerHectare = predictedYieldKgPerHectare;
    if (confidencePct != null) result.confidencePct = confidencePct;
    if (yieldLowerBound != null) result.yieldLowerBound = yieldLowerBound;
    if (yieldUpperBound != null) result.yieldUpperBound = yieldUpperBound;
    if (stressFactors != null) result.stressFactors.addAll(stressFactors);
    if (modelVersion != null) result.modelVersion = modelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    if (modelSource != null) result.modelSource = modelSource;
    if (tabularWeight != null) result.tabularWeight = tabularWeight;
    if (cropSupported != null) result.cropSupported = cropSupported;
    if (intervalCoverage != null) result.intervalCoverage = intervalCoverage;
    if (parametricYieldKgPerHectare != null)
      result.parametricYieldKgPerHectare = parametricYieldKgPerHectare;
    if (attribution != null) result.attribution = attribution;
    return result;
  }

  PredictYieldResponse._();

  factory PredictYieldResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PredictYieldResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PredictYieldResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aD(2, _omitFieldNames ? '' : 'predictedYieldKgPerHectare')
    ..aD(3, _omitFieldNames ? '' : 'confidencePct')
    ..aD(4, _omitFieldNames ? '' : 'yieldLowerBound')
    ..aD(5, _omitFieldNames ? '' : 'yieldUpperBound')
    ..pPM<StressFactor>(6, _omitFieldNames ? '' : 'stressFactors',
        subBuilder: StressFactor.create)
    ..aOS(7, _omitFieldNames ? '' : 'modelVersion')
    ..aInt64(8, _omitFieldNames ? '' : 'processingTimeMs')
    ..aOS(9, _omitFieldNames ? '' : 'modelSource')
    ..aD(10, _omitFieldNames ? '' : 'tabularWeight')
    ..aOB(11, _omitFieldNames ? '' : 'cropSupported')
    ..aD(12, _omitFieldNames ? '' : 'intervalCoverage')
    ..aD(13, _omitFieldNames ? '' : 'parametricYieldKgPerHectare')
    ..aOM<AttributionSummary>(14, _omitFieldNames ? '' : 'attribution',
        subBuilder: AttributionSummary.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PredictYieldResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PredictYieldResponse copyWith(void Function(PredictYieldResponse) updates) =>
      super.copyWith((message) => updates(message as PredictYieldResponse))
          as PredictYieldResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PredictYieldResponse create() => PredictYieldResponse._();
  @$core.override
  PredictYieldResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PredictYieldResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PredictYieldResponse>(create);
  static PredictYieldResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get predictedYieldKgPerHectare => $_getN(1);
  @$pb.TagNumber(2)
  set predictedYieldKgPerHectare($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPredictedYieldKgPerHectare() => $_has(1);
  @$pb.TagNumber(2)
  void clearPredictedYieldKgPerHectare() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get confidencePct => $_getN(2);
  @$pb.TagNumber(3)
  set confidencePct($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConfidencePct() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfidencePct() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get yieldLowerBound => $_getN(3);
  @$pb.TagNumber(4)
  set yieldLowerBound($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasYieldLowerBound() => $_has(3);
  @$pb.TagNumber(4)
  void clearYieldLowerBound() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get yieldUpperBound => $_getN(4);
  @$pb.TagNumber(5)
  set yieldUpperBound($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasYieldUpperBound() => $_has(4);
  @$pb.TagNumber(5)
  void clearYieldUpperBound() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<StressFactor> get stressFactors => $_getList(5);

  @$pb.TagNumber(7)
  $core.String get modelVersion => $_getSZ(6);
  @$pb.TagNumber(7)
  set modelVersion($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasModelVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearModelVersion() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get processingTimeMs => $_getI64(7);
  @$pb.TagNumber(8)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasProcessingTimeMs() => $_has(7);
  @$pb.TagNumber(8)
  void clearProcessingTimeMs() => $_clearField(8);

  /// Provenance of the point estimate: "parametric", "tabular", or "blended".
  @$pb.TagNumber(9)
  $core.String get modelSource => $_getSZ(8);
  @$pb.TagNumber(9)
  set modelSource($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasModelSource() => $_has(8);
  @$pb.TagNumber(9)
  void clearModelSource() => $_clearField(9);

  /// Weight given to the trained tabular model in a blended estimate (0..1).
  @$pb.TagNumber(10)
  $core.double get tabularWeight => $_getN(9);
  @$pb.TagNumber(10)
  set tabularWeight($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTabularWeight() => $_has(9);
  @$pb.TagNumber(10)
  void clearTabularWeight() => $_clearField(10);

  /// False when crop_type was not recognized and generic wheat parameters were used.
  @$pb.TagNumber(11)
  $core.bool get cropSupported => $_getBF(10);
  @$pb.TagNumber(11)
  set cropSupported($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasCropSupported() => $_has(10);
  @$pb.TagNumber(11)
  void clearCropSupported() => $_clearField(11);

  /// Nominal coverage of [yield_lower_bound, yield_upper_bound] (e.g. 0.9); 0 when heuristic.
  @$pb.TagNumber(12)
  $core.double get intervalCoverage => $_getN(11);
  @$pb.TagNumber(12)
  set intervalCoverage($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasIntervalCoverage() => $_has(11);
  @$pb.TagNumber(12)
  void clearIntervalCoverage() => $_clearField(12);

  /// Parametric (stress-factor) estimate, kept for transparency when blended.
  @$pb.TagNumber(13)
  $core.double get parametricYieldKgPerHectare => $_getN(12);
  @$pb.TagNumber(13)
  set parametricYieldKgPerHectare($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasParametricYieldKgPerHectare() => $_has(12);
  @$pb.TagNumber(13)
  void clearParametricYieldKgPerHectare() => $_clearField(13);

  /// Why this number: the learned model's inputs, ranked by how much each moved
  /// it. Absent when no trained model contributed, or when the model was
  /// trained before it kept a reference set to compare against.
  @$pb.TagNumber(14)
  AttributionSummary get attribution => $_getN(13);
  @$pb.TagNumber(14)
  set attribution(AttributionSummary value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasAttribution() => $_has(13);
  @$pb.TagNumber(14)
  void clearAttribution() => $_clearField(14);
  @$pb.TagNumber(14)
  AttributionSummary ensureAttribution() => $_ensure(13);
}

class EnvironmentFactors extends $pb.GeneratedMessage {
  factory EnvironmentFactors({
    $core.double? temperatureCelsius,
    $core.double? humidityPct,
    $core.double? rainfallMm,
    $core.double? solarRadiation,
    $core.double? windSpeedKmh,
    $core.double? growingDegreeDays,
    $core.int? frostDays,
    $core.int? heatStressDays,
  }) {
    final result = create();
    if (temperatureCelsius != null)
      result.temperatureCelsius = temperatureCelsius;
    if (humidityPct != null) result.humidityPct = humidityPct;
    if (rainfallMm != null) result.rainfallMm = rainfallMm;
    if (solarRadiation != null) result.solarRadiation = solarRadiation;
    if (windSpeedKmh != null) result.windSpeedKmh = windSpeedKmh;
    if (growingDegreeDays != null) result.growingDegreeDays = growingDegreeDays;
    if (frostDays != null) result.frostDays = frostDays;
    if (heatStressDays != null) result.heatStressDays = heatStressDays;
    return result;
  }

  EnvironmentFactors._();

  factory EnvironmentFactors.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EnvironmentFactors.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EnvironmentFactors',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'temperatureCelsius')
    ..aD(2, _omitFieldNames ? '' : 'humidityPct')
    ..aD(3, _omitFieldNames ? '' : 'rainfallMm')
    ..aD(4, _omitFieldNames ? '' : 'solarRadiation')
    ..aD(5, _omitFieldNames ? '' : 'windSpeedKmh')
    ..aD(6, _omitFieldNames ? '' : 'growingDegreeDays')
    ..aI(7, _omitFieldNames ? '' : 'frostDays')
    ..aI(8, _omitFieldNames ? '' : 'heatStressDays')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnvironmentFactors clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnvironmentFactors copyWith(void Function(EnvironmentFactors) updates) =>
      super.copyWith((message) => updates(message as EnvironmentFactors))
          as EnvironmentFactors;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EnvironmentFactors create() => EnvironmentFactors._();
  @$core.override
  EnvironmentFactors createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EnvironmentFactors getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EnvironmentFactors>(create);
  static EnvironmentFactors? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get temperatureCelsius => $_getN(0);
  @$pb.TagNumber(1)
  set temperatureCelsius($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTemperatureCelsius() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemperatureCelsius() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get humidityPct => $_getN(1);
  @$pb.TagNumber(2)
  set humidityPct($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHumidityPct() => $_has(1);
  @$pb.TagNumber(2)
  void clearHumidityPct() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get rainfallMm => $_getN(2);
  @$pb.TagNumber(3)
  set rainfallMm($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRainfallMm() => $_has(2);
  @$pb.TagNumber(3)
  void clearRainfallMm() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get solarRadiation => $_getN(3);
  @$pb.TagNumber(4)
  set solarRadiation($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSolarRadiation() => $_has(3);
  @$pb.TagNumber(4)
  void clearSolarRadiation() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get windSpeedKmh => $_getN(4);
  @$pb.TagNumber(5)
  set windSpeedKmh($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWindSpeedKmh() => $_has(4);
  @$pb.TagNumber(5)
  void clearWindSpeedKmh() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get growingDegreeDays => $_getN(5);
  @$pb.TagNumber(6)
  set growingDegreeDays($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasGrowingDegreeDays() => $_has(5);
  @$pb.TagNumber(6)
  void clearGrowingDegreeDays() => $_clearField(6);

  /// Season counts from weather-service agro metrics (optional).
  @$pb.TagNumber(7)
  $core.int get frostDays => $_getIZ(6);
  @$pb.TagNumber(7)
  set frostDays($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFrostDays() => $_has(6);
  @$pb.TagNumber(7)
  void clearFrostDays() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get heatStressDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set heatStressDays($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasHeatStressDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearHeatStressDays() => $_clearField(8);
}

class SoilFactors extends $pb.GeneratedMessage {
  factory SoilFactors({
    $core.double? ph,
    $core.double? organicMatterPct,
    $core.double? nitrogenPpm,
    $core.double? phosphorusPpm,
    $core.double? potassiumPpm,
    $core.double? moisturePct,
    $core.String? texture,
    $core.double? compactionIndex,
  }) {
    final result = create();
    if (ph != null) result.ph = ph;
    if (organicMatterPct != null) result.organicMatterPct = organicMatterPct;
    if (nitrogenPpm != null) result.nitrogenPpm = nitrogenPpm;
    if (phosphorusPpm != null) result.phosphorusPpm = phosphorusPpm;
    if (potassiumPpm != null) result.potassiumPpm = potassiumPpm;
    if (moisturePct != null) result.moisturePct = moisturePct;
    if (texture != null) result.texture = texture;
    if (compactionIndex != null) result.compactionIndex = compactionIndex;
    return result;
  }

  SoilFactors._();

  factory SoilFactors.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SoilFactors.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SoilFactors',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'ph')
    ..aD(2, _omitFieldNames ? '' : 'organicMatterPct')
    ..aD(3, _omitFieldNames ? '' : 'nitrogenPpm')
    ..aD(4, _omitFieldNames ? '' : 'phosphorusPpm')
    ..aD(5, _omitFieldNames ? '' : 'potassiumPpm')
    ..aD(6, _omitFieldNames ? '' : 'moisturePct')
    ..aOS(7, _omitFieldNames ? '' : 'texture')
    ..aD(8, _omitFieldNames ? '' : 'compactionIndex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilFactors clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilFactors copyWith(void Function(SoilFactors) updates) =>
      super.copyWith((message) => updates(message as SoilFactors))
          as SoilFactors;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SoilFactors create() => SoilFactors._();
  @$core.override
  SoilFactors createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SoilFactors getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SoilFactors>(create);
  static SoilFactors? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get ph => $_getN(0);
  @$pb.TagNumber(1)
  set ph($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPh() => $_has(0);
  @$pb.TagNumber(1)
  void clearPh() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get organicMatterPct => $_getN(1);
  @$pb.TagNumber(2)
  set organicMatterPct($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOrganicMatterPct() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrganicMatterPct() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get nitrogenPpm => $_getN(2);
  @$pb.TagNumber(3)
  set nitrogenPpm($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNitrogenPpm() => $_has(2);
  @$pb.TagNumber(3)
  void clearNitrogenPpm() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get phosphorusPpm => $_getN(3);
  @$pb.TagNumber(4)
  set phosphorusPpm($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPhosphorusPpm() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhosphorusPpm() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get potassiumPpm => $_getN(4);
  @$pb.TagNumber(5)
  set potassiumPpm($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPotassiumPpm() => $_has(4);
  @$pb.TagNumber(5)
  void clearPotassiumPpm() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get moisturePct => $_getN(5);
  @$pb.TagNumber(6)
  set moisturePct($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMoisturePct() => $_has(5);
  @$pb.TagNumber(6)
  void clearMoisturePct() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get texture => $_getSZ(6);
  @$pb.TagNumber(7)
  set texture($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTexture() => $_has(6);
  @$pb.TagNumber(7)
  void clearTexture() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get compactionIndex => $_getN(7);
  @$pb.TagNumber(8)
  set compactionIndex($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCompactionIndex() => $_has(7);
  @$pb.TagNumber(8)
  void clearCompactionIndex() => $_clearField(8);
}

class ManagementFactors extends $pb.GeneratedMessage {
  factory ManagementFactors({
    $core.double? irrigationEfficiency,
    $core.double? fertilizerRateKgPerHa,
    $core.String? tillageType,
    $core.double? plantingDensity,
    $core.String? pestManagementLevel,
    $core.int? plantingDay,
    $core.double? irrigationMm,
  }) {
    final result = create();
    if (irrigationEfficiency != null)
      result.irrigationEfficiency = irrigationEfficiency;
    if (fertilizerRateKgPerHa != null)
      result.fertilizerRateKgPerHa = fertilizerRateKgPerHa;
    if (tillageType != null) result.tillageType = tillageType;
    if (plantingDensity != null) result.plantingDensity = plantingDensity;
    if (pestManagementLevel != null)
      result.pestManagementLevel = pestManagementLevel;
    if (plantingDay != null) result.plantingDay = plantingDay;
    if (irrigationMm != null) result.irrigationMm = irrigationMm;
    return result;
  }

  ManagementFactors._();

  factory ManagementFactors.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ManagementFactors.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ManagementFactors',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'irrigationEfficiency')
    ..aD(2, _omitFieldNames ? '' : 'fertilizerRateKgPerHa')
    ..aOS(3, _omitFieldNames ? '' : 'tillageType')
    ..aD(4, _omitFieldNames ? '' : 'plantingDensity')
    ..aOS(5, _omitFieldNames ? '' : 'pestManagementLevel')
    ..aI(6, _omitFieldNames ? '' : 'plantingDay')
    ..aD(7, _omitFieldNames ? '' : 'irrigationMm')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ManagementFactors clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ManagementFactors copyWith(void Function(ManagementFactors) updates) =>
      super.copyWith((message) => updates(message as ManagementFactors))
          as ManagementFactors;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ManagementFactors create() => ManagementFactors._();
  @$core.override
  ManagementFactors createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ManagementFactors getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ManagementFactors>(create);
  static ManagementFactors? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get irrigationEfficiency => $_getN(0);
  @$pb.TagNumber(1)
  set irrigationEfficiency($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIrrigationEfficiency() => $_has(0);
  @$pb.TagNumber(1)
  void clearIrrigationEfficiency() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get fertilizerRateKgPerHa => $_getN(1);
  @$pb.TagNumber(2)
  set fertilizerRateKgPerHa($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFertilizerRateKgPerHa() => $_has(1);
  @$pb.TagNumber(2)
  void clearFertilizerRateKgPerHa() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tillageType => $_getSZ(2);
  @$pb.TagNumber(3)
  set tillageType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTillageType() => $_has(2);
  @$pb.TagNumber(3)
  void clearTillageType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get plantingDensity => $_getN(3);
  @$pb.TagNumber(4)
  set plantingDensity($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPlantingDensity() => $_has(3);
  @$pb.TagNumber(4)
  void clearPlantingDensity() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get pestManagementLevel => $_getSZ(4);
  @$pb.TagNumber(5)
  set pestManagementLevel($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPestManagementLevel() => $_has(4);
  @$pb.TagNumber(5)
  void clearPestManagementLevel() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get plantingDay => $_getIZ(5);
  @$pb.TagNumber(6)
  set plantingDay($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPlantingDay() => $_has(5);
  @$pb.TagNumber(6)
  void clearPlantingDay() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get irrigationMm => $_getN(6);
  @$pb.TagNumber(7)
  set irrigationMm($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIrrigationMm() => $_has(6);
  @$pb.TagNumber(7)
  void clearIrrigationMm() => $_clearField(7);
}

class StressFactor extends $pb.GeneratedMessage {
  factory StressFactor({
    $core.String? factorName,
    $core.double? severity,
    $core.double? yieldImpactPct,
  }) {
    final result = create();
    if (factorName != null) result.factorName = factorName;
    if (severity != null) result.severity = severity;
    if (yieldImpactPct != null) result.yieldImpactPct = yieldImpactPct;
    return result;
  }

  StressFactor._();

  factory StressFactor.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StressFactor.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StressFactor',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'factorName')
    ..aD(2, _omitFieldNames ? '' : 'severity')
    ..aD(3, _omitFieldNames ? '' : 'yieldImpactPct')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StressFactor clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StressFactor copyWith(void Function(StressFactor) updates) =>
      super.copyWith((message) => updates(message as StressFactor))
          as StressFactor;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StressFactor create() => StressFactor._();
  @$core.override
  StressFactor createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StressFactor getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StressFactor>(create);
  static StressFactor? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get factorName => $_getSZ(0);
  @$pb.TagNumber(1)
  set factorName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFactorName() => $_has(0);
  @$pb.TagNumber(1)
  void clearFactorName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get severity => $_getN(1);
  @$pb.TagNumber(2)
  set severity($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSeverity() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeverity() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get yieldImpactPct => $_getN(2);
  @$pb.TagNumber(3)
  set yieldImpactPct($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasYieldImpactPct() => $_has(2);
  @$pb.TagNumber(3)
  void clearYieldImpactPct() => $_clearField(3);
}

class SimulateCropGrowthRequest extends $pb.GeneratedMessage {
  factory SimulateCropGrowthRequest({
    $core.String? requestId,
    $core.String? cropType,
    $core.int? simulationDays,
    EnvironmentFactors? initialEnvironment,
    SoilFactors? initialSoil,
    $core.double? plantingDensity,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (cropType != null) result.cropType = cropType;
    if (simulationDays != null) result.simulationDays = simulationDays;
    if (initialEnvironment != null)
      result.initialEnvironment = initialEnvironment;
    if (initialSoil != null) result.initialSoil = initialSoil;
    if (plantingDensity != null) result.plantingDensity = plantingDensity;
    return result;
  }

  SimulateCropGrowthRequest._();

  factory SimulateCropGrowthRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SimulateCropGrowthRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SimulateCropGrowthRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'cropType')
    ..aI(3, _omitFieldNames ? '' : 'simulationDays')
    ..aOM<EnvironmentFactors>(4, _omitFieldNames ? '' : 'initialEnvironment',
        subBuilder: EnvironmentFactors.create)
    ..aOM<SoilFactors>(5, _omitFieldNames ? '' : 'initialSoil',
        subBuilder: SoilFactors.create)
    ..aD(6, _omitFieldNames ? '' : 'plantingDensity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimulateCropGrowthRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimulateCropGrowthRequest copyWith(
          void Function(SimulateCropGrowthRequest) updates) =>
      super.copyWith((message) => updates(message as SimulateCropGrowthRequest))
          as SimulateCropGrowthRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SimulateCropGrowthRequest create() => SimulateCropGrowthRequest._();
  @$core.override
  SimulateCropGrowthRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SimulateCropGrowthRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SimulateCropGrowthRequest>(create);
  static SimulateCropGrowthRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get cropType => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropType() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get simulationDays => $_getIZ(2);
  @$pb.TagNumber(3)
  set simulationDays($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSimulationDays() => $_has(2);
  @$pb.TagNumber(3)
  void clearSimulationDays() => $_clearField(3);

  @$pb.TagNumber(4)
  EnvironmentFactors get initialEnvironment => $_getN(3);
  @$pb.TagNumber(4)
  set initialEnvironment(EnvironmentFactors value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasInitialEnvironment() => $_has(3);
  @$pb.TagNumber(4)
  void clearInitialEnvironment() => $_clearField(4);
  @$pb.TagNumber(4)
  EnvironmentFactors ensureInitialEnvironment() => $_ensure(3);

  @$pb.TagNumber(5)
  SoilFactors get initialSoil => $_getN(4);
  @$pb.TagNumber(5)
  set initialSoil(SoilFactors value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasInitialSoil() => $_has(4);
  @$pb.TagNumber(5)
  void clearInitialSoil() => $_clearField(5);
  @$pb.TagNumber(5)
  SoilFactors ensureInitialSoil() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.double get plantingDensity => $_getN(5);
  @$pb.TagNumber(6)
  set plantingDensity($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPlantingDensity() => $_has(5);
  @$pb.TagNumber(6)
  void clearPlantingDensity() => $_clearField(6);
}

class SimulateCropGrowthResponse extends $pb.GeneratedMessage {
  factory SimulateCropGrowthResponse({
    $core.String? requestId,
    $core.Iterable<GrowthStageResult>? stages,
    $core.double? finalBiomassKgPerHa,
    $core.int? estimatedDaysToMaturity,
    $core.String? modelVersion,
    $fixnum.Int64? processingTimeMs,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (stages != null) result.stages.addAll(stages);
    if (finalBiomassKgPerHa != null)
      result.finalBiomassKgPerHa = finalBiomassKgPerHa;
    if (estimatedDaysToMaturity != null)
      result.estimatedDaysToMaturity = estimatedDaysToMaturity;
    if (modelVersion != null) result.modelVersion = modelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    return result;
  }

  SimulateCropGrowthResponse._();

  factory SimulateCropGrowthResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SimulateCropGrowthResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SimulateCropGrowthResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..pPM<GrowthStageResult>(2, _omitFieldNames ? '' : 'stages',
        subBuilder: GrowthStageResult.create)
    ..aD(3, _omitFieldNames ? '' : 'finalBiomassKgPerHa')
    ..aI(4, _omitFieldNames ? '' : 'estimatedDaysToMaturity')
    ..aOS(5, _omitFieldNames ? '' : 'modelVersion')
    ..aInt64(6, _omitFieldNames ? '' : 'processingTimeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimulateCropGrowthResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimulateCropGrowthResponse copyWith(
          void Function(SimulateCropGrowthResponse) updates) =>
      super.copyWith(
              (message) => updates(message as SimulateCropGrowthResponse))
          as SimulateCropGrowthResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SimulateCropGrowthResponse create() => SimulateCropGrowthResponse._();
  @$core.override
  SimulateCropGrowthResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SimulateCropGrowthResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SimulateCropGrowthResponse>(create);
  static SimulateCropGrowthResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<GrowthStageResult> get stages => $_getList(1);

  @$pb.TagNumber(3)
  $core.double get finalBiomassKgPerHa => $_getN(2);
  @$pb.TagNumber(3)
  set finalBiomassKgPerHa($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFinalBiomassKgPerHa() => $_has(2);
  @$pb.TagNumber(3)
  void clearFinalBiomassKgPerHa() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get estimatedDaysToMaturity => $_getIZ(3);
  @$pb.TagNumber(4)
  set estimatedDaysToMaturity($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEstimatedDaysToMaturity() => $_has(3);
  @$pb.TagNumber(4)
  void clearEstimatedDaysToMaturity() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get modelVersion => $_getSZ(4);
  @$pb.TagNumber(5)
  set modelVersion($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasModelVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearModelVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get processingTimeMs => $_getI64(5);
  @$pb.TagNumber(6)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProcessingTimeMs() => $_has(5);
  @$pb.TagNumber(6)
  void clearProcessingTimeMs() => $_clearField(6);
}

class GrowthStageResult extends $pb.GeneratedMessage {
  factory GrowthStageResult({
    $core.int? day,
    $core.String? stageName,
    $core.double? biomassKgPerHa,
    $core.double? leafAreaIndex,
    $core.double? canopyHeightCm,
    $core.double? waterDemandMm,
  }) {
    final result = create();
    if (day != null) result.day = day;
    if (stageName != null) result.stageName = stageName;
    if (biomassKgPerHa != null) result.biomassKgPerHa = biomassKgPerHa;
    if (leafAreaIndex != null) result.leafAreaIndex = leafAreaIndex;
    if (canopyHeightCm != null) result.canopyHeightCm = canopyHeightCm;
    if (waterDemandMm != null) result.waterDemandMm = waterDemandMm;
    return result;
  }

  GrowthStageResult._();

  factory GrowthStageResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GrowthStageResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GrowthStageResult',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'day')
    ..aOS(2, _omitFieldNames ? '' : 'stageName')
    ..aD(3, _omitFieldNames ? '' : 'biomassKgPerHa')
    ..aD(4, _omitFieldNames ? '' : 'leafAreaIndex')
    ..aD(5, _omitFieldNames ? '' : 'canopyHeightCm')
    ..aD(6, _omitFieldNames ? '' : 'waterDemandMm')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GrowthStageResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GrowthStageResult copyWith(void Function(GrowthStageResult) updates) =>
      super.copyWith((message) => updates(message as GrowthStageResult))
          as GrowthStageResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GrowthStageResult create() => GrowthStageResult._();
  @$core.override
  GrowthStageResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GrowthStageResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GrowthStageResult>(create);
  static GrowthStageResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get day => $_getIZ(0);
  @$pb.TagNumber(1)
  set day($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDay() => $_has(0);
  @$pb.TagNumber(1)
  void clearDay() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get stageName => $_getSZ(1);
  @$pb.TagNumber(2)
  set stageName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStageName() => $_has(1);
  @$pb.TagNumber(2)
  void clearStageName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get biomassKgPerHa => $_getN(2);
  @$pb.TagNumber(3)
  set biomassKgPerHa($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBiomassKgPerHa() => $_has(2);
  @$pb.TagNumber(3)
  void clearBiomassKgPerHa() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get leafAreaIndex => $_getN(3);
  @$pb.TagNumber(4)
  set leafAreaIndex($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLeafAreaIndex() => $_has(3);
  @$pb.TagNumber(4)
  void clearLeafAreaIndex() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get canopyHeightCm => $_getN(4);
  @$pb.TagNumber(5)
  set canopyHeightCm($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCanopyHeightCm() => $_has(4);
  @$pb.TagNumber(5)
  void clearCanopyHeightCm() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get waterDemandMm => $_getN(5);
  @$pb.TagNumber(6)
  set waterDemandMm($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasWaterDemandMm() => $_has(5);
  @$pb.TagNumber(6)
  void clearWaterDemandMm() => $_clearField(6);
}

class ComputeNDVIRequest extends $pb.GeneratedMessage {
  factory ComputeNDVIRequest({
    $core.String? requestId,
    $core.String? rasterUrl,
    RasterBands? bands,
    BoundingBox? clipBounds,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (rasterUrl != null) result.rasterUrl = rasterUrl;
    if (bands != null) result.bands = bands;
    if (clipBounds != null) result.clipBounds = clipBounds;
    return result;
  }

  ComputeNDVIRequest._();

  factory ComputeNDVIRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ComputeNDVIRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ComputeNDVIRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'rasterUrl')
    ..aOM<RasterBands>(3, _omitFieldNames ? '' : 'bands',
        subBuilder: RasterBands.create)
    ..aOM<BoundingBox>(4, _omitFieldNames ? '' : 'clipBounds',
        subBuilder: BoundingBox.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeNDVIRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeNDVIRequest copyWith(void Function(ComputeNDVIRequest) updates) =>
      super.copyWith((message) => updates(message as ComputeNDVIRequest))
          as ComputeNDVIRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ComputeNDVIRequest create() => ComputeNDVIRequest._();
  @$core.override
  ComputeNDVIRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ComputeNDVIRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ComputeNDVIRequest>(create);
  static ComputeNDVIRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get rasterUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set rasterUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRasterUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearRasterUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  RasterBands get bands => $_getN(2);
  @$pb.TagNumber(3)
  set bands(RasterBands value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBands() => $_has(2);
  @$pb.TagNumber(3)
  void clearBands() => $_clearField(3);
  @$pb.TagNumber(3)
  RasterBands ensureBands() => $_ensure(2);

  @$pb.TagNumber(4)
  BoundingBox get clipBounds => $_getN(3);
  @$pb.TagNumber(4)
  set clipBounds(BoundingBox value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasClipBounds() => $_has(3);
  @$pb.TagNumber(4)
  void clearClipBounds() => $_clearField(4);
  @$pb.TagNumber(4)
  BoundingBox ensureClipBounds() => $_ensure(3);
}

class RasterBands extends $pb.GeneratedMessage {
  factory RasterBands({
    $core.Iterable<$core.double>? nirBand,
    $core.Iterable<$core.double>? redBand,
    $core.Iterable<$core.double>? greenBand,
    $core.Iterable<$core.double>? blueBand,
    $core.Iterable<$core.double>? redEdgeBand,
    $core.int? width,
    $core.int? height,
    $core.Iterable<$core.double>? sclBand,
    $core.Iterable<$core.double>? qaPixelBand,
    $core.String? processingLevel,
    $core.String? sensor,
    $core.int? cloudBufferPixels,
  }) {
    final result = create();
    if (nirBand != null) result.nirBand.addAll(nirBand);
    if (redBand != null) result.redBand.addAll(redBand);
    if (greenBand != null) result.greenBand.addAll(greenBand);
    if (blueBand != null) result.blueBand.addAll(blueBand);
    if (redEdgeBand != null) result.redEdgeBand.addAll(redEdgeBand);
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (sclBand != null) result.sclBand.addAll(sclBand);
    if (qaPixelBand != null) result.qaPixelBand.addAll(qaPixelBand);
    if (processingLevel != null) result.processingLevel = processingLevel;
    if (sensor != null) result.sensor = sensor;
    if (cloudBufferPixels != null) result.cloudBufferPixels = cloudBufferPixels;
    return result;
  }

  RasterBands._();

  factory RasterBands.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RasterBands.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RasterBands',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..p<$core.double>(1, _omitFieldNames ? '' : 'nirBand', $pb.PbFieldType.KD)
    ..p<$core.double>(2, _omitFieldNames ? '' : 'redBand', $pb.PbFieldType.KD)
    ..p<$core.double>(3, _omitFieldNames ? '' : 'greenBand', $pb.PbFieldType.KD)
    ..p<$core.double>(4, _omitFieldNames ? '' : 'blueBand', $pb.PbFieldType.KD)
    ..p<$core.double>(
        5, _omitFieldNames ? '' : 'redEdgeBand', $pb.PbFieldType.KD)
    ..aI(6, _omitFieldNames ? '' : 'width')
    ..aI(7, _omitFieldNames ? '' : 'height')
    ..p<$core.double>(8, _omitFieldNames ? '' : 'sclBand', $pb.PbFieldType.KD)
    ..p<$core.double>(
        9, _omitFieldNames ? '' : 'qaPixelBand', $pb.PbFieldType.KD)
    ..aOS(10, _omitFieldNames ? '' : 'processingLevel')
    ..aOS(11, _omitFieldNames ? '' : 'sensor')
    ..aI(12, _omitFieldNames ? '' : 'cloudBufferPixels')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RasterBands clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RasterBands copyWith(void Function(RasterBands) updates) =>
      super.copyWith((message) => updates(message as RasterBands))
          as RasterBands;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RasterBands create() => RasterBands._();
  @$core.override
  RasterBands createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RasterBands getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RasterBands>(create);
  static RasterBands? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.double> get nirBand => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<$core.double> get redBand => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.double> get greenBand => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.double> get blueBand => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.double> get redEdgeBand => $_getList(4);

  @$pb.TagNumber(6)
  $core.int get width => $_getIZ(5);
  @$pb.TagNumber(6)
  set width($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasWidth() => $_has(5);
  @$pb.TagNumber(6)
  void clearWidth() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get height => $_getIZ(6);
  @$pb.TagNumber(7)
  set height($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHeight() => $_has(6);
  @$pb.TagNumber(7)
  void clearHeight() => $_clearField(7);

  /// Optional per-pixel QA layers used for cloud/shadow/snow masking.
  @$pb.TagNumber(8)
  $pb.PbList<$core.double> get sclBand => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<$core.double> get qaPixelBand => $_getList(8);

  /// Product metadata used for processing-level checks and cross-sensor harmonization.
  @$pb.TagNumber(10)
  $core.String get processingLevel => $_getSZ(9);
  @$pb.TagNumber(10)
  set processingLevel($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasProcessingLevel() => $_has(9);
  @$pb.TagNumber(10)
  void clearProcessingLevel() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get sensor => $_getSZ(10);
  @$pb.TagNumber(11)
  set sensor($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSensor() => $_has(10);
  @$pb.TagNumber(11)
  void clearSensor() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.int get cloudBufferPixels => $_getIZ(11);
  @$pb.TagNumber(12)
  set cloudBufferPixels($core.int value) => $_setSignedInt32(11, value);
  @$pb.TagNumber(12)
  $core.bool hasCloudBufferPixels() => $_has(11);
  @$pb.TagNumber(12)
  void clearCloudBufferPixels() => $_clearField(12);
}

class BoundingBox extends $pb.GeneratedMessage {
  factory BoundingBox({
    $core.double? minLon,
    $core.double? minLat,
    $core.double? maxLon,
    $core.double? maxLat,
  }) {
    final result = create();
    if (minLon != null) result.minLon = minLon;
    if (minLat != null) result.minLat = minLat;
    if (maxLon != null) result.maxLon = maxLon;
    if (maxLat != null) result.maxLat = maxLat;
    return result;
  }

  BoundingBox._();

  factory BoundingBox.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BoundingBox.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoundingBox',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'minLon')
    ..aD(2, _omitFieldNames ? '' : 'minLat')
    ..aD(3, _omitFieldNames ? '' : 'maxLon')
    ..aD(4, _omitFieldNames ? '' : 'maxLat')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoundingBox clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoundingBox copyWith(void Function(BoundingBox) updates) =>
      super.copyWith((message) => updates(message as BoundingBox))
          as BoundingBox;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BoundingBox create() => BoundingBox._();
  @$core.override
  BoundingBox createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BoundingBox getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BoundingBox>(create);
  static BoundingBox? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get minLon => $_getN(0);
  @$pb.TagNumber(1)
  set minLon($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMinLon() => $_has(0);
  @$pb.TagNumber(1)
  void clearMinLon() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get minLat => $_getN(1);
  @$pb.TagNumber(2)
  set minLat($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMinLat() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinLat() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get maxLon => $_getN(2);
  @$pb.TagNumber(3)
  set maxLon($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxLon() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxLon() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get maxLat => $_getN(3);
  @$pb.TagNumber(4)
  set maxLat($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxLat() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxLat() => $_clearField(4);
}

class ComputeNDVIResponse extends $pb.GeneratedMessage {
  factory ComputeNDVIResponse({
    $core.String? requestId,
    $core.Iterable<$core.double>? ndviValues,
    $core.int? width,
    $core.int? height,
    BandStatistics? statistics,
    $core.Iterable<NdviZone>? zones,
    $core.String? modelVersion,
    $fixnum.Int64? processingTimeMs,
    $core.bool? cloudMasked,
    $core.double? cloudFraction,
    $core.double? validPixelFraction,
    $core.String? processingLevel,
    $core.String? processingAdvisory,
    $core.String? sensor,
    $core.bool? harmonized,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (ndviValues != null) result.ndviValues.addAll(ndviValues);
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (statistics != null) result.statistics = statistics;
    if (zones != null) result.zones.addAll(zones);
    if (modelVersion != null) result.modelVersion = modelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    if (cloudMasked != null) result.cloudMasked = cloudMasked;
    if (cloudFraction != null) result.cloudFraction = cloudFraction;
    if (validPixelFraction != null)
      result.validPixelFraction = validPixelFraction;
    if (processingLevel != null) result.processingLevel = processingLevel;
    if (processingAdvisory != null)
      result.processingAdvisory = processingAdvisory;
    if (sensor != null) result.sensor = sensor;
    if (harmonized != null) result.harmonized = harmonized;
    return result;
  }

  ComputeNDVIResponse._();

  factory ComputeNDVIResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ComputeNDVIResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ComputeNDVIResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..p<$core.double>(
        2, _omitFieldNames ? '' : 'ndviValues', $pb.PbFieldType.KD)
    ..aI(3, _omitFieldNames ? '' : 'width')
    ..aI(4, _omitFieldNames ? '' : 'height')
    ..aOM<BandStatistics>(5, _omitFieldNames ? '' : 'statistics',
        subBuilder: BandStatistics.create)
    ..pPM<NdviZone>(6, _omitFieldNames ? '' : 'zones',
        subBuilder: NdviZone.create)
    ..aOS(7, _omitFieldNames ? '' : 'modelVersion')
    ..aInt64(8, _omitFieldNames ? '' : 'processingTimeMs')
    ..aOB(9, _omitFieldNames ? '' : 'cloudMasked')
    ..aD(10, _omitFieldNames ? '' : 'cloudFraction')
    ..aD(11, _omitFieldNames ? '' : 'validPixelFraction')
    ..aOS(12, _omitFieldNames ? '' : 'processingLevel')
    ..aOS(13, _omitFieldNames ? '' : 'processingAdvisory')
    ..aOS(14, _omitFieldNames ? '' : 'sensor')
    ..aOB(15, _omitFieldNames ? '' : 'harmonized')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeNDVIResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeNDVIResponse copyWith(void Function(ComputeNDVIResponse) updates) =>
      super.copyWith((message) => updates(message as ComputeNDVIResponse))
          as ComputeNDVIResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ComputeNDVIResponse create() => ComputeNDVIResponse._();
  @$core.override
  ComputeNDVIResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ComputeNDVIResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ComputeNDVIResponse>(create);
  static ComputeNDVIResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.double> get ndviValues => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get width => $_getIZ(2);
  @$pb.TagNumber(3)
  set width($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearWidth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(3);
  @$pb.TagNumber(4)
  set height($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeight() => $_clearField(4);

  @$pb.TagNumber(5)
  BandStatistics get statistics => $_getN(4);
  @$pb.TagNumber(5)
  set statistics(BandStatistics value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatistics() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatistics() => $_clearField(5);
  @$pb.TagNumber(5)
  BandStatistics ensureStatistics() => $_ensure(4);

  @$pb.TagNumber(6)
  $pb.PbList<NdviZone> get zones => $_getList(5);

  @$pb.TagNumber(7)
  $core.String get modelVersion => $_getSZ(6);
  @$pb.TagNumber(7)
  set modelVersion($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasModelVersion() => $_has(6);
  @$pb.TagNumber(7)
  void clearModelVersion() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get processingTimeMs => $_getI64(7);
  @$pb.TagNumber(8)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasProcessingTimeMs() => $_has(7);
  @$pb.TagNumber(8)
  void clearProcessingTimeMs() => $_clearField(8);

  /// Quality metadata (populated when QA layers / product metadata are supplied).
  @$pb.TagNumber(9)
  $core.bool get cloudMasked => $_getBF(8);
  @$pb.TagNumber(9)
  set cloudMasked($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCloudMasked() => $_has(8);
  @$pb.TagNumber(9)
  void clearCloudMasked() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get cloudFraction => $_getN(9);
  @$pb.TagNumber(10)
  set cloudFraction($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasCloudFraction() => $_has(9);
  @$pb.TagNumber(10)
  void clearCloudFraction() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get validPixelFraction => $_getN(10);
  @$pb.TagNumber(11)
  set validPixelFraction($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasValidPixelFraction() => $_has(10);
  @$pb.TagNumber(11)
  void clearValidPixelFraction() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get processingLevel => $_getSZ(11);
  @$pb.TagNumber(12)
  set processingLevel($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasProcessingLevel() => $_has(11);
  @$pb.TagNumber(12)
  void clearProcessingLevel() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get processingAdvisory => $_getSZ(12);
  @$pb.TagNumber(13)
  set processingAdvisory($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasProcessingAdvisory() => $_has(12);
  @$pb.TagNumber(13)
  void clearProcessingAdvisory() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get sensor => $_getSZ(13);
  @$pb.TagNumber(14)
  set sensor($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasSensor() => $_has(13);
  @$pb.TagNumber(14)
  void clearSensor() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.bool get harmonized => $_getBF(14);
  @$pb.TagNumber(15)
  set harmonized($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasHarmonized() => $_has(14);
  @$pb.TagNumber(15)
  void clearHarmonized() => $_clearField(15);
}

class BandStatistics extends $pb.GeneratedMessage {
  factory BandStatistics({
    $core.double? min,
    $core.double? max,
    $core.double? mean,
    $core.double? stdDev,
    $core.double? median,
    $fixnum.Int64? validPixelCount,
  }) {
    final result = create();
    if (min != null) result.min = min;
    if (max != null) result.max = max;
    if (mean != null) result.mean = mean;
    if (stdDev != null) result.stdDev = stdDev;
    if (median != null) result.median = median;
    if (validPixelCount != null) result.validPixelCount = validPixelCount;
    return result;
  }

  BandStatistics._();

  factory BandStatistics.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BandStatistics.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BandStatistics',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'min')
    ..aD(2, _omitFieldNames ? '' : 'max')
    ..aD(3, _omitFieldNames ? '' : 'mean')
    ..aD(4, _omitFieldNames ? '' : 'stdDev')
    ..aD(5, _omitFieldNames ? '' : 'median')
    ..aInt64(6, _omitFieldNames ? '' : 'validPixelCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BandStatistics clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BandStatistics copyWith(void Function(BandStatistics) updates) =>
      super.copyWith((message) => updates(message as BandStatistics))
          as BandStatistics;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BandStatistics create() => BandStatistics._();
  @$core.override
  BandStatistics createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static BandStatistics getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BandStatistics>(create);
  static BandStatistics? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get min => $_getN(0);
  @$pb.TagNumber(1)
  set min($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMin() => $_has(0);
  @$pb.TagNumber(1)
  void clearMin() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get max => $_getN(1);
  @$pb.TagNumber(2)
  set max($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMax() => $_has(1);
  @$pb.TagNumber(2)
  void clearMax() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get mean => $_getN(2);
  @$pb.TagNumber(3)
  set mean($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMean() => $_has(2);
  @$pb.TagNumber(3)
  void clearMean() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get stdDev => $_getN(3);
  @$pb.TagNumber(4)
  set stdDev($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStdDev() => $_has(3);
  @$pb.TagNumber(4)
  void clearStdDev() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get median => $_getN(4);
  @$pb.TagNumber(5)
  set median($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMedian() => $_has(4);
  @$pb.TagNumber(5)
  void clearMedian() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get validPixelCount => $_getI64(5);
  @$pb.TagNumber(6)
  set validPixelCount($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasValidPixelCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearValidPixelCount() => $_clearField(6);
}

class NdviZone extends $pb.GeneratedMessage {
  factory NdviZone({
    $core.String? classification,
    $core.double? minValue,
    $core.double? maxValue,
    $fixnum.Int64? pixelCount,
    $core.double? areaPct,
  }) {
    final result = create();
    if (classification != null) result.classification = classification;
    if (minValue != null) result.minValue = minValue;
    if (maxValue != null) result.maxValue = maxValue;
    if (pixelCount != null) result.pixelCount = pixelCount;
    if (areaPct != null) result.areaPct = areaPct;
    return result;
  }

  NdviZone._();

  factory NdviZone.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NdviZone.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NdviZone',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'classification')
    ..aD(2, _omitFieldNames ? '' : 'minValue')
    ..aD(3, _omitFieldNames ? '' : 'maxValue')
    ..aInt64(4, _omitFieldNames ? '' : 'pixelCount')
    ..aD(5, _omitFieldNames ? '' : 'areaPct')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NdviZone clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NdviZone copyWith(void Function(NdviZone) updates) =>
      super.copyWith((message) => updates(message as NdviZone)) as NdviZone;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NdviZone create() => NdviZone._();
  @$core.override
  NdviZone createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NdviZone getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<NdviZone>(create);
  static NdviZone? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get classification => $_getSZ(0);
  @$pb.TagNumber(1)
  set classification($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasClassification() => $_has(0);
  @$pb.TagNumber(1)
  void clearClassification() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get minValue => $_getN(1);
  @$pb.TagNumber(2)
  set minValue($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMinValue() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinValue() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get maxValue => $_getN(2);
  @$pb.TagNumber(3)
  set maxValue($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxValue() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get pixelCount => $_getI64(3);
  @$pb.TagNumber(4)
  set pixelCount($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPixelCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearPixelCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get areaPct => $_getN(4);
  @$pb.TagNumber(5)
  set areaPct($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAreaPct() => $_has(4);
  @$pb.TagNumber(5)
  void clearAreaPct() => $_clearField(5);
}

class DetectVegetationStressRequest extends $pb.GeneratedMessage {
  factory DetectVegetationStressRequest({
    $core.String? requestId,
    $core.String? rasterUrl,
    RasterBands? bands,
    BoundingBox? clipBounds,
    $core.double? ndviStressThreshold,
    $core.double? ndwiStressThreshold,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (rasterUrl != null) result.rasterUrl = rasterUrl;
    if (bands != null) result.bands = bands;
    if (clipBounds != null) result.clipBounds = clipBounds;
    if (ndviStressThreshold != null)
      result.ndviStressThreshold = ndviStressThreshold;
    if (ndwiStressThreshold != null)
      result.ndwiStressThreshold = ndwiStressThreshold;
    return result;
  }

  DetectVegetationStressRequest._();

  factory DetectVegetationStressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectVegetationStressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectVegetationStressRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'rasterUrl')
    ..aOM<RasterBands>(3, _omitFieldNames ? '' : 'bands',
        subBuilder: RasterBands.create)
    ..aOM<BoundingBox>(4, _omitFieldNames ? '' : 'clipBounds',
        subBuilder: BoundingBox.create)
    ..aD(5, _omitFieldNames ? '' : 'ndviStressThreshold')
    ..aD(6, _omitFieldNames ? '' : 'ndwiStressThreshold')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectVegetationStressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectVegetationStressRequest copyWith(
          void Function(DetectVegetationStressRequest) updates) =>
      super.copyWith(
              (message) => updates(message as DetectVegetationStressRequest))
          as DetectVegetationStressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectVegetationStressRequest create() =>
      DetectVegetationStressRequest._();
  @$core.override
  DetectVegetationStressRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectVegetationStressRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectVegetationStressRequest>(create);
  static DetectVegetationStressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get rasterUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set rasterUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRasterUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearRasterUrl() => $_clearField(2);

  @$pb.TagNumber(3)
  RasterBands get bands => $_getN(2);
  @$pb.TagNumber(3)
  set bands(RasterBands value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBands() => $_has(2);
  @$pb.TagNumber(3)
  void clearBands() => $_clearField(3);
  @$pb.TagNumber(3)
  RasterBands ensureBands() => $_ensure(2);

  @$pb.TagNumber(4)
  BoundingBox get clipBounds => $_getN(3);
  @$pb.TagNumber(4)
  set clipBounds(BoundingBox value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasClipBounds() => $_has(3);
  @$pb.TagNumber(4)
  void clearClipBounds() => $_clearField(4);
  @$pb.TagNumber(4)
  BoundingBox ensureClipBounds() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.double get ndviStressThreshold => $_getN(4);
  @$pb.TagNumber(5)
  set ndviStressThreshold($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNdviStressThreshold() => $_has(4);
  @$pb.TagNumber(5)
  void clearNdviStressThreshold() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get ndwiStressThreshold => $_getN(5);
  @$pb.TagNumber(6)
  set ndwiStressThreshold($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNdwiStressThreshold() => $_has(5);
  @$pb.TagNumber(6)
  void clearNdwiStressThreshold() => $_clearField(6);
}

class DetectVegetationStressResponse extends $pb.GeneratedMessage {
  factory DetectVegetationStressResponse({
    $core.String? requestId,
    $core.Iterable<StressZone>? stressZones,
    $core.double? overallStressPct,
    $core.double? healthyPct,
    BandStatistics? ndviStatistics,
    $core.String? modelVersion,
    $fixnum.Int64? processingTimeMs,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (stressZones != null) result.stressZones.addAll(stressZones);
    if (overallStressPct != null) result.overallStressPct = overallStressPct;
    if (healthyPct != null) result.healthyPct = healthyPct;
    if (ndviStatistics != null) result.ndviStatistics = ndviStatistics;
    if (modelVersion != null) result.modelVersion = modelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    return result;
  }

  DetectVegetationStressResponse._();

  factory DetectVegetationStressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectVegetationStressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectVegetationStressResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..pPM<StressZone>(2, _omitFieldNames ? '' : 'stressZones',
        subBuilder: StressZone.create)
    ..aD(3, _omitFieldNames ? '' : 'overallStressPct')
    ..aD(4, _omitFieldNames ? '' : 'healthyPct')
    ..aOM<BandStatistics>(5, _omitFieldNames ? '' : 'ndviStatistics',
        subBuilder: BandStatistics.create)
    ..aOS(6, _omitFieldNames ? '' : 'modelVersion')
    ..aInt64(7, _omitFieldNames ? '' : 'processingTimeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectVegetationStressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectVegetationStressResponse copyWith(
          void Function(DetectVegetationStressResponse) updates) =>
      super.copyWith(
              (message) => updates(message as DetectVegetationStressResponse))
          as DetectVegetationStressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectVegetationStressResponse create() =>
      DetectVegetationStressResponse._();
  @$core.override
  DetectVegetationStressResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectVegetationStressResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectVegetationStressResponse>(create);
  static DetectVegetationStressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<StressZone> get stressZones => $_getList(1);

  @$pb.TagNumber(3)
  $core.double get overallStressPct => $_getN(2);
  @$pb.TagNumber(3)
  set overallStressPct($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOverallStressPct() => $_has(2);
  @$pb.TagNumber(3)
  void clearOverallStressPct() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get healthyPct => $_getN(3);
  @$pb.TagNumber(4)
  set healthyPct($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHealthyPct() => $_has(3);
  @$pb.TagNumber(4)
  void clearHealthyPct() => $_clearField(4);

  @$pb.TagNumber(5)
  BandStatistics get ndviStatistics => $_getN(4);
  @$pb.TagNumber(5)
  set ndviStatistics(BandStatistics value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasNdviStatistics() => $_has(4);
  @$pb.TagNumber(5)
  void clearNdviStatistics() => $_clearField(5);
  @$pb.TagNumber(5)
  BandStatistics ensureNdviStatistics() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get modelVersion => $_getSZ(5);
  @$pb.TagNumber(6)
  set modelVersion($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasModelVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearModelVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get processingTimeMs => $_getI64(6);
  @$pb.TagNumber(7)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasProcessingTimeMs() => $_has(6);
  @$pb.TagNumber(7)
  void clearProcessingTimeMs() => $_clearField(7);
}

class StressZone extends $pb.GeneratedMessage {
  factory StressZone({
    $core.String? stressType,
    $core.String? severity,
    $core.double? affectedAreaPct,
    $core.double? confidence,
    BoundingBox? bounds,
  }) {
    final result = create();
    if (stressType != null) result.stressType = stressType;
    if (severity != null) result.severity = severity;
    if (affectedAreaPct != null) result.affectedAreaPct = affectedAreaPct;
    if (confidence != null) result.confidence = confidence;
    if (bounds != null) result.bounds = bounds;
    return result;
  }

  StressZone._();

  factory StressZone.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StressZone.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StressZone',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'stressType')
    ..aOS(2, _omitFieldNames ? '' : 'severity')
    ..aD(3, _omitFieldNames ? '' : 'affectedAreaPct')
    ..aD(4, _omitFieldNames ? '' : 'confidence')
    ..aOM<BoundingBox>(5, _omitFieldNames ? '' : 'bounds',
        subBuilder: BoundingBox.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StressZone clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StressZone copyWith(void Function(StressZone) updates) =>
      super.copyWith((message) => updates(message as StressZone)) as StressZone;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StressZone create() => StressZone._();
  @$core.override
  StressZone createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static StressZone getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StressZone>(create);
  static StressZone? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get stressType => $_getSZ(0);
  @$pb.TagNumber(1)
  set stressType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStressType() => $_has(0);
  @$pb.TagNumber(1)
  void clearStressType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get severity => $_getSZ(1);
  @$pb.TagNumber(2)
  set severity($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSeverity() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeverity() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get affectedAreaPct => $_getN(2);
  @$pb.TagNumber(3)
  set affectedAreaPct($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAffectedAreaPct() => $_has(2);
  @$pb.TagNumber(3)
  void clearAffectedAreaPct() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get confidence => $_getN(3);
  @$pb.TagNumber(4)
  set confidence($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfidence() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfidence() => $_clearField(4);

  @$pb.TagNumber(5)
  BoundingBox get bounds => $_getN(4);
  @$pb.TagNumber(5)
  set bounds(BoundingBox value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasBounds() => $_has(4);
  @$pb.TagNumber(5)
  void clearBounds() => $_clearField(5);
  @$pb.TagNumber(5)
  BoundingBox ensureBounds() => $_ensure(4);
}

class RecommendCropsRequest extends $pb.GeneratedMessage {
  factory RecommendCropsRequest({
    $core.String? requestId,
    SoilConditions? soil,
    ClimateConditions? climate,
    EconomicFactors? economics,
    $core.int? maxRecommendations,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (soil != null) result.soil = soil;
    if (climate != null) result.climate = climate;
    if (economics != null) result.economics = economics;
    if (maxRecommendations != null)
      result.maxRecommendations = maxRecommendations;
    return result;
  }

  RecommendCropsRequest._();

  factory RecommendCropsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecommendCropsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecommendCropsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOM<SoilConditions>(2, _omitFieldNames ? '' : 'soil',
        subBuilder: SoilConditions.create)
    ..aOM<ClimateConditions>(3, _omitFieldNames ? '' : 'climate',
        subBuilder: ClimateConditions.create)
    ..aOM<EconomicFactors>(4, _omitFieldNames ? '' : 'economics',
        subBuilder: EconomicFactors.create)
    ..aI(5, _omitFieldNames ? '' : 'maxRecommendations')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecommendCropsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecommendCropsRequest copyWith(
          void Function(RecommendCropsRequest) updates) =>
      super.copyWith((message) => updates(message as RecommendCropsRequest))
          as RecommendCropsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecommendCropsRequest create() => RecommendCropsRequest._();
  @$core.override
  RecommendCropsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecommendCropsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecommendCropsRequest>(create);
  static RecommendCropsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  SoilConditions get soil => $_getN(1);
  @$pb.TagNumber(2)
  set soil(SoilConditions value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSoil() => $_has(1);
  @$pb.TagNumber(2)
  void clearSoil() => $_clearField(2);
  @$pb.TagNumber(2)
  SoilConditions ensureSoil() => $_ensure(1);

  @$pb.TagNumber(3)
  ClimateConditions get climate => $_getN(2);
  @$pb.TagNumber(3)
  set climate(ClimateConditions value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasClimate() => $_has(2);
  @$pb.TagNumber(3)
  void clearClimate() => $_clearField(3);
  @$pb.TagNumber(3)
  ClimateConditions ensureClimate() => $_ensure(2);

  @$pb.TagNumber(4)
  EconomicFactors get economics => $_getN(3);
  @$pb.TagNumber(4)
  set economics(EconomicFactors value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasEconomics() => $_has(3);
  @$pb.TagNumber(4)
  void clearEconomics() => $_clearField(4);
  @$pb.TagNumber(4)
  EconomicFactors ensureEconomics() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get maxRecommendations => $_getIZ(4);
  @$pb.TagNumber(5)
  set maxRecommendations($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMaxRecommendations() => $_has(4);
  @$pb.TagNumber(5)
  void clearMaxRecommendations() => $_clearField(5);
}

class SoilConditions extends $pb.GeneratedMessage {
  factory SoilConditions({
    $core.double? ph,
    $core.double? organicMatterPct,
    $core.double? nitrogenPpm,
    $core.double? phosphorusPpm,
    $core.double? potassiumPpm,
    $core.String? texture,
    $core.String? drainageClass,
  }) {
    final result = create();
    if (ph != null) result.ph = ph;
    if (organicMatterPct != null) result.organicMatterPct = organicMatterPct;
    if (nitrogenPpm != null) result.nitrogenPpm = nitrogenPpm;
    if (phosphorusPpm != null) result.phosphorusPpm = phosphorusPpm;
    if (potassiumPpm != null) result.potassiumPpm = potassiumPpm;
    if (texture != null) result.texture = texture;
    if (drainageClass != null) result.drainageClass = drainageClass;
    return result;
  }

  SoilConditions._();

  factory SoilConditions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SoilConditions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SoilConditions',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'ph')
    ..aD(2, _omitFieldNames ? '' : 'organicMatterPct')
    ..aD(3, _omitFieldNames ? '' : 'nitrogenPpm')
    ..aD(4, _omitFieldNames ? '' : 'phosphorusPpm')
    ..aD(5, _omitFieldNames ? '' : 'potassiumPpm')
    ..aOS(6, _omitFieldNames ? '' : 'texture')
    ..aOS(7, _omitFieldNames ? '' : 'drainageClass')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilConditions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilConditions copyWith(void Function(SoilConditions) updates) =>
      super.copyWith((message) => updates(message as SoilConditions))
          as SoilConditions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SoilConditions create() => SoilConditions._();
  @$core.override
  SoilConditions createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SoilConditions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SoilConditions>(create);
  static SoilConditions? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get ph => $_getN(0);
  @$pb.TagNumber(1)
  set ph($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPh() => $_has(0);
  @$pb.TagNumber(1)
  void clearPh() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get organicMatterPct => $_getN(1);
  @$pb.TagNumber(2)
  set organicMatterPct($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOrganicMatterPct() => $_has(1);
  @$pb.TagNumber(2)
  void clearOrganicMatterPct() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get nitrogenPpm => $_getN(2);
  @$pb.TagNumber(3)
  set nitrogenPpm($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNitrogenPpm() => $_has(2);
  @$pb.TagNumber(3)
  void clearNitrogenPpm() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get phosphorusPpm => $_getN(3);
  @$pb.TagNumber(4)
  set phosphorusPpm($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPhosphorusPpm() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhosphorusPpm() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get potassiumPpm => $_getN(4);
  @$pb.TagNumber(5)
  set potassiumPpm($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPotassiumPpm() => $_has(4);
  @$pb.TagNumber(5)
  void clearPotassiumPpm() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get texture => $_getSZ(5);
  @$pb.TagNumber(6)
  set texture($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTexture() => $_has(5);
  @$pb.TagNumber(6)
  void clearTexture() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get drainageClass => $_getSZ(6);
  @$pb.TagNumber(7)
  set drainageClass($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDrainageClass() => $_has(6);
  @$pb.TagNumber(7)
  void clearDrainageClass() => $_clearField(7);
}

class ClimateConditions extends $pb.GeneratedMessage {
  factory ClimateConditions({
    $core.double? avgTemperatureCelsius,
    $core.double? annualRainfallMm,
    $core.double? avgHumidityPct,
    $core.double? frostFreeDays,
    $core.double? solarRadiationKwh,
    $core.String? climateZone,
  }) {
    final result = create();
    if (avgTemperatureCelsius != null)
      result.avgTemperatureCelsius = avgTemperatureCelsius;
    if (annualRainfallMm != null) result.annualRainfallMm = annualRainfallMm;
    if (avgHumidityPct != null) result.avgHumidityPct = avgHumidityPct;
    if (frostFreeDays != null) result.frostFreeDays = frostFreeDays;
    if (solarRadiationKwh != null) result.solarRadiationKwh = solarRadiationKwh;
    if (climateZone != null) result.climateZone = climateZone;
    return result;
  }

  ClimateConditions._();

  factory ClimateConditions.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ClimateConditions.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ClimateConditions',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'avgTemperatureCelsius')
    ..aD(2, _omitFieldNames ? '' : 'annualRainfallMm')
    ..aD(3, _omitFieldNames ? '' : 'avgHumidityPct')
    ..aD(4, _omitFieldNames ? '' : 'frostFreeDays')
    ..aD(5, _omitFieldNames ? '' : 'solarRadiationKwh')
    ..aOS(6, _omitFieldNames ? '' : 'climateZone')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClimateConditions clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClimateConditions copyWith(void Function(ClimateConditions) updates) =>
      super.copyWith((message) => updates(message as ClimateConditions))
          as ClimateConditions;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClimateConditions create() => ClimateConditions._();
  @$core.override
  ClimateConditions createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ClimateConditions getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClimateConditions>(create);
  static ClimateConditions? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get avgTemperatureCelsius => $_getN(0);
  @$pb.TagNumber(1)
  set avgTemperatureCelsius($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAvgTemperatureCelsius() => $_has(0);
  @$pb.TagNumber(1)
  void clearAvgTemperatureCelsius() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get annualRainfallMm => $_getN(1);
  @$pb.TagNumber(2)
  set annualRainfallMm($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAnnualRainfallMm() => $_has(1);
  @$pb.TagNumber(2)
  void clearAnnualRainfallMm() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get avgHumidityPct => $_getN(2);
  @$pb.TagNumber(3)
  set avgHumidityPct($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAvgHumidityPct() => $_has(2);
  @$pb.TagNumber(3)
  void clearAvgHumidityPct() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get frostFreeDays => $_getN(3);
  @$pb.TagNumber(4)
  set frostFreeDays($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFrostFreeDays() => $_has(3);
  @$pb.TagNumber(4)
  void clearFrostFreeDays() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get solarRadiationKwh => $_getN(4);
  @$pb.TagNumber(5)
  set solarRadiationKwh($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSolarRadiationKwh() => $_has(4);
  @$pb.TagNumber(5)
  void clearSolarRadiationKwh() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get climateZone => $_getSZ(5);
  @$pb.TagNumber(6)
  set climateZone($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasClimateZone() => $_has(5);
  @$pb.TagNumber(6)
  void clearClimateZone() => $_clearField(6);
}

class EconomicFactors extends $pb.GeneratedMessage {
  factory EconomicFactors({
    $core.double? marketPricePerKg,
    $core.double? inputCostPerHectare,
    $core.double? laborCostPerHectare,
    $core.double? waterCostPerCubicMeter,
    $core.bool? organicPremium,
  }) {
    final result = create();
    if (marketPricePerKg != null) result.marketPricePerKg = marketPricePerKg;
    if (inputCostPerHectare != null)
      result.inputCostPerHectare = inputCostPerHectare;
    if (laborCostPerHectare != null)
      result.laborCostPerHectare = laborCostPerHectare;
    if (waterCostPerCubicMeter != null)
      result.waterCostPerCubicMeter = waterCostPerCubicMeter;
    if (organicPremium != null) result.organicPremium = organicPremium;
    return result;
  }

  EconomicFactors._();

  factory EconomicFactors.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EconomicFactors.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EconomicFactors',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'marketPricePerKg')
    ..aD(2, _omitFieldNames ? '' : 'inputCostPerHectare')
    ..aD(3, _omitFieldNames ? '' : 'laborCostPerHectare')
    ..aD(4, _omitFieldNames ? '' : 'waterCostPerCubicMeter')
    ..aOB(5, _omitFieldNames ? '' : 'organicPremium')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EconomicFactors clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EconomicFactors copyWith(void Function(EconomicFactors) updates) =>
      super.copyWith((message) => updates(message as EconomicFactors))
          as EconomicFactors;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EconomicFactors create() => EconomicFactors._();
  @$core.override
  EconomicFactors createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EconomicFactors getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EconomicFactors>(create);
  static EconomicFactors? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get marketPricePerKg => $_getN(0);
  @$pb.TagNumber(1)
  set marketPricePerKg($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMarketPricePerKg() => $_has(0);
  @$pb.TagNumber(1)
  void clearMarketPricePerKg() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get inputCostPerHectare => $_getN(1);
  @$pb.TagNumber(2)
  set inputCostPerHectare($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasInputCostPerHectare() => $_has(1);
  @$pb.TagNumber(2)
  void clearInputCostPerHectare() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get laborCostPerHectare => $_getN(2);
  @$pb.TagNumber(3)
  set laborCostPerHectare($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLaborCostPerHectare() => $_has(2);
  @$pb.TagNumber(3)
  void clearLaborCostPerHectare() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get waterCostPerCubicMeter => $_getN(3);
  @$pb.TagNumber(4)
  set waterCostPerCubicMeter($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWaterCostPerCubicMeter() => $_has(3);
  @$pb.TagNumber(4)
  void clearWaterCostPerCubicMeter() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get organicPremium => $_getBF(4);
  @$pb.TagNumber(5)
  set organicPremium($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOrganicPremium() => $_has(4);
  @$pb.TagNumber(5)
  void clearOrganicPremium() => $_clearField(5);
}

class RecommendCropsResponse extends $pb.GeneratedMessage {
  factory RecommendCropsResponse({
    $core.String? requestId,
    $core.Iterable<CropRecommendation>? recommendations,
    $core.String? modelVersion,
    $fixnum.Int64? processingTimeMs,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (recommendations != null) result.recommendations.addAll(recommendations);
    if (modelVersion != null) result.modelVersion = modelVersion;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    return result;
  }

  RecommendCropsResponse._();

  factory RecommendCropsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RecommendCropsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RecommendCropsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..pPM<CropRecommendation>(2, _omitFieldNames ? '' : 'recommendations',
        subBuilder: CropRecommendation.create)
    ..aOS(3, _omitFieldNames ? '' : 'modelVersion')
    ..aInt64(4, _omitFieldNames ? '' : 'processingTimeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecommendCropsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecommendCropsResponse copyWith(
          void Function(RecommendCropsResponse) updates) =>
      super.copyWith((message) => updates(message as RecommendCropsResponse))
          as RecommendCropsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecommendCropsResponse create() => RecommendCropsResponse._();
  @$core.override
  RecommendCropsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RecommendCropsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RecommendCropsResponse>(create);
  static RecommendCropsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<CropRecommendation> get recommendations => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get modelVersion => $_getSZ(2);
  @$pb.TagNumber(3)
  set modelVersion($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasModelVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearModelVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get processingTimeMs => $_getI64(3);
  @$pb.TagNumber(4)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProcessingTimeMs() => $_has(3);
  @$pb.TagNumber(4)
  void clearProcessingTimeMs() => $_clearField(4);
}

class CropRecommendation extends $pb.GeneratedMessage {
  factory CropRecommendation({
    $core.String? cropName,
    $core.String? scientificName,
    $core.String? category,
    $core.double? suitabilityScore,
    $core.double? confidence,
    $core.double? expectedYieldKgPerHa,
    $core.double? expectedProfitPerHa,
    $core.double? waterRequirementMm,
    $core.String? rationale,
    $core.Iterable<$core.String>? riskFactors,
  }) {
    final result = create();
    if (cropName != null) result.cropName = cropName;
    if (scientificName != null) result.scientificName = scientificName;
    if (category != null) result.category = category;
    if (suitabilityScore != null) result.suitabilityScore = suitabilityScore;
    if (confidence != null) result.confidence = confidence;
    if (expectedYieldKgPerHa != null)
      result.expectedYieldKgPerHa = expectedYieldKgPerHa;
    if (expectedProfitPerHa != null)
      result.expectedProfitPerHa = expectedProfitPerHa;
    if (waterRequirementMm != null)
      result.waterRequirementMm = waterRequirementMm;
    if (rationale != null) result.rationale = rationale;
    if (riskFactors != null) result.riskFactors.addAll(riskFactors);
    return result;
  }

  CropRecommendation._();

  factory CropRecommendation.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CropRecommendation.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CropRecommendation',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cropName')
    ..aOS(2, _omitFieldNames ? '' : 'scientificName')
    ..aOS(3, _omitFieldNames ? '' : 'category')
    ..aD(4, _omitFieldNames ? '' : 'suitabilityScore')
    ..aD(5, _omitFieldNames ? '' : 'confidence')
    ..aD(6, _omitFieldNames ? '' : 'expectedYieldKgPerHa')
    ..aD(7, _omitFieldNames ? '' : 'expectedProfitPerHa')
    ..aD(8, _omitFieldNames ? '' : 'waterRequirementMm')
    ..aOS(9, _omitFieldNames ? '' : 'rationale')
    ..pPS(10, _omitFieldNames ? '' : 'riskFactors')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CropRecommendation clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CropRecommendation copyWith(void Function(CropRecommendation) updates) =>
      super.copyWith((message) => updates(message as CropRecommendation))
          as CropRecommendation;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CropRecommendation create() => CropRecommendation._();
  @$core.override
  CropRecommendation createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static CropRecommendation getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CropRecommendation>(create);
  static CropRecommendation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cropName => $_getSZ(0);
  @$pb.TagNumber(1)
  set cropName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCropName() => $_has(0);
  @$pb.TagNumber(1)
  void clearCropName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get scientificName => $_getSZ(1);
  @$pb.TagNumber(2)
  set scientificName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScientificName() => $_has(1);
  @$pb.TagNumber(2)
  void clearScientificName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get category => $_getSZ(2);
  @$pb.TagNumber(3)
  set category($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCategory() => $_has(2);
  @$pb.TagNumber(3)
  void clearCategory() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get suitabilityScore => $_getN(3);
  @$pb.TagNumber(4)
  set suitabilityScore($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSuitabilityScore() => $_has(3);
  @$pb.TagNumber(4)
  void clearSuitabilityScore() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get confidence => $_getN(4);
  @$pb.TagNumber(5)
  set confidence($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConfidence() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfidence() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get expectedYieldKgPerHa => $_getN(5);
  @$pb.TagNumber(6)
  set expectedYieldKgPerHa($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasExpectedYieldKgPerHa() => $_has(5);
  @$pb.TagNumber(6)
  void clearExpectedYieldKgPerHa() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get expectedProfitPerHa => $_getN(6);
  @$pb.TagNumber(7)
  set expectedProfitPerHa($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasExpectedProfitPerHa() => $_has(6);
  @$pb.TagNumber(7)
  void clearExpectedProfitPerHa() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get waterRequirementMm => $_getN(7);
  @$pb.TagNumber(8)
  set waterRequirementMm($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWaterRequirementMm() => $_has(7);
  @$pb.TagNumber(8)
  void clearWaterRequirementMm() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get rationale => $_getSZ(8);
  @$pb.TagNumber(9)
  set rationale($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasRationale() => $_has(8);
  @$pb.TagNumber(9)
  void clearRationale() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<$core.String> get riskFactors => $_getList(9);
}

class ImageData extends $pb.GeneratedMessage {
  factory ImageData({
    $core.String? imageUrl,
    $core.List<$core.int>? imageBytes,
    $core.String? imageType,
    $core.String? mimeType,
  }) {
    final result = create();
    if (imageUrl != null) result.imageUrl = imageUrl;
    if (imageBytes != null) result.imageBytes = imageBytes;
    if (imageType != null) result.imageType = imageType;
    if (mimeType != null) result.mimeType = mimeType;
    return result;
  }

  ImageData._();

  factory ImageData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ImageData.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ImageData',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'imageUrl')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'imageBytes', $pb.PbFieldType.OY)
    ..aOS(3, _omitFieldNames ? '' : 'imageType')
    ..aOS(4, _omitFieldNames ? '' : 'mimeType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImageData copyWith(void Function(ImageData) updates) =>
      super.copyWith((message) => updates(message as ImageData)) as ImageData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImageData create() => ImageData._();
  @$core.override
  ImageData createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ImageData getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImageData>(create);
  static ImageData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get imageUrl => $_getSZ(0);
  @$pb.TagNumber(1)
  set imageUrl($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasImageUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearImageUrl() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get imageBytes => $_getN(1);
  @$pb.TagNumber(2)
  set imageBytes($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasImageBytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearImageBytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get imageType => $_getSZ(2);
  @$pb.TagNumber(3)
  set imageType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasImageType() => $_has(2);
  @$pb.TagNumber(3)
  void clearImageType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get mimeType => $_getSZ(3);
  @$pb.TagNumber(4)
  set mimeType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMimeType() => $_has(3);
  @$pb.TagNumber(4)
  void clearMimeType() => $_clearField(4);
}

class EvaluateFieldRiskRequest extends $pb.GeneratedMessage {
  factory EvaluateFieldRiskRequest({
    $core.String? requestId,
    $core.String? fieldId,
    $core.String? farmId,
    $core.String? cropType,
    FieldWeather? weather,
    FieldSoilState? soilState,
    DetectionResults? detections,
    GrowthState? growth,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (cropType != null) result.cropType = cropType;
    if (weather != null) result.weather = weather;
    if (soilState != null) result.soilState = soilState;
    if (detections != null) result.detections = detections;
    if (growth != null) result.growth = growth;
    return result;
  }

  EvaluateFieldRiskRequest._();

  factory EvaluateFieldRiskRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EvaluateFieldRiskRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EvaluateFieldRiskRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'cropType')
    ..aOM<FieldWeather>(5, _omitFieldNames ? '' : 'weather',
        subBuilder: FieldWeather.create)
    ..aOM<FieldSoilState>(6, _omitFieldNames ? '' : 'soilState',
        subBuilder: FieldSoilState.create)
    ..aOM<DetectionResults>(7, _omitFieldNames ? '' : 'detections',
        subBuilder: DetectionResults.create)
    ..aOM<GrowthState>(8, _omitFieldNames ? '' : 'growth',
        subBuilder: GrowthState.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EvaluateFieldRiskRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EvaluateFieldRiskRequest copyWith(
          void Function(EvaluateFieldRiskRequest) updates) =>
      super.copyWith((message) => updates(message as EvaluateFieldRiskRequest))
          as EvaluateFieldRiskRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EvaluateFieldRiskRequest create() => EvaluateFieldRiskRequest._();
  @$core.override
  EvaluateFieldRiskRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EvaluateFieldRiskRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EvaluateFieldRiskRequest>(create);
  static EvaluateFieldRiskRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

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
  $core.String get cropType => $_getSZ(3);
  @$pb.TagNumber(4)
  set cropType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCropType() => $_has(3);
  @$pb.TagNumber(4)
  void clearCropType() => $_clearField(4);

  @$pb.TagNumber(5)
  FieldWeather get weather => $_getN(4);
  @$pb.TagNumber(5)
  set weather(FieldWeather value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasWeather() => $_has(4);
  @$pb.TagNumber(5)
  void clearWeather() => $_clearField(5);
  @$pb.TagNumber(5)
  FieldWeather ensureWeather() => $_ensure(4);

  @$pb.TagNumber(6)
  FieldSoilState get soilState => $_getN(5);
  @$pb.TagNumber(6)
  set soilState(FieldSoilState value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasSoilState() => $_has(5);
  @$pb.TagNumber(6)
  void clearSoilState() => $_clearField(6);
  @$pb.TagNumber(6)
  FieldSoilState ensureSoilState() => $_ensure(5);

  @$pb.TagNumber(7)
  DetectionResults get detections => $_getN(6);
  @$pb.TagNumber(7)
  set detections(DetectionResults value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasDetections() => $_has(6);
  @$pb.TagNumber(7)
  void clearDetections() => $_clearField(7);
  @$pb.TagNumber(7)
  DetectionResults ensureDetections() => $_ensure(6);

  @$pb.TagNumber(8)
  GrowthState get growth => $_getN(7);
  @$pb.TagNumber(8)
  set growth(GrowthState value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasGrowth() => $_has(7);
  @$pb.TagNumber(8)
  void clearGrowth() => $_clearField(8);
  @$pb.TagNumber(8)
  GrowthState ensureGrowth() => $_ensure(7);
}

class FieldWeather extends $pb.GeneratedMessage {
  factory FieldWeather({
    $core.double? temperatureCurrent,
    $core.double? temperatureMinForecast,
    $core.double? temperatureMaxForecast,
    $core.double? precipitationMm,
    $core.double? precipitationForecastMm,
    $core.double? etReferenceMm,
    $core.double? co2Ppm,
  }) {
    final result = create();
    if (temperatureCurrent != null)
      result.temperatureCurrent = temperatureCurrent;
    if (temperatureMinForecast != null)
      result.temperatureMinForecast = temperatureMinForecast;
    if (temperatureMaxForecast != null)
      result.temperatureMaxForecast = temperatureMaxForecast;
    if (precipitationMm != null) result.precipitationMm = precipitationMm;
    if (precipitationForecastMm != null)
      result.precipitationForecastMm = precipitationForecastMm;
    if (etReferenceMm != null) result.etReferenceMm = etReferenceMm;
    if (co2Ppm != null) result.co2Ppm = co2Ppm;
    return result;
  }

  FieldWeather._();

  factory FieldWeather.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FieldWeather.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldWeather',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'temperatureCurrent')
    ..aD(2, _omitFieldNames ? '' : 'temperatureMinForecast')
    ..aD(3, _omitFieldNames ? '' : 'temperatureMaxForecast')
    ..aD(4, _omitFieldNames ? '' : 'precipitationMm')
    ..aD(5, _omitFieldNames ? '' : 'precipitationForecastMm')
    ..aD(6, _omitFieldNames ? '' : 'etReferenceMm')
    ..aD(7, _omitFieldNames ? '' : 'co2Ppm')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldWeather clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldWeather copyWith(void Function(FieldWeather) updates) =>
      super.copyWith((message) => updates(message as FieldWeather))
          as FieldWeather;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FieldWeather create() => FieldWeather._();
  @$core.override
  FieldWeather createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FieldWeather getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldWeather>(create);
  static FieldWeather? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get temperatureCurrent => $_getN(0);
  @$pb.TagNumber(1)
  set temperatureCurrent($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTemperatureCurrent() => $_has(0);
  @$pb.TagNumber(1)
  void clearTemperatureCurrent() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get temperatureMinForecast => $_getN(1);
  @$pb.TagNumber(2)
  set temperatureMinForecast($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTemperatureMinForecast() => $_has(1);
  @$pb.TagNumber(2)
  void clearTemperatureMinForecast() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get temperatureMaxForecast => $_getN(2);
  @$pb.TagNumber(3)
  set temperatureMaxForecast($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTemperatureMaxForecast() => $_has(2);
  @$pb.TagNumber(3)
  void clearTemperatureMaxForecast() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get precipitationMm => $_getN(3);
  @$pb.TagNumber(4)
  set precipitationMm($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPrecipitationMm() => $_has(3);
  @$pb.TagNumber(4)
  void clearPrecipitationMm() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get precipitationForecastMm => $_getN(4);
  @$pb.TagNumber(5)
  set precipitationForecastMm($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPrecipitationForecastMm() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrecipitationForecastMm() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get etReferenceMm => $_getN(5);
  @$pb.TagNumber(6)
  set etReferenceMm($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasEtReferenceMm() => $_has(5);
  @$pb.TagNumber(6)
  void clearEtReferenceMm() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get co2Ppm => $_getN(6);
  @$pb.TagNumber(7)
  set co2Ppm($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasCo2Ppm() => $_has(6);
  @$pb.TagNumber(7)
  void clearCo2Ppm() => $_clearField(7);
}

class FieldSoilState extends $pb.GeneratedMessage {
  factory FieldSoilState({
    $core.double? soilMoisture,
  }) {
    final result = create();
    if (soilMoisture != null) result.soilMoisture = soilMoisture;
    return result;
  }

  FieldSoilState._();

  factory FieldSoilState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FieldSoilState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldSoilState',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'soilMoisture')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldSoilState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldSoilState copyWith(void Function(FieldSoilState) updates) =>
      super.copyWith((message) => updates(message as FieldSoilState))
          as FieldSoilState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FieldSoilState create() => FieldSoilState._();
  @$core.override
  FieldSoilState createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FieldSoilState getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldSoilState>(create);
  static FieldSoilState? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get soilMoisture => $_getN(0);
  @$pb.TagNumber(1)
  set soilMoisture($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSoilMoisture() => $_has(0);
  @$pb.TagNumber(1)
  void clearSoilMoisture() => $_clearField(1);
}

class DetectionResults extends $pb.GeneratedMessage {
  factory DetectionResults({
    $core.double? pestConfidence,
    $core.String? pestSpecies,
    $core.double? diseaseConfidence,
    $core.String? diseaseName,
    $core.double? nutrientSeverity,
    $core.String? nutrientType,
  }) {
    final result = create();
    if (pestConfidence != null) result.pestConfidence = pestConfidence;
    if (pestSpecies != null) result.pestSpecies = pestSpecies;
    if (diseaseConfidence != null) result.diseaseConfidence = diseaseConfidence;
    if (diseaseName != null) result.diseaseName = diseaseName;
    if (nutrientSeverity != null) result.nutrientSeverity = nutrientSeverity;
    if (nutrientType != null) result.nutrientType = nutrientType;
    return result;
  }

  DetectionResults._();

  factory DetectionResults.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DetectionResults.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DetectionResults',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'pestConfidence')
    ..aOS(2, _omitFieldNames ? '' : 'pestSpecies')
    ..aD(3, _omitFieldNames ? '' : 'diseaseConfidence')
    ..aOS(4, _omitFieldNames ? '' : 'diseaseName')
    ..aD(5, _omitFieldNames ? '' : 'nutrientSeverity')
    ..aOS(6, _omitFieldNames ? '' : 'nutrientType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectionResults clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectionResults copyWith(void Function(DetectionResults) updates) =>
      super.copyWith((message) => updates(message as DetectionResults))
          as DetectionResults;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectionResults create() => DetectionResults._();
  @$core.override
  DetectionResults createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DetectionResults getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DetectionResults>(create);
  static DetectionResults? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get pestConfidence => $_getN(0);
  @$pb.TagNumber(1)
  set pestConfidence($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPestConfidence() => $_has(0);
  @$pb.TagNumber(1)
  void clearPestConfidence() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pestSpecies => $_getSZ(1);
  @$pb.TagNumber(2)
  set pestSpecies($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPestSpecies() => $_has(1);
  @$pb.TagNumber(2)
  void clearPestSpecies() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get diseaseConfidence => $_getN(2);
  @$pb.TagNumber(3)
  set diseaseConfidence($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDiseaseConfidence() => $_has(2);
  @$pb.TagNumber(3)
  void clearDiseaseConfidence() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get diseaseName => $_getSZ(3);
  @$pb.TagNumber(4)
  set diseaseName($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDiseaseName() => $_has(3);
  @$pb.TagNumber(4)
  void clearDiseaseName() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get nutrientSeverity => $_getN(4);
  @$pb.TagNumber(5)
  set nutrientSeverity($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNutrientSeverity() => $_has(4);
  @$pb.TagNumber(5)
  void clearNutrientSeverity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get nutrientType => $_getSZ(5);
  @$pb.TagNumber(6)
  set nutrientType($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNutrientType() => $_has(5);
  @$pb.TagNumber(6)
  void clearNutrientType() => $_clearField(6);
}

class GrowthState extends $pb.GeneratedMessage {
  factory GrowthState({
    $core.double? ndviCurrent,
    $core.double? ndviPrevious,
    $core.double? growthExpected,
    $core.double? growthActual,
  }) {
    final result = create();
    if (ndviCurrent != null) result.ndviCurrent = ndviCurrent;
    if (ndviPrevious != null) result.ndviPrevious = ndviPrevious;
    if (growthExpected != null) result.growthExpected = growthExpected;
    if (growthActual != null) result.growthActual = growthActual;
    return result;
  }

  GrowthState._();

  factory GrowthState.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GrowthState.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GrowthState',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'ndviCurrent')
    ..aD(2, _omitFieldNames ? '' : 'ndviPrevious')
    ..aD(3, _omitFieldNames ? '' : 'growthExpected')
    ..aD(4, _omitFieldNames ? '' : 'growthActual')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GrowthState clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GrowthState copyWith(void Function(GrowthState) updates) =>
      super.copyWith((message) => updates(message as GrowthState))
          as GrowthState;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GrowthState create() => GrowthState._();
  @$core.override
  GrowthState createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GrowthState getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GrowthState>(create);
  static GrowthState? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get ndviCurrent => $_getN(0);
  @$pb.TagNumber(1)
  set ndviCurrent($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNdviCurrent() => $_has(0);
  @$pb.TagNumber(1)
  void clearNdviCurrent() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get ndviPrevious => $_getN(1);
  @$pb.TagNumber(2)
  set ndviPrevious($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNdviPrevious() => $_has(1);
  @$pb.TagNumber(2)
  void clearNdviPrevious() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get growthExpected => $_getN(2);
  @$pb.TagNumber(3)
  set growthExpected($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGrowthExpected() => $_has(2);
  @$pb.TagNumber(3)
  void clearGrowthExpected() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get growthActual => $_getN(3);
  @$pb.TagNumber(4)
  set growthActual($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGrowthActual() => $_has(3);
  @$pb.TagNumber(4)
  void clearGrowthActual() => $_clearField(4);
}

class EvaluateFieldRiskResponse extends $pb.GeneratedMessage {
  factory EvaluateFieldRiskResponse({
    $core.String? requestId,
    $core.String? fieldId,
    $core.double? overallRisk,
    $core.double? temperatureRisk,
    $core.double? waterRisk,
    $core.double? pestRisk,
    $core.double? diseaseRisk,
    $core.double? nutrientRisk,
    $core.double? growthRisk,
    $core.Iterable<FieldAlert>? alerts,
    $fixnum.Int64? processingTimeMs,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (fieldId != null) result.fieldId = fieldId;
    if (overallRisk != null) result.overallRisk = overallRisk;
    if (temperatureRisk != null) result.temperatureRisk = temperatureRisk;
    if (waterRisk != null) result.waterRisk = waterRisk;
    if (pestRisk != null) result.pestRisk = pestRisk;
    if (diseaseRisk != null) result.diseaseRisk = diseaseRisk;
    if (nutrientRisk != null) result.nutrientRisk = nutrientRisk;
    if (growthRisk != null) result.growthRisk = growthRisk;
    if (alerts != null) result.alerts.addAll(alerts);
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    return result;
  }

  EvaluateFieldRiskResponse._();

  factory EvaluateFieldRiskResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EvaluateFieldRiskResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EvaluateFieldRiskResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aD(3, _omitFieldNames ? '' : 'overallRisk')
    ..aD(4, _omitFieldNames ? '' : 'temperatureRisk')
    ..aD(5, _omitFieldNames ? '' : 'waterRisk')
    ..aD(6, _omitFieldNames ? '' : 'pestRisk')
    ..aD(7, _omitFieldNames ? '' : 'diseaseRisk')
    ..aD(8, _omitFieldNames ? '' : 'nutrientRisk')
    ..aD(9, _omitFieldNames ? '' : 'growthRisk')
    ..pPM<FieldAlert>(10, _omitFieldNames ? '' : 'alerts',
        subBuilder: FieldAlert.create)
    ..aInt64(11, _omitFieldNames ? '' : 'processingTimeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EvaluateFieldRiskResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EvaluateFieldRiskResponse copyWith(
          void Function(EvaluateFieldRiskResponse) updates) =>
      super.copyWith((message) => updates(message as EvaluateFieldRiskResponse))
          as EvaluateFieldRiskResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EvaluateFieldRiskResponse create() => EvaluateFieldRiskResponse._();
  @$core.override
  EvaluateFieldRiskResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EvaluateFieldRiskResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EvaluateFieldRiskResponse>(create);
  static EvaluateFieldRiskResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get overallRisk => $_getN(2);
  @$pb.TagNumber(3)
  set overallRisk($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOverallRisk() => $_has(2);
  @$pb.TagNumber(3)
  void clearOverallRisk() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get temperatureRisk => $_getN(3);
  @$pb.TagNumber(4)
  set temperatureRisk($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTemperatureRisk() => $_has(3);
  @$pb.TagNumber(4)
  void clearTemperatureRisk() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get waterRisk => $_getN(4);
  @$pb.TagNumber(5)
  set waterRisk($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWaterRisk() => $_has(4);
  @$pb.TagNumber(5)
  void clearWaterRisk() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get pestRisk => $_getN(5);
  @$pb.TagNumber(6)
  set pestRisk($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPestRisk() => $_has(5);
  @$pb.TagNumber(6)
  void clearPestRisk() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get diseaseRisk => $_getN(6);
  @$pb.TagNumber(7)
  set diseaseRisk($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDiseaseRisk() => $_has(6);
  @$pb.TagNumber(7)
  void clearDiseaseRisk() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get nutrientRisk => $_getN(7);
  @$pb.TagNumber(8)
  set nutrientRisk($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNutrientRisk() => $_has(7);
  @$pb.TagNumber(8)
  void clearNutrientRisk() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get growthRisk => $_getN(8);
  @$pb.TagNumber(9)
  set growthRisk($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasGrowthRisk() => $_has(8);
  @$pb.TagNumber(9)
  void clearGrowthRisk() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<FieldAlert> get alerts => $_getList(9);

  @$pb.TagNumber(11)
  $fixnum.Int64 get processingTimeMs => $_getI64(10);
  @$pb.TagNumber(11)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasProcessingTimeMs() => $_has(10);
  @$pb.TagNumber(11)
  void clearProcessingTimeMs() => $_clearField(11);
}

class FieldAlert extends $pb.GeneratedMessage {
  factory FieldAlert({
    $core.String? alertType,
    $core.String? severity,
    $core.String? title,
    $core.String? message,
    $core.Iterable<$core.String>? recommendations,
    $core.double? metricValue,
    $core.double? thresholdValue,
  }) {
    final result = create();
    if (alertType != null) result.alertType = alertType;
    if (severity != null) result.severity = severity;
    if (title != null) result.title = title;
    if (message != null) result.message = message;
    if (recommendations != null) result.recommendations.addAll(recommendations);
    if (metricValue != null) result.metricValue = metricValue;
    if (thresholdValue != null) result.thresholdValue = thresholdValue;
    return result;
  }

  FieldAlert._();

  factory FieldAlert.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory FieldAlert.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'FieldAlert',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'alertType')
    ..aOS(2, _omitFieldNames ? '' : 'severity')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'message')
    ..pPS(5, _omitFieldNames ? '' : 'recommendations')
    ..aD(6, _omitFieldNames ? '' : 'metricValue')
    ..aD(7, _omitFieldNames ? '' : 'thresholdValue')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldAlert clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FieldAlert copyWith(void Function(FieldAlert) updates) =>
      super.copyWith((message) => updates(message as FieldAlert)) as FieldAlert;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FieldAlert create() => FieldAlert._();
  @$core.override
  FieldAlert createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static FieldAlert getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FieldAlert>(create);
  static FieldAlert? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get alertType => $_getSZ(0);
  @$pb.TagNumber(1)
  set alertType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAlertType() => $_has(0);
  @$pb.TagNumber(1)
  void clearAlertType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get severity => $_getSZ(1);
  @$pb.TagNumber(2)
  set severity($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSeverity() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeverity() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get message => $_getSZ(3);
  @$pb.TagNumber(4)
  set message($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMessage() => $_has(3);
  @$pb.TagNumber(4)
  void clearMessage() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get recommendations => $_getList(4);

  @$pb.TagNumber(6)
  $core.double get metricValue => $_getN(5);
  @$pb.TagNumber(6)
  set metricValue($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMetricValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearMetricValue() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get thresholdValue => $_getN(6);
  @$pb.TagNumber(7)
  set thresholdValue($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasThresholdValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearThresholdValue() => $_clearField(7);
}

class ComputeFieldAnalyticsRequest extends $pb.GeneratedMessage {
  factory ComputeFieldAnalyticsRequest({
    $core.String? requestId,
    $core.String? fieldId,
    $core.String? farmId,
    $core.Iterable<SeasonRecord>? seasons,
    $core.Iterable<NdviDataPoint>? ndviSeries,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (fieldId != null) result.fieldId = fieldId;
    if (farmId != null) result.farmId = farmId;
    if (seasons != null) result.seasons.addAll(seasons);
    if (ndviSeries != null) result.ndviSeries.addAll(ndviSeries);
    return result;
  }

  ComputeFieldAnalyticsRequest._();

  factory ComputeFieldAnalyticsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ComputeFieldAnalyticsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ComputeFieldAnalyticsRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..pPM<SeasonRecord>(4, _omitFieldNames ? '' : 'seasons',
        subBuilder: SeasonRecord.create)
    ..pPM<NdviDataPoint>(5, _omitFieldNames ? '' : 'ndviSeries',
        subBuilder: NdviDataPoint.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeFieldAnalyticsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeFieldAnalyticsRequest copyWith(
          void Function(ComputeFieldAnalyticsRequest) updates) =>
      super.copyWith(
              (message) => updates(message as ComputeFieldAnalyticsRequest))
          as ComputeFieldAnalyticsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ComputeFieldAnalyticsRequest create() =>
      ComputeFieldAnalyticsRequest._();
  @$core.override
  ComputeFieldAnalyticsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ComputeFieldAnalyticsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ComputeFieldAnalyticsRequest>(create);
  static ComputeFieldAnalyticsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

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
  $pb.PbList<SeasonRecord> get seasons => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<NdviDataPoint> get ndviSeries => $_getList(4);
}

class SeasonRecord extends $pb.GeneratedMessage {
  factory SeasonRecord({
    $core.String? cropType,
    $core.String? season,
    $core.int? year,
    $core.double? yieldKgPerHa,
    $core.int? stressDays,
    $core.int? frostEvents,
    $core.int? heatEvents,
    $core.int? droughtDays,
    $core.double? totalPrecipitationMm,
    $core.double? meanTemperature,
    $core.double? meanNdvi,
    $core.double? peakNdvi,
    $core.double? totalThermalTime,
  }) {
    final result = create();
    if (cropType != null) result.cropType = cropType;
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (yieldKgPerHa != null) result.yieldKgPerHa = yieldKgPerHa;
    if (stressDays != null) result.stressDays = stressDays;
    if (frostEvents != null) result.frostEvents = frostEvents;
    if (heatEvents != null) result.heatEvents = heatEvents;
    if (droughtDays != null) result.droughtDays = droughtDays;
    if (totalPrecipitationMm != null)
      result.totalPrecipitationMm = totalPrecipitationMm;
    if (meanTemperature != null) result.meanTemperature = meanTemperature;
    if (meanNdvi != null) result.meanNdvi = meanNdvi;
    if (peakNdvi != null) result.peakNdvi = peakNdvi;
    if (totalThermalTime != null) result.totalThermalTime = totalThermalTime;
    return result;
  }

  SeasonRecord._();

  factory SeasonRecord.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SeasonRecord.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SeasonRecord',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cropType')
    ..aOS(2, _omitFieldNames ? '' : 'season')
    ..aI(3, _omitFieldNames ? '' : 'year')
    ..aD(4, _omitFieldNames ? '' : 'yieldKgPerHa')
    ..aI(5, _omitFieldNames ? '' : 'stressDays', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'frostEvents',
        fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'heatEvents', fieldType: $pb.PbFieldType.OU3)
    ..aI(8, _omitFieldNames ? '' : 'droughtDays',
        fieldType: $pb.PbFieldType.OU3)
    ..aD(9, _omitFieldNames ? '' : 'totalPrecipitationMm')
    ..aD(10, _omitFieldNames ? '' : 'meanTemperature')
    ..aD(11, _omitFieldNames ? '' : 'meanNdvi')
    ..aD(12, _omitFieldNames ? '' : 'peakNdvi')
    ..aD(13, _omitFieldNames ? '' : 'totalThermalTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SeasonRecord clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SeasonRecord copyWith(void Function(SeasonRecord) updates) =>
      super.copyWith((message) => updates(message as SeasonRecord))
          as SeasonRecord;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SeasonRecord create() => SeasonRecord._();
  @$core.override
  SeasonRecord createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SeasonRecord getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SeasonRecord>(create);
  static SeasonRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cropType => $_getSZ(0);
  @$pb.TagNumber(1)
  set cropType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCropType() => $_has(0);
  @$pb.TagNumber(1)
  void clearCropType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get season => $_getSZ(1);
  @$pb.TagNumber(2)
  set season($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSeason() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeason() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get year => $_getIZ(2);
  @$pb.TagNumber(3)
  set year($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasYear() => $_has(2);
  @$pb.TagNumber(3)
  void clearYear() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get yieldKgPerHa => $_getN(3);
  @$pb.TagNumber(4)
  set yieldKgPerHa($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasYieldKgPerHa() => $_has(3);
  @$pb.TagNumber(4)
  void clearYieldKgPerHa() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get stressDays => $_getIZ(4);
  @$pb.TagNumber(5)
  set stressDays($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStressDays() => $_has(4);
  @$pb.TagNumber(5)
  void clearStressDays() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get frostEvents => $_getIZ(5);
  @$pb.TagNumber(6)
  set frostEvents($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFrostEvents() => $_has(5);
  @$pb.TagNumber(6)
  void clearFrostEvents() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get heatEvents => $_getIZ(6);
  @$pb.TagNumber(7)
  set heatEvents($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHeatEvents() => $_has(6);
  @$pb.TagNumber(7)
  void clearHeatEvents() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get droughtDays => $_getIZ(7);
  @$pb.TagNumber(8)
  set droughtDays($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDroughtDays() => $_has(7);
  @$pb.TagNumber(8)
  void clearDroughtDays() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get totalPrecipitationMm => $_getN(8);
  @$pb.TagNumber(9)
  set totalPrecipitationMm($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTotalPrecipitationMm() => $_has(8);
  @$pb.TagNumber(9)
  void clearTotalPrecipitationMm() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get meanTemperature => $_getN(9);
  @$pb.TagNumber(10)
  set meanTemperature($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasMeanTemperature() => $_has(9);
  @$pb.TagNumber(10)
  void clearMeanTemperature() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get meanNdvi => $_getN(10);
  @$pb.TagNumber(11)
  set meanNdvi($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasMeanNdvi() => $_has(10);
  @$pb.TagNumber(11)
  void clearMeanNdvi() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get peakNdvi => $_getN(11);
  @$pb.TagNumber(12)
  set peakNdvi($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPeakNdvi() => $_has(11);
  @$pb.TagNumber(12)
  void clearPeakNdvi() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.double get totalThermalTime => $_getN(12);
  @$pb.TagNumber(13)
  set totalThermalTime($core.double value) => $_setDouble(12, value);
  @$pb.TagNumber(13)
  $core.bool hasTotalThermalTime() => $_has(12);
  @$pb.TagNumber(13)
  void clearTotalThermalTime() => $_clearField(13);
}

class NdviDataPoint extends $pb.GeneratedMessage {
  factory NdviDataPoint({
    $core.String? date,
    $core.double? meanNdvi,
    $core.double? minNdvi,
    $core.double? maxNdvi,
    $core.double? stdDev,
  }) {
    final result = create();
    if (date != null) result.date = date;
    if (meanNdvi != null) result.meanNdvi = meanNdvi;
    if (minNdvi != null) result.minNdvi = minNdvi;
    if (maxNdvi != null) result.maxNdvi = maxNdvi;
    if (stdDev != null) result.stdDev = stdDev;
    return result;
  }

  NdviDataPoint._();

  factory NdviDataPoint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NdviDataPoint.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NdviDataPoint',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'date')
    ..aD(2, _omitFieldNames ? '' : 'meanNdvi')
    ..aD(3, _omitFieldNames ? '' : 'minNdvi')
    ..aD(4, _omitFieldNames ? '' : 'maxNdvi')
    ..aD(5, _omitFieldNames ? '' : 'stdDev')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NdviDataPoint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NdviDataPoint copyWith(void Function(NdviDataPoint) updates) =>
      super.copyWith((message) => updates(message as NdviDataPoint))
          as NdviDataPoint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NdviDataPoint create() => NdviDataPoint._();
  @$core.override
  NdviDataPoint createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static NdviDataPoint getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NdviDataPoint>(create);
  static NdviDataPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get date => $_getSZ(0);
  @$pb.TagNumber(1)
  set date($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDate() => $_has(0);
  @$pb.TagNumber(1)
  void clearDate() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get meanNdvi => $_getN(1);
  @$pb.TagNumber(2)
  set meanNdvi($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMeanNdvi() => $_has(1);
  @$pb.TagNumber(2)
  void clearMeanNdvi() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get minNdvi => $_getN(2);
  @$pb.TagNumber(3)
  set minNdvi($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMinNdvi() => $_has(2);
  @$pb.TagNumber(3)
  void clearMinNdvi() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get maxNdvi => $_getN(3);
  @$pb.TagNumber(4)
  set maxNdvi($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMaxNdvi() => $_has(3);
  @$pb.TagNumber(4)
  void clearMaxNdvi() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get stdDev => $_getN(4);
  @$pb.TagNumber(5)
  set stdDev($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStdDev() => $_has(4);
  @$pb.TagNumber(5)
  void clearStdDev() => $_clearField(5);
}

class ComputeFieldAnalyticsResponse extends $pb.GeneratedMessage {
  factory ComputeFieldAnalyticsResponse({
    $core.String? requestId,
    $core.String? fieldId,
    $core.int? seasonCount,
    $core.String? yieldTrend,
    $core.double? yieldTrendPctPerYear,
    $core.double? meanYield,
    $core.double? bestYield,
    $core.double? worstYield,
    $core.double? yieldVariabilityCv,
    $core.String? ndviTrend,
    $core.double? ndviTrendPerYear,
    $core.double? meanStressDaysPerSeason,
    RotationAnalysis? rotation,
    $core.Iterable<SeasonComparisonResult>? seasonComparisons,
    $fixnum.Int64? processingTimeMs,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (fieldId != null) result.fieldId = fieldId;
    if (seasonCount != null) result.seasonCount = seasonCount;
    if (yieldTrend != null) result.yieldTrend = yieldTrend;
    if (yieldTrendPctPerYear != null)
      result.yieldTrendPctPerYear = yieldTrendPctPerYear;
    if (meanYield != null) result.meanYield = meanYield;
    if (bestYield != null) result.bestYield = bestYield;
    if (worstYield != null) result.worstYield = worstYield;
    if (yieldVariabilityCv != null)
      result.yieldVariabilityCv = yieldVariabilityCv;
    if (ndviTrend != null) result.ndviTrend = ndviTrend;
    if (ndviTrendPerYear != null) result.ndviTrendPerYear = ndviTrendPerYear;
    if (meanStressDaysPerSeason != null)
      result.meanStressDaysPerSeason = meanStressDaysPerSeason;
    if (rotation != null) result.rotation = rotation;
    if (seasonComparisons != null)
      result.seasonComparisons.addAll(seasonComparisons);
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    return result;
  }

  ComputeFieldAnalyticsResponse._();

  factory ComputeFieldAnalyticsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ComputeFieldAnalyticsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ComputeFieldAnalyticsResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aI(3, _omitFieldNames ? '' : 'seasonCount')
    ..aOS(4, _omitFieldNames ? '' : 'yieldTrend')
    ..aD(5, _omitFieldNames ? '' : 'yieldTrendPctPerYear')
    ..aD(6, _omitFieldNames ? '' : 'meanYield')
    ..aD(7, _omitFieldNames ? '' : 'bestYield')
    ..aD(8, _omitFieldNames ? '' : 'worstYield')
    ..aD(9, _omitFieldNames ? '' : 'yieldVariabilityCv')
    ..aOS(10, _omitFieldNames ? '' : 'ndviTrend')
    ..aD(11, _omitFieldNames ? '' : 'ndviTrendPerYear')
    ..aD(12, _omitFieldNames ? '' : 'meanStressDaysPerSeason')
    ..aOM<RotationAnalysis>(13, _omitFieldNames ? '' : 'rotation',
        subBuilder: RotationAnalysis.create)
    ..pPM<SeasonComparisonResult>(
        14, _omitFieldNames ? '' : 'seasonComparisons',
        subBuilder: SeasonComparisonResult.create)
    ..aInt64(15, _omitFieldNames ? '' : 'processingTimeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeFieldAnalyticsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ComputeFieldAnalyticsResponse copyWith(
          void Function(ComputeFieldAnalyticsResponse) updates) =>
      super.copyWith(
              (message) => updates(message as ComputeFieldAnalyticsResponse))
          as ComputeFieldAnalyticsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ComputeFieldAnalyticsResponse create() =>
      ComputeFieldAnalyticsResponse._();
  @$core.override
  ComputeFieldAnalyticsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ComputeFieldAnalyticsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ComputeFieldAnalyticsResponse>(create);
  static ComputeFieldAnalyticsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get seasonCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set seasonCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSeasonCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeasonCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get yieldTrend => $_getSZ(3);
  @$pb.TagNumber(4)
  set yieldTrend($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasYieldTrend() => $_has(3);
  @$pb.TagNumber(4)
  void clearYieldTrend() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get yieldTrendPctPerYear => $_getN(4);
  @$pb.TagNumber(5)
  set yieldTrendPctPerYear($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasYieldTrendPctPerYear() => $_has(4);
  @$pb.TagNumber(5)
  void clearYieldTrendPctPerYear() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get meanYield => $_getN(5);
  @$pb.TagNumber(6)
  set meanYield($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMeanYield() => $_has(5);
  @$pb.TagNumber(6)
  void clearMeanYield() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get bestYield => $_getN(6);
  @$pb.TagNumber(7)
  set bestYield($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBestYield() => $_has(6);
  @$pb.TagNumber(7)
  void clearBestYield() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get worstYield => $_getN(7);
  @$pb.TagNumber(8)
  set worstYield($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWorstYield() => $_has(7);
  @$pb.TagNumber(8)
  void clearWorstYield() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get yieldVariabilityCv => $_getN(8);
  @$pb.TagNumber(9)
  set yieldVariabilityCv($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasYieldVariabilityCv() => $_has(8);
  @$pb.TagNumber(9)
  void clearYieldVariabilityCv() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get ndviTrend => $_getSZ(9);
  @$pb.TagNumber(10)
  set ndviTrend($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasNdviTrend() => $_has(9);
  @$pb.TagNumber(10)
  void clearNdviTrend() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get ndviTrendPerYear => $_getN(10);
  @$pb.TagNumber(11)
  set ndviTrendPerYear($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasNdviTrendPerYear() => $_has(10);
  @$pb.TagNumber(11)
  void clearNdviTrendPerYear() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get meanStressDaysPerSeason => $_getN(11);
  @$pb.TagNumber(12)
  set meanStressDaysPerSeason($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasMeanStressDaysPerSeason() => $_has(11);
  @$pb.TagNumber(12)
  void clearMeanStressDaysPerSeason() => $_clearField(12);

  @$pb.TagNumber(13)
  RotationAnalysis get rotation => $_getN(12);
  @$pb.TagNumber(13)
  set rotation(RotationAnalysis value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasRotation() => $_has(12);
  @$pb.TagNumber(13)
  void clearRotation() => $_clearField(13);
  @$pb.TagNumber(13)
  RotationAnalysis ensureRotation() => $_ensure(12);

  @$pb.TagNumber(14)
  $pb.PbList<SeasonComparisonResult> get seasonComparisons => $_getList(13);

  @$pb.TagNumber(15)
  $fixnum.Int64 get processingTimeMs => $_getI64(14);
  @$pb.TagNumber(15)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(14, value);
  @$pb.TagNumber(15)
  $core.bool hasProcessingTimeMs() => $_has(14);
  @$pb.TagNumber(15)
  void clearProcessingTimeMs() => $_clearField(15);
}

class RotationAnalysis extends $pb.GeneratedMessage {
  factory RotationAnalysis({
    $core.Iterable<$core.String>? rotationPattern,
    $core.double? effectivenessScore,
    $core.double? yieldImpactPct,
    $core.double? stressReductionPct,
    $core.String? recommendation,
  }) {
    final result = create();
    if (rotationPattern != null) result.rotationPattern.addAll(rotationPattern);
    if (effectivenessScore != null)
      result.effectivenessScore = effectivenessScore;
    if (yieldImpactPct != null) result.yieldImpactPct = yieldImpactPct;
    if (stressReductionPct != null)
      result.stressReductionPct = stressReductionPct;
    if (recommendation != null) result.recommendation = recommendation;
    return result;
  }

  RotationAnalysis._();

  factory RotationAnalysis.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RotationAnalysis.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RotationAnalysis',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'rotationPattern')
    ..aD(2, _omitFieldNames ? '' : 'effectivenessScore')
    ..aD(3, _omitFieldNames ? '' : 'yieldImpactPct')
    ..aD(4, _omitFieldNames ? '' : 'stressReductionPct')
    ..aOS(5, _omitFieldNames ? '' : 'recommendation')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RotationAnalysis clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RotationAnalysis copyWith(void Function(RotationAnalysis) updates) =>
      super.copyWith((message) => updates(message as RotationAnalysis))
          as RotationAnalysis;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RotationAnalysis create() => RotationAnalysis._();
  @$core.override
  RotationAnalysis createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static RotationAnalysis getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RotationAnalysis>(create);
  static RotationAnalysis? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get rotationPattern => $_getList(0);

  @$pb.TagNumber(2)
  $core.double get effectivenessScore => $_getN(1);
  @$pb.TagNumber(2)
  set effectivenessScore($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEffectivenessScore() => $_has(1);
  @$pb.TagNumber(2)
  void clearEffectivenessScore() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get yieldImpactPct => $_getN(2);
  @$pb.TagNumber(3)
  set yieldImpactPct($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasYieldImpactPct() => $_has(2);
  @$pb.TagNumber(3)
  void clearYieldImpactPct() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get stressReductionPct => $_getN(3);
  @$pb.TagNumber(4)
  set stressReductionPct($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStressReductionPct() => $_has(3);
  @$pb.TagNumber(4)
  void clearStressReductionPct() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get recommendation => $_getSZ(4);
  @$pb.TagNumber(5)
  set recommendation($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRecommendation() => $_has(4);
  @$pb.TagNumber(5)
  void clearRecommendation() => $_clearField(5);
}

class SeasonComparisonResult extends $pb.GeneratedMessage {
  factory SeasonComparisonResult({
    $core.String? season,
    $core.int? year,
    $core.String? cropType,
    $core.double? yieldVsMeanPct,
    $core.double? stressVsMeanPct,
    $core.double? ndviVsMeanPct,
    $core.Iterable<$core.String>? notableEvents,
  }) {
    final result = create();
    if (season != null) result.season = season;
    if (year != null) result.year = year;
    if (cropType != null) result.cropType = cropType;
    if (yieldVsMeanPct != null) result.yieldVsMeanPct = yieldVsMeanPct;
    if (stressVsMeanPct != null) result.stressVsMeanPct = stressVsMeanPct;
    if (ndviVsMeanPct != null) result.ndviVsMeanPct = ndviVsMeanPct;
    if (notableEvents != null) result.notableEvents.addAll(notableEvents);
    return result;
  }

  SeasonComparisonResult._();

  factory SeasonComparisonResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SeasonComparisonResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SeasonComparisonResult',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'season')
    ..aI(2, _omitFieldNames ? '' : 'year')
    ..aOS(3, _omitFieldNames ? '' : 'cropType')
    ..aD(4, _omitFieldNames ? '' : 'yieldVsMeanPct')
    ..aD(5, _omitFieldNames ? '' : 'stressVsMeanPct')
    ..aD(6, _omitFieldNames ? '' : 'ndviVsMeanPct')
    ..pPS(7, _omitFieldNames ? '' : 'notableEvents')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SeasonComparisonResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SeasonComparisonResult copyWith(
          void Function(SeasonComparisonResult) updates) =>
      super.copyWith((message) => updates(message as SeasonComparisonResult))
          as SeasonComparisonResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SeasonComparisonResult create() => SeasonComparisonResult._();
  @$core.override
  SeasonComparisonResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SeasonComparisonResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SeasonComparisonResult>(create);
  static SeasonComparisonResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get season => $_getSZ(0);
  @$pb.TagNumber(1)
  set season($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeason() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeason() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get year => $_getIZ(1);
  @$pb.TagNumber(2)
  set year($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasYear() => $_has(1);
  @$pb.TagNumber(2)
  void clearYear() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get cropType => $_getSZ(2);
  @$pb.TagNumber(3)
  set cropType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCropType() => $_has(2);
  @$pb.TagNumber(3)
  void clearCropType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get yieldVsMeanPct => $_getN(3);
  @$pb.TagNumber(4)
  set yieldVsMeanPct($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasYieldVsMeanPct() => $_has(3);
  @$pb.TagNumber(4)
  void clearYieldVsMeanPct() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get stressVsMeanPct => $_getN(4);
  @$pb.TagNumber(5)
  set stressVsMeanPct($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasStressVsMeanPct() => $_has(4);
  @$pb.TagNumber(5)
  void clearStressVsMeanPct() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get ndviVsMeanPct => $_getN(5);
  @$pb.TagNumber(6)
  set ndviVsMeanPct($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNdviVsMeanPct() => $_has(5);
  @$pb.TagNumber(6)
  void clearNdviVsMeanPct() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get notableEvents => $_getList(6);
}

class GeneratePrescriptionRequest extends $pb.GeneratedMessage {
  factory GeneratePrescriptionRequest({
    $core.String? requestId,
    $core.String? fieldId,
    PrescriptionGrid? grid,
    PrescriptionZoneInput? zoneInput,
    PrescriptionCropRequirements? cropRequirements,
    $core.Iterable<$core.String>? prescriptionTypes,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (fieldId != null) result.fieldId = fieldId;
    if (grid != null) result.grid = grid;
    if (zoneInput != null) result.zoneInput = zoneInput;
    if (cropRequirements != null) result.cropRequirements = cropRequirements;
    if (prescriptionTypes != null)
      result.prescriptionTypes.addAll(prescriptionTypes);
    return result;
  }

  GeneratePrescriptionRequest._();

  factory GeneratePrescriptionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GeneratePrescriptionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GeneratePrescriptionRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..aOM<PrescriptionGrid>(3, _omitFieldNames ? '' : 'grid',
        subBuilder: PrescriptionGrid.create)
    ..aOM<PrescriptionZoneInput>(4, _omitFieldNames ? '' : 'zoneInput',
        subBuilder: PrescriptionZoneInput.create)
    ..aOM<PrescriptionCropRequirements>(
        5, _omitFieldNames ? '' : 'cropRequirements',
        subBuilder: PrescriptionCropRequirements.create)
    ..pPS(6, _omitFieldNames ? '' : 'prescriptionTypes')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeneratePrescriptionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeneratePrescriptionRequest copyWith(
          void Function(GeneratePrescriptionRequest) updates) =>
      super.copyWith(
              (message) => updates(message as GeneratePrescriptionRequest))
          as GeneratePrescriptionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GeneratePrescriptionRequest create() =>
      GeneratePrescriptionRequest._();
  @$core.override
  GeneratePrescriptionRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GeneratePrescriptionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GeneratePrescriptionRequest>(create);
  static GeneratePrescriptionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  PrescriptionGrid get grid => $_getN(2);
  @$pb.TagNumber(3)
  set grid(PrescriptionGrid value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasGrid() => $_has(2);
  @$pb.TagNumber(3)
  void clearGrid() => $_clearField(3);
  @$pb.TagNumber(3)
  PrescriptionGrid ensureGrid() => $_ensure(2);

  @$pb.TagNumber(4)
  PrescriptionZoneInput get zoneInput => $_getN(3);
  @$pb.TagNumber(4)
  set zoneInput(PrescriptionZoneInput value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasZoneInput() => $_has(3);
  @$pb.TagNumber(4)
  void clearZoneInput() => $_clearField(4);
  @$pb.TagNumber(4)
  PrescriptionZoneInput ensureZoneInput() => $_ensure(3);

  @$pb.TagNumber(5)
  PrescriptionCropRequirements get cropRequirements => $_getN(4);
  @$pb.TagNumber(5)
  set cropRequirements(PrescriptionCropRequirements value) =>
      $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCropRequirements() => $_has(4);
  @$pb.TagNumber(5)
  void clearCropRequirements() => $_clearField(5);
  @$pb.TagNumber(5)
  PrescriptionCropRequirements ensureCropRequirements() => $_ensure(4);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get prescriptionTypes => $_getList(5);
}

class PrescriptionGrid extends $pb.GeneratedMessage {
  factory PrescriptionGrid({
    $core.int? rows,
    $core.int? cols,
    $core.double? cellSizeM,
    $core.double? originLat,
    $core.double? originLon,
  }) {
    final result = create();
    if (rows != null) result.rows = rows;
    if (cols != null) result.cols = cols;
    if (cellSizeM != null) result.cellSizeM = cellSizeM;
    if (originLat != null) result.originLat = originLat;
    if (originLon != null) result.originLon = originLon;
    return result;
  }

  PrescriptionGrid._();

  factory PrescriptionGrid.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PrescriptionGrid.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrescriptionGrid',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'rows')
    ..aI(2, _omitFieldNames ? '' : 'cols')
    ..aD(3, _omitFieldNames ? '' : 'cellSizeM')
    ..aD(4, _omitFieldNames ? '' : 'originLat')
    ..aD(5, _omitFieldNames ? '' : 'originLon')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrescriptionGrid clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrescriptionGrid copyWith(void Function(PrescriptionGrid) updates) =>
      super.copyWith((message) => updates(message as PrescriptionGrid))
          as PrescriptionGrid;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PrescriptionGrid create() => PrescriptionGrid._();
  @$core.override
  PrescriptionGrid createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PrescriptionGrid getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PrescriptionGrid>(create);
  static PrescriptionGrid? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get rows => $_getIZ(0);
  @$pb.TagNumber(1)
  set rows($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRows() => $_has(0);
  @$pb.TagNumber(1)
  void clearRows() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get cols => $_getIZ(1);
  @$pb.TagNumber(2)
  set cols($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCols() => $_has(1);
  @$pb.TagNumber(2)
  void clearCols() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get cellSizeM => $_getN(2);
  @$pb.TagNumber(3)
  set cellSizeM($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCellSizeM() => $_has(2);
  @$pb.TagNumber(3)
  void clearCellSizeM() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get originLat => $_getN(3);
  @$pb.TagNumber(4)
  set originLat($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOriginLat() => $_has(3);
  @$pb.TagNumber(4)
  void clearOriginLat() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get originLon => $_getN(4);
  @$pb.TagNumber(5)
  set originLon($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOriginLon() => $_has(4);
  @$pb.TagNumber(5)
  void clearOriginLon() => $_clearField(5);
}

class PrescriptionZoneInput extends $pb.GeneratedMessage {
  factory PrescriptionZoneInput({
    $core.Iterable<$core.double>? ndvi,
    $core.Iterable<$core.double>? soilNitrogen,
    $core.Iterable<$core.double>? soilPhosphorus,
    $core.Iterable<$core.double>? soilPotassium,
    $core.Iterable<$core.double>? soilPh,
    $core.Iterable<$core.double>? soilMoisture,
    $core.Iterable<$core.double>? soilOrganicMatter,
  }) {
    final result = create();
    if (ndvi != null) result.ndvi.addAll(ndvi);
    if (soilNitrogen != null) result.soilNitrogen.addAll(soilNitrogen);
    if (soilPhosphorus != null) result.soilPhosphorus.addAll(soilPhosphorus);
    if (soilPotassium != null) result.soilPotassium.addAll(soilPotassium);
    if (soilPh != null) result.soilPh.addAll(soilPh);
    if (soilMoisture != null) result.soilMoisture.addAll(soilMoisture);
    if (soilOrganicMatter != null)
      result.soilOrganicMatter.addAll(soilOrganicMatter);
    return result;
  }

  PrescriptionZoneInput._();

  factory PrescriptionZoneInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PrescriptionZoneInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrescriptionZoneInput',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..p<$core.double>(1, _omitFieldNames ? '' : 'ndvi', $pb.PbFieldType.KD)
    ..p<$core.double>(
        2, _omitFieldNames ? '' : 'soilNitrogen', $pb.PbFieldType.KD)
    ..p<$core.double>(
        3, _omitFieldNames ? '' : 'soilPhosphorus', $pb.PbFieldType.KD)
    ..p<$core.double>(
        4, _omitFieldNames ? '' : 'soilPotassium', $pb.PbFieldType.KD)
    ..p<$core.double>(5, _omitFieldNames ? '' : 'soilPh', $pb.PbFieldType.KD)
    ..p<$core.double>(
        6, _omitFieldNames ? '' : 'soilMoisture', $pb.PbFieldType.KD)
    ..p<$core.double>(
        7, _omitFieldNames ? '' : 'soilOrganicMatter', $pb.PbFieldType.KD)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrescriptionZoneInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrescriptionZoneInput copyWith(
          void Function(PrescriptionZoneInput) updates) =>
      super.copyWith((message) => updates(message as PrescriptionZoneInput))
          as PrescriptionZoneInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PrescriptionZoneInput create() => PrescriptionZoneInput._();
  @$core.override
  PrescriptionZoneInput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PrescriptionZoneInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PrescriptionZoneInput>(create);
  static PrescriptionZoneInput? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.double> get ndvi => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<$core.double> get soilNitrogen => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$core.double> get soilPhosphorus => $_getList(2);

  @$pb.TagNumber(4)
  $pb.PbList<$core.double> get soilPotassium => $_getList(3);

  @$pb.TagNumber(5)
  $pb.PbList<$core.double> get soilPh => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<$core.double> get soilMoisture => $_getList(5);

  @$pb.TagNumber(7)
  $pb.PbList<$core.double> get soilOrganicMatter => $_getList(6);
}

class PrescriptionCropRequirements extends $pb.GeneratedMessage {
  factory PrescriptionCropRequirements({
    $core.String? cropType,
    $core.double? targetYieldKgHa,
    $core.double? nitrogenKgHa,
    $core.double? phosphorusKgHa,
    $core.double? potassiumKgHa,
    $core.double? optimalPhLow,
    $core.double? optimalPhHigh,
    $core.double? waterRequirementMm,
    $core.double? seedRatePerHa,
  }) {
    final result = create();
    if (cropType != null) result.cropType = cropType;
    if (targetYieldKgHa != null) result.targetYieldKgHa = targetYieldKgHa;
    if (nitrogenKgHa != null) result.nitrogenKgHa = nitrogenKgHa;
    if (phosphorusKgHa != null) result.phosphorusKgHa = phosphorusKgHa;
    if (potassiumKgHa != null) result.potassiumKgHa = potassiumKgHa;
    if (optimalPhLow != null) result.optimalPhLow = optimalPhLow;
    if (optimalPhHigh != null) result.optimalPhHigh = optimalPhHigh;
    if (waterRequirementMm != null)
      result.waterRequirementMm = waterRequirementMm;
    if (seedRatePerHa != null) result.seedRatePerHa = seedRatePerHa;
    return result;
  }

  PrescriptionCropRequirements._();

  factory PrescriptionCropRequirements.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PrescriptionCropRequirements.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrescriptionCropRequirements',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'cropType')
    ..aD(2, _omitFieldNames ? '' : 'targetYieldKgHa')
    ..aD(3, _omitFieldNames ? '' : 'nitrogenKgHa')
    ..aD(4, _omitFieldNames ? '' : 'phosphorusKgHa')
    ..aD(5, _omitFieldNames ? '' : 'potassiumKgHa')
    ..aD(6, _omitFieldNames ? '' : 'optimalPhLow')
    ..aD(7, _omitFieldNames ? '' : 'optimalPhHigh')
    ..aD(8, _omitFieldNames ? '' : 'waterRequirementMm')
    ..aD(9, _omitFieldNames ? '' : 'seedRatePerHa')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrescriptionCropRequirements clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrescriptionCropRequirements copyWith(
          void Function(PrescriptionCropRequirements) updates) =>
      super.copyWith(
              (message) => updates(message as PrescriptionCropRequirements))
          as PrescriptionCropRequirements;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PrescriptionCropRequirements create() =>
      PrescriptionCropRequirements._();
  @$core.override
  PrescriptionCropRequirements createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PrescriptionCropRequirements getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PrescriptionCropRequirements>(create);
  static PrescriptionCropRequirements? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get cropType => $_getSZ(0);
  @$pb.TagNumber(1)
  set cropType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCropType() => $_has(0);
  @$pb.TagNumber(1)
  void clearCropType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get targetYieldKgHa => $_getN(1);
  @$pb.TagNumber(2)
  set targetYieldKgHa($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTargetYieldKgHa() => $_has(1);
  @$pb.TagNumber(2)
  void clearTargetYieldKgHa() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get nitrogenKgHa => $_getN(2);
  @$pb.TagNumber(3)
  set nitrogenKgHa($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNitrogenKgHa() => $_has(2);
  @$pb.TagNumber(3)
  void clearNitrogenKgHa() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get phosphorusKgHa => $_getN(3);
  @$pb.TagNumber(4)
  set phosphorusKgHa($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPhosphorusKgHa() => $_has(3);
  @$pb.TagNumber(4)
  void clearPhosphorusKgHa() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get potassiumKgHa => $_getN(4);
  @$pb.TagNumber(5)
  set potassiumKgHa($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPotassiumKgHa() => $_has(4);
  @$pb.TagNumber(5)
  void clearPotassiumKgHa() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get optimalPhLow => $_getN(5);
  @$pb.TagNumber(6)
  set optimalPhLow($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOptimalPhLow() => $_has(5);
  @$pb.TagNumber(6)
  void clearOptimalPhLow() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get optimalPhHigh => $_getN(6);
  @$pb.TagNumber(7)
  set optimalPhHigh($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOptimalPhHigh() => $_has(6);
  @$pb.TagNumber(7)
  void clearOptimalPhHigh() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get waterRequirementMm => $_getN(7);
  @$pb.TagNumber(8)
  set waterRequirementMm($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWaterRequirementMm() => $_has(7);
  @$pb.TagNumber(8)
  void clearWaterRequirementMm() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get seedRatePerHa => $_getN(8);
  @$pb.TagNumber(9)
  set seedRatePerHa($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSeedRatePerHa() => $_has(8);
  @$pb.TagNumber(9)
  void clearSeedRatePerHa() => $_clearField(9);
}

class GeneratePrescriptionResponse extends $pb.GeneratedMessage {
  factory GeneratePrescriptionResponse({
    $core.String? requestId,
    $core.String? fieldId,
    $core.Iterable<PrescriptionMapResult>? prescriptions,
    $core.double? estimatedCostSavingsPct,
    $core.double? estimatedYieldGainPct,
    $fixnum.Int64? processingTimeMs,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (fieldId != null) result.fieldId = fieldId;
    if (prescriptions != null) result.prescriptions.addAll(prescriptions);
    if (estimatedCostSavingsPct != null)
      result.estimatedCostSavingsPct = estimatedCostSavingsPct;
    if (estimatedYieldGainPct != null)
      result.estimatedYieldGainPct = estimatedYieldGainPct;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    return result;
  }

  GeneratePrescriptionResponse._();

  factory GeneratePrescriptionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GeneratePrescriptionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GeneratePrescriptionResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOS(2, _omitFieldNames ? '' : 'fieldId')
    ..pPM<PrescriptionMapResult>(3, _omitFieldNames ? '' : 'prescriptions',
        subBuilder: PrescriptionMapResult.create)
    ..aD(4, _omitFieldNames ? '' : 'estimatedCostSavingsPct')
    ..aD(5, _omitFieldNames ? '' : 'estimatedYieldGainPct')
    ..aInt64(6, _omitFieldNames ? '' : 'processingTimeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeneratePrescriptionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GeneratePrescriptionResponse copyWith(
          void Function(GeneratePrescriptionResponse) updates) =>
      super.copyWith(
              (message) => updates(message as GeneratePrescriptionResponse))
          as GeneratePrescriptionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GeneratePrescriptionResponse create() =>
      GeneratePrescriptionResponse._();
  @$core.override
  GeneratePrescriptionResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GeneratePrescriptionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GeneratePrescriptionResponse>(create);
  static GeneratePrescriptionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFieldId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFieldId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<PrescriptionMapResult> get prescriptions => $_getList(2);

  @$pb.TagNumber(4)
  $core.double get estimatedCostSavingsPct => $_getN(3);
  @$pb.TagNumber(4)
  set estimatedCostSavingsPct($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEstimatedCostSavingsPct() => $_has(3);
  @$pb.TagNumber(4)
  void clearEstimatedCostSavingsPct() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get estimatedYieldGainPct => $_getN(4);
  @$pb.TagNumber(5)
  set estimatedYieldGainPct($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEstimatedYieldGainPct() => $_has(4);
  @$pb.TagNumber(5)
  void clearEstimatedYieldGainPct() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get processingTimeMs => $_getI64(5);
  @$pb.TagNumber(6)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProcessingTimeMs() => $_has(5);
  @$pb.TagNumber(6)
  void clearProcessingTimeMs() => $_clearField(6);
}

class PrescriptionMapResult extends $pb.GeneratedMessage {
  factory PrescriptionMapResult({
    $core.String? prescriptionType,
    $core.Iterable<$core.double>? rates,
    $core.String? unit,
    $core.double? totalAmount,
    $core.Iterable<PrescriptionZoneSummary>? zoneSummaries,
  }) {
    final result = create();
    if (prescriptionType != null) result.prescriptionType = prescriptionType;
    if (rates != null) result.rates.addAll(rates);
    if (unit != null) result.unit = unit;
    if (totalAmount != null) result.totalAmount = totalAmount;
    if (zoneSummaries != null) result.zoneSummaries.addAll(zoneSummaries);
    return result;
  }

  PrescriptionMapResult._();

  factory PrescriptionMapResult.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PrescriptionMapResult.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrescriptionMapResult',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'prescriptionType')
    ..p<$core.double>(2, _omitFieldNames ? '' : 'rates', $pb.PbFieldType.KD)
    ..aOS(3, _omitFieldNames ? '' : 'unit')
    ..aD(4, _omitFieldNames ? '' : 'totalAmount')
    ..pPM<PrescriptionZoneSummary>(5, _omitFieldNames ? '' : 'zoneSummaries',
        subBuilder: PrescriptionZoneSummary.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrescriptionMapResult clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrescriptionMapResult copyWith(
          void Function(PrescriptionMapResult) updates) =>
      super.copyWith((message) => updates(message as PrescriptionMapResult))
          as PrescriptionMapResult;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PrescriptionMapResult create() => PrescriptionMapResult._();
  @$core.override
  PrescriptionMapResult createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PrescriptionMapResult getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PrescriptionMapResult>(create);
  static PrescriptionMapResult? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get prescriptionType => $_getSZ(0);
  @$pb.TagNumber(1)
  set prescriptionType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrescriptionType() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrescriptionType() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.double> get rates => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get unit => $_getSZ(2);
  @$pb.TagNumber(3)
  set unit($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUnit() => $_has(2);
  @$pb.TagNumber(3)
  void clearUnit() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get totalAmount => $_getN(3);
  @$pb.TagNumber(4)
  set totalAmount($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalAmount() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<PrescriptionZoneSummary> get zoneSummaries => $_getList(4);
}

class PrescriptionZoneSummary extends $pb.GeneratedMessage {
  factory PrescriptionZoneSummary({
    $core.String? zone,
    $core.int? cellCount,
    $core.double? areaHa,
    $core.double? meanRate,
    $core.double? minRate,
    $core.double? maxRate,
    $core.double? totalAmount,
    AttributionSummary? attribution,
  }) {
    final result = create();
    if (zone != null) result.zone = zone;
    if (cellCount != null) result.cellCount = cellCount;
    if (areaHa != null) result.areaHa = areaHa;
    if (meanRate != null) result.meanRate = meanRate;
    if (minRate != null) result.minRate = minRate;
    if (maxRate != null) result.maxRate = maxRate;
    if (totalAmount != null) result.totalAmount = totalAmount;
    if (attribution != null) result.attribution = attribution;
    return result;
  }

  PrescriptionZoneSummary._();

  factory PrescriptionZoneSummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PrescriptionZoneSummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PrescriptionZoneSummary',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'zone')
    ..aI(2, _omitFieldNames ? '' : 'cellCount')
    ..aD(3, _omitFieldNames ? '' : 'areaHa')
    ..aD(4, _omitFieldNames ? '' : 'meanRate')
    ..aD(5, _omitFieldNames ? '' : 'minRate')
    ..aD(6, _omitFieldNames ? '' : 'maxRate')
    ..aD(7, _omitFieldNames ? '' : 'totalAmount')
    ..aOM<AttributionSummary>(8, _omitFieldNames ? '' : 'attribution',
        subBuilder: AttributionSummary.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrescriptionZoneSummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrescriptionZoneSummary copyWith(
          void Function(PrescriptionZoneSummary) updates) =>
      super.copyWith((message) => updates(message as PrescriptionZoneSummary))
          as PrescriptionZoneSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PrescriptionZoneSummary create() => PrescriptionZoneSummary._();
  @$core.override
  PrescriptionZoneSummary createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static PrescriptionZoneSummary getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PrescriptionZoneSummary>(create);
  static PrescriptionZoneSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get zone => $_getSZ(0);
  @$pb.TagNumber(1)
  set zone($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasZone() => $_has(0);
  @$pb.TagNumber(1)
  void clearZone() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get cellCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set cellCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCellCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCellCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get areaHa => $_getN(2);
  @$pb.TagNumber(3)
  set areaHa($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAreaHa() => $_has(2);
  @$pb.TagNumber(3)
  void clearAreaHa() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get meanRate => $_getN(3);
  @$pb.TagNumber(4)
  set meanRate($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMeanRate() => $_has(3);
  @$pb.TagNumber(4)
  void clearMeanRate() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get minRate => $_getN(4);
  @$pb.TagNumber(5)
  set minRate($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMinRate() => $_has(4);
  @$pb.TagNumber(5)
  void clearMinRate() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get maxRate => $_getN(5);
  @$pb.TagNumber(6)
  set maxRate($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxRate() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxRate() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get totalAmount => $_getN(6);
  @$pb.TagNumber(7)
  set totalAmount($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTotalAmount() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalAmount() => $_clearField(7);

  /// Why this zone gets this rate rather than the field average, split across
  /// the measured inputs. Computed for the cell whose rate is most typical of
  /// the zone, against the field's own cells as the reference.
  @$pb.TagNumber(8)
  AttributionSummary get attribution => $_getN(7);
  @$pb.TagNumber(8)
  set attribution(AttributionSummary value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasAttribution() => $_has(7);
  @$pb.TagNumber(8)
  void clearAttribution() => $_clearField(8);
  @$pb.TagNumber(8)
  AttributionSummary ensureAttribution() => $_ensure(7);
}

class AnalyzeTerrainRequest extends $pb.GeneratedMessage {
  factory AnalyzeTerrainRequest({
    $core.String? requestId,
    $core.Iterable<$core.double>? elevation,
    $core.int? width,
    $core.int? height,
    $core.double? cellSize,
    $core.double? nodataValue,
    $core.Iterable<$core.String>? analyses,
    $core.double? contourInterval,
    $core.double? streamThreshold,
    $core.double? hillshadeAzimuth,
    $core.double? hillshadeAltitude,
    $core.double? hillshadeZFactor,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (elevation != null) result.elevation.addAll(elevation);
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (cellSize != null) result.cellSize = cellSize;
    if (nodataValue != null) result.nodataValue = nodataValue;
    if (analyses != null) result.analyses.addAll(analyses);
    if (contourInterval != null) result.contourInterval = contourInterval;
    if (streamThreshold != null) result.streamThreshold = streamThreshold;
    if (hillshadeAzimuth != null) result.hillshadeAzimuth = hillshadeAzimuth;
    if (hillshadeAltitude != null) result.hillshadeAltitude = hillshadeAltitude;
    if (hillshadeZFactor != null) result.hillshadeZFactor = hillshadeZFactor;
    return result;
  }

  AnalyzeTerrainRequest._();

  factory AnalyzeTerrainRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AnalyzeTerrainRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnalyzeTerrainRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..p<$core.double>(2, _omitFieldNames ? '' : 'elevation', $pb.PbFieldType.KD)
    ..aI(3, _omitFieldNames ? '' : 'width')
    ..aI(4, _omitFieldNames ? '' : 'height')
    ..aD(5, _omitFieldNames ? '' : 'cellSize')
    ..aD(6, _omitFieldNames ? '' : 'nodataValue')
    ..pPS(7, _omitFieldNames ? '' : 'analyses')
    ..aD(8, _omitFieldNames ? '' : 'contourInterval')
    ..aD(9, _omitFieldNames ? '' : 'streamThreshold')
    ..aD(10, _omitFieldNames ? '' : 'hillshadeAzimuth')
    ..aD(11, _omitFieldNames ? '' : 'hillshadeAltitude')
    ..aD(12, _omitFieldNames ? '' : 'hillshadeZFactor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzeTerrainRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzeTerrainRequest copyWith(
          void Function(AnalyzeTerrainRequest) updates) =>
      super.copyWith((message) => updates(message as AnalyzeTerrainRequest))
          as AnalyzeTerrainRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyzeTerrainRequest create() => AnalyzeTerrainRequest._();
  @$core.override
  AnalyzeTerrainRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AnalyzeTerrainRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnalyzeTerrainRequest>(create);
  static AnalyzeTerrainRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  /// DEM elevation data as a flat row-major array.
  @$pb.TagNumber(2)
  $pb.PbList<$core.double> get elevation => $_getList(1);

  @$pb.TagNumber(3)
  $core.int get width => $_getIZ(2);
  @$pb.TagNumber(3)
  set width($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWidth() => $_has(2);
  @$pb.TagNumber(3)
  void clearWidth() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(3);
  @$pb.TagNumber(4)
  set height($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeight() => $_clearField(4);

  /// Cell size in meters (square cells).
  @$pb.TagNumber(5)
  $core.double get cellSize => $_getN(4);
  @$pb.TagNumber(5)
  set cellSize($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCellSize() => $_has(4);
  @$pb.TagNumber(5)
  void clearCellSize() => $_clearField(5);

  /// Nodata value (default -9999).
  @$pb.TagNumber(6)
  $core.double get nodataValue => $_getN(5);
  @$pb.TagNumber(6)
  set nodataValue($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNodataValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearNodataValue() => $_clearField(6);

  /// Which analyses to run: SLOPE, ASPECT, CONTOUR, FLOW_DIRECTION,
  /// FLOW_ACCUMULATION, WATERSHED, HILLSHADE, TRI, TPI, FULL.
  @$pb.TagNumber(7)
  $pb.PbList<$core.String> get analyses => $_getList(6);

  /// Contour interval in meters (used when CONTOUR or FULL is requested).
  @$pb.TagNumber(8)
  $core.double get contourInterval => $_getN(7);
  @$pb.TagNumber(8)
  set contourInterval($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasContourInterval() => $_has(7);
  @$pb.TagNumber(8)
  void clearContourInterval() => $_clearField(8);

  /// Stream threshold for flow accumulation (used when FLOW_ACCUMULATION or FULL).
  @$pb.TagNumber(9)
  $core.double get streamThreshold => $_getN(8);
  @$pb.TagNumber(9)
  set streamThreshold($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasStreamThreshold() => $_has(8);
  @$pb.TagNumber(9)
  void clearStreamThreshold() => $_clearField(9);

  /// Hillshade parameters (defaults: azimuth 315, altitude 45, z_factor 1).
  @$pb.TagNumber(10)
  $core.double get hillshadeAzimuth => $_getN(9);
  @$pb.TagNumber(10)
  set hillshadeAzimuth($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasHillshadeAzimuth() => $_has(9);
  @$pb.TagNumber(10)
  void clearHillshadeAzimuth() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get hillshadeAltitude => $_getN(10);
  @$pb.TagNumber(11)
  set hillshadeAltitude($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasHillshadeAltitude() => $_has(10);
  @$pb.TagNumber(11)
  void clearHillshadeAltitude() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get hillshadeZFactor => $_getN(11);
  @$pb.TagNumber(12)
  set hillshadeZFactor($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasHillshadeZFactor() => $_has(11);
  @$pb.TagNumber(12)
  void clearHillshadeZFactor() => $_clearField(12);
}

class AnalyzeTerrainResponse extends $pb.GeneratedMessage {
  factory AnalyzeTerrainResponse({
    $core.String? requestId,
    $core.int? width,
    $core.int? height,
    $core.Iterable<$core.double>? slope,
    $core.Iterable<$core.double>? aspect,
    $core.Iterable<$core.double>? hillshade,
    $core.Iterable<$core.double>? tri,
    $core.Iterable<$core.double>? tpi,
    $core.Iterable<$core.int>? flowDirection,
    $core.Iterable<$core.double>? flowAccumulation,
    $core.Iterable<$core.int>? watershedIds,
    $core.Iterable<TerrainContourLine>? contourLines,
    TerrainDemStatistics? demStatistics,
    TerrainFlowStats? flowStatistics,
    $core.Iterable<TerrainWatershedInfo>? watershedStatistics,
    $fixnum.Int64? processingTimeMs,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    if (slope != null) result.slope.addAll(slope);
    if (aspect != null) result.aspect.addAll(aspect);
    if (hillshade != null) result.hillshade.addAll(hillshade);
    if (tri != null) result.tri.addAll(tri);
    if (tpi != null) result.tpi.addAll(tpi);
    if (flowDirection != null) result.flowDirection.addAll(flowDirection);
    if (flowAccumulation != null)
      result.flowAccumulation.addAll(flowAccumulation);
    if (watershedIds != null) result.watershedIds.addAll(watershedIds);
    if (contourLines != null) result.contourLines.addAll(contourLines);
    if (demStatistics != null) result.demStatistics = demStatistics;
    if (flowStatistics != null) result.flowStatistics = flowStatistics;
    if (watershedStatistics != null)
      result.watershedStatistics.addAll(watershedStatistics);
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    return result;
  }

  AnalyzeTerrainResponse._();

  factory AnalyzeTerrainResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AnalyzeTerrainResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AnalyzeTerrainResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aI(2, _omitFieldNames ? '' : 'width')
    ..aI(3, _omitFieldNames ? '' : 'height')
    ..p<$core.double>(4, _omitFieldNames ? '' : 'slope', $pb.PbFieldType.KD)
    ..p<$core.double>(5, _omitFieldNames ? '' : 'aspect', $pb.PbFieldType.KD)
    ..p<$core.double>(6, _omitFieldNames ? '' : 'hillshade', $pb.PbFieldType.KD)
    ..p<$core.double>(7, _omitFieldNames ? '' : 'tri', $pb.PbFieldType.KD)
    ..p<$core.double>(8, _omitFieldNames ? '' : 'tpi', $pb.PbFieldType.KD)
    ..p<$core.int>(
        9, _omitFieldNames ? '' : 'flowDirection', $pb.PbFieldType.K3)
    ..p<$core.double>(
        10, _omitFieldNames ? '' : 'flowAccumulation', $pb.PbFieldType.KD)
    ..p<$core.int>(
        11, _omitFieldNames ? '' : 'watershedIds', $pb.PbFieldType.KU3)
    ..pPM<TerrainContourLine>(12, _omitFieldNames ? '' : 'contourLines',
        subBuilder: TerrainContourLine.create)
    ..aOM<TerrainDemStatistics>(13, _omitFieldNames ? '' : 'demStatistics',
        subBuilder: TerrainDemStatistics.create)
    ..aOM<TerrainFlowStats>(14, _omitFieldNames ? '' : 'flowStatistics',
        subBuilder: TerrainFlowStats.create)
    ..pPM<TerrainWatershedInfo>(
        15, _omitFieldNames ? '' : 'watershedStatistics',
        subBuilder: TerrainWatershedInfo.create)
    ..aInt64(16, _omitFieldNames ? '' : 'processingTimeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzeTerrainResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AnalyzeTerrainResponse copyWith(
          void Function(AnalyzeTerrainResponse) updates) =>
      super.copyWith((message) => updates(message as AnalyzeTerrainResponse))
          as AnalyzeTerrainResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyzeTerrainResponse create() => AnalyzeTerrainResponse._();
  @$core.override
  AnalyzeTerrainResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AnalyzeTerrainResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AnalyzeTerrainResponse>(create);
  static AnalyzeTerrainResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get width => $_getIZ(1);
  @$pb.TagNumber(2)
  set width($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWidth() => $_has(1);
  @$pb.TagNumber(2)
  void clearWidth() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get height => $_getIZ(2);
  @$pb.TagNumber(3)
  set height($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => $_clearField(3);

  /// Slope in degrees (row-major flat array).
  @$pb.TagNumber(4)
  $pb.PbList<$core.double> get slope => $_getList(3);

  /// Aspect in degrees clockwise from north.
  @$pb.TagNumber(5)
  $pb.PbList<$core.double> get aspect => $_getList(4);

  /// Hillshade values (0-255).
  @$pb.TagNumber(6)
  $pb.PbList<$core.double> get hillshade => $_getList(5);

  /// Terrain Ruggedness Index.
  @$pb.TagNumber(7)
  $pb.PbList<$core.double> get tri => $_getList(6);

  /// Topographic Position Index.
  @$pb.TagNumber(8)
  $pb.PbList<$core.double> get tpi => $_getList(7);

  /// D8 flow direction (encoded as u8, cast to int32).
  @$pb.TagNumber(9)
  $pb.PbList<$core.int> get flowDirection => $_getList(8);

  /// Flow accumulation values.
  @$pb.TagNumber(10)
  $pb.PbList<$core.double> get flowAccumulation => $_getList(9);

  /// Watershed IDs per cell.
  @$pb.TagNumber(11)
  $pb.PbList<$core.int> get watershedIds => $_getList(10);

  /// Contour lines.
  @$pb.TagNumber(12)
  $pb.PbList<TerrainContourLine> get contourLines => $_getList(11);

  /// DEM statistics.
  @$pb.TagNumber(13)
  TerrainDemStatistics get demStatistics => $_getN(12);
  @$pb.TagNumber(13)
  set demStatistics(TerrainDemStatistics value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasDemStatistics() => $_has(12);
  @$pb.TagNumber(13)
  void clearDemStatistics() => $_clearField(13);
  @$pb.TagNumber(13)
  TerrainDemStatistics ensureDemStatistics() => $_ensure(12);

  /// Flow accumulation statistics.
  @$pb.TagNumber(14)
  TerrainFlowStats get flowStatistics => $_getN(13);
  @$pb.TagNumber(14)
  set flowStatistics(TerrainFlowStats value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasFlowStatistics() => $_has(13);
  @$pb.TagNumber(14)
  void clearFlowStatistics() => $_clearField(14);
  @$pb.TagNumber(14)
  TerrainFlowStats ensureFlowStatistics() => $_ensure(13);

  /// Per-watershed statistics.
  @$pb.TagNumber(15)
  $pb.PbList<TerrainWatershedInfo> get watershedStatistics => $_getList(14);

  @$pb.TagNumber(16)
  $fixnum.Int64 get processingTimeMs => $_getI64(15);
  @$pb.TagNumber(16)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(15, value);
  @$pb.TagNumber(16)
  $core.bool hasProcessingTimeMs() => $_has(15);
  @$pb.TagNumber(16)
  void clearProcessingTimeMs() => $_clearField(16);
}

class TerrainContourLine extends $pb.GeneratedMessage {
  factory TerrainContourLine({
    $core.double? elevation,
    $core.Iterable<$core.double>? coordinates,
  }) {
    final result = create();
    if (elevation != null) result.elevation = elevation;
    if (coordinates != null) result.coordinates.addAll(coordinates);
    return result;
  }

  TerrainContourLine._();

  factory TerrainContourLine.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TerrainContourLine.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TerrainContourLine',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'elevation')
    ..p<$core.double>(
        2, _omitFieldNames ? '' : 'coordinates', $pb.PbFieldType.KD)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TerrainContourLine clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TerrainContourLine copyWith(void Function(TerrainContourLine) updates) =>
      super.copyWith((message) => updates(message as TerrainContourLine))
          as TerrainContourLine;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TerrainContourLine create() => TerrainContourLine._();
  @$core.override
  TerrainContourLine createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TerrainContourLine getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TerrainContourLine>(create);
  static TerrainContourLine? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get elevation => $_getN(0);
  @$pb.TagNumber(1)
  set elevation($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasElevation() => $_has(0);
  @$pb.TagNumber(1)
  void clearElevation() => $_clearField(1);

  /// Interleaved x,y coordinates: [x0, y0, x1, y1, ...].
  @$pb.TagNumber(2)
  $pb.PbList<$core.double> get coordinates => $_getList(1);
}

class TerrainDemStatistics extends $pb.GeneratedMessage {
  factory TerrainDemStatistics({
    $core.double? minElevation,
    $core.double? maxElevation,
    $core.double? meanElevation,
    $core.double? elevationRange,
    $fixnum.Int64? validCells,
    $fixnum.Int64? totalCells,
  }) {
    final result = create();
    if (minElevation != null) result.minElevation = minElevation;
    if (maxElevation != null) result.maxElevation = maxElevation;
    if (meanElevation != null) result.meanElevation = meanElevation;
    if (elevationRange != null) result.elevationRange = elevationRange;
    if (validCells != null) result.validCells = validCells;
    if (totalCells != null) result.totalCells = totalCells;
    return result;
  }

  TerrainDemStatistics._();

  factory TerrainDemStatistics.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TerrainDemStatistics.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TerrainDemStatistics',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'minElevation')
    ..aD(2, _omitFieldNames ? '' : 'maxElevation')
    ..aD(3, _omitFieldNames ? '' : 'meanElevation')
    ..aD(4, _omitFieldNames ? '' : 'elevationRange')
    ..aInt64(5, _omitFieldNames ? '' : 'validCells')
    ..aInt64(6, _omitFieldNames ? '' : 'totalCells')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TerrainDemStatistics clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TerrainDemStatistics copyWith(void Function(TerrainDemStatistics) updates) =>
      super.copyWith((message) => updates(message as TerrainDemStatistics))
          as TerrainDemStatistics;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TerrainDemStatistics create() => TerrainDemStatistics._();
  @$core.override
  TerrainDemStatistics createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TerrainDemStatistics getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TerrainDemStatistics>(create);
  static TerrainDemStatistics? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get minElevation => $_getN(0);
  @$pb.TagNumber(1)
  set minElevation($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMinElevation() => $_has(0);
  @$pb.TagNumber(1)
  void clearMinElevation() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get maxElevation => $_getN(1);
  @$pb.TagNumber(2)
  set maxElevation($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxElevation() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxElevation() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get meanElevation => $_getN(2);
  @$pb.TagNumber(3)
  set meanElevation($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMeanElevation() => $_has(2);
  @$pb.TagNumber(3)
  void clearMeanElevation() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get elevationRange => $_getN(3);
  @$pb.TagNumber(4)
  set elevationRange($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasElevationRange() => $_has(3);
  @$pb.TagNumber(4)
  void clearElevationRange() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get validCells => $_getI64(4);
  @$pb.TagNumber(5)
  set validCells($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasValidCells() => $_has(4);
  @$pb.TagNumber(5)
  void clearValidCells() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get totalCells => $_getI64(5);
  @$pb.TagNumber(6)
  set totalCells($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalCells() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalCells() => $_clearField(6);
}

class TerrainFlowStats extends $pb.GeneratedMessage {
  factory TerrainFlowStats({
    $core.double? maxAccumulation,
    $core.double? meanAccumulation,
    $fixnum.Int64? streamCellCount,
    $fixnum.Int64? totalCells,
    $core.double? drainageDensity,
  }) {
    final result = create();
    if (maxAccumulation != null) result.maxAccumulation = maxAccumulation;
    if (meanAccumulation != null) result.meanAccumulation = meanAccumulation;
    if (streamCellCount != null) result.streamCellCount = streamCellCount;
    if (totalCells != null) result.totalCells = totalCells;
    if (drainageDensity != null) result.drainageDensity = drainageDensity;
    return result;
  }

  TerrainFlowStats._();

  factory TerrainFlowStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TerrainFlowStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TerrainFlowStats',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'maxAccumulation')
    ..aD(2, _omitFieldNames ? '' : 'meanAccumulation')
    ..aInt64(3, _omitFieldNames ? '' : 'streamCellCount')
    ..aInt64(4, _omitFieldNames ? '' : 'totalCells')
    ..aD(5, _omitFieldNames ? '' : 'drainageDensity')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TerrainFlowStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TerrainFlowStats copyWith(void Function(TerrainFlowStats) updates) =>
      super.copyWith((message) => updates(message as TerrainFlowStats))
          as TerrainFlowStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TerrainFlowStats create() => TerrainFlowStats._();
  @$core.override
  TerrainFlowStats createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TerrainFlowStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TerrainFlowStats>(create);
  static TerrainFlowStats? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get maxAccumulation => $_getN(0);
  @$pb.TagNumber(1)
  set maxAccumulation($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMaxAccumulation() => $_has(0);
  @$pb.TagNumber(1)
  void clearMaxAccumulation() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get meanAccumulation => $_getN(1);
  @$pb.TagNumber(2)
  set meanAccumulation($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMeanAccumulation() => $_has(1);
  @$pb.TagNumber(2)
  void clearMeanAccumulation() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get streamCellCount => $_getI64(2);
  @$pb.TagNumber(3)
  set streamCellCount($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStreamCellCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearStreamCellCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get totalCells => $_getI64(3);
  @$pb.TagNumber(4)
  set totalCells($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalCells() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalCells() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get drainageDensity => $_getN(4);
  @$pb.TagNumber(5)
  set drainageDensity($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDrainageDensity() => $_has(4);
  @$pb.TagNumber(5)
  void clearDrainageDensity() => $_clearField(5);
}

class TerrainWatershedInfo extends $pb.GeneratedMessage {
  factory TerrainWatershedInfo({
    $core.int? id,
    $fixnum.Int64? cellCount,
    $core.double? areaSqM,
    $core.double? meanElevation,
    $core.double? minElevation,
    $core.double? maxElevation,
    $core.double? relief,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (cellCount != null) result.cellCount = cellCount;
    if (areaSqM != null) result.areaSqM = areaSqM;
    if (meanElevation != null) result.meanElevation = meanElevation;
    if (minElevation != null) result.minElevation = minElevation;
    if (maxElevation != null) result.maxElevation = maxElevation;
    if (relief != null) result.relief = relief;
    return result;
  }

  TerrainWatershedInfo._();

  factory TerrainWatershedInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TerrainWatershedInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TerrainWatershedInfo',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id', fieldType: $pb.PbFieldType.OU3)
    ..aInt64(2, _omitFieldNames ? '' : 'cellCount')
    ..aD(3, _omitFieldNames ? '' : 'areaSqM')
    ..aD(4, _omitFieldNames ? '' : 'meanElevation')
    ..aD(5, _omitFieldNames ? '' : 'minElevation')
    ..aD(6, _omitFieldNames ? '' : 'maxElevation')
    ..aD(7, _omitFieldNames ? '' : 'relief')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TerrainWatershedInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TerrainWatershedInfo copyWith(void Function(TerrainWatershedInfo) updates) =>
      super.copyWith((message) => updates(message as TerrainWatershedInfo))
          as TerrainWatershedInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TerrainWatershedInfo create() => TerrainWatershedInfo._();
  @$core.override
  TerrainWatershedInfo createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TerrainWatershedInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TerrainWatershedInfo>(create);
  static TerrainWatershedInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get cellCount => $_getI64(1);
  @$pb.TagNumber(2)
  set cellCount($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCellCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCellCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get areaSqM => $_getN(2);
  @$pb.TagNumber(3)
  set areaSqM($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAreaSqM() => $_has(2);
  @$pb.TagNumber(3)
  void clearAreaSqM() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get meanElevation => $_getN(3);
  @$pb.TagNumber(4)
  set meanElevation($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMeanElevation() => $_has(3);
  @$pb.TagNumber(4)
  void clearMeanElevation() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get minElevation => $_getN(4);
  @$pb.TagNumber(5)
  set minElevation($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMinElevation() => $_has(4);
  @$pb.TagNumber(5)
  void clearMinElevation() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get maxElevation => $_getN(5);
  @$pb.TagNumber(6)
  set maxElevation($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxElevation() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxElevation() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get relief => $_getN(6);
  @$pb.TagNumber(7)
  set relief($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRelief() => $_has(6);
  @$pb.TagNumber(7)
  void clearRelief() => $_clearField(7);
}

class SimulateWaterFlowRequest extends $pb.GeneratedMessage {
  factory SimulateWaterFlowRequest({
    $core.String? requestId,
    WaterFlowMoistureParams? moistureParams,
    WaterFlowBalanceParams? balanceParams,
    $core.double? rainfallMmDay,
    $core.double? etMmDay,
    $core.double? irrigationMmDay,
    $core.double? simulationDays,
    $core.Iterable<$core.double>? dailyRainfallMm,
    $core.double? initialDepletionMm,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (moistureParams != null) result.moistureParams = moistureParams;
    if (balanceParams != null) result.balanceParams = balanceParams;
    if (rainfallMmDay != null) result.rainfallMmDay = rainfallMmDay;
    if (etMmDay != null) result.etMmDay = etMmDay;
    if (irrigationMmDay != null) result.irrigationMmDay = irrigationMmDay;
    if (simulationDays != null) result.simulationDays = simulationDays;
    if (dailyRainfallMm != null) result.dailyRainfallMm.addAll(dailyRainfallMm);
    if (initialDepletionMm != null)
      result.initialDepletionMm = initialDepletionMm;
    return result;
  }

  SimulateWaterFlowRequest._();

  factory SimulateWaterFlowRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SimulateWaterFlowRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SimulateWaterFlowRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..aOM<WaterFlowMoistureParams>(2, _omitFieldNames ? '' : 'moistureParams',
        subBuilder: WaterFlowMoistureParams.create)
    ..aOM<WaterFlowBalanceParams>(3, _omitFieldNames ? '' : 'balanceParams',
        subBuilder: WaterFlowBalanceParams.create)
    ..aD(4, _omitFieldNames ? '' : 'rainfallMmDay')
    ..aD(5, _omitFieldNames ? '' : 'etMmDay')
    ..aD(6, _omitFieldNames ? '' : 'irrigationMmDay')
    ..aD(7, _omitFieldNames ? '' : 'simulationDays')
    ..p<$core.double>(
        8, _omitFieldNames ? '' : 'dailyRainfallMm', $pb.PbFieldType.KD)
    ..aD(9, _omitFieldNames ? '' : 'initialDepletionMm')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimulateWaterFlowRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimulateWaterFlowRequest copyWith(
          void Function(SimulateWaterFlowRequest) updates) =>
      super.copyWith((message) => updates(message as SimulateWaterFlowRequest))
          as SimulateWaterFlowRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SimulateWaterFlowRequest create() => SimulateWaterFlowRequest._();
  @$core.override
  SimulateWaterFlowRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SimulateWaterFlowRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SimulateWaterFlowRequest>(create);
  static SimulateWaterFlowRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  /// Soil moisture parameters.
  @$pb.TagNumber(2)
  WaterFlowMoistureParams get moistureParams => $_getN(1);
  @$pb.TagNumber(2)
  set moistureParams(WaterFlowMoistureParams value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasMoistureParams() => $_has(1);
  @$pb.TagNumber(2)
  void clearMoistureParams() => $_clearField(2);
  @$pb.TagNumber(2)
  WaterFlowMoistureParams ensureMoistureParams() => $_ensure(1);

  /// Water balance parameters.
  @$pb.TagNumber(3)
  WaterFlowBalanceParams get balanceParams => $_getN(2);
  @$pb.TagNumber(3)
  set balanceParams(WaterFlowBalanceParams value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBalanceParams() => $_has(2);
  @$pb.TagNumber(3)
  void clearBalanceParams() => $_clearField(3);
  @$pb.TagNumber(3)
  WaterFlowBalanceParams ensureBalanceParams() => $_ensure(2);

  /// Simulation inputs.
  @$pb.TagNumber(4)
  $core.double get rainfallMmDay => $_getN(3);
  @$pb.TagNumber(4)
  set rainfallMmDay($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRainfallMmDay() => $_has(3);
  @$pb.TagNumber(4)
  void clearRainfallMmDay() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get etMmDay => $_getN(4);
  @$pb.TagNumber(5)
  set etMmDay($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEtMmDay() => $_has(4);
  @$pb.TagNumber(5)
  void clearEtMmDay() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get irrigationMmDay => $_getN(5);
  @$pb.TagNumber(6)
  set irrigationMmDay($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIrrigationMmDay() => $_has(5);
  @$pb.TagNumber(6)
  void clearIrrigationMmDay() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get simulationDays => $_getN(6);
  @$pb.TagNumber(7)
  set simulationDays($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSimulationDays() => $_has(6);
  @$pb.TagNumber(7)
  void clearSimulationDays() => $_clearField(7);

  /// Daily rainfall series (used for water balance computation; overrides
  /// rainfall_mm_day when non-empty).
  @$pb.TagNumber(8)
  $pb.PbList<$core.double> get dailyRainfallMm => $_getList(7);

  /// Soil water depletion from field capacity at day 0 (mm). 0 = at field capacity.
  @$pb.TagNumber(9)
  $core.double get initialDepletionMm => $_getN(8);
  @$pb.TagNumber(9)
  set initialDepletionMm($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasInitialDepletionMm() => $_has(8);
  @$pb.TagNumber(9)
  void clearInitialDepletionMm() => $_clearField(9);
}

class WaterFlowMoistureParams extends $pb.GeneratedMessage {
  factory WaterFlowMoistureParams({
    $core.int? numLayers,
    $core.double? layerThicknessM,
    $core.double? kSatMDay,
    $core.double? fieldCapacity,
    $core.double? wiltingPoint,
    $core.double? saturation,
    $core.double? rootZoneDepthM,
  }) {
    final result = create();
    if (numLayers != null) result.numLayers = numLayers;
    if (layerThicknessM != null) result.layerThicknessM = layerThicknessM;
    if (kSatMDay != null) result.kSatMDay = kSatMDay;
    if (fieldCapacity != null) result.fieldCapacity = fieldCapacity;
    if (wiltingPoint != null) result.wiltingPoint = wiltingPoint;
    if (saturation != null) result.saturation = saturation;
    if (rootZoneDepthM != null) result.rootZoneDepthM = rootZoneDepthM;
    return result;
  }

  WaterFlowMoistureParams._();

  factory WaterFlowMoistureParams.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WaterFlowMoistureParams.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WaterFlowMoistureParams',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'numLayers')
    ..aD(2, _omitFieldNames ? '' : 'layerThicknessM')
    ..aD(3, _omitFieldNames ? '' : 'kSatMDay')
    ..aD(4, _omitFieldNames ? '' : 'fieldCapacity')
    ..aD(5, _omitFieldNames ? '' : 'wiltingPoint')
    ..aD(6, _omitFieldNames ? '' : 'saturation')
    ..aD(7, _omitFieldNames ? '' : 'rootZoneDepthM')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WaterFlowMoistureParams clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WaterFlowMoistureParams copyWith(
          void Function(WaterFlowMoistureParams) updates) =>
      super.copyWith((message) => updates(message as WaterFlowMoistureParams))
          as WaterFlowMoistureParams;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WaterFlowMoistureParams create() => WaterFlowMoistureParams._();
  @$core.override
  WaterFlowMoistureParams createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WaterFlowMoistureParams getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WaterFlowMoistureParams>(create);
  static WaterFlowMoistureParams? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get numLayers => $_getIZ(0);
  @$pb.TagNumber(1)
  set numLayers($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNumLayers() => $_has(0);
  @$pb.TagNumber(1)
  void clearNumLayers() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get layerThicknessM => $_getN(1);
  @$pb.TagNumber(2)
  set layerThicknessM($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLayerThicknessM() => $_has(1);
  @$pb.TagNumber(2)
  void clearLayerThicknessM() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get kSatMDay => $_getN(2);
  @$pb.TagNumber(3)
  set kSatMDay($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasKSatMDay() => $_has(2);
  @$pb.TagNumber(3)
  void clearKSatMDay() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get fieldCapacity => $_getN(3);
  @$pb.TagNumber(4)
  set fieldCapacity($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFieldCapacity() => $_has(3);
  @$pb.TagNumber(4)
  void clearFieldCapacity() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get wiltingPoint => $_getN(4);
  @$pb.TagNumber(5)
  set wiltingPoint($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasWiltingPoint() => $_has(4);
  @$pb.TagNumber(5)
  void clearWiltingPoint() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get saturation => $_getN(5);
  @$pb.TagNumber(6)
  set saturation($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSaturation() => $_has(5);
  @$pb.TagNumber(6)
  void clearSaturation() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get rootZoneDepthM => $_getN(6);
  @$pb.TagNumber(7)
  set rootZoneDepthM($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRootZoneDepthM() => $_has(6);
  @$pb.TagNumber(7)
  void clearRootZoneDepthM() => $_clearField(7);
}

class WaterFlowBalanceParams extends $pb.GeneratedMessage {
  factory WaterFlowBalanceParams({
    $core.double? fieldAreaHa,
    $core.double? cropCoefficient,
    $core.double? referenceEtMmDay,
    $core.double? rootZoneDepthM,
    $core.double? fieldCapacity,
    $core.double? wiltingPoint,
    $core.double? managementAllowedDepletion,
    $core.String? cropType,
    $core.String? growthStage,
    $core.int? daysAfterPlanting,
  }) {
    final result = create();
    if (fieldAreaHa != null) result.fieldAreaHa = fieldAreaHa;
    if (cropCoefficient != null) result.cropCoefficient = cropCoefficient;
    if (referenceEtMmDay != null) result.referenceEtMmDay = referenceEtMmDay;
    if (rootZoneDepthM != null) result.rootZoneDepthM = rootZoneDepthM;
    if (fieldCapacity != null) result.fieldCapacity = fieldCapacity;
    if (wiltingPoint != null) result.wiltingPoint = wiltingPoint;
    if (managementAllowedDepletion != null)
      result.managementAllowedDepletion = managementAllowedDepletion;
    if (cropType != null) result.cropType = cropType;
    if (growthStage != null) result.growthStage = growthStage;
    if (daysAfterPlanting != null) result.daysAfterPlanting = daysAfterPlanting;
    return result;
  }

  WaterFlowBalanceParams._();

  factory WaterFlowBalanceParams.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WaterFlowBalanceParams.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WaterFlowBalanceParams',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'fieldAreaHa')
    ..aD(2, _omitFieldNames ? '' : 'cropCoefficient')
    ..aD(3, _omitFieldNames ? '' : 'referenceEtMmDay')
    ..aD(4, _omitFieldNames ? '' : 'rootZoneDepthM')
    ..aD(5, _omitFieldNames ? '' : 'fieldCapacity')
    ..aD(6, _omitFieldNames ? '' : 'wiltingPoint')
    ..aD(7, _omitFieldNames ? '' : 'managementAllowedDepletion')
    ..aOS(8, _omitFieldNames ? '' : 'cropType')
    ..aOS(9, _omitFieldNames ? '' : 'growthStage')
    ..aI(10, _omitFieldNames ? '' : 'daysAfterPlanting')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WaterFlowBalanceParams clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WaterFlowBalanceParams copyWith(
          void Function(WaterFlowBalanceParams) updates) =>
      super.copyWith((message) => updates(message as WaterFlowBalanceParams))
          as WaterFlowBalanceParams;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WaterFlowBalanceParams create() => WaterFlowBalanceParams._();
  @$core.override
  WaterFlowBalanceParams createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WaterFlowBalanceParams getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WaterFlowBalanceParams>(create);
  static WaterFlowBalanceParams? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get fieldAreaHa => $_getN(0);
  @$pb.TagNumber(1)
  set fieldAreaHa($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFieldAreaHa() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldAreaHa() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get cropCoefficient => $_getN(1);
  @$pb.TagNumber(2)
  set cropCoefficient($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCropCoefficient() => $_has(1);
  @$pb.TagNumber(2)
  void clearCropCoefficient() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get referenceEtMmDay => $_getN(2);
  @$pb.TagNumber(3)
  set referenceEtMmDay($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReferenceEtMmDay() => $_has(2);
  @$pb.TagNumber(3)
  void clearReferenceEtMmDay() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get rootZoneDepthM => $_getN(3);
  @$pb.TagNumber(4)
  set rootZoneDepthM($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRootZoneDepthM() => $_has(3);
  @$pb.TagNumber(4)
  void clearRootZoneDepthM() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get fieldCapacity => $_getN(4);
  @$pb.TagNumber(5)
  set fieldCapacity($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFieldCapacity() => $_has(4);
  @$pb.TagNumber(5)
  void clearFieldCapacity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get wiltingPoint => $_getN(5);
  @$pb.TagNumber(6)
  set wiltingPoint($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasWiltingPoint() => $_has(5);
  @$pb.TagNumber(6)
  void clearWiltingPoint() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get managementAllowedDepletion => $_getN(6);
  @$pb.TagNumber(7)
  set managementAllowedDepletion($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasManagementAllowedDepletion() => $_has(6);
  @$pb.TagNumber(7)
  void clearManagementAllowedDepletion() => $_clearField(7);

  /// When crop_coefficient is 0, Kc is looked up from FAO-56 tables for this
  /// crop at the given growth stage or days after planting.
  @$pb.TagNumber(8)
  $core.String get cropType => $_getSZ(7);
  @$pb.TagNumber(8)
  set cropType($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCropType() => $_has(7);
  @$pb.TagNumber(8)
  void clearCropType() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get growthStage => $_getSZ(8);
  @$pb.TagNumber(9)
  set growthStage($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasGrowthStage() => $_has(8);
  @$pb.TagNumber(9)
  void clearGrowthStage() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get daysAfterPlanting => $_getIZ(9);
  @$pb.TagNumber(10)
  set daysAfterPlanting($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDaysAfterPlanting() => $_has(9);
  @$pb.TagNumber(10)
  void clearDaysAfterPlanting() => $_clearField(10);
}

class SimulateWaterFlowResponse extends $pb.GeneratedMessage {
  factory SimulateWaterFlowResponse({
    $core.String? requestId,
    $core.Iterable<SoilMoistureSnapshot>? moistureProfiles,
    $core.Iterable<WaterBalanceDay>? waterBalance,
    WaterFlowIrrigationSummary? irrigationSummary,
    $fixnum.Int64? processingTimeMs,
  }) {
    final result = create();
    if (requestId != null) result.requestId = requestId;
    if (moistureProfiles != null)
      result.moistureProfiles.addAll(moistureProfiles);
    if (waterBalance != null) result.waterBalance.addAll(waterBalance);
    if (irrigationSummary != null) result.irrigationSummary = irrigationSummary;
    if (processingTimeMs != null) result.processingTimeMs = processingTimeMs;
    return result;
  }

  SimulateWaterFlowResponse._();

  factory SimulateWaterFlowResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SimulateWaterFlowResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SimulateWaterFlowResponse',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'requestId')
    ..pPM<SoilMoistureSnapshot>(2, _omitFieldNames ? '' : 'moistureProfiles',
        subBuilder: SoilMoistureSnapshot.create)
    ..pPM<WaterBalanceDay>(3, _omitFieldNames ? '' : 'waterBalance',
        subBuilder: WaterBalanceDay.create)
    ..aOM<WaterFlowIrrigationSummary>(
        4, _omitFieldNames ? '' : 'irrigationSummary',
        subBuilder: WaterFlowIrrigationSummary.create)
    ..aInt64(5, _omitFieldNames ? '' : 'processingTimeMs')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimulateWaterFlowResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SimulateWaterFlowResponse copyWith(
          void Function(SimulateWaterFlowResponse) updates) =>
      super.copyWith((message) => updates(message as SimulateWaterFlowResponse))
          as SimulateWaterFlowResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SimulateWaterFlowResponse create() => SimulateWaterFlowResponse._();
  @$core.override
  SimulateWaterFlowResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SimulateWaterFlowResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SimulateWaterFlowResponse>(create);
  static SimulateWaterFlowResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get requestId => $_getSZ(0);
  @$pb.TagNumber(1)
  set requestId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRequestId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequestId() => $_clearField(1);

  /// Soil moisture profiles over time.
  @$pb.TagNumber(2)
  $pb.PbList<SoilMoistureSnapshot> get moistureProfiles => $_getList(1);

  /// Daily water balance results.
  @$pb.TagNumber(3)
  $pb.PbList<WaterBalanceDay> get waterBalance => $_getList(2);

  /// Irrigation schedule summary.
  @$pb.TagNumber(4)
  WaterFlowIrrigationSummary get irrigationSummary => $_getN(3);
  @$pb.TagNumber(4)
  set irrigationSummary(WaterFlowIrrigationSummary value) =>
      $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasIrrigationSummary() => $_has(3);
  @$pb.TagNumber(4)
  void clearIrrigationSummary() => $_clearField(4);
  @$pb.TagNumber(4)
  WaterFlowIrrigationSummary ensureIrrigationSummary() => $_ensure(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get processingTimeMs => $_getI64(4);
  @$pb.TagNumber(5)
  set processingTimeMs($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProcessingTimeMs() => $_has(4);
  @$pb.TagNumber(5)
  void clearProcessingTimeMs() => $_clearField(5);
}

class SoilMoistureSnapshot extends $pb.GeneratedMessage {
  factory SoilMoistureSnapshot({
    $core.double? timeDays,
    $core.Iterable<$core.double>? layerMoisture,
    $core.double? rootZoneWaterMm,
    $core.double? availableWaterMm,
    $core.double? drainageMmDay,
  }) {
    final result = create();
    if (timeDays != null) result.timeDays = timeDays;
    if (layerMoisture != null) result.layerMoisture.addAll(layerMoisture);
    if (rootZoneWaterMm != null) result.rootZoneWaterMm = rootZoneWaterMm;
    if (availableWaterMm != null) result.availableWaterMm = availableWaterMm;
    if (drainageMmDay != null) result.drainageMmDay = drainageMmDay;
    return result;
  }

  SoilMoistureSnapshot._();

  factory SoilMoistureSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory SoilMoistureSnapshot.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SoilMoistureSnapshot',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'timeDays')
    ..p<$core.double>(
        2, _omitFieldNames ? '' : 'layerMoisture', $pb.PbFieldType.KD)
    ..aD(3, _omitFieldNames ? '' : 'rootZoneWaterMm')
    ..aD(4, _omitFieldNames ? '' : 'availableWaterMm')
    ..aD(5, _omitFieldNames ? '' : 'drainageMmDay')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilMoistureSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SoilMoistureSnapshot copyWith(void Function(SoilMoistureSnapshot) updates) =>
      super.copyWith((message) => updates(message as SoilMoistureSnapshot))
          as SoilMoistureSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SoilMoistureSnapshot create() => SoilMoistureSnapshot._();
  @$core.override
  SoilMoistureSnapshot createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static SoilMoistureSnapshot getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SoilMoistureSnapshot>(create);
  static SoilMoistureSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get timeDays => $_getN(0);
  @$pb.TagNumber(1)
  set timeDays($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTimeDays() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimeDays() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.double> get layerMoisture => $_getList(1);

  @$pb.TagNumber(3)
  $core.double get rootZoneWaterMm => $_getN(2);
  @$pb.TagNumber(3)
  set rootZoneWaterMm($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRootZoneWaterMm() => $_has(2);
  @$pb.TagNumber(3)
  void clearRootZoneWaterMm() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get availableWaterMm => $_getN(3);
  @$pb.TagNumber(4)
  set availableWaterMm($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAvailableWaterMm() => $_has(3);
  @$pb.TagNumber(4)
  void clearAvailableWaterMm() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get drainageMmDay => $_getN(4);
  @$pb.TagNumber(5)
  set drainageMmDay($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDrainageMmDay() => $_has(4);
  @$pb.TagNumber(5)
  void clearDrainageMmDay() => $_clearField(5);
}

class WaterBalanceDay extends $pb.GeneratedMessage {
  factory WaterBalanceDay({
    $core.int? day,
    $core.double? etcMmDay,
    $core.double? depletionMm,
    $core.double? totalAvailableWaterMm,
    $core.double? readilyAvailableWaterMm,
    $core.bool? irrigationNeeded,
    $core.double? irrigationAmountMm,
    $core.double? effectiveRainfallMm,
    $core.double? deepPercolationMm,
  }) {
    final result = create();
    if (day != null) result.day = day;
    if (etcMmDay != null) result.etcMmDay = etcMmDay;
    if (depletionMm != null) result.depletionMm = depletionMm;
    if (totalAvailableWaterMm != null)
      result.totalAvailableWaterMm = totalAvailableWaterMm;
    if (readilyAvailableWaterMm != null)
      result.readilyAvailableWaterMm = readilyAvailableWaterMm;
    if (irrigationNeeded != null) result.irrigationNeeded = irrigationNeeded;
    if (irrigationAmountMm != null)
      result.irrigationAmountMm = irrigationAmountMm;
    if (effectiveRainfallMm != null)
      result.effectiveRainfallMm = effectiveRainfallMm;
    if (deepPercolationMm != null) result.deepPercolationMm = deepPercolationMm;
    return result;
  }

  WaterBalanceDay._();

  factory WaterBalanceDay.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WaterBalanceDay.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WaterBalanceDay',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'day')
    ..aD(2, _omitFieldNames ? '' : 'etcMmDay')
    ..aD(3, _omitFieldNames ? '' : 'depletionMm')
    ..aD(4, _omitFieldNames ? '' : 'totalAvailableWaterMm')
    ..aD(5, _omitFieldNames ? '' : 'readilyAvailableWaterMm')
    ..aOB(6, _omitFieldNames ? '' : 'irrigationNeeded')
    ..aD(7, _omitFieldNames ? '' : 'irrigationAmountMm')
    ..aD(8, _omitFieldNames ? '' : 'effectiveRainfallMm')
    ..aD(9, _omitFieldNames ? '' : 'deepPercolationMm')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WaterBalanceDay clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WaterBalanceDay copyWith(void Function(WaterBalanceDay) updates) =>
      super.copyWith((message) => updates(message as WaterBalanceDay))
          as WaterBalanceDay;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WaterBalanceDay create() => WaterBalanceDay._();
  @$core.override
  WaterBalanceDay createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WaterBalanceDay getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WaterBalanceDay>(create);
  static WaterBalanceDay? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get day => $_getIZ(0);
  @$pb.TagNumber(1)
  set day($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDay() => $_has(0);
  @$pb.TagNumber(1)
  void clearDay() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get etcMmDay => $_getN(1);
  @$pb.TagNumber(2)
  set etcMmDay($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEtcMmDay() => $_has(1);
  @$pb.TagNumber(2)
  void clearEtcMmDay() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get depletionMm => $_getN(2);
  @$pb.TagNumber(3)
  set depletionMm($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDepletionMm() => $_has(2);
  @$pb.TagNumber(3)
  void clearDepletionMm() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get totalAvailableWaterMm => $_getN(3);
  @$pb.TagNumber(4)
  set totalAvailableWaterMm($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalAvailableWaterMm() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalAvailableWaterMm() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get readilyAvailableWaterMm => $_getN(4);
  @$pb.TagNumber(5)
  set readilyAvailableWaterMm($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReadilyAvailableWaterMm() => $_has(4);
  @$pb.TagNumber(5)
  void clearReadilyAvailableWaterMm() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get irrigationNeeded => $_getBF(5);
  @$pb.TagNumber(6)
  set irrigationNeeded($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIrrigationNeeded() => $_has(5);
  @$pb.TagNumber(6)
  void clearIrrigationNeeded() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get irrigationAmountMm => $_getN(6);
  @$pb.TagNumber(7)
  set irrigationAmountMm($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIrrigationAmountMm() => $_has(6);
  @$pb.TagNumber(7)
  void clearIrrigationAmountMm() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get effectiveRainfallMm => $_getN(7);
  @$pb.TagNumber(8)
  set effectiveRainfallMm($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEffectiveRainfallMm() => $_has(7);
  @$pb.TagNumber(8)
  void clearEffectiveRainfallMm() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get deepPercolationMm => $_getN(8);
  @$pb.TagNumber(9)
  set deepPercolationMm($core.double value) => $_setDouble(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDeepPercolationMm() => $_has(8);
  @$pb.TagNumber(9)
  void clearDeepPercolationMm() => $_clearField(9);
}

class WaterFlowIrrigationSummary extends $pb.GeneratedMessage {
  factory WaterFlowIrrigationSummary({
    $core.double? totalIrrigationMm,
    $core.double? totalEffectiveRainfallMm,
    $core.double? totalCropEtMm,
    $core.double? totalDeepPercolationMm,
    $core.int? irrigationEvents,
    $core.double? averageIntervalDays,
    $core.double? waterUseEfficiency,
  }) {
    final result = create();
    if (totalIrrigationMm != null) result.totalIrrigationMm = totalIrrigationMm;
    if (totalEffectiveRainfallMm != null)
      result.totalEffectiveRainfallMm = totalEffectiveRainfallMm;
    if (totalCropEtMm != null) result.totalCropEtMm = totalCropEtMm;
    if (totalDeepPercolationMm != null)
      result.totalDeepPercolationMm = totalDeepPercolationMm;
    if (irrigationEvents != null) result.irrigationEvents = irrigationEvents;
    if (averageIntervalDays != null)
      result.averageIntervalDays = averageIntervalDays;
    if (waterUseEfficiency != null)
      result.waterUseEfficiency = waterUseEfficiency;
    return result;
  }

  WaterFlowIrrigationSummary._();

  factory WaterFlowIrrigationSummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory WaterFlowIrrigationSummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'WaterFlowIrrigationSummary',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'agriculture.ai.v1'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'totalIrrigationMm')
    ..aD(2, _omitFieldNames ? '' : 'totalEffectiveRainfallMm')
    ..aD(3, _omitFieldNames ? '' : 'totalCropEtMm')
    ..aD(4, _omitFieldNames ? '' : 'totalDeepPercolationMm')
    ..aI(5, _omitFieldNames ? '' : 'irrigationEvents')
    ..aD(6, _omitFieldNames ? '' : 'averageIntervalDays')
    ..aD(7, _omitFieldNames ? '' : 'waterUseEfficiency')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WaterFlowIrrigationSummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WaterFlowIrrigationSummary copyWith(
          void Function(WaterFlowIrrigationSummary) updates) =>
      super.copyWith(
              (message) => updates(message as WaterFlowIrrigationSummary))
          as WaterFlowIrrigationSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WaterFlowIrrigationSummary create() => WaterFlowIrrigationSummary._();
  @$core.override
  WaterFlowIrrigationSummary createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static WaterFlowIrrigationSummary getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WaterFlowIrrigationSummary>(create);
  static WaterFlowIrrigationSummary? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get totalIrrigationMm => $_getN(0);
  @$pb.TagNumber(1)
  set totalIrrigationMm($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalIrrigationMm() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalIrrigationMm() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get totalEffectiveRainfallMm => $_getN(1);
  @$pb.TagNumber(2)
  set totalEffectiveRainfallMm($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalEffectiveRainfallMm() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalEffectiveRainfallMm() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get totalCropEtMm => $_getN(2);
  @$pb.TagNumber(3)
  set totalCropEtMm($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCropEtMm() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCropEtMm() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get totalDeepPercolationMm => $_getN(3);
  @$pb.TagNumber(4)
  set totalDeepPercolationMm($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalDeepPercolationMm() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalDeepPercolationMm() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get irrigationEvents => $_getIZ(4);
  @$pb.TagNumber(5)
  set irrigationEvents($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIrrigationEvents() => $_has(4);
  @$pb.TagNumber(5)
  void clearIrrigationEvents() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get averageIntervalDays => $_getN(5);
  @$pb.TagNumber(6)
  set averageIntervalDays($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAverageIntervalDays() => $_has(5);
  @$pb.TagNumber(6)
  void clearAverageIntervalDays() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get waterUseEfficiency => $_getN(6);
  @$pb.TagNumber(7)
  set waterUseEfficiency($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasWaterUseEfficiency() => $_has(6);
  @$pb.TagNumber(7)
  void clearWaterUseEfficiency() => $_clearField(7);
}

/// AIGatewayService is the central gateway that wraps all Rust AI/ML engines
/// and exposes them over gRPC to Go microservices.
class AIGatewayServiceApi {
  final $pb.RpcClient _client;

  AIGatewayServiceApi(this._client);

  /// ─── Plant Diagnosis ───────────────────────────────────────────────
  /// Diagnose plant diseases from leaf/stem/fruit images.
  $async.Future<DiagnoseImageResponse> diagnoseImage(
          $pb.ClientContext? ctx, DiagnoseImageRequest request) =>
      _client.invoke<DiagnoseImageResponse>(ctx, 'AIGatewayService',
          'DiagnoseImage', request, DiagnoseImageResponse());

  /// Detect pest damage from plant images.
  $async.Future<DetectPestsResponse> detectPests(
          $pb.ClientContext? ctx, DetectPestsRequest request) =>
      _client.invoke<DetectPestsResponse>(ctx, 'AIGatewayService',
          'DetectPests', request, DetectPestsResponse());

  /// Detect nutrient deficiency from visual symptoms in plant images.
  $async.Future<DetectNutrientDeficiencyResponse> detectNutrientDeficiency(
          $pb.ClientContext? ctx, DetectNutrientDeficiencyRequest request) =>
      _client.invoke<DetectNutrientDeficiencyResponse>(
          ctx,
          'AIGatewayService',
          'DetectNutrientDeficiency',
          request,
          DetectNutrientDeficiencyResponse());

  /// Classify a plant species from images.
  $async.Future<ClassifyPlantResponse> classifyPlant(
          $pb.ClientContext? ctx, ClassifyPlantRequest request) =>
      _client.invoke<ClassifyPlantResponse>(ctx, 'AIGatewayService',
          'ClassifyPlant', request, ClassifyPlantResponse());

  /// ─── Yield Prediction ──────────────────────────────────────────────
  /// Predict crop yield from environmental, soil, and management factors.
  $async.Future<PredictYieldResponse> predictYield(
          $pb.ClientContext? ctx, PredictYieldRequest request) =>
      _client.invoke<PredictYieldResponse>(ctx, 'AIGatewayService',
          'PredictYield', request, PredictYieldResponse());

  /// Simulate crop growth over time given initial conditions.
  $async.Future<SimulateCropGrowthResponse> simulateCropGrowth(
          $pb.ClientContext? ctx, SimulateCropGrowthRequest request) =>
      _client.invoke<SimulateCropGrowthResponse>(ctx, 'AIGatewayService',
          'SimulateCropGrowth', request, SimulateCropGrowthResponse());

  /// ─── Satellite / Vegetation ────────────────────────────────────────
  /// Compute NDVI and related vegetation indices from raster bands.
  $async.Future<ComputeNDVIResponse> computeNDVI(
          $pb.ClientContext? ctx, ComputeNDVIRequest request) =>
      _client.invoke<ComputeNDVIResponse>(ctx, 'AIGatewayService',
          'ComputeNDVI', request, ComputeNDVIResponse());

  /// Detect vegetation stress from satellite imagery.
  $async.Future<DetectVegetationStressResponse> detectVegetationStress(
          $pb.ClientContext? ctx, DetectVegetationStressRequest request) =>
      _client.invoke<DetectVegetationStressResponse>(ctx, 'AIGatewayService',
          'DetectVegetationStress', request, DetectVegetationStressResponse());

  /// ─── Recommendations ──────────────────────────────────────────────
  /// Recommend suitable crops based on soil, climate, and economics.
  $async.Future<RecommendCropsResponse> recommendCrops(
          $pb.ClientContext? ctx, RecommendCropsRequest request) =>
      _client.invoke<RecommendCropsResponse>(ctx, 'AIGatewayService',
          'RecommendCrops', request, RecommendCropsResponse());

  /// ─── Alerting ─────────────────────────────────────────────────────
  /// Evaluate field conditions and return risk scores with alerts.
  $async.Future<EvaluateFieldRiskResponse> evaluateFieldRisk(
          $pb.ClientContext? ctx, EvaluateFieldRiskRequest request) =>
      _client.invoke<EvaluateFieldRiskResponse>(ctx, 'AIGatewayService',
          'EvaluateFieldRisk', request, EvaluateFieldRiskResponse());

  /// ─── Analytics ────────────────────────────────────────────────────
  /// Compute field-level historical analytics with trend analysis.
  $async.Future<ComputeFieldAnalyticsResponse> computeFieldAnalytics(
          $pb.ClientContext? ctx, ComputeFieldAnalyticsRequest request) =>
      _client.invoke<ComputeFieldAnalyticsResponse>(ctx, 'AIGatewayService',
          'ComputeFieldAnalytics', request, ComputeFieldAnalyticsResponse());

  /// ─── Prescriptions ────────────────────────────────────────────────
  /// Generate variable-rate prescription maps for a field.
  $async.Future<GeneratePrescriptionResponse> generatePrescription(
          $pb.ClientContext? ctx, GeneratePrescriptionRequest request) =>
      _client.invoke<GeneratePrescriptionResponse>(ctx, 'AIGatewayService',
          'GeneratePrescription', request, GeneratePrescriptionResponse());

  /// ─── Terrain Analysis ───────────────────────────────────────────
  $async.Future<AnalyzeTerrainResponse> analyzeTerrain(
          $pb.ClientContext? ctx, AnalyzeTerrainRequest request) =>
      _client.invoke<AnalyzeTerrainResponse>(ctx, 'AIGatewayService',
          'AnalyzeTerrain', request, AnalyzeTerrainResponse());

  /// ─── Water Flow Simulation ──────────────────────────────────────
  $async.Future<SimulateWaterFlowResponse> simulateWaterFlow(
          $pb.ClientContext? ctx, SimulateWaterFlowRequest request) =>
      _client.invoke<SimulateWaterFlowResponse>(ctx, 'AIGatewayService',
          'SimulateWaterFlow', request, SimulateWaterFlowResponse());

  /// Human-in-the-loop review of collected training samples.
  $async.Future<ListTrainingSamplesResponse> listTrainingSamples(
          $pb.ClientContext? ctx, ListTrainingSamplesRequest request) =>
      _client.invoke<ListTrainingSamplesResponse>(ctx, 'AIGatewayService',
          'ListTrainingSamples', request, ListTrainingSamplesResponse());
  $async.Future<SubmitLabelReviewResponse> submitLabelReview(
          $pb.ClientContext? ctx, SubmitLabelReviewRequest request) =>
      _client.invoke<SubmitLabelReviewResponse>(ctx, 'AIGatewayService',
          'SubmitLabelReview', request, SubmitLabelReviewResponse());
  $async.Future<GetTrainingSampleImageResponse> getTrainingSampleImage(
          $pb.ClientContext? ctx, GetTrainingSampleImageRequest request) =>
      _client.invoke<GetTrainingSampleImageResponse>(ctx, 'AIGatewayService',
          'GetTrainingSampleImage', request, GetTrainingSampleImageResponse());
  $async.Future<RequestSecondOpinionResponse> requestSecondOpinion(
          $pb.ClientContext? ctx, RequestSecondOpinionRequest request) =>
      _client.invoke<RequestSecondOpinionResponse>(ctx, 'AIGatewayService',
          'RequestSecondOpinion', request, RequestSecondOpinionResponse());
  $async.Future<GetReviewAgreementResponse> getReviewAgreement(
          $pb.ClientContext? ctx, GetReviewAgreementRequest request) =>
      _client.invoke<GetReviewAgreementResponse>(ctx, 'AIGatewayService',
          'GetReviewAgreement', request, GetReviewAgreementResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
