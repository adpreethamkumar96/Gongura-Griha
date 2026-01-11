import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../di/injection.dart';

/// Authentication service using Firebase Auth
///
/// Handles phone OTP authentication flow.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // OTP verification state
  String? _verificationId;
  int? _resendToken;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// Get user phone number
  String? get userPhone => _auth.currentUser?.phoneNumber;

  /// Get user display name
  String? get userName => _auth.currentUser?.displayName;

  /// Send OTP to phone number
  ///
  /// Returns a stream that emits verification states.
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(FirebaseAuthException error) onVerificationFailed,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    // Ensure phone number has country code
    String formattedPhone = phoneNumber;
    if (!phoneNumber.startsWith('+')) {
      formattedPhone = '+91$phoneNumber'; // Default to India
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      timeout: const Duration(seconds: 60),
      forceResendingToken: forceResendingToken,
      verificationCompleted: (PhoneAuthCredential credential) {
        // Auto-verification on Android
        onVerificationCompleted(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('Verification failed: ${e.message}');
        onVerificationFailed(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        onCodeAutoRetrievalTimeout(verificationId);
      },
    );
  }

  /// Verify OTP and sign in
  ///
  /// Returns the UserCredential on success, throws on failure.
  Future<UserCredential> verifyOtp({
    required String otp,
    String? verificationId,
  }) async {
    final verId = verificationId ?? _verificationId;

    if (verId == null) {
      throw AuthException(
        code: 'no-verification-id',
        message: 'No verification ID. Please request OTP first.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verId,
      smsCode: otp,
    );

    final userCredential = await _auth.signInWithCredential(credential);

    // Save FCM token and ensure user profile exists
    if (userCredential.user != null) {
      final user = userCredential.user!;
      await _saveFcmToken(user.uid);
      await _ensureUserProfileExists(user);

      // Track login/signup in analytics
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser) {
        await analyticsService.logSignUp(method: 'phone');
      } else {
        await analyticsService.logLogin(method: 'phone');
      }
      await analyticsService.setUserId(user.uid);
    }

    return userCredential;
  }

  /// Save FCM token to Firestore for push notifications
  Future<void> _saveFcmToken(String userId) async {
    try {
      await pushNotificationService.saveTokenToFirestore(userId);
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Ensure user profile exists in Firestore
  Future<void> _ensureUserProfileExists(User user) async {
    try {
      final existingProfile = await userProfileService.getProfile(user.uid);
      if (existingProfile == null) {
        // Create a basic profile for new users
        await userProfileService.createProfileForNewUser(
          uid: user.uid,
          displayName: user.displayName,
          phoneNumber: user.phoneNumber,
        );
        debugPrint('Created new user profile for ${user.uid}');
      }
    } catch (e) {
      debugPrint('Error ensuring user profile exists: $e');
    }
  }

  /// Sign in with credential (for auto-verification)
  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);

    // Save FCM token and ensure user profile exists
    if (userCredential.user != null) {
      final user = userCredential.user!;
      await _saveFcmToken(user.uid);
      await _ensureUserProfileExists(user);

      // Track login/signup in analytics
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser) {
        await analyticsService.logSignUp(method: 'phone');
      } else {
        await analyticsService.logLogin(method: 'phone');
      }
      await analyticsService.setUserId(user.uid);
    }

    return userCredential;
  }

  /// Update user display name
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  /// Update user email
  Future<void> updateEmail(String email) async {
    await _auth.currentUser?.verifyBeforeUpdateEmail(email);
  }

  /// Resend OTP
  Future<void> resendOtp({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(PhoneAuthCredential credential) onVerificationCompleted,
    required Function(FirebaseAuthException error) onVerificationFailed,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
  }) async {
    await sendOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationCompleted: onVerificationCompleted,
      onVerificationFailed: onVerificationFailed,
      onCodeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      forceResendingToken: _resendToken,
    );
  }

  /// Sign out
  Future<void> signOut() async {
    // Remove FCM token before signing out
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      try {
        await pushNotificationService.removeTokenFromFirestore(userId);
      } catch (e) {
        debugPrint('Error removing FCM token: $e');
      }
    }

    // Clear analytics user ID
    await analyticsService.setUserId(null);

    await _auth.signOut();
    _verificationId = null;
    _resendToken = null;
  }

  /// Delete user account and all associated data
  ///
  /// This performs the following:
  /// 1. Deletes all user data from Firestore (profile, addresses, orders, wishlist)
  /// 2. Removes FCM token
  /// 3. Clears local data (cart, wishlist)
  /// 4. Deletes Firebase Auth account
  ///
  /// Throws an exception if deletion fails.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw AuthException(
        code: 'not-authenticated',
        message: 'No user logged in',
      );
    }

    final userId = user.uid;

    try {
      // 1. Remove FCM token first
      await pushNotificationService.removeTokenFromFirestore(userId);

      // 2. Delete user data from Firestore
      await userProfileService.deleteUserData(userId);

      // 3. Delete addresses
      await addressService.deleteAllUserAddresses(userId);

      // 4. Clear local cart and wishlist
      await cartRepository.clearCart();
      await wishlistRepository.clearWishlist();

      // 5. Clear analytics user ID
      await analyticsService.setUserId(null);

      // 6. Finally, delete Firebase Auth account
      await user.delete();

      // Clear verification state
      _verificationId = null;
      _resendToken = null;

      debugPrint('Account deleted successfully for user: $userId');
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error during account deletion: ${e.code}');
      if (e.code == 'requires-recent-login') {
        throw AuthException(
          code: 'requires-recent-login',
          message: 'Please log out and log back in before deleting your account',
        );
      }
      rethrow;
    } catch (e) {
      debugPrint('Error during account deletion: $e');
      throw AuthException(
        code: 'deletion-failed',
        message: 'Failed to delete account. Please try again.',
      );
    }
  }

  /// Get resend token for re-sending OTP
  int? get resendToken => _resendToken;

  /// Get verification ID
  String? get verificationId => _verificationId;
}

/// Custom Auth Exception for app-specific errors
class AuthException implements Exception {
  final String code;
  final String message;

  AuthException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'AuthException: [$code] $message';

  /// Get user-friendly error message
  String get userMessage {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number. Please enter a valid number.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please check and try again.';
      case 'session-expired':
        return 'OTP expired. Please request a new one.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'no-verification-id':
        return 'Please request OTP first.';
      default:
        return message.isNotEmpty ? message : 'Authentication failed. Please try again.';
    }
  }
}
