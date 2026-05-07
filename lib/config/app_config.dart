class AppConfig {
  AppConfig._();

  // Android emulator → host machine localhost
  // For real device: change to your machine's local IP e.g. http://192.168.1.x:5000/api
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );

  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://10.0.2.2:5000',
  );

  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  // Token lifetimes (mirrors backend)
  static const Duration accessTokenLifetime  = Duration(minutes: 15);
  static const Duration refreshTokenLifetime = Duration(days: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // Run tracking
  static const int gpsDistanceFilterMeters = 5;
  static const int gpsIntervalMs           = 5000;

  // Search debounce
  static const Duration searchDebounce = Duration(milliseconds: 300);
}
