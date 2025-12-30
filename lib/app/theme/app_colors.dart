import 'package:flutter/material.dart';

/// App Colors
///
/// Contains all color constants used in the app.
/// Based on the UI/UX Guidelines document.
class AppColors {
  AppColors._();

  // ============ Primary Colors ============

  /// Primary green - Gongura leaf green
  static const Color primary = Color(0xFF2E7D32);

  /// Primary green light variant
  static const Color primaryLight = Color(0xFF4CAF50);

  /// Primary green dark variant
  static const Color primaryDark = Color(0xFF1B5E20);

  // ============ Secondary/Accent Colors ============

  /// Accent orange - Spice/Chili orange
  static const Color accent = Color(0xFFFF5722);

  /// Accent orange light variant
  static const Color accentLight = Color(0xFFFF8A65);

  // ============ Background Colors ============

  /// Primary background
  static const Color background = Color(0xFFFAFAFA);

  /// Secondary background (cards, surfaces)
  static const Color surface = Color(0xFFFFFFFF);

  /// Tertiary background
  static const Color backgroundSecondary = Color(0xFFF5F5F5);

  // ============ Text Colors ============

  /// Primary text color
  static const Color textPrimary = Color(0xFF212121);

  /// Secondary text color
  static const Color textSecondary = Color(0xFF757575);

  /// Tertiary/hint text color
  static const Color textTertiary = Color(0xFFBDBDBD);

  /// Text color on primary background
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ============ Status Colors ============

  /// Success color
  static const Color success = Color(0xFF4CAF50);

  /// Warning color
  static const Color warning = Color(0xFFFFC107);

  /// Error color
  static const Color error = Color(0xFFF44336);

  /// Info color
  static const Color info = Color(0xFF2196F3);

  // ============ Other Colors ============

  /// Divider color
  static const Color divider = Color(0xFFE0E0E0);

  /// Disabled color
  static const Color disabled = Color(0xFFBDBDBD);

  /// Overlay color (for modals)
  static const Color overlay = Color(0x80000000);

  /// Shimmer base color
  static const Color shimmerBase = Color(0xFFE0E0E0);

  /// Shimmer highlight color
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ============ Veg/Non-Veg Indicators ============

  /// Vegetarian indicator color
  static const Color veg = Color(0xFF00C853);

  /// Non-vegetarian indicator color
  static const Color nonVeg = Color(0xFFD32F2F);

  // ============ Rating Colors ============

  /// Star rating color
  static const Color rating = Color(0xFFFFC107);

  /// Discount badge color
  static const Color discount = Color(0xFFE91E63);

  // ============ Social Colors ============

  /// Google color
  static const Color google = Color(0xFFDB4437);

  /// Facebook color
  static const Color facebook = Color(0xFF4267B2);

  /// WhatsApp color
  static const Color whatsapp = Color(0xFF25D366);

  // ============ Payment Colors ============

  /// UPI color
  static const Color upi = Color(0xFF00897B);

  /// Card payment color
  static const Color card = Color(0xFF1565C0);

  /// COD color
  static const Color cod = Color(0xFF795548);

  // ============ Gradient Colors ============

  /// Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  /// Accent gradient
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentLight, accent],
  );

  // ============ Material Color Swatch ============

  /// Primary material color swatch
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF2E7D32,
    <int, Color>{
      50: Color(0xFFE8F5E9),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(0xFF4CAF50),
      600: Color(0xFF43A047),
      700: Color(0xFF388E3C),
      800: Color(0xFF2E7D32),
      900: Color(0xFF1B5E20),
    },
  );
}
