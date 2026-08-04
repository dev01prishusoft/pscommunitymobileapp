import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class CupertinoSearchbar extends StatelessWidget {
  final String? hintText;
  final void Function()? onTapSuffix;
  final void Function(String)? onChanged;
  final TextEditingController controller;
  CupertinoSearchbar({
    Key? key,
    required this.hintText,
    required this.onChanged,
    required this.controller,
    required this.onTapSuffix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hint: Text(
            hintText.toString(),
            style: AppTextStyles.bodySmall.copyWith(
              height: 1.5,
              color: AppColors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          prefixIcon: Icon(Iconsax.search_normal_copy, size: 15),
          suffixIcon: GestureDetector(
            onTap: onTapSuffix,
            child: Icon(Iconsax.close_circle_copy, size: 20),
          ),
          contentPadding: EdgeInsets.only(bottom: 10),
        ),
      ),
    );
  }
}
