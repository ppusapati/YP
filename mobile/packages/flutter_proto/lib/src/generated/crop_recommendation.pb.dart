/// Simulated protobuf generated code for crop recommendation models.
import 'package:protobuf/protobuf.dart' as $pb;

/// A recommendation for a crop to plant.
class CropRecommendation extends $pb.GeneratedMessage {
  factory CropRecommendation({
    String? cropName,
    String? plantingWindow,
    double? soilSuitability,
    double? expectedYield,
    List<String>? reasons,
  }) {
    final msg = CropRecommendation._();
    if (cropName != null) msg.cropName = cropName;
    if (plantingWindow != null) msg.plantingWindow = plantingWindow;
    if (soilSuitability != null) msg.soilSuitability = soilSuitability;
    if (expectedYield != null) msg.expectedYield = expectedYield;
    if (reasons != null) msg.reasons.addAll(reasons);
    return msg;
  }

  CropRecommendation._() : super();

  factory CropRecommendation.fromBuffer(List<int> data) =>
      CropRecommendation._()..mergeFromBuffer(data);
  factory CropRecommendation.fromJson(String json) =>
      CropRecommendation._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'CropRecommendation',
    package: const $pb.PackageName('yieldpoint.recommendation.v1'),
    createEmptyInstance: () => CropRecommendation._(),
  )
    ..aOS(1, 'cropName', protoName: 'cropName')
    ..aOS(2, 'plantingWindow', protoName: 'plantingWindow')
    ..a<double>(3, 'soilSuitability', $pb.PbFieldType.OD,
        protoName: 'soilSuitability')
    ..a<double>(4, 'expectedYield', $pb.PbFieldType.OD,
        protoName: 'expectedYield')
    ..pPS(5, 'reasons')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  CropRecommendation createEmptyInstance() => CropRecommendation._();
  static CropRecommendation getDefault() =>
      _defaultInstance ??= CropRecommendation._();
  static CropRecommendation? _defaultInstance;

  @$pb.TagNumber(1)
  String get cropName => $_getSZ(0);
  @$pb.TagNumber(1)
  set cropName(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get plantingWindow => $_getSZ(1);
  @$pb.TagNumber(2)
  set plantingWindow(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  double get soilSuitability => $_getN(2);
  @$pb.TagNumber(3)
  set soilSuitability(double v) => $_setDouble(2, v);

  @$pb.TagNumber(4)
  double get expectedYield => $_getN(3);
  @$pb.TagNumber(4)
  set expectedYield(double v) => $_setDouble(3, v);

  @$pb.TagNumber(5)
  $pb.PbList<String> get reasons => $_getList(4);
}
