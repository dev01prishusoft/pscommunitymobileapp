import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class AppTextStyles {
  // Headline – large bold text
  static TextStyle get headlineBold => TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.foreground,
      );

  // Sub‑title – medium weight
  static TextStyle get subtitle => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
      );

  // Button text – regular button label
  static TextStyle get button => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  // Small hint text
  static TextStyle get hint => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.mutedForeground,
      );
}
