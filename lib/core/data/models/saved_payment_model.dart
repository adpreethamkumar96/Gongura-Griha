import 'package:cloud_firestore/cloud_firestore.dart';

/// Payment method type
enum SavedPaymentType {
  card,
  upi;

  String get displayName {
    switch (this) {
      case SavedPaymentType.card:
        return 'Card';
      case SavedPaymentType.upi:
        return 'UPI';
    }
  }
}

/// Saved payment method model
class SavedPaymentModel {
  final String id;
  final SavedPaymentType type;
  final String displayName; // e.g., "Visa ****4242" or "user@upi"
  final String? cardNetwork; // Visa, Mastercard, etc.
  final String? last4; // last 4 digits for cards
  final String? upiId; // UPI ID
  final bool isDefault;
  final DateTime createdAt;

  SavedPaymentModel({
    required this.id,
    required this.type,
    required this.displayName,
    this.cardNetwork,
    this.last4,
    this.upiId,
    this.isDefault = false,
    required this.createdAt,
  });

  factory SavedPaymentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavedPaymentModel(
      id: doc.id,
      type: SavedPaymentType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'card'),
        orElse: () => SavedPaymentType.card,
      ),
      displayName: data['displayName'] as String? ?? '',
      cardNetwork: data['cardNetwork'] as String?,
      last4: data['last4'] as String?,
      upiId: data['upiId'] as String?,
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'displayName': displayName,
      'cardNetwork': cardNetwork,
      'last4': last4,
      'upiId': upiId,
      'isDefault': isDefault,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Get icon name based on type
  String get iconName {
    if (type == SavedPaymentType.upi) return 'account_balance';
    switch (cardNetwork?.toLowerCase()) {
      case 'visa':
        return 'credit_card';
      case 'mastercard':
        return 'credit_card';
      default:
        return 'credit_card';
    }
  }
}
