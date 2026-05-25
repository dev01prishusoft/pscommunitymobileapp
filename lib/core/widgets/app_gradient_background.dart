import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';

class AppGradientBackground extends StatelessWidget {
  const AppGradientBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFFFFF), AppColors.accent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300.w,
            height: 300.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 200.w,
            height: 200.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
