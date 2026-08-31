/// Simulated protobuf generated code for soil analysis models.
import 'package:protobuf/protobuf.dart' as $pb;

/// Soil analysis data for a field.
class SoilAnalysis extends $pb.GeneratedMessage {
  factory SoilAnalysis({
    String? fieldId,
    double? pH,
    double? organicCarbon,
    double? nitrogen,
    double? phosphorus,
    double? potassium,
    String? texture,
  }) {
    final msg = SoilAnalysis._();
    if (fieldId != null) msg.fieldId = fieldId;
    if (pH != null) msg.pH = pH;
    if (organicCarbon != null) msg.organicCarbon = organicCarbon;
    if (nitrogen != null) msg.nitrogen = nitrogen;
    if (phosphorus != null) msg.phosphorus = phosphorus;
    if (potassium != null) msg.potassium = potassium;
    if (texture != null) msg.texture = texture;
    return msg;
  }

  SoilAnalysis._() : super();

  factory SoilAnalysis.fromBuffer(List<int> data) =>
      SoilAnalysis._()..mergeFromBuffer(data);
  factory SoilAnalysis.fromJson(String json) =>
      SoilAnalysis._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'SoilAnalysis',
    package: const $pb.PackageName('yieldpoint.soil.v1'),
    createEmptyInstance: () => SoilAnalysis._(),
  )
    ..aOS(1, 'fieldId', protoName: 'fieldId')
    ..a<double>(2, 'pH', $pb.PbFieldType.OD)
    ..a<double>(3, 'organicCarbon', $pb.PbFieldType.OD,
        protoName: 'organicCarbon')
    ..a<double>(4, 'nitrogen', $pb.PbFieldType.OD)
    ..a<double>(5, 'phosphorus', $pb.PbFieldType.OD)
    ..a<double>(6, 'potassium', $pb.PbFieldType.OD)
    ..aOS(7, 'texture')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  SoilAnalysis createEmptyInstance() => SoilAnalysis._();
  static SoilAnalysis getDefault() => _defaultInstance ??= SoilAnalysis._();
  static SoilAnalysis? _defaultInstance;

  @$pb.TagNumber(1)
  String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  double get pH => $_getN(1);
  @$pb.TagNumber(2)
  set pH(double v) => $_setDouble(1, v);

  @$pb.TagNumber(3)
  double get organicCarbon => $_getN(2);
  @$pb.TagNumber(3)
  set organicCarbon(double v) => $_setDouble(2, v);

  @$pb.TagNumber(4)
  double get nitrogen => $_getN(3);
  @$pb.TagNumber(4)
  set nitrogen(double v) => $_setDouble(3, v);

  @$pb.TagNumber(5)
  double get phosphorus => $_getN(4);
  @$pb.TagNumber(5)
  set phosphorus(double v) => $_setDouble(4, v);

  @$pb.TagNumber(6)
  double get potassium => $_getN(5);
  @$pb.TagNumber(6)
  set potassium(double v) => $_setDouble(5, v);

  @$pb.TagNumber(7)
  String get texture => $_getSZ(6);
  @$pb.TagNumber(7)
  set texture(String v) => $_setString(6, v);
}
