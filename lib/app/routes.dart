import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection.dart';
import '../features/address/presentation/screens/add_address_screen.dart';
import '../features/address/presentation/screens/address_list_screen.dart';
import '../features/address/presentation/screens/edit_address_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/otp_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/cart/presentation/screens/checkout_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/legal/presentation/screens/privacy_policy_screen.dart';
import '../features/legal/presentation/screens/terms_conditions_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/orders/presentation/screens/order_detail_screen.dart';
import '../features/orders/presentation/screens/order_success_screen.dart';
import '../features/orders/presentation/screens/orders_screen.dart';
import '../features/payment/presentation/screens/payment_methods_screen.dart';
import '../features/products/presentation/screens/product_detail_screen.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/settings/presentation/screens/language_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/support/presentation/screens/about_screen.dart';
import '../features/support/presentation/screens/help_support_screen.dart';
import '../features/wishlist/presentation/screens/wishlist_screen.dart';

/// App Routes
///
/// Contains all route definitions and navigation configuration.
class AppRoutes {
  AppRoutes._();

  // ============ Route Names ============

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String register = '/register';
  static const String home = '/home';
  static const String productList = '/products';
  static const String productDetail = '/product/:slug';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String orders = '/orders';
  static const String orderDetail = '/order/:orderNumber';
  static const String wishlist = '/wishlist';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String addresses = '/addresses';
  static const String addAddress = '/addresses/add';
  static const String editAddress = '/addresses/edit/:id';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String help = '/help';
  static const String about = '/about';
  static const String paymentMethods = '/payment-methods';
  static const String language = '/language';
  static const String termsConditions = '/terms-conditions';
  static const String privacyPolicy = '/privacy-policy';

  // ============ Route Helpers ============

  /// Get product detail route with slug
  static String getProductDetailRoute(String slug) => '/product/$slug';

  /// Get order detail route with order number
  static String getOrderDetailRoute(String orderNumber) =>
      '/order/$orderNumber';

  /// Get edit address route with address ID
  static String getEditAddressRoute(String id) => '/addresses/edit/$id';
}

/// Router Configuration
///
/// GoRouter configuration for the app.
GoRouter createRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    observers: [analyticsService.observer],
    routes: [
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        name: 'otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpScreen(
            phoneNumber: extra?['phone'] as String?,
            verificationId: extra?['verificationId'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Routes (with bottom navigation shell)
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          // Home
          GoRoute(
            path: AppRoutes.home,
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Orders
          GoRoute(
            path: AppRoutes.orders,
            name: 'orders',
            builder: (context, state) => const OrdersScreen(),
          ),

          // Wishlist
          GoRoute(
            path: AppRoutes.wishlist,
            name: 'wishlist',
            builder: (context, state) => const WishlistScreen(),
          ),

          // Profile
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          // Product Routes (inside shell for persistent nav bar)
          GoRoute(
            path: AppRoutes.productList,
            name: 'productList',
            builder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return ProductListScreen(category: category);
            },
          ),
          GoRoute(
            path: AppRoutes.productDetail,
            name: 'productDetail',
            builder: (context, state) {
              final slug = state.pathParameters['slug']!;
              return ProductDetailScreen(slug: slug);
            },
          ),

          // Cart
          GoRoute(
            path: AppRoutes.cart,
            name: 'cart',
            builder: (context, state) => const CartScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        name: 'orderSuccess',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OrderSuccessScreen(
            orderNumber: extra?['orderNumber'] as String?,
          );
        },
      ),

      // Order Detail
      GoRoute(
        path: AppRoutes.orderDetail,
        name: 'orderDetail',
        builder: (context, state) {
          final orderNumber = state.pathParameters['orderNumber']!;
          return OrderDetailScreen(orderNumber: orderNumber);
        },
      ),

      // Profile Sub-routes
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.addresses,
        name: 'addresses',
        builder: (context, state) => const AddressListScreen(),
      ),
      GoRoute(
        path: AppRoutes.addAddress,
        name: 'addAddress',
        builder: (context, state) => const AddAddressScreen(),
      ),
      GoRoute(
        path: AppRoutes.editAddress,
        name: 'editAddress',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EditAddressScreen(addressId: id);
        },
      ),

      // Other Routes
      GoRoute(
        path: AppRoutes.search,
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.help,
        name: 'help',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        builder: (context, state) => const AboutScreen(),
      ),

      // Settings & Legal Routes
      GoRoute(
        path: AppRoutes.paymentMethods,
        name: 'paymentMethods',
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: AppRoutes.language,
        name: 'language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: AppRoutes.termsConditions,
        name: 'termsConditions',
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        name: 'privacyPolicy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
    ],

    // Error Page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
}

/// Main Shell with Bottom Navigation
class _MainShell extends StatelessWidget {
  final Widget child;

  const _MainShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.transparent,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A7C59),
              );
            }
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            );
          }),
        ),
        child: NavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined, color: Colors.grey),
              selectedIcon: const Icon(Icons.home, color: Color(0xFF4A7C59)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
              selectedIcon: const Icon(Icons.shopping_bag, color: Color(0xFF4A7C59)),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_outline, color: Colors.grey),
              selectedIcon: const Icon(Icons.favorite, color: Color(0xFF4A7C59)),
              label: 'Wishlist',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline, color: Colors.grey),
              selectedIcon: const Icon(Icons.person, color: Color(0xFF4A7C59)),
              label: 'Profile',
            ),
          ],
          selectedIndex: _calculateSelectedIndex(context),
          onDestinationSelected: (index) => _onItemTapped(index, context),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/products')) return 0;
    if (location.startsWith('/product/')) return 0;
    if (location.startsWith('/cart')) return 0;
    if (location.startsWith('/orders')) return 1;
    if (location.startsWith('/order/')) return 1;
    if (location.startsWith('/wishlist')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.orders);
      case 2:
        context.go(AppRoutes.wishlist);
      case 3:
        context.go(AppRoutes.profile);
    }
  }
}
