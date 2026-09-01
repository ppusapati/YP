import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/yield.pb.dart' as yield_pb;
import 'package:protobuf/protobuf.dart' as $pb;

import '../models/yield_prediction_model.dart';

abstract class YieldRemoteDataSource {
  Future<List<YieldPredictionModel>> getPredictions({
    String? fieldId,
    String? cropType,
  });
  Future<YieldPredictionModel> getPredictionById(String predictionId);
  Future<List<YieldPredictionModel>> getHistory(
    String fieldId, {
    String? cropType,
  });
}

class YieldRemoteDataSourceImpl implements YieldRemoteDataSource {
  const YieldRemoteDataSourceImpl(this._client);

  final ConnectClient _client;

  static const _basePath = '/agriculture.yield.v1.YieldService';

  Future<ConnectResponse> _call(
      String method, $pb.GeneratedMessage request) async {
    final response = await _client.unary(
      '$_basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw ConnectException(
        code: 'internal',
        message: 'YieldService/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<List<YieldPredictionModel>> getPredictions({
    String? fieldId,
    String? cropType,
  }) async {
    final request = yield_pb.ListPredictionsRequest(
      fieldId: fieldId,
      cropId: cropType,
    );

    final response = await _call('ListPredictions', request);
    final pbResponse =
        yield_pb.ListPredictionsResponse.fromBuffer(response.body);
    return pbResponse.predictions.map(_predictionFromPb).toList();
  }

  @override
  Future<YieldPredictionModel> getPredictionById(
      String predictionId) async {
    final request = yield_pb.GetPredictionRequest(id: predictionId);

    final response = await _call('GetPrediction', request);
    final pbResponse =
        yield_pb.GetPredictionResponse.fromBuffer(response.body);
    return _predictionFromPb(pbResponse.prediction);
  }

  @override
  Future<List<YieldPredictionModel>> getHistory(
    String fieldId, {
    String? cropType,
  }) async {
    final request = yield_pb.GetYieldHistoryRequest(
      fieldId: fieldId,
      cropId: cropType,
    );

    final response = await _call('GetYieldHistory', request);
    final pbResponse =
        yield_pb.GetYieldHistoryResponse.fromBuffer(response.body);
    return pbResponse.records.map(_yieldRecordToModel).toList();
  }

  // ---------------------------------------------------------------------------
  // Pb-to-model helpers
  // ---------------------------------------------------------------------------

  static YieldPredictionModel _predictionFromPb(
      yield_pb.YieldPrediction p) {
    final factors = <YieldFactorModel>[];
    if (p.hasYieldFactors()) {
      final yf = p.yieldFactors;
      if (yf.hasSoilQualityScore()) {
        factors.add(YieldFactorModel(
          name: 'Soil Quality',
          impact: yf.soilQualityScore,
          value: yf.soilQualityScore,
        ));
      }
      if (yf.hasWeatherScore()) {
        factors.add(YieldFactorModel(
          name: 'Weather',
          impact: yf.weatherScore,
          value: yf.weatherScore,
        ));
      }
      if (yf.hasIrrigationScore()) {
        factors.add(YieldFactorModel(
          name: 'Irrigation',
          impact: yf.irrigationScore,
          value: yf.irrigationScore,
        ));
      }
      if (yf.hasPestPressureScore()) {
        factors.add(YieldFactorModel(
          name: 'Pest Pressure',
          impact: yf.pestPressureScore,
          value: yf.pestPressureScore,
        ));
      }
      if (yf.hasNutrientScore()) {
        factors.add(YieldFactorModel(
          name: 'Nutrients',
          impact: yf.nutrientScore,
          value: yf.nutrientScore,
        ));
      }
      if (yf.hasManagementScore()) {
        factors.add(YieldFactorModel(
          name: 'Management',
          impact: yf.managementScore,
          value: yf.managementScore,
        ));
      }
    }

    return YieldPredictionModel(
      id: p.id,
      fieldId: p.fieldId,
      cropType: p.cropId,
      expectedYield: p.predictedYieldKgPerHectare,
      unit: 'kg/ha',
      harvestDate: p.hasCreatedAt()
          ? DateTime.fromMillisecondsSinceEpoch(
              p.createdAt.seconds.toInt() * 1000 +
                  p.createdAt.nanos ~/ 1000000,
            )
          : DateTime.now(),
      confidenceLevel: p.predictionConfidencePct,
      factors: factors,
    );
  }

  /// Maps a historical [YieldRecord] to [YieldPredictionModel] for the
  /// getHistory call, which the interface returns as predictions.
  static YieldPredictionModel _yieldRecordToModel(
      yield_pb.YieldRecord r) {
    return YieldPredictionModel(
      id: r.id,
      fieldId: r.fieldId,
      cropType: r.cropId,
      expectedYield: r.actualYieldKgPerHectare,
      unit: 'kg/ha',
      harvestDate: r.hasHarvestDate()
          ? DateTime.fromMillisecondsSinceEpoch(
              r.harvestDate.seconds.toInt() * 1000 +
                  r.harvestDate.nanos ~/ 1000000,
            )
          : DateTime.now(),
      confidenceLevel: 1.0, // actual record, full confidence
      factors: const [],
    );
  }
}
