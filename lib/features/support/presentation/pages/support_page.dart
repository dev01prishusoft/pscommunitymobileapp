import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/member_avatar.dart';
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

                      _contactCard(
                        controller: controller,
                        isWhatsApp: false,
                        contactDetails: support.contactEmail ?? '-',
                      ),

                      SizedBox(height: 12.h),

                      _contactCard(
                        controller: controller,
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
                            onTap: () {
                              Get.toNamed<void>(
                                AppRouter.memberProfile,
                                arguments: {'memberId': member.memberId},
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              child: MemberAvatar(
                                imageUrl: member.profileImage,
                                fallbackName: _getInitials(member.displayName),
                                radius: 24,
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

  Widget _contactCard({
    required SupportController controller,
    required bool isWhatsApp,
    required String contactDetails,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isWhatsApp
            ? AppColors.chart2.withValues(alpha: 0.3)
            : AppColors.chart5.withValues(alpha: 0.3),
      ),
      child: ListTile(
        leading: Icon(
          isWhatsApp ? Icons.chat : Icons.email,
          color: isWhatsApp ? AppColors.chart2 : AppColors.chart5,
        ),
        title: Text(
          contactDetails,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isWhatsApp ? AppColors.chart2 : AppColors.chart5,
          ),
        ),
        subtitle: Text(
          isWhatsApp ? 'WhatsApp Support' : 'Email Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isWhatsApp ? AppColors.chart2 : AppColors.chart5,
          ),
        ),
        onTap: () {
          if (contactDetails.isEmpty) return;
          if (isWhatsApp) {
            controller.openWhatsApp(contactDetails);
          } else {
            controller.openEmail(contactDetails);
          }
        },
      ),
    );
  }
}

String _getInitials(String name) {
  final cleanName = name.split('(').first.trim();
  final parts = cleanName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) {
    return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}