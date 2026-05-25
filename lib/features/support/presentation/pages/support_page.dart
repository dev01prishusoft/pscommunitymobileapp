import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LK.support.tr)),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(LK.needHelp.tr, style: AppTextStyles.displaySmall),
              SizedBox(height: 20.h),
              Text(LK.supportEmail.tr),
              Text(LK.supportPhone.tr),
              SizedBox(height: 10.h),
              Text(LK.supportHours.tr),
            ],
          ),
        ),
      ),
    );
  }
}
