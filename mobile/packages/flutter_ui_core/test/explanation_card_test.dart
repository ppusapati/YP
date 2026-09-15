import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ui_core/flutter_ui_core.dart';

/// A real 2x2 greyscale PNG, dark on the left and bright on the right.
///
/// A real one rather than arbitrary bytes because the card decodes it: a
/// placeholder would exercise the error path and prove nothing about the
/// path that matters.
final _png = Uint8List.fromList(const [
  137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, //
  0, 0, 0, 2, 0, 0, 0, 2, 8, 0, 0, 0, 0, 87, 221, 82, 248, //
  0, 0, 0, 14, 73, 68, 65, 84, 120, 156, 99, 80, 248, 192, 160, //
  240, 1, 0, 5, 150, 2, 33, 241, 151, 112, 33, //
  0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
]);

ModelExplanation _entity({
  bool localised = true,
  Uint8List? heatmap,
  double coverage = 0.18,
  String summary = 'The model keyed on the lower-left of the leaf.',
}) {
  return ModelExplanation(
    task: 'disease',
    className: 'Late blight',
    heatmapPng: heatmap ?? _png,
    heatmapWidth: 2,
    heatmapHeight: 2,
    focusX: 0.1,
    focusY: 0.55,
    focusWidth: 0.3,
    focusHeight: 0.35,
    focusCoverage: coverage,
    summary: summary,
    method: 'grad-cam',
    localised: localised,
  );
}

void main() {
  group('ModelExplanation', () {
    test('survives the JSON round trip the offline cache puts it through', () {
      // Both apps cache rows with json.encode, which cannot serialise a
      // Uint8List — so the heatmap goes out as base64 and has to come back as
      // the same bytes, not as a list of integers.
      final before = _entity();
      final encoded = json.encode(before.toJson());
      final after = ModelExplanation.fromJson(
        json.decode(encoded) as Map<String, dynamic>,
      );

      expect(after, before);
      expect(after.heatmapPng, _png);
    });

    test('an absent heatmap stays absent rather than becoming empty bytes', () {
      final json_ = _entity(heatmap: Uint8List(0)).toJson();

      expect(json_['heatmap_png'], '');

      final back = ModelExplanation.fromJson(json_);
      expect(back.heatmapPng, isEmpty);
      expect(back.hasHeatmap, isFalse);
    });

    test('hasHeatmap is false when the dimensions are zero', () {
      // A model can return bytes with no dimensions; painting those stretches
      // an undefined frame over the photo.
      final e = ModelExplanation(
        task: 'disease',
        className: 'Late blight',
        heatmapPng: _png,
        heatmapWidth: 0,
        heatmapHeight: 0,
        focusX: 0,
        focusY: 0,
        focusWidth: 0,
        focusHeight: 0,
        focusCoverage: 1,
        summary: '',
        method: '',
        localised: false,
      );
      expect(e.hasHeatmap, isFalse);
    });

    test('coveragePercent rounds for display', () {
      expect(_entity(coverage: 0.184).coveragePercent, '18%');
      expect(_entity(coverage: 1).coveragePercent, '100%');
    });
  });

  group('analysedImageProvider', () {
    test('decodes a data URI, which is what uploadImage produces', () {
      final uri = Uri.dataFromBytes(_png, mimeType: 'image/png').toString();
      expect(analysedImageProvider(uri), isA<MemoryImage>());
    });

    test('uses the network for an http URL', () {
      expect(
        analysedImageProvider('https://example.test/leaf.jpg'),
        isA<NetworkImage>(),
      );
    });

    test('falls back to a file for a local path', () {
      expect(analysedImageProvider('/tmp/leaf.jpg'), isA<FileImage>());
    });

    test('returns null for an empty path rather than an unloadable file', () {
      expect(analysedImageProvider(''), isNull);
    });

    test('returns null for a malformed data URI instead of throwing', () {
      expect(analysedImageProvider('data:not-a-real-uri'), isNull);
    });
  });

  group('ExplanationSection', () {
    Future<void> pump(WidgetTester tester, List<ModelExplanation> xs) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ExplanationSection(
                explanations: xs,
                imagePath: '',
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('says the model cannot explain itself when there is nothing',
        (tester) async {
      await pump(tester, const []);

      expect(find.text('Why this answer'), findsOneWidget);
      expect(
        find.textContaining('cannot show its working'),
        findsOneWidget,
        reason: 'an absent section reads as a UI that forgot',
      );
    });

    testWidgets('shows the summary and the focus share', (tester) async {
      await pump(tester, [_entity()]);

      expect(
        find.text('The model keyed on the lower-left of the leaf.'),
        findsOneWidget,
      );
      expect(find.text('18%'), findsOneWidget);
      expect(find.text('Late blight'), findsOneWidget);
    });

    testWidgets('warns when the model did not settle anywhere', (tester) async {
      await pump(tester, [_entity(localised: false, coverage: 0.97)]);

      expect(find.textContaining('spread its attention'), findsOneWidget);
      expect(
        find.text('97%'),
        findsNothing,
        reason: 'a focus share is meaningless when nothing was focused on',
      );
    });

    testWidgets('the overlay can be turned off to see the photo',
        (tester) async {
      await pump(tester, [_entity()]);

      expect(find.text('Hide'), findsOneWidget);
      expect(find.byType(Image), findsWidgets);

      // The card is a 4:3 photo plus its caption, which is taller than the
      // default test surface — so the button has to be scrolled to before it
      // can be tapped, exactly as on a phone.
      await tester.ensureVisible(find.text('Hide'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide'));
      await tester.pump();

      expect(find.text('Show'), findsOneWidget);
    });

    testWidgets('offers no toggle when there is no heatmap to hide',
        (tester) async {
      await pump(tester, [_entity(heatmap: Uint8List(0))]);

      expect(find.text('Hide'), findsNothing);
      expect(find.text('Show'), findsNothing);
      expect(
        find.text('The model keyed on the lower-left of the leaf.'),
        findsOneWidget,
        reason: 'the sentence is still worth showing without the map',
      );
    });

    testWidgets('renders one card per analysed photo', (tester) async {
      await pump(tester, [
        _entity(summary: 'First photo.'),
        _entity(summary: 'Second photo.'),
      ]);

      expect(find.byType(ExplanationCard), findsNWidgets(2));
      expect(find.text('First photo.'), findsOneWidget);
      expect(find.text('Second photo.'), findsOneWidget);
    });
  });
}
