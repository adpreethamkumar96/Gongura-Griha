import 'package:cloud_firestore/cloud_firestore.dart';

/// Order status enum
enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  outForDelivery,
  delivered,
  cancelled,
  refunded;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
    }
  }

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// Payment method enum
enum PaymentMethod {
  upi,
  card,
  cod,
  netBanking;

  String get displayName {
    switch (this) {
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.cod:
        return 'Cash on Delivery';
      case PaymentMethod.netBanking:
        return 'Net Banking';
    }
  }

  static PaymentMethod fromString(String value) {
    return PaymentMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentMethod.cod,
    );
  }
}

/// Order model for Firestore
class OrderModel {
  final String id;
  final String orderNumber;
  final String userId;
  final List<OrderItem> items;
  final OrderAddress deliveryAddress;
  final double subtotal;
  final double deliveryCharge;
  final double discount;
  final double total;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;
  final String? trackingNumber;
  final String? cancellationReason;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.items,
    required this.deliveryAddress,
    required this.subtotal,
    required this.deliveryCharge,
    this.discount = 0,
    required this.total,
    required this.paymentMethod,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.trackingNumber,
    this.cancellationReason,
  });

  /// Total item count
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if order can be cancelled
  bool get canBeCancelled =>
      status == OrderStatus.pending ||
      status == OrderStatus.confirmed ||
      status == OrderStatus.processing;

  /// Create from Firestore document
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      orderNumber: data['orderNumber'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      items: (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      deliveryAddress: OrderAddress.fromMap(
        data['deliveryAddress'] as Map<String, dynamic>? ?? {},
      ),
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryCharge: (data['deliveryCharge'] as num?)?.toDouble() ?? 0,
      discount: (data['discount'] as num?)?.toDouble() ?? 0,
      total: (data['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: PaymentMethod.fromString(
        data['paymentMethod'] as String? ?? 'cod',
      ),
      status: OrderStatus.fromString(data['status'] as String? ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      deliveredAt: (data['deliveredAt'] as Timestamp?)?.toDate(),
      trackingNumber: data['trackingNumber'] as String?,
      cancellationReason: data['cancellationReason'] as String?,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'orderNumber': orderNumber,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'deliveryAddress': deliveryAddress.toMap(),
      'subtotal': subtotal,
      'deliveryCharge': deliveryCharge,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'deliveredAt':
          deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'trackingNumber': trackingNumber,
      'cancellationReason': cancellationReason,
    };
  }

  /// Create a copy with updated fields
  OrderModel copyWith({
    String? id,
    String? orderNumber,
    String? userId,
    List<OrderItem>? items,
    OrderAddress? deliveryAddress,
    double? subtotal,
    double? deliveryCharge,
    double? discount,
    double? total,
    PaymentMethod? paymentMethod,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveredAt,
    String? trackingNumber,
    String? cancellationReason,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      subtotal: subtotal ?? this.subtotal,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }
}

/// Order item model
class OrderItem {
  final String productSlug;
  final String productName;
  final String productImage;
  final String sizeCode;
  final String sizeName;
  final String weight;
  final int quantity;
  final double price;
  final double totalPrice;

  OrderItem({
    required this.productSlug,
    required this.productName,
    required this.productImage,
    required this.sizeCode,
    required this.sizeName,
    required this.weight,
    required this.quantity,
    required this.price,
    required this.totalPrice,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productSlug: map['productSlug'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      productImage: map['productImage'] as String? ?? '',
      sizeCode: map['sizeCode'] as String? ?? '',
      sizeName: map['sizeName'] as String? ?? '',
      weight: map['weight'] as String? ?? '',
      quantity: map['quantity'] as int? ?? 1,
      price: (map['price'] as num?)?.toDouble() ?? 0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productSlug': productSlug,
      'productName': productName,
      'productImage': productImage,
      'sizeCode': sizeCode,
      'sizeName': sizeName,
      'weight': weight,
      'quantity': quantity,
      'price': price,
      'totalPrice': totalPrice,
    };
  }
}

/// Order address model (snapshot of address at order time)
class OrderAddress {
  final String name;
  final String phone;
  final String address;
  final String landmark;
  final String city;
  final String state;
  final String pincode;
  final String type;

  OrderAddress({
    required this.name,
    required this.phone,
    required this.address,
    this.landmark = '',
    required this.city,
    this.state = '',
    required this.pincode,
    this.type = 'Home',
  });

  String get fullAddress {
    final parts = [address];
    if (landmark.isNotEmpty) parts.add(landmark);
    parts.add('$city - $pincode');
    if (state.isNotEmpty) parts.add(state);
    return parts.join(', ');
  }

  factory OrderAddress.fromMap(Map<String, dynamic> map) {
    return OrderAddress(
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? '',
      landmark: map['landmark'] as String? ?? '',
      city: map['city'] as String? ?? '',
      state: map['state'] as String? ?? '',
      pincode: map['pincode'] as String? ?? '',
      type: map['type'] as String? ?? 'Home',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'type': type,
    };
  }
}
