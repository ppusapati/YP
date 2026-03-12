/// Simulated protobuf generated code for produce traceability models.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

import 'farm.pb.dart';

/// A record tracking a produce batch from farm to market.
class ProduceRecord extends $pb.GeneratedMessage {
  factory ProduceRecord({
    String? id,
    String? farmId,
    String? cropVariety,
    Int64? harvestDate,
    List<String>? treatments,
    LatLng? farmLocation,
    List<String>? certifications,
  }) {
    final msg = ProduceRecord._();
    if (id != null) msg.id = id;
    if (farmId != null) msg.farmId = farmId;
    if (cropVariety != null) msg.cropVariety = cropVariety;
    if (harvestDate != null) msg.harvestDate = harvestDate;
    if (treatments != null) msg.treatments.addAll(treatments);
    if (farmLocation != null) msg.farmLocation = farmLocation;
    if (certifications != null) msg.certifications.addAll(certifications);
    return msg;
  }

  ProduceRecord._() : super();

  factory ProduceRecord.fromBuffer(List<int> data) =>
      ProduceRecord._()..mergeFromBuffer(data);
  factory ProduceRecord.fromJson(String json) =>
      ProduceRecord._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'ProduceRecord',
    package: const $pb.PackageName('yieldpoint.traceability.v1'),
    createEmptyInstance: () => ProduceRecord._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'farmId', protoName: 'farmId')
    ..aOS(3, 'cropVariety', protoName: 'cropVariety')
    ..aInt64(4, 'harvestDate', protoName: 'harvestDate')
    ..pPS(5, 'treatments')
    ..aOM<LatLng>(6, 'farmLocation',
        protoName: 'farmLocation', subBuilder: LatLng._)
    ..pPS(7, 'certifications')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  ProduceRecord createEmptyInstance() => ProduceRecord._();
  static ProduceRecord getDefault() => _defaultInstance ??= ProduceRecord._();
  static ProduceRecord? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get cropVariety => $_getSZ(2);
  @$pb.TagNumber(3)
  set cropVariety(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  Int64 get harvestDate => $_getI64(3);
  @$pb.TagNumber(4)
  set harvestDate(Int64 v) => $_setInt64(3, v);

  @$pb.TagNumber(5)
  $pb.PbList<String> get treatments => $_getList(4);

  @$pb.TagNumber(6)
  LatLng get farmLocation => $_getN(5);
  @$pb.TagNumber(6)
  set farmLocation(LatLng v) => setField(6, v);
  @$pb.TagNumber(6)
  bool hasFarmLocation() => $_has(5);
  @$pb.TagNumber(6)
  void clearFarmLocation() => clearField(6);
  @$pb.TagNumber(6)
  LatLng ensureFarmLocation() => $_ensure(5);

  @$pb.TagNumber(7)
  $pb.PbList<String> get certifications => $_getList(6);
}
