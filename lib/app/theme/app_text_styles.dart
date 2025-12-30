import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// App Text Styles
///
/// Material Design-style text styles for the app.
class AppTextStyles {
  AppTextStyles._();

  /// Base text style using Poppins font
  static TextStyle get _baseTextStyle => GoogleFonts.poppins(
        color: AppColors.textPrimary,
      );

  // ============ Display Styles ============

  static TextStyle get displayLarge => _baseTextStyle.copyWith(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      );

  static TextStyle get displayMedium => _baseTextStyle.copyWith(
        fontSize: 45,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get displaySmall => _baseTextStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w400,
      );

  // ============ Headline Styles ============

  static TextStyle get headlineLarge => _baseTextStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineMedium => _baseTextStyle.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get headlineSmall => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  // ============ Title Styles ============

  static TextStyle get titleLarge => _baseTextStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMedium => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
      );

  static TextStyle get titleSmall => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );

  // ============ Body Styles ============

  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      );

  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      );

  static TextStyle get bodySmall => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      );

  // ============ Label Styles ============

  static TextStyle get labelLarge => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      );

  static TextStyle get labelMedium => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  static TextStyle get labelSmall => _baseTextStyle.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );
}
