import '../repositories/alert_repository.dart';

class GetUnreadCountUseCase {
  const GetUnreadCountUseCase(this._repository);

  final AlertRepository _repository;

  Future<int> call({String? farmId}) async {
    return _repository.getUnreadCount(farmId: farmId);
  }
}
