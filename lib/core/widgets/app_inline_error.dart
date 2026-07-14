import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class AppInlineError extends StatelessWidget {
  const AppInlineError({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.red.withAlpha(24),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.red.withAlpha(60)),
      ),
      child: Row(
        children: <Widget>[
          Icon(Iconsax.info_circle_copy, color: AppColors.red, size: 18),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}
