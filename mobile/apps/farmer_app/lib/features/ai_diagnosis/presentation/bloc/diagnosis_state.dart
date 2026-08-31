import 'package:equatable/equatable.dart';

import '../../domain/entities/diagnosis_entity.dart';

sealed class DiagnosisState extends Equatable {
  const DiagnosisState();

  @override
  List<Object?> get props => [];
}

final class DiagnosisInitial extends DiagnosisState {
  const DiagnosisInitial();
}

final class CameraReady extends DiagnosisState {
  const CameraReady();
}

final class DiagnosisLoading extends DiagnosisState {
  const DiagnosisLoading();
}

final class ImageCaptured extends DiagnosisState {
  const ImageCaptured({required this.imagePath});

  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

final class ImageUploading extends DiagnosisState {
  const ImageUploading();
}

final class ImageUploaded extends DiagnosisState {
  const ImageUploaded({required this.imageUrl});

  final String imageUrl;

  @override
  List<Object?> get props => [imageUrl];
}

final class Diagnosing extends DiagnosisState {
  const Diagnosing();
}

final class DiagnosisComplete extends DiagnosisState {
  const DiagnosisComplete({required this.diagnosis});

  final Diagnosis diagnosis;

  @override
  List<Object?> get props => [diagnosis];
}

final class DiagnosisHistoryLoaded extends DiagnosisState {
  const DiagnosisHistoryLoaded({required this.diagnoses});

  final List<Diagnosis> diagnoses;

  @override
  List<Object?> get props => [diagnoses];
}

final class DiagnosisError extends DiagnosisState {
  const DiagnosisError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
