import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pscommunitymobileapp/app/app_router.dart';
import 'package:pscommunitymobileapp/core/auth/auth_state.dart';
import 'package:pscommunitymobileapp/core/config/app_environment.dart';
import 'package:pscommunitymobileapp/core/localization/translation_keys.dart';
import 'package:pscommunitymobileapp/core/theme/app_text_styles.dart';
import 'package:pscommunitymobileapp/core/theme/app_theme.dart';
import 'package:pscommunitymobileapp/core/widgets/app_primary_button.dart';
import 'package:pscommunitymobileapp/core/widgets/app_snackbar.dart';
import 'package:pscommunitymobileapp/core/widgets/app_webview_page.dart';
import 'package:pscommunitymobileapp/core/widgets/cached_img.dart';
import 'package:pscommunitymobileapp/core/network/api_client.dart';
import 'package:pscommunitymobileapp/core/storage/token_manager.dart';
import 'package:pscommunitymobileapp/features/member/domain/entities/member.dart';
import 'package:pscommunitymobileapp/features/samaj/presentation/controllers/samaj_controller.dart';

class DrawerUserController extends GetxController with WidgetsBindingObserver {
  final Rx<Member?> member = Rx<Member?>(null);
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    fetchUser();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (Get.context == null) return;
      fetchUser();
    }
  }

  Future<void> fetchUser() async {
    try {
      isLoading.value = true;
      final tokenManager = Get.find<TokenManager>();
      final memberId = tokenManager.memberId;
      if (memberId != null) {
        final apiClient = Get.find<ApiClient>();
        final response = await apiClient.getParsed<Member>(
          '/api/v1/member/$memberId',
          fromJsonT: (json) => Member.fromJson(json as Map<String, dynamic>),
        );
        member.value = response.dataOrNull?.data;
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final samajController = Get.find<SamajController>();
    final authState = Get.find<AuthState>();
    final userController = Get.put(DrawerUserController(), permanent: true);

    return SafeArea(
      top: false,
      bottom: true,
      child: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: Obx(() {
                if (userController.isLoading.value) {
                  return Container(
                    width: 64.w,
                    height: 64.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }
                final userPic =
                    userController.member.value?.profilePhotoFullUrl;
                final logoUrl = userPic?.isNotEmpty == true
                    ? userPic
                    : samajController.samaj.value?.logoUrl;
                return Container(
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: logoUrl != null && logoUrl.isNotEmpty
                        ? CachedImg(
                            url: logoUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/prishusoft_logo.png',
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/images/prishusoft_logo.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                );
              }),
              accountName: Obx(() {
                if (userController.isLoading.value) {
                  return Text(
                    '...',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.white,
                    ),
                  );
                }
                final member = userController.member.value;
                final name = member != null
                    ? '${member.firstName} ${member.lastName}'
                    : (samajController.samaj.value?.name ?? LK.samajName.tr);
                return Text(
                  name,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.white,
                  ),
                );
              }),
              accountEmail: const SizedBox.shrink(),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.home_outlined,
                      color: AppColors.primary,
                    ),
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
                    leading: Icon(
                      Icons.favorite_outline,
                      color: AppColors.primary,
                    ),
                    title: Text(LK.marriage.tr),
                    onTap: () => Get.toNamed<void>(AppRouter.marriage),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.edit_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(LK.editProfile.tr),
                    onTap: () => Get.toNamed<void>(AppRouter.editProfile),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.corporate_fare_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(LK.samajSansthas.tr),
                    onTap: () {
                      Get.back<void>();
                      Get.toNamed<void>(AppRouter.samajSansthas);
                    },
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
                    leading: Icon(
                      Icons.groups_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(LK.addedMembers.tr),
                    onTap: () => Get.toNamed<void>(AppRouter.addedMembers),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.primary,
                    ),
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
                    leading: Icon(
                      Icons.gavel_outlined,
                      color: AppColors.primary,
                    ),
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
                ],
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(
                Icons.person_remove_alt_1_outlined,
                color: AppColors.red,
              ),
              title: Text(
                LK.deleteAccount.tr,
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.red),
              ),
              onTap: () {
                Get.back<void>();
                _showDeleteAccountDialog(context, authState);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout_rounded, color: AppColors.red),
              title: Text(
                LK.logout.tr,
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.red),
              ),
              onTap: () {
                Get.back<void>();
                _showLogoutDialog(context, authState);
              },
            ),
            SizedBox(height: 20.h),
          ],
        ),
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
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
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
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.red),
        ),
        content: Text(LK.deleteAccountConfirm.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              LK.cancel.tr,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey),
            ),
          ),
          SizedBox(width: 8.w),
          ElevatedButton(
            onPressed: () {
              Get.back<void>();
              authState.deleteAccountAndRedirect();
              PSDelightToastBar(
                snackbarDuration: const Duration(seconds: 3),
                builder: (context) => ToastCard(
                  title: LK.accountDeleted.tr,
                  subtitle: LK.accountDeletedBody.tr,
                ),
              ).show();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
              elevation: 0,
              minimumSize: Size(120, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              LK.deleteAccount.tr,
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
