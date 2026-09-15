import 'dart:typed_data';

import 'package:flutter_proto/src/generated/diagnosis.pb.dart' as pb;
import 'package:flutter_ui_core/flutter_ui_core.dart' show ModelExplanation;

/// Maps the service's `Explanation` onto the shared presentation type.
///
/// The JSON half lives on [ModelExplanation] itself because both apps cache
/// the same shape; only this proto step is per-app, because only the data
/// layer knows which generated message it is reading.
ModelExplanation modelExplanationFromProto(pb.Explanation proto) {
  return ModelExplanation(
    task: proto.task,
    className: proto.className,
    // A copy rather than the protobuf-owned list: the message is discarded
    // right after mapping and the bytes outlive it in the widget tree.
    heatmapPng: Uint8List.fromList(proto.heatmapPng),
    heatmapWidth: proto.heatmapWidth,
    heatmapHeight: proto.heatmapHeight,
    focusX: proto.focusX,
    focusY: proto.focusY,
    focusWidth: proto.focusWidth,
    focusHeight: proto.focusHeight,
    focusCoverage: proto.focusCoverage,
    summary: proto.summary,
    method: proto.method,
    localised: proto.localised,
  );
}
