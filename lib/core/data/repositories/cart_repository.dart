import 'package:hive_flutter/hive_flutter.dart';

import '../models/cart_item_model.dart';

/// Repository for managing cart data with Hive persistence
///
/// Provides methods to add, update, remove items from cart
/// and calculates totals with coupon support.
class CartRepository {
  static const String _boxName = 'cart';
  Box<CartItemModel>? _box;

  // Business rules
  static const double freeDeliveryThreshold = 499.0;
  static const double deliveryCharge = 49.0;

  /// Initialize the cart repository
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CartItemModelAdapter());
    }
    _box = await Hive.openBox<CartItemModel>(_boxName);
  }

  /// Get the cart box (lazy initialization)
  Box<CartItemModel> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Cart repository not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Get all cart items
  List<CartItemModel> getItems() {
    return box.values.toList();
  }

  /// Get cart item count
  int get itemCount => box.length;

  /// Get total quantity of all items
  int get totalQuantity {
    return box.values.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Check if product+size is in cart
  bool isInCart(String productSlug, String sizeCode) {
    final key = '${productSlug}_$sizeCode';
    return box.containsKey(key);
  }

  /// Get item by product slug and size
  CartItemModel? getItem(String productSlug, String sizeCode) {
    final key = '${productSlug}_$sizeCode';
    return box.get(key);
  }

  /// Add item to cart
  Future<void> addItem(CartItemModel item) async {
    final key = item.cartKey;
    final existing = box.get(key);

    if (existing != null) {
      // Update quantity if already in cart
      final newQty = (existing.quantity + item.quantity)
          .clamp(1, item.maxQuantity);
      existing.quantity = newQty;
      await existing.save();
    } else {
      // Add new item
      await box.put(key, item);
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String productSlug, String sizeCode, int quantity) async {
    final key = '${productSlug}_$sizeCode';
    final item = box.get(key);

    if (item != null) {
      item.quantity = quantity.clamp(1, item.maxQuantity);
      await item.save();
    }
  }

  /// Increment item quantity
  Future<bool> incrementQuantity(String productSlug, String sizeCode) async {
    final key = '${productSlug}_$sizeCode';
    final item = box.get(key);

    if (item != null && item.quantity < item.maxQuantity) {
      item.quantity++;
      await item.save();
      return true;
    }
    return false; // Already at max
  }

  /// Decrement item quantity
  Future<bool> decrementQuantity(String productSlug, String sizeCode) async {
    final key = '${productSlug}_$sizeCode';
    final item = box.get(key);

    if (item != null && item.quantity > 1) {
      item.quantity--;
      await item.save();
      return true;
    }
    return false; // Already at 1
  }

  /// Remove item from cart
  Future<void> removeItem(String productSlug, String sizeCode) async {
    final key = '${productSlug}_$sizeCode';
    await box.delete(key);
  }

  /// Clear all items from cart
  Future<void> clearCart() async {
    await box.clear();
  }

  /// Calculate subtotal
  double get subtotal {
    return box.values.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  /// Calculate delivery charge based on subtotal
  double calculateDeliveryCharge(double orderSubtotal) {
    // Free delivery above threshold
    if (orderSubtotal >= freeDeliveryThreshold) {
      return 0.0;
    }

    return deliveryCharge;
  }

  /// Calculate total with optional discount amount
  double calculateTotal({double discountAmount = 0, bool freeDelivery = false}) {
    final subTotal = subtotal;
    final delivery = freeDelivery ? 0.0 : calculateDeliveryCharge(subTotal);

    return subTotal - discountAmount + delivery;
  }

  /// Get cart summary
  Map<String, dynamic> getCartSummary({double discountAmount = 0, bool freeDelivery = false}) {
    final subTotal = subtotal;
    return {
      'items': getItems(),
      'itemCount': itemCount,
      'totalQuantity': totalQuantity,
      'subtotal': subTotal,
      'discount': discountAmount,
      'deliveryCharge': freeDelivery ? 0.0 : calculateDeliveryCharge(subTotal),
      'total': calculateTotal(discountAmount: discountAmount, freeDelivery: freeDelivery),
      'isFreeDelivery': subTotal >= freeDeliveryThreshold || freeDelivery,
      'amountForFreeDelivery': subTotal < freeDeliveryThreshold
          ? freeDeliveryThreshold - subTotal
          : 0.0,
    };
  }

  /// Listen to cart changes
  Stream<BoxEvent> watch() {
    return box.watch();
  }

  /// Close the box
  Future<void> close() async {
    await _box?.close();
  }
}
