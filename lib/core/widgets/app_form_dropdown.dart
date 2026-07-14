import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/profile_update_status_badge.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/profile_update_status.dart';

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
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.grey),
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
        Listener(
          onPointerDown: (_) => FocusScope.of(context).requestFocus(FocusNode()),
          child: DropdownButtonFormField<T>(
            key: ValueKey(value),
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
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
            ),
            validator: (val) {
              if (isRequired && val == null) {
                if (originalValue == null) {
                  return requiredErrorMessage ??
                      '${label.replaceAll('*', '').trim()} ${LK.isRequired.tr}';
                }
              }
              if (isRequired && val is String && val.trim().isEmpty) {
                if (originalValue != null &&
                    originalValue is String &&
                    (originalValue as String).trim().isEmpty) {
                } else {
                  return requiredErrorMessage ??
                      '${label.replaceAll('*', '').trim()} ${LK.isRequired.tr}';
                }
              }
              if (validator != null) {
                return validator!(val);
              }
              return null;
            },
          ),
        ),
        if (updateStatus != null)
          ProfileUpdateStatusBadge(status: updateStatus!),
      ],
    );
  }
}
