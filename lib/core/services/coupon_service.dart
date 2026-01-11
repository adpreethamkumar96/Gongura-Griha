import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/models/coupon_model.dart';

/// Coupon Service
///
/// Manages coupon validation and redemption with Firestore.
class CouponService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _couponsCollection =>
      _firestore.collection('coupons');

  CollectionReference<Map<String, dynamic>> _getUserCouponsCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('usedCoupons');

  /// Get all active coupons
  Future<List<CouponModel>> getActiveCoupons() async {
    try {
      final snapshot = await _couponsCollection
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => CouponModel.fromFirestore(doc))
          .where((coupon) => coupon.isValid)
          .toList();
    } catch (e) {
      debugPrint('Error fetching coupons: $e');
      return [];
    }
  }

  /// Get coupon by code
  Future<CouponModel?> getCouponByCode(String code) async {
    try {
      final doc = await _couponsCollection.doc(code.toUpperCase()).get();
      if (!doc.exists) return null;
      return CouponModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error fetching coupon: $e');
      return null;
    }
  }

  /// Validate coupon for order
  Future<CouponValidationResult> validateCoupon({
    required String code,
    required double orderAmount,
    String? userId,
    List<String>? cartCategories,
  }) async {
    try {
      final coupon = await getCouponByCode(code);

      if (coupon == null) {
        return CouponValidationResult.invalid('Invalid coupon code');
      }

      if (!coupon.isActive) {
        return CouponValidationResult.invalid('This coupon is no longer active');
      }

      // Check validity dates
      final now = DateTime.now();
      if (coupon.validFrom != null && now.isBefore(coupon.validFrom!)) {
        return CouponValidationResult.invalid('This coupon is not yet active');
      }
      if (coupon.validUntil != null && now.isAfter(coupon.validUntil!)) {
        return CouponValidationResult.invalid('This coupon has expired');
      }

      // Check minimum order amount
      if (orderAmount < coupon.minOrderAmount) {
        return CouponValidationResult.invalid(
          'Minimum order amount is \u20B9${coupon.minOrderAmount.toInt()}',
        );
      }

      // Check usage limit
      if (coupon.usageLimit != null && coupon.usedCount >= coupon.usageLimit!) {
        return CouponValidationResult.invalid('This coupon has reached its usage limit');
      }

      // Check user usage limit
      if (userId != null && coupon.usagePerUser != null) {
        final userUsageCount = await _getUserCouponUsageCount(userId, code);
        if (userUsageCount >= coupon.usagePerUser!) {
          return CouponValidationResult.invalid(
            'You have already used this coupon the maximum number of times',
          );
        }
      }

      // Check applicable categories
      if (coupon.applicableCategories != null &&
          coupon.applicableCategories!.isNotEmpty &&
          cartCategories != null) {
        final hasApplicableItem = cartCategories.any(
          (cat) => coupon.applicableCategories!.contains(cat.toLowerCase()),
        );
        if (!hasApplicableItem) {
          return CouponValidationResult.invalid(
            'This coupon is not applicable to items in your cart',
          );
        }
      }

      // Calculate discount
      final discount = coupon.calculateDiscount(orderAmount);

      return CouponValidationResult.valid(coupon, discount);
    } catch (e) {
      debugPrint('Error validating coupon: $e');
      return CouponValidationResult.invalid('Error validating coupon');
    }
  }

  /// Get user's usage count for a coupon
  Future<int> _getUserCouponUsageCount(String userId, String code) async {
    try {
      final doc = await _getUserCouponsCollection(userId).doc(code.toUpperCase()).get();
      if (!doc.exists) return 0;
      return (doc.data()?['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Record coupon usage with transaction to prevent race conditions
  /// Returns true if coupon was successfully claimed, false if limit reached
  Future<CouponClaimResult> claimCoupon({
    required String userId,
    required String code,
    required double orderAmount,
  }) async {
    final couponCode = code.toUpperCase();

    try {
      final result = await _firestore.runTransaction<CouponClaimResult>(
        (transaction) async {
          // Read coupon
          final couponDoc = await transaction.get(_couponsCollection.doc(couponCode));
          if (!couponDoc.exists) {
            return CouponClaimResult(success: false, error: 'Coupon not found');
          }

          final coupon = CouponModel.fromFirestore(couponDoc);

          // Validate coupon is still active
          if (!coupon.isActive) {
            return CouponClaimResult(success: false, error: 'Coupon is no longer active');
          }

          // Check global usage limit
          if (coupon.usageLimit != null && coupon.usedCount >= coupon.usageLimit!) {
            return CouponClaimResult(
              success: false,
              error: 'Sorry! This coupon has reached its usage limit',
            );
          }

          // Check user usage limit
          if (coupon.usagePerUser != null) {
            final userCouponDoc = await transaction.get(
              _getUserCouponsCollection(userId).doc(couponCode),
            );
            final userUsageCount = userCouponDoc.exists
                ? (userCouponDoc.data()?['count'] as int? ?? 0)
                : 0;

            if (userUsageCount >= coupon.usagePerUser!) {
              return CouponClaimResult(
                success: false,
                error: 'You have already used this coupon the maximum number of times',
              );
            }
          }

          // Check minimum order amount
          if (orderAmount < coupon.minOrderAmount) {
            return CouponClaimResult(
              success: false,
              error: 'Minimum order amount is \u20B9${coupon.minOrderAmount.toInt()}',
            );
          }

          // All checks passed - claim the coupon
          // Increment global usage count
          transaction.update(_couponsCollection.doc(couponCode), {
            'usedCount': FieldValue.increment(1),
          });

          // Increment user usage count
          transaction.set(
            _getUserCouponsCollection(userId).doc(couponCode),
            {
              'count': FieldValue.increment(1),
              'lastUsed': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );

          final discount = coupon.calculateDiscount(orderAmount);
          return CouponClaimResult(
            success: true,
            coupon: coupon,
            discountAmount: discount,
          );
        },
        timeout: const Duration(seconds: 10),
        maxAttempts: 3,
      );

      return result;
    } catch (e) {
      debugPrint('Error claiming coupon: $e');
      return CouponClaimResult(success: false, error: 'Failed to apply coupon');
    }
  }

  /// Record coupon usage (simple version for backward compatibility)
  Future<bool> recordCouponUsage(String userId, String code) async {
    final result = await claimCoupon(
      userId: userId,
      code: code,
      orderAmount: double.infinity, // Skip min order check
    );
    return result.success;
  }

  /// Seed sample coupons for development
  Future<void> seedCoupons() async {
    final coupons = [
      {
        'code': 'GONGURA20',
        'description': '20% off on orders above \u20B9500',
        'type': CouponType.percentage.name,
        'value': 20,
        'minOrderAmount': 500,
        'maxDiscount': 200,
        'isActive': true,
      },
      {
        'code': 'FIRST50',
        'description': '\u20B950 off on your first order',
        'type': CouponType.fixed.name,
        'value': 50,
        'minOrderAmount': 299,
        'usagePerUser': 1,
        'isActive': true,
      },
      {
        'code': 'FREESHIP',
        'description': 'Free delivery on orders above \u20B9299',
        'type': CouponType.freeDelivery.name,
        'value': 0,
        'minOrderAmount': 299,
        'isActive': true,
      },
      {
        'code': 'PICKLE100',
        'description': '\u20B9100 off on orders above \u20B91000',
        'type': CouponType.fixed.name,
        'value': 100,
        'minOrderAmount': 1000,
        'isActive': true,
      },
    ];

    final batch = _firestore.batch();
    for (final coupon in coupons) {
      final docRef = _couponsCollection.doc(coupon['code'] as String);
      batch.set(docRef, {
        ...coupon,
        'usedCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    debugPrint('Seeded ${coupons.length} coupons');
  }
}
