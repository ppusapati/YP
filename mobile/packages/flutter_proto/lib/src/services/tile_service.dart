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
      'agriculture.satellite.tile.v1.SatelliteTileService';

  /// Generates a new tileset from a processing job.
  Future<GenerateTilesetResponse> generateTileset(
      GenerateTilesetRequest request) async {
    final bytes = await callUnary('GenerateTileset', request);
    return GenerateTilesetResponse.fromBuffer(bytes);
  }

  /// Retrieves a tileset by ID.
  Future<GetTilesetResponse> getTileset(String id) async {
    final request = GetTilesetRequest(id: id);
    final bytes = await callUnary('GetTileset', request);
    return GetTilesetResponse.fromBuffer(bytes);
  }

  /// Lists available tilesets.
  Future<ListTilesetsResponse> listTilesets({
    int pageSize = 20,
    String pageToken = '',
  }) async {
    final request = ListTilesetsRequest(
      pageSize: pageSize,
      pageToken: pageToken,
    );
    final bytes = await callUnary('ListTilesets', request);
    return ListTilesetsResponse.fromBuffer(bytes);
  }

  /// Retrieves tile data for a specific tile.
  Future<GetTileResponse> getTile(GetTileRequest request) async {
    final bytes = await callUnary('GetTile', request);
    return GetTileResponse.fromBuffer(bytes);
  }

  /// Deletes a tileset by ID.
  Future<void> deleteTileset(String id) async {
    final request = DeleteTilesetRequest(id: id);
    await callUnary('DeleteTileset', request);
  }
}
