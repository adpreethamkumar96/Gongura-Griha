import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/app_config.dart';
import '../../firebase_options.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/wishlist_repository.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../services/address_service.dart';
import '../services/auth_service.dart';
import '../services/inventory_service.dart';
import '../services/notification_service.dart';
import '../services/order_service.dart';
import '../services/payment_service.dart';
import '../services/coupon_service.dart';
import '../services/user_profile_service.dart';
import '../services/saved_payment_service.dart';
import '../services/analytics_service.dart';
import '../services/push_notification_service.dart';
import '../services/wishlist_service.dart';

/// Global service locator instance
final getIt = GetIt.instance;

/// Initialize all dependencies
///
/// This must be called before running the app.
Future<void> configureDependencies() async {
  // ============ Firebase ============
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ============ Hive (Local Storage) ============
  await Hive.initFlutter();

  // ============ External Dependencies ============

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Connectivity
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // ============ Core Dependencies ============

  // Network Info
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<Connectivity>()),
  );

  // API Client
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: AppConfig.apiBaseUrl),
  );

  // ============ Services ============

  // Auth Service
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // Inventory Service (real-time Firestore)
  final inventoryService = InventoryService();
  await inventoryService.init();
  getIt.registerSingleton<InventoryService>(inventoryService);

  // Order Service (Firestore)
  getIt.registerLazySingleton<OrderService>(() => OrderService());

  // Address Service (Firestore)
  getIt.registerLazySingleton<AddressService>(() => AddressService());

  // Notification Service (Firestore)
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());

  // Wishlist Service (Firestore cloud sync)
  getIt.registerLazySingleton<WishlistService>(() => WishlistService());

  // Payment Service (Razorpay)
  final paymentService = PaymentService();
  paymentService.init();
  getIt.registerSingleton<PaymentService>(paymentService);

  // Coupon Service (Firestore)
  getIt.registerLazySingleton<CouponService>(() => CouponService());

  // User Profile Service (Firestore + Storage)
  getIt.registerLazySingleton<UserProfileService>(() => UserProfileService());

  // Saved Payment Methods Service (Firestore)
  getIt.registerLazySingleton<SavedPaymentService>(() => SavedPaymentService());

  // Push Notification Service (FCM)
  final pushNotificationService = PushNotificationService();
  await pushNotificationService.init();
  getIt.registerSingleton<PushNotificationService>(pushNotificationService);

  // Analytics Service
  getIt.registerLazySingleton<AnalyticsService>(() => AnalyticsService());

  // ============ Repositories ============

  // Cart Repository
  final cartRepository = CartRepository();
  await cartRepository.init();
  getIt.registerSingleton<CartRepository>(cartRepository);

  // Wishlist Repository
  final wishlistRepository = WishlistRepository();
  await wishlistRepository.init();
  getIt.registerSingleton<WishlistRepository>(wishlistRepository);

  // ============ Use Cases ============

  // TODO: Register use cases here as needed
  // Example:
  // getIt.registerLazySingleton(() => AddToCartUseCase(getIt()));

  // ============ BLoCs ============

  // TODO: Register BLoCs here as needed
  // Example:
  // getIt.registerFactory(() => CartBloc(cartRepository: getIt()));
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  // Close Hive boxes
  if (getIt.isRegistered<CartRepository>()) {
    await getIt<CartRepository>().close();
  }
  if (getIt.isRegistered<WishlistRepository>()) {
    await getIt<WishlistRepository>().close();
  }
  if (getIt.isRegistered<InventoryService>()) {
    await getIt<InventoryService>().close();
  }
  if (getIt.isRegistered<PaymentService>()) {
    getIt<PaymentService>().dispose();
  }

  await getIt.reset();
}

/// Get the cart repository instance
CartRepository get cartRepository => getIt<CartRepository>();

/// Get the wishlist repository instance
WishlistRepository get wishlistRepository => getIt<WishlistRepository>();

/// Get the auth service instance
AuthService get authService => getIt<AuthService>();

/// Get the inventory service instance
InventoryService get inventoryService => getIt<InventoryService>();

/// Get the order service instance
OrderService get orderService => getIt<OrderService>();

/// Get the address service instance
AddressService get addressService => getIt<AddressService>();

/// Get the notification service instance
NotificationService get notificationService => getIt<NotificationService>();

/// Get the wishlist service instance (cloud sync)
WishlistService get wishlistService => getIt<WishlistService>();

/// Get the payment service instance
PaymentService get paymentService => getIt<PaymentService>();

/// Get the coupon service instance
CouponService get couponService => getIt<CouponService>();

/// Get the user profile service instance
UserProfileService get userProfileService => getIt<UserProfileService>();

/// Get the saved payment service instance
SavedPaymentService get savedPaymentService => getIt<SavedPaymentService>();

/// Get the push notification service instance
PushNotificationService get pushNotificationService => getIt<PushNotificationService>();

/// Get the analytics service instance
AnalyticsService get analyticsService => getIt<AnalyticsService>();

/// Seed initial inventory data (only runs once)
///
/// Call this in development mode to populate Firestore with test data.
Future<void> seedInitialDataIfNeeded() async {
  final prefs = getIt<SharedPreferences>();
  const key = 'inventory_seeded_v1';

  if (!prefs.containsKey(key)) {
    try {
      await inventoryService.seedInventoryData();
      await prefs.setBool(key, true);
    } catch (e) {
      // Firestore might not be enabled yet - that's ok
      debugPrint('Could not seed inventory data: $e');
    }
  }
}

/// Force re-seed inventory data (for development/testing)
Future<void> forceSeedInventoryData() async {
  final prefs = getIt<SharedPreferences>();
  const key = 'inventory_seeded_v1';

  try {
    await inventoryService.seedInventoryData();
    await prefs.setBool(key, true);
  } catch (e) {
    debugPrint('Could not seed inventory data: $e');
    rethrow;
  }
}

/// Seed sample notifications for a user (for development/testing)
Future<void> seedNotificationsForUser(String userId) async {
  final prefs = getIt<SharedPreferences>();
  final key = 'notifications_seeded_$userId';

  if (!prefs.containsKey(key)) {
    try {
      await notificationService.seedNotifications(userId);
      await prefs.setBool(key, true);
    } catch (e) {
      debugPrint('Could not seed notifications: $e');
    }
  }
}

/// Seed sample coupons (for development/testing)
Future<void> seedCouponsIfNeeded() async {
  final prefs = getIt<SharedPreferences>();
  const key = 'coupons_seeded_v1';

  if (!prefs.containsKey(key)) {
    try {
      await couponService.seedCoupons();
      await prefs.setBool(key, true);
    } catch (e) {
      debugPrint('Could not seed coupons: $e');
    }
  }
}
