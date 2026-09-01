// This is a generated file - do not edit.
//
// Generated from tile.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart'
    as $0;

import 'tile.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'tile.pbenum.dart';

class Tileset extends $pb.GeneratedMessage {
  factory Tileset({
    $core.String? id,
    $core.String? tenantId,
    $core.String? farmId,
    $core.String? processingJobId,
    TileLayer? layer,
    TileFormat? format,
    TilesetStatus? status,
    $core.int? minZoom,
    $core.int? maxZoom,
    $core.String? s3Prefix,
    $fixnum.Int64? totalTiles,
    $core.String? bboxGeojson,
    $core.String? errorMessage,
    $0.Timestamp? acquisitionDate,
    $0.Timestamp? createdAt,
    $0.Timestamp? completedAt,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (tenantId != null) result.tenantId = tenantId;
    if (farmId != null) result.farmId = farmId;
    if (processingJobId != null) result.processingJobId = processingJobId;
    if (layer != null) result.layer = layer;
    if (format != null) result.format = format;
    if (status != null) result.status = status;
    if (minZoom != null) result.minZoom = minZoom;
    if (maxZoom != null) result.maxZoom = maxZoom;
    if (s3Prefix != null) result.s3Prefix = s3Prefix;
    if (totalTiles != null) result.totalTiles = totalTiles;
    if (bboxGeojson != null) result.bboxGeojson = bboxGeojson;
    if (errorMessage != null) result.errorMessage = errorMessage;
    if (acquisitionDate != null) result.acquisitionDate = acquisitionDate;
    if (createdAt != null) result.createdAt = createdAt;
    if (completedAt != null) result.completedAt = completedAt;
    return result;
  }

  Tileset._();

  factory Tileset.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Tileset.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Tileset',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.tile.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'tenantId')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aOS(4, _omitFieldNames ? '' : 'processingJobId')
    ..aE<TileLayer>(5, _omitFieldNames ? '' : 'layer',
        enumValues: TileLayer.values)
    ..aE<TileFormat>(6, _omitFieldNames ? '' : 'format',
        enumValues: TileFormat.values)
    ..aE<TilesetStatus>(7, _omitFieldNames ? '' : 'status',
        enumValues: TilesetStatus.values)
    ..aI(8, _omitFieldNames ? '' : 'minZoom')
    ..aI(9, _omitFieldNames ? '' : 'maxZoom')
    ..aOS(10, _omitFieldNames ? '' : 's3Prefix')
    ..aInt64(11, _omitFieldNames ? '' : 'totalTiles')
    ..aOS(12, _omitFieldNames ? '' : 'bboxGeojson')
    ..aOS(13, _omitFieldNames ? '' : 'errorMessage')
    ..aOM<$0.Timestamp>(14, _omitFieldNames ? '' : 'acquisitionDate',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(15, _omitFieldNames ? '' : 'createdAt',
        subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(16, _omitFieldNames ? '' : 'completedAt',
        subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tileset clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Tileset copyWith(void Function(Tileset) updates) =>
      super.copyWith((message) => updates(message as Tileset)) as Tileset;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Tileset create() => Tileset._();
  @$core.override
  Tileset createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Tileset getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Tileset>(create);
  static Tileset? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get tenantId => $_getSZ(1);
  @$pb.TagNumber(2)
  set tenantId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTenantId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTenantId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get processingJobId => $_getSZ(3);
  @$pb.TagNumber(4)
  set processingJobId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasProcessingJobId() => $_has(3);
  @$pb.TagNumber(4)
  void clearProcessingJobId() => $_clearField(4);

  @$pb.TagNumber(5)
  TileLayer get layer => $_getN(4);
  @$pb.TagNumber(5)
  set layer(TileLayer value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasLayer() => $_has(4);
  @$pb.TagNumber(5)
  void clearLayer() => $_clearField(5);

  @$pb.TagNumber(6)
  TileFormat get format => $_getN(5);
  @$pb.TagNumber(6)
  set format(TileFormat value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasFormat() => $_has(5);
  @$pb.TagNumber(6)
  void clearFormat() => $_clearField(6);

  @$pb.TagNumber(7)
  TilesetStatus get status => $_getN(6);
  @$pb.TagNumber(7)
  set status(TilesetStatus value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get minZoom => $_getIZ(7);
  @$pb.TagNumber(8)
  set minZoom($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMinZoom() => $_has(7);
  @$pb.TagNumber(8)
  void clearMinZoom() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get maxZoom => $_getIZ(8);
  @$pb.TagNumber(9)
  set maxZoom($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMaxZoom() => $_has(8);
  @$pb.TagNumber(9)
  void clearMaxZoom() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get s3Prefix => $_getSZ(9);
  @$pb.TagNumber(10)
  set s3Prefix($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasS3Prefix() => $_has(9);
  @$pb.TagNumber(10)
  void clearS3Prefix() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get totalTiles => $_getI64(10);
  @$pb.TagNumber(11)
  set totalTiles($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasTotalTiles() => $_has(10);
  @$pb.TagNumber(11)
  void clearTotalTiles() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get bboxGeojson => $_getSZ(11);
  @$pb.TagNumber(12)
  set bboxGeojson($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasBboxGeojson() => $_has(11);
  @$pb.TagNumber(12)
  void clearBboxGeojson() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get errorMessage => $_getSZ(12);
  @$pb.TagNumber(13)
  set errorMessage($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasErrorMessage() => $_has(12);
  @$pb.TagNumber(13)
  void clearErrorMessage() => $_clearField(13);

  @$pb.TagNumber(14)
  $0.Timestamp get acquisitionDate => $_getN(13);
  @$pb.TagNumber(14)
  set acquisitionDate($0.Timestamp value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasAcquisitionDate() => $_has(13);
  @$pb.TagNumber(14)
  void clearAcquisitionDate() => $_clearField(14);
  @$pb.TagNumber(14)
  $0.Timestamp ensureAcquisitionDate() => $_ensure(13);

  @$pb.TagNumber(15)
  $0.Timestamp get createdAt => $_getN(14);
  @$pb.TagNumber(15)
  set createdAt($0.Timestamp value) => $_setField(15, value);
  @$pb.TagNumber(15)
  $core.bool hasCreatedAt() => $_has(14);
  @$pb.TagNumber(15)
  void clearCreatedAt() => $_clearField(15);
  @$pb.TagNumber(15)
  $0.Timestamp ensureCreatedAt() => $_ensure(14);

  @$pb.TagNumber(16)
  $0.Timestamp get completedAt => $_getN(15);
  @$pb.TagNumber(16)
  set completedAt($0.Timestamp value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasCompletedAt() => $_has(15);
  @$pb.TagNumber(16)
  void clearCompletedAt() => $_clearField(16);
  @$pb.TagNumber(16)
  $0.Timestamp ensureCompletedAt() => $_ensure(15);
}

class GenerateTilesetRequest extends $pb.GeneratedMessage {
  factory GenerateTilesetRequest({
    $core.String? processingJobId,
    $core.String? farmId,
    TileLayer? layer,
    TileFormat? format,
    $core.int? minZoom,
    $core.int? maxZoom,
  }) {
    final result = create();
    if (processingJobId != null) result.processingJobId = processingJobId;
    if (farmId != null) result.farmId = farmId;
    if (layer != null) result.layer = layer;
    if (format != null) result.format = format;
    if (minZoom != null) result.minZoom = minZoom;
    if (maxZoom != null) result.maxZoom = maxZoom;
    return result;
  }

  GenerateTilesetRequest._();

  factory GenerateTilesetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateTilesetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateTilesetRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.tile.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'processingJobId')
    ..aOS(2, _omitFieldNames ? '' : 'farmId')
    ..aE<TileLayer>(3, _omitFieldNames ? '' : 'layer',
        enumValues: TileLayer.values)
    ..aE<TileFormat>(4, _omitFieldNames ? '' : 'format',
        enumValues: TileFormat.values)
    ..aI(5, _omitFieldNames ? '' : 'minZoom')
    ..aI(6, _omitFieldNames ? '' : 'maxZoom')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateTilesetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateTilesetRequest copyWith(
          void Function(GenerateTilesetRequest) updates) =>
      super.copyWith((message) => updates(message as GenerateTilesetRequest))
          as GenerateTilesetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateTilesetRequest create() => GenerateTilesetRequest._();
  @$core.override
  GenerateTilesetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateTilesetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateTilesetRequest>(create);
  static GenerateTilesetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get processingJobId => $_getSZ(0);
  @$pb.TagNumber(1)
  set processingJobId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProcessingJobId() => $_has(0);
  @$pb.TagNumber(1)
  void clearProcessingJobId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get farmId => $_getSZ(1);
  @$pb.TagNumber(2)
  set farmId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFarmId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFarmId() => $_clearField(2);

  @$pb.TagNumber(3)
  TileLayer get layer => $_getN(2);
  @$pb.TagNumber(3)
  set layer(TileLayer value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasLayer() => $_has(2);
  @$pb.TagNumber(3)
  void clearLayer() => $_clearField(3);

  @$pb.TagNumber(4)
  TileFormat get format => $_getN(3);
  @$pb.TagNumber(4)
  set format(TileFormat value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasFormat() => $_has(3);
  @$pb.TagNumber(4)
  void clearFormat() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get minZoom => $_getIZ(4);
  @$pb.TagNumber(5)
  set minZoom($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMinZoom() => $_has(4);
  @$pb.TagNumber(5)
  void clearMinZoom() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get maxZoom => $_getIZ(5);
  @$pb.TagNumber(6)
  set maxZoom($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMaxZoom() => $_has(5);
  @$pb.TagNumber(6)
  void clearMaxZoom() => $_clearField(6);
}

class GenerateTilesetResponse extends $pb.GeneratedMessage {
  factory GenerateTilesetResponse({
    Tileset? tileset,
  }) {
    final result = create();
    if (tileset != null) result.tileset = tileset;
    return result;
  }

  GenerateTilesetResponse._();

  factory GenerateTilesetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GenerateTilesetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GenerateTilesetResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.tile.v1'),
      createEmptyInstance: create)
    ..aOM<Tileset>(1, _omitFieldNames ? '' : 'tileset',
        subBuilder: Tileset.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateTilesetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateTilesetResponse copyWith(
          void Function(GenerateTilesetResponse) updates) =>
      super.copyWith((message) => updates(message as GenerateTilesetResponse))
          as GenerateTilesetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateTilesetResponse create() => GenerateTilesetResponse._();
  @$core.override
  GenerateTilesetResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GenerateTilesetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateTilesetResponse>(create);
  static GenerateTilesetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Tileset get tileset => $_getN(0);
  @$pb.TagNumber(1)
  set tileset(Tileset value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTileset() => $_has(0);
  @$pb.TagNumber(1)
  void clearTileset() => $_clearField(1);
  @$pb.TagNumber(1)
  Tileset ensureTileset() => $_ensure(0);
}

class GetTilesetRequest extends $pb.GeneratedMessage {
  factory GetTilesetRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  GetTilesetRequest._();

  factory GetTilesetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTilesetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTilesetRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.tile.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTilesetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTilesetRequest copyWith(void Function(GetTilesetRequest) updates) =>
      super.copyWith((message) => updates(message as GetTilesetRequest))
          as GetTilesetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTilesetRequest create() => GetTilesetRequest._();
  @$core.override
  GetTilesetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTilesetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTilesetRequest>(create);
  static GetTilesetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetTilesetResponse extends $pb.GeneratedMessage {
  factory GetTilesetResponse({
    Tileset? tileset,
  }) {
    final result = create();
    if (tileset != null) result.tileset = tileset;
    return result;
  }

  GetTilesetResponse._();

  factory GetTilesetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTilesetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTilesetResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.tile.v1'),
      createEmptyInstance: create)
    ..aOM<Tileset>(1, _omitFieldNames ? '' : 'tileset',
        subBuilder: Tileset.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTilesetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTilesetResponse copyWith(void Function(GetTilesetResponse) updates) =>
      super.copyWith((message) => updates(message as GetTilesetResponse))
          as GetTilesetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTilesetResponse create() => GetTilesetResponse._();
  @$core.override
  GetTilesetResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTilesetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTilesetResponse>(create);
  static GetTilesetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Tileset get tileset => $_getN(0);
  @$pb.TagNumber(1)
  set tileset(Tileset value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTileset() => $_has(0);
  @$pb.TagNumber(1)
  void clearTileset() => $_clearField(1);
  @$pb.TagNumber(1)
  Tileset ensureTileset() => $_ensure(0);
}

class ListTilesetsRequest extends $pb.GeneratedMessage {
  factory ListTilesetsRequest({
    $core.int? pageSize,
    $core.String? pageToken,
    $core.String? farmId,
    TileLayer? layer,
    TilesetStatus? status,
  }) {
    final result = create();
    if (pageSize != null) result.pageSize = pageSize;
    if (pageToken != null) result.pageToken = pageToken;
    if (farmId != null) result.farmId = farmId;
    if (layer != null) result.layer = layer;
    if (status != null) result.status = status;
    return result;
  }

  ListTilesetsRequest._();

  factory ListTilesetsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTilesetsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTilesetsRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.tile.v1'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'pageSize')
    ..aOS(2, _omitFieldNames ? '' : 'pageToken')
    ..aOS(3, _omitFieldNames ? '' : 'farmId')
    ..aE<TileLayer>(4, _omitFieldNames ? '' : 'layer',
        enumValues: TileLayer.values)
    ..aE<TilesetStatus>(5, _omitFieldNames ? '' : 'status',
        enumValues: TilesetStatus.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTilesetsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTilesetsRequest copyWith(void Function(ListTilesetsRequest) updates) =>
      super.copyWith((message) => updates(message as ListTilesetsRequest))
          as ListTilesetsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTilesetsRequest create() => ListTilesetsRequest._();
  @$core.override
  ListTilesetsRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTilesetsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTilesetsRequest>(create);
  static ListTilesetsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get pageSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set pageSize($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPageSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearPageSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get pageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set pageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get farmId => $_getSZ(2);
  @$pb.TagNumber(3)
  set farmId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFarmId() => $_has(2);
  @$pb.TagNumber(3)
  void clearFarmId() => $_clearField(3);

  @$pb.TagNumber(4)
  TileLayer get layer => $_getN(3);
  @$pb.TagNumber(4)
  set layer(TileLayer value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasLayer() => $_has(3);
  @$pb.TagNumber(4)
  void clearLayer() => $_clearField(4);

  @$pb.TagNumber(5)
  TilesetStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(TilesetStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);
}

class ListTilesetsResponse extends $pb.GeneratedMessage {
  factory ListTilesetsResponse({
    $core.Iterable<Tileset>? tilesets,
    $core.String? nextPageToken,
    $core.int? totalCount,
  }) {
    final result = create();
    if (tilesets != null) result.tilesets.addAll(tilesets);
    if (nextPageToken != null) result.nextPageToken = nextPageToken;
    if (totalCount != null) result.totalCount = totalCount;
    return result;
  }

  ListTilesetsResponse._();

  factory ListTilesetsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ListTilesetsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ListTilesetsResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.tile.v1'),
      createEmptyInstance: create)
    ..pPM<Tileset>(1, _omitFieldNames ? '' : 'tilesets',
        subBuilder: Tileset.create)
    ..aOS(2, _omitFieldNames ? '' : 'nextPageToken')
    ..aI(3, _omitFieldNames ? '' : 'totalCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTilesetsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTilesetsResponse copyWith(void Function(ListTilesetsResponse) updates) =>
      super.copyWith((message) => updates(message as ListTilesetsResponse))
          as ListTilesetsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTilesetsResponse create() => ListTilesetsResponse._();
  @$core.override
  ListTilesetsResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ListTilesetsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTilesetsResponse>(create);
  static ListTilesetsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Tileset> get tilesets => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get nextPageToken => $_getSZ(1);
  @$pb.TagNumber(2)
  set nextPageToken($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNextPageToken() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextPageToken() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get totalCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set totalCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalCount() => $_clearField(3);
}

class GetTileRequest extends $pb.GeneratedMessage {
  factory GetTileRequest({
    $core.String? tilesetId,
    $core.int? z,
    $core.int? x,
    $core.int? y,
  }) {
    final result = create();
    if (tilesetId != null) result.tilesetId = tilesetId;
    if (z != null) result.z = z;
    if (x != null) result.x = x;
    if (y != null) result.y = y;
    return result;
  }

  GetTileRequest._();

  factory GetTileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTileRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTileRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.tile.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'tilesetId')
    ..aI(2, _omitFieldNames ? '' : 'z')
    ..aI(3, _omitFieldNames ? '' : 'x')
    ..aI(4, _omitFieldNames ? '' : 'y')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTileRequest copyWith(void Function(GetTileRequest) updates) =>
      super.copyWith((message) => updates(message as GetTileRequest))
          as GetTileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTileRequest create() => GetTileRequest._();
  @$core.override
  GetTileRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTileRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTileRequest>(create);
  static GetTileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get tilesetId => $_getSZ(0);
  @$pb.TagNumber(1)
  set tilesetId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTilesetId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTilesetId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get z => $_getIZ(1);
  @$pb.TagNumber(2)
  set z($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasZ() => $_has(1);
  @$pb.TagNumber(2)
  void clearZ() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get x => $_getIZ(2);
  @$pb.TagNumber(3)
  set x($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasX() => $_has(2);
  @$pb.TagNumber(3)
  void clearX() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get y => $_getIZ(3);
  @$pb.TagNumber(4)
  set y($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasY() => $_has(3);
  @$pb.TagNumber(4)
  void clearY() => $_clearField(4);
}

class GetTileResponse extends $pb.GeneratedMessage {
  factory GetTileResponse({
    $core.List<$core.int>? tileData,
    $core.String? contentType,
  }) {
    final result = create();
    if (tileData != null) result.tileData = tileData;
    if (contentType != null) result.contentType = contentType;
    return result;
  }

  GetTileResponse._();

  factory GetTileResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GetTileResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetTileResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.tile.v1'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'tileData', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'contentType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTileResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTileResponse copyWith(void Function(GetTileResponse) updates) =>
      super.copyWith((message) => updates(message as GetTileResponse))
          as GetTileResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTileResponse create() => GetTileResponse._();
  @$core.override
  GetTileResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GetTileResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTileResponse>(create);
  static GetTileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get tileData => $_getN(0);
  @$pb.TagNumber(1)
  set tileData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTileData() => $_has(0);
  @$pb.TagNumber(1)
  void clearTileData() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get contentType => $_getSZ(1);
  @$pb.TagNumber(2)
  set contentType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContentType() => $_has(1);
  @$pb.TagNumber(2)
  void clearContentType() => $_clearField(2);
}

class DeleteTilesetRequest extends $pb.GeneratedMessage {
  factory DeleteTilesetRequest({
    $core.String? id,
  }) {
    final result = create();
    if (id != null) result.id = id;
    return result;
  }

  DeleteTilesetRequest._();

  factory DeleteTilesetRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTilesetRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTilesetRequest',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.tile.v1'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTilesetRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTilesetRequest copyWith(void Function(DeleteTilesetRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteTilesetRequest))
          as DeleteTilesetRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTilesetRequest create() => DeleteTilesetRequest._();
  @$core.override
  DeleteTilesetRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTilesetRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTilesetRequest>(create);
  static DeleteTilesetRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class DeleteTilesetResponse extends $pb.GeneratedMessage {
  factory DeleteTilesetResponse({
    $core.bool? success,
  }) {
    final result = create();
    if (success != null) result.success = success;
    return result;
  }

  DeleteTilesetResponse._();

  factory DeleteTilesetResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DeleteTilesetResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DeleteTilesetResponse',
      package: const $pb.PackageName(
          _omitMessageNames ? '' : 'agriculture.satellite.tile.v1'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTilesetResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteTilesetResponse copyWith(
          void Function(DeleteTilesetResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteTilesetResponse))
          as DeleteTilesetResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteTilesetResponse create() => DeleteTilesetResponse._();
  @$core.override
  DeleteTilesetResponse createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DeleteTilesetResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteTilesetResponse>(create);
  static DeleteTilesetResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);
}

class SatelliteTileServiceApi {
  final $pb.RpcClient _client;

  SatelliteTileServiceApi(this._client);

  $async.Future<GenerateTilesetResponse> generateTileset(
          $pb.ClientContext? ctx, GenerateTilesetRequest request) =>
      _client.invoke<GenerateTilesetResponse>(ctx, 'SatelliteTileService',
          'GenerateTileset', request, GenerateTilesetResponse());
  $async.Future<GetTilesetResponse> getTileset(
          $pb.ClientContext? ctx, GetTilesetRequest request) =>
      _client.invoke<GetTilesetResponse>(ctx, 'SatelliteTileService',
          'GetTileset', request, GetTilesetResponse());
  $async.Future<ListTilesetsResponse> listTilesets(
          $pb.ClientContext? ctx, ListTilesetsRequest request) =>
      _client.invoke<ListTilesetsResponse>(ctx, 'SatelliteTileService',
          'ListTilesets', request, ListTilesetsResponse());
  $async.Future<GetTileResponse> getTile(
          $pb.ClientContext? ctx, GetTileRequest request) =>
      _client.invoke<GetTileResponse>(
          ctx, 'SatelliteTileService', 'GetTile', request, GetTileResponse());
  $async.Future<DeleteTilesetResponse> deleteTileset(
          $pb.ClientContext? ctx, DeleteTilesetRequest request) =>
      _client.invoke<DeleteTilesetResponse>(ctx, 'SatelliteTileService',
          'DeleteTileset', request, DeleteTilesetResponse());
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
