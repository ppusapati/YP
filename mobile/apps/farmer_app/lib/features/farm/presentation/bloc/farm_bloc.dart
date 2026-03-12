import 'package:bloc/bloc.dart';

import '../../domain/repositories/farm_repository.dart';
import 'farm_event.dart';
import 'farm_state.dart';

class FarmBloc extends Bloc<FarmEvent, FarmState> {
  FarmBloc({required FarmRepository farmRepository})
      : _farmRepository = farmRepository,
        super(const FarmInitial()) {
    on<LoadFarms>(_onLoadFarms);
    on<LoadFarmById>(_onLoadFarmById);
    on<CreateFarm>(_onCreateFarm);
    on<UpdateFarm>(_onUpdateFarm);
    on<DeleteFarm>(_onDeleteFarm);
    on<SelectFarm>(_onSelectFarm);
  }

  final FarmRepository _farmRepository;

  Future<void> _onLoadFarms(LoadFarms event, Emitter<FarmState> emit) async {
    emit(const FarmLoading());
    try {
      final farms = await _farmRepository.getFarms(event.userId);
      emit(FarmsLoaded(farms: farms));
    } catch (e) {
      emit(FarmError(message: e.toString()));
    }
  }

  Future<void> _onLoadFarmById(
      LoadFarmById event, Emitter<FarmState> emit) async {
    emit(const FarmLoading());
    try {
      final farm = await _farmRepository.getFarmById(event.farmId);
      emit(FarmLoaded(farm: farm));
    } catch (e) {
      emit(FarmError(message: e.toString()));
    }
  }

  Future<void> _onCreateFarm(CreateFarm event, Emitter<FarmState> emit) async {
    emit(const FarmLoading());
    try {
      final farm = await _farmRepository.createFarm(event.farm);
      emit(FarmCreated(farm: farm));
    } catch (e) {
      emit(FarmError(message: e.toString()));
    }
  }

  Future<void> _onUpdateFarm(UpdateFarm event, Emitter<FarmState> emit) async {
    emit(const FarmLoading());
    try {
      final farm = await _farmRepository.updateFarm(event.farm);
      emit(FarmUpdated(farm: farm));
    } catch (e) {
      emit(FarmError(message: e.toString()));
    }
  }

  Future<void> _onDeleteFarm(DeleteFarm event, Emitter<FarmState> emit) async {
    emit(const FarmLoading());
    try {
      await _farmRepository.deleteFarm(event.farmId);
      emit(const FarmDeleted());
    } catch (e) {
      emit(FarmError(message: e.toString()));
    }
  }

  Future<void> _onSelectFarm(
    SelectFarm event,
    Emitter<FarmState> emit,
  ) async {
    final currentState = state;
    if (currentState is FarmsLoaded) {
      final selected = currentState.farms.firstWhere(
        (f) => f.id == event.farmId,
      );
      emit(FarmLoaded(farm: selected));
    } else {
      emit(const FarmLoading());
      try {
        final farm = await _farmRepository.getFarmById(event.farmId);
        emit(FarmLoaded(farm: farm));
      } catch (e) {
        emit(FarmError(message: e.toString()));
      }
    }
  }
}
