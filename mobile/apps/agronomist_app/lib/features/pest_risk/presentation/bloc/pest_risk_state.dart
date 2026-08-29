import 'package:equatable/equatable.dart';

import '../../domain/entities/pest_risk_entity.dart';

sealed class PestRiskState extends Equatable {
  const PestRiskState();
  @override
  List<Object?> get props => [];
}

final class PestRiskInitial extends PestRiskState {
  const PestRiskInitial();
}

final class PestRiskLoading extends PestRiskState {
  const PestRiskLoading();
}

final class PestRisksLoaded extends PestRiskState {
  const PestRisksLoaded({required this.risks});
  final List<PestRiskEntity> risks;
  @override
  List<Object?> get props => [risks];
}

final class PestRiskError extends PestRiskState {
  const PestRiskError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}
