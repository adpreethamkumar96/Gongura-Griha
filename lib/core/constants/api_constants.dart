/// API Constants for Gongura-Griha
///
/// Contains all API endpoint configurations and URLs.
/// These values are set based on the current environment.
class ApiConstants {
  ApiConstants._();

  /// API Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// API Version
  static const String apiVersion = 'v1';

  /// Auth Endpoints
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String socialGoogle = '/auth/social/google';

  /// User Endpoints
  static const String profile = '/users/profile';
  static const String avatar = '/users/avatar';
  static const String fcmToken = '/users/fcm-token';
  static const String addresses = '/users/addresses';

  /// Product Endpoints
  static const String products = '/products';
  static const String productSearch = '/products/search';
  static const String categories = '/categories';

  /// Cart Endpoints
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static const String cartCoupon = '/cart/coupon';

  /// Wishlist Endpoints
  static const String wishlist = '/wishlist';

  /// Order Endpoints
  static const String orders = '/orders';
  static const String verifyPayment = '/verify-payment';

  /// Delivery Endpoints
  static const String checkDelivery = '/delivery/check';

  /// Notification Endpoints
  static const String notifications = '/notifications';

  /// Home Endpoints
  static const String home = '/home';
  static const String config = '/config';

  /// Support Endpoints
  static const String support = '/support/contact';
}
