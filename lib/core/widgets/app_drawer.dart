import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';
import 'package:pscommunitymobileapp/core/config/app_environment.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_webview_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final samajController = Get.find<SamajController>();
    final authState = Get.find<AuthState>();

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.navyBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: Obx(() {
              final logoUrl = samajController.samaj.value?.logoUrl;
              return CircleAvatar(
                backgroundColor: AppColors.white,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: logoUrl != null && logoUrl.isNotEmpty
                      ? CachedImg(
                          url: logoUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/prishusoft_logo.png',
                            fit: BoxFit.contain,
                          ),
                        )
                      : Image.asset(
                          'assets/images/prishusoft_logo.png',
                          fit: BoxFit.contain,
                        ),
                ),
              );
            }),
            accountName: Obx(
              () => Text(
                samajController.samaj.value?.name ?? LK.samajName.tr,
                style: AppTextStyles.titleLarge,
              ),
            ),
            accountEmail: Obx(
              () => Text(
                samajController.samaj.value?.descriptionEnglish ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home_outlined, color: AppColors.primary),
            title: Text(LK.home.tr),
            onTap: () => Get.back<void>(),
          ),
          ListTile(
            leading: Icon(
              Icons.person_search_outlined,
              color: AppColors.primary,
            ),
            title: Text(LK.findMember.tr),
            onTap: () => Get.toNamed<void>(AppRouter.findMember),
          ),
          ListTile(
            leading: Icon(Icons.favorite_outline, color: AppColors.primary),
            title: Text(LK.marriage.tr),
            onTap: () => Get.toNamed<void>(AppRouter.marriage),
          ),
          ListTile(
            leading: Icon(Icons.edit_outlined, color: AppColors.primary),
            title: Text(LK.editProfile.tr),
            onTap: () => Get.toNamed<void>(AppRouter.editProfile),
          ),
          ListTile(
            leading: Icon(
              Icons.person_add_alt_1_outlined,
              color: AppColors.primary,
            ),
            title: Text(LK.addFamilyMember.tr),
            onTap: () => Get.toNamed<void>(AppRouter.addFamilyMember),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
            title: Text(LK.privacyPolicy.tr),
            onTap: () {
              Get.back<void>();
              Get.to<void>(
                () => AppWebViewPage(
                  title: LK.privacyPolicy.tr,
                  url: AppEnvironment.I.privacyPolicyUrl,
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.gavel_outlined, color: AppColors.primary),
            title: Text(LK.termsAndConditions.tr),
            onTap: () {
              Get.back<void>();
              Get.to<void>(
                () => AppWebViewPage(
                  title: LK.termsAndConditions.tr,
                  url: AppEnvironment.I.termsAndConditionsUrl,
                ),
              );
            },
          ),

          Spacer(),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.person_remove_alt_1_outlined,
              color: AppColors.redAccent,
            ),
            title: Text(
              LK.deleteAccount.tr,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.redAccent,
              ),
            ),
            onTap: () {
              Get.back<void>();
              _showDeleteAccountDialog(context, authState);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout_rounded, color: AppColors.redAccent),
            title: Text(
              LK.logout.tr,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.redAccent,
              ),
            ),
            onTap: () {
              Get.back<void>();
              _showLogoutDialog(context, authState);
            },
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthState authState) {
    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(LK.logout.tr),
        content: Text(LK.logoutConfirm.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              LK.cancel.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 120.w,
            child: AppPrimaryButton(
              text: LK.logout.tr,
              height: 45.h,
              onPressed: () {
                Get.back<void>();
                authState.logoutAndRedirect();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthState authState) {
    Get.dialog<void>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          LK.deleteAccount.tr,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.redAccent),
        ),
        content: Text(LK.deleteAccountConfirm.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              LK.cancel.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: () {
              Get.back<void>();
              authState.logoutAndRedirect();
              Get.snackbar(
                'Account Deleted',
                'Your account has been deleted successfully.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redAccent,
              foregroundColor: AppColors.white,
              elevation: 0,
              minimumSize: Size(120, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(LK.deleteAccount.tr, style: AppTextStyles.labelLarge),
          ),
        ],
      ),
    );
  }
}
