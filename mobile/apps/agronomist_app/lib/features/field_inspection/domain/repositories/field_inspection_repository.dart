import '../entities/inspection_entity.dart';

/// Abstract repository interface for field inspection operations.
abstract class FieldInspectionRepository {
  /// Retrieves all inspections, optionally filtered by farm.
  Future<List<InspectionEntity>> getInspections({String? farmId});

  /// Retrieves a single inspection by ID.
  Future<InspectionEntity> getInspectionById(String id);

  /// Creates a new inspection and returns the created entity.
  Future<InspectionEntity> createInspection(InspectionEntity inspection);

  /// Submits a draft inspection for review.
  Future<InspectionEntity> submitInspection(String inspectionId);
}
