import 'package:flutter/material.dart';

/// Design tokens: color constants for the YieldPoint precision agriculture app.
abstract final class AppColors {
  // ─── Primary: Greens ───────────────────────────────────────────────
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);
  static const Color primaryContainer = Color(0xFFC8E6C9);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF002204);

  // ─── Secondary: Earth Brown ────────────────────────────────────────
  static const Color secondary = Color(0xFF6D4C41);
  static const Color secondaryLight = Color(0xFF9C786C);
  static const Color secondaryDark = Color(0xFF40241A);
  static const Color secondaryContainer = Color(0xFFD7CCC8);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF1B0E0A);

  // ─── Accent / Tertiary: Sky Blue ──────────────────────────────────
  static const Color accent = Color(0xFF0288D1);
  static const Color accentLight = Color(0xFF5EB8FF);
  static const Color accentDark = Color(0xFF005B9F);
  static const Color accentContainer = Color(0xFFB3E5FC);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color onAccentContainer = Color(0xFF001E2E);

  // ─── Neutral / Surface ────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAF5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F4EC);
  static const Color onBackground = Color(0xFF1B1C18);
  static const Color onSurface = Color(0xFF1B1C18);
  static const Color onSurfaceVariant = Color(0xFF44483E);
  static const Color outline = Color(0xFF75796D);
  static const Color outlineVariant = Color(0xFFC5C8BA);

  // ─── Dark theme surfaces ──────────────────────────────────────────
  static const Color darkBackground = Color(0xFF1B1C18);
  static const Color darkSurface = Color(0xFF252620);
  static const Color darkSurfaceVariant = Color(0xFF2F312A);
  static const Color darkOnBackground = Color(0xFFE3E3DB);
  static const Color darkOnSurface = Color(0xFFE3E3DB);
  static const Color darkOnSurfaceVariant = Color(0xFFC5C8BA);

  // ─── Semantic ─────────────────────────────────────────────────────
  static const Color error = Color(0xFFD32F2F);
  static const Color errorContainer = Color(0xFFFCDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF410002);

  static const Color success = Color(0xFF388E3C);
  static const Color successContainer = Color(0xFFC8E6C9);
  static const Color warning = Color(0xFFF9A825);
  static const Color warningContainer = Color(0xFFFFF9C4);
  static const Color info = Color(0xFF0288D1);
  static const Color infoContainer = Color(0xFFB3E5FC);

  // ─── NDVI Gradient (0 → 1) ────────────────────────────────────────
  /// Bare soil / dead vegetation (0.0)
  static const Color ndvi0 = Color(0xFFD32F2F);

  /// Sparse vegetation (0.2)
  static const Color ndvi20 = Color(0xFFFF7043);

  /// Moderate stress (0.4)
  static const Color ndvi40 = Color(0xFFFDD835);

  /// Moderate health (0.6)
  static const Color ndvi60 = Color(0xFF9CCC65);

  /// Healthy vegetation (0.8)
  static const Color ndvi80 = Color(0xFF43A047);

  /// Peak health (1.0)
  static const Color ndvi100 = Color(0xFF1B5E20);

  static const List<Color> ndviGradient = [
    ndvi0,
    ndvi20,
    ndvi40,
    ndvi60,
    ndvi80,
    ndvi100,
  ];

  static const List<double> ndviStops = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0];

  /// Returns an interpolated NDVI colour for a value in 0..1.
  static Color ndviColor(double value) {
    final v = value.clamp(0.0, 1.0);
    for (var i = 0; i < ndviStops.length - 1; i++) {
      if (v <= ndviStops[i + 1]) {
        final t =
            (v - ndviStops[i]) / (ndviStops[i + 1] - ndviStops[i]);
        return Color.lerp(ndviGradient[i], ndviGradient[i + 1], t)!;
      }
    }
    return ndvi100;
  }

  // ─── Pest Risk ────────────────────────────────────────────────────
  static const Color pestLow = Color(0xFF4CAF50);
  static const Color pestModerate = Color(0xFFFDD835);
  static const Color pestHigh = Color(0xFFFF9800);
  static const Color pestCritical = Color(0xFFD32F2F);

  static const List<Color> pestRiskGradient = [
    pestLow,
    pestModerate,
    pestHigh,
    pestCritical,
  ];

  static Color pestRiskColor(double risk) {
    final r = risk.clamp(0.0, 1.0);
    if (r < 0.33) return Color.lerp(pestLow, pestModerate, r / 0.33)!;
    if (r < 0.66) return Color.lerp(pestModerate, pestHigh, (r - 0.33) / 0.33)!;
    return Color.lerp(pestHigh, pestCritical, (r - 0.66) / 0.34)!;
  }

  // ─── Soil Fertility ───────────────────────────────────────────────
  static const Color soilVeryLow = Color(0xFFD32F2F);
  static const Color soilLow = Color(0xFFFF9800);
  static const Color soilMedium = Color(0xFFFDD835);
  static const Color soilHigh = Color(0xFF66BB6A);
  static const Color soilVeryHigh = Color(0xFF2E7D32);

  static const List<Color> soilFertilityGradient = [
    soilVeryLow,
    soilLow,
    soilMedium,
    soilHigh,
    soilVeryHigh,
  ];

  static Color soilFertilityColor(double fertility) {
    final f = fertility.clamp(0.0, 1.0);
    final idx = (f * (soilFertilityGradient.length - 1)).floor();
    final next = idx < soilFertilityGradient.length - 1 ? idx + 1 : idx;
    final t = (f * (soilFertilityGradient.length - 1)) - idx;
    return Color.lerp(soilFertilityGradient[idx], soilFertilityGradient[next], t)!;
  }

  // ─── Sensor Status ────────────────────────────────────────────────
  static const Color sensorOnline = Color(0xFF4CAF50);
  static const Color sensorWarning = Color(0xFFFFA000);
  static const Color sensorOffline = Color(0xFF9E9E9E);
  static const Color sensorError = Color(0xFFD32F2F);
  static const Color sensorLowBattery = Color(0xFFFF5722);

  // ─── Miscellaneous ────────────────────────────────────────────────
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x29000000);
  static const Color scrim = Color(0x52000000);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
