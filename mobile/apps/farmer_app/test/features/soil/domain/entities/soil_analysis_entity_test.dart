import 'package:farmer_app/features/soil/domain/entities/soil_analysis_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SoilAnalysis', () {
    group('pHClassification', () {
      test('returns Acidic for pH below 5.5', () {
        final analysis = _makeAnalysis(pH: 4.5);
        expect(analysis.pHClassification, 'Acidic');
      });

      test('returns Slightly Acidic for pH 5.5-6.5', () {
        final analysis = _makeAnalysis(pH: 6.0);
        expect(analysis.pHClassification, 'Slightly Acidic');
      });

      test('returns Neutral for pH 6.5-7.5', () {
        final analysis = _makeAnalysis(pH: 7.0);
        expect(analysis.pHClassification, 'Neutral');
      });

      test('returns Slightly Alkaline for pH 7.5-8.5', () {
        final analysis = _makeAnalysis(pH: 8.0);
        expect(analysis.pHClassification, 'Slightly Alkaline');
      });

      test('returns Alkaline for pH above 8.5', () {
        final analysis = _makeAnalysis(pH: 9.0);
        expect(analysis.pHClassification, 'Alkaline');
      });

      test('returns Neutral at exactly 6.5', () {
        final analysis = _makeAnalysis(pH: 6.5);
        expect(analysis.pHClassification, 'Neutral');
      });
    });

    group('fertilityRating', () {
      test('returns Excellent for optimal soil', () {
        final analysis = _makeAnalysis(
          pH: 6.5,
          organicCarbon: 3.0,
          nitrogen: 300.0,
          phosphorus: 50.0,
          potassium: 300.0,
        );
        expect(analysis.fertilityRating, 'Excellent');
      });

      test('returns Good for reasonable soil', () {
        final analysis = _makeAnalysis(
          pH: 6.5,
          organicCarbon: 2.0,
          nitrogen: 200.0,
          phosphorus: 30.0,
          potassium: 200.0,
        );
        expect(analysis.fertilityRating, 'Good');
      });

      test('returns Very Low for depleted soil', () {
        final analysis = _makeAnalysis(
          pH: 3.5,
          organicCarbon: 0.1,
          nitrogen: 10.0,
          phosphorus: 2.0,
          potassium: 10.0,
        );
        expect(analysis.fertilityRating, 'Very Low');
      });

      test('returns Moderate for average soil', () {
        final analysis = _makeAnalysis(
          pH: 6.5,
          organicCarbon: 1.2,
          nitrogen: 120.0,
          phosphorus: 15.0,
          potassium: 120.0,
        );
        expect(analysis.fertilityRating, 'Moderate');
      });
    });

    group('copyWith', () {
      test('creates copy with changed fields', () {
        final original = _makeAnalysis(pH: 6.5, fieldName: 'North Field');
        final copy = original.copyWith(pH: 7.0, fieldName: 'South Field');

        expect(copy.pH, 7.0);
        expect(copy.fieldName, 'South Field');
        expect(copy.id, original.id);
        expect(copy.nitrogen, original.nitrogen);
      });

      test('preserves all fields when no arguments given', () {
        final original = _makeAnalysis(pH: 6.5);
        final copy = original.copyWith();

        expect(copy, original);
      });
    });

    group('equality', () {
      test('two analyses with same props are equal', () {
        final a = _makeAnalysis(pH: 6.5);
        final b = _makeAnalysis(pH: 6.5);

        expect(a, b);
      });

      test('two analyses with different pH are not equal', () {
        final a = _makeAnalysis(pH: 6.5);
        final b = _makeAnalysis(pH: 7.0);

        expect(a, isNot(b));
      });
    });
  });
}

SoilAnalysis _makeAnalysis({
  double pH = 6.5,
  double organicCarbon = 2.0,
  double nitrogen = 180.0,
  double phosphorus = 35.0,
  double potassium = 220.0,
  String? fieldName,
}) {
  return SoilAnalysis(
    id: 'soil-test',
    fieldId: 'field-1',
    pH: pH,
    organicCarbon: organicCarbon,
    nitrogen: nitrogen,
    phosphorus: phosphorus,
    potassium: potassium,
    texture: SoilTexture.loamy,
    analysisDate: DateTime(2024, 6, 10),
    fieldName: fieldName,
  );
}
