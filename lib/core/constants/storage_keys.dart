/// Storage Keys for Gongura-Griha
///
/// Contains all keys used for local storage (SharedPreferences, Hive, SecureStorage).
class StorageKeys {
  StorageKeys._();

  /// Secure Storage Keys (for sensitive data)
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';

  /// SharedPreferences Keys
  static const String isFirstLaunch = 'is_first_launch';
  static const String isLoggedIn = 'is_logged_in';
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userPhone = 'user_phone';
  static const String userEmail = 'user_email';
  static const String userAvatar = 'user_avatar';
  static const String fcmToken = 'fcm_token';
  static const String selectedAddressId = 'selected_address_id';
  static const String lastSyncTime = 'last_sync_time';
  static const String appTheme = 'app_theme';
  static const String appLanguage = 'app_language';
  static const String notificationsEnabled = 'notifications_enabled';

  /// Hive Box Names
  static const String cartBox = 'cart_box';
  static const String wishlistBox = 'wishlist_box';
  static const String productsBox = 'products_box';
  static const String categoriesBox = 'categories_box';
  static const String addressesBox = 'addresses_box';
  static const String ordersBox = 'orders_box';
  static const String searchHistoryBox = 'search_history_box';
  static const String notificationsBox = 'notifications_box';
}
