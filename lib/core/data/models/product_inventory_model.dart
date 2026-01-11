import 'package:cloud_firestore/cloud_firestore.dart';

/// Product inventory model for Firestore
///
/// Tracks available stock for each product variant (size).
class ProductInventoryModel {
  final String productSlug;
  final String productName;
  final String productImage;
  final double basePrice;
  final String category;
  final bool isVeg;
  final bool isActive;
  final List<VariantInventory> variants;
  final DateTime? updatedAt;

  ProductInventoryModel({
    required this.productSlug,
    required this.productName,
    required this.productImage,
    required this.basePrice,
    required this.category,
    this.isVeg = true,
    this.isActive = true,
    required this.variants,
    this.updatedAt,
  });

  /// Get stock for a specific size
  int getStockForSize(String sizeCode) {
    final variant = variants.firstWhere(
      (v) => v.sizeCode == sizeCode,
      orElse: () => VariantInventory(
        sizeCode: sizeCode,
        sizeName: sizeCode,
        weight: '',
        price: 0,
        stock: 0,
        maxPerOrder: 0,
      ),
    );
    return variant.stock;
  }

  /// Get max quantity allowed per order for a size
  int getMaxPerOrderForSize(String sizeCode) {
    final variant = variants.firstWhere(
      (v) => v.sizeCode == sizeCode,
      orElse: () => VariantInventory(
        sizeCode: sizeCode,
        sizeName: sizeCode,
        weight: '',
        price: 0,
        stock: 0,
        maxPerOrder: 0,
      ),
    );
    // Return minimum of stock and maxPerOrder
    return variant.stock < variant.maxPerOrder ? variant.stock : variant.maxPerOrder;
  }

  /// Check if product is in stock
  bool get isInStock => variants.any((v) => v.stock > 0);

  /// Create from Firestore document
  factory ProductInventoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductInventoryModel(
      productSlug: doc.id,
      productName: data['productName'] as String? ?? '',
      productImage: data['productImage'] as String? ?? '',
      basePrice: (data['basePrice'] as num?)?.toDouble() ?? 0,
      category: data['category'] as String? ?? '',
      isVeg: data['isVeg'] as bool? ?? true,
      isActive: data['isActive'] as bool? ?? true,
      variants: (data['variants'] as List<dynamic>?)
              ?.map((v) => VariantInventory.fromMap(v as Map<String, dynamic>))
              .toList() ??
          [],
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'productName': productName,
      'productImage': productImage,
      'basePrice': basePrice,
      'category': category,
      'isVeg': isVeg,
      'isActive': isActive,
      'variants': variants.map((v) => v.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with updated fields
  ProductInventoryModel copyWith({
    String? productSlug,
    String? productName,
    String? productImage,
    double? basePrice,
    String? category,
    bool? isVeg,
    bool? isActive,
    List<VariantInventory>? variants,
    DateTime? updatedAt,
  }) {
    return ProductInventoryModel(
      productSlug: productSlug ?? this.productSlug,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      basePrice: basePrice ?? this.basePrice,
      category: category ?? this.category,
      isVeg: isVeg ?? this.isVeg,
      isActive: isActive ?? this.isActive,
      variants: variants ?? this.variants,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Variant (size) inventory
class VariantInventory {
  final String sizeCode; // S, M, L
  final String sizeName; // Small, Medium, Large
  final String weight; // 250g, 500g, 1kg
  final double price;
  final int stock; // Available quantity
  final int maxPerOrder; // Max quantity per order

  VariantInventory({
    required this.sizeCode,
    required this.sizeName,
    required this.weight,
    required this.price,
    required this.stock,
    required this.maxPerOrder,
  });

  /// Check if in stock
  bool get isInStock => stock > 0;

  /// Get effective max quantity (min of stock and maxPerOrder)
  int get effectiveMaxQuantity => stock < maxPerOrder ? stock : maxPerOrder;

  factory VariantInventory.fromMap(Map<String, dynamic> map) {
    return VariantInventory(
      sizeCode: map['sizeCode'] as String? ?? '',
      sizeName: map['sizeName'] as String? ?? '',
      weight: map['weight'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      stock: map['stock'] as int? ?? 0,
      maxPerOrder: map['maxPerOrder'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sizeCode': sizeCode,
      'sizeName': sizeName,
      'weight': weight,
      'price': price,
      'stock': stock,
      'maxPerOrder': maxPerOrder,
    };
  }

  VariantInventory copyWith({
    String? sizeCode,
    String? sizeName,
    String? weight,
    double? price,
    int? stock,
    int? maxPerOrder,
  }) {
    return VariantInventory(
      sizeCode: sizeCode ?? this.sizeCode,
      sizeName: sizeName ?? this.sizeName,
      weight: weight ?? this.weight,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      maxPerOrder: maxPerOrder ?? this.maxPerOrder,
    );
  }
}
