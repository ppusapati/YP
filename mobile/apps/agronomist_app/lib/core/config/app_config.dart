/// Application configuration constants.
///
/// Network-related values are overridable via `--dart-define` at build time:
///   flutter run --dart-define=API_BASE_URL=localhost \
///               --dart-define=API_PORT=8080 \
///               --dart-define=API_USE_TLS=false
abstract final class AppConfig {
  /// API base URL (override: `--dart-define=API_BASE_URL=...`).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'api.yieldpoint.io',
  );

  /// API port (override: `--dart-define=API_PORT=...`).
  static const int apiPort = int.fromEnvironment('API_PORT', defaultValue: 443);

  /// Whether to use TLS (override: `--dart-define=API_USE_TLS=false`).
  static const bool apiUseTls = bool.fromEnvironment(
    'API_USE_TLS',
    defaultValue: true,
  );

  /// Default API request timeout.
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Number of API retry attempts.
  static const int apiRetryCount = 3;

  /// Map tile style URL (override: `--dart-define=MAP_STYLE_URL=...`).
  static const String mapStyleUrl = String.fromEnvironment(
    'MAP_STYLE_URL',
    defaultValue: 'https://tiles.yieldpoint.io/styles/satellite/style.json',
  );

  /// Fallback map style URL.
  static const String fallbackMapStyleUrl =
      'https://demotiles.maplibre.org/style.json';

  /// Default map zoom level.
  static const double defaultMapZoom = 14.0;

  /// Minimum map zoom level.
  static const double minMapZoom = 4.0;

  /// Maximum map zoom level.
  static const double maxMapZoom = 22.0;

  /// Maximum image dimension for compression.
  static const int maxImageDimension = 1920;

  /// JPEG quality for compressed images (0-100).
  static const int imageQuality = 85;

  /// Maximum number of photos per inspection.
  static const int maxPhotosPerInspection = 20;

  /// Cache duration for offline data.
  static const Duration cacheDuration = Duration(hours: 24);

  /// Background sync interval.
  static const Duration backgroundSyncInterval = Duration(minutes: 15);

  /// App name.
  static const String appName = 'YieldPoint Agronomist';

  /// Support email.
  static const String supportEmail = 'support@yieldpoint.io';
}
