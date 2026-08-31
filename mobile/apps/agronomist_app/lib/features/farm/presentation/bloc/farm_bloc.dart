import 'package:bloc/bloc.dart';

import '../../domain/usecases/create_farm_usecase.dart';
import '../../domain/usecases/get_farms_usecase.dart';
import '../../domain/usecases/update_farm_usecase.dart';
import 'farm_event.dart';
import 'farm_state.dart';

class FarmBloc extends Bloc<FarmEvent, FarmState> {
  FarmBloc({
    required GetFarmsUseCase getFarms,
    required CreateFarmUseCase createFarm,
    required UpdateFarmUseCase updateFarm,
  })  : _getFarms = getFarms,
        _createFarm = createFarm,
        _updateFarm = updateFarm,
        super(const FarmInitial()) {
    on<LoadFarms>(_onLoadFarms);
    on<LoadFarmById>(_onLoadFarmById);
    on<CreateFarm>(_onCreateFarm);
    on<UpdateFarm>(_onUpdateFarm);
    on<DeleteFarm>(_onDeleteFarm);
  }

  final GetFarmsUseCase _getFarms;
  final CreateFarmUseCase _createFarm;
  final UpdateFarmUseCase _updateFarm;

  Future<void> _onLoadFarms(LoadFarms event, Emitter<FarmState> emit) async {
    emit(const FarmLoading());
    try {
      final farms = await _getFarms();
      emit(FarmsLoaded(farms: farms));
    } catch (e) {
      emit(FarmError(message: e.toString()));
    }
  }

  Future<void> _onLoadFarmById(
      LoadFarmById event, Emitter<FarmState> emit) async {
    emit(const FarmLoading());
    try {
      final farms = await _getFarms();
      final farm = farms.firstWhere((f) => f.id == event.farmId);
      emit(FarmLoaded(farm: farm));
    } catch (e) {
      emit(FarmError(message: e.toString()));
    }
  }

  Future<void> _onCreateFarm(CreateFarm event, Emitter<FarmState> emit) async {
    emit(const FarmLoading());
    try {
      final farm = await _createFarm(event.farm);
      emit(FarmCreated(farm: farm));
    } catch (e) {
      emit(FarmError(message: e.toString()));
    }
  }

  Future<void> _onUpdateFarm(UpdateFarm event, Emitter<FarmState> emit) async {
    emit(const FarmLoading());
    try {
      final farm = await _updateFarm(event.farm);
      emit(FarmUpdated(farm: farm));
    } catch (e) {
      emit(FarmError(message: e.toString()));
    }
  }

  Future<void> _onDeleteFarm(DeleteFarm event, Emitter<FarmState> emit) async {
    emit(const FarmLoading());
    try {
      // Delete is handled via the repository directly through the farms list reload
      final farms = await _getFarms();
      emit(FarmsLoaded(farms: farms));
    } catch (e) {
      emit(FarmError(message: e.toString()));
    }
  }
}
