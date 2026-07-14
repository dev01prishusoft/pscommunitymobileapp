import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/profile_update_status_badge.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/profile_update_status.dart';

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
    this.updateStatus,
    this.originalValue,
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
  final ProfileUpdateStatus? updateStatus;
  final String? originalValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey),
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
        ).paddingOnly(left: 5.w, bottom: 6.h),
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
          buildCounter:
              (
                context, {
                required currentLength,
                required isFocused,
                maxLength,
              }) => null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: AppTextStyles.bodyMedium.copyWith(
            color: readOnly ? AppColors.grey : AppColors.black,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? IconTheme(
                    data: const IconThemeData(size: 20),
                    child: prefixIcon!,
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? IconTheme(
                    data: const IconThemeData(size: 20),
                    child: suffixIcon!,
                  )
                : null,
          ),
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              if (originalValue == null || originalValue!.trim().isNotEmpty) {
                return '${label.replaceAll('*', '').trim()} ${LK.isRequired.tr}';
              }
            }
            if (validator != null) {
              return validator!(value);
            }
            return null;
          },
        ),
        if (updateStatus != null)
          ProfileUpdateStatusBadge(status: updateStatus!),
      ],
    );
  }
}
