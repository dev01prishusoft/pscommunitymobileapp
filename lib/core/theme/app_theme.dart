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
  static const Color red = Color(0xFFD32F2F);
  static const orange = Color(0xFFFDBA13);
  static Color primary = const Color(0xFF042563);
  static Color secondary = const Color(0xFF0d85dc);

  // Status & badge colors
  static const Color success = Color(0xFF1E8E3E);
  static const Color successLight = Color(0xFFE6F4EA);
  static const Color error = Color(0xFFD93025);
  static const Color errorLight = Color(0xFFFCE8E6);
  static const Color warning = Color(0xFFE37400);
  static const Color warningLight = Color(0xFFFEF7E0);
  static const Color info = Color(0xFF1A73E8);
  static const Color infoLight = Color(0xFFE8F0FE);
  static const Color neutral = Color(0xFF5F6368);
  static const Color neutralLight = Color(0xFFF1F3F4);

  static const Color defaultPrimary = Color(0xFF042563);
  static const Color defaultSecondary = Color(0xFF0d85dc);

  static void updateColors(String? primaryHex, String? secondaryHex) {
    if (primaryHex != null && primaryHex.isNotEmpty) {
      primary = _hexToColor(primaryHex) ?? defaultPrimary;
    } else {
      primary = defaultPrimary;
    }

    if (secondaryHex != null && secondaryHex.isNotEmpty) {
      secondary = _hexToColor(secondaryHex) ?? defaultSecondary;
    } else {
      secondary = defaultSecondary;
    }
  }

  static Color? _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
    }
    buffer.write(hexString.replaceFirst('#', ''));
    final val = int.tryParse(buffer.toString(), radix: 16);
    if (val == null) return null;
    return Color(val);
  }

  static const chart1 = Color(0xFF1AA3E8);
  static const chart2 = Color(0xFF3F6BB8);
  static const chart3 = Color(0xFF0F2444);
  static const chart4 = Color(0xFFD4A24A);
  static const chart5 = Color(0xFFC26A3C);

  // Family Tree Colors
  static const Color treeCanvasBackground = Color(0xFFF1F5F9);
  static const Color treeMale = Color(0xFF3B82F6);
  static const Color treeMaleDark = Color(0xFF1D4ED8);
  static const Color treeMaleBg = Color(0xFFF0F5FA);
  static const Color treeMaleBgEnd = Color(0xFFE2EDF7);
  static const Color treeMaleBorder = Color(0xFF93C5FD);
  static const Color treeMaleAccent = Color(0xFF1E40AF);

  static const Color treeFemale = Color(0xFFEC4899);
  static const Color treeFemaleDark = Color(0xFFBE185D);
  static const Color treeFemaleBg = Color(0xFFFDF2F4);
  static const Color treeFemaleBgEnd = Color(0xFFFBE4E8);
  static const Color treeFemaleBorder = Color(0xFFF472B6);
  static const Color treeFemaleAccent = Color(0xFFBE185D);

  static const Color treeOther = Color(0xFF8B5CF6);
  static const Color treeOtherDark = Color(0xFF6D28D9);
  static const Color treeOtherBg = Color(0xFFF5F3FF);
  static const Color treeOtherBgEnd = Color(0xFFEDE9FE);
  static const Color treeOtherBorder = Color(0xFFA78BFA);
  static const Color treeOtherAccent = Color(0xFF7C3AED);

  static const Color treeHead = Color(0xFFF59E0B);
  static const Color treeHeadDark = Color(0xFFD97706);
  static const Color treeHeadText = Color(0xFFB45309);
  static const Color treeHeadBg = Color(0xFFFEF3C7);

  static const Color treeSpouse = Color(0xFFE11D48);
  static const Color treeSelected = Color(0xFF10B981);
  static const Color treeBranchLine = Color(0xFF64748B);
  static const Color treeSlateDark = Color(0xFF0F172A);
  static const Color treeSlateText = Color(0xFF1E293B);
  static const Color treeSlateMuted = Color(0xFF475569);
  static const Color treeSlateLight = Color(0xFF334155);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    dividerColor: AppColors.grey,
    primaryColor: AppColors.primary,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primary,
      selectionColor: AppColors.primary.withValues(alpha: 0.3),
      selectionHandleColor: AppColors.primary,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(AppColors.primary),
      radius: const Radius.circular(8),
      thickness: const WidgetStatePropertyAll(6),
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
    tooltipTheme: const TooltipThemeData(
      triggerMode: TooltipTriggerMode.manual,
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
        fontSize: 17,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      errorMaxLines: 5,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.grey,
        overflow: TextOverflow.ellipsis,
      ),
      hintMaxLines: 1,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 1.w,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.5),
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
        borderSide: BorderSide(color: AppColors.red, width: 1.5.w),
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
