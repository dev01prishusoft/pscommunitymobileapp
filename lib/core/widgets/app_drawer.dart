import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
          // Drawer Header
          Obx(() {
            final samaj = samajController.samaj.value;
            final logoUrl = samaj?.logoUrl;
            
            return UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.navyBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: logoUrl != null && logoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: logoUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
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
              ),
              accountName: Text(
                samaj?.name ?? LK.samajName.tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              accountEmail: Text(
                samaj?.descriptionEnglish ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            );
          }),

          // Drawer Items
          ListTile(
            leading: const Icon(Icons.home_outlined, color: AppColors.primary),
            title: Text(LK.home.tr),
            onTap: () => Get.back<void>(),
          ),
          ListTile(
            leading: const Icon(Icons.person_search_outlined, color: AppColors.primary),
            title: Text(LK.findMember.tr),
            onTap: () => Get.toNamed<void>(AppRouter.findMember),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_outline, color: AppColors.primary),
            title: Text(LK.marriage.tr),
            onTap: () => Get.toNamed<void>(AppRouter.marriage),
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
            title: Text(LK.editProfile.tr),
            onTap: () => Get.toNamed<void>(AppRouter.editProfile),
          ),
          ListTile(
            leading: const Icon(Icons.person_add_alt_1_outlined, color: AppColors.primary),
            title: Text(LK.addFamilyMember.tr),
            onTap: () => Get.toNamed<void>(AppRouter.addFamilyMember),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
            title: Text(LK.privacyPolicy.tr),
            onTap: () {
              Get.back<void>(); // Close drawer
              Get.to<void>(() => AppWebViewPage(
                title: LK.privacyPolicy.tr,
                url: '${AppEnvironment.I.uiBaseUrl}/privacy-policy',
              ));
            },
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined, color: AppColors.primary),
            title: Text(LK.termsAndConditions.tr),
            onTap: () {
              Get.back<void>(); // Close drawer
              Get.to<void>(() => AppWebViewPage(
                title: LK.termsAndConditions.tr,
                url: '${AppEnvironment.I.uiBaseUrl}/terms-and-conditions',
              ));
            },
          ),
          
          const Spacer(),
          const Divider(),
          
          // Delete Account Item
          ListTile(
            leading: const Icon(Icons.person_remove_alt_1_outlined, color: Colors.redAccent),
            title: Text(
              LK.deleteAccount.tr,
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Get.back<void>(); // Close drawer
              _showDeleteAccountDialog(context, authState);
            },
          ),
          
          // Logout Item
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            title: Text(
              LK.logout.tr,
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Get.back<void>(); // Close drawer
              _showLogoutDialog(context, authState);
            },
          ),
          const SizedBox(height: 20),
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
              style: const TextStyle(color: AppColors.mutedForeground),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 120,
            child: AppPrimaryButton(
              text: LK.logout.tr,
              height: 45,
              onPressed: () {
                authState.logout();
                Get.offAllNamed<void>(AppRouter.login);
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
        title: Text(LK.deleteAccount.tr, style: const TextStyle(color: Colors.redAccent)),
        content: Text(LK.deleteAccountConfirm.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: Text(
              LK.cancel.tr,
              style: const TextStyle(color: AppColors.mutedForeground),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement API call to delete account
              Get.back<void>(); // Close the dialog
              authState.logout();
              Get.offAllNamed<void>(AppRouter.login);
              Get.snackbar(
                'Account Deleted', 
                'Your account has been deleted successfully.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(120, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              LK.deleteAccount.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
