import '../generated/assistant.pb.dart';
import 'base_service.dart';

/// ConnectRPC service client for the agronomy assistant.
///
/// Answers are grounded on the tenant's own records and on indexed reference
/// material; every one comes back with its citations, the services that were
/// consulted, and the automated groundedness check that ran on it. The screen
/// showing an answer is expected to show those too — an answer stripped of its
/// citations cannot be checked by the person acting on it.
class AdvisoryServiceClient extends BaseService {
  AdvisoryServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'agriculture.advisory.v1.AdvisoryService';

  /// Asks one question.
  ///
  /// [conversationId] empty starts a new conversation; passing the id returned
  /// by a previous call continues it, so a follow-up question has the earlier
  /// turns as context.
  ///
  /// [fieldId] is what makes the answer about this farm rather than about
  /// farming: with it the assistant reads that field's own weather, alerts,
  /// crop stage and diagnoses before answering.
  Future<AskResponse> ask({
    required String question,
    required Locale locale,
    String conversationId = '',
    String fieldId = '',
    String farmId = '',
    bool disableTools = false,
  }) async {
    final request = AskRequest(
      conversationId: conversationId,
      question: question,
      locale: locale,
      fieldId: fieldId,
      farmId: farmId,
      disableTools: disableTools,
    );
    final bytes = await callUnary('Ask', request);
    return AskResponse.fromBuffer(bytes);
  }

  /// A conversation and every exchange in it, oldest first.
  Future<GetConversationResponse> getConversation(String id) async {
    final bytes = await callUnary('GetConversation', GetConversationRequest(id: id));
    return GetConversationResponse.fromBuffer(bytes);
  }

  /// The conversations this tenant has had, most recently updated first.
  Future<ListConversationsResponse> listConversations({
    String fieldId = '',
    String farmId = '',
    int pageSize = 20,
    int pageOffset = 0,
  }) async {
    final request = ListConversationsRequest(
      fieldId: fieldId,
      farmId: farmId,
      pageSize: pageSize,
      pageOffset: pageOffset,
    );
    final bytes = await callUnary('ListConversations', request);
    return ListConversationsResponse.fromBuffer(bytes);
  }

  /// The review queue.
  ///
  /// [needsReviewOnly] narrows to the answers the automated check could not
  /// tie to a source, which is the queue an agronomist works through.
  Future<ListExchangesResponse> listExchanges({
    bool needsReviewOnly = false,
    bool unreviewedOnly = false,
    String conversationId = '',
    int pageSize = 20,
    int pageOffset = 0,
  }) async {
    final request = ListExchangesRequest(
      needsReviewOnly: needsReviewOnly,
      unreviewedOnly: unreviewedOnly,
      conversationId: conversationId,
      pageSize: pageSize,
      pageOffset: pageOffset,
    );
    final bytes = await callUnary('ListExchanges', request);
    return ListExchangesResponse.fromBuffer(bytes);
  }

  /// Records an agronomist's verdict on one exchange.
  Future<ReviewExchangeResponse> reviewExchange({
    required String exchangeId,
    String note = '',
    int rating = 0,
  }) async {
    final request = ReviewExchangeRequest(
      exchangeId: exchangeId,
      note: note,
      rating: rating,
    );
    final bytes = await callUnary('ReviewExchange', request);
    return ReviewExchangeResponse.fromBuffer(bytes);
  }

  /// This tenant's advisory budget and what it has spent today.
  Future<GetTenantBudgetResponse> getTenantBudget() async {
    final bytes = await callUnary('GetTenantBudget', GetTenantBudgetRequest());
    return GetTenantBudgetResponse.fromBuffer(bytes);
  }

  /// Retrieval on its own, with no answer — what the assistant would have been
  /// given for a query.
  Future<SearchReferenceResponse> searchReference({
    required String query,
    required Locale locale,
    String crop = '',
    int limit = 0,
  }) async {
    final request = SearchReferenceRequest(
      query: query,
      locale: locale,
      crop: crop,
      limit: limit,
    );
    final bytes = await callUnary('SearchReference', request);
    return SearchReferenceResponse.fromBuffer(bytes);
  }
}
