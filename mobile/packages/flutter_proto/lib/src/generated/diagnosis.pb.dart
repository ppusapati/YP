/// Simulated protobuf generated code for AI crop diagnosis models.
import 'package:protobuf/protobuf.dart' as $pb;

/// A request to diagnose a crop image.
class DiagnosisRequest extends $pb.GeneratedMessage {
  factory DiagnosisRequest({
    List<int>? imageData,
    double? latitude,
    double? longitude,
    String? cropType,
  }) {
    final msg = DiagnosisRequest._();
    if (imageData != null) msg.imageData = imageData;
    if (latitude != null) msg.latitude = latitude;
    if (longitude != null) msg.longitude = longitude;
    if (cropType != null) msg.cropType = cropType;
    return msg;
  }

  DiagnosisRequest._() : super();

  factory DiagnosisRequest.fromBuffer(List<int> data) =>
      DiagnosisRequest._()..mergeFromBuffer(data);
  factory DiagnosisRequest.fromJson(String json) =>
      DiagnosisRequest._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'DiagnosisRequest',
    package: const $pb.PackageName('yieldpoint.diagnosis.v1'),
    createEmptyInstance: () => DiagnosisRequest._(),
  )
    ..a<List<int>>(1, 'imageData', $pb.PbFieldType.OY, protoName: 'imageData')
    ..a<double>(2, 'latitude', $pb.PbFieldType.OD)
    ..a<double>(3, 'longitude', $pb.PbFieldType.OD)
    ..aOS(4, 'cropType', protoName: 'cropType')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  DiagnosisRequest createEmptyInstance() => DiagnosisRequest._();
  static DiagnosisRequest getDefault() =>
      _defaultInstance ??= DiagnosisRequest._();
  static DiagnosisRequest? _defaultInstance;

  @$pb.TagNumber(1)
  List<int> get imageData => $_getN(0);
  @$pb.TagNumber(1)
  set imageData(List<int> v) {
    $_setBytes(0, v);
  }

  @$pb.TagNumber(1)
  bool hasImageData() => $_has(0);
  @$pb.TagNumber(1)
  void clearImageData() => clearField(1);

  @$pb.TagNumber(2)
  double get latitude => $_getN(1);
  @$pb.TagNumber(2)
  set latitude(double v) => $_setDouble(1, v);
  @$pb.TagNumber(2)
  bool hasLatitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLatitude() => clearField(2);

  @$pb.TagNumber(3)
  double get longitude => $_getN(2);
  @$pb.TagNumber(3)
  set longitude(double v) => $_setDouble(2, v);
  @$pb.TagNumber(3)
  bool hasLongitude() => $_has(2);
  @$pb.TagNumber(3)
  void clearLongitude() => clearField(3);

  @$pb.TagNumber(4)
  String get cropType => $_getSZ(3);
  @$pb.TagNumber(4)
  set cropType(String v) => $_setString(3, v);
  @$pb.TagNumber(4)
  bool hasCropType() => $_has(3);
  @$pb.TagNumber(4)
  void clearCropType() => clearField(4);
}

/// A recommended treatment for a diagnosed disease.
class Treatment extends $pb.GeneratedMessage {
  factory Treatment({
    String? name,
    String? description,
    String? applicationMethod,
    String? frequency,
  }) {
    final msg = Treatment._();
    if (name != null) msg.name = name;
    if (description != null) msg.description = description;
    if (applicationMethod != null) msg.applicationMethod = applicationMethod;
    if (frequency != null) msg.frequency = frequency;
    return msg;
  }

  Treatment._() : super();

  factory Treatment.fromBuffer(List<int> data) =>
      Treatment._()..mergeFromBuffer(data);
  factory Treatment.fromJson(String json) =>
      Treatment._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'Treatment',
    package: const $pb.PackageName('yieldpoint.diagnosis.v1'),
    createEmptyInstance: () => Treatment._(),
  )
    ..aOS(1, 'name')
    ..aOS(2, 'description')
    ..aOS(3, 'applicationMethod', protoName: 'applicationMethod')
    ..aOS(4, 'frequency')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  Treatment createEmptyInstance() => Treatment._();
  static Treatment getDefault() => _defaultInstance ??= Treatment._();
  static Treatment? _defaultInstance;

  @$pb.TagNumber(1)
  String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get applicationMethod => $_getSZ(2);
  @$pb.TagNumber(3)
  set applicationMethod(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  String get frequency => $_getSZ(3);
  @$pb.TagNumber(4)
  set frequency(String v) => $_setString(3, v);
}

/// The result of an AI crop diagnosis.
class DiagnosisResult extends $pb.GeneratedMessage {
  factory DiagnosisResult({
    String? plantSpecies,
    String? diseaseType,
    double? confidence,
    List<Treatment>? treatments,
    String? severity,
  }) {
    final msg = DiagnosisResult._();
    if (plantSpecies != null) msg.plantSpecies = plantSpecies;
    if (diseaseType != null) msg.diseaseType = diseaseType;
    if (confidence != null) msg.confidence = confidence;
    if (treatments != null) msg.treatments.addAll(treatments);
    if (severity != null) msg.severity = severity;
    return msg;
  }

  DiagnosisResult._() : super();

  factory DiagnosisResult.fromBuffer(List<int> data) =>
      DiagnosisResult._()..mergeFromBuffer(data);
  factory DiagnosisResult.fromJson(String json) =>
      DiagnosisResult._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'DiagnosisResult',
    package: const $pb.PackageName('yieldpoint.diagnosis.v1'),
    createEmptyInstance: () => DiagnosisResult._(),
  )
    ..aOS(1, 'plantSpecies', protoName: 'plantSpecies')
    ..aOS(2, 'diseaseType', protoName: 'diseaseType')
    ..a<double>(3, 'confidence', $pb.PbFieldType.OD)
    ..pc<Treatment>(4, 'treatments', $pb.PbFieldType.PM,
        subBuilder: Treatment._)
    ..aOS(5, 'severity')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  DiagnosisResult createEmptyInstance() => DiagnosisResult._();
  static DiagnosisResult getDefault() =>
      _defaultInstance ??= DiagnosisResult._();
  static DiagnosisResult? _defaultInstance;

  @$pb.TagNumber(1)
  String get plantSpecies => $_getSZ(0);
  @$pb.TagNumber(1)
  set plantSpecies(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get diseaseType => $_getSZ(1);
  @$pb.TagNumber(2)
  set diseaseType(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  double get confidence => $_getN(2);
  @$pb.TagNumber(3)
  set confidence(double v) => $_setDouble(2, v);

  @$pb.TagNumber(4)
  $pb.PbList<Treatment> get treatments => $_getList(3);

  @$pb.TagNumber(5)
  String get severity => $_getSZ(4);
  @$pb.TagNumber(5)
  set severity(String v) => $_setString(4, v);
}
