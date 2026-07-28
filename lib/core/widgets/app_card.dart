import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final double? borderRadius;
  final BoxBorder? border;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation = 0.04,
    this.onTap,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final double radius = borderRadius ?? 16.r;
    final Color bgColor = color ?? AppColors.white;

    Widget cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: (elevation != null && elevation! > 0)
            ? [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: elevation!),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Material(
          color: Colors.transparent,
          child: onTap != null
              ? InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: padding ?? EdgeInsets.all(16.w),
                    child: child,
                  ),
                )
              : Padding(
                  padding: padding ?? EdgeInsets.all(16.w),
                  child: child,
                ),
        ),
      ),
    );

    return cardContent;
  }
}
