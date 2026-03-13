/// Simulated protobuf generated code for satellite tile models.
import 'package:fixnum/fixnum.dart';
import 'package:protobuf/protobuf.dart' as $pb;

/// A tileset generated from a processing job.
class Tileset extends $pb.GeneratedMessage {
  factory Tileset({
    String? id,
    String? processingJobId,
    String? farmId,
    String? layer,
    String? format,
    int? minZoom,
    int? maxZoom,
    int? tileCount,
    String? status,
    Int64? createdAt,
  }) {
    final msg = Tileset._();
    if (id != null) msg.id = id;
    if (processingJobId != null) msg.processingJobId = processingJobId;
    if (farmId != null) msg.farmId = farmId;
    if (layer != null) msg.layer = layer;
    if (format != null) msg.format = format;
    if (minZoom != null) msg.minZoom = minZoom;
    if (maxZoom != null) msg.maxZoom = maxZoom;
    if (tileCount != null) msg.tileCount = tileCount;
    if (status != null) msg.status = status;
    if (createdAt != null) msg.createdAt = createdAt;
    return msg;
  }

  Tileset._() : super();

  factory Tileset.fromBuffer(List<int> data) =>
      Tileset._()..mergeFromBuffer(data);
  factory Tileset.fromJson(String json) =>
      Tileset._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'Tileset',
    package: const $pb.PackageName('yieldpoint.satellite.tile.v1'),
    createEmptyInstance: () => Tileset._(),
  )
    ..aOS(1, 'id')
    ..aOS(2, 'processingJobId', protoName: 'processingJobId')
    ..aOS(3, 'farmId', protoName: 'farmId')
    ..aOS(4, 'layer')
    ..aOS(5, 'format')
    ..a<int>(6, 'minZoom', $pb.PbFieldType.O3, protoName: 'minZoom')
    ..a<int>(7, 'maxZoom', $pb.PbFieldType.O3, protoName: 'maxZoom')
    ..a<int>(8, 'tileCount', $pb.PbFieldType.O3, protoName: 'tileCount')
    ..aOS(9, 'status')
    ..aInt64(10, 'createdAt', protoName: 'createdAt')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  Tileset createEmptyInstance() => Tileset._();
  static Tileset getDefault() => _defaultInstance ??= Tileset._();
  static Tileset? _defaultInstance;

  @$pb.TagNumber(1)
  String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  String get processingJobId => $_getSZ(1);
  @$pb.TagNumber(2)
  set processingJobId(String v) => $_setString(1, v);

  @$pb.TagNumber(3)
  String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId(String v) => $_setString(2, v);

  @$pb.TagNumber(4)
  String get layer => $_getSZ(3);
  @$pb.TagNumber(4)
  set layer(String v) => $_setString(3, v);

  @$pb.TagNumber(5)
  String get format => $_getSZ(4);
  @$pb.TagNumber(5)
  set format(String v) => $_setString(4, v);

  @$pb.TagNumber(6)
  int get minZoom => $_getIZ(5);
  @$pb.TagNumber(6)
  set minZoom(int v) => $_setSignedInt32(5, v);

  @$pb.TagNumber(7)
  int get maxZoom => $_getIZ(6);
  @$pb.TagNumber(7)
  set maxZoom(int v) => $_setSignedInt32(6, v);

  @$pb.TagNumber(8)
  int get tileCount => $_getIZ(7);
  @$pb.TagNumber(8)
  set tileCount(int v) => $_setSignedInt32(7, v);

  @$pb.TagNumber(9)
  String get status => $_getSZ(8);
  @$pb.TagNumber(9)
  set status(String v) => $_setString(8, v);

  @$pb.TagNumber(10)
  Int64 get createdAt => $_getI64(9);
  @$pb.TagNumber(10)
  set createdAt(Int64 v) => $_setInt64(9, v);
}

/// A request for a specific tile.
class TileRequest extends $pb.GeneratedMessage {
  factory TileRequest({
    String? tilesetId,
    int? z,
    int? x,
    int? y,
  }) {
    final msg = TileRequest._();
    if (tilesetId != null) msg.tilesetId = tilesetId;
    if (z != null) msg.z = z;
    if (x != null) msg.x = x;
    if (y != null) msg.y = y;
    return msg;
  }

  TileRequest._() : super();

  factory TileRequest.fromBuffer(List<int> data) =>
      TileRequest._()..mergeFromBuffer(data);
  factory TileRequest.fromJson(String json) =>
      TileRequest._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'TileRequest',
    package: const $pb.PackageName('yieldpoint.satellite.tile.v1'),
    createEmptyInstance: () => TileRequest._(),
  )
    ..aOS(1, 'tilesetId', protoName: 'tilesetId')
    ..a<int>(2, 'z', $pb.PbFieldType.O3)
    ..a<int>(3, 'x', $pb.PbFieldType.O3)
    ..a<int>(4, 'y', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  TileRequest createEmptyInstance() => TileRequest._();
  static TileRequest getDefault() => _defaultInstance ??= TileRequest._();
  static TileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  String get tilesetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tilesetId(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  int get z => $_getIZ(1);
  @$pb.TagNumber(2)
  set z(int v) => $_setSignedInt32(1, v);

  @$pb.TagNumber(3)
  int get x => $_getIZ(2);
  @$pb.TagNumber(3)
  set x(int v) => $_setSignedInt32(2, v);

  @$pb.TagNumber(4)
  int get y => $_getIZ(3);
  @$pb.TagNumber(4)
  set y(int v) => $_setSignedInt32(3, v);
}

/// Tile data returned for a tile request.
class TileData extends $pb.GeneratedMessage {
  factory TileData({
    String? tilesetId,
    int? z,
    int? x,
    int? y,
    List<int>? data,
    String? contentType,
  }) {
    final msg = TileData._();
    if (tilesetId != null) msg.tilesetId = tilesetId;
    if (z != null) msg.z = z;
    if (x != null) msg.x = x;
    if (y != null) msg.y = y;
    if (data != null) msg.data = data;
    if (contentType != null) msg.contentType = contentType;
    return msg;
  }

  TileData._() : super();

  factory TileData.fromBuffer(List<int> data) =>
      TileData._()..mergeFromBuffer(data);
  factory TileData.fromJson(String json) =>
      TileData._()..mergeFromJson(json);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
    'TileData',
    package: const $pb.PackageName('yieldpoint.satellite.tile.v1'),
    createEmptyInstance: () => TileData._(),
  )
    ..aOS(1, 'tilesetId', protoName: 'tilesetId')
    ..a<int>(2, 'z', $pb.PbFieldType.O3)
    ..a<int>(3, 'x', $pb.PbFieldType.O3)
    ..a<int>(4, 'y', $pb.PbFieldType.O3)
    ..a<List<int>>(5, 'data', $pb.PbFieldType.OY)
    ..aOS(6, 'contentType', protoName: 'contentType')
    ..hasRequiredFields = false;

  @override
  $pb.BuilderInfo get info_ => _i;
  @override
  TileData createEmptyInstance() => TileData._();
  static TileData getDefault() => _defaultInstance ??= TileData._();
  static TileData? _defaultInstance;

  @$pb.TagNumber(1)
  String get tilesetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tilesetId(String v) => $_setString(0, v);

  @$pb.TagNumber(2)
  int get z => $_getIZ(1);
  @$pb.TagNumber(2)
  set z(int v) => $_setSignedInt32(1, v);

  @$pb.TagNumber(3)
  int get x => $_getIZ(2);
  @$pb.TagNumber(3)
  set x(int v) => $_setSignedInt32(2, v);

  @$pb.TagNumber(4)
  int get y => $_getIZ(3);
  @$pb.TagNumber(4)
  set y(int v) => $_setSignedInt32(3, v);

  @$pb.TagNumber(5)
  List<int> get data => $_getN(4);
  @$pb.TagNumber(5)
  set data(List<int> v) => setField(5, v);

  @$pb.TagNumber(6)
  String get contentType => $_getSZ(5);
  @$pb.TagNumber(6)
  set contentType(String v) => $_setString(5, v);
}
