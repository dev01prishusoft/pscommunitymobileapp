import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class AppFormTextField extends StatelessWidget {
  const AppFormTextField({
    super.key,
    this.controller,
    this.initialValue,
    required this.label,
    this.hint,
    this.isRequired = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onChanged,
    this.textAlign = TextAlign.start,
    this.inputFormatters,
    this.maxLength,
  });
  final TextEditingController? controller;
  final String? initialValue;
  final String label;
  final String? hint;
  final bool isRequired;
  final bool readOnly;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final void Function(String)? onChanged;
  final TextAlign textAlign;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.red,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          obscureText: obscureText,
          onChanged: onChanged,
          textAlign: textAlign,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: AppTextStyles.bodyMedium.copyWith(
            color: readOnly ? AppColors.mutedForeground : AppColors.foreground,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: readOnly ? AppColors.surfaceVariant : AppColors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: readOnly ? AppColors.border.withValues(alpha: 0.5) : AppColors.primary, 
                width: readOnly ? 1.0 : 1.5.w,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.red, width: 1.5.w),
            ),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return LK.fieldRequired.tr;
            }
            if (validator != null) {
              return validator!(value);
            }
            return null;
          },
        ),
      ],
    );
  }
}

