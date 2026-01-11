import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/models/saved_payment_model.dart';

/// Saved Payment Methods Service
///
/// Manages saved payment methods in Firestore.
class SavedPaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getUserPaymentsCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('savedPayments');

  /// Get all saved payment methods for a user
  Future<List<SavedPaymentModel>> getSavedPayments(String userId) async {
    try {
      final snapshot = await _getUserPaymentsCollection(userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SavedPaymentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching saved payments: $e');
      return [];
    }
  }

  /// Stream of saved payment methods
  Stream<List<SavedPaymentModel>> getSavedPaymentsStream(String userId) {
    return _getUserPaymentsCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SavedPaymentModel.fromFirestore(doc))
            .toList());
  }

  /// Get default payment method
  Future<SavedPaymentModel?> getDefaultPayment(String userId) async {
    try {
      final snapshot = await _getUserPaymentsCollection(userId)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return SavedPaymentModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      debugPrint('Error fetching default payment: $e');
      return null;
    }
  }

  /// Save a new card
  Future<SavedPaymentModel?> saveCard({
    required String userId,
    required String cardNetwork,
    required String last4,
    bool isDefault = false,
  }) async {
    try {
      // If setting as default, unset other defaults
      if (isDefault) {
        await _unsetDefaultPayments(userId);
      }

      final displayName = '$cardNetwork ****$last4';
      final payment = SavedPaymentModel(
        id: '',
        type: SavedPaymentType.card,
        displayName: displayName,
        cardNetwork: cardNetwork,
        last4: last4,
        isDefault: isDefault,
        createdAt: DateTime.now(),
      );

      final docRef = await _getUserPaymentsCollection(userId).add(payment.toFirestore());
      final doc = await docRef.get();

      debugPrint('Card saved: $displayName');
      return SavedPaymentModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error saving card: $e');
      return null;
    }
  }

  /// Save a UPI ID
  Future<SavedPaymentModel?> saveUpi({
    required String userId,
    required String upiId,
    bool isDefault = false,
  }) async {
    try {
      // Check if UPI already exists
      final existing = await _getUserPaymentsCollection(userId)
          .where('upiId', isEqualTo: upiId)
          .get();

      if (existing.docs.isNotEmpty) {
        debugPrint('UPI ID already saved');
        return SavedPaymentModel.fromFirestore(existing.docs.first);
      }

      // If setting as default, unset other defaults
      if (isDefault) {
        await _unsetDefaultPayments(userId);
      }

      final payment = SavedPaymentModel(
        id: '',
        type: SavedPaymentType.upi,
        displayName: upiId,
        upiId: upiId,
        isDefault: isDefault,
        createdAt: DateTime.now(),
      );

      final docRef = await _getUserPaymentsCollection(userId).add(payment.toFirestore());
      final doc = await docRef.get();

      debugPrint('UPI saved: $upiId');
      return SavedPaymentModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error saving UPI: $e');
      return null;
    }
  }

  /// Set payment method as default
  Future<bool> setDefaultPayment(String userId, String paymentId) async {
    try {
      // Unset other defaults
      await _unsetDefaultPayments(userId);

      // Set new default
      await _getUserPaymentsCollection(userId).doc(paymentId).update({
        'isDefault': true,
      });

      return true;
    } catch (e) {
      debugPrint('Error setting default payment: $e');
      return false;
    }
  }

  /// Unset all default payments
  Future<void> _unsetDefaultPayments(String userId) async {
    final defaults = await _getUserPaymentsCollection(userId)
        .where('isDefault', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (final doc in defaults.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }

  /// Delete a saved payment method
  Future<bool> deletePayment(String userId, String paymentId) async {
    try {
      await _getUserPaymentsCollection(userId).doc(paymentId).delete();
      debugPrint('Payment deleted: $paymentId');
      return true;
    } catch (e) {
      debugPrint('Error deleting payment: $e');
      return false;
    }
  }
}
