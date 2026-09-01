import '../generated/field.pb.dart';
import 'base_service.dart';

class FieldServiceClient extends BaseService {
  FieldServiceClient({
    required super.baseUrl,
    super.httpClient,
    super.interceptors,
  });

  @override
  String get serviceName => 'agriculture.field.v1.FieldService';

  Future<GetFieldResponse> getField(String id) async {
    final request = GetFieldRequest(id: id);
    final bytes = await callUnary('GetField', request);
    return GetFieldResponse.fromBuffer(bytes);
  }

  Future<ListFieldsResponse> listFields({
    String? farmId,
    int pageSize = 20,
    int pageOffset = 0,
  }) async {
    final request = ListFieldsRequest(
      farmId: farmId ?? '',
      pageSize: pageSize,
      pageOffset: pageOffset,
    );
    final bytes = await callUnary('ListFields', request);
    return ListFieldsResponse.fromBuffer(bytes);
  }

  Future<CreateFieldResponse> createField(CreateFieldRequest request) async {
    final bytes = await callUnary('CreateField', request);
    return CreateFieldResponse.fromBuffer(bytes);
  }

  Future<UpdateFieldResponse> updateField(UpdateFieldRequest request) async {
    final bytes = await callUnary('UpdateField', request);
    return UpdateFieldResponse.fromBuffer(bytes);
  }

  Future<void> deleteField(String id) async {
    final request = DeleteFieldRequest(id: id);
    await callUnary('DeleteField', request);
  }

  Future<SetFieldBoundaryResponse> setFieldBoundary(
      SetFieldBoundaryRequest request) async {
    final bytes = await callUnary('SetFieldBoundary', request);
    return SetFieldBoundaryResponse.fromBuffer(bytes);
  }

  Future<AssignCropResponse> assignCrop(AssignCropRequest request) async {
    final bytes = await callUnary('AssignCrop', request);
    return AssignCropResponse.fromBuffer(bytes);
  }

  Future<ListFieldsByFarmResponse> listFieldsByFarm(String farmId,
      {int pageSize = 20, int pageOffset = 0}) async {
    final request = ListFieldsByFarmRequest(
      farmId: farmId,
      pageSize: pageSize,
      pageOffset: pageOffset,
    );
    final bytes = await callUnary('ListFieldsByFarm', request);
    return ListFieldsByFarmResponse.fromBuffer(bytes);
  }

  Future<SegmentFieldResponse> segmentField(
      SegmentFieldRequest request) async {
    final bytes = await callUnary('SegmentField', request);
    return SegmentFieldResponse.fromBuffer(bytes);
  }

  Future<GetFieldSegmentsResponse> getFieldSegments(String fieldId) async {
    final request = GetFieldSegmentsRequest(fieldId: fieldId);
    final bytes = await callUnary('GetFieldSegments', request);
    return GetFieldSegmentsResponse.fromBuffer(bytes);
  }

  Future<GetCropHistoryResponse> getCropHistory(String fieldId,
      {int pageSize = 20, int pageOffset = 0}) async {
    final request = GetCropHistoryRequest(
      fieldId: fieldId,
      pageSize: pageSize,
      pageOffset: pageOffset,
    );
    final bytes = await callUnary('GetCropHistory', request);
    return GetCropHistoryResponse.fromBuffer(bytes);
  }
}
