/// Shared UI components, theming, design tokens, and common widgets
/// for the YieldPoint precision agriculture mobile app.
library flutter_ui_core;

// ─── Theme ──────────────────────────────────────────────────────────
export 'src/theme/app_colors.dart';
export 'src/theme/app_theme.dart';
export 'src/theme/app_typography.dart';

// ─── Widgets ────────────────────────────────────────────────────────
export 'src/widgets/alert_banner.dart';
export 'src/widgets/confidence_indicator.dart';
export 'src/widgets/empty_state.dart';
export 'src/widgets/error_view.dart';
export 'src/widgets/image_capture_button.dart';
export 'src/widgets/layer_toggle.dart';
export 'src/widgets/loading_overlay.dart';
export 'src/widgets/metric_tile.dart';
export 'src/widgets/section_header.dart';
export 'src/widgets/sensor_gauge.dart';
export 'src/widgets/stat_card.dart';

// ─── Charts ─────────────────────────────────────────────────────────
export 'src/charts/crop_growth_chart.dart';
export 'src/charts/ndvi_chart.dart';
export 'src/charts/sensor_chart.dart';
export 'src/charts/soil_chart.dart';
export 'src/charts/water_stress_chart.dart';
export 'src/charts/yield_chart.dart';

// ─── Animations ─────────────────────────────────────────────────────
export 'src/animations/fade_slide_transition.dart';
export 'src/animations/pulse_animation.dart';
