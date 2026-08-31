import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/inspection_model.dart';

/// Local data source for field inspections using SharedPreferences.
abstract class FieldInspectionLocalDataSource {
  Future<List<InspectionModel>> getInspections();
  Future<void> cacheInspections(List<InspectionModel> inspections);
  Future<void> cacheInspection(InspectionModel inspection);
  Future<void> clear();
}

class FieldInspectionLocalDataSourceImpl
    implements FieldInspectionLocalDataSource {
  static const _cacheKey = 'cached_inspections';
  final SharedPreferences _prefs;
  final _log = Logger('FieldInspectionLocalDataSource');

  FieldInspectionLocalDataSourceImpl(this._prefs);

  @override
  Future<List<InspectionModel>> getInspections() async {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => InspectionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.warning('Failed to decode cached inspections: $e');
      return [];
    }
  }

  @override
  Future<void> cacheInspections(List<InspectionModel> inspections) async {
    final raw = jsonEncode(inspections.map((e) => e.toJson()).toList());
    await _prefs.setString(_cacheKey, raw);
  }

  @override
  Future<void> cacheInspection(InspectionModel inspection) async {
    final list = await getInspections();
    final index = list.indexWhere((e) => e.id == inspection.id);
    if (index >= 0) {
      list[index] = inspection;
    } else {
      list.add(inspection);
    }
    await cacheInspections(list);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_cacheKey);
  }
}
