import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class SponsoredLabel extends StatelessWidget {
  final Color? backgroundColor;
  final Color? textColor;

  const SponsoredLabel({
    super.key,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: LK.sponsored.tr,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(4.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 0.5,
          ),
        ),
        child: Text(
          LK.sponsored.tr.toUpperCase(),
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: textColor ?? Colors.white,
          ),
        ),
      ),
    );
  }
}
