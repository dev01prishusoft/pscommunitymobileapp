import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';

class AppColors {
  static const grey = Colors.grey;
  static const blue = Colors.blue;
  static const white = Colors.white;
  static const black = Colors.black;
  static const green = Colors.green;
  static const pink = Colors.pink;
  static Color sfBackground = Colors.grey.shade50;
  static const transparent = Colors.transparent;
  static Color red = Colors.red.shade900;
  static const orange = Color(0xFFFDBA13);
  static const primary = Color(0xFF8F0500);
  static const secondary = Color(0xFF4A0200);
  static const chart1 = Color(0xFF1AA3E8);
  static const chart2 = Color(0xFF3F6BB8);
  static const chart3 = Color(0xFF0F2444);
  static const chart4 = Color(0xFFD4A24A);
  static const chart5 = Color(0xFFC26A3C);
}

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    dividerColor: AppColors.grey,
    primaryColor: AppColors.primary,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primary.withValues(alpha: 0.3),
      selectionHandleColor: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.sfBackground,
    splashColor: AppColors.primary.withValues(alpha: 0.1),
    highlightColor: AppColors.primary.withValues(alpha: 0.05),
    splashFactory: NoSplash.splashFactory,
    cardTheme: CardThemeData(color: AppColors.white),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      strokeWidth: 1.5,
      color: AppColors.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),

    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      iconTheme: IconThemeData(color: AppColors.black),
      titleTextStyle: TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      errorMaxLines: 5,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.grey.withValues(alpha: 0.5),
          width: 1.w,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 1.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.red, width: 1.w),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 1.w),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.grey.withValues(alpha: 0.5),
          width: 1.w,
        ),
      ),
      errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.red),
    ),
  );
}
