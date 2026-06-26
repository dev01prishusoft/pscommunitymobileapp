import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/profile_update_status.dart';
import 'package:pscommunitymobileapp/core/widgets/profile_update_status_badge.dart';

class AppFormDatePicker extends StatelessWidget {
  const AppFormDatePicker({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.isRequired = false,
    this.validator,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.updateStatus,
    this.originalValue,
  });
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool isRequired;
  final String? Function(String?)? validator;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ProfileUpdateStatus? updateStatus;
  final String? originalValue;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? parsedDate = initialDate;
    if (parsedDate == null && controller.text.isNotEmpty) {
      try {
        parsedDate = DateFormat('dd-MM-yyyy').parse(controller.text);
      } catch (_) {
        // Ignore parse error
      }
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: parsedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.foreground,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

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
          readOnly: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onTap: () => _selectDate(context),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.foreground),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.mutedForeground,
            ),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: AppColors.mutedForeground,
              size: 20,
            ),
            filled: true,
            fillColor: AppColors.white,
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
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              if (originalValue != null && originalValue!.trim().isEmpty) {
                // allow since originally empty
              } else {
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
