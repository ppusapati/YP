import 'dart:typed_data';

import 'package:farmer_app/features/ai_diagnosis/data/models/explanation_mapper.dart';
import 'package:flutter_proto/src/generated/diagnosis.pb.dart' as pb;
import 'package:flutter_test/flutter_test.dart';

/// A real 2x2 greyscale PNG, dark on the left and bright on the right.
final _png = Uint8List.fromList(const [
  137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, //
  0, 0, 0, 2, 0, 0, 0, 2, 8, 0, 0, 0, 0, 87, 221, 82, 248, //
  0, 0, 0, 14, 73, 68, 65, 84, 120, 156, 99, 80, 248, 192, 160, //
  240, 1, 0, 5, 150, 2, 33, 241, 151, 112, 33, //
  0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
]);

void main() {
  group('modelExplanationFromProto', () {
    test('reads every field off the message', () {
      // Field by field rather than by equality: a mapper that transposes
      // focusX and focusY, or width and height, produces an explanation that
      // points confidently at the wrong part of the leaf, and no round-trip
      // check would notice.
      final e = modelExplanationFromProto(pb.Explanation(
        task: 'disease',
        className: 'Late blight',
        heatmapPng: _png,
        heatmapWidth: 24,
        heatmapHeight: 32,
        focusX: 0.1,
        focusY: 0.55,
        focusWidth: 0.3,
        focusHeight: 0.35,
        focusCoverage: 0.18,
        summary: 'The model keyed on the lower-left of the leaf.',
        method: 'grad-cam',
        localised: true,
      ));

      expect(e.task, 'disease');
      expect(e.className, 'Late blight');
      expect(e.heatmapPng, _png);
      expect(e.heatmapWidth, 24);
      expect(e.heatmapHeight, 32);
      expect(e.focusX, closeTo(0.1, 1e-9));
      expect(e.focusY, closeTo(0.55, 1e-9));
      expect(e.focusWidth, closeTo(0.3, 1e-9));
      expect(e.focusHeight, closeTo(0.35, 1e-9));
      expect(e.focusCoverage, closeTo(0.18, 1e-9));
      expect(e.summary, 'The model keyed on the lower-left of the leaf.');
      expect(e.method, 'grad-cam');
      expect(e.localised, isTrue);
    });

    test('an explanation with no heatmap maps to one with no heatmap', () {
      // What the service sends when the serving model cannot explain itself
      // but still reports which class it answered.
      final e = modelExplanationFromProto(pb.Explanation(
        task: 'disease',
        className: 'Late blight',
        localised: false,
      ));

      expect(e.hasHeatmap, isFalse);
      expect(e.localised, isFalse);
    });

    test('the heatmap outlives the protobuf message it came from', () {
      // The message is discarded right after mapping; a view onto its buffer
      // would be a use-after-free waiting for a widget rebuild.
      final proto = pb.Explanation(heatmapPng: _png);
      final e = modelExplanationFromProto(proto);

      proto.clearHeatmapPng();

      expect(e.heatmapPng, _png);
    });
  });
}
