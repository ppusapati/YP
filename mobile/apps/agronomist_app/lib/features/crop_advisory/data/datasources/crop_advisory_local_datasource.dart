import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/advisory_model.dart';

/// Local data source for crop advisories using SharedPreferences.
abstract class CropAdvisoryLocalDataSource {
  Future<List<AdvisoryModel>> getAdvisories();
  Future<void> cacheAdvisories(List<AdvisoryModel> advisories);
  Future<void> cacheAdvisory(AdvisoryModel advisory);
  Future<void> clear();
}

class CropAdvisoryLocalDataSourceImpl implements CropAdvisoryLocalDataSource {
  static const _cacheKey = 'cached_advisories';
  final SharedPreferences _prefs;
  final _log = Logger('CropAdvisoryLocalDataSource');

  CropAdvisoryLocalDataSourceImpl(this._prefs);

  @override
  Future<List<AdvisoryModel>> getAdvisories() async {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => AdvisoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.warning('Failed to decode cached advisories: $e');
      return [];
    }
  }

  @override
  Future<void> cacheAdvisories(List<AdvisoryModel> advisories) async {
    final raw = jsonEncode(advisories.map((e) => e.toJson()).toList());
    await _prefs.setString(_cacheKey, raw);
  }

  @override
  Future<void> cacheAdvisory(AdvisoryModel advisory) async {
    final list = await getAdvisories();
    final index = list.indexWhere((e) => e.id == advisory.id);
    if (index >= 0) {
      list[index] = advisory;
    } else {
      list.add(advisory);
    }
    await cacheAdvisories(list);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_cacheKey);
  }
}
