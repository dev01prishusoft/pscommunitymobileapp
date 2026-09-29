import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

/// Font sizes are logical pixels. Do not use `.sp` here: the platform already
/// applies the user's text-size setting (clamped to 1.0–2.0 in main.dart), and
/// `.sp` would additionally scale text with the screen size, inflating it on
/// tablets.
class AppTextStyles {
  static TextStyle get displayLarge => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  static TextStyle get displayMedium => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  static TextStyle get displaySmall => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );
  static TextStyle get headlineLarge => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );
  static TextStyle get headlineMedium => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static TextStyle get headlineSmall => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static TextStyle get titleLarge => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static TextStyle get titleMedium => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
  static TextStyle get titleSmall => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
  static TextStyle get bodyLarge => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );
  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );
  static TextStyle get bodySmall => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );
  static TextStyle get labelLarge => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static TextStyle get labelMedium => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );
  static TextStyle get labelSmall => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );
  static TextStyle get headlineBold => displaySmall;
  static TextStyle get subtitle => titleLarge;
  static TextStyle get button => labelLarge.copyWith(color: AppColors.white);
  static TextStyle get hint =>
      bodySmall.copyWith(color: AppColors.black);
}
