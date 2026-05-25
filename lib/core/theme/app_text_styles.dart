import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class AppTextStyles {
  static TextStyle get displayLarge => TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.foreground,
  );
  static TextStyle get displayMedium => TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.foreground,
  );
  static TextStyle get displaySmall => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: AppColors.foreground,
  );
  static TextStyle get headlineLarge => TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.foreground,
  );
  static TextStyle get headlineMedium => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
  );
  static TextStyle get headlineSmall => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
  );
  static TextStyle get titleLarge => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
  );
  static TextStyle get titleMedium => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.foreground,
  );
  static TextStyle get titleSmall => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.foreground,
  );
  static TextStyle get bodyLarge => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.foreground,
  );
  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.foreground,
  );
  static TextStyle get bodySmall => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: AppColors.foreground,
  );
  static TextStyle get labelLarge => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
  );
  static TextStyle get labelMedium => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.foreground,
  );
  static TextStyle get labelSmall => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.foreground,
  );
  static TextStyle get headlineBold => displaySmall;
  static TextStyle get subtitle => titleLarge;
  static TextStyle get button => labelLarge.copyWith(color: AppColors.white);
  static TextStyle get hint =>
      bodySmall.copyWith(color: AppColors.mutedForeground);
}
