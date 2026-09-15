import 'dart:convert';
import 'dart:typed_data';

import 'package:agronomist_app/features/plant_diagnosis/data/models/diagnosis_model.dart';
import 'package:agronomist_app/features/plant_diagnosis/data/models/explanation_mapper.dart';
import 'package:flutter_proto/src/generated/diagnosis.pb.dart' as pb;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart' show ModelExplanation;

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
      // Field by field: a mapper that transposes focusX and focusY produces an
      // explanation that points confidently at the wrong part of the leaf, and
      // an agronomist would have no way to tell.
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
        summary: 'Keyed on the lower-left of the leaf.',
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
      expect(e.summary, 'Keyed on the lower-left of the leaf.');
      expect(e.method, 'grad-cam');
      expect(e.localised, isTrue);
    });

    test('the heatmap outlives the protobuf message it came from', () {
      final proto = pb.Explanation(heatmapPng: _png);
      final e = modelExplanationFromProto(proto);

      proto.clearHeatmapPng();

      expect(e.heatmapPng, _png);
    });
  });

  group('DiagnosisModel', () {
    ModelExplanation explanation() => modelExplanationFromProto(pb.Explanation(
          task: 'disease',
          className: 'Late blight',
          heatmapPng: _png,
          heatmapWidth: 2,
          heatmapHeight: 2,
          focusCoverage: 0.18,
          summary: 'Keyed on the lower-left of the leaf.',
          method: 'grad-cam',
          localised: true,
        ));

    DiagnosisModel model({List<ModelExplanation> explanations = const []}) {
      return DiagnosisModel(
        id: 'diag-1',
        fieldId: 'field-1',
        diseaseName: 'Late blight',
        confidence: 0.82,
        severity: 'severe',
        treatment: 'Copper fungicide, 7-day interval.',
        imageUrl: 'https://example.test/leaf.jpg',
        explanations: explanations,
        diagnosedAt: DateTime.utc(2026, 3, 14, 9, 30),
      );
    }

    test('carries explanations through to the entity', () {
      final e = model(explanations: [explanation()]).toEntity();

      expect(e.explanations, hasLength(1));
      expect(e.explanations.single.className, 'Late blight');
      expect(e.explanations.single.hasHeatmap, isTrue);
    });

    test('survives the JSON round trip the offline cache puts it through', () {
      // json.encode cannot serialise a Uint8List, so the heatmap has to travel
      // as base64 and come back as the same bytes — otherwise a cached
      // diagnosis shows a broken overlay while a fresh one shows the map.
      final before = model(explanations: [explanation()]);
      final after = DiagnosisModel.fromJson(
        json.decode(json.encode(before.toJson())) as Map<String, dynamic>,
      );

      expect(after.explanations, hasLength(1));
      expect(after.explanations.single.heatmapPng, _png);
      expect(after.toEntity().explanations, before.toEntity().explanations);
    });

    test('a diagnosis with no explanations round-trips as having none', () {
      // Distinct from "the field is missing": both have to end up empty rather
      // than throwing, because older cached rows predate the field entirely.
      final encoded = model().toJson();
      expect(encoded['explanations'], isEmpty);

      final withoutKey = Map<String, dynamic>.from(encoded)
        ..remove('explanations');
      expect(DiagnosisModel.fromJson(withoutKey).explanations, isEmpty);
    });
  });
}
