import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/models/address_model.dart';

/// Address Service
///
/// Manages user addresses with Firestore backend.
class AddressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _addressesCollection =>
      _firestore.collection('addresses');

  /// Add a new address
  Future<AddressModel> addAddress({
    required String userId,
    required String name,
    required String phone,
    required String address,
    String landmark = '',
    required String city,
    String state = 'Telangana',
    required String pincode,
    AddressType type = AddressType.home,
    bool isDefault = false,
  }) async {
    try {
      final now = DateTime.now();

      // If this is the first address or marked as default, update other addresses
      if (isDefault) {
        await _clearDefaultAddress(userId);
      }

      // Check if this is the first address for the user
      final existingAddresses = await getUserAddresses(userId);
      final shouldBeDefault = isDefault || existingAddresses.isEmpty;

      final addressData = {
        'userId': userId,
        'name': name,
        'phone': phone,
        'address': address,
        'landmark': landmark,
        'city': city,
        'state': state,
        'pincode': pincode,
        'type': type.name,
        'isDefault': shouldBeDefault,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _addressesCollection.add(addressData);
      final doc = await docRef.get();

      debugPrint('Address added: ${docRef.id}');
      return AddressModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error adding address: $e');
      rethrow;
    }
  }

  /// Get all addresses for a user
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    try {
      final snapshot = await _addressesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('isDefault', descending: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AddressModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching addresses: $e');
      return [];
    }
  }

  /// Stream of user addresses (real-time updates)
  Stream<List<AddressModel>> getUserAddressesStream(String userId) {
    return _addressesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('isDefault', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AddressModel.fromFirestore(doc))
            .toList());
  }

  /// Get a single address by ID
  Future<AddressModel?> getAddress(String addressId) async {
    try {
      final doc = await _addressesCollection.doc(addressId).get();
      if (!doc.exists) return null;
      return AddressModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error fetching address: $e');
      return null;
    }
  }

  /// Get the default address for a user
  Future<AddressModel?> getDefaultAddress(String userId) async {
    try {
      final snapshot = await _addressesCollection
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        // If no default, return the first address
        final allAddresses = await getUserAddresses(userId);
        return allAddresses.isNotEmpty ? allAddresses.first : null;
      }

      return AddressModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      debugPrint('Error fetching default address: $e');
      return null;
    }
  }

  /// Update an address
  Future<bool> updateAddress({
    required String addressId,
    String? name,
    String? phone,
    String? address,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    AddressType? type,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (landmark != null) updateData['landmark'] = landmark;
      if (city != null) updateData['city'] = city;
      if (state != null) updateData['state'] = state;
      if (pincode != null) updateData['pincode'] = pincode;
      if (type != null) updateData['type'] = type.name;

      await _addressesCollection.doc(addressId).update(updateData);
      debugPrint('Address updated: $addressId');
      return true;
    } catch (e) {
      debugPrint('Error updating address: $e');
      return false;
    }
  }

  /// Set an address as default
  Future<bool> setDefaultAddress(String userId, String addressId) async {
    try {
      // Clear existing default
      await _clearDefaultAddress(userId);

      // Set new default
      await _addressesCollection.doc(addressId).update({
        'isDefault': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Default address set: $addressId');
      return true;
    } catch (e) {
      debugPrint('Error setting default address: $e');
      return false;
    }
  }

  /// Clear default flag from all user addresses
  Future<void> _clearDefaultAddress(String userId) async {
    try {
      final snapshot = await _addressesCollection
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing default address: $e');
    }
  }

  /// Delete an address
  Future<bool> deleteAddress(String addressId) async {
    try {
      await _addressesCollection.doc(addressId).delete();
      debugPrint('Address deleted: $addressId');
      return true;
    } catch (e) {
      debugPrint('Error deleting address: $e');
      return false;
    }
  }

  /// Get address count for a user
  Future<int> getUserAddressCount(String userId) async {
    try {
      final snapshot = await _addressesCollection
          .where('userId', isEqualTo: userId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting address count: $e');
      return 0;
    }
  }

  /// Delete all addresses for a user (for account deletion)
  Future<void> deleteAllUserAddresses(String userId) async {
    try {
      final snapshot = await _addressesCollection
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      debugPrint('All addresses deleted for user: $userId');
    } catch (e) {
      debugPrint('Error deleting all user addresses: $e');
      rethrow;
    }
  }
}
