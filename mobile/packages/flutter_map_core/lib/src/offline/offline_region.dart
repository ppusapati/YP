import 'dart:math';

import 'package:maplibre_gl/maplibre_gl.dart';

/// The download status of an offline region.
enum OfflineRegionStatus {
  /// The region has not been downloaded yet.
  pending,

  /// The region is currently being downloaded.
  downloading,

  /// The region has been fully downloaded and is available offline.
  complete,

  /// The download was paused.
  paused,

  /// The download failed.
  failed,

  /// The region is being deleted.
  deleting,
}

/// Represents a geographic region that can be downloaded for offline use.
///
/// An offline region is defined by a bounding box, zoom range, and
/// associated tile sources. It tracks download progress and storage usage.
class OfflineRegion {
  /// Unique identifier for this offline region.
  final String id;

  /// Human-readable name for the region.
  final String name;

  /// The bounding box defining the geographic extent of the region.
  final LatLngBounds bounds;

  /// The minimum zoom level to download.
  final double minZoom;

  /// The maximum zoom level to download.
  final double maxZoom;

  /// The map style URL associated with this region.
  final String styleUrl;

  /// The tile source IDs included in this offline region.
  final List<String> tileSourceIds;

  /// The current download status.
  final OfflineRegionStatus status;

  /// The download progress as a percentage (0.0 to 1.0).
  final double progress;

  /// The total number of tiles to download.
  final int totalTiles;

  /// The number of tiles downloaded so far.
  final int downloadedTiles;

  /// The total storage size in bytes used by this region.
  final int storageSizeBytes;

  /// The timestamp when this region was created.
  final DateTime createdAt;

  /// The timestamp of the last update to this region.
  final DateTime? updatedAt;

  /// Optional metadata for the region.
  final Map<String, dynamic> metadata;

  /// Creates a new [OfflineRegion].
  const OfflineRegion({
    required this.id,
    required this.name,
    required this.bounds,
    required this.minZoom,
    required this.maxZoom,
    required this.styleUrl,
    this.tileSourceIds = const [],
    this.status = OfflineRegionStatus.pending,
    this.progress = 0.0,
    this.totalTiles = 0,
    this.downloadedTiles = 0,
    this.storageSizeBytes = 0,
    required this.createdAt,
    this.updatedAt,
    this.metadata = const {},
  });

  /// The storage size in megabytes.
  double get storageSizeMb => storageSizeBytes / (1024 * 1024);

  /// Whether the region has been fully downloaded.
  bool get isComplete => status == OfflineRegionStatus.complete;

  /// Whether the region is currently downloading.
  bool get isDownloading => status == OfflineRegionStatus.downloading;

  /// Estimates the total number of tiles for the given bounds and zoom range.
  ///
  /// This is an approximation based on the tile grid.
  static int estimateTileCount({
    required LatLngBounds bounds,
    required double minZoom,
    required double maxZoom,
  }) {
    int totalTiles = 0;

    for (int z = minZoom.floor(); z <= maxZoom.floor(); z++) {
      final minTileX = _lngToTileX(bounds.southwest.longitude, z);
      final maxTileX = _lngToTileX(bounds.northeast.longitude, z);
      final minTileY = _latToTileY(bounds.northeast.latitude, z);
      final maxTileY = _latToTileY(bounds.southwest.latitude, z);

      final tilesX = (maxTileX - minTileX + 1).abs();
      final tilesY = (maxTileY - minTileY + 1).abs();
      totalTiles += tilesX * tilesY;
    }

    return totalTiles;
  }

  /// Estimates the storage size in bytes for the given tile count.
  ///
  /// Uses an average tile size estimate.
  static int estimateStorageBytes(int tileCount, {int avgTileSizeBytes = 15000}) {
    return tileCount * avgTileSizeBytes;
  }

  /// Creates a copy with updated fields.
  OfflineRegion copyWith({
    String? id,
    String? name,
    LatLngBounds? bounds,
    double? minZoom,
    double? maxZoom,
    String? styleUrl,
    List<String>? tileSourceIds,
    OfflineRegionStatus? status,
    double? progress,
    int? totalTiles,
    int? downloadedTiles,
    int? storageSizeBytes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return OfflineRegion(
      id: id ?? this.id,
      name: name ?? this.name,
      bounds: bounds ?? this.bounds,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      styleUrl: styleUrl ?? this.styleUrl,
      tileSourceIds: tileSourceIds ?? this.tileSourceIds,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      totalTiles: totalTiles ?? this.totalTiles,
      downloadedTiles: downloadedTiles ?? this.downloadedTiles,
      storageSizeBytes: storageSizeBytes ?? this.storageSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Serializes the region to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bounds': {
        'southwest': {
          'latitude': bounds.southwest.latitude,
          'longitude': bounds.southwest.longitude,
        },
        'northeast': {
          'latitude': bounds.northeast.latitude,
          'longitude': bounds.northeast.longitude,
        },
      },
      'minZoom': minZoom,
      'maxZoom': maxZoom,
      'styleUrl': styleUrl,
      'tileSourceIds': tileSourceIds,
      'status': status.name,
      'progress': progress,
      'totalTiles': totalTiles,
      'downloadedTiles': downloadedTiles,
      'storageSizeBytes': storageSizeBytes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Deserializes a region from a JSON-compatible map.
  factory OfflineRegion.fromJson(Map<String, dynamic> json) {
    final boundsJson = json['bounds'] as Map<String, dynamic>;
    final sw = boundsJson['southwest'] as Map<String, dynamic>;
    final ne = boundsJson['northeast'] as Map<String, dynamic>;

    return OfflineRegion(
      id: json['id'] as String,
      name: json['name'] as String,
      bounds: LatLngBounds(
        southwest: LatLng(
          (sw['latitude'] as num).toDouble(),
          (sw['longitude'] as num).toDouble(),
        ),
        northeast: LatLng(
          (ne['latitude'] as num).toDouble(),
          (ne['longitude'] as num).toDouble(),
        ),
      ),
      minZoom: (json['minZoom'] as num).toDouble(),
      maxZoom: (json['maxZoom'] as num).toDouble(),
      styleUrl: json['styleUrl'] as String,
      tileSourceIds: List<String>.from(json['tileSourceIds'] as List? ?? []),
      status: OfflineRegionStatus.values.byName(json['status'] as String),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      totalTiles: (json['totalTiles'] as num?)?.toInt() ?? 0,
      downloadedTiles: (json['downloadedTiles'] as num?)?.toInt() ?? 0,
      storageSizeBytes: (json['storageSizeBytes'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      metadata:
          Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  @override
  String toString() =>
      'OfflineRegion(id: $id, name: $name, status: ${status.name}, '
      'progress: ${(progress * 100).toStringAsFixed(1)}%)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OfflineRegion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // ---------------------------------------------------------------------------
  // Tile math helpers
  // ---------------------------------------------------------------------------

  static int _lngToTileX(double lng, int zoom) {
    return ((lng + 180.0) / 360.0 * (1 << zoom)).floor();
  }

  static int _latToTileY(double lat, int zoom) {
    final latRad = lat * pi / 180.0;
    final n = 1 << zoom;
    return ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * n)
        .floor();
  }
}
