import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';

class ResponsiveSection extends StatelessWidget {
  const ResponsiveSection({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.action,
    this.padding = AppSpacing.pM,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.l),
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final Widget? action;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: AppSpacing.pL,
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: AppColors.primary),
                  AppSpacing.hM,
                ],
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                if (action != null) action!,
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

class AdaptiveCard extends StatelessWidget {
  const AdaptiveCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.pM,
    this.margin = EdgeInsets.zero,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class AdaptiveListTile extends StatelessWidget {
  const AdaptiveListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AdaptiveCard(
      onTap: onTap,
      padding: AppSpacing.pM,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            AppSpacing.hM,
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                title,
                if (subtitle != null) ...[
                  AppSpacing.vXs,
                  subtitle!,
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            AppSpacing.hM,
            trailing!,
          ],
        ],
      ),
    );
  }
}
