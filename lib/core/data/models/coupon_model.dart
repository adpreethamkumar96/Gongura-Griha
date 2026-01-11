import 'package:cloud_firestore/cloud_firestore.dart';

/// Coupon type
enum CouponType {
  percentage,
  fixed,
  freeDelivery;

  String get displayName {
    switch (this) {
      case CouponType.percentage:
        return 'Percentage Off';
      case CouponType.fixed:
        return 'Fixed Amount';
      case CouponType.freeDelivery:
        return 'Free Delivery';
    }
  }
}

/// Coupon model for Firestore
class CouponModel {
  final String code;
  final String description;
  final CouponType type;
  final double value; // percentage (0-100) or fixed amount
  final double minOrderAmount;
  final double? maxDiscount; // for percentage coupons
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int? usageLimit; // total uses allowed
  final int? usagePerUser; // uses per user
  final int usedCount;
  final bool isActive;
  final List<String>? applicableCategories; // null = all categories

  CouponModel({
    required this.code,
    required this.description,
    required this.type,
    required this.value,
    this.minOrderAmount = 0,
    this.maxDiscount,
    this.validFrom,
    this.validUntil,
    this.usageLimit,
    this.usagePerUser,
    this.usedCount = 0,
    this.isActive = true,
    this.applicableCategories,
  });

  factory CouponModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CouponModel(
      code: doc.id,
      description: data['description'] as String? ?? '',
      type: CouponType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'percentage'),
        orElse: () => CouponType.percentage,
      ),
      value: (data['value'] as num?)?.toDouble() ?? 0,
      minOrderAmount: (data['minOrderAmount'] as num?)?.toDouble() ?? 0,
      maxDiscount: (data['maxDiscount'] as num?)?.toDouble(),
      validFrom: (data['validFrom'] as Timestamp?)?.toDate(),
      validUntil: (data['validUntil'] as Timestamp?)?.toDate(),
      usageLimit: data['usageLimit'] as int?,
      usagePerUser: data['usagePerUser'] as int?,
      usedCount: data['usedCount'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      applicableCategories: (data['applicableCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'description': description,
      'type': type.name,
      'value': value,
      'minOrderAmount': minOrderAmount,
      'maxDiscount': maxDiscount,
      'validFrom': validFrom != null ? Timestamp.fromDate(validFrom!) : null,
      'validUntil': validUntil != null ? Timestamp.fromDate(validUntil!) : null,
      'usageLimit': usageLimit,
      'usagePerUser': usagePerUser,
      'usedCount': usedCount,
      'isActive': isActive,
      'applicableCategories': applicableCategories,
    };
  }

  /// Check if coupon is valid
  bool get isValid {
    if (!isActive) return false;
    final now = DateTime.now();
    if (validFrom != null && now.isBefore(validFrom!)) return false;
    if (validUntil != null && now.isAfter(validUntil!)) return false;
    if (usageLimit != null && usedCount >= usageLimit!) return false;
    return true;
  }

  /// Calculate discount amount
  double calculateDiscount(double orderAmount) {
    if (!isValid) return 0;
    if (orderAmount < minOrderAmount) return 0;

    switch (type) {
      case CouponType.percentage:
        var discount = orderAmount * (value / 100);
        if (maxDiscount != null && discount > maxDiscount!) {
          discount = maxDiscount!;
        }
        return discount;
      case CouponType.fixed:
        return value;
      case CouponType.freeDelivery:
        return 0; // Handled separately
    }
  }
}

/// Coupon validation result
class CouponValidationResult {
  final bool isValid;
  final String? errorMessage;
  final CouponModel? coupon;
  final double discountAmount;

  CouponValidationResult({
    required this.isValid,
    this.errorMessage,
    this.coupon,
    this.discountAmount = 0,
  });

  factory CouponValidationResult.invalid(String message) {
    return CouponValidationResult(
      isValid: false,
      errorMessage: message,
    );
  }

  factory CouponValidationResult.valid(CouponModel coupon, double discount) {
    return CouponValidationResult(
      isValid: true,
      coupon: coupon,
      discountAmount: discount,
    );
  }
}

/// Result of atomic coupon claim operation
class CouponClaimResult {
  final bool success;
  final String? error;
  final CouponModel? coupon;
  final double discountAmount;

  CouponClaimResult({
    required this.success,
    this.error,
    this.coupon,
    this.discountAmount = 0,
  });
}
