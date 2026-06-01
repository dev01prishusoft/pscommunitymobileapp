import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Color(0x00000000);
  static const grey = Colors.grey;
  static const green = Colors.green;
  static const red = Colors.red;
  static const blue = Colors.blue;
  static const orange = Colors.orange;
  static const amber = Colors.amber;
  static const black87 = Colors.black87;
  static const black54 = Colors.black54;
  static const white10 = Colors.white10;
  static const black26 = Colors.black26;
  static const redAccent = Colors.redAccent;
  static const blueGrey = Colors.blueGrey;
  static const primary = Color(0xFF1AA3E8);
  static const primaryForeground = Color(0xFFFFFFFF);

  static const secondary = Color(0xFF0F2444);
  static const secondaryForeground = Color(0xFFF8FAFC);
  static const background = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF1A2238);

  static const card = Color(0xFFFFFFFF);
  static const cardForeground = Color(0xFF1A2238);

  static const popover = Color(0xFFFFFFFF);
  static const popoverForeground = Color(0xFF1A2238);

  static const muted = Color(0xFFF4F6F8);
  static const mutedForeground = Color(0xFF6B7280);

  static const shadow = Color(0xFF000000);

  static const accent = Color(0xFFE2F1FB);
  static const accentForeground = Color(0xFF1B5A85);

  static const border = Color(0xFFE3E8EE);
  static const input = Color(0xFFE3E8EE);

  static const ring = Color(0xFF1AA3E8);
  static const destructive = Color(0xFFE11D2E);
  static const destructiveForeground = Color(0xFFFFFFFF);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
  static const chart1 = Color(0xFF1AA3E8);
  static const chart2 = Color(0xFF3F6BB8);
  static const chart3 = Color(0xFF0F2444);
  static const chart4 = Color(0xFFD4A24A);
  static const chart5 = Color(0xFFC26A3C);
  static const sidebarBackground = Color(0xFF0B1B36);
  static const sidebarForeground = Color(0xFFE3E8EE);
  static const sidebarPrimary = Color(0xFF1AA3E8);
  static const sidebarAccent = Color(0xFF1A2C4F);
  static const sidebarBorder = Color(0xFF1F3257);
  static const navyBlue = Color(0xFF002B5B);
  static const deepBlue = Color(0xFF1E5BB6);
  static const deepGreen = Color(0xFF1B8D5E);
  static const lightGreen = Color(0xFFE8F5E9);
  static const lightBlue = Color(0xFFE2F1FB);
  static const slate = Color(0xFFF1F5F9);
  static const surfaceVariant = Color(0xFFF8FAFC);
}

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme(
      brightness: Brightness.light,

      primary: AppColors.primary,
      onPrimary: AppColors.primaryForeground,

      secondary: AppColors.secondary,
      onSecondary: AppColors.secondaryForeground,

      surface: AppColors.card,
      onSurface: AppColors.foreground,

      error: AppColors.destructive,
      onError: AppColors.destructiveForeground,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.foreground),
      bodyMedium: TextStyle(color: AppColors.foreground),
      bodySmall: TextStyle(color: AppColors.mutedForeground),

      titleLarge: TextStyle(
        color: AppColors.foreground,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.muted.withValues(alpha: 0.5),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      errorMaxLines: 5,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5.w),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.destructive, width: 1.w),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.destructive, width: 1.5.w),
      ),
    ),
    dividerColor: AppColors.border,
    dividerTheme: DividerThemeData(
      color: AppColors.slate,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.foreground,
      elevation: 0,
    ),
    splashColor: AppColors.primary.withValues(alpha: 0.1),
    highlightColor: AppColors.primary.withValues(alpha: 0.05),
  );
}
