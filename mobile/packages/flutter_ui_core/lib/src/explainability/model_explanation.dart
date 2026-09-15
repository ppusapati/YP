import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Why a vision model answered the way it did.
///
/// Produced by Grad-CAM over the serving model's feature map: a greyscale
/// heatmap of what the model actually looked at, brightest where the evidence
/// is, plus the region it keyed on and a sentence describing it.
///
/// A diagnosis carries no explanation when the answer came from a model that
/// cannot produce one — a demo detector, or an external provider. That case is
/// distinct from a model that looked everywhere and found nothing in
/// particular, which is what [localised] `false` means.
class ModelExplanation extends Equatable {
  const ModelExplanation({
    required this.task,
    required this.className,
    required this.heatmapPng,
    required this.heatmapWidth,
    required this.heatmapHeight,
    required this.focusX,
    required this.focusY,
    required this.focusWidth,
    required this.focusHeight,
    required this.focusCoverage,
    required this.summary,
    required this.method,
    required this.localised,
  });

  /// The vision task this explains, e.g. `disease`, `nutrient`, `pest`.
  final String task;

  /// The class the model predicted, which is what the heatmap explains.
  final String className;

  /// Greyscale PNG, brightest where the evidence is. Empty when the model
  /// could not produce one.
  final Uint8List heatmapPng;

  final int heatmapWidth;
  final int heatmapHeight;

  /// Region the model keyed on, normalised to [0,1] from the top left.
  ///
  /// Normalised rather than in pixels so it survives any resize of the photo
  /// it is drawn over — which on a phone is every photo, since the capture is
  /// far larger than the screen.
  final double focusX;
  final double focusY;
  final double focusWidth;
  final double focusHeight;

  /// Share of the image inside the focus region. Near 1 means nothing in
  /// particular was located.
  final double focusCoverage;

  /// A sentence describing where the model looked.
  final String summary;

  /// How the explanation was produced, e.g. `grad-cam`.
  final String method;

  /// False when the map was flat and there is nothing to point at.
  final bool localised;

  /// Whether there is a heatmap image to paint.
  ///
  /// Separate from [localised]: a model can return a valid but flat map, and
  /// painting that is honest — it shows the model spread its attention — while
  /// drawing a focus box around it would not be.
  bool get hasHeatmap =>
      heatmapPng.isNotEmpty && heatmapWidth > 0 && heatmapHeight > 0;

  /// Focus coverage as a percentage, for display.
  String get coveragePercent => '${(focusCoverage * 100).round()}%';

  /// Reads an explanation back out of the offline cache.
  ///
  /// The heatmap travels as base64 rather than as a byte list, because both
  /// apps cache rows through `json.encode`, which cannot serialise a
  /// `Uint8List` — it would silently become a list of integers three times the
  /// size and come back as `List<dynamic>`.
  factory ModelExplanation.fromJson(Map<String, dynamic> json) {
    final encoded = json['heatmap_png'] as String? ?? '';
    return ModelExplanation(
      task: json['task'] as String? ?? '',
      className: json['class_name'] as String? ?? '',
      heatmapPng: encoded.isEmpty ? Uint8List(0) : base64Decode(encoded),
      heatmapWidth: (json['heatmap_width'] as num?)?.toInt() ?? 0,
      heatmapHeight: (json['heatmap_height'] as num?)?.toInt() ?? 0,
      focusX: (json['focus_x'] as num?)?.toDouble() ?? 0.0,
      focusY: (json['focus_y'] as num?)?.toDouble() ?? 0.0,
      focusWidth: (json['focus_width'] as num?)?.toDouble() ?? 0.0,
      focusHeight: (json['focus_height'] as num?)?.toDouble() ?? 0.0,
      focusCoverage: (json['focus_coverage'] as num?)?.toDouble() ?? 0.0,
      summary: json['summary'] as String? ?? '',
      method: json['method'] as String? ?? '',
      localised: json['localised'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task': task,
      'class_name': className,
      'heatmap_png': heatmapPng.isEmpty ? '' : base64Encode(heatmapPng),
      'heatmap_width': heatmapWidth,
      'heatmap_height': heatmapHeight,
      'focus_x': focusX,
      'focus_y': focusY,
      'focus_width': focusWidth,
      'focus_height': focusHeight,
      'focus_coverage': focusCoverage,
      'summary': summary,
      'method': method,
      'localised': localised,
    };
  }

  @override
  List<Object?> get props => [
        task,
        className,
        heatmapPng,
        heatmapWidth,
        heatmapHeight,
        focusX,
        focusY,
        focusWidth,
        focusHeight,
        focusCoverage,
        summary,
        method,
        localised,
      ];
}
