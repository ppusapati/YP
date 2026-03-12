/// Simulated protobuf generated code for farm domain models.
///
/// In production, these classes would be generated from `.proto` files
/// by the `protoc` compiler with the Dart plugin. The API surface mirrors
/// what `package:protobuf` generates.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

/// A geographic coordinate.
class LatLng extends $pb.GeneratedMessage {
  factory LatLng({
    double? latitude,
    double? longitude,
  }) {
    final msg = LatLng._();
    if (latitude != null) msg.latitude = latitude;
    if (longitude != null) msg.longitude = longitude;
    return msg;
  }

  LatLng._() : super();

  factory LatLng.fromBuffer(List<int> data) =>
      LatLng._()..mergeFromBuffer(data);

  factory LatLng.fromJson(String json) => LatLng._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'LatLng',
    package: const $pb.PackageName('yieldpoint.farm.v1'),
    createEmptyInstance: () => LatLng._(),
  )
    ..a<double>(1, 'latitude', $pb.PbFieldType.OD)
    ..a<double>(2, 'longitude', $pb.PbFieldType.OD)
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  LatLng createEmptyInstance() => LatLng._();

  static LatLng getDefault() => _defaultInstance ??= LatLng._();
  static LatLng? _defaultInstance;

  @$pb.TagNumber(1)
  double get latitude => $_getN(0);
  @$pb.TagNumber(1)
  set latitude(double v) {
    $_setDouble(0, v);
  }

  @$pb.TagNumber(1)
  bool hasLatitude() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatitude() => clearField(1);

  @$pb.TagNumber(2)
  double get longitude => $_getN(1);
  @$pb.TagNumber(2)
  set longitude(double v) {
    $_setDouble(1, v);
  }

  @$pb.TagNumber(2)
  bool hasLongitude() => $_has(1);
  @$pb.TagNumber(2)
  void clearLongitude() => clearField(2);
}

/// A farm entity with boundaries and metadata.
class Farm extends $pb.GeneratedMessage {
  factory Farm({
    String? id,
    String? name,
    String? ownerId,
    List<LatLng>? boundaries,
    double? totalArea,
    Int64? createdAt,
    Int64? updatedAt,
  }) {
    final msg = Farm._();
    if (id != null) msg.id = id;
    if (name != null) msg.name = name;
    if (ownerId != null) msg.ownerId = ownerId;
    if (boundaries != null) msg.boundaries.addAll(boundaries);
    if (totalArea != null) msg.totalArea = totalArea;
    if (createdAt != null) msg.createdAt = createdAt;
    if (updatedAt != null) msg.updatedAt = updatedAt;
    return msg;
  }

  Farm._() : super();

  factory Farm.fromBuffer(List<int> data) => Farm._()..mergeFromBuffer(data);
  factory Farm.fromJson(String json) => Farm._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'Farm',
    package: const $pb.PackageName('yieldpoint.farm.v1'),
    createEmptyInstance: () => Farm._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'name')
    ..aOS(3, 'ownerId', protoName: 'ownerId')
    ..pc<LatLng>(4, 'boundaries', $pb.PbFieldType.PM,
        subBuilder: LatLng._)
    ..a<double>(5, 'totalArea', $pb.PbFieldType.OD, protoName: 'totalArea')
    ..aInt64(6, 'createdAt', protoName: 'createdAt')
    ..aInt64(7, 'updatedAt', protoName: 'updatedAt')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  Farm createEmptyInstance() => Farm._();

  static Farm getDefault() => _defaultInstance ??= Farm._();
  static Farm? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name(String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  String get ownerId => $_getSZ(2);
  @$pb.TagNumber(3)
  set ownerId(String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  bool hasOwnerId() => $_has(2);
  @$pb.TagNumber(3)
  void clearOwnerId() => clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<LatLng> get boundaries => $_getList(3);

  @$pb.TagNumber(5)
  double get totalArea => $_getN(4);
  @$pb.TagNumber(5)
  set totalArea(double v) {
    $_setDouble(4, v);
  }

  @$pb.TagNumber(5)
  bool hasTotalArea() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalArea() => clearField(5);

  @$pb.TagNumber(6)
  Int64 get createdAt => $_getI64(5);
  @$pb.TagNumber(6)
  set createdAt(Int64 v) {
    $_setInt64(5, v);
  }

  @$pb.TagNumber(6)
  bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => clearField(6);

  @$pb.TagNumber(7)
  Int64 get updatedAt => $_getI64(6);
  @$pb.TagNumber(7)
  set updatedAt(Int64 v) {
    $_setInt64(6, v);
  }

  @$pb.TagNumber(7)
  bool hasUpdatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearUpdatedAt() => clearField(7);
}

/// A field within a farm.
class Field extends $pb.GeneratedMessage {
  factory Field({
    String? id,
    String? farmId,
    String? name,
    List<LatLng>? polygon,
    double? area,
    String? cropType,
    String? soilType,
  }) {
    final msg = Field._();
    if (id != null) msg.id = id;
    if (farmId != null) msg.farmId = farmId;
    if (name != null) msg.name = name;
    if (polygon != null) msg.polygon.addAll(polygon);
    if (area != null) msg.area = area;
    if (cropType != null) msg.cropType = cropType;
    if (soilType != null) msg.soilType = soilType;
    return msg;
  }

  Field._() : super();

  factory Field.fromBuffer(List<int> data) => Field._()..mergeFromBuffer(data);
  factory Field.fromJson(String json) => Field._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'Field',
    package: const $pb.PackageName('yieldpoint.farm.v1'),
    createEmptyInstance: () => Field._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'farmId', protoName: 'farmId')
    ..aOS(3, 'name')
    ..pc<LatLng>(4, 'polygon', $pb.PbFieldType.PM,
        subBuilder: LatLng._)
    ..a<double>(5, 'area', $pb.PbFieldType.OD)
    ..aOS(6, 'cropType', protoName: 'cropType')
    ..aOS(7, 'soilType', protoName: 'soilType')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;

  @override
  Field createEmptyInstance() => Field._();

  static Field getDefault() => _defaultInstance ??= Field._();
  static Field? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId(String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  bool hasFarmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFarmId() => clearField(2);

  @$pb.TagNumber(3)
  String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name(String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<LatLng> get polygon => $_getList(3);

  @$pb.TagNumber(5)
  double get area => $_getN(4);
  @$pb.TagNumber(5)
  set area(double v) {
    $_setDouble(4, v);
  }

  @$pb.TagNumber(5)
  bool hasArea() => $_has(4);
  @$pb.TagNumber(5)
  void clearArea() => clearField(5);

  @$pb.TagNumber(6)
  String get cropType => $_getSZ(5);
  @$pb.TagNumber(6)
  set cropType(String v) {
    $_setString(5, v);
  }

  @$pb.TagNumber(6)
  bool hasCropType() => $_has(5);
  @$pb.TagNumber(6)
  void clearCropType() => clearField(6);

  @$pb.TagNumber(7)
  String get soilType => $_getSZ(6);
  @$pb.TagNumber(7)
  set soilType(String v) {
    $_setString(6, v);
  }

  @$pb.TagNumber(7)
  bool hasSoilType() => $_has(6);
  @$pb.TagNumber(7)
  void clearSoilType() => clearField(7);
}
