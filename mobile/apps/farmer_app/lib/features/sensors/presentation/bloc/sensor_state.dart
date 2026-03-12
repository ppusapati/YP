import 'package:equatable/equatable.dart';

import '../../domain/entities/sensor_entity.dart';
import '../../domain/entities/sensor_reading_entity.dart';

sealed class SensorState extends Equatable {
  const SensorState();

  @override
  List<Object?> get props => [];
}

final class SensorInitial extends SensorState {
  const SensorInitial();
}

final class SensorLoading extends SensorState {
  const SensorLoading();
}

final class SensorsLoaded extends SensorState {
  const SensorsLoaded({
    required this.sensors,
    this.selectedSensorId,
    this.filterType,
  });

  final List<Sensor> sensors;
  final String? selectedSensorId;
  final SensorType? filterType;

  Sensor? get selectedSensor {
    if (selectedSensorId == null) return null;
    try {
      return sensors.firstWhere((s) => s.id == selectedSensorId);
    } catch (_) {
      return null;
    }
  }

  int get onlineCount => sensors.where((s) => s.isOnline).length;
  int get offlineCount => sensors.where((s) => !s.isOnline).length;
  int get lowBatteryCount => sensors.where((s) => s.isBatteryLow).length;

  SensorsLoaded copyWith({
    List<Sensor>? sensors,
    String? selectedSensorId,
    SensorType? filterType,
    bool clearFilter = false,
  }) {
    return SensorsLoaded(
      sensors: sensors ?? this.sensors,
      selectedSensorId: selectedSensorId ?? this.selectedSensorId,
      filterType: clearFilter ? null : (filterType ?? this.filterType),
    );
  }

  @override
  List<Object?> get props => [sensors, selectedSensorId, filterType];
}

final class SensorReadingsLoaded extends SensorState {
  const SensorReadingsLoaded({
    required this.sensor,
    required this.readings,
  });

  final Sensor sensor;
  final List<SensorReading> readings;

  double get averageValue {
    if (readings.isEmpty) return 0;
    return readings.map((r) => r.value).reduce((a, b) => a + b) /
        readings.length;
  }

  double get minValue {
    if (readings.isEmpty) return 0;
    return readings.map((r) => r.value).reduce((a, b) => a < b ? a : b);
  }

  double get maxValue {
    if (readings.isEmpty) return 0;
    return readings.map((r) => r.value).reduce((a, b) => a > b ? a : b);
  }

  @override
  List<Object?> get props => [sensor, readings];
}

final class SensorError extends SensorState {
  const SensorError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
