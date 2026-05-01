import 'package:flutter/material.dart';

class AppColors {
  // 🔷 Brand
  static const primary = Color(0xFF1AA3E8);
  static const primaryForeground = Color(0xFFFFFFFF);

  static const secondary = Color(0xFF0F2444);
  static const secondaryForeground = Color(0xFFF8FAFC);

  // 🎨 Surface
  static const background = Color(0xFFFFFFFF);
  static const foreground = Color(0xFF1A2238);

  static const card = Color(0xFFFFFFFF);
  static const cardForeground = Color(0xFF1A2238);

  static const popover = Color(0xFFFFFFFF);
  static const popoverForeground = Color(0xFF1A2238);

  static const muted = Color(0xFFF4F6F8);
  static const mutedForeground = Color(0xFF6B7280);

  static const accent = Color(0xFFE2F1FB);
  static const accentForeground = Color(0xFF1B5A85);

  static const border = Color(0xFFE3E8EE);
  static const input = Color(0xFFE3E8EE);

  static const ring = Color(0xFF1AA3E8);

  // ⚠️ Status
  static const destructive = Color(0xFFE11D2E);
  static const destructiveForeground = Color(0xFFFFFFFF);

  // ✅ Recommended additions
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);

  // 📊 Chart
  static const chart1 = Color(0xFF1AA3E8);
  static const chart2 = Color(0xFF3F6BB8);
  static const chart3 = Color(0xFF0F2444);
  static const chart4 = Color(0xFFD4A24A);
  static const chart5 = Color(0xFFC26A3C);

  // 📂 Sidebar
  static const sidebarBackground = Color(0xFF0B1B36);
  static const sidebarForeground = Color(0xFFE3E8EE);
  static const sidebarPrimary = Color(0xFF1AA3E8);
  static const sidebarAccent = Color(0xFF1A2C4F);
  static const sidebarBorder = Color(0xFF1F3257);
}

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,

    // 🔷 Core Colors
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme(
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

    // 📝 Text Theme
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.foreground),
      bodyMedium: TextStyle(color: AppColors.foreground),
      bodySmall: TextStyle(color: AppColors.mutedForeground),

      titleLarge: TextStyle(
        color: AppColors.foreground,
        fontWeight: FontWeight.w600,
      ),
    ),

    // 🔘 Buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryForeground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),

    // 🧾 Cards
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // 🧩 Input Fields
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    ),

    // 📏 Divider / Border
    dividerColor: AppColors.border,

    // 🔵 AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.foreground,
      elevation: 0,
    ),

    // 🎯 Focus / Ripple
    splashColor: AppColors.primary.withValues(alpha: 0.1),
    highlightColor: AppColors.primary.withValues(alpha: 0.05),
  );
}
