/// Simulated protobuf generated code for pest risk models.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import 'farm.pb.dart';

/// The risk level for pest activity.
class PestRiskLevel extends $pb.ProtobufEnum {
  static const PestRiskLevel LOW = PestRiskLevel._(0, 'LOW');
  static const PestRiskLevel MODERATE = PestRiskLevel._(1, 'MODERATE');
  static const PestRiskLevel HIGH = PestRiskLevel._(2, 'HIGH');
  static const PestRiskLevel CRITICAL = PestRiskLevel._(3, 'CRITICAL');

  static const List<PestRiskLevel> values = [LOW, MODERATE, HIGH, CRITICAL];

  static final Map<int, PestRiskLevel> _byValue =
      $pb.ProtobufEnum.initByValue(values);
  static PestRiskLevel? valueOf(int value) => _byValue[value];

  const PestRiskLevel._(int v, String n) : super(v, n);
}

/// A zone with identified pest risk.
class PestRiskZone extends $pb.GeneratedMessage {
  factory PestRiskZone({
    String? id,
    String? fieldId,
    PestRiskLevel? riskLevel,
    String? pestType,
    List<LatLng>? polygon,
    Int64? alertDate,
  }) {
    final msg = PestRiskZone._();
    if (id != null) msg.id = id;
    if (fieldId != null) msg.fieldId = fieldId;
    if (riskLevel != null) msg.riskLevel = riskLevel;
    if (pestType != null) msg.pestType = pestType;
    if (polygon != null) msg.polygon.addAll(polygon);
    if (alertDate != null) msg.alertDate = alertDate;
    return msg;
  }

  PestRiskZone._() : super();

  factory PestRiskZone.fromBuffer(List<int> data) =>
      PestRiskZone._()..mergeFromBuffer(data);
  factory PestRiskZone.fromJson(String json) =>
      PestRiskZone._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'PestRiskZone',
    package: const $pb.PackageName('yieldpoint.pest.v1'),
    createEmptyInstance: () => PestRiskZone._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'fieldId', protoName: 'fieldId')
    ..e<PestRiskLevel>(3, 'riskLevel', $pb.PbFieldType.OE,
        protoName: 'riskLevel',
        defaultOrMaker: PestRiskLevel.LOW,
        valueOf: PestRiskLevel.valueOf,
        enumValues: PestRiskLevel.values)
    ..aOS(4, 'pestType', protoName: 'pestType')
    ..pc<LatLng>(5, 'polygon', $pb.PbFieldType.PM, subBuilder: LatLng._)
    ..aInt64(6, 'alertDate', protoName: 'alertDate')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  PestRiskZone createEmptyInstance() => PestRiskZone._();
  static PestRiskZone getDefault() => _defaultInstance ??= PestRiskZone._();
  static PestRiskZone? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get fieldId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fieldId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  PestRiskLevel get riskLevel => $_getN(2);
  @$pb.TagNumber(3)
  set riskLevel(PestRiskLevel v) => setField(3, v);

  @$pb.TagNumber(4)
  String get pestType => $_getSZ(3);
  @$pb.TagNumber(4)
  set pestType(String v) => $_setString(3, v);

  @$pb.TagNumber(5)
  $pb.PbList<LatLng> get polygon => $_getList(4);

  @$pb.TagNumber(6)
  Int64 get alertDate => $_getI64(5);
  @$pb.TagNumber(6)
  set alertDate(Int64 v) => $_setInt64(5, v);
}
