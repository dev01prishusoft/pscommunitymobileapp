import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class AppTextStyles {
  // Headline – large bold text
  static TextStyle get headlineBold => const TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: AppColors.foreground,
      );

  // Sub‑title – medium weight
  static TextStyle get subtitle => const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
      );

  // Button text – regular button label
  static TextStyle get button => const TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  // Small hint text
  static TextStyle get hint => const TextStyle(
        fontSize: 12.0,
        fontWeight: FontWeight.normal,
        color: AppColors.mutedForeground,
      );
}
