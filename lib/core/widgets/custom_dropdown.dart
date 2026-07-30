import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class CustomDropdown<T> extends StatelessWidget {
  const CustomDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.isEnabled = true,
    this.isLoading = false,
    this.height,
    this.fillColor,
    this.padding,
    this.iconSize,
    this.style,
    this.isExpanded = true,
  });

  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final bool isEnabled;
  final bool isLoading;
  final double? height;
  final Color? fillColor;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;
  final TextStyle? style;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 52.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fillColor ?? (isEnabled
            ? AppColors.white
            : AppColors.grey.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isEnabled
              ? (value != null
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.grey.withValues(alpha: 0.25))
              : AppColors.grey.withValues(alpha: 0.15),
          width: 1.2.w,
        ),
      ),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: (value != null && items.any((o) => o.value == value))
              ? items.firstWhere((o) => o.value == value).value
              : null,
          hint: Text(
            hint,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey.withValues(alpha: 0.6),
            ),
          ),
          style: style ?? AppTextStyles.bodyMedium.copyWith(color: AppColors.black),
          isExpanded: isExpanded,
          icon: isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                )
              : Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.grey,
                  size: iconSize ?? 20.sp,
                ),
          items: items.isEmpty ? null : items,
          onChanged: isEnabled ? onChanged : null,
          borderRadius: BorderRadius.circular(14.r),
          dropdownColor: AppColors.white,
          elevation: 8,
          menuMaxHeight: 350,
          isDense: true,
        ),
      ),
    );
  }
}
