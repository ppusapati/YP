import '../entities/farm_entity.dart';
import '../entities/field_entity.dart';

/// Abstract repository interface for farm operations.
///
/// Implementations handle data sourcing (remote/local) and caching strategy.
abstract class FarmRepository {
  /// Retrieves all farms belonging to the specified user.
  Future<List<FarmEntity>> getFarms(String userId);

  /// Retrieves a single farm by its ID.
  Future<FarmEntity> getFarmById(String farmId);

  /// Creates a new farm and returns the created entity.
  Future<FarmEntity> createFarm(FarmEntity farm);

  /// Updates an existing farm and returns the updated entity.
  Future<FarmEntity> updateFarm(FarmEntity farm);

  /// Deletes a farm by its ID.
  Future<void> deleteFarm(String farmId);

  /// Creates a new field within a farm and returns the created entity.
  Future<FieldEntity> createField(FieldEntity field);

  /// Updates an existing field and returns the updated entity.
  Future<FieldEntity> updateField(FieldEntity field);

  /// Deletes a field by its ID.
  Future<void> deleteField(String fieldId);

  /// Retrieves all fields for a given farm.
  Future<List<FieldEntity>> getFieldsByFarmId(String farmId);
}
