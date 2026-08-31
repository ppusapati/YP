/// Simulated protobuf generated code for satellite analytics models.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

/// A stress alert detected in a field.
class StressAlert extends $pb.GeneratedMessage {
  factory StressAlert({
    String? id,
    String? farmId,
    String? fieldId,
    String? stressType,
    String? severity,
    double? confidence,
    double? affectedAreaHectares,
    bool? acknowledged,
    Int64? detectedAt,
  }) {
    final msg = StressAlert._();
    if (id != null) msg.id = id;
    if (farmId != null) msg.farmId = farmId;
    if (fieldId != null) msg.fieldId = fieldId;
    if (stressType != null) msg.stressType = stressType;
    if (severity != null) msg.severity = severity;
    if (confidence != null) msg.confidence = confidence;
    if (affectedAreaHectares != null) {
      msg.affectedAreaHectares = affectedAreaHectares;
    }
    if (acknowledged != null) msg.acknowledged = acknowledged;
    if (detectedAt != null) msg.detectedAt = detectedAt;
    return msg;
  }

  StressAlert._() : super();

  factory StressAlert.fromBuffer(List<int> data) =>
      StressAlert._()..mergeFromBuffer(data);
  factory StressAlert.fromJson(String json) =>
      StressAlert._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'StressAlert',
    package: const $pb.PackageName('yieldpoint.satellite.analytics.v1'),
    createEmptyInstance: () => StressAlert._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'farmId', protoName: 'farmId')
    ..aOS(3, 'fieldId', protoName: 'fieldId')
    ..aOS(4, 'stressType', protoName: 'stressType')
    ..aOS(5, 'severity')
    ..a<double>(6, 'confidence', $pb.PbFieldType.OD)
    ..a<double>(7, 'affectedAreaHectares', $pb.PbFieldType.OD,
        protoName: 'affectedAreaHectares')
    ..aOB(8, 'acknowledged')
    ..aInt64(9, 'detectedAt', protoName: 'detectedAt')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  StressAlert createEmptyInstance() => StressAlert._();
  static StressAlert getDefault() => _defaultInstance ??= StressAlert._();
  static StressAlert? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get fieldId => $_getSZ(2);
  @$pb.TagNumber(3)
  set fieldId(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  String get stressType => $_getSZ(3);
  @$pb.TagNumber(4)
  set stressType(String v) => $_setString(3, v);

  @$pb.TagNumber(5)
  String get severity => $_getSZ(4);
  @$pb.TagNumber(5)
  set severity(String v) => $_setString(4, v);

  @$pb.TagNumber(6)
  double get confidence => $_getN(5);
  @$pb.TagNumber(6)
  set confidence(double v) => $_setDouble(5, v);

  @$pb.TagNumber(7)
  double get affectedAreaHectares => $_getN(6);
  @$pb.TagNumber(7)
  set affectedAreaHectares(double v) => $_setDouble(6, v);

  @$pb.TagNumber(8)
  bool get acknowledged => $_getBF(7);
  @$pb.TagNumber(8)
  set acknowledged(bool v) => $_setBool(7, v);

  @$pb.TagNumber(9)
  Int64 get detectedAt => $_getI64(8);
  @$pb.TagNumber(9)
  set detectedAt(Int64 v) => $_setInt64(8, v);
}

/// Result of a temporal analysis over a time period.
class TemporalAnalysisResult extends $pb.GeneratedMessage {
  factory TemporalAnalysisResult({
    String? farmId,
    String? fieldId,
    String? analysisType,
    Int64? periodStart,
    Int64? periodEnd,
    int? dataPoints,
    String? summary,
  }) {
    final msg = TemporalAnalysisResult._();
    if (farmId != null) msg.farmId = farmId;
    if (fieldId != null) msg.fieldId = fieldId;
    if (analysisType != null) msg.analysisType = analysisType;
    if (periodStart != null) msg.periodStart = periodStart;
    if (periodEnd != null) msg.periodEnd = periodEnd;
    if (dataPoints != null) msg.dataPoints = dataPoints;
    if (summary != null) msg.summary = summary;
    return msg;
  }

  TemporalAnalysisResult._() : super();

  factory TemporalAnalysisResult.fromBuffer(List<int> data) =>
      TemporalAnalysisResult._()..mergeFromBuffer(data);
  factory TemporalAnalysisResult.fromJson(String json) =>
      TemporalAnalysisResult._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'TemporalAnalysisResult',
    package: const $pb.PackageName('yieldpoint.satellite.analytics.v1'),
    createEmptyInstance: () => TemporalAnalysisResult._(),
  )
    ..aOS(1, 'farmId', protoName: 'farmId')
    ..aOS(2, 'fieldId', protoName: 'fieldId')
    ..aOS(3, 'analysisType', protoName: 'analysisType')
    ..aInt64(4, 'periodStart', protoName: 'periodStart')
    ..aInt64(5, 'periodEnd', protoName: 'periodEnd')
    ..a<int>(6, 'dataPoints', $pb.PbFieldType.O3, protoName: 'dataPoints')
    ..aOS(7, 'summary')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  TemporalAnalysisResult createEmptyInstance() => TemporalAnalysisResult._();
  static TemporalAnalysisResult getDefault() =>
      _defaultInstance ??= TemporalAnalysisResult._();
  static TemporalAnalysisResult? _defaultInstance;

  @$pb.TagNumber(1)
  String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get analysisType => $_getSZ(2);
  @$pb.TagNumber(3)
  set analysisType(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  Int64 get periodStart => $_getI64(3);
  @$pb.TagNumber(4)
  set periodStart(Int64 v) => $_setInt64(3, v);

  @$pb.TagNumber(5)
  Int64 get periodEnd => $_getI64(4);
  @$pb.TagNumber(5)
  set periodEnd(Int64 v) => $_setInt64(4, v);

  @$pb.TagNumber(6)
  int get dataPoints => $_getIZ(5);
  @$pb.TagNumber(6)
  set dataPoints(int v) => $_setSignedInt32(5, v);

  @$pb.TagNumber(7)
  String get summary => $_getSZ(6);
  @$pb.TagNumber(7)
  set summary(String v) => $_setString(6, v);
}

/// Summary of analytics for a field.
class FieldAnalyticsSummary extends $pb.GeneratedMessage {
  factory FieldAnalyticsSummary({
    String? farmId,
    String? fieldId,
    int? activeStressAlerts,
    double? healthScore,
    String? ndviTrend,
    String? dominantStressType,
    Int64? lastAnalysis,
  }) {
    final msg = FieldAnalyticsSummary._();
    if (farmId != null) msg.farmId = farmId;
    if (fieldId != null) msg.fieldId = fieldId;
    if (activeStressAlerts != null) {
      msg.activeStressAlerts = activeStressAlerts;
    }
    if (healthScore != null) msg.healthScore = healthScore;
    if (ndviTrend != null) msg.ndviTrend = ndviTrend;
    if (dominantStressType != null) {
      msg.dominantStressType = dominantStressType;
    }
    if (lastAnalysis != null) msg.lastAnalysis = lastAnalysis;
    return msg;
  }

  FieldAnalyticsSummary._() : super();

  factory FieldAnalyticsSummary.fromBuffer(List<int> data) =>
      FieldAnalyticsSummary._()..mergeFromBuffer(data);
  factory FieldAnalyticsSummary.fromJson(String json) =>
      FieldAnalyticsSummary._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'FieldAnalyticsSummary',
    package: const $pb.PackageName('yieldpoint.satellite.analytics.v1'),
    createEmptyInstance: () => FieldAnalyticsSummary._(),
  )
    ..aOS(1, 'farmId', protoName: 'farmId')
    ..aOS(2, 'fieldId', protoName: 'fieldId')
    ..a<int>(3, 'activeStressAlerts', $pb.PbFieldType.O3,
        protoName: 'activeStressAlerts')
    ..a<double>(4, 'healthScore', $pb.PbFieldType.OD, protoName: 'healthScore')
    ..aOS(5, 'ndviTrend', protoName: 'ndviTrend')
    ..aOS(6, 'dominantStressType', protoName: 'dominantStressType')
    ..aInt64(7, 'lastAnalysis', protoName: 'lastAnalysis')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  FieldAnalyticsSummary createEmptyInstance() => FieldAnalyticsSummary._();
  static FieldAnalyticsSummary getDefault() =>
      _defaultInstance ??= FieldAnalyticsSummary._();
  static FieldAnalyticsSummary? _defaultInstance;

  @$pb.TagNumber(1)
  String get farmId => $_getSZ(0);
  @$pb.TagNumber(1)
  set farmId(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  int get activeStressAlerts => $_getIZ(2);
  @$pb.TagNumber(3)
  set activeStressAlerts(int v) => $_setSignedInt32(2, v);

  @$pb.TagNumber(4)
  double get healthScore => $_getN(3);
  @$pb.TagNumber(4)
  set healthScore(double v) => $_setDouble(3, v);

  @$pb.TagNumber(5)
  String get ndviTrend => $_getSZ(4);
  @$pb.TagNumber(5)
  set ndviTrend(String v) => $_setString(4, v);

  @$pb.TagNumber(6)
  String get dominantStressType => $_getSZ(5);
  @$pb.TagNumber(6)
  set dominantStressType(String v) => $_setString(5, v);

  @$pb.TagNumber(7)
  Int64 get lastAnalysis => $_getI64(6);
  @$pb.TagNumber(7)
  set lastAnalysis(Int64 v) => $_setInt64(6, v);
}
