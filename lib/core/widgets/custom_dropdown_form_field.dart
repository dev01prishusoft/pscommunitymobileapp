import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  const CustomDropdownFormField({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hint,
    this.isEnabled = true,
    this.validator,
    this.isExpanded = true,
    this.padding,
    this.icon,
    this.selectedItemBuilder,
    this.menuMaxHeight,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final bool isEnabled;
  final String? Function(T?)? validator;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final DropdownButtonBuilder? selectedItemBuilder;
  final double? menuMaxHeight;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      items: items,
      selectedItemBuilder: selectedItemBuilder,
      menuMaxHeight: menuMaxHeight,
      onChanged: isEnabled ? onChanged : null,
      isExpanded: isExpanded,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.black),
      dropdownColor: AppColors.white,
      icon: icon ??
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.grey,
            size: 20.sp,
          ),
      hint: hint != null
          ? Text(
              hint!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey.withValues(alpha: 0.6),
              ),
            )
          : null,
      validator: validator ?? (val) => val == null ? LK.fieldRequired.tr : null,
      decoration: InputDecoration(
        contentPadding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        filled: true,
        fillColor: isEnabled ? AppColors.white : AppColors.grey.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: AppColors.grey.withValues(alpha: 0.15),
            width: 1.2.w,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: value != null
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.grey.withValues(alpha: 0.25),
            width: 1.2.w,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 1.2.w,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: AppColors.red,
            width: 1.2.w,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(
            color: AppColors.grey.withValues(alpha: 0.15),
            width: 1.2.w,
          ),
        ),
      ),
    );
  }
}
