import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// App Typography
///
/// Contains all text styles used in the app.
/// Based on the UI/UX Guidelines document.
class AppTypography {
  AppTypography._();

  /// Base text style using Poppins font
  static TextStyle get _baseTextStyle => GoogleFonts.poppins(
        color: AppColors.textPrimary,
      );

  // ============ Headings ============

  /// Heading 1 - 32px Bold
  static TextStyle get h1 => _baseTextStyle.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  /// Heading 2 - 24px SemiBold
  static TextStyle get h2 => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  /// Heading 3 - 20px SemiBold
  static TextStyle get h3 => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  /// Heading 4 - 18px SemiBold
  static TextStyle get h4 => _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // ============ Body Text ============

  /// Body Large - 16px Regular
  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  /// Body Medium - 14px Regular
  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  /// Body Small - 12px Regular
  static TextStyle get bodySmall => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  // ============ Labels ============

  /// Label Large - 14px Medium
  static TextStyle get labelLarge => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  /// Label Medium - 12px Medium
  static TextStyle get labelMedium => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  /// Label Small - 10px Medium
  static TextStyle get labelSmall => _baseTextStyle.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.5,
      );

  // ============ Prices ============

  /// Price Regular - 16px SemiBold
  static TextStyle get priceRegular => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  /// Price Large - 20px Bold
  static TextStyle get priceLarge => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  /// Price Struck (original price with line-through)
  static TextStyle get priceStruck => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.2,
        decoration: TextDecoration.lineThrough,
        color: AppColors.textTertiary,
      );

  // ============ Buttons ============

  /// Button Large - 16px SemiBold
  static TextStyle get buttonLarge => _baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  /// Button Medium - 14px SemiBold
  static TextStyle get buttonMedium => _baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  /// Button Small - 12px SemiBold
  static TextStyle get buttonSmall => _baseTextStyle.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.25,
      );

  // ============ Special Styles ============

  /// App Bar Title
  static TextStyle get appBarTitle => h4.copyWith(
        color: AppColors.textPrimary,
      );

  /// Section Title
  static TextStyle get sectionTitle => h4;

  /// Product Name (Card)
  static TextStyle get productName => bodyMedium.copyWith(
        fontWeight: FontWeight.w500,
      );

  /// Product Name (Detail)
  static TextStyle get productNameLarge => h3;

  /// Category Name
  static TextStyle get categoryName => labelMedium;

  /// Rating Text
  static TextStyle get ratingText => labelMedium.copyWith(
        color: AppColors.textSecondary,
      );

  /// Input Label
  static TextStyle get inputLabel => labelMedium;

  /// Input Text
  static TextStyle get inputText => bodyMedium;

  /// Input Hint
  static TextStyle get inputHint => bodyMedium.copyWith(
        color: AppColors.textTertiary,
      );

  /// Input Error
  static TextStyle get inputError => bodySmall.copyWith(
        color: AppColors.error,
      );

  /// Link Text
  static TextStyle get link => bodyMedium.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      );

  /// Caption
  static TextStyle get caption => bodySmall.copyWith(
        color: AppColors.textSecondary,
      );

  /// Overline
  static TextStyle get overline => labelSmall.copyWith(
        letterSpacing: 1.5,
        color: AppColors.textSecondary,
      );
}
