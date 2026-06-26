import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/profile_update_status.dart';
import 'package:pscommunitymobileapp/core/widgets/profile_update_status_badge.dart';

class AppFormDropdown<T> extends StatelessWidget {
  const AppFormDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.label,
    this.hint,
    this.isRequired = false,
    this.validator,
    this.requiredErrorMessage,
    this.updateStatus,
    this.originalValue,
  });
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String label;
  final String? hint;
  final bool isRequired;
  final String? Function(T?)? validator;
  final String? requiredErrorMessage;
  final ProfileUpdateStatus? updateStatus;
  final T? originalValue;

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
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((DropdownMenuItem<T> item) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: item.child,
              );
            }).toList();
          },
          onChanged: onChanged,
          isExpanded: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.foreground),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            filled: true,
            fillColor: onChanged == null ? AppColors.surfaceVariant : AppColors.white,
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
              borderSide: BorderSide(color: AppColors.primary, width: 1.5.w),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.red),
            ),
          ),
          validator: (val) {
            if (isRequired && val == null) {
              if (originalValue == null) {
                 return requiredErrorMessage ?? '${label.replaceAll('*', '').trim()} ${LK.isRequired.tr}';
              }
            }
            if (isRequired && val is String && val.trim().isEmpty) {
              if (originalValue != null && originalValue is String && (originalValue as String).trim().isEmpty) {
                // allow it since it was originally empty
              } else {
                return requiredErrorMessage ?? '${label.replaceAll('*', '').trim()} ${LK.isRequired.tr}';
              }
            }
            if (validator != null) {
              return validator!(val);
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
