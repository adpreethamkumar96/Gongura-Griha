import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/models/product_inventory_model.dart';

/// Inventory Service
///
/// Manages product inventory with real-time Firestore updates.
class InventoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection('products');

  // Cache for inventory data
  final Map<String, ProductInventoryModel> _inventoryCache = {};

  // Stream controllers for real-time updates
  final _inventoryStreamController =
      StreamController<Map<String, ProductInventoryModel>>.broadcast();

  // Subscriptions
  StreamSubscription<QuerySnapshot>? _inventorySubscription;

  /// Stream of all inventory data
  Stream<Map<String, ProductInventoryModel>> get inventoryStream =>
      _inventoryStreamController.stream;

  /// Get cached inventory (synchronous)
  Map<String, ProductInventoryModel> get cachedInventory =>
      Map.unmodifiable(_inventoryCache);

  /// Initialize and start listening to inventory changes
  Future<void> init() async {
    // Start listening to real-time updates
    _inventorySubscription = _productsCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen(
      (snapshot) {
        for (final change in snapshot.docChanges) {
          final doc = change.doc;
          if (change.type == DocumentChangeType.removed) {
            _inventoryCache.remove(doc.id);
          } else {
            _inventoryCache[doc.id] = ProductInventoryModel.fromFirestore(doc);
          }
        }
        // Create a new map reference to ensure stream consumers detect the change
        _inventoryStreamController.add(Map<String, ProductInventoryModel>.from(_inventoryCache));
        debugPrint('Inventory updated: ${_inventoryCache.length} products');
      },
      onError: (error) {
        debugPrint('Inventory stream error: $error');
      },
    );

    // Wait for initial data
    await _loadInitialInventory();
  }

  /// Load initial inventory data
  Future<void> _loadInitialInventory() async {
    try {
      final snapshot =
          await _productsCollection.where('isActive', isEqualTo: true).get();

      for (final doc in snapshot.docs) {
        _inventoryCache[doc.id] = ProductInventoryModel.fromFirestore(doc);
      }

      // Create a new map reference to ensure stream consumers detect the change
      _inventoryStreamController.add(Map<String, ProductInventoryModel>.from(_inventoryCache));
      debugPrint('Initial inventory loaded: ${_inventoryCache.length} products');
    } catch (e) {
      debugPrint('Error loading initial inventory: $e');
    }
  }

  /// Get inventory for a specific product
  ProductInventoryModel? getProductInventory(String productSlug) {
    return _inventoryCache[productSlug];
  }

  /// Get stock for a specific product and size
  int getStock(String productSlug, String sizeCode) {
    final inventory = _inventoryCache[productSlug];
    if (inventory == null) return 0;
    return inventory.getStockForSize(sizeCode);
  }

  /// Get max quantity allowed for a product and size
  int getMaxQuantity(String productSlug, String sizeCode) {
    final inventory = _inventoryCache[productSlug];
    if (inventory == null) return 0;
    return inventory.getMaxPerOrderForSize(sizeCode);
  }

  /// Check if a product variant is in stock
  bool isInStock(String productSlug, String sizeCode) {
    return getStock(productSlug, sizeCode) > 0;
  }

  /// Stream for a specific product's inventory
  Stream<ProductInventoryModel?> getProductInventoryStream(String productSlug) {
    return _productsCollection.doc(productSlug).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ProductInventoryModel.fromFirestore(doc);
    });
  }

  /// Validate cart items against current inventory
  /// Returns list of items that exceed available stock
  Future<List<InventoryValidationResult>> validateCartInventory(
      List<CartValidationItem> cartItems) async {
    final results = <InventoryValidationResult>[];

    for (final item in cartItems) {
      final availableStock = getStock(item.productSlug, item.sizeCode);

      if (item.quantity > availableStock) {
        results.add(InventoryValidationResult(
          productSlug: item.productSlug,
          productName: item.productName,
          sizeCode: item.sizeCode,
          requestedQuantity: item.quantity,
          availableStock: availableStock,
          isValid: false,
        ));
      }
    }

    return results;
  }

  /// Reserve inventory (decrement stock) - called after successful payment
  /// Uses Firestore transactions to prevent race conditions
  Future<InventoryReservationResult> reserveInventory(List<CartValidationItem> items) async {
    try {
      // Use a transaction to ensure atomic read-modify-write
      final result = await _firestore.runTransaction<InventoryReservationResult>(
        (transaction) async {
          final insufficientStock = <String>[];
          final updates = <DocumentReference, Map<String, dynamic>>{};

          // Phase 1: Read all documents and validate stock
          for (final item in items) {
            final docRef = _productsCollection.doc(item.productSlug);
            final doc = await transaction.get(docRef);

            if (!doc.exists) {
              insufficientStock.add('${item.productName} is no longer available');
              continue;
            }

            final inventory = ProductInventoryModel.fromFirestore(doc);
            final variant = inventory.variants.firstWhere(
              (v) => v.sizeCode == item.sizeCode,
              orElse: () => VariantInventory(
                sizeCode: item.sizeCode,
                sizeName: item.sizeCode,
                weight: '',
                price: 0,
                stock: 0,
                maxPerOrder: 0,
              ),
            );

            // Check if sufficient stock is available
            if (variant.stock < item.quantity) {
              if (variant.stock == 0) {
                insufficientStock.add('${item.productName} (${item.sizeCode}) is now out of stock');
              } else {
                insufficientStock.add(
                  '${item.productName} (${item.sizeCode}): Only ${variant.stock} left, you requested ${item.quantity}',
                );
              }
              continue;
            }

            // Prepare the update
            final updatedVariants = inventory.variants.map((v) {
              if (v.sizeCode == item.sizeCode) {
                return v.copyWith(stock: v.stock - item.quantity);
              }
              return v;
            }).toList();

            updates[docRef] = {
              'variants': updatedVariants.map((v) => v.toMap()).toList(),
              'updatedAt': FieldValue.serverTimestamp(),
            };
          }

          // If any items have insufficient stock, abort the transaction
          if (insufficientStock.isNotEmpty) {
            return InventoryReservationResult(
              success: false,
              errors: insufficientStock,
            );
          }

          // Phase 2: Apply all updates atomically
          for (final entry in updates.entries) {
            transaction.update(entry.key, entry.value);
          }

          return InventoryReservationResult(success: true, errors: []);
        },
        timeout: const Duration(seconds: 10),
        maxAttempts: 3, // Retry up to 3 times on conflict
      );

      if (result.success) {
        debugPrint('Inventory reserved successfully for ${items.length} items');
      } else {
        debugPrint('Inventory reservation failed: ${result.errors.join(", ")}');
      }

      return result;
    } catch (e) {
      debugPrint('Error reserving inventory: $e');
      return InventoryReservationResult(
        success: false,
        errors: ['Failed to reserve inventory. Please try again.'],
      );
    }
  }

  /// Release inventory (increment stock) - called if order is cancelled
  Future<bool> releaseInventory(List<CartValidationItem> items) async {
    try {
      await _firestore.runTransaction((transaction) async {
        for (final item in items) {
          final docRef = _productsCollection.doc(item.productSlug);
          final doc = await transaction.get(docRef);

          if (!doc.exists) continue;

          final inventory = ProductInventoryModel.fromFirestore(doc);
          final updatedVariants = inventory.variants.map((v) {
            if (v.sizeCode == item.sizeCode) {
              return v.copyWith(stock: v.stock + item.quantity);
            }
            return v;
          }).toList();

          transaction.update(docRef, {
            'variants': updatedVariants.map((v) => v.toMap()).toList(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      debugPrint('Inventory released for ${items.length} items');
      return true;
    } catch (e) {
      debugPrint('Error releasing inventory: $e');
      return false;
    }
  }

  /// Seed initial inventory data (for development/testing)
  Future<void> seedInventoryData() async {
    final products = [
      ProductInventoryModel(
        productSlug: 'traditional-gongura-pachadi',
        productName: 'Traditional Gongura Pachadi',
        productImage: 'assets/images/GonguraPickle.png',
        basePrice: 199.0,
        category: 'Pachadi',
        isVeg: true,
        isActive: true,
        variants: [
          VariantInventory(
            sizeCode: 'S',
            sizeName: 'Small',
            weight: '250g',
            price: 199.0,
            stock: 10,
            maxPerOrder: 2,
          ),
          VariantInventory(
            sizeCode: 'M',
            sizeName: 'Medium',
            weight: '500g',
            price: 379.0,
            stock: 8,
            maxPerOrder: 4,
          ),
          VariantInventory(
            sizeCode: 'L',
            sizeName: 'Large',
            weight: '1kg',
            price: 699.0,
            stock: 3, // Limited stock!
            maxPerOrder: 5,
          ),
        ],
      ),
      ProductInventoryModel(
        productSlug: 'classic-gongura-chutney',
        productName: 'Classic Gongura Chutney',
        productImage: 'assets/images/GonguraChutney.png',
        basePrice: 149.0,
        category: 'Chutney',
        isVeg: true,
        isActive: true,
        variants: [
          VariantInventory(
            sizeCode: 'S',
            sizeName: 'Small',
            weight: '200g',
            price: 149.0,
            stock: 15,
            maxPerOrder: 2,
          ),
          VariantInventory(
            sizeCode: 'M',
            sizeName: 'Medium',
            weight: '400g',
            price: 279.0,
            stock: 12,
            maxPerOrder: 4,
          ),
          VariantInventory(
            sizeCode: 'L',
            sizeName: 'Large',
            weight: '800g',
            price: 529.0,
            stock: 5,
            maxPerOrder: 5,
          ),
        ],
      ),
      ProductInventoryModel(
        productSlug: 'spicy-gongura-podi',
        productName: 'Spicy Gongura Podi',
        productImage: 'assets/images/GonguraPowder.png',
        basePrice: 139.0,
        category: 'Powder',
        isVeg: true,
        isActive: true,
        variants: [
          VariantInventory(
            sizeCode: 'S',
            sizeName: 'Small',
            weight: '100g',
            price: 139.0,
            stock: 20,
            maxPerOrder: 2,
          ),
          VariantInventory(
            sizeCode: 'M',
            sizeName: 'Medium',
            weight: '250g',
            price: 319.0,
            stock: 0, // Out of stock!
            maxPerOrder: 4,
          ),
          VariantInventory(
            sizeCode: 'L',
            sizeName: 'Large',
            weight: '500g',
            price: 599.0,
            stock: 7,
            maxPerOrder: 5,
          ),
        ],
      ),
    ];

    final batch = _firestore.batch();

    for (final product in products) {
      final docRef = _productsCollection.doc(product.productSlug);
      batch.set(docRef, product.toFirestore());
    }

    await batch.commit();
    debugPrint('Seeded ${products.length} products to Firestore');
  }

  /// Close the service
  Future<void> close() async {
    await _inventorySubscription?.cancel();
    await _inventoryStreamController.close();
  }
}

/// Item for cart validation
class CartValidationItem {
  final String productSlug;
  final String productName;
  final String sizeCode;
  final int quantity;

  CartValidationItem({
    required this.productSlug,
    required this.productName,
    required this.sizeCode,
    required this.quantity,
  });
}

/// Result of inventory validation
class InventoryValidationResult {
  final String productSlug;
  final String productName;
  final String sizeCode;
  final int requestedQuantity;
  final int availableStock;
  final bool isValid;

  InventoryValidationResult({
    required this.productSlug,
    required this.productName,
    required this.sizeCode,
    required this.requestedQuantity,
    required this.availableStock,
    required this.isValid,
  });

  String get errorMessage =>
      '$productName ($sizeCode): Only $availableStock available, you requested $requestedQuantity';
}

/// Result of inventory reservation attempt
class InventoryReservationResult {
  final bool success;
  final List<String> errors;

  InventoryReservationResult({
    required this.success,
    required this.errors,
  });

  String get errorMessage => errors.join('\n');
}
