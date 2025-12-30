/// App Configuration
///
/// Holds environment-specific configuration values.
class AppConfig {
  AppConfig._();

  /// Current environment
  static late Environment environment;

  /// API Base URL
  static late String apiBaseUrl;

  /// Razorpay Key
  static late String razorpayKey;

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
    razorpayKey = 'rzp_test_xxxxxxxxxxxx'; // Replace with actual test key
  }

  /// Staging environment configuration
  static void _initStaging() {
    apiBaseUrl = 'https://staging-api.gongura-griha.com/v1';
    razorpayKey = 'rzp_test_xxxxxxxxxxxx'; // Replace with actual test key
  }

  /// Production environment configuration
  static void _initProduction() {
    apiBaseUrl = 'https://api.gongura-griha.com/v1';
    razorpayKey = 'rzp_live_xxxxxxxxxxxx'; // Replace with actual live key
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
