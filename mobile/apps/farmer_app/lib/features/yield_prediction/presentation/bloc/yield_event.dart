import 'package:equatable/equatable.dart';

sealed class YieldEvent extends Equatable {
  const YieldEvent();

  @override
  List<Object?> get props => [];
}

final class LoadPredictions extends YieldEvent {
  const LoadPredictions({this.fieldId, this.cropType});

  final String? fieldId;
  final String? cropType;

  @override
  List<Object?> get props => [fieldId, cropType];
}

final class LoadHistory extends YieldEvent {
  const LoadHistory({required this.fieldId, this.cropType});

  final String fieldId;
  final String? cropType;

  @override
  List<Object?> get props => [fieldId, cropType];
}

final class SelectField extends YieldEvent {
  const SelectField({required this.fieldId});

  final String fieldId;

  @override
  List<Object?> get props => [fieldId];
}

final class SelectCrop extends YieldEvent {
  const SelectCrop({required this.cropType});

  final String cropType;

  @override
  List<Object?> get props => [cropType];
}
