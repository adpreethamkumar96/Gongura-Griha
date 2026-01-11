import 'package:cloud_firestore/cloud_firestore.dart';

/// Address type enum
enum AddressType {
  home,
  office,
  other;

  String get displayName {
    switch (this) {
      case AddressType.home:
        return 'Home';
      case AddressType.office:
        return 'Office';
      case AddressType.other:
        return 'Other';
    }
  }

  static AddressType fromString(String value) {
    return AddressType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AddressType.home,
    );
  }
}

/// Address model for Firestore
class AddressModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String address;
  final String landmark;
  final String city;
  final String state;
  final String pincode;
  final AddressType type;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AddressModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.address,
    this.landmark = '',
    required this.city,
    this.state = 'Telangana',
    required this.pincode,
    this.type = AddressType.home,
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get full formatted address
  String get fullAddress {
    final parts = [address];
    if (landmark.isNotEmpty) parts.add(landmark);
    parts.add('$city - $pincode');
    if (state.isNotEmpty) parts.add(state);
    return parts.join(', ');
  }

  /// Get short address (first line + city)
  String get shortAddress {
    return '$address, $city - $pincode';
  }

  /// Create from Firestore document
  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AddressModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      landmark: data['landmark'] as String? ?? '',
      city: data['city'] as String? ?? '',
      state: data['state'] as String? ?? 'Telangana',
      pincode: data['pincode'] as String? ?? '',
      type: AddressType.fromString(data['type'] as String? ?? 'home'),
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'address': address,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'type': type.name,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Create a copy with updated fields
  AddressModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? address,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    AddressType? type,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to OrderAddress for orders
  Map<String, dynamic> toOrderAddress() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'type': type.displayName,
    };
  }
}
