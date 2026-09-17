import 'package:flutter_network/flutter_network.dart';
import 'package:flutter_proto/src/generated/assistant.pb.dart' as assistant_pb;
import 'package:protobuf/protobuf.dart' as $pb;

/// Remote data source for the agronomy assistant.
///
/// Imports the generated file directly rather than the package barrel, because
/// the barrel hides `Locale` — Flutter's own `Locale` arrives with
/// material.dart and the two would collide on any screen that needs both.
abstract class AssistantRemoteDataSource {
  /// Asks one question and returns the answer with its citations, the services
  /// that were consulted and the groundedness check that ran on it.
  Future<assistant_pb.AskResponse> ask({
    required String question,
    required assistant_pb.Locale locale,
    String conversationId,
    String fieldId,
    String farmId,
  });

  /// One conversation and every exchange in it, oldest first.
  Future<assistant_pb.GetConversationResponse> getConversation(String id);

  /// This tenant's advisory budget and what it has spent today.
  Future<assistant_pb.GetTenantBudgetResponse> getTenantBudget();
}

class AssistantRemoteDataSourceImpl implements AssistantRemoteDataSource {
  AssistantRemoteDataSourceImpl(this._client);

  final ConnectClient _client;

  static const _basePath = '/agriculture.advisory.v1.AdvisoryService';

  Future<ConnectResponse> _call(
      String method, $pb.GeneratedMessage request) async {
    final response = await _client.unary(
      '$_basePath/$method',
      body: request.writeToBuffer(),
    );
    if (!response.isSuccess) {
      throw AssistantRemoteException(
        'RPC call $_basePath/$method failed',
        statusCode: response.statusCode,
      );
    }
    return response;
  }

  @override
  Future<assistant_pb.AskResponse> ask({
    required String question,
    required assistant_pb.Locale locale,
    String conversationId = '',
    String fieldId = '',
    String farmId = '',
  }) async {
    final request = assistant_pb.AskRequest(
      question: question,
      locale: locale,
      conversationId: conversationId,
      fieldId: fieldId,
      farmId: farmId,
    );
    final response = await _call('Ask', request);
    return assistant_pb.AskResponse.fromBuffer(response.body);
  }

  @override
  Future<assistant_pb.GetConversationResponse> getConversation(String id) async {
    final request = assistant_pb.GetConversationRequest(id: id);
    final response = await _call('GetConversation', request);
    return assistant_pb.GetConversationResponse.fromBuffer(response.body);
  }

  @override
  Future<assistant_pb.GetTenantBudgetResponse> getTenantBudget() async {
    final response =
        await _call('GetTenantBudget', assistant_pb.GetTenantBudgetRequest());
    return assistant_pb.GetTenantBudgetResponse.fromBuffer(response.body);
  }
}

/// Raised when the advisory service returns a non-success status.
class AssistantRemoteException implements Exception {
  AssistantRemoteException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => statusCode == null
      ? 'AssistantRemoteException: $message'
      : 'AssistantRemoteException: $message (HTTP $statusCode)';
}
