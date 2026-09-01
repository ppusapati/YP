import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/yield.pb.dart' as yield_pb;
import 'package:protobuf/protobuf.dart' as $pb;

import '../models/yield_prediction_model.dart';

abstract class YieldAnalysisRemoteDataSource {
  Future<List<YieldPredictionModel>> getYieldForecast(String fieldId);
  Future<List<YieldPredictionModel>> getYieldHistory(String fieldId);
}

class YieldAnalysisRemoteDataSourceImpl implements YieldAnalysisRemoteDataSource {
  final ConnectClient _client;

  static const _basePath = '/agriculture.yield.v1.YieldService';

  YieldAnalysisRemoteDataSourceImpl(this._client);

  Future<ConnectResponse> _call(
      String method, $pb.GeneratedMessage request) async {
    final response = await _client.unary(
      '$_basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw ConnectException(
        code: 'internal',
        message: '$_basePath/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<List<YieldPredictionModel>> getYieldForecast(String fieldId) async {
    final request = yield_pb.ListPredictionsRequest(fieldId: fieldId);
    final response = await _call('ListPredictions', request);
    final pbResponse =
        yield_pb.ListPredictionsResponse.fromBuffer(response.body);
    return pbResponse.predictions.map(_predictionFromProto).toList();
  }

  @override
  Future<List<YieldPredictionModel>> getYieldHistory(String fieldId) async {
    final request = yield_pb.GetYieldHistoryRequest(fieldId: fieldId);
    final response = await _call('GetYieldHistory', request);
    final pbResponse =
        yield_pb.GetYieldHistoryResponse.fromBuffer(response.body);
    return pbResponse.records.map(_recordFromProto).toList();
  }

  /// Converts a protobuf [yield_pb.YieldPrediction] to [YieldPredictionModel].
  static YieldPredictionModel _predictionFromProto(
      yield_pb.YieldPrediction pb) {
    final createdAt = pb.hasCreatedAt()
        ? DateTime.fromMillisecondsSinceEpoch(
            pb.createdAt.seconds.toInt() * 1000)
        : DateTime.now();
    return YieldPredictionModel(
      id: pb.id,
      fieldId: pb.fieldId,
      cropName: pb.cropId,
      predictedYield: pb.predictedYieldKgPerHectare / 1000.0,
      unit: 'tonnes/ha',
      confidence: pb.predictionConfidencePct / 100.0,
      harvestDate: createdAt,
      predictedAt: createdAt,
    );
  }

  /// Converts a protobuf [yield_pb.YieldRecord] to [YieldPredictionModel].
  static YieldPredictionModel _recordFromProto(yield_pb.YieldRecord pb) {
    final harvestDate = pb.hasHarvestDate()
        ? DateTime.fromMillisecondsSinceEpoch(
            pb.harvestDate.seconds.toInt() * 1000)
        : DateTime.now();
    final createdAt = pb.hasCreatedAt()
        ? DateTime.fromMillisecondsSinceEpoch(
            pb.createdAt.seconds.toInt() * 1000)
        : DateTime.now();
    return YieldPredictionModel(
      id: pb.id,
      fieldId: pb.fieldId,
      cropName: pb.cropId,
      predictedYield: pb.actualYieldKgPerHectare / 1000.0,
      unit: 'tonnes/ha',
      confidence: 1.0,
      harvestDate: harvestDate,
      predictedAt: createdAt,
    );
  }
}
