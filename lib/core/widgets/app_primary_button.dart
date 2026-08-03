import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_loading_indicator.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.color,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (onPressed != null && !isLoading)
            BoxShadow(
              color: buttonColor.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: buttonColor.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? AppLoadingIndicator(
                size: 20,
                strokeWidth: 2,
                color: AppColors.white,
              )
            : Text(
                text,
                style: AppTextStyles.titleSmall.copyWith(
                  letterSpacing: 0.5,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
