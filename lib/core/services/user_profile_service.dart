import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../data/models/user_profile_model.dart';

/// User Profile Service
///
/// Manages user profile data in Firestore and profile pictures in Firebase Storage.
class UserProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  DocumentReference<Map<String, dynamic>> _getUserDoc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Get user profile
  Future<UserProfileModel?> getProfile(String uid) async {
    try {
      final doc = await _getUserDoc(uid).get();
      if (!doc.exists) return null;
      return UserProfileModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      return null;
    }
  }

  /// Stream of user profile
  Stream<UserProfileModel?> getProfileStream(String uid) {
    return _getUserDoc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfileModel.fromFirestore(doc);
    });
  }

  /// Create or update user profile
  Future<bool> saveProfile(UserProfileModel profile) async {
    try {
      await _getUserDoc(profile.uid).set(
        profile.toFirestore(),
        SetOptions(merge: true),
      );
      debugPrint('Profile saved for ${profile.uid}');
      return true;
    } catch (e) {
      debugPrint('Error saving profile: $e');
      return false;
    }
  }

  /// Update specific fields
  Future<bool> updateProfile({
    required String uid,
    String? displayName,
    String? email,
    String? phoneNumber,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updates['displayName'] = displayName;
      if (email != null) updates['email'] = email;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (preferences != null) updates['preferences'] = preferences;

      await _getUserDoc(uid).update(updates);
      return true;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  /// Upload profile picture to Firebase Storage
  Future<String?> uploadProfilePicture(String uid, File imageFile) async {
    try {
      final ref = _storage.ref().child('profile_pictures/$uid.jpg');

      // Upload file
      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();

      // Update profile with photo URL
      await _getUserDoc(uid).update({
        'photoUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Profile picture uploaded for $uid');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      return null;
    }
  }

  /// Delete profile picture
  Future<bool> deleteProfilePicture(String uid) async {
    try {
      // Delete from storage
      final ref = _storage.ref().child('profile_pictures/$uid.jpg');
      try {
        await ref.delete();
      } catch (e) {
        // File might not exist, continue anyway
        debugPrint('Profile picture file not found: $e');
      }

      // Remove URL from profile
      await _getUserDoc(uid).update({
        'photoUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      debugPrint('Error deleting profile picture: $e');
      return false;
    }
  }

  /// Create profile for new user
  Future<UserProfileModel> createProfileForNewUser({
    required String uid,
    String? displayName,
    String? email,
    String? phoneNumber,
  }) async {
    final profile = UserProfileModel(
      uid: uid,
      displayName: displayName,
      email: email,
      phoneNumber: phoneNumber,
      createdAt: DateTime.now(),
    );

    await saveProfile(profile);
    return profile;
  }

  /// Update user preferences
  Future<bool> updatePreferences(
    String uid,
    Map<String, dynamic> preferences,
  ) async {
    try {
      await _getUserDoc(uid).update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating preferences: $e');
      return false;
    }
  }

  /// Delete all user data (for account deletion)
  ///
  /// Deletes:
  /// - User profile document
  /// - Profile picture from storage
  /// - All subcollections (wishlist, used coupons)
  Future<void> deleteUserData(String uid) async {
    try {
      // Delete profile picture from storage
      try {
        final ref = _storage.ref().child('profile_pictures/$uid.jpg');
        await ref.delete();
      } catch (e) {
        // File might not exist, continue
        debugPrint('Profile picture not found during deletion: $e');
      }

      // Delete wishlist subcollection
      final wishlistSnapshot =
          await _getUserDoc(uid).collection('wishlist').get();
      for (final doc in wishlistSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete used coupons subcollection
      final couponsSnapshot =
          await _getUserDoc(uid).collection('usedCoupons').get();
      for (final doc in couponsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete the user profile document
      await _getUserDoc(uid).delete();

      debugPrint('User data deleted for $uid');
    } catch (e) {
      debugPrint('Error deleting user data: $e');
      rethrow;
    }
  }
}
