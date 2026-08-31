/// Simulated protobuf generated code for yield prediction models.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

/// A factor contributing to yield prediction.
class YieldFactor extends $pb.GeneratedMessage {
  factory YieldFactor({
    String? name,
    double? impact,
    double? value,
  }) {
    final msg = YieldFactor._();
    if (name != null) msg.name = name;
    if (impact != null) msg.impact = impact;
    if (value != null) msg.value = value;
    return msg;
  }

  YieldFactor._() : super();

  factory YieldFactor.fromBuffer(List<int> data) =>
      YieldFactor._()..mergeFromBuffer(data);
  factory YieldFactor.fromJson(String json) =>
      YieldFactor._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'YieldFactor',
    package: const $pb.PackageName('yieldpoint.yield.v1'),
    createEmptyInstance: () => YieldFactor._(),
  )
    ..aOS(1, 'name')
    ..a<double>(2, 'impact', $pb.PbFieldType.OD)
    ..a<double>(3, 'value', $pb.PbFieldType.OD)
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  YieldFactor createEmptyInstance() => YieldFactor._();
  static YieldFactor getDefault() => _defaultInstance ??= YieldFactor._();
  static YieldFactor? _defaultInstance;

  @$pb.TagNumber(1)
  String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  double get impact => $_getN(1);
  @$pb.TagNumber(2)
  set impact(double v) => $_setDouble(1, v);

  @$pb.TagNumber(3)
  double get value => $_getN(2);
  @$pb.TagNumber(3)
  set value(double v) => $_setDouble(2, v);
}

/// A yield prediction for a field.
class YieldPrediction extends $pb.GeneratedMessage {
  factory YieldPrediction({
    String? fieldId,
    String? cropType,
    double? expectedYield,
    Int64? harvestDate,
    double? confidence,
    List<YieldFactor>? factors,
  }) {
    final msg = YieldPrediction._();
    if (fieldId != null) msg.fieldId = fieldId;
    if (cropType != null) msg.cropType = cropType;
    if (expectedYield != null) msg.expectedYield = expectedYield;
    if (harvestDate != null) msg.harvestDate = harvestDate;
    if (confidence != null) msg.confidence = confidence;
    if (factors != null) msg.factors.addAll(factors);
    return msg;
  }

  YieldPrediction._() : super();

  factory YieldPrediction.fromBuffer(List<int> data) =>
      YieldPrediction._()..mergeFromBuffer(data);
  factory YieldPrediction.fromJson(String json) =>
      YieldPrediction._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'YieldPrediction',
    package: const $pb.PackageName('yieldpoint.yield.v1'),
    createEmptyInstance: () => YieldPrediction._(),
  )
    ..aOS(1, 'fieldId', protoName: 'fieldId')
    ..aOS(2, 'cropType', protoName: 'cropType')
    ..a<double>(3, 'expectedYield', $pb.PbFieldType.OD,
        protoName: 'expectedYield')
    ..aInt64(4, 'harvestDate', protoName: 'harvestDate')
    ..a<double>(5, 'confidence', $pb.PbFieldType.OD)
    ..pc<YieldFactor>(6, 'factors', $pb.PbFieldType.PM,
        subBuilder: YieldFactor._)
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  YieldPrediction createEmptyInstance() => YieldPrediction._();
  static YieldPrediction getDefault() =>
      _defaultInstance ??= YieldPrediction._();
  static YieldPrediction? _defaultInstance;

  @$pb.TagNumber(1)
  String get fieldId => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldId(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get cropType => $_getSZ(1);
  @$pb.TagNumber(2)
  set cropType(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  double get expectedYield => $_getN(2);
  @$pb.TagNumber(3)
  set expectedYield(double v) => $_setDouble(2, v);

  @$pb.TagNumber(4)
  Int64 get harvestDate => $_getI64(3);
  @$pb.TagNumber(4)
  set harvestDate(Int64 v) => $_setInt64(3, v);

  @$pb.TagNumber(5)
  double get confidence => $_getN(4);
  @$pb.TagNumber(5)
  set confidence(double v) => $_setDouble(4, v);

  @$pb.TagNumber(6)
  $pb.PbList<YieldFactor> get factors => $_getList(5);
}
