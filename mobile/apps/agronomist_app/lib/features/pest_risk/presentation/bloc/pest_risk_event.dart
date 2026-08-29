import 'package:equatable/equatable.dart';

sealed class PestRiskEvent extends Equatable {
  const PestRiskEvent();
  @override
  List<Object?> get props => [];
}

final class LoadPestRisks extends PestRiskEvent {
  const LoadPestRisks({required this.fieldId});
  final String fieldId;
  @override
  List<Object?> get props => [fieldId];
}

final class LoadPestAlerts extends PestRiskEvent {
  const LoadPestAlerts();
}
