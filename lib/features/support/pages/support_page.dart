import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/constants/app_router.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/theme/app_spacing.dart';
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
        return Scaffold(
          appBar: AppBar(title: Text(LK.support.tr)),
          body: controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : support == null
              ? const Center(child: Text('No Data Found'))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: AppSpacing.pagePadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.primary, AppColors.secondary],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.support_agent_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LK.needHelp.tr,
                                    style: AppTextStyles.displaySmall.copyWith(
                                      color: Colors.white,
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    LK.ourSupportTeamDesc.tr,

                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      SizedBox(height: 28.h),
                      if (support.members.isNotEmpty) ...[
                        Text(
                          LK.supportMembers.tr,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: support.members.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final member = support.members[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  iconColor: AppColors.primary,
                                  collapsedIconColor: Colors.grey.shade400,
                                  leading: MemberAvatar(
                                    imageUrl: member.profileImage,
                                    fallbackName: _getInitials(
                                      member.displayName,
                                    ),
                                    radius: 24,
                                  ),
                                  title: Text(
                                    member.displayName,
                                    style: AppTextStyles.titleMedium.copyWith(
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  subtitle: Text(
                                    LK.representative.tr,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  childrenPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  children: [
                                    Divider(
                                      color: Colors.grey.shade100,
                                      height: 1,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            if (member.mobileNumber != null &&
                                                member
                                                    .mobileNumber!
                                                    .isNotEmpty) ...[
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.phone_rounded,
                                                    size: 16,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap: () => controller
                                                        .launchSafeUrl(
                                                          'tel:${member.mobileNumber}',
                                                        ),
                                                    child: Text(
                                                      member.mobileNumber!,
                                                      style: AppTextStyles
                                                          .bodyMedium
                                                          .copyWith(
                                                            color:
                                                                AppColors.blue,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                            if (member.email != null &&
                                                member.email!.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.email_rounded,
                                                    size: 16,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  GestureDetector(
                                                    onTap: () => controller
                                                        .launchSafeUrl(
                                                          'mailto:${member.email}',
                                                        ),
                                                    child: Text(
                                                      member.email!,
                                                      style: AppTextStyles
                                                          .bodyMedium
                                                          .copyWith(
                                                            color:
                                                                AppColors.blue,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Get.toNamed<void>(
                                              AppRouter.memberProfile,
                                              arguments: {
                                                'memberId': member.memberId,
                                              },
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                            textStyle: AppTextStyles.labelLarge
                                                .copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(0, 0),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: const Text('View Profile'),
                                        ),
                                      ],
                                    ),
                                    10.verticalSpace,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
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
    final Color themeColor = isWhatsApp
        ? const Color(0xFF25D366)
        : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: contactDetails.isNotEmpty && contactDetails != '-'
            ? () {
                if (isWhatsApp) {
                  controller.openWhatsApp(contactDetails);
                } else {
                  controller.openEmail(contactDetails);
                }
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: themeColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: themeColor.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isWhatsApp ? Icons.chat_bubble_rounded : Icons.mail_rounded,
                    color: themeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWhatsApp ? LK.whatsAppSupport.tr : LK.emailSupport.tr,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: themeColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contactDetails,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _getInitials(String name) {
  final cleanName = name.split('(').first.trim();
  final parts = cleanName
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) {
    return parts.first
        .substring(0, parts.first.length >= 2 ? 2 : 1)
        .toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
