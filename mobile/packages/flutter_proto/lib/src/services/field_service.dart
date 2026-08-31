import 'package:http/http.dart' as http;

import '../generated/farm.pb.dart';
import '../generated/field.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for field management.
///
/// Provides CRUD operations for fields, boundaries, segments,
/// crop assignments, and crop history.
class FieldServiceClient extends BaseService {
  FieldServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'yieldpoint.field.v1.FieldService';

  /// Retrieves a field by ID.
  Future<Field> getField(String id) async {
    final request = Field(id: id);
    final bytes = await callUnary('GetField', request);
    return Field.fromBuffer(bytes);
  }

  /// Lists all fields for a farm.
  Future<List<Field>> listFields(String farmId) async {
    final request = Field(farmId: farmId);
    final bytes = await callUnary('ListFields', request);
    final field = Field.fromBuffer(bytes);
    return [field];
  }

  /// Creates a new field.
  Future<Field> createField(Field field) async {
    final bytes = await callUnary('CreateField', field);
    return Field.fromBuffer(bytes);
  }

  /// Updates an existing field.
  Future<Field> updateField(Field field) async {
    final bytes = await callUnary('UpdateField', field);
    return Field.fromBuffer(bytes);
  }

  /// Deletes a field by ID.
  Future<void> deleteField(String id) async {
    final request = Field(id: id);
    await callUnary('DeleteField', request);
  }

  /// Sets the boundary for a field.
  Future<FieldBoundary> setFieldBoundary(FieldBoundary boundary) async {
    final bytes = await callUnary('SetFieldBoundary', boundary);
    return FieldBoundary.fromBuffer(bytes);
  }

  /// Assigns a crop to a field.
  Future<CropAssignment> assignCrop(CropAssignment assignment) async {
    final bytes = await callUnary('AssignCrop', assignment);
    return CropAssignment.fromBuffer(bytes);
  }

  /// Segments a field into zones.
  Future<List<FieldSegment>> segmentField(String fieldId) async {
    final request = FieldSegment(fieldId: fieldId);
    final bytes = await callUnary('SegmentField', request);
    final segment = FieldSegment.fromBuffer(bytes);
    return [segment];
  }

  /// Retrieves all segments for a field.
  Future<List<FieldSegment>> getFieldSegments(String fieldId) async {
    final request = FieldSegment(fieldId: fieldId);
    final bytes = await callUnary('GetFieldSegments', request);
    final segment = FieldSegment.fromBuffer(bytes);
    return [segment];
  }

  /// Retrieves crop history for a field.
  Future<List<CropHistoryEntry>> getCropHistory(String fieldId) async {
    final request = CropHistoryEntry(fieldId: fieldId);
    final bytes = await callUnary('GetCropHistory', request);
    final entry = CropHistoryEntry.fromBuffer(bytes);
    return [entry];
  }
}
