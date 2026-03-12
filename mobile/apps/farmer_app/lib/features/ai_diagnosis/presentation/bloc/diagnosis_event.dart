import 'dart:typed_data';

import 'package:equatable/equatable.dart';

sealed class DiagnosisEvent extends Equatable {
  const DiagnosisEvent();

  @override
  List<Object?> get props => [];
}

final class CaptureImage extends DiagnosisEvent {
  const CaptureImage();
}

final class UploadImage extends DiagnosisEvent {
  const UploadImage({
    required this.imageBytes,
    required this.fileName,
  });

  final Uint8List imageBytes;
  final String fileName;

  @override
  List<Object?> get props => [fileName];
}

final class SubmitDiagnosis extends DiagnosisEvent {
  const SubmitDiagnosis({
    required this.fieldId,
    required this.imagePath,
  });

  final String fieldId;
  final String imagePath;

  @override
  List<Object?> get props => [fieldId, imagePath];
}

final class LoadDiagnosisHistory extends DiagnosisEvent {
  const LoadDiagnosisHistory({this.fieldId});

  final String? fieldId;

  @override
  List<Object?> get props => [fieldId];
}
