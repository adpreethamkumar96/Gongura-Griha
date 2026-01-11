import 'package:hive/hive.dart';

/// Hive model for wishlist items
///
/// Stores wishlisted products locally for persistence across sessions.
class WishlistItemModel extends HiveObject {
  final String productSlug;
  final String productName;
  final String productImage;
  final double basePrice;
  final String category;
  final bool isVeg;
  final DateTime addedAt;

  WishlistItemModel({
    required this.productSlug,
    required this.productName,
    required this.productImage,
    required this.basePrice,
    required this.category,
    this.isVeg = true,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  /// Convert to Map for display
  Map<String, dynamic> toMap() {
    return {
      'productSlug': productSlug,
      'productName': productName,
      'productImage': productImage,
      'basePrice': basePrice,
      'category': category,
      'isVeg': isVeg,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  /// Create from Map
  factory WishlistItemModel.fromMap(Map<String, dynamic> map) {
    return WishlistItemModel(
      productSlug: map['productSlug'] as String,
      productName: map['productName'] as String,
      productImage: map['productImage'] as String,
      basePrice: (map['basePrice'] as num).toDouble(),
      category: map['category'] as String,
      isVeg: map['isVeg'] as bool? ?? true,
      addedAt: map['addedAt'] != null
          ? DateTime.parse(map['addedAt'] as String)
          : null,
    );
  }
}

/// Hive TypeAdapter for WishlistItemModel
class WishlistItemModelAdapter extends TypeAdapter<WishlistItemModel> {
  @override
  final int typeId = 1;

  @override
  WishlistItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WishlistItemModel(
      productSlug: fields[0] as String,
      productName: fields[1] as String,
      productImage: fields[2] as String,
      basePrice: fields[3] as double,
      category: fields[4] as String,
      isVeg: fields[5] as bool? ?? true,
      addedAt: fields[6] != null
          ? DateTime.fromMillisecondsSinceEpoch(fields[6] as int)
          : null,
    );
  }

  @override
  void write(BinaryWriter writer, WishlistItemModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.productSlug)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.productImage)
      ..writeByte(3)
      ..write(obj.basePrice)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.isVeg)
      ..writeByte(6)
      ..write(obj.addedAt.millisecondsSinceEpoch);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WishlistItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
