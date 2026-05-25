import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pscommunitymobileapp/core/constants/app_strings_preboot.dart';

class PrebootColors {
  static const background = Color(0xFF0F172A);
  static const errorIcon = Color(0xFFEF4444);
  static const textPrimary = AppColors.white;
  static const textSecondary = Color(0xFF94A3B8);
  static const logBackground = Color(0xFF1E293B);
  static const logBorder = AppColors.white10;
  static const logHeader = Color(0xFF3B82F6);
  static const logText = Color(0xFFF1F5F9);
  static const buttonBg = Color(0xFF3B82F6);
  static const buttonText = AppColors.white;
}

class FatalErrorScreen extends StatelessWidget {
  const FatalErrorScreen({super.key, required this.error, this.stackTrace});
  final Object error;
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: PrebootColors.background,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: PrebootColors.errorIcon,
                  size: 80,
                ),
                SizedBox(height: 24.h),
                Text(
                  PrebootStrings.initError,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displaySmall.copyWith(
                    color: PrebootColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  PrebootStrings.initBody,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: PrebootColors.textSecondary,
                    height: 1.5.h,
                  ),
                ),
                SizedBox(height: 32.h),
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: PrebootColors.logBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PrebootColors.logBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PrebootStrings.errorLog,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: PrebootColors.logHeader,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '$error',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: PrebootColors.logText,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 48.h),
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PrebootColors.buttonBg,
                    foregroundColor: PrebootColors.buttonText,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    PrebootStrings.closeApp,
                    style: AppTextStyles.labelLarge.copyWith(
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
