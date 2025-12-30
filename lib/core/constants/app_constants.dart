/// Application Constants for Gongura-Griha
///
/// Contains all app-wide constants like dimensions, durations, and limits.
class AppConstants {
  AppConstants._();

  /// App Info
  static const String appName = 'Gongura-Griha';
  static const String appTagline = 'Authentic Gongura Delights';

  /// Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  /// Cart Limits
  static const int minQuantity = 1;
  static const int maxQuantity = 10;

  /// OTP
  static const int otpLength = 6;
  static const int otpResendTimeout = 30; // seconds
  static const int otpExpiryTime = 300; // seconds (5 minutes)
  static const int maxOtpAttempts = 3;

  /// Image Quality
  static const int imageQuality = 85;
  static const int maxImageSize = 5; // MB

  /// Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 250);
  static const Duration animationSlow = Duration(milliseconds: 400);

  /// Debounce
  static const Duration searchDebounce = Duration(milliseconds: 500);

  /// Cache Durations
  static const Duration cacheProductsDuration = Duration(hours: 1);
  static const Duration cacheCategoriesDuration = Duration(hours: 6);
  static const Duration cacheHomeDuration = Duration(minutes: 30);

  /// Delivery
  static const double freeDeliveryThreshold = 499.0;
  static const double standardDeliveryCharge = 49.0;
  static const double codExtraCharge = 40.0;
  static const double maxCodAmount = 5000.0;

  /// Tax
  static const double gstPercentage = 5.0;

  /// Support
  static const String supportPhone = '+919876543210';
  static const String supportEmail = 'support@gongura-griha.com';
  static const String supportWhatsApp = '+919876543210';

  /// Social Links
  static const String instagramUrl = 'https://instagram.com/gongura_griha';
  static const String facebookUrl = 'https://facebook.com/gongura.griha';

  /// Policy URLs
  static const String termsUrl = 'https://gongura-griha.com/terms';
  static const String privacyUrl = 'https://gongura-griha.com/privacy';
  static const String refundUrl = 'https://gongura-griha.com/refund';

  /// Regex Patterns
  static final RegExp phoneRegex = RegExp(r'^[6-9]\d{9}$');
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp pinCodeRegex = RegExp(r'^[1-9][0-9]{5}$');
  static final RegExp otpRegex = RegExp(r'^\d{6}$');
  static final RegExp nameRegex = RegExp(r'^[a-zA-Z\s]{2,100}$');
}
