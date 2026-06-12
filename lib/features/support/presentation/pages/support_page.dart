import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/support/controller/support_controller.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SupportController>(
      initState: (state) {
        Future.microtask(() {
          state.controller?.fetchCustomerSupportDetail();
        });
      },
      builder: (controller) {
        final support = controller.supportData.value;

        if (controller.isLoading.value) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(LK.support.tr)),
          body: support == null
              ? const Center(child: Text('No Data Found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(LK.needHelp.tr, style: AppTextStyles.displaySmall),

                      SizedBox(height: 24.h),

                      controller.contactCard(
                        isWhatsApp: false,
                        contactDetails: support.contactEmail ?? '-',
                      ),

                      SizedBox(height: 12.h),

                      controller.contactCard(
                        isWhatsApp: true,
                        contactDetails: support.whatsAppNumber ?? '-',
                      ),

                      SizedBox(height: 24.h),

                      Text(
                        'Support Members',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      SizedBox(height: 12.h),

                      ...support.members.map(
                        (member) => Container(
                          margin: EdgeInsets.only(bottom: 5.h),
                          decoration: BoxDecoration(
                            color: AppColors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                member.displayName
                                    .substring(0, 1)
                                    .toUpperCase(),
                              ),
                            ),
                            title: Text(member.displayName),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
