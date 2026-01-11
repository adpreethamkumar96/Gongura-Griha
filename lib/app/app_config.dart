/// App Configuration
///
/// Holds environment-specific configuration values.
///
/// For production, pass keys via --dart-define:
/// flutter build apk --dart-define=RAZORPAY_KEY=rzp_live_xxx
class AppConfig {
  AppConfig._();

  /// Current environment
  static late Environment environment;

  /// API Base URL
  static late String apiBaseUrl;

  /// Razorpay Key (loaded from dart-define or fallback to test key)
  static late String razorpayKey;

  // Dart-define constants (passed at build time)
  static const String _razorpayKeyFromEnv = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: '',
  );
  static const String _apiBaseUrlFromEnv = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  /// Initialize configuration for the given environment
  static void init(Environment env) {
    environment = env;

    switch (env) {
      case Environment.development:
        _initDevelopment();
        break;
      case Environment.staging:
        _initStaging();
        break;
      case Environment.production:
        _initProduction();
        break;
    }
  }

  /// Development environment configuration
  static void _initDevelopment() {
    apiBaseUrl = 'http://localhost:3000/v1';
    // Use dart-define value if provided, otherwise use test key
    razorpayKey = _razorpayKeyFromEnv.isNotEmpty
        ? _razorpayKeyFromEnv
        : 'rzp_test_S2Z4miimMrBb10';
  }

  /// Staging environment configuration
  static void _initStaging() {
    apiBaseUrl = _apiBaseUrlFromEnv.isNotEmpty
        ? _apiBaseUrlFromEnv
        : 'https://staging-api.gongura-griha.com/v1';
    razorpayKey = _razorpayKeyFromEnv.isNotEmpty
        ? _razorpayKeyFromEnv
        : 'rzp_test_S2Z4miimMrBb10';
  }

  /// Production environment configuration
  static void _initProduction() {
    apiBaseUrl = _apiBaseUrlFromEnv.isNotEmpty
        ? _apiBaseUrlFromEnv
        : 'https://api.gongura-griha.com/v1';
    // CRITICAL: For production, ALWAYS pass RAZORPAY_KEY via --dart-define
    razorpayKey = _razorpayKeyFromEnv.isNotEmpty
        ? _razorpayKeyFromEnv
        : 'rzp_live_xxxxxxxxxxxx'; // Replace with actual live key

    // Warn if using placeholder in production
    assert(
      !razorpayKey.contains('xxxxxxxxxxxx'),
      'SECURITY WARNING: Razorpay key not configured! '
      'Pass via: flutter build --dart-define=RAZORPAY_KEY=rzp_live_xxx',
    );
  }

  /// Check if running in development
  static bool get isDevelopment => environment == Environment.development;

  /// Check if running in staging
  static bool get isStaging => environment == Environment.staging;

  /// Check if running in production
  static bool get isProduction => environment == Environment.production;

  /// Check if running in debug mode (dev or staging)
  static bool get isDebug => !isProduction;
}

/// Environment types
enum Environment {
  development,
  staging,
  production,
}
