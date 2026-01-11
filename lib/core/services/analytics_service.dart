import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Analytics Service
///
/// Tracks user events and screen views using Firebase Analytics.
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get the analytics observer for navigation tracking
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ============ User Properties ============

  /// Set user ID for analytics
  Future<void> setUserId(String? userId) async {
    await _analytics.setUserId(id: userId);
    debugPrint('Analytics: User ID set to $userId');
  }

  /// Set user properties
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    await _analytics.setUserProperty(name: name, value: value);
  }

  // ============ Screen Tracking ============

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
    debugPrint('Analytics: Screen view - $screenName');
  }

  // ============ Authentication Events ============

  /// Log login event
  Future<void> logLogin({String method = 'phone'}) async {
    await _analytics.logLogin(loginMethod: method);
    debugPrint('Analytics: Login - $method');
  }

  /// Log sign up event
  Future<void> logSignUp({String method = 'phone'}) async {
    await _analytics.logSignUp(signUpMethod: method);
    debugPrint('Analytics: Sign up - $method');
  }

  // ============ E-Commerce Events ============

  /// Log product view
  Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required String category,
    double? price,
  }) async {
    await _analytics.logViewItem(
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          itemCategory: category,
          price: price,
        ),
      ],
    );
    debugPrint('Analytics: View item - $itemName');
  }

  /// Log add to cart
  Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required String category,
    required int quantity,
    required double price,
  }) async {
    await _analytics.logAddToCart(
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          itemCategory: category,
          quantity: quantity,
          price: price,
        ),
      ],
      value: price * quantity,
      currency: 'INR',
    );
    debugPrint('Analytics: Add to cart - $itemName x$quantity');
  }

  /// Log remove from cart
  Future<void> logRemoveFromCart({
    required String itemId,
    required String itemName,
    required String category,
    required int quantity,
    required double price,
  }) async {
    await _analytics.logRemoveFromCart(
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          itemCategory: category,
          quantity: quantity,
          price: price,
        ),
      ],
      value: price * quantity,
      currency: 'INR',
    );
    debugPrint('Analytics: Remove from cart - $itemName x$quantity');
  }

  /// Log view cart
  Future<void> logViewCart({
    required List<Map<String, dynamic>> items,
    required double cartValue,
  }) async {
    await _analytics.logViewCart(
      items: items
          .map((item) => AnalyticsEventItem(
                itemId: item['itemId'] as String,
                itemName: item['itemName'] as String,
                itemCategory: item['category'] as String?,
                quantity: item['quantity'] as int?,
                price: item['price'] as double?,
              ))
          .toList(),
      value: cartValue,
      currency: 'INR',
    );
    debugPrint('Analytics: View cart - ${items.length} items');
  }

  /// Log begin checkout
  Future<void> logBeginCheckout({
    required List<Map<String, dynamic>> items,
    required double value,
    String? couponCode,
  }) async {
    await _analytics.logBeginCheckout(
      items: items
          .map((item) => AnalyticsEventItem(
                itemId: item['itemId'] as String,
                itemName: item['itemName'] as String,
                itemCategory: item['category'] as String?,
                quantity: item['quantity'] as int?,
                price: item['price'] as double?,
              ))
          .toList(),
      value: value,
      currency: 'INR',
      coupon: couponCode,
    );
    debugPrint('Analytics: Begin checkout - $value INR');
  }

  /// Log purchase
  Future<void> logPurchase({
    required String orderId,
    required List<Map<String, dynamic>> items,
    required double value,
    double? shipping,
    double? discount,
    String? couponCode,
  }) async {
    await _analytics.logPurchase(
      transactionId: orderId,
      items: items
          .map((item) => AnalyticsEventItem(
                itemId: item['itemId'] as String,
                itemName: item['itemName'] as String,
                itemCategory: item['category'] as String?,
                quantity: item['quantity'] as int?,
                price: item['price'] as double?,
              ))
          .toList(),
      value: value,
      currency: 'INR',
      shipping: shipping,
      coupon: couponCode,
    );
    debugPrint('Analytics: Purchase - Order $orderId, $value INR');
  }

  /// Log refund
  Future<void> logRefund({
    required String orderId,
    required double value,
  }) async {
    await _analytics.logRefund(
      transactionId: orderId,
      value: value,
      currency: 'INR',
    );
    debugPrint('Analytics: Refund - Order $orderId, $value INR');
  }

  // ============ Wishlist Events ============

  /// Log add to wishlist
  Future<void> logAddToWishlist({
    required String itemId,
    required String itemName,
    required String category,
    double? price,
  }) async {
    await _analytics.logAddToWishlist(
      items: [
        AnalyticsEventItem(
          itemId: itemId,
          itemName: itemName,
          itemCategory: category,
          price: price,
        ),
      ],
    );
    debugPrint('Analytics: Add to wishlist - $itemName');
  }

  // ============ Search Events ============

  /// Log search
  Future<void> logSearch({required String searchTerm}) async {
    await _analytics.logSearch(searchTerm: searchTerm);
    debugPrint('Analytics: Search - $searchTerm');
  }

  // ============ Engagement Events ============

  /// Log share
  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) async {
    await _analytics.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
    debugPrint('Analytics: Share - $contentType/$itemId via $method');
  }

  /// Log select content (category, filter, etc.)
  Future<void> logSelectContent({
    required String contentType,
    required String itemId,
  }) async {
    await _analytics.logSelectContent(
      contentType: contentType,
      itemId: itemId,
    );
    debugPrint('Analytics: Select content - $contentType/$itemId');
  }

  // ============ Custom Events ============

  /// Log coupon applied
  Future<void> logCouponApplied({
    required String couponCode,
    required double discount,
  }) async {
    await _analytics.logEvent(
      name: 'coupon_applied',
      parameters: {
        'coupon_code': couponCode,
        'discount_amount': discount,
      },
    );
    debugPrint('Analytics: Coupon applied - $couponCode, $discount off');
  }

  /// Log address added
  Future<void> logAddressAdded() async {
    await _analytics.logEvent(name: 'address_added');
    debugPrint('Analytics: Address added');
  }

  /// Log payment method selected
  Future<void> logPaymentMethodSelected({required String method}) async {
    await _analytics.logEvent(
      name: 'payment_method_selected',
      parameters: {'method': method},
    );
    debugPrint('Analytics: Payment method selected - $method');
  }

  /// Log order cancelled
  Future<void> logOrderCancelled({
    required String orderId,
    String? reason,
  }) async {
    await _analytics.logEvent(
      name: 'order_cancelled',
      parameters: {
        'order_id': orderId,
        if (reason != null) 'reason': reason,
      },
    );
    debugPrint('Analytics: Order cancelled - $orderId');
  }

  /// Log notification received
  Future<void> logNotificationReceived({
    required String type,
    String? title,
  }) async {
    await _analytics.logEvent(
      name: 'notification_received',
      parameters: {
        'type': type,
        if (title != null) 'title': title,
      },
    );
  }

  /// Log notification opened
  Future<void> logNotificationOpened({
    required String type,
    String? action,
  }) async {
    await _analytics.logEvent(
      name: 'notification_opened',
      parameters: {
        'type': type,
        if (action != null) 'action': action,
      },
    );
  }

  /// Log generic custom event
  Future<void> logCustomEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
    debugPrint('Analytics: Custom event - $name');
  }
}
