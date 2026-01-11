import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/models/wishlist_item_model.dart';

/// Wishlist Service
///
/// Manages wishlist sync with Firestore backend for cross-device persistence.
class WishlistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference - wishlists are stored per user
  CollectionReference<Map<String, dynamic>> _getUserWishlistCollection(
      String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlist');
  }

  /// Get all wishlist items for a user
  Future<List<WishlistItemModel>> getWishlistItems(String userId) async {
    try {
      final snapshot = await _getUserWishlistCollection(userId)
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return WishlistItemModel(
          productSlug: doc.id,
          productName: data['productName'] as String? ?? '',
          productImage: data['productImage'] as String? ?? '',
          basePrice: (data['basePrice'] as num?)?.toDouble() ?? 0,
          category: data['category'] as String? ?? '',
          isVeg: data['isVeg'] as bool? ?? true,
          addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error fetching wishlist: $e');
      return [];
    }
  }

  /// Stream of wishlist items (real-time updates)
  Stream<List<WishlistItemModel>> getWishlistStream(String userId) {
    return _getUserWishlistCollection(userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return WishlistItemModel(
                productSlug: doc.id,
                productName: data['productName'] as String? ?? '',
                productImage: data['productImage'] as String? ?? '',
                basePrice: (data['basePrice'] as num?)?.toDouble() ?? 0,
                category: data['category'] as String? ?? '',
                isVeg: data['isVeg'] as bool? ?? true,
                addedAt: (data['addedAt'] as Timestamp?)?.toDate(),
              );
            }).toList());
  }

  /// Stream of wishlisted product slugs (for quick lookup)
  Stream<Set<String>> getWishlistSlugsStream(String userId) {
    return _getUserWishlistCollection(userId).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => doc.id).toSet(),
        );
  }

  /// Check if product is in wishlist
  Future<bool> isInWishlist(String userId, String productSlug) async {
    try {
      final doc =
          await _getUserWishlistCollection(userId).doc(productSlug).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking wishlist: $e');
      return false;
    }
  }

  /// Add item to wishlist
  Future<bool> addToWishlist(String userId, WishlistItemModel item) async {
    try {
      await _getUserWishlistCollection(userId).doc(item.productSlug).set({
        'productName': item.productName,
        'productImage': item.productImage,
        'basePrice': item.basePrice,
        'category': item.category,
        'isVeg': item.isVeg,
        'addedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('Added to wishlist: ${item.productSlug}');
      return true;
    } catch (e) {
      debugPrint('Error adding to wishlist: $e');
      return false;
    }
  }

  /// Remove item from wishlist
  Future<bool> removeFromWishlist(String userId, String productSlug) async {
    try {
      await _getUserWishlistCollection(userId).doc(productSlug).delete();
      debugPrint('Removed from wishlist: $productSlug');
      return true;
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
      return false;
    }
  }

  /// Toggle item in wishlist
  Future<bool> toggleWishlist(String userId, WishlistItemModel item) async {
    final inWishlist = await isInWishlist(userId, item.productSlug);
    if (inWishlist) {
      await removeFromWishlist(userId, item.productSlug);
      return false; // Removed
    } else {
      await addToWishlist(userId, item);
      return true; // Added
    }
  }

  /// Clear all wishlist items
  Future<bool> clearWishlist(String userId) async {
    try {
      final snapshot = await _getUserWishlistCollection(userId).get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      debugPrint('Cleared wishlist for user $userId');
      return true;
    } catch (e) {
      debugPrint('Error clearing wishlist: $e');
      return false;
    }
  }

  /// Get wishlist count
  Future<int> getWishlistCount(String userId) async {
    try {
      final snapshot =
          await _getUserWishlistCollection(userId).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting wishlist count: $e');
      return 0;
    }
  }

  /// Sync local wishlist to cloud (called when user logs in)
  Future<void> syncLocalToCloud(
      String userId, List<WishlistItemModel> localItems) async {
    try {
      // Get existing cloud items
      final cloudItems = await getWishlistItems(userId);
      final cloudSlugs = cloudItems.map((e) => e.productSlug).toSet();

      // Add local items that don't exist in cloud
      final batch = _firestore.batch();
      int addedCount = 0;

      for (final item in localItems) {
        if (!cloudSlugs.contains(item.productSlug)) {
          final docRef =
              _getUserWishlistCollection(userId).doc(item.productSlug);
          batch.set(docRef, {
            'productName': item.productName,
            'productImage': item.productImage,
            'basePrice': item.basePrice,
            'category': item.category,
            'isVeg': item.isVeg,
            'addedAt': Timestamp.fromDate(item.addedAt),
          });
          addedCount++;
        }
      }

      if (addedCount > 0) {
        await batch.commit();
        debugPrint('Synced $addedCount local items to cloud');
      }
    } catch (e) {
      debugPrint('Error syncing wishlist to cloud: $e');
    }
  }

  /// Sync cloud wishlist to local (returns items to add locally)
  Future<List<WishlistItemModel>> getCloudItemsNotInLocal(
      String userId, Set<String> localSlugs) async {
    try {
      final cloudItems = await getWishlistItems(userId);
      return cloudItems
          .where((item) => !localSlugs.contains(item.productSlug))
          .toList();
    } catch (e) {
      debugPrint('Error getting cloud items: $e');
      return [];
    }
  }
}
