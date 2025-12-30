import '../constants/app_constants.dart';

/// Input Validators
///
/// Contains validation functions for form inputs.
class Validators {
  Validators._();

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final cleaned = value.replaceAll(RegExp(r'\D'), '');

    if (cleaned.length != 10) {
      return 'Phone number must be 10 digits';
    }

    if (!AppConstants.phoneRegex.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validate email
  static String? validateEmail(String? value, {bool required = false}) {
    if (value == null || value.isEmpty) {
      return required ? 'Email is required' : null;
    }

    if (!AppConstants.emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validate name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 100) {
      return 'Name must be less than 100 characters';
    }

    if (!AppConstants.nameRegex.hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  /// Validate OTP
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != AppConstants.otpLength) {
      return 'OTP must be ${AppConstants.otpLength} digits';
    }

    if (!AppConstants.otpRegex.hasMatch(value)) {
      return 'OTP must contain only digits';
    }

    return null;
  }

  /// Validate PIN code
  static String? validatePinCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN code is required';
    }

    if (!AppConstants.pinCodeRegex.hasMatch(value)) {
      return 'Please enter a valid 6-digit PIN code';
    }

    return null;
  }

  /// Validate address
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }

    if (value.length < 10) {
      return 'Please enter a complete address';
    }

    if (value.length > 255) {
      return 'Address is too long';
    }

    return null;
  }

  /// Validate city
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }

    if (value.length < 2) {
      return 'City name is too short';
    }

    return null;
  }

  /// Validate state
  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'State is required';
    }

    return null;
  }

  /// Validate coupon code
  static String? validateCouponCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a coupon code';
    }

    if (value.length < 3 || value.length > 20) {
      return 'Invalid coupon code';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate password (if we add email/password login)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }
}
