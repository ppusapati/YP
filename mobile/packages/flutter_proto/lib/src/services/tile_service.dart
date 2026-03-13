import 'package:http/http.dart' as http;

import '../generated/tile.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for satellite tile management.
///
/// Provides operations for generating, retrieving, and managing
/// map tilesets from processed satellite imagery.
class TileServiceClient extends BaseService {
  TileServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName =>
      'yieldpoint.satellite.tile.v1.SatelliteTileService';

  /// Generates a new tileset from a processing job.
  Future<Tileset> generateTileset(Tileset tileset) async {
    final bytes = await callUnary('GenerateTileset', tileset);
    return Tileset.fromBuffer(bytes);
  }

  /// Retrieves a tileset by ID.
  Future<Tileset> getTileset(String id) async {
    final request = Tileset(id: id);
    final bytes = await callUnary('GetTileset', request);
    return Tileset.fromBuffer(bytes);
  }

  /// Lists available tilesets.
  Future<List<Tileset>> listTilesets({int pageSize = 20}) async {
    final request = Tileset();
    final bytes = await callUnary('ListTilesets', request);
    final tileset = Tileset.fromBuffer(bytes);
    return [tileset];
  }

  /// Retrieves tile data for a specific tile.
  Future<TileData> getTile(TileRequest request) async {
    final bytes = await callUnary('GetTile', request);
    return TileData.fromBuffer(bytes);
  }

  /// Deletes a tileset by ID.
  Future<void> deleteTileset(String id) async {
    final request = Tileset(id: id);
    await callUnary('DeleteTileset', request);
  }
}
