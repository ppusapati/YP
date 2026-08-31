import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/diagnosis_model.dart';

abstract class DiagnosisLocalDataSource {
  Future<List<DiagnosisModel>> getDiagnoses();
  Future<void> cacheDiagnoses(List<DiagnosisModel> diagnoses);
  Future<void> cacheDiagnosis(DiagnosisModel diagnosis);
  Future<void> clear();
}

class DiagnosisLocalDataSourceImpl implements DiagnosisLocalDataSource {
  static const _cacheKey = 'cached_diagnoses';
  final SharedPreferences _prefs;

  DiagnosisLocalDataSourceImpl(this._prefs);

  @override
  Future<List<DiagnosisModel>> getDiagnoses() async {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => DiagnosisModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> cacheDiagnoses(List<DiagnosisModel> diagnoses) async {
    final raw = jsonEncode(diagnoses.map((e) => e.toJson()).toList());
    await _prefs.setString(_cacheKey, raw);
  }

  @override
  Future<void> cacheDiagnosis(DiagnosisModel diagnosis) async {
    final list = await getDiagnoses();
    final index = list.indexWhere((e) => e.id == diagnosis.id);
    if (index >= 0) {
      list[index] = diagnosis;
    } else {
      list.add(diagnosis);
    }
    await cacheDiagnoses(list);
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(_cacheKey);
  }
}
