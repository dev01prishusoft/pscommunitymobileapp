import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.secondaryIcon,
    this.actionButton,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData? secondaryIcon;
  final Widget? actionButton;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxxl, horizontal: AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
              if (secondaryIcon != null)
                Positioned(
                  top: 10,
                  child: Icon(
                    secondaryIcon,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          AppSpacing.vL,
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.secondary,
            ),
          ),
          AppSpacing.vS,
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
          if (actionButton != null) ...[AppSpacing.vXxl, actionButton!],
        ],
      ),
    );
  }
}
