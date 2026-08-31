import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../tiles/tile_manager.dart';
import 'offline_region.dart';

/// Callback for download progress updates.
typedef DownloadProgressCallback = void Function(
  String regionId,
  int downloadedTiles,
  int totalTiles,
  double progress,
);

/// Manages offline tile storage, downloading, and serving.
///
/// [OfflineTileManager] downloads tile images for specified geographic
/// regions and stores them in a local SQLite database. When offline,
/// tiles are served from the local cache.
///
/// Usage:
/// ```dart
/// final offlineManager = OfflineTileManager();
/// await offlineManager.initialize();
///
/// final region = OfflineRegion(
///   id: 'farm_region_1',
///   name: 'North Farm',
///   bounds: LatLngBounds(...),
///   minZoom: 10,
///   maxZoom: 18,
///   styleUrl: 'https://...',
///   createdAt: DateTime.now(),
/// );
///
/// await offlineManager.downloadRegion(
///   region: region,
///   tileConfig: tileSourceConfig,
///   onProgress: (id, downloaded, total, progress) {
///     print('$downloaded / $total (${(progress * 100).toStringAsFixed(1)}%)');
///   },
/// );
/// ```
class OfflineTileManager {
  static const String _dbName = 'offline_tiles.db';
  static const String _tilesTable = 'tiles';
  static const String _regionsTable = 'regions';

  Database? _db;
  final Map<String, OfflineRegion> _regions = {};
  bool _initialized = false;

  /// Maximum storage quota in bytes (default 500 MB).
  int maxStorageBytes;

  /// The HTTP client used for downloading tiles.
  final http.Client _httpClient;

  /// Whether a download is currently in progress.
  bool _isDownloading = false;

  /// The region ID currently being downloaded, if any.
  String? _activeDownloadRegionId;

  /// Cancellation token for the active download.
  bool _cancelRequested = false;

  final StreamController<OfflineRegion> _regionUpdateController =
      StreamController<OfflineRegion>.broadcast();

  /// Creates a new [OfflineTileManager].
  OfflineTileManager({
    this.maxStorageBytes = 500 * 1024 * 1024,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Whether the manager has been initialized.
  bool get isInitialized => _initialized;

  /// Whether a download is currently active.
  bool get isDownloading => _isDownloading;

  /// The region ID currently being downloaded.
  String? get activeDownloadRegionId => _activeDownloadRegionId;

  /// A stream of region updates (progress, status changes).
  Stream<OfflineRegion> get regionUpdates => _regionUpdateController.stream;

  /// All registered offline regions.
  Map<String, OfflineRegion> get regions => Map.unmodifiable(_regions);

  /// Initializes the offline tile database.
  Future<void> initialize() async {
    if (_initialized) return;

    final directory = await getApplicationDocumentsDirectory();
    final dbPath = p.join(directory.path, _dbName);

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tilesTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            region_id TEXT NOT NULL,
            source_id TEXT NOT NULL,
            z INTEGER NOT NULL,
            x INTEGER NOT NULL,
            y INTEGER NOT NULL,
            data BLOB NOT NULL,
            size INTEGER NOT NULL,
            created_at TEXT NOT NULL,
            UNIQUE(source_id, z, x, y)
          )
        ''');

        await db.execute('''
          CREATE TABLE $_regionsTable (
            id TEXT PRIMARY KEY,
            data TEXT NOT NULL
          )
        ''');

        await db.execute(
          'CREATE INDEX idx_tiles_region ON $_tilesTable(region_id)',
        );
        await db.execute(
          'CREATE INDEX idx_tiles_coords ON $_tilesTable(source_id, z, x, y)',
        );
      },
    );

    // Load saved regions.
    await _loadRegions();
    _initialized = true;
  }

  /// Downloads tiles for the given [region] using the specified [tileConfig].
  ///
  /// [onProgress] is called with download progress updates.
  /// [concurrency] controls the number of parallel tile downloads.
  ///
  /// Returns the updated [OfflineRegion] with final status.
  Future<OfflineRegion> downloadRegion({
    required OfflineRegion region,
    required TileSourceConfig tileConfig,
    DownloadProgressCallback? onProgress,
    int concurrency = 4,
  }) async {
    _ensureInitialized();

    if (_isDownloading) {
      throw StateError(
        'A download is already in progress for region: $_activeDownloadRegionId',
      );
    }

    // Check storage quota.
    final currentStorage = await getTotalStorageBytes();
    final estimatedSize = OfflineRegion.estimateStorageBytes(
      OfflineRegion.estimateTileCount(
        bounds: region.bounds,
        minZoom: region.minZoom,
        maxZoom: region.maxZoom,
      ),
    );

    if (currentStorage + estimatedSize > maxStorageBytes) {
      throw StateError(
        'Insufficient storage. Current: ${currentStorage ~/ (1024 * 1024)} MB, '
        'Estimated: ${estimatedSize ~/ (1024 * 1024)} MB, '
        'Quota: ${maxStorageBytes ~/ (1024 * 1024)} MB',
      );
    }

    _isDownloading = true;
    _activeDownloadRegionId = region.id;
    _cancelRequested = false;

    // Calculate total tiles.
    final totalTiles = OfflineRegion.estimateTileCount(
      bounds: region.bounds,
      minZoom: region.minZoom,
      maxZoom: region.maxZoom,
    );

    var currentRegion = region.copyWith(
      status: OfflineRegionStatus.downloading,
      totalTiles: totalTiles,
      downloadedTiles: 0,
      progress: 0.0,
    );

    _regions[region.id] = currentRegion;
    await _saveRegion(currentRegion);
    _emitRegionUpdate(currentRegion);

    int downloadedCount = 0;
    int totalBytes = 0;

    try {
      // Generate all tile coordinates.
      final tileCoords = _generateTileCoordinates(
        region.bounds,
        region.minZoom.floor(),
        region.maxZoom.floor(),
      );

      // Download tiles in batches.
      for (int i = 0; i < tileCoords.length; i += concurrency) {
        if (_cancelRequested) {
          currentRegion = currentRegion.copyWith(
            status: OfflineRegionStatus.paused,
            updatedAt: DateTime.now(),
          );
          break;
        }

        final batch = tileCoords.skip(i).take(concurrency).toList();

        final futures = batch.map((coord) async {
          final url = tileConfig.resolveUrl(coord.z, coord.x, coord.y);
          try {
            final response = await _httpClient.get(
              Uri.parse(url),
              headers: tileConfig.headers.isNotEmpty
                  ? tileConfig.headers
                  : null,
            );

            if (response.statusCode == 200) {
              final tileData = response.bodyBytes;
              await _storeTile(
                regionId: region.id,
                sourceId: tileConfig.sourceId,
                z: coord.z,
                x: coord.x,
                y: coord.y,
                data: tileData,
              );
              return tileData.length;
            }
          } catch (_) {
            // Skip failed tiles.
          }
          return 0;
        });

        final results = await Future.wait(futures);
        for (final size in results) {
          if (size > 0) {
            downloadedCount++;
            totalBytes += size;
          }
        }

        final progress =
            totalTiles > 0 ? downloadedCount / totalTiles : 0.0;

        currentRegion = currentRegion.copyWith(
          downloadedTiles: downloadedCount,
          progress: progress,
          storageSizeBytes: totalBytes,
          updatedAt: DateTime.now(),
        );

        _regions[region.id] = currentRegion;
        _emitRegionUpdate(currentRegion);

        onProgress?.call(
          region.id,
          downloadedCount,
          totalTiles,
          progress,
        );
      }

      if (!_cancelRequested) {
        currentRegion = currentRegion.copyWith(
          status: OfflineRegionStatus.complete,
          progress: 1.0,
          downloadedTiles: downloadedCount,
          storageSizeBytes: totalBytes,
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      currentRegion = currentRegion.copyWith(
        status: OfflineRegionStatus.failed,
        updatedAt: DateTime.now(),
      );
    } finally {
      _isDownloading = false;
      _activeDownloadRegionId = null;

      _regions[region.id] = currentRegion;
      await _saveRegion(currentRegion);
      _emitRegionUpdate(currentRegion);
    }

    return currentRegion;
  }

  /// Cancels the active download.
  void cancelDownload() {
    _cancelRequested = true;
  }

  /// Retrieves a cached tile by its coordinates.
  ///
  /// Returns the tile data as bytes, or `null` if not cached.
  Future<Uint8List?> getTile({
    required String sourceId,
    required int z,
    required int x,
    required int y,
  }) async {
    _ensureInitialized();

    final results = await _db!.query(
      _tilesTable,
      columns: ['data'],
      where: 'source_id = ? AND z = ? AND x = ? AND y = ?',
      whereArgs: [sourceId, z, x, y],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return results.first['data'] as Uint8List;
  }

  /// Deletes an offline region and all its associated tiles.
  Future<void> deleteRegion(String regionId) async {
    _ensureInitialized();

    if (_activeDownloadRegionId == regionId) {
      cancelDownload();
      // Wait briefly for the download loop to notice the cancellation.
      await Future.delayed(const Duration(milliseconds: 200));
    }

    await _db!.delete(
      _tilesTable,
      where: 'region_id = ?',
      whereArgs: [regionId],
    );

    await _db!.delete(
      _regionsTable,
      where: 'id = ?',
      whereArgs: [regionId],
    );

    final removed = _regions.remove(regionId);
    if (removed != null) {
      _emitRegionUpdate(removed.copyWith(
        status: OfflineRegionStatus.deleting,
      ));
    }
  }

  /// Returns the total storage used by all offline tiles in bytes.
  Future<int> getTotalStorageBytes() async {
    _ensureInitialized();

    final result = await _db!.rawQuery(
      'SELECT COALESCE(SUM(size), 0) as total FROM $_tilesTable',
    );

    return (result.first['total'] as num?)?.toInt() ?? 0;
  }

  /// Returns the storage used by a specific region in bytes.
  Future<int> getRegionStorageBytes(String regionId) async {
    _ensureInitialized();

    final result = await _db!.rawQuery(
      'SELECT COALESCE(SUM(size), 0) as total FROM $_tilesTable WHERE region_id = ?',
      [regionId],
    );

    return (result.first['total'] as num?)?.toInt() ?? 0;
  }

  /// Returns the total number of cached tiles.
  Future<int> getTotalTileCount() async {
    _ensureInitialized();

    final result = await _db!.rawQuery(
      'SELECT COUNT(*) as count FROM $_tilesTable',
    );

    return (result.first['count'] as num?)?.toInt() ?? 0;
  }

  /// Clears all cached tiles and regions.
  Future<void> clearAll() async {
    _ensureInitialized();

    await _db!.delete(_tilesTable);
    await _db!.delete(_regionsTable);
    _regions.clear();
  }

  /// Closes the database and releases resources.
  Future<void> dispose() async {
    _cancelRequested = true;
    _regionUpdateController.close();
    await _db?.close();
    _db = null;
    _initialized = false;
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  void _ensureInitialized() {
    if (!_initialized || _db == null) {
      throw StateError(
        'OfflineTileManager has not been initialized. Call initialize() first.',
      );
    }
  }

  Future<void> _storeTile({
    required String regionId,
    required String sourceId,
    required int z,
    required int x,
    required int y,
    required Uint8List data,
  }) async {
    await _db!.insert(
      _tilesTable,
      {
        'region_id': regionId,
        'source_id': sourceId,
        'z': z,
        'x': x,
        'y': y,
        'data': data,
        'size': data.length,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _saveRegion(OfflineRegion region) async {
    final jsonStr = json.encode(region.toJson());
    await _db!.insert(
      _regionsTable,
      {'id': region.id, 'data': jsonStr},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _loadRegions() async {
    final results = await _db!.query(_regionsTable);
    for (final row in results) {
      try {
        final data = row['data'] as String;
        final jsonMap = json.decode(data) as Map<String, dynamic>;
        final region = OfflineRegion.fromJson(jsonMap);
        _regions[region.id] = region;
      } catch (_) {
        // Skip corrupted entries.
      }
    }
  }

  List<_TileCoordinate> _generateTileCoordinates(
    LatLngBounds bounds,
    int minZoom,
    int maxZoom,
  ) {
    final coords = <_TileCoordinate>[];

    for (int z = minZoom; z <= maxZoom; z++) {
      final minTileX = _lngToTileX(bounds.southwest.longitude, z);
      final maxTileX = _lngToTileX(bounds.northeast.longitude, z);
      final minTileY = _latToTileY(bounds.northeast.latitude, z);
      final maxTileY = _latToTileY(bounds.southwest.latitude, z);

      for (int x = minTileX; x <= maxTileX; x++) {
        for (int y = minTileY; y <= maxTileY; y++) {
          coords.add(_TileCoordinate(z: z, x: x, y: y));
        }
      }
    }

    return coords;
  }

  static int _lngToTileX(double lng, int zoom) {
    return ((lng + 180.0) / 360.0 * (1 << zoom)).floor();
  }

  static int _latToTileY(double lat, int zoom) {
    final latRad = lat * pi / 180.0;
    final n = 1 << zoom;
    return ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n)
        .floor();
  }

  void _emitRegionUpdate(OfflineRegion region) {
    if (!_regionUpdateController.isClosed) {
      _regionUpdateController.add(region);
    }
  }
}

/// Internal tile coordinate representation.
class _TileCoordinate {
  final int z;
  final int x;
  final int y;

  const _TileCoordinate({
    required this.z,
    required this.x,
    required this.y,
  });
}
