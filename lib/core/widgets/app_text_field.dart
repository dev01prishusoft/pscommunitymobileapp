import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
    this.label,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.maxLength,
    this.inputFormatters,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final String? label;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text.rich(
            TextSpan(
              children: [
                if (label!.contains('*')) ...[
                  TextSpan(
                    text: '${label!.replaceAll('*', '').trimRight()} ',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  TextSpan(
                    text: '*',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ] else ...[
                  TextSpan(
                    text: label!,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.foreground,
            fontWeight: FontWeight.w400,
            fontSize: 14.0.sp,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.mutedForeground,
              fontSize: 14.0.sp,
            ),
            prefixIcon: Icon(icon, color: AppColors.mutedForeground),
            suffixIcon: suffixIcon,
            counterText: '',
          ),
          validator: validator,
        ),
      ],
    );
  }
}
