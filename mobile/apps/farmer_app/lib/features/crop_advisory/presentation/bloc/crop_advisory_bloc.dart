import 'package:bloc/bloc.dart';

import '../../domain/usecases/create_advisory_usecase.dart';
import '../../domain/usecases/get_advisories_usecase.dart';
import 'crop_advisory_event.dart';
import 'crop_advisory_state.dart';

class CropAdvisoryBloc extends Bloc<CropAdvisoryEvent, CropAdvisoryState> {
  CropAdvisoryBloc({
    required GetAdvisoriesUseCase getAdvisories,
    required CreateAdvisoryUseCase createAdvisory,
  })  : _getAdvisories = getAdvisories,
        _createAdvisory = createAdvisory,
        super(const CropAdvisoryInitial()) {
    on<LoadAdvisories>(_onLoadAdvisories);
    on<CreateAdvisory>(_onCreateAdvisory);
  }

  final GetAdvisoriesUseCase _getAdvisories;
  final CreateAdvisoryUseCase _createAdvisory;

  Future<void> _onLoadAdvisories(
      LoadAdvisories event, Emitter<CropAdvisoryState> emit) async {
    emit(const CropAdvisoryLoading());
    try {
      final advisories = await _getAdvisories(farmId: event.farmId);
      emit(AdvisoriesLoaded(advisories: advisories));
    } catch (e) {
      emit(CropAdvisoryError(message: e.toString()));
    }
  }

  Future<void> _onCreateAdvisory(
      CreateAdvisory event, Emitter<CropAdvisoryState> emit) async {
    emit(const CropAdvisoryLoading());
    try {
      final advisory = await _createAdvisory(event.advisory);
      emit(AdvisoryCreated(advisory: advisory));
    } catch (e) {
      emit(CropAdvisoryError(message: e.toString()));
    }
  }
}
