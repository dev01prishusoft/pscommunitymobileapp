import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/profile_update_status_badge.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/profile_update_status.dart';

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
    FocusScope.of(context).requestFocus(FocusNode());
    DateTime? parsedDate = initialDate;
    if (parsedDate == null && controller.text.isNotEmpty) {
      try {
        parsedDate = DateFormat('dd-MM-yyyy').parse(controller.text);
      } catch (_) {}
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
              onSurface: AppColors.black,
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
          readOnly: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onTap: () => _selectDate(context),
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.black),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(Icons.calendar_today, size: 20, color: AppColors.grey),
          ),
          validator: (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              if (originalValue != null && originalValue!.trim().isNotEmpty) {
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
