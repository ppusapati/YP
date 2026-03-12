import 'package:bloc/bloc.dart';
import 'package:logging/logging.dart';

import '../../domain/usecases/get_farm_history_usecase.dart';
import '../../domain/usecases/get_produce_record_usecase.dart';
import '../../domain/usecases/scan_qr_code_usecase.dart';
import 'traceability_event.dart';
import 'traceability_state.dart';

/// BLoC managing traceability QR scanning and produce record retrieval.
class TraceabilityBloc extends Bloc<TraceabilityEvent, TraceabilityState> {
  TraceabilityBloc({
    required ScanQrCodeUseCase scanQrCode,
    required GetProduceRecordUseCase getProduceRecord,
    required GetFarmHistoryUseCase getFarmHistory,
  })  : _scanQrCode = scanQrCode,
        _getProduceRecord = getProduceRecord,
        _getFarmHistory = getFarmHistory,
        super(const TraceabilityInitial()) {
    on<ScanQRCode>(_onScanQRCode);
    on<LoadProduceRecord>(_onLoadProduceRecord);
    on<LoadFarmHistory>(_onLoadFarmHistory);
  }

  final ScanQrCodeUseCase _scanQrCode;
  final GetProduceRecordUseCase _getProduceRecord;
  final GetFarmHistoryUseCase _getFarmHistory;
  static final _log = Logger('TraceabilityBloc');

  Future<void> _onScanQRCode(
    ScanQRCode event,
    Emitter<TraceabilityState> emit,
  ) async {
    emit(const Scanning());
    try {
      final record = await _scanQrCode(event.qrData);
      emit(RecordLoaded(record));
    } catch (e, stack) {
      _log.severe('QR scan failed', e, stack);
      emit(const TraceabilityError(
        'Unable to read QR code. Please try again with a valid produce QR code.',
      ));
    }
  }

  Future<void> _onLoadProduceRecord(
    LoadProduceRecord event,
    Emitter<TraceabilityState> emit,
  ) async {
    emit(const TraceabilityLoading());
    try {
      final record = await _getProduceRecord(event.recordId);
      emit(RecordLoaded(record));
    } catch (e, stack) {
      _log.severe('Failed to load produce record', e, stack);
      emit(const TraceabilityError(
        'Unable to load produce record. Please try again.',
      ));
    }
  }

  Future<void> _onLoadFarmHistory(
    LoadFarmHistory event,
    Emitter<TraceabilityState> emit,
  ) async {
    emit(const TraceabilityLoading());
    try {
      final records = await _getFarmHistory(event.farmId);
      emit(FarmHistoryLoaded(records));
    } catch (e, stack) {
      _log.severe('Failed to load farm history', e, stack);
      emit(const TraceabilityError(
        'Unable to load farm history. Please try again.',
      ));
    }
  }
}
