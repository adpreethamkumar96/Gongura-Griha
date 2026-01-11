import 'package:hive/hive.dart';

/// Hive model for cart items
///
/// Stores cart items locally for persistence across sessions.
class CartItemModel extends HiveObject {
  final String productSlug;
  final String productName;
  final String productImage;
  final String sizeName;
  final String sizeCode;
  final String weight;
  final double price;
  int quantity;
  final int maxQuantity;
  final String category;
  final bool isVeg;

  CartItemModel({
    required this.productSlug,
    required this.productName,
    required this.productImage,
    required this.sizeName,
    required this.sizeCode,
    required this.weight,
    required this.price,
    required this.quantity,
    required this.maxQuantity,
    required this.category,
    this.isVeg = true,
  });

  /// Unique key for this cart item (product + size)
  String get cartKey => '${productSlug}_$sizeCode';

  /// Total price for this line item
  double get lineTotal => price * quantity;

  /// Create a copy with updated quantity
  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      productSlug: productSlug,
      productName: productName,
      productImage: productImage,
      sizeName: sizeName,
      sizeCode: sizeCode,
      weight: weight,
      price: price,
      quantity: quantity ?? this.quantity,
      maxQuantity: maxQuantity,
      category: category,
      isVeg: isVeg,
    );
  }

  /// Convert to Map for display
  Map<String, dynamic> toMap() {
    return {
      'productSlug': productSlug,
      'productName': productName,
      'productImage': productImage,
      'sizeName': sizeName,
      'sizeCode': sizeCode,
      'weight': weight,
      'price': price,
      'quantity': quantity,
      'maxQuantity': maxQuantity,
      'category': category,
      'isVeg': isVeg,
    };
  }

  /// Create from Map
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productSlug: map['productSlug'] as String,
      productName: map['productName'] as String,
      productImage: map['productImage'] as String,
      sizeName: map['sizeName'] as String,
      sizeCode: map['sizeCode'] as String,
      weight: map['weight'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      maxQuantity: map['maxQuantity'] as int,
      category: map['category'] as String,
      isVeg: map['isVeg'] as bool? ?? true,
    );
  }
}

/// Hive TypeAdapter for CartItemModel
class CartItemModelAdapter extends TypeAdapter<CartItemModel> {
  @override
  final int typeId = 0;

  @override
  CartItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItemModel(
      productSlug: fields[0] as String,
      productName: fields[1] as String,
      productImage: fields[2] as String,
      sizeName: fields[3] as String,
      sizeCode: fields[4] as String,
      weight: fields[5] as String,
      price: fields[6] as double,
      quantity: fields[7] as int,
      maxQuantity: fields[8] as int,
      category: fields[9] as String,
      isVeg: fields[10] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, CartItemModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.productSlug)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.productImage)
      ..writeByte(3)
      ..write(obj.sizeName)
      ..writeByte(4)
      ..write(obj.sizeCode)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.quantity)
      ..writeByte(8)
      ..write(obj.maxQuantity)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.isVeg);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
