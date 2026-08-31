import 'package:http/http.dart' as http;

import '../generated/vegetation_index.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for vegetation index computation.
///
/// Provides operations for computing vegetation indices, retrieving
/// NDVI time series, and assessing field health.
class VegetationIndexServiceClient extends BaseService {
  VegetationIndexServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName =>
      'yieldpoint.satellite.vegetation.v1.VegetationIndexService';

  /// Computes vegetation indices for a field.
  Future<VegetationIndex> computeIndices(VegetationIndex request) async {
    final bytes = await callUnary('ComputeIndices', request);
    return VegetationIndex.fromBuffer(bytes);
  }

  /// Retrieves a vegetation index by ID.
  Future<VegetationIndex> getVegetationIndex(String id) async {
    final request = VegetationIndex(id: id);
    final bytes = await callUnary('GetVegetationIndex', request);
    return VegetationIndex.fromBuffer(bytes);
  }

  /// Lists vegetation indices.
  Future<List<VegetationIndex>> listVegetationIndices(
      {int pageSize = 20}) async {
    final request = VegetationIndex();
    final bytes = await callUnary('ListVegetationIndices', request);
    final index = VegetationIndex.fromBuffer(bytes);
    return [index];
  }

  /// Retrieves NDVI time series for a field.
  Future<List<NDVITimeSeriesEntry>> getNDVITimeSeries(
      String farmId, String fieldId) async {
    final request = VegetationIndex(farmId: farmId, fieldId: fieldId);
    final bytes = await callUnary('GetNDVITimeSeries', request);
    final entry = NDVITimeSeriesEntry.fromBuffer(bytes);
    return [entry];
  }

  /// Retrieves field health assessment.
  Future<FieldHealth> getFieldHealth(String farmId, String fieldId) async {
    final request = FieldHealth(farmId: farmId, fieldId: fieldId);
    final bytes = await callUnary('GetFieldHealth', request);
    return FieldHealth.fromBuffer(bytes);
  }
}
