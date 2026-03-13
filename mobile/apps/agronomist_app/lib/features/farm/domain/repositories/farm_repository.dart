import '../entities/farm_entity.dart';

/// Abstract repository interface for farm operations.
///
/// Implementations handle data sourcing (remote/local) and caching strategy.
/// The agronomist repository works across ALL client farms, not filtered by owner.
abstract class FarmRepository {
  /// Retrieves all farms managed by the agronomist.
  Future<List<FarmEntity>> getFarms();

  /// Retrieves a single farm by its ID.
  Future<FarmEntity> getFarmById(String farmId);

  /// Creates a new farm and returns the created entity.
  Future<FarmEntity> createFarm(FarmEntity farm);

  /// Updates an existing farm and returns the updated entity.
  Future<FarmEntity> updateFarm(FarmEntity farm);

  /// Deletes a farm by its ID.
  Future<void> deleteFarm(String farmId);
}
