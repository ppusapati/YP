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

import 'package:protobuf/protobuf.dart' as $pb;

import 'tile.pb.dart' as $1;
import 'tile.pbjson.dart';

export 'tile.pb.dart';

abstract class SatelliteTileServiceBase extends $pb.GeneratedService {
  $async.Future<$1.GenerateTilesetResponse> generateTileset(
      $pb.ServerContext ctx, $1.GenerateTilesetRequest request);
  $async.Future<$1.GetTilesetResponse> getTileset(
      $pb.ServerContext ctx, $1.GetTilesetRequest request);
  $async.Future<$1.ListTilesetsResponse> listTilesets(
      $pb.ServerContext ctx, $1.ListTilesetsRequest request);
  $async.Future<$1.GetTileResponse> getTile(
      $pb.ServerContext ctx, $1.GetTileRequest request);
  $async.Future<$1.DeleteTilesetResponse> deleteTileset(
      $pb.ServerContext ctx, $1.DeleteTilesetRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GenerateTileset':
        return $1.GenerateTilesetRequest();
      case 'GetTileset':
        return $1.GetTilesetRequest();
      case 'ListTilesets':
        return $1.ListTilesetsRequest();
      case 'GetTile':
        return $1.GetTileRequest();
      case 'DeleteTileset':
        return $1.DeleteTilesetRequest();
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx,
      $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GenerateTileset':
        return generateTileset(ctx, request as $1.GenerateTilesetRequest);
      case 'GetTileset':
        return getTileset(ctx, request as $1.GetTilesetRequest);
      case 'ListTilesets':
        return listTilesets(ctx, request as $1.ListTilesetsRequest);
      case 'GetTile':
        return getTile(ctx, request as $1.GetTileRequest);
      case 'DeleteTileset':
        return deleteTileset(ctx, request as $1.DeleteTilesetRequest);
      default:
        throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json =>
      SatelliteTileServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>>
      get $messageJson => SatelliteTileServiceBase$messageJson;
}
