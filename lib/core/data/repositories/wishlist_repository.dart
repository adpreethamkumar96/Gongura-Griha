import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/di/injection.dart';
import '../models/wishlist_item_model.dart';

/// Repository for managing wishlist data with Hive persistence and Firestore sync
///
/// Provides methods to add, remove, and check wishlist items.
/// Supports cross-device sync when user is logged in.
class WishlistRepository {
  static const String _boxName = 'wishlist';
  Box<WishlistItemModel>? _box;
  StreamSubscription<List<WishlistItemModel>>? _cloudSubscription;
  String? _currentUserId;
  bool _isSyncing = false;

  /// Initialize the wishlist repository
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(WishlistItemModelAdapter());
    }
    _box = await Hive.openBox<WishlistItemModel>(_boxName);
  }

  /// Get the wishlist box (lazy initialization)
  Box<WishlistItemModel> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Wishlist repository not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Get all wishlist items
  List<WishlistItemModel> getItems() {
    return box.values.toList()
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt)); // Newest first
  }

  /// Get wishlist item count
  int get itemCount => box.length;

  /// Check if product is in wishlist
  bool isInWishlist(String productSlug) {
    return box.containsKey(productSlug);
  }

  /// Get item by product slug
  WishlistItemModel? getItem(String productSlug) {
    return box.get(productSlug);
  }

  /// Add item to wishlist (local + cloud)
  Future<void> addItem(WishlistItemModel item) async {
    if (!box.containsKey(item.productSlug)) {
      await box.put(item.productSlug, item);

      // Sync to cloud if logged in
      if (_currentUserId != null && !_isSyncing) {
        await wishlistService.addToWishlist(_currentUserId!, item);
      }
    }
  }

  /// Remove item from wishlist (local + cloud)
  Future<void> removeItem(String productSlug) async {
    await box.delete(productSlug);

    // Sync to cloud if logged in
    if (_currentUserId != null && !_isSyncing) {
      await wishlistService.removeFromWishlist(_currentUserId!, productSlug);
    }
  }

  /// Toggle item in wishlist (local + cloud)
  Future<bool> toggleItem(WishlistItemModel item) async {
    if (box.containsKey(item.productSlug)) {
      await removeItem(item.productSlug);
      return false; // Removed
    } else {
      await addItem(item);
      return true; // Added
    }
  }

  /// Clear all items from wishlist (local + cloud)
  Future<void> clearWishlist() async {
    await box.clear();

    // Clear cloud if logged in
    if (_currentUserId != null && !_isSyncing) {
      await wishlistService.clearWishlist(_currentUserId!);
    }
  }

  /// Get all product slugs in wishlist
  Set<String> getWishlistedSlugs() {
    return box.keys.cast<String>().toSet();
  }

  /// Listen to wishlist changes
  Stream<BoxEvent> watch() {
    return box.watch();
  }

  /// Start cloud sync for logged-in user
  Future<void> startCloudSync(String userId) async {
    if (_currentUserId == userId && _cloudSubscription != null) {
      return; // Already syncing for this user
    }

    _currentUserId = userId;

    // Sync local items to cloud (merge strategy)
    await _syncLocalToCloud(userId);

    // Listen for cloud changes
    _cloudSubscription?.cancel();
    _cloudSubscription = wishlistService.getWishlistStream(userId).listen(
      (cloudItems) async {
        await _handleCloudUpdate(cloudItems);
      },
      onError: (Object e) {
        debugPrint('Wishlist cloud sync error: $e');
      },
    );
  }

  /// Stop cloud sync (when user logs out)
  void stopCloudSync() {
    _cloudSubscription?.cancel();
    _cloudSubscription = null;
    _currentUserId = null;
  }

  /// Sync local items to cloud
  Future<void> _syncLocalToCloud(String userId) async {
    _isSyncing = true;
    try {
      final localItems = getItems();
      if (localItems.isNotEmpty) {
        await wishlistService.syncLocalToCloud(userId, localItems);
      }
    } catch (e) {
      debugPrint('Error syncing local wishlist to cloud: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Handle updates from cloud
  Future<void> _handleCloudUpdate(List<WishlistItemModel> cloudItems) async {
    _isSyncing = true;
    try {
      final localSlugs = getWishlistedSlugs();
      final cloudSlugs = cloudItems.map((e) => e.productSlug).toSet();

      // Add cloud items that aren't local
      for (final item in cloudItems) {
        if (!localSlugs.contains(item.productSlug)) {
          await box.put(item.productSlug, item);
        }
      }

      // Remove local items that were removed from cloud
      // (Only if they existed in cloud before - we use a simple approach here)
      for (final slug in localSlugs) {
        if (!cloudSlugs.contains(slug)) {
          // Check if this was recently added locally
          final localItem = box.get(slug);
          if (localItem != null) {
            final timeDiff = DateTime.now().difference(localItem.addedAt);
            // If added more than 30 seconds ago and not in cloud, remove
            // This prevents removing items that were just added locally
            if (timeDiff.inSeconds > 30) {
              await box.delete(slug);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error handling cloud wishlist update: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Stream of wishlisted slugs for quick lookup
  Stream<Set<String>> getWishlistSlugsStream() {
    if (_currentUserId != null) {
      // Return cloud stream when logged in
      return wishlistService.getWishlistSlugsStream(_currentUserId!);
    }
    // Return local stream when not logged in
    return box.watch().map((_) => getWishlistedSlugs());
  }

  /// Close the box and stop sync
  Future<void> close() async {
    stopCloudSync();
    await _box?.close();
  }
}
