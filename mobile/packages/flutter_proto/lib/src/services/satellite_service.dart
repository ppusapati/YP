import 'package:fixnum/fixnum.dart';
import 'package:http/http.dart' as http;

import '../generated/farm.pb.dart';
import '../generated/satellite.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for satellite imagery and NDVI data.
///
/// Provides access to satellite tiles, NDVI vegetation index data,
/// and crop health time series.
class SatelliteServiceClient extends BaseService {
  SatelliteServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'yieldpoint.satellite.v1.SatelliteService';

  /// Retrieves available satellite tiles for a field.
  Future<List<SatelliteTile>> getTilesForField({
    required String fieldId,
    String? indexType,
    Int64? fromDate,
    Int64? toDate,
  }) async {
    final request = SatelliteTile(
      fieldId: fieldId,
      indexType: indexType,
    );
    final bytes = await callUnary('GetTilesForField', request);
    final tile = SatelliteTile.fromBuffer(bytes);
    return [tile];
  }

  /// Retrieves a specific satellite tile by ID.
  Future<SatelliteTile> getTile(String tileId) async {
    final request = SatelliteTile(id: tileId);
    final bytes = await callUnary('GetTile', request);
    return SatelliteTile.fromBuffer(bytes);
  }

  /// Retrieves NDVI data for a field at a specific timestamp.
  Future<NDVIData> getNDVIData({
    required String fieldId,
    Int64? timestamp,
  }) async {
    final request = NDVIData(
      fieldId: fieldId,
      timestamp: timestamp,
    );
    final bytes = await callUnary('GetNDVIData', request);
    return NDVIData.fromBuffer(bytes);
  }

  /// Retrieves the crop health time series for a field.
  Future<CropHealthTimeSeries> getCropHealthTimeSeries({
    required String fieldId,
    Int64? fromDate,
    Int64? toDate,
  }) async {
    final request = CropHealthTimeSeries(fieldId: fieldId);
    final bytes = await callUnary('GetCropHealthTimeSeries', request);
    return CropHealthTimeSeries.fromBuffer(bytes);
  }

  /// Streams real-time NDVI updates for a field.
  Stream<NDVIData> streamNDVIUpdates(String fieldId) {
    final request = NDVIData(fieldId: fieldId);
    return callServerStream('StreamNDVIUpdates', request)
        .map((bytes) => NDVIData.fromBuffer(bytes));
  }
}
